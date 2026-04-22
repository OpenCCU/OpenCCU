#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

ID=${1:-$(resolve_latest_github_stable_tag "raspberrypi" "linux" '^stable_[0-9]+$')}
PACKAGE_NAME="linux"
PROJECT_URL="https://github.com/raspberrypi/linux"
ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${ID}.tar.gz"
CURRENT_ID=$(sed -nE 's|.*BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION="https://github.com/raspberrypi/linux/archive/([^"]+)\.tar\.gz".*|\1|p' buildroot-external/configs/rpi4.config | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "rpi-kernel"
fi

# download archive for hash update
if ! wget --passive-ftp -nd -t 3 --spider "${ARCHIVE_URL}"; then
  echo "Failed to download archive for ${PACKAGE_NAME}" >&2
  exit 1
fi
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL}" | sha256sum | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then

  # get old stable version
  OLD_PACKAGE=$(sed -n 's/BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION="\(.*\)"/\1/p' buildroot-external/configs/rpi*.config | head -1 | xargs basename)

  # update package info
  sed -i "s|BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION=\"${PROJECT_URL}/.*\"|BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION=\"${PROJECT_URL}/archive/${ID}.tar.gz\"|g" buildroot-external/configs/rpi*.config

  # update hash files
  sed -i "/${OLD_PACKAGE}/d" "buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${ID}.tar.gz" >>"buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  sed -i "/${OLD_PACKAGE}/d" "buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${ID}.tar.gz" >>"buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
