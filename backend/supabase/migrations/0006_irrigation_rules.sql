create table public.crop_irrigation_rules (
  id uuid primary key,
  crop_id text not null references public.official_crops(id),
  soil_type_code text not null,
  version integer not null check (version > 0),
  soil_multiplier_permille integer not null check (soil_multiplier_permille > 0),
  efficiency_permille integer not null check (efficiency_permille between 1 and 1000),
  minimum_duration_minutes integer not null check (minimum_duration_minutes > 0),
  maximum_duration_minutes integer not null check (maximum_duration_minutes >= minimum_duration_minutes),
  source_title text not null,
  source_reference text not null,
  approved_at timestamptz,
  is_active boolean not null default false,
  unique(crop_id, soil_type_code, version),
  check (not is_active or approved_at is not null)
);

create table public.irrigation_estimates (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  sector_id uuid not null references public.sectors(id),
  rule_id uuid not null references public.crop_irrigation_rules(id),
  rule_version integer not null,
  soil_type_code text not null,
  inputs jsonb not null,
  estimated_liters_milli bigint not null check (estimated_liters_milli > 0),
  recommended_minutes integer not null check (recommended_minutes > 0),
  warnings jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.crop_irrigation_rules enable row level security;
alter table public.irrigation_estimates enable row level security;
create policy irrigation_rules_read_approved on public.crop_irrigation_rules
  for select using (auth.role() = 'authenticated' and is_active and approved_at is not null);
create policy irrigation_estimates_owner_all on public.irrigation_estimates
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

-- Intentionally no seed rows: agricultural coefficients require explicit validation and 20 vectors.
