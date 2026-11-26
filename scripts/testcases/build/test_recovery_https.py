#!/usr/bin/env python3
"""The recovery system's HTTPS instance (S51lighttpd-ssl): when it serves the system's
certificate on port 443, and that every broken, missing or hanging certificate means
plain HTTP only - quickly, without a second lighttpd, and without holding up the boot.

The init script runs with its paths moved into a temporary root and with mocks for
lighttpd, start-stop-daemon and logger; openssl, timeout, stat, readlink and head are
the host's (GNU or busybox, the script uses only what both have).
"""
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[3]
RECOVERY = ROOT / "buildroot-external/package/recovery-system/external/overlay/base"
SCRIPT = RECOVERY / "etc/init.d/S51lighttpd-ssl"
CONF = RECOVERY / "etc/lighttpd/lighttpd.conf"

STEP_TIMEOUT = 2
# the whole check with a hanging step: one step's timeout plus the rest, generously
BOUND = 4 * STEP_TIMEOUT


def openssl(*args, cwd=None):
    subprocess.run(["openssl", *args], check=True, capture_output=True, cwd=cwd)


class RecoveryHttpsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.keys = tempfile.TemporaryDirectory(prefix="recovery-https-keys-")
        k = Path(cls.keys.name)
        ec = ["-newkey", "ec", "-pkeyopt", "ec_paramgen_curve:prime256v1", "-nodes"]
        openssl("req", "-x509", *ec, "-days", "3650", "-subj", "/CN=openccu",
                "-keyout", str(k / "a.key"), "-out", str(k / "a.crt"))
        openssl("req", "-x509", *ec, "-days", "3650", "-subj", "/CN=other",
                "-keyout", str(k / "b.key"), "-out", str(k / "b.crt"))
        # an expired one: openssl ca takes explicit dates (req -x509 does not before 3.4)
        ca = k / "ca"
        ca.mkdir()
        (ca / "index.txt").write_text("")
        (ca / "serial").write_text("01\n")
        (ca / "ca.cnf").write_text(
            "[ca]\ndefault_ca = d\n[d]\ndir = .\ndatabase = index.txt\nserial = serial\n"
            "new_certs_dir = .\ndefault_md = sha256\npolicy = p\n[p]\ncommonName = supplied\n")
        openssl("req", "-new", *ec, "-subj", "/CN=expired", "-keyout", "e.key", "-out", "e.csr", cwd=ca)
        openssl("ca", "-batch", "-config", "ca.cnf", "-selfsign", "-keyfile", "e.key", "-in", "e.csr",
                "-startdate", "20200101000000Z", "-enddate", "20200102000000Z", "-notext",
                "-out", "e.crt", cwd=ca)
        cls.good = (k / "a.crt").read_text() + (k / "a.key").read_text()
        cls.mismatch = (k / "a.crt").read_text() + (k / "b.key").read_text()
        cls.cert_only = (k / "a.crt").read_text()
        cls.key_only = (k / "a.key").read_text()
        cls.expired = (ca / "e.crt").read_text() + (ca / "e.key").read_text()

    @classmethod
    def tearDownClass(cls):
        cls.keys.cleanup()

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="recovery-https-")
        self.addCleanup(self.temp.cleanup)
        r = self.root = Path(self.temp.name).resolve()
        # the recovery's layout: /etc/config -> /usr/local/etc/config, /usr/local -> /userfs
        for d in ("userfs/etc/config", "usr", "etc", "run", "bin", "var/run"):
            (r / d).mkdir(parents=True)
        (r / "usr/local").symlink_to(r / "userfs")
        (r / "etc/config").symlink_to(r / "usr/local/etc/config")
        self.pem = r / "userfs/etc/config/server.pem"
        self.mounts = r / "mounts"
        self.mounts.write_text(f"/dev/mmcblk0p3 {r}/userfs ext4 ro,noatime 0 0\n")
        shutil.copy(CONF, r / "lighttpd.conf")
        self.calls = r / "calls"
        self.calls.write_text("")
        self.logfile = r / "log"
        self.logfile.write_text("")
        self.mock("start-stop-daemon", 'printf "ssd %s\\n" "$*" >>"$CALL_LOG"\n')
        self.mock("logger", 'shift 2; printf "%s\\n" "$*" >>"$LOG_FILE"\n')
        self.mock("lighttpd", 'printf "lighttpd %s\\n" "$*" >>"$CALL_LOG"\n'
                              'if [ "$1" = -tt ]; then exit "${TT_RC:-0}"; fi\n')
        self.env = dict(os.environ, CALL_LOG=str(self.calls), LOG_FILE=str(self.logfile),
                        PATH=str(r / "bin") + ":" + os.environ["PATH"])
        script = SCRIPT.read_text()
        for name, value in (("DAEMON", r / "bin/lighttpd"), ("SRC_CONF", r / "lighttpd.conf"),
                            ("RUN_DIR", r / "run/lighttpd-ssl"), ("PID_FILE", r / "var/run/lighttpd-ssl.pid"),
                            ("START_LOCK", r / "var/run/lighttpd-ssl.lock"),
                            ("USERFS", r / "userfs"), ("MOUNTS", self.mounts),
                            ("CERT", r / "etc/config/server.pem"),
                            ("STEP_TIMEOUT", STEP_TIMEOUT)):
            script, n = re.subn(rf"^{name}=.*$", f"{name}={value}", script, count=1, flags=re.M)
            self.assertEqual(n, 1, f"{name}= not found in the init script")
        # the check directory too
        script = script.replace("RUN_DIR=/run/lighttpd-ssl-check", f"RUN_DIR={r}/run/lighttpd-ssl-check")
        self.script = r / "S51lighttpd-ssl"
        self.script.write_text(script)

    def mock(self, name, body):
        p = self.root / "bin" / name
        p.write_text("#!/bin/sh\n" + body)
        p.chmod(0o755)

    def start(self):
        """S51lighttpd-ssl start: returns at once; waits for the background job's log line."""
        t0 = time.monotonic()
        res = subprocess.run(["sh", str(self.script), "start"], env=self.env, capture_output=True, text=True,
                             timeout=30)
        self.assertEqual(res.returncode, 0, res.stderr)
        self.assertLess(time.monotonic() - t0, 1.5, "start must not wait for the certificate")
        deadline = t0 + BOUND + 5
        while time.monotonic() < deadline and not self.logfile.read_text().strip():
            time.sleep(0.05)
        elapsed = time.monotonic() - t0
        log = self.logfile.read_text()
        self.assertTrue(log.strip(), "no log line")
        self.assertEqual(len(log.strip().splitlines()), 1, f"one log line, got: {log!r}")
        return log, elapsed

    def started(self):
        return "ssd -S" in self.calls.read_text()

    def assert_https(self, log):
        self.assertTrue(self.started(), self.calls.read_text())
        self.assertIn("HTTPS on port 443", log)
        conf = (self.root / "lighttpd-ssl.conf").read_text()
        self.assertRegex(conf, r"(?m)^server\.port = 443$")
        self.assertRegex(conf, r'(?m)^\$SERVER\["socket"\] == "\[::\]:443" \{$')
        self.assertNotRegex(conf, r'(?m)^[^#]*:80"')
        self.assertNotRegex(conf, r"(?m)^server\.port = 80$")
        self.assertIn(f'ssl.pemfile = "{self.root}/run/lighttpd-ssl/server.pem"', conf)
        self.assertIn(f'server.pid-file = "{self.root}/var/run/lighttpd-ssl.pid"', conf)
        # no redirect and no HSTS from the recovery, on either instance
        self.assertNotIn("Strict-Transport-Security\" =>", re.sub(r"(?m)^\s*#.*$", "", conf))
        self.assertNotRegex(re.sub(r"(?m)^\s*#.*$", "", conf), r"url\.redirect[^\n]*https")
        copy = self.root / "run/lighttpd-ssl/server.pem"
        self.assertEqual(copy.stat().st_mode & 0o777, 0o600)
        self.assertEqual(copy.read_text(), self.pem.read_text())
        self.assertIn(f"-f {self.root}/lighttpd-ssl.conf", self.calls.read_text())

    def assert_http_only(self, log, elapsed, reason):
        self.assertFalse(self.started(), self.calls.read_text())
        self.assertIn("no HTTPS on port 443", log)
        self.assertIn(reason, log)
        self.assertFalse((self.root / "run/lighttpd-ssl").exists(), "the RAM copy must be gone")
        self.assertFalse((self.root / "lighttpd-ssl.conf").exists(), "no configuration left")
        self.assertLess(elapsed, BOUND + 1)

    # --- the good cases ---------------------------------------------------------------------

    def test_valid_certificate_is_served_from_a_ram_copy(self):
        self.pem.write_text(self.good)
        log, _ = self.start()
        self.assert_https(log)
        self.assertNotIn("expired", log)
        # the port-80 configuration is untouched
        self.assertEqual((self.root / "lighttpd.conf").read_text(), CONF.read_text())

    def test_expired_certificate_is_served_and_logged(self):
        self.pem.write_text(self.expired)
        log, _ = self.start()
        self.assert_https(log)
        self.assertIn("expired - served anyway", log)

    # --- every failure: HTTP only -------------------------------------------------------------

    def test_userfs_not_mounted(self):
        self.pem.write_text(self.good)
        self.mounts.write_text("proc /proc proc rw 0 0\n")
        self.assert_http_only(*self.start(), "userfs not mounted")

    def test_missing(self):
        self.assert_http_only(*self.start(), "missing or unreadable")

    def test_empty(self):
        self.pem.write_text("")
        self.assert_http_only(*self.start(), "empty")

    def test_truncated(self):
        self.pem.write_text(self.good[: len(self.good) // 2])
        log, elapsed = self.start()
        self.assertFalse(self.started())
        self.assertIn("no HTTPS on port 443", log)

    def test_garbage(self):
        self.pem.write_bytes(os.urandom(3000))
        self.assert_http_only(*self.start(), "no readable certificate")

    def test_huge(self):
        self.pem.write_text(self.good + "x" * 70000)
        self.assert_http_only(*self.start(), "limit")

    def test_key_mismatch(self):
        self.pem.write_text(self.mismatch)
        self.assert_http_only(*self.start(), "does not belong")

    def test_certificate_without_key(self):
        self.pem.write_text(self.cert_only)
        self.assert_http_only(*self.start(), "no readable private key")

    def test_key_without_certificate(self):
        self.pem.write_text(self.key_only)
        self.assert_http_only(*self.start(), "no readable certificate")

    def test_symlink_out_of_place(self):
        other = self.root / "elsewhere.pem"
        other.write_text(self.good)
        self.pem.symlink_to(other)
        self.assert_http_only(*self.start(), "does not lead to")

    def test_directory_in_its_place(self):
        self.pem.mkdir()
        self.assert_http_only(*self.start(), "not a regular file")

    def test_fifo_in_its_place(self):
        os.mkfifo(self.pem)
        self.assert_http_only(*self.start(), "not a regular file")

    @unittest.skipIf(os.geteuid() == 0, "root reads a file with mode 000")
    def test_unreadable(self):
        self.pem.write_text(self.good)
        self.pem.chmod(0)
        self.assert_http_only(*self.start(), "reading")

    def test_hanging_lookup_is_cut_off(self):
        # a dying card: the first access to the userfs never returns
        self.pem.write_text(self.good)
        self.mock("readlink", "exec sleep 600\n")
        self.assert_http_only(*self.start(), "timeout or error")

    def test_hanging_stat_is_cut_off(self):
        self.pem.write_text(self.good)
        self.mock("stat", "exec sleep 600\n")
        self.assert_http_only(*self.start(), "timed out")

    def test_hanging_read_is_cut_off(self):
        self.pem.write_text(self.good)
        self.mock("head", "exec sleep 600\n")
        self.assert_http_only(*self.start(), "timed out")

    def test_unexpected_configuration_shape(self):
        self.pem.write_text(self.good)
        conf = self.root / "lighttpd.conf"
        conf.write_text(conf.read_text().replace("server.port = 80\n", "server.port = 8080\n"))
        self.assert_http_only(*self.start(), "not in the expected shape")

    def test_lighttpd_refusing_the_configuration(self):
        self.pem.write_text(self.good)
        self.env["TT_RC"] = "1"
        log, elapsed = self.start()
        self.assert_http_only(log, elapsed, "refuses the configuration")

    def test_check_does_not_touch_a_running_instance(self):
        self.pem.write_text(self.good)
        self.start()
        before = (self.root / "run/lighttpd-ssl/server.pem").read_text()
        res = subprocess.run(["sh", str(self.script), "check"], env=self.env, capture_output=True, text=True)
        self.assertEqual(res.returncode, 0, res.stdout + res.stderr)
        self.assertIn("usable", res.stdout)
        self.assertEqual((self.root / "run/lighttpd-ssl/server.pem").read_text(), before)
        self.assertFalse((self.root / "run/lighttpd-ssl-check").exists())

    # --- stop and a start that is still under way --------------------------------------------

    def run_script(self, action):
        t0 = time.monotonic()
        res = subprocess.run(["sh", str(self.script), action], env=self.env, capture_output=True, text=True,
                             timeout=30)
        self.assertEqual(res.returncode, 0, res.stderr)
        return res.stdout, time.monotonic() - t0

    def hold_config_test(self):
        """lighttpd -tt reports that it was reached (wait_for) and then stays there until
        release(): the start is under way for exactly as long as the test wants it to be"""
        self.reached = self.root / "tt-reached"
        self.released = self.root / "tt-released"
        # the release is a file that stays: it also holds when it comes before the mock looks.
        # The mock waits with the real sleep, not with one a test puts into the PATH.
        sleep = shutil.which("sleep")
        self.mock("lighttpd", 'printf "lighttpd %s\\n" "$*" >>"$CALL_LOG"\n'
                              'if [ "$1" = -tt ]; then\n'
                              f'  : >"{self.reached}"\n'
                              f'  while [ ! -e "{self.released}" ]; do "{sleep}" 0.05; done\n'
                              '  exit 0\n'
                              'fi\n')
        self.addCleanup(self.release)

    def release(self):
        """lets a held lighttpd -tt go on, whether it already waits or only gets there later"""
        self.released.touch()

    def wait_for(self, marker, what):
        deadline = time.monotonic() + BOUND + 5
        while time.monotonic() < deadline and not marker.exists():
            time.sleep(0.02)
        self.assertTrue(marker.exists(), what)

    def assert_nothing_left(self):
        self.assertFalse(self.started(), self.calls.read_text())
        self.assertFalse((self.root / "run/lighttpd-ssl").exists(), "the RAM copy must be gone")
        self.assertFalse((self.root / "lighttpd-ssl.conf").exists(), "no configuration left")
        self.assertFalse((self.root / "var/run/lighttpd-ssl.lock").exists(), "the lock must be gone")

    def test_stop_cancels_a_start_under_way(self):
        self.pem.write_text(self.good)
        self.hold_config_test()
        # stop waits for the job with sleep, after it has told it to give up
        waiting = self.root / "stop-waiting"
        sleep = shutil.which("sleep")
        self.mock("sleep", f': >"{waiting}"\nexec "{sleep}" "$@"\n')
        self.run_script("start")
        self.wait_for(self.reached, "the start must be under way")
        t0 = time.monotonic()
        stop = subprocess.Popen(["sh", str(self.script), "stop"], env=self.env, stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE, text=True)
        self.addCleanup(stop.kill)
        self.wait_for(waiting, "stop must wait for the start under way")
        self.assertIsNone(stop.poll(), "stop must not return while the start is under way")
        self.release()
        _, err = stop.communicate(timeout=30)
        self.assertEqual(stop.returncode, 0, err)
        self.assertLess(time.monotonic() - t0, BOUND + 5)
        # the job gave up instead of starting the instance, and nothing comes back
        self.assert_nothing_left()
        time.sleep(1)
        self.assert_nothing_left()
        self.assertEqual(self.logfile.read_text(), "")

    def test_stop_right_after_start(self):
        self.pem.write_text(self.good)
        self.run_script("start")
        self.run_script("stop")
        calls = self.calls.read_text()
        # either the job gave up, or the instance it started was stopped after it
        if "ssd -S" in calls:
            self.assertLess(calls.index("ssd -S"), calls.rindex("ssd -K"), calls)
        self.assertFalse((self.root / "run/lighttpd-ssl").exists())
        self.assertFalse((self.root / "lighttpd-ssl.conf").exists())
        time.sleep(1)
        self.assertEqual(calls, self.calls.read_text(), "nothing may happen after the stop")
        self.assertFalse((self.root / "run/lighttpd-ssl").exists())
        self.assertFalse((self.root / "lighttpd-ssl.conf").exists())

    def test_stop_does_not_wait_for_a_hanging_step_forever(self):
        self.pem.write_text(self.good)
        self.mock("readlink", "exec sleep 600\n")
        self.run_script("start")
        _, elapsed = self.run_script("stop")
        self.assertLess(elapsed, BOUND + 1)
        self.assert_nothing_left()

    def test_second_start_while_the_first_is_under_way(self):
        self.pem.write_text(self.good)
        self.hold_config_test()
        self.run_script("start")
        self.wait_for(self.reached, "the start must be under way")
        out, _ = self.run_script("start")
        self.assertIn("already under way", out)
        self.release()
        deadline = time.monotonic() + BOUND
        while time.monotonic() < deadline and not self.logfile.read_text().strip():
            time.sleep(0.05)
        self.assertEqual(self.calls.read_text().count("lighttpd -tt"), 1, self.calls.read_text())
        self.assertEqual(self.calls.read_text().count("ssd -S"), 1, self.calls.read_text())

    def test_restart_starts_again(self):
        self.pem.write_text(self.good)
        self.start()
        self.logfile.write_text("")
        self.run_script("restart")
        deadline = time.monotonic() + BOUND
        while time.monotonic() < deadline and not self.logfile.read_text().strip():
            time.sleep(0.05)
        self.assert_https(self.logfile.read_text())
        self.assertEqual(self.calls.read_text().count("ssd -S"), 2)

    def lock(self, pid=None):
        """the lock as somebody else holds it, with or without a pid in it"""
        lock = self.root / "var/run/lighttpd-ssl.lock"
        lock.mkdir()
        if pid is not None:
            (lock / "pid").write_text(f"{pid}\n")
        return lock

    def test_start_does_nothing_while_the_lock_is_held(self):
        # another start that has taken the lock and not yet named its job, or a stop
        self.pem.write_text(self.good)
        lock = self.lock()
        out, _ = self.run_script("start")
        self.assertIn("already under way", out)
        time.sleep(1)
        self.assertEqual(self.calls.read_text(), "", "no second job may run")
        self.assertEqual(self.logfile.read_text(), "")
        self.assertTrue(lock.is_dir(), "the lock is the other one's")

    def test_simultaneous_starts_run_one_job(self):
        self.pem.write_text(self.good)
        self.hold_config_test()
        starts = [subprocess.Popen(["sh", str(self.script), "start"], env=self.env, stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE, text=True) for _ in range(12)]
        outs = [p.communicate(timeout=30)[0] for p in starts]
        self.assertEqual([p.returncode for p in starts], [0] * len(starts))
        self.assertEqual(sum("in the background" in o for o in outs), 1, outs)
        self.assertEqual(sum("already under way" in o for o in outs), len(starts) - 1, outs)
        self.wait_for(self.reached, "the one job must be under way")
        self.release()
        deadline = time.monotonic() + BOUND
        while time.monotonic() < deadline and not self.logfile.read_text().strip():
            time.sleep(0.05)
        self.assert_https(self.logfile.read_text())
        self.assertEqual(self.calls.read_text().count("lighttpd -tt"), 1, self.calls.read_text())
        self.assertEqual(self.calls.read_text().count("ssd -S"), 1, self.calls.read_text())

    def test_simultaneous_starts_and_a_stop(self):
        # whichever start got the lock: the stop ends its job, and nothing is left or comes back
        self.pem.write_text(self.good)
        self.hold_config_test()
        starts = [subprocess.Popen(["sh", str(self.script), "start"], env=self.env, stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE, text=True) for _ in range(12)]
        for p in starts:
            p.communicate(timeout=30)
        self.wait_for(self.reached, "the one job must be under way")
        waiting = self.root / "stop-waiting"
        sleep = shutil.which("sleep")
        self.mock("sleep", f': >"{waiting}"\nexec "{sleep}" "$@"\n')
        stop = subprocess.Popen(["sh", str(self.script), "stop"], env=self.env, stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE, text=True)
        self.addCleanup(stop.kill)
        self.wait_for(waiting, "stop must wait for the start under way")
        self.release()
        _, err = stop.communicate(timeout=30)
        self.assertEqual(stop.returncode, 0, err)
        self.assert_nothing_left()
        time.sleep(1)
        self.assert_nothing_left()
        self.assertEqual(self.calls.read_text().count("lighttpd -tt"), 1, self.calls.read_text())

    def test_stop_removes_a_lock_nobody_holds(self):
        # left over, or with a pid that is no start of this script (here: this test): such a
        # process is never signalled, and the next start works
        self.pem.write_text(self.good)
        for pid in (None, os.getpid()):
            with self.subTest(pid=pid):
                self.lock(pid)
                _, elapsed = self.run_script("stop")
                self.assertLess(elapsed, 5)
                self.assertFalse((self.root / "var/run/lighttpd-ssl.lock").exists())
        self.assert_https(self.start()[0])
        self.assertFalse((self.root / "var/run/lighttpd-ssl.lock").exists(), "a finished start frees the lock")

    def test_nothing_is_written_to_the_userfs(self):
        self.pem.write_text(self.good)
        before = sorted((p.relative_to(self.root), p.stat().st_mtime_ns) for p in (self.root / "userfs").rglob("*"))
        self.start()
        after = sorted((p.relative_to(self.root), p.stat().st_mtime_ns) for p in (self.root / "userfs").rglob("*"))
        self.assertEqual(before, after)


if __name__ == "__main__":
    unittest.main()
