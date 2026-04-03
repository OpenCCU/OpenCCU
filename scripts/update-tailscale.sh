#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

ID=${1:-$(strip_v_prefix "$(resolve_latest_github_stable_tag "tailscale" "tailscale" '^[vV][0-9]+(\.[0-9]+)*$')")}
PACKAGE_NAME="tailscale-bin"
PROJECT_URL="https://pkgs.tailscale.com/stable"
ARCHIVE_URL="${PROJECT_URL}/tailscale_${ID}_CPU.tgz"
CURRENT_ID=$(sed -nE 's/^TAILSCALE_BIN_VERSION = (.*)$/\1/p' "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk" | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "${PACKAGE_NAME}"
fi

# function to download archive hash for certain CPU
function resolve_hash() {
  local cpu=${1}
  local archive_hash
  # download archive for hash update
  if ! wget --passive-ftp -nd -t 3 --spider "${ARCHIVE_URL/CPU/${cpu}}"; then
    echo "Failed to download archive for ${PACKAGE_NAME} (${cpu})" >&2
    return 1
  fi
  archive_hash=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL/CPU/${cpu}}" | sha256sum | awk '{ print $1 }')
  if [[ -n "${archive_hash}" ]]; then
    echo "${archive_hash}"
  else
    echo "Failed to retrieve archive hash for ${PACKAGE_NAME} (${cpu})" >&2
    return 1
  fi
}

HASH_AMD64=$(resolve_hash amd64 || true)
HASH_ARM64=$(resolve_hash arm64 || true)

if [[ -z "${HASH_AMD64}" || -z "${HASH_ARM64}" ]]; then
  echo "Could not download latest tailscale archives yet for all architectures. Skipping update." >&2
  exit 0
fi

# update package hashes
sed -i "/_amd64\.tgz/d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
echo "sha256  ${HASH_AMD64}  tailscale_${ID}_amd64.tgz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
sed -i "/_arm64\.tgz/d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
echo "sha256  ${HASH_ARM64}  tailscale_${ID}_arm64.tgz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"

# update package info
BR_PACKAGE_NAME=${PACKAGE_NAME^^}
BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"
