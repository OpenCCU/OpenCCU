#!/bin/sh
# shellcheck shell=dash disable=SC2169
#
# bad blocks check script v1.1
# Copyright (c) 2020-2021 Jens Maus <mail@jens-maus.de>
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
# This script is used to perform a daily check for bad blocks of the main
# root device and monit is then used to create an alarm message in case
# bad blocks are found.
#
# The functionality/idead of this check script has been inspired by
# previous work created by jp112sdl
#

ROOTDEV=$(mountpoint -n / | cut -d" " -f1)
[[ -b ${ROOTDEV} ]] || exit 1

DISKDEV=$(/bin/lsblk -s -p -d -r -n -o NAME "${ROOTDEV}" | tail -1)
[[ -b ${DISKDEV} ]] || exit 1

LOGFILE=/tmp/badblocks.txt
BLOCKSIZE=$(/sbin/blockdev --getbsz "${DISKDEV}")

# execute /sbin/badblocks to search for bad blocks
rm -f ${LOGFILE}
echo "checking for bad blocks on ${DISKDEV}"
/sbin/badblocks -b "${BLOCKSIZE}" -o "${LOGFILE}" -e 1 "${DISKDEV}"

exit 0
