################################################################################
#
# Mediola Neo Server
#
################################################################################

NEOSERVER_VERSION = 2.18.3
NEOSERVER_SOURCE = neo_server.tar.gz
NEOSERVER_SITE = $(BR2_EXTERNAL_EQ3_PATH)/package/neoserver
NEOSERVER_SITE_METHOD = file
NEOSERVER_LICENSE = PROPERITARY

define NEOSERVER_BUILD_CMDS
	$(INSTALL) -d -m 0755 $(@D)/build/mediola/
	$(INSTALL) -D -m 0644 $(@D)/VERSION $(@D)/build/mediola/VERSION
	touch $(@D)/build/mediola/.nobackup
	touch $(@D)/build/mediola/Disabled
	cp -a $(@D)/bin $(@D)/build/mediola/
	$(INSTALL) -D -m 0644 $(@D)/mediola_addon.cfg $(@D)/build/mediola/mediola_addon.cfg
	cp -a $(@D)/rc.d $(@D)/build/mediola/
	cp -a $(@D)/neo_server $(@D)/build/mediola/
	tar -C $(@D)/build --owner=root --group=root -czf $(@D)/mediola.tar.gz mediola
endef

define NEOSERVER_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/opt/mediola/
	cp -a $(@D)/www $(TARGET_DIR)/opt/mediola/
	cp -a $(NEOSERVER_PKGDIR)/overlay/* $(TARGET_DIR)/
	$(INSTALL) -D -m 0644 $(@D)/VERSION $(TARGET_DIR)/opt/mediola/VERSION
	$(INSTALL) -D -m 0755 $(@D)/install.tcl $(TARGET_DIR)/opt/mediola/install.tcl
	$(INSTALL) -D -m 0644 $(@D)/mediola.tar.gz $(TARGET_DIR)/opt/mediola/pkg/mediola.tar.gz
endef

define NEOSERVER_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(NEOSERVER_PKGDIR)/S97NeoServer \
		$(TARGET_DIR)/etc/init.d/S97NeoServer
endef

$(eval $(generic-package))
