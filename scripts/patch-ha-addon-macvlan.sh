#!/usr/bin/env bash
#
# helper script to patch the docker environment of homeassistant so that
# the openccu will be additionally connected via a macvlan interface
# to be able to connect a HmIP-HAP/HmIPW-DRAP.
#
# Can be called in full interactive mode by just calling it via:
#
# ./patch-ha-addon-macvlan.sh
#
# or via overriding certain settings like:
#
# CCU_NETWORK_INTERFACE=eth1 CCU_CONTAINER_IP=192.168.178.20 ./patch-ha-addon-macvlan.sh
#
# or in full non-interactive mode accepting all defaults with
# allowing to partly override certain defaults:
#
# CCU_CONTAINER_IP=192.168.178.30 ./patch-ha-addon-macvlan.sh -n
#
# Copyright (c) 2023-2024 Jens Maus <mail@jens-maus.de>
# Apache 2.0 License applies
#

#############################################################
#                           Settings                        #
#############################################################

# network interface (e.g. 'eth0')
: "${CCU_NETWORK_INTERFACE:=""}"

# network subnet (e.g. '192.168.178.0/24')
: "${CCU_NETWORK_SUBNET:=""}"

# network gateway (e.g. '192.168.178.1')
: "${CCU_NETWORK_GATEWAY:=""}"

# openccu container name (e.g. '5422eb72-openccu')
: "${CCU_CONTAINER_NAME:=""}"

# openccu container ip (e.g. '192.168.178.4')
: "${CCU_CONTAINER_IP:=""}"

#############################################################
#                         Main App                          #
#############################################################
echo "OpenCCU HA-Addon macvlan patch script v1.2"
echo "Copyright (c) 2023-2024 Jens Maus <mail@jens-maus.de>"
echo

# check if non-interactive mode is requested
if [[ "${1}" == "-n" ]]; then
  NON_INTERACTIVE=true
fi

# network calc helper functions
tonum() {
  if [[ ${1} =~ ([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+) ]]; then
    addr=$(( (BASH_REMATCH[1] << 24) + (BASH_REMATCH[2] << 16) + (BASH_REMATCH[3] << 8) + BASH_REMATCH[4] ))
    echo "${addr}"
  fi
}

toaddr() {
  b1=$(( (${1} & 0xFF000000) >> 24))
  b2=$(( (${1} & 0xFF0000) >> 16))
  b3=$(( (${1} & 0xFF00) >> 8))
  b4=$(( ${1} & 0xFF ))
  echo "${b1}.${b2}.${b3}.${b4}"
}

cidr2network() {
  if [[ ${1} =~ ^([0-9\.]+)/([0-9]+)$ ]]; then
    ipaddr=${BASH_REMATCH[1]}
    netlen=${BASH_REMATCH[2]}
    zeros=$((32-netlen))
    netnum=0
    for (( i=0; i < zeros; i++ )); do
      netnum=$(( (netnum << 1) ^ 1 ))
    done
    netnum=$((netnum ^ 0xFFFFFFFF))
    netmask=$(toaddr ${netnum})
    ipaddrnum=$(tonum "${ipaddr}")
    netmasknum=$(tonum "${netmask}")
    networknum=$(( ipaddrnum & netmasknum ))
    network=$(toaddr ${networknum})
    echo "${network}/${netlen}"
  fi
}

echo -n "HomeAssistant Main Ethernet Interface (e.g. eth0): "
if [[ -z "${CCU_NETWORK_INTERFACE}" ]]; then
  CCU_NETWORK_INTERFACE=$(ip -o -f inet route | grep -e "^default" | awk '{print $5}')
  if [[ -z "${NON_INTERACTIVE}" ]]; then
    read -r -e -i "${CCU_NETWORK_INTERFACE}" CCU_NETWORK_INTERFACE </dev/tty
  else
    echo "${CCU_NETWORK_INTERFACE}"
  fi
else
  echo "${CCU_NETWORK_INTERFACE}"
fi

echo -n "HomeAssistant Main Subnet (e.g. 192.168.178.0/24): "
if [[ -z "${CCU_NETWORK_SUBNET}" ]]; then
  CCU_NETWORK_CIDR=$(ip -o -f inet addr show dev "${CCU_NETWORK_INTERFACE}" | awk '/scope global/ {print $4}')
  CCU_NETWORK_SUBNET=$(cidr2network "${CCU_NETWORK_CIDR}")
  if [[ -z "${NON_INTERACTIVE}" ]]; then
    read -r -e -i "${CCU_NETWORK_SUBNET}" CCU_NETWORK_SUBNET </dev/tty
  else
    echo "${CCU_NETWORK_SUBNET}"
  fi
else
  echo "${CCU_NETWORK_SUBNET}"
fi

echo -n "HomeAssistant Main Gateway (e.g. 192.168.178.1): "
if [[ -z "${CCU_NETWORK_GATEWAY}" ]]; then
  CCU_NETWORK_GATEWAY=$(ip route list dev "${CCU_NETWORK_INTERFACE}" | awk ' /^default/ {print $3}')
  if [[ -z "${NON_INTERACTIVE}" ]]; then
    read -r -e -i "${CCU_NETWORK_GATEWAY}" CCU_NETWORK_GATEWAY </dev/tty
  else
    echo "${CCU_NETWORK_GATEWAY}"
  fi
else
  echo "${CCU_NETWORK_GATEWAY}"
fi

echo -n "OpenCCU Add-on Hostname (e.g. 5422eb72-openccu): "
if [[ -z "${CCU_CONTAINER_NAME}" ]]; then
  CCU_CONTAINER_NAME=$(docker ps --format '{{.Names}}' | grep "_openccu" | cut -c7-)
  if [[ -z "${NON_INTERACTIVE}" ]]; then
    read -r -e -i "${CCU_CONTAINER_NAME}" CCU_CONTAINER_NAME </dev/tty
  else
    echo "${CCU_CONTAINER_NAME}"
  fi
  if [[ -z "${CCU_CONTAINER_NAME}" ]]; then
    echo "ERROR: Must specify the hostname of the running OpenCCU add-on"
    exit 1
  fi
else
  echo "${CCU_CONTAINER_NAME}"
fi
CCU_CONTAINER_NAME=$(echo "addon_${CCU_CONTAINER_NAME}" | sed 's/-rasp/_rasp/')

echo -n "OpenCCU Add-on IP (e.g. 192.168.178.4): "
if [[ -z "${CCU_CONTAINER_IP}" ]]; then
  CCU_CONTAINER_IP=$(echo "${CCU_NETWORK_GATEWAY}" | cut -d"." -f1-3)
  if [[ -z "${NON_INTERACTIVE}" ]]; then
    read -r -e -i "${CCU_CONTAINER_IP}." CCU_CONTAINER_IP </dev/tty
  else
    echo "${CCU_CONTAINER_IP}"
  fi
  if [[ -z "${CCU_CONTAINER_IP}" ]] || [[ $(echo "${CCU_CONTAINER_IP}" | grep -o "\." | wc -l) -ne 3 ]]; then
    echo "ERROR: Must specify a free and valid ip to assign to OpenCCU add-on"
    exit 1
  fi
else
  echo "${CCU_CONTAINER_IP}"
fi

# check if add-on is running
if ! docker inspect "${CCU_CONTAINER_NAME}" >/dev/null 2>&1; then
  echo "ERROR: OpenCCU isn't running or hostname incorrect."
  exit 1
fi

# remove old macvlan
if docker network inspect ccu >/dev/null 2>&1; then
  echo "Removing docker macvlan ccu network bridge"
  docker network disconnect ccu "${CCU_CONTAINER_NAME}"
  docker network rm ccu
fi

# re-create docker macvlan network
echo "Creating docker macvlan network"
docker network create -d macvlan \
                      --opt parent="${CCU_NETWORK_INTERFACE}" \
                      --subnet "${CCU_NETWORK_SUBNET}" \
                      --gateway "${CCU_NETWORK_GATEWAY}" \
                      ccu

echo "Connecting add-on to macvlan network"
docker network connect --ip "${CCU_CONTAINER_IP}" ccu "${CCU_CONTAINER_NAME}"

echo "Stopping add-on (${CCU_CONTAINER_NAME})"
docker stop --time 120 "${CCU_CONTAINER_NAME}"

echo "Starting add-on (${CCU_CONTAINER_NAME})"
docker start "${CCU_CONTAINER_NAME}"

exit 0
