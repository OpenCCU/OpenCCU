#!/usr/bin/env python3
"""Guard the rpi3 recovery initrd relocation cap."""
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
RPI3_BOOT_CMD = ROOT / "buildroot-external/board/rpi3/boot.cmd"


class RecoveryConfigTest(unittest.TestCase):
    def test_rpi3_recovery_caps_initrd_relocation(self):
        boot_cmd = RPI3_BOOT_CMD.read_text()
        self.assertIn('setenv initrd_high "0x18000000"', boot_cmd)


if __name__ == "__main__":
    unittest.main()
