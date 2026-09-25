#!/bin/sh
# shellcheck source=/dev/null
#
# post-build.sh script with common stuff todo for all platforms
#

# Stop on error
set -e

# Define parameters with default values
DHCP_VENDOR_ID=eQ3-CCU3
 
# Load product specific parameters
if [ -r "${TARGET_DIR}/etc/product" ]; then
  . "${TARGET_DIR}/etc/product"

  # Replace vendor ID in interfaces
  sed -i "s/eQ3-CCU3/${DHCP_VENDOR_ID}/g" "${TARGET_DIR}/etc/network/interfaces"
fi

# Run the shared rootfs setup with the recovery version. Keep its cron service
# and omit the main system's /boot/VERSION link.
RECOVERY_POST_BUILD=yes PRODUCT_VERSION="${BR2_RECOVERY_SYSTEM_VERSION}" \
  "$(dirname "$0")/../../../../board/post-build.sh"
