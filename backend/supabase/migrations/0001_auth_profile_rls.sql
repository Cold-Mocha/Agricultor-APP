create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (length(btrim(display_name)) between 1 and 120),
  email_display text,
  locale text not null default 'es_CL' check (locale = 'es_CL'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

revoke all on public.profiles from anon;
revoke all on public.profiles from authenticated;
grant select, insert, update on public.profiles to authenticated;

create policy "profiles_select_owner"
on public.profiles for select to authenticated
using ((select auth.uid()) = id);

create policy "profiles_insert_owner"
on public.profiles for insert to authenticated
with check ((select auth.uid()) = id);

create policy "profiles_update_owner"
on public.profiles for update to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create or replace function public.prevent_profile_identity_change()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin
  if new.id <> old.id then
    raise exception 'profile_identity_immutable';
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists profiles_identity_guard on public.profiles;
create trigger profiles_identity_guard
before update on public.profiles
for each row execute function public.prevent_profile_identity_change();
