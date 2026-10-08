begin;
select plan(2);

select policies_are(
  'public',
  'device_installations',
  array['installations_owner_all'],
  'device installation access is owner-scoped'
);

select is(
  (select count(*)::integer from pg_policies
    where schemaname = 'public'
      and tablename = 'device_installations'
      and qual like '%auth.uid()%'),
  1,
  'policy checks the authenticated owner'
);

select * from finish();
rollback;
