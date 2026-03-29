#!/bin/bash
set -e

PACKAGE_NAME="java-azul"
DOWNLOAD_URL="https://cdn.azul.com"
API_URL="https://api.azul.com/metadata/v1/zulu/packages"
JAVA_MAJOR_VERSION="21"

function resolve_latest_java_azul_v21() {
  local arch_query=${1}
  local archive_arch=${2}
  local response
  local versions

  if ! response=$(curl -fsSL "${API_URL}/?java_version=${JAVA_MAJOR_VERSION}&os=linux&archive_type=tar.gz&java_package_type=jre&release_status=ga&availability_types=CA&arch=${arch_query}"); then
    echo "Failed to query Azul metadata API for Java ${JAVA_MAJOR_VERSION} (${arch_query})" >&2
    return 1
  fi

  versions=$(printf '%s\n' "${response}" \
    | sed -nE "s/.*\"name\":\"zulu([^\"]+)-linux_${archive_arch}\\.tar\\.gz\".*/\\1/p" \
    | sort -Vu)
  if [[ -z "${versions}" ]]; then
    echo "Failed to parse Azul metadata API response for Java ${JAVA_MAJOR_VERSION} (${arch_query})" >&2
    return 1
  fi

  echo "${versions}"
}

function resolve_latest_java_azul_version() {
  local x64_versions
  local aarch64_versions
  local common_version

  x64_versions=$(resolve_latest_java_azul_v21 "x86_64" "x64")
  aarch64_versions=$(resolve_latest_java_azul_v21 "aarch64" "aarch64")

  if [[ -z "${x64_versions}" || -z "${aarch64_versions}" ]]; then
    echo "Failed to resolve latest Azul Java ${JAVA_MAJOR_VERSION} version from ${API_URL}" >&2
    exit 1
  fi

  common_version=$(printf '%s\n' "${x64_versions}" \
    | grep -Fxf <(printf '%s\n' "${aarch64_versions}") \
    | sort -V \
    | tail -n1)
  if [[ -n "${common_version}" ]]; then
    echo "${common_version}"
    return 0
  fi

  for candidate in $(printf '%s\n%s\n' "${x64_versions}" "${aarch64_versions}" | sort -Vru); do
    if wget --spider -q -t 2 -T 30 "${DOWNLOAD_URL}/zulu/bin/zulu${candidate}-linux_x64.tar.gz" \
      && wget --spider -q -t 2 -T 30 "${DOWNLOAD_URL}/zulu/bin/zulu${candidate}-linux_aarch64.tar.gz"; then
      echo "${candidate}"
      return 0
    fi
  done

  echo "Resolved different Azul Java ${JAVA_MAJOR_VERSION} version sets for x64 and aarch64 with no common downloadable version" >&2
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
