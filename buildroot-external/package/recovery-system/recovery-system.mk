################################################################################
#
# Recovery Image Package
#
################################################################################

RECOVERY_SYSTEM_VER = 1.21.0
RECOVERY_SYSTEM_VERSION = $(RECOVERY_SYSTEM_VER)-$(BR2_VERSION)
RECOVERY_SYSTEM_SOURCE =
RECOVERY_SYSTEM_LICENSE = Apache-2.0

define RECOVERY_SYSTEM_CONFIGURE_CMDS
	mkdir -p $(@D)/output/build
	rsync -a --ignore-missing-args --exclude '.stamp_target_installed' --exclude ".stamp_staging_installed" --exclude '.stamp_images_installed' --exclude '.stamp_installed' $(@D)/../multilib32-* $(@D)/output/build/
endef

define RECOVERY_SYSTEM_BUILD_CMDS
	$(MAKE) O=$(@D)/output -C $(TOPDIR) HOSTCXX="$(HOSTCXX_NOCCACHE)" HOSTCC="$(HOSTCC_NOCCACHE)" BR2_EXTERNAL=$(RECOVERY_SYSTEM_PKGDIR)/external alldefconfig
	(cd $(@D)/output && HOSTCXX="$(HOSTCXX_NOCCACHE)" HOSTCC="$(HOSTCC_NOCCACHE)" BR2_EXTERNAL=$(RECOVERY_SYSTEM_PKGDIR)/external BR2_RECOVERY_SYSTEM_VERSION=$(PRODUCT_VERSION)-$(RECOVERY_SYSTEM_VER) BR2_PACKAGE_PSPLASH_IMAGE=$(BR2_PACKAGE_PSPLASH_IMAGE) BR2_EXTERNAL_LINUX_KERNEL_CUSTOM_VERSION_VALUE=$(BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE) BR2_EXTERNAL_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION=$(BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION) $(TOPDIR)/support/kconfig/merge_config.sh $(RECOVERY_SYSTEM_PKGDIR)/external/Buildroot.config $(RECOVERY_SYSTEM_PKGDIR)/external/configs/$(BR2_PACKAGE_RECOVERY_SYSTEM_CONFIG_FRAGMENT_FILE))
	$(MAKE) O=$(@D)/output -C $(TOPDIR) HOSTCXX="$(HOSTCXX_NOCCACHE)" HOSTCC="$(HOSTCC_NOCCACHE)" BR2_EXTERNAL=$(RECOVERY_SYSTEM_PKGDIR)/external BR2_RECOVERY_SYSTEM_VERSION=$(PRODUCT_VERSION)-$(RECOVERY_SYSTEM_VER) BR2_PACKAGE_PSPLASH_IMAGE=$(BR2_PACKAGE_PSPLASH_IMAGE) BR2_EXTERNAL_LINUX_KERNEL_CUSTOM_VERSION_VALUE=$(BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE) BR2_EXTERNAL_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION=$(BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION)
endef

define RECOVERY_SYSTEM_INSTALL_TARGET_CMDS
	test -f $(@D)/output/images/rootfs.cpio.uboot && cp -a $(@D)/output/images/rootfs.cpio.uboot $(BINARIES_DIR)/recoveryfs-initrd || cp -a $(@D)/output/images/rootfs.cpio.lz4 $(BINARIES_DIR)/recoveryfs-initrd
	test -f $(@D)/output/images/bzImage && cp -a $(@D)/output/images/bzImage $(BINARIES_DIR)/recoveryfs-zImage || true
	test -f $(@D)/output/images/zImage && cp -a $(@D)/output/images/zImage $(BINARIES_DIR)/recoveryfs-zImage || true
	test -f $(@D)/output/images/Image && cp -a $(@D)/output/images/Image $(BINARIES_DIR)/recoveryfs-Image || true
endef

$(eval $(generic-package))
