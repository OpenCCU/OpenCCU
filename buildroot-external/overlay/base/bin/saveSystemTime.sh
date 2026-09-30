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
# Usage: saveSystemTime.sh
#
# The time is only saved if it is plausible (not older than the firmware
# build time). Returns 0 if the time was saved, 1 otherwise.
#

TIMEFILE=/usr/local/etc/lastKnownTime

# get the firmware build time (in seconds since epoch) as the minimum
# plausible system time. For this we use the modification time of /VERSION
# which is generated at build time and located on the read-only rootfs.
BUILDTIME=$(stat -c %Y /VERSION 2>/dev/null || echo 0)

# only save the time if it is plausible at all
[[ "$(date +%s)" -ge "${BUILDTIME}" ]] || exit 1
[[ -d "$(dirname "${TIMEFILE}")" ]] || exit 1

# we only use the modification time of the file
touch "${TIMEFILE}"
