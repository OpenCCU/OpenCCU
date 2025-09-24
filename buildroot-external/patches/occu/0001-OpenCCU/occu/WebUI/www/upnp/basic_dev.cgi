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
proc _ip_route_get {} {
    if {[catch {exec ip -4 route get 1.1.1.1} out]} { return "" }
    return $out
}

proc get_default_iface {} {
    set out [_ip_route_get]
    if {$out ne "" && [regexp {dev ([^ ]+)} $out -> iface]} {
        return $iface
    }
    return ""
}

proc get_ip_address {} {
    # Primary attempt: `ip -4 route get` (extract "src <IPv4>")
    set out [_ip_route_get]
    if {$out ne "" && [regexp {src ([0-9.]+)} $out -> ip]} {
        return $ip
    }
    # Broaden regex to match BusyBox variants (inet 192.168.x.y OR inet addr:...)
    if {[regexp -line {inet (?:addr:)?([\d.]+)} $ifc -> ip]} {
        return $ip
    }
    return ""
}

proc get_mac_address {} {
    # Try to read MAC of the default interface from sysfs first
    set iface [get_default_iface]
    if {$iface ne ""} {
        set p "/sys/class/net/$iface/address"
        if {[file exists $p]} {
            if {![catch {set mac [string trim [exec cat $p]]}]} { return $mac }
        }
        # Fallback via `ip link show <iface>`
        if {![catch {exec ip link show $iface} out]} {
            # Prefer link/ether only (avoid matching loopback)
            if {[regexp {link/ether ([0-9a-f:]{17})} $out -> mac]} { return $mac }
        }
    }
    # Last resort: return empty to avoid breaking output
    return ""
}

# Robust file existence + trimmed content to avoid newlines in UDN/XML
# (Developer preference: keep the simple `cat` approach with exists checks.)
proc get_serial_number {} {
    set serial ""
    if {[file exists /var/board_sgtin]} {
        if {![catch {exec cat /var/board_sgtin} content]} {
            set serial [string trim $content]
        }
    } elseif {[file exists /var/board_serial]} {
        if {![catch {exec cat /var/board_serial} content]} {
            set serial [string trim $content]
        }
    } elseif {[file exists /sys/module/plat_eq3ccu2/parameters/board_serial]} {
        if {![catch {exec cat /sys/module/plat_eq3ccu2/parameters/board_serial} content]} {
            set serial [string trim $content]
        }
    }
    if {![info exists serial] || $serial eq ""} { set serial "" }
    return $serial
}

# --- branding & identity ---------------------------------------------------
# NOTE: Keep UUID pattern to avoid breaking legacy discovery tools.
set hostname "[info hostname]"
set RESOURCE(TITLE) "OpenCCU - $hostname"
set RESOURCE(MANUFACTURER) "OpenCCU"
set RESOURCE(MANUFACTURER_URL) "https://openccu.de"
set RESOURCE(SERIAL_NUMBER) "[get_serial_number]"
# Fallback: derive a stable identifier from MAC if serial is empty
if {$RESOURCE(SERIAL_NUMBER) eq ""} {
    set _mac [get_mac_address]
    if {$_mac ne ""} {
        # Strip colons to keep legacy UDN pattern intact
        set RESOURCE(SERIAL_NUMBER) [string map {: ""} $_mac]
    }
}
if {$RESOURCE(SERIAL_NUMBER) eq ""} {
    set RESOURCE(SERIAL_NUMBER) $hostname
}
# Avoid duplicate get_serial_number calls
set RESOURCE(DESCRIPTION) "OpenCCU $RESOURCE(SERIAL_NUMBER)"
set RESOURCE(MODEL_NAME) "OpenCCU"
set RESOURCE(MODEL_NUMBER) "OpenCCU"
set RESOURCE(MODEL_URL) $RESOURCE(MANUFACTURER_URL)
set RESOURCE(UUID) "upnp-BasicDevice-1_0-$RESOURCE(SERIAL_NUMBER)"
set RESOURCE(UPC) "123456789002"
set RESOURCE(DEVTYPE) "urn:schemas-upnp-org:device:Basic:1"

# --- base URLs -------------------------------------------------------------
# Determine port safely and prefer HTTP_HOST when present; validate/trim host
set _port 80
if {[info exists env(SERVER_PORT)]} {
    if {![catch {expr {int($env(SERVER_PORT))}} tmp]} { set _port $tmp }
}
set MY_PORT [expr {$_port==80 ? "" : ":$_port"}]
# Legacy placeholder (unused here) – kept to minimize diff and preserve intent:
set ISE_PORT ""
if {[info exists env(HTTP_HOST)] && $env(HTTP_HOST) ne ""} {
    set host [string trim $env(HTTP_HOST)]
    # Allow only host[:port] where host is IPv4/hostname or bracketed IPv6; else fall back
    if {![regexp {^(?:\[[0-9A-Fa-f:]+\]|[A-Za-z0-9\.\-]+)(?::\d+)?$} $host]} {
        set _ip [get_ip_address]
        if {$_ip eq ""} { set _ip "127.0.0.1" }
        set host "${_ip}$MY_PORT"
    }
} else {
    set _ip [get_ip_address]
    if {$_ip eq ""} { set _ip "127.0.0.1" }
    set host "${_ip}$MY_PORT"
}
# Normalize bracketless pure-IPv6 host (defensive; typical HTTP_HOST uses brackets already)
set _root_host $host
if {[regexp {^[0-9A-Fa-f:]+$} $_root_host]} {
    set _root_host "[$_root_host]"
}
set RESOURCE(ROOT_URL) "http://$_root_host"
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
    # Use append for efficiency; keep global buffer as agreed.
    global output_buffer
    append output_buffer $s "\r\n"
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
    # XML-escape UDN to guard against unexpected serial contents
    set _udn "uuid:$RESOURCE(UUID)"
    out "\t\t<UDN>[xml_escape $_udn]</UDN>"
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

    # Content-Type based on payload type
    set ctype [expr {$ssdp eq "description" ? "text/xml" : "text/plain"}]
    puts "Content-Type: $ctype; charset=\"utf-8\"\r"
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
