-- Only test-owned accounts. Requires the disposable project's localhost guard
-- in scripts/run_local_supabase_gate.py before PostgreSQL access.
begin;
create temp table fixture_owners as
select id from auth.users where email like 'qa-persistence-%@example.invalid'
  or email like 'territory-e2e-%@example.invalid'
  or email like 'seasons-e2e-%@example.invalid'
  or email like 'labors-e2e-%@example.invalid'
  or email like 'specialization-e2e-%@example.invalid';
do $$ declare table_name text; begin
  foreach table_name in array array['sync_changes','sync_operations','irrigation_estimates','irrigation_records',
    'production_records','soil_measurements','apiary_inspections','photos','reminders','sector_irrigation_configs',
    'labors','crop_seasons','agricultural_seasons','custom_crops','sectors','device_installations'] loop
    if to_regclass('public.'||table_name) is not null then
      execute format('delete from public.%I where owner_id in (select id from fixture_owners)',table_name);
    end if;
  end loop;
end $$;
delete from auth.users where id in (select id from fixture_owners);
commit;
