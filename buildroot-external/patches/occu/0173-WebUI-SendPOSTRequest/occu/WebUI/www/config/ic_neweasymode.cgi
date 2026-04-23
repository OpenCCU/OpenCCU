#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
#sourceOnce session.tcl
sourceOnce ic_common.tcl
sourceOnce common.tcl
#loadOnce tclrpc.so


proc create_profile {pBASEPROFILE pNEWPROFILE new_pnr} {

  #cgi_debug -on

  global env base_pnr

  set IGNORE_PARAMS {EasyModeName base_pnr cmd ps_id ps_ids sensor actor _}

  upvar $pBASEPROFILE BASEPROFILE
  upvar $pNEWPROFILE  PROFILE_TMP
  
  array set PROFILE_TMP [array get BASEPROFILE]

  #Subsets referenzieren für modify_easymode_ui
  set i 1
  catch {upvar SUBSET_$i SUBSET_$i}
  while { [array size SUBSET_$i] > 0  } {
    incr i
    catch {upvar SUBSET_$i SUBSET_$i}
  }
  #=====

  modify_easymode_ui $IGNORE_PARAMS $base_pnr PROFILE_TMP

  set PROFILE_TMP(UI_HINT) $new_pnr
}

proc StoreUserProfiles {} {
  
  global USERPROFILEFILE PROFILEFILE base_pnr EasyModeName env
  set LISTS {UI_BLACKLIST UI_WHITELIST}
  set STRINGS {UI_DESCRIPTION UI_TEMPLATE}
  
  catch {source $PROFILEFILE}
  catch {source $USERPROFILEFILE}

  #Neues Profil anlegen===================================================================
  set is_userprofile [regexp {^([0-9]+)\.([0-9]+)$} $base_pnr dummy f_base_pnr f_user_pnr]
  
  if {$is_userprofile} then {
    incr f_user_pnr
  } else {
    set f_base_pnr $base_pnr
    set f_user_pnr 1
  }

  #finde einen Schlüssel der noch nicht existiert durch inkrementieren des zweiten Schlüsselteils.
  set new_pnr "${f_base_pnr}.$f_user_pnr"
  while {[info exists PROFILES_MAP($new_pnr)]} {
    incr f_user_pnr
    set new_pnr "${f_base_pnr}.$f_user_pnr"
  }
  array set PROFILE_$new_pnr ""
  create_profile PROFILE_$base_pnr PROFILE_$new_pnr $new_pnr
  set PROFILES_MAP($new_pnr) $EasyModeName
  #=======================================================================================

  if {![StoreFile PROFILES_MAP]} then { return -2 }

  return 1
}

proc DeleteUserProfile {pnr} {

  global USERPROFILEFILE PROFILEFILE env
  
  catch {source $PROFILEFILE}
  catch {source $USERPROFILEFILE}
  
  if { [catch {unset PROFILES_MAP($pnr)}] } then {
    return -2
  }

  if {![StoreFile PROFILES_MAP]} then { return -3 }
  
  return 1
}

proc StoreFile {pPROFILES_MAP} {
  global USERPROFILEFILE USERPROFILESPATH actor

  set path "$USERPROFILESPATH/$actor"

  set LISTS {UI_BLACKLIST UI_WHITELIST}
  set STRINGS {UI_DESCRIPTION UI_TEMPLATE}
  set profilescount 0

  upvar $pPROFILES_MAP PROFILES_MAP

  if { ! [catch {open $USERPROFILEFILE w} f] } then {
  
    puts $f "#!/bin/tclsh"
    puts $f {source [file join $env(DOCUMENT_ROOT) config/easymodes/em_common.tcl]}
    
    foreach pnr [array names PROFILES_MAP] {
      
      set is_userprofile [regexp {^([0-9]+)\.([0-9]+)$} $pnr dummy f_base_pnr f_user_pnr]
      if {! $is_userprofile } then { continue }

      incr profilescount

      puts $f "set PROFILES_MAP($pnr) \"[cgi_quote_html $PROFILES_MAP($pnr)]\""

      upvar PROFILE_$pnr PROFILE
      foreach pname [array names PROFILE] {
        
        if { [lsearch -exact $STRINGS $pname] >= 0 } then {
          puts $f "set PROFILE_${pnr}($pname) \"$PROFILE($pname)\""
        } elseif {[lsearch -exact $LISTS $pname] >= 0 } then {
          puts $f "set PROFILE_${pnr}($pname) \{$PROFILE($pname)\}"
        } else {
          if {$pname == "NAME"} {
            puts $f "##set PROFILE_${pnr}($pname) \"$PROFILE($pname)\""
          } else {
            puts $f "set PROFILE_${pnr}($pname) [lindex $PROFILE($pname) 0]"
          }  
        }
      }
    }

    puts $f "proc set_htmlParams \{iface address pps pps_descr special_input_id peer_type\} \{"
    puts $f "  upvar \$pps          ps"
    puts $f "  upvar \$pps_descr    ps_descr"
    puts $f "  upvar HTML_PARAMS   HTML_PARAMS"
    puts $f "  append HTML_PARAMS(separate_0) \[cmd_link_paramset2 \$iface \$address ps_descr ps \"LINK\" \$\{special_input_id\}_0\]"
    puts $f "\}"

    puts $f "constructor"
    
    close $f
    if {$profilescount == 0} then { 
      # sollte kein Userprofil mehr vorhanden sein, das Profilfile bitte loeschen
      file delete -force -- $USERPROFILEFILE 
      # sollte das Verzeichniss jetzt leer sein, dieses auch löschen (file delete löscht nur leere Verzeichnisse).
      catch {file delete $path}
    }
    
    return 1
  }

  return 0
}

cgi_eval {

  cgi_input
#  cgi_debug -on

  http_head

  set base_pnr -1
  set ps_id ""
  set cmd ""
  set new_profilepath ""
  set sensor "sender"
  set actor "receiver"

  catch {import base_pnr} 
  catch {import ps_id}  ;# enth. EasyMode-Datei z. B. switch_ch_link
  catch {import cmd}
  catch {import new_profilepath}
  catch {import sensor}
  catch {import actor}

  if {$ps_id == ""} then {

    #EasyMode-Seite easymodes/<ps_id>.tcl existiert nicht. Es gibt nur den Expertenmodus.
    #In ps_ids sind sämtliche ParamsetIds aufgelistet (direkt aus xmlrpc getParamsetIds)
    #auch wenn es die Dateien dazu nicht gibt.
    set ps_ids ""
    catch {import ps_ids}
    set ps_id $ps_ids
  }

  catch {unset PROFILEFILE} 
  catch {unset USERPROFILEFILE}

  if {[lindex [split $ps_id "-"] 0] != "$actor/$sensor"} {
    if {[file exists $USERPROFILESPATH/$actor] != 1 } {file mkdir $USERPROFILESPATH/$actor}
  } else { set new_profilepath $ps_id }

  set PROFILEFILE    easymodes/$actor/$sensor.tcl
  set USERPROFILEFILE $USERPROFILESPATH/$new_profilepath.tcl
  
  # Ende neue Profilstruktur
  
  if {$cmd == "SAVE"} then {
  
    catch {import EasyModeName}
    
    puts "<script type=\"text/javascript\">"

    set ret [StoreUserProfiles]
    
  
    if {$ret < 0} then {
      puts "if (ProgressBar) ProgressBar.IncCounter(\"Erstellen der Profilvorlage war nicht erfolgreich.\");"
      puts "ShowErrorMsg('Fehler beim Speichern des benutzerdefinierten Profils. Fehler Nr. $ret.')";
    } else {
      puts "if (ProgressBar) ProgressBar.IncCounter(\"Erstellen der Profilvorlage war erfolgreich.\");"
      puts "NewEasyModeDialog.removeAndReload();"
    }
    
    puts "</script>"
      
    return

  } elseif {$cmd == "DELETE"} then {

    catch {import pnr}
    catch {import special_input_id}
    puts "<script type=\"text/javascript\">"

    set ret [DeleteUserProfile $pnr]
  
    if {$ret < 0} then {
      puts "if (ProgressBar) ProgressBar.IncCounter(\"Löschen der Profilvorlage war nicht erfolgreich.\");"
      puts "ShowErrorMsg('Fehler beim L&ouml;schen des benutzerdefinierten Profils. Fehler Nr. $ret.')";
    } else {
      puts "if (ProgressBar) ProgressBar.IncCounter(\"Löschen der Profilvorlage war erfolgreich.\");"

      if {[regexp {^([a-z]+)group$} $special_input_id dummy firstpart]} then {
        #special_input_id: sendergroup|receivergroup

        #sender|receiver
        puts "RemoveProfile( '$firstpart', $pnr);"

        #sendergroup|receivergroup
        puts "RemoveProfile( '$special_input_id', $pnr);"
      } else {
        #special_input_id: sender|receiver
        
        #sender|receiver
        puts "RemoveProfile( '$special_input_id', $pnr);"
        
        #sendergroup|receivergroup
        puts "RemoveProfile( '${special_input_id}group', $pnr);"
      }

      if {[regexp {^([0-9]+)\.([0-9]+)$} $pnr dummy f_base_pnr f_user_pnr]} then {
        #Es ist ein vom User erstelltes Benutzerprofil
        puts "SwitchEasyMode('$special_input_id', $f_base_pnr);"
      }
    }
    puts "</script>"
      
    return
  }
  puts "<div id=\"ic_neweasymode\">"
  puts "  <div id=\"id_header\" class=\"popupTitle\"><textarea id=\"title_SaveNewProfile\" style=\"display:none\">"
  puts "    \${title}"
  puts "  </textarea></div>"

  
  if {$base_pnr > -1} then {
    
    catch {source $PROFILEFILE}
    catch {source $USERPROFILEFILE}
    set base_name "Expertenprofil"
    catch { set base_name "$PROFILES_MAP($base_pnr)"}
    set default_name "$base_name"

    if { ! [regexp {benutzerdefiniert} $base_name] } then {
      set default_name "$base_name \${userdefined}"
    }

    if { ![info exists PROFILES_MAP] } then { array set PROFILES_MAP "" }

    puts "<script type=\"text/javascript\">"
    foreach pnr [array names PROFILES_MAP] {
      puts "NewEasyModeDialog.AddProfile($pnr, '$PROFILES_MAP($pnr)');"
    }
    puts "</script>"
    
    puts "  <div id=\"id_body\"><textarea id=\"id_body_textarea\" style=\"display:none\">"
    puts "    \${origProfile}: '$base_name'<br/><br/>"
    puts "    \${insertDescr}<br/><br/>"
    puts "    \${newDescr}:"
#    puts "    <form _action=\"#\">"
    puts "      <input type=\"text\"   size=\"30\" id=\"EasyModeName\"    name=\"EasyModeName\"    value=\"$default_name\" class=\"CLASS22201\" onkeyup=\"NewEasyModeDialog.ProfileOverwriteWarning();\" />"
    puts "      <div style=\"visibility: hidden; display: none;\">"
    puts "        <input type=\"hidden\" id=\"EasyModeBasePnr\" name=\"EasyModeBasePnr\" value=\"$base_pnr\" />"
    puts "        <input type=\"hidden\" id=\"EasyModePsId\"    name=\"EasyModePsId\"    value=\"$ps_id\" />"
    puts "      </div>"
#    puts "    </form>"
  #  puts "    <div id=\"id_overwrite_warning\" class=\"CLASS22201\" style=\"visibility: hidden;\">Achtung: diese Profilvorlagen-Bezeichnung gibt es bereits. Bitte geben Sie einen eindeutigen Bezeichner ein.</div>"
    puts "    <div id=\"id_overwrite_warning\" class=\"CLASS22201\" style=\"visibility: hidden;\">\${profile_overwrite}</div>"
    puts "  </textarea></div>"
    puts "  <div class=\"popupControls\" id=\"id_footer\"><textarea id=\"id_footer_textarea\" style=\"display:none\">"
    puts "    <table class=\"CLASS22202\">"
    puts "      <tr>"
    puts "        <td class=\"CLASS22203\"><div id=\"save_new_profile\" style=\"visibility:visible; text-align:center; margin:2px; width:auto; cursor: pointer; border: 1px solid Black; background-color: #5d6373; color: Black; padding:2px;\" onclick=\"NewEasyModeDialog.StoreNewProfile();\">\${save}</div></td>"
    puts "        <td class=\"CLASS22203\"><div class=\"CLASS22204\" onclick=\"NewEasyModeDialog.hide();\">\${cancel}</div></td>"
    puts "        <td class=\"CLASS22207\">.</td>"
    puts "      </tr>"
    puts "    </table>"
    puts "  </textarea></div>"
    puts "<script type=\"text/javascript\">translate_newProfile(function(){ NewEasyModeDialog.ProfileOverwriteWarning(); });</script>"

    #destructor of easymode-tcl-page:
    catch { destructor }

  } else {

    puts "  <div id=\"id_body\">"
    puts "    <div class=\"CLASS22206\">Fehler in der Seite!</div>"
    puts "  </div>"
    puts "  <div class=\"popupControls\" id=\"id_footer\">"
    puts "    <table class=\"CLASS22202\">"
    puts "      <tr>"
    puts "        <td class=\"CLASS22203\"><div class=\"CLASS22204\" onclick=\"NewEasyModeDialog.hide();\">Abbrechen</div></td>"
    puts "        <td class=\"CLASS22205\">&nbsp;</td>"
    puts "      </tr>"
    puts "    </table>"
    puts "  </div>"
  }
  
  puts "</div>"
}
