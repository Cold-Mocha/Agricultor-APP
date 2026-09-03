begin;
select plan(3);
select has_table('public', 'photo_attachments', 'photo metadata table exists');
select ok(
  (select relrowsecurity from pg_class where oid = 'public.photo_attachments'::regclass),
  'photo metadata RLS is active'
);
select ok((select public = false from storage.buckets where id = 'photos'), 'photo bucket is private');
select * from finish();
rollback;
