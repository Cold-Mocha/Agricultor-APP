-- AgroCampo 004: sector-only territory. Parcels are removed from the model and
-- the product owner approved a full reset of agricultural and sync data
-- (specs/004-sector-only-territory). Profiles and auth users are preserved.
-- Migrations 0001-0020 stay immutable; this file redefines the affected
-- sync_push handlers in place, keeping the existing delegation chain:
-- sync_push (reminder) -> irrigation -> labor -> seasons/crops -> territory.

-- 1. Data reset. TRUNCATE ... CASCADE also empties every dependent table.
truncate table
  public.sync_changes,
  public.sync_operations,
  public.parcels,
  public.sectors,
  public.custom_crops
cascade;

-- 2. Sectors belong directly to their owner.
drop trigger if exists sectors_containment on public.sectors;
drop function if exists public.enforce_sector_inside_parcel();
drop index if exists public.sectors_owner_parcel_idx;
alter table public.sectors drop column parcel_id;
alter table public.sectors
  add constraint sectors_owner_number_key unique (owner_id, number);
create index if not exists sectors_owner_number_idx
  on public.sectors(owner_id, number) where deleted_at is null;

-- 3. Agricultural seasons belong to one sector.
drop index if exists public.agricultural_seasons_active_idx;
drop index if exists public.agricultural_seasons_owner_parcel_idx;
alter table public.agricultural_seasons drop column parcel_id;
alter table public.agricultural_seasons
  add column sector_id uuid not null references public.sectors(id);
create unique index agricultural_seasons_one_active_per_sector
  on public.agricultural_seasons(sector_id)
  where status = 'active' and deleted_at is null;
create index agricultural_seasons_owner_sector_idx
  on public.agricultural_seasons(owner_id, sector_id, starts_on desc);

-- 4. Records keep sector, season and assignment links only.
drop index if exists public.production_history_idx;
drop index if exists public.labors_history_idx;
alter table public.labors drop column parcel_id;
alter table public.production_records drop column parcel_id;
alter table public.reminders drop column parcel_id;
create index production_history_idx
  on public.production_records(owner_id, sector_id, season_id, harvested_at desc);
create index labors_history_idx
  on public.labors(owner_id, sector_id, season_id, occurred_at desc);

-- 5. Parcels disappear.
drop table public.parcels;

-- 6. Sync handlers without parcels. The 'parcel' aggregate is now rejected
-- as aggregate_unsupported by the territory handler.
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
          when sqlstate = '23505' then 'uniqueness_conflict'
          when sqlstate = '22P02' then 'payload_invalid'
          else 'operation_invalid' end
      );
    end;
    results := results || jsonb_build_array(result_row);
  end loop;
  return jsonb_build_object('protocol_version', 2, 'results', results);
end $$;

create or replace function public.sync_push_seasons_crops_v2(operations jsonb)
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
        -- 'parcel' reaches the territory handler, which rejects it as unsupported.
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
             or payload->>'sector_id' is null
             or payload->>'starts_on' is null
             or payload->>'status' not in ('planned','active','closed')
             or not exists (
               select 1 from public.sectors
               where id = (payload->>'sector_id')::uuid and owner_id = auth.uid() and deleted_at is null
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
                  id, owner_id, sector_id, name, starts_on, ends_on, status, notes,
                  is_migration_backfill, version, updated_at, deleted_at
                ) values (
                  aggregate_uuid, auth.uid(), (payload->>'sector_id')::uuid,
                  trim(payload->>'name'), (payload->>'starts_on')::date,
                  nullif(payload->>'ends_on','')::date, payload->>'status', payload->>'notes',
                  coalesce((payload->>'is_migration_backfill')::boolean, false), next_version,
                  coalesce((payload->>'updated_at')::timestamptz, now()),
                  case when operation->>'mutation_kind' = 'delete'
                    then coalesce(nullif(payload->>'deleted_at','')::timestamptz, now())
                    else nullif(payload->>'deleted_at','')::timestamptz end
                ) on conflict (id) do update set
                  sector_id = excluded.sector_id, name = excluded.name,
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
              and season.sector_id = sec.id and sec.deleted_at is null and season.deleted_at is null
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

create or replace function public.sync_push_labor_v2(operations jsonb)
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
            or payload->>'sector_id' is null
            or payload->>'agricultural_season_id' is null or payload->>'crop_assignment_id' is null
            or payload->>'type' not in ('irrigation','soil','fertilization','diseaseAndPestControl','sowing','pruning','harvest','apiary','other')
            or jsonb_typeof(payload->'details') <> 'object'
            or payload->>'occurred_at' is null then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'labor_payload_invalid');
        elsif not exists (
          select 1 from public.sectors sec
          join public.agricultural_seasons season on season.id = (payload->>'agricultural_season_id')::uuid
          join public.crop_seasons assignment on assignment.id = (payload->>'crop_assignment_id')::uuid
          where sec.id = (payload->>'sector_id')::uuid and sec.owner_id = auth.uid()
            and season.owner_id = auth.uid() and season.sector_id = sec.id
            and assignment.owner_id = auth.uid() and assignment.sector_id = sec.id
            and assignment.agricultural_season_id = season.id
            and sec.deleted_at is null
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
              id, owner_id, sector_id, season_id, agricultural_season_id,
              crop_assignment_id, type, custom_name, details, details_schema_version,
              status, supersedes_labor_id, notes, occurred_at, version, updated_at, deleted_at
            ) values (
              aggregate_uuid, auth.uid(),
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
                id, owner_id, sector_id, labor_id, season_id, crop_id,
                quantity, unit, quality_notes, harvested_at, updated_at
              ) values (
                (production->>'id')::uuid, auth.uid(),
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

create or replace function public.sync_push(operations jsonb)
returns jsonb language plpgsql security definer set search_path=public,extensions as $$
declare
  operation jsonb; payload jsonb; operation_uuid uuid; aggregate_uuid uuid;
  request_hash_value text; receipt public.sync_operations%rowtype;
  current_row public.reminders%rowtype; next_version bigint; change_number bigint;
  result_row jsonb; results jsonb := '[]'::jsonb;
begin
  if auth.uid() is null then raise exception 'authentication_required'; end if;
  if jsonb_typeof(operations)<>'array' or jsonb_array_length(operations) not between 1 and 25 then
    raise exception 'operations_batch_invalid';
  end if;
  for operation in select value from jsonb_array_elements(operations)
  loop
    begin
      if operation->>'aggregate_type'<>'reminder' then
        result_row := public.sync_push_irrigation_v2(jsonb_build_array(operation))->'results'->0;
      else
        operation_uuid := (operation->>'operation_id')::uuid;
        aggregate_uuid := (operation->>'aggregate_id')::uuid;
        payload := operation->'payload';
        request_hash_value := coalesce(nullif(operation->>'request_hash',''),md5(operation::text));
        select * into receipt from public.sync_operations where owner_id=auth.uid() and operation_id=operation_uuid;
        if found then
          if receipt.request_hash is distinct from request_hash_value then
            result_row := jsonb_build_object('operation_id',operation_uuid,'status','rejected','error_code','idempotency_mismatch');
          else
            result_row := receipt.result || jsonb_build_object('operation_id',operation_uuid,'status','duplicate');
          end if;
        elsif coalesce((operation->>'protocol_version')::integer,0)<>2
          or coalesce((operation->>'payload_schema_version')::integer,0)<>1
          or payload->>'id' is distinct from operation->>'aggregate_id'
          or nullif(trim(payload->>'title'),'') is null
          or char_length(trim(payload->>'title'))>120
          or payload->>'scheduled_at' is null
          or payload->>'status' not in ('scheduled','completed','cancelled') then
          result_row := jsonb_build_object('operation_id',operation_uuid,'status','rejected','error_code','reminder_payload_invalid');
        elsif payload->>'sector_id' is not null and not exists(
          select 1 from public.sectors where id=(payload->>'sector_id')::uuid and owner_id=auth.uid()
            and deleted_at is null
        ) then
          result_row := jsonb_build_object('operation_id',operation_uuid,'status','rejected','error_code','reminder_parent_missing');
        else
          select * into current_row from public.reminders where id=aggregate_uuid and owner_id=auth.uid() for update;
          if found and operation->>'base_version' is not null and current_row.version<>(operation->>'base_version')::bigint then
            result_row := jsonb_build_object('operation_id',operation_uuid,'status','conflict','remote_version',current_row.version,'error_code','version_conflict');
          else
            next_version := case when found then current_row.version+1 else 1 end;
            insert into public.reminders(
              id,owner_id,sector_id,title,description,notes,scheduled_at,
              source_time_zone,status,is_completed,completed_at,cancelled_at,version,updated_at,deleted_at
            ) values(
              aggregate_uuid,auth.uid(),nullif(payload->>'sector_id','')::uuid,
              trim(payload->>'title'),payload->>'description',payload->>'notes',(payload->>'scheduled_at')::timestamptz,
              coalesce(payload->>'source_time_zone','UTC'),payload->>'status',payload->>'status'='completed',
              nullif(payload->>'completed_at','')::timestamptz,nullif(payload->>'cancelled_at','')::timestamptz,
              next_version,coalesce((payload->>'updated_at')::timestamptz,now()),
              case when operation->>'mutation_kind'='delete' then coalesce(nullif(payload->>'deleted_at','')::timestamptz,now()) else nullif(payload->>'deleted_at','')::timestamptz end
            ) on conflict(id) do update set
              sector_id=excluded.sector_id,title=excluded.title,
              description=excluded.description,notes=excluded.notes,scheduled_at=excluded.scheduled_at,
              source_time_zone=excluded.source_time_zone,status=excluded.status,is_completed=excluded.is_completed,
              completed_at=excluded.completed_at,cancelled_at=excluded.cancelled_at,
              version=excluded.version,updated_at=excluded.updated_at,deleted_at=excluded.deleted_at;
            payload := payload || jsonb_build_object('version',next_version);
            insert into public.sync_changes(owner_id,aggregate_type,aggregate_id,mutation_kind,payload,remote_version)
              values(auth.uid(),'reminder',aggregate_uuid,operation->>'mutation_kind',payload,next_version)
              returning change_seq into change_number;
            result_row := jsonb_build_object('operation_id',operation_uuid,'status','applied','remote_version',next_version,'change_seq',change_number);
            insert into public.sync_operations(owner_id,operation_id,aggregate_type,aggregate_id,request_hash,protocol_version,status,result)
              values(auth.uid(),operation_uuid,'reminder',aggregate_uuid,request_hash_value,2,'applied',result_row);
          end if;
        end if;
      end if;
    exception when others then
      result_row := jsonb_build_object('operation_id',operation->>'operation_id','status','rejected',
        'error_code',case when sqlstate='22P02' then 'payload_invalid' else 'operation_invalid' end);
    end;
    results := results || jsonb_build_array(result_row);
  end loop;
  return jsonb_build_object('protocol_version',2,'results',results);
end $$;
