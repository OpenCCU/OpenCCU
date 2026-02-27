#!/bin/sh
# shellcheck shell=dash disable=SC2169 source=/dev/null
#
# simple wrapper script to generate a CCU compatible sbk file
#
# Copyright (c) 2016-2025 Jens Maus <mail@jens-maus.de>
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
# createBackup.sh <directory/file>
#

# Stop on error
set -e

# default backup destination directory
BACKUPDIR=/usr/local/tmp

# let caller overwrite the backup path
if [[ -n "${1}" ]]; then
  BACKUPPATH="${1}"
else
  BACKUPPATH=${BACKUPDIR}
fi

# get running firmware version
. /VERSION 2>/dev/null

# check if specified path is a directory or file
if [[ -d "${BACKUPPATH}" ]]; then
  # a directory path was specified, lets construct the complete filepath
  BACKUPDIR="$(realpath "${BACKUPPATH}")"
  BACKUPFILE="$(hostname)-${VERSION}-$(date +%Y-%m-%d-%H%M).sbk"
elif [[ "${BACKUPPATH:0:1}" != "." && "${BACKUPPATH:0:1}" != "/" ]]; then
  # a filename without path was specified, thus add it to default backup path
  BACKUPFILE="${BACKUPPATH}"
else
  # a file was specified with a directory path
  BACKUPDIR="$(realpath "$(dirname "${BACKUPPATH}")")"
  BACKUPFILE="$(basename "${BACKUPPATH}")"
fi

# use the backupdir as base directory for creating
# a temporary directory to create the backup stuff in there.
TMPDIR=$(mktemp -d -p "${BACKUPDIR}")
if [[ -d "${TMPDIR}" ]]; then
  # make sure TMPDIR is removed under all circumstances
  # shellcheck disable=SC2064
  trap "rm -rf ${TMPDIR}" EXIT

  # make sure ReGaHSS saves its current settings
  echo 'load tclrega.so; rega system.Save()' | tclsh >/dev/null 2>&1

  # create a tar.gz of /usr/local
  set +e # disable abort on error
  /bin/tar -C / --owner=root --group=root --exclude=usr/local/tmp --exclude="usr/local/.*" --exclude=usr/local/lost+found --exclude="${BACKUPDIR}" --exclude=usr/local/eQ-3-Backup --exclude-tag=.nobackup --one-file-system --ignore-failed-read --warning=no-file-changed -czf "${TMPDIR}/usr_local.tar.gz" usr/local 2>/dev/null
  if [[ $? -eq 2 ]]; then
    exit 2
  fi
  set -e # re-enable abort on error

  # check the gzip integrity
  /bin/gzip -t "${TMPDIR}/usr_local.tar.gz"

  # check if the tar.gz is valid
  /bin/gzip -dc "${TMPDIR}/usr_local.tar.gz" | /bin/tar -tf - >/dev/null

  # sign the configuration with the current key
  /bin/crypttool -s -t 1 <"${TMPDIR}/usr_local.tar.gz" >"${TMPDIR}/signature"

  # store the current key index
  /bin/crypttool -g -t 1 >"${TMPDIR}/key_index"

  # store the firmware VERSION
  echo "VERSION=${VERSION}" >"${TMPDIR}/firmware_version"

  # create sha256 checksum of all files
  (cd "${TMPDIR}" && /usr/bin/sha256sum ./* >signature.sha256)

  # create sbk file
  /bin/tar -C "${TMPDIR}" --owner=root --group=root -cf "${BACKUPDIR}/${BACKUPFILE}" usr_local.tar.gz signature signature.sha256 key_index firmware_version 2>/dev/null

  # test if the final tar created is a valid tar archive
  /bin/tar -tf "${BACKUPDIR}/${BACKUPFILE}" >/dev/null

  exit 0
else
  exit 1
fi
