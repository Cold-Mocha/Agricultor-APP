-- AgroCampo 002: additive functional-core schema. Keep migrations 0001-0011 immutable.
alter table public.parcels add column if not exists sync_state text not null default 'synced';
alter table public.parcels add column if not exists server_updated_at timestamptz;
alter table public.parcels add column if not exists last_sync_error_code text;

alter table public.sectors add column if not exists sync_state text not null default 'synced';
alter table public.sectors add column if not exists server_updated_at timestamptz;
alter table public.sectors add column if not exists last_sync_error_code text;

alter table public.custom_crops add column if not exists normalized_name text;
alter table public.custom_crops add column if not exists description text;
alter table public.custom_crops add column if not exists archived_at timestamptz;
alter table public.custom_crops add column if not exists version bigint not null default 1;
alter table public.custom_crops add column if not exists deleted_at timestamptz;
update public.custom_crops set normalized_name = lower(trim(name)) where normalized_name is null;
alter table public.custom_crops alter column normalized_name set not null;
create unique index if not exists custom_crops_owner_name_active_idx
  on public.custom_crops(owner_id, normalized_name) where deleted_at is null and archived_at is null;

create table public.agricultural_seasons (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  parcel_id uuid not null references public.parcels(id),
  name text not null check (char_length(trim(name)) between 1 and 120),
  starts_on date not null,
  ends_on date,
  status text not null check (status in ('planned','active','closed')),
  notes text,
  is_migration_backfill boolean not null default false,
  version bigint not null default 1 check (version > 0),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (ends_on is null or ends_on >= starts_on)
);
create unique index agricultural_seasons_active_idx
  on public.agricultural_seasons(parcel_id) where status = 'active' and deleted_at is null;
create index agricultural_seasons_owner_parcel_idx
  on public.agricultural_seasons(owner_id, parcel_id, starts_on desc);
alter table public.agricultural_seasons enable row level security;
create policy agricultural_seasons_owner_all on public.agricultural_seasons
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

insert into public.agricultural_seasons
  (id, owner_id, parcel_id, name, starts_on, status, is_migration_backfill, updated_at)
select gen_random_uuid(), p.owner_id, p.id, 'Temporada importada', p.updated_at::date,
       case when p.is_archived then 'closed' else 'active' end, true, p.updated_at
from public.parcels p
where p.deleted_at is null
  and not exists (select 1 from public.agricultural_seasons s where s.parcel_id = p.id);

alter table public.crop_seasons add column if not exists agricultural_season_id uuid references public.agricultural_seasons(id);
alter table public.crop_seasons add column if not exists notes text;
alter table public.crop_seasons add column if not exists version bigint not null default 1;
alter table public.crop_seasons add column if not exists deleted_at timestamptz;
update public.crop_seasons cs set agricultural_season_id = s.id
from public.sectors sec join public.agricultural_seasons s on s.parcel_id = sec.parcel_id and s.is_migration_backfill
where cs.sector_id = sec.id and cs.agricultural_season_id is null;
create index crop_seasons_owner_sector_start_idx on public.crop_seasons(owner_id, sector_id, starts_on desc);
create index crop_seasons_owner_agricultural_season_idx on public.crop_seasons(owner_id, agricultural_season_id, sector_id);

create table public.sector_irrigation_configs (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  sector_id uuid not null references public.sectors(id),
  method text not null check (method = 'drip'),
  plant_count integer not null check (plant_count > 0),
  emitter_count integer not null check (emitter_count > 0),
  emitters_per_plant_milli integer,
  flow_ml_min integer not null check (flow_ml_min > 0),
  pressure_kpa integer,
  distribution_notes text,
  effective_from timestamptz not null,
  effective_to timestamptz,
  config_version integer not null check (config_version > 0),
  version bigint not null default 1 check (version > 0),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (effective_to is null or effective_to > effective_from)
);
create unique index sector_irrigation_configs_current_idx
  on public.sector_irrigation_configs(owner_id, sector_id, method)
  where effective_to is null and deleted_at is null;
alter table public.sector_irrigation_configs enable row level security;
create policy sector_irrigation_configs_owner_all on public.sector_irrigation_configs
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

alter table public.labors add column if not exists agricultural_season_id uuid references public.agricultural_seasons(id);
alter table public.labors add column if not exists crop_assignment_id uuid references public.crop_seasons(id);
alter table public.labors add column if not exists details_schema_version integer not null default 1;
alter table public.labors add column if not exists status text not null default 'recorded';
alter table public.labors add column if not exists supersedes_labor_id uuid references public.labors(id);
alter table public.labors add column if not exists version bigint not null default 1;
alter table public.labors add column if not exists deleted_at timestamptz;

alter table public.irrigation_records add column if not exists labor_id uuid references public.labors(id);
alter table public.irrigation_records add column if not exists config_id uuid references public.sector_irrigation_configs(id);
alter table public.irrigation_records add column if not exists config_version integer;
alter table public.irrigation_records add column if not exists duration_seconds integer;
alter table public.irrigation_records add column if not exists applied_volume_ml bigint;
alter table public.irrigation_records add column if not exists performed_details jsonb;
create unique index irrigation_records_labor_idx on public.irrigation_records(labor_id) where labor_id is not null;

alter table public.production_records add column if not exists labor_id uuid references public.labors(id);
create unique index production_records_labor_idx on public.production_records(labor_id) where labor_id is not null;

alter table public.reminders add column if not exists parcel_id uuid references public.parcels(id);
alter table public.reminders add column if not exists description text;
alter table public.reminders add column if not exists source_time_zone text;
alter table public.reminders add column if not exists status text not null default 'scheduled';
alter table public.reminders add column if not exists completed_at timestamptz;
alter table public.reminders add column if not exists cancelled_at timestamptz;
alter table public.reminders add column if not exists version bigint not null default 1;
alter table public.reminders add column if not exists deleted_at timestamptz;
