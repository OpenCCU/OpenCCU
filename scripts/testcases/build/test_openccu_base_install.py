#!/usr/bin/env python3
"""Check the real package install recipe with Buildroot's CMake build layout."""
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
PACKAGE = ROOT / "buildroot-external/package/openccu-base/openccu-base.mk"


class OpenCCUBaseInstallTest(unittest.TestCase):
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
