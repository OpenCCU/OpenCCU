#!/bin/tclsh
source ../cgi.tcl

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

proc get_serial_number {} {
    if {[file exist /var/board_sgtin]} {
      set serial [exec cat /var/board_sgtin]
    } elseif {[file exist /var/board_serial]} {
      set serial [exec cat /var/board_serial]
    } elseif {[file exist /sys/module/plat_eq3ccu2/parameters/board_serial]} {
      set serial [exec cat /sys/module/plat_eq3ccu2/parameters/board_serial]
    } else {
      set serial ""
    }
    return $serial
}

proc get_hostname {} {
    return [exec hostname]
}

set hostname "[get_hostname]"
if { "$hostname" == "homematic-ccu3" } {
    set RESOURCE(TITLE) "HomeMatic Central CCU3"
} elseif { "$hostname" == "homematic-raspi" } {
    set RESOURCE(TITLE) "HomeMatic Central RaspberryMatic"
} elseif { "$hostname" == "homematic-ccu2" } {
    set RESOURCE(TITLE) "HomeMatic Central CCU2"
} else {
    set RESOURCE(TITLE) "HomeMatic Central - $hostname"
}

set RESOURCE(MANUFACTURER) "EQ3"
set RESOURCE(MANUFACTURER_URL) "http://www.homematic.com"
set RESOURCE(PRESENTATION_URL) ""
set RESOURCE(DESCRIPTION) "HomeMatic Central [get_serial_number]"
set RESOURCE(MODEL_NAME) "HomeMatic Central"
set RESOURCE(MODEL_NUMBER) "HomeMatic Central"
set RESOURCE(MODEL_URL) $RESOURCE(MANUFACTURER_URL)
set RESOURCE(SERIAL_NUMBER) "[get_serial_number]"
set RESOURCE(UUID) "upnp-BasicDevice-1_0-$RESOURCE(SERIAL_NUMBER)"
set RESOURCE(UPC) "123456789002"
set RESOURCE(DEVTYPE) "urn:schemas-upnp-org:device:Basic:1"

set MY_PORT [expr $env(SERVER_PORT)==80?"":":$env(SERVER_PORT)"]
set ISE_PORT ""
set RESOURCE(ROOT_URL) "http://[get_ip_address]$MY_PORT"
set RESOURCE(BASE_URL) "$RESOURCE(ROOT_URL)/upnp/"

set output_buffer ""

proc out {s} {
    global output_buffer
    set output_buffer "$output_buffer$s\r\n"
}

proc send_description {} {
    global RESOURCE
    
    out {<?xml version="1.0"?>}
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
    
   
    out "\t\t<serviceList>"
    out "\t\t\t<service>"
    out "\t\t\t\t<serviceType>urn:schemas-upnp-org:service:dummy:1</serviceType>"
    out "\t\t\t\t<serviceId>urn:upnp-org:serviceId:dummy1</serviceId>"
    out "\t\t\t\t<controlURL></controlURL>"
    out "\t\t\t\t<eventSubURL></eventSubURL>"
    out "\t\t\t\t<SCPDURL></SCPDURL>"
    out "\t\t\t</service>"
    out "\t\t</serviceList>"
    
#    out "\t\t<modelNumber>$RESOURCE(MODEL_NUMBER)</modelNumber>"
#    out "\t\t<modelURL>$RESOURCE(MODEL_URL)</modelURL>"
#    out "\t\t<serialNumber>$RESOURCE(SERIAL_NUMBER)</serialNumber>"
    #out "\t\t<serviceList/>"
    #out "\t\t<deviceList/>"
    #out {    <iconList>}
    #out {      <icon>}
    #out {        <mimetype>image/format</mimetype>}
    #out {        <width>horizontal pixels</width>}
    #out {        <height>vertical pixels</height>}
    #out {        <depth>color depth</depth>}
    #out {        <url>URL to icon</url>}
    #out {      </icon>}
    #out {    </iconList>}
    out "\t</device>"
    out "</root>"
}

proc send_response {} {
    global RESOURCE env
    
    for { set i 0 } { $i < 1 } { incr i } {
        out "HTTP/1.1 200 OK"
        out "CACHE-CONTROL:max-age=5000"
        out "EXT:"
        out "LOCATION:$RESOURCE(ROOT_URL)$env(SCRIPT_NAME)"
        out "SERVER:HomeMatic"
        switch $i {
            0 {
                out "ST:upnp:rootdevice"
                out "USN:uuid:$RESOURCE(UUID)::upnp:rootdevice"
            }
            1 {
                out "ST:uuid:$RESOURCE(UUID)"
                out "USN:uuid:$RESOURCE(UUID)"
            }
            2 {
                out "ST:$RESOURCE(DEVTYPE)"
                out "USN:uuid:$RESOURCE(UUID)::$RESOURCE(DEVTYPE)"
            }
        }
        out ""
    }
}

proc send_alive {} {
    global RESOURCE env

    for { set i 0 } { $i < 1 } { incr i } {
        out "NOTIFY * HTTP/1.1"
        out "HOST:239.255.255.250:1900"
        out "CACHE-CONTROL:max-age=5000"
        out "LOCATION:$RESOURCE(ROOT_URL)$env(SCRIPT_NAME)"
        out "NTS:ssdp:alive"
        out "SERVER:HomeMatic"
        
        switch $i {
            0 {
                out "NT:upnp:rootdevice"
                out "USN:uuid:$RESOURCE(UUID)::upnp:rootdevice"
            }
            1 {
                out "NT:uuid:$RESOURCE(UUID)"
                out "USN:uuid:$RESOURCE(UUID)"
            }
            2 {
                out "NT:$RESOURCE(DEVTYPE)"
                out "USN:uuid:$RESOURCE(UUID)::$RESOURCE(DEVTYPE)"
            }
        }
        out ""
    }
}

cgi_eval {
   #cgi_debug on
    cgi_input
    set ssdp "description"
    catch {
        import ssdp
    }

    send_$ssdp
    puts "Content-type: text/xml\r"
    puts "Content-Length: [string length $output_buffer]\r"
    puts "\r"
    puts -nonewline $output_buffer
}
