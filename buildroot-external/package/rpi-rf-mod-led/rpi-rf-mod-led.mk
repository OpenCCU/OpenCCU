################################################################################
# Central RPI-RF-MOD LED service (normal and recovery systems)
################################################################################
RPI_RF_MOD_LED_VERSION = 1.0
RPI_RF_MOD_LED_SITE = $(RPI_RF_MOD_LED_PKGDIR)
RPI_RF_MOD_LED_SITE_METHOD = local
RPI_RF_MOD_LED_LICENSE = Apache-2.0
RPI_RF_MOD_LED_LICENSE_FILES = LICENSE

define RPI_RF_MOD_LED_BUILD_CMDS
	$(TARGET_CXX) $(TARGET_CPPFLAGS) $(TARGET_CXXFLAGS) -std=c++11 -Wall -Wextra \
		-o $(@D)/rpi-rf-mod-ledd $(@D)/led.cpp $(TARGET_LDFLAGS)
endef

define RPI_RF_MOD_LED_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/rpi-rf-mod-ledd $(TARGET_DIR)/usr/sbin/rpi-rf-mod-ledd
	$(INSTALL) -d $(TARGET_DIR)/bin
	ln -sf ../usr/sbin/rpi-rf-mod-ledd $(TARGET_DIR)/bin/rpi-rf-mod-led
endef

define RPI_RF_MOD_LED_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(RPI_RF_MOD_LED_PKGDIR)/S01rpi-rf-mod-ledd $(TARGET_DIR)/etc/init.d/S01rpi-rf-mod-ledd
endef

define RPI_RF_MOD_LED_USERS
	- -1 status -1 * - - - LED status clients
endef

$(eval $(generic-package))
