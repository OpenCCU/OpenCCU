#!/bin/tclsh
#------------------------------------------------------------------------------
# OpenCCU UPnP device description (Basic:1) CGI
#
# Purpose
#   - Advertise the controller as a UPnP *Basic:1* device with a working
#     presentationURL to the WebUI, but **without** declaring services.
#   - Prevent Control Points from requesting a non-existent SCPD (<scpd> root),
#     which previously caused parsing errors when an empty <serviceList> was present.
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
#------------------------------------------------------------------------------

source ../cgi.tcl

# --- helpers ---------------------------------------------------------------
proc get_mac_address {} {
    # Harden against exec failure (missing ifconfig or no eth0)
    if {[catch {exec /sbin/ifconfig eth0} ifconfig_result]} { return "" }
    if {! [regexp -line {HWaddr *([^ \t]+) *$} $ifconfig_result dummy mac_addr]} {return ""}
    return $mac_addr
}

proc get_ip_address {} {
    # Harden against exec failure (missing ifconfig or no eth0)
    if {[catch {exec /sbin/ifconfig eth0} ifconfig_result]} { return "" }
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

# Prefer [info hostname] (no external process)
proc get_hostname {} { return [info hostname] }

# --- branding & identity ---------------------------------------------------
# NOTE: Keep UUID pattern to avoid breaking legacy discovery tools.
set hostname "[get_hostname]"
set RESOURCE(TITLE) "OpenCCU - $hostname"
set RESOURCE(MANUFACTURER) "OpenCCU"
set RESOURCE(MANUFACTURER_URL) "https://openccu.de"
set RESOURCE(SERIAL_NUMBER) "[get_serial_number]"
# Avoid duplicate get_serial_number calls
set RESOURCE(DESCRIPTION) "OpenCCU $RESOURCE(SERIAL_NUMBER)"
set RESOURCE(MODEL_NAME) "OpenCCU"
set RESOURCE(MODEL_NUMBER) "OpenCCU"
set RESOURCE(MODEL_URL) $RESOURCE(MANUFACTURER_URL)
set RESOURCE(UUID) "upnp-BasicDevice-1_0-$RESOURCE(SERIAL_NUMBER)"
set RESOURCE(UPC) "123456789002"
set RESOURCE(DEVTYPE) "urn:schemas-upnp-org:device:Basic:1"

# --- base URLs -------------------------------------------------------------
# Determine port and prefer HTTP_HOST when present (proxy-friendly); trim host
set _port [expr {[info exists env(SERVER_PORT)] ? $env(SERVER_PORT) : 80}]
set MY_PORT [expr {$_port==80 ? "" : ":$_port"}]
# Legacy placeholder (unused here) – kept to minimize diff and preserve intent:
set ISE_PORT ""
if {[info exists env(HTTP_HOST)] && $env(HTTP_HOST) ne ""} {
    set host [string trim $env(HTTP_HOST)]
    # Allow only host[:port] (IPv4/hostname or [IPv6]); otherwise fall back
    if {![regexp {^\[?[A-Za-z0-9\.\-:]+\]?(?::\d+)?$} $host]} {
        set host "[get_ip_address]$MY_PORT"
    }
} else {
    set host "[get_ip_address]$MY_PORT"
}
if {$host eq ""} {
    # Last-resort fallback to avoid invalid URL if IP/host could not be determined
    set host "127.0.0.1$MY_PORT"
}
set RESOURCE(ROOT_URL) "http://$host"
set RESOURCE(BASE_URL) "$RESOURCE(ROOT_URL)/upnp/"
set RESOURCE(PRESENTATION_URL) "$RESOURCE(ROOT_URL)/"

# --- SERVER header (spec-ish: OS/Ver, UPnP/1.0, Product[/Ver]) ------------
set _os "Unix"; set _ver "1.0"
catch { set _os [exec uname -s] }
catch { set _ver [exec uname -r] }
set SERVER_HEADER "$_os/$_ver UPnP/1.0 OpenCCU"

# --- output buffer ---------------------------------------------------------
set output_buffer ""
proc out {s} {
    global output_buffer
    set output_buffer "$output_buffer$s\r\n"
}

# Minimal XML text escape for text nodes
proc xml_escape {s} {
    return [string map {& &amp; < &lt; > &gt; \" &quot; ' &apos;} $s]
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
    # URLBase should typically point to the root, not a subpath
    out "\t<URLBase>$RESOURCE(ROOT_URL)</URLBase>"
    out "\t<device>"
    out "\t\t<deviceType>$RESOURCE(DEVTYPE)</deviceType>"
    out "\t\t<presentationURL>[xml_escape $RESOURCE(PRESENTATION_URL)]</presentationURL>"
    out "\t\t<friendlyName>[xml_escape $RESOURCE(TITLE)]</friendlyName>"
    out "\t\t<manufacturer>[xml_escape $RESOURCE(MANUFACTURER)]</manufacturer>"
    out "\t\t<manufacturerURL>[xml_escape $RESOURCE(MANUFACTURER_URL)]</manufacturerURL>"
    out "\t\t<modelDescription>[xml_escape $RESOURCE(DESCRIPTION)]</modelDescription>"
    out "\t\t<modelName>[xml_escape $RESOURCE(MODEL_NAME)]</modelName>"
    out "\t\t<UDN>uuid:$RESOURCE(UUID)</UDN>"
    out "\t\t<UPC>$RESOURCE(UPC)</UPC>"

    # Optional examples (kept commented for future use):
    # out "\t\t<modelNumber>$RESOURCE(MODEL_NUMBER)</modelNumber>"
    # out "\t\t<modelURL>$RESOURCE(MODEL_URL)</modelURL>"
    # out "\t\t<serialNumber>$RESOURCE(SERIAL_NUMBER)</serialNumber>"
    # out "\t\t<deviceList/>"
    # out {    <iconList>}
    # out {      <icon>}
    # out {        <mimetype>image/png</mimetype>}
    # out {        <width>128</width>}
    # out {        <height>128</height>}
    # out {        <depth>24</depth>}
    # out {        <url>/images/openccu-128.png</url>}
    # out {      </icon>}
    # out {    </iconList>}

    # OPTION B (COMMENTED): vendor service with a valid SCPD (see footer)
    # out "\t\t<serviceList>"
    # out "\t\t  <service>"
    # out "\t\t    <serviceType>urn:schemas-openccu-org:service:DeviceInfo:1</serviceType>"
    # out "\t\t    <serviceId>urn:openccu-org:serviceId:DeviceInfo1</serviceId>"
    # out "\t\t    <controlURL>/upnp/deviceinfo/control</controlURL>"
    # out "\t\t    <eventSubURL>/upnp/deviceinfo/event</eventSubURL>"
    # out "\t\t    <SCPDURL>/upnp/deviceinfo_scpd.xml</SCPDURL>"
    # out "\t\t  </service>"
    # out "\t\t</serviceList>"

    out "\t</device>"
    out "</root>"
}

# --- SSDP response/notify (emit ONE variant per invocation) ----------------
proc send_response {} {
    global RESOURCE env SERVER_HEADER
    out "HTTP/1.1 200 OK"
    out "CACHE-CONTROL: max-age=5000"
    out "EXT:"
    out "LOCATION: $RESOURCE(ROOT_URL)$env(SCRIPT_NAME)"
    out "SERVER: $SERVER_HEADER"
    out "ST: upnp:rootdevice"
    out "USN: uuid:$RESOURCE(UUID)::upnp:rootdevice"
    out ""
}

proc send_alive {} {
    global RESOURCE env SERVER_HEADER
    out "NOTIFY * HTTP/1.1"
    out "HOST: 239.255.255.250:1900"
    out "CACHE-CONTROL: max-age=5000"
    out "LOCATION: $RESOURCE(ROOT_URL)$env(SCRIPT_NAME)"
    out "NTS: ssdp:alive"
    out "SERVER: $SERVER_HEADER"
    out "NT: upnp:rootdevice"
    out "USN: uuid:$RESOURCE(UUID)::upnp:rootdevice"
    out ""
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

    # Ensure output encoding matches Content-Length computation
    fconfigure stdout -encoding utf-8

    puts "Content-Type: text/xml; charset=\"utf-8\"\r"
    # Content-Length in BYTES (UTF-8)
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
#     <!-- Example state variables (optional) -->
#     <!--
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
