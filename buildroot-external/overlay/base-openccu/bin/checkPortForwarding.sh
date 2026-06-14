#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010,SC3001
#
# Port Forwarding check script v2.0
# Copyright (c) 2022-2026 Jens Maus <mail@jens-maus.de>
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
# This script tries to identify whether this OpenCCU is reachable from the
# public internet in an insecure way. It performs three independent checks:
#
#  1) a local configuration audit which reliably detects the most critical
#     misconfiguration (the WebUI being reachable from the internet *without*
#     a password) without depending on any (unreliable) external self-scan,
#  2) a firewall protection state audit which verifies that the on-device
#     firewall is actually restricting access to local source networks when
#     it is supposed to (i.e. it catches a silently failed prevention), and
#  3) a best-effort external port scan of the public IPv4 address which tries
#     to identify a router port forwarding that links back to this CCU.
#
# Note on detection limits: a host can not reliably observe its own external
# attack surface from behind the NAT/firewall (a self-scan of the device's
# own public IPv6 address for example is always answered locally via the
# loopback path and would therefore yield false positives). The actual
# *prevention* of external access is therefore implemented in the on-device
# firewall (see /lib/libfirewall.tcl), which restricts the WebUI and other
# services to local source networks by default. This script complements that
# firewall and warns about the remaining, locally detectable risks.
#
# This script returns the following result codes:
#
# 0 = No insecure internet exposure identified (or check not possible)
# 1 = Insecure internet exposure identified
#

# presence of this file means the user explicitly allowed external (internet)
# access to the WebUI and services (disabling the local-only firewall
# restriction), see /lib/libfirewall.tcl
OVERRIDE_FILE="/etc/config/AllowExternalAccess"

# presence of this file means the WebUI authentication (password) is enabled
AUTH_FILE="/etc/config/authEnabled"

# log <syslog-level> <message>
log() {
  /usr/bin/logger -t checkPortForwarding -p "user.${1}" "${2}"
}

# checkCCU <baseurl>
# Returns 0 if the given base URL points to a CCU (i.e. answers the
# homematic ReGa.isPresent API call positively), 1 otherwise. The match is
# whitespace tolerant to also catch reverse-proxied or differently formatted
# answers.
checkCCU() {
  _res=$(/usr/bin/curl -k -s --max-time 15 "${1}/api/homematic.cgi" \
           --data-raw '{"version": "1.1", "method": "ReGa.isPresent", "params": {}}' 2>/dev/null)
  [[ $? -ne 0 ]] && return 1
  _res=$(echo "${_res}" | tr -d ' \t\r\n')
  case "${_res}" in
    *'"result":true'*) return 0 ;;
  esac
  return 1
}

# exit in HMLGW mode immediately
[[ -e /usr/local/HMLGW ]] && exit 0

RESULT=0

########################################################################
# 1) local configuration audit
#
# The most dangerous and most frequently observed misconfiguration is a CCU
# whose WebUI is reachable from the internet *without* any password. This
# happens when the user both disabled the WebUI authentication AND explicitly
# allowed external access (which disables the local-only firewall
# restriction). This combination can be detected reliably on the device
# itself - independent of any (unreliable) self-scan.
########################################################################
if [[ -e "${OVERRIDE_FILE}" ]]; then
  if [[ ! -e "${AUTH_FILE}" ]]; then
    MSG="CRITICAL SECURITY ISSUE: WebUI is reachable from the internet WITHOUT a password (external access is allowed and authentication is disabled). Enable WebUI authentication or disable external access immediately."
    log err "${MSG}"
    /bin/triggerAlarm.tcl "${MSG}" "WatchDog: security-portforward" true
    RESULT=1
  else
    # external access is allowed but at least protected by a password - log
    # it so the exposure is not silently forgotten
    log notice "external (internet) access to the WebUI is explicitly allowed (password protected)"
  fi
fi

########################################################################
# 2) firewall protection state audit
#
# The external access prevention is implemented in the on-device firewall
# (see /lib/libfirewall.tcl) which restricts the WebUI and other services to
# local source networks via the OPENCCU_LOCAL gate chain. As a watchdog we
# verify that this protection is actually active when it is supposed to be
# (i.e. when the user did not opt into external access). If the firewall
# silently failed to apply, the protection would be missing without anybody
# noticing - which is exactly the kind of regression that detection (as
# opposed to prevention) is meant to catch.
########################################################################
if [[ ! -e "${OVERRIDE_FILE}" ]]; then

  # gate_state: active   = OPENCCU_LOCAL gate chain is referenced in INPUT
  #             inactive = INPUT could be queried but the gate is missing
  #             unknown  = iptables could not be queried (e.g. inside an
  #                        unprivileged container) - not verifiable
  gate_state="unknown"
  if [[ -x /usr/sbin/iptables ]] && fw_input=$(/usr/sbin/iptables -nL INPUT 2>/dev/null); then
    case "${fw_input}" in
      *OPENCCU_LOCAL*) gate_state="active" ;;
      *)               gate_state="inactive" ;;
    esac
    # if IPv6 is available the gate must be active there as well
    if [[ "${gate_state}" == "active" ]] && [[ -e /proc/net/if_inet6 ]] && [[ -x /usr/sbin/ip6tables ]]; then
      if fw_input6=$(/usr/sbin/ip6tables -nL INPUT 2>/dev/null); then
        case "${fw_input6}" in
          *OPENCCU_LOCAL*) ;;
          *)               gate_state="inactive" ;;
        esac
      fi
    fi
  fi

  if [[ "${gate_state}" == "inactive" ]]; then
    if [[ ! -e "${AUTH_FILE}" ]]; then
      MSG="CRITICAL SECURITY ISSUE: the firewall protection that restricts the WebUI to local networks is not active and WebUI authentication is disabled. The WebUI may be reachable from the internet without a password. Check the firewall configuration immediately."
      log err "${MSG}"
      /bin/triggerAlarm.tcl "${MSG}" "WatchDog: security-portforward" true
      RESULT=1
    else
      log warning "firewall protection (OPENCCU_LOCAL gate chain) is not active - WebUI/services are currently protected by authentication only"
    fi
  elif [[ "${gate_state}" == "unknown" ]]; then
    log notice "could not verify firewall protection state (iptables not usable)"
  fi
fi

########################################################################
# 3) best-effort external port scan (IPv4)
#
# As an additional safety net we try to identify a router port forwarding
# that links back to this CCU. If the user explicitly allowed external access
# this is intentional, so the scan is skipped in that case.
########################################################################
if [[ ! -e "${OVERRIDE_FILE}" ]]; then

  # get public ipv4 using different public services
  PUBIP_URIS="ifconfig.me icanhazip.com ipecho.net/plain ifconfig.co"
  PUBLIC_IP4=""
  for uri in ${PUBIP_URIS}; do
    PUBLIC_IP4=$(/usr/bin/curl -s -4 --max-time 10 "${uri}")
    # check if we received a valid ipv4 address
    if expr "${PUBLIC_IP4}" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
      break
    fi
    PUBLIC_IP4=""
  done

  if [[ -z "${PUBLIC_IP4}" ]]; then
    # could not determine the public IPv4 address (e.g. an IPv6-only / DS-Lite
    # connection or all lookup services being unreachable). This is explicitly
    # NOT an all-clear, so we log it to avoid a false sense of security.
    log notice "could not determine public IPv4 address - external port scan skipped"
  elif [[ ! -x /usr/bin/nmap ]]; then
    log notice "nmap not available - external port scan skipped"
  else
    # use nmap to get all open ports @ the public IP (use -T4 instead of -T5
    # to reduce the amount of missed open ports caused by dropped packets)
    OPEN_PORTS=$(/usr/bin/nmap --open -Pn -oG - -p- -n -T4 "${PUBLIC_IP4}" 2>/dev/null | /usr/bin/awk '
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
      }')

    # walk through all open ports and try to see if there is a CCU listening
    # using HTTP or HTTPS
    for p in ${OPEN_PORTS}; do
      if checkCCU "http://${p}" || checkCCU "https://${p}"; then
        MSG="CRITICAL SECURITY ISSUE: a port forwarding linking back to this CCU was identified at ${p}. Disable the port forwarding in your internet router immediately."
        log err "${MSG}"
        /bin/triggerAlarm.tcl "${MSG}" "WatchDog: security-portforward" true
        RESULT=1
        break
      fi
    done
  fi
fi

exit ${RESULT}
