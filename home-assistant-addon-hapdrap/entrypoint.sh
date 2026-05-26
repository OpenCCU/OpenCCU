#!/usr/bin/with-contenv bashio
# shellcheck disable=SC1008
set -euo pipefail

OPENCCU_SLUG="$(bashio::config 'openccu_slug')"
NETWORK_NAME="$(bashio::config 'network_name')"
PARENT_IF="$(bashio::config 'parent_interface')"
SUBNET="$(bashio::config 'subnet')"
GATEWAY="$(bashio::config 'gateway')"
OPENCCU_IP="$(bashio::config 'openccu_ip')"
OPENCCU_MAC="$(bashio::config 'openccu_mac')"
CHECK_INTERVAL="$(bashio::config 'check_interval')"
DOCKER_API_BASE=""

check_protection_mode() {
  local protection_mode="" supervisor_protection_mode="" key

  if [ ! -r /data/options.json ]; then
    bashio::log.error "Cannot read /data/options.json. Add-on options are not accessible."
    exit 1
  fi

  for key in openccu_ip check_interval; do
    if ! jq -e "has(\"${key}\")" /data/options.json >/dev/null 2>&1; then
      bashio::log.error "Missing required key '${key}' in /data/options.json. Check app config.yaml options/schema."
      exit 1
    fi
  done

  protection_mode="$(jq -r '.protection_mode // empty' /data/options.json 2>/dev/null || true)"

  if [ "${protection_mode}" = "true" ]; then
    bashio::log.error "Home Assistant protection mode is enabled for this app."
    bashio::log.error "Disable protection mode in the app configuration and start the app again."
    exit 1
  fi

  if [ -n "${protection_mode}" ]; then
    bashio::log.info "Protection mode check passed (disabled)."
    return 0
  fi

  if [ -n "${SUPERVISOR_TOKEN:-}" ]; then
    supervisor_protection_mode="$(curl -fsSL \
      -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
      -H "Content-Type: application/json" \
      http://supervisor/addons/self/info 2>/dev/null \
      | jq -r '.data.protected // .data.protection_mode // .data.options.protection_mode // empty' 2>/dev/null || true)"
  fi

  if [ "${supervisor_protection_mode}" = "true" ]; then
    bashio::log.error "Home Assistant protection mode is enabled for this app."
    bashio::log.error "Disable protection mode in the app configuration and start the app again."
    exit 1
  fi

  bashio::log.info "Protection mode check passed (disabled)."
}

validate_required_config() {
  if [ -z "${OPENCCU_SLUG}" ]; then
    bashio::log.info "Using 'openccu' as default OpenCCU App slug name."
    OPENCCU_SLUG="openccu"
  fi
  if [ -z "${NETWORK_NAME}" ]; then
    bashio::log.info "Using 'ccu' as default OpenCCU docker network."
    NETWORK_NAME="ccu"
  fi
}

normalize_mac() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

validate_mac() {
  [[ "$(normalize_mac "$1")" =~ ^([0-9a-f]{2}:){5}[0-9a-f]{2}$ ]]
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
  PARENT_IF="$(ip -o -f inet route 2>/dev/null | awk '/^default/ {print $5; exit}' || true)"
  if [ -z "${PARENT_IF}" ]; then
    bashio::log.error "Could not detect parent interface. Please set 'parent_interface'."
    exit 1
  fi
  bashio::log.info "Detected parent interface: ${PARENT_IF}"
}

resolve_openccu_mac() {
  local parent_mac="" mac_derivation_seed="" b0="" b1="" b2="" b3="" b4="" b5=""

  if [ -n "${OPENCCU_MAC}" ]; then
    OPENCCU_MAC="$(normalize_mac "${OPENCCU_MAC}")"
    if ! validate_mac "${OPENCCU_MAC}"; then
      bashio::log.error "Configured OpenCCU MAC '${OPENCCU_MAC}' is invalid. Please use the format '02:11:22:33:44:55'."
      exit 1
    fi
    bashio::log.info "Using configured OpenCCU MAC: ${OPENCCU_MAC}"
    return 0
  fi

  parent_mac="$(ip link show dev "${PARENT_IF}" 2>/dev/null | awk '/link\/ether/ {print $2; exit}' || true)"
  if [ -z "${parent_mac}" ]; then
    bashio::log.error "Could not detect MAC address of parent interface ${PARENT_IF}. Please set 'openccu_mac'."
    exit 1
  fi

  parent_mac="$(normalize_mac "${parent_mac}")"
  if ! validate_mac "${parent_mac}"; then
    bashio::log.error "Detected invalid MAC address '${parent_mac}' on parent interface ${PARENT_IF}. Please set 'openccu_mac'."
    exit 1
  fi

  IFS=: read -r b0 b1 b2 b3 b4 b5 <<<"${parent_mac}"
  # Convert the first octet into a locally administered unicast MAC prefix.
  b0=$(( (16#${b0} | 0x02) & 0xFE ))
  b1=$((16#${b1}))
  b2=$((16#${b2}))
  b3=$((16#${b3}))
  b4=$((16#${b4}))
  b5=$((16#${b5}))
  mac_derivation_seed="$(printf '%s' "${parent_mac}|${NETWORK_NAME}|${OPENCCU_SLUG}" | cksum | awk '{print $1}')"
  # Keep the last octet different from the parent MAC by adding 1..253.
  b5=$(( (b5 + (mac_derivation_seed % 253) + 1) & 0xFF ))
  OPENCCU_MAC="$(printf '%02x:%02x:%02x:%02x:%02x:%02x' "${b0}" "${b1}" "${b2}" "${b3}" "${b4}" "${b5}")"
  bashio::log.info "Derived OpenCCU MAC ${OPENCCU_MAC} from parent interface ${PARENT_IF} (${parent_mac})"
}

resolve_subnet() {
  if [ -n "${SUBNET}" ]; then
    bashio::log.info "Using configured subnet: ${SUBNET}"
    return 0
  fi

  bashio::log.info "Detecting subnet on parent interface ${PARENT_IF}"
  local iface_cidr
  iface_cidr="$(ip -o -f inet addr show dev "${PARENT_IF}" 2>/dev/null | awk '/scope global/ {print $4; exit}' || true)"
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
  GATEWAY="$(ip route list dev "${PARENT_IF}" 2>/dev/null | awk '/^default/ {print $3; exit}' || true)"
  if [ -z "${GATEWAY}" ]; then
    GATEWAY="$(ip -o -f inet route 2>/dev/null | awk '/^default/ {print $3; exit}' || true)"
  fi
  if [ -z "${GATEWAY}" ]; then
    bashio::log.error "Could not detect gateway. Please set 'gateway'."
    exit 1
  fi
  bashio::log.info "Detected gateway: ${GATEWAY}"
}

resolve_docker_api_base() {
  local api_version=""

  api_version="$(docker version --format '{{.Server.APIVersion}}' 2>/dev/null || true)"
  if [ -z "${api_version}" ]; then
    bashio::log.error "Could not determine Docker API version."
    exit 1
  fi

  DOCKER_API_BASE="http://localhost/v${api_version}"
  bashio::log.info "Using Docker API ${api_version}"
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
    bashio::log.info "Detected OpenCCU IP from docker network '${NETWORK_NAME}: ${OPENCCU_IP}"
    return 0
  fi

  bashio::log.error "No OpenCCU IP configured and no existing '${NETWORK_NAME}' network IP detected."
  bashio::log.error "Set 'openccu_ip' to a free LAN IP and restart this helper."
  exit 1
}

ensure_network() {
  local container="${1:-}"
  local inspect_output existing_driver existing_parent existing_subnet existing_gateway
  local create_output create_status

  bashio::log.info "Inspecting docker network '${NETWORK_NAME}'"
  inspect_output="$(docker network inspect "${NETWORK_NAME}" \
    --format '{{.Driver}}|{{index .Options "parent"}}|{{(index .IPAM.Config 0).Subnet}}|{{(index .IPAM.Config 0).Gateway}}' \
    2>/dev/null || true)"

  if [ -z "${inspect_output}" ]; then
    bashio::log.info "Creating docker macvlan network '${NETWORK_NAME}'"
    set +e
    create_output="$(docker network create -d macvlan \
      --opt parent="${PARENT_IF}" \
      --subnet "${SUBNET}" \
      --gateway "${GATEWAY}" \
      "${NETWORK_NAME}" 2>&1)"
    create_status=$?
    set -e
    if [ "${create_status}" -ne 0 ]; then
      if echo "${create_output}" | grep -Fq "invalid pool request: Pool overlaps with other one on this address space"; then
        bashio::log.error "Cannot create docker network '${NETWORK_NAME}': subnet '${SUBNET}' overlaps with an existing docker network."
        bashio::log.error "Remove the conflicting network, then this helper will retry automatically."
        bashio::log.error "Hint: use 'docker network ls' and 'docker network inspect <network>' to identify it."
        bashio::log.error "Hint: remove it with 'docker network rm <network>' (only if that network is not needed)."
      else
        bashio::log.error "Failed to create docker network '${NETWORK_NAME}': ${create_output}"
      fi
      return 1
    fi
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
  if ! docker network rm "${NETWORK_NAME}" >/dev/null 2>&1; then
    bashio::log.warning "Failed to remove docker network '${NETWORK_NAME}'; will retry next cycle."
    return 1
  fi
  set +e
  create_output="$(docker network create -d macvlan \
    --opt parent="${PARENT_IF}" \
    --subnet "${SUBNET}" \
    --gateway "${GATEWAY}" \
    "${NETWORK_NAME}" 2>&1)"
  create_status=$?
  set -e
  if [ "${create_status}" -ne 0 ]; then
    if echo "${create_output}" | grep -Fq "invalid pool request: Pool overlaps with other one on this address space"; then
      bashio::log.error "Cannot recreate docker network '${NETWORK_NAME}': subnet '${SUBNET}' overlaps with an existing docker network."
      bashio::log.error "Remove the conflicting network, then this helper will retry automatically."
      bashio::log.error "Hint: use 'docker network ls' and 'docker network inspect <network>' to identify it."
      bashio::log.error "Hint: remove it with 'docker network rm <network>' (only if that network is not needed)."
    else
      bashio::log.error "Failed to recreate docker network '${NETWORK_NAME}': ${create_output}"
    fi
    return 1
  fi
  bashio::log.info "Docker network '${NETWORK_NAME}' recreated"
}

ensure_connected() {
  local container="$1" current_ip="" current_mac="" connect_payload="" connect_output="" connect_response="" connect_status="" connect_error=""

  bashio::log.info "Checking '${container}' network attachment to '${NETWORK_NAME}'"
  IFS='|' read -r current_ip current_mac <<<"$(docker inspect -f "{{with index .NetworkSettings.Networks \"${NETWORK_NAME}\"}}{{.IPAddress}}|{{.MacAddress}}{{end}}" "${container}" 2>/dev/null || true)"
  current_mac="$(normalize_mac "${current_mac}")"

  if [ -z "${current_ip}" ]; then
    bashio::log.info "Connecting '${container}' to '${NETWORK_NAME}' with IP ${OPENCCU_IP} and MAC ${OPENCCU_MAC}"
  elif [ "${current_ip}" != "${OPENCCU_IP}" ] || [ "${current_mac}" != "${OPENCCU_MAC}" ]; then
    bashio::log.info "Reconnecting '${container}' to '${NETWORK_NAME}' with corrected IP ${OPENCCU_IP} and MAC ${OPENCCU_MAC} (was ${current_ip}/${current_mac:-unknown})"
    docker network disconnect "${NETWORK_NAME}" "${container}" >/dev/null 2>&1 || true
  else
    bashio::log.info "Container already connected with expected IP ${OPENCCU_IP} and MAC ${OPENCCU_MAC}"
    return 0
  fi

  connect_payload="$(jq -cn \
    --arg container "${container}" \
    --arg ip "${OPENCCU_IP}" \
    --arg mac "${OPENCCU_MAC}" \
    '{Container:$container, EndpointConfig:{IPAMConfig:{IPv4Address:$ip}, MacAddress:$mac}}')"
  set +e
  connect_response="$(curl -sS -w '\nHTTPSTATUS:%{http_code}' \
    --unix-socket /var/run/docker.sock \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "${connect_payload}" \
    "${DOCKER_API_BASE}/networks/${NETWORK_NAME}/connect" 2>&1)"
  set -e
  connect_status="${connect_response##*HTTPSTATUS:}"
  connect_output="${connect_response%$'\n'HTTPSTATUS:*}"
  if [ "${connect_status}" != "200" ]; then
    connect_error="$(printf '%s' "${connect_output}" | jq -r '.message // empty' 2>/dev/null || true)"
    if [ -z "${connect_error}" ]; then
      connect_error="${connect_output}"
    fi
    bashio::log.error "Failed to connect '${container}' to '${NETWORK_NAME}' with IP ${OPENCCU_IP} and MAC ${OPENCCU_MAC}: HTTP ${connect_status} ${connect_error}"
    bashio::log.error "Check whether the MAC address is already in use and whether the Docker network '${NETWORK_NAME}' still exists."
    exit 1
  fi
}

setup_container_routes() {
  local container="$1" macvlan_iface="" current_multicast_route="" current_default_route=""

  bashio::log.info "Determining macvlan interface inside '${container}' for IP ${OPENCCU_IP}"
  for _ in $(seq 1 30); do
    macvlan_iface="$(docker exec "${container}" ip -o -f inet addr show 2>/dev/null \
      | awk -v ip="${OPENCCU_IP}" '{split($4,a,"/"); if (a[1] == ip) {print $2; exit}}' || true)"
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

  current_multicast_route="$(docker exec "${container}" ip -o route show 224.0.0.0/24 2>/dev/null | head -n1 || true)"
  if echo "${current_multicast_route}" | grep -Eq "^224\.0\.0\.0/24 dev ${macvlan_iface}( |$).*scope link( |$)"; then
    bashio::log.info "Multicast route already set in '${container}': 224.0.0.0/24 dev ${macvlan_iface} scope link"
  else
    bashio::log.info "Applying multicast route in '${container}': 224.0.0.0/24 dev ${macvlan_iface} scope link"
    docker exec "${container}" ip route replace 224.0.0.0/24 dev "${macvlan_iface}" scope link
  fi

  current_default_route="$(docker exec "${container}" ip -o route show default 2>/dev/null | head -n1 || true)"
  if echo "${current_default_route}" | grep -Eq "^default via ${GATEWAY}( |$)"; then
    bashio::log.info "Default route already set in '${container}': default via ${GATEWAY}"
  else
    bashio::log.info "Applying default route in '${container}': default via ${GATEWAY}"
    docker exec "${container}" ip route replace default via "${GATEWAY}"
  fi
}

bashio::log.info "Starting OpenCCU HAP/DRAP helper (openccu_ip=${OPENCCU_IP}, openccu_mac=${OPENCCU_MAC:-auto}, interval=${CHECK_INTERVAL}s)"
check_protection_mode
validate_required_config
resolve_parent_interface
resolve_subnet
resolve_gateway
resolve_openccu_mac
resolve_docker_api_base

while true; do
  bashio::log.info "==================================================="
  bashio::log.info "Polling for OpenCCU app container (slug=${OPENCCU_SLUG})"
  CONTAINER="$(find_openccu_container || true)"
  if [ -z "${CONTAINER}" ]; then
    bashio::log.warning "OpenCCU app container not running/found."
    sleep "${CHECK_INTERVAL}"
    continue
  fi

  bashio::log.info "OpenCCU container detected: ${CONTAINER}"
  resolve_openccu_ip "${CONTAINER}"
  if ! ensure_network "${CONTAINER}"; then
    bashio::log.warning "Skipping this cycle due to docker network setup failure; retrying in ${CHECK_INTERVAL}s."
    sleep "${CHECK_INTERVAL}"
    continue
  fi
  ensure_connected "${CONTAINER}"
  setup_container_routes "${CONTAINER}"
  bashio::log.info "Cycle completed successfully for '${CONTAINER}'"
  sleep "${CHECK_INTERVAL}"
done
