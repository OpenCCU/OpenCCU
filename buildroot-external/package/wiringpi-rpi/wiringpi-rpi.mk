################################################################################
#
# wiringpi (https://github.com/WiringPi/WiringPi)
#
################################################################################

WIRINGPI_RPI_VERSION = 3.16
WIRINGPI_RPI_SITE = $(call github,wiringpi,wiringpi,$(WIRINGPI_RPI_VERSION))

WIRINGPI_RPI_LICENSE = LGPL-3.0+
WIRINGPI_RPI_LICENSE_FILES = COPYING.LESSER
WIRINGPI_RPI_INSTALL_STAGING = YES

define WIRINGPI_RPI_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/wiringPi all
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/devLib all
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/gpio all
endef

define WIRINGPI_RPI_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/wiringPi install DESTDIR=$(STAGING_DIR) PREFIX=/usr LDCONFIG=true
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/devLib install DESTDIR=$(STAGING_DIR) PREFIX=/usr LDCONFIG=true
endef

define WIRINGPI_RPI_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/wiringPi install DESTDIR=$(TARGET_DIR) PREFIX=/usr LDCONFIG=true
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/devLib install DESTDIR=$(TARGET_DIR) PREFIX=/usr LDCONFIG=true
	$(INSTALL) -D -m 0755 $(@D)/gpio/gpio $(TARGET_DIR)/usr/bin/gpio
endef

$(eval $(generic-package))
