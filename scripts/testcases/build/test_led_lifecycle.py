#!/usr/bin/env python3
"""Check driver ownership and init failures without touching real modules/sysfs."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
HELPERS = [ROOT / "buildroot-external/overlay/base/bin/rpi-rf-mod-led-driver",
           ROOT / "buildroot-external/package/recovery-system/external/overlay/base/bin/rpi-rf-mod-led-driver"]
INIT = ROOT / "buildroot-external/package/openccu-base/S00hss_led"


class LedLifecycleTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="led-lifecycle-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.modules = self.root / "modules"
        self.modules.mkdir()
        self.state = self.root / "state"
        self.log = self.root / "calls"
        self.log.write_text("")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        mock = '''import os, pathlib, sys
module = sys.argv[2] if pathlib.Path(sys.argv[0]).name == "modprobe" else sys.argv[1]
operation = pathlib.Path(sys.argv[0]).name
with open(os.environ["MOCK_LOG"], "a") as log:
    log.write(operation + " " + module + "\\n")
if os.environ.get("MOCK_FAIL") in (module, operation):
    sys.exit(1)
path = pathlib.Path(os.environ["MOCK_MODULES"]) / module
if operation == "modprobe":
    path.mkdir(exist_ok=True)
else:
    path.rmdir()
'''
        for name in ("modprobe", "rmmod"):
            path = self.bin / name
            path.write_text("#!" + sys.executable + "\n" + mock)
            path.chmod(0o755)
        self.env = dict(os.environ, PATH=str(self.bin) + ":" + os.environ["PATH"],
                        MOCK_MODULES=str(self.modules), MOCK_LOG=str(self.log), MOCK_FAIL="")
        self.helper = self.root / "helper"
        self.helper.write_text(HELPERS[0].read_text().replace("/sys/module/", str(self.modules) + "/")
                               .replace("/run/rpi-rf-mod-led-driver", str(self.state)))

    def run_helper(self, action, check=True):
        args = ["/bin/sh", str(self.helper), action]
        if action == "load":
            args += ["1", "2", "3"]
        return subprocess.run(args, env=self.env, check=check, text=True, capture_output=True)

    def test_recovery_helper_matches_normal(self):
        self.assertEqual(HELPERS[0].read_bytes(), HELPERS[1].read_bytes())

    def test_preexisting_modules_are_never_owned_or_removed(self):
        for module in ("rpi_rf_mod_rgb", "rpi_rf_mod_led"):
            with self.subTest(module=module):
                (self.modules / module).mkdir()
                self.run_helper("load")
                self.run_helper("unload")
                self.assertTrue((self.modules / module).is_dir())
                self.assertFalse((self.state / module).exists())
                self.assertEqual(self.log.read_text(), "")
                (self.modules / module).rmdir()

    def test_own_module_repeated_load_and_unload(self):
        self.run_helper("load")
        self.run_helper("load")
        self.assertTrue((self.state / "rpi_rf_mod_rgb").is_file())
        self.run_helper("unload")
        self.run_helper("unload")
        self.assertEqual(self.log.read_text(), "modprobe rpi_rf_mod_rgb\nrmmod rpi_rf_mod_rgb\n")
        self.assertFalse((self.state / "rpi_rf_mod_rgb").exists())

    def test_legacy_fallback_is_owned(self):
        self.env["MOCK_FAIL"] = "rpi_rf_mod_rgb"
        self.run_helper("load")
        self.assertTrue((self.state / "rpi_rf_mod_led").is_file())
        self.assertFalse((self.state / "rpi_rf_mod_rgb").exists())
        self.run_helper("unload")
        self.assertTrue(self.log.read_text().endswith("rmmod rpi_rf_mod_led\n"))

    def test_failed_load_does_not_claim_ownership(self):
        self.env["MOCK_FAIL"] = "modprobe"
        self.assertNotEqual(self.run_helper("load", check=False).returncode, 0)
        self.run_helper("unload")
        self.assertNotIn("rmmod", self.log.read_text())
        self.assertEqual(list(self.state.iterdir()), [])

    def test_failed_unload_keeps_marker_for_retry(self):
        self.run_helper("load")
        self.env["MOCK_FAIL"] = "rmmod"
        self.assertNotEqual(self.run_helper("unload", check=False).returncode, 0)
        self.assertTrue((self.state / "rpi_rf_mod_rgb").is_file())
        self.assertFalse((self.state / "lock").exists())
        self.env["MOCK_FAIL"] = ""
        self.run_helper("unload")
        self.assertFalse((self.state / "rpi_rf_mod_rgb").exists())

    def test_external_reload_invalidates_marker(self):
        self.run_helper("load")
        (self.modules / "rpi_rf_mod_rgb").rename(self.modules / "old-instance")
        (self.modules / "rpi_rf_mod_rgb").mkdir()
        self.run_helper("unload")
        self.assertTrue((self.modules / "rpi_rf_mod_rgb").is_dir())
        self.assertFalse((self.state / "rpi_rf_mod_rgb").exists())
        self.assertNotIn("rmmod", self.log.read_text())

    def test_concurrent_call_does_not_take_the_lock(self):
        (self.state / "lock").mkdir(parents=True)
        result = self.run_helper("load", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("locked", result.stderr)
        self.assertTrue((self.state / "lock").is_dir())
        self.assertEqual(self.log.read_text(), "")

    def test_early_start_uses_version_platform_without_host_initialization(self):
        script = self.root / "init"
        daemon = self.root / "hss_led"
        client = self.root / "hss_ledctl"
        version = self.root / "VERSION"
        runtime = self.root / "runtime"
        for program in (daemon, client):
            program.write_text("#!/bin/sh\nexit 0\n")
            program.chmod(0o755)
        for name in ("start-stop-daemon", "chown", "chmod"):
            mock = self.bin / name
            mock.write_text("#!" + sys.executable + "\nimport json, os, sys\n"
                            "with open(os.environ['MOCK_LOG'], 'a') as f:\n"
                            "    f.write(json.dumps(sys.argv) + '\\n')\n")
            mock.chmod(0o755)
        script.write_text(INIT.read_text().replace("/bin/$DAEMON", str(daemon))
                          .replace("/bin/hss_ledctl", str(client)).replace("/VERSION", str(version))
                          .replace("/var/run/hss_led", str(runtime))
                          .replace("/sys/class/leds/*", str(self.root / "no-leds/*")))
        for platform, user in (("rpi3", "hssled"), ("tinkerboard2", "hssled"),
                               ("oci_amd64", "root"), ("lxc", "root")):
            with self.subTest(platform=platform):
                version.write_text('PLATFORM="' + platform + '"\n')
                self.log.write_text("")
                subprocess.run(["/bin/sh", str(script), "start"], env=self.env, check=True,
                               capture_output=True, text=True)
                calls = [json.loads(line) for line in self.log.read_text().splitlines()]
                command = next(args for args in calls if Path(args[0]).name == "start-stop-daemon")
                self.assertEqual(command[command.index("-c") + 1], user)
                self.assertEqual(command[-3:], ["--", "-l", "6"])
        self.assertEqual(INIT.name, "S00hss_led")
        for later in ("S01InitHost", "S01USBGadgetMode", "S02InitRTC"):
            self.assertLess(INIT.name, later)

    def test_missing_daemon_and_missing_client_are_errors(self):
        script = self.root / "init"
        daemon = self.root / "hss_led"
        client = self.root / "hss_ledctl"
        script.write_text(INIT.read_text().replace("/bin/$DAEMON", str(daemon))
                          .replace("/bin/hss_ledctl", str(client)))
        for missing in ("hss_led", "hss_ledctl"):
            with self.subTest(missing=missing):
                result = subprocess.run(["/bin/sh", str(script), "start"], text=True, capture_output=True)
                self.assertEqual(result.returncode, 1)
                self.assertIn(missing + " is missing or not executable", result.stderr)
                self.assertFalse(self.state.exists())
            daemon.write_text("#!/bin/sh\nexit 0\n")
            daemon.chmod(0o755)


if __name__ == "__main__":
    unittest.main()
