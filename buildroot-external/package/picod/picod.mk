################################################################################
#
# Pico UPS Support (pimodules.com)
#
################################################################################

PICOD_VERSION = 55458477aa48b1ccccbb8b09175dd81fd3512ebf
PICOD_SITE = $(call github,ef-gy,rpi-ups-pico,$(PICOD_VERSION))
PICOD_LICENSE = MIT
PICOD_LICENSE_FILES = LICENSE

PICOD_DEPENDENCIES += i2c-tools

define PICOD_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) LDFLAGS+="-li2c" -C $(@D) all
endef

define PICOD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/picod $(TARGET_DIR)/opt/picod/picod
	$(INSTALL) -D -m 0755 $(@D)/pico-i2cd $(TARGET_DIR)/opt/picod/pico-i2cd
	$(INSTALL) -D -m 0755 $(PICOD_PKGDIR)/picod.sh $(TARGET_DIR)/opt/picod/picod.sh
endef

define PICOD_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(PICOD_PKGDIR)/S51picod \
		$(TARGET_DIR)/etc/init.d/S51picod
endef

$(eval $(generic-package))
