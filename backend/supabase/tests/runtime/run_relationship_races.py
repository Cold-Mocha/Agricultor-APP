#!/usr/bin/env python3
"""First-reference races: real READ COMMITTED connections and row-lock barriers."""
import json
from pathlib import Path
import subprocess
import time
from run_contracts import Run, CLI_DEFAULT, HERE, FIXTURES, fid, quote, sanitize

r = Run(CLI_DEFAULT)


def race(name, first, second, code, message):
    processes = []
    for index, source in enumerate([first, second]):
        sql = (f"begin;set local role authenticated;set local request.jwt.claim.sub={quote(fid(1))};"
               + source + ('select pg_sleep(2);' if index == 0 else '') + 'commit;')
        (r.sql_dir / f'{name}_{index+1}.sql').write_text(sql)
        process = subprocess.Popen(r.psql, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE, text=True,
                                   env=r.env | {'PGAPPNAME': f'{name}_{index+1}'})
        process.stdin.write(sql)
        process.stdin.close()
        process.stdin = None
        processes.append(process)
        if index == 0:
            deadline = time.monotonic() + 5
            while time.monotonic() < deadline:
                probe = subprocess.run(r.psql, env=r.env, capture_output=True, text=True,
                    input=f"select count(*) from pg_stat_activity where application_name={quote(name+'_1')} and wait_event='PgSleep';")
                if probe.stdout.strip() == '1':
                    break
                time.sleep(.02)
            else:
                raise RuntimeError(f'{name}: barrier not reached')
    time.sleep(.15)
    locks = r.json_sql(name+'_locks', f"select coalesce(json_agg(json_build_object('type',wait_event_type,'event',wait_event)),'[]'::json) from pg_stat_activity where application_name={quote(name+'_2')};")
    observations = []
    for index, process in enumerate(processes):
        stdout, stderr = process.communicate(timeout=20)
        (r.logs / f'{name}_{index+1}.log').write_text(sanitize(stdout+stderr)+f'\nexit={process.returncode}\n')
        observations.append({'exit':process.returncode,'error':sanitize(stderr)})
    good = (observations[0]['exit'] == 0 and observations[1]['exit'] != 0
            and code in observations[1]['error'] and message in observations[1]['error']
            and any(row['type'] == 'Lock' for row in locks))
    r.record(name, {'first_commit':0,'second_error':code,'message':message,'actual_wait':True},
             {'connections':observations,'locks':locks}, good, f'logs/{name}_1.log; logs/{name}_2.log')


try:
    r.sql('prepare', (FIXTURES/'prepare.sql').read_text())
    r.sql('relations_seed', f"""
insert into sectors(id,owner_id,number,name,kind,boundary) values('{fid(191)}','{fid(1)}',91,'FICTICIO','crop',extensions.st_geomfromtext('POLYGON((-72.6 -38.74,-72.59 -38.74,-72.59 -38.73,-72.6 -38.74))',4326));
insert into agricultural_seasons(id,owner_id,sector_id,name,starts_on,status) values('{fid(391)}','{fid(1)}','{fid(191)}','FICTICIO','2026-01-01','active'),('{fid(392)}','{fid(1)}','{fid(191)}','FICTICIO','2027-01-01','planned');
insert into crop_seasons(id,owner_id,sector_id,agricultural_season_id,crop_id,status,starts_on) values('{fid(491)}','{fid(1)}','{fid(191)}','{fid(391)}','maiz','active','2026-01-01'),('{fid(493)}','{fid(1)}','{fid(191)}','{fid(391)}','maiz','planned','2026-01-01');
insert into custom_crops(id,owner_id,name,normalized_name) values('{fid(393)}','{fid(1)}','FICTICIO A','ficticio a'),('{fid(394)}','{fid(1)}','FICTICIO B','ficticio b');
insert into labors(id,owner_id,sector_id,season_id,agricultural_season_id,crop_assignment_id,type,occurred_at) values('{fid(691)}','{fid(1)}','{fid(191)}','{fid(493)}','{fid(391)}','{fid(493)}','irrigation',now());
insert into sector_irrigation_configs(id,owner_id,sector_id,method,plant_count,emitter_count,flow_ml_min,effective_from,config_version) values('{fid(771)}','{fid(1)}','{fid(191)}','drip',10,10,100,now(),1);
""")
    def labor_insert(number, season_number):
        return f"insert into labors(id,owner_id,sector_id,season_id,agricultural_season_id,crop_assignment_id,type,occurred_at) values('{fid(number)}','{fid(1)}','{fid(191)}','{fid(491)}','{fid(season_number)}','{fid(491)}','fertilization',now());"
    race('assignment_update_first', f"update crop_seasons set agricultural_season_id='{fid(392)}' where id='{fid(491)}';", labor_insert(681,391),'23514','labor_context_mismatch')
    race('assignment_child_first', labor_insert(682,392),f"update crop_seasons set agricultural_season_id='{fid(391)}' where id='{fid(491)}';",'23514','assignment_context_referenced')
    def irrigation_insert(number, version):
        return f"insert into irrigation_records(id,owner_id,sector_id,labor_id,config_id,config_version,irrigation_type,soil_type_code,duration_minutes,irrigated_at) values('{fid(number)}','{fid(1)}','{fid(191)}','{fid(691)}','{fid(771)}',{version},'drip','loamy',1,now());"
    race('config_update_first',f"update sector_irrigation_configs set config_version=2 where id='{fid(771)}';",irrigation_insert(891,1),'23514','irrigation_config_version_mismatch')
    race('config_child_first',irrigation_insert(892,2),f"update sector_irrigation_configs set config_version=3 where id='{fid(771)}';",'23514','irrigation_config_version_referenced')
    def custom_assignment(number, crop):
        return f"insert into crop_seasons(id,owner_id,sector_id,agricultural_season_id,crop_id,is_custom_crop,status,starts_on) values('{fid(number)}','{fid(1)}','{fid(191)}','{fid(391)}','{{{fid(crop).upper()}}}',true,'planned','2026-01-01');"
    race('custom_delete_first',f"delete from custom_crops where id='{fid(393)}';",custom_assignment(492,393),'23514','assignment_crop_missing')
    race('custom_child_first',custom_assignment(494,394),f"delete from custom_crops where id='{fid(394)}';",'23503','custom_crop_referenced')
    r.expect('relations_consistent', f"select json_build_object('labor_failed',(select count(*) from labors where id='{fid(681)}'),'labor_valid',(select count(*) from labors where id='{fid(682)}'),'assignment_season',(select agricultural_season_id from crop_seasons where id='{fid(491)}'),'config_version',(select config_version from sector_irrigation_configs where id='{fid(771)}'),'dangling_assignment',(select count(*) from crop_seasons where id='{fid(492)}'),'protected_crop',(select count(*) from custom_crops where id='{fid(394)}'));", {'labor_failed':0,'labor_valid':1,'assignment_season':fid(392),'config_version':2,'dangling_assignment':0,'protected_crop':1},owner=None)
finally:
    r.cleanup()
    summary={'total':len(r.results),'passed':sum(row['passed'] for row in r.results),'failed':sum(not row['passed'] for row in r.results)}
    (HERE/'relationships-summary.json').write_text(json.dumps(summary,indent=2))
    print(summary)
raise SystemExit(1 if summary['failed'] else 0)
