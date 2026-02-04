#!/bin/bash
set -e

ID=${1}
PACKAGE_NAME="java-azul"
DOWNLOAD_URL="https://cdn.azul.com"

if [[ -z "${ID}" ]]; then
  echo "version id required (see ${URL})"
  exit 1
fi

# function to download archive hash for certain CPU
function updateHash() {
  local type=${1}
  local cpu=${2}

  # define project+archive url
  PROJECT_URL="${DOWNLOAD_URL}/${type}/bin"
  ARCHIVE_URL="${PROJECT_URL}/zulu${ID}-linux_CPU.tar.gz"

  # download archive for hash update
  ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL/CPU/${cpu}}" | sha256sum | awk '{ print $1 }')
  if [[ -n "${ARCHIVE_HASH}" ]]; then
    sed -i "/_${cpu}\.tar.gz/d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
    echo "sha256  ${ARCHIVE_HASH}  zulu${ID}-linux_${cpu}.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  fi
}

# update package info
BR_PACKAGE_NAME=${PACKAGE_NAME^^}
BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"

# update package hashes
updateHash zulu x64
updateHash zulu aarch64
