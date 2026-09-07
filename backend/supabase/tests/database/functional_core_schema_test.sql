begin;
select plan(12);

select has_table('public', 'agricultural_seasons', 'agricultural seasons exist');
select has_table('public', 'sector_irrigation_configs', 'irrigation configs exist');
select has_column('public', 'crop_seasons', 'agricultural_season_id', 'assignment links season');
select has_column('public', 'labors', 'crop_assignment_id', 'labor links assignment');
select has_column('public', 'labors', 'details_schema_version', 'labor details are versioned');
select has_column('public', 'irrigation_records', 'labor_id', 'irrigation links labor');
select has_column('public', 'production_records', 'labor_id', 'production links labor');
select has_column('public', 'reminders', 'parcel_id', 'reminder links parcel');
select has_column('public', 'custom_crops', 'normalized_name', 'custom crop name normalized');
select ok(
  (select relrowsecurity from pg_class where oid = 'public.agricultural_seasons'::regclass),
  'agricultural seasons RLS active'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.sector_irrigation_configs'::regclass),
  'irrigation configs RLS active'
);
select is_empty(
  $$select 1 from public.crop_seasons where agricultural_season_id is null$$,
  'legacy assignments receive a season'
);

select * from finish();
rollback;
