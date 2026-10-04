#!/usr/bin/env python3
"""Exercise RF reset-marker handling with simulated modules and updater calls."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "buildroot-external/overlay/base/etc/init.d/S47InitRFHardware"
HMIP_MODULES = ("RPI-RF-MOD", "HMIP-RFUSB", "HMIP-RFUSB-TK")


class FactoryResetTest(unittest.TestCase):
    def check_reset(self, hardware, updater, requested=True):
        """Run the real parameter-query loop and cleanup, without hardware access."""
        with tempfile.TemporaryDirectory(prefix="rf-reset-") as temp:
            root = Path(temp)
            marker = root / "reset-request"
            jar = root / "updater.jar"
            calls = root / "calls"
            if requested:
                marker.touch()
            if updater:
                jar.touch()
            source = SCRIPT.read_text()
            start = source.index("query_rf_parameters() {")
            # Stop after marker cleanup, before unrelated LED-driver setup.
            end = source.index("\n  #####################################", start)
            query = source[start:end] + "\n}\n"
            query = query.replace("/usr/local/.doCoproFactoryReset", str(marker))
            query = query.replace("/opt/HmIP/hmip-copro-update.jar", str(jar))
            query = query.replace("/bin/detect_radio_module", "detect_radio_module")
            query = query.replace("/usr/bin/timeout 20 /opt/java/bin/java", "update_copro")
            query = query.replace("/sys/", str(root / "sys") + "/")
            harness = root / "query.sh"
            harness.write_text('''
detect_radio_module() { printf '%s SERIAL SGTIN 0x123456 0x654321 1.0\\n' "$HARDWARE"; }
update_copro() { printf '%s\\n' "$*" >>"$CALLS"; }
sleep() { :; }
RF_DEVNODES=null
''' + query + "\nquery_rf_parameters\n")
            subprocess.run(["bash", str(harness)], check=True, capture_output=True,
                           text=True, timeout=5,
                           env=dict(os.environ, HARDWARE=hardware, CALLS=str(calls)))
            return marker.exists(), calls.read_text().splitlines() if calls.exists() else []

    def test_bidcos_request_is_consumed_with_or_without_updater(self):
        """HM-MOD-RPI-PCB requires no Java updater to consume its reset marker."""
        for updater in (False, True):
            with self.subTest(updater=updater):
                self.assertEqual(self.check_reset("HM-MOD-RPI-PCB", updater), (False, []))

    def test_hmip_without_updater_preserves_request(self):
        """An HmIP request must remain pending when its updater is unavailable."""
        for hardware in HMIP_MODULES:
            with self.subTest(hardware=hardware):
                self.assertEqual(self.check_reset(hardware, False), (True, []))

    def test_hmip_with_updater_runs_reset_and_consumes_request(self):
        """Supported HmIP modules invoke the updater once before cleanup."""
        for hardware in HMIP_MODULES:
            with self.subTest(hardware=hardware):
                pending, calls = self.check_reset(hardware, True)
                self.assertFalse(pending)
                self.assertEqual(len(calls), 1)
                self.assertIn("-p /dev/null -r", calls[0])

    def test_no_request_never_runs_updater(self):
        """Installing the updater alone must not trigger a factory reset."""
        for hardware in ("HM-MOD-RPI-PCB", *HMIP_MODULES):
            with self.subTest(hardware=hardware):
                self.assertEqual(self.check_reset(hardware, True, requested=False), (False, []))


if __name__ == "__main__":
    unittest.main()
