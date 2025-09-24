#!/bin/tclsh
#------------------------------------------------------------------------------
# OpenCCU UPnP device description (Basic:1) CGI
#
# Purpose
#   - Advertise the controller as a UPnP *Basic:1* device with a working
#     presentationURL to the WebUI, but **without** declaring services.
#   - This avoids Control Points requesting a non-existent SCPD (<scpd> root),
#     which previously caused parser errors when an empty <serviceList> was present.
#
# Branding & Compatibility
#   - Friendly name and headers branded as "OpenCCU".
#   - UUID/UDN format kept as "upnp-BasicDevice-1_0-<SERIAL>" for compatibility
#     with existing discovery tools (e.g., eQ-3 NetFinder).
#
# Specs / References (stable URLs)
#   - UPnP Device Architecture v2.0 (OCF):
#     https://openconnectivity.org/upnp-specs/UPnP-arch-DeviceArchitecture-v2.0-20200417.pdf
#   - UPnP Device Architecture v1.1 (UPnP Forum/OCF):
#     https://openconnectivity.org/upnp-specs/UPnP-arch-DeviceArchitecture-v1.1.pdf
#   - Basic:1 Device Definition (UPnP Forum):
#     https://upnp.org/specs/basic/UPnP-basic-Basic-v1-Device.pdf
#
# Best practices captured here
#   - No <serviceList> for Basic:1 unless real services (with SCPD) are provided.
#   - Normalize HTTP/SSDP headers (space after colon; consistent casing).
#   - Set explicit Content-Type charset and XML declaration (UTF-8).
#   - Keep comments short; keep spec URLs here (no long quotes inline).
#------------------------------------------------------------------------------

source ../cgi.tcl

# --- helpers ---------------------------------------------------------------
proc get_mac_address {} {
    set ifconfig_result [exec /sbin/ifconfig eth0]
    if {! [regexp -line {HWaddr *([^ \t]+) *$} $ifconfig_result dummy mac_addr]} {return ""}
    return $mac_addr
}

proc get_ip_address {} {
    set ifconfig_result [exec /sbin/ifconfig eth0]
    if {! [regexp -line {inet addr:([\d.]+).*Mask:} $ifconfig_result dummy ip]} {return ""}
    return $ip
}

# Robust file existence + trimmed content to avoid newlines in UDN/XML
proc get_serial_number {} {
    set serial ""
    foreach path {/var/board_sgtin /var/board_serial /sys/module/plat_eq3ccu2/parameters/board_serial} {
        if {[file exists $path]} {
            if {![catch {
                set fd [open $path r]
                set data [read $fd]
                close $fd
                set serial [string trim $data]
            }]} {
                if {$serial ne ""} { break }
            } else {
                set serial ""
            }
        }
    }
    return $serial
}

proc get_hostname {} {
    return [exec hostname]
}

# --- branding & identity ---------------------------------------------------
# NOTE: Keep UUID pattern to avoid breaking legacy discovery tools.
set hostname "[get_hostname]"
# Keep hostname visible as requested:
set RESOURCE(TITLE) "OpenCCU - $hostname"
set RESOURCE(MANUFACTURER) "OpenCCU"
set RESOURCE(MANUFACTURER_URL) "https://openccu.de"
set RESOURCE(DESCRIPTION) "OpenCCU [get_serial_number]"
set RESOURCE(MODEL_NAME) "OpenCCU"
set RESOURCE(MODEL_NUMBER) "OpenCCU"
set RESOURCE(MODEL_URL) $RESOURCE(MANUFACTURER_URL)
set RESOURCE(SERIAL_NUMBER) "[get_serial_number]"
set RESOURCE(UUID) "upnp-BasicDevice-1_0-$RESOURCE(SERIAL_NUMBER)"
set RESOURCE(UPC) "123456789002"
set RESOURCE(DEVTYPE) "urn:schemas-upnp-org:device:Basic:1"

# --- base URLs -------------------------------------------------------------
# Compute port (fallback to 80) and prefer HTTP_HOST (works with proxies)
set _port [expr {[info exists env(SERVER_PORT)] ? $env(SERVER_PORT) : 80}]
set MY_PORT [expr {$_port==80 ? "" : ":$_port"}]
# Legacy placeholder (unused here) – kept to minimize diff and preserve intent:
set ISE_PORT ""
if {[info exists env(HTTP_HOST)] && $env(HTTP_HOST) ne ""} {
    set host $env(HTTP_HOST)
} else {
    set host "[get_ip_address]$MY_PORT"
}
set RESOURCE(ROOT_URL) "http://$host"
set RESOURCE(BASE_URL) "$RESOURCE(ROOT_URL)/upnp/"
# Absolute presentationURL to the WebUI landing page:
set RESOURCE(PRESENTATION_URL) "$RESOURCE(ROOT_URL)/"

# --- SERVER header (spec-ish: OS/Ver, UPnP/1.0, Product[/Ver]) ------------
set _os "Unix"
set _ver "1.0"
catch { set _os [exec uname -s] }
catch { set _ver [exec uname -r] }
set SERVER_HEADER "$_os/$_ver UPnP/1.0 OpenCCU"

# --- output buffer ---------------------------------------------------------
set output_buffer ""
proc out {s} {
    global output_buffer
    set output_buffer "$output_buffer$s\r\n"
}

# --- device description (no serviceList for Basic:1) -----------------------
proc send_description {} {
    global RESOURCE

    out {<?xml version="1.0" encoding="UTF-8"?>}
    out {<root xmlns="urn:schemas-upnp-org:device-1-0">}
    out "\t<specVersion>"
    out "\t\t<major>1</major>"
    out "\t\t<minor>0</minor>"
    out "\t</specVersion>"
    out "\t<URLBase>$RESOURCE(BASE_URL)</URLBase>"
    out "\t<device>"
    out "\t\t<deviceType>$RESOURCE(DEVTYPE)</deviceType>"
    out "\t\t<presentationURL>$RESOURCE(PRESENTATION_URL)</presentationURL>"
    out "\t\t<friendlyName>$RESOURCE(TITLE)</friendlyName>"
    out "\t\t<manufacturer>$RESOURCE(MANUFACTURER)</manufacturer>"
    out "\t\t<manufacturerURL>$RESOURCE(MANUFACTURER_URL)</manufacturerURL>"
    out "\t\t<modelDescription>$RESOURCE(DESCRIPTION)</modelDescription>"
    out "\t\t<modelName>$RESOURCE(MODEL_NAME)</modelName>"
    out "\t\t<UDN>uuid:$RESOURCE(UUID)</UDN>"
    out "\t\t<UPC>$RESOURCE(UPC)</UPC>"

    # Optional fields below are intentionally commented out.
    # They are valid if you want them, but not required for Basic:1.
    # Keep them here so the maintainer can toggle them later.

    # out "\t\t<modelNumber>$RESOURCE(MODEL_NUMBER)</modelNumber>"
    # out "\t\t<modelURL>$RESOURCE(MODEL_URL)</modelURL>"
    # out "\t\t<serialNumber>$RESOURCE(SERIAL_NUMBER)</serialNumber>"
    # out "\t\t<deviceList/>"

    # Example icon list (fill with real data if ever used):
    # out {    <iconList>}
    # out {      <icon>}
    # out {        <mimetype>image/png</mimetype>}
    # out {        <width>128</width>}
    # out {        <height>128</height>}
    # out {        <depth>24</depth>}
    # out {        <url>/images/openccu-128.png</url>}
    # out {      </icon>}
    # out {    </iconList>}

    # ----------------------------------------------------------------------
    # OPTION B (COMMENTED): declare a vendor service with a valid SCPD
    # ----------------------------------------------------------------------
    # IMPORTANT:
    # - Only enable if you also serve the SCPD file AND handle (or reject)
    #   control requests at the controlURL to avoid client timeouts.
    # - Uncomment the block below AND provide the SCPD file shown at the end
    #   of this CGI (see "DeviceInfo SCPD example").
    #
    # out "\t\t<serviceList>"
    # out "\t\t  <service>"
    # out "\t\t    <serviceType>urn:schemas-openccu-org:service:DeviceInfo:1</serviceType>"
    # out "\t\t    <serviceId>urn:openccu-org:serviceId:DeviceInfo1</serviceId>"
    # out "\t\t    <controlURL>/upnp/deviceinfo/control</controlURL>"
    # out "\t\t    <eventSubURL>/upnp/deviceinfo/event</eventSubURL>"
    # out "\t\t    <SCPDURL>/upnp/deviceinfo_scpd.xml</SCPDURL>"
    # out "\t\t  </service>"
    # out "\t\t</serviceList>"

    # Intentionally no <serviceList/> for Basic:1 by default.
    out "\t</device>"
    out "</root>"
}

# --- SSDP response/notify formatting (emit all three variants) -------------
proc send_response {} {
    global RESOURCE env SERVER_HEADER

    for { set i 0 } { $i < 3 } { incr i } {
        out "HTTP/1.1 200 OK"
        out "CACHE-CONTROL: max-age=5000"
        out "EXT:"
        out "LOCATION: $RESOURCE(ROOT_URL)$env(SCRIPT_NAME)"
        out "SERVER: $SERVER_HEADER"
        switch $i {
            0 { out "ST: upnp:rootdevice"; out "USN: uuid:$RESOURCE(UUID)::upnp:rootdevice" }
            1 { out "ST: uuid:$RESOURCE(UUID)"; out "USN: uuid:$RESOURCE(UUID)" }
            2 { out "ST: $RESOURCE(DEVTYPE)"; out "USN: uuid:$RESOURCE(UUID)::$RESOURCE(DEVTYPE)" }
        }
        out ""
    }
}

proc send_alive {} {
    global RESOURCE env SERVER_HEADER

    for { set i 0 } { $i < 3 } { incr i } {
        out "NOTIFY * HTTP/1.1"
        out "HOST: 239.255.255.250:1900"
        out "CACHE-CONTROL: max-age=5000"
        out "LOCATION: $RESOURCE(ROOT_URL)$env(SCRIPT_NAME)"
        out "NTS: ssdp:alive"
        out "SERVER: $SERVER_HEADER"
        switch $i {
            0 { out "NT: upnp:rootdevice"; out "USN: uuid:$RESOURCE(UUID)::upnp:rootdevice" }
            1 { out "NT: uuid:$RESOURCE(UUID)"; out "USN: uuid:$RESOURCE(UUID)" }
            2 { out "NT: $RESOURCE(DEVTYPE)"; out "USN: uuid:$RESOURCE(UUID)::$RESOURCE(DEVTYPE)" }
        }
        out ""
    }
}

# --- CGI entrypoint --------------------------------------------------------
cgi_eval {
    # cgi_debug on
    cgi_input
    set ssdp "description"
    catch { import ssdp }
    # Whitelist to avoid command injection via send_$ssdp
    if {[lsearch -exact {description response alive} $ssdp] < 0} {
        set ssdp description
    }
    send_$ssdp
    puts "Content-Type: text/xml; charset=\"utf-8\"\r"
    # Content-Length in BYTES (UTF-8), not characters
    puts "Content-Length: [string length [encoding convertto utf-8 $output_buffer]]\r"
    puts "\r"
    puts -nonewline $output_buffer
}

#------------------------------------------------------------------------------
# DeviceInfo SCPD example (OPTION B) – place this as /www/upnp/deviceinfo_scpd.xml
#------------------------------------------------------------------------------
# <?xml version="1.0" encoding="UTF-8"?>
# <scpd xmlns="urn:schemas-upnp-org:service-1-0">
#   <specVersion><major>1</major><minor>0</minor></specVersion>
#   <actionList>
#     <!-- Example action (optional):
#     <action>
#       <name>GetInfo</name>
#       <argumentList>
#         <argument>
#           <name>FriendlyName</name>
#           <direction>out</direction>
#           <relatedStateVariable>OpenCCU.FriendlyName</relatedStateVariable>
#         </argument>
#         <argument>
#           <name>Version</name>
#           <direction>out</direction>
#           <relatedStateVariable>OpenCCU.Version</relatedStateVariable>
#         </argument>
#       </argumentList>
#     </action>
#     -->
#   </actionList>
#   <serviceStateTable>
#     <!-- Example state variables (optional):
#     <stateVariable sendEvents="no">
#       <name>OpenCCU.FriendlyName</name>
#       <dataType>string</dataType>
#     </stateVariable>
#     <stateVariable sendEvents="no">
#       <name>OpenCCU.Version</name>
#       <dataType>string</dataType>
#     </stateVariable>
#     -->
#   </serviceStateTable>
# </scpd>
#------------------------------------------------------------------------------
