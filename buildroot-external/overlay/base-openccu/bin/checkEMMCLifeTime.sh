#!/bin/sh
# shellcheck shell=dash disable=SC2169
#
# eMMC life time check script v1.1
# Copyright (c) 2021 Jens Maus <mail@jens-maus.de>
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
# This script can be executed and will query the device where rootfs (/)
# is mounted. It will then check if a /sys/block/<diskid>/device/life_time
# entry exists and if so it outputs the life time level of the user
# partition for further analysis. In addition it sets the return/exit code
# according to the severity (0=ok, 1=n/a, 2=warn, 3=error)
#

ROOTDEV=$(mountpoint -n / | cut -d" " -f1)
[[ -b ${ROOTDEV} ]] || exit 1

DISKDEV=$(/bin/lsblk -s -p -d -r -n -o NAME "${ROOTDEV}" | tail -1)
[[ -b ${DISKDEV} ]] || exit 1

DISKID=$(basename "${DISKDEV}")
[[ -n "${DISKID}" ]] || exit 1

# check if /sys/block/<diskid>/device/life_time
if [[ -f "/sys/block/${DISKID}/device/life_time" ]]; then
  life_time_value=$(( $(cut -d' ' -f2 "/sys/block/${DISKID}/device/life_time") ))

  # 0=Not defined, 1-10=0-100% device life time used, 11=Exceeded
  if [[ ${life_time_value} -gt 0 ]]; then
    if [[ ${life_time_value} -eq 11 ]]; then
      echo "100%"
      exit 3
    elif [[ ${life_time_value} -ge 9 ]]; then
      echo "$(( (life_time_value-1) * 10 ))-$(( life_time_value * 10 ))%"
      exit 2
    else
      echo "$(( (life_time_value-1) * 10 ))-$(( life_time_value * 10 ))%"
      exit 0
    fi
  fi
fi

exit 1
