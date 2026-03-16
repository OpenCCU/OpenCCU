#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010,SC3036,SC3014,SC3015 source=/dev/null
#
# General purpose shell script to prepare and install a firmware update
# either archived or unarchived, verifies its validity and installs it
# unattended accordingly.
#
# Copyright (c) 2018-2026 Jens Maus <mail@jens-maus.de>
# Apache 2.0 License applies
#

######
# function that is called to resize the rootfs partition
resize_rootfs()
{
  #
  # Implements resizing of the rootfs partition by shifting the userfs
  # filesystem (LABEL=userfs) to the right using e2image -O, then rewriting
  # the partition table accordingly.
  #
  # Assumptions (OpenCCU default):
  #   LABEL=bootfs, LABEL=rootfs, LABEL=userfs
  #   MBR label-id is fixed to 0xdeedbeef, GPT label-id is DEEDBEEF-0000-0000-0000-000000000000 (PARTUUID stability)
  #
  # Parameters:
  #   $1: current size in bytes
  #   $2: desired size in bytes
  #

  local SRC_SIZE=${1}  # bytes
  local DST_SIZE=${2}  # bytes
  local BOOT_DEV ROOT_DEV USER_DEV DISK_DEV SECTOR_SIZE SFDISK_DUMP
  local LINE_BOOT LINE_ROOT LINE_USER
  local BOOT_START BOOT_SIZE BOOT_TYPE
  local ROOT_START ROOT_SIZE ROOT_TYPE
  local USER_START USER_SIZE USER_TYPE
  local USER_END NEW_ROOT_SIZE NEW_ROOT_END NEW_USER_START SHIFT_SECTORS
  local NEW_USER_SIZE SFDISK_RC
  local SHIFT_BYTES OLD_USER_BYTES MAX_FS_BYTES
  local FS_BLKSZ MIN_BLKS MAX_BLKS MARGIN_BLKS TARGET_BLKS
  local OLD_USER_OFFSET NEW_USER_OFFSET
  local E2FSCK_RC E2FSCK_USER_RC
  local LABEL_TYPE LABEL_ID FIRST_LBA
  local BOOT_UUID BOOT_NAME BOOT_ATTRS
  local ROOT_UUID ROOT_NAME ROOT_ATTRS
  local USER_UUID USER_NAME USER_ATTRS
  if [[ -z "${SRC_SIZE}" ]] || [[ -z "${DST_SIZE}" ]] || \
     [[ "${SRC_SIZE}" -le 0 ]] || [[ "${DST_SIZE}" -le 0 ]]; then
    echo "ERROR: (invalid resize_rootfs arguments: src=${SRC_SIZE} dst=${DST_SIZE})"
    return 1
  fi

  # Resolve devnodes by LABEL
  BOOT_DEV=$(/sbin/blkid --label bootfs 2>/dev/null || true)
  ROOT_DEV=$(/sbin/blkid --label rootfs 2>/dev/null || true)
  USER_DEV=$(/sbin/blkid --label userfs 2>/dev/null || true)
  if [[ -z "${BOOT_DEV}" ]] || [[ -z "${ROOT_DEV}" ]] || [[ -z "${USER_DEV}" ]]; then
    echo "ERROR: (blkid labels)"
    return 1
  fi

  echo -ne "${ROOT_DEV}: ${SRC_SIZE} => ${DST_SIZE}, "

  if [[ ${DST_SIZE} -gt ${SRC_SIZE} ]]; then
    echo -ne "enlarge, "
  elif [[ ${DST_SIZE} -lt ${SRC_SIZE} ]]; then
    echo -ne "reduce, "
  else
    echo "no change"
    return 0
  fi

  # unmount (do not abort if already unmounted)
  umount -f /bootfs 2>/dev/null || true
  umount -f /rootfs 2>/dev/null || true
  umount -f /userfs 2>/dev/null || true

  # determine parent disk (handles /dev/mmcblk0p2 and /dev/nvme0n1p3)
  DISK_DEV="/dev/$(lsblk -d -n -i -o PKNAME "${ROOT_DEV}")"
  if [[ "${DISK_DEV}" == "/dev/" ]] || [[ ! -b "${DISK_DEV}" ]]; then
    echo "ERROR: (cannot determine disk devnode)"
    return 1
  fi

  # sector size (default 512)
  SECTOR_SIZE=$(/sbin/blockdev --getss "${DISK_DEV}" 2>/dev/null || echo 512)

  # DST_SIZE must be sector-aligned (it should be, as it comes from fdisk/stat)
  if [[ $((DST_SIZE % SECTOR_SIZE)) -ne 0 ]]; then
    echo "ERROR: (DST_SIZE not sector aligned: ${DST_SIZE} % ${SECTOR_SIZE})"
    return 1
  fi

  SFDISK_DUMP=$(/sbin/sfdisk -d "${DISK_DEV}" 2>/dev/null)
  if [[ -z "${SFDISK_DUMP}" ]]; then
    echo "ERROR: (sfdisk -d)"
    return 1
  fi

  # Detect partition table type (dos or gpt) and label-id
  LABEL_TYPE=$(echo "${SFDISK_DUMP}" | awk '/^label:/ {print $2; exit}')
  LABEL_ID=$(echo "${SFDISK_DUMP}" | awk '/^label-id:/ {print $2; exit}')
  FIRST_LBA=$(echo "${SFDISK_DUMP}" | awk '/^first-lba:/ {print $2; exit}')

  # Validate that the disk uses the fixed OpenCCU label-id (MBR: 0xdeedbeef, GPT: DEEDBEEF-0000-0000-0000-000000000000)
  if ! echo "${SFDISK_DUMP}" | grep -E -i -q '^label-id: (0xdeedbeef|deedbeef-0000-0000-0000-000000000000)'; then
    echo "ERROR: (disk label-id is not OpenCCU-standard, not an OpenCCU disk)"
    return 1
  fi

  _get_line() {
    local dev=${1}
    echo "${SFDISK_DUMP}" | awk -v p="${dev}" '{ gsub(/\r/,"",$0); if (substr($0,1,length(p))==p) { print $0; exit } }'
  }
  _get_num() {
    local line=${1}
    local key=${2}
    printf '%s\n' "${line}" | awk -v k="${key}" '
      { gsub(/\r/,"",$0); gsub(/,/,"",$0);
        for(i=1;i<=NF;i++){
          if($i==k"="){v=$(i+1); gsub(/[^0-9]/,"",v); print v; exit}
          if(index($i,k"=")==1){v=$i; sub(k"=","",v); gsub(/[^0-9]/,"",v); print v; exit}
        }
      }'
  }
  _get_type() {
    local line=${1}
    printf '%s\n' "${line}" | awk '
      { gsub(/\r/,"",$0); gsub(/,/,"",$0);
        for(i=1;i<=NF;i++){
          if($i=="type="){v=$(i+1); gsub(/[^0-9A-Fa-f-]/,"",v); print v; exit}
          if(index($i,"type=")==1){v=$i; sub("type=","",v); gsub(/[^0-9A-Fa-f-]/,"",v); print v; exit}
        }
      }'
  }
  _get_uuid() {
    local line=${1}
    printf '%s\n' "${line}" | awk '
      { gsub(/\r/,"",$0); gsub(/,/,"",$0);
        for(i=1;i<=NF;i++){
          if(index($i,"uuid=")==1){v=$i; sub("uuid=","",v); print v; exit}
        }
      }'
  }
  _get_name() {
    local line=${1}
    printf '%s\n' "${line}" | awk '
      { gsub(/\r/,"",$0); gsub(/,/,"",$0);
        for(i=1;i<=NF;i++){
          if(index($i,"name=")==1){v=$i; sub("name=","",v); print v; exit}
        }
      }'
  }
  _get_attrs() {
    local line=${1}
    printf '%s\n' "${line}" | awk '
      { gsub(/\r/,"",$0); gsub(/,/,"",$0);
        for(i=1;i<=NF;i++){
          if(index($i,"attrs=")==1){v=$i; sub("attrs=","",v); print v; exit}
        }
      }'
  }
  _write_sfdisk() {
    local _nrs=${1} _ust=${2} _usz=${3}
    local _boot_line _root_line _user_line
    if [[ "${LABEL_TYPE}" == "gpt" ]]; then
      _boot_line="${BOOT_DEV} : start=${BOOT_START}, size=${BOOT_SIZE}, type=${BOOT_TYPE}, uuid=${BOOT_UUID}, name=${BOOT_NAME}"
      [[ -n "${BOOT_ATTRS}" ]] && _boot_line="${_boot_line}, attrs=${BOOT_ATTRS}"
      _root_line="${ROOT_DEV} : start=${ROOT_START}, size=${_nrs}, type=${ROOT_TYPE}, uuid=${ROOT_UUID}, name=${ROOT_NAME}"
      [[ -n "${ROOT_ATTRS}" ]] && _root_line="${_root_line}, attrs=${ROOT_ATTRS}"
      _user_line="${USER_DEV} : start=${_ust}, size=${_usz}, type=${USER_TYPE}, uuid=${USER_UUID}, name=${USER_NAME}"
      [[ -n "${USER_ATTRS}" ]] && _user_line="${_user_line}, attrs=${USER_ATTRS}"
      printf 'label: gpt\nlabel-id: %s\ndevice: %s\nunit: sectors\nsector-size: %s\nfirst-lba: %s\n\n%s\n%s\n%s\n' \
        "${LABEL_ID}" "${DISK_DEV}" "${SECTOR_SIZE}" "${FIRST_LBA}" \
        "${_boot_line}" "${_root_line}" "${_user_line}" | /sbin/sfdisk "${DISK_DEV}"
    else
      /sbin/sfdisk "${DISK_DEV}" <<EOF
label: dos
label-id: 0xdeedbeef
device: ${DISK_DEV}
unit: sectors
sector-size: ${SECTOR_SIZE}

${BOOT_DEV} : start=${BOOT_START}, size=${BOOT_SIZE}, type=${BOOT_TYPE}, bootable
${ROOT_DEV} : start=${ROOT_START}, size=${_nrs}, type=${ROOT_TYPE}
${USER_DEV} : start=${_ust}, size=${_usz}, type=${USER_TYPE}
EOF
    fi
  }

  LINE_BOOT=$(_get_line "${BOOT_DEV}")
  LINE_ROOT=$(_get_line "${ROOT_DEV}")
  LINE_USER=$(_get_line "${USER_DEV}")
  if [[ -z "${LINE_BOOT}" ]] || [[ -z "${LINE_ROOT}" ]] || [[ -z "${LINE_USER}" ]]; then
    echo "ERROR: (cannot parse sfdisk lines)"
    return 1
  fi

  BOOT_START=$(_get_num "${LINE_BOOT}" start)
  BOOT_SIZE=$(_get_num "${LINE_BOOT}" size)
  BOOT_TYPE=$(_get_type "${LINE_BOOT}")

  ROOT_START=$(_get_num "${LINE_ROOT}" start)
  ROOT_SIZE=$(_get_num "${LINE_ROOT}" size)
  ROOT_TYPE=$(_get_type "${LINE_ROOT}")

  USER_START=$(_get_num "${LINE_USER}" start)
  USER_SIZE=$(_get_num "${LINE_USER}" size)
  USER_TYPE=$(_get_type "${LINE_USER}")

  # For GPT: extract per-partition uuid, name, and optional attrs
  if [[ "${LABEL_TYPE}" == "gpt" ]]; then
    BOOT_UUID=$(_get_uuid "${LINE_BOOT}")
    BOOT_NAME=$(_get_name "${LINE_BOOT}")
    BOOT_ATTRS=$(_get_attrs "${LINE_BOOT}")
    ROOT_UUID=$(_get_uuid "${LINE_ROOT}")
    ROOT_NAME=$(_get_name "${LINE_ROOT}")
    ROOT_ATTRS=$(_get_attrs "${LINE_ROOT}")
    USER_UUID=$(_get_uuid "${LINE_USER}")
    USER_NAME=$(_get_name "${LINE_USER}")
    USER_ATTRS=$(_get_attrs "${LINE_USER}")
  fi

  if [[ -z "${ROOT_START}" ]] || [[ -z "${ROOT_SIZE}" ]] || [[ -z "${USER_START}" ]] || [[ -z "${USER_SIZE}" ]]; then
    echo "ERROR: (invalid partition geometry)"
    return 1
  fi

  if [[ -z "${BOOT_START}" ]] || [[ -z "${BOOT_SIZE}" ]] || \
     [[ -z "${BOOT_TYPE}" ]] || [[ -z "${ROOT_TYPE}" ]] || [[ -z "${USER_TYPE}" ]]; then
    echo "ERROR: (invalid partition type/geometry for boot or type fields)"
    return 1
  fi

  USER_END=$((USER_START + USER_SIZE - 1))

  NEW_ROOT_SIZE=$((DST_SIZE / SECTOR_SIZE))
  NEW_ROOT_END=$((ROOT_START + NEW_ROOT_SIZE - 1))
  NEW_USER_START=$((NEW_ROOT_END + 1))
  SHIFT_SECTORS=$((NEW_USER_START - USER_START))

  # Default: keep userfs at its current size (overridden when shift > 0)
  NEW_USER_SIZE=${USER_SIZE}

  # If shrinking rootfs would require a left-move of userfs, we keep userfs
  # unchanged and accept a gap (safe, sufficient for smaller images).
  if [[ ${SHIFT_SECTORS} -lt 0 ]]; then
    echo -ne "no userfs shift needed (gap), "

    # Now shrink only the rootfs partition; keep userfs partition unchanged (gap remains).
    _write_sfdisk "${NEW_ROOT_SIZE}" "${USER_START}" "${USER_SIZE}"
    SFDISK_RC=$?
    if [[ ${SFDISK_RC} -ne 0 ]]; then
      echo "ERROR: (sfdisk rewrite)"
      return 1
    fi
    partprobe "${DISK_DEV}" 2>/dev/null || true

    # Final fresh mkfs because rootfs content will anyway be replaced next
    mkfs.ext4 -F -L rootfs -I 256 -E lazy_itable_init=0,lazy_journal_init=0 "${ROOT_DEV}" || { echo "ERROR: (mkfs.ext4 rootfs)"; return 1; }

    mount /bootfs       || { echo "ERROR: (mount /bootfs)"; return 1; }
    mount /rootfs       || { echo "ERROR: (mount /rootfs)"; return 1; }
    mount -o rw /userfs || { echo "ERROR: (mount /userfs)"; return 1; }

    echo "OK"
    return 0

  fi

  # check if we need to realign userfs
  if [[ ${SHIFT_SECTORS} -gt 0 ]]; then
    # rootfs grow => move userfs right by SHIFT_SECTORS
    SHIFT_BYTES=$((SHIFT_SECTORS * SECTOR_SIZE))
    NEW_USER_SIZE=$((USER_END - NEW_USER_START + 1))
    if [[ ${NEW_USER_SIZE} -le 0 ]]; then
      echo "ERROR: (not enough space: userfs would become <= 0)"
      return 1
    fi

    echo -ne "move userfs +${SHIFT_SECTORS} sectors, "
    e2fsck -f -y "${USER_DEV}" >/dev/null 2>&1
    E2FSCK_RC=$?
    if [[ ${E2FSCK_RC} -ge 4 ]]; then
      echo "ERROR: (e2fsck userfs, rc=${E2FSCK_RC})"
      return 1
    fi

    # --- Pre-check: ensure userfs can be shrunk enough before we attempt a move ---
    # We must satisfy two constraints BEFORE rewriting the partition table:
    #   (1) Filesystem size must be <= (old userfs partition bytes - SHIFT_BYTES)
    #   (2) Filesystem size must be >= the ext4 minimum size (resize2fs -P)
    # If this is not possible, abort early so we do NOT end up with an invalid userfs.

    # ext4 block size (bytes)
    FS_BLKSZ=$(/sbin/dumpe2fs -h "${USER_DEV}" 2>/dev/null | awk -F: '/Block size:/ {gsub(/ /,"",$2); print $2; exit}')
    [[ -n "${FS_BLKSZ}" ]] || FS_BLKSZ=4096

    # ext4 minimum blocks
    MIN_BLKS=$(resize2fs -P "${USER_DEV}" 2>/dev/null | awk '{print $NF}' | tail -1)
    if [[ -z "${MIN_BLKS}" ]]; then
      echo "ERROR: (cannot determine userfs minimum size via resize2fs -P)"
      return 1
    fi

    # Maximum filesystem blocks we can keep so the FS fits *after* shifting right by SHIFT_BYTES
    OLD_USER_BYTES=$((USER_SIZE * SECTOR_SIZE))
    MAX_FS_BYTES=$((OLD_USER_BYTES - SHIFT_BYTES))
    if [[ ${MAX_FS_BYTES} -le 0 ]]; then
      echo "ERROR: (shift too large for userfs device)"
      return 1
    fi
    MAX_BLKS=$((MAX_FS_BYTES / FS_BLKSZ))

    if [[ ${MAX_BLKS} -lt ${MIN_BLKS} ]]; then
      echo "ERROR: (userfs cannot be shrunk enough: min=${MIN_BLKS} blks, max=${MAX_BLKS} blks)"
      echo "ERROR: (aborting without rewriting partition table)"
      return 1
    fi

    # Keep a small margin (in filesystem blocks) to avoid edge rounding issues.
    # 1024 blocks @4KiB = 4MiB.
    MARGIN_BLKS=1024
    TARGET_BLKS=${MAX_BLKS}
    if [[ ${TARGET_BLKS} -gt ${MARGIN_BLKS} ]]; then
      TARGET_BLKS=$((TARGET_BLKS - MARGIN_BLKS))
    fi
    if [[ ${TARGET_BLKS} -lt ${MIN_BLKS} ]]; then
      TARGET_BLKS=${MIN_BLKS}
    fi

    resize2fs -p "${USER_DEV}" "${TARGET_BLKS}" || { echo "ERROR: (resize2fs userfs)"; return 1; }
    OLD_USER_OFFSET=$((USER_START * SECTOR_SIZE))
    NEW_USER_OFFSET=$((NEW_USER_START * SECTOR_SIZE))
    sync
    e2image -ra -p -o "${OLD_USER_OFFSET}" -O "${NEW_USER_OFFSET}" "${DISK_DEV}" || { echo "ERROR: (e2image move userfs)"; return 1; }
    sync
  else
    echo -ne "userfs already aligned, "
  fi

  _write_sfdisk "${NEW_ROOT_SIZE}" "${NEW_USER_START}" "${NEW_USER_SIZE}"
  SFDISK_RC=$?
  if [[ ${SFDISK_RC} -ne 0 ]]; then
    echo "ERROR: (sfdisk rewrite)"
    return 1
  fi

  partprobe "${DISK_DEV}" 2>/dev/null || true

  # Fresh mkfs because rootfs content will anyway be replaced in fwinstall()
  mkfs.ext4 -F -L rootfs -I 256 -E lazy_itable_init=0,lazy_journal_init=0 "${ROOT_DEV}" || { echo "ERROR: (mkfs.ext4 rootfs)"; return 1; }

  e2fsck -f -y "${USER_DEV}" >/dev/null 2>&1
  E2FSCK_USER_RC=$?
  if [[ ${E2FSCK_USER_RC} -ge 4 ]]; then
    echo "ERROR: (e2fsck userfs post-move, rc=${E2FSCK_USER_RC})"
    return 1
  fi
  if ! resize2fs -p "${USER_DEV}"; then
    echo "WARNING: (resize2fs expand userfs failed on ${USER_DEV}, userfs may be smaller than partition)"
  fi

  # re-mount stuff again
  mount /bootfs       || { echo "ERROR: (mount /bootfs)"; return 1; }
  mount /rootfs       || { echo "ERROR: (mount /rootfs)"; return 1; }
  mount -o rw /userfs || { echo "ERROR: (mount /userfs)"; return 1; }

  echo "OK"

  return 0
}

######
# function that is called with the filename containing
# the firmware update either archived or unarchived.
fwprepare()
{
  filename=${1}

  echo -ne "[1/7] Checking uploaded data... "
  # check if filename exists
  if [[ ! -f "${filename}" ]]; then
    echo "ERROR: ('${filename}' does not exist)"
    exit 1
  fi

  # check file size to be > 0
  FILESIZE=$(stat -c%s "${filename}" 2>/dev/null)
  if [[ -z "${FILESIZE}" ]] || [[ "${FILESIZE}" -le 0 ]]; then
    echo "ERROR: (filesize: ${FILESIZE})"
    exit 1
  fi
  echo "${FILESIZE} bytes received, OK<br/>"

  ########
  # calculate/output sha256 checksum of uploaded data
  echo -ne "[2/7] Calculating SHA256 checksum..."

  # start a progress bar outputing dots every few seconds
  awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
  PROGRESS_PID=$!
  # shellcheck disable=SC2064
  trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT

  if ! CHKSUM=$(/usr/bin/sha256sum "${filename}" 2>/dev/null) || [[ -z "${CHKSUM}" ]]; then
    echo "ERROR: (sha256sum)"
    exit 1
  fi
  # stop the progress output
  kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT

  echo "$(echo "${CHKSUM}" | awk '{ print $1 }')<br/>"

  ########
  # create tmpdir and output available disk space
  echo -ne "[3/7] Checking free disk space... "
  TMPDIR="${filename}-dir"
  rm -rf "${TMPDIR}"
  if ! mkdir -p "${TMPDIR}"; then
    echo "ERROR: (mkdir tmpdir)"
    exit 1
  fi

  # output
  AVAILSPACE=$(/bin/df -B1 "${TMPDIR}" | tail -1 | awk '{ print $4 }')
  echo -ne "${AVAILSPACE} bytes, "

  # check if > 0 bytes available
  if [[ -z "${AVAILSPACE}" ]] || [[ "${AVAILSPACE}" -le 0 ]]; then
    echo "ERROR: not enough disk space available!"
    exit 1
  fi
  echo "OK<br/>"

  ########
  # create tmpdir and output available disk space
  echo -ne "[4/7] Checking storage performance..."

  # start a progress bar outputing dots every few seconds
  awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
  PROGRESS_PID=$!
  # shellcheck disable=SC2064
  trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT

  # run the file i/o test using 'fio' which emulates a
  # Apps Class A1 performance test
  if ! RES=$(/usr/bin/fio --output-format=terse --max-jobs=4 /usr/share/agnostics/sd_bench.fio | cut -f 3,7,8,48,49 -d";" -) || [[ -z "${RES}" ]]; then
    echo "WARNING: performance test failed"
    # stop the progress output
    kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT
  else
    # stop the progress output
    kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT
    rm -f /usr/local/tmp/sd.test.file

    swri=$(echo "${RES}" | head -n 2 | tail -n 1 | cut -d ";" -f 4)
    swrimb=$(echo "${swri}" | awk '{printf "%.2f",($1/1000)}')
    rwri=$(echo "$RES" | head -n 3 | tail -n 1 | cut -d ";" -f 5)
    rrea=$(echo "$RES" | head -n 4 | tail -n 1 | cut -d ";" -f 3)
    pass=0

    # sequential write check
    echo -ne "sequential write: ${swrimb} MB/s"
    if [[ "${swri}" -lt 10000 ]]; then
      echo -ne " (WARN! < 10.0 MB/s), "
      pass=1
    else
      echo -ne " (OK: > 10.0 MB/s), "
    fi

    # random write check
    echo -ne "random write: ${rwri} IOPS"
    if [[ "${rwri}" -lt 500 ]]; then
      echo -ne " (WARN! < 500 IOPS), "
      pass=1
    else
      echo -ne " (OK: > 500 IOPS), "
    fi

    # random read check
    echo -ne "random read: ${rrea} IOPS"
    if [[ "${rrea}" -lt 1500 ]]; then
      echo -ne " (WARN! < 1500 IOPS), "
      pass=1
    else
      echo -ne " (OK: > 1500 IOPS), "
    fi

    # final pass check
    if [[ "${pass}" -eq 0 ]]; then
      echo "PASSED<br/>"
    else
      echo "WARNING: Update process will take considerable time!<br/>"
    fi

  fi

  ########
  # check if file is a valid firmware update/recovery file
  echo -ne "[5/7] Preparing uploaded data... "

  FILETYPE=""

  # check for tar.gz or .tar
  if [[ -z "${FILETYPE}" ]]; then
    if /usr/bin/file -b "${filename}" | grep -E -q "(gzip compressed|tar archive)"; then
      echo -ne "tar identified, "

      # check if unarchived size is < available space or we abort right away!
      REQSIZE=$(/bin/tar -tvzf "${filename}" | awk '{s+=$3} END{print s}')
      if [[ -z "${REQSIZE}" ]] || [[ "${REQSIZE}" -ge "${AVAILSPACE}" ]]; then
        echo "ERROR: ${REQSIZE} bytes required!"
        exit 1
      fi

      # start unarchiving
      echo -ne "unarchiving.."

      # start a progress bar outputing dots every few seconds
      awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
      PROGRESS_PID=$!
      # shellcheck disable=SC2064
      trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT

      # unarchive the tar
      if ! /bin/tar -C "${TMPDIR}" --warning=no-timestamp --no-same-owner -xmf "${filename}"; then
        echo "ERROR: (untar)"
        exit 1
      fi

      # stop the progress output
      kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT

      rm -f "${filename}"

      FILETYPE="tar"
    fi
  fi

  # check for .zip
  if [[ -z "${FILETYPE}" ]]; then
    if /usr/bin/file -b "${filename}" | grep -q "Zip archive data"; then
      echo -ne "zip identified, "

      # check if unarchived size is < available space or we abort right away!
      REQSIZE=$(/usr/bin/unzip -v "${filename}" | tail -1 | cut -d" " -f1)
      if [[ -z "${REQSIZE}" ]] || [[ "${REQSIZE}" -ge "${AVAILSPACE}" ]]; then
        echo "ERROR: ${REQSIZE} bytes required!"
        exit 1
      fi

      # start unarchiving
      echo -ne "unarchiving.."

      # start a progress bar outputing dots every few seconds
      awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
      PROGRESS_PID=$!
      # shellcheck disable=SC2064
      trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT

      # unarchive the zip
      if ! /usr/bin/unzip -q -o -d "${TMPDIR}" "${filename}" 2>/dev/null; then
        echo "ERROR: (unzip)"
        exit 1
      fi
      kill ${PROGRESS_PID} 2>/dev/null || true

      # use the first found *.img as the image file we analyze regarding
      # potential re-partitioning.
      PRE_IMG=""
      for f in "${TMPDIR}"/*.img; do
        [[ -f "${f}" ]] || break
        PRE_IMG="${f}"
        break
      done

      if [[ -n "${PRE_IMG}" ]]; then
        # Determine if rootfs resize would be needed by comparing current rootfs partition
        # size with the rootfs partition size inside the new image.
        ROOTFS_DEV=$(/sbin/blkid --label rootfs 2>/dev/null || true)
        if [[ -n "${ROOTFS_DEV}" ]]; then
          ROOTFS_SIZE=$(/sbin/blockdev --getsize64 "${ROOTFS_DEV}" 2>/dev/null || true)
        else
          ROOTFS_SIZE=""
        fi

        if [[ -n "${ROOTFS_SIZE}" ]]; then
          # Determine rootfs partition size inside image using parted machine-readable output
          # parted -sm format: number:start:end:size:filesystem:name:flags
          ROOTFS_IMG_SIZE=$(/usr/sbin/parted -sm "${PRE_IMG}" unit B print 2>/dev/null | \
            awk -F: '$1=="2" { gsub(/B$/,"",$4); print $4; exit }')

          # If resize is needed (image rootfs larger/smaller)
          if [[ -n "${ROOTFS_IMG_SIZE}" ]]; then

            # if image rootfs is larger remove extracted img now to free userfs space
            # and perform resize BEFORE fully unpacking the zip.
            #
            # IMPORTANT:
            # If a rootfs resize is required (rootfs in image larger than current rootfs),
            # we must avoid filling userfs by fully unpacking the zip first, because that
            # could prevent shrinking userfs. Therefore, once we identified such a
            # required userfs shrinking we remove TMPDIR later on and do a re-unzipping
            # accordingly and continue.
            if [[ "${ROOTFS_IMG_SIZE}" -gt "${ROOTFS_SIZE}" ]]; then
              rm -rf "${TMPDIR}" 2>/dev/null || true
              sync 2>/dev/null || true

              echo -ne "resize rootfs, "
              if ! resize_rootfs "${ROOTFS_SIZE}" "${ROOTFS_IMG_SIZE}"; then
                echo "ERROR: (resize_rootfs)<br/>"
                exit 1
              fi

              #############################
              # now unarchive once again
              if ! mkdir -p "${TMPDIR}"; then
                echo "ERROR: (mkdir tmpdir after resize)"
                exit 1
              fi

              # check available space again
              AVAILSPACE=$(/bin/df -B1 "${TMPDIR}" | tail -1 | awk '{ print $4 }')
              echo -ne "${AVAILSPACE} bytes available, "
              if [[ -z "${REQSIZE}" ]] || [[ "${REQSIZE}" -ge "${AVAILSPACE}" ]]; then
                echo "ERROR: ${REQSIZE} bytes required!"
                exit 1
              fi

              echo -ne "re-unarchiving.."
              # restart progress indicator
              awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
              PROGRESS_PID=$!
              # shellcheck disable=SC2064
              trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT
              # unarchive the zip once more
              if ! /usr/bin/unzip -q -o -d "${TMPDIR}" "${filename}" 2>/dev/null; then
                echo "ERROR: (unzip)"
                exit 1
              fi
              kill ${PROGRESS_PID} 2>/dev/null || true
            elif [[ "${ROOTFS_IMG_SIZE}" -lt "${ROOTFS_SIZE}" ]]; then
              # if image rootfs is smaller we just shrink the rootfs fs and
              # partition but keep userfs untouched.
              sync 2>/dev/null || true
              echo -ne "resize rootfs, "
              if ! resize_rootfs "${ROOTFS_SIZE}" "${ROOTFS_IMG_SIZE}"; then
                echo "ERROR: (resize_rootfs)<br/>"
                exit 1
              fi
            fi
          fi
        fi
      fi

      # stop the progress output (may already be stopped on resize paths)
      kill ${PROGRESS_PID} 2>/dev/null || true
      trap "rm -f /tmp/.runningFirmwareUpdate" EXIT

      rm -f "${filename}"

      FILETYPE="zip"
    fi
  fi

  # check for .img
  if [[ -z "${FILETYPE}" ]]; then
    if /usr/bin/file -b "${filename}" | grep -E -q "(DOS/MBR boot sector|GUID Partition Table)"; then
      echo -ne "img identified, validating, "

      # the file seems to be a full-fledged disk image (MBR or GPT) so lets
      # check if we have exactly 3 partitions
      if ! /usr/sbin/parted -sm "${filename}" print 2>/dev/null | tail -1 | grep -E -q "3:.*:ext4:"; then
        echo "ERROR: (parted)"
        exit 1
      fi

      # Determine if rootfs resize would be needed by comparing current rootfs partition
      # size with the rootfs partition size inside the new image.
      ROOTFS_DEV=$(/sbin/blkid --label rootfs 2>/dev/null || true)
      if [[ -n "${ROOTFS_DEV}" ]]; then
        ROOTFS_SIZE=$(/sbin/blockdev --getsize64 "${ROOTFS_DEV}" 2>/dev/null || true)
      else
        ROOTFS_SIZE=""
      fi

      if [[ -n "${ROOTFS_SIZE}" ]]; then
        # Determine rootfs partition size inside image using parted machine-readable output
        # parted -sm format: number:start:end:size:filesystem:name:flags
        ROOTFS_IMG_SIZE=$(/usr/sbin/parted -sm "${filename}" unit B print 2>/dev/null | \
          awk -F: '$1=="2" { gsub(/B$/,"",$4); print $4; exit }')

        # If resize is needed (image rootfs larger or smaller)
        if [[ -n "${ROOTFS_IMG_SIZE}" ]] && [[ "${ROOTFS_IMG_SIZE}" != "${ROOTFS_SIZE}" ]]; then

          # For enlarge: check whether the img file itself blocks the required userfs shrink.
          if [[ "${ROOTFS_IMG_SIZE}" -gt "${ROOTFS_SIZE}" ]]; then
            SHIFT_B=$(( ROOTFS_IMG_SIZE - ROOTFS_SIZE ))
            IMG_BYTES=$(stat -c%s "${filename}" 2>/dev/null || echo 0)
            USERFS_DEV_TMP=$(/sbin/blkid --label userfs 2>/dev/null || true)
            if [[ -n "${USERFS_DEV_TMP}" ]]; then
              USERFS_BYTES=$(/sbin/blockdev --getsize64 "${USERFS_DEV_TMP}" 2>/dev/null || echo 0)
              if [[ $((USERFS_BYTES - SHIFT_B)) -lt ${IMG_BYTES} ]]; then
                echo "ERROR: cannot enlarge rootfs — the uploaded img file (${IMG_BYTES} bytes) occupies"
                echo "ERROR: the userfs space needed to complete the resize. Free userfs space first.<br/>"
                exit 1
              fi
            fi
          fi

          sync 2>/dev/null || true
          echo -ne "resize rootfs, "
          if ! resize_rootfs "${ROOTFS_SIZE}" "${ROOTFS_IMG_SIZE}"; then
            echo "ERROR: (resize_rootfs)<br/>"
            exit 1
          fi
        fi
      fi
      mv -f "${filename}" "${TMPDIR}/new_firmware.img"

      FILETYPE="img"
    fi
  fi

  # check for ext4 rootfs filesystem
  if [[ -z "${FILETYPE}" ]]; then
    if /usr/bin/file -b "${filename}" | grep -E -q "ext4 filesystem.*rootfs"; then
      echo -ne "rootfs ext4 identified, validating, "

      # the file seems to be an ext4 fs of the rootfs lets check if the ext4 is valid
      if ! /sbin/e2fsck -nf "${filename}" 2>/dev/null >/dev/null; then
        echo "ERROR: (e2fsck)"
        exit 1
      fi

      mv -f "${filename}" "${TMPDIR}/rootfs.ext4"

      FILETYPE="ext4"
    fi
  fi

  # check for vfat bootfs filesystem
  if [[ -z "${FILETYPE}" ]]; then
    if /usr/bin/file -b "${filename}" | grep -E -q "DOS/MBR boot sector.*bootfs.*FAT"; then
      echo -ne "bootfs vfat identified, validating, "

      # the file seems to be a vfat fs of the bootfs lets check if the ext4 is valid
      #/sbin/fsck.fat -nf ${filename} 2>/dev/null >/dev/null
      #if [ $? -ne 0 ]; then
      #  echo "ERROR: (fsck.fat)"
      #  exit 1
      #fi

      mv -f "${filename}" "${TMPDIR}/bootfs.vfat"

      FILETYPE="vfat"
    fi
  fi

  if [[ -z "${FILETYPE}" ]]; then
    echo "ERROR: no valid filetype found"
    exit 1
  else
    echo "OK<br/>"
  fi

  ######
  # now we have unarchived everyting to TMPDIR, so lets check if it is valid
  echo -ne "[6/7] Verifying uploaded data..."

  # start a progress bar outputing dots every few seconds
  awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
  PROGRESS_PID=$!
  # shellcheck disable=SC2064
  trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT

  # check for sha256 checksums
  (cd "${TMPDIR}";
    for chk_file in *.sha256; do
      [[ -f "${chk_file}" ]] || break
      if ! /usr/bin/sha256sum -sc "${chk_file}"; then
        echo "ERROR: (sha256sum)"
        exit 1
      else
        echo -ne "OK (sha256sum), "
      fi
    done
  ) || exit 1

  # check for md5 checksums
  (cd "${TMPDIR}";
    for chk_file in *.md5; do
      [[ -f "${chk_file}" ]] || break
      if ! /usr/bin/md5sum -sc "${chk_file}"; then
        echo "ERROR: (md5sum)"
        exit 1
      else
        echo -ne "OK (md5sum), "
      fi
    done
  ) || exit 1

  # stop the progress output
  kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT

  echo "DONE<br>"

  ######
  # now we check if update_script is required and found and if so we
  # flag this firmware update accordingly
  echo -ne "[7/7] Preparing firmware update... "

  if ! ls "${TMPDIR}"/*.img >/dev/null 2>&1 &&
     ! ls "${TMPDIR}"/*.ext4 >/dev/null 2>&1 &&
     ! ls "${TMPDIR}"/*.vfat >/dev/null 2>&1; then
    if [[ ! -x "${TMPDIR}/update_script" ]]; then
      echo "ERROR: (update_script)"
      exit 1
    fi

    echo "update_script found, "
  fi

  rm -rf /usr/local/.firmwareUpdate
  if ! ln -sfn "${TMPDIR}" /usr/local/.firmwareUpdate; then
    echo "ERROR: (ln)"
    exit 1
  fi

  echo "OK, DONE<br/>"
}

######
# function that is performing the unattended firmware update by
# checking if there is an /usr/local/.firmwareUpdate link to the
# directory containing the update files
fwinstall()
{
  echo -ne "[1/5] Validate update directory... "
  UPDATEDIR=$(readlink -f /usr/local/.firmwareUpdate)
  if [[ -z "${UPDATEDIR}" ]] || [[ ! -d "${UPDATEDIR}" ]]; then
    echo "ERROR: (updatedir)<br/>"
    exit 1
  fi
  echo "OK<br/>"

  # check for executable update_script in UPDATEDIR
  echo -ne "[2/5] Checking update_script... "
  if [[ -f "${UPDATEDIR}/update_script" ]]; then
    if [[ ! -x "${UPDATEDIR}/update_script" ]]; then
      echo "ERROR: update_script NOT executable<br/>"
      exit 1
    fi
    echo "exists, executing:<br/>"
    echo "================================================<br/>"

    # execute update_script
    if ! (cd "${UPDATEDIR}" && "${UPDATEDIR}/update_script" HM-RASPBERRYMATIC); then
      echo "<br/>================================================<br/>"
      echo "ERROR: update_script failed!<br/>"
      exit 1
    fi
    echo "<br/>================================================<br/>"

    # update script succeeded, lets finish immediately
    echo "DONE (succeeded)<br/>"
    return 0
  else
    echo "no 'update_script', OK<br/>"
  fi

  # check if there is an ext4 file waiting for us in UPDATEDIR
  echo -ne "[3/5] Checking for rootfs filesystem images... "
  FLASHED_ROOTFS=0
  for ext4_file in "${UPDATEDIR}"/*.ext4; do
    [[ -f ${ext4_file} ]] || break

    # lets see if this is rootfs
    if file -b "${ext4_file}" | grep -E -q "ext4 filesystem.*rootfs"; then
      echo -ne "found ($(basename "${ext4_file}")), "

      # find out the rootfs device node
      ROOTFS_DEV=$(/sbin/blkid --label rootfs)
      if [[ -z "${ROOTFS_DEV}" ]]; then
        echo "ERROR: (blkid)<br/>"
        exit 1
      fi

      # get rootfs partition size in bytes
      ROOTFS_SIZE=$(/sbin/blockdev --getsize64 "${ROOTFS_DEV}")
      if [[ -z "${ROOTFS_SIZE}" ]]; then
        echo "ERROR: (blockdev rootfs)<br/>"
        exit 1
      fi

      # check if the found rootfs ext4 file matches the current rootfs partition size
      if [[ "${ROOTFS_SIZE}" != $(stat -c%s "${ext4_file}") ]]; then
        echo "ERROR: rootfs partition has different size than provided image<br/>"
        exit 1
      fi

      # find out if the hardware platform of the current rootfs and the one
      # we are going to flash are the same
      ROOTFS_PLATFORM=$(grep PLATFORM= /VERSION | cut -d= -f2)
      if [[ -z "${ROOTFS_PLATFORM}" ]]; then
        echo "ERROR: (ROOTFS_PLATFORM)<br/>"
        exit 1
      fi

      # mount fs readonly
      if ! mount -o ro,loop "${ext4_file}" /mnt; then
        echo "ERROR: (lo mount)<br/>"
        exit 1
      fi

      # get platform info in image file
      IMG_PLATFORM=$(grep PLATFORM= /mnt/VERSION | cut -d= -f2)

      # unmount immediately
      if ! umount -f /mnt; then
        echo "ERROR: (umount /mnt)<br/>"
        exit 1
      fi

      # check if plaform is non-empty
      if [[ -z "${IMG_PLATFORM}" ]]; then
        echo "ERROR: (IMG_PLATFORM)<br/>"
        exit 1
      fi

      # check if both PLATFORM match
      if [[ "${ROOTFS_PLATFORM}" != "${IMG_PLATFORM}" ]]; then
        echo "ERROR: incorrect hardware platform (${IMG_PLATFORM} != ${ROOTFS_PLATFORM})<br/>"
        exit 1
      fi

      # unmount /rootfs and flash the image using dd
      echo -ne "flashing.."
      umount -f "${ROOTFS_DEV}"

      # start a progress bar outputing dots every few seconds
      awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
      PROGRESS_PID=$!
      # shellcheck disable=SC2064
      trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT

      # use dd to write the image file to the boot partition
      if ! /bin/dd if="${ext4_file}" of="${ROOTFS_DEV}" bs=4M conv=fsync status=none; then
        echo "ERROR: (dd)<br/>"
        exit 1
      fi

      # stop the progress output
      kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT

      if ! mount -o ro "${ROOTFS_DEV}" /rootfs; then
        echo "ERROR: (mount)<br/>"
        exit 1
      fi

      echo "OK<br/>"

      FLASHED_ROOTFS=1
      break
    fi

  done
  if [[ ${FLASHED_ROOTFS} -eq 0 ]]; then
    echo "none found, OK<br/>"
  fi

  # check if there is an vfat file waiting for us in UPDATEDIR
  echo -ne "[4/5] Checking for bootfs filesystem images... "
  FLASHED_BOOTFS=0
  for vfat_file in "${UPDATEDIR}"/*.vfat; do
    [[ -f ${vfat_file} ]] || break

    # lets see if this is bootfs
    if file -b "${vfat_file}" | grep -E -q "DOS/MBR boot sector.*mkfs.fat.*bootfs.*FAT"; then
      echo -ne "found ($(basename "${vfat_file}")), "

      # find out the bootfs device node
      BOOTFS_DEV=$(/sbin/blkid --label bootfs)
      if [[ -z "${BOOTFS_DEV}" ]]; then
        echo "ERROR: (blkid)<br/>"
        exit 1
      fi

      # get bootfs partition size in bytes
      BOOTFS_SIZE=$(/sbin/blockdev --getsize64 "${BOOTFS_DEV}")
      if [[ -z "${BOOTFS_SIZE}" ]]; then
        echo "ERROR: (blockdev bootfs)<br/>"
        exit 1
      fi

      # check if the found bootfs vfat file matches the current bootfs partition size
      if [[ "${BOOTFS_SIZE}" != $(stat -c%s "${vfat_file}") ]]; then
        echo "ERROR: bootfs partition has different size than provided image<br/>"
        exit 1
      fi

      # find out if the hardware platform of the current rootfs and the one
      # we are going to flash are the same
      BOOTFS_PLATFORM=$(grep PLATFORM= /VERSION | cut -d= -f2)
      if [[ -z "${BOOTFS_PLATFORM}" ]]; then
        echo "ERROR: (BOOTFS_PLATFORM)<br/>"
        exit 1
      fi

      # mount fs readonly
      if ! mount -o ro,loop "${vfat_file}" /mnt; then
        echo "ERROR: (lo mount)<br/>"
        exit 1
      fi

      # get platform info in image file
      IMG_PLATFORM=$(grep PLATFORM= /mnt/VERSION | cut -d= -f2)

      # unmount immediately
      if ! umount -f /mnt; then
        echo "ERROR: (umount /mnt)<br/>"
        exit 1
      fi

      # check if plaform is non-empty
      if [[ -z "${IMG_PLATFORM}" ]]; then
        echo "ERROR: (IMG_PLATFORM)<br/>"
        exit 1
      fi

      # check if both PLATFORM match
      if [[ "${BOOTFS_PLATFORM}" != "${IMG_PLATFORM}" ]]; then
        echo "ERROR: incorrect hardware platform (${IMG_PLATFORM} != ${BOOTFS_PLATFORM})<br/>"
        exit 1
      fi

      # unmount /bootfs and flash the image using dd
      echo -ne "flashing.."
      umount -f "${BOOTFS_DEV}"

      # start a progress bar outputing dots every few seconds
      awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
      PROGRESS_PID=$!
      # shellcheck disable=SC2064
      trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT

      # use dd to write the image file to the boot partition
      if ! /bin/dd if="${vfat_file}" of="${BOOTFS_DEV}" bs=4M conv=fsync status=none; then
        echo "ERROR: (dd)<br/>"
        exit 1
      fi

      # stop the progress output
      kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT

      if ! mount -o ro "${BOOTFS_DEV}" /bootfs; then
        echo "ERROR: (mount)<br/>"
        exit 1
      fi

      echo "OK<br/>"

      FLASHED_BOOTFS=1
      break
    fi
  done
  if [[ ${FLASHED_BOOTFS} -eq 0 ]]; then
    echo "none found, OK<br/>"
  fi

  ######
  # check for a full-fledged image in update dir
  echo -ne "[5/5] Checking for image file... "

  # if we flashed either rootfs or bootfs we are finished
  if [[ ${FLASHED_ROOTFS} -eq 1 ]] || [[ ${FLASHED_BOOTFS} -eq 1 ]]; then
    echo "skipped, OK<br/>"
    return 0
  fi

  FLASHED_IMG=0
  for img_file in "${UPDATEDIR}"/*.img; do
    [[ -f ${img_file} ]] || break

    echo -ne "found, "

    # find out which will be the next lofs device node
    LOFS_DEV=$(/sbin/losetup -f)

    # perform a lofs mount of the image file
    if ! /sbin/losetup -r -f "${img_file}"; then
      echo "ERROR: (losetup)<br/>"
      exit 1
    fi

    # lets scan for partitions using partprobe
    if ! /usr/sbin/partprobe "${LOFS_DEV}"; then
      echo "ERROR: (partprobe)<br/>"
      exit 1
    fi

    # find out the bootfs loop device node
    BOOTFS_LOOPDEV=$(/sbin/blkid | grep -E "${LOFS_DEV}.*bootfs" | cut -f1 -d:)
    if [[ -n "${BOOTFS_LOOPDEV}" ]]; then
      # found out the bootfs main device
      BOOTFS_DEV=$(/sbin/blkid | grep -v "${LOFS_DEV}" | grep bootfs | cut -f1 -d:)
      if [[ -z "${BOOTFS_DEV}" ]]; then
        echo "ERROR: (blkid bootfs)<br/>"
        exit 1
      fi

      # get boot partition size in bytes
      BOOTFS_SIZE=$(/sbin/blockdev --getsize64 "${BOOTFS_DEV}")
      if [[ -z "${BOOTFS_SIZE}" ]]; then
        echo "ERROR: (blockdev bootfs)<br/>"
        exit 1
      fi

      # get boot lofs partition size in bytes
      BOOTFS_LOOPSIZE=$(/sbin/blockdev --getsize64 "${BOOTFS_LOOPDEV}")
      if [[ -z "${BOOTFS_LOOPSIZE}" ]]; then
        echo "ERROR: (blockdev bootfs loopfs)<br/>"
        exit 1
      fi

      # check if the found bootfs loopfs size matches the current bootfs partition size
      if [[ "${BOOTFS_SIZE}" != "${BOOTFS_LOOPSIZE}" ]]; then
        echo "ERROR: bootfs partition has different size than provided image<br/>"
        exit 1
      fi

      # find out if the hardware platform of the current rootfs and the one
      # we are going to flash are the same
      BOOTFS_PLATFORM=$(grep PLATFORM= /VERSION | cut -d= -f2)
      if [[ -z "${BOOTFS_PLATFORM}" ]]; then
        echo "ERROR: (BOOTFS_PLATFORM)<br/>"
        exit 1
      fi

      # mount fs readonly
      if ! mount -o ro,loop "${BOOTFS_LOOPDEV}" /mnt; then
        echo "ERROR: (lo mount)<br/>"
        exit 1
      fi

      # get platform info in image file
      IMG_PLATFORM=$(grep PLATFORM= /mnt/VERSION | cut -d= -f2)

      # unmount immediately
      if ! umount -f /mnt; then
        echo "ERROR: (umount /mnt)<br/>"
        exit 1
      fi

      # check if plaform is non-empty
      if [[ -z "${IMG_PLATFORM}" ]]; then
        echo "ERROR: (IMG_PLATFORM)<br/>"
        exit 1
      fi

      # check if both PLATFORM match
      if [[ "${BOOTFS_PLATFORM}" != "${IMG_PLATFORM}" ]]; then
        echo "ERROR: incorrect hardware platform (${IMG_PLATFORM} != ${BOOTFS_PLATFORM})<br/>"
        exit 1
      fi

      # unmount /bootfs and flash the image using dd
      echo -ne "flashing bootfs.."
      umount -f "${BOOTFS_DEV}"

      # start a progress bar outputing dots every few seconds
      awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
      PROGRESS_PID=$!
      # shellcheck disable=SC2064
      trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT

      # use dd to write the image file to the boot partition
      if ! /bin/dd if="${BOOTFS_LOOPDEV}" of="${BOOTFS_DEV}" bs=4M conv=fsync status=none; then
        echo "ERROR: (dd)<br/>"
        exit 1
      fi

      # stop the progress output
      kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT

      if ! mount -o ro "${BOOTFS_DEV}" /bootfs; then
        echo "ERROR: (mount)<br/>"
        exit 1
      fi

      echo -ne "OK, "

      # on platforms with dedicated pc-bios (non UEFI) boot loaders
      # we have to update them as well.
      if [[ "${BOOTFS_PLATFORM}" == "ova" ]] ||
         [[ "${BOOTFS_PLATFORM}" == "odroid-c4" ]] ||
         [[ "${BOOTFS_PLATFORM}" == "odroid-n2" ]] ||
         [[ "${BOOTFS_PLATFORM}" == "odroid-c2" ]]; then
        BOOTFS_ROOTDEV="/dev/$(basename "$(dirname "$(readlink "/sys/class/block/${BOOTFS_DEV#/dev/}")")")"
        BOOTFS_START=$(/sbin/fdisk -l "${BOOTFS_ROOTDEV}" | grep FAT32 | head -1 | awk '{ printf $3 }')
        BOOTFS_LOOPROOTDEV=${LOFS_DEV}
        BOOTFS_LOOPSTART=$(/sbin/fdisk -l "${BOOTFS_LOOPROOTDEV}" | grep FAT32 | head -1 | awk '{ printf $3 }')
        echo -ne "updating bootloader "
        if [[ "${BOOTFS_START}" == "${BOOTFS_LOOPSTART}" ]] && [[ "${BOOTFS_LOOPSTART}" -ge 2048 ]]; then
          if [[ "${BOOTFS_PLATFORM}" == "odroid-c4" ]] ||
             [[ "${BOOTFS_PLATFORM}" == "odroid-n2" ]] ||
             [[ "${BOOTFS_PLATFORM}" == "odroid-c2" ]]; then
            # ODroid-C4/N2/C2 has U-Boot in seperate boot sector
            echo -ne "(U-Boot)... "
            /bin/dd if="${BOOTFS_LOOPROOTDEV}" of="${BOOTFS_ROOTDEV}" bs=512 count=10239 seek=1 skip=1 conv=fsync status=none
            result=$?
          else
            # x86 with GRUB
            echo -ne "(GRUB)... "
            /bin/dd if="${BOOTFS_LOOPROOTDEV}" of="${BOOTFS_ROOTDEV}" bs=512 count=2047 seek=1 skip=1 conv=fsync status=none
            result=$?
          fi

          if [[ ${result} -ne 0 ]]; then
            echo "ERROR: (dd)<br/>"
            exit 1
          fi
          echo -ne "OK, "
        else
          echo -ne "WARNING: (${BOOTFS_START}:${BOOTFS_LOOPSTART}), "
        fi
      fi
    fi

    # find out the rootfs loop device node
    ROOTFS_LOOPDEV=$(/sbin/blkid | grep -E "${LOFS_DEV}.*rootfs" | cut -f1 -d:)
    if [[ -n "${ROOTFS_LOOPDEV}" ]]; then
      # found out the rootfs main device
      ROOTFS_DEV=$(/sbin/blkid | grep -v "${LOFS_DEV}" | grep rootfs | cut -f1 -d:)
      if [[ -z "${ROOTFS_DEV}" ]]; then
        echo "ERROR: (blkid rootfs)<br/>"
        exit 1
      fi

      # get root partition size in bytes
      ROOTFS_SIZE=$(/sbin/blockdev --getsize64 "${ROOTFS_DEV}")
      if [[ -z "${ROOTFS_SIZE}" ]]; then
        echo "ERROR: (blockdev rootfs)<br/>"
        exit 1
      fi

      # get root lofs partition size in bytes
      ROOTFS_LOOPSIZE=$(/sbin/blockdev --getsize64 "${ROOTFS_LOOPDEV}")
      if [[ -z "${ROOTFS_LOOPSIZE}" ]]; then
        echo "ERROR: (blockdev rootfs loopfs)<br/>"
        exit 1
      fi

      # check if the found rootfs loopfs size matches the current rootfs partition size
      if [[ "${ROOTFS_SIZE}" != "${ROOTFS_LOOPSIZE}" ]]; then
        echo "ERROR: rootfs partition has different size than provided image<br/>"
        exit 1
      fi

      # find out if the hardware platform of the current rootfs and the one
      # we are going to flash are the same
      ROOTFS_PLATFORM=$(grep PLATFORM= /VERSION | cut -d= -f2)
      if [[ -z "${ROOTFS_PLATFORM}" ]]; then
        echo "ERROR: (ROOTFS_PLATFORM)<br/>"
        exit 1
      fi

      # mount fs readonly
      if ! mount -o ro,loop "${ROOTFS_LOOPDEV}" /mnt; then
        echo "ERROR: (lo mount)<br/>"
        exit 1
      fi

      # get platform info in image file
      IMG_PLATFORM=$(grep PLATFORM= /mnt/VERSION | cut -d= -f2)

      # unmount immediately
      if ! umount -f /mnt; then
        echo "ERROR: (umount /mnt)<br/>"
        exit 1
      fi

      # check if plaform is non-empty
      if [[ -z "${IMG_PLATFORM}" ]]; then
        echo "ERROR: (IMG_PLATFORM)<br/>"
        exit 1
      fi

      # check if both PLATFORM match
      if [[ "${ROOTFS_PLATFORM}" != "${IMG_PLATFORM}" ]]; then
        echo "ERROR: incorrect hardware platform (${IMG_PLATFORM} != ${ROOTFS_PLATFORM})<br/>"
        exit 1
      fi

      # unmount /rootfs and flash the image using dd
      echo -ne "flashing rootfs.."
      umount -f "${ROOTFS_DEV}"

      # start a progress bar outputing dots every few seconds
      awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
      PROGRESS_PID=$!
      # shellcheck disable=SC2064
      trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT

      # use dd to write the image file to the boot partition
      if ! /bin/dd if="${ROOTFS_LOOPDEV}" of="${ROOTFS_DEV}" bs=4M conv=fsync status=none; then
        echo "ERROR: (dd)<br/>"
        exit 1
      fi

      # stop the progress output
      kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT

      if ! mount -o ro "${ROOTFS_DEV}" /rootfs; then
        echo "ERROR: (mount)<br/>"
        exit 1
      fi

      echo -ne "OK, "

    fi

    # detach all lofs devices
    if ! /sbin/losetup -d "${LOFS_DEV}"; then
      echo "ERROR: (lofs detach)<br/>"
      exit 1
    fi

    echo "DONE<br/>"

    FLASHED_IMG=1
    break
  done
  if [[ ${FLASHED_IMG} -eq 0 ]]; then
    echo "none found, OK<br/>"
  else
    return 0
  fi

  echo "<br/>"
  echo "WARNING: no firmware update/recovery performed<br/>"
  exit 1
}

#################################
# main body starts here

# there can be only one!
if [[ -f /tmp/.runningFirmwareUpdate ]]; then
  echo "ERROR: Firmware Update already running<br/>"
  exit 1
fi

# capture on EXIT and create the lock file
trap 'rm -f /tmp/.runningFirmwareUpdate' EXIT
touch /tmp/.runningFirmwareUpdate

# source all data from /var/hm_mode
[[ -r /var/hm_mode ]] && . /var/hm_mode

# fast blink magenta on RPI-RF-MOD or HB-RF-USB/HB-RF-USB-2
if [[ "${HM_RTC}" == "rx8130" ]] || lsusb | grep -q 0403:6f70 || lsusb | grep -q 10c4:8c07; then
  if [[ -e /sys/class/leds/rpi_rf_mod:green/trigger ]]; then
    echo none  >/sys/class/leds/rpi_rf_mod:green/trigger
    echo timer >/sys/class/leds/rpi_rf_mod:red/trigger
    echo timer >/sys/class/leds/rpi_rf_mod:blue/trigger
    echo 100 >/sys/class/leds/rpi_rf_mod:red/delay_on
    echo 100 >/sys/class/leds/rpi_rf_mod:red/delay_off
    echo 100 >/sys/class/leds/rpi_rf_mod:blue/delay_on
    echo 100 >/sys/class/leds/rpi_rf_mod:blue/delay_off
  fi
fi

# if an argument was given (filename of the update file/data)
# we run fwprepare to verify its validity
if [[ "$#" -eq 1 ]] && [[ -n "${1}" ]]; then
  echo "Preparing firmware update:<br/>"
  fwprepare "${1}"
  echo "Finished preparation successfully.<br/><br/>"
fi

# run the fwinstall function to actually
# run the unattended firmware update
echo "Starting firmware update (DO NOT INTERRUPT!!!):<br/>"
fwinstall
echo "Finished firmware update successfully.<br/>"

exit 0
