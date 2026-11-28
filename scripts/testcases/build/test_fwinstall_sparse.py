#!/usr/bin/env python3
"""Check that the recovery firmware update unpacks disk images as sparse files.

The helper functions of fwinstall.sh are run with the tools of the host
(unzip, dd with conv=sparse) instead of the BusyBox applets of the recovery
system, so this tests the shell logic, not the BusyBox dd patch itself.
"""
import os
from pathlib import Path
import shutil
import stat
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

    def call(self, *args, prelude=""):
        cmd = '. "$0"; ' + prelude + '\n"$@"'
        return subprocess.run(["bash", "-c", cmd, str(self.funcs), *args],
                              env=self.env, capture_output=True, text=True)

    def make_zip(self, name):
        with zipfile.ZipFile(self.zip, "w", zipfile.ZIP_DEFLATED) as z:
            z.write(self.image, name)
            z.writestr("EULA.en", "eula\n")

    def mock_dd_out_of_space(self, failures):
        """dd failing with ENOSPC for the first `failures` image writes."""
        count = self.root / "dd-count"
        count.write_text("0")
        dd = self.bin / "dd"
        dd.write_text(
            '#!/bin/sh\n'
            'case "$*" in *of=/dev/null*) ;; *)\n'
            f'  n=$(cat {count}); echo $((n + 1)) >{count}\n'
            f'  if [ "$n" -lt {failures} ]; then cat >/dev/null\n'
            '    echo "dd: error writing: No space left on device" >&2\n'
            '    exit 1; fi;;\n'
            'esac\n'
            f'exec {shutil.which("dd")} "$@"\n')
        dd.chmod(0o755)

    def test_unzip_firmware_writes_sparse_image(self):
        result = self.call("unzip_firmware", str(self.zip), str(self.out))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        out = self.out / IMG
        self.assertEqual(out.read_bytes(), self.image.read_bytes())
        self.assertLess(out.stat().st_blocks * 512, 8 * MIB)
        self.assertTrue((self.out / (IMG + ".sha256")).is_file())
        self.assertTrue((self.out / "EULA.en").is_file())
        self.assertIn("bytes allocated", result.stdout)

    def test_unzip_firmware_keeps_name_with_spaces_and_path(self):
        name = "images/OpenCCU test image.img"
        self.make_zip(name)
        result = self.call("unzip_firmware", str(self.zip), str(self.out))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        out = self.out / name
        self.assertEqual(out.read_bytes(), self.image.read_bytes())
        self.assertLess(out.stat().st_blocks * 512, 8 * MIB)
        self.assertTrue((self.out / "EULA.en").is_file())

    def test_unzip_firmware_refuses_path_outside_directory(self):
        self.make_zip("../evil.img")
        result = self.call("unzip_firmware", str(self.zip), str(self.out))
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("invalid path", result.stdout)
        self.assertFalse((self.root / "evil.img").exists())

    def test_unzip_firmware_refuses_symlink_in_image_path(self):
        outside = self.root / "outside"
        outside.mkdir()
        with zipfile.ZipFile(self.zip, "w") as z:
            link = zipfile.ZipInfo("images")
            link.create_system = 3
            link.external_attr = (stat.S_IFLNK | 0o777) << 16
            z.writestr(link, str(outside))
            z.write(self.image, "images/" + IMG)
        result = self.call("unzip_firmware", str(self.zip), str(self.out))
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("symlink in path", result.stdout)
        self.assertEqual(list(outside.iterdir()), [])

    def test_unzip_firmware_escapes_pattern_characters(self):
        name = "OpenCCU[1]*?.img"
        with zipfile.ZipFile(self.zip, "w", zipfile.ZIP_DEFLATED) as z:
            z.write(self.image, name)
            z.writestr("OpenCCU1.img", b"wrong member")
        result = self.call("unzip_firmware", str(self.zip), str(self.out))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((self.out / name).read_bytes(),
                         self.image.read_bytes())
        # the other member is extracted as it is, not excluded
        self.assertEqual((self.out / "OpenCCU1.img").read_bytes(),
                         b"wrong member")

    def test_out_of_space_is_retried_after_userfs_expansion(self):
        self.mock_dd_out_of_space(1)
        expand = ('expand_userfs_to_max() { echo -n "EXPANDED, "; return 0; }'
                  f'; TMPDIR={self.out}')
        result = self.call("unzip_firmware_retry", str(self.zip),
                           str(self.out), prelude=expand)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("No space left", result.stdout)
        self.assertIn("EXPANDED", result.stdout)
        self.assertIn("retrying", result.stdout)
        self.assertNotIn("ERROR", result.stdout)
        self.assertEqual((self.out / IMG).read_bytes(),
                         self.image.read_bytes())

    def test_out_of_space_without_userfs_expansion_fails(self):
        self.mock_dd_out_of_space(2)
        expand = ('expand_userfs_to_max() { echo -n "MAXED, "; return 1; }'
                  f'; TMPDIR={self.out}')
        result = self.call("unzip_firmware_retry", str(self.zip),
                           str(self.out), prelude=expand)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("MAXED", result.stdout)
        self.assertNotIn("retrying", result.stdout)
        self.assertIn("ERROR: (not enough free space", result.stdout)
        self.assertFalse((self.out / IMG).exists())

    def test_gunzip_out_of_space_is_retried_once(self):
        gz = self.root / "rootfs.ext4.gz"
        subprocess.run(["sh", "-c", f'gzip -c "{self.image}" >"{gz}"'],
                       check=True)
        self.mock_dd_out_of_space(2)
        expand = ('expand_userfs_to_max() { echo -n "EXPANDED, "; return 0; }'
                  f'; TMPDIR={self.out}')
        out = self.out / "rootfs.ext4"
        # the second failure is final: the userfs is expanded only once
        result = self.call("gunzip_firmware_retry", str(gz), str(out),
                           prelude=expand)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertEqual(result.stdout.count("EXPANDED"), 1)
        self.assertIn("ERROR: (not enough free space", result.stdout)
        self.assertFalse(out.exists())

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

    def test_required_size_without_sparse_support_is_full_size(self):
        dd = self.bin / "dd"
        dd.write_text('#!/bin/sh\ncase "$*" in *conv=sparse*) exit 1;; esac\n'
                      f'exec {shutil.which("dd")} "$@"\n')
        dd.chmod(0o755)
        result = self.call("get_zip_required_size", str(self.zip))
        self.assertEqual(result.returncode, 0, result.stderr)
        with zipfile.ZipFile(self.zip) as z:
            full = sum(i.file_size for i in z.infolist())
        self.assertEqual(int(result.stdout), full)

    def test_sparse_estimate_is_capped_at_full_size(self):
        result = self.call("get_sparse_required_size", "1000", "2500")
        self.assertEqual(result.stdout.strip(), "2500")
        result = self.call("get_sparse_required_size", "1000", "5000")
        self.assertEqual(result.stdout.strip(), "3000")


if __name__ == "__main__":
    unittest.main()
