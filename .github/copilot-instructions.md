# OpenCCU – Copilot Instructions

## Project Overview

OpenCCU (formerly RaspberryMatic) is a **Buildroot-based custom Linux operating system** that runs a cloud-free Homematic IP / HomeMatic smart-home hub. It aims for 100% CCU3 compatibility while adding OS-level enhancements.

Supported targets (14): `rpi3`, `rpi4`, `rpi5`, `tinkerboard2`, `odroid-c2`, `odroid-c4`, `odroid-n2`, `generic-aarch64`, `generic-x86_64`, `ova`, `lxc_amd64`, `lxc_arm64`, `oci_amd64`, `oci_arm64`.

## Build Commands

```bash
# Build a specific product (downloads Buildroot on first run)
make PRODUCT=rpi4 build

# Build all supported products
make build-all

# Create a release archive for one product
make PRODUCT=rpi4 release

# Run CI consistency checks for one product (requires Python flake8)
make PRODUCT=rpi4 check

# Run checks for all products
make check-all

# Interactive Buildroot config
make PRODUCT=rpi4 menuconfig

# Interactive Linux kernel config
make PRODUCT=rpi4 linux-menuconfig

# Save modified defconfig back to the repo
make PRODUCT=rpi4 savedefconfig
make PRODUCT=rpi4 linux-update-defconfig

# Clean build dir for one product
make PRODUCT=rpi4 clean

# Remove everything (all build dirs + downloaded Buildroot source)
make distclean
```

`make` without arguments prints the full list of available targets and supported products.

## Architecture

```text
buildroot-external/        # Buildroot BR2_EXTERNAL layer – all OpenCCU customization
  configs/                 # Per-product Buildroot defconfigs (e.g. rpi4.config)
  package/                 # Custom Buildroot packages (openccu-base, rpi-rf-mod, …)
    openccu-base/
      rootfs-patches/      # OpenCCU WebUI/rootfs patch workspaces and series
  patches/<pkg>/           # Patches applied to other Buildroot packages
  board/<product>/         # Board-specific files: kernel defconfig, U-Boot config, DTS patches
  kernel/6.18/             # Shared kernel config fragments applied to all boards
  overlay/                 # Filesystem overlays merged into the target rootfs
  bootloader/              # U-Boot configuration
  scripts/                 # Helper scripts used during build
buildroot-patches/         # Patches applied to Buildroot itself before use
release/                   # Release scripts, EULA files, package manifests
home-assistant-addon/      # Published Home Assistant add-on
home-assistant-addon-dev/  # Development/pre-release add-on variant
helm/                      # Kubernetes Helm chart
.github/workflows/         # CI/CD: ci.yml, snapshot.yml, release.yml, …
```

The build system downloads `buildroot-2026.05.2.tar.gz`, applies `buildroot-patches/`, then invokes Buildroot with `BR2_EXTERNAL=buildroot-external`. Build output goes to `build-<product>/`.

## Key Conventions

### OpenCCU-Base rootfs patches

OpenCCU-specific changes to the generated WebUI and runtime files live in
`buildroot-external/package/openccu-base/rootfs-patches/`. They are applied
after OpenCCU-Base has staged `build/rootfs`, but before files are installed
into Buildroot's target directory.

Each numbered patch has a generated `.patch` file and a workspace directory.
The workspace mirrors the staged rootfs; for every changed path it contains an
upstream `.orig` file and the desired file without that suffix:

```text
rootfs-patches/0123-WebUI-Example/
  rootfs/www/webui/example.js.orig
  rootfs/www/webui/example.js
rootfs-patches/0123-WebUI-Example.patch
```

Edit only the file without `.orig`, then keep the generated series synchronized:

```bash
# Verify that generated patches match their workspaces
buildroot-external/package/openccu-base/rootfs-patches/create_patches.sh --check

# Regenerate after editing a workspace
buildroot-external/package/openccu-base/rootfs-patches/create_patches.sh

# Rebase workspaces onto a newly generated pristine rootfs
buildroot-external/package/openccu-base/rootfs-patches/update_patchfiles.sh \
  /absolute/path/to/pristine/build/rootfs \
  /absolute/path/to/OpenCCU-Base

# Apply and validate the complete series independently
buildroot-external/package/openccu-base/rootfs-patches/validate_patches.sh \
  /absolute/path/to/pristine/build/rootfs \
  /absolute/path/to/OpenCCU-Base
```

`prepare_patch_input.sh` converts generated inputs such as `webui.js` into the
canonical patchable representation. `finalize_patch_input.sh` restores the
runtime representation after the series has been applied. The `series` file is
the authoritative patch order. CI builds an unpatched pristine rootfs and then
runs the same validation lifecycle, so stale workspaces, rejects, excessive
fuzz, missing symlinks, Tcl syntax errors, and security regressions fail early.

### Kernel & Defconfig Changes

- Board-specific kernel config fragments live in `buildroot-external/board/<board>/kernel.config` (delta from global config) and in `buildroot-external/kernel/6.18/global.config`.
- After modifying the kernel config via `linux-menuconfig`, always save it back with `make PRODUCT=<product> linux-update-defconfig`.
- The full compiled defconfig lives in `buildroot-external/board/<board>/kernel_defconfig` – keep it in sync.

### Board-Specific DTS Patches

Device tree patches are stored as unified diffs in `buildroot-external/board/<board>/kernel-patches/`. Hunk line counts in patch headers must exactly match actual content – Buildroot uses `patch -F0`.

### Release EULA Files

Files in `release/updatepkg/*/EULA.de` must encode German umlauts as HTML entities (e.g. `&uuml;`, `&Auml;`) – no raw non-ASCII characters.

### GitHub Actions

All action SHA pins are audited via `action-sha-audit.csv`. When updating a GitHub Action, update both the SHA in the workflow YAML and the CSV.

CI linting runs:
- **hadolint** on `buildroot-external/board/oci/Dockerfile`
- **shellcheck** on shell scripts (with specific exclusion paths)

### Home Assistant Add-on

`home-assistant-addon-dev/config.yaml` is the development counterpart to `home-assistant-addon/config.yaml`. Before cutting a release, diff them to ensure all development changes are merged:
```bash
diff -u home-assistant-addon-dev/config.yaml home-assistant-addon/config.yaml
```

## Recovery System

The recovery system is a **Buildroot-within-Buildroot** nested build. It lives entirely inside `buildroot-external/package/recovery-system/` and has its own self-contained BR2_EXTERNAL tree at `buildroot-external/package/recovery-system/external/`.

**How it works:**
- `recovery-system` is a regular Buildroot package that invokes a *second* Buildroot build inside its `_BUILD_CMDS` step.
- The inner build uses `recovery-system/external/` as its own BR2_EXTERNAL layer (separate `Buildroot.config`, `configs/`, `overlay/`, `package/` subdirectories).
- The inner build produces a tiny initramfs (`rootfs.cpio.lz4` or `rootfs.cpio.uboot`) plus a kernel image, which are copied into the outer build's `$(BINARIES_DIR)/` as `recoveryfs-initrd` / `recoveryfs-zImage` / `recoveryfs-Image`.

**Platform config fragments** (one per board):
```text
recovery-system/external/configs/
  recovery_rpi3.config
  recovery_rpi4.config
  recovery_rpi5.config
  recovery_tinkerboard2.config
  recovery_odroid-c2.config
  recovery_odroid-c4.config
  recovery_odroid-n2.config
  recovery_ova.config
  recovery_generic-aarch64.config
  recovery_generic-x86_64.config
```

**Key recovery build characteristics:**
- Hostname: `homematic-recovery`, issue: `Welcome to CCU Recovery`
- Timezone: `Europe/Berlin`
- Root filesystem: CPIO archive (LZ4 compressed) – no tar output
- Boots directly into an initramfs; it never mounts a persistent disk root

**Menuconfig for the recovery system:**
```bash
make PRODUCT=rpi4 recovery-menuconfig
make PRODUCT=rpi4 recovery-savedefconfig
```

The recovery build **reuses completed multilib32 artifacts when the selected configuration fragment matches**. `RECOVERY_SYSTEM_BUILD_CMDS` copies the current `MULTILIB32_DIR` via rsync, excluding installation stamps so the artifacts are installed into the recovery target. If the configuration differs or the outer build is incomplete, recovery builds its own variant.

---

## multilib32 Package

`multilib32` is a **second nested Buildroot build** (same pattern as the recovery system) that produces a 32-bit userspace for legacy/vendor binaries running on 64-bit targets.

**Why it exists:** Some OpenCCU runtime components are available only as pre-compiled 32-bit binaries (ARM hard-float or x86). All OpenCCU targets are 64-bit, so they need a 32-bit glibc and support libraries alongside the native 64-bit ones.

**What gets built:** The inner Buildroot produces a minimal `rootfs.tar` containing only shared libraries. `MULTILIB32_INSTALL_TARGET_CMDS` extracts from that tar:
- `./lib/*.so*` → `/lib32/` on the target
- `./usr/lib/*.so*` → `/usr/lib32/` on the target

It also writes `/etc/ld.so.conf.d/lib32.conf` (paths `/lib32`, `/usr/lib32`, `/usr/local/lib32`) and creates the dynamic linker symlink:
- x86_64: `lib/ld-linux.so.2 → ../lib32/ld-linux.so.2`
- aarch64: `lib/ld-linux-armhf.so.3 → ../lib32/ld-linux-armhf.so.3`

**32-bit packages built** (defined in `multilib32/external/Buildroot.config`):
`c-ares`, `file`, `fontconfig`, `libglib2`, `libusb`, `libusb-compat`, `libuv`, `openccu-base`, `openssl`, `pcre`, `readline`

In this 32-bit build, `openccu-base` selects `compat-libraries` and supplies `libxmlparser.so` and `libXmlRpc.so` from the same pinned revision as the native build. The former standalone `libxmlparser` and `libxmlrpcxx` packages no longer exist.

**CPU architecture config fragments** (selected per product via `BR2_PACKAGE_MULTILIB32_CONFIG_FRAGMENT_FILE`):

| Config fragment | CPU | Used by |
|---|---|---|
| `multilib32_arm_a53.config` | Cortex-A53 armhf | rpi3, odroid-c2/c4/n2, generic-aarch64 |
| `multilib32_arm_a53-64k.config` | Cortex-A53, 64k pages | oci_arm64, lxc_arm64 |
| `multilib32_arm_a72.config` | Cortex-A72 armhf | rpi4, tinkerboard2 |
| `multilib32_arm_a76-16k.config` | Cortex-A76, 16k pages | rpi5 |
| `multilib32_i686.config` | x86 i686 | generic-x86_64, ova, lxc_amd64, oci_amd64 |

**Menuconfig for the multilib32 inner build:**
```bash
make PRODUCT=rpi4 multilib32-menuconfig
make PRODUCT=rpi4 multilib32-savedefconfig
```

**Interaction with recovery-system:** Recovery reuses only the completed current multilib32 build with a matching configuration fragment. Otherwise it builds its own variant. The outer package versions include the Base revision, Buildroot version and multilib configuration hash to invalidate stale nested builds.

**Adding a new 32-bit library:** Edit `multilib32/external/Buildroot.config` to enable the package, verify it exists in the Buildroot package tree, then rebuild: `make -C build-<product> multilib32-rebuild`.

---

## Custom Packages (`buildroot-external/package/`)

Each subdirectory is a standard Buildroot package (with `Config.in` + `<name>.mk`). Packages that have no upstream source use `SITE_METHOD = local`.

The `eq3configd` and `ssdpd` daemons, their init scripts and user definitions are part of `openccu-base`; they are no longer separate packages. The Tcl modules `tclrega` and `tclrpc` are also built by Base.

| Package | Purpose | Source |
|---------|---------|--------|
| `openccu-base` | Native services, libraries, firmware, HMServer, WebUI and device types | github:OpenCCU/OpenCCU-Base |
| `generic_raw_uart` | Low-latency UART kernel module for RF modules (RPI-RF-MOD, HM-MOD-RPI-PCB, HmIP-RFUSB) | github:OpenCCU/piVCCU (fork of alexreinert/piVCCU) |
| `bcm2835_raw_uart` | Legacy BCM2835 raw UART kernel module (RPi-specific predecessor) | local |
| `rpi-rf-mod` | Meta package: compiles the correct DTS overlay for the RF module per board; uses `host-dtc` | local |
| `detect_radio_module` | Tool that detects attached HM/HmIP RF modules at runtime | github:OpenCCU/piVCCU (fork of alexreinert/piVCCU) |
| `eq3_char_loop` | eQ-3 char loopback kernel module; revision follows `openccu-base` | github:OpenCCU/OpenCCU-Base, src/eq3_char_loop |
| `recovery-system` | Nested Buildroot build producing the recovery initramfs (see above) | local |
| `multilib32` | Nested Buildroot build producing 32-bit userspace libraries for 64-bit targets | local |
| `java-azul` | Azul Zulu Embedded JRE (required by HMServer) | cdn.azul.com |
| `tdom` | Tcl DOM/XML library | local |
| `hmlangw` | HomeMatic LAN Gateway daemon | local |
| `neoserver` | Mediola NEO Server integration | local |
| `cloudmatic` | CloudMatic/meine-homematic.de cloud add-on | github:OpenCCU/CloudMatic-CCUAddon |
| `tailscale-bin` | Tailscale zero-config VPN (pre-built binary) | pkgs.tailscale.com |
| `qemu-guest-agent` | QEMU guest agent (for OVA/VM targets) | download.qemu.org |
| `xe-guest-utilities` | XCP-ng / XenServer guest utilities | github:xenserver/xe-guest-utilities |
| `hardkernel-boot` | Hardkernel U-Boot secure bootloader (ODROID boards) | github:hardkernel/u-boot |
| `wiringpi-rpi` | WiringPi GPIO library for Raspberry Pi | github:WiringPi/WiringPi |
| `wiringpi-odroid` | WiringPi GPIO library for ODROID | github:hardkernel/wiringPi |
| `rpi-eeprom` | Raspberry Pi EEPROM firmware updater | github:raspberrypi/rpi-eeprom |
| `raspi-fanshim` | Fan Shim HAT daemon for Raspberry Pi | github:flobernd/raspi-fanshim |
| `argononed` | ArgonONE / ArgonFOUR fan/power daemon | local |
| `pidesktopd` | PiDesktop case daemon | local |
| `picod` | Pico UPS daemon (pimodules.com) | github:ef-gy/rpi-ups-pico |
| `piusvd` | PiUSV+ UPS daemon | local |
| `susvd` | S.USV UPS daemon | local |
| `strompi2d` | StromPi2 UPS daemon | local |
| `daemonize` | Utility to run programs as Unix daemons | github:bmc/daemonize |

**Adding or updating a package:**
- Version pins for packages sourced from GitHub use **commit SHAs** (not tag names) for `generic_raw_uart`, `detect_radio_module`, `cloudmatic`, `hardkernel-boot`, `picod`, `raspi-fanshim`, and `wiringpi-odroid`. Update via the corresponding `scripts/update-*.sh` script where one exists.
- After changing a package's `.mk` or `.hash` file, rebuild only that package: `make -C build-<product> <package-name>-rebuild`.
- Run `make PRODUCT=<product> check` afterward to validate the package definition against Buildroot's `check-package` linter.

## Component Update Scripts

`scripts/update-*.sh` scripts automate upstream component bumps. Tracked components include Buildroot, the RPi and ODROID/Tinkerboard kernels, RPi firmware/EEPROM, Java Azul, CloudMatic, CodeMirror (WebUI script editor), S.USV tools, and the `generic_raw_uart` / `detect_radio_module` drivers. After running an update script, verify the build still passes before committing.

## LTS Releases

See `docs/LTS_RELEASE_PLAYBOOK.md` for the full LTS release process. The workflow file is `.github/workflows/release-lts.yml`.
