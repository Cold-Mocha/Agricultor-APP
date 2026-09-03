-- Sync v2 labor aggregate. Production is an atomic child of a harvest labor.
alter function public.sync_push(jsonb) rename to sync_push_seasons_crops_v2;

create or replace function public.sync_push(operations jsonb)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
declare
  operation jsonb;
  payload jsonb;
  production jsonb;
  operation_uuid uuid;
  aggregate_uuid uuid;
  request_hash_value text;
  receipt public.sync_operations%rowtype;
  current_labor public.labors%rowtype;
  next_version bigint;
  change_number bigint;
  result_row jsonb;
  results jsonb := '[]'::jsonb;
begin
  if auth.uid() is null then raise exception 'authentication_required'; end if;
  if jsonb_typeof(operations) <> 'array' or jsonb_array_length(operations) not between 1 and 25 then
    raise exception 'operations_batch_invalid';
  end if;

  for operation in select value from jsonb_array_elements(operations)
  loop
    begin
      if operation->>'aggregate_type' <> 'labor' then
        result_row := public.sync_push_seasons_crops_v2(jsonb_build_array(operation))->'results'->0;
      else
        operation_uuid := (operation->>'operation_id')::uuid;
        aggregate_uuid := (operation->>'aggregate_id')::uuid;
        payload := operation->'payload';
        production := payload->'production';
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
        elsif coalesce((operation->>'payload_schema_version')::integer, 0) <> 1
            or jsonb_typeof(payload) <> 'object'
            or payload->>'id' is distinct from operation->>'aggregate_id'
            or payload->>'parcel_id' is null or payload->>'sector_id' is null
            or payload->>'agricultural_season_id' is null or payload->>'crop_assignment_id' is null
            or payload->>'type' not in ('irrigation','soil','fertilization','diseaseAndPestControl','sowing','pruning','harvest','apiary','other')
            or jsonb_typeof(payload->'details') <> 'object'
            or payload->>'occurred_at' is null then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'labor_payload_invalid');
        elsif not exists (
          select 1 from public.sectors sec
          join public.parcels p on p.id = sec.parcel_id and p.owner_id = auth.uid()
          join public.agricultural_seasons season on season.id = (payload->>'agricultural_season_id')::uuid
          join public.crop_seasons assignment on assignment.id = (payload->>'crop_assignment_id')::uuid
          where sec.id = (payload->>'sector_id')::uuid and sec.owner_id = auth.uid()
            and p.id = (payload->>'parcel_id')::uuid
            and season.owner_id = auth.uid() and season.parcel_id = p.id
            and assignment.owner_id = auth.uid() and assignment.sector_id = sec.id
            and assignment.agricultural_season_id = season.id
            and p.deleted_at is null and sec.deleted_at is null
            and season.deleted_at is null and assignment.deleted_at is null
        ) then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'labor_parent_missing');
        elsif production is not null and (
          payload->>'type' <> 'harvest' or jsonb_typeof(production) <> 'object'
          or production->>'id' is null or production->>'crop_id' is null
          or coalesce((production->>'quantity')::double precision, 0) <= 0
          or nullif(trim(production->>'unit'), '') is null
          or production->>'harvested_at' is null
          or production->>'labor_id' is distinct from payload->>'id'
        ) then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'production_payload_invalid');
        else
          select * into current_labor from public.labors
          where id = aggregate_uuid and owner_id = auth.uid() for update;
          if found and operation->>'base_version' is not null
             and current_labor.version <> (operation->>'base_version')::bigint then
            result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'conflict', 'remote_version', current_labor.version, 'error_code', 'version_conflict');
          else
            next_version := case when found then current_labor.version + 1 else 1 end;
            insert into public.labors(
              id, owner_id, parcel_id, sector_id, season_id, agricultural_season_id,
              crop_assignment_id, type, custom_name, details, details_schema_version,
              status, supersedes_labor_id, notes, occurred_at, version, updated_at, deleted_at
            ) values (
              aggregate_uuid, auth.uid(), (payload->>'parcel_id')::uuid,
              (payload->>'sector_id')::uuid, (payload->>'crop_assignment_id')::uuid,
              (payload->>'agricultural_season_id')::uuid, (payload->>'crop_assignment_id')::uuid,
              payload->>'type', payload->>'custom_name', payload->'details',
              coalesce((payload->>'details_schema_version')::integer, 1),
              coalesce(payload->>'status','recorded'), nullif(payload->>'supersedes_labor_id','')::uuid,
              payload->>'notes', (payload->>'occurred_at')::timestamptz, next_version,
              coalesce((payload->>'updated_at')::timestamptz, now()),
              case when operation->>'mutation_kind' = 'delete'
                then coalesce(nullif(payload->>'deleted_at','')::timestamptz, now())
                else nullif(payload->>'deleted_at','')::timestamptz end
            ) on conflict (id) do update set
              status = excluded.status, supersedes_labor_id = excluded.supersedes_labor_id,
              details = excluded.details, details_schema_version = excluded.details_schema_version,
              notes = excluded.notes, occurred_at = excluded.occurred_at,
              version = excluded.version, updated_at = excluded.updated_at,
              deleted_at = excluded.deleted_at;

            if production is not null then
              insert into public.production_records(
                id, owner_id, parcel_id, sector_id, labor_id, season_id, crop_id,
                quantity, unit, quality_notes, harvested_at, updated_at
              ) values (
                (production->>'id')::uuid, auth.uid(), (payload->>'parcel_id')::uuid,
                (payload->>'sector_id')::uuid, aggregate_uuid,
                (payload->>'crop_assignment_id')::uuid, production->>'crop_id',
                (production->>'quantity')::double precision, trim(production->>'unit'),
                production->>'quality_notes', (production->>'harvested_at')::timestamptz,
                coalesce((production->>'updated_at')::timestamptz, now())
              ) on conflict (id) do update set
                quantity = excluded.quantity, unit = excluded.unit,
                quality_notes = excluded.quality_notes, harvested_at = excluded.harvested_at,
                updated_at = excluded.updated_at;
            end if;

            payload := payload || jsonb_build_object('version', next_version);
            insert into public.sync_changes(owner_id, aggregate_type, aggregate_id, mutation_kind, payload, remote_version)
            values (auth.uid(), 'labor', aggregate_uuid, operation->>'mutation_kind', payload, next_version)
            returning change_seq into change_number;
            result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'applied', 'remote_version', next_version, 'change_seq', change_number);
            insert into public.sync_operations(owner_id, operation_id, aggregate_type, aggregate_id, request_hash, protocol_version, status, result)
            values (auth.uid(), operation_uuid, 'labor', aggregate_uuid, request_hash_value, 2, 'applied', result_row);
          end if;
        end if;
      end if;
    exception when unique_violation then
      result_row := jsonb_build_object('operation_id', operation->>'operation_id', 'status', 'rejected', 'error_code', 'uniqueness_conflict');
    when others then
      result_row := jsonb_build_object(
        'operation_id', operation->>'operation_id', 'status', 'rejected',
        'error_code', case when sqlstate = '22P02' then 'payload_invalid' else 'operation_invalid' end
      );
    end;
    results := results || jsonb_build_array(result_row);
  end loop;
  return jsonb_build_object('protocol_version', 2, 'results', results);
end $$;
