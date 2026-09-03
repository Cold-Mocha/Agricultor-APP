begin;
select plan(22);

select has_column('public', 'sync_operations', 'request_hash', 'receipt stores request hash');
select has_column('public', 'sync_operations', 'protocol_version', 'receipt stores protocol version');
select has_column('public', 'sync_changes', 'remote_version', 'pull stores remote version');
select has_function('public', 'sync_push', array['jsonb']);
select has_function('public', 'sync_pull', array['bigint', 'integer']);
select throws_ok(
  $$select public.sync_push('[{}]'::jsonb)$$,
  'authentication_required',
  'anonymous push is rejected'
);
select ok((select relrowsecurity from pg_class where oid = 'public.sync_operations'::regclass), 'receipt RLS active');
select ok((select relrowsecurity from pg_class where oid = 'public.sync_changes'::regclass), 'change RLS active');
select col_is_pk('public', 'sync_operations', array['owner_id','operation_id'], 'receipt key is owner plus operation');
select results_eq(
  $$select count(*)::bigint from public.sync_operations where status = 'applied' and request_hash is null$$,
  array[0::bigint],
  'successful v2 receipts always retain request hash'
);

insert into auth.users(id, aud, role, email, created_at, updated_at)
values
  ('10000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'sync-a@test.local', now(), now()),
  ('10000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'sync-b@test.local', now(), now());
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);

create temporary table sync_v2_results(value jsonb);
create function pg_temp.push_result(operation jsonb) returns jsonb
language sql as $$ select public.sync_push(jsonb_build_array(operation))->'results'->0 $$;
insert into sync_v2_results values (public.sync_push(jsonb_build_array(jsonb_build_object(
  'operation_id','20000000-0000-4000-8000-000000000001',
  'aggregate_type','parcel','aggregate_id','30000000-0000-4000-8000-000000000001',
  'mutation_kind','create','protocol_version',2,'payload_schema_version',1,
  'request_hash','hash-create','payload',jsonb_build_object(
    'id','30000000-0000-4000-8000-000000000001','name','Parcela pgTAP',
    'is_active',true,'updated_at','2026-01-01T00:00:00Z'
  )
))));
select is((select value#>>'{results,0,status}' from sync_v2_results), 'applied', 'parcel applies before ACK');
select is((select count(*)::integer from public.parcels where id='30000000-0000-4000-8000-000000000001'), 1, 'business row exists after applied');
select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','20000000-0000-4000-8000-000000000001','aggregate_type','parcel',
  'aggregate_id','30000000-0000-4000-8000-000000000001','mutation_kind','create',
  'protocol_version',2,'payload_schema_version',1,'request_hash','hash-create','payload',jsonb_build_object(
    'id','30000000-0000-4000-8000-000000000001','name','Parcela pgTAP','is_active',true,'updated_at','2026-01-01T00:00:00Z'
  ))) ->> 'status', 'duplicate', 'lost ACK retry is duplicate');
select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','20000000-0000-4000-8000-000000000001','aggregate_type','parcel',
  'aggregate_id','30000000-0000-4000-8000-000000000001','mutation_kind','update',
  'protocol_version',2,'payload_schema_version',1,'request_hash','different','payload','{}'::jsonb
  )) ->> 'error_code', 'idempotency_mismatch', 'same id with different hash rejects');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','20000000-0000-4000-8000-000000000002','aggregate_type','sector',
  'aggregate_id','30000000-0000-4000-8000-000000000002','mutation_kind','create',
  'protocol_version',2,'payload_schema_version',1,'request_hash','unsupported','payload','{}'::jsonb
  )) ->> 'status', 'rejected', 'unsupported aggregate rejects');
select is((select count(*)::integer from public.sync_operations where operation_id='20000000-0000-4000-8000-000000000002'), 0, 'unsupported aggregate gets no success receipt');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','20000000-0000-4000-8000-000000000003','aggregate_type','parcel',
  'aggregate_id','30000000-0000-4000-8000-000000000001','mutation_kind','update',
  'protocol_version',2,'payload_schema_version',1,'base_version',0,'request_hash','conflict','payload',jsonb_build_object(
    'id','30000000-0000-4000-8000-000000000001','name','Conflicto','updated_at','2026-01-02T00:00:00Z'
  ))) ->> 'status', 'conflict', 'stale base returns conflict');
select is((select count(*)::integer from public.sync_operations where operation_id='20000000-0000-4000-8000-000000000003'), 0, 'conflict gets no success receipt');

select is(pg_temp.push_result(jsonb_build_object(
  'operation_id','20000000-0000-4000-8000-000000000004','aggregate_type','parcel',
  'aggregate_id','30000000-0000-4000-8000-000000000001','mutation_kind','delete',
  'protocol_version',2,'payload_schema_version',1,'base_version',1,'request_hash','delete','payload',jsonb_build_object(
    'id','30000000-0000-4000-8000-000000000001','name','Parcela pgTAP','is_archived',true,
    'deleted_at','2026-01-03T00:00:00Z','updated_at','2026-01-03T00:00:00Z'
  ))) ->> 'status', 'applied', 'delete applies as tombstone');
select ok((select deleted_at is not null from public.parcels where id='30000000-0000-4000-8000-000000000001'), 'tombstone remains remotely');
select ok((select bool_and(change_seq > 0) from public.sync_pull(0, 200)), 'pull returns ordered positive sequence');

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000002', true);
select is_empty($$select * from public.sync_pull(0, 200)$$, 'second owner cannot pull first owner changes');

select * from finish();
rollback;
