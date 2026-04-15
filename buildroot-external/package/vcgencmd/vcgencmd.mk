################################################################################
#
# vcgencmd (rpi-userland tool)
#
################################################################################

VCGENCMD_VERSION = a54a0dbb2b8dcf9bafdddfc9a9374fb51d97e976
VCGENCMD_SITE = $(call github,raspberrypi,userland,$(VCGENCMD_VERSION))
VCGENCMD_LICENSE = BSD-3-Clause
VCGENCMD_LICENSE_FILES = LICENCE
VCGENCMD_INSTALL_STAGING = YES

# ARM64=ON disables MMAL/OpenMAX builds not supported on aarch64;
# for 32-bit ARM the flag is omitted so those features build normally.
# CMAKE_POLICY_VERSION_MINIMUM=3.5 is required because upstream
# CMakeLists.txt uses cmake_minimum_required below 3.5, which newer
# CMake versions no longer support without this override.
VCGENCMD_CONF_OPTS = \
	-DVMCS_INSTALL_PREFIX=/usr \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	$(if $(BR2_aarch64),-DARM64=ON)

define VCGENCMD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/vcgencmd $(TARGET_DIR)/usr/bin/vcgencmd
endef

$(eval $(cmake-package))
