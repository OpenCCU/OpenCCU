#!/usr/bin/env python3
"""Build and test the real LED daemon/client against isolated fake sysfs."""
import os
import pathlib
import shutil
import socket
import subprocess
import tempfile
import time
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[3]
PACKAGE = ROOT / "buildroot-external/package/rpi-rf-mod-led"


class LedServiceTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        try:
            probe = socket.socket(socket.AF_UNIX, socket.SOCK_SEQPACKET)
            probe.close()
        except PermissionError:
            raise unittest.SkipTest("execution environment prohibits Unix sockets; run on a Linux build host")
        cls.build = tempfile.TemporaryDirectory(prefix="led-service-build-")
        cls.binary = pathlib.Path(cls.build.name) / "led-test"
        subprocess.run([os.environ.get("CXX", "g++"), "-std=c++11", "-Wall", "-Wextra", "-Werror",
                        "-DLED_TEST_BUILD", str(PACKAGE / "led.cpp"), "-o", str(cls.binary)], check=True)

    @classmethod
    def tearDownClass(cls):
        cls.build.cleanup()

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="led-service-test-")
        self.root = pathlib.Path(self.temp.name)
        self.leds = self.root / "leds"
        self.leds.mkdir()
        self.runtime = self.root / "run"
        self.startup = self.root / "startupFinished"
        self.disabled = self.root / "disableLED"
        self.env = dict(os.environ, LED_TEST_RUNTIME=str(self.runtime), LED_TEST_SYSFS=str(self.leds),
                        LED_TEST_STARTUP=str(self.startup), LED_TEST_DISABLED=str(self.disabled))
        self.process = None

    def tearDown(self):
        self.stop()
        self.temp.cleanup()

    def stop(self, crash=False):
        if self.process is not None:
            if crash:
                self.process.kill()
            else:
                self.process.terminate()
            self.process.communicate(timeout=3)
            self.process = None

    def wait_for(self, predicate, timeout=2):
        deadline = time.monotonic() + timeout
        while not predicate():
            if self.process is not None:
                if self.process.poll() is not None:
                    self.fail("daemon exited: " + self.process.stderr.read())
            self.assertLess(time.monotonic(), deadline, "condition did not become true")
            time.sleep(0.005)

    def start(self):
        self.process = subprocess.Popen([str(self.binary), "--daemon"], env=self.env,
                                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.wait_for(lambda: self.cli("status", check=False).returncode == 0)

    def cli(self, *args, check=True):
        p = subprocess.run([str(self.binary), *args], env=self.env, capture_output=True, text=True, timeout=3)
        if check:
            self.assertEqual(p.returncode, 0, p.stderr)
        return p

    def report(self, a, b, da=0, db=0):
        return self.request(f"1 report {a} {b} {da} {db}")

    def request(self, message):
        with socket.socket(socket.AF_UNIX, socket.SOCK_SEQPACKET) as s:
            s.settimeout(2)
            s.connect(str(self.runtime / "control"))
            s.sendall(message.encode())
            return s.recv(1024).decode()

    def rgb(self, order="red green blue", maximum=255, timer=True):
        p = self.leds / "rpi_rf_mod:rgb:status"
        p.mkdir()
        for name, value in {"multi_index": order, "max_brightness": str(maximum), "brightness": "0",
                            "multi_intensity": "0 0 0", "trigger": "[none] timer" if timer else "[none]",
                            "delay_on": "0", "delay_off": "0"}.items():
            (p / name).write_text(value + "\n")
        return p

    def legacy(self):
        result = []
        for c in ("red", "green", "blue"):
            p = self.leds / ("rpi_rf_mod:" + c)
            p.mkdir()
            for name, value in {"max_brightness": "1", "brightness": "0", "trigger": "[none] timer"}.items():
                (p / name).write_text(value + "\n")
            result.append(p)
        return result

    def value(self, p, name="multi_intensity"):
        return (p / name).read_text().strip()

    def expect_color(self, p, value):
        self.wait_for(lambda: self.value(p) == value)

    def test_all_colors_and_kernel_blink(self):
        p = self.rgb("blue red green")
        self.start()
        for name, values in {"off": "0 0 0", "red": "0 255 0", "green": "0 0 255", "blue": "255 0 0",
                             "yellow": "0 255 255", "magenta": "255 255 0", "cyan": "255 0 255", "white": "255 255 255"}.items():
            self.cli(name)
            self.expect_color(p, values)
        self.cli("magenta", "100")
        self.wait_for(lambda: self.value(p, "trigger") == "timer")
        self.assertEqual(self.value(p, "delay_on"), "100")
        self.assertEqual(self.value(p, "delay_off"), "100")

    def test_alternate_returns_and_is_replaced(self):
        p = self.rgb()
        self.start()
        self.cli("alternate", "blue", "red", "40", "70")
        for color in ("0 0 255", "255 0 0", "0 0 255"):
            self.expect_color(p, color)
        self.cli("green")
        self.expect_color(p, "0 255 0")
        time.sleep(0.2)
        self.assertEqual(self.value(p), "0 255 0")
        self.cli("stop")
        self.expect_color(p, "0 0 0")

    def test_auto_override_report_release_and_shutdown(self):
        p = self.rgb()
        self.start()
        self.cli("system", "yellow")
        self.report(4, 4)
        self.expect_color(p, "255 255 0")
        self.startup.touch()
        self.cli("auto")
        self.expect_color(p, "0 0 255")
        self.cli("alternate", "green", "yellow", "50")
        self.report(1, 1)
        self.assertIn("owner=override", self.cli("status").stdout)
        self.cli("release")
        self.expect_color(p, "255 0 0")
        self.cli("white")
        self.startup.unlink()
        self.cli("system", "yellow")
        self.report(4, 4)
        self.expect_color(p, "255 255 0")
        self.assertIn("owner=system", self.cli("status").stdout)

    def test_restart_restores_override_and_latest_report(self):
        p = self.rgb()
        self.startup.touch()
        self.start()
        self.cli("auto")
        self.cli("green")
        self.report(1, 1)
        self.stop(crash=True)
        self.start()
        self.expect_color(p, "0 255 0")
        self.cli("release")
        self.expect_color(p, "255 0 0")

    def test_legacy_and_no_kernel_timer(self):
        devs = self.legacy()
        self.start()
        self.cli("alternate", "green", "yellow", "50")
        self.wait_for(lambda: self.value(devs[0], "brightness") == "1")
        self.wait_for(lambda: self.value(devs[0], "brightness") == "0")
        self.assertEqual(self.value(devs[1], "brightness"), "1")
        self.assertEqual(self.value(devs[2], "brightness"), "0")
        self.cli("off")
        self.wait_for(lambda: all(self.value(p, "brightness") == "0" for p in devs))

    def test_missing_hardware_and_reprobe(self):
        self.start()
        self.cli("blue")
        self.assertIn("backend=missing", self.cli("status").stdout)
        p = self.rgb()
        self.expect_color(p, "0 0 255")
        shutil.rmtree(p)
        self.wait_for(lambda: "backend=missing" in self.cli("status").stdout)
        p = self.rgb("blue green red", timer=False)
        self.expect_color(p, "255 0 0")
        self.cli("blue", "50")
        self.expect_color(p, "0 0 0")
        self.expect_color(p, "255 0 0")

    def test_invalid_requests_do_not_replace_pattern(self):
        p = self.rgb()
        self.start()
        self.cli("blue")
        for args in [("alternate", "blue", "red", "0"), ("alternate", "blue", "red", "100", "-1"),
                     ("unknown",), ("blue", "86400001"), ("blue", "12", "extra")]:
            self.assertNotEqual(self.cli(*args, check=False).returncode, 0)
        for message in ("1 report 9 0 10 10", "1 report 1 2 0 0", "1 override 1 2 10 0", "1 auto extra",
                        "2 auto", "1 system 1 1 0 0\x00", "x" * 600):
            self.assertTrue(self.request(message).startswith("ERR"))
        self.expect_color(p, "0 0 255")

    def test_invalid_rgb_never_falls_back_to_components(self):
        devs = self.legacy()
        self.rgb("red red blue")
        self.start()
        self.cli("white")
        self.assertIn("backend=error", self.cli("status").stdout)
        self.assertTrue(all(self.value(p, "brightness") == "0" for p in devs))

    def test_disable_led_overrides_manual_pattern(self):
        p = self.rgb()
        self.start()
        self.cli("white")
        self.expect_color(p, "255 255 255")
        self.disabled.touch()
        self.expect_color(p, "0 0 0")
        self.disabled.unlink()
        self.expect_color(p, "255 255 255")

    def test_second_daemon_does_not_remove_socket(self):
        self.rgb()
        self.start()
        p = subprocess.run([str(self.binary), "--daemon"], env=self.env, capture_output=True, timeout=2)
        self.assertNotEqual(p.returncode, 0)
        self.cli("blue")

    def test_idle_clients_do_not_block_timer(self):
        p = self.rgb()
        self.start()
        self.cli("alternate", "blue", "red", "40")
        idle = []
        try:
            for _ in range(8):
                s = socket.socket(socket.AF_UNIX, socket.SOCK_SEQPACKET)
                s.connect(str(self.runtime / "control"))
                idle.append(s)
            self.expect_color(p, "255 0 0")
            self.expect_color(p, "0 0 255")
            self.cli("off")
        finally:
            for s in idle:
                s.close()

    def test_corrupt_saved_state_uses_safe_boot_default(self):
        p = self.rgb()
        self.runtime.mkdir()
        (self.runtime / "state").write_text("1 0 0 invalid")
        self.start()
        self.expect_color(p, "255 255 0")


if __name__ == "__main__":
    unittest.main()
