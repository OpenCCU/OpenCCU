#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

function resolve_latest_rpi_eeprom_firmware() {
  local archive_path=${1}
  local firmware_dir=${2}
  local firmware_name

  firmware_name=$(tar -tzf "${archive_path}" \
    | sed -nE "s|.*/${firmware_dir}/latest/(pieeprom-[0-9]{4}-[0-9]{2}-[0-9]{2}\\.bin)$|\\1|p" \
    | sort -V \
    | tail -n1)

  if [[ -z "${firmware_name}" ]]; then
    echo "Failed to resolve latest firmware for ${firmware_dir}" >&2
    exit 1
  fi

  echo "${firmware_name}"
}

if [[ -n "${1}" && "${1}" =~ ^pieeprom-.*\.bin$ ]]; then
  ID=$(resolve_latest_github_head_commit "raspberrypi" "rpi-eeprom")
  RPI4_FIRMWARE_PATH=${1}
  RPI5_FIRMWARE_PATH=${1}
elif [[ -n "${2}" && "${2}" =~ ^pieeprom-.*\.bin$ ]]; then
  ID=${1}
  RPI4_FIRMWARE_PATH=${2}
  RPI5_FIRMWARE_PATH=${3:-${2}}
else
  ID=${1:-$(resolve_latest_github_head_commit "raspberrypi" "rpi-eeprom")}
fi

PACKAGE_NAME="rpi-eeprom"
PROJECT_URL="https://github.com/raspberrypi/rpi-eeprom"
ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${PACKAGE_NAME}-${ID}.tar.gz"
CURRENT_ID=$(sed -nE 's/^RPI_EEPROM_VERSION = (.*)$/\1/p' "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "${PACKAGE_NAME}"
fi

ARCHIVE_TMP=$(mktemp)
trap 'rm -f "${ARCHIVE_TMP}"' EXIT

if ! wget -nd -t 3 -O "${ARCHIVE_TMP}" "${ARCHIVE_URL}"; then
  echo "Failed to download archive for ${PACKAGE_NAME}" >&2
  exit 1
fi

if [[ -z "${RPI4_FIRMWARE_PATH}" ]]; then
  RPI4_FIRMWARE_PATH=$(resolve_latest_rpi_eeprom_firmware "${ARCHIVE_TMP}" "firmware-2711")
fi

if [[ -z "${RPI5_FIRMWARE_PATH}" ]]; then
  RPI5_FIRMWARE_PATH=$(resolve_latest_rpi_eeprom_firmware "${ARCHIVE_TMP}" "firmware-2712")
fi

ARCHIVE_HASH=$(sha256sum "${ARCHIVE_TMP}" | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  # update package info
  BR_PACKAGE_NAME=${PACKAGE_NAME^^}
  BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  sed -Ei "s#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2711/(stable|latest)/.*#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2711/latest/${RPI4_FIRMWARE_PATH}#g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  sed -Ei "s#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2712/(stable|latest)/.*#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2712/latest/${RPI5_FIRMWARE_PATH}#g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  # update package hash
  sed -i "$ d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
