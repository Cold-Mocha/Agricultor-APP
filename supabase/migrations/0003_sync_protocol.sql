create table public.sync_operations (
  owner_id uuid not null references auth.users(id) on delete cascade,
  operation_id uuid not null,
  aggregate_type text not null,
  aggregate_id uuid not null,
  applied_at timestamptz not null default now(),
  result jsonb not null default '{}'::jsonb,
  primary key (owner_id, operation_id)
);

create table public.sync_changes (
  change_seq bigint generated always as identity primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  aggregate_type text not null,
  aggregate_id uuid not null,
  mutation_kind text not null,
  payload jsonb not null,
  changed_at timestamptz not null default now()
);
create index sync_changes_owner_seq_idx on public.sync_changes(owner_id, change_seq);

alter table public.sync_operations enable row level security;
alter table public.sync_changes enable row level security;
create policy sync_operations_owner on public.sync_operations for select using (owner_id = auth.uid());
create policy sync_changes_owner on public.sync_changes for select using (owner_id = auth.uid());

create or replace function public.sync_push(operations jsonb)
returns jsonb language plpgsql security invoker set search_path = public as $$
declare
  operation jsonb;
  parcel_payload jsonb;
  acknowledgements jsonb := '[]'::jsonb;
  conflicts jsonb := '[]'::jsonb;
  inserted_count integer;
  current_parcel public.parcels%rowtype;
begin
  if jsonb_typeof(operations) <> 'array' then raise exception 'operations_must_be_array'; end if;
  for operation in select * from jsonb_array_elements(operations)
  loop
    if (operation->>'owner_id')::uuid <> auth.uid() then raise exception 'owner_mismatch'; end if;
    insert into public.sync_operations(owner_id, operation_id, aggregate_type, aggregate_id)
      values (auth.uid(), (operation->>'operation_id')::uuid, operation->>'aggregate_type', (operation->>'aggregate_id')::uuid)
      on conflict do nothing;
    get diagnostics inserted_count = row_count;
    if inserted_count = 1 and operation->>'aggregate_type' = 'parcel' then
      parcel_payload := (operation->>'payload')::jsonb;
      select * into current_parcel from public.parcels
        where id = (operation->>'aggregate_id')::uuid and owner_id = auth.uid();
      if found and operation->>'base_version' is not null
          and current_parcel.version <> (operation->>'base_version')::bigint then
        conflicts := conflicts || jsonb_build_array(jsonb_build_object(
          'id', operation->>'operation_id',
          'aggregate_type', 'parcel',
          'aggregate_id', operation->>'aggregate_id',
          'local', parcel_payload,
          'remote', to_jsonb(current_parcel)
        ));
      else
        insert into public.parcels(id, owner_id, name, locality, is_active, version, updated_at)
        values (
          (parcel_payload->>'id')::uuid,
          auth.uid(),
          parcel_payload->>'name',
          parcel_payload->>'locality',
          coalesce((parcel_payload->>'is_active')::boolean, false),
          (parcel_payload->>'version')::bigint,
          (parcel_payload->>'updated_at')::timestamptz
        )
        on conflict (id) do update set
          name = excluded.name,
          locality = excluded.locality,
          is_active = excluded.is_active,
          version = excluded.version,
          updated_at = excluded.updated_at;
        insert into public.sync_changes(owner_id, aggregate_type, aggregate_id, mutation_kind, payload)
        values (auth.uid(), 'parcel', (operation->>'aggregate_id')::uuid, operation->>'mutation_kind', parcel_payload);
      end if;
    end if;
    acknowledgements := acknowledgements || jsonb_build_array(operation->>'operation_id');
  end loop;
  return jsonb_build_object('acknowledged_operation_ids', acknowledgements, 'conflicts', conflicts);
end $$;

create or replace function public.sync_pull(after_cursor bigint default 0, page_size integer default 200)
returns table(change_seq bigint, aggregate_type text, aggregate_id uuid, mutation_kind text, payload jsonb)
language sql security invoker set search_path = public as $$
  select c.change_seq, c.aggregate_type, c.aggregate_id, c.mutation_kind, c.payload
  from public.sync_changes c
  where c.owner_id = auth.uid() and c.change_seq > after_cursor
  order by c.change_seq limit least(greatest(page_size, 1), 500);
$$;
