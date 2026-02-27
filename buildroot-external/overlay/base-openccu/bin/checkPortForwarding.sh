#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010,SC3001
#
# Port Forwarding check script v1.1
# Copyright (c) 2022-2023 Jens Maus <mail@jens-maus.de>
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
# This script retrieves the public internet IP and uses "nmap" to
# try to identify open ports which could potentially link back to a CCU
# which means that a port forwarding has been setup in the internet
# router for which we need to trigger an alarm message in the WebUI.
#
# This script returns the following result codes:
#
# 0 = No port forwarding identified
# 1 = Identified port forwarding
#

# exit in HMLGW mode immediately
[[ -e /usr/local/HMLGW ]] && exit 0

# get public ipv4 using different public services
PUBIP_URIS="ifconfig.me icanhazip.com ipecho.net/plain ifconfig.co"
for uri in ${PUBIP_URIS}; do
  PUBLIC_IP4=$(/usr/bin/curl -s -4 "${uri}")
  # check if we received a valid ipv4 address
  if expr "${PUBLIC_IP4}" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
    break;
  fi
done

# check if we have a valid ipv4 address
if expr "${PUBLIC_IP4}" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
  # use nmap to get all open ports @ the public IP
  OPEN_PORTS=$(/usr/bin/nmap --open -Pn -oG - -p- -n -T5 "${PUBLIC_IP4}" 2>/dev/null | awk -f <(cat - <<-'_EOF_'
    BEGIN { OFS=":" }
    { ip = $2 }
    sub(/^([^[:space:]]+[[:space:]]+){3}Ports:[[:space:]]+/,"") {
        n = split($0,f,/\/[^,]+(,[[:space:]]*|[[:space:]]*$)/)
        for (i=1; i<n; i++) {
            port = f[i]
            if ( !seen[ip,port]++ ) {
                print ip, port
            }
        }
    }
_EOF_
))

  # walk through all open ports and try to see if there is rega listening
  # using HTTP or HTTPS
  for p in ${OPEN_PORTS}; do
    RES=$(/usr/bin/curl -s "http://${p}/api/homematic.cgi" \
               --data-raw '{"version": "1.1", "method": "ReGa.isPresent", "params": {}}')
    RET=$?
    if [[ ${RET} -eq 0 ]]; then
      if [[ "${RES}" == '{"version": "1.1","result": true,"error": null}' ]]; then
        echo "WARN: critical port forwarding identified at ${p}"
        /bin/triggerAlarm.tcl "CRITICAL SECURITY ISSUE: Disable port forwarding @ ${p} immediately" "WatchDog: security-portforward" true
        exit 1
      fi
    elif [[ ${RET} -eq 35 ]]; then
      # try to connect via https now since return code 35 could mean
      # this port requires a secure http connection instead.
      RES=$(/usr/bin/curl -k -s "https://${p}/api/homematic.cgi" \
                 --data-raw '{"version": "1.1", "method": "ReGa.isPresent", "params": {}}')
      RET=$?
      if [[ ${RET} -eq 0 ]]; then
        if [[ "${RES}" == '{"version": "1.1","result": true,"error": null}' ]]; then
          echo "WARN: critical port forwarding identified at ${p}"
          /bin/triggerAlarm.tcl "CRITICAL SECURITY ISSUE: Disable port forwarding @ ${p} immediately" "WatchDog: security-portforward" true
          exit 1
        fi
      fi
    fi
  done
else
  echo "No valid public IPv4 address identified"
fi

exit 0
