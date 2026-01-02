BUILDROOT_VERSION=2025.11
BUILDROOT_SHA256=50062bfb50d3bae686daddd90885b02de018c1abf36034e0637bffdca28d9b98
BUILDROOT_EXTERNAL=buildroot-external
DEFCONFIG_DIR=$(BUILDROOT_EXTERNAL)/configs
OCCU_VERSION=$(shell grep "OCCU_VERSION =" $(BUILDROOT_EXTERNAL)/package/occu/occu.mk | cut -d' ' -f3 | cut -d'-' -f1)
DATE=$(shell date +%Y%m%d)
PRODUCT=
PRODUCT_VERSION:=$(OCCU_VERSION).$(DATE)
PRODUCTS:=$(sort $(notdir $(patsubst %.config,%,$(wildcard $(DEFCONFIG_DIR)/*.config))))
BR2_DL_DIR=$(shell pwd)/download
BR2_CCACHE_DIR=${HOME}/.buildroot-ccache
BR2_JLEVEL=$(shell nproc)

ifneq ($(PRODUCT),)
	PRODUCTS:=$(PRODUCT)
else
	PRODUCT:=$(firstword $(PRODUCTS))
endif

PLATFORM:=$(shell echo -n $(PRODUCT) | sed 's/_\(amd64\|arm.*\)//')

.NOTPARALLEL: $(PRODUCTS) $(addsuffix -release, $(PRODUCTS)) $(addsuffix -clean, $(PRODUCTS)) build-all clean-all release-all
.PHONY: all build release clean clean-all distclean default buildroot-help help updatePkg

all: help

buildroot-$(BUILDROOT_VERSION).tar.gz: $(BR2_DL_DIR)
	@echo "[downloading buildroot-$(BUILDROOT_VERSION).tar.gz]"
	wget https://github.com/buildroot/buildroot/archive/refs/tags/$(BUILDROOT_VERSION).tar.gz -O buildroot-$(BUILDROOT_VERSION).tar.gz
	echo "$(BUILDROOT_SHA256)  buildroot-$(BUILDROOT_VERSION).tar.gz" >buildroot-$(BUILDROOT_VERSION).tar.gz.sign
	shasum -a 256 -c buildroot-$(BUILDROOT_VERSION).tar.gz.sign

buildroot-$(BUILDROOT_VERSION): | buildroot-$(BUILDROOT_VERSION).tar.gz
	@echo "[patching buildroot-$(BUILDROOT_VERSION)]"
	if [ ! -d $@ ]; then tar xf buildroot-$(BUILDROOT_VERSION).tar.gz; for p in $(sort $(wildcard buildroot-patches/*.patch)); do echo "\nApplying $${p}"; patch -d buildroot-$(BUILDROOT_VERSION) --remove-empty-files --no-backup-if-mismatch -p1 < $${p} || exit 127; [ ! -x $${p%.*}.sh ] || $${p%.*}.sh buildroot-$(BUILDROOT_VERSION); done; fi

build-$(PRODUCT): | buildroot-$(BUILDROOT_VERSION)
	mkdir $(shell pwd)/build-$(PRODUCT)

$(BR2_DL_DIR):
	@echo "[mkdir $(BR2_DL_DIR)]"
	test -e $(BR2_DL_DIR) || mkdir $(BR2_DL_DIR)

$(BR2_CCACHE_DIR):
	@echo "[mkdir $(BR2_CCACHE_DIR)]"
	test -e $(BR2_CCACHE_DIR) || mkdir $(BR2_CCACHE_DIR)

build-$(PRODUCT)/.config: | build-$(PRODUCT) $(BR2_CCACHE_DIR)
	@echo "[config $@]"
	cd $(shell pwd)/build-$(PRODUCT) && $(MAKE) O=$(shell pwd)/build-$(PRODUCT) -C ../buildroot-$(BUILDROOT_VERSION) BR2_EXTERNAL=../$(BUILDROOT_EXTERNAL) BR2_DL_DIR=$(BR2_DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) alldefconfig
	cd $(shell pwd)/build-$(PRODUCT) && BR2_EXTERNAL=../$(BUILDROOT_EXTERNAL) BR2_DL_DIR=$(BR2_DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) ../buildroot-$(BUILDROOT_VERSION)/support/kconfig/merge_config.sh ../$(BUILDROOT_EXTERNAL)/Buildroot.config ../$(BUILDROOT_EXTERNAL)/configs/$(PRODUCT).config

build-all: $(PRODUCTS)
$(PRODUCTS): %:
	@echo "[build1: $@]"
	@$(MAKE) PRODUCT=$@ PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) build

build: | buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)/.config
	@echo "[build: $(PRODUCT)]"
ifneq ($(FAKE_BUILD),true)
	cd $(shell pwd)/build-$(PRODUCT) && $(MAKE) O=$(shell pwd)/build-$(PRODUCT) -C ../buildroot-$(BUILDROOT_VERSION) BR2_EXTERNAL=../$(BUILDROOT_EXTERNAL) BR2_DL_DIR=$(BR2_DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM)
else
	$(eval BOARD := $(shell echo $(PRODUCT)))
	# Dummy build - mainly for testing CI
	echo -n "FAKE_BUILD - generating fake release archives..."
	mkdir -p build-$(PRODUCT)/images
	for f in `cat release/updatepkg/$(PRODUCT)/files-images.txt`; do echo DUMMY >build-$(PRODUCT)/images/$${f}; done
	# create fake OCI/Docker image
	$(eval TMPDIR := $(shell mktemp -d))
	mkdir -p $(TMPDIR)/oci $(TMPDIR)/sbin
	echo -e '#!/bin/sh\nwhile true; do echo CONTINUE; sleep 5; done\nexit 0' >$(TMPDIR)/sbin/init
	chmod a+rx $(TMPDIR)/sbin/init
	mkdir -p $(TMPDIR)/var/status
	touch $(TMPDIR)/var/status/startupFinished
	echo DUMMY >$(TMPDIR)/LICENSE
	tar -C $(TMPDIR) -cvf $(TMPDIR)/oci/layer.tar LICENSE sbin/init var/status/startupFinished
	echo '[{"Layers":["oci/layer.tar"]}]' >$(TMPDIR)/manifest.json
	tar -C $(TMPDIR) -cvf $(TMPDIR)/OpenCCU-$(PRODUCT_VERSION)-$(BOARD).tar oci manifest.json
	mv $(TMPDIR)/OpenCCU-$(PRODUCT_VERSION)-$(BOARD).tar build-$(PRODUCT)/images/
	rm -rf $(TMPDIR)
	# create fake sdcard.img and ova
	echo DUMMY >build-$(PRODUCT)/images/sdcard.img
	echo DUMMY >build-$(PRODUCT)/images/OpenCCU.ova
endif

release-all: $(addsuffix -release, $(PRODUCTS))
$(addsuffix -release, $(PRODUCTS)): %:
	@$(MAKE) PRODUCT=$(subst -release,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) release

release: build
	@echo "[creating release: $(PRODUCT)]"
	$(eval BOARD_DIR := $(BUILDROOT_EXTERNAL)/board/$(shell echo $(PRODUCT) | sed 's/_\(amd64\|arm.*\)//'))
	if [ -x $(BOARD_DIR)/post-release.sh ]; then $(BOARD_DIR)/post-release.sh $(BOARD_DIR) $(PRODUCT) $(PRODUCT_VERSION); fi

check-all: $(addsuffix -check, $(PRODUCTS))
$(addsuffix -check, $(PRODUCTS)): %:
	@$(MAKE) PRODUCT=$(subst -check,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) check

check: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)/.config
	@echo "[checking: $(PRODUCT)]"
	$(eval BOARD_DIR := $(BUILDROOT_EXTERNAL)/board/$(shell echo $(PRODUCT) | sed 's/_\(amd64\|arm.*\)//'))
	@echo "[checking status: $(BUILDROOT_EXTERNAL)]"
	buildroot-$(BUILDROOT_VERSION)/utils/check-package --exclude PackageHeader --br2-external $(BUILDROOT_EXTERNAL)/package/*/*
	@echo "[checking apply patch status: OCCU $(OCCU_VERSION)]"
	(cd $(BUILDROOT_EXTERNAL)/patches/occu ; ./create_patches.sh)
	rm -rf build-$(PRODUCT)/build/occu-$(OCCU_VERSION)*
	$(MAKE) -C build-$(PRODUCT) occu-patch
	@echo "[checking clean patch status: OCCU $(OCCU_VERSION)]"
	git diff --exit-code $(BUILDROOT_EXTERNAL)/patches/occu/*.patch

clean-all: $(addsuffix -clean, $(PRODUCTS))
$(addsuffix -clean, $(PRODUCTS)): %:
	@$(MAKE) PRODUCT=$(subst -clean,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) clean

clean:
	@echo "[clean $(PRODUCT)]"
	@rm -rf build-$(PRODUCT)

distclean: clean-all
	@echo "[distclean]"
	@rm -rf buildroot-$(BUILDROOT_VERSION)
	@rm -f buildroot-$(BUILDROOT_VERSION).tar.*
	@rm -rf $(BR2_DL_DIR)

.PHONY: menuconfig
menuconfig: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)/.config
	cd $(shell pwd)/build-$(PRODUCT) && $(MAKE) O=$(shell pwd)/build-$(PRODUCT) -C ../buildroot-$(BUILDROOT_VERSION) BR2_EXTERNAL=../$(BUILDROOT_EXTERNAL) BR2_DL_DIR=$(BR2_DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) menuconfig

.PHONY: xconfig
xconfig: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)/.config
	cd $(shell pwd)/build-$(PRODUCT) && $(MAKE) O=$(shell pwd)/build-$(PRODUCT) -C ../buildroot-$(BUILDROOT_VERSION) BR2_EXTERNAL=../$(BUILDROOT_EXTERNAL) BR2_DL_DIR=$(BR2_DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) xconfig

.PHONY: savedefconfig
savedefconfig: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)
	cd $(shell pwd)/build-$(PRODUCT) && $(MAKE) O=$(shell pwd)/build-$(PRODUCT) -C ../buildroot-$(BUILDROOT_VERSION) BR2_EXTERNAL=../$(BUILDROOT_EXTERNAL) BR2_DL_DIR=$(BR2_DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) savedefconfig BR2_DEFCONFIG=../$(DEFCONFIG_DIR)/$(PRODUCT).config

.PHONY: toolchain
toolchain: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)/.config
	cd $(shell pwd)/build-$(PRODUCT) && $(MAKE) O=$(shell pwd)/build-$(PRODUCT) -C ../buildroot-$(BUILDROOT_VERSION) BR2_EXTERNAL=../$(BUILDROOT_EXTERNAL) BR2_DL_DIR=$(BR2_DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) toolchain

.PHONY: recovery-menuconfig
recovery-menuconfig: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)/.config
	cd $(shell pwd)/build-$(PRODUCT)/build/recovery-system-*/output && $(MAKE) BR2_EXTERNAL_EQ3_PATH=$(shell pwd)/$(BUILDROOT_EXTERNAL) menuconfig

.PHONY: recovery-savedefconfig
recovery-savedefconfig: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)/.config
	cd $(shell pwd)/build-$(PRODUCT)/build/recovery-system-*/output && $(MAKE) BR2_EXTERNAL_EQ3_PATH=$(shell pwd)/$(BUILDROOT_EXTERNAL) savedefconfig

.PHONY: multilib32-menuconfig
multilib32-menuconfig: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)/.config
	cd $(shell pwd)/build-$(PRODUCT)/build/multilib32-*/output && $(MAKE) BR2_EXTERNAL_EQ3_PATH=$(shell pwd)/$(BUILDROOT_EXTERNAL) menuconfig

.PHONY: multilib32-savedefconfig
multilib32-savedefconfig: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)/.config
	cd $(shell pwd)/build-$(PRODUCT)/build/multilib32-*/output && $(MAKE) BR2_EXTERNAL_EQ3_PATH=$(shell pwd)/$(BUILDROOT_EXTERNAL) savedefconfig

.PHONY: linux-check-dotconfig
linux-check-dotconfig: buildroot-$(BUILDROOT_VERSION) build-$(PRODUCT)
	cd $(shell pwd)/build-$(PRODUCT) && $(MAKE) O=$(shell pwd)/build-$(PRODUCT) -C ../buildroot-$(BUILDROOT_VERSION) BR2_EXTERNAL=../$(BUILDROOT_EXTERNAL) BR2_DL_DIR=$(BR2_DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) linux-check-dotconfig BR2_DEFCONFIG=../$(DEFCONFIG_DIR)/$(PRODUCT).config BR2_CHECK_DOTCONFIG_OPTS="--github-format --strip-path-prefix=$(PWD)/"

# Create a fallback target (%) to forward all unknown target calls to the build Makefile.
# This includes:
#   linux-menuconfig
#   linux-update-defconfig
#   busybox-menuconfig
#   busybox-update-config
#   uboot-menuconfig
#   uboot-update-defconfig
linux-menuconfig linux-update-defconfig busybox-menuconfig busybox-update-config uboot-menuconfig uboot-update-defconfig legal-info:
	@echo "[$@ $(PRODUCT)]"
	@$(MAKE) -C build-$(PRODUCT) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) $@

buildroot-help:
	@$(MAKE) -C build-$(PRODUCT) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) PRODUCT_PLATFORM=$(PLATFORM) help

help:
	@echo "OpenCCU Build Environment"
	@echo
	@echo "Usage:"
	@echo "  $(MAKE) <product>: build+create image for selected product"
	@echo "  $(MAKE) build-all: run build for all supported products"
	@echo
	@echo "  $(MAKE) <product>-release: build+create release archive for product"
	@echo "  $(MAKE) release-all: build+create release archive for all supported products"
	@echo
	@echo "  $(MAKE) <product>-check: run ci consistency check for product"
	@echo "  $(MAKE) check-all: run ci consistency check all supported platforms"
	@echo
	@echo "  $(MAKE) <product>-clean: remove build directory for product"
	@echo "  $(MAKE) clean-all: remove build directories for all supported platforms"
	@echo
	@echo "  $(MAKE) distclean: clean everything (all build dirs and buildroot sources)"
	@echo
	@echo "  $(MAKE) PRODUCT=<product> menuconfig: change buildroot config options"
	@echo "  $(MAKE) PRODUCT=<product> savedefconfig: update buildroot defconfig file"
	@echo "  $(MAKE) PRODUCT=<product> linux-menuconfig: change linux kernel config option"
	@echo "  $(MAKE) PRODUCT=<product> linux-update-defconfig: update linux kernel defconfig file"
	@echo "  $(MAKE) PRODUCT=<product> linux-check-dotconfig: checks dotconfig files against Kconfig"
	@echo "  $(MAKE) PRODUCT=<product> busybox-menuconfig: change busybox config options"
	@echo "  $(MAKE) PRODUCT=<product> busybox-update-config: update busybox defconfig file"
	@echo "  $(MAKE) PRODUCT=<product> uboot-menuconfig: change u-boot config options"
	@echo "  $(MAKE) PRODUCT=<product> uboot-update-defconfig: update u-boot defconfig file"
	@echo "  $(MAKE) PRODUCT=<product> recovery-menuconfig: change config options for recovery system"
	@echo "  $(MAKE) PRODUCT=<product> recovery-savedefconfig: update defconfig file for recovery system"
	@echo "  $(MAKE) PRODUCT=<product> multilib32-menuconfig: change config options for multilib32 build environment"
	@echo "  $(MAKE) PRODUCT=<product> multilib32-savedefconfig: update defconfig file for multilib32 build environment"
	@echo
	@echo "  $(MAKE) PRODUCT=<product> legal-info: update legal information file"
	@echo
	@echo "Supported products: $(PRODUCTS)"
