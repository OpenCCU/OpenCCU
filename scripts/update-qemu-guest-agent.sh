#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils/utils.sh
source "${SCRIPT_DIR}/utils/utils.sh"

ID=${1:-$(strip_v_prefix "$(resolve_latest_github_stable_tag "qemu" "qemu" '^[vV][0-9]+(\.[0-9]+)*$')")}
PACKAGE_NAME="qemu-guest-agent"
PROJECT_URL="https://download.qemu.org"
ARCHIVE_URL="${PROJECT_URL}/qemu-${ID}.tar.xz"

# download archive for hash update
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL}" | sha256sum | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  # update package info
  BR_PACKAGE_NAME=${PACKAGE_NAME^^}
  BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  # update package hash
  sed -i "$ d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  qemu-${ID}.tar.xz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
fi
