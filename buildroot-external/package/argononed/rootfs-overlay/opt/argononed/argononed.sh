#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010
#
# A shell script variant of a control daemon to
# control the fan and power buttons of a ArgonONE case
# or Argon FAN HAT
#
# Copyright (c) 2020-2021 Jens Maus <mail@jens-maus.de>
#

fancontrol()
{
  curspeed=-1
  dstspeed=0
  current_level=-1

  speed255_to_percent()
  {
    local speed255

    speed255=$1
    if [[ ${speed255} -lt 0 ]]; then
      speed255=0
    elif [[ ${speed255} -gt 255 ]]; then
      speed255=255
    fi
    echo $(( (speed255 * 100 + 127) / 255 ))
  }

  sanitize_uint()
  {
    local value fallback

    value=$1
    fallback=$2
    case "${value}" in
      ''|*[!0-9]*)
        echo "${fallback}"
        ;;
      *)
        echo "${value}"
        ;;
    esac
  }

  level_temp()
  {
    case "$1" in
      0) echo "${fan_temp0}" ;;
      1) echo "${fan_temp1}" ;;
      2) echo "${fan_temp2}" ;;
      3) echo "${fan_temp3}" ;;
      4) echo "${fan_temp4}" ;;
    esac
  }

  level_hyst()
  {
    case "$1" in
      0) echo "${fan_temp0_hyst}" ;;
      1) echo "${fan_temp1_hyst}" ;;
      2) echo "${fan_temp2_hyst}" ;;
      3) echo "${fan_temp3_hyst}" ;;
      4) echo "${fan_temp4_hyst}" ;;
      *) echo "0" ;;
    esac
  }

  level_speed_percent()
  {
    case "$1" in
      0) echo "${fan_temp0_speed_percent}" ;;
      1) echo "${fan_temp1_speed_percent}" ;;
      2) echo "${fan_temp2_speed_percent}" ;;
      3) echo "${fan_temp3_speed_percent}" ;;
      4) echo "${fan_temp4_speed_percent}" ;;
      *) echo "0" ;;
    esac
  }

  validate_curve()
  {
    local prev_temp temp hyst level

    prev_temp=-1
    for level in 0 1 2 3 4; do
      temp=$(level_temp "${level}")
      hyst=$(level_hyst "${level}")

      if [[ ${temp} -le ${prev_temp} ]] || [[ ${hyst} -gt ${temp} ]]; then
        return 1
      fi
      prev_temp=${temp}
    done
  }

  set_default_curve()
  {
    fan_temp0=56000
    fan_temp0_speed=10
    fan_temp0_hyst=2000
    fan_temp1=66000
    fan_temp1_speed=15
    fan_temp1_hyst=2000
    fan_temp2=70000
    fan_temp2_speed=26
    fan_temp2_hyst=2000
    fan_temp3=75000
    fan_temp3_speed=128
    fan_temp3_hyst=2000
    fan_temp4=80000
    fan_temp4_speed=255
    fan_temp4_hyst=2000
  }

  # default fan curve, can be overwritten in /etc/config/argononed.conf
  set_default_curve

  # shellcheck disable=SC1091
  [[ -r /etc/config/argononed.conf ]] && . /etc/config/argononed.conf

  fan_temp0=$(sanitize_uint "${fan_temp0}" "56000")
  fan_temp1=$(sanitize_uint "${fan_temp1}" "66000")
  fan_temp2=$(sanitize_uint "${fan_temp2}" "70000")
  fan_temp3=$(sanitize_uint "${fan_temp3}" "75000")
  fan_temp4=$(sanitize_uint "${fan_temp4}" "80000")
  fan_temp0_hyst=$(sanitize_uint "${fan_temp0_hyst}" "2000")
  fan_temp1_hyst=$(sanitize_uint "${fan_temp1_hyst}" "2000")
  fan_temp2_hyst=$(sanitize_uint "${fan_temp2_hyst}" "2000")
  fan_temp3_hyst=$(sanitize_uint "${fan_temp3_hyst}" "2000")
  fan_temp4_hyst=$(sanitize_uint "${fan_temp4_hyst}" "2000")
  fan_temp0_speed=$(sanitize_uint "${fan_temp0_speed}" "10")
  fan_temp1_speed=$(sanitize_uint "${fan_temp1_speed}" "15")
  fan_temp2_speed=$(sanitize_uint "${fan_temp2_speed}" "26")
  fan_temp3_speed=$(sanitize_uint "${fan_temp3_speed}" "128")
  fan_temp4_speed=$(sanitize_uint "${fan_temp4_speed}" "255")

  fan_temp0_speed_percent=$(speed255_to_percent "${fan_temp0_speed}")
  fan_temp1_speed_percent=$(speed255_to_percent "${fan_temp1_speed}")
  fan_temp2_speed_percent=$(speed255_to_percent "${fan_temp2_speed}")
  fan_temp3_speed_percent=$(speed255_to_percent "${fan_temp3_speed}")
  fan_temp4_speed_percent=$(speed255_to_percent "${fan_temp4_speed}")

  if ! validate_curve; then
    logger -t argononed "Invalid fan curve in /etc/config/argononed.conf, falling back to defaults"
    set_default_curve
    fan_temp0_speed_percent=$(speed255_to_percent "${fan_temp0_speed}")
    fan_temp1_speed_percent=$(speed255_to_percent "${fan_temp1_speed}")
    fan_temp2_speed_percent=$(speed255_to_percent "${fan_temp2_speed}")
    fan_temp3_speed_percent=$(speed255_to_percent "${fan_temp3_speed}")
    fan_temp4_speed_percent=$(speed255_to_percent "${fan_temp4_speed}")
  fi

  while true; do
    curtemp=$(sanitize_uint "$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)" "0")

    next_level=$(( current_level + 1 ))
    while [[ ${next_level} -le 4 ]]; do
      next_temp=$(level_temp "${next_level}")
      if [[ ${curtemp} -ge ${next_temp} ]]; then
        current_level=${next_level}
        next_level=$(( next_level + 1 ))
      else
        break
      fi
    done

    while [[ ${current_level} -ge 0 ]]; do
      level_temp_value=$(level_temp "${current_level}")
      level_hyst_value=$(level_hyst "${current_level}")
      if [[ ${curtemp} -lt $(( level_temp_value - level_hyst_value )) ]]; then
        current_level=$(( current_level - 1 ))
      else
        break
      fi
    done

    if [[ ${current_level} -ge 0 ]]; then
      dstspeed=$(level_speed_percent "${current_level}")
    else
      dstspeed=0
    fi

    if [[ ${dstspeed} -ne ${curspeed} ]]; then
      /usr/sbin/i2cset -y 1 0x1a "${dstspeed}"
      curspeed=${dstspeed}
    fi

    sleep 30
  done
}

powercontrol()
{
  while true; do
    # wait for rising+falling edge on GPIO line 4
    # and catch the timestamp output to check if we
    # need to reboot or shutdown
    output=$(/usr/bin/gpiomon -r -f -n 2 -F %s.%n gpiochip0 4)
    pulsetime=$(echo "${output}" | awk '{ print int(($2-$1)/0.01) }')

    # depending on the pulsetime length we either reboot
    # or shutdown
    if [[ ${pulsetime} -ge 2 ]] && [[ ${pulsetime} -le 3 ]]; then
      /sbin/reboot
    elif [[ ${pulsetime} -ge 4 ]] && [[ ${pulsetime} -le 5 ]]; then
      /sbin/poweroff
    fi
  done
}

cleanup()
{
  kill -9 "${fancontrolPID}" 2>/dev/null
  kill -9 "${powercontrolPID}" 2>/dev/null
  pkill -f gpiomon.*gpiochip0.4
}

# install exit traps
trap cleanup EXIT INT TERM

# switch ArgonONE case to "always on"
# see https://github.com/Argon40Tech/Argon-ONE-i2c-Codes
# NOTE: This seems to require newer ArgonONE firmwares/hardware revisions
/usr/sbin/i2cset -y 1 0x1a 0xfe

# start fancontrol sub-process
fancontrol &
fancontrolPID=$!

# start powercontrol sub-process
powercontrol &
powercontrolPID=$!

# wait until powercontrol sub-process finishes
wait ${powercontrolPID}
