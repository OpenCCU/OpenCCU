#!/bin/sh
# shellcheck shell=dash disable=SC3010

# exit in HMLGW mode immediately
[[ -e /usr/local/HMLGW ]] && exit 0

jsonfile=/tmp/addon_updates.json
logtag=checkAddonUpdates

json_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

is_valid_webversion() {
  local webversion="$1"

  [[ -z "${webversion}" ]] && return 1
  [[ "${webversion}" == "n/a" ]] && return 0

  echo "${webversion}" | grep -Eiq '(not found|error|<html|<!doctype|^404($|[^0-9]))' && return 1
  echo "${webversion}" | grep -Eq '^[0-9a-z][0-9a-z._:+~/-]*$' || return 1

  return 0
}

if [[ -n "$(ls -A /etc/config/rc.d)" ]]; then
  tmpjsonfile=$(mktemp "${jsonfile}.XXXXXX") || exit 1
  echo "[" > "${tmpjsonfile}"
  first=1
  for filename in /etc/config/rc.d/*; do
    if [[ -f ${filename} ]]; then
      DINFO=$("${filename}" info)
      DNAME=$(echo "${DINFO}" | grep "Name: " | sed "s/Name: //g")
      DVERSION=$(echo "${DINFO}" | grep "Version:" | awk '{print $2}')
      DUPDATESCRIPT=$(echo "${DINFO}" | grep "Update:" | awk '{print $2}')
      if [[ -n "${DUPDATESCRIPT}" ]]; then
        WEBRESULT=$(/usr/bin/curl -fsS --max-time 10 "http://localhost${DUPDATESCRIPT}" 2>/dev/null | tr -d '\r\n' | xargs | tr '[:upper:]' '[:lower:]')
        if [[ $? -ne 0 ]]; then
          logger -t "${logtag}" "Skipping update check result for ${DNAME}: failed to fetch ${DUPDATESCRIPT}"
          continue
        fi

        if ! is_valid_webversion "${WEBRESULT}"; then
          logger -t "${logtag}" "Skipping invalid update check result for ${DNAME}: '${WEBRESULT}' (${DUPDATESCRIPT})"
          continue
        fi

        DNAME_JSON=$(json_escape "${DNAME}")
        WEBRESULT_JSON=$(json_escape "${WEBRESULT}")
        if [[ ${first} -eq 1 ]]; then
          first=0
        else
          echo "," >> "${tmpjsonfile}"
        fi
        echo "{\"name\":\"${DNAME_JSON}\",\"webversion\":\"${WEBRESULT_JSON}\"}" >> "${tmpjsonfile}"
        if [[ -n "${WEBRESULT}" ]] && [[ "${WEBRESULT}" != "n/a" ]] &&
           [[ "${DVERSION}" != "${WEBRESULT}" ]]; then
          echo "Update available for ${DNAME} (${DVERSION} / ${WEBRESULT})"
        fi
      fi
    fi
  done
  echo "]" >> "${tmpjsonfile}"
  mv -f "${tmpjsonfile}" "${jsonfile}"
else
  [[ -f "${jsonfile}" ]] && rm -f "${jsonfile}"
fi
