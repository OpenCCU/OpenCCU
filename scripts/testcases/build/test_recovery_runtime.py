#!/usr/bin/env python3
"""Exercise recovery runtime layout using the real post-build and boot scripts."""
import json
import os
from pathlib import Path
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
RECOVERY = ROOT / "buildroot-external/package/recovery-system"
EXTERNAL = RECOVERY / "external"
POST_BUILD = EXTERNAL / "board/post-build.sh"
RCS = EXTERNAL / "overlay/base/etc/init.d/rcS"
FSTAB = EXTERNAL / "overlay/base/etc/fstab"
LED_PACKAGE = ROOT / "buildroot-external/package/openccu-base"


class RecoveryRuntimeTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="recovery-runtime-")
        self.addCleanup(self.temp.cleanup)
        self.target = Path(self.temp.name) / "target"
        (self.target / "etc/init.d").mkdir(parents=True)
        # Layout supplied by Buildroot's common and sysv skeletons.
        (self.target / "run/lock").mkdir(parents=True)
        (self.target / "var").mkdir()
        (self.target / "var/run").symlink_to("../run")
        self.env = dict(os.environ, TARGET_DIR=str(self.target),
                        BR2_RECOVERY_SYSTEM_VERSION="test", PRODUCT="OpenCCU",
                        PRODUCT_PLATFORM="tinkerboard2")

    def post_build(self, success=True):
        result = subprocess.run(["/bin/sh", str(POST_BUILD)], env=self.env,
                                capture_output=True, text=True)
        if success:
            self.assertEqual(result.returncode, 0, result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("ERROR: recovery", result.stderr)
        return result

    def test_skeleton_layout_and_incremental_build(self):
        self.post_build()
        self.assertEqual(os.readlink(self.target / "run"), "var/run")
        self.assertFalse((self.target / "var/run").is_symlink())
        marker = self.target / "var/run/state"
        marker.write_text("keep")
        self.assertTrue(marker.samefile(self.target / "run/state"))
        self.post_build()
        self.assertEqual((self.target / "run/state").read_text(), "keep")

    def test_absolute_skeleton_link(self):
        (self.target / "var/run").unlink()
        (self.target / "var/run").symlink_to("/run")
        self.post_build()
        self.assertTrue((self.target / "run").samefile(self.target / "var/run"))

    def test_missing_run_directory(self):
        shutil.rmtree(self.target / "run")
        self.post_build()
        self.assertTrue((self.target / "run").samefile(self.target / "var/run"))

    def test_reapplied_skeleton_link_does_not_create_a_loop(self):
        self.post_build()
        (self.target / "var/run").rmdir()
        (self.target / "var/run").symlink_to("../run")
        self.post_build()
        self.assertTrue((self.target / "run").samefile(self.target / "var/run"))

    def test_runtime_files_are_not_discarded(self):
        for relative in ("run/state", "run/lock/held"):
            with self.subTest(path=relative):
                path = self.target / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("preserve")
                self.post_build(success=False)
                self.assertEqual(path.read_text(), "preserve")
                path.unlink()

    def test_unexpected_symlinks_are_not_followed(self):
        for relative in ("run", "var/run", "var"):
            with self.subTest(path=relative):
                path = self.target / relative
                if path.is_symlink():
                    path.unlink()
                else:
                    shutil.rmtree(path)
                outside = Path(self.temp.name) / "outside"
                outside.mkdir(exist_ok=True)
                marker = outside / "keep"
                marker.write_text("preserve")
                path.symlink_to(outside)
                result = subprocess.run(["/bin/sh", str(POST_BUILD)], env=self.env,
                                        capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertTrue(path.is_symlink())
                self.assertEqual(marker.read_text(), "preserve")
                path.unlink()
                path.mkdir()

    def test_boot_prepares_shared_runtime_before_services(self):
        self.post_build()
        # Run the actual early rcS section; simulate the fresh /var mount.
        # Never execute mount/fsck or touch the host's runtime directories.
        mock = Path(self.temp.name) / "boot-command"
        log = Path(self.temp.name) / "boot.log"
        mock.write_text("#!" + sys.executable + "\n"
                        "import json, os, pathlib, shutil, sys\n"
                        "with open(os.environ['BOOT_LOG'], 'a') as f:\n"
                        "    f.write(json.dumps(sys.argv[1:]) + '\\n')\n"
                        "if sys.argv[1] == 'mount':\n"
                        "    var = pathlib.Path(os.environ['TARGET_DIR']) / 'var'\n"
                        "    shutil.rmtree(var)\n"
                        "    var.mkdir()\n")
        mock.chmod(0o755)
        prefix = RCS.read_text().split("# create ld.so.cache file", 1)[0]
        self.assertIn("/bin/mount -a", prefix)
        for command in ("fsck", "mount", "chown"):
            binary = "/sbin/fsck" if command == "fsck" else "/bin/" + command
            prefix = prefix.replace(binary, str(mock) + " " + command)
        prefix = prefix.replace("/var/", str(self.target / "var") + "/")
        subprocess.run(["/bin/sh", "-c", prefix],
                       env=dict(self.env, BOOT_LOG=str(log)), check=True)
        self.assertEqual([call[0] for call in map(json.loads, log.read_text().splitlines())],
                         ["fsck", "mount", "chown"])
        self.assertIn(["chown", "0:0", str(self.target / "var/run")],
                      [json.loads(line) for line in log.read_text().splitlines()])
        self.assertEqual(stat.S_IMODE((self.target / "var/run").stat().st_mode), 0o755)
        init_path = re.search(r'^RUNTIME="([^"]+)"$',
                              (LED_PACKAGE / "S00hss_led").read_text(), re.MULTILINE).group(1)
        daemon_path = re.search(r'^\+static std::string runtime = "([^"]+)";',
                                (LED_PACKAGE / "0001-OpenCCU-Base-led-service.patch").read_text(),
                                re.MULTILINE).group(1)
        init_runtime = self.target / init_path.lstrip("/")
        daemon_runtime = self.target / daemon_path.lstrip("/")
        init_runtime.mkdir(mode=0o755)
        self.assertTrue(init_runtime.samefile(daemon_runtime))
        (init_runtime / "state").write_text("shared")
        self.assertEqual((daemon_runtime / "state").read_text(), "shared")

    def test_fstab_does_not_overmount_run(self):
        entries = [line.split() for line in FSTAB.read_text().splitlines()
                   if line.strip() and not line.lstrip().startswith("#")]
        self.assertFalse(any(entry[1] in ("/run", "/var/run") for entry in entries))
        var = next(entry for entry in entries if entry[1] == "/var")
        self.assertEqual(var[2], "tmpfs")
        self.assertTrue({"noexec", "nosuid", "nodev"}.issubset(var[3].split(",")))


if __name__ == "__main__":
    unittest.main()
