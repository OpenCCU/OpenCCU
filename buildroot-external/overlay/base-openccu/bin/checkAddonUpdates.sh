#!/bin/sh
# shellcheck shell=dash disable=SC3010

# exit in HMLGW mode immediately
[[ -e /usr/local/HMLGW ]] && exit 0

jsonfile=/tmp/addon_updates.json
if [[ -n "$(ls -A /etc/config/rc.d)" ]]; then
  # write to a temporary file and replace the list at the end, so that
  # CCU.getAddonVersions never reads a partially written list
  tmpfile=$(mktemp "${jsonfile}.XXXXXX") || exit 1
  failed=0
  chmod 644 "${tmpfile}" || failed=1
  echo "[" > "${tmpfile}" || failed=1
  first=1
  for filename in /etc/config/rc.d/*; do
    if [[ -f ${filename} ]]; then
      DINFO=$($filename info)
      DNAME=$(echo "${DINFO}" | grep "Name: " | sed "s/Name: //g")
      DVERSION=$(echo "${DINFO}" | grep "Version:" | awk '{print $2}')
      DUPDATESCRIPT=$(echo "${DINFO}" | grep "Update:" | awk '{print $2}')
      if [[ -n "${DUPDATESCRIPT}" ]]; then
        WEBRESULT=$(/usr/bin/curl -s "http://localhost${DUPDATESCRIPT}" | xargs | tr '[:upper:]' '[:lower:]')
        if [[ ${first} -eq 1 ]]; then
          first=0
        else
          echo "," >> "${tmpfile}" || failed=1
        fi
        echo "{\"name\":\"${DNAME}\",\"webversion\":\"${WEBRESULT}\"}" >> "${tmpfile}" || failed=1
        if [[ -n "${WEBRESULT}" ]] && [[ "${WEBRESULT}" != "n/a" ]] &&
           [[ "${DVERSION}" != "${WEBRESULT}" ]]; then
          echo "Update available for ${DNAME} (${DVERSION} / ${WEBRESULT})"
        fi
      fi
    fi
  done
  echo "]" >> "${tmpfile}" || failed=1
  # keep the previous list if the new one could not be written completely
  if [[ ${failed} -ne 0 ]] || ! mv -f "${tmpfile}" "${jsonfile}"; then
    rm -f "${tmpfile}"
    exit 1
  fi
else
  [[ -f ${jsonfile} ]] && rm -f ${jsonfile}
fi
