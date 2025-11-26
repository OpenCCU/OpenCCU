#!/usr/bin/env bash
# shellcheck disable=SC2086
#
# Script to install a OpenCCU VM/CT in Proxmox programatically.
# https://raw.githubusercontent.com/OpenCCU/OpenCCU/master/scripts/install-proxmox.sh
#
# Inspired by https://github.com/whiskerz007/proxmox_hassos_install
#
# Copyright (c) 2022-2025 Jens Maus <mail@jens-maus.de>
# Apache 2.0 License applies
#
# Usage:
# wget -qO - https://openccu.de/install-proxmox.sh | bash -
#

# Setup script environment
set -o errexit  #Exit immediately if a pipeline returns a non-zero status
set -o errtrace #Trap ERR from shell functions, command substitutions, and commands from subshell
set -o nounset  #Treat unset variables as an error
set -o pipefail #Pipe will exit with last non-zero status if applicable
shopt -s expand_aliases
alias die='EXIT=$? LINE=${LINENO} error_exit'
trap die ERR
trap cleanup EXIT

# Set default variables
VERSION="3.17"
LOGFILE="/tmp/install-proxmox.log"
LINE=

error_exit() {
  trap - ERR
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR] \e[93m${EXIT}@${LINE}:"
  msg "${FLAG} ${REASON}"
  [ -n "${VMID-}" ] && cleanup_vmid
  if [[ -s "${LOGFILE}" ]]; then
    msg "${FLAG} \e[39mSee ${LOGFILE} for error details"
  fi
  exit "${EXIT}"
}
warn() {
  local REASON="\e[97m$1\e[39m"
  local FLAG="\e[93m[WARNING]\e[39m"
  msg "${FLAG} ${REASON}"
}
info() {
  local REASON="$1"
  local FLAG="\e[36m[INFO]\e[39m"
  msg "${FLAG} ${REASON}"
}
msg() {
  local TEXT="$1"
  echo -e "${TEXT}"
}
cleanup_vmid() {
  if [[ -n "${VMID}" ]]; then
    if [[ "${VMTYPE}" == "VM" ]]; then
      if qm status "${VMID}" >>${LOGFILE} 2>&1; then
        if [ "$(qm status "${VMID}" | awk '{print $2}')" == "running" ]; then
          qm stop "${VMID}" >>${LOGFILE} 2>&1
        fi
        qm destroy "${VMID}" >>${LOGFILE} 2>&1
      fi
    elif [[ "${VMTYPE}" == "CT" ]]; then
      if pct status "${VMID}" >>${LOGFILE} 2>&1; then
        if [ "$(pct status "${VMID}" | awk '{print $2}')" == "running" ]; then
          pct stop "${VMID}" >>${LOGFILE} 2>&1
        fi
        pct destroy "${VMID}" >>${LOGFILE} 2>&1
      fi
    fi
  fi
}
check_sudo() {
  # Make sure only root can run our script
  if [[ $EUID -ne 0 ]]; then
    die "This script must be run as root/sudo to modify host settings"
    exit 1
  fi
}
cleanup() {
  popd >/dev/null
  rm -rf "${TEMP_DIR}"
}

pkg_installed() {
  PKG=${1}
  if dpkg -s "${PKG}" 2>/dev/null | grep -Eq "^Status:.*installed.*"; then
    return 0
  else
    return 1
  fi
}

uninstall() {
  info "Purging/Uninstalling LXC container dependencies..."

  if [[ -e /etc/pve/unrestricted.seccomp ]]; then
    info "Removing /etc/pve/unrestricted.seccomp"
    rm -f /etc/pve/unrestricted.seccomp
  fi

  if pkg_installed pivccu-modules-dkms; then
    info "Purging pivccu-modules-dkms"
    apt purge -y pivccu-modules-dkms
  fi

  HEADER_PKGS=
  if [[ "${PLATFORM}" == "aarch64" ]] &&
     command -v armbian-install >/dev/null; then
    # arm based Armbian system
    info "Identified arm64-based Armbian Proxmox VE system..."
    HEADER_PKGS="$(dpkg --get-selections | grep 'linux-image-' | grep -m1 '\sinstall' | sed -e 's/linux-image-\([a-z0-9-]\+\).*/linux-headers-\1/')"
  elif [[ "${PLATFORM}" == "aarch64" ]] &&
       grep -q Raspberry /proc/cpuinfo; then
    # arm based RaspberryPiOS system
    info "Identified arm64-based RaspberryPiOS Proxmox VE system..."
    HEADER_PKGS="raspberrypi-kernel-headers"
  elif [[ "${PLATFORM}" == "x86_64" ]]; then
    # full amd64/x86 based Proxmox VE system
    info "Identified x86-based Proxmox VE system..."
    HEADER_PKGS="pve-headers pve-headers-$(uname -r)"
  else
    warn "Could not identify host system for kernel header uninstall"
  fi
  if [[ -n "${HEADER_PKGS}" ]]; then
    for pkg in ${HEADER_PKGS}; do
      if pkg_installed "${pkg}"; then
        info "Purging ${pkg}"
        apt purge -y "${pkg}"
      fi
    done
  fi

  # remove OS specific device tree stuff
  if pkg_installed pivccu-devicetree-armbian; then
    info "Purging pivccu-devicetree-armbian"
    apt purge -y pivccu-devicetree-armbian
  fi

  if pkg_installed pivccu-modules-raspberrypi; then
    info "Purging pivccu-modules-raspberrypi"
    apt purge -y pivccu-modules-raspberrypi
  fi

  if command -v armbian-install >/dev/null &&
     grep -q Raspberry /proc/cpuinfo &&
     [[ -f /boot/firmware/overlays/pivccu-raspberrypi.dtbo ]]; then

    info "Purging pivccu-raspberrypi.dtbo"
    rm -f /boot/firmware/overlays/pivccu-raspberrypi.dtbo
    sed -i '/^dtoverlay=pivccu-raspberrypi/d' /boot/firmware/config.txt
    sed -i '/^dtoverlay=miniuart-bt/d' /boot/firmware/config.txt
  fi

  # remove pivccu public key and repo
  if [[ -f /etc/apt/sources.list.d/pivccu.list ]]; then
    info "Removing pivccu apt repository"
    rm -f /etc/apt/sources.list.d/pivccu.list
  fi
  if [[ -f /usr/share/keyrings/pivccu-archive-keyring.gpg ]]; then
    info "Removing pivccu apt repository key"
    rm -f /usr/share/keyrings/pivccu-archive-keyring.gpg
  fi

  if pkg_installed pivccu-modules-dkms; then
    info "Uninstall pivccu-modules-dkms"
    apt purge -y pivccu-modules-dkms
  fi

  msg "LXC container host dependencies successfully removed."
  msg "- Only dependencies (kernel modules, etc.) were removed."
  msg "- No LXC container or related disks were removed. Revisit with \"pct list\""
  msg "- Use 'sudo apt autoremove' to remove all unnecessary dependencies again"
  msg "- Reboot your Proxmox system to ensure clean operation without dependencies."
}

update() {
  info "Selecting container..."
  MSG_MAX_LENGTH=0
  while read -r line; do
    # check if container is a openccu kind of
    # container
    CTID=$(echo ${line} | awk '{ print $1 }')
    if grep -q "unrestricted.seccomp" /etc/pve/lxc/${CTID}.conf 2>/dev/null; then
      CTSTATUS=$(echo ${line} | awk '{ print $2 }')
      CTNAME=$(echo ${line} | awk '{ print $3 }')
      if [[ "${CTNAME}" == "mounted" ]]; then
        CTSTATUS="locked"
        CTNAME=$(echo ${line} | awk '{ print $4 }')
      fi
      CONTAINER_MENU+=( "${CTID} ${CTSTATUS}" "${CTNAME}" "OFF" )
      OFFSET=4
      if [[ $((${#CTSTATUS} + ${#CTNAME} + OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
        MSG_MAX_LENGTH=$((${#CTSTATUS} + ${#CTNAME} + OFFSET))
      fi
    fi
  done < <(pct list)

  if [[ -z "${CONTAINER_MENU[*]}" ]]; then
    die "No installed OpenCCU container (CT) identified. The 'update' procedure is only for CT-based installations of OpenCCU!"
  fi

  CONTAINER=
  while [[ -z "${CONTAINER:+x}" ]]; do
    CONTAINER=$(whiptail --title "Container selection" --radiolist \
    "Which container would you like to update?" \
    20 $((MSG_MAX_LENGTH + 14)) 12 \
    "${CONTAINER_MENU[@]}" 3>&1 1>&2 2>&3) || die "aborted"
  done
  CONTAINER_STATUS=$(echo ${CONTAINER} | cut -d' ' -f2)
  CONTAINER=$(echo ${CONTAINER} | cut -d' ' -f1)
  info "Selected '${CONTAINER}' for update."

  # check if container is running
  if [[ "${CONTAINER_STATUS}" != "stopped" ]]; then
    die "Container is ${CONTAINER_STATUS}. Please shutdown with 'pct shutdown ${CONTAINER}' first."
  fi

  # set the VMTYPE we are going to update
  VMTYPE="CT"

  # select target openccu version
  select_version version url

  # Download OpenCCU ova archive
  info "Downloading disk image..."
  # shellcheck disable=SC2154
  wget -q --show-progress "${url}"
  echo -en "\e[1A\e[0K" #Overwrite output from wget
  FILE=$(basename "${url}")

  # final update question
  # shellcheck disable=SC2154
  if ! whiptail --title "Update confirnation" \
                --yesno "During the next steps the rootfs of the '${CONTAINER}' container will be updated to version ${version}. All user configuration will be preserved, but you are requested to perform a backup before you continue.\n\nDo you want to continue and perform the update now?" \
                11 78; then
    die "aborting"
  fi

  # make sure to mount ct
  ROOTFS_PATH=$(pct mount ${CONTAINER} | awk '{print $5}' | xargs)
  if ! mountpoint -q "${ROOTFS_PATH}"; then
    pct unmount ${CONTAINER}
    die "Could not mount rootfs of container ${CONTAINER}"
  fi

  # check if VERSION file contains a valid reference to lxc
  OLD_VERSION=$(grep "VERSION=" ${ROOTFS_PATH}/VERSION 2>/dev/null | cut -d= -f2)
  if [[ -z "${OLD_VERSION}" ]] ||
    ! grep -q "PLATFORM=lxc" ${ROOTFS_PATH}/VERSION 2>/dev/null; then
    pct unmount ${CONTAINER}
    die "Container ${CONTAINER} does not seem to have a valid OpenCCU rootfs path"
  fi

  # start to perform update
  info "Performing update from ${OLD_VERSION} to ${version}. DO NOT INTERRUPT!"

  # check if ${ROOTFS_PATH}/usr/local is currently a mountpoint and if so unmount it
  info "Unmounting userfs..."
  if mountpoint -q "${ROOTFS_PATH}/usr/local"; then
    umount ${ROOTFS_PATH}/usr/local
    if mountpoint -q "${ROOTFS_PATH}/usr/local"; then
      die "Could not unmount ${ROOTFS_PATH}/usr/local"
    fi
  fi

  # clear old rootfs
  info "Wiping old rootfs..."
  shopt -s dotglob
  rm -rf --one-file-system ${ROOTFS_PATH:?}/*

  # unarchive new rootfs
  info "Updating rootfs..."
  tar --numeric-owner -xpf "${FILE}" -C "${ROOTFS_PATH}"

  # unmount rootfs again
  pct unmount ${CONTAINER}

  info "Completed update of '${CONTAINER}' container successfully."
  msg "- Start container via \"pct start ${CONTAINER}\""
  msg "- Access console via \"pct console ${CONTAINER}\""
}

select_version() {

  # define the download archive end pattern
  if [[ "${VMTYPE}" == "VM" ]]; then

    case "${PLATFORM}" in
      x86_64)
        ENDSWITH=".ova"
      ;;
      aarch64)
        ENDSWITH="generic-aarch64.zip"
      ;;
    esac
  else
    case "${PLATFORM}" in
      x86_64)
        ENDSWITH="lxc_amd64.tar.xz"
        CTARCH="amd64"
      ;;
      aarch64)
        ENDSWITH="lxc_arm64.tar.xz"
        CTARCH="arm64"
      ;;
      arm*)
        ENDSWITH="lxc_arm.tar.xz"
        CTARCH="armhf"
      ;;
    esac
  fi

  # Select OpenCCU ova version
  info "Getting available OpenCCU versions..."
  RELEASES=$(cat<<EOF | python3
import requests
import os
import re
url = "https://api.github.com/repos/OpenCCU/OpenCCU/releases"
r = requests.get(url).json()
if "message" in r:
    print("ERROR")
    exit()
num = 0
for release in r:
    if release["prerelease"] or release["tag_name"] == "snapshots":
      continue
    for asset in release["assets"]:
        if asset["name"].endswith("${ENDSWITH}") == True:
            image_url = asset["browser_download_url"]
            name = asset["name"]
            version = re.findall('OpenCCU-(\\\\d+\\\\.\\\\d+\\\\.\\\\d+\\\\.\\\\d+(?:-[0-9a-f]{6})?)-?.*\\\\.', name)
            if len(version) > 0 and num < 5:
                print(version[0] + ' release ' + image_url)
                num = num + 1
            break
EOF
  )
  if [[ "${RELEASES}" == "ERROR" ]]; then
    die "GitHub has returned an error. A rate limit may have been applied to your connection. Try again later."
  fi

  SNAPSHOTS=$(cat<<EOF | python3
import requests
import os
import re
url = "https://api.github.com/repos/OpenCCU/OpenCCU/releases/tags/snapshots"
r = requests.get(url).json()
if "message" in r:
    print("ERROR")
    exit()
for asset in r["assets"]:
    if asset["name"].endswith("${ENDSWITH}") == True:
        image_url = asset["browser_download_url"]
        name = asset["name"]
        version = re.findall('OpenCCU-(\\\\d+\\\\.\\\\d+\\\\.\\\\d+\\\\.\\\\d+(?:-[0-9a-f]{6})?)-?.*\\\\.', name)
        if len(version) > 0:
          print(version[0] + ' snapshot ' + image_url)
        break
EOF
  )

  if [[ "${SNAPSHOTS}" == "ERROR" ]]; then
    die "GitHub has returned an error. A rate limit may have been applied to your connection. Try again later."
  fi

  if [[ -z "${RELEASES}${SNAPSHOTS}" ]]; then
    die "No OpenCCU release or snapshot build for '${PLATFORM}' PVE version found."
  fi

  if [[ -n "${RELEASES}" ]] && [[ -n "${SNAPSHOTS}" ]]; then
    RELEASES+=$'\n'${SNAPSHOTS}
  elif [[ -n "${SNAPSHOTS}" ]]; then
    RELEASES=${SNAPSHOTS}
  fi
  MSG_MAX_LENGTH=0
  RELEASES_MENU=()
  i=0
  while read -r line; do
    VERSION=$(echo "${line}" | cut -d' ' -f1)
    ITEM=$(echo "${line}" | cut -d' ' -f2)
    OFFSET=20
    if [[ $((${#ITEM} + OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
      MSG_MAX_LENGTH=$((${#ITEM} + OFFSET))
    fi
    RELEASES_MENU+=("${VERSION}" " ${ITEM}")
    ((i=i+1))
  done < <(echo "${RELEASES}")

  RELEASE=$(whiptail --title "Select OpenCCU Version" \
                     --menu \
                       "Select OpenCCU version to install:\n\n" \
                       16 $((MSG_MAX_LENGTH + 23)) 6 \
                       "${RELEASES_MENU[@]}" 3>&1 1>&2 2>&3) || exit

  # extract URL from RELEASES
  prefix=${RELEASES%%"$RELEASE"*}
  URL=$(echo ${RELEASES:${#prefix}} | cut -d' ' -f3)
  info "Selected ${RELEASE} as target ${VMTYPE} version"

  eval ${1}="${RELEASE}"
  eval ${2}="${URL}"
}

msg "OpenCCU Proxmox installation script v${VERSION}"
msg "Copyright (c) 2022-2025 Jens Maus <mail@jens-maus.de>"
msg ""

# create temp dir
TEMP_DIR=$(mktemp -d)
pushd "${TEMP_DIR}" >/dev/null

# remove existing log
rm -f "${LOGFILE}"

# check if this is a valid PVE environment host or not
if [[ ! -d /etc/pve ]]; then
  die "This script must be executed on a Proxmox VE host system."
fi

# check that this script is run as root/sudo
check_sudo

# PVE platform
PLATFORM=$(uname -m)

# when executing with "uninstall" remove/purge all config files
# and dependency packages
if [[ "${1-}" == "uninstall" ]]; then
  if ! whiptail --title "Host dependency uninstall" \
	        --yesno "You are about to uninstall all LXC related host packages dependencies. This might require to manually reboot your Proxmox system afterwards.\n\nDo you want to continue?" \
                10 78; then
    die "aborting"
  fi
  uninstall
  exit 0
elif [[ "${1-}" == "update" ]]; then
  update
  exit 0
fi

VMTYPE=$(whiptail --title "Virtual machine type selection" \
	          --radiolist "Please select the virtual machine type you want OpenCCU to be installed:" \
		    16 46 6 \
		    "VM" "(OVA) Full Virtual Machine" ON \
		    "CT" "(LXC) Lightweight LXC container" OFF \
                    3>&1 1>&2 2>&3) || exit

info "Using ${VMTYPE} as target virtual machine type"

if [[ "${VMTYPE}" == "CT" ]]; then

  text=$(cat <<EOF
When running OpenCCU as a LXC container, the Proxmox host system
requires certain dependencies (e.g. kernel modules) to be installed.
During the next steps, correct installation of these dependencies is
checked and packages might get installed which require a manual reboot
of your Proxmox system afterwards. Please note, that if you want to
uninstall these dependencies later you can run the install script
with the 'uninstall' parameter appended.

Do you want to continue now?
EOF
)

  if ! whiptail --title "Host dependency check+installation" \
                --yesno "${text}" \
                15 78; then
    die "aborting"
  fi

  info "Checking/Installing host package dependencies..."

  # check that all necessary host packages are installed
  if ! pkg_installed wget; then
    apt install -y wget
  fi
  if ! pkg_installed ca-certificates; then
    apt install -y ca-certificates
  fi
  if ! pkg_installed build-essential; then
    apt install -y build-essential
  fi
  if ! pkg_installed bison; then
    apt install -y bison
  fi
  if ! pkg_installed flex; then
    apt install -y flex
  fi
  if ! pkg_installed libssl-dev; then
    apt install -y libssl-dev
  fi
  if ! pkg_installed gpg; then
    apt install -y gpg
  fi

  # use gpg to dearmor the pivccu public key
  wget -qO - https://apt.pivccu.de/piVCCU/public.key | gpg --batch --yes --dearmor -o /usr/share/keyrings/pivccu-archive-keyring.gpg
  sh -c 'echo "deb [signed-by=/usr/share/keyrings/pivccu-archive-keyring.gpg] https://apt.pivccu.de/piVCCU stable main" >/etc/apt/sources.list.d/pivccu.list'
  apt update

  # install kernel headers
  HEADER_PKGS=
  if [[ "${PLATFORM}" == "aarch64" ]] &&
     command -v armbian-install >/dev/null; then
    # arm based Armbian system
    info "Identified arm64-based Armbian Proxmox VE system..."
    HEADER_PKGS="$(dpkg --get-selections | grep 'linux-image-' | grep -m1 '\sinstall' | sed -e 's/linux-image-\([a-z0-9-]\+\).*/linux-headers-\1/')"
  elif [[ "${PLATFORM}" == "aarch64" ]] &&
       grep -q Raspberry /proc/cpuinfo; then
    # arm based RaspberryPiOS system
    info "Identified arm64-based RaspberryPiOS Proxmox VE system..."
    HEADER_PKGS="raspberrypi-kernel-headers"
  elif [[ "${PLATFORM}" == "x86_64" ]]; then
    # full amd64/x86 based Proxmox VE system
    info "Identified x86-based Proxmox VE system..."
    HEADER_PKGS="pve-headers pve-headers-$(uname -r)"
  else
    warn "Could not identify host platform for kernel header install"
  fi
  if [[ -n "${HEADER_PKGS}" ]]; then
    for pkg in ${HEADER_PKGS}; do
      if ! pkg_installed "${pkg}"; then
        info "Installing ${pkg}"
        apt install -y "${pkg}"
      fi
    done
  fi

  # install OS specific device tree stuff if RPI-RF-MOD
  # or HM-MOD-RPI-PCB will be connected to the GPIO
  if [[ "${PLATFORM}" == "aarch64" ]] &&
     ! pkg_installed pivccu-devicetree-armbian &&
     ! pkg_installed pivccu-modules-raspberrypi &&
     [[ ! -f /boot/firmware/overlays/pivccu-raspberrypi.dtbo ]]; then

     text=$(cat <<EOF
If you want to use a RPI-RF-MOD or HM-MOD-RPI-PCB on the GPIO port
of the ARM-based host hardware of this system, dedicated device tree
overlay modules have to be installed. If you, however, don't plan to
put a HomeMatic RF module on the GPIO bus but want to use a USB
connected RF module only (e.g. HmIP-RFUSB) you can (and should) skip
this step.

Do you want to install the device tree overlays for GPIO use?
EOF
)

    if whiptail --title "GPIO module/overlay installation check" \
                --yesno "${text}" \
                15 78; then

      if command -v armbian-install >/dev/null; then
        if grep -q Raspberry /proc/cpuinfo; then
          if [[ ! -f /boot/firmware/overlays/pivccu-raspberrypi.dtbo ]]; then
            info "Downloading pivccu-modules-raspberrypi"
            (cd "${TEMP_DIR}" && apt download pivccu-modules-raspberrypi)
            info "Extracting pivccu-modules-raspberrypi"
            (cd "${TEMP_DIR}" && ar x pivccu-modules-raspberrypi_*_all.deb)
            info "Extracting pivccu-raspberry.dtbo"
            (cd "${TEMP_DIR}" && tar -C "${TEMP_DIR}" -xf data.tar.xz ./var/lib/piVCCU/dtb/overlays/pivccu-raspberrypi.dtbo)
            info "Installing dtbo to /boot/firmware/overlays/"
            cp "${TEMP_DIR}/var/lib/piVCCU/dtb/overlays/pivccu-raspberrypi.dtbo" /boot/firmware/overlays/
            echo "dtoverlay=pivccu-raspberrypi" >>/boot/firmware/config.txt

            # on Pi < 5 we have to add miniuart-bt dtoverlay
            if ! grep -Eq "Raspberry Pi 5" /proc/cpuinfo; then
              echo "dtoverlay=miniuart-bt" >>/boot/firmware/config.txt
            fi
          fi
        else
          info "Installing pivccu-devicetree-armbian"
          DEBIAN_FRONTEND=noninteractive apt install -y pivccu-devicetree-armbian
        fi
      elif grep -q Raspberry /proc/cpuinfo; then
        info "Installing pivccu-modules-raspberrypi"
        DEBIAN_FRONTEND=noninteractive apt install -y pivccu-modules-raspberrypi
      fi
    else
      info "Skipped GPIO overlay module installation step"
    fi
  fi

  # Install & Build homematic kernel modules
  if ! pkg_installed pivccu-modules-dkms; then
    info "Building and installing homematic kernel modules..."
    DEBIAN_FRONTEND=noninteractive apt install -y pivccu-modules-dkms
    service pivccu-dkms start
  fi

  # create /etc/pve/unrestricted.seccomp for CTs
  # which should have full hardware/kernel access
  if [[ ! -e /etc/pve/unrestricted.seccomp ]]; then
    cat <<EOF >/etc/pve/unrestricted.seccomp
2
blacklist
# v2 allows comments after the second line, with '#' in first column,
# blacklist will allow syscalls by default
EOF
  fi

  # check if cgroup cpuset and memory is enabled and if not try
  # to enable them (if this is a RaspberryPi system)
  info "Checking correct cgroup kernel settings..."
  CGROUP_CPU=$( (grep -m1 ^cpuset /proc/cgroups 2>/dev/null || true) | cut -f4)
  CGROUP_MEM=$( (grep -m1 ^memory /proc/cgroups 2>/dev/null || true) | cut -f4)
  if [[ "${CGROUP_CPU}" != "1" ]] || [[ "${CGROUP_MEM}" != "1" ]]; then
    # check if this is a RaspberryPi system and try to enable
    # all necessary cgroup sets
    if [[ -f /boot/firmware/cmdline.txt ]] ||
       [[ -f /boot/cmdline.txt ]]; then

      # select the correct cmdfile
      if [[ -f /boot/firmware/cmdline.txt ]]; then
        cmdfile=/boot/firmware/cmdline.txt
      else
        cmdfile=/boot/cmdline.txt
      fi

      change=0
      # check if cmdline.txt contains the necessary cgroup statements
      if [[ "${CGROUP_CPU}" != "1" ]] &&
         ! grep -q "cgroup_enable=cpuset" ${cmdfile}; then
        sed -i '1 s/$/ cgroup_enable=cpuset/' ${cmdfile}
        change=1
      fi
      if [[ "${CGROUP_MEM}" != "1" ]] &&
         ! grep -q "cgroup_enable=memory" ${cmdfile}; then
        sed -i '1 s/$/ cgroup_enable=memory cgroup_memory=1/' ${cmdfile}
        change=1
      fi

      if [[ ${change} -eq 1 ]]; then
        warn "${cmdfile} modified. A reboot is required before container can be used."
      else
        warn "${cmdfile} is already modified, but the host system is still missing cgroup settings. Please perform a reboot or check the kernel cmdline settings of your bootloader."
      fi
    else
      warn "This host system is missing cgroup settings for optimal LXC use. Please add 'cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1' to the kernel commandline of your bootloader and reboot."
    fi
  fi

fi

# ask for the openccu version
select_version RELEASE URL

# Select storage location
info "Selecting storage location"
MSG_MAX_LENGTH=0

if [[ "${VMTYPE}" == "CT" ]]; then
  CONTENT_TYPE="rootdir"
else
  CONTENT_TYPE="images"
fi

while read -r line; do
  TAG=$(echo "${line}" | awk '{print $1}')
  TYPE=$(echo "${line}" | awk '{printf "%-10s", $2}')
  FREE=$(echo "${line}" | numfmt --field 4-6 --from-unit=K --to=iec --format %.2f | awk '{printf( "%9sB", $6)}')
  ITEM="  Type: ${TYPE} Free: ${FREE} "
  OFFSET=2
  if [[ $((${#ITEM} + OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
    MSG_MAX_LENGTH=$((${#ITEM} + OFFSET))
  fi
  STORAGE_MENU+=( "${TAG}" "${ITEM}" "OFF" )
done < <(pvesm status -content ${CONTENT_TYPE} | awk 'NR>1')
if [ $((${#STORAGE_MENU[@]}/3)) -eq 0 ]; then
  warn "'Disk image' needs to be selected for at least one storage location."
  die "Unable to detect valid storage location."
elif [ $((${#STORAGE_MENU[@]}/3)) -eq 1 ]; then
  STORAGE=${STORAGE_MENU[0]}
else
  while [ -z "${STORAGE:+x}" ]; do
    STORAGE=$(whiptail --title "Storage Pools" --radiolist \
    "Which storage pool you would like to use for the container?\n\n" \
    16 $((MSG_MAX_LENGTH + 23)) 6 \
    "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit
  done
fi
info "Using '${STORAGE}' for storage location."

# Select storage size
info "Selecting virtual disk size"
DISK_MINSIZE=4
DISK_CURSIZE=6
while true; do
  if DISK_SIZE=$(whiptail --inputbox "Please enter the virtual disk size (GB) for the OpenCCU ${VMTYPE} (minimum is ${DISK_MINSIZE} GB)" 8 58 ${DISK_CURSIZE} --title "Virtual disk size" 3>&1 1>&2 2>&3); then
    if [[ -z "${DISK_SIZE}" ]]; then
      DISK_SIZE=${DISK_MINSIZE}
    fi
    if ! [[ "${DISK_SIZE}" =~ ^[0-9]+$ ]] || [[ ${DISK_SIZE} -lt ${DISK_MINSIZE} ]]; then
      info "Virtual disk size not allowed to be smaller than ${DISK_MINSIZE} GB."
      sleep 3
      continue
    fi
    info "Chosen virtual disk size is ${DISK_SIZE} GB."
    break
  else
    die "Virtual disk size selection canceled."
  fi
done

# Search+Select HomeMatic USB devices
MSG_MAX_LENGTH=0
USB_MENU=()
USB_DEVICE=
if [[ "${VMTYPE}" == "VM" ]]; then
  while read -r line; do
    ID=$(echo "${line}" | cut -d' ' -f6)
    if [[ "${ID}" == "1b1f:c020" ]] ||     # HmIP-RFUSB
       [[ "${ID}" == "10c4:8c07" ]] ||     # HB-RF-USB-2
       [[ "${ID}" == "0403:6f70" ]] ||     # HB-RF-USB
       [[ "${ID}" == "1b1f:c00f" ]]; then  # HM-CFG-USB-2
      ITEM=$(echo "${line}" | cut -d' ' -f7-)
      OFFSET=2
      if [[ $((${#ITEM} + OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
        MSG_MAX_LENGTH=$((${#ITEM} + OFFSET))
      fi
      USB_MENU+=( "${ID}" "${ITEM}" "OFF" )
    fi
  done < <(lsusb)
  if [[ -n "${USB_MENU[*]}" ]]; then
    info "Selecting HomeMatic-RF USB devices"
    USB_DEVICE=$(whiptail --title "HomeMatic-RF USB devices" --radiolist \
    "Which HomeMatic-RF USB device should be bind to OpenCCU ${VMTYPE}?\n\n" \
    16 $((MSG_MAX_LENGTH + 23)) 6 \
    "${USB_MENU[@]}" 3>&1 1>&2 2>&3) || exit

    if [[ -n "${USB_DEVICE}" ]]; then
      info "Using '${USB_DEVICE}' as HomeMatic-RF device on usb0."
    else
      info "Using no USB device as HomeMatic-RF device."
    fi
  else
    info "No HomeMatic-RF USB device found."
  fi
fi

# Get next free VM/LXC ID and ask user
NEXTID=$(pvesh get /cluster/nextid)
while true; do
  if VMID=$(whiptail --inputbox "Please enter the ID for the OpenCCU ${VMTYPE}\n(next free ID is: ${NEXTID})" 8 58 ${NEXTID} --title "Virtual Machine ID" 3>&1 1>&2 2>&3); then
    if [[ -z "${VMID}" ]]; then
      VMID=${NEXTID}
    fi
    if ! [[ "${VMID}" =~ ^[1-9][0-9]+$ ]] || [[ ${VMID} -lt 100 ]]; then
      info "ID '${VMID}' is not a number or smaller than 100."
      sleep 3
      continue
    fi
    if pct status "${VMID}" &>/dev/null || qm status "${VMID}" &>/dev/null; then
      info "ID '${VMID}' already in use."
      sleep 3
      continue
    fi
    info "Selected ${VMID} as ${VMTYPE} ID."
    break
  else
    die "${VMTYPE} ID selection canceled."
  fi
done

# Download OpenCCU ova archive
info "Downloading disk image..."
wget -q --show-progress "${URL}"
echo -en "\e[1A\e[0K" #Overwrite output from wget
FILE=$(basename "${URL}")

# main installation steps
if [[ "${VMTYPE}" == "VM" ]]; then

  # Extract OpenCCU disk image
  info "Extracting disk image..."
  if [[ "${PLATFORM}" == "aarch64" ]]; then
    unzip "${FILE}" '*.img*'
    IMG_FILE="$(ls OpenCCU-*-aarch64.img)"
    if [[ -f "${IMG_FILE}.sha256" ]]; then
      info "Verifying download checksum..."
      sha256sum -c "${IMG_FILE}.sha256" >>${LOGFILE}
    fi
  else
    tar xf "${FILE}"
    IMG_FILE="OpenCCU.ovf"
  fi

  # Identify target format
  IMPORT_OPT=
  STORAGE_TYPE=$(pvesm status -storage "${STORAGE}" | awk 'NR>1 {print $2}')
  if [[ "${STORAGE_TYPE}" == "dir" ]] ||
     [[ "${STORAGE_TYPE}" == "nfs" ]] ||
     [[ "${PLATFORM}" == "aarch64" ]]; then
    IMPORT_OPT="-format qcow2"
  fi

  # Create VM using the "importovf" or use manual create
  if [[ "${PLATFORM}" == "aarch64" ]]; then
    info "Creating VM ${VMID}..."
    qm create ${VMID} -bios ovmf \
                      -cores 2 \
                      -memory 1024 \
                      -name "OpenCCU"

    # create EFI disk
    info "Allocating EFI disk..."
    pvesm alloc "${STORAGE}" "${VMID}" "vm-${VMID}-disk-0.qcow2" 64M >>${LOGFILE}

    # set efi disk
    info "Setting EFI disk parameter..."
    qm set "${VMID}" -efidisk0 "${STORAGE}:${VMID}/vm-${VMID}-disk-0.qcow2,efitype=4m,size=64M" >>${LOGFILE}

    # import img file
    info "Importing image..."
    qm importdisk "${VMID}" "${IMG_FILE}" "${STORAGE}" ${IMPORT_OPT}

    # get disk id/num
    DISK_ID="${STORAGE}:${VMID}/vm-${VMID}-disk-1.qcow2"

    # Change settings of VM
    info "Modifying VM setting..."
    qm set "${VMID}" \
      --acpi 1 \
      --agent 1,fstrim_cloned_disks=1,type=virtio \
      --hotplug network,disk,usb \
      --description "[![OpenCCU](https://raw.githubusercontent.com/OpenCCU/OpenCCU/master/release/logo.png 'OpenCCU')](https://openccu.de)" \
      --net0 virtio,bridge=vmbr0,firewall=1 \
      --onboot 1 \
      --tablet 1 \
      --ostype l26 \
      --scsihw virtio-scsi-single \
      --scsi0 "${DISK_ID},discard=on,iothread=1" >>${LOGFILE} 2>&1
  else
    info "Importing OVA..."
    qm importovf "${VMID}" \
      "${IMG_FILE}" \
      "${STORAGE}" \
      ${IMPORT_OPT} >>${LOGFILE} 2>&1

    # get the assigned disk id after the import
    DISK_ID=$(qm config "${VMID}" 2>>${LOGFILE} | grep -e "^\(sata\|scsi\).:" | cut -d' ' -f2 | cut -d',' -f1)
    if [[ -z "${DISK_ID}" ]]; then
      die "could not retrieve disk id from vm config"
    fi

    # Change settings of VM
    info "Modifying VM setting..."
    qm set "${VMID}" \
      --acpi 1 \
      --vcpus 2 \
      --numa 1 \
      --agent 1,fstrim_cloned_disks=1,type=virtio \
      --hotplug network,disk,usb,cpu,memory \
      --description "[![OpenCCU](https://raw.githubusercontent.com/OpenCCU/OpenCCU/master/release/logo.png 'OpenCCU')](https://openccu.de)" \
      --net0 virtio,bridge=vmbr0,firewall=1 \
      --onboot 1 \
      --tablet 0 \
      --watchdog model=i6300esb,action=reset \
      --ostype l26 \
      --scsihw virtio-scsi-single \
      --delete sata0 \
      --scsi0 "${DISK_ID},discard=on,iothread=1" >>${LOGFILE} 2>&1
  fi

  # Set boot order
  qm set "${VMID}" \
    --boot order=scsi0 >>${LOGFILE} 2>&1

  # Resize scsi0 disk
  info "Resizing virtual disk to ${DISK_SIZE} GB..."
  sync
  qm resize "${VMID}" scsi0 "${DISK_SIZE}G" >>${LOGFILE}

  # Identify+Set known USB-based RF module devices
  if [[ -n "${USB_DEVICE}" ]]; then
    info "Setting ${USB_DEVICE} as usb0..."
    qm set "${VMID}" --usb0 host="${USB_DEVICE}",usb3=1 >>${LOGFILE} 2>&1
  fi

elif [[ "${VMTYPE}" == "CT" ]]; then
  info "Creating CT..."

  # create initial CT
  pct create "${VMID}" "${FILE}" \
    --arch "${CTARCH}" \
    --storage "${STORAGE}" \
    --cores 2 \
    --onboot 1 \
    --net0 name=eth0,bridge=vmbr0,ip=dhcp \
    --unprivileged 0 \
    --ostype unmanaged \
    --memory 1024 \
    --rootfs volume=${STORAGE}:1,mountoptions=noatime \
    --mp0 volume=${STORAGE}:${DISK_SIZE},mp=/usr/local,mountoptions=noatime \
    --description "[![OpenCCU](https://raw.githubusercontent.com/OpenCCU/OpenCCU/master/release/logo.png 'OpenCCU')](https://openccu.de)" \
    --hostname "OpenCCU"

  # patching container config
  info "Patching CT config..."
  cat <<EOF >>"/etc/pve/lxc/${VMID}.conf"
lxc.apparmor.profile: unconfined
lxc.seccomp.profile: /etc/pve/unrestricted.seccomp
lxc.cap.drop:
lxc.mount.auto: proc:rw sys:rw cgroup:rw
lxc.cgroup2.devices.allow: c *:* rw
lxc.mount.entry: /lib/modules lib/modules none ro,bind
lxc.hook.pre-start: sh -c "sysctl -q -w kernel.sched_rt_runtime_us=-1"
EOF
fi

info "Completed Successfully. New ${VMTYPE} is: \e[1m${VMID} (OpenCCU)\e[0m."
