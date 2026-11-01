################################################################################
#
# eQ-3 char loopback kernel module for HomeMatic/homematicIP
# dual stack implementations for the RPI-RF-MOD/HM-MOD-RPI-PCB
#
# Copyright (c) 2015 by eQ-3 Entwicklung GmbH
# https://github.com/OpenCCU/OpenCCU-Base/tree/main/src/eq3_char_loop
#
################################################################################

# Only the single driver source file and the license are downloaded at the
# pinned OpenCCU-Base revision instead of extracting the whole OpenCCU-Base
# tree. The hashes are maintained by scripts/update-openccu-base.sh.
EQ3_CHAR_LOOP_VERSION = $(OPENCCU_BASE_VERSION)
EQ3_CHAR_LOOP_BASE_SITE = https://raw.githubusercontent.com/OpenCCU/OpenCCU-Base/$(EQ3_CHAR_LOOP_VERSION)
EQ3_CHAR_LOOP_SITE = $(EQ3_CHAR_LOOP_BASE_SITE)/src/eq3_char_loop
EQ3_CHAR_LOOP_SOURCE = eq3_char_loop.c
EQ3_CHAR_LOOP_EXTRA_DOWNLOADS = $(EQ3_CHAR_LOOP_BASE_SITE)/licenses/gpl-2.0.txt
EQ3_CHAR_LOOP_LICENSE = GPL-2.0+
EQ3_CHAR_LOOP_LICENSE_FILES = gpl-2.0.txt

define EQ3_CHAR_LOOP_EXTRACT_CMDS
	$(INSTALL) -m 0644 $(EQ3_CHAR_LOOP_DL_DIR)/eq3_char_loop.c $(@D)/eq3_char_loop.c
	$(INSTALL) -m 0644 $(EQ3_CHAR_LOOP_DL_DIR)/gpl-2.0.txt $(@D)/gpl-2.0.txt
	echo 'obj-m += eq3_char_loop.o' >$(@D)/Makefile
endef

$(eval $(kernel-module))
$(eval $(generic-package))
