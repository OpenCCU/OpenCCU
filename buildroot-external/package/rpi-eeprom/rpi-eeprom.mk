################################################################################
#
# rpi-eeprom
#
################################################################################

# Only the license, the two helper scripts and the firmware images of the
# selected SoC are downloaded at the pinned revision instead of the whole
# rpi-eeprom repository (>100 MB), which contains every firmware release.
# The paths use the real firmware directory, because the "stable" symlink
# is not resolved by raw.githubusercontent.com.
RPI_EEPROM_VERSION = 65d9489a4938569001d46291431f6a737a516e18
RPI_EEPROM_SITE = https://raw.githubusercontent.com/raspberrypi/rpi-eeprom/$(RPI_EEPROM_VERSION)
RPI_EEPROM_SOURCE = LICENSE
RPI_EEPROM_LICENSE = BSD-3-Clause, MIT, uIP, custom
RPI_EEPROM_LICENSE_FILES = LICENSE
RPI_EEPROM_INSTALL_IMAGES = YES

ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI4),y)
  # Raspberry Pi 4 (2711)
  RPI_EEPROM_SOC = 2711
  RPI_EEPROM_FIRMWARE_PATH = firmware-2711/latest/pieeprom-2026-10-30.bin
  RPI_EEPROM_RECOVERY_PATH = firmware-2711/latest/recovery.bin
  RPI_EEPROM_VL805_PATH = firmware-2711/latest/vl805-000138c0.bin
else ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI5),y)
  # Raspberry Pi 5 (2712)
  RPI_EEPROM_SOC = 2712
  RPI_EEPROM_FIRMWARE_PATH = firmware-2712/latest/pieeprom-2026-10-30.bin
  RPI_EEPROM_RECOVERY_PATH = firmware-2712/latest/recovery.bin
endif

RPI_EEPROM_EXTRA_DOWNLOADS = \
	rpi-eeprom-config \
	rpi-eeprom-digest \
	$(RPI_EEPROM_FIRMWARE_PATH) \
	$(RPI_EEPROM_RECOVERY_PATH) \
	$(RPI_EEPROM_VL805_PATH)

# The firmware images of both SoCs share their file names (e.g.
# recovery.bin), so they are kept in a separate download directory per SoC.
RPI_EEPROM_DL_SUBDIR = rpi-eeprom-$(RPI_EEPROM_SOC)

define RPI_EEPROM_EXTRACT_CMDS
	$(INSTALL) -m 0644 $(RPI_EEPROM_DL_DIR)/LICENSE $(@D)/LICENSE
	$(INSTALL) -m 0755 $(RPI_EEPROM_DL_DIR)/rpi-eeprom-config $(@D)/rpi-eeprom-config
	$(INSTALL) -m 0755 $(RPI_EEPROM_DL_DIR)/rpi-eeprom-digest $(@D)/rpi-eeprom-digest
	$(foreach f,$(RPI_EEPROM_FIRMWARE_PATH) $(RPI_EEPROM_RECOVERY_PATH) $(RPI_EEPROM_VL805_PATH),\
		$(INSTALL) -D -m 0644 $(RPI_EEPROM_DL_DIR)/$(notdir $(f)) $(@D)/$(f)$(sep))
endef

define RPI_EEPROM_BUILD_CMDS
	$(@D)/rpi-eeprom-config $(@D)/$(RPI_EEPROM_FIRMWARE_PATH) --out $(@D)/default.conf
	(cat $(@D)/default.conf | grep -v ^$$; echo HDMI_DELAY=0) > $(@D)/boot.conf
	$(@D)/rpi-eeprom-config $(@D)/$(RPI_EEPROM_FIRMWARE_PATH) --config $(@D)/boot.conf --out $(@D)/pieeprom.upd
	$(@D)/rpi-eeprom-digest -i $(@D)/pieeprom.upd -o $(@D)/pieeprom.sig
	$(RPI_EEPROM_BUILD_VL805_CMDS)
endef

ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI4),y)
define RPI_EEPROM_BUILD_VL805_CMDS
	cp $(@D)/$(RPI_EEPROM_VL805_PATH) $(@D)/vl805.bin
	$(@D)/rpi-eeprom-digest -i $(@D)/vl805.bin -o $(@D)/vl805.sig
	echo "$(patsubst vl805-%.bin,%,$(notdir $(RPI_EEPROM_VL805_PATH)))" >$(@D)/vl805.ver
endef
endif

define RPI_EEPROM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(RPI_EEPROM_PKGDIR)/rpi-eeprom-info $(TARGET_DIR)/bin
endef

define RPI_EEPROM_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 0644 $(@D)/pieeprom.sig $(BINARIES_DIR)/rpi-eeprom/pieeprom.sig
	$(INSTALL) -D -m 0644 $(@D)/pieeprom.upd $(BINARIES_DIR)/rpi-eeprom/pieeprom.upd
	$(INSTALL) -D -m 0644 $(@D)/$(RPI_EEPROM_RECOVERY_PATH) $(BINARIES_DIR)/rpi-eeprom/recovery.bin
	$(RPI_EEPROM_INSTALL_VL805_IMAGES_CMDS)
endef

ifeq ($(BR2_PACKAGE_RPI_EEPROM_RPI4),y)
define RPI_EEPROM_INSTALL_VL805_IMAGES_CMDS
  # VL805 firmware + version sidecar
	$(INSTALL) -D -m 0644 $(@D)/vl805.bin $(BINARIES_DIR)/rpi-eeprom/vl805.bin
	$(INSTALL) -D -m 0644 $(@D)/vl805.sig $(BINARIES_DIR)/rpi-eeprom/vl805.sig
	$(INSTALL) -D -m 0644 $(@D)/vl805.ver $(BINARIES_DIR)/rpi-eeprom/vl805.ver
endef
endif

$(eval $(generic-package))

# The hashes of the firmware images are kept in a separate hash file per SoC,
# because the images of both SoCs share their file names.
RPI_EEPROM_HASH_FILES += $(RPI_EEPROM_PKGDIR)/rpi-eeprom-$(RPI_EEPROM_SOC).hash
