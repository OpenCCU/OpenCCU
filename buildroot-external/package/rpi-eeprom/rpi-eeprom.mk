################################################################################
#
# rpi-eeprom
#
################################################################################

RPI_EEPROM_VERSION = 85c834683d380c3ce2254c6cb0c79ee6ee737b78
RPI_EEPROM_SITE = $(call github,raspberrypi,rpi-eeprom,$(RPI_EEPROM_VERSION))
RPI_EEPROM_LICENSE = BSD-3-Clause, MIT, uIP, custom
RPI_EEPROM_LICENSE_FILES = LICENSE
RPI_EEPROM_INSTALL_IMAGES = YES

ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI4),y)
  # Raspberry Pi 4 (2711)
  RPI_EEPROM_FIRMWARE_PATH = firmware-2711/latest/pieeprom-2026-04-14.bin
  RPI_EEPROM_RECOVERY_PATH = firmware-2711/stable/recovery.bin
  RPI_EEPROM_VL805_GLOB = firmware-2711/stable/vl805-*.bin
else ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI5),y)
  # Raspberry Pi 5 (2712)
  RPI_EEPROM_FIRMWARE_PATH = firmware-2712/latest/pieeprom-2026-04-14.bin
  RPI_EEPROM_RECOVERY_PATH = firmware-2712/stable/recovery.bin
endif

define RPI_EEPROM_BUILD_CMDS
	$(@D)/rpi-eeprom-config $(@D)/$(RPI_EEPROM_FIRMWARE_PATH) --out $(@D)/default.conf
	(cat $(@D)/default.conf | grep -v ^$$; echo HDMI_DELAY=0) > $(@D)/boot.conf
	$(@D)/rpi-eeprom-config $(@D)/$(RPI_EEPROM_FIRMWARE_PATH) --config $(@D)/boot.conf --out $(@D)/pieeprom.upd
	$(@D)/rpi-eeprom-digest -i $(@D)/pieeprom.upd -o $(@D)/pieeprom.sig
	$(RPI_EEPROM_BUILD_VL805_CMDS)
endef

ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI4),y)
define RPI_EEPROM_BUILD_VL805_CMDS
	RPI_EEPROM_VL805_PATH=$$(ls -1 $(@D)/$(RPI_EEPROM_VL805_GLOB) 2>/dev/null | sort -r | head -n1); \
	[ -n "$$RPI_EEPROM_VL805_PATH" ] || { echo "No VL805 firmware image found matching $(RPI_EEPROM_VL805_GLOB)"; exit 1; }; \
	cp "$$RPI_EEPROM_VL805_PATH" $(@D)/vl805.bin; \
	$(@D)/rpi-eeprom-digest -i $(@D)/vl805.bin -o $(@D)/vl805.sig
endef
endif

define RPI_EEPROM_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 0644 $(@D)/pieeprom.sig $(BINARIES_DIR)/rpi-eeprom/pieeprom.sig
	$(INSTALL) -D -m 0644 $(@D)/pieeprom.upd $(BINARIES_DIR)/rpi-eeprom/pieeprom.upd
	$(INSTALL) -D -m 0644 $(@D)/$(RPI_EEPROM_RECOVERY_PATH) $(BINARIES_DIR)/rpi-eeprom/recovery.bin
	$(RPI_EEPROM_INSTALL_VL805_IMAGES_CMDS)
endef

ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI4),y)
define RPI_EEPROM_INSTALL_VL805_IMAGES_CMDS
	$(INSTALL) -D -m 0644 $(@D)/vl805.bin $(BINARIES_DIR)/rpi-eeprom/vl805.bin
	$(INSTALL) -D -m 0644 $(@D)/vl805.sig $(BINARIES_DIR)/rpi-eeprom/vl805.sig
endef
endif

$(eval $(generic-package))
