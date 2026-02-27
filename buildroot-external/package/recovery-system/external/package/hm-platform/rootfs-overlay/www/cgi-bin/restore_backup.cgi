#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC2034 source=/dev/null

echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"

if [ -f /tmp/.runningFirmwareUpdate ]; then
  echo "ERROR: firmware update is currently running"
  exit 1
fi

echo -ne "[1/8] Checking /userfs... "

if ! mount | grep -q /userfs; then
  echo "ERROR: userfs not available"
  exit 1
fi
echo "done.<br>"

if ! mount -o rw,remount /userfs; then
  echo "ERROR (rw remount)"
  exit 1
fi

echo -ne "[2/8] Processing uploaded data... "

#####
# read security key settings first

# fake read boundary+disposition, etc.
read -r boundary
read -r disposition
read -r junk
read -r seckey

# retrieve security key
SECKEY=$(echo -e "${seckey}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# get length
boundary_len=$((${#boundary}+1))
disposition_len=$((${#disposition}+1))
junk_len=2
seckey_len=$((${#seckey}+1))
sum_len=$((boundary_len+disposition_len+junk_len+seckey_len))

#####
# read the uploaded data (binary)

# fake read boundary+disposition, etc.
read -r boundary
read -r disposition
read -r ctype
read -r junk

# get length
boundary_len=$((${#boundary}+1))
disposition_len=$((${#disposition}+1))
ctype_len=$((${#ctype}+1))
junk_len=2
sum_len=$((sum_len+boundary_len+disposition_len+ctype_len+junk_len))

# calculate the expected content length using
# HTTP_CONTENT_LENGTH or CONTENT_LENGTH
if [ -z "${HTTP_CONTENT_LENGTH}" ]; then
  HTTP_CONTENT_LENGTH=${CONTENT_LENGTH}
fi
SIZE=$((HTTP_CONTENT_LENGTH-sum_len-boundary_len-4))

# write out the data
filename=$(mktemp -p /usr/local/tmp)
if ! head -q -c $SIZE >"${filename}"; then
  echo "ERROR (head)"
  exit 1
fi

echo "$(stat -c%s "${filename}") bytes received.<br>"

echo -ne "[3/8] Calculating SHA256 checksum: "
if ! CHKSUM=$(/usr/bin/sha256sum "${filename}"); then
  echo "ERROR (sha256sum)"
  exit 1
fi
echo "$(echo "${CHKSUM}" | awk '{ print $1 }')<br>"

echo -ne "[3/8] Extracting to temp location... "

TMPDIR="${filename}-dir"
mkdir -p "${TMPDIR}"

if ! /bin/tar -C "${TMPDIR}" --warning=no-timestamp --no-same-owner -xf "${filename}" 2>/dev/null; then
  echo "ERROR (untar)"
  exit 1
fi

echo "OK<br>"

# check the firmware version
echo -ne "[4/8] Checking backup version... "
source "${TMPDIR}/firmware_version"
BACKUP_VERSION=${VERSION}
if [ "$(echo "${BACKUP_VERSION}" | cut -d'.' -f1)" != "2" ] && [ "$(echo "${BACKUP_VERSION}" | cut -d'.' -f1)" != "3" ]; then
  echo "ERROR: backup version (${BACKUP_VERSION}) not supported"
  exit 1
fi
echo "${BACKUP_VERSION}, OK<br>"

# verify security key settings
echo -ne "[5/8] Verifying security key settings... "
SYSTEM_HAS_USER_KEY=$(/bin/crypttool -v -t 0 >/dev/null; echo $?)
STORED_SIGNATURE=$(cat "${TMPDIR}/signature")
CALCED_SIGNATURE=$(/bin/crypttool -s -t 0 <"${TMPDIR}/usr_local.tar.gz")

# check for syskey
if [ "${SYSTEM_HAS_USER_KEY}" == "1" ]; then
  echo -ne "syskey, "
else
  echo -ne "NO syskey, "
fi

# check for userkey
if [ "${STORED_SIGNATURE}" != "${CALCED_SIGNATURE}" ]; then
  echo -ne "userkey, "

  # backup has a user key, so lets check if the provided security
  # key matches it
  VERIFIED_SIGNATURE=$(/bin/crypttool -t 3 -k "${SECKEY}" -s <"${TMPDIR}/usr_local.tar.gz")
  if [ "${STORED_SIGNATURE}" != "${VERIFIED_SIGNATURE}" ]; then
    echo "ERROR: provided key DOES NOT match backup key"
    exit 1
  else
    echo -ne "matches backupkey, "
  fi

else
  echo -ne "NO userkey, "
fi
echo "OK<br>"

# set seckey if no syskey is present but there is a user key
echo -ne "[6/8] Setting security key... "
if [ "${SYSTEM_HAS_USER_KEY}" == "0" ] && [ "${STORED_SIGNATURE}" != "${CALCED_SIGNATURE}" ]; then
  STORED_KEYINDEX=$(cat "${TMPDIR}/key_index")
  if [ -n "${STORED_KEYINDEX}" ]; then
    if ! /bin/crypttool -S -i "${STORED_KEYINDEX}" -k "${SECKEY}"; then
      echo "ERROR: crypttool cannot set provided security key (${STORED_KEYINDEX})"
      exit 1
    else
      echo "OK"
    fi
  else
    echo "ERROR: no key index found"
    exit 1
  fi
else
  echo "not required"
fi
echo "<br>"

# put usr_local.tar.gz to tmp dir
echo -ne "[7/8] Prepare backup restore... "
if ! mv -f "${TMPDIR}/usr_local.tar.gz" /usr/local/tmp/; then
  echo "ERROR (mv)"
  exit 1
fi

if ! touch /usr/local/.doBackupRestore; then
  echo "ERROR (touch)"
  exit 1
fi

if ! mount -o ro,remount /userfs; then
  echo "ERROR (ro umount)"
  exit 1
fi

echo "OK<br>"

echo "[8/8] Rebooting into Backup-Restore Mode..."
/sbin/reboot
