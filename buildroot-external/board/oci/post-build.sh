#!/bin/sh

# Stop on error
set -e

# remove unnecessary stuff from TARGET_DIR
rm -f "${TARGET_DIR}/etc/init.d/S01InitZRAMSwap"
rm -f "${TARGET_DIR}/etc/init.d/S01USBGadgetMode"
rm -f "${TARGET_DIR}/etc/init.d/S03seedrng"
rm -f "${TARGET_DIR}/etc/init.d/S40bluetooth"
#rm -f "${TARGET_DIR}/etc/init.d/S40network"
rm -f "${TARGET_DIR}/etc/init.d/S46chronyd"
rm -f "${TARGET_DIR}/etc/init.d/S49chronyd"
rm -f "${TARGET_DIR}/etc/init.d/S13irqbalance"
rm -f "${TARGET_DIR}/lib/udev/rules.d/usbmount.rules"
rm -f "${TARGET_DIR}/lib/udev/rules.d/76-usb-gadget.rules"
rm -f "${TARGET_DIR}/lib/udev/rules.d/99-hmip-rfusb.rules"
rm -rf "${TARGET_DIR}/usr/share/usbmount"
rm -rf "${TARGET_DIR}/etc/usbmount"
rm -rf "${TARGET_DIR}/etc/usb_modeswitch.d"
rm -f "${TARGET_DIR}/bin/dhcp.script"
rm -f "${TARGET_DIR}/bin/checkBadBlocks.sh"
rm -f "${TARGET_DIR}/etc/sysctl.conf"

# remove files managed by docker
rm -f "${TARGET_DIR}/etc/hosts"
rm -f "${TARGET_DIR}/etc/resolv.conf"
