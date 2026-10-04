#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010 source=/dev/null
#
# Helper script to save the current system time as the "last known" system
# time to the persistent userfs (cf. restoreSystemTime.sh). This makes sure
# that systems without a (valid) RTC never start with a system time in the
# past (e.g. 1970-01-01) in case no NTP server can be reached at boot time
# (e.g. router still booting after a power outage). Such an invalid time can
# cause trouble for time dependent services like the HmIP security counter
# handling of HMIPServer (cf. https://github.com/OpenCCU/OpenCCU/issues/4274)
#
# Usage: saveSystemTime.sh [--force]
#
# The time is only saved if it is plausible, i.e. not older than the firmware
# build time and not more than 2 years ahead of the last known time (or the
# firmware build time), e.g. after the time was set manually to a bogus value.
# The latter check can be skipped with --force if the time has been verified
# (e.g. after a NTP time sync). Returns 0 if the time was saved, 1 otherwise.
#

TIMEFILE=/usr/local/etc/lastKnownTime

# maximum time (2 years) the system time may be ahead of the last known time
# before it is considered implausible (cf. restoreSystemTime.sh)
MAXAHEAD=$((2 * 366 * 24 * 60 * 60))

# get the firmware build time (in seconds since epoch) as the minimum
# plausible system time. For this we use the modification time of /VERSION
# which is generated at build time and located on the read-only rootfs.
BUILDTIME=$(stat -c %Y /VERSION 2>/dev/null || echo 0)

# only save the time if it is not older than the build time
NOW=$(date +%s)
[[ "${NOW}" -ge "${BUILDTIME}" ]] || exit 1

# only save a not verified time if it is not implausibly far ahead of the
# last known time (or the build time). Otherwise such a time would be used
# by restoreSystemTime.sh at the next boot.
if [[ "$1" != "--force" ]]; then
  MINTIME=${BUILDTIME}
  if [[ -f "${TIMEFILE}" ]]; then
    LASTTIME=$(stat -c %Y "${TIMEFILE}" 2>/dev/null || echo 0)
    [[ "${LASTTIME}" -gt "${MINTIME}" ]] && MINTIME=${LASTTIME}
  fi
  if [[ "${MINTIME}" -gt 0 ]] &&
     [[ "${NOW}" -gt $((MINTIME + MAXAHEAD)) ]]; then
    exit 1
  fi
fi

[[ -d "$(dirname "${TIMEFILE}")" ]] || exit 1

# we only use the modification time of the file
touch "${TIMEFILE}"
