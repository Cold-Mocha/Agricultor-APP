begin;
select plan(14);

insert into auth.users(id, aud, role, email, created_at, updated_at)
values
  ('11000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'territory-a@test.local', now(), now()),
  ('11000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'territory-b@test.local', now(), now());
select set_config('request.jwt.claim.sub', '11000000-0000-4000-8000-000000000001', true);

create function pg_temp.push_result(operation jsonb) returns jsonb
language sql as $$ select public.sync_push(jsonb_build_array(operation))->'results'->0 $$;

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','21000000-0000-4000-8000-000000000001','aggregate_type','parcel',
  'aggregate_id','31000000-0000-4000-8000-000000000001','mutation_kind','create',
  'protocol_version',2,'payload_schema_version',1,'request_hash','parcel-with-boundary',
  'payload',jsonb_build_object(
    'id','31000000-0000-4000-8000-000000000001','name','Campo territorio','is_active',true,
    'polygon',jsonb_build_array(
      jsonb_build_object('lat',-38.75,'lng',-72.61), jsonb_build_object('lat',-38.75,'lng',-72.57),
      jsonb_build_object('lat',-38.71,'lng',-72.57), jsonb_build_object('lat',-38.71,'lng',-72.61)
    ), 'updated_at','2026-08-29T00:00:00Z'
  ))) ->> 'status', 'applied', 'parcel geometry applies');
select ok((select boundary is not null from public.parcels where id='31000000-0000-4000-8000-000000000001'), 'parcel boundary persisted');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','21000000-0000-4000-8000-000000000002','aggregate_type','sector',
  'aggregate_id','32000000-0000-4000-8000-000000000001','mutation_kind','create',
  'protocol_version',2,'payload_schema_version',1,'request_hash','sector-create',
  'depends_on_operation_id','21000000-0000-4000-8000-000000000001',
  'payload',jsonb_build_object(
    'id','32000000-0000-4000-8000-000000000001','parcel_id','31000000-0000-4000-8000-000000000001',
    'number',1,'name','Norte','kind','crop','polygon',jsonb_build_array(
      jsonb_build_object('lat',-38.74,'lng',-72.60), jsonb_build_object('lat',-38.74,'lng',-72.59),
      jsonb_build_object('lat',-38.73,'lng',-72.59), jsonb_build_object('lat',-38.73,'lng',-72.60)
    ), 'updated_at','2026-08-29T00:01:00Z'
  ))) ->> 'status', 'applied', 'sector applies after parent');
select is((select count(*)::integer from public.sectors where id='32000000-0000-4000-8000-000000000001'), 1, 'sector business row exists before ACK');
select ok((select area_square_meters > 0 from public.sectors where id='32000000-0000-4000-8000-000000000001'), 'PostGIS computes positive sector area');
select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','21000000-0000-4000-8000-000000000002','aggregate_type','sector',
  'aggregate_id','32000000-0000-4000-8000-000000000001','mutation_kind','create',
  'protocol_version',2,'payload_schema_version',1,'request_hash','sector-create','payload','{}'::jsonb
  )) ->> 'status', 'duplicate', 'sector retry after lost ACK is idempotent');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','21000000-0000-4000-8000-000000000003','aggregate_type','sector',
  'aggregate_id','32000000-0000-4000-8000-000000000002','mutation_kind','create',
  'protocol_version',2,'payload_schema_version',1,'request_hash','missing-parent','payload',jsonb_build_object(
    'id','32000000-0000-4000-8000-000000000002','parcel_id','31000000-0000-4000-8000-000000000099',
    'number',2,'name','Huérfano','polygon',jsonb_build_array(1,2,3)
  ))) ->> 'error_code', 'parent_missing', 'missing parent rejects without ACK');
select is((select count(*)::integer from public.sync_operations where operation_id='21000000-0000-4000-8000-000000000003'), 0, 'rejected child has no success receipt');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','21000000-0000-4000-8000-000000000004','aggregate_type','sector',
  'aggregate_id','32000000-0000-4000-8000-000000000001','mutation_kind','update',
  'protocol_version',2,'payload_schema_version',1,'base_version',0,'request_hash','stale-sector','payload',jsonb_build_object(
    'id','32000000-0000-4000-8000-000000000001','parcel_id','31000000-0000-4000-8000-000000000001',
    'number',1,'name','Stale','polygon',jsonb_build_array(1,2,3)
  ))) ->> 'status', 'conflict', 'stale sector update conflicts');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','21000000-0000-4000-8000-000000000005','aggregate_type','sector',
  'aggregate_id','32000000-0000-4000-8000-000000000001','mutation_kind','delete',
  'protocol_version',2,'payload_schema_version',1,'base_version',1,'request_hash','delete-sector','payload',jsonb_build_object(
    'id','32000000-0000-4000-8000-000000000001','parcel_id','31000000-0000-4000-8000-000000000001',
    'number',1,'name','Norte','kind','crop','polygon',jsonb_build_array(
      jsonb_build_object('lat',-38.74,'lng',-72.60), jsonb_build_object('lat',-38.74,'lng',-72.59),
      jsonb_build_object('lat',-38.73,'lng',-72.59), jsonb_build_object('lat',-38.73,'lng',-72.60)
    ), 'deleted_at','2026-08-30T00:00:00Z','updated_at','2026-08-30T00:00:00Z'
  ))) ->> 'status', 'applied', 'sector tombstone applies');
select ok((select deleted_at is not null from public.sectors where id='32000000-0000-4000-8000-000000000001'), 'sector tombstone retained');
select is((select count(*)::integer from public.sync_pull(0, 200) where aggregate_type='sector'), 2, 'sector create and tombstone both pull in order');

set local role authenticated;
select set_config('request.jwt.claim.sub', '11000000-0000-4000-8000-000000000002', true);
select is_empty($$select * from public.sectors where id='32000000-0000-4000-8000-000000000001'$$, 'RLS hides other owner sector');
select is_empty($$select * from public.sync_pull(0, 200)$$, 'RLS pull isolates other owner');

select * from finish();
rollback;
