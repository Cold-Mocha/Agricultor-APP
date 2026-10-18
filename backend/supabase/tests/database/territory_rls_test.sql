begin;
select plan(6);
select has_table('public', 'sectors', 'sectors exists');
select has_table('public', 'official_crops', 'official catalog exists');
select has_table('public', 'custom_crops', 'custom crops exist');
select has_table('public', 'crop_seasons', 'crop seasons exist');
select ok(
  (select relrowsecurity from pg_class where oid = 'public.sectors'::regclass),
  'sector RLS is active'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.crop_seasons'::regclass),
  'crop season RLS is active'
);
select * from finish();
rollback;
