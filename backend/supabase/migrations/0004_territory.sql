create extension if not exists postgis with schema extensions;

alter table public.parcels
  add column boundary extensions.geometry(polygon, 4326),
  add column area_square_meters double precision generated always as (extensions.st_area(boundary::extensions.geography)) stored;
create index parcels_boundary_gix on public.parcels using gist(boundary);

create table public.sectors (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  parcel_id uuid not null references public.parcels(id) on delete cascade,
  number integer not null check (number > 0),
  name text not null check (char_length(trim(name)) between 1 and 120),
  kind text not null default 'crop' check (kind in ('crop', 'apiary')),
  boundary extensions.geometry(polygon, 4326) not null,
  area_square_meters double precision generated always as (extensions.st_area(boundary::extensions.geography)) stored,
  version bigint not null default 1,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique(parcel_id, number)
);
create index sectors_boundary_gix on public.sectors using gist(boundary);
create index sectors_owner_parcel_idx on public.sectors(owner_id, parcel_id, number);

create function public.enforce_sector_inside_parcel() returns trigger
language plpgsql security invoker set search_path = public, extensions as $$
begin
  if not exists (
    select 1 from public.parcels p
    where p.id = new.parcel_id and p.owner_id = new.owner_id and st_covers(p.boundary, new.boundary)
  ) then
    raise exception 'sector_outside_parcel';
  end if;
  return new;
end $$;
create trigger sectors_containment before insert or update of boundary, parcel_id on public.sectors
for each row execute function public.enforce_sector_inside_parcel();

create table public.official_crops (
  id text primary key,
  common_name text not null,
  scientific_name text,
  category text not null,
  color_token text not null,
  icon_asset text not null,
  catalog_version integer not null default 1
);

create table public.custom_crops (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 120),
  notes text,
  updated_at timestamptz not null default now()
);

create table public.crop_seasons (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  sector_id uuid not null references public.sectors(id) on delete cascade,
  crop_id text not null,
  is_custom_crop boolean not null default false,
  status text not null check (status in ('planned', 'active', 'ended', 'cancelled')),
  starts_on date not null,
  ends_on date,
  updated_at timestamptz not null default now(),
  check (ends_on is null or ends_on > starts_on)
);
create unique index crop_seasons_one_active on public.crop_seasons(sector_id) where status = 'active';

alter table public.sectors enable row level security;
alter table public.official_crops enable row level security;
alter table public.custom_crops enable row level security;
alter table public.crop_seasons enable row level security;
create policy sectors_owner_all on public.sectors for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy official_crops_read on public.official_crops for select using (auth.role() = 'authenticated');
create policy custom_crops_owner_all on public.custom_crops for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy crop_seasons_owner_all on public.crop_seasons for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
