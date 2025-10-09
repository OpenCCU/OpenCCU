#!/bin/sh

# Stop on error
set -e

# copy the kernel image to rootfs
cp -a "${BINARIES_DIR}/bzImage" "${TARGET_DIR}/zImage"

# remove unnecessary /lib/firmware stuff
rm -rf "${TARGET_DIR}/lib/firmware/intel-ucode"
rm -rf "${TARGET_DIR}/lib/firmware/amd-ucode"
