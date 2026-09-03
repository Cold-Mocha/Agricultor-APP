-- AgroCampo Sync v2. The authenticated JWT is the sole ownership authority.
alter table public.sync_operations add column if not exists request_hash text;
alter table public.sync_operations add column if not exists protocol_version integer not null default 2;
alter table public.sync_operations add column if not exists status text not null default 'applied';
alter table public.sync_changes add column if not exists remote_version bigint;

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
      elsif operation->>'aggregate_type' <> 'parcel' then
        result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'aggregate_unsupported');
      elsif coalesce((operation->>'payload_schema_version')::integer, 0) <> 1
          or jsonb_typeof(payload) <> 'object'
          or payload->>'id' is distinct from operation->>'aggregate_id' then
        result_row := jsonb_build_object('operation_id', operation_uuid, 'status', 'rejected', 'error_code', 'payload_invalid');
      else
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
          if coalesce((payload->>'is_active')::boolean, false) then
            update public.parcels set is_active = false
            where owner_id = auth.uid() and id <> aggregate_uuid and is_active;
          end if;
          insert into public.parcels(
            id, owner_id, name, locality, is_active, is_archived,
            version, updated_at, deleted_at
          ) values (
            aggregate_uuid, auth.uid(), coalesce(nullif(trim(payload->>'name'), ''), 'Parcela'),
            payload->>'locality', coalesce((payload->>'is_active')::boolean, false),
            coalesce((payload->>'is_archived')::boolean, false), next_version,
            coalesce((payload->>'updated_at')::timestamptz, now()),
            case when operation->>'mutation_kind' = 'delete'
              then coalesce((payload->>'deleted_at')::timestamptz, now()) else null end
          ) on conflict (id) do update set
            name = excluded.name, locality = excluded.locality,
            is_active = excluded.is_active, is_archived = excluded.is_archived,
            version = excluded.version, updated_at = excluded.updated_at,
            deleted_at = excluded.deleted_at;

          insert into public.sync_changes(
            owner_id, aggregate_type, aggregate_id, mutation_kind, payload, remote_version
          ) values (
            auth.uid(), 'parcel', aggregate_uuid, operation->>'mutation_kind',
            payload || jsonb_build_object('version', next_version), next_version
          ) returning change_seq into change_number;

          result_row := jsonb_build_object(
            'operation_id', operation_uuid, 'status', 'applied',
            'remote_version', next_version, 'change_seq', change_number
          );
          insert into public.sync_operations(
            owner_id, operation_id, aggregate_type, aggregate_id,
            request_hash, protocol_version, status, result
          ) values (
            auth.uid(), operation_uuid, 'parcel', aggregate_uuid,
            request_hash_value, 2, 'applied', result_row
          );
        end if;
      end if;
    exception when others then
      result_row := jsonb_build_object(
        'operation_id', operation->>'operation_id', 'status', 'rejected',
        'error_code', case when sqlstate = '22P02' then 'payload_invalid' else 'operation_invalid' end
      );
    end;
    results := results || jsonb_build_array(result_row);
  end loop;
  return jsonb_build_object('protocol_version', 2, 'results', results);
end $$;

drop function if exists public.sync_pull(bigint, integer);
create function public.sync_pull(after_cursor bigint default 0, page_size integer default 200)
returns table(
  change_seq bigint, aggregate_type text, aggregate_id uuid,
  mutation_kind text, payload jsonb, remote_version bigint
)
language sql security invoker set search_path = public as $$
  select c.change_seq, c.aggregate_type, c.aggregate_id, c.mutation_kind,
         c.payload, c.remote_version
  from public.sync_changes c
  where c.owner_id = auth.uid() and c.change_seq > after_cursor
  order by c.change_seq asc
  limit least(greatest(page_size, 1), 200);
$$;
