################################################################################
#
# ca-certificates
#
################################################################################

CA_CERTIFICATES_VERSION = 20260223
CA_CERTIFICATES_SOURCE = ca-certificates_$(CA_CERTIFICATES_VERSION).tar.xz
CA_CERTIFICATES_SITE = https://snapshot.debian.org/archive/debian/20260223T202245Z/pool/main/c/ca-certificates
CA_CERTIFICATES_DEPENDENCIES = host-openssl host-python3
HOST_CA_CERTIFICATES_DEPENDENCIES = host-openssl host-python3
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

define HOST_CA_CERTIFICATES_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) clean all
endef

define HOST_CA_CERTIFICATES_INSTALL_CMDS
	$(INSTALL) -d -m 0755 $(HOST_DIR)/share/ca-certificates
	$(INSTALL) -d -m 0755 $(HOST_DIR)/etc/ssl/certs
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) install DESTDIR=$(HOST_DIR)
	rm -f $(HOST_DIR)/sbin/update-ca-certificates
	# Remove any existing certificates under /etc/ssl/certs
	rm -f $(HOST_DIR)/etc/ssl/certs/*

	# Create symlinks to certificates under /etc/ssl/certs
	# and generate the bundle
	cd $(HOST_DIR) ;\
	for i in `find share/ca-certificates -name "*.crt" | LC_COLLATE=C sort` ; do \
		ln -sf ../../../$$i etc/ssl/certs/`basename $${i} .crt`.pem ;\
		cat $$i ;\
	done >$(BUILD_DIR)/ca-certificates.crt

	# Create symlinks to the certificates by their hash values
	$(HOST_DIR)/bin/c_rehash $(HOST_DIR)/etc/ssl/certs

	# Install the certificates bundle
	$(INSTALL) -D -m 644 $(BUILD_DIR)/ca-certificates.crt \
		$(HOST_DIR)/etc/ssl/certs/ca-certificates.crt
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
