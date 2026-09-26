#!/bin/sh
# shellcheck shell=dash disable=SC2169

echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"

if [ -f /tmp/.runningFirmwareUpdate ]; then
  echo "ERROR: firmware update is currently running"
  exit 1
fi

echo -ne "[1/2] Setting safemode boot... "

if ! mount -o rw,remount /userfs; then
	echo "ERROR (rw remount)"
	exit 1
fi

if ! touch /usr/local/etc/config/safemode; then
	echo "ERROR (touch)"
	exit 1
fi

if ! mount -o ro,remount /userfs; then
	echo "ERROR (ro remount)"
	exit 1
fi

echo "done.<br>"

echo "[2/2] Rebooting..."
/sbin/reboot
