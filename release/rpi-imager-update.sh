#!/usr/bin/env bash
#
# helper script to update a rpi-imager json with the supplied
# manifest (*.mf) files for all rpi platforms
#

# check number of arguments
if [ "$#" -ne 6 ]; then
  echo "ERROR: invalid number of arguments"
  exit 1
fi

# Setup script environment
set -o errexit  #Exit immediately if a pipeline returns a non-zero status
set -o errtrace #Trap ERR from shell functions, command substitutions, and commands from subshell
set -o nounset  #Treat unset variables as an error
set -o pipefail #Pipe will exit with last non-zero status if applicable
shopt -s expand_aliases
alias die='EXIT=$? LINE=${LINENO} error_exit'
trap die ERR
trap cleanup EXIT

function error_exit() {
  trap - ERR
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR] \e[93m${EXIT}@${LINE}"
  msg "${FLAG} ${REASON}"
  exit "${EXIT}"
}

function warn() {
  local REASON="\e[97m$1\e[39m"
  local FLAG="\e[93m[WARNING]\e[39m"
  msg "${FLAG} ${REASON}"
}

function info() {
  local REASON="$1"
  local FLAG="\e[36m[INFO]\e[39m"
  msg "${FLAG} ${REASON}"
}

function msg() {
  local TEXT="$1"
  echo -e "${TEXT}"
}

function cleanup() {
  popd >/dev/null
  rm -rf "${TEMP_DIR}"
}

# get rpi-image.json path
RPI_IMAGER_PATH=$(readlink -f "${1}")

# retrieve manifest file paths
RPI3_MF=$(readlink -f "${2}")
RPI4_MF=$(readlink -f "${3}")
RPI5_MF=$(readlink -f "${4}")

# extract version and release date from first mf filename
# shellcheck disable=SC2001
NEW_VERSION=$(echo "${RPI3_MF}" | sed 's/.*\/OpenCCU-\(.*\)-rpi.\.mf/\1/')
RELEASE_DATE=$(date --date="$(echo "${NEW_VERSION}" | cut -d'.' -f4 | head -c8)" +%Y-%m-%d)

# common infos
DESCRIPTION="Lightweight Linux OS for running a HomeMatic/homematicIP IoT central."
if [[ ${NEW_VERSION} =~ "-" ]]; then
  NEW_VERSION=${NEW_VERSION::-1} # remove last char because of deploy-nightly action
  DOWNLOAD_URL="https://github.com/OpenCCU/OpenCCU/releases/download/snapshots/OpenCCU-VERSION"
else
  DOWNLOAD_URL="https://github.com/OpenCCU/OpenCCU/releases/download/VERSION/OpenCCU-VERSION"
fi

# create temp dir and copy rpi-imager.json to it
TEMP_DIR=$(mktemp -d)
cp -a "${RPI_IMAGER_PATH}" "${TEMP_DIR}/"
pushd "${TEMP_DIR}" >/dev/null

function updateJSON() {
  local id=${1}       # id
  local platform=${2} # platform
  local mf=${3}       # manifest file
  local descr=${4}    # description

  # extract info from manifest
  IMAGE_DOWNLOAD_SIZE=$(grep -e "-${platform}\.zip$" "${mf}" | cut -d' ' -f1)
  IMAGE_DOWNLOAD_CHKS=$(grep -e "-${platform}\.zip$" "${mf}" | cut -d' ' -f2)
  EXTRACT_SIZE=$(grep -e "-${platform}\.img$" "${mf}" | cut -d' ' -f1)
  EXTRACT_CHKS=$(grep -e "-${platform}\.img$" "${mf}" | cut -d' ' -f2)
  ARCHIVE_URL="${DOWNLOAD_URL//VERSION/${NEW_VERSION}}-${platform}.zip"
  
  info "Patching rpi-imager.json [${platform}]..."
  jq ".os_list[${id}].name = \"OpenCCU ${NEW_VERSION} (${descr})\" | \
      .os_list[${id}].description = \"${DESCRIPTION}\" | \
      .os_list[${id}].url = \"${ARCHIVE_URL}\" | \
      .os_list[${id}].release_date = \"${RELEASE_DATE}\" | \
      .os_list[${id}].extract_size = ${EXTRACT_SIZE} | \
      .os_list[${id}].extract_sha256 = \"${EXTRACT_CHKS}\" | \
      .os_list[${id}].image_download_size = ${IMAGE_DOWNLOAD_SIZE} | \
      .os_list[${id}].image_download_sha256 = \"${IMAGE_DOWNLOAD_CHKS}\"" "${TEMP_DIR}/rpi-imager.json" >rpi-imager-new.json
  mv rpi-imager-new.json "${TEMP_DIR}/rpi-imager.json"
}

# copy rpi-imager to tmp
cp -a "${RPI_IMAGER_PATH}" "${TEMP_DIR}/rpi-imager.json"

# update rpi-imager.json
updateJSON 0 rpi5 "${RPI5_MF}" "Pi 5"
updateJSON 1 rpi4 "${RPI4_MF}" "Pi 4, Pi 400"
updateJSON 2 rpi3 "${RPI3_MF}" "Pi 3, Pi Zero 2, ELV-Charly, CCU3"

cp -a "${TEMP_DIR}/rpi-imager.json" "${RPI_IMAGER_PATH}"
