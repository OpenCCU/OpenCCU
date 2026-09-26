#!/bin/sh
# shellcheck shell=dash disable=SC2169 source=/dev/null

if [ -f /tmp/.runningFirmwareUpdate ]; then
  echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"
  echo "ERROR: firmware update is currently running"
  exit 1
fi

if ! mount | grep -q /userfs; then
  echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"
  echo "ERROR: userfs not available to create backup"
  exit 1
fi

if ! mount | grep -q /rootfs; then
  echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"
  echo "ERROR: rootfs not available to create backup"
  exit 1
fi

echo -ne "Content-Type: application/octet-stream\r\n"

if ! mount -o rw,remount /userfs; then
  echo "ERROR (rw remount)"
  exit 1
fi

# make sure BACKUPDIR exists
TMPDIR=$(mktemp -d -p /usr/local/tmp)

# create a gzipped tar of /usr/local
if ! /bin/tar --owner=root --group=root --exclude=userfs/tmp --exclude=userfs/lost+found --exclude="userfs/.*" --exclude-tag=.nobackup --one-file-system --ignore-failed-read -czf "${TMPDIR}/usr_local.tar.gz" --transform 's,^userfs,usr/local,' /userfs/; then
  echo "ERROR (tar)"
  exit 1
fi

# sign the configuration with the current key
if ! /bin/crypttool -s -t 1 <"${TMPDIR}/usr_local.tar.gz" >"${TMPDIR}/signature"; then
  echo "ERROR (crypttool sign)"
  exit 1
fi

# store the current key index
if ! /bin/crypttool -g -t 1 >"${TMPDIR}/key_index"; then
  echo "ERROR (crypttool store)"
  exit 1
fi

# store the firmware VERSION
source /rootfs/VERSION 2>/dev/null
if ! cp -a /rootfs/VERSION "${TMPDIR}/firmware_version"; then
  echo "ERROR (firmware_version)"
  exit 1
fi

# create sbk file
BACKUPFILE="/usr/local/tmp/${VERSION}-$(date +%Y-%m-%d-%H%M).sbk"
if ! /bin/tar -C "${TMPDIR}" --owner=root --group=root -cf "${BACKUPFILE}" usr_local.tar.gz signature key_index firmware_version 2>/dev/null; then
  echo "ERROR (tar .sbk)"
  exit 1
fi

# remove all temp files
rm -rf "${TMPDIR}"

if ! mount -o ro,remount /userfs; then
  echo "ERROR (ro remount)"
  exit 1
fi

echo -ne "X-Sendfile: ${BACKUPFILE}\r\n"
echo -ne "Content-Disposition: attachment; filename=\"$(basename "${BACKUPFILE}")\"\r\n\r\n"
