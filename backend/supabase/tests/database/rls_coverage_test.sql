begin;
select plan(2);

select is(
  (select count(*)::integer
   from pg_class c
   join pg_namespace n on n.oid = c.relnamespace
   join information_schema.columns col on col.table_schema = n.nspname and col.table_name = c.relname
   where n.nspname = 'public' and c.relkind = 'r' and col.column_name = 'owner_id' and not c.relrowsecurity),
  0,
  'every public owner-scoped table has RLS enabled'
);

select is(
  (select count(*)::integer from storage.buckets where id = 'photos' and public),
  0,
  'photo bucket is never public'
);

select * from finish();
rollback;
