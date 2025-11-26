#!/bin/bash
set -e

ID=${1}
PACKAGE_NAME="rpi-firmware"
PROJECT_URL="https://github.com/raspberrypi/firmware"
ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${ID}.tar.gz"

if [[ -z "${ID}" ]]; then
  echo "tag name or commit sha required (see ${URL})"
  exit 1
fi

# download archive for hash update
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL}" | sha256sum | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then

  # update package info
  sed -i "s|BR2_PACKAGE_RPI_FIRMWARE_VERSION=\".*\"|BR2_PACKAGE_RPI_FIRMWARE_VERSION=\"${ID}\"|g" buildroot-external/configs/rpi*.config

  # update hash files
  sed -i "/rpi-firmware/d" "buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.gz" >>"buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
fi
