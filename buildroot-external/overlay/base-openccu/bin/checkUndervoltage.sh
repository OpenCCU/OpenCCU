#!/bin/sh
# checkUndervoltage.sh - platform independent undervoltage-check
#
# Exit codes:
#   0 = no alarm active
#   1 = no hwmon alarm files present (nothing to check)
#   2 = at least one alarm is active

# Check whether any undervoltage-related alarm file exists before iterating.
# Glob expands to itself if nothing matches, so a -e test is reliable.
FOUND=0
for f in /sys/class/hwmon/hwmon*/in*_lcrit_alarm /sys/class/hwmon/hwmon*/in*_min_alarm; do
    [ -e "$f" ] && FOUND=1 && break
done

if [ "$FOUND" -eq 0 ]; then
    echo "No hwmon alarm files found" >&2
    exit 1
fi

# iterate over undervoltage-related hwmon alarms
for f in /sys/class/hwmon/hwmon*/in*_lcrit_alarm /sys/class/hwmon/hwmon*/in*_min_alarm; do
    [ -r "$f" ] || continue
    if [ "$(cat "$f" 2>/dev/null)" = "1" ]; then
        echo "ALARM: $f"
        exit 2
    fi
done

echo "No undervoltage identified"

exit 0
