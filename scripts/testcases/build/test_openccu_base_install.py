#!/usr/bin/env python3
"""Check the real package install recipe with Buildroot's CMake build layout."""
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
PACKAGE = ROOT / "buildroot-external/package/openccu-base/openccu-base.mk"
MAIN_OVERLAY = ROOT / "buildroot-external/overlay/base/etc"


class OpenCCUBaseInstallTest(unittest.TestCase):
    def test_existing_default_directory_is_migrated_before_overlay(self):
        with tempfile.TemporaryDirectory(prefix="openccu-base-upgrade-") as tmp:
            root = Path(tmp)
            target = root / "target"
            old_defaults = target / "etc/default"
            old_defaults.mkdir(parents=True)
            (old_defaults / "openccu-base").write_text("obsolete policy\n")
            (old_defaults / "another-service").write_text("keep setting\n")
            persistent_defaults = target / "usr/local/etc/config/default"
            persistent_defaults.mkdir(parents=True)
            (persistent_defaults / "existing").write_text("existing setting\n")
            (target / "etc/config").symlink_to("../usr/local/etc/config")
            makefile = root / "Makefile"
            makefile.write_text(
                f"TARGET_DIR := {target}\n"
                "BR2_PACKAGE_OPENCCU_BASE_SYSTEM_INTEGRATION := y\n"
                "cmake-package =\n"
                f"include {PACKAGE}\n"
                ".PHONY: finalize\n"
                "finalize:\n"
                "\t$(OPENCCU_BASE_MIGRATE_DEFAULTS)\n")
            for _ in range(2):
                result = subprocess.run(["make", "-f", str(makefile), "finalize"],
                                        cwd=root, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                subprocess.run(["rsync", "-a", str(MAIN_OVERLAY) + "/",
                                str(target / "etc") + "/"],
                               check=True, capture_output=True, text=True)
                self.assertEqual((target / "etc/default").readlink(),
                                 Path("config/default"))
                self.assertFalse((target / "etc/default/openccu-base").exists())
                self.assertEqual((target / "etc/default/another-service").read_text(),
                                 "keep setting\n")
                self.assertEqual((target / "etc/default/existing").read_text(),
                                 "existing setting\n")

    def test_service_policy_and_main_default_overlay_link(self):
        for recovery in (False, True):
            with self.subTest(recovery=recovery), tempfile.TemporaryDirectory(
                    prefix="openccu-base-policy-") as tmp:
                root = Path(tmp)
                target = root / "target"
                (target / "etc").mkdir(parents=True)
                value = "no" if recovery else "yes"
                makefile = root / "Makefile"
                makefile.write_text(
                    f"TARGET_DIR := {target}\n"
                    f"OPENCCU_BASE_PKGDIR := {PACKAGE.parent}\n"
                    "INSTALL := install\n"
                    "sep := ;\n"
                    "BR2_PACKAGE_OPENCCU_BASE_EQ3CONFIGD := y\n"
                    "BR2_PACKAGE_OPENCCU_BASE_SSDPD := y\n"
                    "BR2_PACKAGE_OPENCCU_BASE_INIT_SCRIPTS := y\n"
                    f"BR2_PACKAGE_OPENCCU_BASE_SERVICE_USERS := {'' if recovery else 'y'}\n"
                    f"BR2_PACKAGE_OPENCCU_BASE_SYSTEM_INTEGRATION := {'' if recovery else 'y'}\n"
                    "cmake-package =\n"
                    f"include {PACKAGE}\n"
                    ".PHONY: install\n"
                    "install:\n"
                    "\t$(OPENCCU_BASE_INSTALL_SELECTED_CONFIG)\n"
                    "\t$(OPENCCU_BASE_INSTALL_INIT_SYSV)\n")
                result = subprocess.run(["make", "-f", str(makefile), "install"], cwd=root,
                                        capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                for name in ("S50eq3configd", "S50ssdpd"):
                    installed = target / "etc/init.d" / name
                    script = installed.read_text()
                    self.assertIn(f"OPENCCU_BASE_SERVICE_USERS={value}\n", script)
                    if name == "S50eq3configd":
                        self.assertIn(f"OPENCCU_BASE_CONFIG_INIT={value}\n", script)
                    else:
                        self.assertNotIn("OPENCCU_BASE_CONFIG_INIT", script)
                    self.assertEqual(installed.stat().st_mode & 0o777, 0o755)
                self.assertFalse((target / "etc/default").exists())
                if not recovery:
                    subprocess.run(["rsync", "-a", str(MAIN_OVERLAY) + "/",
                                    str(target / "etc") + "/"],
                                   check=True, capture_output=True, text=True)
                    self.assertEqual((target / "etc/default").readlink(),
                                     Path("config/default"))

    def test_runtime_installs_from_buildroot_build_directory(self):
        cmake = shutil.which("cmake")
        self.assertIsNotNone(cmake, "CMake is required to test Buildroot installation")
        with tempfile.TemporaryDirectory(prefix="openccu-base-install-") as tmp:
            root = Path(tmp)
            source = root / "openccu-base"
            source.mkdir()
            (source / "CMakeLists.txt").write_text(
                "cmake_minimum_required(VERSION 3.20)\n"
                "project(package_install NONE)\n"
                "install(FILES payload DESTINATION bin COMPONENT runtime)\n")
            (source / "payload").write_text("selected runtime file\n")
            build = source / "buildroot-build"
            subprocess.run([cmake, "-S", str(source), "-B", str(build)],
                           check=True, capture_output=True, text=True, timeout=30)
            self.assertTrue((build / "cmake_install.cmake").is_file())
            self.assertFalse((source / "build/cmake_install.cmake").exists())

            target = root / "target"
            makefile = root / "Makefile"
            makefile.write_text(
                f"OPENCCU_BASE_BUILDDIR := {build}\n"
                f"BR2_CMAKE := {cmake}\n"
                f"TARGET_DIR := {target}\n"
                "TARGET_MAKE_ENV :=\n"
                "INSTALL := install\n"
                "cmake-package =\n"
                f"include {PACKAGE}\n"
                ".PHONY: install\n"
                "install:\n"
                "\t$(OPENCCU_BASE_INSTALL_TARGET_CMDS)\n")
            subprocess.run(["make", "-f", str(makefile), "install"], cwd=root,
                           check=True, capture_output=True, text=True, timeout=30)
            self.assertEqual((target / "bin/payload").read_text(),
                             "selected runtime file\n")


if __name__ == "__main__":
    unittest.main()
