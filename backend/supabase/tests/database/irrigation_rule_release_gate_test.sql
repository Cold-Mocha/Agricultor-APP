begin;
select plan(7);

select has_column('public', 'crop_irrigation_rules', 'reviewer', 'reviewer is persisted');
select has_column('public', 'crop_irrigation_rules', 'approved_vector_count', 'approved vector count is persisted');
select has_column('public', 'crop_irrigation_rules', 'base_ml_per_plant', 'base coefficient is persisted');
select has_column('public', 'crop_irrigation_rules', 'minimum_adjustment_bp', 'minimum bound is persisted');
select has_column('public', 'crop_irrigation_rules', 'maximum_adjustment_bp', 'maximum bound is persisted');

insert into public.official_crops(id, common_name, category, color_token, icon_asset)
values ('release-gate-test', 'Cultivo de prueba', 'test', 'test', 'test')
on conflict (id) do nothing;

select throws_ok(
  $$insert into public.crop_irrigation_rules(
      id, crop_id, soil_type_code, version, soil_multiplier_permille,
      efficiency_permille, minimum_duration_minutes, maximum_duration_minutes,
      source_title, source_reference, approved_at, is_active
    ) values (
      '00000000-0000-4000-8000-000000000191', 'release-gate-test', 'loamy', 1,
      1000, 900, 1, 120, 'Fuente', 'Referencia', now(), true
    )$$,
  '23514',
  null,
  'an active rule without reviewer and vectors is rejected'
);

select lives_ok(
  $$insert into public.crop_irrigation_rules(
      id, crop_id, soil_type_code, version, soil_multiplier_permille,
      efficiency_permille, minimum_duration_minutes, maximum_duration_minutes,
      source_title, source_reference, reviewer, approved_at,
      approved_vector_count, base_ml_per_plant,
      minimum_adjustment_bp, maximum_adjustment_bp, is_active
    ) values (
      '00000000-0000-4000-8000-000000000192', 'release-gate-test', 'loamy', 1,
      1000, 900, 1, 120, 'Fuente', 'Referencia', 'Revisor agronómico', now(),
      20, 1000, 5000, 15000, true
    )$$,
  'a fully approved immutable rule is accepted'
);

select * from finish();
rollback;
