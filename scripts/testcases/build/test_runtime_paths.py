#!/usr/bin/env python3
"""Check the common board post-build script for main and recovery images."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
MAIN = ROOT / "buildroot-external/board/post-build.sh"
RECOVERY = ROOT / "buildroot-external/package/recovery-system/external/board/post-build.sh"
CONFIG = ROOT / "buildroot-external/package/recovery-system/external/Buildroot.config"


class RuntimePathsTest(unittest.TestCase):
    def prepare(self, target):
        (target / "run/lock").mkdir(parents=True)
        (target / "run/lock/installed").write_text("keep\n")
        (target / "var").mkdir()
        (target / "var/run").symlink_to("../run")
        (target / "etc/init.d").mkdir(parents=True)
        for name in ("S10udevd", "S50crond", "S35iptables"):
            (target / "etc/init.d" / name).touch()

    def run_post_build(self, script, target):
        env = os.environ | dict(TARGET_DIR=str(target), BR2_CONFIG=str(CONFIG),
                                PRODUCT="OpenCCU", PRODUCT_PLATFORM="rpi3",
                                PRODUCT_VERSION="main-version",
                                BR2_RECOVERY_SYSTEM_VERSION="recovery-version")
        return subprocess.run([str(script)], env=env, capture_output=True, text=True)

    def test_main_and_recovery_preserve_the_runtime_layout(self):
        for script, recovery in ((MAIN, False), (RECOVERY, True)):
            with self.subTest(recovery=recovery), tempfile.TemporaryDirectory() as temp:
                target = Path(temp)
                self.prepare(target)
                (target / "etc/network").mkdir()
                (target / "etc/network/interfaces").write_text("eQ3-CCU3\n")
                if recovery:
                    (target / "etc/product").write_text("DHCP_VENDOR_ID=recovery-vendor\n")
                for _ in range(2):
                    result = self.run_post_build(script, target)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual((target / "run").readlink(), Path("var/run"))
                    self.assertFalse((target / "var/run").is_symlink())
                    self.assertEqual((target / "run/lock/installed").read_text(), "keep\n")
                    self.assertTrue((target / "run/lock").samefile(target / "var/run/lock"))
                version = "recovery-version" if recovery else "main-version"
                self.assertIn(f"VERSION={version}\n", (target / "VERSION").read_text())
                self.assertEqual((target / "etc/init.d/S50crond").exists(), recovery)
                self.assertEqual((target / "boot/VERSION").is_symlink(), not recovery)
                self.assertTrue((target / "etc/init.d/S00udevd").exists())
                self.assertFalse((target / "etc/init.d/S35iptables").exists())
                if recovery:
                    self.assertEqual((target / "etc/network/interfaces").read_text(),
                                     "recovery-vendor\n")

    def test_unexpected_link_is_not_replaced(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp)
            self.prepare(target)
            (target / "run/lock/installed").unlink()
            (target / "run/lock").rmdir()
            (target / "run").rmdir()
            (target / "run").symlink_to("elsewhere")

            result = self.run_post_build(MAIN, target)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual((target / "run").readlink(), Path("elsewhere"))


if __name__ == "__main__":
    unittest.main()
