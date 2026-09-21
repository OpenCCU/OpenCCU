#!/usr/bin/env python3
"""Guard recovery config choices that keep Pi Zero 2 W recovery boots small."""
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
RPI3_RECOVERY_CONFIG = ROOT / "buildroot-external/package/recovery-system/external/configs/recovery_rpi3.config"


class RecoveryConfigTest(unittest.TestCase):
    def test_rpi3_recovery_does_not_enable_multilib32(self):
        lines = set(RPI3_RECOVERY_CONFIG.read_text().splitlines())
        self.assertNotIn('BR2_ROOTFS_LIB32_DIR="lib32"', lines)
        self.assertNotIn("BR2_PACKAGE_MULTILIB32=y", lines)
        self.assertFalse(any(line.startswith("BR2_PACKAGE_MULTILIB32_CONFIG_FRAGMENT_FILE=")
                             for line in lines))


if __name__ == "__main__":
    unittest.main()
