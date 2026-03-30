#!/bin/bash
set -e
set -o pipefail

ID=${1}
PACKAGE_NAME="generic_raw_uart"
PROJECT_URL="https://github.com/alexreinert/piVCCU"
ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${PACKAGE_NAME}-${ID}.tar.gz"

if [[ -z "${ID}" ]]; then
  echo "tag name or commit sha required (see ${URL})"
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
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = $1/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  # update package hash
  sed -i "$ d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
