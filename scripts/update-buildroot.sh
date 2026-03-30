#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

ID=${1:-$(resolve_latest_github_stable_tag "buildroot" "buildroot" '^[0-9]+(\.[0-9]+)*$')}
#PACKAGE_NAME="buildroot"
PROJECT_URL="https://github.com/buildroot/buildroot"
ARCHIVE_URL="${PROJECT_URL}/archive/refs/tags/${ID}.tar.gz"
CURRENT_ID=$(sed -nE 's/^BUILDROOT_VERSION=(.*)$/\1/p' "Makefile" | head -n1)

if [[ -z "${1}" ]]; then
  exit_if_version_unchanged "${CURRENT_ID}" "${ID}" "buildroot"
fi

# download archive for hash update
if ! wget --passive-ftp -nd -t 3 --spider "${ARCHIVE_URL}"; then
  echo "Failed to download archive for buildroot" >&2
  exit 1
fi
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL}" | sha256sum | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  # update package info
  sed -i "s/BUILDROOT_VERSION=.*/BUILDROOT_VERSION=${ID}/g" "Makefile"
  # update package hash
  sed -i "s/BUILDROOT_SHA256=.*/BUILDROOT_SHA256=${ARCHIVE_HASH}/g" "Makefile"
else
  echo "Failed to retrieve archive hash for buildroot" >&2
  exit 1
fi
