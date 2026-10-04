#!/usr/bin/env python3
"""Test the patched asset target's failure handling without Java or a compiler.

Usage: python3 test_devicetypes_assets.py OPENCCU_BASE_SOURCE
The source tree must have the Buildroot package patches applied already.
The strip stub tests error propagation, not the real stripper's correctness.
"""

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class DeviceTypesAssetsTest(unittest.TestCase):
    """Exercise the real CMake target with controlled generator results."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(
            prefix="openccu-devicetypes-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "source with spaces"
        self.devices = self.source / "src/devicetypes"
        self.build = self.root / "build with spaces"
        self.rootfs = self.build / "rootfs"
        self.devices.mkdir(parents=True)
        for name in ("CMakeLists.txt", "GenerateDeviceTypes.cmake"):
            shutil.copy2(BASE_SOURCE / "src/devicetypes" / name,
                         self.devices / name)
        for family in ("rftypes", "hs485types"):
            (self.devices / family).mkdir()
            for name in ("first.xml", "last.xml"):
                (self.devices / family / name).write_text("<device/>\n")
        (self.devices / "replaceMap").mkdir()
        (self.devices / "replaceMap/rfReplaceMap.xml").write_text("<map/>\n")
        for name in ("st_values.cgi", "st_values.js"):
            (self.devices / name).write_text("fixture\n")
        strip_script = '''#!/bin/sh
set -eu
if [ "${1-}" = "-jar" ]; then
  device="$3"
  output="$5"
else
  device="$1"
  output="$3"
fi
printf '%s\\n' "$device" >> "$CALL_LOG"
case "$device" in
  */"$FAIL_DEVICE")
    case "$MODE" in
      fail) exit 42 ;;
      partial) printf 'partial' > "$output"; exit 42 ;;
      empty) : > "$output"; exit 0 ;;
      missing) exit 0 ;;
    esac
    ;;
esac
printf 'generated\\n' > "$output"
'''
        java = self.source / "java stub"
        java.write_text(strip_script)
        java.chmod(0o755)
        strip = self.source / "build-tools/bidcos-devicetype-strip"
        strip.parent.mkdir()
        strip.write_text(strip_script)
        strip.chmod(0o755)
        (self.source / "CMakeLists.txt").write_text('''\
cmake_minimum_required(VERSION 3.20)
project(DeviceTypesFailureTest NONE)
set(ROOTFS_DIR "${CMAKE_BINARY_DIR}/rootfs")
set(OPENCCU_JAVA_EXECUTABLE "${CMAKE_SOURCE_DIR}/java stub")
add_subdirectory(src/devicetypes)
''')
        configured = subprocess.run(
            [CMAKE, "-S", str(self.source), "-B", str(self.build)],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            check=False,
        )
        self.assertEqual(configured.returncode, 0, configured.stdout)

    def build_assets(self, mode="ok", family="rftypes"):
        log = self.root / "calls.log"
        log.write_text("")
        env = dict(os.environ, MODE=mode,
                   FAIL_DEVICE=f"{family}/first.xml", CALL_LOG=str(log))
        result = subprocess.run(
            [CMAKE, "--build", str(self.build),
             "--target", "devicetypes-assets"],
            env=env, text=True, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
        return result, log.read_text().splitlines()

    def test_all_outputs_generated(self):
        result, calls = self.build_assets()
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(len(calls), 4)
        for family in ("rftypes", "hs485types"):
            for name in ("first.xml", "last.xml"):
                output = self.rootfs / "firmware" / family / name
                self.assertEqual(output.read_text(), "generated\n")
        self.assertFalse(list(self.rootfs.rglob("*.tmp")))

    def test_each_failure_stops_before_next_device(self):
        for family in ("rftypes", "hs485types"):
            for mode in ("fail", "partial", "empty", "missing"):
                with self.subTest(family=family, mode=mode):
                    output = self.rootfs / "firmware" / family / "first.xml"
                    output.parent.mkdir(parents=True, exist_ok=True)
                    output.write_text("previous valid device\n")
                    # A stale temporary file must not mask absent new output.
                    Path(str(output) + ".tmp").write_text("stale temporary\n")
                    result, calls = self.build_assets(mode, family)
                    self.assertNotEqual(result.returncode, 0, result.stdout)
                    self.assertTrue(calls[-1].endswith(f"/{family}/first.xml"))
                    self.assertEqual(output.read_text(),
                                     "previous valid device\n")
                    self.assertFalse(Path(str(output) + ".tmp").exists())

    def test_empty_source_family_rejected(self):
        for path in (self.devices / "rftypes").glob("*.xml"):
            path.unlink()
        result, calls = self.build_assets()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertFalse(calls)

    def test_success_after_failure(self):
        result, _ = self.build_assets("partial")
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.test_all_outputs_generated()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    args = parser.parse_args()
    BASE_SOURCE = args.source.resolve()
    CMAKE = os.environ.get("CMAKE", "cmake")
    unittest.main(argv=[__file__], verbosity=2)
