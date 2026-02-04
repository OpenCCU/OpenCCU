################################################################################
#
# Azul java runtime - https://www.azul.com/downloads/?package=jre#zulu
#
################################################################################

JAVA_AZUL_VERSION = 11.86.19-ca-jre11.0.30
JAVA_AZUL_SITE = https://cdn.azul.com/zulu/bin
ifeq ($(call qstrip,$(BR2_ARCH)),aarch64)
JAVA_AZUL_SOURCE = zulu$(JAVA_AZUL_VERSION)-linux_aarch64.tar.gz
else ifeq ($(call qstrip,$(BR2_ARCH)),x86_64)
JAVA_AZUL_SOURCE = zulu$(JAVA_AZUL_VERSION)-linux_x64.tar.gz
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
