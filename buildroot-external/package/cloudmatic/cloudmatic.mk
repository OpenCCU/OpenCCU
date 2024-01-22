################################################################################
#
# CloudMatic/meine-homematic.de support
#
################################################################################

CLOUDMATIC_VERSION = 9e006bf58706e52ee5b23964e2ca064bb14775f4
CLOUDMATIC_SITE = $(call github,jens-maus,CloudMatic-CCUAddon,$(CLOUDMATIC_VERSION))
CLOUDMATIC_LICENSE = BSD-3-Clause

ifeq ($(BR2_arm),y)
  NGINX_BIN=nginx.armhf
  ZABBIX_BIN=zabbix_agentd
endif

ifeq ($(BR2_aarch64),y)
  NGINX_BIN=nginx.aarch64
  ZABBIX_BIN=zabbix_agentd
endif

ifeq ($(BR2_i386),y)
  NGINX_BIN=nginx.i686
  ZABBIX_BIN=zabbix_agentd.i686
endif

ifeq ($(BR2_x86_64),y)
  NGINX_BIN=nginx.x86_64
  ZABBIX_BIN=zabbix_agentd.i686
endif

define CLOUDMATIC_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/opt/mh
	$(INSTALL) -D -m 0755 $(@D)/install.tcl $(TARGET_DIR)/opt/mh/
	$(INSTALL) -D -m 0755 $(@D)/startup.sh $(TARGET_DIR)/opt/mh/
	$(INSTALL) -D -m 0755 $(@D)/openvpn $(TARGET_DIR)/opt/mh/
	cp -a $(@D)/user $(TARGET_DIR)/opt/mh/
	cp -a $(@D)/www $(TARGET_DIR)/opt/mh/
	rm -f $(TARGET_DIR)/opt/mh/user/nginx*
	[[ -n "$(NGINX_BIN)" ]] && $(INSTALL) -m 0755 $(@D)/user/$(NGINX_BIN) $(TARGET_DIR)/opt/mh/user/nginx || true
	$(INSTALL) -D -m 0644 $(@D)/user/nginx.conf $(TARGET_DIR)/opt/mh/user/
	$(INSTALL) -D -m 0644 $(@D)/user/nginx.conf.default $(TARGET_DIR)/opt/mh/user/
	rm -f $(TARGET_DIR)/opt/mh/user/zabbix_agentd*
	[[ -n "$(ZABBIX_BIN)" ]] && $(INSTALL) -m 0755 $(@D)/user/$(ZABBIX_BIN) $(TARGET_DIR)/opt/mh/user/zabbix_agentd || true
endef

define CLOUDMATIC_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(CLOUDMATIC_PKGDIR)/S97CloudMatic \
		$(TARGET_DIR)/etc/init.d/S97CloudMatic
endef

$(eval $(generic-package))
