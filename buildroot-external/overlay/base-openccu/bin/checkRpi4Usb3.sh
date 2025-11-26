#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010,SC1091
#
# RaspberryPi4+USB+GPIO check script v1.2
# Copyright (c) 2021-2022 Jens Maus <mail@jens-maus.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This script can be executed and will check if the underlying system is
# a RaspberryPi4 where one of the USB3 ports are running with USB3 speed
# together with a connected GPIO RF module (RPI-RF-MOD/HM-MOD-RPI-PCB)
# because this combination is known to rf interference issues due to the
# critical USB3 controller of the Pi4 which produces a lot of RF jam
# resulting in our 868MHz communication to not work properly.
#
# This script returns the following result codes:
# 0=Pi4 found with no USB3 device connectivity
# 1=non-Pi4 device or no GPIO use detected (will disable the watchdog)
# 2=critical USB3+GPIO rf module use identified -> watchdog-alarm!
#

# only continue if not disabled
[[ -e /etc/config/rpi4usb3CheckDisabled ]] && exit 1

# check if this is a RaspberryPi4 model
case "$(grep Revision /proc/cpuinfo | awk '{print $3}')" in

  # RaspberryPi4 has cpuinfo Revision like 'd03114'
  [abcd]?31[134]?)

    # source in values from /var/hm_mode
    [[ -r /var/hm_mode ]] && . /var/hm_mode

    # check if a rf module is connected via GPIO
    if echo "${HM_HMRF_DEVTYPE}${HM_HMIP_DEVTYPE}" | grep -qi GPIO; then

      # check if critical USB3 connectivity exists (Bus 002 used)
      for f in /sys/bus/usb/devices/2-[12]:*; do
        if [[ -e "${f}" ]]; then
          echo "critical"
          exit 2
        fi
      done

      echo "ok"
      exit 0
    fi
  ;;

esac

exit 1
