#!/bin/bash
set -e

ID=${1}
PACKAGE_NAME="qemu-guest-agent"
PROJECT_URL="https://download.qemu.org"
ARCHIVE_URL="${PROJECT_URL}/qemu-${ID}.tar.xz"

if [[ -z "${ID}" ]]; then
  echo "tag name or commit sha required (see ${URL})"
  exit 1
fi

# download archive for hash update
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL}" | sha256sum | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  # update package info
  BR_PACKAGE_NAME=${PACKAGE_NAME^^}
  BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = $1/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  # update package hash
  sed -i "$ d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  qemu-${ID}.tar.xz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
fi
