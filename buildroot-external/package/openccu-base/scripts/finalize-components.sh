#!/bin/sh
# Remove service files supplied by board overlays for deselected components.
set -eu
root=$1
config=$2

enabled() {
	grep -qx "BR2_PACKAGE_OPENCCU_BASE_$1=y" "$config"
}

disabled_monitors=""
service() {
	component=$1
	monitors=$2
	shift 2
	if ! enabled "$component" || ! enabled INIT_SCRIPTS; then
		for script in "$@"; do
			rm -f "$root/etc/init.d/$script"
		done
		disabled_monitors="$disabled_monitors $monitors"
	fi
}
service RFD 'rfd rfdEnabled' S61rfd
service MULTIMACD 'multimacd multimacdEnabled' S60multimacd
service HS485D 'hs485d hs485dEnabled' S49hs485d S60hs485d
service HMSERVER 'HMIPServer HMServer' S62HMServer
service REGAHSS 'ReGaHss regaHssEnabled' S70ReGaHss
service EQ3CONFIGD eq3configd S50eq3configd
service SSDPD ssdpd S50ssdpd
service HSS_LED hss_led S00hss_led

if ! enabled INIT_SCRIPTS || { ! enabled RFD && ! enabled HMSERVER && ! enabled REGAHSS && ! enabled WEBUI; }; then
	rm -f "$root/etc/init.d/S49InitInterfaces"
fi

if [ -f "$root/etc/monitrc" ]; then
	awk -v disabled="$disabled_monitors" '
		BEGIN { split(disabled, names); for (i in names) omit[names[i]] = 1 }
		/^check[[:space:]]/ { skip = ($3 in omit) }
		!skip { print }
	' "$root/etc/monitrc" >"$root/etc/monitrc.components"
	cat "$root/etc/monitrc.components" >"$root/etc/monitrc"
	rm -f "$root/etc/monitrc.components"
fi

if ! enabled RFD; then
	rm -f "$root/etc/config_templates/rfd.conf" "$root/etc/rfd.port"
fi
if ! enabled MULTIMACD; then
	rm -f "$root/etc/config_templates/multimacd.conf" "$root/etc/multimacd.conf"
fi
if ! enabled HMSERVER; then
	rm -f "$root/etc/HMServer.conf" "$root/etc/config_templates/log4j2.xml" \
		"$root/etc/config_templates/crRFD.conf"
fi
if ! enabled EQ3CONFIGCMD; then
	rm -f "$root/etc/init.d/S58LGWFirmwareUpdate" "$root/etc/init.d/S59SetLGWKey"
fi

if ! enabled CONFIG_TEMPLATES; then
	for file in crypttool.cfg crRFD.conf log4j2.xml rfd.conf multimacd.conf; do
		rm -f "$root/etc/config_templates/$file"
	done
fi
