#!/usr/bin/env python3
"""Check the CSRF protection and the shared action lock of the recovery system CGIs."""
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[3]
RECOVERY = ROOT / "buildroot-external/package/recovery-system/external/overlay/base"
LIB = RECOVERY / "lib/librecovery.sh"
INDEX = RECOVERY / "www/index.cgi"
FWINSTALL = RECOVERY / "bin/fwinstall.sh"
CGI_DIR = RECOVERY / "www/cgi-bin"

# every recovery action (all of them change the storage or reboot the system)
ACTIONS = ("admin_password_reset", "check_storage", "clone_system", "create_backup",
           "factory_reset", "firmware_update", "network_reset", "normal_boot",
           "restore_backup", "safemode_boot")
# actions that just modify a file on /userfs and reboot
SIMPLE_REBOOT_ACTIONS = ("admin_password_reset", "network_reset", "normal_boot",
                         "safemode_boot")
HOST = "192.168.1.10"


class RecoveryActionsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="recovery-actions-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in ("bin", "lib", "tmp", "userfs", "usr/local/etc/config"):
            (self.root / name).mkdir(parents=True)
        self.log = self.root / "calls"
        self.log.write_text("")
        self.lock = self.root / "tmp/.recoveryActionLock"
        # commands with side effects are only logged
        for name in ("mount", "umount", "reboot", "mkfs.ext4", "tune2fs", "e2fsck"):
            self.mock(name, f'echo "{name} $*" >>"$CALL_LOG"')
        self.localize(LIB.read_text(), "lib/librecovery.sh")
        self.env = dict(os.environ, CALL_LOG=str(self.log), REQUEST_METHOD="POST",
                        HTTP_HOST=HOST, HTTP_ORIGIN=f"http://{HOST}",
                        PATH=str(self.root / "bin") + ":" + os.environ["PATH"])
        self.env.pop("HTTP_REFERER", None)

    def mock(self, name, body):
        path = self.root / "bin" / name
        path.write_text("#!/bin/sh\n" + body + "\n")
        path.chmod(0o755)

    def localize(self, source, target):
        """Redirect absolute paths of a recovery script into the temp root."""
        source = source.replace("/sbin/reboot", "reboot")
        source = re.sub(r"(?<![\w./-])(/tmp/|/userfs|/usr/local/|/lib/librecovery\.sh)",
                        lambda match: str(self.root) + match.group(1), source)
        out = self.root / target
        out.write_text(source)
        out.chmod(0o755)
        return out

    def run_cgi(self, name, **env):
        script = self.localize((CGI_DIR / f"{name}.cgi").read_text(), f"{name}.cgi")
        return subprocess.run(["bash", str(script)], env=dict(self.env, **env),
                              capture_output=True, text=True, timeout=10,
                              stdin=subprocess.DEVNULL)

    def check_request(self, **env):
        lib = self.root / "lib/librecovery.sh"
        return subprocess.run(["bash", "-c", '. "$0"; recovery_check_request', str(lib)],
                              env=dict(self.env, **env), capture_output=True, text=True)

    def test_request_check(self):
        cases = [
            (dict(REQUEST_METHOD="GET"), 1),
            (dict(REQUEST_METHOD=""), 1),
            (dict(), 0),
            (dict(HTTP_HOST=f"{HOST}:8080", HTTP_ORIGIN=f"http://{HOST}:8080"), 0),
            (dict(HTTP_ORIGIN=f"https://{HOST}"), 0),
            (dict(HTTP_ORIGIN="http://evil.example"), 1),
            (dict(HTTP_ORIGIN=f"http://{HOST}.evil.example"), 1),
            (dict(HTTP_ORIGIN=f"http://{HOST}:8080"), 1),
            (dict(HTTP_ORIGIN="null"), 1),
            (dict(HTTP_ORIGIN="", HTTP_REFERER=f"http://{HOST}/index.cgi"), 0),
            (dict(HTTP_ORIGIN="", HTTP_REFERER="http://evil.example/index.cgi"), 1),
            (dict(HTTP_ORIGIN=""), 1),
            (dict(HTTP_ORIGIN="", HTTP_REFERER=""), 1),
            (dict(HTTP_HOST=""), 1),
            (dict(HTTP_HOST="", HTTP_ORIGIN=""), 1),
        ]
        for env, expected in cases:
            with self.subTest(env=env):
                self.assertEqual(self.check_request(**env).returncode, expected)

    def test_lock_is_exclusive(self):
        lib = self.root / "lib/librecovery.sh"
        result = subprocess.run(
            ["bash", "-c", '. "$0"; recovery_lock && ! recovery_lock && recovery_locked '
             '&& recovery_unlock && ! recovery_locked && recovery_lock', str(lib)],
            env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.lock.is_dir())

    def assert_rejected(self, name, result, message):
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn(message, result.stdout)
        self.assertEqual(self.log.read_text(), "", name)

    def test_get_requests_are_rejected(self):
        for name in ACTIONS:
            with self.subTest(action=name):
                self.assert_rejected(name, self.run_cgi(name, REQUEST_METHOD="GET"),
                                     "invalid request method")
                self.assertFalse(self.lock.exists())

    def test_cross_site_requests_are_rejected(self):
        for name in ACTIONS:
            with self.subTest(action=name):
                self.assert_rejected(name, self.run_cgi(name, HTTP_ORIGIN="http://evil.example"),
                                     "cross-site request rejected")
                self.assertFalse(self.lock.exists())

    def test_actions_are_rejected_while_another_one_runs(self):
        self.lock.mkdir()
        for name in ACTIONS:
            with self.subTest(action=name):
                self.assert_rejected(name, self.run_cgi(name), "currently running")
                # the lock of the running action must stay in place
                self.assertTrue(self.lock.is_dir())

    def test_reboot_actions_keep_lock_until_reboot(self):
        userfs = str(self.root / "userfs")
        for name in SIMPLE_REBOOT_ACTIONS:
            with self.subTest(action=name):
                self.log.write_text("")
                result = self.run_cgi(name)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(self.log.read_text().splitlines(),
                                 [f"mount -o rw,remount {userfs}",
                                  f"mount -o ro,remount {userfs}", "reboot "])
                self.assertTrue(self.lock.is_dir())
                self.lock.rmdir()

    @unittest.skipUnless(shutil.which("busybox"), "busybox is required")
    def test_terminated_action_releases_lock(self):
        """BusyBox ash skips the EXIT trap on signals unless they are trapped."""
        lib = self.root / "lib/librecovery.sh"
        script = self.root / "action.sh"
        script.write_text(f'. "{lib}"\nrecovery_cgi_begin\nsleep 1\nsleep 30\n')
        # own process group so that the cleanup only affects this test's processes
        proc = subprocess.Popen(["busybox", "sh", str(script)], env=self.env,
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                                start_new_session=True)
        try:
            for _ in range(50):
                if self.lock.is_dir():
                    break
                time.sleep(0.05)
            self.assertTrue(self.lock.is_dir())
            proc.send_signal(signal.SIGTERM)
            proc.wait(timeout=10)
        finally:
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            proc.wait()
        self.assertFalse(self.lock.exists())

    def test_failing_reboot_releases_lock(self):
        self.mock("reboot", 'echo "reboot $*" >>"$CALL_LOG"; exit 1')
        for name in SIMPLE_REBOOT_ACTIONS:
            with self.subTest(action=name):
                result = self.run_cgi(name)
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertIn("ERROR: reboot failed", result.stdout)
                self.assertFalse(self.lock.exists())

    def run_firmware_update(self, fwinstall_rc):
        """Upload a firmware file with a mocked fwinstall.sh that logs the lock state."""
        (self.root / "usr/local/tmp").mkdir(parents=True)
        self.mock("fwinstall.sh",
                  f'[ -d "{self.lock}" ] && echo "fwinstall locked=yes held=$RECOVERY_LOCK_HELD" '
                  f'>>"$CALL_LOG"; exit {fwinstall_rc}')
        source = (CGI_DIR / "firmware_update.cgi").read_text().replace(
            "/bin/fwinstall.sh", "fwinstall.sh")
        script = self.localize(source, "firmware_update.cgi")
        headers = ("--boundary\r\n"
                   'Content-Disposition: form-data; name="Datei"; filename="fw.tgz"\r\n'
                   "Content-Type: application/octet-stream\r\n\r\n")
        body = (headers + "firmware-data\r\n--boundary--\r\n").encode()
        return subprocess.run(["bash", str(script)], input=body, capture_output=True,
                              timeout=20, env=dict(self.env, CONTENT_LENGTH=str(len(body))))

    def test_firmware_update_holds_lock_from_upload_until_reboot(self):
        result = self.run_firmware_update(0)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.log.read_text().splitlines(),
                         ["fwinstall locked=yes held=1", "reboot "])
        self.assertTrue(self.lock.is_dir())

    def test_failing_firmware_update_releases_lock(self):
        result = self.run_firmware_update(1)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertEqual(self.log.read_text().splitlines(), ["fwinstall locked=yes held=1"])
        self.assertFalse(self.lock.exists())

    def test_failing_action_releases_lock(self):
        self.mock("mount", f'echo "mount $*" >>"$CALL_LOG"; exit 1')
        for name in SIMPLE_REBOOT_ACTIONS:
            with self.subTest(action=name):
                result = self.run_cgi(name)
                self.assertEqual(result.returncode, 1)
                self.assertIn("ERROR (rw remount)", result.stdout)
                self.assertNotIn("reboot", self.log.read_text())
                self.assertFalse(self.lock.exists())

    def test_index_triggers_actions_via_post_only(self):
        index = INDEX.read_text()
        self.assertNotRegex(index, r"location\.href\s*=\s*'cgi-bin/")
        for form in re.findall(r"<form [^>]*>", index):
            with self.subTest(form=form):
                self.assertIn('method="post"', form)
        for name in ACTIONS:
            with self.subTest(action=name):
                self.assertIn(f"cgi-bin/{name}.cgi", index)

    def run_fwinstall(self, *args, **env):
        script = self.localize(FWINSTALL.read_text(), "fwinstall.sh")
        return subprocess.run(["bash", str(script), *args], env=dict(self.env, **env),
                              capture_output=True, text=True, timeout=10)

    def test_fwinstall_refuses_while_another_action_runs(self):
        self.lock.mkdir()
        result = self.run_fwinstall("/nonexistent")
        self.assertEqual(result.returncode, 1)
        self.assertIn("already running", result.stdout)
        self.assertTrue(self.lock.is_dir())
        self.assertFalse((self.root / "tmp/.runningFirmwareUpdate").exists())

    def test_fwinstall_uses_lock_held_by_caller(self):
        self.lock.mkdir()
        result = self.run_fwinstall("/nonexistent", RECOVERY_LOCK_HELD="1")
        self.assertNotIn("already running", result.stdout)
        self.assertIn("Preparing firmware update", result.stdout)
        # the caller stays responsible for releasing its lock
        self.assertTrue(self.lock.is_dir())
        self.assertFalse((self.root / "tmp/.runningFirmwareUpdate").exists())

    def test_fwinstall_ignores_lock_handover_without_lock(self):
        result = self.run_fwinstall("/nonexistent", RECOVERY_LOCK_HELD="1")
        self.assertIn("Preparing firmware update", result.stdout)
        # it claimed the lock itself and released it again on exit
        self.assertFalse(self.lock.exists())

    def test_fwinstall_exit_releases_only_own_lock(self):
        functions = FWINSTALL.read_text().split("# main body starts here")[0]
        script = self.localize(functions, "fw-funcs.sh")
        lib = self.root / "lib/librecovery.sh"
        marker = self.root / "tmp/.runningFirmwareUpdate"
        for owner, released in (("0", False), ("1", True)):
            with self.subTest(owner=owner):
                marker.touch()
                if not self.lock.exists():
                    self.lock.mkdir()
                result = subprocess.run(
                    ["bash", "-c", '. "$0"; . "$1"; RECOVERY_LOCK_OWNER=$2; on_exit',
                     str(script), str(lib), owner],
                    env=self.env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.lock.exists(), not released)
                self.assertFalse(marker.exists())


if __name__ == "__main__":
    unittest.main()
