create table public.labors (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  parcel_id uuid not null references public.parcels(id),
  sector_id uuid not null references public.sectors(id),
  season_id uuid references public.crop_seasons(id),
  type text not null check (type in ('irrigation','soil','fertilization','diseaseAndPestControl','sowing','pruning','harvest','apiary','other')),
  custom_name text,
  details jsonb not null default '{}'::jsonb,
  notes text,
  occurred_at timestamptz not null,
  updated_at timestamptz not null default now(),
  check (type <> 'other' or (char_length(trim(custom_name)) > 0 and char_length(trim(notes)) > 0))
);

create table public.soil_measurements (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  sector_id uuid not null references public.sectors(id),
  moisture_percent double precision check (moisture_percent between 0 and 100),
  ph double precision check (ph between 0 and 14),
  temperature_celsius double precision,
  conductivity double precision check (conductivity >= 0),
  nitrogen double precision check (nitrogen >= 0),
  phosphorus double precision check (phosphorus >= 0),
  potassium double precision check (potassium >= 0),
  notes text,
  measured_at timestamptz not null,
  updated_at timestamptz not null default now(),
  check (num_nonnulls(moisture_percent, ph, temperature_celsius, conductivity, nitrogen, phosphorus, potassium) > 0)
);

create table public.irrigation_records (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  sector_id uuid not null references public.sectors(id),
  irrigation_type text not null check (irrigation_type in ('drip','sprinkler','furrow','gravity')),
  soil_type_code text not null,
  flow_liters_per_hour double precision check (flow_liters_per_hour > 0),
  duration_minutes integer not null check (duration_minutes > 0),
  estimated_liters double precision,
  irrigated_at timestamptz not null,
  updated_at timestamptz not null default now()
);

alter table public.labors enable row level security;
alter table public.soil_measurements enable row level security;
alter table public.irrigation_records enable row level security;
create policy labors_owner_all on public.labors for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy soil_owner_all on public.soil_measurements for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy irrigation_owner_all on public.irrigation_records for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
