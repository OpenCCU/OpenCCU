#!/bin/bash
set -e

PACKAGE_NAME="java-azul"
DOWNLOAD_URL="https://cdn.azul.com"
API_URL="https://api.azul.com/metadata/v1/zulu/packages"
JAVA_MAJOR_VERSION="21"

function resolve_latest_java_azul_v21() {
  local arch_query=${1}
  local archive_arch=${2}

  curl -fsSL "${API_URL}/?java_version=${JAVA_MAJOR_VERSION}&os=linux&archive_type=tar.gz&java_package_type=jre&latest=true&release_status=ga&availability_types=CA&arch=${arch_query}" \
    | sed -nE "s/.*\"name\":\"zulu([^\"]+)-linux_${archive_arch}\\.tar\\.gz\".*/\\1/p" \
    | head -n1
}

function resolve_latest_java_azul_version() {
  local x64_version
  local aarch64_version

  x64_version=$(resolve_latest_java_azul_v21 "x86_64" "x64")
  aarch64_version=$(resolve_latest_java_azul_v21 "aarch64" "aarch64")

  if [[ -z "${x64_version}" || -z "${aarch64_version}" ]]; then
    echo "Failed to resolve latest Azul Java ${JAVA_MAJOR_VERSION} version from ${API_URL}" >&2
    exit 1
  fi

  if [[ "${x64_version}" == "${aarch64_version}" ]]; then
    echo "${x64_version}"
    return 0
  fi

  for candidate in "${x64_version}" "${aarch64_version}"; do
    if wget --spider -q "${DOWNLOAD_URL}/zulu/bin/zulu${candidate}-linux_x64.tar.gz" \
      && wget --spider -q "${DOWNLOAD_URL}/zulu/bin/zulu${candidate}-linux_aarch64.tar.gz"; then
      echo "${candidate}"
      return 0
    fi
  done

  echo "Resolved different Azul Java ${JAVA_MAJOR_VERSION} versions for x64 (${x64_version}) and aarch64 (${aarch64_version}) with no common downloadable version" >&2
  exit 1
}

ID=${1:-$(resolve_latest_java_azul_version)}

# function to download archive hash for certain CPU
function updateHash() {
  local type=${1}
  local cpu=${2}

  # define project+archive url
  PROJECT_URL="${DOWNLOAD_URL}/${type}/bin"
  ARCHIVE_URL="${PROJECT_URL}/zulu${ID}-linux_CPU.tar.gz"

  # download archive for hash update
  ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL/CPU/${cpu}}" | sha256sum | awk '{ print $1 }')
  if [[ -n "${ARCHIVE_HASH}" ]]; then
    sed -i "/_${cpu}\.tar.gz/d" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
    echo "sha256  ${ARCHIVE_HASH}  zulu${ID}-linux_${cpu}.tar.gz" >>"buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.hash"
  fi
}

# update package info
BR_PACKAGE_NAME=${PACKAGE_NAME^^}
BR_PACKAGE_NAME=${BR_PACKAGE_NAME//-/_}
sed -i "s/${BR_PACKAGE_NAME}_VERSION = .*/${BR_PACKAGE_NAME}_VERSION = ${ID}/g" "buildroot-external/package/${PACKAGE_NAME}/${PACKAGE_NAME}.mk"

# update package hashes
updateHash zulu x64
updateHash zulu aarch64
