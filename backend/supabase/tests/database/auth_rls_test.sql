begin;
select plan(5);

select has_table('public', 'profiles', 'profiles exists');
select has_column('public', 'profiles', 'id', 'profile identity exists');
select policies_are(
  'public',
  'profiles',
  array['profiles_insert_owner', 'profiles_select_owner', 'profiles_update_owner'],
  'owner policies are explicit'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  'RLS is active'
);
select isnt_empty(
  $$select 1 from information_schema.table_privileges where table_schema='public' and table_name='profiles' and grantee='authenticated'$$,
  'authenticated receives explicit grants'
);

select * from finish();
rollback;
