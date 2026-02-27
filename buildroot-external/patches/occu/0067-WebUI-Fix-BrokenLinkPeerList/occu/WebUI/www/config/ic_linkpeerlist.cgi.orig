#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl
#sourceOnce user.tcl
sourceOnce ic_common.tcl
sourceOnce common.tcl
loadOnce tclrpc.so

#sortby: SENDER | LINK | RECEIVER
#default: LINK
#set sortby "SENDER"
set sortby "LINK"
#set sortby "RECEIVER"

#channel: SN | ""
#"" listet alle Kanäle auf
set channel ""

#wenn channel einen Kanal bezeichnet, der sich in einer Gruppe befindet, werden die
#Kommunikationsbeziehungen für alle Kanäle der Gruppe zurückgegeben (keypair == 1)
set keypair 0

#Interface des übergebenen channels
set ch_iface ""
set hmIPIdentifier "HmIP-RF"
set hmwIdentifier "BidCos-Wired"
set hmIdentifier "BidCos-RF"

proc isHMW {} {
  global iface hmwIdentifier
  if {$iface == $hmwIdentifier} {
    return "true"
  }
  return "false"
}

proc isHM {} {
  global iface hmIdentifier
  if {$iface == $hmIdentifier} {
    return "true"
  }
  return "false"
}

proc isHmIP {} {
  global iface hmIPIdentifier
  if {$iface == $hmIPIdentifier} {
    return "true"
  }
  return "false"
}

proc put_page {} {

  #global HTMLTITLE sidname sid 
  global sidname sid sortby
  #cgi_debug -on
  
  puts "<div id=\"ic_linkpeerlist\" class=\"j_translate\">"
    
    puts "<div id=\"id_body\">"

      puts "<script type=\"text/javascript\">"
      puts "  setPath(\"<span onclick='WebUI.enter(LinksAndPrograms);'>\"+ translateKey('menuProgramsLinksPage') +\"</span> &gt; <span onclick='WebUI.enter(LinkListPage);'>\" + translateKey('submenuDirectLinks') + \"</span>\");"
      puts "  var s = \"\";"
      puts "  s += \"<table cellspacing='8'>\";"
      puts "  s += \"<tr>\";"
      puts "  s += \"<td  style='text-align:center; vertical-align:middle;'><div class='FooterButton' onclick='WebUI.goBack()'>\" + translateKey('footerBtnPageBack') + \"</div></td>\";"
      puts "  s += \"<td  style='text-align:center; vertical-align:middle;'><div class='FooterButton CLASS22100' onclick='loadNewLinkPage();' >\"+ translateKey('footerBtnNewLink') +\"</div></td>\";"
      puts "  s += \"</tr>\";"
      puts "  s += \"</table>\";"
      puts "  setFooter(s);"

      puts "  LINKLISTSORTBY = '$sortby';"
  
      puts "</script>"
  
      puts "<div class=\"subOffsetDivPopup CLASS22101\" >"
      #puts "<div class=\"popupTitle\" id=\"head_wrapper\">"
      puts "<div id=\"global_values\" style=\"display: none; visibility: hidden;\">"
      puts "<form action=\"#\">"
      puts "<input id=\"global_sid\"    type=\"hidden\" name=\"$sidname\" value=\"$sid\"/>"
      puts "</form>"
      #puts "Direkte Verkn&uuml;pfungen"
      puts "</div>"
      #puts "</div>"

      #puts "<div id=\"infobox\" class=\"CLASS22102\" style=\"display:none;\"></div>"

      #Reihenfolge thead -> tfoot -> tbody ist Pflicht, wenn diese Elemente benutzt werden.
      puts "<div id=\"body_wrapper\">"
      puts "<table class=\"LinkListTbl\" cellspacing=\"0\">"
      put_tableheader
      put_tablebody
      puts "</table>"
      puts "</div>"

      #puts "<div class=\"popupControls\" id=\"foot_wrapper\">"
      #put_navibuttons
      #puts "</div>"
      
      #put_picDiv_wz

      #subOffsetDivPopup
      puts "</div>"
      
    #id_body
    puts "</div>"

  #ic_linkpeerlist
  puts "</div>"
  puts "<script type=\"text/javascript\">"
  puts "translatePage(\"#ic_linkpeerlist\");"
  puts "\$('ic_linkpeerlist').style.display = 'contents';"
  puts "</script>"
}

proc _incr {p_arr address peer} {
  upvar sender_broken sb
  upvar receiver_broken rb

  # If address == peer then we have an internal link which we don´t count
  if { ($address != $peer) && ($sb == 0) && ($rb == 0)} {
    upvar $p_arr arr
    if { [catch {incr arr($address)}] } then {
    set arr($address) 1
    }
  }
}

# Checks if the link contains a wired component
proc isWired {senderDescription receiverDescription} {
    
  set senderParentType [lsearch $senderDescription PARENT_TYPE] 
  set receiverParentType [lsearch $receiverDescription PARENT_TYPE] 
  
  set senderType [lindex $senderDescription [expr $senderParentType + 1] ]      
  set receiverType [lindex $receiverDescription [expr $receiverParentType + 1] ]      

  set senderIsHMW [lsearch $senderType HMW-*] 
  set receiverIsHMW [lsearch $receiverType HMW-*] 

  if {($senderIsHMW != -1) && ($receiverIsHMW != -1)} {
    return 1
  }
  return 0 
}

# Introduced with the 'power meter switch actuator'
# Some internal links are visible within the page "Direct device connections"
proc isInExceptionList {senderType receiverType} {

  # Show all internal keys of HmIP and HMW devices
  if {([isHmIP] == "true") || ([isHMW] == "true")} {return 1}


  # Hide all internal keys of BidCos-RF devices except these in the following exceptions list
  array set exceptions {
    CONDITION_POWER SWITCH
    CONDITION_CURRENT SWITCH
    CONDITION_VOLTAGE SWITCH
    CONDITION_FREQUENCY SWITCH
  }

  foreach val [array names exceptions] {
    if {$senderType == $val && $receiverType == $exceptions($val)} {
    #puts "$val : $exceptions($val)<br/>"
    return 1
    }
  }

  return 0
}

proc areMoreLinksAllowed {devType chType} {

  set result 1

  array set notAllowed {
    HmIP-PS KEY_TRANSCEIVER
    HmIP-PSM KEY_TRANSCEIVER
    HmIP-PDT KEY_TRANSCEIVER
    HmIP-PDT-UK KEY_TRANSCEIVER
  }

  foreach val [array names notAllowed] {
    if {[string tolower $val] == [string tolower $devType] && $chType == $notAllowed($val)} {
      set result 0
    }
  }
  return $result
}

proc put_tablebody {} {
  global iface iface_url sortby ch_iface channel keypair GL_FLAG_GROUP GL_FLAG_SENDER_DESCRIPTION GL_FLAG_RECEIVER_DESCRIPTION
  global GL_FLAG_SENDER_BROKEN GL_FLAG_RECEIVER_BROKEN
  global GL_FLAG_SENDER_UNKNOWN GL_FLAG_RECEIVER_UNKNOWN

# cgi_debug -on

  array set ise_CHANNELNAMES ""
  ise_getChannelNames ise_CHANNELNAMES

    set tablestruct ""
    array set SENDER_LINKCOUNTER ""
  array set RECEIVER_LINKCOUNTER ""

  set rowcount 0

  #Erster Schritt: Daten sammeln.
    foreach iface [array names iface_url] {

    if {$ch_iface != "" && $channel != ""} then {
      if {$ch_iface != $iface} then {
        continue
      }
    }

    set url $iface_url($iface)

    #check if the interface supports links. failure of this call will throw us out of here
    if { [ catch { xmlrpc $url system.methodHelp getLinks } ] } { continue }
                                 set flags 0
    if {$keypair == 1         } {set flags [expr $flags + $GL_FLAG_GROUP]}
    #if {$sortby  == "SENDER"  } {set flags [expr $flags + $GL_FLAG_SENDER_DESCRIPTION]}
    #if {$sortby  == "RECEIVER"} {set flags [expr $flags + $GL_FLAG_RECEIVER_DESCRIPTION]}
    set flags [expr $flags + $GL_FLAG_RECEIVER_DESCRIPTION + $GL_FLAG_SENDER_DESCRIPTION]

     array_clear linklist
    if { [set rc [ catch {set linklist [xmlrpc $url getLinks [list string $channel] [list int $flags]]} e ]] } then {
    # Falls es sich um ein unbekanntes Gerät handelt, keine Fehlermeldung ausgeben
      if { $rc != -2 } then {
        if {$rc == -321} {
           puts "<div class=\"CLASS22103\">\${unknownError} '$iface' - Channel: '$channel'. Flags: '$flags' $e</div>"
        } else {
          puts "<div class=\"CLASS22103\">\${interfaceProcessNotReadyA} '$iface' \${interfaceProcessNotReadyB} Channel: '$channel'. Flags: '$flags' $e</div>"
        }
      }
      continue
    }
    foreach _link $linklist {

      cgi_debug -on
      array set link $_link

      if {([info exists link(SENDER)] != 1) && ([info exists link(RECEIVER)] != 1)} {
        continue
      }

      # SPHM-535
      if {$sortby != "LINK"} {
        if {([string index $link(SENDER) 0] == "@")  || ([string index $link(RECEIVER) 0] == "@")} {
          continue
        }
      }

      catch {array set sender_descr   $link(SENDER_DESCRIPTION)}
      catch {array set receiver_descr $link(RECEIVER_DESCRIPTION)}
      array set SENTRY ""

      #FLAGS auslesen=======
      set sender_broken    0
      set sender_unknown   0
      set receiver_broken  0
      set receiver_unknown 0

      if { ! [catch {set flags $link(FLAGS)} ] } then {
        if { [BitsSet $GL_FLAG_SENDER_BROKEN $flags] } then {
          set sender_broken 1
        }
        if { [BitsSet $GL_FLAG_SENDER_UNKNOWN $flags] } then {
          set sender_unknown 1
        }
        if { [BitsSet $GL_FLAG_RECEIVER_BROKEN $flags] } then {
          set receiver_broken 1
        }
        if { [BitsSet $GL_FLAG_RECEIVER_UNKNOWN $flags] } then {
          set receiver_unknown 1
        }
      }

      _incr SENDER_LINKCOUNTER   $link(SENDER) $link(RECEIVER)
      _incr RECEIVER_LINKCOUNTER $link(RECEIVER) $link(SENDER)

      #=====================
      #Verknüpfung mit interner Gerätetaste?
      set isHMW 0
      set internalLink 0
      set hideBtnDelete 0
      set senderParent [lindex [split $link(SENDER) ":"] 0]
      set receiverParent [lindex [split $link(RECEIVER) ":"] 0]

      # Sind Sender u. Receiver identisch? Dann handelt es sich um einen internen Link, z. B. die interne Gerätetaste
      # Diese soll bei BidCos-RF nicht in der Verknüpfungsübersichtsliste angezeigt werden, Ausnahmen werden mittels isInExceptionList erlaubt.
      # Interne Links von HmIP-Geräten werden immer angezeigt, da sie anders als bei HM nur hier editiert werden können (nicht als Kanalparameter).
      # Interne Links bestimmter Geräte dürfen nicht löschbar sein, da sie aufgrund der Firmware nur per Werksreset wieder restauriert werden können,
      #   oder bei der Erstellung von Verknüpfungen nicht als Linkpartner angeboten werden, da sie nur eine Verknüpfung zulassen.
      # Interne Links anderer HmIP-Geräte können gelöscht werden. Vor dem Löschen erscheint aber ein entsprechender Warnhinweis.
      # Nach dem Löschen können diese Verknüpfungen aber problemlos wieder hergestellt werden.

      if {$senderParent == $receiverParent} {

        # Hide the delete button of all HmIP-Devices of the type PS and PSM.
        # When an internal link for a device of the type PS / PSM is deleted it can only be restored by a factory reset of the device.
        # This is because of a firmware error. Therefore we prevent the deleting of this links by hiding the delete button.

        catch {
          set devType $sender_descr(PARENT_TYPE)
          if { ([isHmIP] == "true") &&
            ($devType == "HMIP-PS")
            || ([string equal -nocase -length 8 $devType "HMIP-PSM"] == 1)
            || ([string equal -nocase -length 8 $devType "HMIP-PDT"] == 1)
            || ([string equal -nocase -length 9 $devType "HMIP-PCBS"] == 1)
            || (![isInExceptionList $sender_descr(TYPE) $receiver_descr(TYPE)]) } {
            set hideBtnDelete 1
          }
        }
        catch {
          if {([string index $senderParent 0] != "@")  && ([string index $receiverParent 0] != "@") && ![isInExceptionList $sender_descr(TYPE) $receiver_descr(TYPE)]} {
            set internalLink 1
            set hideBtnDelete 1
          }
        }
      }

      catch {set isHMW [isWired $link(SENDER_DESCRIPTION) $link(RECEIVER_DESCRIPTION)]}

      if {(($internalLink == 0) || ($isHMW == 1)) } {
        #Bilder=====
        set sender_parent_type "unknown_device"
        set receiver_parent_type "unknown_device"
        set sender_type ""
        set sender_index 0
        set receiver_index 0
        set receiver_type ""
        catch { set sender_parent_type $sender_descr(PARENT_TYPE) }
        catch { set sender_type $sender_descr(TYPE) }
        catch { set sender_index $sender_descr(INDEX) }
        catch { set receiver_parent_type $receiver_descr(PARENT_TYPE) }
        catch { set receiver_index $receiver_descr(INDEX) }
        catch { set receiver_type $receiver_descr(TYPE) }
        set SENTRY(SENDER_PARENT_TYPE) $sender_parent_type
        set SENTRY(SENDER_TYPE) $sender_type
        set SENTRY(RECEIVER_PARENT_TYPE) $receiver_parent_type

        set SENTRY(SENDER_IMAGE) "<div id=\"picDiv_sender_$rowcount\" class=\"CLASS22104\" onmouseover=\"picDivShow(jg_250, '$sender_parent_type', 250, '$sender_index', this);\" onmouseout=\"picDivHide(jg_250);\"></div>"
        append SENTRY(SENDER_IMAGE) "<script type=\"text/javascript\">"
        append SENTRY(SENDER_IMAGE) "var jg_sender_$rowcount = new jsGraphics(\"picDiv_sender_$rowcount\");"
        append SENTRY(SENDER_IMAGE) "InitGD(jg_sender_$rowcount, 50);"
        append SENTRY(SENDER_IMAGE) "Draw(jg_sender_$rowcount, '$sender_parent_type', 50, $sender_index);"
        append SENTRY(SENDER_IMAGE) "</script>"

        set SENTRY(RECEIVER_IMAGE) "<div id=\"picDiv_receiver_$rowcount\" class=\"CLASS22105\" onmouseover=\"picDivShow(jg_250, '$receiver_parent_type', 250, '$receiver_index', this);\" onmouseout=\"picDivHide(jg_250);\"></div>"
        append SENTRY(RECEIVER_IMAGE) "<script type=\"text/javascript\">"
        append SENTRY(RECEIVER_IMAGE) "var jg_receiver_$rowcount = new jsGraphics(\"picDiv_receiver_$rowcount\");"
        append SENTRY(RECEIVER_IMAGE) "InitGD(jg_receiver_$rowcount, 50);"
        append SENTRY(RECEIVER_IMAGE) "Draw(jg_receiver_$rowcount, '$receiver_parent_type', 50, $receiver_index);"
        append SENTRY(RECEIVER_IMAGE) "</script>"
        #===========

        #Direction (Sender|Receiver) für Buttons "Sender hinzufügen" und "Empfänger hinzufügen"
        set SENTRY(SENDERDIRECTION)   0
        set SENTRY(RECEIVERDIRECTION) 0
        catch { set SENTRY(SENDERDIRECTION)   $sender_descr(DIRECTION)   }
        catch { set SENTRY(RECEIVERDIRECTION) $receiver_descr(DIRECTION) }
        if {$sender_unknown == 1} then {
          set SENTRY(SENDERNAME_DISPLAY) "<span onmouseover=\"picDivShow(jg_250, '$sender_parent_type', 250, '$sender_index', this);\" onmouseout=\"picDivHide(jg_250);\">Unbekanntes Ger&auml;t</span>"
        } else {
          if { [catch { set SENTRY(SENDERNAME_DISPLAY) "<span onmouseover=\"picDivShow(jg_250, '$sender_parent_type', 250, '$sender_index', this);\" onmouseout=\"picDivHide(jg_250);\">[cgi_quote_html $ise_CHANNELNAMES($iface;$link(SENDER))]&nbsp;</span>" } ] } then {
            set SENTRY(SENDERNAME_DISPLAY) "<span onmouseover=\"picDivShow(jg_250, '$sender_parent_type', 250, '$sender_index', this);\" onmouseout=\"picDivHide(jg_250);\">Unbenanntes Ger&auml;t</span>"
          }
        }
        if { [catch { set SENTRY(SENDERNAME) $ise_CHANNELNAMES($iface;$link(SENDER))} ] } then {
            set SENTRY(SENDERNAME) "$iface"
            append SENTRY(SENDERNAME) ".$link(SENDER)"
        }

        set SENTRY(SENDERADDR) $link(SENDER)
        set SENTRY(IFACE) $iface

        if { $sender_unknown == 1 } then {
            set SENTRY(SENDERADDR_DISPLAY) "&nbsp;"
        } else {
            set SENTRY(SENDERADDR_DISPLAY) $link(SENDER)
        }

        set SENTRY(LINKNAME) "[cgi_quote_html $link(NAME)]&nbsp;"

        if {$sender_broken == 1 || $receiver_broken == 1} then {
              append SENTRY(LINKNAME) " <img src=\"/ise/img/dialog-error.png\" alt=\"Verkn&uuml;pfung defekt\" title=\"Verkn&uuml;pfung defekt\"/>"
        }
        set SENTRY(LINKDESC) "[cgi_quote_html $link(DESCRIPTION)]&nbsp;"

        # It's not allowed to delete internal links
        if {$hideBtnDelete == 0} {
          set SENTRY(ACTION) "<div class=\"CLASS21000\" onclick=\"RemoveLink('$iface', '$link(SENDER)', '$link(RECEIVER)', '$sender_parent_type');\" >\${btnRemove}</div>"
        }

        if { $receiver_unknown==0 && $sender_unknown==0 && $sender_broken==0 && $receiver_broken==0} then {
#       append SENTRY(ACTION) "<div class=\"CLASS21000\" onclick=\"OpenSetProfiles('$iface', '$link(SENDER)', '$link(RECEIVER)');\">${btnEdit}</div>"
        append SENTRY(ACTION) "<div class=\"CLASS21000\" onclick=\"WebUI.enter(LinkEditProfilePage, {iface: '$iface', sender: '$link(SENDER)', receiver: '$link(RECEIVER)'});\">\${btnEdit}</div>"
        }

        if {$receiver_unknown == 1} then {
          set SENTRY(RECEIVERNAME_DISPLAY) "<span onmouseover=\"picDivShow(jg_250, '$receiver_parent_type', 250, '$receiver_index', this);\" onmouseout=\"picDivHide(jg_250);\">\${unknownDevice}</span>"
        } else {
          if { [catch { set SENTRY(RECEIVERNAME_DISPLAY) "<span onmouseover=\"picDivShow(jg_250, '$receiver_parent_type', 250, '$receiver_index', this);\" onmouseout=\"picDivHide(jg_250);\">[cgi_quote_html $ise_CHANNELNAMES($iface;$link(RECEIVER))]&nbsp;</span>" } ] } then {
            set SENTRY(RECEIVERNAME_DISPLAY)  "<span onmouseover=\"picDivShow(jg_250, '$receiver_parent_type', 250, '$receiver_index', this);\" onmouseout=\"picDivHide(jg_250);\">\${unknownDevice}</span>"
          }
        }
        if { [catch { set SENTRY(RECEIVERNAME) $ise_CHANNELNAMES($iface;$link(RECEIVER))} ] } then {
          set SENTRY(RECEIVERNAME) "$iface"
          append SENTRY(RECEIVERNAME) ".$link(RECEIVER)"
        }

        set SENTRY(RECEIVERADDR) $link(RECEIVER)

        if { $receiver_unknown == 1 } then {
            set SENTRY(RECEIVERADDR_DISPLAY) "&nbsp;"
        } else {
          set SENTRY(RECEIVERADDR_DISPLAY) $link(RECEIVER)
        }

        lappend tablestruct [array get SENTRY]

        array_clear sender_descr
        array_clear receiver_descr
        array_clear SENTRY
        array_clear link

        incr rowcount
      }
    }
  }

  puts "<TBODY>"
  #Zweiter Schritt: Daten in HTML setzen
  if {[llength $tablestruct] == 0} then {
    puts "<TR>"
    #puts "<TD height=\"100\"  style=\"text-align:center;\" COLSPAN=\"7\">Es sind keine Verkn&uuml;pfungen vorhanden.</TD>"
    puts "<TD height=\"100\"  style=\"text-align:center;\" COLSPAN=\"7\">\${lblNoLinksAvailable}</TD>"
    puts "</TR>"
  } else {
    if {$sortby == "LINK"} then {

      set tablestruct [lsort -command my_sort $tablestruct]
      set loop 0
      foreach tr $tablestruct {

        array set SENTRY $tr
        set internalKeyCSS ""

        if {[string first "NO_DESCRIPTION" $SENTRY(LINKDESC)] == 0} {
          set senderParentAdr [lindex [split $SENTRY(SENDERADDR) ":"] 0]
          set receiverParentAdr [lindex [split $SENTRY(RECEIVERADDR) ":"] 0]

          if {[string equal $senderParentAdr $receiverParentAdr] == 1} {
            if {[isHmIP] == "true"} {
               set internalKeyCSS "style='background-color:#E0E0E0'"
               set SENTRY(LINKDESC) "\${lblLinkInternalDescInternalKey}<br/>"
               append SENTRY(LINKDESC) $SENTRY(SENDERNAME_DISPLAY)
            }
          }

        } elseif {[string first "" $SENTRY(LINKDESC)] == 0} {
          set SENTRY(LINKDESC) "\${lblLinkNoDescriptionAvailable}<br/>"
        }

        puts "<tr>"
        puts "<td class=\"CLASS22106\">$SENTRY(SENDERNAME_DISPLAY)<br/><br/><span id=\"senderNameExtension_$loop\"></span></td>"
        puts "<td class=\"CLASS22106\">$SENTRY(SENDERADDR_DISPLAY)</td>"
        puts "<td>$SENTRY(LINKNAME)</td>"
        puts "<td $internalKeyCSS>$SENTRY(LINKDESC)</td>"
        puts "<td class=\"CLASS22106\">$SENTRY(ACTION)</td>"
        puts "<td class=\"CLASS22106\">$SENTRY(RECEIVERNAME_DISPLAY)<br/><br/><span id=\"receiverNameExtension_$loop\"></span></td>"
        puts "<td class=\"CLASS22106\">$SENTRY(RECEIVERADDR_DISPLAY)</td>"
        puts "</tr>"

        set senderAddress $SENTRY(SENDERADDR)
        set receiverAddress $SENTRY(RECEIVERADDR)
        set senderCh [lindex [split $SENTRY(SENDERADDR) ":"] 1]
        set receiverCh [lindex [split $SENTRY(RECEIVERADDR) ":"] 1]
        set _sender_parent_type $SENTRY(SENDER_PARENT_TYPE)
        set _sender_type $SENTRY(SENDER_TYPE)
        set _receiver_parent_type $SENTRY(RECEIVER_PARENT_TYPE)

        puts "<script type=\"text/javascript\>"
          if {! [string equal $_sender_type "MULTI_MODE_INPUT_TRANSMITTER"]} {
            puts "jQuery(\"#senderNameExtension_$loop\").html(getExtendedDescription(\{ 'deviceType' : '$_sender_parent_type','channelAddress' : '$senderAddress' ,'channelIndex' : '$senderCh' \}));"
          } else {
            puts "var channel = DeviceList.getChannelByAddress(\"$senderAddress\");"
            puts "if (channel) {"
              puts "homematic(\"Interface.getMetadata\", {\"objectId\" : channel.id, \"dataId\" : \"channelMode\"}, function(result) {"
                puts "if (result == \"null\") {result = 1;}"
                puts "jQuery(\"#senderNameExtension_$loop\").html(translateKey(\"chType_MULTI_MODE_INPUT_TRANSMITTER_\"+result));"
              puts "});"
            puts "}"
          }

          puts "jQuery(\"#receiverNameExtension_$loop\").html(getExtendedDescription(\{ 'deviceType' : '$_receiver_parent_type','channelAddress' : '$receiverAddress' ,'channelIndex' : '$receiverCh' \}));"


        puts "</script>"

        incr loop
        array_clear SENTRY
      }
    } elseif {$sortby == "SENDER"} then {

      set tablestruct [lsort -command my_sort $tablestruct]
      set prev_sender ""
      set this_sender ""

      foreach tr $tablestruct {
        array set SENTRY $tr
        set internalKeyCSS ""
        set this_sender $SENTRY(SENDERNAME)

        puts "<tr>"

        #Zellen zusammenfassen -
        if {$this_sender != $prev_sender} then {

          puts "<td class=\"LinkListTbl_img\" rowspan=\"$SENDER_LINKCOUNTER($SENTRY(SENDERADDR))\"><div class=\"CLASS22106\">$SENTRY(SENDERNAME_DISPLAY)</div>$SENTRY(SENDER_IMAGE)</td>"
          puts "<td rowspan=\"$SENDER_LINKCOUNTER($SENTRY(SENDERADDR))\" class=\"CLASS22106\">$SENTRY(SENDERADDR_DISPLAY)"

           # Under certain circumstances hide the button for adding more link partners (e. g. PS/PSM/PDT aren't allowed)
           if {([lindex [split $SENTRY(SENDERADDR) ":"] 0] != [lindex [split $SENTRY(RECEIVERADDR) ":"] 0]) || ([areMoreLinksAllowed $SENTRY(SENDER_PARENT_TYPE) $SENTRY(SENDER_TYPE)] == 1)} {
            if { $sender_unknown==0 } then {
              puts "<hr width=\"75%\" />"
              puts "<div class=\"CLASS21000\" onclick=\"Select2ndLinkPartner('$SENTRY(IFACE)', '$SENTRY(SENDERADDR)', $SENTRY(SENDERDIRECTION));\">\${btnAddReceiver}</div>"
            }
          }
          puts "</td>"
        }

       if {[string first "NO_DESCRIPTION" $SENTRY(LINKDESC)] == 0} {
          set senderParentAdr [lindex [split $SENTRY(SENDERADDR) ":"] 0]
          set receiverParentAdr [lindex [split $SENTRY(RECEIVERADDR) ":"] 0]

         if {[string equal $senderParentAdr $receiverParentAdr] == 1} {
            if {[isHmIP] == "true"} {
               set internalKeyCSS "style='background-color:#E0E0E0'"
               set SENTRY(LINKDESC) "\${lblLinkInternalDescInternalKey}<br/>"
               append SENTRY(LINKDESC) $SENTRY(SENDERNAME_DISPLAY)
            }
          }

        } elseif {[string first "" $SENTRY(LINKDESC)] == 0} {
          set SENTRY(LINKDESC) "\${lblLinkNoDescriptionAvailable}<br/>"
        }

        puts "<td>$SENTRY(LINKNAME)</td>"
        puts "<td $internalKeyCSS>$SENTRY(LINKDESC)</td>"
        puts "<td style=\"text-align:center;\">$SENTRY(ACTION)</td>"
        puts "<td>$SENTRY(RECEIVERNAME_DISPLAY)</td>"
        puts "<td>$SENTRY(RECEIVERADDR_DISPLAY)</td>"
        puts "</tr>"

        set prev_sender $this_sender
            array_clear SENTRY
      }

    } elseif {$sortby == "RECEIVER"} then {
      
      cgi_debug -on
      set tablestruct [lsort -command my_sort $tablestruct]
      set prev_receiver ""
      set this_receiver ""

      foreach tr $tablestruct {
      
        array set SENTRY $tr
        set internalKeyCSS ""

        set this_receiver $SENTRY(RECEIVERNAME)
        
        set rowSpan $RECEIVER_LINKCOUNTER($SENTRY(RECEIVERADDR))

       if {[string first "NO_DESCRIPTION" $SENTRY(LINKDESC)] == 0} {
          set senderParentAdr [lindex [split $SENTRY(SENDERADDR) ":"] 0]
          set receiverParentAdr [lindex [split $SENTRY(RECEIVERADDR) ":"] 0]

          if {[string equal $senderParentAdr $receiverParentAdr] == 1} {
            if {[isHmIP] == "true"} {
               set internalKeyCSS "style='background-color:#E0E0E0'"
               set SENTRY(LINKDESC) "\${lblLinkInternalDescInternalKey}<br/>"
               append SENTRY(LINKDESC) $SENTRY(SENDERNAME_DISPLAY)
            }
          }

        } elseif {[string first "" $SENTRY(LINKDESC)] == 0} {
          set SENTRY(LINKDESC) "\${lblLinkNoDescriptionAvailable}<br/>"
        }

        puts "<tr>"
        puts "<td>$SENTRY(SENDERNAME_DISPLAY)</td>"
        puts "<td>$SENTRY(SENDERADDR_DISPLAY)</td>"
        puts "<td>$SENTRY(LINKNAME)</td>"
        puts "<td $internalKeyCSS>$SENTRY(LINKDESC)</td>"
        puts "<td style=\"text-align:center;\">$SENTRY(ACTION)</td>"

        #Zellen zusammenfassen
        if {$this_receiver != $prev_receiver} then {
          puts "<td class=\"LinkListTbl_img\" rowspan=\"$rowSpan\"><div class=\"CLASS22106\">$SENTRY(RECEIVERNAME_DISPLAY)</div>$SENTRY(RECEIVER_IMAGE)</td>"
          puts "<td rowspan=\"$rowSpan\" class=\"CLASS22106\">$SENTRY(RECEIVERADDR_DISPLAY)"
          
          if { $receiver_unknown == 0 } then {
            puts "<hr width=\"75%\" />"
            puts "<div class=\"CLASS21000\" onclick=\"Select2ndLinkPartner('$SENTRY(IFACE)', '$SENTRY(RECEIVERADDR)', $SENTRY(RECEIVERDIRECTION));\">\${btnAddSender}</div>"
          }
          puts "</td>"
        }

        puts "</tr>"
        
        set prev_receiver $this_receiver
            array_clear SENTRY
      }
    }
  }
  puts "</TBODY>"
}

proc my_sort {a b} {

  global sortby

  array set aa $a
  array set bb $b

  if {$sortby == "SENDER"} then {
    set key SENDERNAME
  } elseif {$sortby == "LINK"} then {
    set key LINKNAME
  } elseif {$sortby == "RECEIVER"} then {
    set key RECEIVERNAME
  } else {
    set key LINKNAME
  }
  
  return [string compare $aa($key) $bb($key)]
}

proc put_tableheader {} {
  global sortby

  #cgi_debug -on

  puts "<colgroup>"
  puts "<col />"
  puts "<col />"
  puts "<col />"
  puts "<col />"
  puts "<col style='width:100px;'>"
  puts "<col />"
  puts "<col />"
  puts "</colgroup>"
  puts "<THEAD>"
  puts "<TR>"


  puts "<TH COLSPAN=\"2\" align=\"center\" onclick=\"WebUI.enter(LinkListPage, {'LINKLISTSORTBY':'SENDER'});\"  [expr {$sortby=="SENDER"?"class=\"header_active\"":""} ]>\${thSender}</TH>"
  puts "<TH COLSPAN=\"3\" align=\"center\" onclick=\"WebUI.enter(LinkListPage, {'LINKLISTSORTBY':'LINK'});\"    [expr {$sortby=="LINK"?"class=\"header_active\"":""} ]>\${thLink}</TH>"
  puts "<TH COLSPAN=\"2\" align=\"center\" onclick=\"WebUI.enter(LinkListPage, {'LINKLISTSORTBY':'RECEIVER'});\" [expr {$sortby=="RECEIVER"?"class=\"header_active\"":""} ]>\${thReceiver}</TH>"
  puts "</TR>"

  puts "<TR>"
  puts "<TD  style=\"text-align:center;\" [expr {$sortby=="SENDER"?"class=\"header_active\"":""} ] >\${thName}</TD>"
  puts "<TD  style=\"text-align:center;\">\${thSerialNumber}</TD>"
  puts "<TD  style=\"text-align:center;\" [expr {$sortby=="LINK"?"class=\"header_active\"":""} ]>\${thName}</TD>"
  puts "<TD  style=\"text-align:center;\">\${thDescription}</TD>"
  puts "<TD  style=\"text-align:center;\">\${thAction}</TD>"
  puts "<TD  style=\"text-align:center;\" [expr {$sortby=="RECEIVER"?"class=\"header_active\"":""} ]>\${thName}</TD>"
  puts "<TD  style=\"text-align:center;\">\${thSerialNumber}</TD>"
  puts "</TR>"
  puts "</THEAD>"
}

proc put_navibuttons {} {

  global urlsid

  #cgi_debug -on
  
  puts "<table>"
  puts "<tbody>"
  puts "<tr>"
  
  puts "<td class=\"ActiveButton CLASS22107\" onclick=\"WebUI.goBack();\"><div class=\"CLASS22109\">\${footerBtnPageBack}</div></td>"
  puts "<td class=\"ActiveButton CLASS22107\" onclick=\"loadNewLinkPage();\"><div>\${footerBtnNewLink}</div></TD>"
  puts "<td class=\"CLASS22108\">&nbsp;</td>"
  
  puts "</tr>"
  puts "</tbody>"
  puts "</table>"
}

cgi_eval {

  #cgi_debug -on

  cgi_input

    http_head
    
  if {[session_requestisvalid 0] > 0} then {
  
    catch {import_as LINKLISTSORTBY sortby}
    catch {import keypair}
    catch {import channel}
    catch {import_as iface ch_iface}
      
    put_page
  }
}
