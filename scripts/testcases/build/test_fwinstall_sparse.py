#!/usr/bin/env python3
"""Check that the recovery firmware update unpacks disk images as sparse files.

The helper functions of fwinstall.sh are run with the tools of the host
(unzip, dd with conv=sparse) instead of the BusyBox applets of the recovery
system, so this tests the shell logic, not the BusyBox dd patch itself.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[3]
FWINSTALL = (ROOT / "buildroot-external/package/recovery-system/external/"
             "overlay/base/bin/fwinstall.sh")
MIB = 1024 * 1024
IMG = "OpenCCU-0.0.0-test.img"


def make_image(path):
    """A disk image of 64 MiB with only 3 MiB of non-zero data."""
    with open(path, "wb") as f:
        for offset in (0, 20 * MIB, 63 * MIB):
            f.seek(offset)
            f.write(os.urandom(MIB))
        f.truncate(64 * MIB)


@unittest.skipUnless(shutil.which("unzip") and shutil.which("bash"),
                     "unzip and bash are required")
class FwinstallSparseTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="fwinstall-sparse-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        # the functions of fwinstall.sh without its main body, with the
        # tools taken from PATH
        script = FWINSTALL.read_text().split("# main body starts here")[0]
        for tool in ("/usr/bin/unzip", "/bin/dd", "/bin/df"):
            script = script.replace(tool + " ", Path(tool).name + " ")
        self.funcs = self.root / "fw-funcs.sh"
        self.funcs.write_text(script)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.env = dict(os.environ,
                        PATH=str(self.bin) + ":" + os.environ["PATH"])

        self.image = self.root / IMG
        make_image(self.image)
        self.zip = self.root / "update.zip"
        with zipfile.ZipFile(self.zip, "w", zipfile.ZIP_DEFLATED) as z:
            z.write(self.image, IMG)
            z.writestr(IMG + ".sha256", "checksum  " + IMG + "\n")
            z.writestr("EULA.en", "eula\n")
        self.out = self.root / "out"
        self.out.mkdir()

    def call(self, *args):
        cmd = '. "$0"; "$@"'
        return subprocess.run(["bash", "-c", cmd, str(self.funcs), *args],
                              env=self.env, capture_output=True, text=True)

    def test_unzip_firmware_writes_sparse_image(self):
        result = self.call("unzip_firmware", str(self.zip), str(self.out))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        out = self.out / IMG
        self.assertEqual(out.read_bytes(), self.image.read_bytes())
        self.assertLess(out.stat().st_blocks * 512, 8 * MIB)
        self.assertTrue((self.out / (IMG + ".sha256")).is_file())
        self.assertTrue((self.out / "EULA.en").is_file())
        self.assertIn("bytes allocated", result.stdout)

    def test_unzip_firmware_without_image_extracts_all(self):
        with zipfile.ZipFile(self.zip, "w") as z:
            z.writestr("update_script", "#!/bin/sh\n")
        result = self.call("unzip_firmware", str(self.zip), str(self.out))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue((self.out / "update_script").is_file())

    def test_unzip_firmware_fails_on_corrupt_image(self):
        data = bytearray(self.zip.read_bytes())
        # corrupt the compressed data of the image (first entry)
        for i in range(2000, 2100):
            data[i] ^= 0xff
        self.zip.write_bytes(bytes(data))
        result = self.call("unzip_firmware", str(self.zip), str(self.out))
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("ERROR: (unzip " + IMG, result.stdout)
        self.assertFalse((self.out / IMG).exists())

    def test_write_sparse_falls_back_without_conv_sparse(self):
        dd = self.bin / "dd"
        dd.write_text('#!/bin/sh\ncase "$*" in *conv=sparse*) exit 1;; esac\n'
                      f'exec {shutil.which("dd")} "$@"\n')
        dd.chmod(0o755)
        result = self.call("unzip_firmware", str(self.zip), str(self.out))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        out = self.out / IMG
        self.assertEqual(out.read_bytes(), self.image.read_bytes())
        self.assertGreaterEqual(out.stat().st_blocks * 512, 64 * MIB)

    def test_required_size_uses_sparse_estimate(self):
        result = self.call("get_zip_required_size", str(self.zip))
        self.assertEqual(result.returncode, 0, result.stderr)
        other = len("checksum  " + IMG + "\n") + len("eula\n")
        expected = 3 * self.zip.stat().st_size + other
        self.assertEqual(int(result.stdout), expected)
        self.assertLess(expected, 64 * MIB)

    def test_sparse_estimate_is_capped_at_full_size(self):
        result = self.call("get_sparse_required_size", "1000", "2500")
        self.assertEqual(result.stdout.strip(), "2500")
        result = self.call("get_sparse_required_size", "1000", "5000")
        self.assertEqual(result.stdout.strip(), "3000")


if __name__ == "__main__":
    unittest.main()
