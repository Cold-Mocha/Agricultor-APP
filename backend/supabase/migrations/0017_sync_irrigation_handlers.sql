-- Sync v2 drip configuration and irrigation specialization.
alter table public.irrigation_estimates add column if not exists irrigation_labor_id uuid references public.labors(id);
alter table public.irrigation_estimates add column if not exists crop_assignment_id uuid references public.crop_seasons(id);
alter table public.irrigation_estimates add column if not exists config_id uuid references public.sector_irrigation_configs(id);
alter table public.irrigation_estimates add column if not exists config_version integer;
alter table public.irrigation_estimates add column if not exists algorithm_version integer not null default 1;
alter table public.irrigation_estimates add column if not exists recommended_duration_seconds integer;
alter table public.irrigation_estimates add column if not exists explanation jsonb not null default '{}'::jsonb;
alter table public.irrigation_estimates add column if not exists calculated_at timestamptz;
create unique index if not exists irrigation_estimates_labor_idx
  on public.irrigation_estimates(irrigation_labor_id) where irrigation_labor_id is not null;

alter function public.sync_push(jsonb) rename to sync_push_labor_v2;

create or replace function public.sync_push(operations jsonb)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
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
          select * into current_config from public.sector_irrigation_configs
            where id=aggregate_uuid and owner_id=auth.uid() for update;
          if found and operation->>'base_version' is not null
             and current_config.version<>(operation->>'base_version')::bigint then
            result_row := jsonb_build_object('operation_id',operation_uuid,'status','conflict','remote_version',current_config.version,'error_code','version_conflict');
          else
            next_version := case when found then current_config.version+1 else 1 end;
            if payload->>'supersedes_config_id' is not null then
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
              version=excluded.version,updated_at=excluded.updated_at,deleted_at=excluded.deleted_at;
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
           and result_row->>'status' in ('applied','duplicate') then
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
            performed_details=excluded.performed_details,updated_at=excluded.updated_at;
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
            ) on conflict(id) do nothing;
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
