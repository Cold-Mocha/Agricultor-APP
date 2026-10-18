-- Reconstructed regression for PLAN-ACCION-CI-SUPABASE-2026-10-10; fictitious rollback fixtures.
begin;
select no_plan();
\ir persistence_helpers.inc
set local role authenticated;
select set_config('request.jwt.claim.sub',pg_temp.fid(1)::text,true);
select is(pg_temp.push(50001,'sector',pg_temp.sector(101,1))->>'status','applied','crop sector');
select is(pg_temp.push(50002,'sector',pg_temp.sector(102,2,'apiary'))->>'status','applied','apiary sector');
create function pg_temp.soil(n integer, child_n integer, sec_n integer default 101) returns jsonb language sql as $$
  select (pg_temp.labor(n,'soil',sec_n)-'agricultural_season_id'-'crop_assignment_id') || jsonb_build_object(
    'soil',jsonb_build_object('id',pg_temp.fid(child_n),'labor_id',pg_temp.fid(n),'moisturePercent',0,'ph',6.5,
      'temperatureCelsius',null,'conductivity',0,'nitrogen',0,'phosphorus',1.25,'potassium',2.5,'units',jsonb_build_object('conductivity','mS/cm')))
$$;
create function pg_temp.apiary(n integer, child_n integer, sec_n integer default 102) returns jsonb language sql as $$
  select (pg_temp.labor(n,'apiary',sec_n)-'agricultural_season_id'-'crop_assignment_id') || jsonb_build_object(
    'domain_category','apiary','apiary',jsonb_build_object('id',pg_temp.fid(child_n),'task_type','inspection',
      'beekeeper_name','FICTICIO','hive_count',3,'queen_status','ok','brood_status','ok','feeding_status','',
      'health_notes','','pest_notes','','super_installed',true,'observations',null,'inspected_at','2026-10-10T12:00:00Z'))
$$;
select is(pg_temp.push(51001,'labor',pg_temp.soil(501,601))->>'status','applied','real soil without agricultural context applies');
select results_eq($$select moisture_percent,ph,temperature_celsius,conductivity,nitrogen,phosphorus,potassium from soil_measurements where id=pg_temp.fid(601)$$,
  $$select 0::double precision,6.5::double precision,null::double precision,0::double precision,0::double precision,1.25::double precision,2.5::double precision$$,'all soil values and NULL/zero preserved');
select is((select measured_at from soil_measurements where id=pg_temp.fid(601)), '2026-10-10T12:00:00Z'::timestamptz,'measured_at derived from occurred_at');
select is((select labor_id from soil_measurements where id=pg_temp.fid(601)),pg_temp.fid(501),'soil grouping link retained');
select is(pg_temp.push(51001,'labor',pg_temp.soil(501,601))->>'status','duplicate','soil retry is duplicate');
select is((select count(*)::integer from soil_measurements where labor_id=pg_temp.fid(501)),1,'one soil child');
select is((select payload#>>'{soil,units,conductivity}' from sync_pull(0,200) where aggregate_id=pg_temp.fid(501)),'mS/cm','units retained in compound JSON');
select is((select domain_category from labors where id=pg_temp.fid(501)),'crop','row category crop');
select is((select payload->>'domain_category' from sync_pull(0,200) where aggregate_id=pg_temp.fid(501)),'crop','pull category crop');
select is(pg_temp.push(51002,'labor',pg_temp.apiary(502,602))->>'status','applied','real apiary without agricultural context applies');
select ok((select super_installed and hive_count=3 and observations is null and labor_id=pg_temp.fid(502) from apiary_inspections where id=pg_temp.fid(602)),'apiary bool NULL count and labor link preserved');
select is((select domain_category from labors where id=pg_temp.fid(502)),'apiary','row category apiary');
select is(pg_temp.push(51002,'labor',pg_temp.apiary(502,602))->>'status','duplicate','apiary retry duplicate');
select is(pg_temp.push(52001,'labor',pg_temp.soil(511,611)||jsonb_build_object('soil',(pg_temp.soil(511,611)->'soil')||'{"ph":15}'::jsonb))->>'status','rejected','invalid soil child rejects');
select is(pg_temp.push(52002,'labor',pg_temp.apiary(512,612)||jsonb_build_object('apiary',(pg_temp.apiary(512,612)->'apiary')||'{"hive_count":0}'::jsonb))->>'status','rejected','invalid apiary child rejects');
select is(pg_temp.push(52003,'labor',pg_temp.soil(513,613)||jsonb_build_object('soil',(pg_temp.soil(513,613)->'soil')||jsonb_build_object('labor_id',pg_temp.fid(501))))->>'status','rejected','foreign child labor id rejects');
select is(pg_temp.push(52004,'labor',pg_temp.soil(514,614)||jsonb_build_object('agricultural_season_id',pg_temp.fid(999)))->>'status','rejected','optional season validated');
select is(pg_temp.push(52005,'labor',pg_temp.soil(515,615)||'{"domain_category":"apiary"}'::jsonb)->>'status','rejected','incompatible category rejects');
select is(pg_temp.push(52006,'labor',pg_temp.soil(516,601))->>'status','rejected','same-owner child UUID cannot be reassigned to a new labor');
select is(pg_temp.push(52007,'labor',pg_temp.soil(517,617)-'domain_category')->>'status','applied','legacy category derives from sector');
select is((select domain_category from labors where id=pg_temp.fid(517)),'crop','derived category stored');
select is(pg_temp.push(52008,'labor',pg_temp.soil(518,618)||jsonb_build_object('soil',(pg_temp.soil(518,618)->'soil')||'{"moisture_percent":1}'::jsonb))->>'status','rejected','ambiguous camel/snake aliases reject');
select is((select count(*)::integer from labors where id between pg_temp.fid(511) and pg_temp.fid(516)),0,'invalid children leave no labor roots');
select is((select count(*)::integer from sync_operations where operation_id between pg_temp.fid(52001) and pg_temp.fid(52006)),0,'invalid children leave no receipts');
select is((select count(*)::integer from sync_changes where aggregate_id between pg_temp.fid(511) and pg_temp.fid(516)),0,'invalid children leave no changes');
select throws_ok($$update labors set domain_category='apiary' where id=pg_temp.fid(501)$$,'23514','labor_category_mismatch','direct category mismatch rejected');
select set_config('request.jwt.claim.sub',pg_temp.fid(2)::text,true);
select is(pg_temp.push(53001,'sector',pg_temp.sector(201,1))->>'status','applied','B crop fixture');
select is(pg_temp.push(53002,'sector',pg_temp.sector(202,2,'apiary'))->>'status','applied','B apiary fixture');
select is(pg_temp.push(53003,'labor',pg_temp.soil(521,601,201))->>'status','rejected','B cannot overwrite A soil child UUID');
select is(pg_temp.push(53004,'labor',pg_temp.apiary(522,602,202))->>'status','rejected','B cannot overwrite A apiary child UUID');
select is((select count(*)::integer from labors where id in (pg_temp.fid(521),pg_temp.fid(522))),0,'foreign children rollback B roots');
select is((select count(*)::integer from sync_operations where operation_id in (pg_temp.fid(53003),pg_temp.fid(53004))),0,'foreign children have no successful receipt');

select set_config('request.jwt.claim.sub',pg_temp.fid(1)::text,true);
select is(pg_temp.push(54001,'labor',pg_temp.soil(541,641)||jsonb_build_object('soil',(pg_temp.soil(541,641)->'soil')||'{"ph":"6"}'::jsonb))->>'status','rejected','numeric JSON strings cannot block the Dart pull codec');
select is(pg_temp.push(54002,'labor',pg_temp.soil(542,642)||jsonb_build_object('soil',(pg_temp.soil(542,642)->'soil')||'{"temperatureCelsius":"NaN"}'::jsonb))->>'status','rejected','nonfinite strings reject before ACK');
select is((select count(*)::integer from labors where id in (pg_temp.fid(541),pg_temp.fid(542))),0,'malformed numeric children roll back their roots');
select is((select count(*)::integer from sync_operations where operation_id in (pg_temp.fid(54001),pg_temp.fid(54002))),0,'malformed numeric children leave no receipts');
select * from finish();
rollback;
