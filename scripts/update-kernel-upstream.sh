#!/bin/bash
set -e

ID=${1}
PACKAGE_NAME="linux"
PROJECT_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x"
#ARCHIVE_URL="${PROJECT_URL}/${PACKAGE_NAME}-${ID}.tar.xz"
CHECKSUM_URL="${PROJECT_URL}/sha256sums.asc"

if [[ -z "${ID}" ]]; then
  echo "Need a kernel version!"
  exit 1
fi

# extract sha256 checksum
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${CHECKSUM_URL}" | grep "${PACKAGE_NAME}-${ID}.tar.xz" | awk '{ print $1 }')
if [[ -z "${ARCHIVE_HASH}" ]]; then
  echo "no hash found for ${PACKAGE_NAME}-${ID}.tar.xz"
  exit 1
fi

# update kconfig file
sed -i "s/BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=\".*\"/BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=\"${ID}\"/g" buildroot-external/configs/{oci_*,odroid-*,ova,tinkerboard,generic-*}.config

# update hash files
sed -i "/${PACKAGE_NAME}-.*\.tar\.xz/d" "buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.xz" >>"buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
sed -i "/${PACKAGE_NAME}-.*\.tar\.xz/d" "buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash"
echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.xz" >>"buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash"
