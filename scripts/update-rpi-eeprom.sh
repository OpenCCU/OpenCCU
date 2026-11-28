#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

# Resolve the real directory behind the "stable" symlink of a SoC, e.g.
# firmware-2711/latest. The package downloads single files from
# raw.githubusercontent.com, which does not resolve symlinks.
function resolve_stable_rpi_eeprom_dir() {
  local source_dir=${1}
  local firmware_dir=${2}

  realpath --relative-to="${source_dir}" "${source_dir}/${firmware_dir}/stable"
}

# Find the newest image matching a pattern (e.g. pieeprom-*.bin) in a directory.
function resolve_latest_rpi_eeprom_image() {
  local source_dir=${1}
  local image_dir=${2}
  local pattern=${3}

  find "${source_dir}/${image_dir}" -maxdepth 1 -type f -name "${pattern}" -printf '%f\n' | sort -V | tail -n1
}

function rpi_eeprom_file_hash() {
  sha256sum "${1}" | awk '{ print $1 }'
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
PACKAGE_DIR="buildroot-external/package/${PACKAGE_NAME}"
PACKAGE_MK="${PACKAGE_DIR}/${PACKAGE_NAME}.mk"
CURRENT_ID=$(sed -nE 's/^RPI_EEPROM_VERSION = (.*)$/\1/p' "${PACKAGE_MK}" | head -n1)
BR_PACKAGE_NAME=${PACKAGE_NAME^^}
BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
CURRENT_RPI4_FIRMWARE_PATH=$(sed -nE "s#^[[:space:]]*${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2711/[^/]+/(pieeprom-[0-9]{4}-[0-9]{2}-[0-9]{2}\\.bin)\$#\\1#p" "${PACKAGE_MK}" | head -n1)
CURRENT_RPI5_FIRMWARE_PATH=$(sed -nE "s#^[[:space:]]*${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2712/[^/]+/(pieeprom-[0-9]{4}-[0-9]{2}-[0-9]{2}\\.bin)\$#\\1#p" "${PACKAGE_MK}" | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "${PACKAGE_NAME}"
fi

# The package only downloads single files, but the whole archive is needed
# here to resolve the stable firmware images of the new revision.
WORK_DIR=$(mktemp -d)
trap 'rm -rf "${WORK_DIR}"' EXIT
ARCHIVE_TMP="${WORK_DIR}/${PACKAGE_NAME}.tar.gz"
SOURCE_DIR="${WORK_DIR}/src"

if ! wget -nd -t 3 -O "${ARCHIVE_TMP}" "${ARCHIVE_URL}"; then
  echo "Failed to download archive for ${PACKAGE_NAME}" >&2
  exit 1
fi
mkdir -p "${SOURCE_DIR}"
tar -xzf "${ARCHIVE_TMP}" -C "${SOURCE_DIR}" --strip-components=1

RPI4_DIR=$(resolve_stable_rpi_eeprom_dir "${SOURCE_DIR}" "firmware-2711")
RPI5_DIR=$(resolve_stable_rpi_eeprom_dir "${SOURCE_DIR}" "firmware-2712")

if [[ -z "${RPI4_FIRMWARE_PATH}" ]]; then
  RPI4_FIRMWARE_PATH=$(resolve_latest_rpi_eeprom_image "${SOURCE_DIR}" "${RPI4_DIR}" "pieeprom-*.bin")
fi

if [[ -z "${RPI5_FIRMWARE_PATH}" ]]; then
  RPI5_FIRMWARE_PATH=$(resolve_latest_rpi_eeprom_image "${SOURCE_DIR}" "${RPI5_DIR}" "pieeprom-*.bin")
fi

RPI4_VL805_PATH=$(resolve_latest_rpi_eeprom_image "${SOURCE_DIR}" "${RPI4_DIR}" "vl805-*.bin")

if [[ -z "${RPI4_FIRMWARE_PATH}" || -z "${RPI5_FIRMWARE_PATH}" || -z "${RPI4_VL805_PATH}" ]]; then
  echo "Failed to resolve the firmware images in archive for ${PACKAGE_NAME}" >&2
  exit 1
fi

for file in \
  "${RPI4_DIR}/${RPI4_FIRMWARE_PATH}" \
  "${RPI4_DIR}/recovery.bin" \
  "${RPI4_DIR}/${RPI4_VL805_PATH}" \
  "${RPI5_DIR}/${RPI5_FIRMWARE_PATH}" \
  "${RPI5_DIR}/recovery.bin"; do
  if [[ ! -f "${SOURCE_DIR}/${file}" ]]; then
    echo "Failed to find ${file} in archive for ${PACKAGE_NAME}" >&2
    exit 1
  fi
done

if [[ -n "${CURRENT_RPI4_FIRMWARE_PATH}" && -n "${CURRENT_RPI5_FIRMWARE_PATH}" \
  && "${RPI4_FIRMWARE_PATH}" == "${CURRENT_RPI4_FIRMWARE_PATH}" \
  && "${RPI5_FIRMWARE_PATH}" == "${CURRENT_RPI5_FIRMWARE_PATH}" ]]; then
  echo "${PACKAGE_NAME}: pieeprom firmware unchanged (rpi4=${RPI4_FIRMWARE_PATH}, rpi5=${RPI5_FIRMWARE_PATH}), skipping version/hash update"
  exit 0
fi

# update package info
sed -i "s/^${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "${PACKAGE_MK}"
sed -Ei "s#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2711/.*#${BR_PACKAGE_NAME}_FIRMWARE_PATH = ${RPI4_DIR}/${RPI4_FIRMWARE_PATH}#g" "${PACKAGE_MK}"
sed -Ei "s#${BR_PACKAGE_NAME}_RECOVERY_PATH = firmware-2711/.*#${BR_PACKAGE_NAME}_RECOVERY_PATH = ${RPI4_DIR}/recovery.bin#g" "${PACKAGE_MK}"
sed -Ei "s#${BR_PACKAGE_NAME}_VL805_PATH = firmware-2711/.*#${BR_PACKAGE_NAME}_VL805_PATH = ${RPI4_DIR}/${RPI4_VL805_PATH}#g" "${PACKAGE_MK}"
sed -Ei "s#${BR_PACKAGE_NAME}_FIRMWARE_PATH = firmware-2712/.*#${BR_PACKAGE_NAME}_FIRMWARE_PATH = ${RPI5_DIR}/${RPI5_FIRMWARE_PATH}#g" "${PACKAGE_MK}"
sed -Ei "s#${BR_PACKAGE_NAME}_RECOVERY_PATH = firmware-2712/.*#${BR_PACKAGE_NAME}_RECOVERY_PATH = ${RPI5_DIR}/recovery.bin#g" "${PACKAGE_MK}"

# update package hashes: one file for the common files and one per SoC,
# because the firmware images of both SoCs share their file names
cat >"${PACKAGE_DIR}/${PACKAGE_NAME}.hash" <<EOF
# Locally computed
sha256  $(rpi_eeprom_file_hash "${SOURCE_DIR}/LICENSE")  LICENSE
sha256  $(rpi_eeprom_file_hash "${SOURCE_DIR}/rpi-eeprom-config")  rpi-eeprom-config
sha256  $(rpi_eeprom_file_hash "${SOURCE_DIR}/rpi-eeprom-digest")  rpi-eeprom-digest
EOF
cat >"${PACKAGE_DIR}/${PACKAGE_NAME}-2711.hash" <<EOF
# Locally computed
sha256  $(rpi_eeprom_file_hash "${SOURCE_DIR}/${RPI4_DIR}/${RPI4_FIRMWARE_PATH}")  ${RPI4_FIRMWARE_PATH}
sha256  $(rpi_eeprom_file_hash "${SOURCE_DIR}/${RPI4_DIR}/recovery.bin")  recovery.bin
sha256  $(rpi_eeprom_file_hash "${SOURCE_DIR}/${RPI4_DIR}/${RPI4_VL805_PATH}")  ${RPI4_VL805_PATH}
EOF
cat >"${PACKAGE_DIR}/${PACKAGE_NAME}-2712.hash" <<EOF
# Locally computed
sha256  $(rpi_eeprom_file_hash "${SOURCE_DIR}/${RPI5_DIR}/${RPI5_FIRMWARE_PATH}")  ${RPI5_FIRMWARE_PATH}
sha256  $(rpi_eeprom_file_hash "${SOURCE_DIR}/${RPI5_DIR}/recovery.bin")  recovery.bin
EOF

# report firmware versions to the dependency update workflow
report_update_version_label "$(rpi_eeprom_version_label "${RPI4_FIRMWARE_PATH}" "${RPI5_FIRMWARE_PATH}" "${CURRENT_RPI4_FIRMWARE_PATH}" "${CURRENT_RPI5_FIRMWARE_PATH}")"
report_update_details "$(cat <<EOF
- Changes........: ${PROJECT_URL}/compare/${CURRENT_ID:0:7}...${ID:0:7}
- RPi4 pieeprom..: \`${CURRENT_RPI4_FIRMWARE_PATH:-n/a}\` → \`${RPI4_FIRMWARE_PATH}\`
- RPi5 pieeprom..: \`${CURRENT_RPI5_FIRMWARE_PATH:-n/a}\` → \`${RPI5_FIRMWARE_PATH}\`
EOF
)"
