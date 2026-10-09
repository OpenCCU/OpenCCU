# OpenCCU-Base rootfs patches

The numbered directories are the editable source of truth. Each file to be
changed is stored as a pristine `rootfs/path.orig` file and its corresponding
modified `rootfs/path` file. The adjacent numbered `.patch` files are generated
artifacts consumed by Buildroot after OpenCCU-Base has populated `build/rootfs`.

Regenerate after editing a modified file:

```sh
./create_patches.sh
./create_patches.sh --check
```

Patch generation requires Bash 4 or newer and GNU diffutils. Refreshing also
requires GNU coreutils. Validation requires GNU patch and a Tcl interpreter;
set `TCLSH` when it is not available as `tclsh` in `PATH`.

Refresh the complete stack for a newer OpenCCU-Base revision using an unpatched
rootfs generated with `OPENCCU_BASE_ENABLE_ROOTFS_PATCHING=NO`:

```sh
./update_patchfiles.sh \
  /absolute/path/to/pristine/build/rootfs \
  /absolute/path/to/extracted/OpenCCU-Base
```

The refresh deliberately fails at the first incompatible patch. Resolve that
patch's semantic change in its modified file, regenerate, and repeat. Do not
generate patches automatically during a normal Buildroot build; generated
patches are committed so they remain reproducible and reviewable.

Patches `0125`, `0155`, and `0207` are rebased semantically because their
generated inputs are unstable across OpenCCU-Base revisions. For these three
patches the transformations in `update_patchfiles.sh`, together with their
workspace files, define the desired result. Keep both representations in sync;
`validate_patches.sh` detects divergence after a refresh.

Non-rootfs maintenance inputs may be kept next to a patch workspace and are
preserved by `update_patchfiles.sh`; these files are not emitted into the
firmware image. They are not migrated with the patch:
`scripts/base-patch-migration.py prepare-cleanup` refuses to remove a workspace
that contains files outside `rootfs/`, so move them first (for example, the
Bootstrap tooling of the former patch `0002` now lives in OpenCCU-Base below
`src/webui/bootstrap`).

Normal builds call `prepare_patch_input.sh` before applying the series and
`finalize_patch_input.sh` afterwards. The pair temporarily splits generated
template strings in `webui.js` for legacy patches and restores valid JavaScript
before the rootfs is installed. Always use both helpers when applying the stack
outside Buildroot.

The repository-level `check-openccu-base` target extracts the pinned
OpenCCU-Base revision and calls `stage_validation_rootfs.sh`. That helper uses
the OpenCCU-Base CMake definitions to generate only WebUI, device-type, and Tcl
assets with host tools; it does not compile target binaries or libraries. The
result is then passed to `validate_patches.sh` to verify the complete patch
series with zero fuzz.
