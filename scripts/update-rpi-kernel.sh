#!/bin/bash
set -e

ID=${1}
PACKAGE_NAME="linux"
PROJECT_URL="https://github.com/raspberrypi/linux"
ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${ID}.tar.gz"

if [[ -z "${ID}" ]]; then
  echo "tag name or commit sha required (see ${URL})"
  exit 1
fi

# download archive for hash update
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
fi
