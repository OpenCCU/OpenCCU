#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils/utils.sh
source "${SCRIPT_DIR}/utils/utils.sh"

ID=${1:-$(strip_v_prefix "$(resolve_latest_github_stable_tag "tailscale" "tailscale" '^[vV][0-9]+(\.[0-9]+)*$')")}
PACKAGE_NAME="tailscale-bin"
PROJECT_URL="https://pkgs.tailscale.com/stable"
ARCHIVE_URL="${PROJECT_URL}/tailscale_${ID}_CPU.tgz"

# function to download archive hash for certain CPU
function updateHash() {
  local cpu=${1}
  local archive_hash
  # download archive for hash update
  archive_hash=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL/CPU/${cpu}}" | sha256sum | awk '{ print $1 }')
  if [[ -n "${archive_hash}" ]]; then
    sed -i "/_${cpu}\.tgz/d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
    echo "sha256  ${archive_hash}  tailscale_${ID}_${cpu}.tgz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  fi
}

# update package info
BR_PACKAGE_NAME=${PACKAGE_NAME^^}
BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"

# update package hashes
updateHash amd64
updateHash arm64
