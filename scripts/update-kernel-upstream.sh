#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

PACKAGE_NAME="linux"
PROJECT_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x"
#ARCHIVE_URL="${PROJECT_URL}/${PACKAGE_NAME}-${ID}.tar.xz"
CHECKSUM_URL="${PROJECT_URL}/sha256sums.asc"

# extract sha256 checksum
if ! wget --passive-ftp -nd -t 3 --spider "${CHECKSUM_URL}"; then
  echo "Failed to download checksum list for ${PACKAGE_NAME}" >&2
  exit 1
fi
CHECKSUM_CONTENT=$(wget --passive-ftp -nd -t 3 -O - "${CHECKSUM_URL}")
ID=${1:-$(echo "${CHECKSUM_CONTENT}" | grep -oE "${PACKAGE_NAME}-6\.12\.[0-9]+\.tar\.xz" | sed -E "s/^${PACKAGE_NAME}-//; s/\.tar\.xz$//" | sort -V | tail -n1)}
if [[ -z "${ID}" ]]; then
  echo "Failed to resolve latest ${PACKAGE_NAME} 6.12.x version from ${CHECKSUM_URL}" >&2
  exit 1
fi
ARCHIVE_HASH=$(echo "${CHECKSUM_CONTENT}" | grep "${PACKAGE_NAME}-${ID}.tar.xz" | awk '{ print $1 }')
if [[ -z "${ARCHIVE_HASH}" ]]; then
  echo "no hash found for ${PACKAGE_NAME}-${ID}.tar.xz"
  exit 1
fi

EXPECTED_HASH_LINE="sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.xz"
CURRENT_VERSION_LIST=$(grep -oE 'BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE="[^"]+"' buildroot-external/configs/{oci_*,odroid-*,ova,generic-*,tinkerboard2}.config | sed -E 's/.*"([^"]+)"/\1/' | sort -u)
if [[ $(echo "${CURRENT_VERSION_LIST}" | wc -l) -ne 1 ]]; then
  echo "${PACKAGE_NAME}: inconsistent kernel versions found across target configs, refusing to auto-update" >&2
  exit 1
fi
CURRENT_VERSION="${CURRENT_VERSION_LIST}"
HASH_LINE_COUNT=$(grep -Ec "^sha256[[:space:]]+[[:alnum:]]+[[:space:]]+${PACKAGE_NAME}-.*\\.tar\\.xz$" "buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash")
HEADERS_HASH_LINE_COUNT=$(grep -Ec "^sha256[[:space:]]+[[:alnum:]]+[[:space:]]+${PACKAGE_NAME}-.*\\.tar\\.xz$" "buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash")
if [[ "${CURRENT_VERSION}" == "${ID}" ]] \
  && grep -Fxq "${EXPECTED_HASH_LINE}" "buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash" \
  && grep -Fxq "${EXPECTED_HASH_LINE}" "buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash" \
  && [[ "${HASH_LINE_COUNT}" -eq 1 ]] \
  && [[ "${HEADERS_HASH_LINE_COUNT}" -eq 1 ]]; then
  echo "${PACKAGE_NAME}: version ${ID} is already current, no config or hash updates required"
  exit 0
fi

# update kconfig file
sed -i "s/BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=\".*\"/BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=\"${ID}\"/g" buildroot-external/configs/{oci_*,odroid-*,ova,generic-*,tinkerboard2}.config

# update hash files
sed -i "/${PACKAGE_NAME}-.*\.tar\.xz/d" "buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.xz" >>"buildroot-external/patches/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
sed -i "/${PACKAGE_NAME}-.*\.tar\.xz/d" "buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash"
echo "sha256  ${ARCHIVE_HASH}  ${PACKAGE_NAME}-${ID}.tar.xz" >>"buildroot-external/patches/${PACKAGE_NAME}-headers/${PACKAGE_NAME}-headers.hash"
