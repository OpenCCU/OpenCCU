#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010,SC3015 source=/dev/null
#
# firmware update check script v1.4
# Copyright (c) 2022-2024 Jens Maus <mail@jens-maus.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This script allows to perform an online check for a new firmware version
# available and allow also to perform the update to the new firmware.
#
# Usage:
#   checkFirmware.sh [-a] [-r] [-b] [-s] [-f] [-h] <TARGET_VERSION>
#
# Options:
#   -a: apply firmware update
#   -r: reboot immediately after applying firmware update
#   -b: create backup (*.sbk) in standard path before updating
#   -s: use nightly snapshot
#   -f: force update even if version is equal
#   -h: help page
#   TARGET_VERSION: update to a specific version (3.XX.YY.YYYYMMDD)
#
# Exit codes:
#   0: no update available
#   1: update available
#   2: update applied
#   3: update immediately applied
#  >3: error
#

# Stop on error
set -e

# soure /VERSION
[[ -r /VERSION ]] && . /VERSION

# parse arguments
OPTIND=1 # Reset in case getopts has been used previously in the shell.
APPLY=0
BACKUP=0
SNAPSHOT=0
REBOOT=0
FORCE=0

while getopts "arbsfh" opt; do
  case "$opt" in
    a) APPLY=1 ;;
    r) REBOOT=1 ;;
    b) BACKUP=1 ;;
    s) SNAPSHOT=1 ;;
    f) FORCE=1 ;;
    h)
      echo "$0 [-a] [-r] [-b] [-s] [-f] [-h] <TARGET_VERSION>"
      echo
      echo "Usage:"
      echo "  -a: apply firmware update"
      echo "  -r: reboot immediately after applying firmware update"
      echo "  -b: create backup (*.sbk) in standard path before updating"
      echo "  -s: use nightly snapshot"
      echo "  -f: force update even if version is equal"
      echo "  -h: help page"
      echo "  TARGET_VERSION: update to a specific version (3.XX.YY.YYYYMMDD)"
      exit 4
    ;;
    *) exit 4 ;;
  esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift
TARGET_VERSION="$*"

# public URLs
LATEST_URL="https://api.github.com/repos/openccu/openccu/releases/latest"
SNAPSHOT_URL="https://api.github.com/repos/openccu/openccu/releases/tags/snapshots"
TARGET_URL="https://api.github.com/repos/openccu/openccu/releases/tags/${TARGET_VERSION}"

# if oci platform found we need to reuse the PRODUCT information instead
if [[ "${PLATFORM}" == "oci" ]]; then
  PLATFORM=$(echo "${PRODUCT}" | sed 's/openccu_//')
  EXTENSION="tgz"
elif [[ "${PLATFORM}" == "lxc" ]]; then
  PLATFORM=$(echo "${PRODUCT}" | sed 's/openccu_//')
  EXTENSION="tar.xz"
else
  EXTENSION="zip"
fi

# output currently installed version
echo "Installed version: ${VERSION} (${PLATFORM})"

# download releases json
RELEASES_JSON=$(mktemp -u)
if [[ -z "${TARGET_VERSION}" ]]; then
  if [[ ${SNAPSHOT} -ne 1 ]]; then
    REQUEST_URL=${LATEST_URL}
  else
    REQUEST_URL=${SNAPSHOT_URL}
  fi
else
  REQUEST_URL=${TARGET_URL}
fi
/usr/bin/curl -L --silent -o "${RELEASES_JSON}" "${REQUEST_URL}"

# make sure RELEASES_JSON is removed under all circumstances
# shellcheck disable=SC2064
trap "rm -f ${RELEASES_JSON}" EXIT

# if we could download the json file get the available releases
ret=4
if [[ -s "${RELEASES_JSON}" ]]; then

  # parse json
  AVAILABLE_VERSIONS=$(/usr/bin/jq -r ".assets[] | select(.browser_download_url | endswith(\"${TARGET_VERSION}-${PLATFORM}.${EXTENSION}\")) | .browser_download_url" "${RELEASES_JSON}")

  # get LATEST
  LATEST_VERSION_URL=$(echo "${AVAILABLE_VERSIONS}" | head -1)
  LATEST_VERSION=$(echo "${LATEST_VERSION_URL##*/}" | cut -d- -f2)

  # check if not empty
  if [[ -z "${LATEST_VERSION}" ]]; then
    echo "ERROR: online update check not working or target version (${TARGET_VERSION}) does not exist."
    exit ${ret}
  fi

  if [[ -z "${TARGET_VERSION}" ]]; then
    echo -n "Latest version...: "
  else
    echo -n "Target version...: "
  fi

  if [[ ${SNAPSHOT} -ne 1 ]]; then
    echo "${LATEST_VERSION}"
  else
    echo "$(echo "${LATEST_VERSION_URL##*/}" | cut -d- -f2-3) [snapshot]"
  fi

  # check if we have latest or not
  echo
  if [[ "${VERSION}" != "${LATEST_VERSION}" ]]; then
    echo "Update available to ${LATEST_VERSION} (${PLATFORM})"

    ret=1 # update available
  else
    echo -n "You have the latest version installed"

    if [[ ${FORCE} -eq 1 ]]; then
      echo " (forced apply)"
      ret=1 # update available
    else
      echo
      ret=0 # no update
    fi
  fi

  # check if user wants to apply the update right away
  if [[ ${ret} -eq 1 ]]; then
    if [[ ${APPLY} -eq 1 ]]; then
      echo

      # only allow firmware updates for platforms supporting it
      if [[ "${PLATFORM}" =~ oci_\|lxc_ ]]; then
        echo "ERROR: platform '${PLATFORM}' does not support being updated using this script."
        exit 4 # error
      fi

      # create a explicit backup before applying firmware update
      if [[ ${BACKUP} -eq 1 ]]; then
        echo -n "0) Creating backup (*.sbk)... "
        # set default values
        BACKUPDIR=/media/usb0/backup
        # check for external default parameters
        [[ -f /etc/config/CronBackupPath ]] && BACKUPDIR=$(cat /etc/config/CronBackupPath)
        # check if backup directory exists
        if [[ -d "${BACKUPDIR}" ]]; then
          if ! /bin/createBackup.sh "${BACKUPDIR}"; then
            echo "ERROR: could not create backup in '${BACKUPDIR}'"
            exit 4
          fi
          echo "created backup in '${BACKUPDIR}', OK"
        else
          echo "ERROR: missing '${BACKUPDIR}' backup directory."
          exit 4
        fi
      fi

      echo "1) Downloading update files... "
      FILENAME="/usr/local/tmp/${LATEST_VERSION_URL##*/}"

      # clear previous runs
      rm -f "/usr/local/.firmwareUpdate"
      rm -f "${FILENAME}"
      rm -f "${FILENAME}.sha256"

      # perform downloads
      /usr/bin/wget -q --show-progress -P /usr/local/tmp "${LATEST_VERSION_URL}" "${LATEST_VERSION_URL}.sha256"

      # next step: check sha256 checksum
      if [[ -f "${FILENAME}" ]]; then
        echo -n "2) Performing SHA256 checksum check... "
        SHA256_DL=$(cut -d" " -f1 "${FILENAME}.sha256")
        SHA256_FN=$(/usr/bin/sha256sum "${FILENAME}" | cut -d" " -f1)

        # check if computed and downloaded sha256 matches
        if [[ "${SHA256_DL}" == "${SHA256_FN}" ]]; then
          echo "OK (${SHA256_DL})"

          # create symbolic link
          echo -n "3) Scheduling firmware update for next boot cycle... "
          /bin/ln -sfn "${FILENAME}" "/usr/local/.firmwareUpdate"
          if [[ -L /usr/local/.firmwareUpdate ]]; then
            touch /usr/local/.recoveryMode
            if [[ -f /usr/local/.recoveryMode ]]; then
              echo "OK"
              ret=2 # update applied

              # reboot if requested
              if [[ ${REBOOT} -eq 1 ]]; then
                echo -n "4) Rebooting immediately... "
                /sbin/reboot
                echo "OK"
                ret=3 # update applied immediately
              fi
            else
              echo "ERROR: could not schedule firmware update"
            fi
          else
            echo "ERROR: could not create symbolic link"
            ret=4 # error
          fi
        else
          echo "ERROR: checksum does not match (${SHA256_FN})"
          ret=4 # error
        fi
      else
        echo "ERROR: could not download update files."
        ret=4
      fi
    fi
  fi
fi

exit ${ret}
