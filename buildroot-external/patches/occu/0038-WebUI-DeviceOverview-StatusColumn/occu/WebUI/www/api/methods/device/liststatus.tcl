##
# Device.listStatus
# Liefert die Detaildaten aller fertig konfigurierten Geräte.
#
# Parameter:
#   address: [string] addresse des devices
#   interface: [string] name des interfaces (z.B. BidCos-RF)
#
# Rückgabewert: [array]
#   Jedes Element ist eine Zeichenkette, welche die Id des Geräts symbolisiert.
##

proc getIfaceURL {interface} {
  global INTERFACE_LIST
  if {[info exists INTERFACE_LIST($interface)]} {
    array set ifaceList $INTERFACE_LIST($interface)
    return $ifaceList(URL)
  } else {
    return ""
  }
}

#
# get device status information
#
set url [getIfaceURL $args(interface)]
if { $url != "" } then {
  array set valueset [xmlrpc $url getParamset "$args(address):0" "VALUES"]
} else {
  array set valueset {}
}

#
# form output JSON
#

set result "\{"
append result "\"ID\":[json_toString $args(id)]"
append result ",\"ADDRESS\":[json_toString $args(address)]"
append result ",\"INTERFACE\":[json_toString $args(interface)]"
foreach key [array names valueset] {
  append result ",\"$key\":[json_toString $valueset($key)]"
}
append result "\}"

jsonrpc_response $result
