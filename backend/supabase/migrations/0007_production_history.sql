create table public.production_records (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  parcel_id uuid not null references public.parcels(id),
  sector_id uuid not null references public.sectors(id),
  season_id uuid references public.crop_seasons(id),
  crop_id text not null,
  quantity double precision not null check (quantity > 0),
  unit text not null check (char_length(trim(unit)) > 0),
  quality_notes text,
  harvested_at timestamptz not null,
  updated_at timestamptz not null default now()
);
create index production_history_idx on public.production_records(owner_id, parcel_id, sector_id, season_id, harvested_at desc);
create index labors_history_idx on public.labors(owner_id, parcel_id, sector_id, season_id, occurred_at desc);
alter table public.production_records enable row level security;
create policy production_owner_all on public.production_records
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
