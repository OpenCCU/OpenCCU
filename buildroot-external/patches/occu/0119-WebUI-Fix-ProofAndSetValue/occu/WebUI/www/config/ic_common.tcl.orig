#!/bin/tclsh
source once.tcl
loadOnce tclrpc.so
sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce user.tcl
sourceOnce common.tcl
sourceOnce ic_metadata.tcl

source [file join $env(DOCUMENT_ROOT) config/easymodes/EnterFreeValue.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/getStatusDisplayHelp.tcl]


#Flags für xmlrpc Aufruf "getLinks"
set GL_FLAG_GROUP                0x01
set GL_FLAG_SENDER_PARAMSET      0x02
set GL_FLAG_RECEIVER_PARAMSET    0x04
set GL_FLAG_SENDER_DESCRIPTION   0x08
set GL_FLAG_RECEIVER_DESCRIPTION 0x10
set GL_FLAG_SENDER_BROKEN        0x1
set GL_FLAG_RECEIVER_BROKEN      0x2
set GL_FLAG_SENDER_UNKNOWN       0x4
set GL_FLAG_RECEIVER_UNKNOWN     0x8

set HTMLTITLE "HomeMatic Interne Konfiguration"
set INTERFACES_FILE "/etc/config/InterfacesList.xml"

if { ![info exists env(CONFIG_ROOT)] } {
    set env(CONFIG_ROOT) "/etc/config"
}

set USERPROFILESPATH [file join $env(CONFIG_ROOT) userprofiles]
catch { file mkdir $USERPROFILESPATH }

set wired "n.a"
set mapped_profile "unset"
array set map_link ""

array set iface_url   ""
array set iface_descr ""
array set nav_th ""
array set nav_td ""
array set TYPE_MAP { "BOOL" "bool" "ENUM" "int" "INTEGER" "int" "FLOAT" "double" "STRING" "string"}

set IC_SETTINGS_CONF_FILE [file join $env(CONFIG_ROOT) ic_settings.dat]
array set IC_SETTINGS_VALUES ""
#Defaults (werden von der Settings-Datei überschrieben):
set IC_SETTINGS_VALUES(EXPERTMODE) "off"

#proc appenduser2nav {} {
#proc appenddev2nav {device} {
#proc appendchannel2nav {device iface channel} {
#proc append2nav {th td} {
#proc put_header {} {
#proc put_footer {} {
#proc read_interfaces {} {
#proc set_profiles {iface address profile type} {
#proc base_put_profile {iface address profile peer ps_type} {
#proc base_put_page {iface address pid peer} {
#proc put_error404 {} {
#proc put_error_profilenotfound {} {

proc read_ic_settings {} {
  global IC_SETTINGS_CONF_FILE IC_SETTINGS_VALUES
  read_assignment_file $IC_SETTINGS_CONF_FILE IC_SETTINGS_VALUES
}

proc write_ic_settings {} {
  global IC_SETTINGS_CONF_FILE IC_SETTINGS_VALUES
  write_assignment_file $IC_SETTINGS_CONF_FILE IC_SETTINGS_VALUES
}

proc appenduser2nav {} {

  global sidname
  
  set uid  [session_uid]
  
  if {$sidname == "sid"} then {
    set name [user_name_ise $uid]
  } else {
    set name [user_name $uid]
  }

  set url  [session_geturlwithoutsid]

  if {$name == ""} then {set name $uid}

  append2nav [url "Benutzer" $url] $name
}

proc appendstart2nav {} {

  global urlsid
  
  append2nav [url "Start" "ic_start.cgi?$urlsid"] "&nbsp;"
}

proc appenddev2nav {device} {

  global urlsid

  append2nav [url "Gerät" "ic_devices.cgi?$urlsid"] $device
}

proc appendchannel2nav {device iface channel} {

  global urlsid

  append2nav [url "Kanal" "ic_channels.cgi?device=$device\&amp;iface=$iface\&amp;$urlsid"] $channel
}
  
proc appendpeer2nav {channel iface peer} {

  global urlsid

  append2nav [url "Verknüpfungspartner" "ic_linkpeers.cgi?device=$channel\&amp;iface=$iface\&amp;$urlsid"] $peer
}

proc append_dev_channel_2nav {address iface} {

  global iface_url
  
  set channel ""
  set device  ""

    set url $iface_url($iface)
    array set dev_descr [xmlrpc $url getDeviceDescription [list string $address]]

  if {$dev_descr(PARENT) != $address && $dev_descr(PARENT) != ""} then {

    set channel $address
    set device  $dev_descr(PARENT)
  
    appenddev2nav $device
    appendchannel2nav $device $iface $channel
  } else {
  
    set channel ""
    set device $address

    appenddev2nav $device
  }
}

proc append2nav {th td} {

  global nav_th nav_td
  
  set idx [array size nav_th]
  
  array set nav_th [list $idx $th]
  array set nav_td [list $idx $td]
}

proc put_header {} {

  global nav_th nav_td
  
  h3 "Navigation"
  set theader ""
  set tdata   ""
  
    foreach key [lsort [array names nav_th]] {
  
    set theader $theader<th>$nav_th($key)</th>
    set tdata   $tdata<td>$nav_td($key)</td>
  }
  
  puts "<table border=\"1\" >"
  puts <tr>$theader</tr>
  puts <tr>$tdata</tr>
  puts "</table>"
  hr
}

proc put_footer {} {

  hr
   puts [url "Zurück" "javascript:history.back()"]
}

proc read_interfaces {} {

    global iface_url iface_descr INTERFACES_FILE env
    set retval 1

    if { [ info exist env(BIDCOS_SERVICE) ] } {
        set iface_url(default) "$env(BIDCOS_SERVICE)"
        set iface_descr(default) "Default BidCoS Interface"
    } else {

        set fd -1

      if { ! [catch {open $INTERFACES_FILE RDONLY} fd] } then {
  
            set contents [read $fd]
    
            while { [regexp -indices {</ipc[^>]*>} $contents range] } {
    
                set section  [string range $contents 0                            [lindex $range 1]]
                set contents [string range $contents [expr [lindex $range 1] + 1] end]
      
                if { 
                    [regexp {<name[^>]*>([^<]+)</name} $section dummy name] &&
                    [regexp {<url[^>]*>([^<]+)</url} $section dummy url] &&
                    [regexp {<info[^>]*>([^<]+)</info} $section dummy description ]
                } {
                    array set iface_url   [list $name $url]
                    array set iface_descr [list $name $description]
                }
            }
    
            close $fd
    
        } else {
  
        html {
            h1 "Could not open interface file<br/>"
        }
            set retval 0
        }
    }
    return $retval
}

#return -1: Fehler
#return  1: OK
proc set_value {iface address id type value} {
  
  global iface_url

  set ret -1
  set url $iface_url($iface)

  #exec echo $address $id $type $value $f >> /var/tmp/out.txt
    
  if { ! [catch {xmlrpc $url setValue [list string $address] [list string $id] [list $type $value] } f ] } then {
    set ret 1
  }

  return $ret
}

#return -1: Fehler: Im übergebenen Profil ist kein Element enthalten, welches zu dem Parametern der Instanz passt.
#return  1: xmlrpc Aufruf durchgeführt
proc set_profiles {iface address pprofile type peer} {
    global USERPROFILESPATH iface_url TYPE_MAP map_link

#cgi_debug -on

  upvar $pprofile profile
  
  set ret -1
  set url $iface_url($iface)

  array set ps_descr ""

  catch { array set ps_descr [xmlrpc $url getParamsetDescription [list string $address] [list string $type] ] }

    set struct ""

  # catch {exec rm /var/tmp/out.txt}
  # exec echo Interface : $iface - Address : $address - Type : $type - Peer : $peer >> /var/tmp/out.txt
    
  if { ![info exist env(IC_OPTIONS)] || ([string first NO_PROFILE_MAPPING $env(IC_OPTIONS)] < 0) } {
  
      # Verknuepfungen dem array map_link zuweisen
      read_links

      #Wenn die Verknüpfung noch nicht registriert ist  
      if {! [info exists map_link($peer-$address)]} {
            catch {
                set fd [open $USERPROFILESPATH/link.db a]
                puts $fd "$peer-$address"
                close $fd
            }
      }  
    }
  
  #lsort: nur für eine saubere out.txt
  foreach param_id [lsort [array names ps_descr]] {

        array_clear param_descr
        array set param_descr $ps_descr($param_id)

        set sentry ""
        lappend sentry $param_id
        set paramtype $param_descr(TYPE)
    
    #Wert aus dem Profil entnehmen
    set pval 0

    #In den IF-Zweig sollte das Skript nie hineinlaufen. Dann fehlen Parameter in dem Profil.
    #Ein Expertenprofil ist anders: es gibt keine Vorgaben / alle Werte kommen aus dem WebUI.
    if { [catch { set pval $profile($param_id) }] } then {
    
      #Nur das Link-Parameterset hat UI_HINT UI_DESCRIPTION UI_TEMPLATE UI_...
      if { $type == "LINK" && [string range $param_id 0 2] != "UI_" } then {
        #Die Ausgabe: NUR FÜR DIE ENTWICKLUNGSZEIT:
        puts "<b style=\"CLASS21806\">FEHLER! Parameter $param_id ist nicht im Profil enthalten!</b> check XML-File<br/>"
      }

      continue
    }


      if { $paramtype != "STRING" } then {
        ## gral :  durch [lindex $pval 0] wird immer der 1. Wert aus dem jeweiligem easymode-Profile gesetzt,
        ##      unabhängig davon, wieviel Werte vorhanden sind.
        
        lappend sentry [list $TYPE_MAP($paramtype) [lindex $pval 0]]
      } else {
        ## wernerf: Parameter vom Typ "string" sollen nicht als Listen aufgefasst werden, da sie sonst
        ##          nach dem ersten Leerzeichen abgeschnitten werden.
        ## ==> Parameter vom Typ "string" beginnen mit "string:"
        
        # lappend sentry [list $TYPE_MAP($paramtype) [string range $pval 0 end]]
        lappend sentry [list $TYPE_MAP($paramtype) $pval] 
      }
      
    # exec echo $param_id : $pval >> /var/tmp/out.txt
    #-----------------------------

        lappend struct $sentry
    #puts "Wert: $pval auf $param_id <br />"
  }

  if {[llength $struct] > 0} then {
      #putParamset - values to commit to the rfd
      #exec echo "$address $peer $struct" >> /tmp/profile.txt
      if { ! [catch {xmlrpc $url putParamset [list string $address] [list string $peer] [list struct $struct]} ] } then {
      set ret 1
    }
  }
  return $ret
}

proc put_linkimage_dev {} {

  global iface_url iface device peer

    set url $iface_url($iface)
  set imgpath_devi "img/devices/unknown_device.png"

  catch {
    array set devi_descr        [xmlrpc $url getDeviceDescription [list string $device]]
            set imgpath_devi      "img/devices/$devi_descr(TYPE).png"
    array set devi_descr_parent [xmlrpc $url getDeviceDescription [list string $devi_descr(PARENT)]]
            set imgpath_devi      "img/devices/$devi_descr_parent(TYPE).png"
  }

  if { ![file exists $imgpath_devi]} then {
    set imgpath_devi "img/devices/unknown_device.png"
  }

  set img_devi "<img alt=\"$devi_descr(TYPE)\" src=\"$imgpath_devi\" width=\"50\" onmouseover=\"picDivShow('$imgpath_devi');\" onmouseout=\"picDivHide();\" />"

  puts "<table cellspacing=\"10\" border=\"0\">"
  puts "<tr>"
  puts "<td style=\"text-align:center;\">$img_devi</td>"
  puts "</tr>"
  puts "<tr>"
  puts "<td style=\"text-align:center;\">$devi_descr(TYPE)</td>"
  puts "</tr>"
  puts "</table>"
}

proc put_linkimages {} {

  global iface_url iface device peer

    set url $iface_url($iface)
  
    set imgpath_devi "img/devices/unknown_device.png"
  catch {
    array set devi_descr [xmlrpc $url getDeviceDescription [list string $device]]
    array set devi_descr_parent [xmlrpc $url getDeviceDescription [list string $devi_descr(PARENT)]]
            set imgpath_devi "img/devices/$devi_descr_parent(TYPE).png"
  }
  
    set imgpath_peer "img/devices/unknown_device.png"
  catch {
    array set peer_descr [xmlrpc $url getDeviceDescription [list string $peer]  ]
    array set peer_descr_parent [xmlrpc $url getDeviceDescription [list string $peer_descr(PARENT)]]
          set imgpath_peer "img/devices/$peer_descr_parent(TYPE).png"
  }
  
  if { ![file exists $imgpath_devi]} then {
    set imgpath_devi "img/devices/unknown_device.png"
  }

  if { ![file exists $imgpath_peer]} then {
    set imgpath_peer "img/devices/unknown_device.png"
  }
  
  set img_devi "<img alt=\"$devi_descr(TYPE)\" src=\"$imgpath_devi\" width=\"50\" onmouseover=\"picDivShow('$imgpath_devi');\" onmouseout=\"picDivHide();\" />"
  set img_peer "<img alt=\"$peer_descr(TYPE)\" src=\"$imgpath_peer\" width=\"50\" onmouseover=\"picDivShow('$imgpath_peer');\" onmouseout=\"picDivHide();\" />"

  puts "<table cellspacing=\"10\" border=\"0\">"
  puts "<tr>"
  puts "<td style=\"text-align:center;\">$img_devi</td>"
  puts "<td style=\"text-align:center;\">===</td>"
  puts "<td style=\"text-align:center;\">$img_peer</td>"
  puts "</tr>"
    puts "<tr>"
  puts "<td style=\"text-align:center;\">$devi_descr(TYPE)</td>"
  puts "<td style=\"text-align:center;\">&nbsp;</td>"
  puts "<td style=\"text-align:center;\">$peer_descr(TYPE)</td>"
  puts "</tr>"
  puts "</table>"
}

proc check_role_match { set1 set2 } {
    foreach role $set1 { 
        if { [lsearch -exact $set2 $role] >= 0 } {
            return 1
        }
    }
    return 0
}

# This has been introduced with the heating control HM-CC-RT-DN
# While creating a link the peer partner of the the same device will be filtered
# For example: channel 4 of a new heating device can be linked with channel 5 of other new heating devices and vice versa.
# We have to filter out channel 5 of the same device, otherwise we could link channel 4 with channel 5 of the same device.
proc check_isSameDeviceAndValid {senderAddress receiverAddress peerAddress type} {
   if {[string length $senderAddress] != 0} {
     if {[lindex [split $senderAddress ":"] 0] == [lindex [split $peerAddress ":"] 0]  } {
       if {$type == "CLIMATECONTROL_RT_RECEIVER"} {
         return 0
       }
      return 1
     }
   } else {
   if {[lindex [split $receiverAddress ":"] 0] == [lindex [split $peerAddress ":"] 0]  } {
     if {$type == "CLIMATECONTROL_RT_TRANSCEIVER"} {
       return 0
     }
    return 1
   }
   }
   return 1
}

proc cmd_add_link {iface device peer} {

    global iface_url
    set url $iface_url($iface)
    xmlrpc $url addLinkPeer [list string $device] [list string $peer]
}

proc cmd_delete_link {iface device peer} {
    global iface_url
    set url $iface_url($iface)
    xmlrpc $url removeLinkPeer [list string $device] [list string $peer]
}

proc base_put_page {iface address pid peer ps_type} {

  global HTMLTITLE PROFILES_MAP env sid HTML_PARAMS cur_profile IC_SETTINGS_VALUES sidname
  appenduser2nav
  appendstart2nav
  
  if {$peer == "MASTER"} then {
    #appenddev2nav $address
    append_dev_channel_2nav $address $iface
  } else {
    append_dev_channel_2nav $address $iface
    appendpeer2nav $address $iface $peer
  }


  html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"de\" lang=\"de\" {
    head {
      puts "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\" />"
      title "$HTMLTITLE - Geräteparameter"

      puts "<script src=\"/config/js/ic_common.js\" type=\"text/javascript\"></script>"
      puts "<script src=\"/webui/js/extern&prototype.js\" type=\"text/javascript\"></script>"
    }

    body "onload=\"SwitchActiveProfile($cur_profile);\"" {
      put_header

      if {$peer == "MASTER"} then {
        put_linkimage_dev
      } else {
        put_linkimages
      }
      
      puts "<div id=\"settingscontent\">"
      puts "<span id=\"settingsheading\">Bitte wählen Sie ein Profil.</span>"
      puts "<br />"
      puts "<p>(Klicken Sie auf ein Profil, um die Ansicht zu erweitern.)</p>"

      puts "<form action=\"#\">"
      puts "<input id=\"global_1\" type=\"hidden\" name=\"$sidname\" value=\"$sid\" />"
      puts "<input id=\"global_2\" type=\"hidden\" name=\"peer\"     value=\"$peer\" />"
      puts "<input id=\"global_3\" type=\"hidden\" name=\"paramId\"  value=\"$pid\" />"
      puts "<input id=\"global_4\" type=\"hidden\" name=\"cmd\"      value=\"set\" />"
      puts "<input id=\"global_5\" type=\"hidden\" name=\"iface\"    value=\"$iface\" />"
      puts "<input id=\"global_6\" type=\"hidden\" name=\"device\"   value=\"$address\" />"
      puts "<input id=\"global_7\" type=\"hidden\" name=\"ps_type\"  value=\"$ps_type\" />"
      
      puts "<input id=\"profile\"  type=\"hidden\" name=\"profile\"  value=\"-1\" />"
      puts "</form>"

      if {$peer != "MASTER"} then {
        puts "Aktives Profil auslösen:<br />Kurzer Tastendruck:"
        puts "<a href=\"#\" onclick=\"SimulateShortKeyPress();\"><img alt=\"Kurzen Tastendruck simulieren\" title=\"Kurzen Tastendruck simulieren\" class=\"clickIcon\" src=\"img/profile_activate_short.png\" /></a>"
        puts "Langer Tastendruck:<a href=\"#\" onclick=\"SimulateLongKeyPress();\"><img alt=\"Kurzen Tastendruck simulieren\" title=\"Langen Tastendruck simulieren\" class=\"clickIcon\" src=\"img/profile_activate_long.png\" /></a>"
      }

      set hasprofile false

      catch {
        puts $HTML_PARAMS(before_profiles)
        set hasprofile true
      }

      foreach pnr [lsort [array names PROFILES_MAP]] {

        if {$IC_SETTINGS_VALUES(EXPERTMODE) != "on" && $pnr == 0} then { continue }

        if {$HTML_PARAMS(separate_$pnr) == ""} then { continue }

        puts "<table class=\"profileTable\"><tbody><tr>"
        puts "  <td id=\"caption_profile$pnr\" onclick=\"ToggleVisibility('profile$pnr')\" class=\"CLASS21800\">$PROFILES_MAP($pnr) $HTML_PARAMS(active_$pnr)</td>"
        puts "</tr></tbody></table>" 

        puts "<div style=\"visibility: visible; display: none;\" class=\"profileDetails\" id=\"profile$pnr\">"
        puts "<table class=\"profileSetting\"><tbody><tr class=\"CLASS21801\">"
        puts "  <td>$HTML_PARAMS(separate_$pnr)"
        if {$pnr != 9999} then { puts "    <a href=\"#\" onclick=\"SubmitProfile($pnr, '$PROFILES_MAP($pnr)');\"><img alt=\"Profil setzen\" title=\"Profil setzen\" class=\"clickIcon\" src=\"img/profile_save.png\" /></a>" }
        puts "  </td></tr></tbody></table>" 
        puts "</div>"

        set hasprofile true
      } 

      catch {
        puts $HTML_PARAMS(after_profiles)
        set hasprofile true
      }

      if {$hasprofile == "false"} then {
        puts "Kein Profil gefunden."
      }

      #id=settingscontent
      puts "</div>"

      puts "<div id=\"infobox\" class=\"CLASS21802\" style=\"display:none;\"></div>"
      
      put_footer
      put_picDiv
    }
  }
}

proc activate_link_paramset {iface address ps_id long_push} {

    global iface_url
    set url $iface_url($iface)

  html {
    head {
    }
    body {
      if { ![catch { xmlrpc $url activateLinkParamset [list string $address] [list string $ps_id] [list bool $long_push] } ] } then {
        puts "<table><tr><td></td><img alt=\"Info\" class=\"CLASS21803\" src=\"/ise/img/dialog-information.png\" /><td><span>Tastendruck wurde simuliert.</span></td></tr></table>"
      } else {
        puts "<table><tr><td><img alt=\"Error\" class=\"CLASS21803\" src=\"/ise/img/dialog-error.png\" /></td><td><span>Fehler! Der Tastendruck konnte <u>nicht</u> simuliert werden.</span></td></tr></table>"
      }
    }
  }
}

proc modify_easymode_ui {IGNORE_PARAMS profile pPROFILE} {

#cgi_debug -on

  global env
  upvar $pPROFILE PROFILE_TMP

  set params [split [cgi_unquote_input $env(QUERY_STRING)] &]


  #Parametername eines evtl. Subsets auf den URL-Parametern generieren. z.B. subset_4_1
  set i 1
  set subsetid subset_${profile}_$i

  foreach p $params {

    if { [regexp {^(.*)=(.*)$} $p dummy name value] } then {

      if { [lsearch -exact $IGNORE_PARAMS $name] >= 0} then {

        continue
        
      } elseif { $name == $subsetid } then {

        #Subset setzen:
        global SUBSET_$value

        #NEU-----
        if { [array size SUBSET_$value] == 0 } then {
          upvar SUBSET_$value PROFILE_X
          array set SUBSET_$value [array get PROFILE_X]
        }
        #-----
        
        array set SUBSET [array get SUBSET_$value]

        if {[array size SUBSET] == 0} then {continue}

        foreach p [array names SUBSET] {
          if { [lsearch -exact $IGNORE_PARAMS $p] >= 0} then {
            continue
          }
          set PROFILE_TMP($p) $SUBSET($p)
        }

        #Neuen Subset-Parameternamen generieren, z.B. subset_4_2
        incr i
        set subsetid subset_$profile
        append subsetid _$i

      } else {

        #Parameter aus URL-Variable setzen:
        set plist [split $name |]

        foreach ap $plist {
          set PROFILE_TMP($ap) $value
        }
      }
    }
  }
}

proc base_put_profile {iface address profile peer ps_type {html_response 1}} {

#cgi_debug -on

  global HTMLTITLE env

  set IGNORE_PARAMS {address cmd iface paramid peer pnr ps_id ps_type sid SUBSET_OPTION_VALUE NAME}

  if { $profile != "" } then {
    
    set arrname PROFILE_$profile

    global PROFILE_TMP
    array_copy $arrname "PROFILE_TMP"

    if { [array size $arrname] == 0 } then {
      upvar $arrname PROFILE_X
      array set PROFILE_TMP [array get PROFILE_X]
    }
  } else {
    #Geräte- und Kanalparameter (MASTER)
    array set PROFILE_TMP ""
  }

  set PROFILE_TMP(CH_VAL_VALUE) ""

  set i 1
  catch {upvar SUBSET_$i SUBSET_$i}
  while { [array size SUBSET_$i] > 0  } {
    incr i
    catch {upvar SUBSET_$i SUBSET_$i}
  }

  #Hier wird das EasyMode-Profil um die WebUI-Eingaben variiert. URL-Parameter, Subsets, usw.
  modify_easymode_ui $IGNORE_PARAMS $profile PROFILE_TMP

  set ret -1
  if {$PROFILE_TMP(CH_VAL_VALUE) == ""} then {
    set ret [set_profiles $iface $address PROFILE_TMP $ps_type $peer]
  
    if {$html_response != 1} then { return $ret }

    global PROFILES_MAP
    if { [array size PROFILES_MAP] == 0 } then {
      upvar PROFILES_MAP PROFILES_MAP
    }
    set pname $PROFILES_MAP($profile)

    html {
      head {
      }
      body {
        if {$ret == "1"} then {
          puts "<table><tr><td></td><img alt=\"Info\" class=\"CLASS21803\" src=\"/ise/img/dialog-information.png\" /><td><span>Das Profil [cgi_quote_html \"$pname\"] wurde gespeichert.</span></td></tr></table>"
          puts "<script type=\"text/javascript\">SwitchActiveProfile($profile);</script>"
        } else {
          puts "<table><tr><td><img alt=\"Error\" class=\"CLASS21803\" src=\"/ise/img/dialog-error.png\" /></td><td><span>Fehler! Das Profil [cgi_quote_html \"$pname\"] konnte <u>nicht</u> gespeichert werden.</span></td></tr></table>"
        }
      }
    }
  } else {
    catch { set ret [set_value $iface $address $PROFILE_TMP(CH_VAL_ID) $PROFILE_TMP(CH_VAL_TYPE) $PROFILE_TMP(CH_VAL_VALUE)] }

    if {$html_response != 1} then { return $ret }

    html {
      head {
      }
      body {
        if {$ret == "1"} then {
          puts "<table><tr><td></td><img alt=\"Info\" class=\"CLASS21803\" src=\"/ise/img/dialog-information.png\" /><td><span>Der Wert [cgi_quote_html '$PROFILE_TMP(CH_VAL_ID)'] wurde gesetzt.</span></td></tr></table>"
        } else {
          puts "<table><tr><td><img alt=\"Error\" class=\"CLASS21803\" src=\"/ise/img/dialog-error.png\" /></td><td><span>Fehler! Der Wert [cgi_quote_html '$PROFILE_TMP(CH_VAL_ID)'] konnte <u>nicht</u> gesetzt werden.</span></td></tr></table>"
        }
      }
    }
  }

  return $ret
}

proc put_error404 {} {

  global HTMLTITLE paramId

  html {
    head {
      puts "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">"
      title "$HTMLTITLE - Profil nicht gefunden"
    }

    body {
      h3 "Das Profil \"$paramId\" wurde nicht gefunden."
      put_footer
    }
  }
}

proc put_error_profilenotfound {} {

  global HTMLTITLE

  html {
    head {
      puts "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">"
      title "$HTMLTITLE - Profil nicht gefunden"
    }

    body {
      h3 "Es wurde kein Profil übergeben."
      put_footer
    }
  }
}

proc put_firebug {} {
  
    puts "<script language=\"javascript\" type=\"text/javascript\" src=\"/config/js/firebug/firebug.js\"></script>"
}

proc put_picDiv {} {
  puts "<div id=\"picDiv\" style=\"position:absolute; left:0px; top:0px; width:200px; height:200px; z-index:1; display:none;\">"
  puts "  <table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" class=\"CLASS21804\">"
  puts "    <tr>"
  puts "      <td style=\"CLASS21807\"  style=\"text-align:center; vertical-align:middle;\"\"><img width=\"200\" alt=\"Loading...\" src=\"img/loading.gif\" id=\"picDivImg\" /></td>"
  puts "    </tr>"
  puts "  </table>"
  puts "</div>"
  puts "<script type=\"text/javascript\">"
  puts "function picDivShow(imgPath)"
  puts "\{"
  puts "  var varPicDiv    = document.getElementById('picDiv');"
  puts "  var varPicDivImg = document.getElementById('picDivImg');"
  puts "  varPicDivImg.src = imgPath;"
  puts "  varPicDiv.style.display = \"\";"
  puts "\}"
  puts "function picDivHide()"
  puts "\{"
  puts "  var varPicDiv    = document.getElementById('picDiv');"
  puts "  var varPicDivImg = document.getElementById('picDivImg');"
  puts "  varPicDiv.style.display = \"none\";"
  puts "  varPicDivImg.src        = 'img/loading.gif';"
  puts "\}"
  puts "function updateMausPosition(e) \{"
  puts "  var varPicDiv = document.getElementById('picDiv');"
  puts "  x = (document.all) ? window.event.x + document.body.scrollLeft : e.pageX;"
  puts "  y = (document.all) ? window.event.y + document.body.scrollTop  : e.pageY;"
  puts "  if (varPicDiv != null && x != null && y != null) \{"
  puts "    try \{"
  puts "      varPicDiv.style.left = ( x +  30 ) + \"px\";"
  puts "      varPicDiv.style.top  = ( y - 100 ) + \"px\";"
  puts "    \} catch (e) \{\}"
  puts "  \}"
  puts "\}"
  puts "document.onmousemove = updateMausPosition;"
  puts "</script>"
}

#width: 250px
#height: 250px
proc put_picDiv_wz { {width 250} {height 250} } {

  set css_w ${width}px
  set css_h ${height}px

  puts "<div id=\"picDiv\" class=\"CLASS21805\" style=\"position:absolute; left:0px; top:0px; width:$css_w; height:$css_h; z-index:9999; visibility: hidden; margin: 0; padding: 0;\">"
  #puts "<div id=\"picDiv\" style=\"position:absolute; left:0px; top:0px; width:$css_w height:$css_h; z-index:1; visibility: hidden; margin: 0; padding: 0; background-color: white;\">"
  #puts "  <table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"width:$css_w; height:$css_h; border: 1px solid #000066\">"
  #puts "    <tr>"
  #puts "      <td bgcolor=\"#FFFFFF\"  style=\"text-align:center; vertical-align:middle;\"><img alt=\"Loading...\" src=\"img/loading.gif\" id=\"picDivImg\" /></td>"
  #puts "    </tr>"
  #puts "  </table>"
  #puts "<img alt=\"Loading...\" src=\"img/loading.gif\" id=\"picDivImg\" />"
  puts "</div>"
  puts "<script type=\"text/javascript\">"
  puts "var jg_250 = new jsGraphics(\"picDiv\");"
  puts "InitGD(jg_250, 250);"
  puts "</script>"
}

proc read_links {} {
  global USERPROFILESPATH map_link  
  
  if { ! [catch {open $USERPROFILESPATH/link.db RDONLY} fd] } then {
    while {![eof $fd]} {
    set map_link([gets $fd]) "true"
    }
    close $fd
  } 
}

proc get_cur_profile2 {pps pPROFILES_MAP pPROFILE_TMP peer_type} {

  global USERPROFILESPATH sender_address receiver_address mapped_profile map_link env
  upvar $pps           ps
  upvar $pPROFILES_MAP PROFILES_MAP
  upvar $pPROFILE_TMP  PROFILE_TMP
  set new_profile_is_set ""
  set cur_profile ""
  catch { set cur_profile $ps(UI_HINT) }
  if { (![info exist env(IC_OPTIONS)]) || ([string first NO_PROFILE_MAPPING $env(IC_OPTIONS)] < 0) } {
      # Verknuepfungen dem array map_link zuweisen
      read_links

      catch {
          # Handelt es sich um ein Profil der Firmwareversion 1.4?
          if {[info exists map_link($sender_address-$receiver_address)]} {
            set new_profile_is_set "true"
          }
        # Wenn noch nicht geschehen, dann die Profile beim Wechsel von
        # Firmwareversionen < 1.4 auf die neue Profilstruktur in >= 1.4 mappen
        if {$cur_profile != "" && $new_profile_is_set == ""} then {
        upvar PROFILE_$cur_profile PROFILE

          if {! [catch {set map_prn $PROFILE(UI_MAP)}]}  {
            set cur_profile $map_prn
            set mapped_profile $map_prn
          #  puts "<p style=\"color:red; text-decoration:blink\">Mapped profile!<p>"
          }
        }

        if {$mapped_profile != "unset"} {set cur_profile $mapped_profile}
        # end mapping....
      }
  }

  if {$cur_profile != ""} then {
    #Existiert dieses Benutzerprofil noch?
    if {[regexp {^([0-9]+)\.([0-9]+)$} $cur_profile dummy f_base_pnr f_user_pnr]} then {
      #Es ist ein vom User erstelltes Benutzerprofil
      if {! [info exists PROFILES_MAP($cur_profile)]} then {
        set cur_profile $f_base_pnr
        return $cur_profile
      }
    }
  }

  #Expertenprofil ist 0:
  set cur_profile 0
  for {set pnr 1} {$pnr < [array size PROFILES_MAP]} {incr pnr} {
    upvar PROFILE_$pnr PROFILE
    catch {
      if {($ps(SHORT_ACTION_TYPE) == 0) && ($ps(LONG_ACTION_TYPE) == 0) && ( [catch {set tmp $PROFILE(UI_VIRTUAL) }] == 0 ) } {
        set cur_profile $pnr
        continue
      } 
    }

    if { [array size PROFILE] == 0 } then {
      upvar PROFILE_$pnr PROFILE
      global PROFILE_$pnr
      array set PROFILE [array get PROFILE_$pnr]
    }         
    
  
    if {[array size PROFILE] == 0} then { continue }

    set match "true"
    set white "false"  ;# WHITELIST vorhanden ?
    set whiteparam "false"  
      
    foreach param [array names PROFILE] { 
        #Wenn Geraet in der Blacklist, dann abbrechen und mit dem nächsten Profil weiter.  
        if {$param  == "UI_BLACKLIST" } then {
          if {[lsearch $PROFILE($param) $peer_type] != -1 } then {
            set match "false"
            continue
          }
        }

        #alle UI_...-Werte (ausser UI_WHITELIST) aus den easymode-Profilen ausblenden
        #UI_WHITELIST wird zur Erkennung des passenden Profiles des jeweiligen Gerätes benötigt.
        if {[string range $param 0 2] == "UI_" && [string range $param 3 11] != "WHITELIST"}  then {continue}
      
        #Gibt es diesen Parameter im Aktor überhaupt?
        if {$param != "UI_WHITELIST" && [catch {set dummy $ps($param) } ] } then { continue }
      
        #Hier wird der Wert in der Variablen whiteparam zwischengespeichert und UI_WHITELIST auch übersprungen
        #Da es mehrere Parameter geben kann, müssen diese via lsearch abgefragt werden
        
        if {$param == "UI_WHITELIST"}  then {
          set white "true" 
          set val [lsearch $PROFILE($param) $peer_type] 
          if { $val != -1 } then {
            set whiteparam [lindex $PROFILE($param) $val]
            continue  
          } else   {continue}
        }
      
      # wird nur aufgerufen, wenn ein "range" im Parameter vorkommt
        if {[lindex $PROFILE($param) 1] == "range"} then {
          set min [lindex $PROFILE($param) 2]
          set max [lindex $PROFILE($param) 4]

          if {$ps($param) >= $min && $ps($param) <= $max } then {
            set PROFILE($param) $ps($param)
            continue
          }
        } else {
        
        # wird nur aufgerufen, wenn kein "range" im Parameter vorkommt
          for {set loop 0} {$loop <= [llength $PROFILE($param)]} {incr loop} {  
        
            if { [lindex $PROFILE($param) $loop] ==  [ expr $ps($param) ] } then  { 
        
              if {$ps($param) != ""} then {
                set PROFILE($param) $ps($param)
             } else { 
                set PROFILE($param) [lindex $PROFILE($param) 0]
             }
                 ## puts "MATCH -- $param&nbsp;Profil Nr $pnr '$PROFILES_MAP($pnr)': [lindex $PROFILE($param) $loop]&nbsp;Aktor: $ps($param)<br/>"
                break
            } 
          }
        }

        if { [lindex $PROFILE($param) 0] != [ expr $ps($param) ] } then {
          ## puts "MISMATCH -- $param&nbsp;Profil Nr $pnr '$PROFILES_MAP($pnr)': [lindex $PROFILE($param) 0]&nbsp;Aktor: $ps($param)<br/>"
          set match "false"
          break 
        }
    };# foreach
  
    #Wenn eine WHITELIST vorhanden ist und das Gerät nicht drin  steht, dann nächstes Profil 
  
    if {$white != "false" && $whiteparam != $peer_type} then {
      set match "false"
    }

    if {$match == "true"} then {
      set cur_profile $pnr
      break
    }
  
  }; # for
  return $cur_profile
}

proc get_cur_profile {iface address peer pps} {

  global PROFILES_MAP PROFILE_TMP cur_profile

  upvar $pps ps
  
  set cur_profile [get_cur_profile2 ps PROFILES_MAP PROFILE_TMP]
  return $cur_profile
}

proc cmd_link_paramset {iface address ps_id ps_type {pnr 0}} {

  global iface_url wired
  #cgi_debug -on 
  
    array set ps_descr ""
    array set ps       ""

    set url $iface_url($iface)

     catch { 
     array set ps_descr [xmlrpc $url getParamsetDescription [list string $address] [list string $ps_type]]
     array set ps       [xmlrpc $url getParamset            [list string $address] [list string $ps_id  ]]
     array set dev_descr [xmlrpc $url getDeviceDescription [list string $address]]
     set wired [string range $dev_descr(PARENT_TYPE) 0 [expr [string first "-" $dev_descr(PARENT_TYPE)] -1]]
    }
    return [cmd_link_paramset2 $iface $address ps_descr ps $ps_type $pnr]
}

proc sort_by_taborder {pps_descr} {

  #cgi_debug -on 

  upvar $pps_descr ps_descr
  array set order_map ""

  foreach param_id [array names ps_descr] {
    catch {
      array_clear param_descr
      array set param_descr $ps_descr($param_id)
      set order_map($param_descr(TAB_ORDER)) $param_id
    }
  }

  #Offenbar ist die Reihenfolge der Tab-Order-Werte nicht stetig, sodass hier auf lsort zurückgegriffen
  #werden muss. Bei der HM-RC-3 gab es die Reihenfolge 0 1 2 4 -- die 3 fehlt! Wenn man nicht davon ausgehen
  #kann dass alle Indizes vorhanden sind, kann man auch nicht mit der (performanteren) Funktion for arbeiten.
  set sorted_params {}

  foreach tab_order [lsort -integer [array names order_map]] {
    lappend sorted_params $order_map($tab_order)
  }

  if { [array size ps_descr] != [llength $sorted_params] } then {
    #Wenn etwas schiefgeht, wird nach Parameternamen sortiert:
    set sorted_params [lsort [array names ps_descr]]
  }

  return $sorted_params
}

proc cmd_link_paramset2 {iface address pps_descr pps ps_type {pnr 0}} {

  global iface_url env urlsid sid dev_type wired TYPE_MAP

  #cgi_debug -on

  upvar $pps_descr ps_descr
  upvar $pps       ps

  set url $iface_url($iface)

  #==========
  #Aufruf wird nur gemacht, um channel_type zu bekommen, welcher für den Context aus der stringtable_de nötig ist.
  #Evtl. irgendwann umbauen.
  global iface_url
  set channel_type ""
  set chn ""

  set hmDisEPIdentifier "HM-Dis-EP-WM55"
  set hmDisWM55Identifier "HM-Dis-WM55"

  if { ! [catch { array set ch_descr [xmlrpc $iface_url($iface) getDeviceDescription [list string $address]] } ] } then {
    set channel_type $ch_descr(TYPE)
    catch {set chn $ch_descr(INDEX)}
    set parent_type ""
    catch {set parent_type $ch_descr(PARENT_TYPE)}
  }
  #==========

  set s ""

  append s "<tr style=\"visibility: hidden; display: none;\">"
  append s "<td colspan=\"5\">"
  append s "<input type=\"hidden\" name=\"UI_HINT\"        value=\"0\"              id=\"separate_${pnr}_1\" />"
  append s "<input type=\"hidden\" name=\"UI_DESCRIPTION\" value=\"Expertenprofil\" id=\"separate_${pnr}_2\" />&nbsp;"
  append s "</td>"
  append s "</tr>"

  set j 2
  set i 0

  foreach param_id [sort_by_taborder ps_descr] {
    #Hier braucht nur der UI_HINT geprüft werden. UI_DESCRIPTION und UI_TEMPLATE sind nur in den Easy-Mode-Seiten gespeichert und statisch
    if { $param_id == "UI_HINT" } then {continue}

    array_clear param_descr
    array set param_descr $ps_descr($param_id)
    set default_value $param_descr(DEFAULT)
    set type $param_descr(TYPE)
    #set unit [cgi_quote_html $param_descr(UNIT)]
    set unit ""
    catch {set unit $param_descr(UNIT)}
    set min  $param_descr(MIN)
    set max  $param_descr(MAX)
    set flags $param_descr(FLAGS)
    set operations $param_descr(OPERATIONS)
    set value $min

    if {[info exists unit] == 0} {
     set unit ""
    } else {
      if {($unit == "??C") || ($unit == "Â°C")} {
        set unit "&#176;C"
      }
    }

    # omit internal and invisible parameters
    if { (!($flags & 1)) || ($flags & 2) } then { continue }

    incr j
    set id    "id=\"separate_${pnr}_$j\""
    set idval "separate_${pnr}_$j"

    if { ! ($operations & 3) } then { continue }
    if {    $operations & 1  } then { catch {set value $ps($param_id)} }
    if {    $operations & 2  } then { set access "" } else { set access "disabled=\"disabled\"" }

    append s "<tr>"
    if {$ps_type == "MASTER" && $parent_type == "" } then {
      append s "<td><span class=\"stringtable_value\">${param_id}</span></td>"
    } elseif {$ps_type == "MASTER" || $ps_type == "VALUES"} then {
      # We have to rename the translation of the parameters for the channels >=4 of the HM-Dis-EP-WM55 (Text Zeile x > Text Block x)
      if {($parent_type != $hmDisEPIdentifier) || ($chn < 4)} {
        # original translation
        append s "<td><span class=\"stringtable_value\">$channel_type|${param_id}</span></td>"
      } else {
        # new translation
        append s "<td><span>\${lblTextBlock}</span></td>"
      }
    } else {

      # Nötig, zum übersetzen der Parameter auf der Senderseite (wie PEER_NEEDS_BURST, oder EXPECT_AES)
      if {$ch_descr(DIRECTION) == 1} {
        append s "<td><span class=\"stringtable_value\">$channel_type|${param_id}</span><span>&nbsp;</span></td>"
      } else {
        append s "<td>${param_id}</td>"
      }
    }

    switch $type {
      "BOOL" {
        set checked ""
        if { $value } then { set checked "checked=\"checked\"" }
        append s "<td><input type=\"checkbox\" name=\"$param_id\" $id $access $checked value=\"dummy\" /></td>"
        append s "<td>&nbsp;</td>"
      }
      "STRING" {
        # Prüfen, ob es sich um einen Text-Parameter des Gerätes vom Typ 'HM Wireless Status Display' handelt.
        # In diesem Fall wird dem Texteingabefeld eine fortlaufende Nr. vorangestellt.
        if {$param_id != "TEXTLINE_1" && $param_id != "TEXTLINE_2"} {
          append s "<td><input type=\"text\" name=\"$param_id\" value=\"$value\" $id $access /></td>"
        } else {
          puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/KEY_4Dis.js');</script>"
          set helpText [getStatusDisplayHelp]

          # The parameter numbering of the channels 1 and 2 are the same as from the HM-Dis-WM55
          if {($parent_type != $hmDisEPIdentifier) || ($chn < 4)} {
            if {$param_id == "TEXTLINE_1"} {
              # Fortlaufende Nummerierung der Textblöcke hinzufügen.
              # Berechnung:
              # 1. Parameter = Kanalnummer * 2 - 1
              if {($parent_type != $hmDisEPIdentifier) && ($parent_type != $hmDisWM55Identifier)} {
                append s "<td>[expr $chn * 2 - 1]&nbsp;&nbsp;<input type=\"text\" name=\"$param_id\" maxlength=\"12\" onblur=\"encodeStringStatusDisplay('$idval', true);\" value=\"$value\" $id $access /></td>"
              } else {
                append s "<td>[expr $chn * 2 - 1]&nbsp;&nbsp;<input type=\"text\" name=\"$param_id\" maxlength=\"12\" onblur=\"encodeStringStatusDisplay('$idval', true, '_');\" value=\"$value\" $id $access /></td>"
              }
            } else {
              # 2. Parameter = Kanalnummer * 2
              if {($parent_type != $hmDisEPIdentifier) && ($parent_type != $hmDisWM55Identifier)} {
                append s "<td>[expr $chn * 2]&nbsp;&nbsp;<input type=\"text\" name=\"$param_id\" maxlength=\"12\" onblur=\"encodeStringStatusDisplay('$idval', true);\" value=\"$value\" $id $access /></td>"
              } else {
                append s "<td>[expr $chn * 2]&nbsp;&nbsp;<input type=\"text\" name=\"$param_id\" maxlength=\"12\" onblur=\"encodeStringStatusDisplay('$idval', true, '_');\" value=\"$value\" $id $access /></td>"
              }

              append s "<td><img src=\"/ise/img/help.png\"/ size=\"24\" width=\"24\" onclick=\"MessageBox.show(translateKey('dialogHelpTitle'), '$helpText', '', 450, 375) ;\"></td>"
            }
          } else {
            # Here we set the parameter numbering for the channels 4 - 8 of the HM-Dis-EP-WM55
            if {$param_id == "TEXTLINE_1"} {
              # Fortlaufende Nummerierung der Textblöcke hinzufügen.
              # Berechnung:
              # 1. Parameter = Kanalnummer * 2 - 7
              append s "<td>[expr $chn * 2 - 7]&nbsp;&nbsp;<input type=\"text\" name=\"$param_id\" maxlength=\"12\" onblur=\"encodeStringStatusDisplay('$idval', true, '_');\" value=\"$value\" $id $access /></td>"
            } else {
              # 2. Parameter = Kanalnummer * 2 -6
              append s "<td>[expr $chn * 2 - 6]&nbsp;&nbsp;<input type=\"text\" name=\"$param_id\" maxlength=\"12\" onblur=\"encodeStringStatusDisplay('$idval', true, '_');\" value=\"$value\" $id $access /></td>"
              append s "<td><img src=\"/ise/img/help.png\"/ size=\"24\" width=\"24\" onclick=\"MessageBox.show(translateKey('dialogHelpTitle'), '$helpText', '', 450, 375) ;\"></td>"
            }
          }
        }
        append s "<td>$unit</td>"
      }
      "INTEGER" {
        set input_idval   ${idval}_temp
          
        set factor 1
        
        set value_orig $value
        set value         [format "%i" [expr $value         * $factor]]

        set min_orig $min
        set min           [format "%i" [expr $min           * $factor]]

        set max_orig $max
        set max           [format "%i" [expr $max           * $factor]]

        set default_value_orig $default_value
        set default_value [format "%i" [expr $default_value * $factor]]

        set max_special   $max
        set min_special   $min
        
        append s "<td>"

          set hidden ""

          if { [ info exist param_descr(SPECIAL) ] } then {
        
            #Spezialwerte sind < min und > max!
            foreach _sv $param_descr(SPECIAL) {
              array set sv $_sv
              set max_special [max $max_special $sv(VALUE)]
              set min_special [min $min_special $sv(VALUE)]
            }
            #-----
            
            append s "<select class=\"stringtable_select\" name=\"_$param_id\" size=\"1\" onchange=\""
            append s "  document.getElementById(\'$input_idval\').style.visibility=(this.selectedIndex < [llength $param_descr(SPECIAL)])?\'hidden\':\'visible\';"
            append s "  document.getElementById(\'${input_idval}_unit\').style.visibility=(this.selectedIndex < [llength $param_descr(SPECIAL)])?\'hidden\':\'visible\';"
            append s "  document.getElementById(\'$input_idval\').value=this.options\[this.selectedIndex\].value; "
            append s "  document.getElementById(\'$idval\').value=Math.round(parseFloat(this.options\[this.selectedIndex\].value) / parseFloat($factor));"
            append s "\">"

              set i 0
              foreach _sv $param_descr(SPECIAL) {
                array set sv $_sv
                set sv_value [expr $sv(VALUE) * $factor]

                if {$ps_type == "MASTER" && $parent_type == "" } then {
                    set v "<span class=\"stringtable_value\">${param_id}=$sv(ID)</span>"
                } elseif {$ps_type == "MASTER" || $ps_type == "VALUES"} then {
                    set v "<span class=\"stringtable_value\">$channel_type|${param_id}=$sv(ID)</span>"
                } else {
                    set v $sv(ID)
                }

                if { $sv_value == $value } then {
                  set selected selected=\"selected\"
                } else  {
                  set selected ""
                }
                append s "<option value=\"$sv_value\" $selected class=\"stringtable_value\">$v</option>"
                incr i
                set selected selected=\"selected\"
                set hidden ""
              }  
              if { $value >= $min && $value <= $max } then {
                set selected selected=\"selected\"
                set hidden ""
              } else {
                set selected ""
                set hidden "style=\"visibility:hidden;\""
              }
              if { $default_value < $min || $default_value > $max } then {
                set default_value $min
              }

              # Werteingabe
              append s "<option value=\"$default_value\" $selected>\${optionEnterValue}</option>"


            append s "</select>"
          }

          append s "<input type=\"hidden\" name=\"$param_id\"   value=\"$value_orig\" $id                 $access style=\"visibility:hidden;display:none;\" />"
          append s "<input type=\"text\"   name=\"__$param_id\" value=\"$value\"       id=\"$input_idval\" $access $hidden"
          append s "  onblur=\"ProofAndSetValue('$input_idval', '${idval}', parseInt($min), parseInt($max), parseFloat([expr 1 / $factor]));\" /></td>"
          append s "<td><div id=\"${input_idval}_unit\" $hidden class=\"_stringtable_value\">$unit ($min-$max)</div></td>"
      }
      "FLOAT" {
        set input_idval   ${idval}_temp
          
        set factor 1
        if {$unit == "100\%"} then {
          #0..1 --> 0..100
          set factor 100
          set unit "\%"
        }

        set value_orig $value
        set formatString "%.1f"

        if {$iface == "HmIP-RF"} {
          # SPHM-801
          if {([string first "_LEVEL" $param_id] != -1) || ([string first "_SATURATION" $param_id] != -1)} {
            set formatString "%.3f"
          }

          # SPHM-845
          if {[string first "RAMP_START_STEP" $param_id] != -1} {
            set formatString "%.2f"
          }
        }

        set value         [format $formatString [expr $value         * $factor]]
        
        set min_orig $min
        set min           [format $formatString [expr $min           * $factor]]

        set max_orig $max
        set max           [format $formatString [expr $max           * $factor]]

        set default_value_orig $default_value
        set default_value [format $formatString [expr $default_value * $factor]]

        set max_special   $max
        set min_special   $min
        
        append s "<td>"

          set hidden ""

          if { [ info exist param_descr(SPECIAL) ] } then {
        
            #Spezialwerte sind < min und > max!
            foreach _sv $param_descr(SPECIAL) {
              array set sv $_sv
              set max_special [max $max_special $sv(VALUE)]
              set min_special [min $min_special $sv(VALUE)]
            }
            #-----
            
            append s "<select class=\"stringtable_select\" name=\"_$param_id\" size=\"1\" onchange=\""
            append s "  document.getElementById(\'$input_idval\').style.visibility=(this.selectedIndex < [llength $param_descr(SPECIAL)])?\'hidden\':\'visible\';"
            append s "  document.getElementById(\'${input_idval}_unit\').style.visibility=(this.selectedIndex < [llength $param_descr(SPECIAL)])?\'hidden\':\'visible\';"
            append s "  document.getElementById(\'$input_idval\').value=this.options\[this.selectedIndex\].value; "
            append s "  document.getElementById(\'$idval\').value=parseFloat(this.options\[this.selectedIndex\].value) / parseFloat($factor);"
            append s "\">"
            
              set i 0
              foreach _sv $param_descr(SPECIAL) {
                array set sv $_sv
                set sv_value [expr $sv(VALUE) * $factor]
                                
                                if {$ps_type == "MASTER" && $parent_type == "" } then {
                                    set v "<span class=\"stringtable_value\">${param_id}=$sv(ID)</span>"
                                } elseif {$ps_type == "MASTER" || $ps_type == "VALUES"} then {
                                    set v "<span class=\"stringtable_value\">$channel_type|${param_id}=$sv(ID)</span>"
                                } else {
                                    set v $sv(ID)
                                }
                                
                if { $sv_value == $value } then {
                                    append s "<option value=\"$sv_value\" selected=\"selected\">$v</option>"
                                } else  {
                                    append s "<option value=\"$sv_value\">$v</option>"
                                }
                                
                incr i
              }
              if { $value >= $min && $value <= $max } then {
                set selected selected=\"selected\"
                set hidden ""
              } else {
                set selected ""
                set hidden "style=\"visibility:hidden;\""
              }
              if { $default_value < $min || $default_value > $max } then {
                set default_value $min
              }

              # Werteingabe
              append s "<option name=\"optionFreeValue\" value=\"$default_value\" $selected>Werteingabe</option>"
              append s "<script type=\"text/javascript\">jQuery('\[name=optionFreeValue\]').text(translateKey('optionEnterValue'));</script>"


            append s "</select>"
          }

          append s "<input type=\"hidden\" name=\"$param_id\"   value=\"$value_orig\" $id $access style=\"visibility:hidden;display:none;\" />"
          append s "<input type=\"text\"   name=\"__$param_id\" value=\"$value\"       id=\"$input_idval\" $access $hidden"
          append s "  onblur=\"_iface='$iface'; ProofAndSetValue('$input_idval', '${idval}', [expr $min + 0.001], [expr $max + 0.001], parseFloat([expr 1 / $factor]));\" /></td>"
          append s "<td><div id=\"${input_idval}_unit\" $hidden>$unit ($min-$max)</div></td>"
      }
      "ENUM" {
        append s "<td>"
        set value_list $param_descr(VALUE_LIST)

        if {$ps_type == "MASTER" && $parent_type == "" } then {
          append s "<select class=\"stringtable_select\" name=\"$param_id\" size=\"1\" $id $access>"
        } elseif {$ps_type == "MASTER" || $ps_type == "VALUES"} then {
          append s "<select class=\"stringtable_select\" name=\"$param_id\" size=\"1\" $id $access>"
          if {$wired == "HMW"} then {
            puts "<script type=\"text/javascript\">HMW_WebUIsetChannel('$id', '$channel_type');</script>"
          }
        } else {
          append s "<select name=\"$param_id\" size=\"1\" $id $access>"
        }
          
        set k 0
        foreach v $value_list {

          if {$ps_type == "MASTER" && $parent_type == "" } then {
            set v "<span class=\"stringtable_value\">${param_id}=$v</span>"
          } elseif {$ps_type == "MASTER" || $ps_type == "VALUES"} then {
            set v "<span class=\"stringtable_value\">$channel_type|${param_id}=$v</span>"
          }
          
          if { $k == $value } then {
            append s "<option value=\"$k\" selected=\"selected\">$v</option>"
          } else  {
            append s "<option value=\"$k\">$v</option>"
          }
          incr k
        }
          
        append s "</select>"
        append s "</td>"
        append s "<td>&nbsp;</td>"
      }
      default {
        append s "Unknown type \"$type\"<br />"
      }
    }

    #Einzelklickbutton für Setzen einzelner Werte
    if { $ps_type == "VALUES" } then {
      append s "<td>"
      if { $operations & 2 } then {
        append s "<a href=\"#\" onclick=\"set_value('$idval', '$param_id', '$TYPE_MAP($type)')\"><img title=\"$param_id setzen\" alt=\"$param_id setzen\" class=\"clickIcon\" src=\"img/profile_save.png\" /></a>"
      }
      append s "</td>"
    }

    if { $operations & 8 } {
          append s "<td><div class=\"CLASS21000\" onclick=\"DetermineParameterValue('$iface', '$address', '$ps_type', '$param_id', '${idval}_temp');\" >Automatisch ermitteln</div></td>"
      append s "<td>&nbsp;</td>"
    } else {
      append s "<td>&nbsp;</td>"
      append s "<td>&nbsp;</td>"
    }
  
    append s "</tr>"

    incr i
  }
  
  if {$i > 0} then {
    set TableString "<table class=\"ProfileTbl\">"
    
    append TableString "<thead>"
    append TableString "<tr>"
    append TableString "<td id=\"paramName\"></td>"
    append TableString "<td id=\"paramValue\"></td>"
    append TableString "<td id=\"paramRange\"></td>"
    append TableString "<td>&nbsp;</td>"
    append TableString "<td>&nbsp;</td>"
    append TableString "</tr>"
    append TableString "</thead>"
    
    append TableString "<tbody>"
    append TableString $s
    append TableString "</tbody>"
    append TableString "</table>"
    
    append TableString "<script type=\"text/javascript\">"
    append TableString "st_setStringTableValues();"
    append TableString "jQuery(\"#paramName\").html(translateKey(\"lblParameterName\"));"
    append TableString "jQuery(\"#paramValue\").html(translateKey(\"lblValue\"));"
    append TableString "jQuery(\"#paramRange\").html(translateKey(\"lblRangeOfValue\"));</script>"

    set s $TableString
  } else {
    set s ""
  }

  return $s
}

proc init_Profiles {} {

  global PROFILES_MAP HTML_PARAMS PROFILE_TMP cur_profile
  
  set cur_profile -1

  array set PROFILE_TMP ""

  foreach pnr [array names PROFILES_MAP] {

    #Für HTML-Befehle, die die separaten Einstellungen vornehmen je Profil.
    set HTML_PARAMS(separate_$pnr) ""
    
    #Für Ausgabe, welches Profil aktiv ist:
    set HTML_PARAMS(active_$pnr)   ""
  }
}

proc ConvTime {value} {

# value ist ein Wert in Form von zb. 90.000000, was 90 Sekunden entspricht
# dieser Wert ist in Std., Min. u. Sekunden zu konvertieren
  global unit_hour 
  global unit_min 
  global unit_sec 
  
  set hour [expr int($value) / 3600]
  set min [expr (int($value) % 3600) / 60]
  set sec [expr (int($value) % 3600) % 60]
  set msec [expr [format "%.1f" $value] - int($value)]

  if {$hour > 0} {
    set time "$hour$unit_hour"
    if {$min > 0} {append time " $min$unit_min"}
    if {$sec > 0} {append time " $sec$unit_sec"}
  
  } elseif {$min > 0} {
    set time "$min$unit_min"
    if {$sec > 0} {append time " $sec$unit_sec"}
        
  } elseif {$sec > 0 } {
      set time "$sec$unit_sec"
      if {$msec > 0} {set time "[expr $sec + $msec]$unit_sec"}; 

  } elseif {$msec > 0} {
    set time "$msec$unit_sec"  
  
  } else { set time "0$unit_sec"}
  
  return $time
  
  
}

proc ConvFreeValue {param value} {
  set freeValue $value
  set unit ""
  if {[string first "DIM_STEP_COLOR_TEMPERATURE" $param] != -1} {
    set unit "K"
  }
  append freeValue " $unit"
  return $freeValue
}

proc ConvPercent {value} {

  global unit_perc

  set percent "[expr $value * 100]" 
  
  # Nachkommastellen ja/nein ? Wenn nein, x.0% in x% ändern
  
  if {[expr $percent - [expr int($percent)]] > 0} {
    append percent "$unit_perc"
  } else {
    set percent [expr int($percent)] 
    append percent "$unit_perc"
  }
  
  return $percent
}

proc ConvTemp {value} {
  global unit_temp unit_cf
  set temp [expr [format "%.1f" $value]]
  
  # Fahrenheit eingestellt?
  if {$unit_cf} {
    set temp [expr $temp * 9 / 5 + 32]
  }

  # Nachkommastellen ja/nein ? Wenn nein, x.0% in x% ändern
  
  if {[expr $temp - [expr int($temp)]] > 0} {
  } else {
    set temp [expr int($temp)] 
  }
  
  append temp "$unit_temp"
  return $temp
}

proc get_ComboBox2 {val_arr name id selectedvalue {extraparam ""}} {
  upvar $val_arr arr
  set doppelt "false"
  set selectedActive 0

  set selectedvalue [lindex $selectedvalue 0]
  
  foreach option [array names arr ] {
    if {$option == $selectedvalue} {set doppelt "true"} ; # prüfen, ob es den Menüeintrag schon gibt.
  }  

  foreach option [array names arr] {
    # neuer Wert in der Easy-Mode Drop-Down-Liste 
    # switch unbedingt mit der Option -- ausfuehren, da es in den Easymode-Profilen negative Werte gibt,
    # die sonst eine Fehlermeldung verursachen (z. Bsp. Keymatic)
    switch -- $option {
    "99999999"  { if {$doppelt == "false"} {set arr($selectedvalue) [ConvTime $selectedvalue]}} 
    "99999998"  { if {$doppelt == "false"} {set arr($selectedvalue) [ConvPercent $selectedvalue]}}
    "99999997"  { if {$doppelt == "false"} {set arr($selectedvalue) [ConvTemp $selectedvalue]}}  
    "99999990"  { if {$doppelt == "false"} {set arr($selectedvalue) [ConvFreeValue $name $selectedvalue]}}
    }
  }  
  set s "<select class=\"$selectedvalue\" name=\"$name\" id=\"$id\" $extraparam [expr {[array size arr]<=1?"disabled=\"disabled\" ":" "} ]>"
  foreach value [lsort -real [array names arr]] {
    if { ([expr $value == [lindex $selectedvalue 0]]) && ($selectedActive == 0) } then {
      append s "<option value=\"$value\" selected=\"selected\">$arr($value)</option>"
      set selectedActive 1
    } else {
      append s "<option value=\"$value\">$arr($value)</option>"
    }
  }

  append s "</select>"
  return $s
}

proc get_ComboBox {val_arr name id ps_arr pname {extraparam ""}} {

  upvar $ps_arr ps
    upvar $val_arr arr
  return [get_ComboBox2 arr $name $id $ps($pname) $extraparam]
}

proc get_ComboBox2_MD {val_arr name id selectedvalue {extraparam ""}} {
#1
  upvar $val_arr arr
  set doppelt "false"
  upvar ps ps
  if {$ps(SHORT_OFFDELAY_TIME) > 0} {
    set selectedvalue [expr $ps(SHORT_ON_TIME) + $ps(SHORT_OFFDELAY_TIME)]
  } else {
    set selectedvalue [lindex $selectedvalue 0]
  }

#2
  foreach option [array names arr ] {
    if {$option == $selectedvalue} {set doppelt "true"} ;  
  }  

#3 
  foreach option [array names arr] {
    switch -- $option {
    "99999999"  { if {$doppelt == "false"} {set arr($selectedvalue) [ConvTime $selectedvalue]}} 
    }
  }  
  set s "<select class=\"$selectedvalue\" name=\"$name\" id=\"$id\" $extraparam [expr {[array size arr]<=1?"disabled=\"disabled\" ":" "} ]>"
  foreach value [lsort -real [array names arr]] {
    if { [expr $value == [lindex $selectedvalue 0]] } then {
      append s "<option value=\"$value\" selected=\"selected\">$arr($value)</option>"
    } else {
      append s "<option value=\"$value\">$arr($value)</option>"
    }
  }

  append s "</select>"
  return $s
}

proc get_ComboBox_MD {val_arr name id ps_arr pname {extraparam ""}} {
#1
  upvar $ps_arr ps
    upvar $val_arr arr
  return [get_ComboBox2_MD arr $name $id $ps($pname) $extraparam]
}

proc get_Pulse2 {val_arr id selectedvalue dev_address arr_pulse {extraparam ""}} {
  upvar $val_arr arr
  upvar $arr_pulse pulse
  global iface_url iface   
  set url $iface_url($iface)

  set default "0.496"
#1
  array set ch_param [xmlrpc $url getParamset $dev_address "MASTER"]
  
  for {set loop 1} {$loop <= 5} {incr loop} {
    set  pulse($loop) [format {%1.3f} $ch_param(SEQUENCE_PULSE_$loop)]
  }
  set pulse(6) [format {%1.3f} $ch_param(SEQUENCE_TOLERANCE)] 
#2
  set aktiv "false"  
  set exp "false"
  for {set loop 1} {$loop <= 5} {incr loop} {
    if {$pulse($loop) != "0.000"  } {
      set aktiv "true"
      if {$pulse($loop) != $default} {
        set exp "true"
      }
    }
  }
  
  set selectedvalue "99999992"
  
  if {$aktiv == "true"} {
    set selectedvalue "99999996"
  
    if {$pulse(1) == $default && $pulse(6) == $default && $exp == "false"} {
      set selectedvalue "99999993"
      if {$pulse(2) == $default && $pulse(3) == $default} {
        set selectedvalue "99999994"
        if {$pulse(4) == $default && $pulse(5) == $default} {
          set selectedvalue "99999995"  
        }    
      }
    } 
  }

  set s "<select class=\"$selectedvalue\" name=\"Pulse\" id=\"$id\" $extraparam [expr {[array size arr]<=1?"disabled=\"disabled\"":""} ]>"
  
  foreach value [lsort -real [array names arr]] {
    
    if { [expr $value == [lindex $selectedvalue 0]] } then {
      append s "<option value=\"$value\" selected=\"selected\">$arr($value)</option>"
    } else {
      append s "<option value=\"$value\">$arr($value)</option>"
    }
  }
  append s "</select>"
  
  return $s
}

proc get_Pulse {val_arr id ps_arr pname dev_address arr_pulse {extraparam ""}} {
  upvar $ps_arr ps
    upvar $val_arr arr
  upvar arr_pulse pulse
  return [get_Pulse2 arr $id $ps($pname) $dev_address pulse $extraparam]
}

proc get_InputElem {name id ps_arr pname {extraparam ""}} {
  
  upvar $ps_arr ps
  set pname $name 
  set s ""
  # change because of HmIP
  # set value $ps($pname)
  set value [lindex $ps($pname) 0]

  if {[string first "." $value] >= 0} then {
    set value [format "%.1f" $value]
  }

  append s "<input type=\"text\" "
  append s "$extraparam "
  append s "id=\"$id\""
  append s "value=\"$value\" "
  append s "name=\"$name\" />"

  return $s
}

proc isSubsetActive {subset_arr profile_arr} {

    upvar $subset_arr  subset
    upvar $profile_arr profile

  if { [array size subset] == 0 } then { return -1 }

  set subsetactive 1
  
  foreach pname [array names subset] {

    #Parameter mit Namen NAME auslassen:
    if {$pname == "NAME" || $pname == "SUBSET_OPTION_VALUE"} then {continue}

    set subset_pvalue  $subset($pname)
    set profile_pvalue $profile($pname)

    if {[lindex $profile_pvalue 1] == "range"} { 
    
      set min [lindex $profile_pvalue 2]
      set max [lindex $profile_pvalue 4]


      if {! [expr $subset_pvalue >= $min] && ! [expr $subset_pvalue <= $max]} {
    
        set subsetactive 0
        break
      }
      } else {
        foreach value $profile_pvalue { 
          if { ! [expr $subset_pvalue == $value]} {
            set subsetactive 0
            break
          }
        }
      }
  }

  return $subsetactive
}

proc subset2combobox {subsetlist name id ps_arr {extraparam ""}} {
  upvar $subsetlist arr
    upvar $ps_arr ps
  
  set selectedOptionFound 0
  
  set s "<select name=\"$name\" id=\"$id\" $extraparam>"

  foreach a_subset $subsetlist {
    upvar $a_subset SUBSET

    if { [array size SUBSET] == 0 } then {
      global $a_subset
      array set SUBSET [array get $a_subset]
    }

    if { [array size SUBSET] == 0 } then { continue }

    if { $selectedOptionFound == 0 && [isSubsetActive SUBSET ps ] == 1 } then {
      append s "<option value=\"$SUBSET(SUBSET_OPTION_VALUE)\" selected=\"selected\">[cgi_quote_html $SUBSET(NAME)]</option>"
      set selectedOptionFound 1
    } else {
      append s "<option value=\"$SUBSET(SUBSET_OPTION_VALUE)\">[cgi_quote_html $SUBSET(NAME)]</option>"
    }
  }

  append s "</select>"

  return $s
}

proc getLinkCount_incr {p_arr address} {

  upvar $p_arr arr

  if { [catch {incr arr($address)}] } then {
    set arr($address) 1
  }
}

proc getLinkCountByAddress {iface address} {


  global iface_url
  
  set flags 0
  set linkcount -1
    
  catch {
    set linklist [xmlrpc $iface_url($iface) getLinks [list string $address] [list int $flags]]
    set linkcount [llength $linklist]
  }

  return $linkcount
}

proc getLinkCount {p_LINKCOUNT} {


  global iface_url GL_FLAG_SENDER_DESCRIPTION GL_FLAG_RECEIVER_DESCRIPTION

  set flags [expr $GL_FLAG_RECEIVER_DESCRIPTION + $GL_FLAG_SENDER_DESCRIPTION]
  
  upvar $p_LINKCOUNT LINKCOUNT

    foreach iface [array names iface_url] {

    if { [ catch { xmlrpc $iface_url($iface) system.methodHelp getLinks } ] } { continue }
    
      set linklist [xmlrpc $iface_url($iface) getLinks [list string ""] [list int $flags]]

    foreach _link $linklist {

      array set link $_link

      getLinkCount_incr LINKCOUNT $link(SENDER)
      getLinkCount_incr LINKCOUNT $link(RECEIVER)

      catch {
        array set sender_descr $link(SENDER_DESCRIPTION)
        getLinkCount_incr LINKCOUNT $sender_descr(PARENT)
            array_clear sender_descr
      }

      catch {
        array set receiver_descr $link(RECEIVER_DESCRIPTION)
        getLinkCount_incr LINKCOUNT $receiver_descr(PARENT)
            array_clear receiver_descr
      }

          array_clear link
    }

        array_clear linklist
  }
}

# Funkadresse: @001398:1
# @-Zeichen Funkadresse(Hex, 6 Nummern lang) Doppelpunkt Kanalnummer(0-63)
#proc is_rf_address {address} {
  #return [regexp {^@[A-Fa-f0-9]{6}:[0-9]{1,2}$} $address]
#}

# Kanal-Addresse: DEQ1234567:1
# 3 Großbuchstaben, 7 Zahlen, Doppelpunkt, Zahl in Intervall [0,63]
#proc is_channel_address {address} {
  #return [regexp {^[A-Z]{3}[0-9]{7}:[0-9]{1,2}$} $address]
#}

#set paramids [xmlrpc $url getParamsetId $receiver_address LINK] liefert eine Liste der Art { profil1 profil2 profil3 }
#Diese Funktion prüft ob es eine Datei mit Namen profil1.tcl profil2.tcl profil3.tcl gibt und gibt die erste vorhandene
#zurück, oder "" wenn keine vorhanden ist.
proc getExistingParamId {paramids} {

  set paramid ""
  
  if {$paramids != ""} then {
    foreach filename $paramids {

      # This is because nowadays a device type identifier can contain a whitespace - which is quite silly
      set arFilename [split $filename =]
      if {[llength $arFilename] == 2} {
        set filename [lindex $arFilename 1]
      }

      if { [file exists easymodes/$filename.tcl] || [file exists easymodes/hmip/$filename.tcl] } then {
        set paramid $filename
        break
      }
    }
  }

  return $paramid
}

read_interfaces
read_ic_settings
