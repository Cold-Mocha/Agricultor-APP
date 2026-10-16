#!/usr/bin/env python3
"""Contrato recuperado de la evidencia original, con fixtures equivalentes y regresiones adicionales. Exclusivamente Supabase desechable.

Cada invocación psql abre otra conexión. Los fallos de producto producen exit 1.
No requiere dependencias Python, .env, Flutter ni credenciales de producción.
"""
import argparse
import copy
import hashlib
import http.client
import json
import os
from pathlib import Path
import re
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request

FIXTURES = Path(__file__).resolve().parent
ROOT = FIXTURES.parents[3]
HERE = Path(os.environ.get('AGROCAMPO_TEST_OUTPUT', ROOT / 'build/supabase-local-gate/runtime'))
HERE.mkdir(parents=True, exist_ok=True)
PROJECT = os.environ.get('AGROCAMPO_TEST_PROJECT', 'agrocampo-ci-plan-local')
WORK = Path(os.environ.get('AGROCAMPO_TEST_WORK', '/tmp/' + PROJECT))
STAMP = '2026-10-10T12:00:00Z'
PREFIX = 'ac200000-0000-4000-8000-'
CLI_DEFAULT = os.environ.get('SUPABASE_CLI', 'supabase')


def fid(n):
    return PREFIX + f'{n:012d}'


def quote(value):
    return "'" + value.replace("'", "''") + "'"


def sector(n, number, kind='crop'):
    return dict(id=fid(n), number=number, name=f'FICTICIO QA Sector {number}', kind=kind,
                polygon=[dict(lat=-38.74, lng=-72.60), dict(lat=-38.74, lng=-72.59),
                         dict(lat=-38.73, lng=-72.59), dict(lat=-38.73, lng=-72.60)],
                updated_at=STAMP)


def season(n, parent):
    return dict(id=fid(n), sector_id=fid(parent), name='FICTICIO QA Temporada',
                starts_on='2026-01-01', status='active', updated_at=STAMP)


def crop(n, letter):
    return dict(id=fid(n), name=f'FICTICIO QA Cultivo {letter}',
                normalized_name=f'ficticio qa cultivo {letter.lower()}', updated_at=STAMP)


def assignment(n, parent, season_n, crop_n):
    return dict(id=fid(n), sector_id=fid(parent), agricultural_season_id=fid(season_n),
                crop_id=fid(crop_n), is_custom_crop=True, status='active',
                starts_on='2026-01-01', updated_at=STAMP)


def labor(n, kind='fertilization', parent=101, season_n=301, assignment_n=401):
    return dict(id=fid(n), sector_id=fid(parent), agricultural_season_id=fid(season_n),
                crop_assignment_id=fid(assignment_n), type=kind, domain_category='crop',
                details=dict(schemaVersion=1, type=kind,
                             data=dict(amount=10.5, unit='kg', measured=True)),
                details_schema_version=1, status='recorded', notes='FICTICIO QA',
                occurred_at=STAMP, updated_at=STAMP)


def operation(n, kind, payload, mutation='create', base=None):
    # Mismo contenido -> mismo hash. El protocolo recibe hashes opacos del cliente.
    canonical = json.dumps([kind, payload, mutation, base], sort_keys=True)
    return dict(operation_id=fid(n), aggregate_type=kind, aggregate_id=payload['id'],
                mutation_kind=mutation, protocol_version=2, payload_schema_version=1,
                base_version=base, request_hash=hashlib.sha256(canonical.encode()).hexdigest(),
                payload=payload)


def sanitize(s):
    s = re.sub(r'eyJ[\w-]+\.[\w-]+\.[\w-]+', '[JWT_LOCAL_REDACTADO]', s)
    s = re.sub(r'sb_(?:publishable|secret)_[\w-]+', '[CLAVE_LOCAL_REDACTADA]', s)
    s = re.sub(r'(postgres(?:ql)?://[^: ]+:)[^@ ]+@', r'\1[REDACTADO]@', s)
    for key in ['JWT_SECRET', 'S3_PROTOCOL_ACCESS_KEY_ID', 'S3_PROTOCOL_ACCESS_KEY_SECRET']:
        s = re.sub(r'("' + key + r'"\s*:\s*)"[^"]*"', r'\1"[REDACTADO]"', s)
    return s


class Run:
    def __init__(self, cli):
        if not re.fullmatch(r'agrocampo-ci-plan-(?:local|[0-9]+)|agrocampo-ci-implementation-20261010', PROJECT) or WORK != Path('/tmp') / PROJECT:
            raise RuntimeError('Se requiere un workdir /tmp y project_id exclusivo de pruebas')
        self.results = []
        self.fixtures = []
        self.counter = 0
        self.tokens = {}
        self.logs = HERE / 'logs'
        self.sql_dir = HERE / 'sql'
        self.logs.mkdir(exist_ok=True)
        self.sql_dir.mkdir(exist_ok=True)
        cfg = (WORK / 'supabase/config.toml').read_text()
        if f'project_id = "{PROJECT}"' not in cfg:
            raise RuntimeError('Se requiere la copia desechable; nunca el workdir backend')
        inspect = subprocess.check_output(['docker', 'inspect', f'supabase_db_{PROJECT}'], text=True)
        info = json.loads(inspect)[0]
        if info['Config']['Image'] != 'public.ecr.aws/supabase/postgres:17.6.1.167':
            raise RuntimeError('Imagen PostgreSQL distinta; revisar versión antes de probar')
        p = subprocess.run([cli, '--workdir', str(WORK), 'status', '--output', 'json'],
                           capture_output=True, text=True, check=True)
        status = json.loads(p.stdout)
        url = urllib.parse.urlparse(status['DB_URL'])
        if (url.hostname, url.port, url.path) != ('127.0.0.1', 54422, '/postgres'):
            raise RuntimeError('Destino PostgreSQL no autorizado')
        if status['API_URL'] != 'http://127.0.0.1:54421':
            raise RuntimeError('Destino API no autorizado')
        self.key = status['ANON_KEY']
        self.api = status['API_URL']
        self.env = os.environ | dict(PGHOST='127.0.0.1', PGPORT='54422', PGDATABASE='postgres',
                                     PGUSER=url.username, PGPASSWORD=url.password,
                                     PGCONNECT_TIMEOUT='5', PGAPPNAME='agrocampo-persistence-qa')
        # Evita parámetros externos que puedan cambiar el destino o inyectar SQL.
        for k in ['PGSERVICE', 'PGSERVICEFILE', 'PGOPTIONS']:
            self.env.pop(k, None)
        self.psql = ['psql', '-X', '-qAt', '-v', 'ON_ERROR_STOP=1', '-v', 'VERBOSITY=verbose', '--pset', 'pager=off']
        (self.logs / 'environment.json').write_text(json.dumps(dict(
            commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
            project=PROJECT, api=self.api, db='127.0.0.1:54422/postgres',
            image=info['Config']['Image'], image_id=info['Image'],
            cli_version=subprocess.check_output([cli, '--version'], text=True).strip()), indent=2))

    def sql(self, name, source, owner=None, check=True):
        if owner is not None:
            source = f"begin; set local role authenticated; set local request.jwt.claim.sub={quote(fid(owner))};\n{source}\ncommit;"
        self.counter += 1
        file = self.sql_dir / f'{self.counter:03d}_{name}.sql'
        file.write_text(source + '\n')
        p = subprocess.run(self.psql, input=source, env=self.env, capture_output=True, text=True)
        (self.logs / (file.stem + '.log')).write_text(
            '$ psql -X -qAt -v ON_ERROR_STOP=1 < sql/' + file.name + '\n'
            + sanitize(p.stdout + p.stderr) + f'\nexit={p.returncode}\n')
        if check and p.returncode:
            raise RuntimeError(f'{name}: {sanitize(p.stderr)}')
        return p

    def json_sql(self, name, source, owner=None):
        p = self.sql(name, source, owner)
        value = p.stdout.strip()
        if not value:
            return None
        if value in ['t', 'f']:
            return value == 't'
        return json.loads(value)

    def record(self, name, expected, actual, passed, evidence):
        result = dict(case=name, expected=expected, observed=actual, passed=bool(passed), evidence=evidence)
        self.results.append(result)
        (self.logs / 'runtime-results.json').write_text(json.dumps(self.results, indent=2, ensure_ascii=False))
        print(('PASS ' if passed else 'FAIL ') + name + ': ' + json.dumps(actual, ensure_ascii=False), flush=True)

    def expect(self, name, source, expected, owner=1):
        actual = self.json_sql(name, source, owner)
        self.record(name, expected, actual, actual == expected, f'sql/{self.counter:03d}_{name}.sql')
        return actual

    def push(self, name, op, expected='applied', owner=1):
        self.fixtures.append(dict(case=name, owner=fid(owner), operation=op))
        (HERE / 'fixtures.json').write_text(json.dumps(self.fixtures, indent=2, ensure_ascii=False))
        response = self.json_sql(name,
            'select sync_push(' + quote(json.dumps([op])) + '::jsonb);', owner)
        row = response['results'][0]
        actual = row['status']
        passed = actual == expected if isinstance(expected, str) else actual in expected
        self.record(name, expected, row, passed, f'sql/{self.counter:03d}_{name}.sql')
        return row

    def http(self, path, body=None, owner=1, method=None):
        headers = {'apikey': self.key, 'Content-Type': 'application/json'}
        if owner in self.tokens:
            headers['Authorization'] = 'Bearer ' + self.tokens[owner]
        request = urllib.request.Request(self.api + path,
            data=None if body is None else json.dumps(body).encode(), headers=headers, method=method)
        try:
            with urllib.request.urlopen(request, timeout=15) as res:
                return res.status, json.loads(res.read() or b'null')
        except urllib.error.HTTPError as e:
            return e.code, json.loads(e.read() or b'null')

    def concurrent(self, name, first, second, same_operation=False):
        paths = []
        procs = []
        for i, op in enumerate([first, second]):
            sql = (f"begin; set local role authenticated; set local request.jwt.claim.sub={quote(fid(1))};"
                   f"select sync_push({quote(json.dumps([op]))}::jsonb);"
                   + ('select pg_sleep(4);' if i == 0 else '') + 'commit;')
            file = self.sql_dir / f'{name}_{i+1}.sql'
            file.write_text(sql + '\n')
            env = self.env | {'PGAPPNAME': f'{name}_{i+1}'}
            process = subprocess.Popen(self.psql, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE, text=True, env=env)
            process.stdin.write(sql)
            process.stdin.close()
            process.stdin = None
            paths.append(file)
            procs.append(process)
            if i == 0:
                deadline = time.monotonic() + 3
                while time.monotonic() < deadline:
                    q = subprocess.run(self.psql, env=self.env, capture_output=True, text=True,
                        input=f"select count(*) from pg_stat_activity where application_name={quote(name+'_1')} and wait_event='PgSleep';")
                    if q.stdout.strip() == '1':
                        break
                    time.sleep(.03)
                else:
                    raise RuntimeError('No se pudo establecer barrera de concurrencia')
        time.sleep(.1)
        locks = self.json_sql(name+'_locks',
            f"select coalesce(json_agg(json_build_object('application',application_name,'wait',wait_event_type,'event',wait_event)), '[]'::json) from pg_stat_activity where application_name in ({quote(name+'_1')},{quote(name+'_2')});")
        rows = []
        for file, process in zip(paths, procs):
            out, err = process.communicate(timeout=15)
            (self.logs / (file.stem + '.log')).write_text(sanitize(out + err) + f'\nexit={process.returncode}\n')
            if process.returncode:
                raise RuntimeError(file.stem + ': ' + sanitize(err))
            rows.append(json.loads(next(s for s in out.splitlines() if s.startswith('{')))['results'][0])
        wanted = ['applied', 'duplicate' if same_operation else 'rejected']
        self.record(name, dict(statuses=wanted, real_lock=True), dict(results=rows, locks=locks),
                    [r['status'] for r in rows] == wanted and any(l['wait'] == 'Lock' for l in locks),
                    ', '.join('sql/' + p.name for p in paths))

    def cleanup(self):
        source = (FIXTURES / 'cleanup.sql').read_text()
        self.sql('cleanup', source)
        self.expect('CLEANUP_no_fictional_users',
                    f"select count(*) from auth.users where id in ({quote(fid(1))},{quote(fid(2))});", 0, owner=None)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--cli', default=CLI_DEFAULT)
    parser.add_argument('--cleanup-only', action='store_true')
    args = parser.parse_args()
    r = Run(args.cli)
    if args.cleanup_only:
        r.cleanup()
        return
    existing = r.json_sql('guard_empty_test_users', f"select count(*) from auth.users where id in ({quote(fid(1))},{quote(fid(2))});")
    if existing:
        raise RuntimeError('Fixtures previos detectados; usar --cleanup-only antes de repetir')
    r.sql('prepare_users', (FIXTURES / 'prepare.sql').read_text())
    try:
        r.expect('ENV_authenticated_A', "select json_build_object('role',current_user,'uid',auth.uid());",
                 dict(role='authenticated', uid=fid(1)))
        versions = r.json_sql('server_versions', "select json_build_object('postgres',version(),'extensions',(select json_agg(json_build_object('name',name,'version',default_version,'installed',installed_version)) from pg_available_extensions where name in ('pgtap','postgis','pgcrypto')),'migrations',(select json_agg(version order by version) from supabase_migrations.schema_migrations));")
        (r.logs / 'server-versions.json').write_text(json.dumps(versions, indent=2))
        tables = r.json_sql('remote_inventory', "select json_agg(json_build_object('table',table_name,'columns',(select json_agg(column_name order by ordinal_position) from information_schema.columns c where c.table_schema='public' and c.table_name=t.table_name))) from information_schema.tables t where table_schema='public' and table_type='BASE TABLE';")
        (r.logs / 'remote-inventory.json').write_text(json.dumps(tables, indent=2))
        r.expect('MODEL_no_parcels', "select count(*) from information_schema.columns where table_schema='public' and (table_name='parcels' or column_name ilike '%parcel%');", 0)
        r.push('MODEL_reject_parcel', operation(10001, 'parcel', dict(id=fid(901), name='FICTICIO')), 'rejected')
        # Destino HTTP real: sesiones emitidas por GoTrue local, no JWT inventados.
        for owner in [1, 2]:
            code, auth = r.http('/auth/v1/token?grant_type=password', dict(
                email=f'qa-persistence-{owner}@example.invalid', password='Ficticio-QA-2026-Only!'), owner=None)
            good = code == 200 and auth.get('user', {}).get('id') == fid(owner)
            if good:
                r.tokens[owner] = auth['access_token']
            r.record(f'AUTH_login_{owner}', 'HTTP 200 y usuario ficticio correcto',
                     dict(http=code, user_id=auth.get('user', {}).get('id'), error=auth.get('error_code')),
                     good, 'prepare.sql; run_runtime.py /auth/v1/token')
            if not good:
                raise RuntimeError('No hay sesión local: no ejecutar pruebas HTTP con permisos distintos')
        # Fuentes de A y B creadas siempre mediante RPC authenticated.
        for owner, parents in [(1, [(101,1,'crop'),(102,2,'apiary'),(103,10,'crop')]),(2,[(201,1,'crop')])]:
            for n,num,kind in parents:
                r.push(f'PREP_sector_{n}',operation(10000+n,'sector',sector(n,num,kind)),owner=owner)
        for owner,sn,parent,cn,an in [(1,301,101,303,401),(2,302,201,304,402)]:
            r.push(f'PREP_season_{sn}',operation(11000+sn,'agriculturalSeason',season(sn,parent)),owner=owner)
            r.push(f'PREP_crop_{cn}',operation(12000+cn,'customCrop',crop(cn,str(owner))),owner=owner)
            r.push(f'PREP_assignment_{an}',operation(13000+an,'sectorCropAssignment',assignment(an,parent,sn,cn)),owner=owner)
        r.expect('RLS_B_reads_no_A',f"select count(*) from sectors where owner_id={quote(fid(1))};",0,owner=2)
        r.expect('RLS_B_pull_no_A',f"select count(*) from sync_pull(0,200) where aggregate_id={quote(fid(101))};",0,owner=2)
        r.expect('RLS_B_direct_update_A',f"with x as(update sectors set name='FICTICIO intruso' where id={quote(fid(101))} returning id) select count(*) from x;",0,owner=2)
        r.expect('RLS_B_direct_delete_A',f"with x as(delete from sectors where id={quote(fid(101))} returning id) select count(*) from x;",0,owner=2)
        # Reserva histórica, hipótesis prioritaria, conexión distinta por cada comprobación.
        r.push('NUM_retire_10',operation(14001,'sector',sector(103,10)|dict(deleted_at=STAMP),'delete',1))
        r.expect('NUM_historical_next_11','select max(number)+1 from sectors;',11)
        r.push('NUM_reuse_retired_10',operation(14002,'sector',sector(104,10)),'rejected')
        r.expect('NUM_rejected_no_receipt',f"select count(*) from sync_operations where operation_id={quote(fid(14002))};",0)
        r.push('NUM_next_11',operation(14003,'sector',sector(105,11)))
        r.push('NUM_renumber_11_to_12',operation(14004,'sector',sector(105,12),'update',1),['rejected','conflict'])
        r.expect('NUM_identity_stays_11',f"select number from sectors where id={quote(fid(105))};",11)
        r.push('NUM_reactivate_10',operation(14005,'sector',sector(103,10),'update',2),['rejected','conflict'])
        r.expect('NUM_tombstone_stays',f"select deleted_at is not null from sectors where id={quote(fid(103))};",True)
        # Retirado independiente para evitar que la reactivación anterior altere el caso.
        r.push('NUM_prepare_retired_edit',operation(14006,'sector',sector(106,20)))
        r.push('NUM_retire_edit_fixture',operation(14007,'sector',sector(106,20),'delete',1))
        r.push('NUM_edit_retired',operation(14008,'sector',sector(106,20)|dict(name='FICTICIO cambiado'),'archive',2),['rejected','conflict'])
        r.push('NUM_update_nonexistent',operation(14009,'sector',sector(107,21),'update',1),['rejected','conflict'])
        # ACK perdido: enviar petición HTTP completa y cerrar sin leer respuesta.
        ack_op=operation(15001,'labor',labor(501))
        r.fixtures.append(dict(case='ACK_request_discarded',owner=fid(1),operation=ack_op))
        (HERE/'lost_ack_request.json').write_text(json.dumps(dict(operations=[ack_op]),indent=2))
        conn=http.client.HTTPConnection('127.0.0.1',54421,timeout=10)
        conn.request('POST','/rest/v1/rpc/sync_push',body=json.dumps(dict(operations=[ack_op])),headers={
            'apikey':r.key,'Authorization':'Bearer '+r.tokens[1],'Content-Type':'application/json'})
        deadline=time.monotonic()+5
        while time.monotonic()<deadline:
            count=r.json_sql('ACK_wait_committed',f"select count(*) from sync_operations where operation_id={quote(fid(15001))};",1)
            if count: break
            time.sleep(.05)
        conn.close()  # Tras confirmar commit por SQL; nunca se llama getresponse.
        observed=r.json_sql('ACK_observer_before_retry',f"select json_build_object('business',(select count(*) from labors where id={quote(fid(501))}),'receipt',(select count(*) from sync_operations where operation_id={quote(fid(15001))}),'change',(select count(*) from sync_changes where aggregate_id={quote(fid(501))}));",1)
        r.record('ACK_committed_without_client_response',dict(business=1,receipt=1,change=1),observed,
                 observed==dict(business=1,receipt=1,change=1),'lost_ack_request.json; sql/ACK_observer_before_retry')
        r.push('ACK_retry_duplicate',ack_op,'duplicate')
        r.expect('ACK_no_duplicate_rows',f"select count(*) from labors where id={quote(fid(501))};",1)
        changed=copy.deepcopy(ack_op);changed['request_hash']='FICTICIO hash distinto'
        r.push('SYNC_idempotency_mismatch',changed,'rejected')
        r.push('SYNC_stale_version',operation(15002,'labor',labor(501),'update',0),'conflict')
        r.expect('SYNC_conflict_no_receipt',f"select count(*) from sync_operations where operation_id={quote(fid(15002))};",0)
        r.push('SYNC_correct_base',operation(15003,'labor',labor(501)|dict(notes='FICTICIO versión 2'),'update',1))
        r.expect('SYNC_version_2',f"select version from labors where id={quote(fid(501))};",2)
        r.expect('JSON_native_values',f"select json_build_object('amount',details#>'{{data,amount}}','measured',details#>'{{data,measured}}') from labors where id={quote(fid(501))};",dict(amount=10.5,measured=True))
        r.expect('JSON_domain_category',f"select to_json(domain_category) from labors where id={quote(fid(501))};",'crop')
        r.push('CORRECTION_create',operation(15004,'labor',labor(502)|dict(supersedes_labor_id=fid(501))))
        r.push('CORRECTION_mark_original',operation(15005,'labor',labor(501)|dict(status='corrected'),'update',2))
        r.expect('CORRECTION_observer',f"select json_build_object('original_status',(select status from labors where id={quote(fid(501))}),'correction_original',(select supersedes_labor_id from labors where id={quote(fid(502))}));",dict(original_status='corrected',correction_original=fid(501)))
        # SoilRepository usa un labor sin temporada/asignación.
        soil=dict(id=fid(503),owner_id=fid(1),sector_id=fid(101),type='soil',domain_category='crop',
                  details=dict(schemaVersion=1,type='soil',data=dict(moisturePercent=0,ph=6.5)),
                  soil=dict(id=fid(603),labor_id=fid(503),moisturePercent=0,ph=6.5),
                  occurred_at=STAMP,version=1,updated_at=STAMP)
        r.push('SOIL_real_app_payload',operation(15006,'labor',soil))
        r.expect('SOIL_real_child_observer',f"select count(*) from soil_measurements where id={quote(fid(603))};",1)
        apiary=dict(id=fid(504),sector_id=fid(102),agricultural_season_id=None,crop_assignment_id=None,
                    type='apiary',task_type='inspection',beekeeper_name='FICTICIO QA',hive_count=3,
                    inspected_at=STAMP,domain_category='apiary',details=dict(schemaVersion=1,type='apiary',
                    data=dict(taskType='inspection',beekeeperName='FICTICIO QA',hiveCount=3,queenStatus='ok',
                              broodStatus='ok',feedingStatus='ok',healthNotes='ok',pestNotes='ninguna',superInstalled=True)),
                    details_schema_version=1,occurred_at=STAMP,updated_at=STAMP,
                    apiary=dict(id=fid(604),task_type='inspection',beekeeper_name='FICTICIO QA',hive_count=3,
                                queen_status='ok',brood_status='ok',feeding_status='ok',health_notes='ok',
                                pest_notes='ninguna',super_installed=True,inspected_at=STAMP))
        r.push('APIARY_real_app_payload',operation(15007,'labor',apiary))
        r.expect('APIARY_real_child_observer',f"select count(*) from apiary_inspections where id={quote(fid(604))};",1)
        soil_context=labor(505,'soil')|dict(soil=dict(id=fid(605),labor_id=fid(505),moisturePercent=0,ph=6.5))
        r.push('SOIL_valid_context_variant',operation(15008,'labor',soil_context))
        r.expect('SOIL_ACK_child_missing',f"select count(*) from soil_measurements where id={quote(fid(605))};",1)
        r.expect('SOIL_change_payload_preserved',f"select count(*) from sync_pull(0,200) where aggregate_id={quote(fid(505))} and payload?'soil';",1)
        # Persistencia directa de las tablas especializadas: no equivale a sync_push.
        p=r.sql('SOIL_direct_duplicate_child',f"insert into soil_measurements(id,owner_id,sector_id,labor_id,moisture_percent,ph,measured_at) values({quote(fid(606))},{quote(fid(1))},{quote(fid(101))},{quote(fid(505))},0,6.5,{quote(STAMP)});",1,check=False)
        r.record('SOIL_direct_duplicate_child','23505 uniqueness rejection',dict(exit=p.returncode,error=sanitize(p.stderr)),p.returncode!=0 and '23505' in p.stderr,'logs/runtime-results.json')
        r.sql('SOIL_direct_insert',f"insert into soil_measurements(id,owner_id,sector_id,moisture_percent,ph,measured_at) values({quote(fid(606))},{quote(fid(1))},{quote(fid(101))},0,6.5,{quote(STAMP)});",1)
        r.expect('SOIL_direct_zero_vs_null',f"select json_build_object('moisture',moisture_percent,'temperature',temperature_celsius,'ph',ph) from soil_measurements where id={quote(fid(606))};",dict(moisture=0,temperature=None,ph=6.5))
        r.sql('APIARY_direct_insert',f"insert into apiary_inspections(id,owner_id,sector_id,task_type,beekeeper_name,hive_count,queen_status,brood_status,feeding_status,health_notes,pest_notes,super_installed,inspected_at) values({quote(fid(607))},{quote(fid(1))},{quote(fid(102))},'inspection','FICTICIO QA',3,'ok','ok','ok','ok','ninguna',true,{quote(STAMP)});",1)
        r.expect('APIARY_direct_observer',f"select json_build_object('hives',hive_count,'super',super_installed) from apiary_inspections where id={quote(fid(607))};",dict(hives=3,super=True))
        # Producción e irrigación soportadas realmente por RPC.
        harvest=labor(506,'harvest')|dict(production=dict(id=fid(608),labor_id=fid(506),crop_id=fid(303),
            quantity=125.5,unit='kg',quality_notes='FICTICIO QA',harvested_at=STAMP,updated_at=STAMP))
        r.push('PRODUCTION_aggregate',operation(15009,'labor',harvest))
        r.expect('PRODUCTION_observer',f"select json_build_object('quantity',quantity,'unit',unit,'labor_id',labor_id) from production_records where id={quote(fid(608))};",dict(quantity=125.5,unit='kg',labor_id=fid(506)))
        config=dict(id=fid(701),sector_id=fid(101),method='drip',plant_count=100,emitter_count=200,
                    flow_ml_min=4000,effective_from=STAMP,config_version=1,updated_at=STAMP)
        r.push('IRRIGATION_config',operation(15010,'irrigationConfig',config))
        water=labor(507,'irrigation')|dict(irrigation=dict(id=fid(609),labor_id=fid(507),sector_id=fid(101),
            irrigation_type='drip',soil_type_code='loamy',config_id=fid(701),config_version=1,
            duration_seconds=1800,applied_volume_ml=120000,
            performed_details=dict(config_snapshot=dict(version=1)),irrigated_at=STAMP,updated_at=STAMP))
        water_op=operation(15011,'labor',water)
        r.push('IRRIGATION_aggregate',water_op)
        r.push('IRRIGATION_retry',water_op,'duplicate')
        r.expect('IRRIGATION_observer',f"select json_build_object('seconds',duration_seconds,'ml',applied_volume_ml,'config_version',config_version,'snapshot',performed_details) from irrigation_records where id={quote(fid(609))};",dict(seconds=1800,ml=120000,config_version=1,snapshot=dict(config_snapshot=dict(version=1))))
        r.expect('IRRIGATION_once',f"select count(*) from irrigation_records where labor_id={quote(fid(507))};",1)
        invalid=labor(508,'irrigation')|dict(irrigation=water['irrigation']|dict(id=fid(610),labor_id=fid(508),duration_seconds=0))
        r.push('IRRIGATION_invalid_atomic_reject',operation(15012,'labor',invalid),'rejected')
        r.expect('IRRIGATION_no_partial_ACK',f"select json_build_object('labor',(select count(*) from labors where id={quote(fid(508))}),'receipt',(select count(*) from sync_operations where operation_id={quote(fid(15012))}),'change',(select count(*) from sync_changes where aggregate_id={quote(fid(508))}));",dict(labor=0,receipt=0,change=0))
        # Aislamiento de tablas fuente y relaciones bajo authenticated B.
        for table in ['agricultural_seasons','crop_seasons','labors','soil_measurements','irrigation_records','production_records','apiary_inspections','sync_operations','sync_changes']:
            r.expect('RLS_B_hidden_'+table,f"select count(*) from {table} where owner_id={quote(fid(1))};",0,2)
        r.push('RLS_B_foreign_season_parent',operation(16001,'agriculturalSeason',season(305,101)),'rejected',2)
        r.push('RLS_B_foreign_assignment_parent',operation(16002,'sectorCropAssignment',assignment(405,101,301,303)),'rejected',2)
        r.push('RLS_B_foreign_labor_parent',operation(16003,'labor',labor(509)),'rejected',2)
        # Relación de corrección no tiene guard de propietario.
        r.push('RLS_B_foreign_correction',operation(16004,'labor',labor(510,parent=201,season_n=302,assignment_n=402)|dict(supersedes_labor_id=fid(501))),['rejected','conflict'],2)
        r.expect('RLS_foreign_correction_observer',f"select count(*) from labors where id={quote(fid(510))} and supersedes_labor_id={quote(fid(501))};",0,2)
        # UPDATE RPC con el mismo UUID sector de A (no sólo un parent incorrecto).
        attack=operation(16005,'sector',sector(105,77)|dict(name='FICTICIO QA B sobre A'),'update',1)
        code,response=r.http('/rest/v1/rpc/sync_push',dict(operations=[attack]),2)
        row=response.get('results',[{}])[0]
        (HERE/'http_sector_collision.json').write_text(json.dumps(dict(operation=attack,http=code,response=response),indent=2))
        r.record('RLS_HTTP_B_cannot_overwrite_A','rejected/conflict',dict(http=code,result=row),
                 row.get('status') in ['rejected','conflict'],'http_sector_collision.json')
        r.expect('RLS_owner_A_observer_after_B',f"select json_build_object('owner',owner_id,'number',number,'name',name) from sectors where id={quote(fid(105))};",dict(owner=fid(1),number=11,name='FICTICIO QA Sector 11'))
        code,foreign_changes=r.http('/rest/v1/rpc/sync_pull',dict(after_cursor=0,page_size=200),2)
        foreign=[c for c in foreign_changes if c['aggregate_id']==fid(105)]
        r.record('RLS_HTTP_B_no_foreign_receipt','ningún cambio del sector A',dict(http=code,changes=foreign),
                 code==200 and not foreign,'http_sector_collision.json; runtime-results.json')
        p=r.sql('RLS_direct_foreign_relation',f"insert into soil_measurements(id,owner_id,sector_id,ph,measured_at) values({quote(fid(699))},{quote(fid(2))},{quote(fid(101))},6.5,{quote(STAMP)});",2,check=False)
        r.record('RLS_direct_foreign_relation','denegación RLS',dict(exit=p.returncode,error=sanitize(p.stderr)),
                 p.returncode!=0 and '23503' in p.stderr and 'productive_sector_owner_mismatch' in p.stderr,'sql/'+f'{r.counter:03d}_RLS_direct_foreign_relation.sql')
        r.expect('RLS_foreign_relation_observer',f"select count(*) from soil_measurements where id={quote(fid(699))};",0,2)
        # Actual HTTP authenticated collisions for every root handler, with
        # an administrative observer comparing complete A rows before/after.
        reminder=dict(id=fid(720),sector_id=fid(101),title='FICTICIO',scheduled_at=STAMP,status='scheduled',updated_at=STAMP)
        r.push('HTTP_prep_reminder',operation(18000,'reminder',reminder))
        attacks=[('sector','sectors',sector(105,77)),
          ('agriculturalSeason','agricultural_seasons',season(301,201)),
          ('customCrop','custom_crops',crop(303,'intruso')),
          ('sectorCropAssignment','crop_seasons',assignment(401,201,302,304)),
          ('labor','labors',labor(501,parent=201,season_n=302,assignment_n=402)),
          ('irrigationConfig','sector_irrigation_configs',config|dict(sector_id=fid(201))),
          ('reminder','reminders',reminder|dict(sector_id=fid(201),title='FICTICIO intruso'))]
        for index,(kind,table,data) in enumerate(attacks):
            before=r.json_sql('HTTP_before_'+kind,f"select to_jsonb(t) from {table} t where id={quote(data['id'])};")
            attack=operation(18100+index,kind,data,'update',1)
            code,response=r.http('/rest/v1/rpc/sync_push',dict(operations=[attack]),2)
            (HERE/('http-collision-'+kind+'.json')).write_text(json.dumps(dict(request=attack,http=code,response=response),indent=2))
            row=response.get('results',[{}])[0]
            r.record('HTTP_collision_'+kind,'HTTP200 rejected operation_invalid',dict(http=code,row=row),code==200 and row.get('status')=='rejected' and row.get('error_code')=='operation_invalid','http-collision-'+kind+'.json')
            after=r.json_sql('HTTP_after_'+kind,f"select to_jsonb(t) from {table} t where id={quote(data['id'])};")
            r.record('HTTP_intact_'+kind,before,after,before==after,'logs/runtime-results.json')
            r.expect('HTTP_no_ack_'+kind,f"select json_build_object('receipt',(select count(*) from sync_operations where operation_id={quote(attack['operation_id'])}),'change',(select count(*) from sync_changes where aggregate_id={quote(data['id'])}));",dict(receipt=0,change=0),2)
        for index,(name,table,data) in enumerate([
            ('production','production_records',labor(530,'harvest',201,302,402)|dict(production=harvest['production']|dict(labor_id=fid(530),crop_id=fid(304)))),
            ('irrigation','irrigation_records',labor(531,'irrigation',201,302,402)|dict(irrigation=water['irrigation']|dict(labor_id=fid(531),sector_id=fid(201),config_id=None,config_version=None))) ]):
            child_id=data[name]['id'];before=r.json_sql('HTTP_child_before_'+name,f"select to_jsonb(t) from {table} t where id={quote(child_id)};")
            attack=operation(18200+index,'labor',data)
            code,response=r.http('/rest/v1/rpc/sync_push',dict(operations=[attack]),2)
            row=response.get('results',[{}])[0]
            r.record('HTTP_child_collision_'+name,'HTTP200 rejected',dict(http=code,row=row),code==200 and row.get('status')=='rejected','logs/runtime-results.json')
            after=r.json_sql('HTTP_child_after_'+name,f"select to_jsonb(t) from {table} t where id={quote(child_id)};")
            r.record('HTTP_child_intact_'+name,before,after,before==after,'logs/runtime-results.json')
            r.expect('HTTP_child_atomic_'+name,f"select json_build_object('root',(select count(*) from labors where id={quote(data['id'])}),'receipt',(select count(*) from sync_operations where operation_id={quote(attack['operation_id'])}),'change',(select count(*) from sync_changes where aggregate_id={quote(data['id'])}));",dict(root=0,receipt=0,change=0),2)
        # Concurrencia real con barrera y evidencia de bloqueo de índice/transactionid.
        r.concurrent('CONCURRENT_same_number',operation(17001,'sector',sector(110,30)),operation(17002,'sector',sector(111,30)))
        r.expect('CONCURRENT_one_number_row','select count(*) from sectors where number=30;',1)
        repeated=operation(17003,'sector',sector(112,31))
        r.concurrent('CONCURRENT_same_operation',repeated,repeated,same_operation=True)
        r.expect('CONCURRENT_one_operation_receipt',f"select count(*) from sync_operations where operation_id={quote(fid(17003))};",1)
        r.expect('CONCURRENT_one_operation_change',f"select count(*) from sync_changes where aggregate_id={quote(fid(112))};",1)
        # 113 labores: cinco lotes de hasta 25, filtros/cursores de sync_pull reales.
        for offset in range(0,113,25):
            batch=[operation(20000+i,'labor',labor(1000+i)|dict(notes=f'FICTICIO QA histórico {i:03d}'))
                   for i in range(offset,min(offset+25,113))]
            (HERE/f'batch_{offset:03d}.json').write_text(json.dumps(dict(operations=batch),indent=2))
            response=r.json_sql('HISTORY_batch_'+str(offset),'select sync_push('+quote(json.dumps(batch))+'::jsonb);',1)
            statuses=[row['status'] for row in response['results']]
            r.record('HISTORY_batch_'+str(offset),'todos applied, lote <=25',dict(count=len(batch),statuses=statuses),
                     all(s=='applied' for s in statuses),'batch_'+f'{offset:03d}.json')
        r.expect('HISTORY_113_business_rows',f"select count(*) from labors where id>={quote(fid(1000))} and id<={quote(fid(1112))};",113)
        # Experimental upper-limit coverage: exceed 200 persisted changes.
        for offset in range(0,100,25):
            batch=[operation(24000+i,'labor',labor(2000+i)) for i in range(offset,offset+25)]
            response=r.json_sql('PULL_upper_seed_'+str(offset),'select sync_push('+quote(json.dumps(batch))+'::jsonb);',1)
            r.record('PULL_upper_seed_'+str(offset),'25 applied',response,all(row['status']=='applied' for row in response['results']),'logs/runtime-results.json')
        cursor=0;changes=[];sizes=[];pages=[]
        while True:
            page=r.json_sql('PULL_page_'+str(len(sizes)),f"select coalesce(json_agg(t),'[]'::json) from sync_pull({cursor},37) t;",1)
            sizes.append(len(page));pages.append(page)
            if not page: break
            changes.extend(page);cursor=page[-1]['change_seq']
            if len(sizes)>20: raise RuntimeError('Cursor no progresa')
        (r.logs/'pull-pages.json').write_text(json.dumps(pages,indent=2))
        seqs=[c['change_seq'] for c in changes]
        business=[c for c in changes if c['aggregate_id']>=fid(1000) and c['aggregate_id']<=fid(1112) and c['aggregate_type']=='labor']
        r.record('PULL_over_100_unique','113 labores, secuencias crecientes sin duplicados',
                 dict(labors=len(business),rows=len(changes),page_sizes=sizes,cursor=cursor),
                 len(business)==113 and seqs==sorted(set(seqs)),'logs/pull-pages.json')
        r.record('PULL_experimental_over_200','more than200 persisted changes',len(changes),len(changes)>200,'logs/pull-pages.json')
        first=r.json_sql('PULL_repeat_page','select coalesce(json_agg(t),\'[]\'::json) from sync_pull(0,37) t;',1)
        r.record('PULL_same_cursor_stable','primera página idéntica',dict(identical=first==pages[0]),first==pages[0],'logs/pull-pages.json')
        for size,wanted in [(0,1),(-5,1),(999,200)]:
            count=r.json_sql('PULL_limit_'+str(abs(size)),f'select count(*) from sync_pull(0,{size});',1)
            expected=min(wanted,len(changes))
            r.record('PULL_limit_'+str(size),expected,count,count==expected,'run_runtime.py')
        # Sólo pruebas de fuente remota, sin inventar timeline/export remotos.
        before=r.json_sql('HISTORY_before_retire',f"select json_build_object('labors',(select count(*) from labors where sector_id={quote(fid(101))}),'soil',(select count(*) from soil_measurements where sector_id={quote(fid(101))}),'production',(select count(*) from production_records where sector_id={quote(fid(101))}),'irrigation',(select count(*) from irrigation_records where sector_id={quote(fid(101))}),'seasons',(select count(*) from agricultural_seasons where sector_id={quote(fid(101))}),'assignments',(select count(*) from crop_seasons where sector_id={quote(fid(101))}));",1)
        r.push('HISTORY_retire_parent',operation(30001,'sector',sector(101,1)|dict(deleted_at=STAMP),'delete',1))
        after=r.json_sql('HISTORY_after_retire',f"select json_build_object('labors',(select count(*) from labors where sector_id={quote(fid(101))}),'soil',(select count(*) from soil_measurements where sector_id={quote(fid(101))}),'production',(select count(*) from production_records where sector_id={quote(fid(101))}),'irrigation',(select count(*) from irrigation_records where sector_id={quote(fid(101))}),'seasons',(select count(*) from agricultural_seasons where sector_id={quote(fid(101))}),'assignments',(select count(*) from crop_seasons where sector_id={quote(fid(101))}));",1)
        r.record('HISTORY_sources_retained',before,after,before==after,'sql/HISTORY_before_retire; sql/HISTORY_after_retire')
        all_after=[];after_cursor=0
        while True:
            page=r.json_sql('HISTORY_pull_after_retire_'+str(after_cursor),f"select coalesce(json_agg(t),'[]'::json) from sync_pull({after_cursor},200) t;",1)
            if not page: break
            all_after.extend(page);after_cursor=page[-1]['change_seq']
        historical=[c for c in all_after if fid(1000)<=c['aggregate_id']<=fid(1112) and c['aggregate_type']=='labor']
        tombstones=[c for c in all_after if c['aggregate_id']==fid(101) and c['mutation_kind']=='delete']
        r.record('HISTORY_pull_retired_with_113','113 labores y tombstone',dict(labors=len(historical),tombstones=len(tombstones)),
                 len(historical)==113 and len(tombstones)==1,'logs/runtime-results.json')
        r.expect('HISTORY_tombstone_payload',f"select (payload->>'deleted_at') is not null from sync_changes where aggregate_id={quote(fid(101))} and mutation_kind='delete';",True)
        r.push('HISTORY_no_new_labor_retired',operation(30002,'labor',labor(511)),'rejected')
        # Lectura HTTP autenticada además de SQL: cada cliente sólo sus filas.
        for owner,table in [(1,'labors'),(2,'labors'),(1,'sectors'),(2,'sectors')]:
            code,rows=r.http('/rest/v1/'+table+'?select=id,owner_id',owner=owner)
            good=code==200 and all(row['owner_id']==fid(owner) for row in rows)
            r.record(f'HTTP_RLS_owner_{owner}_{table}','HTTP 200 sólo owner propio',dict(http=code,rows=len(rows)),good,'logs/runtime-results.json')
    finally:
        r.cleanup()
        (HERE/'fixtures.json').write_text(json.dumps(r.fixtures,indent=2,ensure_ascii=False))
        summary=dict(total=len(r.results),passed=sum(x['passed'] for x in r.results),
                     failed=sum(not x['passed'] for x in r.results))
        (r.logs/'runtime-summary.json').write_text(json.dumps(summary,indent=2))
        print('SUMMARY '+json.dumps(summary),flush=True)
    raise SystemExit(1 if any(not x['passed'] for x in r.results) else 0)


if __name__ == '__main__':
    main()
