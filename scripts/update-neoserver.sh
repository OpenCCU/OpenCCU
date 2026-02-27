#!/bin/bash
set -e

PACKAGE_NAME="neoserver"
DOWNLOAD_URL="https://s3-eu-west-1.amazonaws.com/mediola-download/ccu3/neo_server.tar.gz"
VERSION_URL="https://s3-eu-west-1.amazonaws.com/mediola-download/ccu3/VERSION"

# download/check current version
VERSION=$(curl ${VERSION_URL})

# download latest archive
wget --passive-ftp -nd -t 3 -O "buildroot-external/package/${PACKAGE_NAME}/neo_server.tar.gz" ${DOWNLOAD_URL}

# update package info
BR_PACKAGE_NAME=${PACKAGE_NAME^^}
BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${VERSION}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"

# update package hash
ARCHIVE_HASH=$(sha256sum "buildroot-external/package/${PACKAGE_NAME}/neo_server.tar.gz" | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  sed -i "/neo_server\.tar\.gz/d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  neo_server.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
fi
