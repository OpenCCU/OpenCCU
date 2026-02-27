#!/bin/sh
# shellcheck shell=dash disable=SC2169 source=/dev/null
#
# crRFD device check script v1.5
# Copyright (c) 2019-2021 Jens Maus <mail@jens-maus.de>
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
# This script checks all *.dev,*.ap,*.apkx,*.bbkx files in /etc/config/crRFD/data
# and moves files to a backup directory for which the SGTIN cannot be found
# in the homematic.regadom file of ReGaHss
#

# do not continue if homematic.regadom is not there or empty
[[ -s /etc/config/homematic.regadom ]] || exit 1

# do not continue if /etc/config/crRFD/data does not exist
[[ -d /etc/config/crRFD/data ]] || exit 1

# soure /var/hm_mode
[[ -r /var/hm_mode ]] && . /var/hm_mode

# continue only if HM_HMIP_SGTIN is not empty
[[ -n "${HM_HMIP_SGTIN}" ]] || exit 1

# check for "-f" option to start fixing operation
[[ "${1}" == "-f" ]] && FIX=1 || FIX=0

# check if regadom contains HmIP-RCV already and if not we don't
# move away any ap,apkx,bbkx files
if grep -q -m1 "<devlabel>HmIP-RCV-" /etc/config/homematic.regadom; then
  FILE_PATTERN="[0-9A-F]{24}\.(dev|ap|apkx|bbkx)$"
else
  FILE_PATTERN="[0-9A-F]{24}\.dev$"
fi

OLDPATH=/etc/config/crRFD/data/old_$(date +%Y%m%d-%H%M%S)
# shellcheck disable=SC2010
FILES=$(ls /etc/config/crRFD/data | grep -E "${FILE_PATTERN}" | cut -d. -f1 | uniq)
for sgtin in ${FILES}; do

  # check if this SGTIN belongs to a HmIPW-DRAP by checking if it is
  # listed in metaData.conf and if so skip it
  if grep -q "${sgtin}:type\":\"HmIPW-DRAP\"" /etc/config/crRFD/data/metaData.conf &>/dev/null; then
    continue
  fi

  # check if this SGTIN belongs to our currently active RF-module and
  # if so we ignore it
  if [[ "${HM_HMIP_SGTIN}" == "${sgtin}" ]]; then
    continue
  fi

  DEVADR=${sgtin:(-14)}
  if [[ -n "${DEVADR}" ]]; then
    if ! grep -iq -m1 "<devadr>${DEVADR}" /etc/config/homematic.regadom; then
      echo -n "WARNING: SGTIN ${DEVADR} not found in regadom"
      if [[ ${FIX} -eq 1 ]]; then
        [[ -d ${OLDPATH} ]] || mkdir -p "${OLDPATH}"
        mv "/etc/config/crRFD/data/${sgtin}".* "${OLDPATH}/"
        echo "... moved ${sgtin}.* to ${OLDPATH}/"
      else
        echo "."
      fi
    fi
  fi
done

exit 0
