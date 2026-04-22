#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

PACKAGE_NAME="neoserver"
DOWNLOAD_URL="https://s3-eu-west-1.amazonaws.com/mediola-download/ccu3/neo_server.tar.gz"
VERSION_URL="https://s3-eu-west-1.amazonaws.com/mediola-download/ccu3/VERSION"

# download/check current version
if [[ -n "${1}" ]]; then
  VERSION=${1}
else
  VERSION=$(curl -fsSL "${VERSION_URL}") || {
    echo "Failed to fetch version for ${PACKAGE_NAME} from ${VERSION_URL}" >&2
    exit 1
  }
fi
CURRENT_VERSION=$(sed -nE 's/^NEOSERVER_VERSION = (.*)$/\1/p' "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_VERSION}" "${VERSION}" "${PACKAGE_NAME}"
fi

# download latest archive
wget --passive-ftp -nd -t 3 -O "buildroot-external/package/${PACKAGE_NAME}/neo_server.tar.gz" ${DOWNLOAD_URL}

# update package hash
ARCHIVE_HASH=$(sha256sum "buildroot-external/package/${PACKAGE_NAME}/neo_server.tar.gz" | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  sed -i "/neo_server\.tar\.gz/d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  neo_server.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  # update package info
  BR_PACKAGE_NAME=${PACKAGE_NAME^^}
  BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${VERSION}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
