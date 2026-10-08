# AGENTS.md – OpenCCU

Guidance for AI coding agents working in this repository. Human contributors
should start with [README.md](README.md), [CONTRIBUTING.md](CONTRIBUTING.md) and
[DEVELOPMENT.md](DEVELOPMENT.md).

## Project overview

OpenCCU (formerly RaspberryMatic) is a **Buildroot-based Linux operating system**
that runs a cloud-free HomeMatic / Homematic IP smart-home hub. It aims for 100%
CCU3 compatibility while adding OS-level enhancements.

This repository contains the Buildroot `BR2_EXTERNAL` layer, patches to
Buildroot itself, release tooling, the Home Assistant apps and a Helm chart. The
eQ-3 CCU components (ReGaHss, rfd, hs485d, HMServer, WebUI, firmware, …) are
**not** maintained here: they are built from the separate repository
[OpenCCU/OpenCCU-Base](https://github.com/OpenCCU/OpenCCU-Base) by the
`openccu-base` package.

Supported products: `rpi3`, `rpi4`, `rpi5`, `tinkerboard2`, `odroid-c2`,
`odroid-c4`, `odroid-n2`, `generic-aarch64`, `generic-x86_64`, `ova`,
`lxc_amd64`, `lxc_arm64`, `oci_amd64`, `oci_arm64` (one defconfig each in
`buildroot-external/configs/`; `make` without arguments prints the current list).

Do not hard-code component versions in documentation or instructions. The
authoritative values live in the source: Buildroot in `Makefile`
(`BUILDROOT_VERSION`), the kernel series in `buildroot-external/kernel/<series>/`,
every package in its `<package>.mk`.

## Repository layout

```text
Makefile                   # Entry point: downloads/patches Buildroot, drives builds per PRODUCT
buildroot-external/        # BR2_EXTERNAL layer – all OpenCCU customization
  Buildroot.config         # Common Buildroot options merged into every product
  configs/<product>.config # Per-product Buildroot defconfig fragments
  package/                 # Custom Buildroot packages (Config.in, <pkg>.mk, <pkg>.hash)
    openccu-base/
      rootfs-patches/      # OpenCCU WebUI/rootfs patch workspaces, generated .patch files, series
  patches/<pkg>/           # Patches applied to upstream Buildroot packages
  board/<board>/           # Board files: kernel.config, boot config, genimage, post-*.sh,
                           #   patches/<pkg>/ (linux, uboot, …), kernel_defconfig (some boards)
  kernel/<series>/         # Shared kernel config fragments (global, device-support, security*)
  overlay/                 # Rootfs overlays (base*, WebUI*, RFD, per-board, lxc, oci)
  bootloader/              # U-Boot configuration
  scripts/                 # Helper scripts used during the build
buildroot-patches/         # Patches applied to Buildroot itself (workspace dir + generated .patch)
release/                   # Release scripts, update packages, EULA files, version manifests
home-assistant-addon/      # Published Home Assistant app (release-managed)
home-assistant-addon-dev/  # Development/pre-release variant of the Home Assistant app
home-assistant-addon-proxy/, home-assistant-addon-hapdrap/  # Additional Home Assistant apps
helm/openccu/              # Kubernetes Helm chart
scripts/update-*.sh        # Component bump scripts
scripts/testcases/         # Python/Tcl/shell tests (build, migration, security, API)
docs/                      # Maintainer documentation (LTS playbook, Base migration, …)
.github/workflows/         # CI/CD: ci.yml, snapshot.yml, release.yml, release-lts.yml, …
```

The build downloads the Buildroot release named in `Makefile`, applies
`buildroot-patches/`, merges `buildroot-external/Buildroot.config` with
`configs/<product>.config` and invokes Buildroot with
`BR2_EXTERNAL=buildroot-external`. Output goes to `build-<product>/`.

## Build commands

```bash
make PRODUCT=rpi4 build                   # Build one product (downloads Buildroot on first run)
make build-all                            # Build all products
make PRODUCT=rpi4 release                 # Create release archives for one product
make PRODUCT=rpi4 check                   # Package lint + rootfs patch validation (what CI runs)
make check-all                            # Checks for all products
make PRODUCT=rpi4 menuconfig              # Buildroot config  -> persist with savedefconfig
make PRODUCT=rpi4 linux-menuconfig        # Kernel config     -> persist with linux-update-defconfig
make PRODUCT=rpi4 recovery-menuconfig     # Recovery config   -> persist with recovery-savedefconfig
make PRODUCT=rpi4 multilib32-menuconfig   # multilib32 config -> persist with multilib32-savedefconfig
make -C build-rpi4 <pkg>-rebuild          # Rebuild a single package in an existing build dir
make PRODUCT=rpi4 clean                   # Remove one build dir
make distclean                            # Remove all build dirs and the Buildroot source
```

## Validate before you push

A full image build takes hours and tens of GB of disk. Do not start one unless
asked. Run the checks that match the files you touched, fastest first:

| Changed files | Check |
| --- | --- |
| Shell scripts | `shellcheck -e SC3010,SC3014,SC3057,SC3036,SC3028,SC3020 <file>` |
| YAML | `yamllint .` (config: `.yamllint`) |
| Markdown | `markdownlint` with `.markdownlint.yml` |
| `buildroot-external/board/oci/Dockerfile` | `hadolint` |
| Base migration tooling | `python3 -m unittest discover -s scripts/testcases/migration -v` and `python3 scripts/base-patch-migration.py index` |
| Build/package logic | `python3 scripts/testcases/build/test_<name>.py -v` (needs `kconfiglib`) |
| rootfs patches | `buildroot-external/package/openccu-base/rootfs-patches/create_patches.sh --check` |
| Package definitions, patch series | `make PRODUCT=rpi3 check` (downloads Buildroot and OpenCCU-Base) |
| A single package | `make -C build-<product> <pkg>-rebuild` (needs an existing build dir) |

CI (`.github/workflows/ci.yml`) runs all linters, the Python tests and
`make PRODUCT=rpi3 check`, then builds every product. Report honestly which
checks you ran and which you could not run.

## Hard rules

- **Never hand-edit generated `.patch` files** in
  `buildroot-external/package/openccu-base/rootfs-patches/` or
  `buildroot-patches/`. Edit the workspace file *without* the `.orig` suffix and
  regenerate with that directory's `create_patches.sh`. Never modify `*.orig`
  files. The `series` file defines the patch order.
- Kernel, U-Boot and DTS patches are applied with `patch -F0`: hunk headers must
  match the content exactly.
- Bump components with the matching `scripts/update-*.sh` and keep the
  `<pkg>.hash` file in sync. Keep a package's existing pin style: packages pinned
  to a commit SHA stay on a commit SHA, never switch them to a tag.
- After `menuconfig`, `linux-menuconfig`, `recovery-menuconfig` or
  `multilib32-menuconfig`, persist the change with the matching
  `savedefconfig`/`update-defconfig` target. Never edit `build-*/.config`.
- `release/updatepkg/*/EULA.de*` must encode German umlauts as HTML entities
  (`&uuml;`, `&Auml;`, …), never as raw non-ASCII characters.
- Do not touch release-managed files, which the release workflow bumps:
  `release/LATEST-VERSION.js`, `release/rpi-imager.json`, the version in
  `helm/openccu/Chart.yaml`, and `home-assistant-addon/config.yaml`. Development
  changes to the Home Assistant app go into `home-assistant-addon-dev/`.
- GitHub Actions are pinned by full commit SHA with a trailing `# vX.Y` comment.
- Target shell scripts run under BusyBox ash. Only the extensions excluded via
  the shellcheck codes above are acceptable; no other bashisms.
- WebUI, Tcl and ReGa code must escape every user-controlled value. See
  `scripts/testcases/security/` for injection test patterns.
- Never commit `build-*/`, `buildroot-*/`, `download/` or release images.

## Where does a change belong?

- **Bug fixes and changes in eQ-3 CCU components** (daemons, libraries, HMServer,
  WebUI sources, device types, firmware) belong in
  [OpenCCU/OpenCCU-Base](https://github.com/OpenCCU/OpenCCU-Base). This
  repository then picks them up by bumping `openccu-base`
  (`scripts/update-openccu-base.sh`).
- **rootfs patches** (`openccu-base/rootfs-patches/`) are a transitional
  mechanism: the series is being migrated into OpenCCU-Base, and once that is
  complete, WebUI changes will most likely be made directly in OpenCCU-Base.
  Do not add new rootfs patches by default. Prefer OpenCCU-Base and touch the
  series only where a fix cannot go there yet; ask if unsure.
- **Migrating existing rootfs patches into OpenCCU-Base** follows
  [docs/base-patch-migration.md](docs/base-patch-migration.md) strictly: one
  patch at a time, Base PR first, then the OpenCCU cleanup PR.
- **OS-level changes** (Buildroot configuration, kernel, boards, overlays,
  packages, release tooling, Home Assistant apps, Helm) belong here.

## OpenCCU-Base rootfs patches

The patches are applied after OpenCCU-Base has staged `build/rootfs`, but before
files are installed into Buildroot's target directory. Each numbered patch has a
generated `.patch` file and a workspace directory mirroring the staged rootfs;
for every changed path it contains the upstream `.orig` file and the desired
file without that suffix:

```text
rootfs-patches/0123-WebUI-Example/
  rootfs/www/webui/example.js.orig
  rootfs/www/webui/example.js
rootfs-patches/0123-WebUI-Example.patch
```

```bash
cd buildroot-external/package/openccu-base/rootfs-patches

./create_patches.sh --check   # Verify generated patches match their workspaces
./create_patches.sh           # Regenerate after editing a workspace

# Rebase workspaces onto a newly generated pristine rootfs
./update_patchfiles.sh /abs/path/to/pristine/build/rootfs /abs/path/to/OpenCCU-Base

# Apply and validate the complete series independently
./validate_patches.sh /abs/path/to/pristine/build/rootfs /abs/path/to/OpenCCU-Base
```

`prepare_patch_input.sh` converts generated inputs such as `webui.js` into the
canonical patchable form; `finalize_patch_input.sh` restores the runtime form
after the series has been applied. `make PRODUCT=<product> check` stages an
unpatched rootfs and runs the same validation, so stale workspaces, rejects,
excessive fuzz, missing symlinks, Tcl syntax errors and security regressions
fail early. `buildroot-patches/` uses the same workspace/`create_patches.sh`
pattern for patches to Buildroot itself.

## Kernel and board configuration

- Each product merges the shared fragments from
  `buildroot-external/kernel/<series>/` (`global.config`, `device-support*.config`,
  `security*.config`) with the board delta
  `buildroot-external/board/<board>/kernel.config`. The exact list is
  `BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES` in `configs/<product>.config`.
- The base config is the upstream defconfig (Raspberry Pi, x86) or a full
  `board/<board>/kernel_defconfig` (ODROID, Tinkerboard). After
  `linux-menuconfig`, run `make PRODUCT=<product> linux-update-defconfig`.
- Board-specific kernel, DTS and U-Boot patches live in
  `buildroot-external/board/<board>/patches/<package>/`.

## Nested builds: recovery system and multilib32

### Recovery system

`buildroot-external/package/recovery-system/` is a Buildroot package that runs a
**second Buildroot build** in its build step, using its own BR2_EXTERNAL tree
`recovery-system/external/` (own `Buildroot.config`, `configs/`, `overlay/`,
`package/`).

- One fragment per bootable board: `external/configs/recovery_<board>.config`
  (not used by the lxc/oci products).
- Produces an LZ4-compressed CPIO initramfs plus kernel, copied into the outer
  `$(BINARIES_DIR)` as `recoveryfs-initrd` / `recoveryfs-zImage` /
  `recoveryfs-Image`. It boots into the initramfs and never mounts a persistent
  root.
- Reuses the completed multilib32 build (copied via rsync without install
  stamps) when the configuration fragment matches; otherwise it builds its own
  variant.

### multilib32

`buildroot-external/package/multilib32/` is a second nested Buildroot build that
provides a 32-bit userspace for runtime components only available as 32-bit
binaries on the 64-bit targets.

- Enabled 32-bit packages: `multilib32/external/Buildroot.config`. In this build
  `openccu-base` selects only its compatibility libraries (`libxmlparser.so`,
  `libXmlRpc.so`) from the same pinned revision as the native build.
- The CPU fragment is selected per product via
  `BR2_PACKAGE_MULTILIB32_CONFIG_FRAGMENT_FILE` (files in
  `multilib32/external/configs/`).
- Install step: `./lib/*.so*` → `/lib32/`, `./usr/lib/*.so*` → `/usr/lib32/`,
  `/etc/ld.so.conf.d/lib32.conf`, and the dynamic linker symlink
  (`ld-linux.so.2` on x86_64, `ld-linux-armhf.so.3` on aarch64).
- Adding a 32-bit library: enable it in `multilib32/external/Buildroot.config`,
  then `make -C build-<product> multilib32-rebuild`.

Both outer package versions include the Base revision, Buildroot version and
multilib configuration hash, so stale nested builds are invalidated.

## Custom packages

Each subdirectory of `buildroot-external/package/` is a standard Buildroot
package. After changing a `.mk` or `.hash` file, rebuild just that package and
run `make PRODUCT=<product> check` (Buildroot `check-package`).

| Package | Purpose | Source |
| --- | --- | --- |
| `openccu-base` | eQ-3 daemons, libraries, Tcl modules (`tclrega`, `tclrpc`), HMServer, WebUI, device types, firmware, `eq3configd`, `ssdpd` | OpenCCU/OpenCCU-Base |
| `eq3_char_loop` | eQ-3 char loopback kernel module (revision follows `openccu-base`) | OpenCCU/OpenCCU-Base |
| `generic_raw_uart` | Low-latency UART kernel module for RF modules (RPI-RF-MOD, HM-MOD-RPI-PCB, HmIP-RFUSB, HB-RF-USB/ETH) | OpenCCU/piVCCU |
| `detect_radio_module` | Detects attached HM/HmIP RF modules at runtime | OpenCCU/piVCCU |
| `bcm2835_raw_uart` | Legacy BCM2835 raw UART kernel module | local |
| `rpi-rf-mod` | Builds the RF module DTS overlay per board | local |
| `recovery-system` | Nested Buildroot build for the recovery initramfs | local |
| `multilib32` | Nested Buildroot build for 32-bit userspace libraries | local |
| `java-azul` | Azul Zulu JRE (required by HMServer) | cdn.azul.com |
| `hmlangw` | HomeMatic LAN Gateway daemon | local |
| `neoserver` | Mediola NEO Server integration | local |
| `cloudmatic` | CloudMatic / meine-homematic.de add-on | OpenCCU/CloudMatic-CCUAddon |
| `tailscale-bin` | Tailscale VPN (pre-built binary) | pkgs.tailscale.com |
| `qemu-guest-agent` | QEMU guest agent (OVA/VM targets) | download.qemu.org |
| `xe-guest-utilities` | XCP-ng / XenServer guest utilities | xenserver/xe-guest-utilities |
| `hardkernel-boot` | Hardkernel U-Boot (ODROID boards) | hardkernel/u-boot |
| `vcgencmd` | Raspberry Pi VideoCore command tool | raspberrypi/userland |
| `rpi-eeprom` | Raspberry Pi EEPROM firmware updater | raspberrypi/rpi-eeprom |
| `wiringpi-rpi` | WiringPi GPIO library for Raspberry Pi | WiringPi/WiringPi |
| `wiringpi-odroid` | WiringPi GPIO library for ODROID | hardkernel/wiringPi |
| `raspi-fanshim` | Fan SHIM HAT daemon | flobernd/raspi-fanshim |
| `argononed` | Argon ONE / Argon FOUR fan and power daemon | local |
| `pidesktopd` | Pi Desktop case daemon | local |
| `picod` | UPS PIco daemon | ef-gy/rpi-ups-pico |
| `piusvd` | PiUSV+ UPS daemon | local |
| `susvd` | S.USV UPS daemon | local |
| `strompi2d` | StromPi2 UPS daemon | local |
| `daemonize` | Run programs as Unix daemons | bmc/daemonize |
| `python-html2text` | Host tool used by `openccu-base` patch asset generation | Alir3z4/html2text |

## Component updates

`scripts/update-*.sh` automate upstream bumps (Buildroot, kernels, Raspberry Pi
firmware/EEPROM, OpenCCU-Base, Java Azul, Tailscale, CloudMatic, CodeMirror,
RF drivers, guest agents, …). Run the matching script instead of editing
versions and hashes by hand, then validate as described above.

## Home Assistant app and releases

- `home-assistant-addon-dev/config.yaml` is the development counterpart of
  `home-assistant-addon/config.yaml`. Before a release, maintainers diff both:
  `diff -u home-assistant-addon-dev/config.yaml home-assistant-addon/config.yaml`.
- Releases are cut by maintainers via `.github/workflows/release.yml` (see
  [DEVELOPMENT.md](DEVELOPMENT.md)); LTS releases follow
  [docs/LTS_RELEASE_PLAYBOOK.md](docs/LTS_RELEASE_PLAYBOOK.md) and
  `.github/workflows/release-lts.yml`. Agents do not trigger releases.

## Commits and pull requests

- The author of every commit is the human who requested or made the change
  (their name and e-mail address in `user.name`/`user.email`), never a tool or
  an AI assistant.
- Commit messages, pull request titles and pull request descriptions must not
  mention or credit AI tools or language models: no `Co-Authored-By` trailers
  for tools, no "generated with/by" lines, no links to agent sessions.
- Write commit messages and PRs in English, following Conventional Commits with
  a lowercase imperative description, e.g. `fix(webui): …`, `feat(…): …`,
  `build(openccu-base): …`, `build(deps): …`, `docs: …`. Component bumps use
  `bump <component> to <version>`.
- One logical change per pull request, ideally squashed into a single commit,
  referencing the related issue.
- Keep `README.md` and `README.de.md` in sync when changing either.
- Contributions are licensed under Apache-2.0 (see
  [CONTRIBUTING.md](CONTRIBUTING.md)).
