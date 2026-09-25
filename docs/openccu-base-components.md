# OpenCCU-Base component selection

The `openccu-base` Buildroot package exposes individual options for its native
programs, Tcl modules, prebuilt Java/logic applications and runtime data. All
supported components default to enabled on 64-bit targets. The existing 32-bit
multilib configuration remains limited to the two compatibility libraries.

## Native components

Each name below is a suffix of `BR2_PACKAGE_OPENCCU_BASE_`:

| Option | Program |
| --- | --- |
| `SETINTERFACECLOCK` | `SetInterfaceClock` |
| `CRYPTTOOL` | `crypttool` |
| `EQ3CONFIGCMD` | `eq3configcmd` |
| `EQ3CONFIGD` | `eq3configd` |
| `SSDPD` | `ssdpd` |
| `MULTIMACD` | `multimacd` |
| `RFD` | `rfd` |
| `HS485D` | `hs485d` and its selected loader |
| `HS485DLOADER` | `hs485dLoader` |
| `HSS_LED` | `hss_led` and the `hss_ledctl` link |
| `TCLREGA` | `tclrega.so` |
| `TCLRPC` | `tclrpc.so` |

CMake derives the internal shared-library closure from the real link graph.
Only selected programs and their required libraries are installed, including
when a previous staging directory contains other outputs.
`HSS_LED_STATUS_MONITOR` independently controls the CCU status thread and its
XML-RPC dependencies. Disabling it retains the LED controller and CLI.
The LED source patch declares `hss_ledctl` as a runtime alias of `hss_led`;
CMake stages and installs the relative symlink, including in recovery builds.

## Applications and runtime data

`REGAHSS` selects the prebuilt logic engine and its Tcl extension. `WEBUI` depends
on it and selects the Tcl helpers, XML-RPC module and device descriptions.
`HMSERVER` and `HMIP_TOOLS` select the prebuilt Java services and coprocessor
maintenance tools respectively, and require the Java runtime.

`DEVICETYPES`, `FIRMWARE`, `TCL_HOMEMATIC` and `HM_SCRIPTS` select device
descriptions, firmware payloads, Tcl helpers and maintenance scripts.
`CONFIG_TEMPLATES` installs templates belonging to selected services.

The remaining legacy rootfs patches span several asset components. When any
patched asset is needed, the build prepares the complete asset input in a
separate directory and applies the patch series there. Only selected directories
are copied into the image. A native-only selection, such as recovery, needs no
WebUI/Tcl asset generation or rootfs patching.

## Services and system integration

`INIT_SCRIPTS` controls service startup files. User/group definitions follow the
selected services. `SERVICE_USERS` controls dedicated eq3configd/ssdpd accounts;
without it these services run as root. The LED controller retains its own user
and status group whenever selected. `eq3configd` also runs as root when
configuration initialization is disabled, because the existing encryption key
may not be readable by the dedicated service account.

`SYSTEM_INTEGRATION` enables main-system filesystem setup, license-page creation
and persistent configuration initialization at service startup. Recovery disables
this option and `SERVICE_USERS`, while keeping `INIT_SCRIPTS` enabled. The common
init scripts read the resulting policy from `/etc/default/openccu-base`.

Recovery calls the common board post-build script after applying its overlay.
It links `/run` to `/var/run`, retaining the recovery version and init services
without enabling main-system integration.

After board overlays are applied, the post-build script removes startup files
and Monit entries for deselected services. Optional LED and radio maintenance
calls are guarded when their tools are absent. Shared interface-list generation
lives in `S49InitInterfaces`, independently of the Wired loader, and omits
interfaces whose radio service is not installed.

Recovery explicitly selects `CRYPTTOOL`, `EQ3CONFIGCMD`, `EQ3CONFIGD`, `SSDPD`,
`HSS_LED` and `INIT_SCRIPTS`. It does not use a special CMake or package build mode.

Use a clean Buildroot output directory after changing selections. Neither
Buildroot nor CMake installation uninstalls an older image's files. Full hardware
validation is still needed for custom combinations of radio services.
