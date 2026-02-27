#!/bin/bash
#
# This helper script will walk over all patchfiles and make sure that
# it either takes the original *.orig file from OCCU (in case it is the
# first patch that uses it) or takes it from a previous OCCU patch
# directory in case a previous patch is modifying the same file.
#
# This should ensure that a proper patch hierarchy is maintained
# and that patches will be applicable with fuzz 0.
#

set -e
export LC_ALL=C

OCCU_VERSION=$(grep "OCCU_VERSION =" ../../package/occu/occu.mk | cut -d' ' -f3)
OCCU_URL="https://github.com/openccu/occu/archive/${OCCU_VERSION}/occu-${OCCU_VERSION}.tar.gz"
OCCU_DIR=/tmp/occu-${OCCU_VERSION}

echo "retrieving OCCU ${OCCU_VERSION}..."
rm -rf "${OCCU_DIR}"
wget --passive-ftp -nd -t 3 -O - "${OCCU_URL}" | tar -C /tmp -xz

echo -n "searching for patchable *.orig files..."
declare -A patchedfiles
patchfiles=$(find . -name "*.orig" | sort)
for file in ${patchfiles}; do
  occufile=$(echo "${file}" | cut -d'/' -f4-)
  patchdir=$(echo "${file}" | cut -d'/' -f2)

  # create an associative array full of all occu files
  # we are going to patch and then all the patch directory numbers to it
  # so that with the next step we can walk through this list and
  # update the patches accordingly.
  if [[ -z "${patchedfiles[${occufile}]}" ]]; then
    patchedfiles[${occufile}]=${patchdir}
  else
    patchedfiles[${occufile}]="${patchedfiles[${occufile}]} ${patchdir}"
  fi
done
echo ${#patchedfiles[@]} found


echo "walking through patchable file list:"
# walk through the patchedfiles array and update the files and patches accordingly.
for f in "${!patchedfiles[@]}"; do
  echo "${f}: "
  patchfile=${f}
  patchdirs="${patchedfiles[$f]}"

  # walk through all associated patch dirs and update
  # the patch files in the first one
  prevpatch=
  for d in ${patchdirs}; do
    echo -n "  ${d}"

    # create tmpfile to store diff
    pfile=$(mktemp)
    diff -u "${d}/occu/${patchfile}" "${d}/occu/${patchfile%.orig}" >"${pfile}" || true

    # for the first directory we get the
    # original file directly from OCCU
    if [[ -z "${prevpatch}" ]]; then
      # copy from OCCU if not already empty
      if [[ -s "${d}/occu/${patchfile}" ]]; then
        echo -n ", src=OCCU"
        cp -a "${OCCU_DIR}/${patchfile%.orig}" "${d}/occu/${patchfile}"
        cp -a "${OCCU_DIR}/${patchfile%.orig}" "${d}/occu/${patchfile%.orig}"
      else
        echo -n ", src=empty"
        rm "${d}/occu/${patchfile}" "${d}/occu/${patchfile%.orig}"
        touch "${d}/occu/${patchfile}"
        touch "${d}/occu/${patchfile%.orig}"
      fi
    else
      # copy from previous patch
      echo -n ", src=$(echo "${prevpatch}" | cut -d'/' -f1)"
      cp -a "${prevpatch}" "${d}/occu/${patchfile}"
      cp -a "${prevpatch}" "${d}/occu/${patchfile%.orig}"
    fi

    # before applying the patch we might need to unwrap the webui.js
    # using sed
    if [[ ${patchfile} == "WebUI/www/webui/webui.js.orig" ]] &&
      grep -q -m1 -e ".*\\\n$" "${pfile}"; then

      # unwrap webui.js
      echo -n ", unwrap"
      sed -i '1,10s/\\n/\\n\n/g' "${d}/occu/${patchfile}"
      sed -i '1,10s/\\n/\\n\n/g' "${d}/occu/${patchfile%.orig}"
    fi

    # reapply patch using tmpdiff
    echo -n ", patching"
    patch -s -p0 <"${pfile}"
    rm "${pfile}"
    echo ", OK"

    # mark previous patch
    prevpatch="${d}/occu/${patchfile%.orig}"
  done
done

# re-create the patch files
./create_patches.sh

exit 0
