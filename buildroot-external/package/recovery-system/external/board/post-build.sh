#!/bin/sh
# shellcheck source=/dev/null
#
# post-build.sh script with common stuff todo for all platforms
#

# Stop on error
set -e

# make sure VERSION exists in root of recoveryfs
echo "VERSION=${BR2_RECOVERY_SYSTEM_VERSION}" >"${TARGET_DIR}/VERSION"
echo "PRODUCT=${PRODUCT}" >>"${TARGET_DIR}/VERSION"
echo "PLATFORM=${PRODUCT_PLATFORM}" >>"${TARGET_DIR}/VERSION"

# Define parameters with default values
DHCP_VENDOR_ID=eQ3-CCU3
 
# Load product specific parameters
if [ -r "${TARGET_DIR}/etc/product" ]; then
  . "${TARGET_DIR}/etc/product"

  # Replace vendor ID in interfaces
  sed -i "s/eQ3-CCU3/${DHCP_VENDOR_ID}/g" "${TARGET_DIR}/etc/network/interfaces"
fi

# rename some stuff buildroot introduced but we need differently
[ -e "${TARGET_DIR}/etc/init.d/S10udevd" ] && mv -f "${TARGET_DIR}/etc/init.d/S10udevd" "${TARGET_DIR}/etc/init.d/S00udevd"

# remove unnecessary stuff from TARGET_DIR
rm -f "${TARGET_DIR}/etc/init.d/S35iptables"
