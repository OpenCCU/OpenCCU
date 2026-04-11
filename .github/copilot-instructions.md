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
  package/                 # Custom Buildroot packages (occu, rpi-rf-mod, generic_raw_uart, …)
  patches/occu/            # Upstream OCCU WebUI/firmware patches (see below)
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

The build system downloads `buildroot-2025.11.2.tar.gz`, applies `buildroot-patches/`, then invokes Buildroot with `BR2_EXTERNAL=buildroot-external`. Build output goes to `build-<product>/`.

## Key Conventions

### OCCU Patches

`buildroot-external/patches/occu/` holds all modifications to the upstream eQ-3 OCCU firmware. There are currently **322 patch directories** covering 635 individual files.

#### How Buildroot applies the patches

`buildroot-external/Buildroot.config` sets:

```make
BR2_GLOBAL_PATCH_DIR="$(BR2_EXTERNAL_EQ3_PATH)/patches"
```

Buildroot's global patch mechanism scans that directory for a subdirectory whose name matches the package being built (`occu`), then applies every `*.patch` file found there in **lexicographic / numeric sort order** during the `occu-patch` build step.

#### Directory layout

Every patch is represented by **two sibling items** sharing the same name — a directory and a `.patch` file:

```text
buildroot-external/patches/occu/
  0001-OpenCCU/              ← working-copy source tree for this patch
  0001-OpenCCU.patch         ← generated unified diff (applied by Buildroot)
  0002-WebUI-Bootstrap/
  0002-WebUI-Bootstrap.patch
  …
  0173-WebUI-SendPOSTRequest/
  0173-WebUI-SendPOSTRequest.patch
```

Inside each numbered directory the layout mirrors the upstream OCCU source tree under an `occu/` prefix. For every file that the patch modifies, **two files are kept side by side**:

```text
0001-OpenCCU/
  occu/
    WebUI/www/webui/webui.js        ← modified version (what goes into the build)
    WebUI/www/webui/webui.js.orig   ← upstream original (never edited)
    WebUI/www/config/cp_network.cgi
    WebUI/www/config/cp_network.cgi.orig
    …
```

The `.orig` file is **always the verbatim upstream content** for that OCCU version. The file without `.orig` is the OpenCCU-modified version. Diffs are generated from `.orig` → no-extension.

#### create_patches.sh — what it does

`buildroot-external/patches/occu/create_patches.sh` regenerates **all** `.patch` files from the working-copy source pairs:

1. Deletes every existing `*.patch` file in the directory.
2. Iterates numbered directories in sorted order.
3. For each directory, finds all `*.orig` files under `occu/`.
4. For each `*.orig` file, runs:
   ```sh
   diff -u --label="${file}" --label="${file%.orig}" "${file}" "${file%.orig}" >> "../${dir}.patch"
   ```
   The `--label` flags produce standard `---`/`+++` headers with the `.orig` suffix stripped from the destination label, matching what Buildroot's `patch` command expects.
5. All per-file diffs for a given numbered directory are **concatenated into one `.patch` file**.
6. If a directory contains no `.orig` files it exits non-zero (`set -e` propagates the failure).

#### Workflow for editing an existing patch

```text
# 1. Edit the modified file (never touch .orig)
vim buildroot-external/patches/occu/0042-WebUI-MyFix/occu/WebUI/www/webui/webui.js

# 2. Regenerate all .patch files
cd buildroot-external/patches/occu && ./create_patches.sh

# 3. Commit both the modified source file AND the regenerated .patch file
git add buildroot-external/patches/occu/0042-WebUI-MyFix/occu/WebUI/www/webui/webui.js
git add buildroot-external/patches/occu/0042-WebUI-MyFix.patch
git commit
```

#### Adding a new patch

```text
# 1. Create the numbered directory (choose a number not already in use)
mkdir -p buildroot-external/patches/occu/0206-WebUI-MyNewFix/occu/WebUI/www/webui/

# 2. Copy the upstream file as .orig
cp <upstream-occu-source>/WebUI/www/webui/webui.js \
   buildroot-external/patches/occu/0206-WebUI-MyNewFix/occu/WebUI/www/webui/webui.js.orig

# 3. Copy again as the file to be modified (no extension)
cp buildroot-external/patches/occu/0206-WebUI-MyNewFix/occu/WebUI/www/webui/webui.js.orig \
   buildroot-external/patches/occu/0206-WebUI-MyNewFix/occu/WebUI/www/webui/webui.js

# 4. Make your changes to the no-extension file, then generate the patch
cd buildroot-external/patches/occu && ./create_patches.sh

# 5. Commit directory + .patch file together
```

#### webui.js special handling

`webui.js` is a minified file where actual newlines in the code are represented as literal `\n` escape sequences on a single very long line. To make it patchable line-by-line, `occu.mk` uses two build hooks:

- **`OCCU_UNWRAP_WEBUI_JS`** (PRE_PATCH hook): expands the `\n` literals in the first 10 lines back into real newlines before patches are applied.
- **`OCCU_WRAP_WEBUI_JS`** (POST_PATCH hook): collapses those real newlines back to `\n` literals after all patches have been applied.

This means `webui.js` / `webui.js.orig` pairs in the patch directories are stored in the **unwrapped (multi-line) form** so diffs are readable, but the file installed into the final image is in the original minified single-line form.

#### CI check — how divergence is caught

`make PRODUCT=<product> check` runs three steps specifically for OCCU patches:

```bash
# 1. Regenerate .patch files from working-copy sources
(cd buildroot-external/patches/occu; ./create_patches.sh)

# 2. Wipe the occu build directory and re-apply patches from scratch
rm -rf build-<product>/build/occu-<version>*
make -C build-<product> occu-patch

# 3. Fail if any .patch file changed (i.e. sources and patch file were out of sync)
git diff --exit-code buildroot-external/patches/occu/*.patch
```

CI fails if:
- A `.patch` file was not regenerated after editing a source file.
- A patch fails to apply cleanly to the current OCCU version.
- A `.patch` file was manually edited instead of regenerating via `create_patches.sh`.

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

The recovery build **reuses already-built multilib32 artifacts** via rsync rather than rebuilding them. The `RECOVERY_SYSTEM_CONFIGURE_CMDS` step copies any `multilib32-*` build directories from the outer build into the inner build tree before the inner Buildroot run starts.

---

## multilib32 Package

`multilib32` is a **second nested Buildroot build** (same pattern as the recovery system) that produces a 32-bit userspace to satisfy OCCU's 32-bit ARM/x86 binaries running on 64-bit targets.

**Why it exists:** The eQ-3 OCCU firmware ships pre-compiled 32-bit binaries (ARM hard-float or x86). All OpenCCU targets are 64-bit, so they need a 32-bit glibc and support libraries alongside the native 64-bit ones.

**What gets built:** The inner Buildroot produces a minimal `rootfs.tar` containing only shared libraries. `MULTILIB32_INSTALL_TARGET_CMDS` extracts from that tar:
- `./lib/*.so*` → `/lib32/` on the target
- `./usr/lib/*.so*` → `/usr/lib32/` on the target

It also writes `/etc/ld.so.conf.d/lib32.conf` (paths `/lib32`, `/usr/lib32`, `/usr/local/lib32`) and creates the dynamic linker symlink:
- x86_64: `lib/ld-linux.so.2 → ../lib32/ld-linux.so.2`
- aarch64: `lib/ld-linux-armhf.so.3 → ../lib32/ld-linux-armhf.so.3`

**32-bit packages built** (defined in `multilib32/external/Buildroot.config`):
`c-ares`, `file`, `fontconfig`, `libglib2`, `libusb`, `libusb-compat`, `libuv`, `libxmlparser`, `libxmlrpcxx`, `openssl`, `pcre`, `readline`

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

**Interaction with recovery-system:** The recovery build rsync-copies completed `multilib32-*` build directories from the outer build before starting its own inner Buildroot run, so multilib32 is never rebuilt twice.

**Adding a new 32-bit library:** Edit `multilib32/external/Buildroot.config` to enable the package, verify it exists in the Buildroot package tree, then rebuild: `make -C build-<product> multilib32-rebuild`.

---

## Custom Packages (`buildroot-external/package/`)

Each subdirectory is a standard Buildroot package (with `Config.in` + `<name>.mk`). Packages that have no upstream source use `SITE_METHOD = local`.

| Package | Purpose | Source |
|---------|---------|--------|
| `occu` | eQ-3 OCCU CCU firmware (core component) | github:OpenCCU/occu |
| `generic_raw_uart` | Low-latency UART kernel module for RF modules (RPI-RF-MOD, HM-MOD-RPI-PCB, HmIP-RFUSB) | github:alexreinert/piVCCU |
| `bcm2835_raw_uart` | Legacy BCM2835 raw UART kernel module (RPi-specific predecessor) | local |
| `rpi-rf-mod` | Meta package: compiles the correct DTS overlay for the RF module per board; uses `host-dtc` | local |
| `detect_radio_module` | Tool that detects attached HM/HmIP RF modules at runtime | github:alexreinert/piVCCU |
| `eq3_char_loop` | eQ-3 char loopback kernel module for HM/HmIP virtual devices | local |
| `eq3configd` | eQ-3 configuration daemon | local |
| `recovery-system` | Nested Buildroot build producing the recovery initramfs (see above) | local |
| `multilib32` | Nested Buildroot build producing 32-bit userspace libraries for 64-bit targets | local |
| `java-azul` | Azul Zulu Embedded JRE (required by OCCU) | cdn.azul.com |
| `tclrega` | Tcl library to interact with ReGaHss (OCCU scripting engine) | local |
| `tclrpc` | Tcl library to interact with XML-RPC interfaces | local |
| `tdom` | Tcl DOM/XML library | local |
| `libxmlparser` | XMLParser C++ library | local |
| `libxmlrpcxx` | XML-RPC C++ library | local |
| `hmlangw` | HomeMatic LAN Gateway daemon | local |
| `neoserver` | Mediola NEO Server integration | local |
| `cloudmatic` | CloudMatic/meine-homematic.de cloud add-on | github:OpenCCU/CloudMatic-CCUAddon |
| `ssdpd` | SSDP daemon (UPnP device advertisement) | local |
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
