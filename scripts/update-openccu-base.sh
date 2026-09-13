#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

PACKAGE_NAME="openccu-base"
CURRENT_ID=$(sed -nE 's/^OPENCCU_BASE_VERSION = (.*)$/\1/p' "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

function pin_type() {
  local id="${1}"
  if [[ "${id}" =~ ^[0-9a-f]{40}$ ]]; then
    echo "commit"
    return
  fi
  if [[ "${id}" =~ ^[vV]?[0-9]+(\.[0-9]+)*$ ]]; then
    echo "release"
    return
  fi
  echo "unknown"
}

CURRENT_PIN_TYPE=$(pin_type "${CURRENT_ID}")
if [[ "${CURRENT_PIN_TYPE}" == "unknown" ]]; then
  echo "Unsupported ${PACKAGE_NAME} pin format '${CURRENT_ID}'. Expected release version or 40-char commit SHA." >&2
  exit 1
fi

if [[ -n "${1}" ]]; then
  ID=${1}
else
  if [[ "${CURRENT_PIN_TYPE}" == "commit" ]]; then
    ID=$(resolve_latest_github_head_commit "OpenCCU" "OpenCCU-Base")
  else
    ID=$(strip_v_prefix "$(resolve_latest_github_stable_release_tag "OpenCCU" "OpenCCU-Base")")
  fi
fi

if [[ -z "${1}" ]]; then
  RESOLVED_PIN_TYPE=$(pin_type "${ID}")
  if [[ "${RESOLVED_PIN_TYPE}" != "${CURRENT_PIN_TYPE}" ]]; then
    echo "Refusing to switch ${PACKAGE_NAME} pin type automatically (${CURRENT_PIN_TYPE} -> ${RESOLVED_PIN_TYPE}). Use an explicit script argument to override." >&2
    exit 1
  fi

  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "${PACKAGE_NAME}"
fi

sed -i "s/^OPENCCU_BASE_VERSION = .*/OPENCCU_BASE_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
