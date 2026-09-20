#!/usr/bin/env python3
"""Bounded-output helpers for one-at-a-time OpenCCU-Base migrations.

No commits, pushes, PR creation or merges. See docs/base-patch-migration.md.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile


PACKAGE = Path('buildroot-external/package/openccu-base')
INDEX = Path('docs/base-patch-migration/index.json')
STATE = Path('docs/base-patch-migration/state.json')
SHA = re.compile(r'[0-9a-f]{40}')
PATCH = re.compile(r'[0-9]{4}-[^/]+\.patch')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def output(value):
    print(json.dumps(value, sort_keys=True))


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    # Atomic replacement: an interrupted write must not leave a valid-looking receipt.
    with tempfile.NamedTemporaryFile(mode='w', dir=path.parent, delete=False) as f:
        json.dump(value, f, indent=2, sort_keys=True)
        f.write('\n')
        temporary = f.name
    os.replace(temporary, path)


def git(repo, *args):
    return subprocess.check_output(['git', '-C', str(repo), *args], text=True).strip()


def run(command, log, env=None, cwd=None):
    with log.open('a') as stream:
        stream.write('$ ' + ' '.join(map(str, command)) + '\n')
        stream.flush()
        result = subprocess.run(list(map(str, command)), stdout=stream,
                                stderr=subprocess.STDOUT, env=env, cwd=cwd)
    require(result.returncode == 0,
            f'command failed ({result.returncode}); details: {log}')


def pin(repo):
    text = (repo / PACKAGE / 'openccu-base.mk').read_text()
    matches = re.findall(r'^OPENCCU_BASE_VERSION = (\S+)$', text, re.M)
    require(len(matches) == 1, 'ambiguous or missing Base pin')
    require(SHA.fullmatch(matches[0]), 'migration requires a full commit pin')
    return matches[0]


def series(repo):
    directory = repo / PACKAGE / 'rootfs-patches'
    names = [s for s in (directory / 'series').read_text().splitlines()
             if s and not s.startswith('#')]
    require(all(PATCH.fullmatch(s) for s in names), 'unsafe series entry')
    require(len(set(names)) == len(names), 'duplicate series entry')
    require(set(names) == {p.name for p in directory.glob('*.patch')},
            'series and patch files differ')
    return directory, names


def inventory(repo):
    directory, names = series(repo)
    entries = []
    for name in names:
        lines = (directory / name).read_text(encoding='latin1').splitlines()
        paths = set()
        for line in lines:
            if line.startswith(('--- a/', '+++ b/')):
                path = line[6:].split('\t')[0]
                require(not PurePosixPath(path).is_absolute()
                        and '..' not in PurePosixPath(path).parts,
                        f'unsafe path in {name}')
                paths.add(path)
        require(paths, f'no file headers: {name}')
        entries.append({'patch': name, 'sha256': digest(directory / name),
                        'files': sorted(paths),
                        'added': sum(s.startswith('+') and not s.startswith('+++') for s in lines),
                        'removed': sum(s.startswith('-') and not s.startswith('---') for s in lines)})
    return {'schema': 1, 'series_sha256': digest(directory / 'series'), 'patches': entries}


def select(repo, identifier):
    matches = [p for p in inventory(repo)['patches']
               if identifier in (p['patch'], p['patch'][:4])]
    require(len(matches) == 1, f'patch not uniquely identified: {identifier}')
    return matches[0]


def hashes(repo):
    result = {}
    for line in (repo / PACKAGE / 'openccu-base.hash').read_text().splitlines():
        if not line or line.startswith('#'):
            continue
        kind, value, name = line.split()
        require(kind == 'sha256' and re.fullmatch('[0-9a-f]{64}', value),
                'unsupported hash entry')
        require(name not in result, f'duplicate hash: {name}')
        result[name] = value
    return result


def extract(archive, destination, commit):
    """Extract a verified archive, allowing runtime symlinks but no traversal."""
    prefix = f'openccu-base-{commit}'
    with tarfile.open(archive, 'r:gz') as tar:
        entries = []
        seen = set()
        for member in tar.getmembers():
            parts = PurePosixPath(member.name).parts
            require(parts and parts[0] == prefix and '..' not in parts,
                    f'unsafe archive path: {member.name}')
            if len(parts) == 1:
                require(member.isdir(), 'invalid archive root')
                continue
            path = PurePosixPath(*parts[1:])
            require(path not in seen, f'duplicate archive path: {path}')
            require(member.isfile() or member.isdir() or member.issym(),
                    f'unsupported archive member: {path}')
            seen.add(path)
            entries.append((member, path))
        links = {p for m, p in entries if m.issym()}
        require(not any(parent in links for _, p in entries for parent in p.parents),
                'archive writes through a symlink')
        destination.mkdir()
        for member, relative in entries:
            target = destination / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            if member.isdir():
                target.mkdir(exist_ok=True)
            elif member.issym():
                target.symlink_to(member.linkname)
            else:
                with tar.extractfile(member) as source, target.open('wb') as dest:
                    shutil.copyfileobj(source, dest)
                target.chmod(member.mode & 0o777)


def manifest(root):
    result = {}
    for current, directories, files in os.walk(root, followlinks=False):
        for name in directories + files:
            path = Path(current) / name
            mode = path.lstat().st_mode
            kind = 'link' if stat.S_ISLNK(mode) else 'file' if stat.S_ISREG(mode) else 'dir'
            require(kind == 'dir' and stat.S_ISDIR(mode) or kind != 'dir',
                    f'unsupported filesystem entry: {path}')
            result[path.relative_to(root).as_posix()] = {
                'type': kind, 'mode': stat.S_IMODE(mode),
                'value': os.readlink(path) if kind == 'link' else digest(path) if kind == 'file' else None}
    return result


def verify_source_git(source, base_repo, commit):
    """Bind archive contents to the merge commit, not merely its directory name."""
    tree = subprocess.check_output(['git', '-C', str(base_repo), 'ls-tree', '-rz', commit])
    expected = {}
    for entry in tree.split(b'\0'):
        if not entry:
            continue
        metadata, path = entry.split(b'\t', 1)
        mode, kind, sha = metadata.decode().split()
        require(kind == 'blob', 'submodules require separate archive verification')
        expected[os.fsdecode(path)] = (mode, sha)
    actual = {}
    for path, entry in manifest(source).items():
        if entry['type'] == 'dir':
            continue
        file = source / path
        data = os.fsencode(os.readlink(file)) if file.is_symlink() else file.read_bytes()
        mode = '120000' if file.is_symlink() else '100755' if entry['mode'] & 0o111 else '100644'
        actual[path] = (mode, hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest())
    require(actual == expected, 'archive contents do not match the Base merge commit')


def cache_directory(repo, supplied):
    path = Path(supplied).resolve() if supplied else Path(
        git(repo, 'rev-parse', '--absolute-git-dir')) / 'base-patch-migration'
    path.mkdir(parents=True, exist_ok=True)
    return path


def environment():
    env = os.environ.copy()
    for variable, default in [('CMAKE', 'cmake'), ('PYTHON', sys.executable), ('TCLSH', 'tclsh')]:
        executable = shutil.which(env.get(variable, default))
        require(executable, f'{variable} executable not found')
        env[variable] = str(Path(executable).resolve())
    env['LC_ALL'] = 'C'
    return env


def validate(repo, args):
    directory, names = series(repo)
    commit = args.candidate_commit or pin(repo)
    require(SHA.fullmatch(commit), 'invalid candidate commit')
    require(bool(args.candidate_commit) == bool(args.candidate_sha256),
            'candidate commit and SHA256 must be supplied together')
    require(not args.skip_patch or args.candidate_commit,
            '--skip-patch is only allowed with a candidate archive')
    skip = select(repo, args.skip_patch)['patch'] if args.skip_patch else None
    expected = args.candidate_sha256 or hashes(repo)[f'openccu-base-{commit}-git4.tar.gz']
    require(digest(args.archive) == expected, 'source archive hash mismatch')
    env = environment()
    cache = cache_directory(repo, args.cache)
    work = Path(tempfile.mkdtemp(prefix='run-', dir=cache))
    log = work / 'validation.log'
    # Cached staging is opt-in, tied to an immutable toolchain identity supplied
    # by the caller. Patch application and regression tests are NEVER cached.
    require(not args.reuse_stage or args.toolchain_id,
            '--reuse-stage requires --toolchain-id (e.g. container image digest)')
    identity = {'archive': expected, 'driver': digest(directory / 'stage_validation_rootfs.sh'),
                'toolchain': args.toolchain_id,
                'executables': {key: [env[key], digest(env[key])] for key in ('CMAKE', 'PYTHON', 'TCLSH')}}
    key = hashlib.sha256(json.dumps(identity, sort_keys=True).encode()).hexdigest()
    stage_cache = cache / ('stage-' + key)
    receipt = stage_cache / 'receipt.json'
    reused = False
    if args.reuse_stage and receipt.is_file():
        saved = json.loads(receipt.read_text())
        require(saved['identity'] == identity, 'staging identity mismatch')
        require(saved['source'] == manifest(stage_cache / 'source')
                and saved['rootfs'] == manifest(stage_cache / 'rootfs'),
                f'cached staging was modified; use a fresh --cache directory: {stage_cache}')
        stage = stage_cache
        reused = True
    else:
        stage = work / 'stage'
        stage.mkdir()
        extract(args.archive, stage / 'source', commit)
        run(['bash', directory / 'stage_validation_rootfs.sh', stage / 'source', stage / 'rootfs'], log, env)
        if args.reuse_stage:
            write_json(stage / 'receipt.json', {'identity': identity,
                       'source': manifest(stage / 'source'), 'rootfs': manifest(stage / 'rootfs')})
            # Do not replace an existing cache or race another writer.
            require(not stage_cache.exists(), f'cache already exists: {stage_cache}')
            stage.rename(stage_cache)
            stage = stage_cache
    for name, value in hashes(repo).items():
        if name.startswith('licenses/'):
            require(digest(stage / 'source' / name) == value, f'license hash changed: {name}')
    # Fail rather than silently skip future package-level source patches.
    require(not list((repo / PACKAGE).glob('*.patch'))
            and not (repo / 'buildroot-external/patches/openccu-base').exists(),
            'Base package patches need the Buildroot preparation path; use make check-openccu-base')
    for test in ('test_devicetypes_assets.py', 'test_version_headers.py'):
        run([env['PYTHON'], repo / 'scripts/testcases/build' / test, stage / 'source'], log, env)
    command = ['bash', directory / 'validate_patches.sh', stage / 'rootfs', stage / 'source',
               '--result-dir', work / 'result']
    if skip:
        command.extend(['--skip-patch', skip])
    run(command, log, env)
    state = manifest(work / 'result')
    write_json(work / 'manifest.json', state)
    report = {'schema': 1, 'commit': commit, 'archive_sha256': expected,
              'inventory': inventory(repo), 'skip': skip, 'stage_identity': identity,
              'driver_sha256': digest(Path(__file__)),
              'checks': {str(path.relative_to(repo)): digest(path) for path in
                         sorted(list(directory.glob('*.sh'))
                                + list((repo / 'scripts/testcases/build').glob('*.py'))
                                + list((repo / 'scripts/testcases/security').glob('*.tcl')))},
              'manifest_sha256': digest(work / 'manifest.json')}
    write_json(work / 'report.json', report)
    output({'result': 'PASS', 'patches': len(names) - bool(skip), 'entries': len(state),
            'stage_reused': reused, 'report': str(work / 'report.json'), 'log': str(log)})


def compare(left, right):
    states = []
    for report in (left, right):
        data = json.loads(report.read_text())
        path = report.parent / 'manifest.json'
        require(digest(path) == data['manifest_sha256'], f'manifest changed: {path}')
        states.append(json.loads(path.read_text()))
    differences = sorted(k for k in states[0].keys() | states[1].keys()
                         if states[0].get(k) != states[1].get(k))
    require(not differences, f'{len(differences)} differing entries; first 10: {differences[:10]}')
    output({'result': 'IDENTICAL', 'entries': len(states[0])})


def archive(repo, args):
    require(SHA.fullmatch(args.commit), 'use a full commit SHA')
    expected_version = re.search(r'^BUILDROOT_VERSION=(\S+)$',
                                 (repo / 'Makefile').read_text(), re.M)
    actual_version = re.search(r'^export BR2_VERSION := (\S+)$',
                               (args.buildroot / 'Makefile').read_text(), re.M)
    require(expected_version and actual_version
            and expected_version[1] == actual_version[1], 'Buildroot version mismatch')
    require(re.search(r'^BR_FMT_VERSION_git\s*=\s*-git4\s*$',
                      (args.buildroot / 'package/pkg-download.mk').read_text(), re.M),
            'unsupported Buildroot Git archive format')
    require(git(args.base_repo, 'rev-parse', args.commit + '^{commit}') == args.commit,
            'Base commit is not available locally')
    cache = cache_directory(repo, args.cache)
    work = Path(tempfile.mkdtemp(prefix='archive-', dir=cache))
    download = work / 'download'
    name = f'openccu-base-{args.commit}-git4.tar.gz'
    env = os.environ.copy()
    env.update(BUILD_DIR=str(work / 'build'), BR_NO_CHECK_HASH_FOR=name, GIT='git', TAR='tar')
    (work / 'build').mkdir()
    run([args.buildroot.resolve() / 'support/download/dl-wrapper', '-q', '-c', args.commit,
         '-d', download, '-D', work, '-f', name, '-H', repo / PACKAGE / 'openccu-base.hash',
         '-n', f'openccu-base-{args.commit}', '-N', 'openccu-base', '-o', work / name,
         '-u', 'git+' + args.base_repo.resolve().as_uri()], work / 'archive.log', env,
        args.buildroot.resolve())
    output({'archive': str(work / name), 'sha256': digest(work / name),
            'commit': args.commit, 'log': str(work / 'archive.log')})


def merged_base(receipt):
    data = json.loads(receipt.read_text())
    require(data.get('merged') is True and data.get('merged_at'), 'Base PR is not merged')
    number = data['number']
    require(data.get('html_url') == f'https://github.com/OpenCCU/OpenCCU-Base/pull/{number}'
            and data['base']['repo']['full_name'] == 'OpenCCU/OpenCCU-Base'
            and data['base']['ref'] == 'main', 'unexpected Base PR repository or branch')
    require(SHA.fullmatch(data['merge_commit_sha']), 'invalid merge commit')
    return data


def cleanup(repo, args):
    require(not git(repo, 'status', '--porcelain'), 'cleanup requires a clean worktree')
    branch = git(repo, 'branch', '--show-current')
    require(branch and branch not in ('master', 'main'), 'create a dedicated cleanup branch first')
    selected = select(repo, args.patch)
    receipt = merged_base(args.merge_receipt)
    old, new = pin(repo), receipt['merge_commit_sha']
    state = json.loads((repo / STATE).read_text())
    require(not state.get('in_progress'), 'finish and record the preceding migration first')
    require(not any(item['patch'] == selected['patch'] for item in state['completed']),
            'selected patch is already recorded as completed')
    require(old != new, 'already pinned to this merge')
    require(git(args.base_repo, 'merge-base', old, new) == old,
            'merge commit must descend from the current pin')
    require(selected['patch'] in receipt.get('body', ''), 'Base PR does not name the selected patch')
    # Validate archive structure and license hashes before touching tracked files.
    with tempfile.TemporaryDirectory(prefix='openccu-cleanup-') as temp:
        source = Path(temp) / 'source'
        extract(args.archive, source, new)
        verify_source_git(source, args.base_repo, new)
        for name, value in hashes(repo).items():
            if name.startswith('licenses/'):
                require(digest(source / name) == value, f'license hash changed: {name}')
    directory, names = series(repo)
    workspace = directory / selected['patch'][:-6]
    require(workspace.is_dir() and not workspace.is_symlink(), 'missing or unsafe workspace')
    paths = [directory / selected['patch']] + list(workspace.rglob('*'))
    require(not any(p.is_symlink() for p in paths), 'symlink in patch workspace')
    # A clean worktree can contain ignored files. Never delete untracked payload.
    tracked = set(git(repo, 'ls-files').splitlines())
    require(all(p.relative_to(repo).as_posix() in tracked for p in paths if p.is_file()),
            'untracked file in patch workspace')
    archive_hash = digest(args.archive)
    mk = repo / PACKAGE / 'openccu-base.mk'
    hashfile = repo / PACKAGE / 'openccu-base.hash'
    oldname = f'openccu-base-{old}-git4.tar.gz'
    require(oldname in hashes(repo), 'current archive hash missing')
    newhash = '\n'.join(f'sha256  {archive_hash}  openccu-base-{new}-git4.tar.gz'
                        if s.split()[-1:] == [oldname] else s
                        for s in hashfile.read_text().splitlines()) + '\n'
    updated_mk = mk.read_text().replace(
        'OPENCCU_BASE_VERSION = ' + old, 'OPENCCU_BASE_VERSION = ' + new)
    mk.write_text(updated_mk)
    hashfile.write_text(newhash)
    (directory / 'series').write_text('\n'.join(
        line for line in (directory / 'series').read_text().splitlines()
        if line != selected['patch']) + '\n')
    (directory / selected['patch']).unlink()
    shutil.rmtree(workspace)
    write_json(repo / INDEX, inventory(repo))
    state['in_progress'] = {'patch': selected['patch'], 'base_pr': receipt['number'],
                            'base_merge_commit': new, 'cleanup_pr': None,
                            'phase': 'cleanup-prepared; merge not yet verified'}
    write_json(repo / STATE, state)
    output({'result': 'PREPARED, NOT VALIDATED', 'patch': selected['patch'],
            'base_pr': receipt['html_url'], 'pin': new, 'sha256': archive_hash,
            'remaining': len(names) - 1, 'next': 'validate and compare before committing'})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[1])
    commands = parser.add_subparsers(dest='command', required=True)
    commands.add_parser('status')
    candidates = commands.add_parser('candidates')
    candidates.add_argument('--limit', type=int, default=5)
    index = commands.add_parser('index')
    index.add_argument('--write', action='store_true')
    inspect = commands.add_parser('inspect')
    inspect.add_argument('patch')
    check = commands.add_parser('validate')
    check.add_argument('--archive', required=True, type=Path)
    check.add_argument('--candidate-commit')
    check.add_argument('--candidate-sha256')
    check.add_argument('--skip-patch')
    check.add_argument('--cache')
    check.add_argument('--reuse-stage', action='store_true')
    check.add_argument('--toolchain-id')
    comparison = commands.add_parser('compare')
    comparison.add_argument('left', type=Path)
    comparison.add_argument('right', type=Path)
    download = commands.add_parser('archive')
    download.add_argument('--base-repo', required=True, type=Path)
    download.add_argument('--buildroot', required=True, type=Path)
    download.add_argument('--commit', required=True)
    download.add_argument('--cache')
    prepare = commands.add_parser('prepare-cleanup')
    prepare.add_argument('patch')
    prepare.add_argument('--merge-receipt', required=True, type=Path)
    prepare.add_argument('--base-repo', required=True, type=Path)
    prepare.add_argument('--archive', required=True, type=Path)
    args = parser.parse_args()
    repo = args.repo.resolve()
    if args.command in ('status', 'index', 'inspect', 'candidates'):
        current = inventory(repo)
        if args.command == 'index':
            if args.write:
                write_json(repo / INDEX, current)
            require((repo / INDEX).is_file() and json.loads((repo / INDEX).read_text()) == current,
                    'index stale or missing; run index --write')
            output({'result': 'PASS', 'patches': len(current['patches']), 'index': str(INDEX)})
        elif args.command == 'status':
            checkpoint = json.loads((repo / STATE).read_text())
            output({'head': git(repo, 'rev-parse', 'HEAD'), 'base_pin': pin(repo),
                    'patches': len(current['patches']), 'state': str(STATE),
                    'completed': len(checkpoint['completed']),
                    'in_progress': checkpoint['in_progress'],
                    'checkpoint_matches_pin': checkpoint.get('verified_base_pin') == pin(repo),
                    'index_current': (repo / INDEX).is_file() and json.loads((repo / INDEX).read_text()) == current,
                    'remote_state': 'not queried; verify both HEADs and PR merge state before writes'})
        elif args.command == 'candidates':
            require(1 <= args.limit <= 20, 'candidate limit must be between 1 and 20')
            rows = []
            for entry in current['patches']:
                overlap = sum(bool(set(entry['files']) & set(other['files']))
                              for other in current['patches'] if other != entry)
                rows.append({'patch': entry['patch'], 'files': len(entry['files']),
                             'changed_lines': entry['added'] + entry['removed'],
                             'file_overlaps': overlap})
            rows.sort(key=lambda row: (bool(row['file_overlaps']), row['changed_lines'], row['files'], row['patch']))
            output({'unreviewed_candidates': rows[:args.limit],
                    'note': 'size/file-overlap heuristic only; not semantic dependency analysis'})
        else:
            selected = select(repo, args.patch)
            overlap = [p['patch'][:4] for p in current['patches']
                       if p['patch'] != selected['patch'] and set(p['files']) & set(selected['files'])]
            output({**selected, 'file_overlaps_not_dependencies': overlap,
                    'original_url': ('https://github.com/OpenCCU/OpenCCU/blob/'
                                     + git(repo, 'rev-parse', 'HEAD') + '/' + str(PACKAGE)
                                     + '/rootfs-patches/' + selected['patch'])})
    elif args.command == 'validate':
        validate(repo, args)
    elif args.command == 'compare':
        compare(args.left.resolve(), args.right.resolve())
    elif args.command == 'archive':
        archive(repo, args)
    else:
        cleanup(repo, args)


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, subprocess.CalledProcessError, tarfile.TarError) as error:
        print(f'ERROR: {error}', file=sys.stderr)
        sys.exit(1)
