#!/usr/bin/env python3
"""Local-only disposable CI gate. Never reads .env or touches another project."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import socket
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'backend/supabase/tests/runtime'
sys.path.insert(0, str(SOURCE))
from run_contracts import sanitize  # No connection is made during import.


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--mode', choices=['fresh', 'incremental'], default='fresh')
    parser.add_argument('--output', type=Path, default=ROOT / 'build/supabase-local-gate')
    parser.add_argument('--cli', default='supabase')
    parser.add_argument('--flutter', default='flutter')
    args = parser.parse_args()
    output = args.output.resolve() / args.mode
    output.mkdir(parents=True, exist_ok=True)
    project = f'agrocampo-ci-plan-{os.getpid()}'
    work = Path('/tmp') / project
    commands = []
    started = False
    connection_ready = False
    env = os.environ | {'SUPABASE_CLI': args.cli, 'AGROCAMPO_TEST_PROJECT': project,
                        'AGROCAMPO_TEST_WORK': str(work), 'AGROCAMPO_TEST_OUTPUT': str(output / 'runtime')}

    def run(name, command, *, cwd=ROOT, source=None, expected=0):
        result = subprocess.run(command, cwd=cwd, env=env, input=source, capture_output=True, text=True)
        log = output / (name + '.log')
        log.write_text(sanitize(result.stdout + result.stderr) + f'\nexit={result.returncode}\n')
        commands.append({'name': name, 'command': sanitize(' '.join(command)),
                         'exit': result.returncode, 'expected_exit': expected, 'log': str(log.relative_to(output))})
        (output / 'commands.json').write_text(json.dumps(commands, indent=2))
        print(f'{name}: exit={result.returncode} (expected {expected}); {log}', flush=True)
        if (expected == 0 and result.returncode != 0) or (expected != 0 and result.returncode == 0):
            raise RuntimeError(f'{name} failed; see {log}')
        return result

    psql = ['psql', '-h', '127.0.0.1', '-p', '54422', '-d', 'postgres', '-U', 'postgres', '-w', '-X', '-qAt', '-v', 'ON_ERROR_STOP=1', '-v', 'VERBOSITY=verbose']
    failure = None
    try:
        cli = run('cli-version', [args.cli, '--version']).stdout.strip()
        sdk = json.loads(run('flutter-version', [args.flutter, '--version', '--machine']).stdout)
        if cli != '2.117.0' or sdk['frameworkVersion'] != '3.47.0' or sdk['dartSdkVersion'] != '3.13.0':
            raise RuntimeError('Required: Supabase2.117.0 Flutter3.47.0 Dart3.13.0')
        for command in [['docker', 'ps', '-a', '--format', '{{.Names}}'], ['docker', 'volume', 'ls', '--format', '{{.Name}}']]:
            if any(project in line for line in subprocess.check_output(command, text=True).splitlines()):
                raise RuntimeError('Preexisting project; refusing start')
        for port in [54421, 54422]:
            with socket.socket() as connection:
                if connection.connect_ex(('127.0.0.1', port)) == 0:
                    raise RuntimeError(f'Occupied local port {port}; refusing start')
        if work.exists():
            raise RuntimeError('Preexisting workdir; refusing overwrite')
        shutil.copytree(ROOT / 'backend/supabase', work / 'supabase', ignore=shutil.ignore_patterns('.temp', '.branches', '__pycache__'))
        (work / '.agrocampo-ci-owned').write_text(project)
        (output / 'owned-project.json').write_text(json.dumps({'project': project, 'work': str(work)}, indent=2))
        config = work / 'supabase/config.toml'
        config.write_text(config.read_text().replace('project_id = "agrocampo-local"', f'project_id = "{project}"'))
        migrations = sorted((ROOT / 'backend/supabase/migrations').glob('*.sql'))
        if args.mode == 'incremental':
            for file in (work / 'supabase/migrations').glob('*.sql'):
                if int(file.name.split('_')[0]) > 22:
                    file.unlink()
        started = True
        run('start', [args.cli, '--workdir', str(work), 'start', '--exclude',
                      'realtime,postgres-meta,studio,edge-runtime,logflare,vector,supavisor,imgproxy,mailpit'])
        # Initialization pins image, localhost endpoints and PG connection env.
        os.environ.update({key: env[key] for key in ['SUPABASE_CLI', 'AGROCAMPO_TEST_PROJECT', 'AGROCAMPO_TEST_WORK', 'AGROCAMPO_TEST_OUTPUT']})
        import importlib
        import run_contracts
        importlib.reload(run_contracts)
        r = run_contracts.Run(args.cli)
        env.update(r.env)
        for key in ['PGSERVICE', 'PGSERVICEFILE', 'PGOPTIONS']:
            env.pop(key, None)
        connection_ready = True
        versions = json.loads(run('postgres-version', psql, source="select json_build_object('version',version(),'migrations',(select json_agg(version order by version) from supabase_migrations.schema_migrations));").stdout)
        (output / 'server-versions.json').write_text(json.dumps(versions, indent=2))
        if run('empty-initial-fixtures', psql, source="select count(*) from auth.users;").stdout.strip() != '0':
            raise RuntimeError('Preexisting auth fixtures; refusing tests')
        if args.mode == 'incremental':
            seed = (SOURCE / 'prepare.sql').read_text()
            run('incremental-users', psql, source=seed)
            for index, (kind, payload) in enumerate([
                ('sector', run_contracts.sector(101, 1)),
                ('agriculturalSeason', run_contracts.season(301, 101)),
                ('customCrop', run_contracts.crop(303, 'A')),
                ('sectorCropAssignment', run_contracts.assignment(401, 101, 301, 303)),
                ('labor', run_contracts.labor(501))]):
                result = r.push('incremental-seed-' + kind, run_contracts.operation(91000 + index, kind, payload))
                if result['status'] != 'applied':
                    raise RuntimeError('Invalid incremental seed')
            snapshot_sql = "select json_build_object('sector',(select to_jsonb(s) from sectors s where id='"+run_contracts.fid(101)+"'),'labor',(select to_jsonb(s) from labors s where id='"+run_contracts.fid(501)+"'),'receipts',(select json_agg(s order by operation_id) from sync_operations s),'changes',(select json_agg(s order by change_seq) from sync_changes s));"
            before = json.loads(run('incremental-before', psql, source=snapshot_sql).stdout)
            (output / 'incremental-before.json').write_text(json.dumps(before, indent=2))
            for file in migrations:
                number = int(file.name.split('_')[0])
                if number <= 22:
                    continue
                if number == 24:
                    invalid_id = run_contracts.fid(698)
                    run('legacy-invalid-fixture', psql, source=f"insert into soil_measurements(id,owner_id,sector_id,ph,measured_at) values('{invalid_id}','{run_contracts.fid(2)}','{run_contracts.fid(101)}',6.5,now());")
                    rejected = run('legacy-invalid-diagnostic', psql + ['-1', '-f', str(file)], expected=3)
                    if '23503' not in rejected.stderr or 'soil_measurements_sector_id_context_fk' not in rejected.stderr:
                        raise RuntimeError('Migration failed for a different reason')
                    unchanged = run('legacy-invalid-retained', psql, source=f"select count(*) from soil_measurements where id='{invalid_id}';").stdout.strip()
                    if unchanged != '1':
                        raise RuntimeError('Invalid legacy fixture was silently altered')
                    run('legacy-invalid-fixture-cleanup', psql, source=f"delete from soil_measurements where id='{invalid_id}';")
                if number == 27:
                    invalid_labor = run_contracts.fid(699)
                    run('category-ambiguous-fixture', psql, source=f"insert into labors(id,owner_id,sector_id,type,occurred_at) values('{invalid_labor}','{run_contracts.fid(1)}','{run_contracts.fid(101)}','apiary',now());")
                    rejected = run('category-ambiguous-diagnostic', psql + ['-1', '-f', str(file)], expected=3)
                    if 'labor_category_backfill_ambiguous' not in rejected.stderr:
                        raise RuntimeError('Category backfill failed for a different reason')
                    if run('category-ambiguous-retained', psql, source=f"select count(*) from labors where id='{invalid_labor}' and domain_category is null;").stdout.strip() != '1':
                        raise RuntimeError('Ambiguous legacy category was silently changed')
                    run('category-ambiguous-fixture-cleanup', psql, source=f"delete from labors where id='{invalid_labor}';")
                run('apply-' + file.stem, psql + ['-1', '-f', str(file)])
                version, name = file.stem.split('_', 1)
                run('record-' + version, psql, source=f"insert into supabase_migrations.schema_migrations(version,name,statements) values('{version}','{name}',ARRAY[]::text[]);")
            after = json.loads(run('incremental-after', psql, source=snapshot_sql).stdout)
            (output / 'incremental-after.json').write_text(json.dumps(after, indent=2))
            expected = json.loads(json.dumps(before))
            expected['labor']['domain_category'] = 'crop'
            for change in expected['changes']:
                if change['aggregate_type'] == 'labor':
                    change['payload']['domain_category'] = 'crop'
            if after != expected:
                raise RuntimeError('Unexpected legacy data change; compare incremental snapshots')
            r.cleanup()
        tap_probe = output / 'tap-failure-probe.sql'
        tap_probe.write_text("begin;select plan(1);select is(1,2,'deliberate harness failure must fail gate');select * from finish();rollback;\n")
        run('tap-failure-not-hidden', [args.cli, '--workdir', str(work), 'test', 'db', str(tap_probe)], expected=1)
        run('pgTAP', [args.cli, '--workdir', str(work), 'test', 'db', str(ROOT / 'backend/supabase/tests/database')])
        run('http-contracts', [sys.executable, str(SOURCE / 'run_contracts.py')])
        # A distinct output keeps contract and concurrency results independently reviewable.
        env['AGROCAMPO_TEST_OUTPUT'] = str(output / 'concurrency')
        run('concurrency', [sys.executable, str(SOURCE / 'run_concurrency.py')])
        env['AGROCAMPO_TEST_OUTPUT'] = str(output / 'relationships-concurrency')
        run('relationships-concurrency', [sys.executable, str(SOURCE / 'run_relationship_races.py')])
        status = json.loads(subprocess.check_output([args.cli, '--workdir', str(work), 'status', '--output', 'json'], text=True))
        run('required-E2E', [args.flutter, 'test', '--no-pub', '--reporter', 'expanded',
            '--dart-define=SUPABASE_LOCAL_E2E=true', '--dart-define=SUPABASE_URL='+r.api,
            '--dart-define=SUPABASE_ANON_KEY='+status['ANON_KEY'],
            'test/modules/territory/territory_sync_v2_local_e2e_test.dart',
            'test/modules/crop_cycles/seasons_crops_v2_local_e2e_test.dart',
            'test/integration/labors_production_v2_local_e2e_test.dart',
            'test/integration/soil_apiary_v2_local_e2e_test.dart'], cwd=ROOT / 'backend')
        if 'All tests passed!' not in (output/'required-E2E.log').read_text() or 'Skipped' in (output/'required-E2E.log').read_text():
            raise RuntimeError('Mandatory E2E did not execute every test')
    except Exception as error:
        failure = str(error)
        print(f'FAILED: {failure}', file=sys.stderr, flush=True)
    finally:
        if started and (work / '.agrocampo-ci-owned').read_text() == project:
            # SQL deletes only known fictitious owner IDs/emails, in dependency order.
            cleanup = (SOURCE / 'cleanup_all_fixtures.sql').read_text()
            try:
                if not connection_ready:
                    raise RuntimeError('Stack not initialized; no SQL cleanup attempted')
                run('cleanup-fixtures', psql, source=cleanup)
                clean = run('verify-no-fixtures', psql, source="select json_build_object('users',(select count(*) from auth.users),'owned_rows',(select count(*) from sectors));").stdout.strip()
                if json.loads(clean) != {'users': 0, 'owned_rows': 0}:
                    raise RuntimeError('Fixtures remain')
                inventory_sql = """create function pg_temp.owner_fixture_inventory() returns jsonb language plpgsql as $$ declare t record; n bigint; result jsonb := '{}'::jsonb; begin for t in select table_name from information_schema.columns where table_schema='public' and column_name='owner_id' loop execute format('select count(*) from public.%I',t.table_name) into n; result := result || jsonb_build_object(t.table_name,n); end loop; return result; end $$; select pg_temp.owner_fixture_inventory();"""
                inventory = json.loads(run('verify-all-owner-tables-empty', psql, source=inventory_sql).stdout)
                (output/'fixture-inventory.json').write_text(json.dumps(inventory,indent=2))
                if any(inventory.values()):
                    raise RuntimeError('Owned business rows remain')
            except Exception as error:
                failure = failure or str(error)
            try:
                run('stop', [args.cli, '--workdir', str(work), 'stop', '--no-backup'])
                names = subprocess.check_output(['docker','ps','-a','--format','{{.Names}}'],text=True).splitlines()
                volumes = subprocess.check_output(['docker','volume','ls','--format','{{.Name}}'],text=True).splitlines()
                if any(project in name for name in names+volumes):
                    raise RuntimeError('Task containers/volumes remain')
                (output/'cleanup.json').write_text(json.dumps({'project':project,'containers':0,'volumes':0,'fixture_verification':clean if 'clean' in locals() else None},indent=2))
            except Exception as error:
                failure = failure or str(error)
        (output/'summary.json').write_text(json.dumps({'mode':args.mode,'project':project,'passed':failure is None,'failure':failure,'commands':len(commands)},indent=2))
    return 1 if failure else 0


if __name__ == '__main__':
    sys.exit(main())
