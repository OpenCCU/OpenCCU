#!/bin/sh
#
# post-build.sh script with common stuff todo for all platforms
#

# Stop on error
set -e

# create VERSION file
echo "VERSION=${PRODUCT_VERSION}" >"${TARGET_DIR}/VERSION"
echo "PRODUCT=${PRODUCT}" >>"${TARGET_DIR}/VERSION"
echo "PLATFORM=${PRODUCT_PLATFORM}" >>"${TARGET_DIR}/VERSION"

# fix some permissions
[ -e "${TARGET_DIR}/etc/monitrc" ] && chmod 600 "${TARGET_DIR}/etc/monitrc"

# rename some stuff buildroot introduced but we need differently
[ -e "${TARGET_DIR}/etc/init.d/S10udevd" ] && mv -f "${TARGET_DIR}/etc/init.d/S10udevd" "${TARGET_DIR}/etc/init.d/S00udevd"

# remove unnecessary stuff from TARGET_DIR
rm -f "${TARGET_DIR}/etc/init.d/S50crond"
rm -f "${TARGET_DIR}/etc/init.d/S35iptables"

# link VERSION in /boot on rootfs
mkdir -p "${TARGET_DIR}/boot"
ln -sf ../VERSION "${TARGET_DIR}/boot/VERSION"
