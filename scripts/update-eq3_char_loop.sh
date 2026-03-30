#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

ID=${1:-$(resolve_latest_github_head_commit_for_path "eq-3" "occu" "KernelDrivers")}
PACKAGE_NAME="eq3_char_loop"
PROJECT_URL="https://github.com/eq-3/occu"
ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${PACKAGE_NAME}-${ID}.tar.gz"
CURRENT_ID=$(sed -nE 's/^EQ3_CHAR_LOOP_VERSION = (.*)$/\1/p' "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

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
  BR_PACKAGE_NAME=${PACKAGE_NAME^^}
  BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  # update package hash
  sed -i "$ d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
