#!/usr/bin/env python3
"""Check the PWM-driven RPI-RF-MOD LED of the Raspberry Pi and Tinkerboard 2.

The device tree overlays drive each LED by software PWM (pwm-gpio + pwm-leds)
under the unchanged multicolor group rpi_rf_mod:rgb:status. The kernels must
have the drivers built in (the recovery system loads no modules), and the
Raspberry Pi firmware lights yellow before the kernel takes over.
"""
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
EXT = ROOT / "buildroot-external"
DTS = EXT / "package/rpi-rf-mod/dts"
# overlay -> GPIO specifier of the red, green and blue LED
OVERLAYS = {
    "rpi-rf-mod.dts": ("&gpio 16 0", "&gpio 20 0", "&gpio 21 0"),
    "rpi-rf-mod-tinker2.dts": ("&gpio2 18 0", "&gpio3 27 0", "&gpio3 31 0"),
}
COLORS = ("red", "green", "blue")
KERNEL_FRAGMENTS = [EXT / "board" / board / "kernel.config"
                    for board in ("rpi3", "rpi4", "rpi5", "tinkerboard2")]


def node(text, name):
    """Return the body of the first node called name (braces balanced)."""
    start = text.index(name + " {")
    depth = 0
    for i in range(start, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return text[start:i + 1]
    raise ValueError(name)


class OverlayTest(unittest.TestCase):
    def test_pwm_providers_and_leds(self):
        for overlay, pins in OVERLAYS.items():
            text = (DTS / overlay).read_text()
            with self.subTest(overlay=overlay):
                self.assertEqual(text.count('compatible = "pwm-gpio";'), 3)
                self.assertEqual(text.count('compatible = "pwm-leds";'), 1)
                leds = node(text, "rpi-rf-mod-leds")
                for color, pin in zip(COLORS, pins):
                    provider = node(text, "rpi_rf_mod_pwm_%s: rpi-rf-mod-pwm-%s" % (color, color))
                    self.assertIn("gpios = <%s>;" % pin, provider)
                    self.assertIn("#pwm-cells = <3>;", provider)
                    led = node(leds, "rpi_rf_mod_%s: led-%s" % (color, color))
                    self.assertIn('label = "rpi_rf_mod:%s";' % color, led)
                    self.assertIn("pwms = <&rpi_rf_mod_pwm_%s 0 4000000 0>;" % color, led)
                    self.assertIn("max-brightness = <255>;", led)
                    state = "off" if color == "blue" else "on"
                    self.assertIn('default-state = "%s";' % state, led)
                # The group keeps its name and now uses the PWM LEDs.
                group = node(text, "multi-led")
                self.assertIn('compatible = "leds-group-multicolor";', group)
                self.assertIn('label = "rpi_rf_mod:rgb:status";', group)
                self.assertIn("leds = <&rpi_rf_mod_red>, <&rpi_rf_mod_green>, <&rpi_rf_mod_blue>;", group)
                # generic_raw_uart still learns the same LED pins.
                self.assertIn("pivccu,led-gpios = <%s>, <%s>, <%s>;" % pins, text)
                # No second driver may claim the LED pins.
                self.assertNotIn('default-state = "keep";', text)
                for pin in pins:
                    self.assertEqual(text.count("gpios = <%s>;" % pin), 1, pin)

    def test_tinkerboard2_led_pins_are_not_forced_low(self):
        # Applying an output-low pin state after the LED driver would switch
        # a fully lit channel off (pwm-gpio does not toggle at 100 %).
        text = (DTS / "rpi-rf-mod-tinker2.dts").read_text()
        self.assertNotIn("pcfg_output_low", text)
        pins = node(text, "rpi_rf_mod_led_pins: rpi-rf-mod-led-pins")
        for spec in ("2 18 0", "3 27 0", "3 31 0"):
            self.assertIn("<%s &pcfg_pull_none>" % spec, pins)
        self.assertIn("pinctrl-0 = <&rpi_rf_mod_led_pins>;", node(text, "rpi-rf-mod-leds"))

    @unittest.skipUnless(shutil.which("dtc"), "dtc not installed")
    def test_overlays_compile_like_the_package(self):
        with tempfile.TemporaryDirectory() as temp:
            for overlay in OVERLAYS:
                with self.subTest(overlay=overlay):
                    out = Path(temp) / (overlay + ".dtbo")
                    result = subprocess.run(
                        ["dtc", "-@", "-I", "dts", "-O", "dtb", "-W", "no-unit_address_vs_reg",
                         "-o", str(out), str(DTS / overlay)], capture_output=True, text=True)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(result.stderr, "")


class ConfigTest(unittest.TestCase):
    def test_kernel_drivers_are_built_in(self):
        for fragment in KERNEL_FRAGMENTS:
            text = fragment.read_text()
            for option in ("CONFIG_PWM", "CONFIG_PWM_GPIO", "CONFIG_LEDS_PWM"):
                with self.subTest(fragment=fragment.parent.name, option=option):
                    self.assertRegex(text, r"(?m)^%s=y$" % option)
        common = (EXT / "kernel/6.18/global.config").read_text()
        for option in ("CONFIG_LEDS_CLASS_MULTICOLOR", "CONFIG_LEDS_GROUP_MULTICOLOR"):
            self.assertRegex(common, r"(?m)^%s=y$" % option)

    def test_firmware_lights_yellow_after_the_overlay(self):
        for board in ("rpi3", "rpi4", "rpi5"):
            with self.subTest(board=board):
                lines = [line.strip() for line in (EXT / "board" / board / "config.txt").read_text().splitlines()]
                overlay = lines.index("dtoverlay=rpi-rf-mod")
                self.assertGreater(lines.index("gpio=16,20=op,dh"), overlay)
                self.assertGreater(lines.index("gpio=21=op,dl"), overlay)
                # same [section] as the overlay line
                between = lines[overlay:lines.index("gpio=21=op,dl")]
                self.assertFalse([line for line in between if re.match(r"^\[.*\]$", line)])


if __name__ == "__main__":
    unittest.main()
