create table public.parcels (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 120),
  locality text,
  is_active boolean not null default false,
  is_archived boolean not null default false,
  version bigint not null default 1 check (version > 0),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create unique index parcels_one_active_per_owner
  on public.parcels(owner_id) where is_active and deleted_at is null;
create index parcels_owner_updated_idx on public.parcels(owner_id, updated_at, id);

alter table public.parcels enable row level security;
create policy parcels_owner_all on public.parcels
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
