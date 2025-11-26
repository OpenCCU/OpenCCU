#!/bin/bash

# Stop on error
set -e

#BOARD_DIR=${1}
PRODUCT=${2}
PRODUCT_VERSION=${3}
BOARD=${2}

# change into release dir
cd ./release

# copy the *.img and create checksum
cp -a "../build-${PRODUCT}/images/sdcard.img" "./OpenCCU-${PRODUCT_VERSION}-${BOARD}.img"
sha256sum "OpenCCU-${PRODUCT_VERSION}-${BOARD}.img" >"OpenCCU-${PRODUCT_VERSION}-${BOARD}.img.sha256"

# prepare the release *.zip
rm -f "./OpenCCU-${PRODUCT_VERSION}-${BOARD}.zip"
zip --junk-paths "./OpenCCU-${PRODUCT_VERSION}-${BOARD}.zip" "./OpenCCU-${PRODUCT_VERSION}-${BOARD}.img" "./OpenCCU-${PRODUCT_VERSION}-${BOARD}.img.sha256" ../LICENSE "./updatepkg/${PRODUCT}/EULA.de" "./updatepkg/${PRODUCT}/EULA.en"
sha256sum "OpenCCU-${PRODUCT_VERSION}-${BOARD}.zip" >"OpenCCU-${PRODUCT_VERSION}-${BOARD}.zip.sha256"

# prepare the release *.ova
cp -a "../build-${PRODUCT}/images/OpenCCU.ova" "./OpenCCU-${PRODUCT_VERSION}.ova"
sha256sum "OpenCCU-${PRODUCT_VERSION}.ova" >"OpenCCU-${PRODUCT_VERSION}.ova.sha256"

# create manifest file with checksum+sizes
rm -f "OpenCCU-${PRODUCT_VERSION}-${BOARD}.mf"

# shellcheck disable=SC2129
echo "$(stat -c %s "./OpenCCU-${PRODUCT_VERSION}-${BOARD}.img") $(cat "OpenCCU-${PRODUCT_VERSION}-${BOARD}.img.sha256")" >>"OpenCCU-${PRODUCT_VERSION}-${BOARD}.mf"
echo "$(stat -c %s "./OpenCCU-${PRODUCT_VERSION}-${BOARD}.zip") $(cat "OpenCCU-${PRODUCT_VERSION}-${BOARD}.zip.sha256")" >>"OpenCCU-${PRODUCT_VERSION}-${BOARD}.mf"
echo "$(stat -c %s "./OpenCCU-${PRODUCT_VERSION}.ova") $(cat "OpenCCU-${PRODUCT_VERSION}.ova.sha256")" >>"OpenCCU-${PRODUCT_VERSION}-${BOARD}.mf"
