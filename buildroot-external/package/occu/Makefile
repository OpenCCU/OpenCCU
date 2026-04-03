# 
# OCCU package Makefile
#

install:
	#################################
	# RFD
	# collect legacy binaries (32bit)
	mkdir -p $(TARGET_DIR)/bin
	cp -av $(OCCU_COMMON)/packages-eQ-3/RFD/bin/SetInterfaceClock $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/SetInterfaceClock
	cp -av $(OCCU_COMMON)/packages-eQ-3/RFD/bin/crypttool $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/crypttool
	cp -av $(OCCU_COMMON)/packages-eQ-3/RFD/bin/multimacd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/multimacd
	cp -av $(OCCU_COMMON)/packages-eQ-3/RFD/bin/rfd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/rfd
	# collect legacy libraries (32bit)
ifneq ($(OCCU_LIB32), )
	mkdir -p $(TARGET_DIR)/$(OCCU_LIB32)
	cp -av $(OCCU_COMMON)/packages-eQ-3/RFD/lib/libLanDeviceUtils.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libLanDeviceUtils.so
	cp -av $(OCCU_COMMON)/packages-eQ-3/RFD/lib/libUnifiedLanComm.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libUnifiedLanComm.so
	cp -av $(OCCU_COMMON)/packages-eQ-3/RFD/lib/libelvutils.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libelvutils.so
	cp -av $(OCCU_COMMON)/packages-eQ-3/RFD/lib/libhsscomm.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libhsscomm.so
endif
	# collect legacy config templates
	mkdir -p $(TARGET_DIR)/etc/config_templates
	cp -av $(OCCU_COMMON)/packages-eQ-3/RFD/etc/crRFD_ccu3.conf $(TARGET_DIR)/etc/config_templates/crRFD.conf
	chmod 644 $(TARGET_DIR)/etc/config_templates/crRFD.conf
	# collect legacy device firmwares
	mkdir -p $(TARGET_DIR)/firmware
	cp -Rv firmware/* $(TARGET_DIR)/firmware/
ifneq ($(OCCU_ARCH32), )
	# collect modern binaries (32bit)
	cp -av $(OCCU_ARCH32)/packages-eQ-3/RFD-Beta/bin/SetInterfaceClock $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/SetInterfaceClock
	cp -av $(OCCU_ARCH32)/packages-eQ-3/RFD-Beta/bin/crypttool $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/crypttool
	cp -av $(OCCU_ARCH32)/packages-eQ-3/RFD-Beta/bin/multimacd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/multimacd
	cp -av $(OCCU_ARCH32)/packages-eQ-3/RFD-Beta/bin/rfd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/rfd
	# collect modern libraries (32bit)
ifneq ($(OCCU_LIB32), )
	cp -av $(OCCU_ARCH32)/packages-eQ-3/RFD-Beta/lib/libLanDeviceUtils.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libLanDeviceUtils.so
	cp -av $(OCCU_ARCH32)/packages-eQ-3/RFD-Beta/lib/libUnifiedLanComm.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libUnifiedLanComm.so
	cp -av $(OCCU_ARCH32)/packages-eQ-3/RFD-Beta/lib/libelvutils.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libelvutils.so
	cp -av $(OCCU_ARCH32)/packages-eQ-3/RFD-Beta/lib/libhsscomm.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libhsscomm.so
endif
endif
ifneq ($(OCCU_ARCH64), )
	# collect modern binaries (64bit)
	cp -av $(OCCU_ARCH64)/packages-eQ-3/RFD-Beta/bin/SetInterfaceClock $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/SetInterfaceClock
	cp -av $(OCCU_ARCH64)/packages-eQ-3/RFD-Beta/bin/crypttool $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/crypttool
	cp -av $(OCCU_ARCH64)/packages-eQ-3/RFD-Beta/bin/multimacd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/multimacd
	cp -av $(OCCU_ARCH64)/packages-eQ-3/RFD-Beta/bin/rfd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/rfd
	# collect modern libraries (64bit)
	mkdir -p $(TARGET_DIR)/$(OCCU_LIB64)
	cp -av $(OCCU_ARCH64)/packages-eQ-3/RFD-Beta/lib/libLanDeviceUtils.so $(TARGET_DIR)/$(OCCU_LIB64)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB64)/libLanDeviceUtils.so
	cp -av $(OCCU_ARCH64)/packages-eQ-3/RFD-Beta/lib/libUnifiedLanComm.so $(TARGET_DIR)/$(OCCU_LIB64)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB64)/libUnifiedLanComm.so
	cp -av $(OCCU_ARCH64)/packages-eQ-3/RFD-Beta/lib/libelvutils.so $(TARGET_DIR)/$(OCCU_LIB64)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB64)/libelvutils.so
	cp -av $(OCCU_ARCH64)/packages-eQ-3/RFD-Beta/lib/libhsscomm.so $(TARGET_DIR)/$(OCCU_LIB64)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB64)/libhsscomm.so
endif

	#################################
	# HS485d
	# collect legacy binaries (32bit)
	mkdir -p $(TARGET_DIR)/bin
	cp -av $(OCCU_COMMON)/packages-eQ-3/HS485D/bin/hs485d $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/hs485d
	cp -av $(OCCU_COMMON)/packages-eQ-3/HS485D/bin/hs485dLoader $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/hs485dLoader
ifneq ($(OCCU_ARCH32), )
	# collect modern binaries (32bit)
	cp -av $(OCCU_ARCH32)/packages-eQ-3/HS485D-Beta/bin/hs485d $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/hs485d
	cp -av $(OCCU_ARCH32)/packages-eQ-3/HS485D-Beta/bin/hs485dLoader $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/hs485dLoader
endif
ifneq ($(OCCU_ARCH64), )
	# collect modern binaries (64bit)
	cp -av $(OCCU_ARCH64)/packages-eQ-3/HS485D-Beta/bin/hs485d $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/hs485d
	cp -av $(OCCU_ARCH64)/packages-eQ-3/HS485D-Beta/bin/hs485dLoader $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/hs485dLoader
endif

	#################################
	# WebUI
	# collect legacy binaries (32bit)
	cp -av $(OCCU_COMMON)/packages-eQ-3/WebUI/bin/ReGaHss.community $(TARGET_DIR)/bin/ReGaHss
	chmod 755 $(TARGET_DIR)/bin/ReGaHss
	# copy tcl homematic pkg to tcl 8.6 path
	cp -Rv $(OCCU_COMMON)/packages-eQ-3/WebUI/lib/tcl8.2/homematic $(TARGET_DIR)/usr/lib/tcl8.6/
	# copy whole WebUI to target dir
	cp -Rv WebUI/* $(TARGET_DIR)/
	# copy ReGaHss beta to target dir
ifeq ($(OCCU_WEBUI_REGAHSS_BETA), y)
	cp -av $(OCCU_COMMON)/packages-eQ-3/WebUI-Beta/bin/ReGaHss $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/ReGaHss
ifneq ($(OCCU_ARCH32), )
	# collect modern binaries (32bit)
	cp -av $(OCCU_ARCH32)/packages-eQ-3/WebUI-Beta/bin/ReGaHss $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/ReGaHss
endif
ifneq ($(OCCU_ARCH64), )
	# collect modern binaries (64bit)
	cp -av $(OCCU_ARCH64)/packages-eQ-3/WebUI-Beta/bin/ReGaHss $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/ReGaHss
endif
endif

	#################################
	# LinuxBasis
	# collect legacy binaries (32bit)
	cp -av $(OCCU_COMMON)/packages-eQ-3/LinuxBasis/bin/eq3configcmd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/eq3configcmd
	cp -av $(OCCU_COMMON)/packages-eQ-3/LinuxBasis/bin/eq3configd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/eq3configd
	cp -av $(OCCU_COMMON)/packages-eQ-3/LinuxBasis/bin/hss_led $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/hss_led
	cp -av $(OCCU_COMMON)/packages-eQ-3/LinuxBasis/bin/ssdpd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/ssdpd
	# collect legacy libraries (32bit)
ifneq ($(OCCU_LIB32), )
	cp -av $(OCCU_COMMON)/packages-eQ-3/LinuxBasis/lib/libeq3config.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libeq3config.so
endif
ifneq ($(OCCU_ARCH32), )
	# collect modern binaries (32bit)
	cp -av $(OCCU_ARCH32)/packages-eQ-3/LinuxBasis-Beta/bin/eq3configcmd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/eq3configcmd
	cp -av $(OCCU_ARCH32)/packages-eQ-3/LinuxBasis-Beta/bin/eq3configd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/eq3configd
	cp -av $(OCCU_ARCH32)/packages-eQ-3/LinuxBasis-Beta/bin/hss_led $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/hss_led
	cp -av $(OCCU_ARCH32)/packages-eQ-3/LinuxBasis-Beta/bin/ssdpd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/ssdpd
	# collect modern libraries (32bit)
ifneq ($(OCCU_LIB32), )
	cp -av $(OCCU_ARCH32)/packages-eQ-3/LinuxBasis-Beta/lib/libeq3config.so $(TARGET_DIR)/$(OCCU_LIB32)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB32)/libeq3config.so
endif
endif
ifneq ($(OCCU_ARCH64), )
	# collect modern binaries (64bit)
	cp -av $(OCCU_ARCH64)/packages-eQ-3/LinuxBasis-Beta/bin/eq3configcmd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/eq3configcmd
	cp -av $(OCCU_ARCH64)/packages-eQ-3/LinuxBasis-Beta/bin/eq3configd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/eq3configd
	cp -av $(OCCU_ARCH64)/packages-eQ-3/LinuxBasis-Beta/bin/hss_led $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/hss_led
	cp -av $(OCCU_ARCH64)/packages-eQ-3/LinuxBasis-Beta/bin/ssdpd $(TARGET_DIR)/bin/
	chmod 755 $(TARGET_DIR)/bin/ssdpd
	# collect modern libraries (64bit)
	cp -av $(OCCU_ARCH64)/packages-eQ-3/LinuxBasis-Beta/lib/libeq3config.so $(TARGET_DIR)/$(OCCU_LIB64)/
	chmod 755 $(TARGET_DIR)/$(OCCU_LIB64)/libeq3config.so
endif

	#################################
	# HMIPServer
	mkdir -p $(TARGET_DIR)/opt/HMServer
	cp -av HMserver/etc/config_templates/log4j2.xml $(TARGET_DIR)/etc/config_templates/
	cp -Rv HMserver/opt/HMServer/groups $(TARGET_DIR)/opt/HMServer/
	cp -Rv HMserver/opt/HMServer/measurement $(TARGET_DIR)/opt/HMServer/
	cp -Rv HMserver/opt/HMServer/pages $(TARGET_DIR)/opt/HMServer/
	cp -av HMserver/opt/HMServer/coupling $(TARGET_DIR)/opt/HMServer/
ifneq (,$(filter $(OCCU_RF_PROTOCOL), HM_HMIP HMIP))
	cp -av HMserver/opt/HMServer/HMIPServer.jar $(TARGET_DIR)/opt/HMServer/
	cp -av HMserver/opt/HMServer/HMServer.jar $(TARGET_DIR)/opt/HMServer/
	cp -av HMserver/opt/HmIP $(TARGET_DIR)/opt/
	cp -av HMServer-Beta/opt/HmIP/hmip-copro-update.jar $(TARGET_DIR)/opt/HmIP/
	#cp -av HMServer-Beta/opt/HMServer/HMIPServer.jar $(TARGET_DIR)/opt/HMServer/
	cp -av HMServer-Beta/opt/HMServer/HMServer.jar $(TARGET_DIR)/opt/HMServer/
endif

	#################################
	# Update WebUI
	ln -snf /tmp/EULA.de             					$(TARGET_DIR)/www/rega/EULA.de
	ln -snf /tmp/EULA.en             					$(TARGET_DIR)/www/rega/EULA.en
	ln -snf /www/tcl/extern/cgi.tcl           $(TARGET_DIR)/www/cgi.tcl
	ln -snf /www/tcl/eq3_old/common.tcl       $(TARGET_DIR)/www/common.tcl
	ln -snf /www/tcl/eq3_old/session.tcl      $(TARGET_DIR)/www/session.tcl
	ln -snf /www/tcl/eq3_old/once.tcl         $(TARGET_DIR)/www/once.tcl
	ln -snf /www/tcl/eq3_old/user.tcl         $(TARGET_DIR)/www/user.tcl

	ln -snf /www/tcl/extern/cgi.tcl           $(TARGET_DIR)/www/config/cgi.tcl
	ln -snf /www/tcl/eq3_old/common.tcl       $(TARGET_DIR)/www/config/common.tcl
	ln -snf /www/tcl/eq3_old/session.tcl      $(TARGET_DIR)/www/config/session.tcl
	ln -snf /www/tcl/eq3_old/once.tcl         $(TARGET_DIR)/www/config/once.tcl
	ln -snf /www/tcl/eq3_old/user.tcl         $(TARGET_DIR)/www/config/user.tcl

	ln -snf /www/tcl/extern/cgi.tcl           $(TARGET_DIR)/www/config/display/cgi.tcl
	ln -snf /www/tcl/eq3_old/once.tcl         $(TARGET_DIR)/www/config/display/once.tcl
	ln -snf /www/tcl/eq3_old/common.tcl       $(TARGET_DIR)/www/config/display/common.tcl

	ln -snf /www/tcl/eq3/rega.tcl             $(TARGET_DIR)/www/pda/eq3/rega.tcl
	ln -snf /www/tcl/eq3/session.tcl          $(TARGET_DIR)/www/pda/eq3/session.tcl

	ln -snf /www/tcl/eq3/rega.tcl             $(TARGET_DIR)/www/api/eq3/rega.tcl
	ln -snf /www/tcl/eq3/session.tcl          $(TARGET_DIR)/www/api/eq3/session.tcl

	ln -snf /www/tcl/extern/cgi.tcl           $(TARGET_DIR)/www/tools/cgi.tcl
	ln -snf /www/tcl/eq3_old/once.tcl         $(TARGET_DIR)/www/tools/once.tcl
	ln -snf /www/tcl/eq3_old/session.tcl      $(TARGET_DIR)/www/tools/session.tcl
	ln -snf /www/tcl/eq3_old/common.tcl       $(TARGET_DIR)/www/tools/common.tcl

	ln -snf /etc/config/addons/www            $(TARGET_DIR)/www/addons

	grep -rl 'XXX-WEBUI-VERSION-XXX' $(TARGET_DIR)/www | xargs sed -i 's/XXX-WEBUI-VERSION-XXX/$(PRODUCT_VERSION)/g'
	grep -rl 'XXX-PRODUCT-XXX' $(TARGET_DIR)/www | xargs sed -i 's/XXX-PRODUCT-XXX/$(PRODUCT)/g'

all: 
	@echo "do nothing"
