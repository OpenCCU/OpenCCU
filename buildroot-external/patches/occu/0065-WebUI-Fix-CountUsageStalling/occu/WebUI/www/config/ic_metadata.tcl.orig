#!/bin/tclsh
source once.tcl
loadOnce tclrpc.so

sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce user.tcl
sourceOnce common.tcl

array set metadata_ise_READYCONFIG ""

if { ![ catch { loadOnce tclrega.so } ] } {
    #tclrega.so available. Get Metadata from ReGaHss
proc ise_getChannelRooms {p_ise_ROOMS} {
	
	upvar $p_ise_ROOMS ise_ROOMS
	
	set isecmd ""
	append isecmd "object room;"
	append isecmd "object channel;"
	append isecmd "string id_room;"
	append isecmd "string id_channel;"
	append isecmd "string room_name;"
	append isecmd "string ch_addr;"
	append isecmd "string ch_iface;"
	append isecmd "integer ch_iface_id;"
	append isecmd "integer CHANNEL_COUNT = 0;"
	append isecmd "foreach (id_room, dom.GetObject(ID_ROOMS).EnumUsedIDs())"
	append isecmd "{"
	append isecmd "  room = dom.GetObject(id_room);"
	append isecmd "  room_name = room.Name();"
	append isecmd "  foreach (id_channel, room.EnumUsedIDs())"
	append isecmd "  {"
	append isecmd "    channel = dom.GetObject(id_channel);"
	append isecmd "    ch_addr = channel.Address();"
	append isecmd "    ch_iface_id = channel.Interface();"
	append isecmd "    ch_iface = dom.GetObject(ch_iface_id).Name();"
	append isecmd "    if (channel.Type() == OT_CHANNEL)"
	append isecmd "    {"
	append isecmd "      Write(ch_iface # ';' # ch_addr # ' ' # room_name # '\n');"
	append isecmd "      CHANNEL_COUNT = CHANNEL_COUNT + 1;"
	append isecmd "    }"
	append isecmd "  }"
	append isecmd "}"
	append isecmd "Write('<.');"

	if { [catch {array set result [rega_script $isecmd]} ] } then { return }
	if { [catch {set dummy $result(CHANNEL_COUNT)      } ] } then { return }

	set stdout [split $result(STDOUT) "\n"]
	
	for {set i 0} {$i < $result(CHANNEL_COUNT)} {incr i} {
	
		#Iface;Address iseRoomName
		#HSS;DAA0217858:1 Dachboden
		set zeile [lindex $stdout $i]

		if { $zeile == "" || [string equal $zeile "<."] } then {
			#(Fehler="" Datensatz i.O. = "<.")
			break
		}
				
		set address [string range $zeile 0                                    [expr [string first " " $zeile] - 1]]
		set room    [string range $zeile [expr [string first " " $zeile] + 1] end]

		if { [catch {set dummy $ise_ROOMS($address)} ] } then {
			set ise_ROOMS($address) [list $room]
		} else {
			lappend ise_ROOMS($address) $room
		}

		#puts "$address - $room <br/>"
	}

	#Wenn hier kein "<." steht haben wir einen Fehler:
	#set zeile [lindex $stdout $result(CHANNEL_COUNT)]
	#if { [string equal $zeile "<."] } then {
	#}
}

proc ise_getRooms {p_ise_ROOMS} {
	
	upvar $p_ise_ROOMS ise_ROOMS

	set ise_ROOMS ""
	
	set isecmd ""
	append isecmd "object room;"
	append isecmd "string id_room;"
	append isecmd "string room_name;"
	append isecmd "foreach (id_room, dom.GetObject(ID_ROOMS).EnumUsedIDs())"
	append isecmd "{"
	append isecmd "  room = dom.GetObject(id_room);"
	append isecmd "  room_name = room.Name();"
	append isecmd "  if (room_name != '')"
	append isecmd "  {"
	append isecmd "    Write(room_name # ';');"
	append isecmd "  }"
	append isecmd "}"

	if { [catch {array set result [rega_script $isecmd]} ] } then { return }

	set stdout [split $result(STDOUT) ";"]
	
	foreach room $stdout {
		if {$room != ""} then { lappend ise_ROOMS $room }
	}
}
proc ise_getFunctions {p_ise_FUNCTIONS} {
	
	upvar $p_ise_FUNCTIONS ise_FUNCTIONS

	set ise_FUNCTIONS ""
	
	set isecmd ""
	append isecmd "object function;"
	append isecmd "string id_function;"
	append isecmd "string func_name;"
	append isecmd "foreach (id_function, dom.GetObject(ID_FUNCTIONS).EnumUsedIDs())"
	append isecmd "{"
	append isecmd "  function  = dom.GetObject(id_function);"
	append isecmd "  func_name = function.Name();"
	append isecmd "  if (func_name != '')"
	append isecmd "  {"
	append isecmd "    Write(func_name # ';');"
	append isecmd "  }"
	append isecmd "}"

	if { [catch {array set result [rega_script $isecmd]} ] } then { return }

	set stdout [split $result(STDOUT) ";"]
	
	foreach func $stdout {
		if {$func != ""} then { lappend ise_FUNCTIONS $func }
	}
}

proc ise_getChannelFunctions {p_ise_FUNCTIONS} {
	
	upvar $p_ise_FUNCTIONS ise_FUNCTIONS
	
	set isecmd ""
	append isecmd "object function;"
	append isecmd "object channel;"
	append isecmd "string id_function;"
	append isecmd "string id_channel;"
	append isecmd "string func_name;"
	append isecmd "string ch_addr;"
	append isecmd "string ch_iface;"
	append isecmd "integer ch_iface_id;"
	append isecmd "integer CHANNEL_COUNT = 0;"
	append isecmd "foreach (id_function, dom.GetObject(ID_FUNCTIONS).EnumUsedIDs())"
	append isecmd "{"
	append isecmd "  function = dom.GetObject(id_function);"
	append isecmd "  func_name = function.Name();"
	append isecmd "  foreach (id_channel, function.EnumUsedIDs())"
	append isecmd "  {"
	append isecmd "    channel = dom.GetObject(id_channel);"
	append isecmd "    ch_addr = channel.Address();"
	append isecmd "    ch_iface_id = channel.Interface();"
	append isecmd "    ch_iface = dom.GetObject(ch_iface_id).Name();"
	append isecmd "    if (channel.Type() == OT_CHANNEL)"
	append isecmd "    {"
	append isecmd "      Write(ch_iface # ';' # ch_addr # ' ' # func_name # '\n');"
	append isecmd "      CHANNEL_COUNT = CHANNEL_COUNT + 1;"
	append isecmd "    }"
	append isecmd "  }"
	append isecmd "}"
	append isecmd "Write('<.');"

	#puts $isecmd

	if { [catch {array set result [rega_script $isecmd]} ] } then { return }
	if { [catch {set dummy $result(CHANNEL_COUNT)      } ] } then { return }

	set stdout [split $result(STDOUT) "\n"]
	
	for {set i 0} {$i < $result(CHANNEL_COUNT)} {incr i} {
	
		#Iface;Address iseFunctionName
		#HSS;DAA0217858:1 Elektro
		set zeile [lindex $stdout $i]

		if { $zeile == "" || [string equal $zeile "<."] } then {
			#(Fehler="" Datensatz i.O. = "<.")
			break
		}
				
		set address  [string range $zeile 0                                    [expr [string first " " $zeile] - 1]]
		set function [string range $zeile [expr [string first " " $zeile] + 1] end]

		if { [catch {set dummy $ise_FUNCTIONS($address)} ] } then {
			set ise_FUNCTIONS($address) [list $function]
		} else {
			lappend ise_FUNCTIONS($address) $function
		}

		#puts "$address - $function <br/>"
	}

	#Wenn hier kein "<." steht haben wir einen Fehler:
	#set zeile [lindex $stdout $result(CHANNEL_COUNT)]
	#if { [string equal $zeile "<."] } then {
	#}
}

proc ise_getChannelNames {p_ise_CHANNELNAMES} {

	upvar $p_ise_CHANNELNAMES ise_CHANNELNAMES
	
	set isecmd ""
	append isecmd "string id;"
	append isecmd "object channel;"
	append isecmd "string ch_addr;"
	append isecmd "string ch_name;"
	append isecmd "string ch_iface;"
	append isecmd "integer ch_iface_id;"
	append isecmd "integer CHANNEL_COUNT = 0;"
	append isecmd "foreach(id, root.Channels().EnumUsedIDs())"
	append isecmd "{"
	append isecmd "  channel = dom.GetObject(id);"
	append isecmd "  ch_addr = channel.Address();"
	append isecmd "  ch_name = channel.Name();"
	append isecmd "  ch_iface_id = channel.Interface();"
  append isecmd "  ch_iface    = dom.GetObject(ch_iface_id);"
	append isecmd "  if (ch_iface)"
	append isecmd "  {"
	append isecmd "    Write(ch_iface.Name() # ';' # ch_addr # ' ' # ch_name # '\n');"
	append isecmd "    CHANNEL_COUNT = CHANNEL_COUNT + 1;"
	append isecmd "  }"
	append isecmd "}"
	append isecmd "foreach(id, root.Devices().EnumUsedIDs())"
	append isecmd "{"
	append isecmd "  channel = dom.GetObject(id);"
	append isecmd "  ch_addr = channel.Address();"
	append isecmd "  ch_name = channel.Name();"
	append isecmd "  ch_iface_id = channel.Interface();"
  append isecmd "  ch_iface    = dom.GetObject(ch_iface_id);"
	append isecmd "  if (ch_iface)"
	append isecmd "  {"
	append isecmd "    Write(ch_iface.Name() # ';' # ch_addr # ' ' # ch_name # '\n');"
	append isecmd "    CHANNEL_COUNT = CHANNEL_COUNT + 1;"
	append isecmd "  }"
	append isecmd "}"
	append isecmd "Write('<.');"

	#puts $isecmd

	if { [catch {array set result [rega_script $isecmd]} ] } then { return }
	if { [catch {set dummy $result(CHANNEL_COUNT)      } ] } then { return }

	set stdout [split $result(STDOUT) "\n"]
	
	for {set i 0} {$i < $result(CHANNEL_COUNT)} {incr i} {
	
		#Iface;Address iseChannelName
		#HSS;DAA0217858:1 HSS.DAA0217858:1
		set zeile [lindex $stdout $i]

		if { $zeile == "" || [string equal $zeile "<."] } then {
			#(Fehler="" Datensatz i.O. = "<.")
			break
		}
				
		set address [string range $zeile 0                                    [expr [string first " " $zeile] - 1]]
		set name    [string range $zeile [expr [string first " " $zeile] + 1] end]
		set ise_CHANNELNAMES($address) $name

		#puts "$address - $name <br/>"
	}

	#Wenn hier kein "<." steht haben wir einen Fehler:
	#set zeile [lindex $stdout $result(CHANNEL_COUNT)]
	#if { [string equal $zeile "<."] } then {
	#}
}

#Diese Funktion wird nicht mehr gebraucht. CONFIG_PENDING wird direkt via xmlrpc abgefragt.
#Siehe procedure cmd_ShowConfigPendingMsg in ic_ifacecmd.cgi
proc ise_getConfigPending {p_ise_CONFIGPENDING} {

	upvar $p_ise_CONFIGPENDING ise_CONFIGPENDING
	
	set isecmd ""
	append isecmd "string id;"
	append isecmd "object device;"
	append isecmd "object obj;"
	append isecmd "string config_pending_name;"
	append isecmd "string dev_iface_id;"
	append isecmd "string dev_iface_name;"
	append isecmd "integer DEVICE_COUNT = 0;"
	append isecmd "foreach(id, root.Devices().EnumUsedIDs())"
	append isecmd "{"
	append isecmd "  device = dom.GetObject(id);"
	append isecmd "  config_pending_name = device.Name() # ':0.CONFIG_PENDING';"
	append isecmd "  obj = dom.GetObject(config_pending_name);"
	append isecmd "  dev_iface_id = device.Interface();"
	append isecmd "  dev_iface_name = dom.GetObject(dev_iface_id);"
	append isecmd "  if (obj)"
	append isecmd "  {"
	append isecmd "    Write( dev_iface_name # ';' # device.Address() # ' ' # obj.State() # '\n');"
	append isecmd "    DEVICE_COUNT = DEVICE_COUNT + 1;"
	append isecmd "  }"
	append isecmd "}"
	append isecmd "Write('<.');"

	if { [catch {array set result [rega_script $isecmd]} ] } then { return }
	if { [catch {set dummy $result(DEVICE_COUNT)       } ] } then { return }

	set stdout [split $result(STDOUT) "\n"]
	
	for {set i 0} {$i < $result(DEVICE_COUNT)} {incr i} {
	
		#Iface;Parent-Address configpending-status
		#HSS;DAA0217858 0
		set zeile [lindex $stdout $i]

		if { $zeile == "" || [string equal $zeile "<."] } then {
			#(Fehler="" Datensatz i.O. = "<.")
			break
		}
				
		set address [string range $zeile 0                                    [expr [string first " " $zeile] - 1]]
		set status  [string range $zeile [expr [string first " " $zeile] + 1] end]
		set ise_CONFIGPENDING($address) $status

		#puts "$address - $status <br/>"
	}

	#Wenn hier kein "<." steht haben wir einen Fehler:
	#set zeile [lindex $stdout $result(DEVICE_COUNT)]
	#if { [string equal $zeile "<."] } then {
	#}
}

proc ise_getProgramCount {p_ise_PROGRAMCOUNT} {
	
	upvar $p_ise_PROGRAMCOUNT ise_PROGRAMCOUNT

	set isecmd ""
	append isecmd "string id;"
	append isecmd "string tmp;"
	append isecmd "string dev_iface_id;"
	append isecmd "string dev_iface_name;"
	append isecmd "object dev;"
	append isecmd "object chn;"
	append isecmd "integer iProgCount;"
	append isecmd "integer DEVICE_COUNT = 0;"
	append isecmd "foreach(id, root.Devices().EnumEnabledIDs() )"
	append isecmd "\{"
	append isecmd "  iProgCount = 0;"
	append isecmd "  dev = dom.GetObject(id);"
	append isecmd "  if (dev)"
	append isecmd "  \{"
	append isecmd "    if ( dev.Name() != 'Gateway' )"
	append isecmd "    \{ "
	append isecmd "      if ( dev.Interface() != ID_ERROR )"
	append isecmd "      \{"
	append isecmd "        foreach(tmp, dev.EnumChannelGroups(true) )"
	append isecmd "        \{"
	append isecmd "          chn = dom.GetObject(tmp);"
	append isecmd "          if (chn)"
	append isecmd "          \{"
	append isecmd "            if(chn.Internal() == false)"
	append isecmd "            \{"
	append isecmd "              if (chn.ChnDPUsageCount() != ID_ERROR) "
	append isecmd "              \{"
	append isecmd "                  iProgCount = iProgCount + chn.ChnDPUsageCount();"
	append isecmd "              \}"
	append isecmd "            \}"
	append isecmd "          \}"
	append isecmd "        \}"
	append isecmd "        foreach(tmp, dev.EnumChannelGroups(false) )"
	append isecmd "        \{"
	append isecmd "          chn = dom.GetObject(tmp);"
	append isecmd "          if (chn)"
	append isecmd "          \{"
	append isecmd "            if (chn.ChnNumber() != 0)"
	append isecmd "            \{"
	append isecmd "              if(chn.Internal() == false)"
	append isecmd "              \{"
	append isecmd "                if (chn.ChnDPUsageCount() != ID_ERROR) "
	append isecmd "                \{"
	append isecmd "                  iProgCount = iProgCount + chn.ChnDPUsageCount();"
	append isecmd "                \}"
	append isecmd "              \}"
	append isecmd "            \}"
	append isecmd "          \}"
	append isecmd "        \}"
	append isecmd "        dev_iface_id = dev.Interface();"
	append isecmd "        dev_iface_name = dom.GetObject(dev_iface_id);"
	append isecmd "        DEVICE_COUNT = DEVICE_COUNT + 1;"
	append isecmd "        WriteLine(dev_iface_name # ';' # dev.Address() # ' ' # iProgCount);"
	append isecmd "      \}"
	append isecmd "    \}"
	append isecmd "  \}"
	append isecmd "\}"
	append isecmd "Write('<.');"

	if { [catch {array set result [rega_script $isecmd]} ] } then { return }
	if { [catch {set dummy $result(DEVICE_COUNT)       } ] } then { return }

	set stdout [split $result(STDOUT) "\n"]
	
	for {set i 0} {$i < $result(DEVICE_COUNT)} {incr i} {
	
		#Iface;Address ProgramCount
		#BidCos-RF;DAA0217858 2
		set zeile [lindex $stdout $i]

		if { $zeile == "" || [string equal $zeile "<."] } then {
			#(Fehler="" Datensatz i.O. = "<.")
			break
		}
				
		set address   [string range $zeile 0                                    [expr [string first " " $zeile] - 1]]
		set progcount [string range $zeile [expr [string first " " $zeile] + 1] end]
		set ise_PROGRAMCOUNT($address) $progcount
	}

	#Wenn hier kein "<." steht haben wir einen Fehler:
	#set zeile [lindex $stdout $result(CHANNEL_COUNT)]
	#if { [string equal $zeile "<."] } then {
	#}
}

proc metadata_getReadyConfig { iface device } {

	global metadata_ise_READYCONFIG
	if { ![array size metadata_ise_READYCONFIG] } {
	    set isecmd ""
	    append isecmd "string id;"
	    append isecmd "object channel;"
	    append isecmd "string ch_addr;"
	    append isecmd "string ch_iface;"
	    append isecmd "integer ch_iface_id;"
	    append isecmd "integer CHANNEL_COUNT = 0;"
	    append isecmd "boolean ch_ready;"
	    append isecmd "foreach(id, root.Channels().EnumUsedIDs())"
	    append isecmd "{"
	    append isecmd "  channel = dom.GetObject(id);"
	    append isecmd "  ch_addr = channel.Address();"
	    append isecmd "  ch_ready = channel.ReadyConfig();"
	    #append isecmd "  ch_iface_id = channel.Interface();"
        #append isecmd "  ch_iface    = dom.GetObject(ch_iface_id);"
	    append isecmd "  if (ch_addr != '')"
	    append isecmd "  {"
	    #append isecmd "    Write(ch_iface.Name() # ';' # ch_addr # ' ' # ch_ready # '\n');"
	    append isecmd "    Write( ch_addr # ' ' # ch_ready # '\n');"
	    append isecmd "    CHANNEL_COUNT = CHANNEL_COUNT + 1;"
	    append isecmd "  }"
	    append isecmd "}"
	    append isecmd "foreach(id, root.Devices().EnumUsedIDs())"
	    append isecmd "{"
	    append isecmd "  channel = dom.GetObject(id);"
	    append isecmd "  ch_addr = channel.Address();"
	    #append isecmd "  ch_iface_id = channel.Interface();"
        #append isecmd "  ch_iface    = dom.GetObject(ch_iface_id);"
	    append isecmd "  ch_ready    = channel.ReadyConfig();"
	    append isecmd "  if (ch_addr != '')"
	    append isecmd "  {"
	    #append isecmd "    Write(ch_iface.Name() # ';' # ch_addr # ' ' # ch_ready # '\n');"
	    append isecmd "    Write( ch_addr # ' ' # ch_ready # '\n');"
	    append isecmd "    CHANNEL_COUNT = CHANNEL_COUNT + 1;"
	    append isecmd "  }"
	    append isecmd "}"
	    append isecmd "Write('<.');"
        
	    if { [catch {array set result [rega_script $isecmd]} ] } then { return 0 }
	    if { [catch {set dummy $result(CHANNEL_COUNT)      } ] } then { return 0 }

	    set stdout [split $result(STDOUT) "\n"]
	
	    for {set i 0} {$i < $result(CHANNEL_COUNT)} {incr i} {
	
		    #Address iseReadyConfig
		    #DAA0217858:1 true
		    #DAA0217858:2 false
		    set zeile [lindex $stdout $i]

		    if { $zeile == "" || [string equal $zeile "<."] } then {
			    #(Fehler="" Datensatz i.O. = "<.")
			    break
		    }
				
		    set address [string range $zeile 0                                    [expr [string first " " $zeile] - 1]]
		    set rc      [string range $zeile [expr [string first " " $zeile] + 1] end]
		    set metadata_ise_READYCONFIG($address) $rc

		    #puts "$address - $rc <br/>"
	    }
    }
    if { [info exists metadata_ise_READYCONFIG($device)] } { 
        set v $metadata_ise_READYCONFIG($device) 
        return [ expr {$v  || [string is true $v]} ]
	} else {
        return 0
    }
}

  proc metaData_isGroupOnly {chName} {

    set isecmd ""
    append isecmd "object dev = dom.GetObject('$chName');"
    append isecmd "if (dev.TypeName() == 'CHANNEL')"
    append isecmd "{"
    append isecmd "  dev = dom.GetObject(dev.Device());"
    append isecmd "}"
    append isecmd "var GROUP = dev.MetaData('operateGroupOnly');"

	  if { [catch { array set result [rega_script $isecmd]} ] } then { return }
	  if { [catch {set dummy $result(GROUP)      } ] } then { return }
    return $result(GROUP);
  }

} else {
    #No ReGaHss available. Get Metadata from BidCoS-Service
    
proc ise_getChannelRooms {p_ise_ROOMS} {
	
	upvar $p_ise_ROOMS ise_ROOMS
    
    # ToDo: Array iseROOMS füllen, Schlüssel=Kanaladresse, Wert=Räume als TCL-Liste
}

proc ise_getRooms {p_ise_ROOMS} {
	
	upvar $p_ise_ROOMS ise_ROOMS

	set ise_ROOMS ""
	
    # ToDo: TCL-Liste iseROOMS füllen mit Raumnamen
    set ise_ROOMS [ list Wohnzimmer Kueche Bad ]
}

proc ise_getFunctions {p_ise_FUNCTIONS} {
	
	upvar $p_ise_FUNCTIONS ise_FUNCTIONS

	set ise_FUNCTIONS ""
	
    # ToDo: TCL-Liste iseFUNCTIONS füllen mit Gewerkenamen
    set ise_FUNCTIONS [ list Licht Verschluss Umwelt ]
}

proc ise_getChannelFunctions {p_ise_FUNCTIONS} {
	
	upvar $p_ise_FUNCTIONS ise_FUNCTIONS
	
    # ToDo: Array iseFUNTIONS füllen, Schlüssel=Kanaladresse, Wert=Gewerke als TCL-Liste
}

proc ise_getChannelNames {p_ise_CHANNELNAMES} {

    global iface_url iface_descr INTERFACES_FILE env
	upvar $p_ise_CHANNELNAMES ise_CHANNELNAMES
    
    foreach iface [array names iface_url] {
        catch {
            set url $iface_url($iface)
            set devlist [xmlrpc $url listDevices [list bool 0]]
            foreach dev $devlist {
                array set dev_descr $dev
                set name $dev_descr(ADDRESS)
                catch {
                    set name [xmlrpc $url getMetadata $dev_descr(ADDRESS) NAME]
                }
                set ise_CHANNELNAMES($iface\;$dev_descr(ADDRESS)) $name
            }
        }
    }
}

proc ise_getProgramCount {p_ise_PROGRAMCOUNT} {
	
	upvar $p_ise_PROGRAMCOUNT ise_PROGRAMCOUNT

    # ToDo: Array p_ise_PROGRAMCOUNT füllen, Schlüssel=Kanaladresse, Wert=Programmanzahl
}

proc metadata_getReadyConfig { iface device } {
    return 1
}

  proc metaData_isGroupOnly {chName} {
    # ToDo MetaData operateGroupOnly des Gerätes (nicht des Kanals) zurück geben.
    return false;
  }

}