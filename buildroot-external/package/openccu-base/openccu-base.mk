################################################################################
#
# OpenCCU-Base package
#
################################################################################

OPENCCU_BASE_VERSION = d812681df82b751e4fda80db065315452667e15d
OPENCCU_BASE_COMPAT_VERSION = 3.89.5
OPENCCU_BASE_SITE = https://github.com/OpenCCU/OpenCCU-Base
OPENCCU_BASE_SITE_METHOD = git
OPENCCU_BASE_LICENSE = HMSL-2.0 and mixed
OPENCCU_BASE_LICENSE_FILES = licenses/licenses.md
OPENCCU_BASE_DEPENDENCIES = host-python3 host-python-html2text
OPENCCU_BASE_BUILD_TARGET = package

OPENCCU_BASE_CONF_OPTS = \
	-DDEPLOY_TO_REPO=OFF \
	-DBUILD_TCL_MODULES=ON \
	-DBUILD_WEBUI_AND_DEVICETYPES=ON \
	-DHAS_USB_SUPPORT=ON \
	-DROOTFS_DIR=$(@D)/buildroot-rootfs

ifeq ($(BR2_aarch64),y)
OPENCCU_BASE_TARGET_PLATFORM = aarch64-linux-gnu
endif

ifeq ($(BR2_x86_64),y)
OPENCCU_BASE_TARGET_PLATFORM = x86_64-linux-gnu
endif

OPENCCU_BASE_CONF_OPTS += \
	-DTARGET_PLATFORM=$(OPENCCU_BASE_TARGET_PLATFORM) \
	-DCROSS_PREFIX=$(TARGET_CROSS)

ifeq ($(BR2_PACKAGE_OPENCCU_BASE_RF_PROTOCOL_HM_ONLY),y)
OPENCCU_BASE_RF_PROTOCOL=HM
endif

ifeq ($(BR2_PACKAGE_OPENCCU_BASE_RF_PROTOCOL_HMIP_ONLY),y)
OPENCCU_BASE_RF_PROTOCOL=HMIP
endif

ifeq ($(BR2_PACKAGE_OPENCCU_BASE_RF_PROTOCOL_HM_HMIP),y)
OPENCCU_BASE_RF_PROTOCOL=HM_HMIP
endif

define OPENCCU_BASE_INSTALL_TARGET_CMDS
	cp -a $(@D)/buildroot-rootfs/. $(TARGET_DIR)/

	$(INSTALL) -d -m 0755 $(TARGET_DIR)/bin
	for file in ReGaHss SetInterfaceClock crypttool eq3configcmd eq3configd hs485d hs485dLoader hss_led multimacd rfd ssdpd; do \
		if [ -f "$(@D)/bin/$(OPENCCU_BASE_TARGET_PLATFORM)/$$file" ]; then \
			$(INSTALL) -m 0755 "$(@D)/bin/$(OPENCCU_BASE_TARGET_PLATFORM)/$$file" "$(TARGET_DIR)/bin/$$file"; \
		fi; \
	done

	$(INSTALL) -d -m 0755 $(TARGET_DIR)/$(BR2_ROOTFS_LIB_DIR)
	for lib in libLanDeviceUtils.so libUnifiedLanComm.so libXmlRpc.so libelvutils.so libeq3config.so libhsscomm.so libxmlparser.so; do \
		if [ -f "$(@D)/lib/$(OPENCCU_BASE_TARGET_PLATFORM)/$$lib" ]; then \
			$(INSTALL) -m 0644 "$(@D)/lib/$(OPENCCU_BASE_TARGET_PLATFORM)/$$lib" "$(TARGET_DIR)/$(BR2_ROOTFS_LIB_DIR)/$$lib"; \
		fi; \
	done

	if [ -d "$(@D)/usr/lib/tcl8.6/homematic" ]; then \
		cp -a "$(@D)/usr/lib/tcl8.6/homematic" "$(TARGET_DIR)/usr/lib/tcl8.6/"; \
	fi

	cp -a $(@D)/etc/. $(TARGET_DIR)/etc/
	cp -a $(@D)/firmware/. $(TARGET_DIR)/firmware/
	cp -a $(@D)/opt/. $(TARGET_DIR)/opt/
	cp -a $(@D)/usr/. $(TARGET_DIR)/usr/
	cp -a $(@D)/www/. $(TARGET_DIR)/www/

	ln -snf /tmp/EULA.de $(TARGET_DIR)/www/rega/EULA.de
	ln -snf /tmp/EULA.en $(TARGET_DIR)/www/rega/EULA.en

	grep -rl 'XXX-WEBUI-VERSION-XXX' $(TARGET_DIR)/www | xargs sed -i 's/XXX-WEBUI-VERSION-XXX/$(PRODUCT_VERSION)/g' || true
	grep -rl 'XXX-PRODUCT-XXX' $(TARGET_DIR)/www | xargs sed -i 's/XXX-PRODUCT-XXX/$(PRODUCT)/g' || true
endef

define OPENCCU_BASE_FINALIZE_TARGET
	# setup /usr/local/etc/config
	mkdir -p $(TARGET_DIR)/usr/local/etc/config
	rm -rf $(TARGET_DIR)/etc/config
	ln -snf ../usr/local/etc/config $(TARGET_DIR)/etc/

	# shadow file setup
	touch $(TARGET_DIR)/usr/local/etc/config/shadow
	chmod 0640 $(TARGET_DIR)/usr/local/etc/config/shadow
	rm -f $(TARGET_DIR)/etc/shadow
	ln -snf config/shadow $(TARGET_DIR)/etc/

	# relink /run to /var/run
	rm -rf $(TARGET_DIR)/run $(TARGET_DIR)/var/run
	mkdir -p $(TARGET_DIR)/var/run
	ln -snf var/run $(TARGET_DIR)/

	# relink resolv.conf to /var/etc
	rm -f $(TARGET_DIR)/etc/resolv.conf
	ln -snf ../var/etc/resolv.conf $(TARGET_DIR)/etc/

	# remove the local wpa_supplicant config
	rm -f $(TARGET_DIR)/etc/wpa_supplicant.conf

	# relink the NUT config files
	rm -f $(TARGET_DIR)/etc/upssched.conf.sample
	ln -snf config/nut/upssched.conf $(TARGET_DIR)/etc/
	rm -f $(TARGET_DIR)/etc/upsmon.conf.sample
	ln -snf config/nut/upsmon.conf $(TARGET_DIR)/etc/
	rm -f $(TARGET_DIR)/etc/upsd.conf.sample
	ln -snf config/nut/upsd.conf $(TARGET_DIR)/etc/
	rm -f $(TARGET_DIR)/etc/upsd.users.sample
	ln -snf config/nut/upsd.users $(TARGET_DIR)/etc/
	rm -f $(TARGET_DIR)/etc/ups.conf.sample
	ln -snf config/nut/ups.conf $(TARGET_DIR)/etc/
	rm -f $(TARGET_DIR)/etc/nut.conf.sample
	ln -snf config/nut/nut.conf $(TARGET_DIR)/etc/

	# link timezone information files
	ln -snf config/localtime $(TARGET_DIR)/etc/
	ln -snf config/timezone $(TARGET_DIR)/etc/

	# link /etc/firmware to /lib/firmware
	ln -snf ../lib/firmware $(TARGET_DIR)/etc/

	# link /bin/tclsh to /usr/bin/tclsh
	ln -snf /usr/bin/tclsh $(TARGET_DIR)/bin/tclsh

	# fix permissions
	chmod 755 $(TARGET_DIR)/www/config/fileupload.ccc

	# remove obsolete init.d jobs
	rm -f $(TARGET_DIR)/etc/init.d/S01logging
	rm -f $(TARGET_DIR)/etc/init.d/S20urandom
	rm -f $(TARGET_DIR)/etc/init.d/S01syslogd
	rm -f $(TARGET_DIR)/etc/init.d/S02klogd
	rm -f $(TARGET_DIR)/etc/init.d/S49chronyd

	# remove obsolete config templates
	rm -f $(TARGET_DIR)/etc/config_templates/hmip_networkkey.conf

	# remove obsolete lighttpd config files
	rm -f $(TARGET_DIR)/etc/lighttpd/lighttpd_ssl.conf

	# make sure ReGaHss.* is deleted
	rm -f $(TARGET_DIR)/bin/ReGaHss.*

	# make sure no /etc/ntp.conf is there anymore (chrony used)
	rm -f $(TARGET_DIR)/etc/ntp.conf

	# extract license infos from JAR files
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseForJar.py \
		--packagedir=$(TARGET_DIR)/opt/HMServer \
		--jarfile=HMIPServer.jar \
		--output=$(@D)/HMIPServer.jar-JARLICENSEINFO.txt
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseForJar.py \
		--packagedir=$(TARGET_DIR)/opt/HMServer \
		--jarfile=HMServer.jar \
		--output=$(@D)/HMServer.jar-JARLICENSEINFO.txt
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseForJar.py \
		--packagedir=$(TARGET_DIR)/opt/HmIP \
		--jarfile=hmip-copro-update.jar \
		--output=$(@D)/hmip-copro-update.jar-JARLICENSEINFO.txt
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseForJar.py \
		--packagedir=$(TARGET_DIR)/opt/HMServer/coupling \
		--jarfile=ESHBridge.jar \
		--output=$(@D)/ESHBridge.jar-JARLICENSEINFO.txt

	# create licenseinfo.htm
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseHtml.py \
		--build-dir=$(BUILD_DIR)/../ \
		--jar-license-info=$(@D)/HMIPServer.jar-JARLICENSEINFO.txt \
		--jar-license-info=$(@D)/HMServer.jar-JARLICENSEINFO.txt \
		--jar-license-info=$(@D)/hmip-copro-update.jar-JARLICENSEINFO.txt \
		--jar-license-info=$(@D)/ESHBridge.jar-JARLICENSEINFO.txt \
		--output=$(TARGET_DIR)/www/rega/licenseinfo.htm
endef
TARGET_FINALIZE_HOOKS += OPENCCU_BASE_FINALIZE_TARGET

define OPENCCU_BASE_USERS
	-      -1 hm     -1 * - - -      homematic access group
	-      -1 status -1 * - - -      status access group
	hssled -1 hssled -1 * - - status hss_led user
endef

$(eval $(cmake-package))
