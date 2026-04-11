################################################################################
#
# rpi-userland
#
################################################################################

RPI_USERLAND_VERSION = a54a0dbb2b8dcf9bafdddfc9a9374fb51d97e976
RPI_USERLAND_SITE = $(call github,raspberrypi,userland,$(RPI_USERLAND_VERSION))
RPI_USERLAND_LICENSE = BSD-3-Clause
RPI_USERLAND_LICENSE_FILES = LICENCE
RPI_USERLAND_INSTALL_STAGING = YES

# ARM64=ON disables MMAL/OpenMAX builds not supported on aarch64;
# for 32-bit ARM the flag is omitted so those features build normally.
# CMAKE_POLICY_VERSION_MINIMUM=3.5 is required because upstream
# CMakeLists.txt uses cmake_minimum_required below 3.5, which newer
# CMake versions no longer support without this override.
RPI_USERLAND_CONF_OPTS = \
	-DVMCS_INSTALL_PREFIX=/usr \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	$(if $(BR2_aarch64),-DARM64=ON)

$(eval $(cmake-package))
