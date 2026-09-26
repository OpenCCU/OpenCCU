#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC2034

echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"

if [ -f /tmp/.runningFirmwareUpdate ]; then
  echo "ERROR: firmware update is currently running"
  exit 1
fi

echo "<pre>"

########
# check storage performance
echo -ne "[1/4] Checking raw storage performance: "
USERFS_DEV=$(/sbin/blkid --label userfs)
if [[ -n "${USERFS_DEV}" ]]; then
  mount -o rw,remount ${USERFS_DEV}
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
      echo "PASSED"
    else
      echo "WARNING: Low storage performance"
    fi

  fi
  mount -o ro,remount ${USERFS_DEV}
else
  echo "WARNING: no /userfs found"
fi

########
# perform /bootfs filesystem check
echo -ne "\n[2/4] Checking+Repairing /bootfs filesystem:"
BOOTFS_DEV=$(/sbin/blkid --label bootfs)
if [[ -n "${BOOTFS_DEV}" ]]; then
  awk 'BEGIN{i=0;while(1){if(i%75==0){printf"\n";}printf".";fflush();system("sleep 3");i++;}}' &
  PROGRESS_PID=$!
  # shellcheck disable=SC2064
  trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT
  /bin/umount ${BOOTFS_DEV} 2>/dev/null
  /sbin/fsck.fat -v -a -t -l -V ${BOOTFS_DEV}
  /bin/mount /bootfs
  kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT
else
  echo "WARNING: no /bootfs found"
fi

########
# perform /rootfs filesystem check
echo -ne "\n[3/4] Checking+Repairing /rootfs filesystem:"
ROOTFS_DEV=$(/sbin/blkid --label rootfs)
if [[ -n "${ROOTFS_DEV}" ]]; then
  awk 'BEGIN{i=0;while(1){if(i%75==0){printf"\n";}printf".";fflush();system("sleep 3");i++;}}' &
  PROGRESS_PID=$!
  # shellcheck disable=SC2064
  trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT
  /bin/umount ${ROOTFS_DEV} 2>/dev/null
  /sbin/e2fsck -c -c -y -f -v ${ROOTFS_DEV} 2>/dev/null
  /bin/mount /rootfs
  kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT
else
  echo "WARNING: no /rootfs found"
fi

########
# perform /userfs filesystem check
echo -ne "\n[4/4] Checking+Repairing /userfs filesystem:"
USERFS_DEV=$(/sbin/blkid --label userfs)
if [[ -n "${USERFS_DEV}" ]]; then
  awk 'BEGIN{i=0;while(1){if(i%75==0){printf"\n";}printf".";fflush();system("sleep 3");i++;}}' &
  PROGRESS_PID=$!
  # shellcheck disable=SC2064
  trap "kill ${PROGRESS_PID}; rm -f /tmp/.runningFirmwareUpdate" EXIT
  /bin/umount ${USERFS_DEV} 2>/dev/null
  /sbin/e2fsck -c -c -y -f -v ${USERFS_DEV} 2>/dev/null
  /bin/mount /userfs
  kill ${PROGRESS_PID} && trap "rm -f /tmp/.runningFirmwareUpdate" EXIT
else
  echo "WARNING: no /userfs found"
fi

echo "</pre>"
