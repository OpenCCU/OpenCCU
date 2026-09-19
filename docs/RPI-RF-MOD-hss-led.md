# LED control with hss_led and hss_ledctl

This cumulative follow-up patch applies to OpenCCU PR #4204 at
`7a8af61fd9f4730c5693bc64af633686462a12e2`.
It replaces the experimental `rpi-rf-mod-ledd` with the existing `hss_led` service.
The embedded Base patch targets the PR's unchanged OpenCCU-Base version 3.89.11
(`3ed652a404d72cbe403e37c5b8b1f610451b02fb`).

## Architecture and lifecycle

- `hss_led` owns the RGB/legacy backend, monotonic timers, local control socket
  and runtime state. There is one daemon and one Monit process entry.
- The CCU status monitor runs in a separate thread. It publishes the latest
  pattern to an in-process mailbox; it does not connect to its own socket.
  A slow status/RPC query cannot block LED timers or manual control.
- `/bin/hss_ledctl` is a symlink to `/bin/hss_led`. This invocation only sends
  a command to the running service. `hss_led --led-control COMMAND...` is equivalent.
- `S01hss_led` starts the controller before `S02InitRTC` and waits for its socket.
  `S06InitSystem` creates `/var/status/hssLedReady` at the former hss_led start
  point. Only then does the monitor read CCU configuration and receive UDP status
  messages. Automatic LED output still starts with the existing `auto` command
  in `S99SetupLEDs`.
- Radio detection is refreshed in the monitor; the HB-RF path no longer restarts
  hss_led when the driver appears. The controller discovers replaced sysfs nodes.
- Shutdown scripts retain control until `S01hss_led` stops. The controller handles
  termination even if a status query is stalled. It closes its descriptors and
  ends the process without waiting for that thread; no shared globals are
  destroyed while the status thread might still access them.
- The existing HM-LGW marker selects LED-only operation. Manual/system commands
  remain available and Monit continues monitoring the process in this mode.

The GPIO/USB drivers, DTS overlays and old-kernel fallback in the PR are unchanged.
Kernel timer triggers are used for supported RGB color/off blinking; other
patterns share a userspace timer. Separate legacy GPIO/USB writes are not
physically atomic.

## Recovery and permissions

Recovery enables `BR2_PACKAGE_OPENCCU_BASE_LED_ONLY=y` in the existing Base package.
The CMake option `HSS_LED_ONLY=ON` builds the same controller into a small `hss_led`
with no CCU status thread or XML-RPC dependencies. No WebUI, Java processing,
CCU rootfs patch stack or other Base services are built or installed in this mode.
The recovery `hm-platform` package still provides its existing utilities.

Native systems and recovery run hss_led as the `hssled` user. The init script
prepares its runtime directory and existing LED-node permissions; the packaged
udev rules grant access to later LED nodes and timer attributes. Failed writes
are retried without repeatedly recreating the timer attributes before udev can
change their permissions. Containers retain the previous root execution policy;
the host must expose usable LED sysfs nodes.

## Applying and rebuilding

Apply this follow-up on the PR branch, including its previous lint fixes:

```sh
git apply --check --whitespace=nowarn /path/0003-PR4204-hss-ledctl-and-board-leds.patch
git apply --whitespace=nowarn /path/0003-PR4204-hss-ledctl-and-board-leds.patch
```

Do not use `--whitespace=fix`: context spaces inside the embedded patch must
remain unchanged. This revision replaces the previously supplied `0002` integration patch and
the earlier `0003` revision with optional radio target selection. Do not stack
it on either patch. Start from the PR commit quoted above.

For an existing Tinkerboard2 build:

```sh
make -C build-tinkerboard2 olddefconfig
make -C build-tinkerboard2 openccu-base-dirclean recovery-system-dirclean
make tinkerboard2-release
```

The normal configuration must keep `BR2_PACKAGE_OPENCCU_BASE=y` and leave
`BR2_PACKAGE_OPENCCU_BASE_LED_ONLY` disabled. The nested recovery build selects
LED-only mode itself. The Base install hook removes stale experimental daemon
and init-script files from a reused target directory. Deploy the rebuilt image
and reboot; this patch does not perform a live migration of running daemons.

## Commands on the device

```sh
hss_ledctl --led rpi-rf-mod alternate blue red 499
hss_ledctl --led rpi-rf-mod alternate green yellow 250 750
hss_ledctl --led rpi-rf-mod magenta 100
hss_ledctl --led rpi-rf-mod green
hss_ledctl --led rpi-rf-mod release
hss_ledctl --led rpi-rf-mod status
/etc/init.d/S01hss_led restart
```

Color/alternate commands return after acknowledgment and keep running in hss_led.
`release` removes a manual override. `stop` and `off` override the display with off;
they do not stop the daemon. Acknowledgment confirms acceptance of the command;
`pending=1` means the hardware still needs to be updated.

The socket and RGB state now reside in `/run/hss_led/`. The experimental old
CLI name is not installed as an alias; its stale target-file entry is removed
during package installation. Rebuild and reboot when moving from that draft.
RGB state survives process restarts, but not a normal reboot with cleared
`/run`. `/etc/config/disableLED` retains priority for the RGB status display. A process restart begins the
saved pattern at its first phase; it does not preserve the exact phase timestamp.

## Explicit board LED targets

Every target-specific command requires `--led NAME`, including `status`,
`release` and `auto`. There is no implicit default. Only `list` and `--help`
(or `-h`) work without target selection. `--led rpi-rf-mod` selects the radio
LED's RGB/legacy backend. To address a separate LED, use its exact basename
from `/sys/class/leds`, as shown by `list`:

```sh
hss_ledctl --help
hss_ledctl list
hss_ledctl --led rpi-rf-mod alternate blue red 499
hss_ledctl --led ACT blink 100 900
hss_ledctl --led ACT trigger heartbeat
hss_ledctl --led 'green:' on
hss_ledctl --led 'blue:status' off
hss_ledctl --led ACT brightness 1
hss_ledctl --led ACT status
```

Names vary by board/kernel/device tree. OpenCCU currently uses `ACT`/`PWR`
for Raspberry Pi, `green:`/`red:`/`yellow:` for Tinkerboard2, and `blue:status`
for ODROID. The daemon discovers the LED class and does not depend on these
specific names or model detection. Only LEDs exposed by a kernel driver are
controllable; a hardwired power indicator is not.

Scalar targets accept `on`, `off`, `brightness LEVEL`, `blink ON_MS [OFF_MS]`,
`trigger NAME` and `status`. Brightness is checked against `max_brightness`.
The optional OFF_MS defaults to ON_MS; durations must be 1..86400000 ms.
Blink uses the kernel `timer` trigger and requires it to be available; no
software timer or extra process is created for board LEDs. Other triggers must
be offered by that LED. `on`/`off`/`brightness` switch its trigger to `none`.
The LED class interface is described in the
[Linux kernel documentation](https://docs.kernel.org/leds/leds-class.html).

Commands act on one scalar LED at a time and leave other targets alone.
Monochrome LEDs do not accept color names or RGB alternation. Generic multicolor
nodes are not yet supported; radio component nodes are reserved for the RGB
controller. Invalid requests and direct access to those components are rejected.
The native service's LED-class permissions now cover all class devices, while
control commands still require root. Read-only list/status requests use the
existing socket access policy. Containers additionally require suitable host
sysfs access; these commands cannot grant container access themselves.

Existing boot/shutdown scripts retain their board-trigger policy. The daemon
does not overwrite it on startup, mirror CCU colors to board LEDs, or claim
continuous ownership of scalar targets. These explicit commands write kernel
settings: completed settings survive a daemon restart, but are not journaled
or replayed after hardware removal or reboot. A later boot/shutdown script or
other sysfs writer can replace them. `release`, `auto`, and the controller's
`disableLED` priority remain specific to the radio target. To return a board
LED to heartbeat/disk activity, select that trigger explicitly. The existing
board boot scripts still implement their own `disableLED` handling.

Timer attribute permissions may be updated asynchronously by udev. The daemon
retries for up to five seconds without blocking RGB blinking or recreating the
trigger. `status` reports `pending=1` during setup, then `pending=0`; a failed
setup additionally reports `error=...`. A replacement command cancels earlier
pending setup. Pending setup is not replayed after daemon restart or a changed
sysfs device/trigger. Check `status` after a blink command during testing.

## Validation

The patch includes unit and process tests using fake sysfs files:

```sh
python3 scripts/testcases/build/test_rgb_led.py -v
```

The Python runner extracts the actual new sources from the embedded Base patch;
it does not contain a second controller implementation. The socket tests cover
CLI/background operation, overrides, legacy LEDs, hardware replacement, restart,
a stalled in-process status producer, independent board LEDs, and delayed
board timer permissions. They explicitly skip when Unix sockets
are prohibited. The state/backend tests still run in that environment.

The Base CMake option `HSS_LED_BUILD_TESTS=ON` adds `hss_led_state_test` and the
CTest entry `hss_led_state`, for both normal and LED-only builds.

Checked while preparing this patch: native normal and LED-only builds, controller
unit tests (237 assertions), Buildroot normal/recovery configuration and package selection,
package lint, shell syntax, and application of both outer and embedded patches.

Not verified here: real Unix-socket process tests (the execution environment
returns EPERM), a complete firmware/recovery cross-build, and real GPIO/HB-RF-USB
hardware. In particular, verify early boot, udev permission timing and shutdown
on the target device before merging.
