#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010,SC3001
#
# Port Forwarding check script v2.1
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
# Usage:
#   checkPortForwarding.sh [-q|--quiet]
# Default mode prints execution details to stdout.

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

# progress <message>
progress() {
  [[ "${QUIET}" == "0" ]] && echo "[checkPortForwarding] ${1}"
}

# checkCCU <baseurl>
# Returns 0 if the given base URL points to a CCU (i.e. answers the
# homematic ReGa.isPresent API call positively), 1 otherwise. The match is
# whitespace tolerant to also catch reverse-proxied or differently formatted
# answers.
checkCCU() {
  progress "probing ${1}/api/homematic.cgi"
  if ! _res=$(/usr/bin/curl -k -s --max-time 15 "${1}/api/homematic.cgi" \
              --data-raw '{"version": "1.1", "method": "ReGa.isPresent", "params": {}}' 2>/dev/null); then
    progress "probe failed (no valid API response)"
    return 1
  fi
  _res=$(echo "${_res}" | tr -d ' \t\r\n')
  case "${_res}" in
    *'"result":true'*)
      progress "probe matched OpenCCU API response"
      return 0
      ;;
  esac
  progress "probe did not match OpenCCU API response"
  return 1
}

# hasLocalGateRules <iptables -S INPUT output> <address family>
# Returns 0 if INPUT contains the expected WebUI protection rules
# (--dport 80/443 -> local-only) and no conflicting explicit SSH open rule.
hasLocalGateRules() {
  _rules="${1}"
  _family="${2}"

  # WebUI ports must explicitly go through the local-only gate.
  if ! echo "${_rules}" | /bin/grep -Eq -- '^-A INPUT( .*)?-p tcp( .*)?--dport 80( .*)?-j local-only( |$)'; then
    progress "check 2/3: ${_family} local-only rule for TCP/80 is missing"
    return 1
  fi

  if ! echo "${_rules}" | /bin/grep -Eq -- '^-A INPUT( .*)?-p tcp( .*)?--dport 443( .*)?-j local-only( |$)'; then
    progress "check 2/3: ${_family} local-only rule for TCP/443 is missing"
    return 1
  fi

  # SSH is optional; if it is explicitly opened, it must not bypass the gate.
  _ssh_rules=$(echo "${_rules}" | /bin/grep -E -- '^-A INPUT( .*)?-p tcp( .*)?--dport 22( |$)')
  if [[ -n "${_ssh_rules}" ]]; then
    if echo "${_ssh_rules}" | /bin/grep -Evq -- '-j (local-only|DROP|REJECT)( |$)'; then
      progress "check 2/3: ${_family} SSH rule bypasses the local-only gate"
      return 1
    fi
  fi

  return 0
}

QUIET=0
while [[ $# -gt 0 ]]; do
  case "${1}" in
    -q|--quiet)
      QUIET=1
      ;;
    -h|--help)
      echo "Usage: $0 [-q|--quiet]"
      exit 0
      ;;
    *)
      echo "Unknown option: ${1}" >&2
      echo "Usage: $0 [-q|--quiet]" >&2
      exit 2
      ;;
  esac
  shift
done

# exit in HMLGW mode immediately
if [[ -e /usr/local/HMLGW ]]; then
  progress "HMLGW mode detected, skipping check"
  exit 0
fi

RESULT=0
progress "starting security checks"

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
  progress "check 1/3: external access override is enabled"
  if [[ ! -e "${AUTH_FILE}" ]]; then
    MSG="CRITICAL SECURITY ISSUE: WebUI is reachable from the internet WITHOUT a password (external access is allowed and authentication is disabled). Enable WebUI authentication or disable external access immediately."
    log err "${MSG}"
    /bin/triggerAlarm.tcl "${MSG}" "WatchDog: security-portforward" true
    RESULT=1
    progress "check 1/3: CRITICAL finding (override enabled and authentication disabled)"
  else
    # external access is allowed but at least protected by a password - log
    # it so the exposure is not silently forgotten
    log notice "external (internet) access to the WebUI is explicitly allowed (password protected)"
    progress "check 1/3: override enabled but authentication active"
  fi
else
  progress "check 1/3: external access override is disabled"
fi

########################################################################
# 2) firewall protection state audit
#
# The external access prevention is implemented in the on-device firewall
# (see /lib/libfirewall.tcl) which restricts the WebUI and other services to
# local source networks via the local-only gate chain. As a watchdog we
# verify that this protection is actually active when it is supposed to be
# (i.e. when the user did not opt into external access). If the firewall
# silently failed to apply, the protection would be missing without anybody
# noticing - which is exactly the kind of regression that detection (as
# opposed to prevention) is meant to catch.
########################################################################
if [[ ! -e "${OVERRIDE_FILE}" ]]; then
  progress "check 2/3: verifying local-only firewall gate state"

  # gate_state4/gate_state6:
  #   active         = expected protected INPUT rules are present
  #   inactive       = INPUT could be queried but expected protection is missing
  #   unknown        = firewall rules could not be queried
  #   not-applicable = the corresponding protocol family is unavailable
  gate_state4="unknown"
  gate_state6="not-applicable"

  if [[ -x /usr/sbin/iptables ]] && fw_input=$(/usr/sbin/iptables -S INPUT 2>/dev/null); then
    progress "check 2/3: IPv4 INPUT rules readable"
    if hasLocalGateRules "${fw_input}" "IPv4"; then
      gate_state4="active"
    else
      gate_state4="inactive"
    fi
  else
    progress "check 2/3: IPv4 INPUT rules are not readable"
  fi
  progress "check 2/3: IPv4 gate_state=${gate_state4}"

  # If IPv6 is available, the same protection must be verifiable there as
  # well. Evaluate it independently from IPv4 so a failure clearly identifies
  # the affected protocol family.
  if [[ -e /proc/net/if_inet6 ]]; then
    gate_state6="unknown"
    if [[ -x /usr/sbin/ip6tables ]]; then
      if fw_input6=$(/usr/sbin/ip6tables -S INPUT 2>/dev/null); then
        progress "check 2/3: IPv6 INPUT rules readable"
        if hasLocalGateRules "${fw_input6}" "IPv6"; then
          gate_state6="active"
        else
          gate_state6="inactive"
        fi
      else
        progress "check 2/3: IPv6 INPUT rules are not readable"
      fi
    else
      progress "check 2/3: IPv6 INPUT rules are not readable"
    fi
  else
    progress "check 2/3: IPv6 firewall check is not applicable"
  fi
  progress "check 2/3: IPv6 gate_state=${gate_state6}"

  # Derive the overall firewall state. Any confirmed missing protection is
  # considered inactive. The state is active only if IPv4 is protected and
  # IPv6 is either protected or not available.
  if [[ "${gate_state4}" == "inactive" ]] ||
     [[ "${gate_state6}" == "inactive" ]]; then
    gate_state="inactive"
  elif [[ "${gate_state4}" == "active" ]] &&
       { [[ "${gate_state6}" == "active" ]] ||
         [[ "${gate_state6}" == "not-applicable" ]]; }; then
    gate_state="active"
  else
    gate_state="unknown"
  fi

  progress "check 2/3: overall gate_state=${gate_state}"

  if [[ "${gate_state}" == "inactive" ]]; then
    _failed_families=""
    [[ "${gate_state4}" == "inactive" ]] && _failed_families="IPv4"
    if [[ "${gate_state6}" == "inactive" ]]; then
      _failed_families="${_failed_families:+${_failed_families}, }IPv6"
    fi
    if [[ ! -e "${AUTH_FILE}" ]]; then
      MSG="CRITICAL SECURITY ISSUE: the firewall protection that restricts the WebUI to local networks is not active for ${_failed_families} and WebUI authentication is disabled. The WebUI may be reachable from the internet without a password. Check the firewall configuration immediately."
      log err "${MSG}"
      /bin/triggerAlarm.tcl "${MSG}" "WatchDog: security-portforward" true
      RESULT=1
      progress "check 2/3: CRITICAL finding (firewall gate inactive and authentication disabled)"
    else
      log warning "firewall protection (local-only gate chain) is not active - WebUI/services are currently protected by authentication only"
      progress "check 2/3: firewall gate inactive but authentication enabled"
    fi
  elif [[ "${gate_state}" == "unknown" ]]; then
    log notice "could not verify firewall protection state (iptables not usable)"
    progress "check 2/3: firewall gate state could not be verified"
  fi
else
  progress "check 2/3: skipped because external access override is enabled"
fi

########################################################################
# 3) best-effort external port scan (IPv4)
#
# As an additional safety net we try to identify a router port forwarding
# that links back to this CCU. If the user explicitly allowed external access
# this is intentional, so the scan is skipped in that case.
########################################################################
if [[ ! -e "${OVERRIDE_FILE}" ]]; then
  progress "check 3/3: running best-effort external IPv4 scan"

  # get public ipv4 using different public services
  PUBIP_URIS="ifconfig.me icanhazip.com ipecho.net/plain ifconfig.co"
  PUBLIC_IP4=""
  for uri in ${PUBIP_URIS}; do
    progress "check 3/3: resolving public IPv4 via ${uri}"
    PUBLIC_IP4=$(/usr/bin/curl -s -4 --max-time 10 "${uri}")
    # check if we received a valid ipv4 address
    if expr "${PUBLIC_IP4}" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
      progress "check 3/3: using detected public IPv4 ${PUBLIC_IP4}"
      break
    fi
    PUBLIC_IP4=""
  done

  if [[ -z "${PUBLIC_IP4}" ]]; then
    # could not determine the public IPv4 address (e.g. an IPv6-only / DS-Lite
    # connection or all lookup services being unreachable). This is explicitly
    # NOT an all-clear, so we log it to avoid a false sense of security.
    log notice "could not determine public IPv4 address - external port scan skipped"
    progress "check 3/3: skipped (public IPv4 could not be determined)"
  elif [[ ! -x /usr/bin/nmap ]]; then
    log notice "nmap not available - external port scan skipped"
    progress "check 3/3: skipped (nmap not available)"
  else
    # use nmap to get all open ports @ the public IP (use -T4 instead of -T5
    # to reduce the amount of missed open ports caused by dropped packets)
    progress "check 3/3: scanning open ports on ${PUBLIC_IP4}"
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
      progress "check 3/3: probing detected open port ${p}"
      if checkCCU "http://${p}" || checkCCU "https://${p}"; then
        MSG="CRITICAL SECURITY ISSUE: a port forwarding linking back to this CCU was identified at ${p}. Disable the port forwarding in your internet router immediately."
        log err "${MSG}"
        /bin/triggerAlarm.tcl "${MSG}" "WatchDog: security-portforward" true
        RESULT=1
        progress "check 3/3: CRITICAL finding at ${p}"
        break
      fi
    done
    [[ "${RESULT}" == "0" ]] && progress "check 3/3: no OpenCCU service detected on scanned open ports"
  fi
else
  progress "check 3/3: skipped because external access override is enabled"
fi

progress "finished with result=${RESULT}"
exit ${RESULT}
