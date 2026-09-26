################################################################################
#
# OpenCCU-Base package
#
################################################################################

OPENCCU_BASE_VERSION = e27bd998a13f151d8fc8829978343c6b8e2a3f05
OPENCCU_BASE_COMPAT_VERSION = 3.89.11
OPENCCU_BASE_SITE = https://github.com/OpenCCU/OpenCCU-Base
OPENCCU_BASE_SITE_METHOD = git
OPENCCU_BASE_LICENSE = HMSL-2.0, Apache-2.0 (WebUI), \
	GPL-2.0+ (kernel modules), LGPL-2.1 (libraries)
OPENCCU_BASE_LICENSE_FILES = licenses/licenses.md licenses/HMSL2.txt \
	licenses/gpl-2.0.txt licenses/lgpl-2.1.txt
OPENCCU_BASE_ROOTFS_PATCH_DIR = \
	$(OPENCCU_BASE_PKGDIR)/rootfs-patches
OPENCCU_BASE_ENABLE_ROOTFS_PATCHING ?= YES

OPENCCU_BASE_MINIMAL = $(filter y,$(BR2_PACKAGE_OPENCCU_BASE_COMPAT_LIBS_ONLY) $(BR2_PACKAGE_OPENCCU_BASE_LED_ONLY))

OPENCCU_BASE_DEPENDENCIES = \
	$(if $(OPENCCU_BASE_MINIMAL),,\
	host-pkgconf host-python3 host-python-html2text host-tcl \
	libusb openssl tcl)

OPENCCU_BASE_BUILD_OPTS = \
	--target $(if $(BR2_PACKAGE_OPENCCU_BASE_LED_ONLY),hss_led,$(if $(BR2_PACKAGE_OPENCCU_BASE_COMPAT_LIBS_ONLY),compat-libraries,package))

OPENCCU_BASE_CONF_OPTS = \
	-DDEPLOY_TO_REPO=OFF \
	-DHSS_LED_ONLY=$(if $(BR2_PACKAGE_OPENCCU_BASE_LED_ONLY),ON,OFF) \
	-DBUILD_DEFAULT_COMPONENTS=$(if $(OPENCCU_BASE_MINIMAL),OFF,ON) \
	-DBUILD_TCL_MODULES=$(if $(OPENCCU_BASE_MINIMAL),OFF,ON) \
	-DBUILD_WEBUI_AND_DEVICETYPES=$(if $(OPENCCU_BASE_MINIMAL),OFF,ON) \
	-DHAS_USB_SUPPORT=$(if $(OPENCCU_BASE_MINIMAL),OFF,ON) \
	-DROOTFS_DIR=$(@D)/build/rootfs \
	$(if $(OPENCCU_BASE_MINIMAL),,\
	-DOPENCCU_PYTHON_EXECUTABLE=$(HOST_DIR)/bin/python3 \
	-DOPENCCU_TCLSH_EXECUTABLE=$(HOST_DIR)/bin/tclsh8.6)

ifeq ($(BR2_arm),y)
OPENCCU_BASE_TARGET_PLATFORM = arm-linux-gnueabihf
endif

ifeq ($(BR2_aarch64),y)
OPENCCU_BASE_TARGET_PLATFORM = aarch64-linux-gnu
endif

ifeq ($(BR2_i386),y)
OPENCCU_BASE_TARGET_PLATFORM = i686-linux-gnu
endif

ifeq ($(BR2_x86_64),y)
OPENCCU_BASE_TARGET_PLATFORM = x86_64-linux-gnu
endif

OPENCCU_BASE_CONF_OPTS += \
	-DTARGET_PLATFORM=$(OPENCCU_BASE_TARGET_PLATFORM) \
	-DCROSS_PREFIX=$(TARGET_CROSS)

# Keep build/rootfs as the canonical, pristine input for the post-build patch
# series. Do not remove the complete staging directory here: incremental CMake
# builds do not necessarily re-stage binaries and libraries that are already
# up to date.
define OPENCCU_BASE_PREPARE_ROOTFS_PATCH_INPUTS
	rm -rf \
		"$(@D)/build/rootfs/www" \
		"$(@D)/build/rootfs/opt" \
		"$(@D)/build/rootfs/firmware" \
		"$(@D)/build/rootfs/usr/lib/tcl8.2/homematic"
	rm -f \
		"$(@D)/build/rootfs/bin/hm_autoconf" \
		"$(@D)/build/rootfs/bin/hm_deldev" \
		"$(@D)/build/rootfs/bin/hm_startup" \
		"$(@D)/build/rootfs/.applied_patches_list"
	$(INSTALL) -d -m 0755 "$(@D)/build/rootfs/bin"
	for file in hm_autoconf hm_deldev hm_startup; do \
		$(INSTALL) -m 0755 "$(@D)/bin/$$file" \
			"$(@D)/build/rootfs/bin/$$file"; \
	done
	$(INSTALL) -d -m 0755 "$(@D)/build/rootfs/firmware"
	cp -a "$(@D)/firmware/." "$(@D)/build/rootfs/firmware/"
endef
ifneq ($(OPENCCU_BASE_MINIMAL),y)
OPENCCU_BASE_PRE_BUILD_HOOKS += OPENCCU_BASE_PREPARE_ROOTFS_PATCH_INPUTS
endif

# Apply the OpenCCU rootfs patch stack after CMake has generated the WebUI and
# device types, but before any files are installed into TARGET_DIR.
define OPENCCU_BASE_APPLY_ROOTFS_PATCHES
	test -s "$(@D)/build/rootfs/www/webui/webui.js"
	test -s "$(@D)/build/rootfs/www/webui/style.css"
	test -s "$(@D)/build/rootfs/www/config/st_values.cgi"
	test -s "$(@D)/build/rootfs/opt/HMServer/pages/AvailableFirmware.ftl"
	test -s "$(@D)/build/rootfs/bin/hm_autoconf"
	test -s "$(@D)/build/rootfs/usr/lib/tcl8.2/homematic/homematic.tcl"
	# Legacy patches expect the generated template strings at the beginning of
	# webui.js to be split into individual lines.
	$(SHELL) "$(OPENCCU_BASE_ROOTFS_PATCH_DIR)/prepare_patch_input.sh" \
		"$(@D)/build/rootfs"
	rm -f "$(@D)/build/rootfs/.applied_patches_list"
	$(APPLY_PATCHES) "$(@D)/build/rootfs" \
		"$(OPENCCU_BASE_ROOTFS_PATCH_DIR)" \*.patch
	$(SHELL) "$(OPENCCU_BASE_ROOTFS_PATCH_DIR)/finalize_patch_input.sh" \
		"$(@D)/build/rootfs"
	chmod 0755 "$(@D)/build/rootfs/www/config/fileupload.ccc"
endef
ifeq ($(OPENCCU_BASE_ENABLE_ROOTFS_PATCHING),YES)
ifneq ($(OPENCCU_BASE_MINIMAL),y)
OPENCCU_BASE_POST_BUILD_HOOKS += OPENCCU_BASE_APPLY_ROOTFS_PATCHES
endif
endif

ifneq ($(OPENCCU_BASE_MINIMAL),y)
define OPENCCU_BASE_INSTALL_TARGET_CMDS

	# generate /bin
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/bin

	# collect own compiled binaries from $(@D)/build/rootfs/bin
	for file in SetInterfaceClock crypttool eq3configcmd eq3configd hs485d hs485dLoader hss_led multimacd rfd ssdpd; do \
		$(INSTALL) -m 0755 "$(@D)/build/rootfs/bin/$$file" "$(TARGET_DIR)/bin/$$file"; \
	done
	# collect staged scripts/bins from $(@D)/build/rootfs/bin
	for file in hm_autoconf hm_deldev hm_startup; do \
		$(INSTALL) -m 0755 "$(@D)/build/rootfs/bin/$$file" "$(TARGET_DIR)/bin/$$file"; \
	done
	# generate /lib
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/lib

	# collect own compiled libraries from $(@D)/build/rootfs/lib
	for lib in libLanDeviceUtils.so libUnifiedLanComm.so libXmlRpc.so libelvutils.so libeq3config.so libfirewall.tcl libhsscomm.so libxmlparser.so tclrpc.so; do \
		$(INSTALL) -m 0644 "$(@D)/build/rootfs/lib/$$lib" "$(TARGET_DIR)/lib/$$lib"; \
	done

	# copy homematic tcl package to target dir
	$(INSTALL) -d -m 0755 "$(TARGET_DIR)/usr/lib/tcl8.6/homematic"
	cp -av "$(@D)/build/rootfs/usr/lib/tcl8.2/homematic/." \
		"$(TARGET_DIR)/usr/lib/tcl8.6/homematic/"

	# copy all static /etc stuff from main and build directory
	$(INSTALL) -d -m 0755 "$(TARGET_DIR)/etc"
	cp -av "$(@D)/etc/." "$(TARGET_DIR)/etc/"
	cp -av "$(@D)/build/rootfs/etc/." "$(TARGET_DIR)/etc/"

	# copy the complete staged /firmware tree
	$(INSTALL) -d -m 0755 "$(TARGET_DIR)/firmware"
	cp -av "$(@D)/build/rootfs/firmware/." "$(TARGET_DIR)/firmware/"

	# copy the complete staged /opt tree
	$(INSTALL) -d -m 0755 "$(TARGET_DIR)/opt"
	cp -av "$(@D)/build/rootfs/opt/." "$(TARGET_DIR)/opt/"
endef
else ifeq ($(BR2_PACKAGE_OPENCCU_BASE_LED_ONLY),y)
define OPENCCU_BASE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 "$(@D)/build/rootfs/bin/hss_led" "$(TARGET_DIR)/bin/hss_led"
endef
else
define OPENCCU_BASE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 \
		"$(@D)/build/rootfs/lib/libxmlparser.so" \
		"$(TARGET_DIR)/lib/libxmlparser.so"
	$(INSTALL) -D -m 0644 \
		"$(@D)/build/rootfs/lib/libXmlRpc.so" \
		"$(TARGET_DIR)/lib/libXmlRpc.so"
endef
endif

ifneq ($(OPENCCU_BASE_MINIMAL),y)
ifeq ($(BR2_PACKAGE_OPENCCU_BASE_REGAHSS),y)
define OPENCCU_BASE_INSTALL_REGAHSS
	# collect the pre-compiled ReGaHss from $(@D)/bin/$(OPENCCU_BASE_TARGET_PLATFORM)
	$(INSTALL) -D -m 0755 "$(@D)/bin/$(OPENCCU_BASE_TARGET_PLATFORM)/ReGaHss" \
		"$(TARGET_DIR)/bin/ReGaHss"
	# the Tcl extension scripts load to talk to ReGaHss
	$(INSTALL) -D -m 0644 "$(@D)/build/rootfs/lib/tclrega.so" \
		"$(TARGET_DIR)/lib/tclrega.so"
endef
OPENCCU_BASE_POST_INSTALL_TARGET_HOOKS += OPENCCU_BASE_INSTALL_REGAHSS
endif

ifeq ($(BR2_PACKAGE_OPENCCU_BASE_WEBUI),y)
define OPENCCU_BASE_INSTALL_WEBUI
	# collect own compiled WebUI from $(@D)/build/rootfs/www
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/www
	cp -av "$(@D)/build/rootfs/www/." "$(TARGET_DIR)/www/"

	# patch XXX-WEBUI-VERSION-XXX and XXX-PRODUCT-XXX templates
	grep -rl 'XXX-WEBUI-VERSION-XXX' $(TARGET_DIR)/www | xargs sed -i 's/XXX-WEBUI-VERSION-XXX/$(PRODUCT_VERSION)/g' || true
	grep -rl 'XXX-PRODUCT-XXX' $(TARGET_DIR)/www | xargs sed -i 's/XXX-PRODUCT-XXX/$(PRODUCT)/g' || true
endef
else
define OPENCCU_BASE_INSTALL_WEBUI
	# without the WebUI, only the link addons publish their pages through
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/www
	ln -snf /etc/config/addons/www $(TARGET_DIR)/www/addons
endef
endif
OPENCCU_BASE_POST_INSTALL_TARGET_HOOKS += OPENCCU_BASE_INSTALL_WEBUI
endif

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
		--output=$(OPENCCU_BASE_BUILDDIR)/HMIPServer.jar-JARLICENSEINFO.txt
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseForJar.py \
		--packagedir=$(TARGET_DIR)/opt/HMServer \
		--jarfile=HMServer.jar \
		--output=$(OPENCCU_BASE_BUILDDIR)/HMServer.jar-JARLICENSEINFO.txt
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseForJar.py \
		--packagedir=$(TARGET_DIR)/opt/HmIP \
		--jarfile=hmip-copro-update.jar \
		--output=$(OPENCCU_BASE_BUILDDIR)/hmip-copro-update.jar-JARLICENSEINFO.txt
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseForJar.py \
		--packagedir=$(TARGET_DIR)/opt/HMServer/coupling \
		--jarfile=ESHBridge.jar \
		--output=$(OPENCCU_BASE_BUILDDIR)/ESHBridge.jar-JARLICENSEINFO.txt

	# create licenseinfo.htm, also without the WebUI, so every image
	# carries the license information
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/www/rega
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseHtml.py \
		--build-dir=$(BUILD_DIR)/../ \
		--jar-license-info=$(OPENCCU_BASE_BUILDDIR)/HMIPServer.jar-JARLICENSEINFO.txt \
		--jar-license-info=$(OPENCCU_BASE_BUILDDIR)/HMServer.jar-JARLICENSEINFO.txt \
		--jar-license-info=$(OPENCCU_BASE_BUILDDIR)/hmip-copro-update.jar-JARLICENSEINFO.txt \
		--jar-license-info=$(OPENCCU_BASE_BUILDDIR)/ESHBridge.jar-JARLICENSEINFO.txt \
		--output=$(TARGET_DIR)/www/rega/licenseinfo.htm
endef

define OPENCCU_BASE_FINALIZE_TARGET_WEBUI
	# fix permissions
	chmod 755 $(TARGET_DIR)/www/config/fileupload.ccc
endef
ifeq ($(BR2_PACKAGE_OPENCCU_BASE),y)
ifneq ($(OPENCCU_BASE_MINIMAL),y)
TARGET_FINALIZE_HOOKS += OPENCCU_BASE_FINALIZE_TARGET
ifeq ($(BR2_PACKAGE_OPENCCU_BASE_WEBUI),y)
TARGET_FINALIZE_HOOKS += OPENCCU_BASE_FINALIZE_TARGET_WEBUI
endif
endif
endif

ifneq ($(OPENCCU_BASE_MINIMAL),y)
ifeq ($(BR2_PACKAGE_OPENCCU_BASE_REGAHSS),y)
define OPENCCU_BASE_INSTALL_INIT_SYSV_REGAHSS
	$(INSTALL) -D -m 0755 $(OPENCCU_BASE_PKGDIR)/S70ReGaHss \
		$(TARGET_DIR)/etc/init.d/S70ReGaHss
endef
endif

define OPENCCU_BASE_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(OPENCCU_BASE_PKGDIR)/S50eq3configd \
		$(TARGET_DIR)/etc/init.d/S50eq3configd
	$(INSTALL) -D -m 0755 $(OPENCCU_BASE_PKGDIR)/S50ssdpd \
		$(TARGET_DIR)/etc/init.d/S50ssdpd
	$(OPENCCU_BASE_INSTALL_INIT_SYSV_REGAHSS)
endef

endif

ifneq ($(BR2_PACKAGE_OPENCCU_BASE_COMPAT_LIBS_ONLY),y)
ifeq ($(BR2_PACKAGE_OPENCCU_BASE_LED_ONLY),y)
define OPENCCU_BASE_USERS
	-      -1 status -1 * - - -      status access group
	hssled -1 hssled -1 * - - status hss_led user
endef
else
define OPENCCU_BASE_USERS
	-      -1 hm     -1 * - - -      homematic access group
	-      -1 status -1 * - - -      status access group
	hssled -1 hssled -1 * - - status hss_led user
	eq3cfg -1 eq3cfg -1 * - - -      eq3configd user
	ssdp   -1 ssdp   -1 * - - -      ssdpd user
endef
endif

define OPENCCU_BASE_INSTALL_LED_SERVICE
	ln -sf hss_led $(TARGET_DIR)/bin/hss_ledctl
	$(INSTALL) -D -m 0755 $(OPENCCU_BASE_PKGDIR)/S00hss_led \
		$(TARGET_DIR)/etc/init.d/S00hss_led
	$(INSTALL) -D -m 0644 $(OPENCCU_BASE_PKGDIR)/82-hss_led.rules \
		$(TARGET_DIR)/lib/udev/rules.d/82-hss_led.rules
endef
OPENCCU_BASE_POST_INSTALL_TARGET_HOOKS += OPENCCU_BASE_INSTALL_LED_SERVICE
endif

$(eval $(cmake-package))
