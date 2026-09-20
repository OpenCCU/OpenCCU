"""Offline regression tests for migration bookkeeping and safety gates."""

import argparse
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[2] / 'base-patch-migration.py'
SPEC = importlib.util.spec_from_file_location('migration', SCRIPT)
migration = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(migration)
NAME = '0001-Test.patch'
DIFF = '--- a/www/test.tcl\n+++ b/www/test.tcl\n@@ -1 +1 @@\n-old\n+new\n'


class MigrationTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'ccu'
        self.repo.mkdir()
        self.package = self.repo / migration.PACKAGE
        self.patches = self.package / 'rootfs-patches'
        self.patches.mkdir(parents=True)
        (self.patches / 'series').write_text(NAME + '\n')
        (self.patches / NAME).write_text(DIFF)

    def test_inventory_and_selection(self):
        entry = migration.select(self.repo, '0001')
        self.assertEqual(entry['files'], ['www/test.tcl'])
        self.assertEqual((entry['added'], entry['removed']), (1, 1))
        before = migration.inventory(self.repo)
        (self.patches / NAME).write_text(DIFF.replace('+new', '+changed'))
        self.assertNotEqual(before, migration.inventory(self.repo))

    def test_duplicate_series(self):
        (self.patches / 'series').write_text((NAME + '\n') * 2)
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            migration.inventory(self.repo)

    def test_unlisted_patch(self):
        (self.patches / '0002-Extra.patch').write_text(DIFF)
        with self.assertRaisesRegex(ValueError, 'differ'):
            migration.inventory(self.repo)

    def test_unsafe_series(self):
        (self.patches / 'series').write_text('../escape.patch\n')
        with self.assertRaisesRegex(ValueError, 'unsafe'):
            migration.series(self.repo)

    def test_unsafe_patch_path(self):
        (self.patches / NAME).write_text(DIFF.replace('www/test.tcl', '../outside'))
        with self.assertRaisesRegex(ValueError, 'unsafe'):
            migration.inventory(self.repo)

    def make_archive(self, entries, commit='a' * 40):
        archive = self.root / 'archive.tar.gz'
        with tarfile.open(archive, 'w:gz') as tar:
            for name, content, link in entries:
                member = tarfile.TarInfo(name)
                member.mode = 0o644
                if link is not None:
                    member.type = tarfile.SYMTYPE
                    member.linkname = link
                    tar.addfile(member)
                else:
                    data = content.encode()
                    member.size = len(data)
                    tar.addfile(member, io.BytesIO(data))
        return archive, commit

    def test_extract_regular_and_runtime_symlink(self):
        prefix = 'openccu-base-' + 'a' * 40
        archive, commit = self.make_archive([
            (prefix + '/data', 'hello', None),
            (prefix + '/runtime', '', '/tmp/runtime')])
        destination = self.root / 'source'
        migration.extract(archive, destination, commit)
        self.assertEqual((destination / 'data').read_text(), 'hello')
        self.assertEqual(os.readlink(destination / 'runtime'), '/tmp/runtime')

    def test_extract_blocks_traversal(self):
        prefix = 'openccu-base-' + 'a' * 40
        for name in ('/absolute', prefix + '/../outside', 'other/data'):
            with self.subTest(name=name):
                archive, commit = self.make_archive([(name, 'bad', None)])
                with self.assertRaises(ValueError):
                    migration.extract(archive, self.root / 'source', commit)

    def test_extract_blocks_symlink_parent(self):
        prefix = 'openccu-base-' + 'a' * 40
        archive, commit = self.make_archive([
            (prefix + '/link', '', '/tmp'),
            (prefix + '/link/escape', 'bad', None)])
        with self.assertRaisesRegex(ValueError, 'symlink'):
            migration.extract(archive, self.root / 'source', commit)

    def test_extract_blocks_duplicates(self):
        name = 'openccu-base-' + 'a' * 40 + '/data'
        archive, commit = self.make_archive([(name, 'one', None), (name, 'two', None)])
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            migration.extract(archive, self.root / 'source', commit)

    def report(self, folder, state, inventory_data=None, skip=None, checks=None):
        folder.mkdir()
        migration.write_json(folder / 'manifest.json', state)
        migration.write_json(folder / 'report.json', {
            'schema': 1, 'commit': 'a' * 40, 'archive_sha256': 'b' * 64,
            'inventory': inventory_data or migration.inventory(self.repo), 'skip': skip,
            'stage_identity': {'archive': 'b' * 64, 'driver': 'c' * 64,
                               'toolchain': 'container@sha256:test',
                               'executables': {'PYTHON': ['/usr/bin/python3', 'd' * 64]}},
            'driver_sha256': 'e' * 64,
            'checks': checks or {'validate.sh': 'f' * 64},
            'manifest_sha256': migration.digest(folder / 'manifest.json')})
        return folder / 'report.json'

    def result_state(self, mode=0o644):
        return {'file': {'type': 'file', 'mode': mode, 'value': '0' * 64}}

    def replace_manifest(self, report, state):
        migration.write_json(report.parent / 'manifest.json', state)
        receipt = json.loads(report.read_text())
        receipt['manifest_sha256'] = migration.digest(report.parent / 'manifest.json')
        migration.write_json(report, receipt)

    def test_compare_and_tamper_detection(self):
        a = self.report(self.root / 'a', self.result_state())
        b = self.report(self.root / 'b', self.result_state(), skip=NAME)
        with contextlib.redirect_stdout(io.StringIO()):
            migration.compare(a, b)
        migration.write_json(b.parent / 'manifest.json', self.result_state(0o755))
        with self.assertRaisesRegex(ValueError, 'manifest changed'):
            migration.compare(a, b)
        self.replace_manifest(b, self.result_state(0o755))
        with self.assertRaisesRegex(ValueError, 'differing'):
            migration.compare(a, b)

    def test_compare_rejects_incompatible_metadata(self):
        a = self.report(self.root / 'a', self.result_state())
        b = self.report(self.root / 'b', self.result_state(), skip=NAME,
                        checks={'validate.sh': '0' * 64})
        with self.assertRaisesRegex(ValueError, 'checks differ'):
            migration.compare(a, b)

    def test_compare_rejects_invalid_transition(self):
        a = self.report(self.root / 'a', self.result_state())
        changed = json.loads(json.dumps(migration.inventory(self.repo)))
        changed['patches'][0]['sha256'] = '1' * 64
        b = self.report(self.root / 'b', self.result_state(), changed)
        with self.assertRaisesRegex(ValueError, 'remove exactly one'):
            migration.compare(a, b)

    def test_compare_rejects_malformed_manifest(self):
        a = self.report(self.root / 'a', self.result_state())
        b = self.report(self.root / 'b', self.result_state(), skip=NAME)
        for state, message in [([], 'object'),
                               ({'file': {'type': 'file', 'mode': '0644', 'value': '0' * 64}},
                                'entry'),
                               ({'../file': self.result_state()['file']}, 'path')]:
            with self.subTest(state=state):
                self.replace_manifest(b, state)
                with self.assertRaisesRegex(ValueError, 'invalid manifest ' + message):
                    migration.compare(a, b)

    def test_validate_patches_rejects_empty_option_values(self):
        script = self.patches / 'validate_patches.sh'
        shutil.copyfile(Path(__file__).resolve().parents[3] / migration.PACKAGE /
                        'rootfs-patches' / 'validate_patches.sh', script)
        script.chmod(0o755)
        for option in ('--skip-patch', '--result-dir'):
            with self.subTest(option=option):
                result = subprocess.run(['bash', script, self.root, option, ''],
                                        text=True, capture_output=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('invalid option value: ' + option, result.stderr)

    def test_manifest_records_modes_and_links(self):
        folder = self.root / 'tree'
        folder.mkdir()
        (folder / 'file').write_text('value')
        (folder / 'link').symlink_to('file')
        first = migration.manifest(folder)
        (folder / 'file').chmod(0o755)
        second = migration.manifest(folder)
        self.assertNotEqual(first['file']['mode'], second['file']['mode'])
        self.assertEqual(second['link']['value'], 'file')

    def init_git(self, repo):
        subprocess.run(['git', 'init', '-q', str(repo)], check=True)
        migration.git(repo, 'config', 'user.name', 'Jens Maus')
        migration.git(repo, 'config', 'user.email', 'mail@jens-maus.de')

    def commit(self, repo):
        migration.git(repo, 'add', '.')
        migration.git(repo, 'commit', '-qm', 'Test fixture')
        return migration.git(repo, 'rev-parse', 'HEAD')

    def cleanup_fixture(self):
        base = self.root / 'base'
        base.mkdir()
        self.init_git(base)
        (base / 'licenses').mkdir()
        (base / 'licenses/test.txt').write_text('license')
        (base / 'data').write_text('old')
        old = self.commit(base)
        (base / 'data').write_text('new')
        new = self.commit(base)
        archive = self.root / 'source.tar.gz'
        with tarfile.open(archive, 'w:gz') as tar:
            for file in ('data', 'licenses/test.txt'):
                tar.add(base / file, arcname=f'openccu-base-{new}/{file}')
        (self.package / 'openccu-base.mk').write_text('OPENCCU_BASE_VERSION = ' + old + '\n')
        (self.package / 'openccu-base.hash').write_text(
            'sha256  ' + migration.digest(base / 'licenses/test.txt') + '  licenses/test.txt\n'
            'sha256  ' + 'f' * 64 + f'  openccu-base-{old}-git4.tar.gz\n')
        workspace = self.patches / NAME[:-6]
        workspace.mkdir()
        (workspace / 'test.orig').write_text('old')
        (workspace / 'test').write_text('new')
        migration.write_json(self.repo / migration.STATE, {'completed': [], 'in_progress': None})
        migration.write_json(self.repo / migration.INDEX, migration.inventory(self.repo))
        self.init_git(self.repo)
        self.commit(self.repo)
        migration.git(self.repo, 'checkout', '-qb', 'cleanup-test')
        receipt = self.root / 'receipt.json'
        migration.write_json(receipt, {
            'number': 40, 'merged': True, 'merged_at': '2026-09-20T00:00:00Z',
            'merge_commit_sha': new, 'body': NAME,
            'html_url': 'https://github.com/OpenCCU/OpenCCU-Base/pull/40',
            'base': {'ref': 'main', 'repo': {'full_name': 'OpenCCU/OpenCCU-Base'}}})
        return argparse.Namespace(patch='0001', merge_receipt=receipt, base_repo=base,
                                  buildroot=self.root, archive=archive, cache=None), old, new

    def run_cleanup(self, args, canonical=None):
        generated = canonical or args.archive
        with patch.object(migration, 'canonical_archive',
                          return_value=(generated, self.root / 'archive.log')):
            return migration.cleanup(self.repo, args)

    def test_cleanup_success(self):
        args, old, new = self.cleanup_fixture()
        with contextlib.redirect_stdout(io.StringIO()):
            self.run_cleanup(args)
        self.assertEqual(migration.pin(self.repo), new)
        self.assertFalse((self.patches / NAME).exists())
        self.assertFalse((self.patches / NAME[:-6]).exists())
        self.assertEqual(migration.inventory(self.repo)['patches'], [])
        self.assertEqual(json.loads((self.repo / migration.STATE).read_text())['in_progress']['base_pr'], 40)
        self.assertEqual(migration.git(self.repo, 'log', '-1', '--format=%s'), 'Test fixture')

    def test_cleanup_unmerged_is_nonmutating(self):
        args, old, new = self.cleanup_fixture()
        data = json.loads(args.merge_receipt.read_text())
        data['merged'] = False
        migration.write_json(args.merge_receipt, data)
        with self.assertRaisesRegex(ValueError, 'not merged'):
            self.run_cleanup(args)
        self.assertEqual(migration.git(self.repo, 'status', '--porcelain'), '')

    def test_cleanup_wrong_repo(self):
        args, old, new = self.cleanup_fixture()
        data = json.loads(args.merge_receipt.read_text())
        data['base']['repo']['full_name'] = 'another/repo'
        migration.write_json(args.merge_receipt, data)
        with self.assertRaisesRegex(ValueError, 'unexpected'):
            self.run_cleanup(args)

    def test_cleanup_dirty_worktree(self):
        args, old, new = self.cleanup_fixture()
        (self.patches / NAME).write_text('changed')
        with self.assertRaisesRegex(ValueError, 'clean worktree'):
            self.run_cleanup(args)

    def test_cleanup_wrong_archive_contents(self):
        args, old, new = self.cleanup_fixture()
        with tarfile.open(args.archive, 'w:gz') as tar:
            tar.add(args.base_repo / 'licenses/test.txt',
                    arcname=f'openccu-base-{new}/licenses/test.txt')
        with self.assertRaisesRegex(ValueError, 'do not match'):
            self.run_cleanup(args)
        self.assertEqual(migration.pin(self.repo), old)
        self.assertEqual(migration.git(self.repo, 'status', '--porcelain'), '')

    def test_cleanup_rejects_second_migration(self):
        args, old, new = self.cleanup_fixture()
        migration.write_json(self.repo / migration.STATE, {'in_progress': {'patch': 'other'}})
        self.commit(self.repo)
        with self.assertRaisesRegex(ValueError, 'preceding migration'):
            self.run_cleanup(args)

    def test_cleanup_protected_branch(self):
        args, old, new = self.cleanup_fixture()
        migration.git(self.repo, 'branch', '-M', 'main')
        with self.assertRaisesRegex(ValueError, 'dedicated cleanup branch'):
            self.run_cleanup(args)

    def test_cleanup_preserves_ignored_workspace_file(self):
        args, old, new = self.cleanup_fixture()
        (self.repo / '.gitignore').write_text('*.private\n')
        self.commit(self.repo)
        extra = self.patches / NAME[:-6] / 'notes.private'
        extra.write_text('keep me')
        with self.assertRaisesRegex(ValueError, 'untracked file'):
            self.run_cleanup(args)
        self.assertEqual(extra.read_text(), 'keep me')
        self.assertEqual(migration.pin(self.repo), old)

    def test_cleanup_rejects_completed_patch(self):
        args, old, new = self.cleanup_fixture()
        migration.write_json(self.repo / migration.STATE,
                             {'completed': [{'patch': NAME}], 'in_progress': None})
        self.commit(self.repo)
        with self.assertRaisesRegex(ValueError, 'already recorded'):
            self.run_cleanup(args)

    def test_cleanup_rejects_unrelated_pr(self):
        args, old, new = self.cleanup_fixture()
        data = json.loads(args.merge_receipt.read_text())
        data['body'] = 'A different change'
        migration.write_json(args.merge_receipt, data)
        with self.assertRaisesRegex(ValueError, 'does not name'):
            self.run_cleanup(args)

    def test_cleanup_rejects_noncanonical_archive(self):
        args, old, new = self.cleanup_fixture()
        canonical = self.root / 'canonical.tar.gz'
        shutil.copyfile(args.archive, canonical)
        with canonical.open('ab') as stream:
            stream.write(b'not-the-buildroot-archive')
        with self.assertRaisesRegex(ValueError, 'not the canonical'):
            self.run_cleanup(args, canonical)
        self.assertEqual(migration.pin(self.repo), old)
        self.assertEqual(migration.git(self.repo, 'status', '--porcelain'), '')


if __name__ == '__main__':
    unittest.main()
