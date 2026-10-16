#!/usr/bin/env python3
"""Recover only this gate's disposable stack when its primary finally is interrupted."""
import argparse
import json
from pathlib import Path
import re
import subprocess


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--cli', default='supabase')
    args = parser.parse_args()
    state = args.output / 'owned-project.json'
    if not state.exists():
        print('No disposable stack was registered by this gate.')
        return 0
    ownership = json.loads(state.read_text())
    project = ownership['project']
    work = Path(ownership['work'])
    if not re.fullmatch(r'agrocampo-ci-plan-[0-9]+', project) or work != Path('/tmp') / project:
        raise RuntimeError('Unrecognized project; refusing cleanup')
    if (work / '.agrocampo-ci-owned').read_text() != project:
        raise RuntimeError('Ownership marker mismatch; refusing cleanup')
    if f'project_id = "{project}"' not in (work / 'supabase/config.toml').read_text():
        raise RuntimeError('Project configuration mismatch; refusing cleanup')
    result = subprocess.run([args.cli, '--workdir', str(work), 'stop', '--no-backup'])
    if result.returncode:
        return result.returncode
    containers = subprocess.check_output(['docker', 'ps', '-a', '--format', '{{.Names}}'], text=True).splitlines()
    volumes = subprocess.check_output(['docker', 'volume', 'ls', '--format', '{{.Name}}'], text=True).splitlines()
    remaining = [name for name in containers + volumes if name.endswith('_' + project)]
    if remaining:
        raise RuntimeError('Disposable resources remain: ' + ', '.join(remaining))
    (args.output / 'always-cleanup.json').write_text(json.dumps({
        'project': project, 'containers': 0, 'volumes': 0,
        'method': 'owned workdir stop --no-backup',
    }, indent=2))
    print(f'{project}: zero disposable containers and volumes.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
