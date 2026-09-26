#!/usr/bin/env python3
"""Check gateway updater status when its executable is present or absent."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "buildroot-external/overlay/base/etc/init.d/S58LGWFirmwareUpdate"


class GatewayUpdateTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="gateway-update-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "etc/config").mkdir(parents=True)
        (self.root / "bin").mkdir()
        (self.root / "etc/config/rfd.conf").write_text("Type = HMLGW2\n")
        (self.root / "etc/config/hs485d.conf").write_text("Type = HMWLGW\n")
        self.calls = self.root / "calls"
        logger = self.root / "bin/logger"
        logger.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >>"$CALLS"\n')
        logger.chmod(0o755)
        self.program = self.root / "bin/eq3configcmd"
        script = SCRIPT.read_text()
        script = script.replace("/var/hm_mode", str(self.root / "hm_mode"))
        script = script.replace("/etc/config/", str(self.root / "etc/config") + "/")
        script = script.replace("/bin/eq3configcmd", str(self.program))
        # Keep the gateway updates real while avoiding network-dependent polling.
        script = script.replace("if waitForIP; then", "if true; then")
        self.init = self.root / "S58LGWFirmwareUpdate"
        self.init.write_text(script)

    def start(self):
        result = subprocess.run(["bash", str(self.init), "start"],
                                env=dict(os.environ, HM_MODE="NORMAL", CALLS=str(self.calls),
                                         PATH=str(self.root / "bin") + ":" + os.environ["PATH"]),
                                text=True, capture_output=True, check=True, timeout=10)
        return result.stdout

    def test_missing_updater_does_not_report_firmware_updated(self):
        output = self.start()
        self.assertIn("not required", output)
        self.assertNotIn("Updating", output)
        self.assertFalse(self.calls.exists())

    def test_present_updater_runs_all_configured_gateway_updates(self):
        self.program.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >>"$CALLS"\n')
        self.program.chmod(0o755)
        output = self.start()
        self.assertTrue(output.endswith("OK\n"), output)
        calls = self.calls.read_text().splitlines()
        self.assertEqual(len(calls), 6)
        self.assertEqual(sum("update-coprocessor" in call for call in calls), 1)
        self.assertEqual(sum("update-lgw-firmware" in call for call in calls), 2)


if __name__ == "__main__":
    unittest.main()
