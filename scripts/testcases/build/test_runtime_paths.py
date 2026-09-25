#!/usr/bin/env python3
"""Check the shared runtime paths built for the main and recovery images."""
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
FINALIZE = ROOT / "buildroot-external/board/finalize-run.sh"


class RuntimePathsTest(unittest.TestCase):
    def test_buildroot_skeleton_and_existing_runtime_files(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp)
            (target / "run/lock").mkdir(parents=True)
            (target / "run/lock/installed").write_text("keep\n")
            (target / "var").mkdir()
            (target / "var/run").symlink_to("../run")

            for _ in range(2):
                subprocess.run([str(FINALIZE), str(target)], check=True)
                self.assertEqual((target / "run").readlink(), Path("var/run"))
                self.assertTrue((target / "var/run").is_dir())
                self.assertFalse((target / "var/run").is_symlink())
                self.assertEqual((target / "run/lock/installed").read_text(), "keep\n")
                self.assertTrue((target / "run/lock").samefile(target / "var/run/lock"))

    def test_unexpected_link_is_not_replaced(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp)
            (target / "var").mkdir()
            (target / "run").symlink_to("elsewhere")

            result = subprocess.run([str(FINALIZE), str(target)],
                                    capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual((target / "run").readlink(), Path("elsewhere"))


if __name__ == "__main__":
    unittest.main()
