#!/usr/bin/with-contenv bashio
set -euo pipefail

OPENCCU_SLUG="$(bashio::config 'openccu_slug')"
NETWORK_NAME="$(bashio::config 'network_name')"
PARENT_IF="$(bashio::config 'parent_interface')"
SUBNET="$(bashio::config 'subnet')"
GATEWAY="$(bashio::config 'gateway')"
OPENCCU_IP="$(bashio::config 'openccu_ip')"
CHECK_INTERVAL="$(bashio::config 'check_interval')"
RECONNECT="$(bashio::config 'reconnect_container')"

validate_required_config() {
  if [ -z "${OPENCCU_SLUG}" ]; then
    bashio::log.error "Missing required config option: 'openccu_slug'."
    exit 1
  fi
  if [ -z "${NETWORK_NAME}" ]; then
    bashio::log.error "Missing required config option: 'network_name'."
    exit 1
  fi
}

to_num() {
  local b1 b2 b3 b4
  IFS=. read -r b1 b2 b3 b4 <<<"$1"
  echo "$(( (b1 << 24) + (b2 << 16) + (b3 << 8) + b4 ))"
}

to_addr() {
  local num="$1"
  echo "$(( (num >> 24) & 255 )).$(( (num >> 16) & 255 )).$(( (num >> 8) & 255 )).$(( num & 255 ))"
}

cidr_to_network() {
  local cidr="$1" ip netlen zeros mask ip_num net_num
  if [[ ! "${cidr}" =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/([0-9]+)$ ]]; then
    return 1
  fi

  ip="${BASH_REMATCH[1]}"
  netlen="${BASH_REMATCH[2]}"
  zeros=$((32 - netlen))
  mask=0
  while [ "${zeros}" -gt 0 ]; do
    mask=$(( (mask << 1) ^ 1 ))
    zeros=$((zeros - 1))
  done
  mask=$((mask ^ 0xFFFFFFFF))
  ip_num="$(to_num "${ip}")"
  net_num=$((ip_num & mask))
  echo "$(to_addr "${net_num}")/${netlen}"
}

resolve_parent_interface() {
  if [ -n "${PARENT_IF}" ]; then
    bashio::log.info "Using configured parent interface: ${PARENT_IF}"
    return 0
  fi

  bashio::log.info "Detecting parent network interface from default route"
  PARENT_IF="$(ip -o -f inet route | awk '/^default/ {print $5; exit}')"
  if [ -z "${PARENT_IF}" ]; then
    bashio::log.error "Could not detect parent interface. Please set 'parent_interface'."
    exit 1
  fi
  bashio::log.info "Detected parent interface: ${PARENT_IF}"
}

resolve_subnet() {
  if [ -n "${SUBNET}" ]; then
    bashio::log.info "Using configured subnet: ${SUBNET}"
    return 0
  fi

  bashio::log.info "Detecting subnet on parent interface ${PARENT_IF}"
  local iface_cidr
  iface_cidr="$(ip -o -f inet addr show dev "${PARENT_IF}" | awk '/scope global/ {print $4; exit}')"
  if [ -z "${iface_cidr}" ]; then
    bashio::log.error "Could not detect subnet on ${PARENT_IF}. Please set 'subnet'."
    exit 1
  fi

  SUBNET="$(cidr_to_network "${iface_cidr}" || true)"
  if [ -z "${SUBNET}" ]; then
    bashio::log.error "Could not convert interface CIDR '${iface_cidr}' to subnet."
    exit 1
  fi
  bashio::log.info "Detected subnet: ${SUBNET}"
}

resolve_gateway() {
  if [ -n "${GATEWAY}" ]; then
    bashio::log.info "Using configured gateway: ${GATEWAY}"
    return 0
  fi

  bashio::log.info "Detecting gateway for parent interface ${PARENT_IF}"
  GATEWAY="$(ip route list dev "${PARENT_IF}" | awk '/^default/ {print $3; exit}')"
  if [ -z "${GATEWAY}" ]; then
    GATEWAY="$(ip -o -f inet route | awk '/^default/ {print $3; exit}')"
  fi
  if [ -z "${GATEWAY}" ]; then
    bashio::log.error "Could not detect gateway. Please set 'gateway'."
    exit 1
  fi
  bashio::log.info "Detected gateway: ${GATEWAY}"
}

find_openccu_container() {
  docker ps --format '{{.Names}}' | grep -E "^addon_.*_${OPENCCU_SLUG}$|^addon_${OPENCCU_SLUG}$" | head -n1
}

resolve_openccu_ip() {
  local container="$1"

  if [ -n "${OPENCCU_IP}" ]; then
    bashio::log.info "Using configured OpenCCU IP: ${OPENCCU_IP}"
    return 0
  fi

  bashio::log.info "Detecting OpenCCU IP from existing ${NETWORK_NAME} connection"
  OPENCCU_IP="$(docker inspect -f "{{with index .NetworkSettings.Networks \"${NETWORK_NAME}\"}}{{.IPAddress}}{{end}}" "${container}" 2>/dev/null || true)"
  if [ -n "${OPENCCU_IP}" ]; then
    bashio::log.info "Detected OpenCCU IP from docker network: ${OPENCCU_IP}"
    return 0
  fi

  bashio::log.error "No OpenCCU IP configured and no existing '${NETWORK_NAME}' IP detected."
  bashio::log.error "Set 'openccu_ip' to a free LAN IP and restart this helper."
  exit 1
}

ensure_network() {
  local container="${1:-}"
  local inspect_output existing_driver existing_parent existing_subnet existing_gateway

  bashio::log.info "Inspecting docker network '${NETWORK_NAME}'"
  inspect_output="$(docker network inspect "${NETWORK_NAME}" \
    --format '{{.Driver}}|{{index .Options "parent"}}|{{(index .IPAM.Config 0).Subnet}}|{{(index .IPAM.Config 0).Gateway}}' \
    2>/dev/null || true)"

  if [ -z "${inspect_output}" ]; then
    bashio::log.info "Creating docker macvlan network '${NETWORK_NAME}'"
    docker network create -d macvlan \
      --opt parent="${PARENT_IF}" \
      --subnet "${SUBNET}" \
      --gateway "${GATEWAY}" \
      "${NETWORK_NAME}" >/dev/null
    bashio::log.info "Docker network '${NETWORK_NAME}' created"
    return 0
  fi

  IFS='|' read -r existing_driver existing_parent existing_subnet existing_gateway <<<"${inspect_output}"
  if [ "${existing_driver}" = "macvlan" ] && \
     [ "${existing_parent}" = "${PARENT_IF}" ] && \
     [ "${existing_subnet}" = "${SUBNET}" ] && \
     [ "${existing_gateway}" = "${GATEWAY}" ]; then
    bashio::log.info "Docker network '${NETWORK_NAME}' already matches configured settings"
    return 0
  fi

  bashio::log.info "Recreating docker network '${NETWORK_NAME}' to match configured settings"
  if [ -n "${container}" ]; then
    docker network disconnect "${NETWORK_NAME}" "${container}" >/dev/null 2>&1 || true
  fi
  docker network rm "${NETWORK_NAME}" >/dev/null
  docker network create -d macvlan \
    --opt parent="${PARENT_IF}" \
    --subnet "${SUBNET}" \
    --gateway "${GATEWAY}" \
    "${NETWORK_NAME}" >/dev/null
  bashio::log.info "Docker network '${NETWORK_NAME}' recreated"
}

ensure_connected() {
  local container="$1" current_ip connected_changed=0

  bashio::log.info "Checking '${container}' network attachment to '${NETWORK_NAME}'"
  current_ip="$(docker inspect -f "{{with index .NetworkSettings.Networks \"${NETWORK_NAME}\"}}{{.IPAddress}}{{end}}" "${container}" 2>/dev/null || true)"

  if [ -z "${current_ip}" ]; then
    bashio::log.info "Connecting '${container}' to '${NETWORK_NAME}' with IP ${OPENCCU_IP}"
    docker network connect --ip "${OPENCCU_IP}" "${NETWORK_NAME}" "${container}"
    connected_changed=1
  elif [ "${current_ip}" != "${OPENCCU_IP}" ]; then
    bashio::log.info "Reconnecting '${container}' to '${NETWORK_NAME}' with corrected IP ${OPENCCU_IP} (was ${current_ip})"
    docker network disconnect "${NETWORK_NAME}" "${container}" >/dev/null 2>&1 || true
    docker network connect --ip "${OPENCCU_IP}" "${NETWORK_NAME}" "${container}"
    connected_changed=1
  else
    bashio::log.info "Container already connected with expected IP ${OPENCCU_IP}"
  fi

  if [ "${connected_changed}" -eq 1 ] && [ "${RECONNECT}" = "true" ]; then
    bashio::log.info "Restarting '${container}' (reconnect_container=true)"
    docker restart --time 120 "${container}" >/dev/null
    bashio::log.info "Container '${container}' restarted"
  fi
}

setup_container_routes() {
  local container="$1" macvlan_iface=""

  bashio::log.info "Determining macvlan interface inside '${container}' for IP ${OPENCCU_IP}"
  for _ in $(seq 1 30); do
    macvlan_iface="$(docker exec "${container}" sh -c \
      "ip -o -f inet addr show | awk -v ip='${OPENCCU_IP}' '{split(\\\$4,a,\"/\"); if (a[1] == ip) {print \\\$2; exit}}'")"
    if [ -n "${macvlan_iface}" ]; then
      break
    fi
    sleep 1
  done

  if [ -z "${macvlan_iface}" ]; then
    bashio::log.error "Could not determine macvlan interface for ${OPENCCU_IP} inside '${container}'."
    exit 1
  fi
  bashio::log.info "Detected macvlan interface: ${macvlan_iface}"

  bashio::log.info "Applying multicast route in '${container}': 224.0.0.0/24 dev ${macvlan_iface} scope link"
  docker exec "${container}" ip route replace 224.0.0.0/24 dev "${macvlan_iface}" scope link

  bashio::log.info "Applying default route in '${container}': default via ${GATEWAY}"
  docker exec "${container}" ip route replace default via "${GATEWAY}"
}

bashio::log.info "Starting OpenCCU HAP/DRAP helper (network=${NETWORK_NAME}, interval=${CHECK_INTERVAL}s, reconnect=${RECONNECT})"
validate_required_config
resolve_parent_interface
resolve_subnet
resolve_gateway

while true; do
  bashio::log.info "Polling for OpenCCU add-on container (slug=${OPENCCU_SLUG})"
  CONTAINER="$(find_openccu_container || true)"
  if [ -z "${CONTAINER}" ]; then
    bashio::log.warning "OpenCCU add-on container not running/found."
    sleep "${CHECK_INTERVAL}"
    continue
  fi

  bashio::log.info "OpenCCU container detected: ${CONTAINER}"
  resolve_openccu_ip "${CONTAINER}"
  ensure_network "${CONTAINER}"
  ensure_connected "${CONTAINER}"
  setup_container_routes "${CONTAINER}"
  bashio::log.info "Cycle completed successfully for '${CONTAINER}'"
  sleep "${CHECK_INTERVAL}"
done
