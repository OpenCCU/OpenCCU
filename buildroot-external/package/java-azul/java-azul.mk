################################################################################
#
# Azul java runtime - http://www.azul.com/downloads/zulu-embedded/
#
################################################################################

JAVA_AZUL_VERSION = 11.86.19-ca-jre11.0.30
ifeq ($(call qstrip,$(BR2_ARCH)),arm)
JAVA_AZUL_VERSION = 11.70.15-ca-hl-jre11.0.22
JAVA_AZUL_SOURCE = zulu$(JAVA_AZUL_VERSION)-linux_aarch32hf.tar.gz
JAVA_AZUL_SITE = https://cdn.azul.com/zulu-embedded/bin
else ifeq ($(call qstrip,$(BR2_ARCH)),aarch64)
JAVA_AZUL_SOURCE = zulu$(JAVA_AZUL_VERSION)-linux_aarch64.tar.gz
JAVA_AZUL_SITE = https://cdn.azul.com/zulu/bin
else ifeq ($(call qstrip,$(BR2_ARCH)),i686)
JAVA_AZUL_SOURCE = zulu$(JAVA_AZUL_VERSION)-linux_i686.tar.gz
JAVA_AZUL_SITE = https://cdn.azul.com/zulu/bin
else ifeq ($(call qstrip,$(BR2_ARCH)),x86_64)
JAVA_AZUL_SOURCE = zulu$(JAVA_AZUL_VERSION)-linux_x64.tar.gz
JAVA_AZUL_SITE = https://cdn.azul.com/zulu/bin
endif
JAVA_AZUL_LICENSE = GPL
JAVA_AZUL_LICENSE_FILES = DISCLAIMER
JAVA_AZUL_DEPENDENCIES = fontconfig dejavu liberation

define JAVA_AZUL_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/opt/java-azul
	cp -a $(@D)/bin $(TARGET_DIR)/opt/java-azul/
	cp -a $(@D)/conf $(TARGET_DIR)/opt/java-azul/
	cp -a $(@D)/lib $(TARGET_DIR)/opt/java-azul/
	cp -a $(@D)/legal $(TARGET_DIR)/opt/java-azul/
	cp -a $(@D)/DISCLAIMER $(TARGET_DIR)/opt/java-azul/
	rm -f $(TARGET_DIR)/opt/java
	ln -s java-azul $(TARGET_DIR)/opt/java
endef

$(eval $(generic-package))
