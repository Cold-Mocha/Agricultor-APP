-- F04: map only supplied specialization fields; labor, child and ACK share
-- the handler's transaction/subtransaction. Soil measured_at defaults to the
-- app's occurred_at because SoilRepository uses the same clock for both.
create or replace function public.persist_labor_specialization(payload jsonb, labor_uuid uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare
  soil jsonb := nullif(payload->'soil','null'::jsonb);
  apiary jsonb := nullif(payload->'apiary','null'::jsonb);
  key_pair text[];
  child jsonb;
  numeric_key text;
begin
  if auth.uid() is null then raise exception 'authentication_required'; end if;
  if soil is not null and apiary is not null then raise exception 'labor_children_incompatible'; end if;
  foreach child in array array[soil, apiary] loop
    if child is not null and (jsonb_typeof(child) <> 'object' or child->>'id' is null
      or (child->>'labor_id' is not null and child->>'labor_id' <> labor_uuid::text)
      or (child->>'sector_id' is not null and child->>'sector_id' <> payload->>'sector_id')
      or (child->>'owner_id' is not null and child->>'owner_id' <> auth.uid()::text)) then
      raise exception 'labor_child_identity_invalid';
    end if;
  end loop;
  if soil is not null then
    if payload->>'type' <> 'soil' then raise exception 'soil_labor_type_invalid'; end if;
    foreach key_pair slice 1 in array array[
      ['moisturePercent','moisture_percent'], ['temperatureCelsius','temperature_celsius']
    ] loop
      if soil ? key_pair[1] and soil ? key_pair[2] and soil->key_pair[1] is distinct from soil->key_pair[2] then
        raise exception 'soil_field_alias_mismatch';
      end if;
    end loop;
    foreach numeric_key in array array['moisturePercent','moisture_percent','temperatureCelsius','temperature_celsius',
      'ph','conductivity','nitrogen','phosphorus','potassium'] loop
      if soil ? numeric_key and jsonb_typeof(soil->numeric_key) not in ('number','null') then
        raise exception 'soil_numeric_value_invalid';
      end if;
    end loop;
    insert into public.soil_measurements(
      id, owner_id, sector_id, labor_id, moisture_percent, ph, temperature_celsius,
      conductivity, nitrogen, phosphorus, potassium, notes, measured_at, updated_at
    ) values (
      (soil->>'id')::uuid, auth.uid(), (payload->>'sector_id')::uuid, labor_uuid,
      coalesce(soil->>'moisturePercent', soil->>'moisture_percent')::double precision,
      (soil->>'ph')::double precision,
      coalesce(soil->>'temperatureCelsius', soil->>'temperature_celsius')::double precision,
      (soil->>'conductivity')::double precision, (soil->>'nitrogen')::double precision,
      (soil->>'phosphorus')::double precision, (soil->>'potassium')::double precision,
      soil->>'notes', coalesce((soil->>'measured_at')::timestamptz, (payload->>'occurred_at')::timestamptz),
      coalesce((soil->>'updated_at')::timestamptz, (payload->>'updated_at')::timestamptz, now())
    ) on conflict(id) do update set
      moisture_percent = excluded.moisture_percent, ph = excluded.ph, temperature_celsius = excluded.temperature_celsius,
      conductivity = excluded.conductivity, nitrogen = excluded.nitrogen, phosphorus = excluded.phosphorus,
      potassium = excluded.potassium, notes = excluded.notes, measured_at = excluded.measured_at, updated_at = excluded.updated_at
      where soil_measurements.owner_id = excluded.owner_id and soil_measurements.sector_id = excluded.sector_id
        and soil_measurements.labor_id = excluded.labor_id;
    if not found then raise exception 'identity_unavailable'; end if;
  end if;
  if apiary is not null then
    if payload->>'type' <> 'apiary' or apiary->>'task_type' not in ('inspection','feeding','health','harvest','superPlacement','other')
      or nullif(trim(apiary->>'beekeeper_name'),'') is null
      or nullif(trim(apiary->>'queen_status'),'') is null or nullif(trim(apiary->>'brood_status'),'') is null
      or apiary->>'hive_count' is null or apiary->>'inspected_at' is null then
      raise exception 'apiary_payload_invalid';
    end if;
    insert into public.apiary_inspections(
      id, owner_id, sector_id, labor_id, task_type, beekeeper_name, hive_count, queen_status,
      brood_status, feeding_status, health_notes, pest_notes, super_installed, observations, inspected_at, updated_at
    ) values (
      (apiary->>'id')::uuid, auth.uid(), (payload->>'sector_id')::uuid, labor_uuid,
      apiary->>'task_type', trim(apiary->>'beekeeper_name'), (apiary->>'hive_count')::integer,
      apiary->>'queen_status', apiary->>'brood_status', apiary->>'feeding_status',
      apiary->>'health_notes', apiary->>'pest_notes', coalesce((apiary->>'super_installed')::boolean,false),
      apiary->>'observations', (apiary->>'inspected_at')::timestamptz,
      coalesce((apiary->>'updated_at')::timestamptz, (payload->>'updated_at')::timestamptz, now())
    ) on conflict(id) do update set
      task_type = excluded.task_type, beekeeper_name = excluded.beekeeper_name, hive_count = excluded.hive_count,
      queen_status = excluded.queen_status, brood_status = excluded.brood_status, feeding_status = excluded.feeding_status,
      health_notes = excluded.health_notes, pest_notes = excluded.pest_notes, super_installed = excluded.super_installed,
      observations = excluded.observations, inspected_at = excluded.inspected_at, updated_at = excluded.updated_at
      where apiary_inspections.owner_id = excluded.owner_id and apiary_inspections.sector_id = excluded.sector_id
        and apiary_inspections.labor_id = excluded.labor_id;
    if not found then raise exception 'identity_unavailable'; end if;
  end if;
end $$;
revoke all on function public.persist_labor_specialization(jsonb, uuid) from public, anon, authenticated;

create or replace function public.sync_push_labor_v2(operations jsonb)
returns jsonb language plpgsql security definer set search_path = public, extensions, pg_temp as $$
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
        production := nullif(payload->'production', 'null'::jsonb);
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
            or (payload->>'type' not in ('soil','apiary') and
                (nullif(payload->>'agricultural_season_id','') is null or nullif(payload->>'crop_assignment_id','') is null))
            or payload->>'type' not in ('irrigation','soil','fertilization','diseaseAndPestControl','sowing','pruning','harvest','apiary','other')
            or jsonb_typeof(payload->'details') <> 'object'
            or payload->>'occurred_at' is null then
          result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'labor_payload_invalid');
        elsif not exists (
          select 1 from public.sectors sec
          where sec.id = (payload->>'sector_id')::uuid and sec.owner_id = auth.uid()
            and sec.deleted_at is null
            and sec.kind = case when payload->>'type' = 'apiary' then 'apiary' else 'crop' end
            and (payload->>'domain_category' is null or payload->>'domain_category' = sec.kind)
            and (nullif(payload->>'agricultural_season_id','') is null or exists (
              select 1 from public.agricultural_seasons season
              where season.id = nullif(payload->>'agricultural_season_id','')::uuid
                and season.owner_id = auth.uid() and season.sector_id = sec.id and season.deleted_at is null
            ))
            and (nullif(payload->>'crop_assignment_id','') is null or exists (
              select 1 from public.crop_seasons assignment
              where assignment.id = nullif(payload->>'crop_assignment_id','')::uuid
                and assignment.owner_id = auth.uid() and assignment.sector_id = sec.id
                and assignment.agricultural_season_id = nullif(payload->>'agricultural_season_id','')::uuid
                and assignment.deleted_at is null
            ))
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
          if exists (select 1 from public.labors where id = aggregate_uuid and owner_id <> auth.uid()) then
              raise exception 'identity_unavailable';
            end if;
            select * into current_labor from public.labors
          where id = aggregate_uuid and owner_id = auth.uid() for update;
          if current_labor.id is not null and (
            current_labor.sector_id is distinct from (payload->>'sector_id')::uuid
            or current_labor.type is distinct from payload->>'type'
            or current_labor.agricultural_season_id is distinct from nullif(payload->>'agricultural_season_id','')::uuid
            or current_labor.crop_assignment_id is distinct from nullif(payload->>'crop_assignment_id','')::uuid
          ) then raise exception 'labor_context_immutable'; end if;
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
              (payload->>'sector_id')::uuid, nullif(payload->>'crop_assignment_id','')::uuid,
              nullif(payload->>'agricultural_season_id','')::uuid, nullif(payload->>'crop_assignment_id','')::uuid,
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
              deleted_at = excluded.deleted_at
              where labors.owner_id = excluded.owner_id;
            if not found then raise exception 'identity_unavailable'; end if;

            if production is not null then
              insert into public.production_records(
                id, owner_id, sector_id, labor_id, season_id, crop_id,
                quantity, unit, quality_notes, harvested_at, updated_at
              ) values (
                (production->>'id')::uuid, auth.uid(),
                (payload->>'sector_id')::uuid, aggregate_uuid,
                nullif(payload->>'crop_assignment_id','')::uuid, production->>'crop_id',
                (production->>'quantity')::double precision, trim(production->>'unit'),
                production->>'quality_notes', (production->>'harvested_at')::timestamptz,
                coalesce((production->>'updated_at')::timestamptz, now())
              ) on conflict (id) do update set
                quantity = excluded.quantity, unit = excluded.unit,
                quality_notes = excluded.quality_notes, harvested_at = excluded.harvested_at,
                updated_at = excluded.updated_at
              where production_records.owner_id = excluded.owner_id and production_records.labor_id = excluded.labor_id and production_records.sector_id = excluded.sector_id;
            if not found then raise exception 'identity_unavailable'; end if;
            end if;

            perform public.persist_labor_specialization(payload, aggregate_uuid);
            payload := payload || jsonb_build_object('version', next_version,
              'domain_category', (select kind from public.sectors where id = (payload->>'sector_id')::uuid));
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
