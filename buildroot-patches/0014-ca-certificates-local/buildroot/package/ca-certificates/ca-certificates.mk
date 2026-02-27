################################################################################
#
# ca-certificates
#
################################################################################

CA_CERTIFICATES_VERSION = 20230311
CA_CERTIFICATES_SOURCE = ca-certificates_$(CA_CERTIFICATES_VERSION).tar.xz
CA_CERTIFICATES_SITE = https://snapshot.debian.org/archive/debian/20230317T205011Z/pool/main/c/ca-certificates
CA_CERTIFICATES_DEPENDENCIES = host-openssl host-python3
CA_CERTIFICATES_LICENSE = GPL-2.0+ (script), MPL-2.0 (data)
CA_CERTIFICATES_LICENSE_FILES = debian/copyright

define CA_CERTIFICATES_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) clean all
endef

define CA_CERTIFICATES_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/ca-certificates
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install DESTDIR=$(TARGET_DIR)
endef

define CA_CERTIFICATES_GEN_BUNDLE
	# Remove /etc/ssl/certs and relink it to /var/etc/ssl/certs
	rm -rf $(TARGET_DIR)/etc/ssl/certs
	ln -s /var/etc/ssl/certs $(TARGET_DIR)/etc/ssl/certs

	# add empty /etc/ca-certificates.conf file
	touch $(TARGET_DIR)/etc/ca-certificates.conf
endef
CA_CERTIFICATES_TARGET_FINALIZE_HOOKS += CA_CERTIFICATES_GEN_BUNDLE

define CA_CERTIFICATES_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(CA_CERTIFICATES_PKGDIR)/S07ca-certificates \
		$(TARGET_DIR)/etc/init.d/S07ca-certificates
endef

$(eval $(generic-package))
