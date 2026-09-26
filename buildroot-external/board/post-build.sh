#!/bin/sh
#
# post-build.sh script with common stuff todo for all platforms
#

# Stop on error
set -e

# Buildroot's SysV skeleton starts with /var/run -> ../run. Replace it with
# a real directory before linking /run back to /var/run, and keep entries
# installed in /run by other packages.
if [ -L "${TARGET_DIR}/var/run" ]; then
  if [ "$(readlink "${TARGET_DIR}/var/run")" != ../run ]; then
    echo "Unexpected /var/run link: $(readlink "${TARGET_DIR}/var/run")" >&2
    exit 1
  fi
  rm "${TARGET_DIR}/var/run"
fi
mkdir -p "${TARGET_DIR}/var/run"

if [ -L "${TARGET_DIR}/run" ]; then
  if [ "$(readlink "${TARGET_DIR}/run")" != var/run ]; then
    echo "Unexpected /run link: $(readlink "${TARGET_DIR}/run")" >&2
    exit 1
  fi
elif [ -d "${TARGET_DIR}/run" ]; then
  cp -a "${TARGET_DIR}/run/." "${TARGET_DIR}/var/run/"
  rm -r "${TARGET_DIR}/run"
  ln -s var/run "${TARGET_DIR}/run"
elif [ -e "${TARGET_DIR}/run" ]; then
  echo "Cannot replace /run: not a directory" >&2
  exit 1
else
  ln -s var/run "${TARGET_DIR}/run"
fi

# create VERSION file
echo "VERSION=${PRODUCT_VERSION}" >"${TARGET_DIR}/VERSION"
echo "PRODUCT=${PRODUCT}" >>"${TARGET_DIR}/VERSION"
echo "PLATFORM=${PRODUCT_PLATFORM}" >>"${TARGET_DIR}/VERSION"

# fix some permissions
[ -e "${TARGET_DIR}/etc/monitrc" ] && chmod 600 "${TARGET_DIR}/etc/monitrc"

# rename some stuff buildroot introduced but we need differently
[ -e "${TARGET_DIR}/etc/init.d/S10udevd" ] && mv -f "${TARGET_DIR}/etc/init.d/S10udevd" "${TARGET_DIR}/etc/init.d/S00udevd"

# remove unnecessary stuff from TARGET_DIR
if [ "${RECOVERY_POST_BUILD:-no}" != yes ]; then
  rm -f "${TARGET_DIR}/etc/init.d/S50crond"
fi
rm -f "${TARGET_DIR}/etc/init.d/S35iptables"

# Only the main system exposes VERSION under /boot.
if [ "${RECOVERY_POST_BUILD:-no}" != yes ]; then
  mkdir -p "${TARGET_DIR}/boot"
  ln -sf ../VERSION "${TARGET_DIR}/boot/VERSION"
fi

# Apply component selection after the board overlays have been copied.
"$(dirname "$0")/../package/openccu-base/scripts/finalize-components.sh" \
  "${TARGET_DIR}" "${BR2_CONFIG}"
