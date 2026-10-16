-- Sync v2 reminders. Android notification bindings remain device-local.
alter function public.sync_push(jsonb) rename to sync_push_irrigation_v2;

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
        elsif payload->>'parcel_id' is not null and not exists(
          select 1 from public.parcels where id=(payload->>'parcel_id')::uuid and owner_id=auth.uid() and deleted_at is null
        ) then
          result_row := jsonb_build_object('operation_id',operation_uuid,'status','rejected','error_code','reminder_parent_missing');
        elsif payload->>'sector_id' is not null and not exists(
          select 1 from public.sectors where id=(payload->>'sector_id')::uuid and owner_id=auth.uid()
            and (payload->>'parcel_id' is null or parcel_id=(payload->>'parcel_id')::uuid) and deleted_at is null
        ) then
          result_row := jsonb_build_object('operation_id',operation_uuid,'status','rejected','error_code','reminder_parent_missing');
        else
          select * into current_row from public.reminders where id=aggregate_uuid and owner_id=auth.uid() for update;
          if found and operation->>'base_version' is not null and current_row.version<>(operation->>'base_version')::bigint then
            result_row := jsonb_build_object('operation_id',operation_uuid,'status','conflict','remote_version',current_row.version,'error_code','version_conflict');
          else
            next_version := case when found then current_row.version+1 else 1 end;
            insert into public.reminders(
              id,owner_id,parcel_id,sector_id,title,description,notes,scheduled_at,
              source_time_zone,status,is_completed,completed_at,cancelled_at,version,updated_at,deleted_at
            ) values(
              aggregate_uuid,auth.uid(),nullif(payload->>'parcel_id','')::uuid,nullif(payload->>'sector_id','')::uuid,
              trim(payload->>'title'),payload->>'description',payload->>'notes',(payload->>'scheduled_at')::timestamptz,
              coalesce(payload->>'source_time_zone','UTC'),payload->>'status',payload->>'status'='completed',
              nullif(payload->>'completed_at','')::timestamptz,nullif(payload->>'cancelled_at','')::timestamptz,
              next_version,coalesce((payload->>'updated_at')::timestamptz,now()),
              case when operation->>'mutation_kind'='delete' then coalesce(nullif(payload->>'deleted_at','')::timestamptz,now()) else nullif(payload->>'deleted_at','')::timestamptz end
            ) on conflict(id) do update set
              parcel_id=excluded.parcel_id,sector_id=excluded.sector_id,title=excluded.title,
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
