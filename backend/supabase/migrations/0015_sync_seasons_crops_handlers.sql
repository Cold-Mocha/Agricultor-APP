-- Sync v2 wave for agricultural seasons, custom crops and crop assignments.
alter function public.sync_push(jsonb) rename to sync_push_territory_v2;

create or replace function public.sync_push(operations jsonb)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
declare
  operation jsonb;
  payload jsonb;
  operation_uuid uuid;
  aggregate_uuid uuid;
  aggregate_type_value text;
  request_hash_value text;
  receipt public.sync_operations%rowtype;
  current_season public.agricultural_seasons%rowtype;
  current_crop public.custom_crops%rowtype;
  current_assignment public.crop_seasons%rowtype;
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
      aggregate_type_value := operation->>'aggregate_type';
      if aggregate_type_value in ('parcel', 'sector') then
        result_row := public.sync_push_territory_v2(jsonb_build_array(operation))->'results'->0;
      else
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
        elsif aggregate_type_value not in ('agriculturalSeason', 'customCrop', 'sectorCropAssignment') then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'aggregate_unsupported');
        elsif coalesce((operation->>'payload_schema_version')::integer, 0) <> 1
            or jsonb_typeof(payload) <> 'object'
            or payload->>'id' is distinct from operation->>'aggregate_id' then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'payload_invalid');
        elsif aggregate_type_value = 'agriculturalSeason' then
          if nullif(trim(payload->>'name'), '') is null
             or payload->>'parcel_id' is null
             or payload->>'starts_on' is null
             or payload->>'status' not in ('planned','active','closed')
             or not exists (
               select 1 from public.parcels
               where id = (payload->>'parcel_id')::uuid and owner_id = auth.uid() and deleted_at is null
             ) then
            result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'season_payload_invalid');
          else
            select * into current_season from public.agricultural_seasons
            where id = aggregate_uuid and owner_id = auth.uid() for update;
            if found and operation->>'base_version' is not null
               and current_season.version <> (operation->>'base_version')::bigint then
              result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'conflict', 'remote_version', current_season.version, 'error_code', 'version_conflict');
            else
              next_version := case when found then current_season.version + 1 else 1 end;
              if found and current_season.status = 'closed' and payload->>'status' <> 'closed' then
                result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'season_closed');
              else
                insert into public.agricultural_seasons(
                  id, owner_id, parcel_id, name, starts_on, ends_on, status, notes,
                  is_migration_backfill, version, updated_at, deleted_at
                ) values (
                  aggregate_uuid, auth.uid(), (payload->>'parcel_id')::uuid,
                  trim(payload->>'name'), (payload->>'starts_on')::date,
                  nullif(payload->>'ends_on','')::date, payload->>'status', payload->>'notes',
                  coalesce((payload->>'is_migration_backfill')::boolean, false), next_version,
                  coalesce((payload->>'updated_at')::timestamptz, now()),
                  case when operation->>'mutation_kind' = 'delete'
                    then coalesce(nullif(payload->>'deleted_at','')::timestamptz, now())
                    else nullif(payload->>'deleted_at','')::timestamptz end
                ) on conflict (id) do update set
                  parcel_id = excluded.parcel_id, name = excluded.name,
                  starts_on = excluded.starts_on, ends_on = excluded.ends_on,
                  status = excluded.status, notes = excluded.notes,
                  version = excluded.version, updated_at = excluded.updated_at,
                  deleted_at = excluded.deleted_at;
                payload := payload || jsonb_build_object('version', next_version);
                insert into public.sync_changes(owner_id, aggregate_type, aggregate_id, mutation_kind, payload, remote_version)
                values (auth.uid(), aggregate_type_value, aggregate_uuid, operation->>'mutation_kind', payload, next_version)
                returning change_seq into change_number;
                result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'applied', 'remote_version', next_version, 'change_seq', change_number);
                insert into public.sync_operations(owner_id, operation_id, aggregate_type, aggregate_id, request_hash, protocol_version, status, result)
                values (auth.uid(), operation_uuid, aggregate_type_value, aggregate_uuid, request_hash_value, 2, 'applied', result_row);
              end if;
            end if;
          end if;
        elsif aggregate_type_value = 'customCrop' then
          if nullif(trim(payload->>'name'), '') is null
             or nullif(trim(payload->>'normalized_name'), '') is null then
            result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'custom_crop_payload_invalid');
          else
            select * into current_crop from public.custom_crops
            where id = aggregate_uuid and owner_id = auth.uid() for update;
            if found and operation->>'base_version' is not null
               and current_crop.version <> (operation->>'base_version')::bigint then
              result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'conflict', 'remote_version', current_crop.version, 'error_code', 'version_conflict');
            else
              next_version := case when found then current_crop.version + 1 else 1 end;
              insert into public.custom_crops(
                id, owner_id, name, normalized_name, description, notes,
                archived_at, version, updated_at, deleted_at
              ) values (
                aggregate_uuid, auth.uid(), trim(payload->>'name'), trim(payload->>'normalized_name'),
                payload->>'description', payload->>'notes',
                case when operation->>'mutation_kind' = 'archive'
                  then coalesce(nullif(payload->>'archived_at','')::timestamptz, now())
                  else nullif(payload->>'archived_at','')::timestamptz end,
                next_version, coalesce((payload->>'updated_at')::timestamptz, now()),
                case when operation->>'mutation_kind' = 'delete'
                  then coalesce(nullif(payload->>'deleted_at','')::timestamptz, now())
                  else nullif(payload->>'deleted_at','')::timestamptz end
              ) on conflict (id) do update set
                name = excluded.name, normalized_name = excluded.normalized_name,
                description = excluded.description, notes = excluded.notes,
                archived_at = excluded.archived_at, version = excluded.version,
                updated_at = excluded.updated_at, deleted_at = excluded.deleted_at;
              payload := payload || jsonb_build_object('version', next_version);
              insert into public.sync_changes(owner_id, aggregate_type, aggregate_id, mutation_kind, payload, remote_version)
              values (auth.uid(), aggregate_type_value, aggregate_uuid, operation->>'mutation_kind', payload, next_version)
              returning change_seq into change_number;
              result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'applied', 'remote_version', next_version, 'change_seq', change_number);
              insert into public.sync_operations(owner_id, operation_id, aggregate_type, aggregate_id, request_hash, protocol_version, status, result)
              values (auth.uid(), operation_uuid, aggregate_type_value, aggregate_uuid, request_hash_value, 2, 'applied', result_row);
            end if;
          end if;
        else
          if payload->>'sector_id' is null
             or payload->>'agricultural_season_id' is null
             or payload->>'crop_id' is null
             or payload->>'starts_on' is null
             or payload->>'status' not in ('planned','active','ended','cancelled') then
            result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'assignment_payload_invalid');
          elsif not exists (
            select 1 from public.sectors sec
            join public.agricultural_seasons season on season.id = (payload->>'agricultural_season_id')::uuid
            where sec.id = (payload->>'sector_id')::uuid
              and sec.owner_id = auth.uid() and season.owner_id = auth.uid()
              and sec.parcel_id = season.parcel_id and sec.deleted_at is null and season.deleted_at is null
          ) then
            result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'assignment_parent_missing');
          elsif coalesce((payload->>'is_custom_crop')::boolean, false)
                and not exists (
                  select 1 from public.custom_crops where id = (payload->>'crop_id')::uuid
                    and owner_id = auth.uid() and deleted_at is null
                ) then
            result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'assignment_crop_missing');
          elsif not coalesce((payload->>'is_custom_crop')::boolean, false)
                and not exists (select 1 from public.official_crops where id = payload->>'crop_id') then
            result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'assignment_crop_missing');
          else
            select * into current_assignment from public.crop_seasons
            where id = aggregate_uuid and owner_id = auth.uid() for update;
            if found and operation->>'base_version' is not null
               and current_assignment.version <> (operation->>'base_version')::bigint then
              result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'conflict', 'remote_version', current_assignment.version, 'error_code', 'version_conflict');
            elsif payload->>'status' = 'planned' and exists (
              select 1 from public.crop_seasons other
              where other.owner_id = auth.uid()
                and other.sector_id = (payload->>'sector_id')::uuid
                and other.id <> aggregate_uuid and other.status = 'planned' and other.deleted_at is null
                and daterange(other.starts_on, other.ends_on, '[)') &&
                    daterange((payload->>'starts_on')::date, nullif(payload->>'ends_on','')::date, '[)')
            ) then
              result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'assignment_overlap');
            else
              next_version := case when found then current_assignment.version + 1 else 1 end;
              insert into public.crop_seasons(
                id, owner_id, sector_id, agricultural_season_id, crop_id,
                is_custom_crop, status, starts_on, ends_on, notes,
                version, updated_at, deleted_at
              ) values (
                aggregate_uuid, auth.uid(), (payload->>'sector_id')::uuid,
                (payload->>'agricultural_season_id')::uuid, payload->>'crop_id',
                coalesce((payload->>'is_custom_crop')::boolean, false), payload->>'status',
                (payload->>'starts_on')::date, nullif(payload->>'ends_on','')::date,
                payload->>'notes', next_version,
                coalesce((payload->>'updated_at')::timestamptz, now()),
                case when operation->>'mutation_kind' = 'delete'
                  then coalesce(nullif(payload->>'deleted_at','')::timestamptz, now())
                  else nullif(payload->>'deleted_at','')::timestamptz end
              ) on conflict (id) do update set
                sector_id = excluded.sector_id,
                agricultural_season_id = excluded.agricultural_season_id,
                crop_id = excluded.crop_id, is_custom_crop = excluded.is_custom_crop,
                status = excluded.status, starts_on = excluded.starts_on,
                ends_on = excluded.ends_on, notes = excluded.notes,
                version = excluded.version, updated_at = excluded.updated_at,
                deleted_at = excluded.deleted_at;
              payload := payload || jsonb_build_object('version', next_version);
              insert into public.sync_changes(owner_id, aggregate_type, aggregate_id, mutation_kind, payload, remote_version)
              values (auth.uid(), aggregate_type_value, aggregate_uuid, operation->>'mutation_kind', payload, next_version)
              returning change_seq into change_number;
              result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'applied', 'remote_version', next_version, 'change_seq', change_number);
              insert into public.sync_operations(owner_id, operation_id, aggregate_type, aggregate_id, request_hash, protocol_version, status, result)
              values (auth.uid(), operation_uuid, aggregate_type_value, aggregate_uuid, request_hash_value, 2, 'applied', result_row);
            end if;
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
