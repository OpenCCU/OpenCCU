#!/bin/sh
# shellcheck shell=dash disable=SC2169

echo -ne "Content-Type: text/html; charset=iso-8859-1\r\n\r\n"

# check the request (CSRF) and claim the recovery action lock
. /lib/librecovery.sh
recovery_cgi_begin

echo -ne "[1/2] Setting network configuration to factory defaults... "

if ! mount -o rw,remount /userfs; then
	echo "ERROR (rw remount)"
	exit 1
fi

if ! rm -rf /usr/local/etc/config/netconfig; then
	echo "ERROR (rm)"
	exit 1
fi

if ! mount -o ro,remount /userfs; then
	echo "ERROR (ro remount)"
	exit 1
fi

echo "done.<br>"

echo "[2/2] Rebooting..."
recovery_reboot
