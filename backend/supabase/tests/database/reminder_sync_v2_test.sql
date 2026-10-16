begin;
select plan(10);
insert into auth.users(id,aud,role,email,created_at,updated_at) values
('61000000-0000-4000-8000-000000000001','authenticated','authenticated','rem-a@test.local',now(),now()),
('61000000-0000-4000-8000-000000000002','authenticated','authenticated','rem-b@test.local',now(),now());
select set_config('request.jwt.claim.sub','61000000-0000-4000-8000-000000000001',true);
create function pg_temp.push(opid text, payload jsonb, mutation text default 'create', base bigint default null) returns jsonb language sql as
$$select public.sync_push(jsonb_build_array(jsonb_build_object(
'operation_id',opid,'aggregate_type','reminder','aggregate_id','62000000-0000-4000-8000-000000000001',
'mutation_kind',mutation,'protocol_version',2,'payload_schema_version',1,'base_version',base,
'request_hash',opid,'payload',payload)))->'results'->0$$;
create function pg_temp.payload(status text default 'scheduled') returns jsonb language sql as
$$select jsonb_build_object('id','62000000-0000-4000-8000-000000000001','title','Regar norte',
'description','Antes del amanecer','scheduled_at','2027-01-01T08:00:00Z','source_time_zone','America/Santiago',
'status',status,'completed_at',case when status='completed' then '2026-12-30T00:00:00Z' else null end,
'updated_at','2026-12-30T00:00:00Z')$$;
select is(pg_temp.push('63000000-0000-4000-8000-000000000001',pg_temp.payload())->>'status','applied','create applies');
select is((select count(*)::integer from public.reminders where id='62000000-0000-4000-8000-000000000001'),1,'row exists before ACK');
select is(pg_temp.push('63000000-0000-4000-8000-000000000001','{}')->>'status','duplicate','retry idempotent');
select is(pg_temp.push('63000000-0000-4000-8000-000000000002',pg_temp.payload(),'update',0)->>'status','conflict','stale version conflicts');
select is(pg_temp.push('63000000-0000-4000-8000-000000000003',pg_temp.payload('completed'),'update',1)->>'status','applied','complete applies');
select is((select status from public.reminders where id='62000000-0000-4000-8000-000000000001'),'completed','status persisted');
select ok((select completed_at is not null from public.reminders where id='62000000-0000-4000-8000-000000000001'),'completion timestamp persisted');
select is((select count(*)::integer from public.sync_pull(0,100) where aggregate_type='reminder'),2,'pull includes create and update');
select is(pg_temp.push('63000000-0000-4000-8000-000000000004',pg_temp.payload() || jsonb_build_object('title',''))->>'error_code','reminder_payload_invalid','invalid title rejects');
set local role authenticated;
select set_config('request.jwt.claim.sub','61000000-0000-4000-8000-000000000002',true);
select is_empty($$select * from public.reminders where owner_id='61000000-0000-4000-8000-000000000001'$$,'RLS isolates owner');
select * from finish();
rollback;
