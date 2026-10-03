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
# node matching the pattern, otherwise (also if the process does not run)
# it returns 0.
#

PIDFILE=${1}
PATTERN=${2:-/dev/mmd_*}

[ -r "${PIDFILE}" ] || exit 0
PID=$(cat "${PIDFILE}" 2>/dev/null)
{ [ -n "${PID}" ] && [ -d "/proc/${PID}/fd" ]; } || exit 0

for fd in /proc/"${PID}"/fd/*; do
  target=$(readlink "${fd}" 2>/dev/null) || continue
  # shellcheck disable=SC2254
  case "${target}" in
    ${PATTERN}" (deleted)")
      echo "${target%" (deleted)"} held by PID ${PID} is stale"
      exit 1
    ;;
  esac
done

exit 0
