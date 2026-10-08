create table public.reminders (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  sector_id uuid references public.sectors(id),
  title text not null check (char_length(trim(title)) > 0),
  notes text,
  scheduled_at timestamptz not null,
  is_completed boolean not null default false,
  updated_at timestamptz not null default now()
);
create index reminders_due_idx on public.reminders(owner_id, is_completed, scheduled_at);
alter table public.reminders enable row level security;
create policy reminders_owner_all on public.reminders
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
