#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010 source=/dev/null
#
# Helper script to restore the "last known" system time saved by
# saveSystemTime.sh from the persistent userfs. This makes sure that systems
# without a (valid) RTC never start with a system time in the past (e.g.
# 1970-01-01) in case no NTP server can be reached at boot time (e.g. router
# still booting after a power outage). Such an invalid time can cause trouble
# for time dependent services like the HmIP security counter handling of
# HMIPServer (cf. https://github.com/OpenCCU/OpenCCU/issues/4274)
#
# Usage: restoreSystemTime.sh
#
# The system time is set to the last known time (or at least the firmware
# build time) if the current time is older or if it is implausibly far (more
# than 2 years) in the future (e.g. RTC with a bogus time). Returns 0 if the
# time was restored, 1 otherwise.
#

TIMEFILE=/usr/local/etc/lastKnownTime

# maximum time (2 years) the system time may be ahead of the last known time
# before it is considered implausible
MAXAHEAD=$((2 * 366 * 24 * 60 * 60))

# get the firmware build time (in seconds since epoch) as the minimum
# plausible system time. For this we use the modification time of /VERSION
# which is generated at build time and located on the read-only rootfs.
MINTIME=$(stat -c %Y /VERSION 2>/dev/null || echo 0)

# use the last known time if it is newer
if [[ -f "${TIMEFILE}" ]]; then
  LASTTIME=$(stat -c %Y "${TIMEFILE}" 2>/dev/null || echo 0)
  [[ "${LASTTIME}" -gt "${MINTIME}" ]] && MINTIME=${LASTTIME}
fi

# keep the current system time if it is plausible, i.e. not older than
# MINTIME (e.g. 1970-01-01 due to no/invalid RTC) and not implausibly far
# in the future (e.g. RTC with a bogus time). Without any reference time
# there is no upper bound. Otherwise the time is set to MINTIME, which is
# also the safe direction for a time in the future, because it would
# permanently increase the time based HmIP security counter
# (cf. https://github.com/OpenCCU/OpenCCU/issues/4274)
NOW=$(date +%s)
if [[ "${NOW}" -ge "${MINTIME}" ]] &&
   { [[ "${MINTIME}" -eq 0 ]] || [[ "${NOW}" -le $((MINTIME + MAXAHEAD)) ]]; }; then
  exit 1
fi

date -u -s "@${MINTIME}" >/dev/null 2>&1
