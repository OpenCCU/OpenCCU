#############################################################
#
# HomeMatic platform support package to add necessary
# binaries for the recovery system only.
#
#############################################################

HM_PLATFORM_VERSION = $(OPENCCU_BASE_VERSION)
HM_PLATFORM_SITE = $(call github,OpenCCU,OpenCCU-Base,$(OPENCCU_BASE_VERSION))

ifeq ($(BR2_TOOLCHAIN_USES_GLIBC),)
	$(error hm-platform requires a glibc toolchain (BR2_TOOLCHAIN_USES_GLIBC))
endif

ifeq ($(BR2_aarch64),y)
	HM_PLATFORM_ARCH=aarch64-linux-gnu
endif

ifeq ($(BR2_x86_64),y)
	HM_PLATFORM_ARCH=x86_64-linux-gnu
endif

define HM_PLATFORM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/$(HM_PLATFORM_ARCH)/ssdpd $(TARGET_DIR)/bin/ssdpd
	$(INSTALL) -D -m 0755 $(@D)/bin/$(HM_PLATFORM_ARCH)/eq3configcmd $(TARGET_DIR)/bin/eq3configcmd
	$(INSTALL) -D -m 0755 $(@D)/bin/$(HM_PLATFORM_ARCH)/eq3configd $(TARGET_DIR)/bin/eq3configd
	$(INSTALL) -D -m 0644 $(@D)/lib/$(HM_PLATFORM_ARCH)/libeq3config.so $(TARGET_DIR)/lib/libeq3config.so
	$(INSTALL) -D -m 0755 $(@D)/bin/$(HM_PLATFORM_ARCH)/crypttool $(TARGET_DIR)/bin/crypttool
	$(INSTALL) -D -m 0644 $(@D)/lib/$(HM_PLATFORM_ARCH)/libLanDeviceUtils.so $(TARGET_DIR)/lib/libLanDeviceUtils.so
	$(INSTALL) -D -m 0644 $(@D)/lib/$(HM_PLATFORM_ARCH)/libUnifiedLanComm.so $(TARGET_DIR)/lib/libUnifiedLanComm.so
	$(INSTALL) -D -m 0644 $(@D)/lib/$(HM_PLATFORM_ARCH)/libelvutils.so $(TARGET_DIR)/lib/libelvutils.so
	cp -a $(HM_PLATFORM_PKGDIR)/rootfs-overlay/. $(TARGET_DIR)/
endef

define HM_PLATFORM_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(HM_PLATFORM_PKGDIR)/S50eq3configd \
		$(TARGET_DIR)/etc/init.d/S50eq3configd
endef

$(eval $(generic-package))
