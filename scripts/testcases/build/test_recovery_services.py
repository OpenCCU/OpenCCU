#!/usr/bin/env python3
"""Exercise shared init scripts without touching host services or configuration."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
PACKAGE = ROOT / "buildroot-external/package/openccu-base"


class RecoveryServicesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="recovery-services-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in ("etc/config", "etc/default", "var/run", "bin"):
            (self.root / name).mkdir(parents=True)
        (self.root / "var/rf_address").write_text("123456")
        (self.root / "var/board_serial").write_text("TEST123456")
        self.log = self.root / "calls"
        self.log.write_text("")
        for name in ("start-stop-daemon", "chgrp"):
            mock = self.root / "bin" / name
            mock.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >>"$CALL_LOG"\n')
            mock.chmod(0o755)
        self.env = dict(os.environ, CALL_LOG=str(self.log),
                        PATH=str(self.root / "bin") + ":" + os.environ["PATH"])

    def run_init(self, name, recovery):
        policy = self.root / "etc/default/openccu-base"
        value = "no" if recovery else "yes"
        policy.write_text(f"OPENCCU_BASE_SERVICE_USERS={value}\n"
                          f"OPENCCU_BASE_CONFIG_INIT={value}\n")
        script = (PACKAGE / name).read_text()
        script = script.replace("/etc/", str(self.root / "etc") + "/")
        script = script.replace("/var/", str(self.root / "var") + "/")
        script = script.replace("/proc/$$/oom_score_adj", str(self.root / "oom"))
        path = self.root / name
        path.write_text(script)
        subprocess.run(["bash", str(path), "start"], env=self.env,
                       check=True, capture_output=True, text=True)

    def test_recovery_does_not_create_persistent_configuration(self):
        self.run_init("S50eq3configd", True)
        self.assertEqual(list((self.root / "etc/config").iterdir()), [])
        self.assertEqual((self.root / "var/ids").read_text(),
                         "BidCoS-Address=123456\nSerialNumber=TEST123456\n")
        self.assertIn("-c root ", self.log.read_text())
        self.assertNotIn("eq3cfg", self.log.read_text())
        self.assertFalse((self.root / "oom").exists())

    def test_recovery_preserves_existing_keys_and_permissions(self):
        config = self.root / "etc/config/crypttool.cfg"
        config.write_text("existing secret\n")
        config.chmod(0o600)
        before = config.stat()
        self.run_init("S50eq3configd", True)
        after = config.stat()
        self.assertEqual(config.read_text(), "existing secret\n")
        self.assertEqual((before.st_mode, before.st_uid, before.st_gid, before.st_mtime_ns),
                         (after.st_mode, after.st_uid, after.st_gid, after.st_mtime_ns))
        self.assertNotIn("eq3cfg", self.log.read_text())

    def test_normal_system_initializes_configuration(self):
        self.run_init("S50eq3configd", False)
        self.assertTrue((self.root / "etc/config/ids").is_file())
        config = self.root / "etc/config/crypttool.cfg"
        self.assertEqual(config.stat().st_mode & 0o777, 0o640)
        self.assertIn("eq3cfg ", self.log.read_text())
        self.assertIn("-c eq3cfg:eq3cfg ", self.log.read_text())
        self.assertEqual((self.root / "oom").read_text(), "-900\n")

    def test_ssdp_recovery_user(self):
        self.run_init("S50ssdpd", True)
        self.assertIn("-c root ", self.log.read_text())
        self.assertFalse((self.root / "oom").exists())

    def test_ssdp_normal_user(self):
        self.run_init("S50ssdpd", False)
        self.assertIn("-c ssdp:ssdp ", self.log.read_text())
        self.assertEqual((self.root / "oom").read_text(), "-900\n")


if __name__ == "__main__":
    unittest.main()
