################################################################################
#
# Implementation of XmlRpc protocol (libXmlRpc++)
#
# https://github.com/eq-3/occu/blob/master/CCU2/download/xmlrpc-eQ-3.tar.gz
#
################################################################################

LIBXMLRPCXX_VERSION = 0.10
LIBXMLRPCXX_SITE = $(BR2_EXTERNAL_EQ3_PATH)/package/libxmlrpcxx
LIBXMLRPCXX_SITE_METHOD = local
LIBXMLRPCXX_LICENSE = LGPL-2.1
LIBXMLRPCXX_LICENSE_FILES = COPYING
LIBXMLRPCXX_INSTALL_STAGING = YES

define LIBXMLRPCXX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CXX="$(TARGET_CXX)" LD="$(TARGET_LD)" AR="$(TARGET_AR)" CXXFLAGS="$(TARGET_CXXFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" STRIP="$(TARGET_STRIP)" -C $(@D) all
endef

define LIBXMLRPCXX_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libXmlRpc.a $(STAGING_DIR)/usr/lib
	$(INSTALL) -D -m 0755 $(@D)/libXmlRpc.so $(STAGING_DIR)/usr/lib
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpc.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpcClient.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpcDispatch.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpcSource.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpcException.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpcServer.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpcServerProxy.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpcServerMethod.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpcValue.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/XmlRpcUtil.h $(STAGING_DIR)/usr/include
	$(INSTALL) -D -m 0644 $(@D)/src/dllexport.h $(STAGING_DIR)/usr/include
endef

define LIBXMLRPCXX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libXmlRpc.so $(TARGET_DIR)/lib
endef

$(eval $(generic-package))
