#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
export LC_ALL=C

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

resolve_executable() {
  local candidate=$1
  local resolved

  if [[ $candidate == */* ]]; then
    [[ -x $candidate ]] || die "executable not found: $candidate"
    resolved=$(cd "$(dirname "$candidate")" && pwd -P)/$(basename "$candidate")
  else
    resolved=$(command -v "$candidate" || true)
    [[ -n $resolved ]] || die "executable not found in PATH: $candidate"
  fi
  printf '%s\n' "$resolved"
}

[[ $# == 2 ]] || \
  die "usage: ${0##*/} OPENCCU_BASE_SOURCE OUTPUT_ROOTFS"

openccu_base_source=$(cd "$1" && pwd -P)
output_parent=$(dirname "$2")
mkdir -p "$output_parent"
output_parent=$(cd "$output_parent" && pwd -P)
rootfs=${output_parent}/$(basename "$2")
[[ ! -e $rootfs ]] || die "output rootfs already exists: $rootfs"
mkdir -p "$rootfs"

cmake=$(resolve_executable "${CMAKE:-cmake}")
python=$(resolve_executable "${PYTHON:-python3}")
tclsh=$(resolve_executable "${TCLSH:-tclsh}")

build_dir=$(mktemp -d "${TMPDIR:-/tmp}/openccu-validation-assets.XXXXXX")
trap 'rm -rf -- "$build_dir"' EXIT

# Use the asset subdirectories from OpenCCU-Base directly. A small driver
# project with no compiled languages keeps CMake from probing a compiler or
# configuring unrelated C++ targets.
mkdir -p "$build_dir/source"
"$cmake" -E create_symlink \
  "$openccu_base_source/build-tools" "$build_dir/source/build-tools"
cat >"$build_dir/source/CMakeLists.txt" <<'CMAKE'
cmake_minimum_required(VERSION 3.20)
project(OpenCCUBaseValidationAssets NONE)

add_subdirectory("${OPENCCU_BASE_SOURCE}/src/devicetypes"
  "${CMAKE_BINARY_DIR}/devicetypes")
add_subdirectory("${OPENCCU_BASE_SOURCE}/src/webui"
  "${CMAKE_BINARY_DIR}/webui")
add_subdirectory("${OPENCCU_BASE_SOURCE}/src/tcl_homematic"
  "${CMAKE_BINARY_DIR}/tcl_homematic")
CMAKE

"$cmake" -S "$build_dir/source" -B "$build_dir/build" \
  -DOPENCCU_BASE_SOURCE="$openccu_base_source" \
  -DROOTFS_DIR="$rootfs" \
  -DOPENCCU_PYTHON_EXECUTABLE="$python" \
  -DOPENCCU_TCLSH_EXECUTABLE="$tclsh"
"$cmake" --build "$build_dir/build" --target \
  webui-assets devicetypes-assets tcl-homematic-assets

# Check every generated device before validate_patches.sh can supplement the
# firmware tree with static files from OpenCCU-Base.
for family in rftypes hs485types; do
  device_sources=("$openccu_base_source/src/devicetypes/$family/"*.xml)
  [[ -f ${device_sources[0]} ]] || die "no device XML files found: $family"
  for device_source in "${device_sources[@]}"; do
    generated_device=$rootfs/firmware/$family/${device_source##*/}
    [[ -s $generated_device ]] || die "asset target did not generate: $generated_device"
  done
done

for generated_asset in \
  firmware/rftypes/rf_cfm_tw.xml \
  usr/lib/tcl8.2/homematic/homematic.tcl \
  www/config/st_values.cgi \
  www/webui/style.css \
  www/webui/webui.js; do
  [[ -s ${rootfs}/${generated_asset} ]] || \
    die "asset target did not generate: $generated_asset"
done

# The package target stages the static HMServer files after building core. Copy
# them explicitly because the validation path intentionally never builds core.
"$cmake" -E make_directory "$rootfs/opt"
"$cmake" -E copy_directory "$openccu_base_source/opt" "$rootfs/opt"
