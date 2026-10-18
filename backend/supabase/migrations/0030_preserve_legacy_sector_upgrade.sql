-- Bridge for a deployment still on 0020. Fresh stacks already applied 0021
-- and skip this block. Existing parcel/season metadata is retained privately;
-- no reset, guessed sector, or agricultural-record deletion is performed.
do $$
begin
  if to_regclass('public.parcels') is null then return; end if;
  if exists(select 1 from public.sectors) or exists(select 1 from public.labors)
      or exists(select 1 from public.crop_seasons) then
    raise exception 'legacy_sector_upgrade_requires_data_mapping';
  end if;
  create schema if not exists agrocampo_legacy;
  revoke all on schema agrocampo_legacy from public, anon, authenticated;
  create table agrocampo_legacy.agricultural_seasons_before_sector_only
    as select * from public.agricultural_seasons;

  drop trigger if exists sectors_containment on public.sectors;
  drop function if exists public.enforce_sector_inside_parcel();
  drop index if exists public.sectors_owner_parcel_idx;
  alter table public.sectors drop column parcel_id;
  alter table public.sectors add constraint sectors_owner_number_key unique(owner_id,number);
  create index sectors_owner_number_idx on public.sectors(owner_id,number) where deleted_at is null;

  drop index if exists public.agricultural_seasons_active_idx;
  drop index if exists public.agricultural_seasons_owner_parcel_idx;
  alter table public.agricultural_seasons drop column parcel_id;
  alter table public.agricultural_seasons add column sector_id uuid references public.sectors(id);
  -- Retain an unmapped legacy season; enforce sector context on every new row.
  alter table public.agricultural_seasons add constraint seasons_require_sector
    check(sector_id is not null) not valid;
  create unique index agricultural_seasons_one_active_per_sector
    on public.agricultural_seasons(sector_id) where status='active' and deleted_at is null;
  create index agricultural_seasons_owner_sector_idx
    on public.agricultural_seasons(owner_id,sector_id,starts_on desc);

  alter table public.labors drop column parcel_id;
  alter table public.production_records drop column parcel_id;
  alter table public.reminders drop column parcel_id;
  alter table public.parcels set schema agrocampo_legacy;
  revoke all on all tables in schema agrocampo_legacy from public, anon, authenticated;
end $$;
