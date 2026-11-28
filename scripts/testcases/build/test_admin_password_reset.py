#!/usr/bin/env python3
"""Exercise the admin password reset (recovery action, ReGaHss hook, script) in a temp root."""
import os
import re
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
EXTERNAL = ROOT / "buildroot-external"
RESET_SCRIPT = EXTERNAL / "overlay/base-openccu/bin/resetAdminPasswords"
REGA_INIT_SCRIPT = EXTERNAL / "package/openccu-base/S70ReGaHss"
RECOVERY_CGI = (EXTERNAL / "package/recovery-system/external/overlay/base"
                "/www/cgi-bin/admin_password_reset.cgi")
RECOVERY_INDEX = EXTERNAL / "package/recovery-system/external/overlay/base/www/index.cgi"
RECOVERY_LIB = EXTERNAL / "package/recovery-system/external/overlay/base/lib/librecovery.sh"

SHADOW = ("root:$6$salt$hash:19000:0:99999:7:::\n"
          "daemon:*:10933:0:99999:7:::\n"
          "sshd:*:::::::\n")

# Replaces tclrega.so: 'rega_script' returns the admin names given in
# $REGA_ADMINS once ReGaHss is "ready" and logs each executed script.
TCL_PRELUDE = r'''
proc load {args} {}
proc rega_script {script} {
  if {$::env(REGA_READY) ne "yes"} { error "connection refused" }
  set fd [open $::env(CALL_LOG) a]; puts $fd "REGA: $script"; close $fd
  if {[string match {*Write("READY")*} $script]} { return [list STDOUT READY] }
  set out ""
  foreach name [split $::env(REGA_ADMINS) ","] { append out "$name\n" }
  return [list STDOUT $out]
}
'''


class AdminPasswordResetTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="admin-pw-reset-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in ("etc/config/userprofiles", "var", "bin", "usr/local", "userfs", "tmp"):
            (self.root / name).mkdir(parents=True)
        self.log = self.root / "calls"
        self.log.write_text("")
        self.shadow = self.root / "etc/config/shadow"
        self.shadow.write_text(SHADOW)
        self.hint = self.root / "etc/config/userAckSecurityHint"
        self.hint.touch()
        profiles = self.root / "etc/config/userprofiles"
        for name in ("Admin", "Second;Admin", "User"):
            (profiles / f"userAckInstallWizard_{name}").touch()
        (self.root / "var/hm_mode").write_text("HM_MODE=NORMAL\n")
        self.mock("id", 'echo 0')
        for name in ("chown", "logger", "sync"):
            self.mock(name, 'printf "%s %s\\n" "$(basename "$0")" "$*" >>"$CALL_LOG"')
        self.env = dict(os.environ, CALL_LOG=str(self.log), REGA_READY="yes",
                        REGA_ADMINS="Admin,Second Admin",
                        PATH=str(self.root / "bin") + ":" + os.environ["PATH"])

    def mock(self, name, body):
        path = self.root / "bin" / name
        path.write_text("#!/bin/sh\n" + body + "\n")
        path.chmod(0o755)

    def localize(self, source, target):
        """Redirect absolute paths of a target script into the temp root."""
        source = re.sub(r"(?<![\w./-])(/etc/|/var/|/usr/local/|/userfs|/tmp/|/lib/librecovery\.sh)",
                        lambda match: str(self.root) + match.group(1), source)
        out = self.root / target
        out.write_text(source)
        out.chmod(0o755)
        return out

    def run_reset(self, *args):
        if shutil.which("tclsh") is None:
            self.skipTest("tclsh not available")
        tclsh = shutil.which("tclsh")
        prelude = self.root / "prelude.tcl"
        prelude.write_text(TCL_PRELUDE)
        self.mock("tclsh", f'{{ cat "{prelude}"; cat; }} | "{tclsh}"')
        script = self.localize(RESET_SCRIPT.read_text(), "resetAdminPasswords")
        return subprocess.run(["bash", str(script), *args], env=self.env,
                              capture_output=True, text=True, timeout=30)

    def test_clears_root_and_webui_admin_passwords(self):
        result = self.run_reset("-w", "0")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.shadow.read_text(),
                         SHADOW.replace("root:$6$salt$hash:", "root::"))
        calls = self.log.read_text()
        self.assertIn('oUser.UserBlankPwd("");', calls)
        self.assertIn("oUser.UserLevel() == iulAdmin", calls)
        self.assertIn("system.Save();", calls)
        self.assertIn("  - Admin\n  - Second Admin\n", result.stdout)
        profiles = sorted(p.name for p in (self.root / "etc/config/userprofiles").iterdir())
        self.assertEqual(profiles, ["userAckInstallWizard_User"])
        self.assertFalse(self.hint.exists())

    def test_unreachable_rega_still_clears_root_password(self):
        self.env["REGA_READY"] = "no"
        result = self.run_reset("-w", "0")
        self.assertEqual(result.returncode, 1)
        self.assertIn("ReGaHss is not running or not ready", result.stdout)
        self.assertTrue(self.shadow.read_text().startswith("root::"))
        self.assertTrue(self.hint.exists())

    def test_missing_admin_user_is_an_error(self):
        self.env["REGA_ADMINS"] = ""
        result = self.run_reset("-w", "0")
        self.assertEqual(result.returncode, 1)
        self.assertIn("no WebUI user with administrator rights found", result.stdout)
        self.assertTrue(self.hint.exists())

    def test_non_normal_mode_skips_rega(self):
        (self.root / "var/hm_mode").write_text("HM_MODE=HMLGW\n")
        result = self.run_reset("-w", "0")
        self.assertEqual(result.returncode, 1)
        self.assertIn("not used in HMLGW mode", result.stdout)
        self.assertNotIn("REGA:", self.log.read_text())
        self.assertTrue(self.shadow.read_text().startswith("root::"))

    def test_invalid_wait_time_is_rejected(self):
        result = self.run_reset("-w", "abc")
        self.assertEqual(result.returncode, 1)
        self.assertEqual(self.shadow.read_text(), SHADOW)

    def run_init(self):
        """Run the reset check of S70ReGaHss as executed after ReGaHss was started."""
        source = REGA_INIT_SCRIPT.read_text()
        start = source.index("checkAdminPasswordReset() {")
        end = source.index("\n}\n", start) + 3
        flag = re.search(r"^ADMIN_PASSWORD_RESET_FLAG=.*$", source, re.M).group(0)
        # resolve the script via PATH so that the mock below is used
        hook = (flag + "\n" + source[start:end] + "checkAdminPasswordReset\n").replace(
            "/bin/resetAdminPasswords", "resetAdminPasswords")
        script = self.localize(hook, "check_reset.sh")
        self.mock("resetAdminPasswords", 'echo "reset $*" >>"$CALL_LOG"')
        result = subprocess.run(["bash", str(script)], env=self.env,
                                capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def wait_for_call(self, text):
        for _ in range(50):
            if text in self.log.read_text():
                return
            subprocess.run(["sleep", "0.1"], check=True)
        self.fail(f"{text!r} not called: {self.log.read_text()!r}")

    def test_rega_start_consumes_flag_and_starts_reset(self):
        flag = self.root / "usr/local/.doAdminPasswordReset"
        flag.touch()
        self.assertIn("Admin password reset started", self.run_init())
        self.assertFalse(flag.exists())
        self.wait_for_call("reset -w 300")

    def test_rega_start_without_flag_does_nothing(self):
        self.assertEqual(self.run_init(), "")
        self.assertNotIn("reset", self.log.read_text())

    def test_rega_start_checks_reset_after_startup(self):
        source = REGA_INIT_SCRIPT.read_text()
        start = source[source.index("\nstart() {"):source.index("\nstop() {")]
        self.assertGreater(start.index("\tcheckAdminPasswordReset"),
                           start.index("\twaitStartupComplete"))

    def run_cgi(self):
        for name in ("mount", "reboot"):
            self.mock(name, f'echo "{name} $*" >>"$CALL_LOG"')
        (self.root / "lib").mkdir(exist_ok=True)
        self.localize(RECOVERY_LIB.read_text().replace("/sbin/reboot", "reboot"),
                      "lib/librecovery.sh")
        script = self.localize(RECOVERY_CGI.read_text(), "admin_password_reset.cgi")
        env = dict(self.env, REQUEST_METHOD="POST", HTTP_HOST="ccu", HTTP_ORIGIN="http://ccu")
        return subprocess.run(["bash", str(script)], env=env,
                              capture_output=True, text=True, timeout=10)

    def test_recovery_action_schedules_reset_and_reboots(self):
        result = self.run_cgi()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue((self.root / "userfs/.doAdminPasswordReset").exists())
        calls = self.log.read_text().splitlines()
        userfs = str(self.root / "userfs")
        self.assertEqual(calls, [f"mount -o rw,remount {userfs}",
                                 f"mount -o ro,remount {userfs}", "reboot "])
        self.assertEqual(self.shadow.read_text(), SHADOW)

    def test_recovery_action_refused_during_firmware_update(self):
        (self.root / "tmp/.recoveryActionLock").mkdir()
        result = self.run_cgi()
        self.assertEqual(result.returncode, 1)
        self.assertFalse((self.root / "userfs/.doAdminPasswordReset").exists())
        self.assertEqual(self.log.read_text(), "")

    def test_recovery_menu_offers_action(self):
        index = RECOVERY_INDEX.read_text()
        self.assertIn('value="Reset Admin Passwords"', index)
        self.assertIn("cgi-bin/admin_password_reset.cgi", index)


if __name__ == "__main__":
    unittest.main()
