"""Offline regression tests for migration bookkeeping and safety gates."""

import argparse
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest


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

    def report(self, folder, state):
        folder.mkdir()
        migration.write_json(folder / 'manifest.json', state)
        migration.write_json(folder / 'report.json', {
            'manifest_sha256': migration.digest(folder / 'manifest.json')})
        return folder / 'report.json'

    def test_compare_and_tamper_detection(self):
        a = self.report(self.root / 'a', {'file': {'mode': 0o644}})
        b = self.report(self.root / 'b', {'file': {'mode': 0o644}})
        with contextlib.redirect_stdout(io.StringIO()):
            migration.compare(a, b)
        migration.write_json(b.parent / 'manifest.json', {'file': {'mode': 0o755}})
        with self.assertRaisesRegex(ValueError, 'manifest changed'):
            migration.compare(a, b)
        migration.write_json(b, {'manifest_sha256': migration.digest(b.parent / 'manifest.json')})
        with self.assertRaisesRegex(ValueError, 'differing'):
            migration.compare(a, b)

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
                                  archive=archive), old, new

    def test_cleanup_success(self):
        args, old, new = self.cleanup_fixture()
        with contextlib.redirect_stdout(io.StringIO()):
            migration.cleanup(self.repo, args)
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
            migration.cleanup(self.repo, args)
        self.assertEqual(migration.git(self.repo, 'status', '--porcelain'), '')

    def test_cleanup_wrong_repo(self):
        args, old, new = self.cleanup_fixture()
        data = json.loads(args.merge_receipt.read_text())
        data['base']['repo']['full_name'] = 'another/repo'
        migration.write_json(args.merge_receipt, data)
        with self.assertRaisesRegex(ValueError, 'unexpected'):
            migration.cleanup(self.repo, args)

    def test_cleanup_dirty_worktree(self):
        args, old, new = self.cleanup_fixture()
        (self.patches / NAME).write_text('changed')
        with self.assertRaisesRegex(ValueError, 'clean worktree'):
            migration.cleanup(self.repo, args)

    def test_cleanup_wrong_archive_contents(self):
        args, old, new = self.cleanup_fixture()
        with tarfile.open(args.archive, 'w:gz') as tar:
            tar.add(args.base_repo / 'licenses/test.txt',
                    arcname=f'openccu-base-{new}/licenses/test.txt')
        with self.assertRaisesRegex(ValueError, 'do not match'):
            migration.cleanup(self.repo, args)
        self.assertEqual(migration.pin(self.repo), old)
        self.assertEqual(migration.git(self.repo, 'status', '--porcelain'), '')

    def test_cleanup_rejects_second_migration(self):
        args, old, new = self.cleanup_fixture()
        migration.write_json(self.repo / migration.STATE, {'in_progress': {'patch': 'other'}})
        self.commit(self.repo)
        with self.assertRaisesRegex(ValueError, 'preceding migration'):
            migration.cleanup(self.repo, args)

    def test_cleanup_protected_branch(self):
        args, old, new = self.cleanup_fixture()
        migration.git(self.repo, 'branch', '-M', 'main')
        with self.assertRaisesRegex(ValueError, 'dedicated cleanup branch'):
            migration.cleanup(self.repo, args)

    def test_cleanup_preserves_ignored_workspace_file(self):
        args, old, new = self.cleanup_fixture()
        (self.repo / '.gitignore').write_text('*.private\n')
        self.commit(self.repo)
        extra = self.patches / NAME[:-6] / 'notes.private'
        extra.write_text('keep me')
        with self.assertRaisesRegex(ValueError, 'untracked file'):
            migration.cleanup(self.repo, args)
        self.assertEqual(extra.read_text(), 'keep me')
        self.assertEqual(migration.pin(self.repo), old)

    def test_cleanup_rejects_completed_patch(self):
        args, old, new = self.cleanup_fixture()
        migration.write_json(self.repo / migration.STATE,
                             {'completed': [{'patch': NAME}], 'in_progress': None})
        self.commit(self.repo)
        with self.assertRaisesRegex(ValueError, 'already recorded'):
            migration.cleanup(self.repo, args)

    def test_cleanup_rejects_unrelated_pr(self):
        args, old, new = self.cleanup_fixture()
        data = json.loads(args.merge_receipt.read_text())
        data['body'] = 'A different change'
        migration.write_json(args.merge_receipt, data)
        with self.assertRaisesRegex(ValueError, 'does not name'):
            migration.cleanup(self.repo, args)


if __name__ == '__main__':
    unittest.main()
