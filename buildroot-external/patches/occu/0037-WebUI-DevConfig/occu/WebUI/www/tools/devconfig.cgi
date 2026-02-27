#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce common.tcl
loadOnce tclrpc.so
catch {
    loadOnce tclrega.so
    set rega_available 1
}

set GRAPHSERVICE http://www.homematic.com/tools/drawgraph.php
set INTERFACES_FILE "/etc/config/InterfacesList.xml"

set url ""
set iface ""

set RSSI_BAD -120.0
set RSSI_MEDIUM -100.0
set RSSI_GOOD -20.0

set sid [session_urlsid]
set urlsid "$sidname=$sid"

array set interfaces ""
array set interface_descriptions ""

proc read_interfaces {} {
    global interfaces interface_descriptions INTERFACES_FILE env
    array_clear interfaces
    array_clear interface_descriptions
    set retval 1
    if { [ info exist env(BIDCOS_SERVICE) ] } {
        set interfaces(default) "$env(BIDCOS_SERVICE)"
        set interface_descriptions(default) "Default BidCoS Interface"
    } else {
        set fd -1
        catch {set fd [open $INTERFACES_FILE r]}
        if { $fd >=0 } {
            set contents [read $fd]
            while { [regexp -indices {</ipc[^>]*>} $contents range] } {
                set section [string range $contents 0 [lindex $range 1]]
                set contents [string range $contents [expr [lindex $range 1] + 1] end]
                if { 
                        [regexp {<name[^>]*>([^<]+)</name} $section dummy name] &&
                        [regexp {<url[^>]*>([^<]+)</url} $section dummy url] &&
                        [regexp {<info[^>]*>([^<]+)</info} $section dummy description ]
                } {
                    array set interfaces [list $name $url]
                    array set interface_descriptions [list $name $description]
                }
            }
            close $fd
        } else {
            puts "Could not open interface file"
            set retval 0
        }
    }
    return $retval
}

proc put_javascript {} {
    global url env urlsid
    cgi_javascript "language=\"javascript\"" {
        puts "    var request = false;"
        puts "    function set_value(iface, device, id, type, input_id)"
        puts "    { "
        puts "      var input=document.getElementById(input_id);"
        puts "      var value;"
        puts "      if(input){"
        puts "          if(input.type==\"checkbox\")value=input.checked;"
        puts "          else value=input.value;"
        puts "      }else value=input_id;"
        puts ""        
        puts "      request = false;"
        puts "      if ( window.XMLHttpRequest ){ "
        puts "        try{ "
        puts "          request = new XMLHttpRequest();"
        puts "        } catch ( e ) {}"
        puts "      } else { "
        puts "        if ( window.ActiveXObject ){ "
        puts "          try{ "
        puts "            request = new ActiveXObject( \"Msxml2.XMLHTTP\" );"
        puts "          } catch ( e ) { "
        puts "            try{"
        puts "              request = new ActiveXObject(\"Microsoft.XMLHTTP\");"
        puts "            } catch ( e ) {}"
        puts "          } "
        puts "        } "
        puts "      }"
        puts "     "
        puts "      if ( request ){"
        puts "        request.open( \"GET\", \"$env(SCRIPT_NAME)?$urlsid&cmd=set_value&device=\"+device+\"&iface=\"+iface+\"&id=\"+id+\"&type=\"+type+\"&value=\"+value+\"\", true );"
        puts "        //request.send( \"$urlsid&cmd=set_value&device=\"+device+\"&iface=\"+iface+\"&id=\"+id+\"&type=\"+type+\"&value=\"+value+\"\");"
        puts "        request.send(null);" 
        puts "        return( true );"
        puts "      }"
        puts "      return( false );"
        puts "    };"
        
        
        puts "    function activate_link_paramset(iface, device, ps_id, longpress)"
        puts "    { "
        puts "      request = false;"
        puts "      if ( window.XMLHttpRequest ){ "
        puts "        try{ "
        puts "          request = new XMLHttpRequest();"
        puts "        } catch ( e ) {}"
        puts "      } else { "
        puts "        if ( window.ActiveXObject ){ "
        puts "          try{ "
        puts "            request = new ActiveXObject( \"Msxml2.XMLHTTP\" );"
        puts "          } catch ( e ) { "
        puts "            try{"
        puts "              request = new ActiveXObject(\"Microsoft.XMLHTTP\");"
        puts "            } catch ( e ) {}"
        puts "          } "
        puts "        } "
        puts "      }"
        puts "     "
        puts "      if ( request ){"
        puts "        request.open( \"GET\", \"$env(SCRIPT_NAME)?$urlsid&cmd=activate_link_paramset&device=\"+device+\"&iface=\"+iface+\"&ps_id=\"+ps_id+\"&long=\"+longpress, true );"
        puts "        //request.send( \"$urlsid&cmd=activate_link_paramset&device=\"+device+\"&iface=\"+iface+\"&ps_id=\"+ps_id+\"&long=\"+longpress);"
        puts "        request.send(null);" 
        puts "        return( true );"
        puts "      }"
        puts "      return( false );"
        puts "    };"
    }
}

proc cmd_main {} {
    global env urlsid
    title "HomeMatic Configuration"
    body {
        h2 "HomeMatic Configuration"
        h3 [url "Channel List" $env(SCRIPT_NAME)?cmd=list_channels&$urlsid]
        h3 [url "Device List" $env(SCRIPT_NAME)?cmd=list_devices&$urlsid]
        h3 [url "Interface List" $env(SCRIPT_NAME)?cmd=list_interfaces&$urlsid]
        h3 [url "Device Status" $env(SCRIPT_NAME)?cmd=device_status&$urlsid]
        h3 [url "Link List" $env(SCRIPT_NAME)?cmd=list_links&$urlsid]
        h3 [url "Service Messages" $env(SCRIPT_NAME)?cmd=service_messages&$urlsid]
        h3 [url "RSSI" $env(SCRIPT_NAME)?cmd=show_rssi&$urlsid]
        h3 [url "Device Types" /tools/devicetypes.html]
    }
}

proc get_devicenames {arr_var} {
    upvar $arr_var arr
    array_clear arr
    catch {
        array_clear result
        array set result [rega_script {
            string dev_id;
            string devs;
            foreach(dev_id, dom.GetObject(ID_DEVICES).EnumUsedIDs()){
                object dev=dom.GetObject(dev_id);
                if( (dev.Interface() != 65535) && (dev.Address() != "") && dev.CreatingCompleted() ) {
                    devs = devs # " " # dev.Address() # " {" # dev.Name() # "} ";
                }
            }
        }]
        array set arr $result(devs)
    }
}

proc cmd_activate_link_paramset {} {
    global url env TYPE_MAP
    import device
    import ps_id
    import long
    
    xmlrpc $url activateLinkParamset [list string $device] [list string $ps_id] [list bool $long]
}

proc cmd_set_value {} {
    global url env
    import device
    import id
    import type
    import value
	#exec echo xmlrpc $url setValue $device $id $type $value >> /var/tmp/out.txt
    xmlrpc $url setValue [list string $device] [list string $id] [list $type $value ]
}

proc cmd_list_channels {} {
    global env interfaces urlsid
    title "Channel List"
    body {
    	h2 "Channel List"
        foreach iface [array names interfaces] {
		    h3 "Interface: $iface"
            if { [ catch {
        	    table { 
                    set url $interfaces($iface)
                    set devlist [xmlrpc $url listDevices [list bool 0]]
                    foreach dev $devlist {
                        array_clear dev_descr
                        array set dev_descr $dev
                        if { "$dev_descr(PARENT)" != "" } {
                            puts ""
                            table_row { 
                                table_data {
                                    h3 [url "$dev_descr(ADDRESS)" $env(SCRIPT_NAME)?cmd=config&device=$dev_descr(ADDRESS)&iface=$iface&$urlsid]
                                }
                                table_data {
                                    h3 "$dev_descr(TYPE)"
                                }
                                table_data {
                                    h4 [url "Device: $dev_descr(PARENT)" $env(SCRIPT_NAME)?cmd=list_devices&expand=$dev_descr(PARENT)&$urlsid]
                                }
                            }
                        }
                    }
                } 
            } ] } { puts "Not running" }
			hr
        }
        puts ""
    }
}

proc cmd_service_messages {} {
    global env interfaces urlsid
    title "Service Messages"
    body {
    	h2 "Service Messages"
   	    table border=0 cellspacing=0 cellpadding=5 {
            set row_index 0
            foreach iface [array names interfaces] {
                if { [ catch {
                    set url $interfaces($iface)
                    set devlist [xmlrpc $url listDevices [list bool 0]]
                    foreach dev $devlist {
                        array_clear dev_descr
                        array set dev_descr $dev
                        if { "$dev_descr(PARENT)" != "" } {
                            array_clear values_descr
                            array set values_descr [xmlrpc $url getParamsetDescription [list string $dev_descr(ADDRESS)] [list string "VALUES"]]
                            set messages ""
                            foreach value_id [lsort [array names values_descr]] {
                                array_clear value_descr
                                array set value_descr $values_descr($value_id)
                                if { !($value_descr(FLAGS) & 8) } continue
                                set value [xmlrpc $url getValue [list string $dev_descr(ADDRESS)] [list string $value_id]]
                                switch $value_descr(TYPE) {
                                    "BOOL" {
                                        if { ! $value } continue
                                        if { [string length $messages] } { append messages "<br>\n" }
                                        append messages "$value_id"
                                    }
                                    "INTEGER" {
                                        if { ! $value } continue
                                        if { [string length $messages] } { append messages "<br>\n" }
                                        append messages "$value_id=$value"
                                    }
                                    "ENUM" {
                                        if { ! $value } continue
                                        if { [string length $messages] } { append messages "<br>\n" }
                                        append messages "$value_id=[lindex $value_descr(VALUE_LIST) $value]"
                                    }
                                }
                            }
                            if { ! [string length $messages] } continue
                            set color [expr $row_index%2?"#C0C0C0":"#E0E0E0"]
                            incr row_index
                            table_row bgcolor=$color { 
                                table_data valign=top {
                                    puts [url "$dev_descr(PARENT_TYPE)::$dev_descr(TYPE) ($dev_descr(ADDRESS))" $env(SCRIPT_NAME)?cmd=config&device=$dev_descr(ADDRESS)&iface=$iface&$urlsid]
                                }
                                table_data valign=top {
                                    puts $messages
                                }
                            }
                        }
                    }
                } ] } { 
                    table_row { 
                        table_data colspan=2 {
                            puts "$iface not running" 
                        }
                    }
                }
            } 
        }
        puts ""
    }
}

proc cmd_list_devices {} {
    global env interfaces urlsid
    set expand ""
    catch { import expand }
    title "Device List"
    body {
    	h2 "Device List"
   	    table { 
            foreach iface [array names interfaces] {
                if { [ catch {
                    set url $interfaces($iface)
                    set devlist [xmlrpc $url listDevices [list bool 0]]
                    foreach dev $devlist {
                        array_clear dev_descr
                        array set dev_descr $dev
                        if { "$dev_descr(PARENT)" == "" } {
                            puts ""
                            table_row { 
                                table_data colspan=2 {
                                    h3 [url "$dev_descr(ADDRESS)" $env(SCRIPT_NAME)?cmd=list_devices&expand=$dev_descr(ADDRESS)&$urlsid]
                                }
                                table_data {
                                    h3 "$dev_descr(TYPE)"
                                }
                                table_data {
                                    h5 "|"
                                }
                                table_data {
                                    h5 [url "Delete" $env(SCRIPT_NAME)?cmd=delete&device=$dev_descr(ADDRESS)&iface=$iface&$urlsid]
                                }
                                table_data {
                                    h5 "|"
                                }
                                table_data {
                                    h5 [url "Delete+Reset" $env(SCRIPT_NAME)?cmd=delete&device=$dev_descr(ADDRESS)&reset=1&iface=$iface&$urlsid]
                                }
                                table_data {
                                    h5 "|"
                                }
                                table_data {
                                    h5 [url "Delete+Force" $env(SCRIPT_NAME)?cmd=delete&device=$dev_descr(ADDRESS)&force=1&iface=$iface&$urlsid]
                                }
                                table_data {
                                    h5 "|"
                                }
                                table_data {
                                    h5 [url "Delete+Defer" $env(SCRIPT_NAME)?cmd=delete&device=$dev_descr(ADDRESS)&defer=1&iface=$iface&$urlsid]
                                }
                                table_data {
                                    h5 "|"
                                }
                                table_data {
                                    h5 [url "Delete+Reset+Defer" $env(SCRIPT_NAME)?cmd=delete&device=$dev_descr(ADDRESS)&reset=1&defer=1&iface=$iface&$urlsid]
                                }
                                table_data {
                                    h5 "|"
                                }
                                table_data {
                                    h5 [url "Delete+Reset+Force" $env(SCRIPT_NAME)?cmd=delete&device=$dev_descr(ADDRESS)&reset=1&force=1&iface=$iface&$urlsid]
                                }
                                table_data {
                                    h5 "|"
                                }
                                table_data {
                                    if { [info exist dev_descr(AVAILABLE_FIRMWARE)] &&
                                         $dev_descr(AVAILABLE_FIRMWARE) != "0.0.0" &&
                                         $dev_descr(AVAILABLE_FIRMWARE) != $dev_descr(FIRMWARE) } {
                                        h5 [url "FW-Upd ($dev_descr(FIRMWARE) to $dev_descr(AVAILABLE_FIRMWARE))" $env(SCRIPT_NAME)?cmd=firmware_update&device=$dev_descr(ADDRESS)&iface=$iface&$urlsid]
                                    }
                                }
                            }
                        } elseif { "$dev_descr(PARENT)" == "$expand" } {
                            puts ""
                            table_row { 
                                table_data width=10 { }
                                table_data {
                                    h3 [url "$dev_descr(ADDRESS)" $env(SCRIPT_NAME)?cmd=config&device=$dev_descr(ADDRESS)&iface=$iface&$urlsid]
                                }
                                table_data {
                                    h4 "$dev_descr(TYPE)"
                                }
                                table_data colspan=3 { }
                            }
                        }
                    } 
                } ] } { table_data colspan=4 { puts "$iface: Not running" } }
            }
        }
        puts ""
    }
}

proc cmd_show_rssi {} {
    global env interfaces urlsid
    
    array_clear devnames
    array set devnames ""
    
    set dot "digraph G \{\n    splines = true;\n    mindist=\"0.8\";\n"
        
    get_devicenames devnames
    title "RSSI List"
    body {
    	h2 "RSSI List"
   	    table { 
            foreach iface [array names interfaces] {
                set url $interfaces($iface)
                if {[string match *groups* $url] == 0} {
  #                if { [ catch {
                      if { [ catch {
                          #check if the interface supports rssi
                          #failure of this call will throw us out of here
                          xmlrpc $url system.methodHelp rssiInfo
                      } ] } { continue }
                      array_clear rssi_map
                      if { [catch {
                        set rssi_list [xmlrpc $url rssiInfo ]
                      } ] } {
                        if { "$iface" == "HmIP-RF" } {
                          set rssi_list ""
                          set devlist [xmlrpc $url listDevices [list bool 0]]
                          foreach dev $devlist {
                            array_clear dev_descr
                            array set dev_descr $dev
                            if { "$dev_descr(PARENT)" == "" } {
                              set rssi_device 65536
                              set rssi_peer 65536
                              catch { set rssi_device [xmlrpc $url getValue "$dev_descr(ADDRESS):0" "RSSI_DEVICE"] }
                              catch { set rssi_peer [xmlrpc $url getValue "$dev_descr(ADDRESS):0" "RSSI_PEER"] }
                              set name ""
                              catch { set name $devnames($dev_descr(ADDRESS)) }
                              set rssi_list "\"$name $dev_descr(ADDRESS)\" { $dev_descr(ADDRESS) { $rssi_device $rssi_peer }} $rssi_list"
                            }
                          }
                        } else { continue }
                      }
                      table_data colspan=100 { puts "<hr/><h3><u>$iface:</u></h3>" }
                      array_clear rssi_map
                      array set rssi_map $rssi_list
                      foreach dev [lsort [array names rssi_map]] {
                          puts ""
                          set name ""
                          catch { set name $devnames($dev) }
                          if { [string first $dev $name] < 0 } { append name "<br>$dev" }
                          table_row {
                              table_data rowspan=2 {text-align="left"} {vertical-align="middle"} {
                                  h3 $name
                              }
                              array_clear peer_map
                              array set peer_map $rssi_map($dev)
                              foreach peer [lsort [array names peer_map]] {
                                  set name ""
                                  catch { set name $devnames($peer) }
                                  if { [string first $peer $name] < 0 } { append name "<br>$peer" }
                                  table_data {colspan=2} {text-align="center"} {vertical-align="middle"} {bgcolor="#A0A0A0"} {
                                      puts $name
                                  }
                              }
                              table_row {
                                  foreach peer [lsort [array names peer_map]] {
                                      set rssi_to_peer [lindex $peer_map($peer) 0]
                                      set rssi_from_peer [lindex $peer_map($peer) 1]
                                      rssi_td $rssi_to_peer
                                      rssi_td $rssi_from_peer
                                  }
                              }
                          }
                      }
  #                } ] } { table_data colspan=4 { puts "$iface: Not running" } }
                }
            }
        }
        puts ""
        cmd_rssi_graph
        set GRAPHVIZ_DOWNLOAD "http://www.graphviz.org/Download_windows.php"
        h3 [url "Create RSSI-graph" $env(SCRIPT_NAME)?cmd=dot_rssi&$urlsid]
        puts [url $GRAPHVIZ_DOWNLOAD $GRAPHVIZ_DOWNLOAD] 
    }
}

proc cmd_dot_rssi {} {
    global env interfaces urlsid RSSI_BAD RSSI_MEDIUM RSSI_GOOD
        array_clear devnames
        array set devnames ""
        get_devicenames devnames

		puts "Content-Type:application/octet-stream"
		puts "Content-Disposition:attachment;filename=rssi_graph.cmd\n"
		puts "echo off"
		puts "echo digraph G { > %TEMP%\\rssi.dot"
		puts "echo   splines = true; >> %TEMP%\\rssi.dot"
		puts "echo   mindist=\"0.8\"; >> %TEMP%\\rssi.dot"
		
		foreach iface [array names interfaces] {
			set url $interfaces($iface)
				if { [ catch {
					#check if the interface supports rssi
					#failure of this call will throw us out of here
					xmlrpc $url system.methodHelp rssiInfo
				} ] } { continue }
				set rssi_list [xmlrpc $url rssiInfo ]
				array_clear rssi_map
				array set rssi_map $rssi_list
				
				foreach dev [lsort [array names rssi_map]] {
                    set devname ""
                    catch { set devname $devnames($dev) }
                    if { [string first $dev $devname] < 0 } { append devname "\\n$dev" }
					array_clear peer_map
					array set peer_map $rssi_map($dev)
					foreach peer [lsort [array names peer_map]] {
                        set peername ""
                        catch { set peername $devnames($peer) }
                        if { [string first $peer $peername] < 0 } { append peername "\\n$peer" }
						#set rssi_to_peer [lindex $peer_map($peer) 0]
						set rssi_from_peer [lindex $peer_map($peer) 1]
							
						if { $rssi_from_peer < 65536 } {
							set red [rssi_color $RSSI_GOOD $RSSI_MEDIUM $rssi_from_peer]
							set green [rssi_color $RSSI_BAD $RSSI_MEDIUM $rssi_from_peer]
							set color [format "#%02X%02X00" $red $green]
							puts "echo   \"$devname\" -^> \"$peername\"\[label=\"$rssi_from_peer dBm\" fontcolor=\"$color\" color=\"$color\"\]; >> %TEMP%\\rssi.dot"
						}
					}
				}
		}

		puts "echo } >> %TEMP%\\rssi.dot"
		puts "\n"
		puts "dot -Tpng -Gcharset=latin1 %TEMP%\\rssi.dot -o %TEMP%\\rssi.png"
		puts "start %TEMP%\\rssi.png"

}

proc cmd_rssi_graph {} {
    global env interfaces urlsid RSSI_BAD RSSI_MEDIUM RSSI_GOOD GRAPHSERVICE
        array_clear devnames
        array set devnames ""
        get_devicenames devnames

        set dot "digraph G \{\n    splines = true;\n    mindist=\"0.8\";\n"
        
		foreach iface [array names interfaces] {
			set url $interfaces($iface)
			if {[string match *groups* $url] == 0} {
          if { [ catch {
            #check if the interface supports rssi
            #failure of this call will throw us out of here
            xmlrpc $url system.methodHelp rssiInfo
          } ] } { continue }
          set rssi_list [xmlrpc $url rssiInfo ]
          array_clear rssi_map
          array set rssi_map $rssi_list

          foreach dev [lsort [array names rssi_map]] {
                      set devname ""
                      catch { set devname $devnames($dev) }
                      if { [string first $dev $devname] < 0 } { append devname "\\n$dev" }
            array_clear peer_map
            array set peer_map $rssi_map($dev)
            foreach peer [lsort [array names peer_map]] {
                          set peername ""
                          catch { set peername $devnames($peer) }
                          if { [string first $peer $peername] < 0 } { append peername "\\n$peer" }
              #set rssi_to_peer [lindex $peer_map($peer) 0]
              set rssi_from_peer [lindex $peer_map($peer) 1]

              if { $rssi_from_peer < 65536 } {
                set red [rssi_color $RSSI_GOOD $RSSI_MEDIUM $rssi_from_peer]
                set green [rssi_color $RSSI_BAD $RSSI_MEDIUM $rssi_from_peer]
                set color [format "#%02X%02X00" $red $green]
                              append dot "    \"$devname\" -> \"$peername\"\[label=\"$rssi_from_peer dBm\" fontcolor=\"$color\" color=\"$color\"\];\n"
              }
            }
          }
			}
		}
        append dot "\}\n"

        form "$GRAPHSERVICE" enctype=multipart/form-data method=post target=_blank {
            export action=firmware_upload
            export description=$dot
            submit_button "name=Create RSSI Graph online"
        }
		
}

proc rssi_color {lower_bound upper_bound rssi} {
    set result [expr 256*($rssi-$lower_bound)/($upper_bound-$lower_bound)]
    if { $result < 0 } { set result 0 }
    if { $result > 255 } { set result 255 }
    return [expr int($result)]
}

proc rssi_td {rssi} {
		global RSSI_BAD RSSI_MEDIUM RSSI_GOOD
    if { $rssi >= 65536 } { 
        td "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        return
    }
    set red [rssi_color $RSSI_GOOD $RSSI_MEDIUM $rssi]
    set green [rssi_color $RSSI_BAD $RSSI_MEDIUM $rssi]
    set color [format "#%02X%02X00" $red $green]
    table_data "bgcolor=\"$color\"" {
        puts "[set rssi]&nbsp;dBm"
    }
}

proc cmd_list_links {} {
    global env interfaces urlsid
    title "Link List"
    body {
    	h2 "Link List"
        table {
            foreach iface [array names interfaces] {
                set url $interfaces($iface)
                if { [ catch {
                    #check if the interface supports links
                    #failure of this call will throw us out of here
                    xmlrpc $url system.methodHelp getLinks
                } ] } { continue }
                if { [ catch {
                    set links [xmlrpc $url getLinks]
                    foreach _link $links {
                        array_clear link
                        array set link $_link
                        set sender $link(SENDER)
                        set receiver $link(RECEIVER)
                        table_row {
                            table_data {
                                puts "[url $sender $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$sender&$urlsid] -> [url $receiver $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$receiver&$urlsid]"
                            }
                            td $link(NAME)
                            td [url Edit $env(SCRIPT_NAME)?cmd=link_paramset&iface=$iface&sender=$sender&receiver=$receiver&show_reverse=1&$urlsid]
                            td [url Delete $env(SCRIPT_NAME)?cmd=delete_link&iface=$iface&sender=$sender&receiver=$receiver&redir_cmd=list_links&$urlsid]
                            table_data {
                                if { $link(FLAGS) & 0x01 } { puts "Sender Broken" }
                                if { $link(FLAGS) & 0x02 } {  puts "Receiver Broken"  }
                            }
                        }
                        puts ""
                    }
                } ] } { 
                    table_row {
                        table_data colspan=4 {
                            puts "$iface not running" 
                        }
                    }
                }
            }
        }
    }
}

array set MAINTENANCE_VALUES { CONFIG_PENDING flag LOWBAT flag STICKY_UNREACH flag UNREACH flag AES_KEY value}
proc cmd_device_status {} {
    global env interfaces urlsid MAINTENANCE_VALUES
    title "Device Status List"
    body {
    	h2 "Device Status List"
   	    table { 
            table_row {
                th ""
                foreach name [array names MAINTENANCE_VALUES] {
                    th $name
                }
            }
            foreach iface [array names interfaces] {
                #catch {
                    set url $interfaces($iface)
                    set devlist [xmlrpc $url listDevices [list bool 0]]
                    set mode [expr {$iface == "HmIP-RF" || $iface == "BidCos-RF"}]
                    foreach dev $devlist {
                        array_clear dev_descr
                        array set dev_descr $dev
                        if { "$dev_descr(PARENT)" != "" && "$dev_descr(TYPE)" == "MAINTENANCE" } {
                            puts ""
                            table_row { 
                                table_data {
                                    h3 "$dev_descr(PARENT)"
                                }

				array_clear valueset
				if { $mode } {
				    array set valueset [xmlrpc $url getParamset [list string $dev_descr(ADDRESS)] [list string VALUES] [list int $mode]]
				} else {
				    array set valueset [xmlrpc $url getParamset [list string $dev_descr(ADDRESS)] [list string VALUES]]
				}

				#parray valueset

                                foreach name [array names MAINTENANCE_VALUES] {
                                    set type $MAINTENANCE_VALUES($name)
                                    table_data {
                                        if { [info exist valueset($name)] } {
					    set status ""
					    set val ""
					    if { [string first "UNDEFINED" $valueset($name)] != -1 } {
						array_clear value
						array set value $valueset($name)
						if { $value(UNDEFINED) } {
							set status "(?)"
						}
						set val $value(VALUE)
					    } else {
						set val $valueset($name)
					    }
                                            if { "$type" == "flag" } {
						if { $val } {
							set val "true"
						} else {
							set val "false"
						}
                                            } elseif { "$type" == "value" } {
                                                set val "$val"
                                            }
					    h4 "$val $status"
                                        }
                                    }
                                }
                            }
                        }
                    } 
                #}
            }
        }
        puts ""
    }
}

proc cmd_list_interfaces {} {
    global env interfaces interface_descriptions urlsid
    title "Interface List"
    body {
    	h2 "Interface List"
        foreach iface [array names interfaces] {
            set url $interfaces($iface)
            set description $interface_descriptions($iface)
            h3 "$iface ($description)"
            puts ""
            if [ catch {
                catch {
                    #check if the interface supports install mode
                    #failure of this call will throw us out of here
                    xmlrpc $url system.methodHelp setInstallMode
                    if { [xmlrpc $url getInstallMode ""] } {
                        puts "Install Mode is active "
                        puts [url "Leave install mode" $env(SCRIPT_NAME)?cmd=interface_cmd&iface=$iface&method=setInstallMode&args=bool%20false&$urlsid]
                    } else {
                        puts "Install Mode is not active "
                        puts [url "Enter install mode" $env(SCRIPT_NAME)?cmd=interface_cmd&iface=$iface&method=setInstallMode&args=bool%20true&$urlsid]
                    }
                }
                br
                puts [url "Discovery" $env(SCRIPT_NAME)?cmd=interface_cmd&iface=$iface&method=searchDevices&args=&$urlsid]
                br
                form $env(SCRIPT_NAME) method=get {
					export $urlsid
                    export cmd=interface_cmd
                    export iface=$iface
                    export method=addDevice
                    puts -nonewline "Serial# "
                    cgi_text "args="
                    submit_button "submit=Add Device"
                }
                catch {
                    #check if the interface supports key exchange
                    #failure of this call will throw us out of here
                    xmlrpc $url system.methodHelp changeKey
                    form $env(SCRIPT_NAME) method=get {
						export $urlsid
                        export cmd=interface_cmd
                        export iface=$iface
                        export method=changeKey
                        puts -nonewline "Passphrase"
                        cgi_text "args="
                        submit_button "submit=Change Key"
                    }
                    form $env(SCRIPT_NAME) method=get {
						export $urlsid
                        export cmd=interface_cmd
                        export iface=$iface
                        export method=setTempKey
                        puts -nonewline "Passphrase"
                        cgi_text "args="
                        submit_button "submit=Set Temporary Key"
                    }
                }
            } ] { puts "Not running" }
            br
        }
    }
}

proc cmd_interface_cmd {} {
    global env url iface urlsid
    import method
    import args
    xmlrpc $url $method $args
    redirect $env(SCRIPT_NAME)?cmd=list_interfaces&$urlsid
}

#array set TYPE_MAP {
    #"BOOL" "bool"
    #"ENUM" "int"
    #"INTEGER" "int"
    #"FLOAT" "double"
    #"STRING" "string"
    #"ACTION" "bool"
#}

proc cmd_put_paramset {} {
    global url iface env TYPE_MAP urlsid
    import ps_id
    import ps_type
    import device
    import redir_url
    array_clear ps_descr
    array set ps_descr [xmlrpc $url getParamsetDescription [list string $device] [list string $ps_type]]
    set struct ""
    foreach param_id [lsort [array names ps_descr]] {
        array_clear param_descr
        array set param_descr $ps_descr($param_id)
        set sentry ""
        lappend sentry $param_id
        set type $param_descr(TYPE)
        set value 0
        catch { import_as $param_id value }
        lappend sentry [list $TYPE_MAP($type) $value]
        lappend struct $sentry
    }
#    body { puts "xmlrpc $url putParamset [list string $device] [list string $ps_id] [list struct $struct]" }
    xmlrpc $url putParamset [list string $device] [list string $ps_id] [list struct $struct]

	#Rudiment???
    array_clear ps
    array set ps [xmlrpc $url getParamset [list string $device] [list string $ps_id]]

    redirect $redir_url
}


proc show_paramset {device ps_type ps_id ps_var ps_descr_var redir_url sid} {
    global iface env TYPE_MAP urlsid sidname url
    upvar $ps_var ps
    upvar $ps_descr_var ps_descr
    form $env(SCRIPT_NAME) method=get {
        export cmd=put_paramset
        export ps_id
        export ps_type
        export device
        export iface
        export redir_url
		export $urlsid
        table {
            foreach param_id [lsort [array names ps_descr]] {
                array_clear param_descr
                array set param_descr $ps_descr($param_id)
                set type $param_descr(TYPE)

                # For HmIP-devices the unit is sometimes not available
                if { [catch {set unit $param_descr(UNIT)}]} {
                  set unit ""
                }

                set min $param_descr(MIN)
                set max $param_descr(MAX)
                set operations $param_descr(OPERATIONS)
                set id "id=\"$ps_id.$param_id\""
                set value ""
                if { ! ($operations & 3) } continue
                set unknown ""
                if { $operations & 1 } {
                    if [info exist ps($param_id)] {
                        set value $ps($param_id) 
                    } else {
                        set unknown " (unknown)"
                        set value $param_descr(DEFAULT)
                    }
                }
                if { $operations & 2 } {
                    set access ""
                } else {
                    set access "readonly=\"true\""
                }
                puts ""
                table_row {
                    td "$param_id$unknown"
                    switch $type {
                        "BOOL" {
                            if {$value == "" } {set value false}
                            if { $value } {
                                set checked "checked"
                            } else {
                                set checked ""
                            }
                            table_data { cgi_checkbox $param_id=1 $id $access $checked}
                            td
                        }
                        "STRING" {
                            table_data { cgi_text $param_id=$value $id $access }
                            td "$unit"
                        }
                        "INTEGER" {
                            table_data {
                                set hidden ""
                                if { [ info exist param_descr(SPECIAL) ] } {
                                    cgi_select _$param_id size=1 "onchange=\"document.getElementById('$ps_id.$param_id').value=this.options\[this.selectedIndex\].value;document.getElementById('$ps_id.$param_id').style.visibility=(this.selectedIndex < [llength $param_descr(SPECIAL)])?'hidden':'visible';\"" {
                                        set i 0
                                        foreach _sv $param_descr(SPECIAL) {
                                            array_clear sv
                                            array set sv $_sv
                                            if { $sv(VALUE) == $value } {
                                                set selected selected
                                            } else  {
                                                set selected ""
                                            }
                                            cgi_option $sv(ID) "value=$sv(VALUE)" $selected
                                            incr i
                                        }
                                        if { $value >= $param_descr(MIN) && $value <= $param_descr(MAX) } {
                                            set selected selected
                                            set hidden ""
                                        } else {
                                            set selected ""
                                            set hidden "style=\"visibility:hidden;\""
                                        }
                                        set default_value $param_descr(DEFAULT)
                                        if { $default_value < $param_descr(MIN) || $default_value > $param_descr(MAX) } {
                                            set default_value $param_descr(MIN)
                                        }
                                        cgi_option "Enter Value" "value=$default_value" $selected
                                    }
                                }
                                cgi_text $param_id=$value $id $access $hidden
                            }
                            td "$unit ($min-$max)"
                        }
                        "FLOAT" {
                            table_data {
                                set hidden ""
                                if { [ info exist param_descr(SPECIAL) ] } {
                                    cgi_select _$param_id size=1 "onchange=\"document.getElementById('$ps_id.$param_id').value=this.options\[this.selectedIndex\].value;document.getElementById('$ps_id.$param_id').style.visibility=(this.selectedIndex < [llength $param_descr(SPECIAL)])?'hidden':'visible';\"" {
                                        set i 0
                                        foreach _sv $param_descr(SPECIAL) {
                                            array_clear sv
                                            array set sv $_sv
                                            if { $sv(VALUE) == $value } {
                                                set selected selected
                                            } else  {
                                                set selected ""
                                            }
                                            cgi_option $sv(ID) "value=$sv(VALUE)" $selected
                                            incr i
                                        }
                                        if { $value >= $param_descr(MIN) && $value <= $param_descr(MAX) } {
                                            set selected selected
                                            set hidden ""
                                        } else {
                                            set selected ""
                                            set hidden "style=\"visibility:hidden;\""
                                        }
                                        set default_value $param_descr(DEFAULT)
                                        if { $default_value < $param_descr(MIN) || $default_value > $param_descr(MAX) } {
                                            set default_value $param_descr(MIN)
                                        }
                                        cgi_option "Enter Value" "value=$default_value" $selected
                                    }
                                }
                                cgi_text $param_id=$value $id $access $hidden
                            }
                            td "$unit ($min-$max)"
                        }
                        "ENUM" {
                            table_data {
                                set value_list $param_descr(VALUE_LIST)
                                if { "$access" == "" } {
                                    cgi_select $param_id size=1 $id {
                                        set i 0
                                            foreach v $value_list {
                                                if { ![string length $v] } continue
                                                if { $i == $value } {
                                                    cgi_option $v value=$i selected
                                                } else  {
                                                    cgi_option $v value=$i
                                                }
                                            incr i
                                        }
                                    }
                                } else {
                                    # puts "[lindex $value_list $value]"
                                    puts "[lsearch $value_list $value]"
                                }
                            }
                            td
                        }
                        "ACTION" {
                            table_data { cgi_checkbox $param_id=1 $id $access "style=\"visibility:hidden;\"" }
                            td
                        }
                        default {
                            puts "Unknown type \"$type\"<br>"
                        }
                    }
                    if { $ps_type == "VALUES" } {
                        table_data {
                            if { $operations & 2 } {
                                button "Set" "onClick=set_value('$iface', '$device', '$param_id', '$TYPE_MAP($type)', '$ps_id.$param_id')"
                            }
                        }
                    }
                    if { $operations & 8 } {
                        td [url "Determine" $env(SCRIPT_NAME)?cmd=determine_parameter&iface=$iface&device=$device&ps_id=$ps_id&param_id=$param_id&$urlsid]
                    }
                }
                puts ""
            }
        }
        if { $ps_type != "VALUES" } {
            submit_button "submit=Submit changes"
            puts ""
        }
        if { $ps_type == "LINK" } {
            button "Simulate Shortpress" "onClick=activate_link_paramset('$iface', '$device', '$ps_id', false)"
            puts ""
            button "Simulate Longpress" "onClick=activate_link_paramset('$iface', '$device', '$ps_id', true)"
            puts ""
        }
    }
}

proc cmd_link_paramset {} {
    global iface url env urlsid sid
    import sender
    import receiver
    set show_reverse 0
    catch { import show_reverse }
    title "$sender -> $receiver Link Configuration"
    put_javascript
    body {
        catch {
            array_clear ps_descr
            array set ps_descr [xmlrpc $url getParamsetDescription [list string $sender] [list string "LINK"]]
            array_clear ps
            array set ps [xmlrpc $url getParamset [list string $sender] [list string $receiver]]
    	    h2 "Link Configuration for sender [url $sender $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$sender&$urlsid] with receiver [url $receiver $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$receiver&$urlsid]"
            show_paramset $sender "LINK" $receiver ps ps_descr $env(SCRIPT_NAME)?cmd=link_paramset&iface=$iface&sender=$sender&receiver=$receiver&show_reverse=$show_reverse&$urlsid $sid
        }
        if { $show_reverse } {
            array_clear ps
            array_clear ps_descr
            #catch {
                array set ps_descr [xmlrpc $url getParamsetDescription [list string $receiver] [list string "LINK"]]
                array set ps [xmlrpc $url getParamset [list string $receiver] [list string $sender]]
        	    h2 "Link Configuration for receiver [url $receiver $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$receiver&$urlsid] with sender [url $sender $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$sender&$urlsid]"
                show_paramset $receiver "LINK" $sender ps ps_descr $env(SCRIPT_NAME)?cmd=link_paramset&iface=$iface&sender=$sender&receiver=$receiver&show_reverse=$show_reverse&$urlsid $sid
            #}
        }
    }
}

proc cmd_determine_parameter {} {
    global iface url env urlsid sid
    import device
    import ps_id
    import param_id
    xmlrpc $url determineParameter [list string $device] [list string $ps_id] [list string $param_id]
    redirect $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$device&$urlsid
}

proc cmd_delete_link {} {
    global iface url env urlsid
    import sender
    import receiver
    set device ""
    catch { import device }
    import redir_cmd
    xmlrpc $url removeLink [list string $sender] [list string $receiver]
    redirect $env(SCRIPT_NAME)?cmd=$redir_cmd&iface=$iface&device=$device&$urlsid
}

proc check_role_match { set1 set2 } {
    foreach role $set1 { 
        if { [lsearch -exact $set2 $role] >= 0 } {
            return $role
        }
    }
    return ""
}

proc cmd_clear_config_cache {} {
    global iface url env urlsid
    import device
    xmlrpc $url clearConfigCache [list string $device]
    redirect $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$device&$urlsid
}

proc cmd_add_link_list {} {
    global iface url env urlsid
    import device
    array_clear dev_descr
    array set dev_descr [xmlrpc $url getDeviceDescription [list string $device]]
    set parent $dev_descr(PARENT)
    set peers [xmlrpc $url getLinkPeers [list string $device]]
    set dev_source_roles $dev_descr(LINK_SOURCE_ROLES)
    set dev_target_roles $dev_descr(LINK_TARGET_ROLES)
    title "$device Add Link"
    body {
    	h2 "Add Link for [url $device $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$device&$urlsid] - select peer"
#        puts "$dev_descr(ADDRESS): $dev_descr(LINK_TARGET_ROLES), $dev_descr(LINK_SOURCE_ROLES) <br>"
        set devlist [xmlrpc $url listDevices [list bool 0]]
        array_clear matching_channels
        foreach dev $devlist {
            array_clear peer_descr
            array set peer_descr $dev
            if { "$peer_descr(PARENT)" != "" } {
                set role [check_role_match $dev_source_roles $peer_descr(LINK_TARGET_ROLES)]
                if { "$role" == "" } {
                    set role [check_role_match $dev_target_roles $peer_descr(LINK_SOURCE_ROLES)]
                }
#                puts "$peer_descr(ADDRESS): $peer_descr(LINK_TARGET_ROLES), $peer_descr(LINK_SOURCE_ROLES)<br>"
                if { "$role" == "" } continue
                append matching_channels($role) "[url $peer_descr(ADDRESS) $env(SCRIPT_NAME)?cmd=add_link&iface=$iface&device=$device&peer=$peer_descr(ADDRESS)&$urlsid]\n"
            }
        }
        table {
            table_row {
                th "Role"
                th "Available Channels"
            }
            foreach role [lsort [array names matching_channels]] {
                table_row {
                    td {align="left"} $role
                    td $matching_channels($role)
                }
            }
        }
    }
}

proc cmd_add_link {} {
    global iface url env urlsid
    import device
    import peer
    array_clear device_description
    array set device_description [xmlrpc $url getDeviceDescription [list string $device]]
    if { $device_description(DIRECTION) == 1 } {
        set sender $device
        set receiver $peer
    } else {
        set receiver $device
        set sender $peer
    }
    xmlrpc $url addLink [list string $sender] [list string $receiver]
    redirect $env(SCRIPT_NAME)?cmd=link_paramset&iface=$iface&sender=$sender&receiver=$receiver&show_reverse=1&$urlsid
}

proc cmd_delete {} {
    global url iface env urlsid
    import device
    set reset 0
    set force 0
    set defer 0
    catch { import reset }
    catch { import force }
    catch { import defer }
    set option 0
    if { $reset == 1 } { set option [expr {$option + 1}] }
    if { $force == 1 } { set option [expr {$option + 2}] }
    if { $defer == 1 } { set option [expr {$option + 4}] }
    xmlrpc $url deleteDevice [list string $device] [list int $option]
    redirect $env(SCRIPT_NAME)?cmd=list_devices&iface=$iface&$urlsid
}

proc cmd_firmware_update {} {
    global url iface env urlsid
    import device
    set channel ""
    catch {import channel}
    set result [xmlrpc $url updateFirmware [list string $device]]
    if { [lindex $result 0] } {
        set success "succeeded"
    } else {
        set success "failed"
    }
    title "Firmware update for $device $success"
    body {
        h2 "Firmware update for $device $success"
        if { "$channel" != "" } {
            puts [url "Back to channel config" $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$channel&$urlsid]
        } else {
            puts [url "Back to device list" $env(SCRIPT_NAME)?cmd=list_devices&$urlsid]
        }
    }
}

proc cmd_restore_config {} {
    global url iface env urlsid
    import device
    import channel
    catch {
        xmlrpc $url restoreConfigToDevice [list string $device]
        redirect $env(SCRIPT_NAME)?cmd=config&device=$channel&iface=$iface&$urlsid]
        return
    }
    title "Restoring config for $device failed"
    body {
        h2 "Restoring config for $device failed"
        puts [url "Back to channel config" $env(SCRIPT_NAME)?cmd=config&device=$channel&iface=$iface&$urlsid]
    }
}

proc cmd_config {} {
    global url iface env urlsid sid sidname
    import device
    title "$device Configuration"
    put_javascript
    body {
        array_clear dev_descr
        array set dev_descr [xmlrpc $url getDeviceDescription [list string $device]]
    	h2 "Channel configuration for $dev_descr(TYPE) $device"
        set parent $dev_descr(PARENT)
        if { $parent != "" } {
            array_clear parent_descr
            array set parent_descr [xmlrpc $url getDeviceDescription [list string $parent]]
            puts "Device firmware version $parent_descr(FIRMWARE)\n"
            if { [info exist parent_descr(AVAILABLE_FIRMWARE)] } {
                br
                puts "Available firmware version $parent_descr(AVAILABLE_FIRMWARE)\n"
            }
            if { [lsearch $parent_descr(PARAMSETS) "MASTER"] >= 0 } {
                h3 "Device Parameters"
                puts ""
                array_clear parent_ps_descr
                array set parent_ps_descr [xmlrpc $url getParamsetDescription [list string $parent] [list string "MASTER"]]
                array_clear parent_ps
                array set parent_ps [xmlrpc $url getParamset [list string $parent] [list string "MASTER"]]
                show_paramset $parent "MASTER" "MASTER" parent_ps parent_ps_descr $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$device&$urlsid $sid
            }
            h3 [url "Firmware Update" $env(SCRIPT_NAME)?cmd=firmware_update&device=$parent&channel=$device&iface=$iface&$urlsid]
            h3 [url "Restore Config" $env(SCRIPT_NAME)?cmd=restore_config&device=$parent&channel=$device&iface=$iface&$urlsid]
        }
        foreach ps_id $dev_descr(PARAMSETS) {
            array_clear ps_descr
            array set ps_descr [xmlrpc $url getParamsetDescription [list string $device] [list string $ps_id]]
            if { "$ps_id" == "MASTER" } {
                if { "$dev_descr(PARENT)" == "" } {
                    h3 "Device Parameters"
                    puts ""
                    br
                } else {
                    h3 "Channel Parameters"
                    puts ""
                }
                array_clear ps
                array set ps [xmlrpc $url getParamset [list string $device] [list string $ps_id]]
                show_paramset $device $ps_id $ps_id ps ps_descr $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$device&$urlsid $sid
            }
            if { "$ps_id" == "VALUES" } {
                h3 "Values"
                puts ""
                array_clear ps
                foreach id [array names ps_descr] {
                    catch {
                        set ps($id) [xmlrpc $url getValue [list string $device] [list string $id]]
                    }
                }
                show_paramset $device $ps_id $ps_id ps ps_descr $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$device&$urlsid $sid
            }
        }
        if { [info exist dev_descr(TEAM)] } {
            h3 "Team"
            puts ""
            form $env(SCRIPT_NAME) method=get {
                table {
                    table_row {
                        table_data {
                            puts "[url $dev_descr(TEAM) $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$dev_descr(TEAM)&$urlsid]"
                        }
                        table_data {
                            export cmd=change_team
                            export device
                            export iface
                            export $urlsid
                            cgi_select team size=1 {
                                set i 0
                                set teamlist [xmlrpc $url listTeams ]
                                foreach team $teamlist {
                                    array_clear team_descr
                                    array set team_descr $team
                                    if { "$team_descr(PARENT)" == "" } continue
                                    if { ! [info exist team_descr(TEAM_TAG)] } continue
                                    if { "$team_descr(TEAM_TAG)" != "$dev_descr(TEAM_TAG)" } continue
                                    if { "$team_descr(ADDRESS)" == "$dev_descr(TEAM)" } {
                                        set selected "selected"
                                    } else {
                                        set selected ""
                                    }
                                    cgi_option $team_descr(ADDRESS) value=$team_descr(ADDRESS) $selected
                                    incr i
                                }
                                cgi_option "Reset to default" value=***RESET***
                            }
                        }
                        table_data {
                            submit_button "submit=Change"
                        }
                    }
                }
            }
        }
        if { [info exist dev_descr(TEAM_CHANNELS)] } {
            h3 "Team Members"
            puts ""
            table {
                foreach ch $dev_descr(TEAM_CHANNELS) {
                    table_row {
                        table_data {
                            puts "[url $ch $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$ch&$urlsid]"
                        }
                    }
                }
            }
        }
        if { $dev_descr(DIRECTION) != 0 } {
            h3 "Links"
            puts ""
            table {
                set links [xmlrpc $url getLinks [list string $device]]
                foreach _link $links {
                    array_clear link
                    array set link $_link
                    set sender $link(SENDER)
                    set receiver $link(RECEIVER)
                    
                    table_row {
                        table_data {
                            puts "[url $sender $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$sender&$urlsid] -> [url $receiver $env(SCRIPT_NAME)?cmd=config&iface=$iface&device=$receiver&$urlsid]"
                        }
                        td $link(NAME)
                        td [url Edit $env(SCRIPT_NAME)?cmd=link_paramset&iface=$iface&sender=$sender&receiver=$receiver&show_reverse=1&$urlsid]
                        td [url Delete $env(SCRIPT_NAME)?cmd=delete_link&iface=$iface&sender=$sender&receiver=$receiver&device=$device&redir_cmd=config&$urlsid]
                    }
                    puts ""
                }
            }
            puts [url "Add Peer" $env(SCRIPT_NAME)?cmd=add_link_list&iface=$iface&device=$device&$urlsid]
        }
        br
        puts [url "Clear device config cache" $env(SCRIPT_NAME)?cmd=clear_config_cache&iface=$iface&device=$device&$urlsid]
    }
}

proc cmd_change_team {} {
    global iface url
    import device
    import team
    if { "$team" == "***RESET***" } { set team "" }
    xmlrpc $url setTeam [list string $device] [list string $team]
    cmd_config
}

proc cmd_xml_paramset {} {
    global iface env TYPE_MAP urlsid sidname url
    import sender
    import receiver
    set device $sender
    set peer $receiver
    
    for {set i 0} {$i<2} {incr i} {
    
        array_clear ps_descr
        array set ps_descr [xmlrpc $url getParamsetDescription [list string $device] [list string "LINK"]]
        array_clear ps
        array set ps [xmlrpc $url getParamset [list string $device] [list string $peer]]
        array_clear peer_description
        array set peer_description [xmlrpc $url getDeviceDescription [list string $peer]]
        puts {<default_values function="">}
        foreach param_id [lsort [array names ps_descr]] {
            array_clear param_descr
            array set param_descr $ps_descr($param_id)
            set type $param_descr(TYPE)
            set def $param_descr(DEFAULT)
            set value $ps($param_id)
            if { $value == $def } continue
        
            switch $type {
                "BOOL" {
                    if { $value } {
                        set value "true"
                    } else {
                        set value "false"
                    }
                }
                "STRING" {
                }
                "INTEGER" {
                }
                "FLOAT" {
                }
                "ENUM" {
                    set value_list $param_descr(VALUE_LIST)
                    # set value [lindex $value_list $value]
                    set value [lsearch $value_list $value]
                }
                "ACTION" {
                    continue
                }
            }
            puts "    <value id=\"$param_id\" value=\"$value\"/>"
        }
        puts "</default_values>\n"
        set device $receiver
        set peer $sender
    }
}

proc cmd_csv_paramset {} {
    global iface env TYPE_MAP urlsid sidname url
    import sender
    import receiver
    set device $sender
    set peer $receiver
    
    for {set i 0} {$i<2} {incr i} {

        array_clear ps_descr
        array set ps_descr [xmlrpc $url getParamsetDescription [list string $device] [list string "LINK"]]
        array_clear ps
        array set ps [xmlrpc $url getParamset [list string $device] [list string $peer]]
        array_clear peer_description
        array set peer_description [xmlrpc $url getDeviceDescription [list string $peer]]
        foreach param_id [lsort [array names ps_descr]] {
            array_clear param_descr
            array set param_descr $ps_descr($param_id)
            set type $param_descr(TYPE)
            set def $param_descr(DEFAULT)
            set value $ps($param_id)
            set hr_value ""
            
            switch $type {
                "BOOL" {
                    if { $value } {
                        set hr_value "true"
                    } else {
                        set hr_value "false"
                    }
                }
                "STRING" {
                }
                "INTEGER" {
                }
                "FLOAT" {
                }
                "ENUM" {
                    set value_list $param_descr(VALUE_LIST)
                    # set hr_value [lindex $value_list $value]
                    set hr_value [lsearch $value_list $value]
                }
                "ACTION" {
                    continue
                }
            }
            puts "$param_id;$value;$hr_value"
        }
        puts ""
        set device $receiver
        set peer $sender
    }
}


cgi_eval {
#cgi_debug -on
cgi_input
catch {
    import debug
    cgi_debug -on
}
read_interfaces
catch {
    import iface
    set url $interfaces($iface)
}

if {[session_requestisvalid 0] > 0} then {
	set cmd main
	catch { import cmd }
	cmd_$cmd
}

}
