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

ensure_network() {
  if ! docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1; then
    docker network create -d macvlan \
      --opt parent="${PARENT_IF}" \
      --subnet "${SUBNET}" \
      --gateway "${GATEWAY}" \
      "${NETWORK_NAME}"
  fi
}

find_openccu_container() {
  docker ps --format '{{.Names}}' | grep -E "^addon_.*_${OPENCCU_SLUG}$|^addon_${OPENCCU_SLUG}$" | head -n1
}

ensure_connected() {
  local container="$1"

  if docker inspect "${container}" \
    --format '{{json .NetworkSettings.Networks}}' | grep -q "\"${NETWORK_NAME}\""; then
    return 0
  fi

  docker network connect --ip "${OPENCCU_IP}" "${NETWORK_NAME}" "${container}"

  if [ "${RECONNECT}" = "true" ]; then
    docker restart --time 120 "${container}"
  fi
}

while true; do
  ensure_network

  CONTAINER="$(find_openccu_container || true)"
  if [ -n "${CONTAINER}" ]; then
    ensure_connected "${CONTAINER}"
  else
    bashio::log.warning "OpenCCU add-on container not running/found."
  fi

  sleep "${CHECK_INTERVAL}"
done
