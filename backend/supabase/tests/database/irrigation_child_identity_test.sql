-- F02 leaf estimates and duplicate irrigation handler: exact atomic effects.
begin;
select no_plan();
\ir persistence_helpers.inc
insert into crop_irrigation_rules(id,crop_id,soil_type_code,version,soil_multiplier_permille,efficiency_permille,minimum_duration_minutes,maximum_duration_minutes,source_title,source_reference)
values(pg_temp.fid(951),'maiz','loamy',1,1000,900,1,100,'FICTICIO','fixture');
create function pg_temp.config(n integer,s integer) returns jsonb language sql as $$
select jsonb_build_object('id',pg_temp.fid(n),'sector_id',pg_temp.fid(s),'method','drip','plant_count',10,'emitter_count',10,'flow_ml_min',1000,'effective_from','2026-10-10T12:00:00Z','config_version',1,'updated_at','2026-10-10T12:00:00Z') $$;
create function pg_temp.water(l integer,c integer,e integer,s integer,season integer,a integer,config integer) returns jsonb language sql as $$
select pg_temp.labor(l,'irrigation',s,season,a)||jsonb_build_object('irrigation',jsonb_build_object(
'id',pg_temp.fid(c),'labor_id',pg_temp.fid(l),'sector_id',pg_temp.fid(s),'irrigation_type','drip','soil_type_code','loamy','config_id',pg_temp.fid(config),'config_version',1,'duration_seconds',60,'applied_volume_ml',1000,'irrigated_at','2026-10-10T12:00:00Z',
'estimate',jsonb_build_object('id',pg_temp.fid(e),'config_id',pg_temp.fid(config),'config_version',1,'algorithm_version',1,'rule_id',pg_temp.fid(951),'rule_version',1,'soil_type_code','loamy','inputs','{}'::jsonb,'recommended_volume_ml',1000,'recommended_duration_seconds',60))) $$;
set local role authenticated;
select set_config('request.jwt.claim.sub',pg_temp.fid(1)::text,true);
select is(pg_temp.push(61001,'sector',pg_temp.sector(101,1))->>'status','applied','A sector');
select is(pg_temp.push(61002,'agriculturalSeason',pg_temp.season(301,101))->>'status','applied','A season');
select is(pg_temp.push(61003,'sectorCropAssignment',pg_temp.assignment(401,101,301))->>'status','applied','A assignment');
select is(pg_temp.push(61004,'irrigationConfig',pg_temp.config(801,101))->>'status','applied','A config');
select is(pg_temp.push(61005,'labor',pg_temp.water(501,601,701,101,301,401,801))->>'status','applied','A irrigation and estimate apply atomically');
create temp table original_estimate as select to_jsonb(e) value from irrigation_estimates e where id=pg_temp.fid(701);
select is((sync_push(jsonb_build_array(pg_temp.op(61005,'labor',pg_temp.water(501,601,701,101,301,401,801)||jsonb_build_object('irrigation',(pg_temp.water(501,601,701,101,301,401,801)->'irrigation')||'{"duration_seconds":999}'::jsonb))||jsonb_build_object('request_hash',pg_temp.op(61005,'labor',pg_temp.water(501,601,701,101,301,401,801))->>'request_hash')))->'results'->0)->>'status','duplicate','duplicate does not reopen irrigation persistence');
select is((select duration_seconds from irrigation_records where id=pg_temp.fid(601)),60,'duplicate keeps original child duration');
select is(pg_temp.push(61006,'labor',pg_temp.water(503,603,701,101,301,401,801))->>'status','rejected','same owner cannot move an estimate to another labor');
select is((select count(*)::integer from labors where id=pg_temp.fid(503)),0,'estimate identity mismatch rolls back own labor');
select set_config('request.jwt.claim.sub',pg_temp.fid(2)::text,true);
select is(pg_temp.push(62001,'sector',pg_temp.sector(201,1))->>'status','applied','B sector');
select is(pg_temp.push(62002,'agriculturalSeason',pg_temp.season(302,201))->>'status','applied','B season');
select is(pg_temp.push(62003,'sectorCropAssignment',pg_temp.assignment(402,201,302))->>'status','applied','B assignment');
select is(pg_temp.push(62004,'irrigationConfig',pg_temp.config(802,201))->>'status','applied','B config');
select is(pg_temp.push(62005,'labor',pg_temp.water(502,602,701,201,302,402,802))->>'status','rejected','foreign estimate UUID rejects instead of DO NOTHING ACK');
select is((select count(*)::integer from labors where id=pg_temp.fid(502)),0,'foreign estimate rolls back labor');
select is((select count(*)::integer from irrigation_records where id=pg_temp.fid(602)),0,'foreign estimate rolls back irrigation');
select is((select count(*)::integer from sync_operations where operation_id=pg_temp.fid(62005)),0,'foreign estimate leaves no receipt');
select is((select count(*)::integer from sync_changes where aggregate_id=pg_temp.fid(502)),0,'foreign estimate leaves no change');
reset role;
select results_eq($$select to_jsonb(e) from irrigation_estimates e where id=pg_temp.fid(701)$$,$$select value from original_estimate$$,'A estimate unchanged in full');
select * from finish();
rollback;
