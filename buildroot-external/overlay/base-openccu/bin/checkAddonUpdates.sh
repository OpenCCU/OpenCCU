#!/bin/sh
# shellcheck shell=dash disable=SC3010

# exit in HMLGW mode immediately
[[ -e /usr/local/HMLGW ]] && exit 0

jsonfile=/tmp/addon_updates.json
if [[ -n "$(ls -A /etc/config/rc.d)" ]]; then
  echo "[" > ${jsonfile}
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
          echo "," >> ${jsonfile}
        fi
        echo "{\"name\":\"${DNAME}\",\"webversion\":\"${WEBRESULT}\"}" >> ${jsonfile}
        if [[ -n "${WEBRESULT}" ]] && [[ "${WEBRESULT}" != "n/a" ]] &&
           [[ "${DVERSION}" != "${WEBRESULT}" ]]; then
          echo "Update available for ${DNAME} (${DVERSION} / ${WEBRESULT})"
        fi
      fi
    fi
  done
  echo "]" >> ${jsonfile}
else
  [[ -f ${jsonfile} ]] && rm -f ${jsonfile}
fi
