################################################################################
#
# OpenCCU-Base package
#
################################################################################

OPENCCU_BASE_VERSION = caec7573d289a4b36f322862f22b110903dddf45
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

# Native programs are selected independently. CMake derives the internal
# library installation set from the selected targets' link dependencies.
OPENCCU_BASE_PROGRAMS = SETINTERFACECLOCK CRYPTTOOL EQ3CONFIGCMD EQ3CONFIGD \
	HS485D HS485DLOADER HSS_LED MULTIMACD RFD SSDPD TCLREGA TCLRPC
OPENCCU_BASE_ASSETS = WEBUI DEVICETYPES TCL_HOMEMATIC HMSERVER HMIP_TOOLS \
	FIRMWARE HM_SCRIPTS
OPENCCU_BASE_PATCH_ASSETS = $(strip $(foreach c,$(OPENCCU_BASE_ASSETS),$(if $(filter y,$(BR2_PACKAGE_OPENCCU_BASE_$(c))),$(c))))
OPENCCU_BASE_ASSET_ROOTFS = $(@D)/build/asset-rootfs
OPENCCU_BASE_DEPENDENCIES = \
	$(if $(filter y,$(BR2_PACKAGE_OPENCCU_BASE_HMSERVER) $(BR2_PACKAGE_OPENCCU_BASE_HMIP_TOOLS)),java-azul) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_NEEDS_CRYPTO),openssl) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_NEEDS_TCL),tcl) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_RFD),host-pkgconf libusb) \
	$(if $(OPENCCU_BASE_PATCH_ASSETS),host-python3 host-python-html2text host-tcl) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_SYSTEM_INTEGRATION),host-python3)

OPENCCU_BASE_BUILD_OPTS = --target core
OPENCCU_BASE_CONF_OPTS = \
	-DDEPLOY_TO_REPO=OFF \
	-DBUILD_DEFAULT_COMPONENTS=OFF \
	-DBUILD_TCL_MODULES=OFF \
	-DBUILD_WEBUI_AND_DEVICETYPES=OFF \
	-DBUILD_COMPAT_LIBRARIES=$(if $(BR2_PACKAGE_OPENCCU_BASE_COMPAT_LIBS_ONLY),ON,OFF) \
	-DHSS_LED_STATUS_MONITOR=$(if $(BR2_PACKAGE_OPENCCU_BASE_HSS_LED_STATUS_MONITOR),ON,OFF) \
	-DHAS_USB_SUPPORT=$(if $(BR2_PACKAGE_OPENCCU_BASE_RFD),ON,OFF) \
	-DROOTFS_DIR=$(@D)/build/rootfs \
	$(foreach c,$(OPENCCU_BASE_PROGRAMS),-DBUILD_$(c)=$(if $(filter y,$(BR2_PACKAGE_OPENCCU_BASE_$(c))),ON,OFF))

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

# The remaining rootfs patch series touches WebUI, firmware, scripts and Java
# data together. Prepare that complete input once, then install only the selected
# asset components. A native-only selection needs none of these generators.
define OPENCCU_BASE_PREPARE_ASSETS
	rm -rf "$(OPENCCU_BASE_ASSET_ROOTFS)"
	CMAKE="$(BR2_CMAKE)" PYTHON="$(HOST_DIR)/bin/python3" \
		TCLSH="$(HOST_DIR)/bin/tclsh8.6" \
		$(SHELL) "$(OPENCCU_BASE_ROOTFS_PATCH_DIR)/stage_validation_rootfs.sh" \
		"$(@D)" "$(OPENCCU_BASE_ASSET_ROOTFS)"
	$(INSTALL) -d -m 0755 "$(OPENCCU_BASE_ASSET_ROOTFS)/bin"
	for file in hm_autoconf hm_deldev hm_startup; do \
		$(INSTALL) -m 0755 "$(@D)/bin/$$file" "$(OPENCCU_BASE_ASSET_ROOTFS)/bin/$$file"; \
	done
	# Preserve generated device descriptions when supplementing static firmware.
	rsync -a --ignore-existing "$(@D)/firmware/" "$(OPENCCU_BASE_ASSET_ROOTFS)/firmware/"
endef
ifneq ($(OPENCCU_BASE_PATCH_ASSETS),)
OPENCCU_BASE_POST_BUILD_HOOKS += OPENCCU_BASE_PREPARE_ASSETS
endif

define OPENCCU_BASE_APPLY_ROOTFS_PATCHES
	$(SHELL) "$(OPENCCU_BASE_ROOTFS_PATCH_DIR)/prepare_patch_input.sh" "$(OPENCCU_BASE_ASSET_ROOTFS)"
	$(APPLY_PATCHES) "$(OPENCCU_BASE_ASSET_ROOTFS)" "$(OPENCCU_BASE_ROOTFS_PATCH_DIR)" \*.patch
	$(SHELL) "$(OPENCCU_BASE_ROOTFS_PATCH_DIR)/finalize_patch_input.sh" "$(OPENCCU_BASE_ASSET_ROOTFS)"
	chmod 0755 "$(OPENCCU_BASE_ASSET_ROOTFS)/www/config/fileupload.ccc"
endef
ifeq ($(OPENCCU_BASE_ENABLE_ROOTFS_PATCHING),YES)
ifneq ($(OPENCCU_BASE_PATCH_ASSETS),)
OPENCCU_BASE_POST_BUILD_HOOKS += OPENCCU_BASE_APPLY_ROOTFS_PATCHES
endif
endif

# The runtime install component contains the selected native targets plus their
# transitive internal libraries, never a wildcard over a possibly stale rootfs.
define OPENCCU_BASE_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) DESTDIR="$(TARGET_DIR)" $(BR2_CMAKE) \
		--install "$(OPENCCU_BASE_BUILDDIR)" --prefix / --component runtime
	$(OPENCCU_BASE_INSTALL_SELECTED_ASSETS)
	$(OPENCCU_BASE_INSTALL_SELECTED_CONFIG)
endef

OPENCCU_BASE_ASSET_DIRS = \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_WEBUI),www) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_HMSERVER),opt/HMServer) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_HMIP_TOOLS),opt/HmIP) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_DEVICETYPES),firmware/rftypes firmware/hs485types)

define OPENCCU_BASE_INSTALL_SELECTED_ASSETS
	$(foreach d,$(OPENCCU_BASE_ASSET_DIRS),mkdir -p "$(TARGET_DIR)/$(d)"; cp -a "$(OPENCCU_BASE_ASSET_ROOTFS)/$(d)/." "$(TARGET_DIR)/$(d)/"$(sep))
	$(if $(BR2_PACKAGE_OPENCCU_BASE_FIRMWARE),mkdir -p "$(TARGET_DIR)/firmware"; rsync -a --exclude rftypes --exclude hs485types "$(OPENCCU_BASE_ASSET_ROOTFS)/firmware/" "$(TARGET_DIR)/firmware/")
	$(if $(BR2_PACKAGE_OPENCCU_BASE_TCL_HOMEMATIC),mkdir -p "$(TARGET_DIR)/usr/lib/tcl8.6/homematic"; cp -a "$(OPENCCU_BASE_ASSET_ROOTFS)/usr/lib/tcl8.2/homematic/." "$(TARGET_DIR)/usr/lib/tcl8.6/homematic/")
	$(if $(BR2_PACKAGE_OPENCCU_BASE_HM_SCRIPTS),for file in hm_autoconf hm_deldev hm_startup; do $(INSTALL) -D -m 0755 "$(OPENCCU_BASE_ASSET_ROOTFS)/bin/$$file" "$(TARGET_DIR)/bin/$$file"; done)
	$(if $(BR2_PACKAGE_OPENCCU_BASE_REGAHSS),$(INSTALL) -D -m 0755 "$(@D)/bin/$(OPENCCU_BASE_TARGET_PLATFORM)/ReGaHss" "$(TARGET_DIR)/bin/ReGaHss")
	$(if $(BR2_PACKAGE_OPENCCU_BASE_WEBUI),grep -rl 'XXX-WEBUI-VERSION-XXX' "$(TARGET_DIR)/www" | xargs sed -i 's/XXX-WEBUI-VERSION-XXX/$(PRODUCT_VERSION)/g' || true)
	$(if $(BR2_PACKAGE_OPENCCU_BASE_WEBUI),grep -rl 'XXX-PRODUCT-XXX' "$(TARGET_DIR)/www" | xargs sed -i 's/XXX-PRODUCT-XXX/$(PRODUCT)/g' || true)
endef

ifeq ($(BR2_PACKAGE_OPENCCU_BASE_CONFIG_TEMPLATES),y)
OPENCCU_BASE_CONFIG_FILES = \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_CRYPTTOOL),crypttool.cfg) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_HMSERVER),crRFD.conf log4j2.xml)
endif

define OPENCCU_BASE_INSTALL_SELECTED_CONFIG
	$(foreach f,$(OPENCCU_BASE_CONFIG_FILES),$(INSTALL) -D -m 0644 "$(@D)/etc/config_templates/$(f)" "$(TARGET_DIR)/etc/config_templates/$(f)"$(sep))
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

endef

# Collect license information only from Java components actually installed.
define OPENCCU_BASE_LICENSE_INFO
	set -e; set --; \
	for jar in HMServer/HMIPServer.jar HMServer/HMServer.jar HMServer/coupling/ESHBridge.jar HmIP/hmip-copro-update.jar; do \
		if test -f "$(TARGET_DIR)/opt/$$jar"; then \
			name=$${jar##*/}; dir=$${jar%/*}; \
			out="$(OPENCCU_BASE_BUILDDIR)/$$name-JARLICENSEINFO.txt"; \
			$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseForJar.py \
				--packagedir="$(TARGET_DIR)/opt/$$dir" --jarfile="$$name" --output="$$out"; \
			set -- "$$@" --jar-license-info="$$out"; \
		fi; \
	done; \
	$(INSTALL) -d -m 0755 "$(TARGET_DIR)/www/rega"; \
	$(HOST_DIR)/bin/python3 $(OPENCCU_BASE_PKGDIR)/scripts/createLicenseHtml.py \
		--build-dir="$(BUILD_DIR)/../" "$$@" --output="$(TARGET_DIR)/www/rega/licenseinfo.htm"
endef
ifeq ($(BR2_PACKAGE_OPENCCU_BASE_SYSTEM_INTEGRATION),y)
# Buildroot keeps target/ across builds, even when an older package version
# created /etc/default as a directory. Move its contents to the location of
# the main overlay's /etc/default -> config/default link before overlays run.
define OPENCCU_BASE_MIGRATE_DEFAULTS
	set -e; if [ -d "$(TARGET_DIR)/etc/default" ] && [ ! -L "$(TARGET_DIR)/etc/default" ]; then \
		rm -f "$(TARGET_DIR)/etc/default/openccu-base"; \
		mkdir -p "$(TARGET_DIR)/usr/local/etc/config/default"; \
		cp -a "$(TARGET_DIR)/etc/default/." "$(TARGET_DIR)/usr/local/etc/config/default/"; \
		rm -rf "$(TARGET_DIR)/etc/default"; \
	fi
endef
TARGET_FINALIZE_HOOKS += OPENCCU_BASE_MIGRATE_DEFAULTS
TARGET_FINALIZE_HOOKS += OPENCCU_BASE_FINALIZE_TARGET
ifeq ($(BR2_PACKAGE_OPENCCU_BASE_WEBUI),y)
TARGET_FINALIZE_HOOKS += OPENCCU_BASE_LICENSE_INFO
endif
endif

OPENCCU_BASE_INIT_SCRIPTS = \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_EQ3CONFIGD),S50eq3configd) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_SSDPD),S50ssdpd) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_REGAHSS),S70ReGaHss) \
	$(if $(BR2_PACKAGE_OPENCCU_BASE_HSS_LED),S00hss_led)
ifeq ($(BR2_PACKAGE_OPENCCU_BASE_INIT_SCRIPTS),y)
define OPENCCU_BASE_INSTALL_INIT_SYSV
	$(foreach f,$(OPENCCU_BASE_INIT_SCRIPTS),$(INSTALL) -D -m 0755 "$(OPENCCU_BASE_PKGDIR)/$(f)" "$(TARGET_DIR)/etc/init.d/$(f)"$(sep))
	$(if $(filter S50eq3configd,$(OPENCCU_BASE_INIT_SCRIPTS)),sed -i 's/^OPENCCU_BASE_CONFIG_INIT=yes$$/OPENCCU_BASE_CONFIG_INIT=$(if $(BR2_PACKAGE_OPENCCU_BASE_SYSTEM_INTEGRATION),yes,no)/' "$(TARGET_DIR)/etc/init.d/S50eq3configd")
endef
endif

# Recovery reads the main system's root:eq3cfg crypttool.cfg; both independently
# built images must assign the same numeric GID to the group.
define OPENCCU_BASE_USERS
	$(if $(BR2_PACKAGE_OPENCCU_BASE_SYSTEM_INTEGRATION),- -1 hm -1 * - - - homematic access group)
	$(if $(filter y,$(BR2_PACKAGE_OPENCCU_BASE_HSS_LED) $(BR2_PACKAGE_OPENCCU_BASE_SYSTEM_INTEGRATION)),- -1 status -1 * - - - status access group)
	$(if $(BR2_PACKAGE_OPENCCU_BASE_HSS_LED),hssled -1 hssled -1 * - - status hss_led user)
	$(if $(BR2_PACKAGE_OPENCCU_BASE_EQ3CONFIGD),eq3cfg -1 eq3cfg 995 * - - - eq3configd user)
	$(if $(BR2_PACKAGE_OPENCCU_BASE_SSDPD),ssdp -1 ssdp -1 * - - - ssdpd user)
endef
ifeq ($(BR2_PACKAGE_OPENCCU_BASE_HSS_LED),y)

define OPENCCU_BASE_INSTALL_LED_SERVICE
	$(INSTALL) -D -m 0644 $(OPENCCU_BASE_PKGDIR)/82-hss_led.rules \
		$(TARGET_DIR)/lib/udev/rules.d/82-hss_led.rules
endef
OPENCCU_BASE_POST_INSTALL_TARGET_HOOKS += OPENCCU_BASE_INSTALL_LED_SERVICE
endif

$(eval $(cmake-package))
