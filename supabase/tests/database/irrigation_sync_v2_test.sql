begin;
select plan(13);
insert into auth.users(id,aud,role,email,created_at,updated_at) values
('51000000-0000-4000-8000-000000000001','authenticated','authenticated','water-a@test.local',now(),now()),
('51000000-0000-4000-8000-000000000002','authenticated','authenticated','water-b@test.local',now(),now());
select set_config('request.jwt.claim.sub','51000000-0000-4000-8000-000000000001',true);
insert into public.parcels(id,owner_id,name,is_active,boundary,updated_at) values
('52000000-0000-4000-8000-000000000001','51000000-0000-4000-8000-000000000001','Campo',true,
extensions.st_geomfromtext('POLYGON((-72.7 -38.8,-72.5 -38.8,-72.5 -38.6,-72.7 -38.6,-72.7 -38.8))',4326),now());
insert into public.sectors(id,owner_id,parcel_id,number,name,boundary,updated_at) values
('53000000-0000-4000-8000-000000000001','51000000-0000-4000-8000-000000000001','52000000-0000-4000-8000-000000000001',1,'Norte',
extensions.st_geomfromtext('POLYGON((-72.65 -38.75,-72.55 -38.75,-72.55 -38.65,-72.65 -38.65,-72.65 -38.75))',4326),now());
insert into public.agricultural_seasons(id,owner_id,parcel_id,name,starts_on,status,updated_at) values
('54000000-0000-4000-8000-000000000001','51000000-0000-4000-8000-000000000001','52000000-0000-4000-8000-000000000001','2026','2026-01-01','active',now());
insert into public.custom_crops(id,owner_id,name,normalized_name,updated_at) values
('55000000-0000-4000-8000-000000000001','51000000-0000-4000-8000-000000000001','Ají','aji',now());
insert into public.crop_seasons(id,owner_id,sector_id,agricultural_season_id,crop_id,is_custom_crop,status,starts_on,updated_at) values
('56000000-0000-4000-8000-000000000001','51000000-0000-4000-8000-000000000001','53000000-0000-4000-8000-000000000001','54000000-0000-4000-8000-000000000001','55000000-0000-4000-8000-000000000001',true,'active','2026-01-01',now());

create function pg_temp.push(op jsonb) returns jsonb language sql as
$$select public.sync_push(jsonb_build_array(op))->'results'->0$$;
select is(pg_temp.push(jsonb_build_object(
  'operation_id','57000000-0000-4000-8000-000000000001','aggregate_type','irrigationConfig',
  'aggregate_id','58000000-0000-4000-8000-000000000001','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','config-1','payload',jsonb_build_object(
    'id','58000000-0000-4000-8000-000000000001','sector_id','53000000-0000-4000-8000-000000000001',
    'method','drip','plant_count',100,'emitter_count',200,'flow_ml_min',4000,
    'effective_from','2026-01-01T00:00:00Z','config_version',1,'updated_at','2026-01-01T00:00:00Z')))->>'status','applied','config applies');
select is((select config_version from public.sector_irrigation_configs where id='58000000-0000-4000-8000-000000000001'),1,'config persisted before ACK');
select is(pg_temp.push(jsonb_build_object(
  'operation_id','57000000-0000-4000-8000-000000000001','aggregate_type','irrigationConfig',
  'aggregate_id','58000000-0000-4000-8000-000000000001','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','config-1','payload','{}')) ->> 'status','duplicate','config retry idempotent');
select is(pg_temp.push(jsonb_build_object(
  'operation_id','57000000-0000-4000-8000-000000000002','aggregate_type','irrigationConfig',
  'aggregate_id','58000000-0000-4000-8000-000000000002','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','bad-parent','payload',jsonb_build_object(
    'id','58000000-0000-4000-8000-000000000002','sector_id','53000000-0000-4000-8000-000000000099',
    'method','drip','plant_count',1,'emitter_count',1,'flow_ml_min',1,
    'effective_from','2026-01-01T00:00:00Z','config_version',1)))->>'error_code',
  'irrigation_config_parent_missing','missing sector rejects');
select is((select count(*)::integer from public.sync_operations where operation_id='57000000-0000-4000-8000-000000000002'),0,'rejected config has no receipt');

select is(pg_temp.push(jsonb_build_object(
  'operation_id','57000000-0000-4000-8000-000000000003','aggregate_type','labor',
  'aggregate_id','59000000-0000-4000-8000-000000000001','mutation_kind','create','protocol_version',2,
  'payload_schema_version',1,'request_hash','irrigation-labor','payload',jsonb_build_object(
    'id','59000000-0000-4000-8000-000000000001','parcel_id','52000000-0000-4000-8000-000000000001',
    'sector_id','53000000-0000-4000-8000-000000000001','agricultural_season_id','54000000-0000-4000-8000-000000000001',
    'crop_assignment_id','56000000-0000-4000-8000-000000000001','type','irrigation',
    'details',jsonb_build_object('schemaVersion',1,'type','irrigation','data',jsonb_build_object('method','drip','durationMinutes',30)),
    'details_schema_version',1,'status','recorded','occurred_at','2026-03-01T00:00:00Z','updated_at','2026-03-01T00:00:00Z',
    'irrigation',jsonb_build_object('id','5a000000-0000-4000-8000-000000000001','labor_id','59000000-0000-4000-8000-000000000001',
      'sector_id','53000000-0000-4000-8000-000000000001','irrigation_type','drip','soil_type_code','loamy',
      'config_id','58000000-0000-4000-8000-000000000001','config_version',1,'duration_seconds',1800,
      'applied_volume_ml',120000,'performed_details',jsonb_build_object('config_snapshot',jsonb_build_object('version',1)),
      'irrigated_at','2026-03-01T00:00:00Z','updated_at','2026-03-01T00:00:00Z')))) ->> 'status','applied','irrigation aggregate applies');
select is((select count(*)::integer from public.labors where id='59000000-0000-4000-8000-000000000001'),1,'irrigation labor exists');
select is((select count(*)::integer from public.irrigation_records where labor_id='59000000-0000-4000-8000-000000000001'),1,'irrigation child exists');
select is((select config_version from public.irrigation_records where labor_id='59000000-0000-4000-8000-000000000001'),1,'record retains config snapshot version');
select is((select count(*)::integer from public.sync_changes where aggregate_id='59000000-0000-4000-8000-000000000001'),1,'irrigation emits one history change');
select is((select count(*)::integer from public.sync_pull(0,200) where aggregate_type in ('irrigationConfig','labor')),2,'pull exposes config and labor');

set local role authenticated;
select set_config('request.jwt.claim.sub','51000000-0000-4000-8000-000000000002',true);
select is_empty($$select * from public.sector_irrigation_configs where owner_id='51000000-0000-4000-8000-000000000001'$$,'RLS hides configs');
select is_empty($$select * from public.irrigation_records where owner_id='51000000-0000-4000-8000-000000000001'$$,'RLS hides irrigation records');
select * from finish();
rollback;
