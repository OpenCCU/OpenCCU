#!/bin/sh
#
# This script will be called as soon as NUT identifies a
# connected UPS system to require some attention.
#
# You can adapt this to your needs and use ${UPSNAME} and
# ${NOTIFYTYPE} which will be set by NUT.
#

# trigger a HomeMatic alarm message to "${UPSNAME}-Alarm"
/bin/triggerAlarm.tcl "${NOTIFYTYPE}" "WatchDog: ${UPSNAME}-${NOTIFYTYPE}" true
