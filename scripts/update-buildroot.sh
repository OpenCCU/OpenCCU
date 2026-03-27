#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/utils.sh"

ID=${1:-$(resolve_latest_github_stable_tag "buildroot" "buildroot")}
#PACKAGE_NAME="buildroot"
PROJECT_URL="https://github.com/buildroot/buildroot"
ARCHIVE_URL="${PROJECT_URL}/archive/refs/tags/${ID}.tar.gz"

# download archive for hash update
ARCHIVE_HASH=$(wget --passive-ftp -nd -t 3 -O - "${ARCHIVE_URL}" | sha256sum | awk '{ print $1 }')
if [[ -n "${ARCHIVE_HASH}" ]]; then
  # update package info
  sed -i "s/BUILDROOT_VERSION=.*/BUILDROOT_VERSION=$1/g" "Makefile"
  # update package hash
  sed -i "s/BUILDROOT_SHA256=.*/BUILDROOT_SHA256=${ARCHIVE_HASH}/g" "Makefile"
fi
