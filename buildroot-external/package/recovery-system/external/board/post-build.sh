#!/bin/sh
# shellcheck source=/dev/null
#
# post-build.sh script with common stuff todo for all platforms
#

# Stop on error
set -e
: "${TARGET_DIR:?TARGET_DIR must point to the recovery target directory}"

# Match the main system: /run and /var/run share the /var tmpfs.
# Normalize after packages and overlays, including on incremental builds.
# Do not follow unexpected links or discard package-provided runtime files.
if [ -L "${TARGET_DIR}/var" ]; then
  echo "ERROR: recovery /var must be a directory" >&2
  exit 1
fi
if [ -L "${TARGET_DIR}/var/run" ]; then
  case "$(readlink "${TARGET_DIR}/var/run")" in
    /run|../run) rm "${TARGET_DIR}/var/run" ;;
    *) echo "ERROR: unexpected recovery /var/run symlink" >&2; exit 1 ;;
  esac
fi
mkdir -p "${TARGET_DIR}/var/run"
if [ -L "${TARGET_DIR}/run" ]; then
  if [ "$(readlink "${TARGET_DIR}/run")" != "var/run" ]; then
    echo "ERROR: unexpected recovery /run symlink" >&2
    exit 1
  fi
else
  if [ -e "${TARGET_DIR}/run" ]; then
    # Buildroot's common skeleton supplies an empty /run/lock directory.
    if [ -d "${TARGET_DIR}/run/lock" ] && [ ! -L "${TARGET_DIR}/run/lock" ]; then
      rmdir "${TARGET_DIR}/run/lock" || {
        echo "ERROR: recovery /run/lock must be empty before linking" >&2
        exit 1
      }
    fi
    rmdir "${TARGET_DIR}/run" || {
      echo "ERROR: recovery /run must be an empty directory before linking" >&2
      exit 1
    }
  fi
  ln -s var/run "${TARGET_DIR}/run"
fi

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
