#!/usr/bin/env python3
"""Guard recovery config choices that keep recovery boots small and portable."""
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
RECOVERY_CONFIG_DIR = ROOT / "buildroot-external/package/recovery-system/external/configs"
RPI3_BOOT_CMD = ROOT / "buildroot-external/board/rpi3/boot.cmd"


class RecoveryConfigTest(unittest.TestCase):
    def test_recovery_configs_do_not_enable_multilib32(self):
        for config in RECOVERY_CONFIG_DIR.glob("recovery_*.config"):
            with self.subTest(config=config.name):
                lines = set(config.read_text().splitlines())
                self.assertNotIn('BR2_ROOTFS_LIB32_DIR="lib32"', lines)
                self.assertNotIn("BR2_PACKAGE_MULTILIB32=y", lines)
                self.assertFalse(any(
                    line.startswith("BR2_PACKAGE_MULTILIB32_CONFIG_FRAGMENT_FILE=")
                    for line in lines))

    def test_rpi3_recovery_caps_initrd_relocation(self):
        boot_cmd = RPI3_BOOT_CMD.read_text()
        self.assertIn('setenv initrd_high "0x18000000"', boot_cmd)


if __name__ == "__main__":
    unittest.main()
