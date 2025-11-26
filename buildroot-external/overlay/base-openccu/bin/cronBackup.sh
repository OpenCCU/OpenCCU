#!/bin/sh
# shellcheck shell=dash disable=SC3010 source=/dev/null
#
# script that will create CCU compatible backups in a specified
# directory with taking care of keeping a certain amount of
# backups and deleting old ones.
#
# Copyright (c) 2018-2024 Jens Maus <mail@jens-maus.de>
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
# Usage:
# cronBackup.sh <directory> <maxbackups>
#
# - to disable cron created backups, create an empty
#   /etc/config/NoCronBackup file
# - to set a different default path, put it in a file
#   /etc/config/CronBackupPath
# - to set a different default maxbackups number (0=no limit) put it in
#   a file /etc/config/CronBackupMaxBackups
#

# skip the script if /etc/config/NoCronBackup exists
[[ -e /etc/config/NoCronBackup ]] && exit 0

# read in /var/hm_mode
[[ -r /var/hm_mode ]] && . /var/hm_mode

# set default values
MAXBACKUPS=30
if [[ -n "${HM_RUNNING_IN_HA}" ]]; then
  BACKUPDIR=/backup/openccu
else
  BACKUPDIR=/media/usb0/backup
fi

# check for external default parameters
[[ -f /etc/config/CronBackupPath ]] && BACKUPDIR=$(cat /etc/config/CronBackupPath)
[[ -f /etc/config/CronBackupMaxBackups ]] && MAXBACKUPS=$(cat /etc/config/CronBackupMaxBackups)

# cmdline parameter overrules everything
[[ -n "${1}" ]] && BACKUPDIR=${1}
[[ -n "${2}" ]] && MAXBACKUPS=${2}

# get additional info on backup dir
BACKUPREALPATH="$(realpath "${BACKUPDIR}" 2>/dev/null)"

# prevent that the user is messing up things by
# specifying an incorrect BACKUPDIR
if [[ -z "${BACKUPREALPATH}" ]] || # parent of backupdir does not exit
   [[ "${BACKUPREALPATH}" = "/usr/local" ]] || # not /usr/local
   [[ "$(findmnt -n -o TARGET --target "${BACKUPDIR}")" = "/" ]] || # not on rootfs
   [[ "$(stat -f -c%T "$(dirname "${BACKUPDIR}")")" = "tmpfs" ]]; then # not on tmpfs
  exit 0
fi

# if BACKUPDIR does not exist, create it
if [[ ! -e "${BACKUPDIR}" ]]; then
  if ! mkdir "${BACKUPDIR}"; then
    /bin/triggerAlarm.tcl "cronBackup: Could not create ${BACKUPDIR}" 'WatchDog: cronbackup-create' true
    exit 1
  fi
fi

# make sure .nobackup exists in BACKUPDIR so
# that this dir won't be part of the backup itself
if [[ ! -f "${BACKUPDIR}/.nobackup" ]]; then
  touch "${BACKUPDIR}/.nobackup"
fi

# create the backup in BACKUPDIR now
if ! /bin/createBackup.sh "${BACKUPDIR}"; then
  /bin/triggerAlarm.tcl "cronBackup: Backup job failed" 'WatchDog: cronbackup-failed' true
  exit 1
fi

# check how many backup files are actually in BACKUPDIR and cleanup
# until we reach MAXBACKUPS
if [[ "${MAXBACKUPS}" -gt 0 ]]; then
  # shellcheck disable=SC2012
  NUMFILES=$(ls -dt "${BACKUPDIR}"/*.sbk | wc -l)
  DELFILES=$((NUMFILES-MAXBACKUPS))
  if [[ ${DELFILES} -gt 0 ]]; then
    # shellcheck disable=SC2012
    ls -dt "${BACKUPDIR}"/*.sbk | tail -n "${DELFILES}" | xargs rm -f
  fi
fi

exit 0
