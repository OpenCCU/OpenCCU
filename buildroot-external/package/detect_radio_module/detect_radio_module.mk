################################################################################
#
# detect_radio_module
#
# Alexander Reinert <alex@areinert.de>
# https://github.com/OpenCCU/piVCCU/tree/master/detect_radio_module
# (fork of https://github.com/alexreinert/piVCCU)
#
################################################################################

DETECT_RADIO_MODULE_VERSION = 908d18fd52963ef8bf54b12083650509ce116374
DETECT_RADIO_MODULE_SITE = $(call github,OpenCCU,piVCCU,$(DETECT_RADIO_MODULE_VERSION))
DETECT_RADIO_MODULE_LICENSE = Apache-2.0
DETECT_RADIO_MODULE_LICENSE_FILES = LICENSE

define DETECT_RADIO_MODULE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CXXFLAGS) -pthread" \
		LDFLAGS="$(TARGET_LDFLAGS) -pthread" -C $(@D)/detect_radio_module
endef

define DETECT_RADIO_MODULE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/detect_radio_module/detect_radio_module $(TARGET_DIR)/bin/detect_radio_module
endef

$(eval $(generic-package))
