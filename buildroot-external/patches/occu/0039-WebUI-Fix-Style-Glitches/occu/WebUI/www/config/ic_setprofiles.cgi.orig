#!/bin/tclsh

source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce ic_common.tcl
sourceOnce common.tcl
loadOnce tclrpc.so

#ISE-Daten
array set ise_CHANNELNAMES ""
ise_getChannelNames ise_CHANNELNAMES

proc isHmIP {} {
  global iface
  set hmIPIdentifier "HmIP-RF"
  set hmIPWiredIdentifier "HmIP-Wired"
  if {($iface == $hmIPIdentifier) || ($iface == $hmIPWiredIdentifier)} {
    return "true"
  }
  return "false"
}

proc put_receiver_address_not_found {} {

  global receiver_address

  puts "<div id=\"ic_setprofiles\">"
    puts "<div id=\"id_body\">"
      puts "<script type=\"text/javascript\">"
      puts "  setPath(\"<span onclick='WebUI.enter(LinksAndProgramsPage);'>\${menuProgramsLinksPage}</span> &gt; <span onclick='WebUI.enter(LinkListPage);'>\${submenuDirectLinks}</span> &gt; \${profileSettings}\");"

      puts "  var s = \"\";"
      puts "  s += \"<table cellspacing='8'>\";"
      puts "  s += \"<tr>\";"
      puts "  s += \"<td style='text-align:center; vertical-align:middle;'><div class='FooterButton' onclick='WebUI.enter(LinkListPage);'>\${footerBtnCancel}</div></td>\";"
      puts "  s += \"</tr>\";"
      puts "  s += \"</table>\";"
      puts "  setFooter(s);"
      
      puts "</script>"

      puts "Der Empf&auml;nger $receiver_address wurde nicht gefunden!"
    puts "</div>"
  puts "</div>"
}

proc put_sender_address_not_found {} {

  global sender_address

  puts "<div id=\"ic_setprofiles\">"
    puts "<div id=\"id_body\">"
      puts "<script type=\"text/javascript\">"
      puts "  setPath(\"<span onclick='WebUI.enter(LinksAndProgramsPage);'>\${menuProgramsLinksPage}</span> &gt; <span onclick='WebUI.enter(LinkListPage);'>\${submenuDirectLinks}</span> &gt; \${profileSettings}\");"
      puts "  var s = \"\";"
      puts "  s += \"<table cellspacing='8'>\";"
      puts "  s += \"<tr>\";"
      puts "  s += \"<td style='text-align:center; vertical-align:middle;'><div class='FooterButton' onclick='WebUI.enter(LinkListPage);'>\${footerBtnCancel}</div></td>\";"
      puts "  s += \"</tr>\";"
      puts "  s += \"</table>\";"
      puts "  setFooter(s);"
      
      puts "</script>"

      puts "Der Sender $sender_address wurde nicht gefunden!"
    puts "</div>"
  puts "</div>"
}
        
proc put_page {} {

  #global HTMLTITLE sidname sid
  global iface sender_address sender_group receiver_group
  #cgi_debug -on

  puts "<div id=\"ic_setprofiles\">"
  
    puts "<div id=\"id_body\">"
    
      puts "<script type=\"text/javascript\">"
      #puts "  setPath(\"<span onclick='WebUI.enter(LinksAndProgramsPage);'>\${menuProgramsLinksPage}</span> &gt; <span onclick='WebUI.enter(LinkListPage);'>\${submenuDirectLinks}</span> &gt; \${profileSettings}\");"
      puts "  setPath(\"<span onclick='WebUI.enter(LinksAndProgramsPage);'>\"+translateKey(\"menuProgramsLinksPage\")+\"</span> &gt; <span onclick='WebUI.enter(LinkListPage);'>\"+translateKey(\"submenuDirectLinks\")+\"</span> &gt; \"+translateKey(\"profileSettings\"));"

      puts "  var s = \"\";"
      puts "  s += \"<table cellspacing='8'>\";"
      puts "  s += \"<tr>\";"
      puts "  s += \"<td style='text-align:center; vertical-align:middle;'><div class='FooterButton' onclick='RevertProfileSettings(); WebUI.enter(LinkListPage);'>\${footerBtnCancel}</div></td>\";"
      puts "  s += \"<td id='footerButtonTake' style='text-align:center; vertical-align:middle;'><div class='FooterButton' onclick='CollectData_SaveProfileSettings(1);'>\${footerBtnTransfer}</div></td>\";"
      puts "  s += \"<td id='footerButtonOK' style='text-align:center; vertical-align:middle;'><div class='FooterButton' onclick='CollectData_SaveProfileSettings(0);'>\${footerBtnOk}</div></td>\";"
      puts "  s += \"</tr>\";"
      puts "  s += \"</table>\";"
      puts "  setFooter(s);"
    
    #translate descriptions
    puts "  var senderLinkdescription = jQuery('#sender_linkdescription').val();"
    puts "  if(senderLinkdescription != undefined) {"
    puts "    jQuery('#sender_linkdescription').val(translateString(senderLinkdescription));"
    puts "  }"
    puts "  var sendergroupLinkdescription  = jQuery('#sendergroup_linkdescription').val();"
    puts "  if(sendergroupLinkdescription  != undefined) {"
    puts "    jQuery('#sendergroup_linkdescription').val(translateString(sendergroupLinkdescription ));"
    puts "  }"
    
      puts "</script>"

    # puts "<div class=\"subOffsetDivPopup\" style=\"padding:4px;\">"
      puts "<div class=\"subOffsetDivPopup CLASS20001\">"

      puts "<div id=\"global_values\" style=\"display: none; visibility: hidden;\">"
      put_hidden_values
      puts "</div>"
      puts "<div id=\"body_wrapper\" style=\"display:none\" >"
      
      puts "<div id=\"id_sender_receiver_profiles_wrapper\">"
      put_profile_head "SENDER"
      put_profile_body "SENDER"
      puts "</div>"

      if {$sender_group != ""} then {
        puts "<div id=\"id_sender_group_receiver_profiles_wrapper\">"
        put_profile_head "SENDER_GROUP"
        put_profile_body "SENDER_GROUP"
        puts "</div>"
      }
      
      #body_wrapper
      puts "</div>"

      #subOffsetDivPopup
      puts "</div>"

    #id_body
    puts "</div>"
  
  #ic_setprofiles
  puts "</div>"

  puts "<script>"
    puts "translatePage(\"#body_wrapper\");"
    puts "jQuery(\"#body_wrapper\").show();"
  puts "</script>"
}

proc put_hidden_values {} {

  global sidname sid
  global iface sender_address sender_group receiver_address 
  global sender_paramid receiver_paramid sender_PARAMIDS receiver_PARAMIDS

  puts "<form action=\"#\">"
  puts "<input id=\"global_sid\"              name=\"$sidname\"          type=\"hidden\" value=\"$sid\"/>"
  
  puts "<input id=\"global_iface\"            name=\"iface\"             type=\"hidden\" value=\"$iface\"/>"
  puts "<input id=\"global_sender_address\"   name=\"sender_address\"    type=\"hidden\" value=\"$sender_address\"/>"
  puts "<input id=\"global_sender_group\"     name=\"sender_group\"      type=\"hidden\" value=\"$sender_group\"/>"
  puts "<input id=\"global_receiver_address\" name=\"receiver_address\"  type=\"hidden\" value=\"$receiver_address\"/>"
  
  #Existierende ParamIds:
  puts "<input id=\"sender_paramid\"          name=\"sender_paramid\"    type=\"hidden\" value=\"$sender_paramid\"/>"
  puts "<input id=\"receiver_paramid\"        name=\"receiver_paramid\"  type=\"hidden\" value=\"$receiver_paramid\"/>"
  
  #Unmodifizierte ParamIds:
  puts "<input id=\"sender_paramids\"         name=\"sender_paramids\"   type=\"hidden\" value=\"$sender_PARAMIDS\"/>"
  puts "<input id=\"receiver_paramids\"       name=\"receiver_paramids\" type=\"hidden\" value=\"$receiver_PARAMIDS\"/>"

  puts "</form>"
}

proc add_expertprofile {pPROFILES_MAP pPROFILE} {
  
  upvar $pPROFILES_MAP PROFILES_MAP
  upvar $pPROFILE      PROFILE

  if { ! [info exists PROFILES_MAP(0)] } then {
    set PROFILES_MAP(0) "Experte"
    set PROFILE(UI_DESCRIPTION) "Expertenprofil"
    set PROFILE(UI_TEMPLATE) "Expertenprofil"
    set PROFILE(UI_HINT)  0
    constructor
  }
}

proc put_expertprofile {iface address p_str special_name special_id pps_descr pps} {

  #cgi_debug -on

  upvar $p_str     str
  upvar $pps_descr ps_descr
  upvar $pps       ps

  set name        ${special_name}_profiles
  set id          ${special_id}_profiles
  set profilename ${special_id}_0

  if { ![session_is_expert] } then {
    append str "<div id=\"not_enough_rights_for_expertmode\" style=\"visibility: hidden; display: none;\">"
    
    array set options ""
    set options(0) "Experte"
    append str [get_ComboBox2 options $name $id 0 "onchange=\"ShowEasyMode(this, '$iface');\""]
    append str "<br/>Sie besitzen nicht die Berechtigung das Expertenprofil zu ver&auml;ndern."
    
    append str "</div>"
  } else {
    append str "<div style=\"visibility: hidden; display: none;\">"
    array set options ""
    set options(0) "Experte"
    append str [get_ComboBox2 options $name $id 0 "onchange=\"ShowEasyMode(this, '$iface');\""]
    append str "</div>"
    
    append str [cmd_link_paramset2 $iface $address ps_descr ps "LINK" $profilename]
  }
}

proc recycle_easymodes {pPROFILES_MAP pHTML_PARAMS special_input_id cur_profile pps} {

#cgi_debug -on
  global dev_descr_sender dev_descr_receiver  
  upvar $pPROFILES_MAP PROFILES_MAP
  upvar $pHTML_PARAMS  HTML_PARAMS
  upvar $pps           ps
  
  set u_subset ""

  foreach pnr [array names PROFILES_MAP] {

  if {[regexp {^([0-9]+)\.[0-9]+$} $pnr dummy base_pnr]} then {

      #Dies ist ein vom Benutzer angelegtes Profil.
      #HTML-IDs austauschen und als neuen Text übernehmen:
      set HTML_PARAMS(separate_$pnr) [replace_ids $HTML_PARAMS(separate_$base_pnr) separate_${special_input_id}_$base_pnr separate_${special_input_id}_$pnr]
      set i 1
      set s ""
      upvar PROFILE_$pnr PROFILE

      #HTML-Input-Controls auf richtige Werte setzen:

      foreach pname [array names PROFILE] {
        
        #Nur die Parameter die im Text enthalten sind. Interne Parameter, die mit UI_ anfangen auslassen.
          
        if { [string first $HTML_PARAMS(separate_$pnr) $pname] && [string range $pname 0 2] != "UI_"} { 
        
          if {$pname == "SUBSET_OPTION_VALUE"} {
            set u_subset $PROFILE($pname)
          }

          #Normalerweise die Werte aus den angelegten Profilen nehmen, ausser das Profil ist aktiv. Dann die 
          #Werte des Geräts nehmen (aktuelle).
          
          if {$pname != "NAME" && $pname != "SUBSET_OPTION_VALUE"} {
            if {$cur_profile == $pnr} then { append s "recycle_arr\['$pname'\] = $ps($pname);" 
            } else {                   
              append s "recycle_arr\['$pname'\] = $PROFILE($pname);" 
            }
            incr i 
          }
        }
      }

      if {$i > 1} then {
        append HTML_PARAMS(separate_$pnr) "<script type=\"text/javascript\">var recycle_arr = new Array(); $s UpdateSpecialInputs('separate_${special_input_id}_${pnr}', recycle_arr, '$u_subset');</script>"
      }
    }
  }
}

proc replace_ids {html_params oldid newid} {
  set charMap ""
  lappend charMap $oldid $newid
  lappend charMap ${oldid}_temp ${newid}_temp
  return [string map $charMap $html_params]
}

#Nur bei...
proc pass_whitelist {channel_type whitelist} {
  #puts "ch_type $channel_type whitelist $whitelist lsearch [lsearch -exact $whitelist $channel_type] passed: [expr { [lsearch -exact $whitelist $channel_type]>=0 ? 1 : 0 } ]<br/> "
  return [expr { [lsearch -exact $whitelist $channel_type]>=0 ? 1 : 0 } ]
}

#Nicht bei...
proc pass_blacklist {channel_type blacklist} {
  #puts "ch_type $channel_type blacklist $blacklist passed: [expr { [lsearch -exact $blacklist $channel_type]>=0 ? 0 : 1 } ]<br/> "
  return [expr { [lsearch -exact $blacklist $channel_type]>=0 ? 0 : 1 } ]
}

#PEERPART: SENDER|SENDER_GROUP
proc put_profile_body { PEERPART } {
  global dev_descr_sender dev_descr_receiver dev_descr_sender_group hmw
  global sender_paramid receiver_paramid sender_PARAMIDS receiver_PARAMIDS
  global sender_ps sendergroup_ps receiver_ps receivergroup_ps
  global ps_descr_sender ps_descr_receiver
  global iface sender_address sender_group receiver_address 
  global USERPROFILESPATH
    global env url multilingual
  
  array set SENTRY             ""
  set SENTRY(SENDER_PROFILE)   "\${profileSettingsSender}<br/>"
  set SENTRY(RECEIVER_PROFILE) "\${profileSettingsReceiver}<br/>"

  if {$sender_paramid == ""} then {
    #EasyMode-Seite easymodes/<ps_id>.tcl existiert nicht. Es gibt nur den Expertenmodus.
    #In ps_ids sind sämtliche ParamsetIds aufgelistet (direkt aus xmlrpc getParamsetIds)
    #auch wenn es die Dateien dazu nicht gibt.
    set USERPROFILEFILE $USERPROFILESPATH/$sender_PARAMIDS.tcl
  } else {
    set USERPROFILEFILE $USERPROFILESPATH/$sender_paramid.tcl
  }
  
  append SENTRY(SENDER_PROFILE) "<div class=\"easymode_wrapper\">"

  set sourced 0
  if { ![catch {source $USERPROFILEFILE} ] } then {
    incr sourced
  }

  if { ![catch {source easymodes/$sender_paramid.tcl} ] } then {
    incr sourced
  }

  if {$sourced > 0} then {

    set cur_profile ""
    set special_input_id ""

    add_expertprofile PROFILES_MAP PROFILE_0
    
    if {$PEERPART == "SENDER" } then {
      set group "receiver"
      set special_input_id "sender"
      set cur_profile [get_cur_profile2 sender_ps PROFILES_MAP PROFILE_TMP $dev_descr_receiver(TYPE)]
      set_htmlParams $iface $sender_address sender_ps ps_descr_sender $special_input_id $dev_descr_receiver(TYPE)
      recycle_easymodes PROFILES_MAP HTML_PARAMS "sender" $cur_profile sender_ps

      if { ![session_is_expert] } then {
        unset PROFILES_MAP(0)

        if {$cur_profile == 0} then {
          set PROFILES_MAP(99) "\${unknownProfile}"
          set HTML_PARAMS(separate_99) "\${useExpertMode}"
          set HTML_PARAMS(descriptionTemplate_99) "\${unknownProfile}"
          set cur_profile 99
        }
      }

      append SENTRY(SENDER_PROFILE) [get_ComboBox2 PROFILES_MAP "sender_profiles" "sender_profiles" $cur_profile "onchange=\"ShowEasyMode(this, '$iface');\""]
    } else {
      set group "receivergroup"
      set special_input_id "sendergroup"
      set cur_profile [get_cur_profile2 sendergroup_ps PROFILES_MAP PROFILE_TMP $dev_descr_receiver(TYPE)]
      set_htmlParams $iface $sender_group sendergroup_ps ps_descr_sender $special_input_id $dev_descr_receiver(TYPE)
      recycle_easymodes PROFILES_MAP HTML_PARAMS "sendergroup" $cur_profile sendergroup_ps
      
      if { ![session_is_expert] } then {
        unset PROFILES_MAP(0)

        if {$cur_profile == 0} then {
          set PROFILES_MAP(99) "\${unknownProfile}"
          set HTML_PARAMS(separate_99) "\${useExpertMode}"
          set HTML_PARAMS(descriptionTemplate_99) "\${unknownProfile}"
          set cur_profile 99
        }
      }
      
      append SENTRY(SENDER_PROFILE) [get_ComboBox2 PROFILES_MAP "sender_profiles" "sendergroup_profiles" $cur_profile "onchange=\"ShowEasyMode(this, '$iface');\""]
    }

    catch { append SENTRY(SENDER_PROFILE) $HTML_PARAMS(before_profiles) }
    
    append SENTRY(SENDER_PROFILE) "<table class=\"ProfileTbl\" cellspacing=\"0\">"
    foreach pnr [lsort [array names PROFILES_MAP]] {
      if { ![session_is_expert] && $pnr == 0} then { continue }

      if {[regexp {^([0-9]+)\.[0-9]+$} $pnr dummy base_pnr]} then {
        if { ![session_is_expert]  && $base_pnr == 0} then { continue }
      }

      append SENTRY(SENDER_PROFILE) "<tr class=\"sender_$pnr\" [expr {$cur_profile == $pnr?" ":" style=\"visibility:hidden; display:none;\""} ]><td class=\"CLASS20002\">"
      append SENTRY(SENDER_PROFILE) $HTML_PARAMS(separate_$pnr)
      append SENTRY(SENDER_PROFILE) "</td></tr>"
    } 
    append SENTRY(SENDER_PROFILE) "</table>"

    catch { append SENTRY(SENDER_PROFILE) $HTML_PARAMS(after_profiles) }

    foreach pnr [array names PROFILES_MAP] {
      set profile_visible 1
      if {[info exists HTML_PARAMS(whitelist_$pnr)] && ! [pass_whitelist $dev_descr_receiver(TYPE) $HTML_PARAMS(whitelist_$pnr)] } then { set profile_visible 0 }
      if {[info exists HTML_PARAMS(blacklist_$pnr)] && ! [pass_blacklist $dev_descr_receiver(TYPE) $HTML_PARAMS(blacklist_$pnr)] } then { set profile_visible 0 }
      if {$PEERPART == "SENDER" && $profile_visible == 0 } then {
        append SENTRY(SENDER_PROFILE) "<script type=\"text/javascript\">RemoveProfile('sender',      $pnr);</script>"
      } elseif {$profile_visible == 0} then {
        append SENTRY(SENDER_PROFILE) "<script type=\"text/javascript\">RemoveProfile('sendergroup', $pnr);</script>"
      }
    }
    destructor

    #Ausgewählten Eintrag sichtbar schalten:
    append SENTRY(SENDER_PROFILE) "<script type=\"text/javascript\">ShowEasyMode(\$('${special_input_id}_profiles'), '$iface');</script>"
  } else {
    if {$PEERPART == "SENDER" } then {
      put_expertprofile $iface $sender_address SENTRY(SENDER_PROFILE) "sender" "sender"      ps_descr_sender sender_ps
      set group "receiver"
    } else {
      put_expertprofile $iface $sender_group   SENTRY(SENDER_PROFILE) "sender" "sendergroup" ps_descr_sender sendergroup_ps
      set group "receivergroup"
    }
  }
  append SENTRY(SENDER_PROFILE) "</div>"

##  AG hier muss die Variable USERPROFILEFILE an die neue Profilstruktur angepasst werden

  set HMW ""
  set IO ""
  if {[string first "hmw" $receiver_paramid] != -1} {
    array set hmw [xmlrpc $url getParamset [list string $dev_descr_sender(ADDRESS)] [list string MASTER]] 
    set IO "_1" ;# falls WIRED_VIRTUAL_KEY
    set HMW "HMW_"
    catch {set IO "_$hmw(INPUT_TYPE)"}
  }


  if {$receiver_paramid == ""} then {
    #EasyMode-Seite easymodes/<ps_id>.tcl existiert nicht. Es gibt nur den Expertenmodus.
    #In ps_ids sind sämtliche ParamsetIds aufgelistet (direkt aus xmlrpc getParamsetIds)
    #auch wenn es die Dateien dazu nicht gibt.
    set USERPROFILEFILE $USERPROFILESPATH/$receiver_PARAMIDS.tcl
  } else {
    set USERPROFILEFILE "$USERPROFILESPATH/$HMW$dev_descr_receiver(TYPE)/$dev_descr_sender(TYPE)$IO-$dev_descr_sender(PARENT).tcl"
  }


##  Pfad testen
# puts "<script type=\"text/javascript\">alert('Normalprofil = $receiver_paramid \\n Userprofil = $USERPROFILEFILE');</script>"
  
  append SENTRY(RECEIVER_PROFILE) "<div class=\"easymode_wrapper\">"

  set sourced 0
  if { ![catch {source $USERPROFILEFILE} ] } then {
    incr sourced
  }

  if { ![catch {source easymodes/$receiver_paramid.tcl} ] } then {
    incr sourced
  }

  if {$sourced > 0} then {

    set cur_profile ""
    set special_input_id ""

    add_expertprofile PROFILES_MAP PROFILE_0
    
    if {$PEERPART == "SENDER" } then {
      set special_input_id "receiver"
      
      set cur_profile [get_cur_profile2 receiver_ps PROFILES_MAP PROFILE_TMP  $dev_descr_sender(TYPE)]
      set_htmlParams $iface $receiver_address receiver_ps ps_descr_receiver "receiver" $dev_descr_sender(TYPE)

      recycle_easymodes PROFILES_MAP HTML_PARAMS "receiver" $cur_profile receiver_ps

      if { ![session_is_expert] } then {
        unset PROFILES_MAP(0)
        if {$cur_profile == 0} then {
          set PROFILES_MAP(99) "\${unknownProfile}"
          set HTML_PARAMS(separate_99) "<div id=\"param_99\"><textarea id=\"profile_99\" style=\"display:none\">\${useExpertMode}</textarea></div>"
          set HTML_PARAMS(descriptionTemplate_99) "\${useExpertMode}"
          set cur_profile 99
            puts "<script type=\"text/javascript\">document.getElementById(\"NewProfileTemplate_receiver\").onclick = new Function (\"alert(translateKey('profileNotSaveable'))\");</script>"
        }
      }
      # die ComboBox der Profilauswahl    
      if {[info exists multilingual]} then {
        append SENTRY(RECEIVER_PROFILE) "<div id=\"maps_div_0\"><textarea id=\"maps_textarea_0\" style=\"display:none\">"
        append SENTRY(RECEIVER_PROFILE) [get_ComboBox2 PROFILES_MAP "receiver_profiles" "receiver_profiles" $cur_profile  "onchange=\"ShowEasyMode(this, '$iface');\""]
        append SENTRY(RECEIVER_PROFILE) "</textarea></div>"
        append SENTRY(RECEIVER_PROFILE) "<script type=\"text/javascript\">translate_map('maps_div_0', 'maps_textarea_0');</script>"
      } else {
        append SENTRY(RECEIVER_PROFILE) [get_ComboBox2 PROFILES_MAP "receiver_profiles" "receiver_profiles" $cur_profile  "onchange=\"ShowEasyMode(this, '$iface');\""]
      }
    } else {
      set special_input_id "receivergroup"
      set cur_profile [get_cur_profile2 receivergroup_ps PROFILES_MAP PROFILE_TMP  $dev_descr_sender(TYPE)]
      set_htmlParams $iface $receiver_address receivergroup_ps ps_descr_receiver "receivergroup" $dev_descr_sender(TYPE)
      recycle_easymodes PROFILES_MAP HTML_PARAMS "receivergroup" $cur_profile receivergroup_ps
      
      if { ![session_is_expert] } then {
        unset PROFILES_MAP(0)
        
        if {$cur_profile == 0} then {
          set PROFILES_MAP(99) "\${unknownProfile}"
          set HTML_PARAMS(separate_99) "<div id=\"param_99\"><textarea id=\"profile_99\" style=\"display:none\">\${useExpertMode}</textarea></div>"
          set HTML_PARAMS(descriptionTemplate_99) "\${useExpertMode}"
          set cur_profile 99
            puts "<script type=\"text/javascript\">document.getElementById(\"NewProfileTemplate_receivergroup\").onclick = new Function (\"alert(alert(translateKey('profileNotSaveable')))\");</script>"
        }
      }
      # bei Kanalpaar
      if {[info exists multilingual]} then {
        append SENTRY(RECEIVER_PROFILE) "<div id=\"maps_div_1\"><textarea id=\"maps_textarea_1\" style=\"display:none\">"
        append SENTRY(RECEIVER_PROFILE) [get_ComboBox2 PROFILES_MAP "receiver_profiles" "receivergroup_profiles" $cur_profile  "onchange=\"ShowEasyMode(this, '$iface');\""]
        append SENTRY(RECEIVER_PROFILE) "</textarea></div>"
        append SENTRY(RECEIVER_PROFILE) "<script type=\"text/javascript\">translate_map('maps_div_1', 'maps_textarea_1');</script>"
      } else {
        append SENTRY(RECEIVER_PROFILE) [get_ComboBox2 PROFILES_MAP "receiver_profiles" "receivergroup_profiles" $cur_profile  "onchange=\"ShowEasyMode(this, '$iface');\""]
      }
    }

    catch { append SENTRY(RECEIVER_PROFILE) $HTML_PARAMS(before_profiles) }
    append SENTRY(RECEIVER_PROFILE) "<table id=\"ProfileTbl_$group\" class=\"ProfileTbl\" cellspacing=\"0\">"
    
    foreach pnr [lsort [array names PROFILES_MAP]] {

      if {[info exists multilingual]} then {
        append SENTRY(RECEIVER_PROFILE) "<script type=\"text/javascript\">translate('$pnr', '$group');</script>"
      }

      if { ![session_is_expert] && $pnr == 0} then { continue }
      
      if {[regexp {^([0-9]+)\.[0-9]+$} $pnr dummy base_pnr]} then {
        if { ![session_is_expert] && $base_pnr == 0} then { continue }
      }
    
      append SENTRY(RECEIVER_PROFILE) "<tr class=\"receiver_$pnr\" [expr {$cur_profile == $pnr?" ":" style=\"visibility:hidden; display:none;\""} ]><td>"
      if {$PEERPART == "SENDER"} then {
        catch {append SENTRY(RECEIVER_PROFILE) "<span class=\"descrTemplate_receiver_$pnr\" style=\"visibility:hidden; display:none;\">$HTML_PARAMS(descriptionTemplate_$pnr)</span>"}
      } else {
        catch {append SENTRY(RECEIVER_PROFILE) "<span class=\"descrTemplate_receivergroup_$pnr\" style=\"visibility:hidden; display:none;\">$HTML_PARAMS(descriptionTemplate_$pnr)</span>"}
      }
      append SENTRY(RECEIVER_PROFILE) $HTML_PARAMS(separate_$pnr)
      append SENTRY(RECEIVER_PROFILE) "</td></tr>"
    }
    append SENTRY(RECEIVER_PROFILE) "</table>"

    catch { append SENTRY(RECEIVER_PROFILE) $HTML_PARAMS(after_profiles) }

    foreach pnr [array names PROFILES_MAP] {
      set profile_visible 1
      if {$PEERPART == "SENDER" } then {
        if {[info exists HTML_PARAMS(whitelist_$pnr)] && ! [pass_whitelist $dev_descr_sender(TYPE) $HTML_PARAMS(whitelist_$pnr)] } then { set profile_visible 0 }
        if {[info exists HTML_PARAMS(blacklist_$pnr)] && ! [pass_blacklist $dev_descr_sender(TYPE) $HTML_PARAMS(blacklist_$pnr)] } then { set profile_visible 0 }
        if {$profile_visible == 0} then { append SENTRY(RECEIVER_PROFILE) "<script type=\"text/javascript\">RemoveProfile('receiver',      $pnr);</script>" }
      } else {
        if {[info exists HTML_PARAMS(whitelist_$pnr)] && ! [pass_whitelist $dev_descr_sender_group(TYPE) $HTML_PARAMS(whitelist_$pnr)] } then { set profile_visible 0 }
        if {[info exists HTML_PARAMS(blacklist_$pnr)] && ! [pass_blacklist $dev_descr_sender_group(TYPE) $HTML_PARAMS(blacklist_$pnr)] } then { set profile_visible 0 }
        if {$profile_visible == 0} then { append SENTRY(RECEIVER_PROFILE) "<script type=\"text/javascript\">RemoveProfile('receivergroup', $pnr);</script>" }
      }
    }

    destructor

    #Ausgewählten Eintrag sichtbar schalten:
    append SENTRY(RECEIVER_PROFILE) "<script type=\"text/javascript\">window.setTimeout(function() {ShowEasyMode(\$('${special_input_id}_profiles'), '$iface');},500);</script>"

  } else {

    if {$PEERPART == "SENDER" } then {
      put_expertprofile $iface $receiver_address SENTRY(RECEIVER_PROFILE) "receiver" "receiver"      ps_descr_receiver receiver_ps
    } else {
      put_expertprofile $iface $receiver_address SENTRY(RECEIVER_PROFILE) "receiver" "receivergroup" ps_descr_receiver receivergroup_ps
    }
  }
  append SENTRY(RECEIVER_PROFILE) "</div>"
  
  puts "<table class=\"SetProfLinkTbl\" cellspacing=\"0\">"
  puts "<colgroup>"
  puts "<col style=\"width:50%;\"/>"
  puts "<col style=\"width:50%;\"/>"
  puts "</colgroup>"
  puts "<tbody>"
  puts "<tr class=\"CLASS20003\">"
  puts "<td class=\"CLASS20004\">$SENTRY(SENDER_PROFILE)</td>"
  puts "<td class=\"CLASS20004\">$SENTRY(RECEIVER_PROFILE)</td>"
  puts "</tr>"
  puts "<tr>"
  puts "<td colspan=\"2\" class=\"CLASS20005\">"  

  puts "<table class=\"SetProfLinkTbl_Buttons\" border=\"0\" cellspacing=\"0\">"
  puts "<colgroup>"
  puts "<col style=\"width:10%;\"/>"
  puts "<col style=\"width:26%;\"/>"
  puts "<col style=\"width:28%;\"/>"
  puts "<col style=\"width:26%;\"/>"
  puts "<col style=\"width:10%;\"/>"
  puts "</colgroup>"
  puts "<tbody>"
  puts "<tr>"

  if {$PEERPART == "SENDER" } then {
    set select_id "sender"
  } else {
    set select_id "sendergroup"
  }
  puts "<td  style=\"text-align:left;\">"
  if {$iface != "HmIP-RF"} {
    puts "<div id=\"NewProfileTemplate_$select_id\" onclick=\"ShowNewEasyModeDialog('$select_id');\"  class=\"CLASS20009 CLASS20010\" >\${btnSaveNewProfile}</div>"
  } else {
      puts "<div id=\"NewProfileTemplate_$select_id\" class=\"CLASS20009a CLASS20010\" >\${btnSaveNewProfile}</div>"
  }
  puts "</td>"
  puts "<td  style=\"text-align:left;\">"
  puts "<div id=\"DelBtnEasyMode_$select_id\" onclick=\"DeleteEasyMode('$select_id');\" class=\"CLASS20009 CLASS20010\" style=\"visibility: hidden;\">\${btnRemoveProfileTemplate}</div>"
  puts "</td>"
  if {($iface != "BidCos-Wired") && ($iface != "HmIP-RF") } {
    puts "<td style=\"text-align:center; vertical-align:middle;\"><div onclick=\"ActivateLinkParamset('$iface', '[expr {$PEERPART=="SENDER"?$sender_address:$sender_group} ]', '$receiver_address')\" class=\"CLASS20009 CLASS20010\">\${btnTestReceiverProfile}</div></td>"
  } else {
    puts "<td style=\"text-align:center; vertical-align:middle;\"><div></div></td>"
  }
  if {$PEERPART == "SENDER" } then {
    set select_id "receiver"
  } else {
    set select_id "receivergroup"
  }
  puts "<td  style=\"text-align:right;\">"
  puts "<div id=\"DelBtnEasyMode_$select_id\" onclick=\"DeleteEasyMode('$select_id');\" class=\"CLASS20009 CLASS20010\" style=\"visibility: hidden;\">\${btnRemoveProfileTemplate}</div>"
  puts "</td>"
  puts "<td  style=\"text-align:right;\">"
  if {$iface != "HmIP-RF"} {
    puts "<div id=\"NewProfileTemplate_$select_id\" onclick=\"ShowNewEasyModeDialog('$select_id');\" class=\"CLASS20009 CLASS20010\" style=\"visibility:visible\">\${btnSaveNewProfile}</div>"
  } else {
    puts "<div id=\"NewProfileTemplate_$select_id\" class=\"CLASS20009a CLASS20010\" style=\"visibility:visible\">\${btnSaveNewProfile}</div>"
  }
  puts "</td>"
  puts "</tr>"
  puts "</tbody>"
  puts "</table>"
  
  puts "</td>"  
  puts "</tr>"
  puts "</tbody>"
  puts "</table>"
}

#PEERPART: SENDER|SENDER_GROUP
proc put_profile_head { PEERPART } {

  #cgi_debug -on

  global dev_descr_sender dev_descr_receiver dev_descr_sender_group
  global sender_receiver_linkinfo sendergroup_receiver_linkinfo
  global iface sender_address sender_group receiver_address 
  global ise_CHANNELNAMES

  array set SENTRY                 ""
  set SENTRY(SENDERNAME)           "&nbsp;"
  set SENTRY(SENDERNAME_DISPLAY)   "&nbsp;"
  set SENTRY(SENDERADDR)           "&nbsp;"
  set SENTRY(SENDERACTION)         "&nbsp;"
  set SENTRY(LINKNAME)             "&nbsp;"
  set SENTRY(LINKDESC)             "&nbsp;"
  set SENTRY(LINKACTION)           "&nbsp;"
  set SENTRY(RECEIVERNAME)         "&nbsp;"
  set SENTRY(RECEIVERNAME_DISPLAY) "&nbsp;"
  set SENTRY(RECEIVERADDR)         "&nbsp;"
  set SENTRY(RECEIVERACTION)       "&nbsp;"
    
  if {$PEERPART == "SENDER"} then {
    
    set SENTRY(SENDERADDR) $sender_address
    if { [catch { set SENTRY(SENDERNAME) $ise_CHANNELNAMES($iface;$sender_address)} ] } then {
        set SENTRY(SENDERNAME) "$iface"
        append SENTRY(SENDERNAME) ".$sender_address"
    }

  # set SENTRY(SENDERNAME_DISPLAY) "<div style=\"position:relative;\" onmouseover=\"picDivShow(jg_250, '$dev_descr_sender(PARENT_TYPE)', 250, $dev_descr_sender(INDEX), this);\" onmouseout=\"picDivHide(jg_250);\">[cgi_quote_html $SENTRY(SENDERNAME)]</div>"
    set SENTRY(SENDERNAME_DISPLAY) "<div onmouseover=\"picDivShow(jg_250, '$dev_descr_sender(PARENT_TYPE)', 250, $dev_descr_sender(INDEX), this);\" onmouseout=\"picDivHide(jg_250);\">[cgi_quote_html $SENTRY(SENDERNAME)] </div>"

    set linkname ""
    set linkdesc ""
    
    catch {
      set linkname $sender_receiver_linkinfo(NAME)
      set linkdesc $sender_receiver_linkinfo(DESCRIPTION)
    }

    set SENTRY(LINKNAME) "<input id=\"sender_linkname\"        name=\"sender_linkname\"        type=\"text\" size=\"30\" value=\"$linkname\"/>"
    set SENTRY(LINKDESC) "<div><table><tr class=\"WhiteHeader\"><td style=\"border: 0px\"><input id=\"sender_linkdescription\" name=\"sender_linkdescription\" type=\"text\" size=\"30\" value=\"$linkdesc\" class=\"_CLASS20006\"/></td>"
    append SENTRY(LINKDESC) "<td style=\"border: 0px\"><div onclick=\"EnterDescriptionTemplate('receiver');\" class=\"CLASS20009\" style=\"padding:0px;\">&lt;-</div></td></tr></table></div>"


  } elseif {$PEERPART == "SENDER_GROUP"} then {

    set SENTRY(SENDERADDR) $sender_group
    if { [catch { set SENTRY(SENDERNAME) $ise_CHANNELNAMES($iface;$sender_group)} ] } then {
        set SENTRY(SENDERNAME) "$iface"
        append SENTRY(SENDERNAME) ".$sender_group"
    }
  # set SENTRY(SENDERNAME_DISPLAY) "<div style=\"position:relative;\" onmouseover=\"picDivShow(jg_250, '$dev_descr_sender(PARENT_TYPE)', 250, $dev_descr_sender_group(INDEX), this);\" onmouseout=\"picDivHide(jg_250);\">[cgi_quote_html $SENTRY(SENDERNAME)]</div>"
    set SENTRY(SENDERNAME_DISPLAY) "<div  onmouseover=\"picDivShow(jg_250, '$dev_descr_sender(PARENT_TYPE)', 250, $dev_descr_sender_group(INDEX), this);\" onmouseout=\"picDivHide(jg_250);\">[cgi_quote_html $SENTRY(SENDERNAME)]</div>"

    set linkname ""
    set linkdesc ""

    catch {
      set linkname $sendergroup_receiver_linkinfo(NAME)
      set linkdesc $sendergroup_receiver_linkinfo(DESCRIPTION)
    }

    set SENTRY(LINKNAME) "<input id=\"sendergroup_linkname\"        name=\"sender_linkname\"        type=\"text\" size=\"30\" value=\"$linkname\"/>"
    set SENTRY(LINKDESC) "<div><table><tr class=\"WhiteHeader\"><td style=\"border: 0px\"><input id=\"sendergroup_linkdescription\" name=\"sender_linkdescription\" type=\"text\" size=\"30\" value=\"$linkdesc\" class=\"_CLASS20006\"/></td>"
    append SENTRY(LINKDESC) "<td style=\"border: 0px\"><div onclick=\"EnterDescriptionTemplate('receivergroup');\" class=\"CLASS20009\" style=\"padding:0px;\">&lt;-</div></td></tr></table></div>"
  }
  
  set SENTRY(RECEIVERADDR) $receiver_address
  if { [catch { set SENTRY(RECEIVERNAME) $ise_CHANNELNAMES($iface;$receiver_address)} ] } then {
      set SENTRY(RECEIVERNAME) "$iface"
      append SENTRY(RECEIVERNAME) ".$receiver_address"
  }
  #set SENTRY(RECEIVERNAME_DISPLAY) "<div style=\"position:relative;\" onmouseover=\"picDivShow(jg_250, '$dev_descr_receiver(PARENT_TYPE)', 250, $dev_descr_receiver(INDEX), this);\" onmouseout=\"picDivHide(jg_250);\">[cgi_quote_html $SENTRY(RECEIVERNAME)]</div>"
  set SENTRY(RECEIVERNAME_DISPLAY) "<div onmouseover=\"picDivShow(jg_250, '$dev_descr_receiver(PARENT_TYPE)', 250, $dev_descr_receiver(INDEX), this);\" onmouseout=\"picDivHide(jg_250);\">[cgi_quote_html $SENTRY(RECEIVERNAME)]</div>"

  set SENTRY(SENDERACTION)   "<div onclick=\"WebUI.enter(DeviceConfigPage, {'iface': '$iface','address': '$SENTRY(SENDERADDR)', 'redirect_url': 'IC_SETPROFILES'});\" class=\"CLASS20009\" >\${btnEdit}</div>"
  set SENTRY(LINKACTION)     "<div onclick=\"RemoveLink('$iface', '$SENTRY(SENDERADDR)', '$SENTRY(RECEIVERADDR)', [expr {$sender_group!=""?"'IC_SETPROFILES'":"'IC_LINKPEERLIST'"} ]);\" class=\"CLASS20009\" >\${btnRemove}</div>"
  set SENTRY(RECEIVERACTION) "<div onclick=\"WebUI.enter(DeviceConfigPage, {'iface': '$iface', 'address': '$SENTRY(RECEIVERADDR)', 'redirect_url': 'IC_SETPROFILES'});\" class=\"CLASS20009\" >\${btnEdit}</div>"

  puts "<table class=\"SetProfLinkTbl CLASS20007\" cellspacing=\"0\" >"
  puts "<thead>"

  puts "<tr>"
  puts "<td colspan=\"3\">\${thSender}</td>"
  puts "<td colspan=\"3\" class=\"BlueHeader\">\${thLink}</td>"
  puts "<td colspan=\"3\">\${thReceiver}</td>"
  puts "</tr>"

  puts "<tr class=\"CLASS20008\">"
  puts "<td>\${thName}</td>"
  puts "<td>\${thSerialNumber}</td>"
  puts "<td>\${thChannelParameter}</td>"
  puts "<td class=\"BlueHeader\">\${thName}</td>"
  puts "<td>\${thDescription}</td>"
  puts "<td>\${thAction}</td>"
  puts "<td>\${thName}</td>"
  puts "<td>\${thSerialNumber}</td>"
  puts "<td>\${thChannelParameter}</td>"
  puts "</tr>"
  
  puts "</thead>"
  puts "<tbody>"
  puts "<tr>"
  puts "<td>$SENTRY(SENDERNAME_DISPLAY)</td>"
  puts "<td>$SENTRY(SENDERADDR)</td>"
  puts "<td>$SENTRY(SENDERACTION)</td>"
  puts "<td class=\"WhiteHeader\">$SENTRY(LINKNAME)</td>"
  puts "<td class=\"WhiteHeader\">$SENTRY(LINKDESC)</td>"
  puts "<td>$SENTRY(LINKACTION)</td>"
  puts "<td>$SENTRY(RECEIVERNAME_DISPLAY)</td>"
  puts "<td>$SENTRY(RECEIVERADDR)</td>"
  puts "<td>$SENTRY(RECEIVERACTION)</td>"
  puts "</tr>"
  puts "</tbody>"
  puts "</table>"
}

cgi_eval {

  cgi_input
    catch {
        import debug
        cgi_debug -on
    }

    http_head
    
  if {[session_requestisvalid 0] > 0} then {

    #URL-Parameter----------------------------
    set sender_address   ""
    set receiver_address ""
    set iface            ""

    catch {import iface}
    catch {import sender_address}
    catch {import receiver_address}
    #-----------------------------------------
      
    #Globale Parameter------------------------
    set sender_group                        ""

    array set dev_descr_sender              ""
    array set ps_descr_sender               ""

    array set dev_descr_receiver            ""
    array set ps_descr_receiver             ""

    array set dev_descr_sender_group        ""
    #array set ps_descr_sender_group         ""

    set sender_paramid                      ""
    set receiver_paramid                    ""
    set sender_PARAMIDS                      ""
    set receiver_PARAMIDS                    ""

    #set sender_group_paramid                ""
    
    array set sender_ps                     ""
    array set receiver_ps                   ""

    array set sendergroup_ps                ""
    array set receivergroup_ps              ""

    array set sender_receiver_linkinfo      ""
    array set sendergroup_receiver_linkinfo ""
    #-----------------------------------------
  
    set url $iface_url($iface)

    if {$sender_address   == ""} then {
      put_receiver_address_not_found
      return
    }

    if {$receiver_address == ""} then {
      put_receiver_address_not_found
      return
    }

    #Informationen über den Sender Teil 1/2-------------------------
    array set dev_descr_sender [xmlrpc $url getDeviceDescription [list string $sender_address]]
    #---------------------------------------------------------------

    #Informationen über die Verknüpfung 1---------------------------
    if { [catch { array set sender_receiver_linkinfo [encoding convertfrom [xmlrpc $url getLinkInfo [list string $sender_address] [list string $receiver_address]]] } ] } then {
      
      #Hier gilt: Die Verknüpfung gibt es nicht!
      #ACHTUNG! Falsch übergebener sender_address-Parameter! Umsetzen auf Sender_Group, wenn vorhanden:
      if { ! [catch { set sender_group $dev_descr_sender(GROUP) } ] } then {
        
        #Tastenpaar vorliegend!
        #Existiert eine Verknüpfung mit dem sender_group?
        if { [catch { array set sender_receiver_linkinfo [encoding convertfrom [xmlrpc $url getLinkInfo [list string $sender_group] [list string $receiver_address]]] } ] } then {
          #Weder mit dem sender_address, noch mit den sender_group konnte eine Verknüpfung gefunden werden.
          put_sender_address_not_found
          return
        } else {
          #Verknüpfung mit dem sender_group existiert.
          #Von nun an so tun, als ob nur die Verknüpfung mit dem sender_group angezeigt werden soll.
          
          array_clear dev_descr_sender
          array set dev_descr_sender [xmlrpc $url getDeviceDescription [list string $sender_group]]
          
          #Austausch von Sender und Sendergroup
          set sender_address $sender_group
          set sender_group ""
        }
      } else {
        #Kein Tastenpaar vorhanden
        #puts "Code 2"
        #put_sender_address_not_found
        #return
      }
    }
    array set sender_ps   [xmlrpc $url getParamset [list string $sender_address]   [list string $receiver_address]]
    array set receiver_ps [xmlrpc $url getParamset [list string $receiver_address] [list string $sender_address]]

    set comment {
      # This creates the link params of the receiver. Useful for initializing a new easymode
      foreach val [array names receiver_ps] {
        exec echo "set PROFILE_1($val) $receiver_ps($val)" >> /tmp/link.log
      }
    }
    #---------------------------------------------------------------

    #Informationen über den Sender Teil 2/2-------------------------
    array set ps_descr_sender  [xmlrpc $url getParamsetDescription   [list string $sender_address]   [list string "LINK"]]
    set paramids [xmlrpc $url getParamsetId $sender_address LINK]
    set sender_paramid [getExistingParamId $paramids]

    if {($sender_paramid == "") && ([isHmIP] == "true")} {
      if { [file exists [file join $env(DOCUMENT_ROOT) config/easymodes/linkHmIP_$dev_descr_sender(TYPE).tcl]] } {
        set sender_paramid linkHmIP_$dev_descr_sender(TYPE)
      }
    }

    set sender_PARAMIDS $paramids
    #---------------------------------------------------------------

    #Informationen über den Receiver--------------------------------
    array set dev_descr_receiver [xmlrpc $url getDeviceDescription   [list string $receiver_address]]
    array set ps_descr_receiver  [xmlrpc $url getParamsetDescription [list string $receiver_address] [list string "LINK"]]
    set paramids [xmlrpc $url getParamsetId $receiver_address LINK]
    set receiver_paramid [getExistingParamId $paramids]

    if {($receiver_paramid == "") && ([isHmIP] == "true")} {
      if { [file exists [file join $env(DOCUMENT_ROOT) config/easymodes/linkHmIP_$dev_descr_receiver(TYPE).tcl]] } {
        set receiver_paramid linkHmIP_$dev_descr_receiver(TYPE)
      }
    }

    set receiver_PARAMIDS $paramids

    #---------------------------------------------------------------

    #Informationen über den Sender_Group (falls vorhanden)----------
    if { ! [catch { set sender_group $dev_descr_sender(GROUP) } ] } then {

      # This if condition is necessary for HmIP devices
      if {$sender_group != ""} {
        #Wir haben ein Tastenpaar vorliegen!

        if {! [catch {array set sendergroup_receiver_linkinfo [encoding convertfrom [xmlrpc $url getLinkInfo [list string $sender_group] [list string $receiver_address]]] } ] } then {

          #Hier gilt: Mit dem Tastenpaar ist auch eine Verknüpfung angelegt!

          #Verknüpfung 2---
          array set sendergroup_ps   [xmlrpc $url getParamset [list string $sender_group]     [list string $receiver_address]]
          array set receivergroup_ps [xmlrpc $url getParamset [list string $receiver_address] [list string $sender_group]]

          array set dev_descr_sender_group [xmlrpc $url getDeviceDescription   [list string $sender_group]]
          #array set ps_descr_sender_group  [xmlrpc $url getParamsetDescription [list string $sender_group] [list string "LINK"]]
          #set paramids [xmlrpc $url getParamsetId $sender_group LINK]
          #set sender_group_paramid [getExistingParamId $paramids]

        } else {

          #So tun, als ob es kein Tastenpaar gibt!
          set sender_group ""
        }
      }
    }
    #---------------------------------------------------------------

    put_page
  }
}
