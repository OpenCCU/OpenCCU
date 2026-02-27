################################################################################
#
# TCL library to interact with xmlrpc interfaces
#
# Copyright (c) 2015 by eQ-3 Entwicklung GmbH
# https://github.com/eq-3/occu/blob/master/CCU2/download/tclrpc-eQ-3.tar.gz
#
################################################################################

TCLRPC_VERSION = 1.4
TCLRPC_SITE = $(BR2_EXTERNAL_EQ3_PATH)/package/tclrpc
TCLRPC_SITE_METHOD = local
TCLRPC_LICENSE = Apache-2.0
TCLRPC_LICENSE_FILES = LICENSE

define TCLRPC_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CXX="$(TARGET_CXX)" LD="$(TARGET_LD)" AR="$(TARGET_AR)" CXXFLAGS="$(TARGET_CXXFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" STRIP="$(TARGET_STRIP)" -C $(@D) all
endef

define TCLRPC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/tclrpc.so $(TARGET_DIR)/lib
endef

$(eval $(generic-package))
