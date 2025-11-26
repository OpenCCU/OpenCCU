#!/bin/sh

# Stop on error
set -e

BOARD_DIR="$(dirname "$0")"
#BOARD_NAME="$(basename "${BOARD_DIR}")"

# Use our own cmdline.txt
cp "${BOARD_DIR}/cmdline.txt" "${BINARIES_DIR}/"

#
# Create user filesystem
#
echo "Create user filesystem"
mkdir -p "${BUILD_DIR}/userfs"
touch "${BUILD_DIR}/userfs/.doFactoryReset"
rm -f "${BINARIES_DIR}/userfs.ext4"
"${HOST_DIR}/sbin/mkfs.ext4" -d "${BUILD_DIR}/userfs" -F -L userfs -I 256 -E lazy_itable_init=0,lazy_journal_init=0 "${BINARIES_DIR}/userfs.ext4" 3000

#
# VERSION File
#
cp "${TARGET_DIR}/boot/VERSION" "${BINARIES_DIR}"

# prepare grub config and bootloader
mkdir -p "${BINARIES_DIR}/boot/grub"
cp -a "${BOARD_DIR}/grub.cfg" "${BINARIES_DIR}/boot/grub/"

# create *.img file using genimage
support/scripts/genimage.sh -c "${BOARD_DIR}/genimage.cfg"

# lets create vmdk/vhdx/vdi files
"${HOST_DIR}/bin/qemu-img" convert -O vmdk -o subformat=streamOptimized "${BINARIES_DIR}/sdcard.img" "${BINARIES_DIR}/sdcard.vmdk"
#${HOST_DIR}/bin/qemu-img convert -O vhdx ${BINARIES_DIR}/sdcard.img ${BINARIES_DIR}/sdcard.vhdx
#${HOST_DIR}/bin/qemu-img convert -O vdi ${BINARIES_DIR}/sdcard.img ${BINARIES_DIR}/sdcard.vdi

# lets create an *.ova archive from the vmdk, template ovf file and
# also create a *.mf manifest file
OVADIR=$(mktemp -d)
cp -a "${BINARIES_DIR}/sdcard.vmdk" "${OVADIR}/OpenCCU.vmdk"
cp -a "${BOARD_DIR}/template.ovf" "${OVADIR}/OpenCCU.ovf"
(cd "${OVADIR}" && "${HOST_DIR}/bin/openssl" sha256 OpenCCU.* | sed 's/SHA2-256/SHA256/' >OpenCCU.mf)
tar -C "${OVADIR}" --owner=root --group=root -cf "${BINARIES_DIR}/OpenCCU.ova" OpenCCU.ovf OpenCCU.vmdk OpenCCU.mf
rm -rf "${OVADIR}"
