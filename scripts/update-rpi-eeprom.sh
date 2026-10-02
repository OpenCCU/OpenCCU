#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

function resolve_stable_rpi_eeprom_firmware() {
  local archive_file=${1}
  local firmware_dir=${2}
  local firmware_name

  firmware_name=$(tar -tf "${archive_file}" | sed -nE "s#^.*/${firmware_dir}/(stable|latest)/(pieeprom-[0-9]{4}-[0-9]{2}-[0-9]{2}\\.bin)\$#\\2#p" | sort -V | tail -n1)
  echo "${firmware_name}"
}

# Build a human readable version label from the release dates of the changed
# pieeprom firmware images, e.g. "2026-10-01 (RPi5)" or
# "2026-09-23 (RPi4), 2026-10-01 (RPi5)".
function rpi_eeprom_version_label() {
  local rpi4_firmware=${1}
  local rpi5_firmware=${2}
  local current_rpi4_firmware=${3}
  local current_rpi5_firmware=${4}
  local rpi4_date rpi5_date
  local rpi4_changed=false
  local rpi5_changed=false

  rpi4_date=$(sed -nE 's/^pieeprom-(.*)\.bin$/\1/p' <<<"${rpi4_firmware}")
  rpi5_date=$(sed -nE 's/^pieeprom-(.*)\.bin$/\1/p' <<<"${rpi5_firmware}")

  if [[ -n "${rpi4_date}" && "${rpi4_firmware}" != "${current_rpi4_firmware}" ]]; then
    rpi4_changed=true
  fi
  if [[ -n "${rpi5_date}" && "${rpi5_firmware}" != "${current_rpi5_firmware}" ]]; then
    rpi5_changed=true
  fi
  if [[ "${rpi4_changed}" == "false" && "${rpi5_changed}" == "false" ]]; then
    # no firmware image changed (e.g. explicit commit update), list all known ones
    if [[ -n "${rpi4_date}" ]]; then
      rpi4_changed=true
    fi
    if [[ -n "${rpi5_date}" ]]; then
      rpi5_changed=true
    fi
  fi

  if [[ "${rpi4_changed}" == "true" && "${rpi5_changed}" == "true" ]]; then
    if [[ "${rpi4_date}" == "${rpi5_date}" ]]; then
      echo "${rpi4_date} (RPi4, RPi5)"
    else
      echo "${rpi4_date} (RPi4), ${rpi5_date} (RPi5)"
    fi
  elif [[ "${rpi4_changed}" == "true" ]]; then
    echo "${rpi4_date} (RPi4)"
  elif [[ "${rpi5_changed}" == "true" ]]; then
    echo "${rpi5_date} (RPi5)"
  fi
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
BR_PACKAGE_NAME=${PACKAGE_NAME^^}
BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
CURRENT_RPI4_FIRMWARE_PATH=$(sed -nE "s#^[[:space:]]*${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2711/(stable|latest)/(pieeprom-[0-9]{4}-[0-9]{2}-[0-9]{2}\\.bin)\$#\\2#p" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)
CURRENT_RPI5_FIRMWARE_PATH=$(sed -nE "s#^[[:space:]]*${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2712/(stable|latest)/(pieeprom-[0-9]{4}-[0-9]{2}-[0-9]{2}\\.bin)\$#\\2#p" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

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
  RPI4_FIRMWARE_PATH=$(resolve_stable_rpi_eeprom_firmware "${ARCHIVE_TMP}" "firmware-2711")
fi

if [[ -z "${RPI5_FIRMWARE_PATH}" ]]; then
  RPI5_FIRMWARE_PATH=$(resolve_stable_rpi_eeprom_firmware "${ARCHIVE_TMP}" "firmware-2712")
fi

if [[ -n "${CURRENT_RPI4_FIRMWARE_PATH}" && -n "${CURRENT_RPI5_FIRMWARE_PATH}" \
  && "${RPI4_FIRMWARE_PATH}" == "${CURRENT_RPI4_FIRMWARE_PATH}" \
  && "${RPI5_FIRMWARE_PATH}" == "${CURRENT_RPI5_FIRMWARE_PATH}" ]]; then
  echo "${PACKAGE_NAME}: pieeprom firmware unchanged (rpi4=${RPI4_FIRMWARE_PATH}, rpi5=${RPI5_FIRMWARE_PATH}), skipping version/hash update"
  exit 0
fi

ARCHIVE_HASH=$(sha256sum "${ARCHIVE_TMP}" | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  # update package info
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  if [[ -n "${RPI4_FIRMWARE_PATH}" ]]; then
    sed -Ei "s#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2711/(stable|latest)/.*#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2711/stable/${RPI4_FIRMWARE_PATH}#g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  else
    echo "No firmware image found in archive for firmware-2711, keeping existing firmware path unchanged"
  fi
  if [[ -n "${RPI5_FIRMWARE_PATH}" ]]; then
    sed -Ei "s#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2712/(stable|latest)/.*#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2712/stable/${RPI5_FIRMWARE_PATH}#g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  else
    echo "No firmware image found in archive for firmware-2712, keeping existing firmware path unchanged"
  fi
  # update package hash
  sed -i "$ d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"

  # report firmware versions to the dependency update workflow
  report_update_version_label "$(rpi_eeprom_version_label "${RPI4_FIRMWARE_PATH}" "${RPI5_FIRMWARE_PATH}" "${CURRENT_RPI4_FIRMWARE_PATH}" "${CURRENT_RPI5_FIRMWARE_PATH}")"
  report_update_details "$(cat <<EOF
- Changes........: ${PROJECT_URL}/compare/${CURRENT_ID:0:7}...${ID:0:7}
- RPi4 pieeprom..: \`${CURRENT_RPI4_FIRMWARE_PATH:-n/a}\` → \`${RPI4_FIRMWARE_PATH:-n/a}\`
- RPi5 pieeprom..: \`${CURRENT_RPI5_FIRMWARE_PATH:-n/a}\` → \`${RPI5_FIRMWARE_PATH:-n/a}\`
EOF
)"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
