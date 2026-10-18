-- Recovered original 64 assertions. Two inherited contradictions corrected without weakening rejection/data assertions; see EVIDENCIA.
-- Expectativas de producto. Los fallos se conservan; no son TODO ni SKIP.
begin;
set local search_path = public, extensions;
select no_plan();
\ir persistence_helpers.inc
set local role authenticated;
select set_config('request.jwt.claim.sub',pg_temp.fid(1)::text,true);
select is(current_user::text,'authenticated','ENV: rol real authenticated');
select is(auth.uid(),pg_temp.fid(1),'ENV: UID ficticio A');
select hasnt_table('public','parcels','MODEL: sin tabla parcels');
select is((select count(*)::integer from information_schema.columns
  where table_schema='public' and column_name ilike '%parcel%'),0,'MODEL: sin columnas parcel');
select is(pg_temp.push(10001,'parcel',jsonb_build_object('id',pg_temp.fid(901),'name','FICTICIO QA')) ->> 'error_code',
  'aggregate_unsupported','MODEL: rechaza agregado parcel');
select is(pg_temp.push(10002,'sector',pg_temp.sector(101,1))->>'status','applied','NUM: crea A sector 1');
select is(pg_temp.push(10003,'sector',pg_temp.sector(102,2,'apiary'))->>'status','applied','NUM: crea A sector 2 apícola');
select is(pg_temp.push(10004,'sector',pg_temp.sector(103,10))->>'status','applied','NUM: fixture histórico A sector 10');
select is(pg_temp.push(10005,'sector',pg_temp.sector(104,1))->>'error_code','uniqueness_conflict','NUM: mismo propietario no duplica 1');
select set_config('request.jwt.claim.sub',pg_temp.fid(2)::text,true);
select is(pg_temp.push(10006,'sector',pg_temp.sector(201,1))->>'status','applied','NUM: B puede usar su número 1');
select is_empty($$select * from sectors where owner_id=pg_temp.fid(1)$$,'RLS: B no lee sectores A');
select is_empty($$select * from sync_pull(0,200) where aggregate_id=pg_temp.fid(101)$$,'RLS: pull B no expone A');
select throws_ok($$insert into sectors(id,owner_id,number,name,boundary)
  values(pg_temp.fid(999),pg_temp.fid(1),99,'FICTICIO QA',
  extensions.st_geomfromtext('POLYGON((-72.6 -38.74,-72.59 -38.74,-72.59 -38.73,-72.6 -38.74))',4326))$$,
  '42501',null,'RLS: B no inserta con owner A');
with affected as (update sectors set name='FICTICIO QA Intruso' where id=pg_temp.fid(101) returning id)
  select is(count(*)::integer,0,'RLS: UPDATE directo B no modifica A') from affected;
with affected as (delete from sectors where id=pg_temp.fid(101) returning id)
  select is(count(*)::integer,0,'RLS: DELETE directo B no elimina A') from affected;
select set_config('request.jwt.claim.sub',pg_temp.fid(1)::text,true);
select is(pg_temp.push(10007,'agriculturalSeason',pg_temp.season(301,101))->>'status','applied','SRC: temporada A sincronizada');
select is(pg_temp.push(10008,'sectorCropAssignment',pg_temp.assignment(401,101,301))->>'status','applied','SRC: asignación A sincronizada');
select is(pg_temp.push(10009,'labor',pg_temp.labor(501))->>'status','applied','SRC: labor y JSON aplicados');
select is((select details#>>'{data,amount}' from labors where id=pg_temp.fid(501)),'10.5','SRC: valor numérico en JSON');
select is((select jsonb_typeof(details#>'{data,measured}') from labors where id=pg_temp.fid(501)),'boolean','SRC: booleano en JSON');
select is((select domain_category from labors where id=pg_temp.fid(501)),'crop','SRC: categoría de labor persistida');
select is(pg_temp.push(10009,'labor',pg_temp.labor(501))->>'status','duplicate','SYNC: reintento idéntico no duplica');
select is((select count(*)::integer from labors where id=pg_temp.fid(501)),1,'SYNC: una fila de negocio');
select is((select count(*)::integer from sync_changes where aggregate_id=pg_temp.fid(501)),1,'SYNC: un cambio para reintento');
select is(pg_temp.push(10009,'labor',pg_temp.labor(501)||'{"notes":"FICTICIO cambio"}'::jsonb)->>'error_code',
  'idempotency_mismatch','SYNC: mismo operation_id con hash distinto rechaza');
select is(pg_temp.push(10010,'labor',pg_temp.labor(501),'update',0)->>'status','conflict','SYNC: base obsoleta conflict');
select is((select count(*)::integer from sync_operations where operation_id=pg_temp.fid(10010)),0,'SYNC: conflicto sin recibo exitoso');
select is(pg_temp.push(10011,'labor',pg_temp.labor(502)||jsonb_build_object('supersedes_labor_id',pg_temp.fid(501)))->>'status',
  'applied','CORR: nueva labor enlaza original');
select is((select supersedes_labor_id from labors where id=pg_temp.fid(502)),pg_temp.fid(501),'CORR: conserva enlace original');
select is(pg_temp.push(10012,'labor',pg_temp.labor(501)||'{"status":"corrected"}'::jsonb,'update',1)->>'status',
  'applied','CORR: original se marca corrected');
select is((select version from labors where id=pg_temp.fid(501)),2::bigint,'SYNC: versión incrementada');
-- Reserva histórica y discrepancias entre app y RPC.
select is(pg_temp.push(10013,'sector',pg_temp.sector(103,10)||'{"deleted_at":"2026-10-10T13:00:00Z"}'::jsonb,'delete',1)->>'status',
  'applied','NUM: retira número 10');
select is(pg_temp.push(10014,'sector',pg_temp.sector(105,10))->>'error_code','uniqueness_conflict','NUM: 10 retirado sigue reservado');
select is((select max(number)+1 from sectors),11,'NUM: máximo histórico más uno = 11');
select is(pg_temp.push(10015,'sector',pg_temp.sector(106,11))->>'status','applied','NUM: siguiente 11 persiste');
select isnt(pg_temp.push(10016,'sector',pg_temp.sector(106,12),'update',1)->>'status','applied','NUM: debe impedir renumerar identidad 11 a 12');
select is((select number from sectors where id=pg_temp.fid(106)),11,'NUM: identidad conserva número original');
select isnt(pg_temp.push(10017,'sector',pg_temp.sector(103,10),'update',2)->>'status','applied','NUM: debe impedir reactivar retirado');
select ok((select deleted_at is not null from sectors where id=pg_temp.fid(103)),'NUM: tombstone debe conservarse');
select is(pg_temp.push(100180,'sector',pg_temp.sector(108,14))->>'status','applied','NUM: fixture independiente para edición retirada');
select is(pg_temp.push(100181,'sector',pg_temp.sector(108,14),'delete',1)->>'status','applied','NUM: retira fixture independiente');
select isnt(pg_temp.push(10018,'sector',pg_temp.sector(108,14)||'{"name":"FICTICIO editado retirado"}'::jsonb,'archive',2)->>'status',
  'applied','NUM: debe impedir editar identidad retirada');
select isnt(pg_temp.push(10019,'sector',pg_temp.sector(107,13),'update',1)->>'status','applied','NUM: UPDATE a inexistente debe rechazarse');
-- Fuente real de suelo y apicultura según repositorios (sin contexto agrícola).
select isnt(pg_temp.push(10020,'labor',(pg_temp.labor(503,'soil')-'agricultural_season_id'-'crop_assignment_id')||jsonb_build_object(
  'soil',jsonb_build_object('id',pg_temp.fid(603),'labor_id',pg_temp.fid(503),'moisturePercent',0,'ph',6.5)))->>'status',
  'rejected','SOIL: payload real de SoilRepository debe persistir');
select is((select count(*)::integer from soil_measurements where id=pg_temp.fid(603)),1,'SOIL: medición vinculada debe persistir');
select isnt(pg_temp.push(10021,'labor',jsonb_build_object('id',pg_temp.fid(504),'sector_id',pg_temp.fid(102),
  'agricultural_season_id',null,'crop_assignment_id',null,'type','apiary','domain_category','apiary',
  'details',jsonb_build_object('schemaVersion',1,'type','apiary','data',jsonb_build_object('hiveCount',3)),
  'occurred_at','2026-10-10T12:00:00Z','updated_at','2026-10-10T12:00:00Z',
  'apiary',jsonb_build_object('id',pg_temp.fid(604),'task_type','inspection','beekeeper_name','FICTICIO QA',
    'hive_count',3,'queen_status','ok','brood_status','ok','feeding_status','ok','health_notes','ok',
    'pest_notes','ninguna','super_installed',true,'inspected_at','2026-10-10T12:00:00Z')))->>'status',
  'rejected','APIARY: payload real sin temporada debe persistir');
select is((select count(*)::integer from apiary_inspections where id=pg_temp.fid(604)),1,'APIARY: inspección vinculada debe persistir');
-- Incluso agregando el contexto exigido, no debe perderse el hijo soil.
select is(pg_temp.push(10022,'labor',pg_temp.labor(505,'soil')||jsonb_build_object(
  'soil',jsonb_build_object('id',pg_temp.fid(605),'labor_id',pg_temp.fid(505),'moisturePercent',0,'ph',6.5)))->>'status',
  'applied','SOIL: variante con contexto válido aplica');
select is((select count(*)::integer from soil_measurements where id=pg_temp.fid(605)),1,'SOIL: ACK aplicado debe incluir hijo soil');
select is((select count(*)::integer from sync_pull(0,200) where aggregate_id=pg_temp.fid(505) and payload?'soil'),1,
  'SOIL: sync_changes conserva JSON soil aunque falte fila hija');
-- RPC con UUID de otro propietario: no debe atravesar RLS por SECURITY DEFINER.
select set_config('request.jwt.claim.sub',pg_temp.fid(2)::text,true);
select isnt(pg_temp.push(10023,'sector',pg_temp.sector(106,77),'update',1)->>'status','applied','RLS: RPC B debe rechazar UUID sector A');
select is_empty($$select * from sync_pull(0,200) where aggregate_id=pg_temp.fid(106)$$,'RLS: B no debe recibir recibo/cambio para sector A');
select throws_ok($$insert into soil_measurements(id,owner_id,sector_id,ph,measured_at)
  values(pg_temp.fid(699),pg_temp.fid(2),pg_temp.fid(101),6.5,'2026-10-10T12:00:00Z')$$,
  '23503','productive_sector_owner_mismatch','RLS: relación B hacia sector A debe rechazarse');
select is(pg_temp.push(10024,'agriculturalSeason',pg_temp.season(302,201))->>'status','applied','RLS: fixture temporada propia B');
select is(pg_temp.push(10025,'sectorCropAssignment',pg_temp.assignment(402,201,302))->>'status','applied','RLS: fixture asignación propia B');
select isnt(pg_temp.push(10026,'labor',pg_temp.labor(506,'fertilization',201,302,402)||jsonb_build_object(
  'supersedes_labor_id',pg_temp.fid(501)))->>'status','applied','RLS: corrección B no puede enlazar original A');
select is(pg_temp.push(10027,'labor',pg_temp.labor(507,'fertilization',101,301,401))->>'error_code',
  'labor_parent_missing','RLS: RPC B rechaza padres sector/temporada/asignación A');
select set_config('request.jwt.claim.sub',pg_temp.fid(1)::text,true);
select is((select number from sectors where id=pg_temp.fid(106)),11,'RLS: intento B debe conservar número original A');
select is((select count(*)::integer from labors where id in (pg_temp.fid(501),pg_temp.fid(502))),2,'CORR: original y corrección conservados');
select is(pg_temp.push(10028,'sector',pg_temp.sector(101,1)||'{"deleted_at":"2026-10-10T14:00:00Z"}'::jsonb,'delete',1)->>'status',
  'applied','HIST: retira sector con historial');
select is((select count(*)::integer from labors where sector_id=pg_temp.fid(101)),4,'HIST: retiro conserva todas las labores fuente, incluido suelo real');
select is((select count(*)::integer from agricultural_seasons where sector_id=pg_temp.fid(101)),1,'HIST: retiro conserva temporada');
select is((select count(*)::integer from crop_seasons where sector_id=pg_temp.fid(101)),1,'HIST: retiro conserva asignación');
select is_empty($$select * from sync_operations where status='applied' and result->>'status'<>'applied'$$,'SYNC: sin recibos exitosos falsos');
select * from finish();
rollback;
