#!/bin/bash

# Stop on error
set -e

#BOARD_DIR=${1}
PRODUCT=${2}
PRODUCT_VERSION=${3}
BOARD=${2}

# copy prepared docker image to release path
cp -a "build-${PRODUCT}/images/rootfs.tar" "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar"
#(cd "./release/updatepkg/${PRODUCT}" && tar --numeric-owner --owner=root --group=root -rvf "../../OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar" update_script EULA.de EULA.en)
xz -z -T 0 "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar"
(cd ./release && sha256sum "OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar.xz" >"OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar.xz.sha256")

# create manifest file with checksum+sizes
rm -f "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.mf"

# shellcheck disable=SC2129
echo "$(stat -c %s "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar.xz") $(cat "./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.tar.xz.sha256")" >>"./release/OpenCCU-${PRODUCT_VERSION}-${BOARD}.mf"
