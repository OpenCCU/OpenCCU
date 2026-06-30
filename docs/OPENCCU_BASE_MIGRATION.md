# OpenCCU-Base migration baseline and validation scope

## Artifact inventory baseline from OCCU package install logic

The previous `/home/runner/work/OpenCCU/OpenCCU/buildroot-external/package/occu/Makefile` installation logic provided these runtime artifact classes:

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
  - Tcl modules built from source (`tclrega`, `tclrpc`, `tclticks`).
- **Binary-only from OpenCCU-Base**:
  - Architecture-pinned payload under `bin/<triple>`, `lib/<triple>`, and selected runtime bundles in `opt/`.
- **OpenCCU-local overlays/customizations**:
  - Overlay layers in `buildroot-external/overlay/base*`, `buildroot-external/overlay/WebUI*`, and `buildroot-external/overlay/RFD`.
  - Package finalize hooks for OpenCCU-specific symlinks, cleanup behavior, permissions, and license page generation.
