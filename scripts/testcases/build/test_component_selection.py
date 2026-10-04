#!/usr/bin/env python3
"""Check real Kconfig defaults and post-overlay service pruning."""
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

import kconfiglib

ROOT = Path(__file__).resolve().parents[3]
PACKAGE = ROOT / "buildroot-external/package/openccu-base"
PREFIX = "BR2_PACKAGE_OPENCCU_BASE_"


class ComponentSelectionTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="base-selection-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        source = (PACKAGE / "Config.in").read_text()
        self.defined = set(re.findall(r"^config (\w+)", source, re.M))
        external = set(re.findall(r"\bBR2_\w+", source)) - self.defined
        defaults = {"BR2_x86_64", "BR2_USE_MMU", "BR2_TOOLCHAIN_USES_GLIBC",
                    "BR2_TOOLCHAIN_HAS_THREADS", "BR2_TOOLCHAIN_GCC_AT_LEAST_4_9",
                    "BR2_INSTALL_LIBSTDCPP"}
        stubs = ""
        for symbol in sorted(external):
            value = "y" if symbol in defaults else "n"
            stubs += f'config {symbol}\n\tbool "{symbol}"\n\tdefault {value}\n'
        config = self.root / "Kconfig"
        config.write_text(stubs + f'\nsource "{PACKAGE / "Config.in"}"\n')
        old = os.environ.get("CONFIG_")
        os.environ["CONFIG_"] = ""
        try:
            self.kconfig = kconfiglib.Kconfig(str(config), warn=False)
        finally:
            if old is None:
                del os.environ["CONFIG_"]
            else:
                os.environ["CONFIG_"] = old
        self.kconfig.syms["BR2_PACKAGE_OPENCCU_BASE"].set_value("y")

    def test_default_selection_includes_every_visible_component(self):
        for name in self.defined:
            if self.kconfig.syms[name].nodes[0].prompt:
                self.assertEqual(self.kconfig.syms[name].str_value, "y", name)

    def test_recovery_uses_only_explicit_components(self):
        config = ROOT / "buildroot-external/package/recovery-system/external/Buildroot.config"
        # Load just the Base selection, keeping the simulated external toolchain.
        for line in config.read_text().splitlines():
            match = re.match(r"(?:# )?(BR2_PACKAGE_OPENCCU_BASE\w*)(=y| is not set)$", line)
            if match:
                self.kconfig.syms[match[1]].set_value("y" if match[2] == "=y" else "n")
        actual = {name.removeprefix(PREFIX) for name in self.defined
                  if name.startswith(PREFIX) and self.kconfig.syms[name].str_value == "y"}
        self.assertEqual(actual, {"CRYPTTOOL", "EQ3CONFIGCMD", "EQ3CONFIGD", "SSDPD",
                                  "HSS_LED", "INIT_SCRIPTS", "NEEDS_CRYPTO"})

    def test_32bit_compatibility_remains_library_only(self):
        self.kconfig.syms["BR2_x86_64"].set_value("n")
        self.kconfig.syms["BR2_arm"].set_value("y")
        self.assertEqual(self.kconfig.syms[PREFIX + "COMPAT_LIBS_ONLY"].str_value, "y")
        for name in self.defined:
            if name.startswith(PREFIX) and self.kconfig.syms[name].nodes[0].prompt:
                self.assertEqual(self.kconfig.syms[name].str_value, "n", name)

    def test_overlay_services_and_monitors_follow_selection(self):
        target = self.root / "target"
        init = target / "etc/init.d"
        init.mkdir(parents=True)
        for name in ("S61rfd", "S60multimacd", "S62HMServer", "S50ssdpd", "S50sshd"):
            (init / name).touch()
        shutil.copyfile(ROOT / "buildroot-external/overlay/base-openccu/etc/monitrc",
                        target / "etc/monitrc")
        config = self.root / ".config"
        config.write_text(PREFIX + "SSDPD=y\n" + PREFIX + "INIT_SCRIPTS=y\n")
        subprocess.run([str(PACKAGE / "scripts/finalize-components.sh"),
                        str(target), str(config)], check=True)
        self.assertEqual({p.name for p in init.iterdir()}, {"S50ssdpd", "S50sshd"})
        monit = (target / "etc/monitrc").read_text()
        self.assertIn("check process ssdpd ", monit)
        self.assertIn("check process sshd ", monit)
        for service in ("rfd", "multimacd", "HMIPServer", "ReGaHss", "eq3configd", "hss_led"):
            self.assertNotIn(f"check process {service} ", monit)

    def test_wired_deselection_keeps_shared_interface_initialization(self):
        target = self.root / "target"
        init = target / "etc/init.d"
        init.mkdir(parents=True)
        for name in ("S49InitInterfaces", "S49hs485d", "S60hs485d", "S61rfd"):
            (init / name).touch()
        config = self.root / ".config"
        config.write_text(PREFIX + "RFD=y\n" + PREFIX + "INIT_SCRIPTS=y\n")
        subprocess.run([str(PACKAGE / "scripts/finalize-components.sh"),
                        str(target), str(config)], check=True)
        self.assertEqual({p.name for p in init.iterdir()}, {"S49InitInterfaces", "S61rfd"})

    def test_interface_list_follows_installed_radio_services(self):
        overlay = ROOT / "buildroot-external/overlay/base"
        for directory in ("etc/config", "etc/config_templates", "var", "bin", "opt/HMServer"):
            (self.root / directory).mkdir(parents=True, exist_ok=True)
        shutil.copyfile(overlay / "etc/config_templates/InterfacesList.xml",
                        self.root / "etc/config_templates/InterfacesList.xml")
        script = (overlay / "etc/init.d/S49InitInterfaces").read_text()
        script = re.sub(r"/(etc|var|bin|opt)/", lambda m: str(self.root) + m[0], script)
        path = self.root / "init-interfaces"
        path.write_text(script)
        rfd = self.root / "bin/rfd"
        rfd.touch()
        rfd.chmod(0o755)
        jar = self.root / "opt/HMServer/HMIPServer.jar"
        jar.touch()
        env = dict(os.environ, HM_MODE="NORMAL", HM_HMRF_DEV="present", HM_HMIP_DEV="present")
        for remove, expected in ((None, {"BidCos-RF", "HmIP-RF", "VirtualDevices"}),
                                 (jar, {"BidCos-RF"}), (rfd, set())):
            if remove:
                remove.unlink()
            subprocess.run(["bash", str(path), "start"], env=env, check=True)
            actual = set(re.findall(r"<name>(.*?)</name>",
                                    (self.root / "etc/config/InterfacesList.xml").read_text()))
            self.assertEqual(actual, expected)


if __name__ == "__main__":
    unittest.main()
