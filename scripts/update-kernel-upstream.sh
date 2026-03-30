#!/bin/bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils/utils.sh
source "${SCRIPT_DIR}/utils/utils.sh"

PACKAGE_NAME="linux"
PROJECT_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x"
#ARCHIVE_URL="${PROJECT_URL}/${PACKAGE_NAME}-${ID}.tar.xz"
CHECKSUM_URL="${PROJECT_URL}/sha256sums.asc"

# extract sha256 checksum
if ! wget --passive-ftp -nd -t 3 --spider "${CHECKSUM_URL}"; then
  echo "Failed to download checksum list for ${PACKAGE_NAME}" >&2
  exit 1
fi
CHECKSUM_CONTENT=$(wget --passive-ftp -nd -t 3 -O - "${CHECKSUM_URL}")
ID=${1:-$(echo "${CHECKSUM_CONTENT}" | grep -oE "${PACKAGE_NAME}-6\.12\.[0-9]+\.tar\.xz" | sed -E "s/^${PACKAGE_NAME}-//; s/\.tar\.xz$//" | sort -V | tail -n1)}
ARCHIVE_HASH=$(echo "${CHECKSUM_CONTENT}" | grep "${PACKAGE_NAME}-${ID}.tar.xz" | awk '{ print $1 }')
if [[ -z "${ARCHIVE_HASH}" ]]; then
  echo "no hash found for ${PACKAGE_NAME}-${ID}.tar.xz"
  exit 1
fi

# update kconfig file
sed -i "s/BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=\".*\"/BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=\"${ID}\"/g" buildroot-external/configs/{oci_*,odroid-*,ova,generic-*,tinkerboard2}.config

# update hash files
sed -i "/${PACKAGE_NAME}-.*\.tar\.xz/d" "buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.xz" >>"buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
sed -i "/${PACKAGE_NAME}-.*\.tar\.xz/d" "buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash"
echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.xz" >>"buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash"
