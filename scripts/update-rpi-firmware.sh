#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

ID=${1:-$(resolve_latest_github_stable_tag "raspberrypi" "firmware" '^[0-9]+(\.[0-9]+)*$')}
PACKAGE_NAME="rpi-firmware"
PROJECT_URL="https://github.com/raspberrypi/firmware"
ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${ID}.tar.gz"
CURRENT_ID=$(sed -nE 's|.*BR2_PACKAGE_RPI_FIRMWARE_VERSION="(.*)".*|\1|p' buildroot-external/configs/rpi4.config | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "${PACKAGE_NAME}"
fi

# download archive for hash update
if ! wget --passive-ftp -nd -t 3 --spider "${ARCHIVE_URL}"; then
  echo "Failed to download archive for ${PACKAGE_NAME}" >&2
  exit 1
fi
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL}" | sha256sum | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then

  # update package info
  sed -i "s|BR2_PACKAGE_RPI_FIRMWARE_VERSION=\".*\"|BR2_PACKAGE_RPI_FIRMWARE_VERSION=\"${ID}\"|g" buildroot-external/configs/rpi*.config

  # update hash files
  sed -i "/rpi-firmware/d" "buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.gz" >>"buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
