-- F03: owner/context FKs preserve historical parents, including retired sectors.
-- Each nullable reference is independently constrained (MATCH SIMPLE).
alter table public.sectors add constraint sectors_owner_context_key unique (owner_id, id);
alter table public.agricultural_seasons add constraint agricultural_seasons_owner_context_key unique (owner_id, sector_id, id);
alter table public.crop_seasons add constraint crop_seasons_owner_context_key unique (owner_id, sector_id, id);
alter table public.labors add constraint labors_owner_context_key unique (owner_id, sector_id, id);
alter table public.sector_irrigation_configs add constraint sector_irrigation_configs_owner_context_key unique (owner_id, sector_id, id);
alter table public.agricultural_seasons add constraint agricultural_seasons_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.agricultural_seasons validate constraint agricultural_seasons_sector_id_context_fk;
alter table public.crop_seasons add constraint crop_seasons_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.crop_seasons validate constraint crop_seasons_sector_id_context_fk;
alter table public.labors add constraint labors_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.labors validate constraint labors_sector_id_context_fk;
alter table public.soil_measurements add constraint soil_measurements_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.soil_measurements validate constraint soil_measurements_sector_id_context_fk;
alter table public.apiary_inspections add constraint apiary_inspections_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.apiary_inspections validate constraint apiary_inspections_sector_id_context_fk;
alter table public.irrigation_records add constraint irrigation_records_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.irrigation_records validate constraint irrigation_records_sector_id_context_fk;
alter table public.production_records add constraint production_records_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.production_records validate constraint production_records_sector_id_context_fk;
alter table public.sector_irrigation_configs add constraint sector_irrigation_configs_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.sector_irrigation_configs validate constraint sector_irrigation_configs_sector_id_context_fk;
alter table public.irrigation_estimates add constraint irrigation_estimates_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.irrigation_estimates validate constraint irrigation_estimates_sector_id_context_fk;
alter table public.reminders add constraint reminders_sector_id_context_fk
  foreign key (owner_id, sector_id) references public.sectors (owner_id, id) not valid;
alter table public.reminders validate constraint reminders_sector_id_context_fk;
alter table public.crop_seasons add constraint crop_seasons_agricultural_season_id_context_fk
  foreign key (owner_id, sector_id, agricultural_season_id) references public.agricultural_seasons (owner_id, sector_id, id) not valid;
alter table public.crop_seasons validate constraint crop_seasons_agricultural_season_id_context_fk;
alter table public.labors add constraint labors_agricultural_season_id_context_fk
  foreign key (owner_id, sector_id, agricultural_season_id) references public.agricultural_seasons (owner_id, sector_id, id) not valid;
alter table public.labors validate constraint labors_agricultural_season_id_context_fk;
alter table public.labors add constraint labors_crop_assignment_id_context_fk
  foreign key (owner_id, sector_id, crop_assignment_id) references public.crop_seasons (owner_id, sector_id, id) not valid;
alter table public.labors validate constraint labors_crop_assignment_id_context_fk;
alter table public.labors add constraint labors_season_id_context_fk
  foreign key (owner_id, sector_id, season_id) references public.crop_seasons (owner_id, sector_id, id) not valid;
alter table public.labors validate constraint labors_season_id_context_fk;
alter table public.labors add constraint labors_supersedes_labor_id_context_fk
  foreign key (owner_id, sector_id, supersedes_labor_id) references public.labors (owner_id, sector_id, id) not valid;
alter table public.labors validate constraint labors_supersedes_labor_id_context_fk;
alter table public.soil_measurements add constraint soil_measurements_labor_id_context_fk
  foreign key (owner_id, sector_id, labor_id) references public.labors (owner_id, sector_id, id) not valid;
alter table public.soil_measurements validate constraint soil_measurements_labor_id_context_fk;
alter table public.apiary_inspections add constraint apiary_inspections_labor_id_context_fk
  foreign key (owner_id, sector_id, labor_id) references public.labors (owner_id, sector_id, id) not valid;
alter table public.apiary_inspections validate constraint apiary_inspections_labor_id_context_fk;
alter table public.irrigation_records add constraint irrigation_records_labor_id_context_fk
  foreign key (owner_id, sector_id, labor_id) references public.labors (owner_id, sector_id, id) not valid;
alter table public.irrigation_records validate constraint irrigation_records_labor_id_context_fk;
alter table public.irrigation_records add constraint irrigation_records_config_id_context_fk
  foreign key (owner_id, sector_id, config_id) references public.sector_irrigation_configs (owner_id, sector_id, id) not valid;
alter table public.irrigation_records validate constraint irrigation_records_config_id_context_fk;
alter table public.production_records add constraint production_records_labor_id_context_fk
  foreign key (owner_id, sector_id, labor_id) references public.labors (owner_id, sector_id, id) not valid;
alter table public.production_records validate constraint production_records_labor_id_context_fk;
alter table public.production_records add constraint production_records_season_id_context_fk
  foreign key (owner_id, sector_id, season_id) references public.crop_seasons (owner_id, sector_id, id) not valid;
alter table public.production_records validate constraint production_records_season_id_context_fk;
alter table public.irrigation_estimates add constraint irrigation_estimates_irrigation_labor_id_context_fk
  foreign key (owner_id, sector_id, irrigation_labor_id) references public.labors (owner_id, sector_id, id) not valid;
alter table public.irrigation_estimates validate constraint irrigation_estimates_irrigation_labor_id_context_fk;
alter table public.irrigation_estimates add constraint irrigation_estimates_crop_assignment_id_context_fk
  foreign key (owner_id, sector_id, crop_assignment_id) references public.crop_seasons (owner_id, sector_id, id) not valid;
alter table public.irrigation_estimates validate constraint irrigation_estimates_crop_assignment_id_context_fk;
alter table public.irrigation_estimates add constraint irrigation_estimates_config_id_context_fk
  foreign key (owner_id, sector_id, config_id) references public.sector_irrigation_configs (owner_id, sector_id, id) not valid;
alter table public.irrigation_estimates validate constraint irrigation_estimates_config_id_context_fk;

create or replace function public.protect_owned_identity()
returns trigger language plpgsql set search_path = public, pg_temp as $$
begin
  if new.id is distinct from old.id or new.owner_id is distinct from old.owner_id then
    raise exception 'identity_immutable' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger sectors_identity_immutable before update on public.sectors
  for each row execute function public.protect_owned_identity();
create trigger agricultural_seasons_identity_immutable before update on public.agricultural_seasons
  for each row execute function public.protect_owned_identity();
create trigger custom_crops_identity_immutable before update on public.custom_crops
  for each row execute function public.protect_owned_identity();
create trigger crop_seasons_identity_immutable before update on public.crop_seasons
  for each row execute function public.protect_owned_identity();
create trigger labors_identity_immutable before update on public.labors
  for each row execute function public.protect_owned_identity();
create trigger soil_measurements_identity_immutable before update on public.soil_measurements
  for each row execute function public.protect_owned_identity();
create trigger apiary_inspections_identity_immutable before update on public.apiary_inspections
  for each row execute function public.protect_owned_identity();
create trigger irrigation_records_identity_immutable before update on public.irrigation_records
  for each row execute function public.protect_owned_identity();
create trigger production_records_identity_immutable before update on public.production_records
  for each row execute function public.protect_owned_identity();
create trigger sector_irrigation_configs_identity_immutable before update on public.sector_irrigation_configs
  for each row execute function public.protect_owned_identity();
create trigger irrigation_estimates_identity_immutable before update on public.irrigation_estimates
  for each row execute function public.protect_owned_identity();
create trigger reminders_identity_immutable before update on public.reminders
  for each row execute function public.protect_owned_identity();

-- Rules not representable by a simple FK: polymorphic crop, season/assignment
-- context, specialization type/config version, and correction graph.
create or replace function public.check_productive_context()
returns trigger language plpgsql security definer set search_path = public, pg_temp as $$
declare
  parent public.labors%rowtype;
  assignment public.crop_seasons%rowtype;
  config public.sector_irrigation_configs%rowtype;
  kind_value text;
begin
  select kind into kind_value from public.sectors where id = new.sector_id and owner_id = new.owner_id;
  if kind_value is null then raise exception 'productive_sector_owner_mismatch' using errcode = '23503'; end if;
  if tg_table_name = 'crop_seasons' then
    if new.is_custom_crop then
      -- A key-share lock pairs with parent DELETE, including concurrent first references.
      perform id from public.custom_crops where id = new.crop_id::uuid and owner_id = new.owner_id for key share;
      if not found then
        raise exception 'assignment_crop_missing' using errcode = '23514';
      end if;
    elsif not exists (select 1 from public.official_crops where id = new.crop_id) then
      raise exception 'assignment_crop_missing' using errcode = '23514';
    end if;
  elsif tg_table_name = 'labors' then
    if new.crop_assignment_id is not null then
      select * into assignment from public.crop_seasons where id = new.crop_assignment_id for share;
      if assignment.agricultural_season_id is distinct from new.agricultural_season_id
        or new.season_id is distinct from new.crop_assignment_id then
        raise exception 'labor_context_mismatch' using errcode = '23514';
      end if;
    end if;
    if new.supersedes_labor_id is not null then
      select * into parent from public.labors where id = new.supersedes_labor_id for share;
      if new.id = new.supersedes_labor_id or parent.type is distinct from new.type
        or parent.agricultural_season_id is distinct from new.agricultural_season_id
        or parent.crop_assignment_id is distinct from new.crop_assignment_id then
        raise exception 'correction_context_mismatch' using errcode = '23514';
      end if;
      if exists (with recursive chain(id, original, visited) as (
        select parent.id, parent.supersedes_labor_id, array[parent.id]
        union all select l.id, l.supersedes_labor_id, c.visited || l.id
        from public.labors l join chain c on l.id = c.original where not l.id = any(c.visited)
      ) select 1 from chain where original = new.id) then
        raise exception 'correction_cycle' using errcode = '23514';
      end if;
    end if;
  else
    if tg_table_name = 'irrigation_estimates' then
      select * into parent from public.labors where id = new.irrigation_labor_id for share;
      if new.irrigation_labor_id is not null and (parent.type <> 'irrigation'
        or parent.crop_assignment_id is distinct from new.crop_assignment_id) then
        raise exception 'estimate_context_mismatch' using errcode = '23514';
      end if;
    elsif tg_table_name in ('soil_measurements','apiary_inspections','irrigation_records','production_records') then
      select * into parent from public.labors where id = new.labor_id for share;
      if new.labor_id is not null and parent.type is distinct from
        (case tg_table_name when 'soil_measurements' then 'soil' when 'apiary_inspections' then 'apiary'
          when 'irrigation_records' then 'irrigation' else 'harvest' end) then
        raise exception 'child_labor_type_mismatch' using errcode = '23514';
      end if;
      if tg_table_name = 'production_records' then
        select * into assignment from public.crop_seasons where id = new.season_id for share;
        if new.season_id is not null and assignment.crop_id is distinct from new.crop_id then
          raise exception 'production_crop_mismatch' using errcode = '23514';
        end if;
        if new.labor_id is not null and parent.crop_assignment_id is distinct from new.season_id then
          raise exception 'production_context_mismatch' using errcode = '23514';
        end if;
      end if;
    end if;
    if tg_table_name in ('irrigation_records','irrigation_estimates') then
      if new.config_id is not null then
      select * into config from public.sector_irrigation_configs where id = new.config_id for share;
      if config.config_version is distinct from new.config_version then
        raise exception 'irrigation_config_version_mismatch' using errcode = '23514';
      end if;
      end if;
    end if;
    if tg_table_name = 'apiary_inspections' and kind_value is distinct from 'apiary' then
      raise exception 'operation_not_valid_for_crop' using errcode = '23514';
    elsif tg_table_name in ('soil_measurements','irrigation_records','production_records','irrigation_estimates','sector_irrigation_configs')
      and kind_value is distinct from 'crop' then
      raise exception 'operation_not_valid_for_apiary' using errcode = '23514';
    end if;
  end if;
  return new;
end $$;
create trigger crop_seasons_productive_context before insert or update on public.crop_seasons
  for each row execute function public.check_productive_context();
create trigger labors_productive_context before insert or update on public.labors
  for each row execute function public.check_productive_context();
create trigger soil_measurements_productive_context before insert or update on public.soil_measurements
  for each row execute function public.check_productive_context();
create trigger apiary_inspections_productive_context before insert or update on public.apiary_inspections
  for each row execute function public.check_productive_context();
create trigger irrigation_records_productive_context before insert or update on public.irrigation_records
  for each row execute function public.check_productive_context();
create trigger production_records_productive_context before insert or update on public.production_records
  for each row execute function public.check_productive_context();
create trigger irrigation_estimates_productive_context before insert or update on public.irrigation_estimates
  for each row execute function public.check_productive_context();
create trigger sector_irrigation_configs_productive_context before insert or update on public.sector_irrigation_configs
  for each row execute function public.check_productive_context();
update public.crop_seasons set id = id; -- validate legacy trigger invariants without changing values
update public.labors set id = id; -- validate legacy trigger invariants without changing values
update public.soil_measurements set id = id; -- validate legacy trigger invariants without changing values
update public.apiary_inspections set id = id; -- validate legacy trigger invariants without changing values
update public.irrigation_records set id = id; -- validate legacy trigger invariants without changing values
update public.production_records set id = id; -- validate legacy trigger invariants without changing values
update public.irrigation_estimates set id = id; -- validate legacy trigger invariants without changing values
update public.sector_irrigation_configs set id = id; -- validate legacy trigger invariants without changing values
revoke all on function public.protect_owned_identity() from public, anon, authenticated;
revoke all on function public.check_productive_context() from public, anon, authenticated;

-- The custom/official crop reference is polymorphic text. Its parent side must
-- also prevent a delete from leaving historical assignments dangling.
create or replace function public.protect_custom_crop_reference()
returns trigger language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if exists (select 1 from public.crop_seasons where case when is_custom_crop then crop_id::uuid = old.id else false end) then
    raise exception 'custom_crop_referenced' using errcode = '23503';
  end if;
  return old;
end $$;
create trigger custom_crops_preserve_references before delete on public.custom_crops
  for each row execute function public.protect_custom_crop_reference();
revoke all on function public.protect_custom_crop_reference() from public, anon, authenticated;

-- Parent-side protection prevents a valid child from becoming inconsistent
-- through a later update that does not change the composite FK identity.
create or replace function public.protect_productive_parent_context()
returns trigger language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if tg_table_name = 'sectors' then
    if new.kind is distinct from old.kind then
      raise exception 'sector_kind_immutable' using errcode = '23514';
    end if;
  elsif tg_table_name = 'crop_seasons' then
    if (new.agricultural_season_id is distinct from old.agricultural_season_id
      or new.crop_id is distinct from old.crop_id or new.is_custom_crop is distinct from old.is_custom_crop)
      and (exists (select 1 from public.labors where crop_assignment_id = old.id or season_id = old.id)
        or exists (select 1 from public.production_records where season_id = old.id)
        or exists (select 1 from public.irrigation_estimates where crop_assignment_id = old.id)) then
      raise exception 'assignment_context_referenced' using errcode = '23514';
    end if;
  elsif tg_table_name = 'labors' then
    if new.type is distinct from old.type or new.agricultural_season_id is distinct from old.agricultural_season_id
      or new.crop_assignment_id is distinct from old.crop_assignment_id or new.season_id is distinct from old.season_id then
      raise exception 'labor_context_immutable' using errcode = '23514';
    end if;
  elsif tg_table_name = 'sector_irrigation_configs' then
    if new.config_version is distinct from old.config_version
      and (exists (select 1 from public.irrigation_records where config_id = old.id)
        or exists (select 1 from public.irrigation_estimates where config_id = old.id)) then
      raise exception 'irrigation_config_version_referenced' using errcode = '23514';
    end if;
  end if;
  return new;
end $$;
create trigger sectors_preserve_productive_context before update on public.sectors
  for each row execute function public.protect_productive_parent_context();
create trigger crop_seasons_preserve_productive_context before update on public.crop_seasons
  for each row execute function public.protect_productive_parent_context();
create trigger labors_preserve_productive_context before update on public.labors
  for each row execute function public.protect_productive_parent_context();
create trigger sector_irrigation_configs_preserve_productive_context before update on public.sector_irrigation_configs
  for each row execute function public.protect_productive_parent_context();
revoke all on function public.protect_productive_parent_context() from public, anon, authenticated;

-- Supersession is a payload relationship, not a persisted FK.
create or replace function public.sync_push_irrigation_v2(operations jsonb)
returns jsonb language plpgsql security definer set search_path = public, extensions, pg_temp as $$
declare
  operation jsonb;
  payload jsonb;
  irrigation jsonb;
  estimate jsonb;
  operation_uuid uuid;
  aggregate_uuid uuid;
  request_hash_value text;
  receipt public.sync_operations%rowtype;
  current_config public.sector_irrigation_configs%rowtype;
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
      payload := operation->'payload';
      if operation->>'aggregate_type' = 'irrigationConfig' then
        operation_uuid := (operation->>'operation_id')::uuid;
        aggregate_uuid := (operation->>'aggregate_id')::uuid;
        request_hash_value := coalesce(nullif(operation->>'request_hash',''),md5(operation::text));
        select * into receipt from public.sync_operations
          where owner_id=auth.uid() and operation_id=operation_uuid;
        if found then
          if receipt.request_hash is distinct from request_hash_value then
            result_row := jsonb_build_object('operation_id',operation_uuid,'status','rejected','error_code','idempotency_mismatch');
          else
            result_row := receipt.result || jsonb_build_object('operation_id',operation_uuid,'status','duplicate');
          end if;
        elsif coalesce((operation->>'protocol_version')::integer,0)<>2
          or coalesce((operation->>'payload_schema_version')::integer,0)<>1
          or payload->>'id' is distinct from operation->>'aggregate_id'
          or payload->>'method' <> 'drip'
          or coalesce((payload->>'plant_count')::integer,0)<=0
          or coalesce((payload->>'emitter_count')::integer,0)<=0
          or coalesce((payload->>'flow_ml_min')::integer,0)<=0
          or coalesce((payload->>'config_version')::integer,0)<=0
          or payload->>'effective_from' is null then
          result_row := jsonb_build_object('operation_id',operation_uuid,'status','rejected','error_code','irrigation_config_invalid');
        elsif not exists(select 1 from public.sectors where id=(payload->>'sector_id')::uuid and owner_id=auth.uid() and deleted_at is null) then
          result_row := jsonb_build_object('operation_id',operation_uuid,'status','rejected','error_code','irrigation_config_parent_missing');
        else
          if exists (select 1 from public.sector_irrigation_configs where id = aggregate_uuid and owner_id <> auth.uid()) then
              raise exception 'identity_unavailable';
            end if;
            select * into current_config from public.sector_irrigation_configs
            where id=aggregate_uuid and owner_id=auth.uid() for update;
          if found and operation->>'base_version' is not null
             and current_config.version<>(operation->>'base_version')::bigint then
            result_row := jsonb_build_object('operation_id',operation_uuid,'status','conflict','remote_version',current_config.version,'error_code','version_conflict');
          else
            next_version := case when found then current_config.version+1 else 1 end;
            if payload->>'supersedes_config_id' is not null then
              if payload->>'supersedes_config_id' = payload->>'id' or not exists (
                select 1 from public.sector_irrigation_configs
                where id = (payload->>'supersedes_config_id')::uuid and owner_id = auth.uid()
                  and sector_id = (payload->>'sector_id')::uuid and effective_to is null
              ) then raise exception 'irrigation_config_context_mismatch'; end if;
              update public.sector_irrigation_configs set effective_to=(payload->>'effective_from')::timestamptz
                where id=(payload->>'supersedes_config_id')::uuid and owner_id=auth.uid() and effective_to is null;
            end if;
            insert into public.sector_irrigation_configs(
              id,owner_id,sector_id,method,plant_count,emitter_count,emitters_per_plant_milli,
              flow_ml_min,pressure_kpa,distribution_notes,effective_from,effective_to,
              config_version,version,updated_at,deleted_at
            ) values(
              aggregate_uuid,auth.uid(),(payload->>'sector_id')::uuid,'drip',
              (payload->>'plant_count')::integer,(payload->>'emitter_count')::integer,
              nullif(payload->>'emitters_per_plant_milli','')::integer,(payload->>'flow_ml_min')::integer,
              nullif(payload->>'pressure_kpa','')::integer,payload->>'distribution_notes',
              (payload->>'effective_from')::timestamptz,nullif(payload->>'effective_to','')::timestamptz,
              (payload->>'config_version')::integer,next_version,
              coalesce((payload->>'updated_at')::timestamptz,now()),
              case when operation->>'mutation_kind'='delete' then coalesce(nullif(payload->>'deleted_at','')::timestamptz,now()) else nullif(payload->>'deleted_at','')::timestamptz end
            ) on conflict(id) do update set
              plant_count=excluded.plant_count,emitter_count=excluded.emitter_count,
              flow_ml_min=excluded.flow_ml_min,pressure_kpa=excluded.pressure_kpa,
              distribution_notes=excluded.distribution_notes,effective_to=excluded.effective_to,
              version=excluded.version,updated_at=excluded.updated_at,deleted_at=excluded.deleted_at
              where sector_irrigation_configs.owner_id = excluded.owner_id;
            if not found then raise exception 'identity_unavailable'; end if;
            payload := payload || jsonb_build_object('version',next_version);
            insert into public.sync_changes(owner_id,aggregate_type,aggregate_id,mutation_kind,payload,remote_version)
              values(auth.uid(),'irrigationConfig',aggregate_uuid,operation->>'mutation_kind',payload,next_version)
              returning change_seq into change_number;
            result_row := jsonb_build_object('operation_id',operation_uuid,'status','applied','remote_version',next_version,'change_seq',change_number);
            insert into public.sync_operations(owner_id,operation_id,aggregate_type,aggregate_id,request_hash,protocol_version,status,result)
              values(auth.uid(),operation_uuid,'irrigationConfig',aggregate_uuid,request_hash_value,2,'applied',result_row);
          end if;
        end if;
      else
        result_row := public.sync_push_labor_v2(jsonb_build_array(operation))->'results'->0;
        irrigation := payload->'irrigation';
        if operation->>'aggregate_type'='labor' and irrigation is not null
           and result_row->>'status' = 'applied' then
          if jsonb_typeof(irrigation)<>'object' or irrigation->>'id' is null
             or irrigation->>'irrigation_type' is null or irrigation->>'duration_seconds' is null
             or coalesce((irrigation->>'duration_seconds')::integer,0)<=0 then
            raise exception 'irrigation_payload_invalid';
          end if;
          insert into public.irrigation_records(
            id,owner_id,sector_id,labor_id,irrigation_type,soil_type_code,
            duration_minutes,estimated_liters,config_id,config_version,duration_seconds,
            applied_volume_ml,performed_details,irrigated_at,updated_at
          ) values(
            (irrigation->>'id')::uuid,auth.uid(),(payload->>'sector_id')::uuid,(payload->>'id')::uuid,
            irrigation->>'irrigation_type',coalesce(irrigation->>'soil_type_code','unknown'),
            ceil((irrigation->>'duration_seconds')::numeric/60)::integer,
            case when irrigation->>'applied_volume_ml' is null then null else (irrigation->>'applied_volume_ml')::double precision/1000 end,
            nullif(irrigation->>'config_id','')::uuid,nullif(irrigation->>'config_version','')::integer,
            (irrigation->>'duration_seconds')::integer,nullif(irrigation->>'applied_volume_ml','')::bigint,
            coalesce(irrigation->'performed_details','{}'::jsonb),(irrigation->>'irrigated_at')::timestamptz,
            coalesce((irrigation->>'updated_at')::timestamptz,now())
          ) on conflict(id) do update set
            duration_minutes=excluded.duration_minutes,applied_volume_ml=excluded.applied_volume_ml,
            performed_details=excluded.performed_details,updated_at=excluded.updated_at
              where irrigation_records.owner_id = excluded.owner_id and irrigation_records.labor_id = excluded.labor_id and irrigation_records.sector_id = excluded.sector_id;
            if not found then raise exception 'identity_unavailable'; end if;
          estimate := irrigation->'estimate';
          if estimate is not null then
            insert into public.irrigation_estimates(
              id,owner_id,sector_id,irrigation_labor_id,crop_assignment_id,config_id,config_version,
              algorithm_version,rule_id,rule_version,soil_type_code,inputs,estimated_liters_milli,
              recommended_minutes,recommended_duration_seconds,warnings,explanation,calculated_at,created_at
            ) values(
              (estimate->>'id')::uuid,auth.uid(),(payload->>'sector_id')::uuid,(payload->>'id')::uuid,
              (payload->>'crop_assignment_id')::uuid,(estimate->>'config_id')::uuid,(estimate->>'config_version')::integer,
              (estimate->>'algorithm_version')::integer,(estimate->>'rule_id')::uuid,(estimate->>'rule_version')::integer,
              coalesce(estimate->>'soil_type_code','unknown'),estimate->'inputs',(estimate->>'recommended_volume_ml')::bigint,
              ceil((estimate->>'recommended_duration_seconds')::numeric/60)::integer,
              (estimate->>'recommended_duration_seconds')::integer,coalesce(estimate->'warnings','[]'::jsonb),
              coalesce(estimate->'explanation','{}'::jsonb),now(),now()
            ) on conflict(id) do update set id = excluded.id
              where irrigation_estimates.owner_id = excluded.owner_id
                and irrigation_estimates.irrigation_labor_id = excluded.irrigation_labor_id
                and irrigation_estimates.sector_id = excluded.sector_id;
            if not found then raise exception 'identity_unavailable'; end if;
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
