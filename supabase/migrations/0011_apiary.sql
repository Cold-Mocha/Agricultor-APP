create table if not exists public.apiary_inspections (
  id uuid primary key,
  owner_id uuid not null references auth.users(id),
  sector_id uuid not null references public.sectors(id),
  task_type text not null,
  beekeeper_name text not null,
  hive_count integer not null check (hive_count > 0),
  queen_status text not null,
  brood_status text not null,
  feeding_status text not null,
  health_notes text not null,
  pest_notes text not null,
  super_installed boolean not null default false,
  observations text,
  inspected_at timestamptz not null,
  updated_at timestamptz not null default now()
);

alter table public.apiary_inspections enable row level security;
create policy apiary_inspections_owner_all on public.apiary_inspections
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
