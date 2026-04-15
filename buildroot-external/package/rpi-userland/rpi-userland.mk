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

define RPI_USERLAND_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/vcgencmd $(TARGET_DIR)/usr/bin/vcgencmd
	set -e; \
	set -- "$(TARGET_DIR)/usr/bin/vcgencmd"; \
	processed=""; \
	while [ "$$#" -gt 0 ]; do \
		current="$$1"; \
		shift; \
		case " $$processed " in *" $$current "*) continue ;; esac; \
		processed="$$processed $$current"; \
		for lib in $$($(TARGET_CROSS)readelf -d "$$current" 2>/dev/null | awk -F'[][]' '/Shared library:/ {print $$2}'); do \
			for libdir in /lib /usr/lib; do \
				src="$(STAGING_DIR)$$libdir/$$lib"; \
				dst="$(TARGET_DIR)$$libdir/$$lib"; \
				if [ -e "$$src" ]; then \
					mkdir -p "$(TARGET_DIR)$$libdir"; \
					cp -dpf "$$src" "$$dst"; \
					if [ -L "$$src" ]; then \
						link_target="$$(readlink "$$src")"; \
						case "$$link_target" in \
							/*) real_src="$(STAGING_DIR)$$link_target"; real_dst="$(TARGET_DIR)$$link_target" ;; \
							*) real_src="$$(dirname "$$src")/$$link_target"; real_dst="$$(dirname "$$dst")/$$link_target" ;; \
						esac; \
						if [ -e "$$real_src" ] && [ ! -e "$$real_dst" ]; then \
							mkdir -p "$$(dirname "$$real_dst")"; \
							cp -dpf "$$real_src" "$$real_dst"; \
						fi; \
					fi; \
					case " $$processed $* " in *" $$dst "*) ;; *) set -- "$$@" "$$dst" ;; esac; \
					break; \
				fi; \
			done; \
		done; \
	done
endef

$(eval $(cmake-package))
