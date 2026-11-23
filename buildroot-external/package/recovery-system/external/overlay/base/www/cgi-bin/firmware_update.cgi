#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC2034

echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"

# check the request (CSRF) and claim the recovery action lock before the
# upload is written to /usr/local/tmp. The lock is held until the system
# reboots (or released on exit) and handed over to fwinstall.sh.
. /lib/librecovery.sh
recovery_cgi_begin

# cleanup first
rm -f /usr/local/.firmwareUpdate

# process data upload
echo -ne "Receiving uploaded data.."

# fake read boundary+disposition, etc.
read -r boundary
read -r disposition
read -r ctype
read -r junk

# get length
a=${#boundary}
b=${#disposition}
c=${#ctype}
d=0

# Due to \n\r line breaks we have 2 extra bytes per line read,
# 6 + 2 newlines == 10 junk bytes
a=$((a*2+b+c+d+10))

# start a progress bar outputing dots every few seconds
awk 'BEGIN{while(1){printf".";fflush();system("sleep 3");}}' &
PROGRESS_PID=$!
# shellcheck disable=SC2064
trap "kill ${PROGRESS_PID}; recovery_unlock" EXIT

# calculate the expected content length using
# HTTP_CONTENT_LENGTH or CONTENT_LENGTH
if [ -z "${HTTP_CONTENT_LENGTH}" ]; then
  HTTP_CONTENT_LENGTH=${CONTENT_LENGTH}
fi
SIZE=$((HTTP_CONTENT_LENGTH-a))

# write out the data
filename=$(mktemp -p /usr/local/tmp)
if ! head -q -c $SIZE >"${filename}"; then
  echo "ERROR (head)"
  exit 1
fi

# stop the progress output
kill ${PROGRESS_PID} && trap recovery_unlock EXIT

echo "OK, DONE<br/><br/>"

######
# lets start the firmware update now using /bin/fwinstall.sh
# and if it returns 0 everything was fine and we can reboot!
if ! RECOVERY_LOCK_HELD=1 /bin/fwinstall.sh "${filename}"; then
  RET=1
else
  RET=0
fi

# cleanup
rm -f /usr/local/.firmwareUpdate
rm -f /tmp/.runningFirmwareUpdate

if [ ${RET} -eq 0 ]; then
  echo "Rebooting...<br/>"
  recovery_reboot || RET=1
fi

exit ${RET}
