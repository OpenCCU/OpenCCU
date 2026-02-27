#!/bin/tclsh
source once.tcl
sourceOnce common.tcl
sourceOnce session.tcl

set PFMD_URL "bin://127.0.0.1:2002"

array set OPERATIONS {
  #uninstall   "Deinstallieren"
  uninstall   "\${dialogSettingsExtraSoftwareBtnRemoveSoftware}"

  #restart   "Neustart"
  restart   "\${dialogSettingsExtraSoftwareBtnRestart}"
}

array set swVersion ""
array set swUpdate ""

proc action_install_confirm {} {
  global env
   
  http_head
  division {class="popupTitle j_translate"} {
    #puts "Firmwareupdate - Best&auml;tigung"
    puts "\${dialogSettingsExtraSoftwareInstallMessageBoxTitle}"
  }
  division {class="CLASS21400 j_translate"} {
    table {class="popupTable"} {border="1"} {
      table_row {
        table_data {
          table {class="CLASS21410"} {
            table_row {
              table_data {colspan="2"} {
                 # puts {
                 #   Die einzuspielende Zusatzsoftware befindet sich jetzt auf der Zentrale. Sie k&ouml;nnen jetzt durch Klick auf die
                 #   Schaltfl&auml;che unten die Installation starten.<br>
                 #   R&uuml;ckmeldungen &uuml;ber den Fortschritt erhalten Sie &uuml;ber das Display der Zentrale.
                 # }
                puts "\${dialogSettingsExtraSoftwareInstallMessageBoxContent}"

                set bat_level [get_bat_level]
                if {$bat_level < 50} {
                  br
                  division {class="CLASS21413"} {
                    #puts "Achtung!"
                    #br
                    #puts "Der Ladezustand der Batterien betr&auml;gt nur noch $bat_level%. Um einem Datenverlust oder "
                    #puts "einer Besch&auml;digung des Ger&auml;tes durch einen"
                    #puts "Ausfall der Stromversorgung vorzubeugen, empfehlen wir Ihnen, die Batterien vor dem Einspielen"
                    #puts "der Software zu erneuern."

                    puts "\${dialogSettingsExtraSoftwareInstallMessageBoxHintLowBat_a} $bat_level% \${dialogSettingsExtraSoftwareInstallMessageBoxHintLowBat_b}"
                  }
                }
              }
            }
            table_row {
              table_data {colspan="2"} {
                division {class="popupControls CLASS21411"} {
                  table {
                    table_row {
                      table_data {
                        division {class="CLASS21412"} {onClick="InstallGo();"} {
                          #puts "Installation starten"
                          puts "\${dialogSettingsExtraSoftwareBtnStartInstallSoftware}"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS21403 j_translate"} {
          division {class="CLASS21404"} {onClick="OnBack();"} {
            #puts "Zur&uuml;ck"
            puts "\${dialogBack}"
          }
        }
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      InstallGo = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=install_go");
      }
      OnBack = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(800);
        dlgPopup.LoadFromFile(url);
      }
    }
    puts "translatePage('#messagebox');"
  }
}

proc action_install_go {} {
  global env
  cd /tmp/
  
  http_head

  #put_message "Softwareinstallation" {
  #  Die Softwareinstallation wird jetzt durchgef&uuml;hrt. Meldungen &uuml;ber den Fortschritt erhalten Sie &uuml;ber das Display der Zentrale.
  #  Nach der Installation wird die Zentrale automatisch neu gestartet. Sie k&ouml;nnen sich dann &uuml;ber die Schaltfl&auml;che unten neu anmelden.
  #} {"Neu anmelden" "window.location.href='/';"}

  put_message "\${dialogSettingsExtraSoftwareHintPerformInstallationTitle}" "\${dialogSettingsExtraSoftwareHintPerformInstallationContent}" {"\${btnNewLogin}" "window.location.href='/';"}

  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      var pb = "action=install_start";
      var opts = {
        postBody: pb,
        sendXML: false
      };
      new Ajax.Request(url, opts);
    }
    puts "translatePage('#messagebox');"
  }
}


proc put_message {title msg args} {
  division {class="popupTitle j_translate"} {
    puts $title
  }
  division {class="CLASS21400"} {
    table {class="popupTable CLASS21401"} {border="1"} {
      table_row {class="CLASS21402"} {
        table_data {
          puts $msg
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        if { [llength $args] < 1 } { set args {{"\${dialogBack}" "PopupClose();"}}}
        foreach b $args {
          table_data {class="CLASS21403"} {
            division {class="CLASS21404"} "onClick=\"[lindex $b 1]\"" {
              puts [lindex $b 0]
            }
          }
        }
      }
    }
  }
}

# return the user language
proc getLang {user} {
  set availableLang(0) "auto"
  set availableLang(1) "de"
  set availableLang(2) "en"

  if {[catch {set fp [open "/etc/config/userprofiles/$user.lang" r]}] == 0} {
    set data [read $fp]
    set lang [split $data "\n"]
    close $fp
  } else {
    set lang "0"
  }
  return $availableLang([lindex $lang 0])
 }

proc getUserName {} {
  global sid
  set session [string trim $sid "@" ]
  set isecmd ""
  append isecmd "var user=system.GetSessionVarStr('$session');"
  array set user [rega_script $isecmd]
  set userid [lindex [split $user(user) ";"] 0]

  set isecmd ""
  append isecmd "object user = dom.GetObject($userid);"
  set oUser [rega_script $isecmd]
  set userName [lindex $oUser [expr [lsearch $oUser user] + 1]]
  return $userName
}

proc get_info {script array_var} {
  upvar $array_var arr
  array_clear arr

  # lang is either 'auto', 'de' or 'en'
  # TODO what happens when lang isn´t initialized
  set lang [getLang [getUserName]]

  if {$lang == "auto"} {set lang "de"}


  catch {
    set fd [open "|$script info.$lang" r]
    #set fd [open "|$script info" r]

   while { ! [eof $fd] } {
    set line [gets $fd]
    if { [regexp {^([^:]+): (.*)$} $line dummy key value] } {
      if { [info exists arr($key)] } {append arr($key) "\n"}
      append arr($key) $value
    }
  }
    close $fd
  }

  catch {
   set fd [open "|$script info" r]
   while { ! [eof $fd] } {
    set line [gets $fd]
    if { [regexp {^([^:]+): (.*)$} $line dummy key value] } {
      if { [info exists arr($key)] } {append arr($key) "\n"}
      append arr($key) $value
    }
  }
    close $fd
  }

}

proc action_put_page {} {
  global env REMOTE_FIRMWARE_SCRIPT sid OPERATIONS swVersion swUpdate
  
  http_head
  division {class="popupTitle"} {
    #puts "Zusatzsoftware"
    puts "\${dialogSettingsExtraSoftwareTitle}"
  }
  division {class="CLASS21406"} {
    table {class="popupTable"} {border="1"} {
      set scripts ""
      set loop -1
      catch { set scripts [glob /etc/config/rc.d/*] }
      foreach s $scripts {
        incr loop;
        catch {
          if { ! [file executable $s] } continue
          array set sw_info ""
          get_info $s sw_info
          if { ![info exists sw_info(Name)] } continue
          table_row {class="CLASS21407"} {
            table_data {class="CLASS21408"} {
              puts "$sw_info(Name)"
            }
            table_data {class="CLASS21409"} {width="400"} {
              table {class="CLASS21410"} {
                if { [info exists sw_info(Version) ] } {
                  table_row {
                    #td "Installierte Version:"
                    td "\${dialogSettingsExtraSoftwareInstalledVersion}"
                    td "$sw_info(Version)"
                    td ""
                  }
                }
                if { [info exists sw_info(Update)] } {
                  table_row {
                    table_data {
                      # puts "Verf&uuml;gbare Version:"
                      puts "\${lblAvailableFirmwareVersion}"
                    }
                    # table_data {id=$loop} {name="swVersion"}
                        # puts [iframe "$sw_info(Update)?cmd=check_version&version=$sw_info(Version)" name=\"swInfo\" marginheight=0 marginwidth=0 frameborder=0 width=100 height=20 {scrolling="no"} ]
                    #    set swVersion($loop) $sw_info(Version)

                    puts "<td id=\"availableSWVersion_$loop\" name=\"swVersion\"></td>"
                    set swVersion($loop) $sw_info(Version)
                    set swUpdate($loop) $sw_info(Update)
                    table_data {
                      division {class="popupControls CLASS21411"} {
                        table {
                          table_row {
                            table_data {
                              division {class="CLASS21404"} "onClick=\"window.location.href='$sw_info(Update)?cmd=download&version=$sw_info(Version)';\"" {
                                #puts "Herunterladen"
                                puts "\${dialogSettingsCMBtnPerformSoftwareUpdateDownload}"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
                if { [info exists sw_info(Operations)] || [info exists sw_indo(Config-Url)] } then {
                  table_row {
                    table_data {colspan="3"} {
                      division {class="popupControls CLASS21411"} {
                        table {
                          table_row {
                            if { [info exists sw_info(Operations)] } then {
                            foreach op [array names OPERATIONS] {
                              if { [lsearch $sw_info(Operations) $op] >=0 } {
                                table_data {
                                  division {class="CLASS21404"} "onClick=\"operation('$op', '$s', '$OPERATIONS($op)');\"" {
                                    puts "$OPERATIONS($op)"
                                  }
                                }
                              }
                            }
                            }
                            if { [info exists sw_info(Config-Url)] } then {
                            table_data {
                              division {class="CLASS21404"} "onClick=\"openUrl('$sw_info(Config-Url)?sid=$sid');\"" {
                              puts "\${btnConfigure}"
                              }
                            }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            table_data  {align="left"} {class="CLASS21409"} {

              if { [info exists sw_info(Info)] } {
                puts "<span id='swInfo_$loop'>$sw_info(Info)</span>"
              }
             }
          }
        }
      }

      table_row {class="CLASS21407"} {
        table_data {class="CLASS21408"} {
          #puts "Zusatzsoftware installieren<br>"
          #puts "oder aktualisieren"
          puts "\${dialogSettingsExtraSoftwareTDAddExtraSoftware}"
        }
        table_data {class="CLASS21409"} {width="400"} {
          table {class="CLASS21410"} {
            table_row {
              table_data {
                #puts "Zusatzsoftware ausw&auml;hlen:"
                puts "\${dialogSettingsExtraSoftwareLblSelectExtraSoftware}"
              }
              table_data {
                form "$env(SCRIPT_NAME)?sid=$sid" name=upload_form {target=image_upload_iframe} enctype=multipart/form-data method=post {
                  export action=image_upload
                  file_button firmware_file size=30 maxlength=1000000
                }
                puts {<iframe name="image_upload_iframe" style="display: none;"></iframe>}
              }
            }
            table_row {
              td ""
              table_data {align="right"} {
                division {class="popupControls CLASS21411"} {
                  table {
                    table_row {
                      table_data {
                        division {class="CLASS21412"} {onClick="installAddon();"} {
                          #puts "Installieren"
                          puts "\${dialogSettingsExtraSoftwareBtnInstallSoftware}"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        table_data {align="left"} {class="CLASS21409"} {
          puts "\${dialogSettingsExtraSoftwareHintSelectExtraSoftware}"
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS21403"} {
          division {class="CLASS21404"} {onClick="PopupClose();"} {
            #puts "Zur&uuml;ck"
            puts "\${dialogBack}"
          }
        }
      }
    }
  }
  
  puts ""
  cgi_javascript {

    puts "installAddon = function() {"
      puts "var dlg = new YesNoDialog(translateKey('dialogHint'), translateKey('dialogSettingsExtraSoftwareHintSelectExtraSoftware'), function(result) {"
        puts "if (result == 1) \{document.upload_form.submit();\}"
      puts "},'html');"
      puts "dlg.btnTextNo(translateKey('btnCancel'));"
      puts "dlg.btnTextYes(translateKey('btnOk'));"
    puts "}"

    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      operation = function(op, script, op_name) {
        var pb = "action=operation";
        pb += "&op="+op;
        pb += "&script="+script;
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            if (!transport.responseText.match(/^Success/g)){
              alert(translateString(op_name) + translateKey('btnSysConfAdditionalSoftRemoveFailure') + transport.responseText);
            }else{
              alert(translateString(op_name) + translateKey('btnSysConfAdditionalSoftRemoveSuccess'));
              showSoftwareCP();
            }
          }
        };
        if ("uninstall" == op) 
        {
          new YesNoDialog(translateKey("dialogSafetyCheck"), translateKey("dialogQuestionRemoveExtraSoftware"), function(result) {
          if (result == YesNoDialog.RESULT_YES)
            {
              addOnUninstall = true;
              new Ajax.Request(url, opts);
            }
          });
        }
        else
        {
          new Ajax.Request(url, opts);
        }
      };
      
      openUrl = function(url)
      {
        window.open(url);
      };      
    }
  }
  if { $loop > -1 } {
    translatePage $loop
  } else {
    puts "<script type=\"text/javascript\">translatePage('#messagebox')</script>"
  }
}

proc translatePage {loop} {


  puts "<script type=\"text/javascript\">translatePage('#messagebox')</script>"
  global swVersion swUpdate
  cgi_javascript {
    puts "function getVersion(url, callback) {"
    puts "  var xhr = new XMLHttpRequest();"
    puts "  xhr.onreadystatechange = function () {"
    puts "    if (xhr.readyState === 4 && xhr.status === 200) callback(xhr.responseText);"
    puts "  };"
    puts "  xhr.open(\"GET\", url, true);"
    puts "  xhr.overrideMimeType(\"text/plain; charset=iso-8859-1\");"
    puts "  xhr.send();"
    puts "}"
    for {set i 0} {$i <= $loop} {incr i} {
      if { [info exists swUpdate($i)] } {
        puts "getVersion(\"$swUpdate($i)?cmd=check_version&version=$swVersion($i)\", function(contents) {"
        puts "  document.getElementById(\"availableSWVersion_$i\").innerHTML = contents;"
        puts "});"
        puts "document.getElementById(\"availableSWVersion_$i\").innerHTML = \"n/a\";"
      }
    }
  }
}

proc action_operation {} {
  global env
  
  http_head
  
  import script
  import op
  
  if {[catch {exec $script $op}]} {
    puts "Failure"
  }
  if { "$op" == "uninstall" } {
    exec rm -rf $script
  }
  puts "Success"
}

proc action_image_upload {} {
  global env sid
  cd /tmp/
  
  http_head
  import_file -client firmware_file
  if {[getProduct] < 3} {
    # CCU2
    file rename -force -- [lindex $firmware_file 0] "/var/new_firmware.tar.gz"
  } else {
    # CCU3
    file rename -force -- [lindex $firmware_file 0] "/usr/local/tmp/new_addon.tar.gz"
  }
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=$sid\";"
    puts {
      parent.top.dlgPopup.hide();
      parent.top.dlgPopup.setWidth(600);
      parent.top.dlgPopup.LoadFromFile(url, "action=install_confirm");
    }
  }
}

proc action_install_start {} {
  if {[getProduct] == 3} {
     exec touch /usr/local/.doAddonInstall
     exec /sbin/reboot
  } else {
    # CCU 2
    exec /bin/kill -SIGQUIT 1
  }
  
}

cgi_eval {
  #cgi_debug -on
  cgi_input
  catch {
    import debug
    cgi_debug -on
  }

  set action "put_page"

  catch { import action }

  if {[session_requestisvalid 8] > 0} then action_$action
}
