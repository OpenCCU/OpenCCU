#!/bin/bash

# Stop on error
set -e

#BOARD_DIR=${1}
PRODUCT=${2}
PRODUCT_VERSION=${3}
BOARD=${2}

# copy prepared docker image to release path
cp -a "build-${PRODUCT}/images/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar" ./release/
#(cd "./release/updatepkg/${PRODUCT}" && tar --numeric-owner --owner=root --group=root -rvf "../../OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar" update_script EULA.de EULA.en)
gzip -f "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar"
mv "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar.gz" "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tgz"
(cd ./release && sha256sum "OpenCCU-${PRODUCT_VERSION}-${BOARD}.tgz" >"OpenCCU-${PRODUCT_VERSION}-${BOARD}.tgz.sha256")

# create manifest file with checksum+sizes
rm -f "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.mf"

# shellcheck disable=SC2129
echo "$(stat -c %s "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tgz") $(cat "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tgz.sha256")" >>"./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.mf"
