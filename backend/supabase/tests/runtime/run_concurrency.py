"""Overlapping real PostgreSQL transactions with barriers; no cursor contiguity assumption."""
from run_contracts import Run,CLI_DEFAULT,HERE,operation,sector,fid,quote,sanitize
import subprocess,json,time
from pathlib import Path
r=Run(CLI_DEFAULT)
r.sql('prepare', (Path(__file__).parent/'prepare.sql').read_text())
try:
 r.concurrent('D_same_operation_commit',operation(97001,'sector',sector(170,70)),operation(97001,'sector',sector(170,70)),same_operation=True)

 def overlap(name,first,second,owner2=1,rollback=False,expected=('applied','duplicate'),locked=True,during=False):
  if during:
   r.sql(name+'_pause_install', "create function public._ci_pause_sector() returns trigger language plpgsql as $$ begin if current_setting('application_name') = '"+name+"_1' and new.id = '"+first[0]['aggregate_id']+"'::uuid then perform pg_sleep(2); end if; return new; end $$; create trigger _ci_pause_sector before insert on sectors for each row execute function public._ci_pause_sector();")
  procs=[];locks=[]
  for i,ops in enumerate([first,second]):
   sql=f"begin; set local role authenticated; set local request.jwt.claim.sub={quote(fid(1 if i==0 else owner2))};select sync_push({quote(json.dumps(ops))}::jsonb);"+('select pg_sleep(2);' if i==0 and not during else '')+('rollback;' if rollback and i==0 else 'commit;')
   file=r.sql_dir/(name+f'_{i+1}.sql');file.write_text(sql)
   p=subprocess.Popen(r.psql,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,env=r.env|{'PGAPPNAME':name+f'_{i+1}'})
   p.stdin.write(sql);p.stdin.close();p.stdin=None;procs.append((p,file))
   if i==0:
    until=time.monotonic()+5
    while time.monotonic()<until:
     poll=subprocess.run(r.psql,input=f"select count(*) from pg_stat_activity where application_name={quote(name+'_1')} and wait_event='PgSleep'",env=r.env,capture_output=True,text=True)
     if poll.stdout.strip()=='1':break
     time.sleep(.02)
    else:raise RuntimeError('Barrier not reached')
  time.sleep(.15)
  locks=r.json_sql(name+'_locks',f"select coalesce(json_agg(json_build_object('name',application_name,'type',wait_event_type,'event',wait_event)), '[]'::json) from pg_stat_activity where application_name={quote(name+'_2')}",owner=None)
  responses=[]
  for p,file in procs:
   out,err=p.communicate(timeout=20);(r.logs/(file.stem+'.log')).write_text(sanitize(out+err)+f'\nexit={p.returncode}\n')
   if p.returncode:raise RuntimeError(sanitize(err))
   responses.append(json.loads(next(line for line in out.splitlines() if line.startswith('{')))['results'])
  statuses=[response[0]['status'] for response in responses]
  r.record(name,{'statuses':list(expected),'lock':locked},{'responses':responses,'locks':locks},statuses==list(expected) and any(x['type']=='Lock' for x in locks)==locked,', '.join(str(p.relative_to(HERE)) for _,p in procs))
  if during: r.sql(name+'_pause_remove', 'drop trigger _ci_pause_sector on sectors; drop function public._ci_pause_sector();')
  return responses
 op=operation(97002,'sector',sector(171,71))
 rows=overlap('D_hash_mismatch',[op],[op|{'request_hash':'different-confirmed-hash'}],expected=('applied','rejected'))
 r.record('D_specific_mismatch','idempotency_mismatch',rows[1][0],rows[1][0].get('error_code')=='idempotency_mismatch','logs/D_hash_mismatch_2.log')
 op=operation(97003,'sector',sector(172,72))
 overlap('D_first_rollback',[op],[op],rollback=True,expected=('applied','applied'))
 overlap('D_independent_owners',[operation(97004,'sector',sector(173,73))],[operation(97004,'sector',sector(174,73))],owner2=2,expected=('applied','applied'),locked=False)
 op=operation(97005,'sector',sector(175,75))
 rows=overlap('D_foreign_uuid_race',[op],[operation(97006,'sector',sector(175,76))],owner2=2,expected=('applied','rejected'))
 r.expect('D_foreign_uuid_intact',f"select json_build_object('owner',owner_id,'number',number) from sectors where id={quote(fid(175))};",{'owner':fid(1),'number':75})
 r.expect('D_foreign_uuid_no_receipt',f"select count(*) from sync_operations where owner_id={quote(fid(2))} and operation_id={quote(fid(97006))};",0,2)
 ops=[operation(97007,'sector',sector(176,76)),operation(97008,'sector',sector(177,77))]
 rows=overlap('D_reverse_batch_order',ops,list(reversed(ops)),during=True)
 r.record('D_reverse_batch_all_duplicates',['duplicate','duplicate'],rows[1],all(x['status']=='duplicate' for x in rows[1]),'logs/D_reverse_batch_order_2.log')
 ops=[operation(97009,'sector',sector(178,78)),operation(97010,'sector',sector(179,79))]
 ops=[op|{'operation_id':'{'+op['operation_id'].upper()+'}'} for op in ops]
 rows=overlap('D_equivalent_uuid_reverse_batch',ops,list(reversed(ops)),during=True)
 r.record('D_equivalent_uuid_duplicates',['duplicate','duplicate'],rows[1],all(x['status']=='duplicate' for x in rows[1]),'logs/D_equivalent_uuid_reverse_batch_2.log')
 for opid,entity in [(97001,170),(97002,171),(97003,172),(97005,175),(97007,176),(97008,177)]:
  r.expect(f'D_exact_once_{opid}',f"select json_build_object('row',(select count(*) from sectors where id={quote(fid(entity))}),'receipt',(select count(*) from sync_operations where operation_id={quote(fid(opid))}),'change',(select count(*) from sync_changes where aggregate_id={quote(fid(entity))}));",{'row':1,'receipt':1,'change':1})
 summary={'total':len(r.results),'passed':sum(x['passed'] for x in r.results),'failed':sum(not x['passed'] for x in r.results)}
 (HERE/'d-concurrency-summary.json').write_text(json.dumps(summary,indent=2));(HERE/'d-concurrency-results.json').write_text(json.dumps(r.results,indent=2));print(summary)
 raise SystemExit(1 if summary['failed'] else 0)
finally:
 r.sql('pause_cleanup', 'drop trigger if exists _ci_pause_sector on sectors; drop function if exists public._ci_pause_sector();')
 r.cleanup()
