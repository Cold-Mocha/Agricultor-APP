-- AgroCampo 003: additive category/context links. Migrations 0001-0019 stay immutable.
alter table public.sectors
  add constraint sectors_kind_v11 check (kind in ('crop', 'apiary')) not valid;

create or replace function public.prevent_sector_kind_change()
returns trigger language plpgsql as $$
begin
  if tg_op = 'UPDATE' and new.kind is distinct from old.kind then
    raise exception 'sector_kind_immutable';
  end if;
  return new;
end $$;

drop trigger if exists sectors_kind_immutable on public.sectors;
create trigger sectors_kind_immutable
before update on public.sectors
for each row execute function public.prevent_sector_kind_change();

alter table public.labors
  add column if not exists domain_category text
    check (domain_category is null or domain_category in ('crop', 'apiary'));
alter table public.soil_measurements
  add column if not exists labor_id uuid references public.labors(id);
alter table public.apiary_inspections
  add column if not exists labor_id uuid references public.labors(id);

create unique index if not exists soil_measurements_labor_v11_idx
  on public.soil_measurements(labor_id) where labor_id is not null;
create unique index if not exists apiary_inspections_labor_v11_idx
  on public.apiary_inspections(labor_id) where labor_id is not null;
create index if not exists labors_category_history_v11_idx
  on public.labors(owner_id, domain_category, occurred_at desc, id);

create or replace function public.operation_allowed(
  category text,
  operation text
) returns boolean language sql immutable as $$
  select case
    when category = 'crop' then operation in (
      'soilMeasure', 'irrigationRecord', 'dripBasicEstimate',
      'irrigationAdvancedRecommendation', 'fertilizationRecord',
      'phytosanitaryRecord', 'cultivationRecord', 'vegetableHarvest',
      'otherVegetableLabor', 'photoAttach'
    )
    when category = 'apiary' then operation in (
      'apiaryInspection', 'apiaryFeeding', 'apiaryHealth',
      'apiaryHarvest', 'apiarySuperPlacement', 'otherApiaryOperation',
      'photoAttach'
    )
    else false
  end
$$;
