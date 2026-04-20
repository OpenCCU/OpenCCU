
################################################################################
# licenseinfo integration
################################################################################

LICENSEINFO_VERSION = 1.0
LICENSEINFO_SITE_METHOD = local
LICENSEINFO_SITE = $(BR2_EXTERNAL_EQ3_PATH)/package/licenseinfo
LICENSEINFO_SOURCE =
LICENSEINFO_DEPENDS = occu

define LICENSEINFO_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/www/rega

	# Extract license information from JAR files in occu package
	python3 $(@D)/createLicenseForJar.py --packagedir=$(OCCU_DIR)/HMserver/opt/HMServer --jarfile=HMIPServer.jar --output=$(LICENSEINFO_DIR)/HMIPServer-JARLICENSEINFO.txt
	python3 $(@D)/createLicenseForJar.py --packagedir=$(OCCU_DIR)/HMserver/opt/HMServer --jarfile=HMServer.jar --output=$(LICENSEINFO_DIR)/HMServer-JARLICENSEINFO.txt
	python3 $(@D)/createLicenseForJar.py --packagedir=$(OCCU_DIR)/HMServer-Beta/opt/HmIP --jarfile=hmip-copro-update.jar --output=$(LICENSEINFO_DIR)/hmip-copro-update-JARLICENSEINFO.txt
	python3 $(@D)/createLicenseForJar.py --packagedir=$(OCCU_DIR)/HMServer-Beta/opt/HMServer/coupling --jarfile=ESHBridge.jar --output=$(LICENSEINFO_DIR)/ESHBridge-JARLICENSEINFO.txt
	
	# Create main license HTML file
	python3 $(@D)/createLicenseHtml.py --build-dir=$(BUILD_DIR)/../ \
		--jar-license-info=$(LICENSEINFO_DIR)/HMIPServer-JARLICENSEINFO.txt \
		--jar-license-info=$(LICENSEINFO_DIR)/HMServer-JARLICENSEINFO.txt \
		--jar-license-info=$(LICENSEINFO_DIR)/hmip-copro-update-JARLICENSEINFO.txt \
		--jar-license-info=$(LICENSEINFO_DIR)/ESHBridge-JARLICENSEINFO.txt \
		--output=$(TARGET_DIR)/www/rega/licenseinfo.htm
	
endef

$(eval $(generic-package))
