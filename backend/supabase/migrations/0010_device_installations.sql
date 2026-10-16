create table public.device_installations (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  fcm_token text not null,
  platform text not null check (platform = 'android'),
  updated_at timestamptz not null default now(),
  unique(owner_id, fcm_token)
);
alter table public.device_installations enable row level security;
create policy installations_owner_all on public.device_installations
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
