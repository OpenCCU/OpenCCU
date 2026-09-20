#!/usr/bin/env python3
"""Build and test the real LED daemon/client against isolated fake sysfs."""
import os
import pathlib
import re
import shutil
import socket
import subprocess
import tempfile
import time
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[3]
PATCH = ROOT / "buildroot-external/package/openccu-base/0001-OpenCCU-Base-led-service.patch"


def extract_sources(destination):
    """Use the actual new Base sources embedded in the package patch."""
    expected = {"LedCli.h", "LedController.cpp", "LedController.h", "LedProtocol.h",
                "LedOnlyMain.cpp", "RgbLed.h", "StatusCommand.h", "tests/LedControllerTest.cpp",
                "tests/StatusProducer.cpp"}
    found = set()
    for block in re.split(r"(?m)^diff --git ", PATCH.read_text()):
        lines = block.splitlines()
        prefix = "+++ b/src/hss_led/"
        name = next((line[len(prefix):] for line in lines if line.startswith(prefix)), None)
        if name not in expected:
            continue
        if "new file mode 100644" not in lines:
            raise AssertionError("Expected new source in Base patch: " + name)
        body = next(i for i, line in enumerate(lines) if line.startswith("@@ ")) + 1
        data = lines[body:]
        if any(not line.startswith("+") for line in data):
            raise AssertionError("Unexpected new-file patch body: " + name)
        path = destination / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("\n".join(line[1:] for line in data) + "\n")
        found.add(name)
    if found != expected:
        raise AssertionError("Missing Base sources: " + str(expected - found))


class ControllerStateTest(unittest.TestCase):
    def test_state_and_backend(self):
        with tempfile.TemporaryDirectory(prefix="hss-state-test-") as temp:
            source = pathlib.Path(temp)
            extract_sources(source)
            binary = source / "state-test"
            subprocess.run([os.environ.get("CXX", "g++"), "-std=c++11", "-pthread",
                            "-Wall", "-Wextra", "-Werror", "-DLED_TEST_BUILD",
                            str(source / "tests/LedControllerTest.cpp"), "-o", str(binary)], check=True)
            result = subprocess.run([str(binary)], check=True, capture_output=True, text=True)
            self.assertIn("PASS:", result.stdout)
            for line in result.stdout.splitlines():
                if line.startswith("fixture=/tmp/led-state-test-"):
                    shutil.rmtree(line[len("fixture="):])



class CliHelpTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix="hss-help-test-")
        cls.addClassCleanup(cls.temp.cleanup)
        source = pathlib.Path(cls.temp.name)
        extract_sources(source)
        cls.binary = source / "hss_led"
        cls.client = source / "hss_ledctl"
        cls.client.symlink_to(cls.binary.name)
        subprocess.run([os.environ.get("CXX", "g++"), "-std=c++11", "-pthread",
                        "-Wall", "-Wextra", "-Werror", "-DLED_TEST_BUILD",
                        str(source / "LedController.cpp"), str(source / "LedOnlyMain.cpp"),
                        "-o", str(cls.binary)], check=True)

    def test_help_and_version_work_without_daemon_or_socket(self):
        for binary in (self.binary, self.client):
            for flag in ("-h", "--help", "-V", "--version"):
                with self.subTest(program=binary.name, flag=flag):
                    result = subprocess.run([str(binary), flag], check=True, capture_output=True, text=True)
                    self.assertRegex(result.stdout, binary.name + r" \d+\.\d+ \(built .+ \d{2}:\d{2}:\d{2}\)")
                    self.assertEqual(result.stderr, "")
                    if flag in ("-h", "--help"):
                        self.assertIn("Usage:", result.stdout)
                        if binary == self.client:
                            self.assertIn("slow (=500)", result.stdout)
                            self.assertIn("fast (=100)", result.stdout)
                            self.assertIn("--led NAME", result.stdout)
                    else:
                        self.assertNotIn("Usage:", result.stdout)


class LedServiceTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        try:
            probe = socket.socket(socket.AF_UNIX, socket.SOCK_SEQPACKET)
            probe.close()
        except PermissionError:
            raise unittest.SkipTest("execution environment prohibits Unix sockets; run on a Linux build host")
        cls.build = tempfile.TemporaryDirectory(prefix="hss-service-build-")
        source = pathlib.Path(cls.build.name)
        extract_sources(source)
        cls.binary = source / "hss_led"
        cls.client = source / "hss_ledctl"
        cls.producer = source / "producer"
        cls.client.symlink_to(cls.binary.name)
        flags = [os.environ.get("CXX", "g++"), "-std=c++11", "-pthread", "-Wall", "-Wextra", "-Werror",
                 "-DLED_TEST_BUILD", str(source / "LedController.cpp")]
        subprocess.run(flags + [str(source / "LedOnlyMain.cpp"), "-o", str(cls.binary)], check=True)
        subprocess.run(flags + [str(source / "tests/StatusProducer.cpp"), "-o", str(cls.producer)], check=True)

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

    def start(self, producer=False):
        self.process = subprocess.Popen([str(self.producer)] if producer else [str(self.binary), "--led-only"], env=self.env,
                                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.wait_for(lambda: self.cli("--led", "rpi-rf-mod", "status", check=False).returncode == 0)

    def cli(self, *args, check=True):
        p = subprocess.run([str(self.client), *args], env=self.env, capture_output=True, text=True, timeout=3)
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

    def scalar(self, name="ACT", maximum=255):
        path = self.leds / name
        path.mkdir()
        for key, value in {"max_brightness": str(maximum), "brightness": "17",
                           "trigger": "none timer [heartbeat]", "delay_on": "0", "delay_off": "0"}.items():
            (path / key).write_text(value + "\n")
        return path

    def test_radio_commands_require_an_explicit_target(self):
        p = self.rgb()
        self.start()
        self.cli("--led", "rpi-rf-mod", "green")
        self.expect_color(p, "0 255 0")
        for args in [("blue",), ("status",), ("release",), ("auto",), ("off",),
                     ("alternate", "blue", "red", "100"), ("system", "yellow")]:
            result = self.cli(*args, check=False)
            self.assertEqual(result.returncode, 2)
            self.assertIn("missing --led", result.stderr)
        self.assertEqual(self.value(p), "0 255 0")

    def test_board_targets_are_explicit_and_independent(self):
        rgb = self.rgb(timer=False)
        act = self.scalar()
        blue = self.scalar("blue:status", 1)
        self.start()
        self.assertEqual(self.value(act, "trigger"), "none timer [heartbeat]")
        self.assertIn("ACT", self.cli("list").stdout)
        self.assertIn("blue:status", self.cli("list").stdout)
        self.cli("--led", "rpi-rf-mod", "alternate", "blue", "red", "40")
        self.cli("--led", "ACT", "blink", "100", "900")
        self.cli("--led", "blue:status", "off")
        self.wait_for(lambda: "pending=0" in self.cli("--led", "ACT", "status").stdout)
        self.assertEqual(self.value(act, "trigger"), "timer")
        self.assertEqual(self.value(act, "delay_off"), "900")
        self.assertEqual(self.value(blue, "brightness"), "0")
        for color in ("0 0 255", "255 0 0", "0 0 255"):
            self.expect_color(rgb, color)
        self.cli("--led", "rpi-rf-mod", "green")
        self.expect_color(rgb, "0 255 0")
        self.stop()
        self.start()
        self.assertEqual(self.value(act, "trigger"), "timer")
        self.expect_color(rgb, "0 255 0")

    def test_board_timer_waits_for_udev_without_blocking_rgb(self):
        rgb = self.rgb(timer=False)
        act = self.scalar()
        (act / "delay_on").unlink()
        (act / "delay_off").unlink()
        self.start()
        self.cli("--led", "rpi-rf-mod", "alternate", "blue", "red", "50")
        self.cli("--led", "ACT", "blink", "120")
        self.assertIn("pending=1", self.cli("--led", "ACT", "status").stdout)
        self.expect_color(rgb, "255 0 0")
        self.expect_color(rgb, "0 0 255")
        (act / "brightness").write_text("0\n")
        (act / "delay_on").write_text("0\n")
        (act / "delay_off").write_text("0\n")
        self.wait_for(lambda: "pending=0" in self.cli("--led", "ACT", "status").stdout)
        self.assertEqual(self.value(act, "brightness"), "0")
        self.assertEqual(self.value(act, "delay_on"), "120")
        self.assertEqual(self.value(act, "delay_off"), "120")

    def test_board_requests_reject_invalid_targets_and_values(self):
        act = self.scalar(maximum=1)
        self.start()
        for target, command in [("../ACT", "on"), ("rpi_rf_mod:red", "on"), ("absent", "on")]:
            self.assertNotEqual(self.cli("--led", target, command, check=False).returncode, 0)
        self.assertNotEqual(self.cli("--led", "ACT", "brightness", "2", check=False).returncode, 0)
        self.assertTrue(self.request("1 led ACT trigger bogus").startswith("ERR"))
        self.assertTrue(self.request("1 led ACT off\x00").startswith("ERR"))
        self.assertEqual(self.value(act, "brightness"), "17")
        self.assertEqual(self.value(act, "trigger"), "none timer [heartbeat]")

    def test_internal_report_keeps_blinking_with_stalled_status_worker(self):
        p = self.rgb(timer=False)
        self.startup.touch()
        self.start(producer=True)
        self.cli("--led", "rpi-rf-mod", "auto")
        for color in ("0 0 255", "255 0 0", "0 0 255"):
            self.expect_color(p, color)
        self.cli("--led", "rpi-rf-mod", "green")
        self.expect_color(p, "0 255 0")
        self.cli("--led", "rpi-rf-mod", "release")
        self.expect_color(p, "255 0 0")

    def test_stop_does_not_wait_for_stalled_status_worker(self):
        self.rgb()
        self.start(producer=True)
        began = time.monotonic()
        self.stop()
        self.assertLess(time.monotonic() - began, 1)

    def test_all_colors_and_kernel_blink(self):
        p = self.rgb("blue red green")
        self.start()
        for name, values in {"off": "0 0 0", "red": "0 255 0", "green": "0 0 255", "blue": "255 0 0",
                             "yellow": "0 255 255", "magenta": "255 255 0", "cyan": "255 0 255", "white": "255 255 255"}.items():
            self.cli("--led", "rpi-rf-mod", name)
            self.expect_color(p, values)
        self.cli("--led", "rpi-rf-mod", "magenta", "100")
        self.wait_for(lambda: self.value(p, "trigger") == "timer")
        self.assertEqual(self.value(p, "delay_on"), "100")
        self.assertEqual(self.value(p, "delay_off"), "100")

    def test_alternate_returns_and_is_replaced(self):
        p = self.rgb()
        self.start()
        self.cli("--led", "rpi-rf-mod", "alternate", "blue", "red", "40", "70")
        for color in ("0 0 255", "255 0 0", "0 0 255"):
            self.expect_color(p, color)
        self.cli("--led", "rpi-rf-mod", "green")
        self.expect_color(p, "0 255 0")
        time.sleep(0.2)
        self.assertEqual(self.value(p), "0 255 0")
        self.cli("--led", "rpi-rf-mod", "stop")
        self.expect_color(p, "0 0 0")

    def test_auto_override_report_release_and_shutdown(self):
        p = self.rgb()
        self.start()
        self.cli("--led", "rpi-rf-mod", "system", "yellow")
        self.report(4, 4)
        self.expect_color(p, "255 255 0")
        self.startup.touch()
        self.cli("--led", "rpi-rf-mod", "auto")
        self.expect_color(p, "0 0 255")
        self.cli("--led", "rpi-rf-mod", "alternate", "green", "yellow", "50")
        self.report(1, 1)
        self.assertIn("owner=override", self.cli("--led", "rpi-rf-mod", "status").stdout)
        self.cli("--led", "rpi-rf-mod", "release")
        self.expect_color(p, "255 0 0")
        self.cli("--led", "rpi-rf-mod", "white")
        self.startup.unlink()
        self.cli("--led", "rpi-rf-mod", "system", "yellow")
        self.report(4, 4)
        self.expect_color(p, "255 255 0")
        self.assertIn("owner=system", self.cli("--led", "rpi-rf-mod", "status").stdout)

    def test_restart_restores_override_and_latest_report(self):
        p = self.rgb()
        self.startup.touch()
        self.start()
        self.cli("--led", "rpi-rf-mod", "auto")
        self.cli("--led", "rpi-rf-mod", "green")
        self.report(1, 1)
        self.stop(crash=True)
        self.start()
        self.expect_color(p, "0 255 0")
        self.cli("--led", "rpi-rf-mod", "release")
        self.expect_color(p, "255 0 0")

    def test_legacy_and_no_kernel_timer(self):
        devs = self.legacy()
        self.start()
        self.cli("--led", "rpi-rf-mod", "alternate", "green", "yellow", "50")
        self.wait_for(lambda: self.value(devs[0], "brightness") == "1")
        self.wait_for(lambda: self.value(devs[0], "brightness") == "0")
        self.assertEqual(self.value(devs[1], "brightness"), "1")
        self.assertEqual(self.value(devs[2], "brightness"), "0")
        self.cli("--led", "rpi-rf-mod", "off")
        self.wait_for(lambda: all(self.value(p, "brightness") == "0" for p in devs))

    def test_missing_hardware_and_reprobe(self):
        self.start()
        self.cli("--led", "rpi-rf-mod", "blue")
        self.assertIn("backend=missing", self.cli("--led", "rpi-rf-mod", "status").stdout)
        p = self.rgb()
        self.expect_color(p, "0 0 255")
        shutil.rmtree(p)
        self.wait_for(lambda: "backend=missing" in self.cli("--led", "rpi-rf-mod", "status").stdout)
        p = self.rgb("blue green red", timer=False)
        self.expect_color(p, "255 0 0")
        self.cli("--led", "rpi-rf-mod", "blue", "50")
        self.expect_color(p, "0 0 0")
        self.expect_color(p, "255 0 0")

    def test_invalid_requests_do_not_replace_pattern(self):
        p = self.rgb()
        self.start()
        self.cli("--led", "rpi-rf-mod", "blue")
        for args in [("alternate", "blue", "red", "0"), ("alternate", "blue", "red", "100", "-1"),
                     ("unknown",), ("blue", "86400001"), ("blue", "12", "extra")]:
            self.assertNotEqual(self.cli("--led", "rpi-rf-mod", *args, check=False).returncode, 0)
        for message in ("1 report 9 0 10 10", "1 report 1 2 0 0", "1 override 1 2 10 0", "1 auto extra",
                        "2 auto", "1 system 1 1 0 0\x00", "x" * 600):
            self.assertTrue(self.request(message).startswith("ERR"))
        self.expect_color(p, "0 0 255")

    def test_invalid_rgb_never_falls_back_to_components(self):
        devs = self.legacy()
        self.rgb("red red blue")
        self.start()
        self.cli("--led", "rpi-rf-mod", "white")
        self.assertIn("backend=error", self.cli("--led", "rpi-rf-mod", "status").stdout)
        self.assertTrue(all(self.value(p, "brightness") == "0" for p in devs))

    def test_disable_led_overrides_manual_pattern(self):
        p = self.rgb()
        self.start()
        self.cli("--led", "rpi-rf-mod", "white")
        self.expect_color(p, "255 255 255")
        self.disabled.touch()
        self.expect_color(p, "0 0 0")
        self.disabled.unlink()
        self.expect_color(p, "255 255 255")

    def test_second_daemon_does_not_remove_socket(self):
        self.rgb()
        self.start()
        p = subprocess.run([str(self.binary), "--led-only"], env=self.env, capture_output=True, timeout=2)
        self.assertNotEqual(p.returncode, 0)
        self.cli("--led", "rpi-rf-mod", "blue")

    def test_idle_clients_do_not_block_timer(self):
        p = self.rgb()
        self.start()
        self.cli("--led", "rpi-rf-mod", "alternate", "blue", "red", "40")
        idle = []
        try:
            for _ in range(8):
                s = socket.socket(socket.AF_UNIX, socket.SOCK_SEQPACKET)
                s.connect(str(self.runtime / "control"))
                idle.append(s)
            self.expect_color(p, "255 0 0")
            self.expect_color(p, "0 0 255")
            self.cli("--led", "rpi-rf-mod", "off")
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
