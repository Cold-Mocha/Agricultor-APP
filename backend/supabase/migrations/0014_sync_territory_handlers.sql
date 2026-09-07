-- Sync v2 territory wave: parcel geometry and sector aggregates.
create or replace function public.sync_push(operations jsonb)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
declare
  operation jsonb;
  payload jsonb;
  operation_uuid uuid;
  aggregate_uuid uuid;
  request_hash_value text;
  receipt public.sync_operations%rowtype;
  current_parcel public.parcels%rowtype;
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
      elsif operation->>'aggregate_type' not in ('parcel', 'sector') then
        result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'aggregate_unsupported');
      elsif coalesce((operation->>'payload_schema_version')::integer, 0) <> 1
          or jsonb_typeof(payload) <> 'object'
          or payload->>'id' is distinct from operation->>'aggregate_id' then
        result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'payload_invalid');
      elsif operation->>'aggregate_type' = 'parcel' then
        select * into current_parcel from public.parcels
        where id = aggregate_uuid and owner_id = auth.uid() for update;
        if found and operation->>'base_version' is not null
           and current_parcel.version <> (operation->>'base_version')::bigint then
          result_row := jsonb_build_object(
            'operation_id', operation_uuid, 'status', 'conflict',
            'remote_version', current_parcel.version, 'error_code', 'version_conflict'
          );
        else
          next_version := case when found then current_parcel.version + 1 else 1 end;
          geometry_value := null;
          if jsonb_typeof(payload->'polygon') = 'array' and jsonb_array_length(payload->'polygon') >= 3 then
            select jsonb_agg(jsonb_build_array((point->>'lng')::double precision, (point->>'lat')::double precision) order by ordinal)
              into coordinates
              from jsonb_array_elements(payload->'polygon') with ordinality as points(point, ordinal);
            coordinates := coordinates || jsonb_build_array(coordinates->0);
            geometry_value := extensions.st_setsrid(
              extensions.st_geomfromgeojson(jsonb_build_object('type','Polygon','coordinates',jsonb_build_array(coordinates))::text),
              4326
            );
            if not extensions.st_isvalid(geometry_value) or extensions.st_area(geometry_value::extensions.geography) <= 0 then
              raise exception 'parcel_geometry_invalid';
            end if;
          end if;
          if coalesce((payload->>'is_active')::boolean, false) then
            update public.parcels set is_active = false
            where owner_id = auth.uid() and id <> aggregate_uuid and is_active;
          end if;
          insert into public.parcels(
            id, owner_id, name, locality, is_active, is_archived,
            version, updated_at, deleted_at, boundary
          ) values (
            aggregate_uuid, auth.uid(), coalesce(nullif(trim(payload->>'name'), ''), 'Parcela'),
            payload->>'locality', coalesce((payload->>'is_active')::boolean, false),
            coalesce((payload->>'is_archived')::boolean, false), next_version,
            coalesce((payload->>'updated_at')::timestamptz, now()),
            case when operation->>'mutation_kind' = 'delete'
              then coalesce((payload->>'deleted_at')::timestamptz, now()) else null end,
            geometry_value
          ) on conflict (id) do update set
            name = excluded.name, locality = excluded.locality,
            is_active = excluded.is_active, is_archived = excluded.is_archived,
            version = excluded.version, updated_at = excluded.updated_at,
            deleted_at = excluded.deleted_at,
            boundary = coalesce(excluded.boundary, public.parcels.boundary);

          payload := payload || jsonb_build_object('version', next_version);
          insert into public.sync_changes(owner_id, aggregate_type, aggregate_id, mutation_kind, payload, remote_version)
          values (auth.uid(), 'parcel', aggregate_uuid, operation->>'mutation_kind', payload, next_version)
          returning change_seq into change_number;
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'applied', 'remote_version', next_version, 'change_seq', change_number);
          insert into public.sync_operations(owner_id, operation_id, aggregate_type, aggregate_id, request_hash, protocol_version, status, result)
          values (auth.uid(), operation_uuid, 'parcel', aggregate_uuid, request_hash_value, 2, 'applied', result_row);
        end if;
      else
        if payload->>'parcel_id' is null
           or jsonb_typeof(payload->'polygon') <> 'array'
           or jsonb_array_length(payload->'polygon') < 3
           or coalesce((payload->>'number')::integer, 0) <= 0
           or nullif(trim(payload->>'name'), '') is null then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'payload_invalid');
        elsif not exists (
          select 1 from public.parcels
          where id = (payload->>'parcel_id')::uuid and owner_id = auth.uid() and deleted_at is null
        ) then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'parent_missing');
        else
          select * into current_sector from public.sectors
          where id = aggregate_uuid and owner_id = auth.uid() for update;
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
              id, owner_id, parcel_id, number, name, kind, boundary, version, updated_at, deleted_at
            ) values (
              aggregate_uuid, auth.uid(), (payload->>'parcel_id')::uuid,
              (payload->>'number')::integer, trim(payload->>'name'),
              coalesce(nullif(payload->>'kind',''), 'crop'), geometry_value, next_version,
              coalesce((payload->>'updated_at')::timestamptz, now()),
              case when operation->>'mutation_kind' in ('delete','archive')
                then coalesce((payload->>'deleted_at')::timestamptz, now()) else null end
            ) on conflict (id) do update set
              parcel_id = excluded.parcel_id, number = excluded.number,
              name = excluded.name, kind = excluded.kind, boundary = excluded.boundary,
              version = excluded.version, updated_at = excluded.updated_at,
              deleted_at = excluded.deleted_at;

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
          when sqlerrm like '%sector_outside_parcel%' then 'sector_outside_parcel'
          when sqlstate = '22P02' then 'payload_invalid'
          else 'operation_invalid' end
      );
    end;
    results := results || jsonb_build_array(result_row);
  end loop;
  return jsonb_build_object('protocol_version', 2, 'results', results);
end $$;
