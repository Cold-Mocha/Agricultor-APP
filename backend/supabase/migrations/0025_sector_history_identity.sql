-- F01: immutable historical numbering and explicit sector mutations.
create or replace function public.sync_push_territory_v2(operations jsonb)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
declare
  operation jsonb;
  payload jsonb;
  operation_uuid uuid;
  aggregate_uuid uuid;
  request_hash_value text;
  receipt public.sync_operations%rowtype;
  current_sector public.sectors%rowtype;
  next_version bigint;
  change_number bigint;
  result_row jsonb;
  results jsonb := '[]'::jsonb;
  coordinates jsonb;
  geometry_value extensions.geometry;
begin
  if auth.uid() is null then raise exception 'authentication_required'; end if;
  if jsonb_typeof(operations) <> 'array' or jsonb_array_length(operations) not between 1 and 25 then
    raise exception 'operations_batch_invalid';
  end if;

  for operation in select value from jsonb_array_elements(operations)
  loop
    begin
      operation_uuid := (operation->>'operation_id')::uuid;
      aggregate_uuid := (operation->>'aggregate_id')::uuid;
      payload := operation->'payload';
      request_hash_value := coalesce(nullif(operation->>'request_hash', ''), md5(operation::text));

      select * into receipt from public.sync_operations
      where owner_id = auth.uid() and operation_id = operation_uuid;
      if found then
        if receipt.request_hash is distinct from request_hash_value then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'idempotency_mismatch');
        else
          result_row := receipt.result || jsonb_build_object('operation_id', operation_uuid, 'status', 'duplicate');
        end if;
      elsif coalesce((operation->>'protocol_version')::integer, 0) <> 2 then
        result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'protocol_version_unsupported');
      elsif operation->>'aggregate_type' <> 'sector' then
        result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'aggregate_unsupported');
      elsif coalesce((operation->>'payload_schema_version')::integer, 0) <> 1
          or jsonb_typeof(payload) <> 'object'
          or payload->>'id' is distinct from operation->>'aggregate_id' then
        result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'payload_invalid');
      else
        if jsonb_typeof(payload->'polygon') <> 'array'
           or jsonb_array_length(payload->'polygon') < 3
           or coalesce((payload->>'number')::integer, 0) <= 0
           or nullif(trim(payload->>'name'), '') is null then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'payload_invalid');
        else
          if exists (select 1 from public.sectors where id = aggregate_uuid and owner_id <> auth.uid()) then
              raise exception 'identity_unavailable';
            end if;
            select * into current_sector from public.sectors
          where id = aggregate_uuid and owner_id = auth.uid() for update;
          if operation->>'mutation_kind' is null or operation->>'mutation_kind' not in ('create','update','delete','archive') then
            raise exception 'mutation_invalid';
          elsif current_sector.id is null and operation->>'mutation_kind' <> 'create' then
            raise exception 'sector_missing';
          elsif current_sector.id is not null and operation->>'mutation_kind' = 'create' then
            raise exception 'sector_exists';
          elsif current_sector.deleted_at is not null then
            raise exception 'sector_retired';
          elsif current_sector.id is not null and current_sector.number <> (payload->>'number')::integer then
            raise exception 'sector_number_immutable';
          elsif operation->>'mutation_kind' in ('create','update') and nullif(payload->>'deleted_at','') is not null then
            raise exception 'sector_transition_invalid';
          end if;
          if found and operation->>'base_version' is not null
             and current_sector.version <> (operation->>'base_version')::bigint then
            result_row := jsonb_build_object(
              'operation_id', operation_uuid, 'status', 'conflict',
              'remote_version', current_sector.version, 'error_code', 'version_conflict'
            );
          else
            -- Preserve the result of the row lookup before subsequent SELECTs
            -- change PL/pgSQL's FOUND flag.
            next_version := case when found then current_sector.version + 1 else 1 end;
            select jsonb_agg(jsonb_build_array((point->>'lng')::double precision, (point->>'lat')::double precision) order by ordinal)
              into coordinates
              from jsonb_array_elements(payload->'polygon') with ordinality as points(point, ordinal);
            coordinates := coordinates || jsonb_build_array(coordinates->0);
            geometry_value := extensions.st_setsrid(
              extensions.st_geomfromgeojson(jsonb_build_object('type','Polygon','coordinates',jsonb_build_array(coordinates))::text),
              4326
            );
            if not extensions.st_isvalid(geometry_value) or extensions.st_area(geometry_value::extensions.geography) <= 0 then
              raise exception 'sector_geometry_invalid';
            end if;
            insert into public.sectors(
              id, owner_id, number, name, kind, boundary, version, updated_at, deleted_at
            ) values (
              aggregate_uuid, auth.uid(),
              (payload->>'number')::integer, trim(payload->>'name'),
              coalesce(nullif(payload->>'kind',''), 'crop'), geometry_value, next_version,
              coalesce((payload->>'updated_at')::timestamptz, now()),
              case when operation->>'mutation_kind' in ('delete','archive')
                then coalesce((payload->>'deleted_at')::timestamptz, now()) else null end
            ) on conflict (id) do update set
              number = excluded.number,
              name = excluded.name, kind = excluded.kind, boundary = excluded.boundary,
              version = excluded.version, updated_at = excluded.updated_at,
              deleted_at = excluded.deleted_at
              where sectors.owner_id = excluded.owner_id;
            if not found then raise exception 'identity_unavailable'; end if;

            payload := payload || jsonb_build_object(
              'version', next_version,
              'area_square_meters', extensions.st_area(geometry_value::extensions.geography)
            );
            insert into public.sync_changes(owner_id, aggregate_type, aggregate_id, mutation_kind, payload, remote_version)
            values (auth.uid(), 'sector', aggregate_uuid, operation->>'mutation_kind', payload, next_version)
            returning change_seq into change_number;
            result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'applied', 'remote_version', next_version, 'change_seq', change_number);
            insert into public.sync_operations(owner_id, operation_id, aggregate_type, aggregate_id, request_hash, protocol_version, status, result)
            values (auth.uid(), operation_uuid, 'sector', aggregate_uuid, request_hash_value, 2, 'applied', result_row);
          end if;
        end if;
      end if;
    exception when others then
      result_row := jsonb_build_object(
        'operation_id', operation->>'operation_id', 'status', 'rejected',
        'error_code', case
          when sqlstate = '23505' then 'uniqueness_conflict'
          when sqlstate = '22P02' then 'payload_invalid'
          else 'operation_invalid' end
      );
    end;
    results := results || jsonb_build_array(result_row);
  end loop;
  return jsonb_build_object('protocol_version', 2, 'results', results);
end $$;


create or replace function public.protect_sector_history()
returns trigger language plpgsql set search_path = public, pg_temp as $$
begin
  if tg_op = 'DELETE' then
    -- Administrative cleanup/account removal uses postgres with no user claim.
    if auth.uid() is not null or current_user = 'authenticated' then
      raise exception 'sector_physical_delete_forbidden' using errcode = '23514';
    end if;
    return old;
  end if;
  if new.number is distinct from old.number then
    raise exception 'sector_number_immutable' using errcode = '23514';
  end if;
  if old.deleted_at is not null then
    raise exception 'sector_retired' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger sectors_history_immutable before update or delete on public.sectors
  for each row execute function public.protect_sector_history();
revoke all on function public.protect_sector_history() from public, anon, authenticated;
