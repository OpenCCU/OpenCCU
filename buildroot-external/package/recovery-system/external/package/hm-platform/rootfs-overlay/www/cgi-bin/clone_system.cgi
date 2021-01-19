#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC2034

echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"

if [ -f /tmp/.runningFirmwareUpdate ]; then
  echo "ERROR: firmware update is currently running"
  exit 1
fi

echo -ne "[1/11] Checking source device... "

SOURCE_BOOTFS=$(/bin/mountpoint -n /bootfs | cut -d" " -f1)
if [[ -z "${SOURCE_BOOTFS}" ]]; then
  echo "ERROR: /bootfs not found"
  exit 1
fi

SOURCE_ROOTFS=$(/bin/mountpoint -n /rootfs | cut -d" " -f1)
if [[ -z "${SOURCE_ROOTFS}" ]]; then
  echo "ERROR: /rootfs not found"
  exit 1
fi

SOURCE_USERFS=$(/bin/mountpoint -n /userfs | cut -d" " -f1)
if [[ -z "${SOURCE_USERFS}" ]]; then
  echo "ERROR: /userfs not found"
  exit 1
fi

DEVNODE=$(/bin/mountpoint -d /rootfs)
SOURCE_DEV="/dev/$(readlink "/sys/dev/block/${DEVNODE}" | awk -F/ '{print $(NF-1)}')"

echo "${SOURCE_DEV}. done.<br/>"

echo -ne "[2/11] Checking target device... "

#####
# read target device name

# fake read boundary+disposition, etc.
read -r boundary
read -r disposition
read -r junk
read -r targetDevice

# retrieve target device name
TARGET_DEV=$(echo -e "${targetDevice}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
echo "${TARGET_DEV}. done.<br/>"

echo -ne "[3/11] Unmounting filesystems from target device... "
for mp in $(lsblk -r -p -n -o MOUNTPOINT "${TARGET_DEV}"); do
  if [[ -n "${mp}" ]]; then
    umount -f "${mp}"
  fi
done

echo "done.<br/>"

echo -ne "[4/11] Cloning boot sector... "

if ! /bin/dd if="${SOURCE_DEV}" of="${TARGET_DEV}" bs=1M count=1 conv=fsync status=none >/dev/null 2>&1; then
  echo "ERROR: cloning boot sector failed<br/>"
  exit 1
fi

echo "done.<br/>"

echo -ne "[5/11] Cloning partition table... "

if ! /sbin/sfdisk -q -d "${SOURCE_DEV}" | sfdisk --no-reread --force -q "${TARGET_DEV}" >/dev/null 2>&1; then
  echo "ERROR: cloning partition table failed (enough space on target device?)<br/>"
  exit 1
fi

# call partprobe to check for changed partitions on target device
if ! /usr/sbin/partprobe "${TARGET_DEV}"; then
  echo "ERROR: couldn't probe for new partitions<br/>"
  exit 1
fi

# check the device nodes of each new partition
TARGET_BOOTFS=$(/sbin/blkid | grep "${TARGET_DEV}" | grep deedbeef-01 | cut -d: -f1)
if [[ -z "${TARGET_BOOTFS}" ]]; then
  echo "ERROR: target bootfs missing<br/>"
  exit 1
fi

TARGET_ROOTFS=$(/sbin/blkid | grep "${TARGET_DEV}" | grep deedbeef-02 | cut -d: -f1)
if [[ -z "${TARGET_ROOTFS}" ]]; then
  echo "ERROR: target rootfs missing<br/>"
  exit 1
fi

TARGET_USERFS=$(/sbin/blkid | grep "${TARGET_DEV}" | grep deedbeef-03 | cut -d: -f1)
if [[ -z "${TARGET_USERFS}" ]]; then
  echo "ERROR: target userfs missing<br/>"
  exit 1
fi

echo "done.<br/>"

echo -ne "[6/11] Cloning partition 1 (bootfs)... "

umount -f "${SOURCE_BOOTFS}"
if ! /bin/dd if="${SOURCE_BOOTFS}" of="${TARGET_BOOTFS}" bs=4M conv=fsync status=none >/dev/null 2>&1; then
  echo "ERROR: cloning bootfs<br/>"
  exit 1
fi
mount -o ro "${SOURCE_BOOTFS}" /bootfs

echo "done.<br/>"

echo -ne "[7/11] Cloning partition 2 (rootfs)... "

umount -f "${SOURCE_ROOTFS}"
if ! /bin/dd if="${SOURCE_ROOTFS}" of="${TARGET_ROOTFS}" bs=4M conv=fsync status=none >/dev/null 2>&1; then
  echo "ERROR: cloning rootfs<br/>"
  exit 1
fi
mount -o ro "${SOURCE_ROOTFS}" /rootfs

echo "done.<br/>"

echo -ne "[8/11] Check for resizing userfs partition... "
PARTNUM=3
START_CHS=$(parted -s "${TARGET_DEV}" unit chs print | grep "^ ${PARTNUM} " | awk '{print $2}')
END_CHS=$(parted -s "${TARGET_DEV}" unit chs print | grep "^ ${PARTNUM} " | awk '{print $3}')
MAX_CHS=$(parted -s "${TARGET_DEV}" unit chs print | grep "^Disk ${TARGET_DEV}:" | cut -d' ' -f3)

if [[ -n "${START_CHS}" && -n "${END_CHS}" && -n "${MAX_CHS}" && "${END_CHS}" != "${MAX_CHS}" ]]; then
  echo -ne "resizing... "

  # use resizepart to resize the /usr/local partition to the maximum size of
  # the disk
  if ! parted -s "${TARGET_DEV}" resizepart ${PARTNUM} 100%; then
    echo "ERROR: resizepart failed<br/>"
    exit 1
  fi

  # force PARTUUID to 0xDEEDBEEF (because parted changes partuuid)
  echo -en '\xEF\xBE\xED\xDE' | dd of="${TARGET_DEV}" conv=notrunc bs=1 seek=$((0x1B8)) 2>/dev/null
else
  echo -ne "not required... "
fi
echo "done.<br/>"

echo -ne "[9/11] Re-creating partition 3 (userfs)... "

# recreate userfs on target device
if ! mkfs.ext4 -q -F -L userfs "${TARGET_USERFS}" >/dev/null 2>&1; then
  echo "ERROR: mkfs.ext4 (userfs) failed<br/>"
  exit 1
fi

if ! tune2fs -c 0 -i 0 "${TARGET_USERFS}" >/dev/null 2>&1; then
  echo "ERROR: tune2fs (userfs) failed<br/>"
  exit 1
fi

if ! e2fsck -pDf "${TARGET_USERFS}" >/dev/null 2>&1; then
  echo "ERROR: e2fsck (userfs) failed<br/>"
  exit 1
fi

echo "done.<br/>"

echo -ne "[10/11] Copying partition 3 (userfs)... "

if ! /bin/mount "${TARGET_USERFS}" /mnt; then
  echo "ERROR: mount (userfs) failed<br/>"
  exit 1
fi

if ! mount -o ro,remount /userfs; then
  echo "ERROR: ro-remount (userfs-old) failed<br/>"
  exit 1
fi

if ! rsync -aq --exclude="lost+found" /userfs/ /mnt/; then
  echo "ERROR: copying data failed (enough space on target device?)<br/>"
  exit 1
fi

echo "done.<br/>"

echo -ne "[11/11] Unmounting all devices now... "

if ! umount -f /mnt; then
  echo "ERROR: umount (userfs-new) failed<br/>"
  exit 1
fi

if ! umount -f /userfs; then
  echo "ERROR: umount (userfs-old) failed<br/>"
  exit 1
fi

if ! umount -f /rootfs; then
  echo "ERROR: umount (rootfs) failed<br/>"
  exit 1
fi

if ! umount -f /bootfs; then
  echo "ERROR: umount (bootfs) failed<br/>"
  exit 1
fi

echo "done.<br/>"

echo -ne "Clone operation successfully finished.<br/><br/>"
echo -ne "WARNING: Please poweroff your system now and make sure to only have<br/>"
echo -ne "one device with either the clone or real system connected. Otherwise the<br/>"
echo "system might boot from the incorrect device on the next boot cycle.<br/>"
