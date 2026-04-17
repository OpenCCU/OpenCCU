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
# Considers only physical DRM connector types (HDMI, DisplayPort, DVI, VGA, LVDS).
# Virtual connectors (Writeback, Virtual, ...) are ignored.
# Monitor detection uses EDID file size (reliable at boot time).
#
# Display power control tries fb0/blank first (fbdev emulation), then falls
# back to console DPMS escape sequences for KMS-only systems without fbdev.
# Console escape sequences are sent to /dev/tty0 which is a kernel alias
# for the currently active virtual terminal.
#
# Requires: DRM-capable kernel with display driver
# Minutes after consoleblank until display PHY powerdown
DEFAULT_POWERDOWN_MIN=1

# Match all DRM connectors — physical filter is applied per-connector
DRM_CONNECTORS="/sys/class/drm/card*-*"

# sysfs address to fb0/blank
FB_BLANK="/sys/class/graphics/fb0/blank"

# /dev/tty0 always refers to the currently active VT
ACTIVE_TTY="/dev/tty0"

# Whitelist of physical DRM connector type prefixes.
# Covers HDMI, DisplayPort, DVI (all variants), VGA, LVDS, eDP, DSI, DPI, and legacy types.
is_physical_connector() {
    case "${1##*/}" in
        *-HDMI-A-*|*-HDMI-B-*) return 0 ;;
        *-DP-*|*-eDP-*)        return 0 ;;
        *-DVI-I-*|*-DVI-D-*|*-DVI-A-*) return 0 ;;
        *-VGA-*)               return 0 ;;
        *-LVDS-*)              return 0 ;;
        *-DSI-*|*-DPI-*|*-Composite-*|*-SVIDEO-*|*-Component-*|*-TV-*|*-DIN-*|*-SPI-*) return 0 ;;
        *) return 1 ;;
    esac
}

# Send an escape sequence to the currently active VT.
send_to_console() {
    [ -c "$ACTIVE_TTY" ] || return 1
    printf '%s' "$1" > "$ACTIVE_TTY" 2>/dev/null
}

# Power off display: prefer fb0/blank (fbdev), fall back to console DPMS.
# Console DPMS escape: ESC [ 9 ; n ]  with n=1 blank, n=4 powerdown
display_off() {
    echo "turning display off"
    if [ -w "$FB_BLANK" ]; then
        echo 4 > "$FB_BLANK" 2>/dev/null && return 0
    fi
    send_to_console "$(printf '\033[9;4]')"
}

display_on() {
    echo "turning display on"
    if [ -w "$FB_BLANK" ]; then
        echo 0 > "$FB_BLANK" 2>/dev/null && return 0
    fi
    send_to_console "$(printf '\033[9;0]')"
}

display_connected() {
    for c in ${DRM_CONNECTORS}; do
        is_physical_connector "$c" || continue
        [ -f "$c/edid" ] || continue
        EDID_SIZE=$(wc -c < "$c/edid" 2>/dev/null || echo 0)
        if [ "${EDID_SIZE:-0}" -gt 0 ]; then
          echo "$c connected"
          return 0
        fi
    done
    echo "no display connected"
    return 1
}

display_status() {
    for c in ${DRM_CONNECTORS}; do
        is_physical_connector "$c" || continue
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

# Set VESA powerdown timer via ESC [ 14 ; n ] — n = minutes after blank
display_set_powerdown() {
    send_to_console "$(printf '\033[14;%d]' "$1")"
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
