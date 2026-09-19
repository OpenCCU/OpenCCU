// SPDX-License-Identifier: Apache-2.0
// Exercise the actual parser/state/backend code without creating sockets.
// Build: c++ -std=c++11 -Wall -Wextra -Werror tests.cpp -o led-state-test
#define main led_program_main
#include "led.cpp"
#undef main

static unsigned checks = 0;
static void check(bool ok) {
  ++checks;
  if (!ok) throw std::runtime_error("check " + std::to_string(checks) + " failed");
}
static void put(const std::string& path, const std::string& value) {
  std::ofstream f(path);
  f << value << '\n';
  check(bool(f));
}
static void directory(const std::string& path) { check(!mkdir(path.c_str(), 0755)); }
int main() {
  char temp[] = "/tmp/led-state-test-XXXXXX";
  const char* dir = mkdtemp(temp);
  if (!dir) return 1;
  try {
    runtime = std::string(dir) + "/run"; directory(runtime);
    sysfs = std::string(dir) + "/leds"; directory(sysfs);
    startup = std::string(dir) + "/started";
    disabled = std::string(dir) + "/disabled";
    Pattern p;
    p.a = 4; p.b = 1; p.da = 250; p.db = 750;
    uint64_t delay = 0;
    check(phaseAt(p, 0, delay) == 4 && delay == 250);
    check(phaseAt(p, 249, delay) == 4 && delay == 1);
    check(phaseAt(p, 250, delay) == 1 && delay == 750);
    check(phaseAt(p, 999, delay) == 1 && delay == 1);
    check(phaseAt(p, 1000, delay) == 4 && delay == 250);
    check(phaseAt(p, 1000000350ULL, delay) == 1 && delay == 650);
    check(makeRequest({"alternate", "blue", "red", "250", "750"}) == "1 override 4 1 250 750");
    check(makeRequest({"system", "magenta", "100"}) == "1 system 5 0 100 100");
    check(makeRequest({"blue"}) == "1 override 4 4 0 0");
    check(makeRequest({"off", "100"}) == "1 override 0 0 0 0");
    check(makeRequest({"release"}) == "1 release");
    check(makeRequest({"alternate", "green", "yellow", "000499"}) == "1 override 2 3 499 499");
    for (auto args : std::vector<std::vector<std::string>>{{}, {"invalid"}, {"blue", "-1"},
         {"blue", "99999999999999999"}, {"alternate", "red", "blue", "0"},
         {"alternate", "red", "blue", "10", "0"}, {"blue", "10", "20"}, {"system"}}) {
      bool rejected = false;
      try { (void)makeRequest(args); } catch (const std::runtime_error&) { rejected = true; }
      check(rejected);
    }
    State state;
    Backend backend;
    check(backend.discover() && backend.name == "missing");
    auto command = [&](const std::string& msg, uid_t uid = 0) {
      return dispatch(state, msg, uid, 1234, backend, false);
    };
    check(command("1 report 4 4 0 0", 1234) == "OK accepted");
    check(state.effective().a == 3);
    put(startup, "");
    check(command("1 auto") == "OK accepted" && state.effective().a == 4);
    check(command("1 override 2 3 250 750") == "OK accepted" && state.effective().a == 2);
    check(command("1 report 1 1 0 0", 1234) == "OK accepted" && state.effective().a == 2);
    State restored;
    check(restored.load(readText(runtime + "/state")) && restored.wire() == state.wire());
    check(command("1 release") == "OK accepted" && state.effective().a == 1);
    check(command("1 override 4 1 499 499") == "OK accepted");
    unlink(startup.c_str());
    check(state.effective().a == 3);
    check(command("1 system 3 3 0 0") == "OK accepted" && !state.overrideActive && !state.automatic);
    check(command("1 report 4 4 0 0", 1234) == "OK accepted" && state.effective().a == 3);
    put(disabled, ""); check(state.effective().a == 0); unlink(disabled.c_str());
    std::string before = state.wire();
    for (const auto& msg : {"1 override 9 0 10 10", "1 report 1 2 0 0", "1 auto extra", "2 release", "1 system 1 2 0 1"})
      check(command(msg).compare(0, 3, "ERR") == 0 && state.wire() == before);
    check(command(std::string("1 auto\0", 7)).compare(0, 3, "ERR") == 0);
    check(command("1 override 1 1 0 0", 1234) == "ERR permission denied");
    check(command("1 report 1 1 0 0", 5678) == "ERR permission denied");
    check(command("1 status", 5678).compare(0, 2, "OK") == 0);
    std::string savedRuntime = runtime;
    runtime += "/absent";
    check(command("1 override 7 7 0 0") == "ERR cannot save runtime state" && state.wire() == before);
    runtime = savedRuntime;
    std::string rgb = sysfs + "/rpi_rf_mod:rgb:status";
    directory(rgb);
    for (auto a : {"trigger", "brightness", "multi_intensity", "delay_on", "delay_off"}) put(rgb + "/" + a, "0");
    put(rgb + "/trigger", "[none] timer"); put(rgb + "/multi_index", "blue red green"); put(rgb + "/max_brightness", "255");
    check(backend.discover() && backend.name == "rgb");
    for (unsigned mask = 0; mask < 8; ++mask) {
      Pattern solid; solid.a = solid.b = mask;
      check(backend.apply(solid, mask));
      check(readText(rgb + "/multi_intensity") == std::to_string(mask & 4 ? 255 : 0) + " " +
          std::to_string(mask & 1 ? 255 : 0) + " " + std::to_string(mask & 2 ? 255 : 0) + "\n");
    }
    Pattern blink; blink.a = 5; blink.da = blink.db = 100;
    check(backend.kernelBlink(blink) && backend.apply(blink, 5));
    check(readText(rgb + "/trigger") == "timer\n" && readText(rgb + "/delay_on") == "100\n");
    check(backend.apply(p, p.a) && backend.setColor(p.b));
    check(readText(rgb + "/multi_intensity") == "0 255 0\n");
    check(readText(rgb + "/brightness") == "255\n");
    for (auto a : {"trigger", "brightness", "multi_intensity", "delay_on", "delay_off", "multi_index", "max_brightness"})
      unlink((rgb + "/" + a).c_str());
    rmdir(rgb.c_str()); check(backend.discover() && backend.name == "missing");
    for (auto c : {"red", "green", "blue"}) {
      std::string path = sysfs + "/rpi_rf_mod:" + c;
      directory(path); put(path + "/trigger", "none"); put(path + "/brightness", "0"); put(path + "/max_brightness", "1");
    }
    check(backend.discover() && backend.name == "legacy");
    check(backend.apply(p, 2)); check(backend.setColor(3));
    check(readText(sysfs + "/rpi_rf_mod:red/brightness") == "1\n" &&
          readText(sysfs + "/rpi_rf_mod:green/brightness") == "1\n" &&
          readText(sysfs + "/rpi_rf_mod:blue/brightness") == "0\n");
    directory(rgb); put(rgb + "/multi_index", "red red blue"); put(rgb + "/max_brightness", "255");
    check(backend.discover() && backend.name == "error" && !backend.apply(p, 7));
    check(!restored.load("1 0 0 broken"));
    std::cout << "PASS: " << checks << " state/protocol/phase/backend assertions\n";
    // The temporary fixture is printed so the test runner can remove it.
    std::cout << "fixture=" << dir << '\n';
    return 0;
  } catch (const std::exception& e) {
    std::cerr << e.what() << " (fixture " << dir << ")\n"; return 1;
  }
}
