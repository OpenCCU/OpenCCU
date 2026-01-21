################################################################################
#
# rpi-eeprom
#
################################################################################

RPI_EEPROM_VERSION = 5fa9a43d66c0004d55f7c2c7bd8bdd48c2efc020
RPI_EEPROM_SITE = $(call github,raspberrypi,rpi-eeprom,$(RPI_EEPROM_VERSION))
RPI_EEPROM_LICENSE = BSD-3-Clause
RPI_EEPROM_LICENSE_FILES = LICENSE
RPI_EEPROM_INSTALL_IMAGES = YES

ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI4),y)
  # Raspberry Pi 4 (2711)
  RPI_EEPROM_FIRMWARE_PATH = firmware-2711/stable/pieeprom-2026-01-09.bin
else ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI5),y)
  # Raspberry Pi 5 (2712)
  RPI_EEPROM_FIRMWARE_PATH = firmware-2712/stable/pieeprom-2026-01-21.bin
endif

define RPI_EEPROM_BUILD_CMDS
	$(@D)/rpi-eeprom-config $(@D)/$(RPI_EEPROM_FIRMWARE_PATH) --out $(@D)/default.conf
	(cat $(@D)/default.conf | grep -v ^$$; echo HDMI_DELAY=0) > $(@D)/boot.conf
	$(@D)/rpi-eeprom-config $(@D)/$(RPI_EEPROM_FIRMWARE_PATH) --config $(@D)/boot.conf --out $(@D)/pieeprom.upd
	sha256sum $(@D)/pieeprom.upd | awk '{ print $$1 }' > $(@D)/pieeprom.sig
	echo "ts: $$(date -u +%s)" >> $(@D)/pieeprom.sig
endef

define RPI_EEPROM_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 0644 $(@D)/pieeprom.sig $(BINARIES_DIR)/rpi-eeprom/pieeprom.sig
	$(INSTALL) -D -m 0644 $(@D)/pieeprom.upd $(BINARIES_DIR)/rpi-eeprom/pieeprom.upd
endef

$(eval $(generic-package))
