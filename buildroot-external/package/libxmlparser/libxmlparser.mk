################################################################################
#
# XMLParser library
#
# https://github.com/eq-3/occu/blob/master/CCU2/download/xmlparser-eQ-3.tar.gz
#
################################################################################

LIBXMLPARSER_VERSION = 1.13
LIBXMLPARSER_SITE = $(BR2_EXTERNAL_EQ3_PATH)/package/libxmlparser
LIBXMLPARSER_SITE_METHOD = local
LIBXMLPARSER_LICENSE = LGPL-2.1
LIBXMLPARSER_LICENSE_FILES = LICENSE
LIBXMLPARSER_INSTALL_STAGING = YES

define LIBXMLPARSER_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CXX="$(TARGET_CXX)" LD="$(TARGET_LD)" AR="$(TARGET_AR)" CXXFLAGS="$(TARGET_CXXFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" STRIP="$(TARGET_STRIP)" -C $(@D) all
endef

define LIBXMLPARSER_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libxmlparser.a $(STAGING_DIR)/usr/lib
	$(INSTALL) -D -m 0755 $(@D)/libxmlparser.so $(STAGING_DIR)/usr/lib
	$(INSTALL) -D -m 0644 $(@D)/xmlParser.h $(STAGING_DIR)/usr/include
endef

define LIBXMLPARSER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libxmlparser.so $(TARGET_DIR)/lib
endef

$(eval $(generic-package))
