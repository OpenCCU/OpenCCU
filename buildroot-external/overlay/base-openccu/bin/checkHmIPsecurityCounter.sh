#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010
#
# Helper script to check (and protect/repair) the HmIP security counter of
# HMIPServer (cf. https://github.com/OpenCCU/OpenCCU/issues/4274).
#
# At startup HMIPServer sets the security counter of the RF module to
#   calc = (now - firstConnect) / 300ms + 1 + securityCounterOffset
# (if calc is greater than the current counter), but only sends the lower
# 32 bits of it. Once calc exceeds 2^32 (e.g. because a start with an invalid
# system time raised the offset, or simply ~40 years after firstConnect) the
# counter jumps backwards and all HmIP devices drop the frames of the CCU as
# replays.
#
# Usage: checkHmIPsecurityCounter.sh [status|check|repair]
#
#  status  (default) show the security counter state of all HmIP access
#          points incl. the estimated time left until the 32 bit limit.
#  check   called by S62HMServer before HMIPServer is started: if calc would
#          exceed 2^32 the offset is lowered so that calc = offset+1 is not
#          above the current counter of the RF module. Thus HMIPServer keeps
#          that counter and recalculates the offset itself (prevention).
#          Systems already wrapped before this check existed are only
#          reported, because their devices may have been power cycled since
#          then and work fine.
#  repair  request the repair of an already wrapped security counter at the
#          next start of HMIPServer (a reboot of the system is recommended):
#          calc is then set slightly above the highest counter the devices
#          most likely have seen before the wrap (offset+1 + margin).
#

DATADIR=/etc/config/crRFD/data
REPAIR=/etc/config/HmIPSecurityCounterRepair
WRAP=4294967296                 # 2^32
LIMIT=$((WRAP - 100000))        # 2^32 minus ~8h of time based increase
MARGIN=10000000                 # frames sent with an invalid system time
MINFC=1404165600000             # 2014-07-01 (minimum firstConnect of HMIPServer)

# parse the kryo serialized access point file $1 (Kryo.writeClassAndObject()
# and HMIPAccessPointSerializer): class name (varint 1, varint name id,
# string), reference marker (varint 1), int version, string id, string
# address, long firstConnect, string nwkExchangeState, long
# securityCounterOffset. Sets VER, FC, OFFSET and OFFPOS (file position of
# the offset).
parseAP() {
  # shellcheck disable=SC2046
  set -- $(od -An -v -tu1 "$1")
  POS=0; IDX=0; CLS=0; REF=0; VER=0; FC=0; OFFPOS=0; OFFSET=0
  for FIELD in v v s v i s s l s l; do
    IDX=$((IDX + 1))
    [[ ${IDX} -eq 10 ]] && OFFPOS=${POS}
    case "${FIELD}" in
      v) N=1 ;;
      i) N=4 ;;
      l) N=8 ;;
      s) # ASCII string (2-63 chars, last char | 0x80) or string with UTF8
         # length prefix (charCount+1, 6+7 bits) for null/0/1/>=64 chars
        if [[ $# -gt 0 ]] && [[ $1 -ge 128 ]]; then
          LEN=$(($1 & 63)); N=1
          if [[ $(($1 & 64)) -ne 0 ]]; then
            [[ $# -ge 2 ]] && [[ $2 -lt 128 ]] || return 1
            LEN=$((LEN | ($2 << 6))); N=2
          fi
          [[ ${LEN} -gt 0 ]] && N=$((N + LEN - 1))
        else
          N=1
          while [[ ${N} -le $# ]] && eval "[[ \${${N}} -lt 128 ]]"; do N=$((N + 1)); done
        fi
        ;;
    esac
    [[ $# -ge ${N} ]] || return 1
    VALUE=0
    while [[ ${N} -gt 0 ]]; do
      VALUE=$(((VALUE << 8) | $1)); shift; POS=$((POS + 1)); N=$((N - 1))
    done
    case "${IDX}" in
      1) CLS=${VALUE} ;;
      4) REF=${VALUE} ;;
      5) VER=${VALUE} ;;
      8) FC=${VALUE} ;;
      10) OFFSET=${VALUE} ;;
    esac
  done
  [[ ${CLS} -eq 1 ]] && [[ ${REF} -eq 1 ]] && [[ ${VER} -ge 3 ]] && [[ ${VER} -le 99 ]] &&
    [[ ${FC} -gt 0 ]] && [[ ${OFFSET} -lt ${WRAP} ]]
}

# predict the calculation of HMIPServer (firstConnect is set to at least
# 2014-07-01 and is only used if it is in the past). Sets DIFF and CALC.
predict() {
  [[ ${FC} -lt ${MINFC} ]] && FC=${MINFC}
  DIFF=1
  [[ ${FC} -lt ${NOWMS} ]] && DIFF=$(((NOWMS - FC) / 300 + 1))
  CALC=$((DIFF + OFFSET))
}

# write $2 as 8 byte big endian long at position $3 of file $1
writeOffset() {
  ESC=""; N=56; BYTES=""
  while [[ ${N} -ge 0 ]]; do
    B=$((($2 >> N) & 255))
    ESC="${ESC}\\$(printf '%03o' "${B}")"; BYTES="${BYTES} ${B}"
    N=$((N - 8))
  done
  [[ -e "$1.bak" ]] || cp -a "$1" "$1.bak"
  cp -a "$1" "$1.new"
  # shellcheck disable=SC2059
  printf "${ESC}" | dd of="$1.new" bs=1 seek="$3" count=8 conv=notrunc 2>/dev/null
  if [[ "$(od -An -v -tu1 -j "$3" -N 8 "$1.new" 2>/dev/null | xargs)" == "${BYTES# }" ]] &&
     mv "$1.new" "$1"; then
    return 0
  fi
  rm -f "$1.new"
  return 1
}

# human readable duration of $1 seconds
duration() {
  if [[ $1 -ge 31557600 ]]; then
    Y10=$(($1 * 10 / 31557600))
    echo "$((Y10 / 10)).$((Y10 % 10)) years"
  else
    echo "$(($1 / 86400)) days"
  fi
}

# protect the security counter before HMIPServer is started (S62HMServer)
check() {
  FAILED=0
  for AP in "${DATADIR}"/*.ap; do
    [[ -f "${AP}" ]] || continue
    parseAP "${AP}" || continue
    predict
    if [[ ${CALC} -lt ${LIMIT} ]]; then
      # remember that this access point was ok with a valid system time
      [[ ${DIFF} -gt 1 ]] && [[ ! -e "${AP}.checked" ]] && touch "${AP}.checked"
      continue
    fi

    if [[ -e "${REPAIR}" ]]; then
      TARGET=$((OFFSET + MARGIN))
    elif [[ -e "${AP}.checked" ]]; then
      TARGET=$((OFFSET + 1))
    else
      # already in the wrapped state before this check existed
      echo -n "WARNING: HmIP security counter wrapped, "
      logger -t HMIPServer -p user.warn "security counter of ${AP##*/} already wrapped (offset ${OFFSET}), see checkHmIPsecurityCounter.sh"
      continue
    fi
    [[ ${TARGET} -gt ${LIMIT} ]] && TARGET=${LIMIT}

    # NEWOFFSET can be negative (system time far in the future or ~40 years
    # after firstConnect). This is intended: HMIPServer itself stores negative
    # offsets (current counter - time difference) and recalculates the offset
    # at the next start, while skipping the change would wrap the counter.
    NEWOFFSET=$((TARGET - DIFF))
    if writeOffset "${AP}" "${NEWOFFSET}" "${OFFPOS}"; then
      echo -n "security counter offset fixed, "
      logger -t HMIPServer -p user.warn "security counter offset of ${AP##*/} changed from ${OFFSET} to ${NEWOFFSET} (calc ${TARGET})"
    else
      echo -n "ERROR: security counter fix failed, "
      FAILED=1
    fi
  done
  # keep a requested repair for the next start if writing an offset failed
  [[ ${FAILED} -eq 0 ]] && rm -f "${REPAIR}"
}

# show the security counter state of all access points (returns 1 on errors)
status() {
  RC=0
  FOUND=0
  for AP in "${DATADIR}"/*.ap; do
    [[ -f "${AP}" ]] || continue
    FOUND=1
    echo "${AP##*/}:"
    if ! parseAP "${AP}"; then
      echo "  state:        unknown file format"
      continue
    fi
    predict
    echo "  firstConnect: $(date -d "@$((FC / 1000))" '+%Y-%m-%d %H:%M:%S')"
    echo "  offset:       ${OFFSET}"
    if [[ ${DIFF} -le 1 ]]; then
      echo "  state:        ERROR: system time invalid, no estimation possible"
      RC=1
    elif [[ ${CALC} -lt ${LIMIT} ]]; then
      LEFT=$(((WRAP - CALC) * 3 / 10))
      echo "  calculation:  ${CALC} ($((CALC * 100 / WRAP))% of 2^32)"
      echo "  state:        OK, 32 bit limit in ~$(duration "${LEFT}") ($(date -d "@$((NOWMS / 1000 + LEFT))" '+%Y-%m-%d'))"
    elif [[ -e "${AP}.checked" ]]; then
      echo "  calculation:  ${CALC}"
      echo "  state:        WARNING: 32 bit limit reached, offset is corrected at next HMIPServer start"
      echo "                (counter only increases with sent frames from now on)"
    else
      echo "  calculation:  ${CALC} (sent as $((CALC % WRAP)))"
      echo "  state:        ERROR: security counter already wrapped."
      if [[ -e "${REPAIR}" ]]; then
        echo "                Repair requested, it is applied at the next system reboot."
      else
        echo "                If HmIP devices are unreachable, power cycle them or run"
        echo "                '$0 repair' and reboot the system."
      fi
      RC=1
    fi
  done
  [[ ${FOUND} -eq 1 ]] || echo "No HmIP access point found in ${DATADIR}."
  return ${RC}
}

# request the repair of a wrapped security counter at the next HMIPServer start
repair() {
  WRAPPED=0
  for AP in "${DATADIR}"/*.ap; do
    [[ -f "${AP}" ]] || continue
    parseAP "${AP}" || continue
    predict
    [[ ${CALC} -ge ${LIMIT} ]] && WRAPPED=1
  done
  if [[ ${WRAPPED} -eq 0 ]]; then
    echo "No wrapped HmIP security counter found, nothing to repair."
    return 0
  fi

  # the repair is applied by S62HMServer (cf. check) before HMIPServer is
  # started the next time
  touch "${REPAIR}"
  echo "Repair of the HmIP security counter requested. Please reboot the system to apply it."
}

NOWMS=$(($(date +%s) * 1000))

case "${1:-status}" in
  status)
    status
    ;;
  check)
    check
    ;;
  repair)
    repair
    ;;
  *)
    echo "Usage: $0 [status|check|repair]" >&2
    exit 1
    ;;
esac
