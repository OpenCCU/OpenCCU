#!/bin/sh
# shellcheck shell=dash disable=SC2169

echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"

if [ -f /tmp/.runningFirmwareUpdate ]; then
  echo "ERROR: firmware update is currently running"
  exit 1
fi

echo -ne "[1/2] Scheduling reset of all admin passwords (WebUI + OS) for next boot... "

if ! mount -o rw,remount /userfs; then
	echo "ERROR (rw remount)"
	exit 1
fi

# the actual reset is performed by /etc/init.d/S71CheckAdminPasswordReset
# (/bin/resetAdminPasswords) in the normal system since ReGaHss is required
if ! touch /userfs/.doAdminPasswordReset; then
	echo "ERROR (touch)"
	mount -o ro,remount /userfs
	exit 1
fi

if ! mount -o ro,remount /userfs; then
	echo "ERROR (ro remount)"
	exit 1
fi

echo "done.<br>"

echo "[2/2] Rebooting...<br>"
echo "Please login to the WebUI afterwards and set new passwords immediately!"
/sbin/reboot
