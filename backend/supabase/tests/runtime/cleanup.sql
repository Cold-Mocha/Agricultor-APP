-- No TRUNCATE ni reset. Sólo owner ficticio A/B, en orden de dependencias.
begin;
do $$
declare t text;
begin
  foreach t in array array[
    'sync_changes','sync_operations','irrigation_estimates','irrigation_records',
    'production_records','soil_measurements','apiary_inspections','photos','reminders',
    'sector_irrigation_configs','labors','crop_seasons','agricultural_seasons',
    'custom_crops','sectors','device_installations'
  ] loop
    if to_regclass('public.'||t) is not null then
      execute format('delete from public.%I where owner_id in ($1,$2)',t)
      using 'ac200000-0000-4000-8000-000000000001'::uuid,
            'ac200000-0000-4000-8000-000000000002'::uuid;
    end if;
  end loop;
end $$;
delete from auth.users where id in (
  'ac200000-0000-4000-8000-000000000001','ac200000-0000-4000-8000-000000000002');
commit;
