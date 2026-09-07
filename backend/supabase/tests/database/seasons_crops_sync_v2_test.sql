begin;
select plan(19);

insert into auth.users(id, aud, role, email, created_at, updated_at) values
  ('12000000-0000-4000-8000-000000000001','authenticated','authenticated','crops-a@test.local',now(),now()),
  ('12000000-0000-4000-8000-000000000002','authenticated','authenticated','crops-b@test.local',now(),now());
select set_config('request.jwt.claim.sub','12000000-0000-4000-8000-000000000001',true);

create function pg_temp.push_result(operation jsonb) returns jsonb
language sql as $$ select public.sync_push(jsonb_build_array(operation))->'results'->0 $$;

select pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000001','aggregate_type','parcel',
  'aggregate_id','32000000-0000-4000-8000-000000000001','mutation_kind','create',
  'protocol_version',2,'payload_schema_version',1,'request_hash','crop-parcel',
  'payload',jsonb_build_object('id','32000000-0000-4000-8000-000000000001','name','Campo cultivos','is_active',true,
    'polygon',jsonb_build_array(
      jsonb_build_object('lat',-38.75,'lng',-72.61),jsonb_build_object('lat',-38.75,'lng',-72.57),
      jsonb_build_object('lat',-38.71,'lng',-72.57),jsonb_build_object('lat',-38.71,'lng',-72.61)),
    'updated_at','2026-08-01T00:00:00Z')));
select pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000002','aggregate_type','sector',
  'aggregate_id','33000000-0000-4000-8000-000000000001','mutation_kind','create',
  'protocol_version',2,'payload_schema_version',1,'request_hash','crop-sector',
  'payload',jsonb_build_object('id','33000000-0000-4000-8000-000000000001','parcel_id','32000000-0000-4000-8000-000000000001',
    'number',1,'name','Norte','polygon',jsonb_build_array(
      jsonb_build_object('lat',-38.74,'lng',-72.60),jsonb_build_object('lat',-38.74,'lng',-72.59),
      jsonb_build_object('lat',-38.73,'lng',-72.59),jsonb_build_object('lat',-38.73,'lng',-72.60)),
    'updated_at','2026-08-01T00:01:00Z')));

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000003','aggregate_type','agriculturalSeason',
  'aggregate_id','34000000-0000-4000-8000-000000000001','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','season-create','payload',jsonb_build_object(
    'id','34000000-0000-4000-8000-000000000001','parcel_id','32000000-0000-4000-8000-000000000001',
    'name','2026-27','starts_on','2026-08-01','ends_on','2027-06-30','status','active',
    'updated_at','2026-08-01T00:02:00Z'))) ->> 'status','applied','season applies');
select is((select count(*)::integer from public.agricultural_seasons where id='34000000-0000-4000-8000-000000000001'),1,'season row exists before ACK');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000004','aggregate_type','customCrop',
  'aggregate_id','35000000-0000-4000-8000-000000000001','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','crop-create','payload',jsonb_build_object(
    'id','35000000-0000-4000-8000-000000000001','name','Ají local','normalized_name','aji local',
    'updated_at','2026-08-01T00:03:00Z'))) ->> 'status','applied','custom crop applies');
select is((select count(*)::integer from public.custom_crops where id='35000000-0000-4000-8000-000000000001'),1,'custom crop row exists');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000005','aggregate_type','sectorCropAssignment',
  'aggregate_id','36000000-0000-4000-8000-000000000001','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','assignment-create','payload',jsonb_build_object(
    'id','36000000-0000-4000-8000-000000000001','sector_id','33000000-0000-4000-8000-000000000001',
    'agricultural_season_id','34000000-0000-4000-8000-000000000001','crop_id','35000000-0000-4000-8000-000000000001',
    'is_custom_crop',true,'status','planned','starts_on','2026-09-01','updated_at','2026-08-01T00:04:00Z'))) ->> 'status','applied','assignment applies after parents');
select is((select crop_id from public.crop_seasons where id='36000000-0000-4000-8000-000000000001'),'35000000-0000-4000-8000-000000000001','assignment keeps custom crop reference');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000005','aggregate_type','sectorCropAssignment',
  'aggregate_id','36000000-0000-4000-8000-000000000001','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','assignment-create','payload','{}'::jsonb)) ->> 'status','duplicate','assignment retry is idempotent');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000006','aggregate_type','agriculturalSeason',
  'aggregate_id','34000000-0000-4000-8000-000000000001','mutation_kind','update','protocol_version',2,
  'payload_schema_version',1,'base_version',0,'request_hash','season-stale','payload',jsonb_build_object(
    'id','34000000-0000-4000-8000-000000000001','parcel_id','32000000-0000-4000-8000-000000000001',
    'name','Stale','starts_on','2026-08-01','status','active','updated_at','2026-08-02T00:00:00Z'))) ->> 'status','conflict','stale season conflicts');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000007','aggregate_type','sectorCropAssignment',
  'aggregate_id','36000000-0000-4000-8000-000000000099','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','missing-parent','payload',jsonb_build_object(
    'id','36000000-0000-4000-8000-000000000099','sector_id','33000000-0000-4000-8000-000000000099',
    'agricultural_season_id','34000000-0000-4000-8000-000000000001','crop_id','maiz',
    'is_custom_crop',false,'status','planned','starts_on','2026-10-01','updated_at','2026-08-02T00:00:00Z'))) ->> 'error_code','assignment_parent_missing','missing assignment parent rejects');
select is((select count(*)::integer from public.sync_operations where operation_id='22000000-0000-4000-8000-000000000007'),0,'rejected assignment has no receipt');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000008','aggregate_type','customCrop',
  'aggregate_id','35000000-0000-4000-8000-000000000001','mutation_kind','archive','protocol_version',2,
  'payload_schema_version',1,'base_version',1,'request_hash','crop-archive','payload',jsonb_build_object(
    'id','35000000-0000-4000-8000-000000000001','name','Ají local','normalized_name','aji local',
    'archived_at','2026-10-01T00:00:00Z','updated_at','2026-10-01T00:00:00Z'))) ->> 'status','applied','custom crop archive applies');
select ok((select archived_at is not null from public.custom_crops where id='35000000-0000-4000-8000-000000000001'),'archive retained without deleting referenced crop');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000009','aggregate_type','sectorCropAssignment',
  'aggregate_id','36000000-0000-4000-8000-000000000001','mutation_kind','update','protocol_version',2,
  'payload_schema_version',1,'base_version',1,'request_hash','assignment-ended','payload',jsonb_build_object(
    'id','36000000-0000-4000-8000-000000000001','sector_id','33000000-0000-4000-8000-000000000001',
    'agricultural_season_id','34000000-0000-4000-8000-000000000001','crop_id','35000000-0000-4000-8000-000000000001',
    'is_custom_crop',true,'status','ended','starts_on','2026-09-01','ends_on','2026-11-01','updated_at','2026-11-01T00:00:00Z'))) ->> 'status','applied','assignment can end without deletion');
select is((select status from public.crop_seasons where id='36000000-0000-4000-8000-000000000001'),'ended','historical assignment retained');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','22000000-0000-4000-8000-000000000010','aggregate_type','sectorCropAssignment',
  'aggregate_id','36000000-0000-4000-8000-000000000002','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','assignment-rotated','payload',jsonb_build_object(
    'id','36000000-0000-4000-8000-000000000002','sector_id','33000000-0000-4000-8000-000000000001',
    'agricultural_season_id','34000000-0000-4000-8000-000000000001','crop_id','maiz',
    'is_custom_crop',false,'status','active','starts_on','2026-11-01','updated_at','2026-11-01T00:01:00Z'))) ->> 'status','applied','rotated assignment applies');
select is((select count(*)::integer from public.crop_seasons where sector_id='33000000-0000-4000-8000-000000000001'),2,'rotation preserves both assignments');

select is((select count(*)::integer from public.sync_pull(0,200) where aggregate_type in ('agriculturalSeason','customCrop','sectorCropAssignment')),6,'pull exposes ordered season/crop/assignment changes');

set local role authenticated;
select set_config('request.jwt.claim.sub','12000000-0000-4000-8000-000000000002',true);
select is_empty($$select * from public.agricultural_seasons where id='34000000-0000-4000-8000-000000000001'$$,'RLS hides another owner season');
select is_empty($$select * from public.sync_pull(0,200)$$,'pull isolates another owner');

select * from finish();
rollback;
