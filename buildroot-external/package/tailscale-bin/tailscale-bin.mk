################################################################################
#
# Tailscale Zero config VPN - https://tailscale.com/
#
################################################################################

TAILSCALE_BIN_VERSION = 1.90.6
TAILSCALE_BIN_SITE = https://pkgs.tailscale.com/stable
ifeq ($(call qstrip,$(BR2_ARCH)),arm)
TAILSCALE_BIN_SOURCE = tailscale_$(TAILSCALE_BIN_VERSION)_arm.tgz
else ifeq ($(call qstrip,$(BR2_ARCH)),aarch64)
TAILSCALE_BIN_SOURCE = tailscale_$(TAILSCALE_BIN_VERSION)_arm64.tgz
else ifeq ($(call qstrip,$(BR2_ARCH)),i686)
TAILSCALE_BIN_SOURCE = tailscale_$(TAILSCALE_BIN_VERSION)_386.tgz
else ifeq ($(call qstrip,$(BR2_ARCH)),x86_64)
TAILSCALE_BIN_SOURCE = tailscale_$(TAILSCALE_BIN_VERSION)_amd64.tgz
endif
TAILSCALE_BIN_LICENSE = BSD-3-Clause
TAILSCALE_BIN_LICENSE_FILES = LICENSE

define TAILSCALE_BIN_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/tailscale $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/tailscaled $(TARGET_DIR)/usr/sbin/
endef

define TAILSCALE_BIN_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(TAILSCALE_BIN_PKGDIR)/S46tailscaled \
		$(TARGET_DIR)/etc/init.d/S46tailscaled
endef

$(eval $(generic-package))
