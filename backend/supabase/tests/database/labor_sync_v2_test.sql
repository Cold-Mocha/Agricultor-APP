begin;
select plan(14);

insert into auth.users(id, aud, role, email, created_at, updated_at) values
  ('41000000-0000-4000-8000-000000000001','authenticated','authenticated','labor-a@test.local',now(),now()),
  ('41000000-0000-4000-8000-000000000002','authenticated','authenticated','labor-b@test.local',now(),now());
select set_config('request.jwt.claim.sub','41000000-0000-4000-8000-000000000001',true);

insert into public.parcels(id,owner_id,name,is_active,boundary,updated_at)
values('42000000-0000-4000-8000-000000000001','41000000-0000-4000-8000-000000000001','Campo',true,
  extensions.st_geomfromtext('POLYGON((-72.7 -38.8,-72.5 -38.8,-72.5 -38.6,-72.7 -38.6,-72.7 -38.8))',4326),now());
insert into public.sectors(id,owner_id,parcel_id,number,name,boundary,updated_at)
values('43000000-0000-4000-8000-000000000001','41000000-0000-4000-8000-000000000001','42000000-0000-4000-8000-000000000001',1,'Norte',
  extensions.st_geomfromtext('POLYGON((-72.65 -38.75,-72.55 -38.75,-72.55 -38.65,-72.65 -38.65,-72.65 -38.75))',4326),now());
insert into public.agricultural_seasons(id,owner_id,parcel_id,name,starts_on,status,updated_at)
values('44000000-0000-4000-8000-000000000001','41000000-0000-4000-8000-000000000001','42000000-0000-4000-8000-000000000001','2026','2026-01-01','active',now());
insert into public.custom_crops(id,owner_id,name,normalized_name,updated_at)
values('45000000-0000-4000-8000-000000000001','41000000-0000-4000-8000-000000000001','Ají','aji',now());
insert into public.crop_seasons(id,owner_id,sector_id,agricultural_season_id,crop_id,is_custom_crop,status,starts_on,updated_at)
values('46000000-0000-4000-8000-000000000001','41000000-0000-4000-8000-000000000001','43000000-0000-4000-8000-000000000001','44000000-0000-4000-8000-000000000001','45000000-0000-4000-8000-000000000001',true,'active','2026-01-01',now());

create function pg_temp.labor_payload(id text, kind text default 'fertilization') returns jsonb
language sql as $$ select jsonb_build_object(
  'id',id,'parcel_id','42000000-0000-4000-8000-000000000001',
  'sector_id','43000000-0000-4000-8000-000000000001',
  'agricultural_season_id','44000000-0000-4000-8000-000000000001',
  'crop_assignment_id','46000000-0000-4000-8000-000000000001',
  'type',kind,'details',jsonb_build_object('schemaVersion',1,'type',kind,'data',jsonb_build_object('amount',10)),
  'details_schema_version',1,'status','recorded','occurred_at','2026-03-01T10:00:00Z',
  'updated_at','2026-03-01T10:00:00Z') $$;
create function pg_temp.push(op_id text, labor_id text, payload jsonb, mutation text default 'create', base bigint default null) returns jsonb
language sql as $$ select public.sync_push(jsonb_build_array(jsonb_build_object(
  'operation_id',op_id,'aggregate_type','labor','aggregate_id',labor_id,
  'mutation_kind',mutation,'protocol_version',2,'payload_schema_version',1,
  'base_version',base,'request_hash',op_id,'payload',payload)))->'results'->0 $$;

select is(pg_temp.push('47000000-0000-4000-8000-000000000001','48000000-0000-4000-8000-000000000001',
  pg_temp.labor_payload('48000000-0000-4000-8000-000000000001'))->>'status','applied','labor applies');
select is((select count(*)::integer from public.labors where id='48000000-0000-4000-8000-000000000001'),1,'labor exists before ACK');
select is(pg_temp.push('47000000-0000-4000-8000-000000000001','48000000-0000-4000-8000-000000000001','{}')->>'status','duplicate','retry is idempotent');

select is(pg_temp.push('47000000-0000-4000-8000-000000000002','48000000-0000-4000-8000-000000000099',
  pg_temp.labor_payload('48000000-0000-4000-8000-000000000099') || jsonb_build_object('sector_id','43000000-0000-4000-8000-000000000099'))->>'error_code',
  'labor_parent_missing','missing parent rejects');
select is((select count(*)::integer from public.sync_operations where operation_id='47000000-0000-4000-8000-000000000002'),0,'rejection has no false receipt');

select is(pg_temp.push('47000000-0000-4000-8000-000000000003','48000000-0000-4000-8000-000000000001',
  pg_temp.labor_payload('48000000-0000-4000-8000-000000000001'),'update',0)->>'status','conflict','stale update conflicts');

select is(pg_temp.push('47000000-0000-4000-8000-000000000004','48000000-0000-4000-8000-000000000002',
  pg_temp.labor_payload('48000000-0000-4000-8000-000000000002','harvest') || jsonb_build_object('production',jsonb_build_object(
    'id','49000000-0000-4000-8000-000000000001','labor_id','48000000-0000-4000-8000-000000000002',
    'crop_id','45000000-0000-4000-8000-000000000001','quantity',125,'unit','kg',
    'harvested_at','2026-03-01T10:00:00Z','updated_at','2026-03-01T10:00:00Z')))->>'status','applied','harvest aggregate applies');
select is((select count(*)::integer from public.production_records where labor_id='48000000-0000-4000-8000-000000000002'),1,'production child created once');
select is((select count(*)::integer from public.sync_changes where aggregate_id='48000000-0000-4000-8000-000000000002'),1,'harvest emits one history change');

select is(pg_temp.push('47000000-0000-4000-8000-000000000005','48000000-0000-4000-8000-000000000003',
  pg_temp.labor_payload('48000000-0000-4000-8000-000000000003') || jsonb_build_object(
    'supersedes_labor_id','48000000-0000-4000-8000-000000000001'))->>'status','applied','correction applies');
select is((select supersedes_labor_id::text from public.labors where id='48000000-0000-4000-8000-000000000003'),
  '48000000-0000-4000-8000-000000000001','correction keeps original link');

select is(pg_temp.push('47000000-0000-4000-8000-000000000006','48000000-0000-4000-8000-000000000001',
  pg_temp.labor_payload('48000000-0000-4000-8000-000000000001') || jsonb_build_object('deleted_at','2026-04-01T00:00:00Z'),
  'delete',1)->>'status','applied','tombstone applies');
select ok((select deleted_at is not null from public.labors where id='48000000-0000-4000-8000-000000000001'),'tombstone retained');

set local role authenticated;
select set_config('request.jwt.claim.sub','41000000-0000-4000-8000-000000000002',true);
select is_empty($$select * from public.labors where owner_id='41000000-0000-4000-8000-000000000001'$$,'RLS hides another owner labors');

select * from finish();
rollback;
