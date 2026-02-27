#!/bin/sh

# Stop on error
set -e

# copy the kernel image to rootfs
cp -a "${BINARIES_DIR}/bzImage" "${TARGET_DIR}/zImage"

# copy grub boot.img to binaries dir
cp -f "${HOST_DIR}"/../build/grub2-2.??/build-i386-pc/grub-core/boot.img "${BINARIES_DIR}/"
