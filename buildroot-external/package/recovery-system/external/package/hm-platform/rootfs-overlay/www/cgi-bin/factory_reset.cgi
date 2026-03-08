#!/bin/sh
# shellcheck shell=dash disable=SC2169

echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"

if [ -f /tmp/.runningFirmwareUpdate ]; then
  echo "ERROR: firmware update is currently running"
  exit 1
fi

echo -ne "[1/3] Factory Reset: Checking requirements... "

DEVNAME=$(/sbin/blkid --label userfs)
if [ -n "${DEVNAME}" ] && [ -e "${DEVNAME}" ]; then
  umount -f "${DEVNAME}"
  echo "INFO: user partition '${DEVNAME}' exists.<br>"
else
  echo "ERROR: user partition '${DEVNAME}' does NOT exists. Please contact support hotline.<br>"
  exit 1
fi

echo -ne "[2/3] Factory Reset: Creating new user filesystem... "

if ! mkfs.ext4 -q -F -L userfs -I 256 -E lazy_itable_init=0,lazy_journal_init=0 "${DEVNAME}"; then
  echo "ERROR: mkfs.ext4 failed. Please contact support hotline.<br>"
else
  if ! tune2fs -c 0 -i 0 "${DEVNAME}" >/dev/null; then
    echo "ERROR: tune2fs failed. Please contact support hotline.<br>"
  else
    if ! e2fsck -pDf "${DEVNAME}" >/dev/null; then
      echo "ERROR: e2fsck failed. Please contact support hotline.<br>"
    fi
  fi
fi

# make sure to trigger a factory reset within
# the normal system as well (will reset the copro as well)
mount -o rw /userfs
touch /userfs/.doFactoryReset

# also remove extraconfig.txt from the boot partition if it exists
if [ -f /bootfs/extraconfig.txt ]; then
  if mount -o remount,rw /bootfs 2>/dev/null; then
    rm -f /bootfs/extraconfig.txt
    mount -o remount,ro /bootfs 2>/dev/null || true
  fi
fi

echo "done.<br>"

echo "[3/3] Rebooting...<br>"
/sbin/reboot
