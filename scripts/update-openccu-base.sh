#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

ID=${1:-$(resolve_latest_github_head_commit "OpenCCU" "OpenCCU-Base")}
PACKAGE_NAME="openccu-base"
CURRENT_ID=$(sed -nE 's/^OPENCCU_BASE_VERSION = (.*)$/\1/p' "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "${PACKAGE_NAME}"
fi

sed -i "s/^OPENCCU_BASE_VERSION = .*/OPENCCU_BASE_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
