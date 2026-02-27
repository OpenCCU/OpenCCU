################################################################################
#
# TCL library to interact with ReGaHss
#
# Copyright (c) 2015 by eQ-3 Entwicklung GmbH
# https://github.com/eq-3/occu/blob/master/CCU2/download/tclrega-eQ-3.tar.gz
#
################################################################################

TCLREGA_VERSION = 1.4
TCLREGA_SITE = $(BR2_EXTERNAL_EQ3_PATH)/package/tclrega
TCLREGA_SITE_METHOD = local
TCLREGA_LICENSE = Apache-2.0
TCLREGA_LICENSE_FILES = LICENSE

define TCLREGA_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CXX="$(TARGET_CXX)" LD="$(TARGET_LD)" AR="$(TARGET_AR)" CXXFLAGS="$(TARGET_CXXFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" STRIP="$(TARGET_STRIP)" -C $(@D) all
endef

define TCLREGA_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/tclrega.so $(TARGET_DIR)/lib
endef

$(eval $(generic-package))
