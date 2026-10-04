# OpenCCU-Base migration baseline and validation scope

## Artifact inventory baseline from OCCU package install logic

The previous `buildroot-external/package/occu/occu.mk` installation logic
provided these runtime artifact classes:

- **Binaries (`/bin`)**: `SetInterfaceClock`, `crypttool`, `multimacd`, `rfd`, `hs485d`, `hs485dLoader`, `ReGaHss`, `eq3configcmd`, `eq3configd`, `hss_led`, `ssdpd`.
- **Libraries (`/lib` / architecture lib dir)**: `libLanDeviceUtils.so`, `libUnifiedLanComm.so`, `libelvutils.so`, `libhsscomm.so`, `libeq3config.so`.
- **WebUI runtime tree (`/www`)**: complete WebUI payload including Tcl assets and symlinked compatibility entry points.
- **Firmware (`/firmware`)**: radio/coproc/HMW firmware tree and mapping files.
- **HMServer / HmIP runtime (`/opt/HMServer`, `/opt/HmIP`)**: JARs, coupling assets, groups, measurement, pages, and coprocessor update artifacts.
- **Config templates (`/etc/config_templates`)**: at least `crRFD.conf` and `log4j2.xml` plus related templates.
- **Symlink/runtime compatibility hooks**: EULA links, `/www/*tcl` compatibility links, `/etc/config` relink, `/run` relink, `/etc/resolv.conf` relink, NUT sample relinks.

## Must-match output expectations for objective switchover validation

Parity validation should verify at least:

- **Path parity** for critical runtime trees: `/bin`, `/lib*`, `/www`, `/opt/HMServer`, `/opt/HmIP`, `/firmware`, `/etc/config_templates`.
- **File mode parity** for startup-critical binaries (`0755`) and shared libs/templates (library/template baseline modes).
- **Service/init compatibility** for startup hooks and expected init scripts (including `eq3configd`, `ssdpd`, RF services).
- **Finalize hook parity** for symlink model (`/etc/config`, `/run`, `/etc/resolv.conf`, NUT links, timezone links), cleanup removals, and generated `licenseinfo.htm`.

## Artifact ownership split for migration tracking

- **Source-buildable from OpenCCU-Base**:
  - Native daemons/libs produced by CMake (`package` target) and staged rootfs content.
  - Generated WebUI/devicetype assets from `src/webui` + `src/devicetypes`.
  - Tcl modules built from source (`tclrega`, `tclrpc`).
- **Binary-only from OpenCCU-Base**:
  - Architecture-pinned payload under `bin/<triple>`, `lib/<triple>`, and selected runtime bundles in `opt/`.
- **OpenCCU-local overlays/customizations**:
  - Overlay layers in `buildroot-external/overlay/base*`, `buildroot-external/overlay/WebUI*`, and `buildroot-external/overlay/RFD`.
  - Package finalize hooks for OpenCCU-specific symlinks, cleanup behavior, permissions, and license page generation.

## Version maintenance

`scripts/update-openccu-base.sh` updates `OPENCCU_BASE_VERSION` using the
current pin mode:

- if `OPENCCU_BASE_VERSION` is a release version, it resolves the latest stable
  OpenCCU-Base release tag and updates release-to-release.
- if `OPENCCU_BASE_VERSION` is a 40-character commit SHA, it resolves OpenCCU-Base
  `HEAD` and updates SHA-to-SHA.

To intentionally switch pin mode (release↔SHA), pass the target version/SHA as
an explicit script argument.
`OPENCCU_BASE_COMPAT_VERSION` is the OpenCCU release identity and must be
reviewed and adjusted manually whenever the imported baseline changes.

## 32-bit compatibility libraries

The nested `multilib32` build selects the same `openccu-base` package and
therefore uses the same pinned source commit as the native build. On 32-bit
targets the package automatically builds only the OpenCCU-Base
`compat-libraries` target and installs `libxmlparser.so` and `libXmlRpc.so`.
The outer `multilib32` package then relocates these libraries from `/lib` to
`/lib32` together with the other 32-bit runtime libraries.

## Source patches and fast validation

`make PRODUCT=rpi3 check-openccu-base` applies the Buildroot source patches,
runs compiler-free device generator failure tests, and generates only the
assets needed for the rootfs patch validation. It does not configure or
build the C++ services or the target toolchain. Both the normal package
check and the dependency-update workflow use this target.

The pinned OpenCCU-Base revision includes
`src/devicetypes/GenerateDeviceTypes.cmake`, which fails on a Java error or
missing/empty output. Output is generated into a temporary file before
replacing a previous device definition. No local source patch is needed
for this generator fix.

The pinned OpenCCU-Base revision also keeps the temporary version files for
rfd, hs485d and multimacd in their respective build directories and tracks
the version scripts and header generator as dependencies. No local source
patch is needed for these changes. The fast check also runs compiler-free
parallel and incremental version-header tests.

After adding or changing source patches, clean an existing Base build once
before checking or rebuilding it, for example:

```sh
make -C build-rpi3 openccu-base-dirclean
make PRODUCT=rpi3 check-openccu-base
```

Use the corresponding build directory for other products. A subsequent
normal image build will build Base again; the fast check itself does not.

`eq3_char_loop` follows `OPENCCU_BASE_VERSION` and is updated together with
Base, not through an independent OCCU updater.
