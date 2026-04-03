#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

if [[ -n "${1}" && "${1}" =~ ^pieeprom-.*\.bin$ ]]; then
  ID=$(resolve_latest_github_head_commit "raspberrypi" "rpi-eeprom")
  RPI_FIRMWARE_PATH=${1}
else
  ID=${1:-$(resolve_latest_github_head_commit "raspberrypi" "rpi-eeprom")}
  RPI_FIRMWARE_PATH=${2}
fi

PACKAGE_NAME="rpi-eeprom"
PROJECT_URL="https://github.com/raspberrypi/rpi-eeprom"
ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${PACKAGE_NAME}-${ID}.tar.gz"
CURRENT_ID=$(sed -nE 's/^RPI_EEPROM_VERSION = (.*)$/\1/p' "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "${PACKAGE_NAME}"
fi

if [[ -z "${RPI_FIRMWARE_PATH}" ]]; then
  echo "Need rpi-eeprom version (pieeprom-2021-04-29.bin)"
  echo "Usage: $0 [<rpi-eeprom-commit>] <pieeprom-YYYY-MM-DD.bin>  (or: $0 <pieeprom-YYYY-MM-DD.bin> for latest commit)"
  exit 1
fi

# download archive for hash update
if ! wget --passive-ftp -nd -t 3 --spider "${ARCHIVE_URL}"; then
  echo "Failed to download archive for ${PACKAGE_NAME}" >&2
  exit 1
fi
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL}" | sha256sum | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  # update package info
  BR_PACKAGE_NAME=${PACKAGE_NAME^^}
  BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  sed -i "s/${BR_PACKAGE_NAME}_FIRMWARE_PATH = .*/${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware\/stable\/${RPI_FIRMWARE_PATH}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  # update package hash
  sed -i "$ d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
