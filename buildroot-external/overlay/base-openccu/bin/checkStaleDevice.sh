#!/bin/sh
# shellcheck shell=dash
#
# Helper script to check if a daemon still holds a device node which was
# removed in the meantime (cf. https://github.com/OpenCCU/OpenCCU/issues/3968).
#
# rfd and HMIPServer talk to the RF module through the /dev/mmd_bidcos and
# /dev/mmd_hmip slave devices of the eq3_char_loop driver if multimacd is
# used. If multimacd is restarted (e.g. by monit after a crash) the driver
# (eq3_char_loop >= 1.6) hangs up all open slave connections and removes
# their device nodes, and the new multimacd creates new ones. Neither rfd nor
# HMIPServer re-open their device in that case, so they have to be restarted.
#
# Usage: checkStaleDevice.sh <pidfile> [<device pattern>]
#
# The device pattern defaults to /dev/mmd_*. The script prints the stale
# device and returns 1 if the process of <pidfile> holds a removed device
# node matching the pattern and a new device node with the same name exists
# already, otherwise (also if the process does not run) it returns 0.
# As long as the new device node is missing (e.g. while multimacd is still
# starting), a restart would not help: S61rfd would even disable the RF
# interface in rfd.conf if /dev/mmd_bidcos is missing.
#

PIDFILE=${1}
PATTERN=${2:-/dev/mmd_*}

[ -r "${PIDFILE}" ] || exit 0
PID=$(cat "${PIDFILE}" 2>/dev/null)
{ [ -n "${PID}" ] && [ -d "/proc/${PID}/fd" ]; } || exit 0

# Nothing can be stale as long as no device node matching the pattern exists
# (e.g. if multimacd is not used), so skip scanning the fds in that case.
found=0
# shellcheck disable=SC2086
for dev in ${PATTERN}; do
  if [ -c "${dev}" ]; then
    found=1
    break
  fi
done
[ ${found} -eq 1 ] || exit 0

# List all fds with a single ls call and only keep the ones pointing to a
# removed file. Forking a readlink for each fd caused a high CPU load for
# processes with thousands of open fds like HMIPServer, cf.
# https://github.com/OpenCCU/OpenCCU/issues/4546
# The fd names are plain numbers, so parsing the ls output is safe here.
# shellcheck disable=SC2010
deleted=$(ls -ln "/proc/${PID}/fd/" 2>/dev/null | grep ' (deleted)$')
[ -n "${deleted}" ] || exit 0

while IFS= read -r line; do
  target=${line#* -> }
  # shellcheck disable=SC2254
  case "${target}" in
    ${PATTERN}" (deleted)")
      dev=${target%" (deleted)"}
      if [ -c "${dev}" ]; then
        echo "${dev} held by PID ${PID} is stale"
        exit 1
      fi
    ;;
  esac
done <<EOF
${deleted}
EOF

exit 0
