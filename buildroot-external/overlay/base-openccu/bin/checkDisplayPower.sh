#!/bin/sh
# checkDisplayPower.sh — Display power management for OpenCCU
#
# Usage:
#   checkDisplayPower.sh              # auto: set powerdown timer + disable if no display
#   checkDisplayPower.sh off          # force display PHY off (monitor loses link)
#   checkDisplayPower.sh on           # force display PHY on
#   checkDisplayPower.sh status       # show connection + power state
#   checkDisplayPower.sh powerdown N  # set VESA powerdown timer to N minutes
#
# Supports all DRM connector types (HDMI, DisplayPort, DVI, VGA).
# Monitor detection uses EDID file size (reliable at boot time).
# Requires: DRM-capable kernel with display driver (e.g. vc4-kms-v3d on RPi)

# Minutes after consoleblank until display PHY powerdown
DEFAULT_POWERDOWN_MIN=1

# Match all DRM connectors (HDMI-A-*, DP-*, DVI-I-*, VGA-*, etc.)
DRM_CONNECTORS="/sys/class/drm/card*-*"

display_off() {
    echo 4 > /sys/class/graphics/fb0/blank 2>/dev/null
}

display_on() {
    echo 0 > /sys/class/graphics/fb0/blank 2>/dev/null
}

display_connected() {
    for c in ${DRM_CONNECTORS}; do
        [ -s "$c/edid" ] && return 0
    done
    return 1
}

display_status() {
    for c in ${DRM_CONNECTORS}; do
        [ -f "$c/edid" ] || continue
        EDID_SIZE=$(wc -c < "$c/edid" 2>/dev/null || echo 0)
        if [ "${EDID_SIZE:-0}" -gt 0 ]; then
            CONN="connected"
        else
            CONN="disconnected"
        fi
        echo "$(basename "$c"): ${CONN} edid=${EDID_SIZE}B dpms=$(cat "$c/dpms" 2>/dev/null)"
    done
}

display_set_powerdown() {
    for tty in /dev/tty[0-9]*; do
        [ -c "$tty" ] || continue
        if printf '\033[14;%d]' "$1" > "$tty" 2>/dev/null; then
            return 0
        fi
    done
    return 1
}

case "$1" in
    off)       display_off ;;
    on)        display_on ;;
    status)    display_status ;;
    powerdown)
        mins="${2:-$DEFAULT_POWERDOWN_MIN}"
        case "$mins" in
            ''|*[!0-9]*)
                echo "Invalid powerdown value: '$mins' (expected non-negative integer minutes)" >&2
                exit 1
                ;;
        esac
        display_set_powerdown "$mins"
        ;;
    ""|auto)
        if ! display_set_powerdown "$DEFAULT_POWERDOWN_MIN"; then
            echo "WARNING: failed to set console powerdown timer" >&2
        fi
        display_connected || display_off
        ;;
    *)
        echo "Usage: $0 {auto|off|on|status|powerdown N}" >&2
        exit 1
        ;;
esac
