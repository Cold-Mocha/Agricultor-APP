insert into storage.buckets(id, name, public) values ('photos', 'photos', false)
on conflict (id) do update set public = false;

create table public.photo_attachments (
  id uuid primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  aggregate_type text not null,
  aggregate_id uuid not null,
  content_hash text not null,
  mime_type text not null check (mime_type like 'image/%'),
  storage_path text not null,
  captured_at timestamptz not null,
  unique(owner_id, content_hash),
  check (storage_path like owner_id::text || '/%')
);
alter table public.photo_attachments enable row level security;
create policy photo_metadata_owner_all on public.photo_attachments
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy photo_objects_owner_select on storage.objects for select
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy photo_objects_owner_insert on storage.objects for insert
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy photo_objects_owner_delete on storage.objects for delete
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
