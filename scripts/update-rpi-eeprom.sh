#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

function resolve_stable_rpi_eeprom_firmware() {
  local firmware_dir=${1}
  local ref=${2}
  local api_url="https://api.github.com/repos/raspberrypi/rpi-eeprom/contents/${firmware_dir}/stable?ref=${ref}"
  local api_response
  local api_body
  local http_code
  local api_message
  local firmware_name
  local -a auth_header=()

  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    auth_header=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
  elif [[ -n "${GH_TOKEN:-}" ]]; then
    auth_header=(-H "Authorization: Bearer ${GH_TOKEN}")
  fi

  api_response=$(curl -sSL "${auth_header[@]}" "${api_url}" -w $'\n%{http_code}')
  http_code=${api_response##*$'\n'}
  api_body=${api_response%$'\n'*}

  if [[ "${http_code}" != "200" ]]; then
    api_message=$(jq -r '.message // empty' <<<"${api_body}" 2>/dev/null || true)
    if [[ -n "${api_message}" ]]; then
      echo "Failed to resolve latest stable firmware for ${firmware_dir}: ${api_message} (HTTP ${http_code})" >&2
    else
      echo "Failed to resolve latest stable firmware for ${firmware_dir}: GitHub API request failed (HTTP ${http_code})" >&2
    fi
    exit 1
  fi

  if ! jq -e 'type == "array"' >/dev/null <<<"${api_body}"; then
    api_message=$(jq -r '.message // empty' <<<"${api_body}" 2>/dev/null || true)
    if [[ -n "${api_message}" ]]; then
      echo "Failed to resolve latest stable firmware for ${firmware_dir}: ${api_message}" >&2
    else
      echo "Failed to resolve latest stable firmware for ${firmware_dir}: unexpected GitHub API response" >&2
    fi
    exit 1
  fi

  firmware_name=$(jq -r '[.[] | .name | select(test("^pieeprom-[0-9]{4}-[0-9]{2}-[0-9]{2}\\.bin$"))] | sort | last // empty' <<<"${api_body}")

  if [[ -z "${firmware_name}" ]]; then
    echo "Failed to resolve latest stable firmware for ${firmware_dir}" >&2
    exit 1
  fi

  echo "${firmware_name}"
}

if [[ -n "${1}" && "${1}" =~ ^pieeprom-.*\.bin$ ]]; then
  ID=$(resolve_latest_github_head_commit "raspberrypi" "rpi-eeprom")
  RPI4_FIRMWARE_PATH=${1}
  RPI5_FIRMWARE_PATH=${1}
elif [[ -n "${2}" && "${2}" =~ ^pieeprom-.*\.bin$ ]]; then
  ID=${1}
  RPI4_FIRMWARE_PATH=${2}
  RPI5_FIRMWARE_PATH=${3:-${2}}
else
  ID=${1:-$(resolve_latest_github_head_commit "raspberrypi" "rpi-eeprom")}
fi

PACKAGE_NAME="rpi-eeprom"
PROJECT_URL="https://github.com/raspberrypi/rpi-eeprom"
ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${PACKAGE_NAME}-${ID}.tar.gz"
CURRENT_ID=$(sed -nE 's/^RPI_EEPROM_VERSION = (.*)$/\1/p' "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "${PACKAGE_NAME}"
fi

ARCHIVE_TMP=$(mktemp)
trap 'rm -f "${ARCHIVE_TMP}"' EXIT

if ! wget -nd -t 3 -O "${ARCHIVE_TMP}" "${ARCHIVE_URL}"; then
  echo "Failed to download archive for ${PACKAGE_NAME}" >&2
  exit 1
fi

if [[ -z "${RPI4_FIRMWARE_PATH}" ]]; then
  RPI4_FIRMWARE_PATH=$(resolve_stable_rpi_eeprom_firmware "firmware-2711" "${ID}")
fi

if [[ -z "${RPI5_FIRMWARE_PATH}" ]]; then
  RPI5_FIRMWARE_PATH=$(resolve_stable_rpi_eeprom_firmware "firmware-2712" "${ID}")
fi

ARCHIVE_HASH=$(sha256sum "${ARCHIVE_TMP}" | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  # update package info
  BR_PACKAGE_NAME=${PACKAGE_NAME^^}
  BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  sed -Ei "s#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2711/(stable|latest)/.*#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2711/stable/${RPI4_FIRMWARE_PATH}#g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  sed -Ei "s#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2712/(stable|latest)/.*#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2712/stable/${RPI5_FIRMWARE_PATH}#g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  # update package hash
  sed -i "$ d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
