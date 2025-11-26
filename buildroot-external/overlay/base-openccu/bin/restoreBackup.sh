#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010 source=/dev/null
#
# sbk-backup restore script v2.0
# Copyright (c) 2016-2024 Jens Maus <mail@jens-maus.de>
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
# simple wrapper script to restore a standard sbk file backup
# the standard way (requiring a reboot)
#
# Usage:
#   restoreBackup.sh [-c] [-r] [-b] [-f] <SBK_FILE>
#
# Options:
#   -c: check only the validity of the supplied sbk backup
#   -r: reboot immediately after applying sbk backup file
#   -b: create backup (*.sbk) in standard path before updating
#   -f: force backup restore (ignore security key check)
#   -h: help page
#   SBK_FILE: path to a *.sbk backup file to check and apply
#

# Stop on error
set -e

# soure /VERSION
[[ -r /VERSION ]] && . /VERSION
RUNNING_VERSION=${VERSION}

# parse arguments
OPTIND=1 # Reset in case getopts has been used previously in the shell.
CHECK=0
REBOOT=0
BACKUP=0
FORCE=0

while getopts "crbfh" opt; do
  case "$opt" in
    c) CHECK=1 ;;
    r) REBOOT=1 ;;
    b) BACKUP=1 ;;
    f) FORCE=1 ;;
    h)
      echo "$0 [-c] [-r] [-b] [-f] [-h] <SBK_FILE>"
      echo
      echo "Usage:"
      echo "  -c: check only the validity of the supplied sbk backup"
      echo "  -r: reboot immediately after applying sbk backup file"
      echo "  -b: create backup (*.sbk) in standard path before updating"
      echo "  -f: force backup restore (ignore security key check)"
      echo "  -h: help page"
      echo "  SBK_FILE: path to a *.sbk backup file to check and apply"
      exit 4
    ;;
    *) exit 4;;
  esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift
SBK_FILE="$*"

if [[ -z "${SBK_FILE}" ]]; then
  echo "ERROR: no .sbk backup file specified."
  exit 1
fi

if [[ ! -f "${SBK_FILE}" ]]; then
  echo "ERROR: supplied sbk backup file (${SBK_FILE}) does not exit."
  exit 1
fi

BACKUPDIR=/usr/local/tmp
TMPDIR=$(mktemp -d -p ${BACKUPDIR})
if [[ -d "${TMPDIR}" ]]; then

  # make sure TMPDIR is removed under all circumstances
  # shellcheck disable=SC2064
  trap "rm -rf ${TMPDIR}" EXIT

  ##################################
  # perform a sbk backup checks first
  echo "1) Checking sbk backup file consistency:"

  # extract the sbk to TMPDIR
  if ! /bin/tar -C "${TMPDIR}" --warning=no-timestamp --no-same-owner -xf "${SBK_FILE}" 2>/dev/null; then
    echo "   ERROR: could not untar backup file."
    exit 1
  fi

  # check archive consistency using sha256
  if [[ -f "${TMPDIR}/signature.sha256" ]]; then
    if ! (cd "${TMPDIR}" && /usr/bin/sha256sum -s -c signature.sha256); then
      echo "   ERROR: inconsistent or compromised backup archive identified (sha256)."
      exit 1
    fi
  fi

  # check firmware version this file was generated on
  . "${TMPDIR}/firmware_version"
  BACKUP_VERSION=${VERSION}
  echo -n "   generated on ${BACKUP_VERSION}, applying to ${RUNNING_VERSION}, "
  if [[ "$(echo "${BACKUP_VERSION}" | cut -d'.' -f1)" != "2" ]] && [[ "$(echo "${BACKUP_VERSION}" | cut -d'.' -f1)" != "3" ]]; then
    echo "ERROR: backup version (${BACKUP_VERSION}) not supported. Must bei 2.x or 3.x."
    exit 1
  fi
  echo "OK"

  # verify security key settings
  SYSTEM_HAS_USER_KEY=$(/bin/crypttool -v -t 0 >/dev/null; echo $?)
  STORED_SIGNATURE=$(cat "${TMPDIR}/signature")
  CALCED_SIGNATURE=$(/bin/crypttool -s -t 0 <"${TMPDIR}/usr_local.tar.gz")
  if [[ "${STORED_SIGNATURE}" != "${CALCED_SIGNATURE}" ]]; then
    CONFIG_HAS_USER_KEY=1
  else
    CONFIG_HAS_USER_KEY=0
  fi

  # request key from user if either backup or system
  # has a set security key
  if [[ "${CONFIG_HAS_USER_KEY}" == "1" ]] ||
     [[ "${SYSTEM_HAS_USER_KEY}" == "1" ]]; then
    echo "   backup and/or system protected by security key..."
    read -r -p "   Enter security key: " SECURITY_KEY

    if [[ "${SYSTEM_HAS_USER_KEY}" == "1" ]]; then
      echo -n "   system protected with a key, "
      if ! /bin/crypttool -v -t 3 -k "${SECURITY_KEY}" >/dev/null; then
        echo -n "WARNING: security key does NOT match system key, "
        if [[ ${FORCE} -ne 1 ]]; then
          echo "aborting"
          exit 1
        else
          echo "forced restore."
        fi
      else
        echo "matches, OK"
      fi
    else
      echo "   system NOT protected with a key, OK"
    fi

    if [[ "${CONFIG_HAS_USER_KEY}" == "1" ]]; then
      echo -n "   backup protected with a key, "
      if [[ "${STORED_SIGNATURE}" != $(/bin/crypttool -s -t 3 -k "${SECURITY_KEY}" <"${TMPDIR}/usr_local.tar.gz") ]]; then
        echo -n "WARNING: security key does NOT match key in backup, "
        if [[ ${FORCE} -ne 1 ]]; then
          echo "aborting"
          exit 1
        else
          echo "forced restore."
        fi
      else
        echo "matches, OK"
      fi
    else
      echo "   backup NOT protected with a key, OK"
    fi
  else
    echo "   backup or system NOT protected by security key, OK"
  fi

  # check succeeded, continue if wanted
  if [[ ${CHECK} -eq 1 ]]; then
    echo
    echo "Config check processing only, exiting."
    exit 0
  fi

  # create a fresh backup the standard way
  echo -n "2) Creating backup (*.sbk)... "
  if [[ ${BACKUP} -eq 1 ]]; then
    # set default values
    BACKUPDIR=/media/usb0/backup

    # check for external default parameters
    [[ -f /etc/config/CronBackupPath ]] && BACKUPDIR=$(cat /etc/config/CronBackupPath)

    # check if backup directory exists
    if [[ -d "${BACKUPDIR}" ]]; then
      if ! /bin/createBackup.sh "${BACKUPDIR}"; then
        echo "ERROR: could NOT create backup in '${BACKUPDIR}'"
        exit 1
      fi
      echo "created backup in '${BACKUPDIR}', OK"
    else
      echo "ERROR: missing '${BACKUPDIR}' backup directory."
      exit 1
    fi
  else
    echo "skipped, OK"
  fi

  # set system key in case there is no system key yet
  # but the backup is about to bring in a new/different key
  echo -n "3) Setting system security key... "
  if [[ "${SYSTEM_HAS_USER_KEY}" == "0" ]] &&
     [[ "${CONFIG_HAS_USER_KEY}" == "1" ]]; then
    STORED_KEYINDEX=$(cat "${TMPDIR}/key_index")
    if /bin/crypttool -S -i "${STORED_KEYINDEX}" -k "${SECURITY_KEY}" >/dev/null; then
      echo "OK"
    else
      echo "ERROR: could not set system key."
      exit 1
    fi
  else
    echo "not required, OK"
  fi

  echo -n "4) Scheduling backup restore for next boot cycle, "
  # mv usr_local.tar.gz to /usr/local/tmp for backup restore
  # processing upon next reboot
  mv "${TMPDIR}/usr_local.tar.gz" /usr/local/tmp/

  # flag backup restore processing upon next reboot
  touch /usr/local/.doBackupRestore

  if [[ -f /usr/local/tmp/usr_local.tar.gz ]] &&
     [[ -r /usr/local/.doBackupRestore ]]; then
    echo "OK"
  else
    echo "ERROR: could not prepare backup restore."
    exit 1
  fi

  # reboot immediately if wanted
  if [[ ${REBOOT} -eq 1 ]]; then
    echo -n "5) Rebooting immediately, "
    /sbin/reboot
    echo "OK"
  else
    echo
    echo "Please reboot to apply backup."
  fi

  exit 0
else
  exit 1
fi
