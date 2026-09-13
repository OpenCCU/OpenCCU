#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

PACKAGE_NAME="daemonize"
PROJECT_URL="https://github.com/bmc/daemonize"
CURRENT_ID=$(sed -nE 's/^DAEMONIZE_VERSION = (.*)$/\1/p' "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

function pin_type() {
  local id="${1}"
  if [[ "${id}" =~ ^[0-9a-f]{40}$ ]]; then
    echo "commit"
    return
  fi
  if [[ "${id}" =~ ^release-[0-9]+(\.[0-9]+)*$ ]]; then
    echo "release"
    return
  fi
  echo "unknown"
}

CURRENT_PIN_TYPE=$(pin_type "${CURRENT_ID}")
if [[ "${CURRENT_PIN_TYPE}" == "unknown" ]]; then
  echo "Unsupported ${PACKAGE_NAME} pin format '${CURRENT_ID}'. Expected release tag or 40-char commit SHA." >&2
  exit 1
fi

if [[ -n "${1}" ]]; then
  ID=${1}
else
  if [[ "${CURRENT_PIN_TYPE}" == "commit" ]]; then
    ID=$(resolve_latest_github_head_commit "bmc" "daemonize")
  else
    ID=$(resolve_latest_github_stable_tag "bmc" "daemonize" '^release-[0-9]+(\.[0-9]+)*$')
  fi
fi

ARCHIVE_URL="${PROJECT_URL}/archive/${ID}/${PACKAGE_NAME}-${ID}.tar.gz"

if [[ -z "${1}" ]]; then
  RESOLVED_PIN_TYPE=$(pin_type "${ID}")
  if [[ "${RESOLVED_PIN_TYPE}" != "${CURRENT_PIN_TYPE}" ]]; then
    echo "Refusing to switch ${PACKAGE_NAME} pin type automatically (${CURRENT_PIN_TYPE} -> ${RESOLVED_PIN_TYPE}). Use an explicit script argument to override." >&2
    exit 1
  fi

  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "${PACKAGE_NAME}"
fi

# download archive for hash update
if ! wget --passive-ftp -nd -t 3 --spider "${ARCHIVE_URL}"; then
  echo "Failed to download archive for ${PACKAGE_NAME}" >&2
  exit 1
fi
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL}" | sha256sum | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  # update package info
  BR_PACKAGE_NAME=${PACKAGE_NAME^^}
  BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
  sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
  # update package hash
  sed -i "$ d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
else
  echo "Failed to retrieve archive hash for ${PACKAGE_NAME}" >&2
  exit 1
fi
