#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce common.tcl
sourceOnce backup.tcl
load tclrega.so
load tclrpc.so

array set LOGLEVELS {
  1 "\${dialogSettingsCMLogLevel0}"
  2 "\${dialogSettingsCMLogLevel1}"
  4 "\${dialogSettingsCMLogLevel2}"
  5 "\${dialogSettingsCMLogLevel3}"
}

array set REGA_LOGLEVELS {
  0 "\${dialogSettingsCMLogLevel0}"
  1 "\${dialogSettingsCMLogLevel1}"
  2 "\${dialogSettingsCMLogLevel3}"
  3 "\${dialogSettingsCMLogLevel4}"
}

set portnumber 2001
catch { source "/etc/eq3services.ports.tcl" }
if { [info exists EQ3_SERVICE_RFD_PORT] } {
  set portnumber $EQ3_SERVICE_RFD_PORT
}

set RFD_URL "bin://127.0.0.1:$portnumber"

set portnumber 2000
catch { source "/etc/eq3services.ports.tcl" }
if { [info exists EQ3_SERVICE_HS485D_PORT] } {
  set portnumber $EQ3_SERVICE_HS485D_PORT
}
set HS485D_URL "bin://127.0.0.1:$portnumber"
# set PFMD_URL "bin://127.0.0.1:2002" - not necessary with the ccu2


if {[getProduct] < 3} {
  set REMOTE_FIRMWARE_SCRIPT "https://update.homematic.com/firmware/download"
} else {
  set REMOTE_FIRMWARE_SCRIPT "https://ccu3-update.homematic.com/firmware/download"
}

proc action_acceptEula {} {
  global env sid

  cgi_javascript {
    set action "firmware_update_confirm"
    puts "var url = \"$env(SCRIPT_NAME)?sid=$sid\";"
    puts "var lang = getLang();"

    puts "var req = jQuery.ajax({"
      puts " url : \"/EULA.\"+lang,"
      puts " dataType: \"html\""
    puts "});"

    puts "req.done(function(data) {"
      puts "conInfo(\"EULA found\");"
      puts "jQuery('#fwUpload').hide();"
      puts "var dlg = new EulaDialog(translateKey('dialogEulaTitle'), data, function(result) {"
        puts "if (result == 1) {"
          puts "parent.top.dlgPopup.hide();"
          puts "parent.top.dlgPopup.setWidth(450);"
          puts "parent.top.dlgPopup.LoadFromFile(url, \"action=$action\");"
        puts "} else {"
          puts "jQuery('#fwUpload').hide();"
          puts "dlgPopup.hide();"
          puts "dlgPopup.setWidth(800);"
          puts "dlgPopup.LoadFromFile(url, \"action=firmware_update_cancel\");"
        puts "}"
      puts "}, 'html');"
      puts "dlg.centerDialog();"
    puts "}),"

    puts "req.fail(function(data) {"
      puts "conInfo(\"EULA not available\");"
      puts "parent.top.dlgPopup.hide();"
      puts "parent.top.dlgPopup.setWidth(450);"
      puts "parent.top.dlgPopup.LoadFromFile(url, \"action=$action\");"
    puts "});"
  }
}

proc action_firmware_update_confirm {} {
  global env
   cgi_debug -on
  http_head
  division {class="popupTitle"} {
    #puts "Softwareupdate - Best&auml;tigung"
    puts "\${dialogSettingsCMDialogPerformSoftwareUpdateStartTitle}"
  }
  division {class="CLASS20900 j_translate"} {
    table {class="popupTable CLASS20901"} {border="1"} {
      table_row {
        table_data {
          table {class="CLASS20909"} {
            table_row {
              table_data {colspan="2"} {
                puts {
                  ${dialogSettingsCMDialogPerformSoftwareUpdateStart}
                }
              }
            }
            table_row {
              table_data {
                #puts "Schritt 4: Softwareupdate starten"
                puts "\${dialogSettingsCMDialogPerformSoftwareLblUpdateStart}"
              }
              table_data {
                division {class="popupControls CLASS20905"} {
                  table {
                    table_row {
                      table_data {
                        division {class="CLASS20906"} {id="updateGo"} {onClick="UpdateGo();"} {
                          #puts "Update starten"
                          puts "\${dialogSettingsCMDialogPerformSoftwareBtnUpdateStart}"
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
        table_data {class="CLASS20907"} {
          division {class="CLASS20908"} {onClick="OnBack();"} {
            #puts "Zur&uuml;ck"
            puts "\${dialogBack}"
          }
        }
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "jQuery('#fwUpload').hide();"

    puts "translatePage('#messagebox');"

    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      UpdateGo = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=firmware_update_go");
      }
      OnBack = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(800);
        dlgPopup.LoadFromFile(url, "action=firmware_update_cancel");
      }
    }
    puts "dlgPopup.readaptSize();"
  }
}

proc action_firmware_update_invalid {} {
  global env downloadOnly
   
  http_head
  division {class="popupTitle"} {
    puts "\${dialogSettingsCMErrorTitle}"
  }
  division {class="CLASS20900"} {
    table {class="popupTable CLASS20901"} {border="1"} {
      table_row {
        table_data {
          table {class="CLASS20913"} {
            table_row {
              table_data {
                puts {
                  ${dialogSettingsCMErrorSoftwareUpdate}
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
        table_data {class="CLASS20907"} {
          division {class="CLASS20908"} {onClick="OnBack();"} {
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
        OnBack = function() {
          dlgPopup.hide();
          if (dlgPopup.downloadOnly == 1) {
          showNewFirmwareDownload();
          } else {
          dlgPopup.setWidth(800);
          dlgPopup.LoadFromFile(url);
          }
        }
      }
    puts "translatePage('#messagebox');"
    puts "jQuery('#fwUpload').hide();"
    puts "dlgPopup.readaptSize();"
  }
}

proc action_firmware_update_go {} {
  global env

  if {[getProduct] < 3 } {
     cd /tmp/
  } else {
    cd /usr/local/tmp/
  }

  http_head

  put_message "\${dialogSettingsCMDialogPerformSoftwareUpdateTitle}" {
    <p class="CLASS20914">
    ${dialogSettingsCMDialogPerformSoftwareUpdateP1}
    </p>
    <p class="CLASS20914">
      ${dialogSettingsCMDialogPerformSoftwareUpdateP2}
      <ol class="CLASS20915">
        <li>${dialogSettingsCMDialogPerformSoftwareUpdateLi1}</li>
        <li>
        ${dialogSettingsCMDialogPerformSoftwareUpdateLi2}
        </li>
        <li>${dialogSettingsCMDialogPerformSoftwareUpdateLi3}</li>
      </ol>
    </p>
  } "_empty_"  
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts "dlgPopup.readaptSize();"
    puts {
      if (typeof regaMonitor != "undefined") {
        regaMonitor.stop();
        InterfaceMonitor.stop();
      }
      //var pb = "action=update_start";
      //var opts = {
      //  postBody: pb,
      //  sendXML: false
      //};
      //new Ajax.Request(url, opts);
      window.location.href=url+"&action=update_start"
    }
  }
}

proc action_firmware_update_cancel {} {
  global env

  if {[getProduct] < 3} {
    catch {exec rm /var/new_firmware.tar.gz}
    catch { exec /bin/sh -c "rm /var/EULA.*"}
    cgi_javascript {
      puts {
        startHmIPServer();
      }
    }
  } else {
   catch { exec /bin/sh -c "rm -rf `readlink -f /usr/local/.firmwareUpdate` /usr/local/.firmwareUpdate" }
   catch { exec /bin/sh -c "rm -f /usr/local/tmp/EULA.*"}
   catch { exec /bin/sh -c "rm -f /usr/local/tmp/update_script"}
  }

  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      dlgPopup.setWidth(800);
      dlgPopup.LoadFromFile(url);
    }
  }
}

proc put_message {title msg args} {
  division {class="popupTitle"} {
    puts $title
  }
  division {class="CLASS20900"} {
    table {class="popupTable CLASS20916"} {border="1"} {
      table_row {class="CLASS20917"} {
        table_data {
          puts $msg
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        if { [llength $args] < 1 } { set args {{"Zur&uuml;ck" "PopupClose();"}}}
        # - - - wernerf - - -
        # Wenn die Liste leer ($args == "_empty_") ist, dann sollen keine Schalt-
        # fl�chen ausgegeben werden
        if {"_empty_" == $args} { set args "" }
        # - - - wernerf - - -
        foreach b $args {
          table_data {class="CLASS20907"} {
            division {class="CLASS20908"} "onClick=\"[lindex $b 1]\"" {
              puts [lindex $b 0]
            }
          }
        }
      }
    }
  }

  cgi_javascript {
    puts "translatePage('#messagebox');"
  }
}

proc checkIfFwOnly {} {
  global downloadOnly
  if {$downloadOnly == 1} {
  puts "<script type='text/javascript'>jQuery('.j_fwUpdateOnly').hide();</script>"
  }
}

proc action_put_page {} {
  global env sid REMOTE_FIRMWARE_SCRIPT LOGLEVELS REGA_LOGLEVELS RFD_URL HS485D_URL downloadOnly
  http_head

  division {class="popupTitle j_translate"} {
    puts "\${dialogSettingsCMTitle}"
    #puts [isOldCCU]
  }
  
  division {class="CLASS20918"}  {

    set styleMaxWidth ""
    #set styleMaxWidth "style=max-width:70px;"

    table {class="popupTable CLASS20901 j_translate"} {border="1"} {
      table_row {class="CLASS20902"} {
        table_data {class="CLASS20903"} $styleMaxWidth {
          #puts "Zentralen-<br>"
          #puts "Software"
          puts "\${dialogSettingsCMTDCCUSoftware}"
        }
        table_data {class="CLASS20904"} {width="400"} {
          table {class="CLASS20909"} {
            set cur_version [get_version]
            set serial [get_serial]
            table_row {
              table_data {align="left"} {colspan="2" id="actualSWVersion"} {
                puts "\${dialogSettingsCMLblActualSoftwareVersion}"
              }
              table_data {
                puts "$cur_version"
              }
            }
            table_row {
              table_data {align="left"} {colspan="2"} {
                puts "\${dialogSettingsCMLblAvailableSoftwareVersion}"
              }
              table_data {id="availableSWVersion"} {
                # This doesn�t work properly
                # puts [iframe "$REMOTE_FIRMWARE_SCRIPT?cmd=check_version&version=$cur_version&serial=$serial&lang=de&product=HM-CCU2" marginheight=0 marginwidth=0 frameborder=0 width=100 height=20 {scrolling="no"} ]
                # The available version will be set further down with "jQuery('#availableSWVersion').html(homematic.com.getLatestVersion());"
              }
            }
            table_row {
              table_data {align="left"} {colspan="3"} {
                #puts "[bold "Software-Update durchf�hren"]"
                puts "<b>\${dialogSettingsCMLblPerformSoftwareUpdate}</b>"
              }
            }
            table_row {
              table_data {align="left"} {colspan="3"} {
                  division {class="popupControls CLASS20905"} {
                  table {
                    table_row {
                      table_data {
                        division {class="CLASS20905" style="display: none"} {id="btnFwDirectDownload"} {} "onClick=\"performDirectDownload();\"" {}
                        division {class="CLASS20905"}  "onClick=\"showCCULicense(true);\"" {puts "\${btnDirectFwUpload}"}
                      }
                    }
                  }
                }
              }
            }
            table_row {
              table_data {align="left"} {colspan="3"} {
                #puts "[bold "i18n: Alternative Vorgehensweise:"]"
                puts "<b>\${dialogSettingsCMLblAlternateSoftwareUpdate}</b>"
              }
            }
            table_row {
              td {width="20"} {}
              table_data {align="left"} {
                puts "\${dialogSettingsCMLblPerformSoftwareUpdateStep1}"
              }
              table_data {
                division {class="popupControls CLASS20905"} {
                  table {
                    table_row {
                      table_data {
                        division {class="CLASS20908" style="display: none"} {id="btnFwDownload"} {} "onClick=\"window.location.href='$REMOTE_FIRMWARE_SCRIPT?cmd=download&version=$cur_version&serial=$serial&lang=de&product=HM-CCU[getProduct]';\"" {}
                        division {class="CLASS20908"}  "onClick=\"showCCULicense(false);\"" {puts "\${dialogSettingsCMBtnPerformSoftwareUpdateDownload}"}
                      }
                    }
                  }
                }
              }
            }
            table_row {
              td {width="20"} {}
              table_data {align="left"} {colspan="2"} {
                puts "\${dialogSettingsCMLblPerformSoftwareUpdateStep2}"
              }
            }
            table_row {
              td {width="20"} {}
              table_data {colspan="2"} {
                form "$env(SCRIPT_NAME)?sid=$sid" name=firmware_form {target=firmware_upload_iframe} enctype=multipart/form-data method=post {
                  export action=firmware_upload
                  export downloadOnly=$downloadOnly
                  file_button firmware_file size=30 maxlength=1000000
                }
                puts {<iframe name="firmware_upload_iframe" style="display: none;"></iframe>}
              }
            }
            table_row {
              td {width="20"} {}
              table_data {align="left"} {
                puts "\${dialogSettingsCMLblPerformSoftwareUpdateStep3}"
              }
              table_data {
                division {class="popupControls CLASS20905"} {
                  table {
                    table_row {
                      table_data {
                        division {class="CLASS20919"} {onClick="stopHmIPServer();document.firmware_form.submit();showUserHint();"} {
                          puts "\${dialogSettingsCMBtnPerformSoftwareUpdateUpload}"
                        }
                      }
                    }
                  }
                }
              }
            }
            table_row {
              td {width="20"} {}
              table_data {align="left"} {colspan="2"} {class="CLASS20920"} {
                puts "\${dialogSettingsCMLblPerformSoftwareUpdateStep4}"
              }
            }
          }
        }
        table_data {align="left"} {class="CLASS20921"} {
          puts "\${dialogSettingsCMHintSoftwareUpdate1}"
          number_list {class="j_noForcedUpdate"} {
            li {
              ${dialogSettingsCMHintSoftwareUpdate2}            }
            li {
               ${dialogSettingsCMHintSoftwareUpdate3}
            }
            li {
               ${dialogSettingsCMHintSoftwareUpdate3a}
            }
            set bat_level [get_bat_level]
            if {$bat_level < 50} {
              set msg " \${dialogSettingsCMHintSoftwareUpdate4a} $bat_level%. "
              append msg  \${dialogSettingsCMHintSoftwareUpdate4b}
              li $msg
            }
          }

          division {class="j_forcedUpdate" style="padding:10px;"} {
            puts "<br/>\${dialogSettingsCMHintSoftwareUpdate2}"
          }
        }
      }
      table_row {class="CLASS20902 j_noForcedUpdate j_fwUpdateOnly"} {
        table_data {class="CLASS20903"} $styleMaxWidth {
          #puts "Zentralen-<br>"
          #puts "Neustart"
          puts "\${dialogSettingsCMTDCCURestart}"

        }
        table_data {class="CLASS20904"} {
          division {class="popupControls CLASS20905"} {
            division {class="CLASS20910"} {onClick="OnReboot();"} {
              puts "\${dialogSettingsCMBtnCCURestart}"
            }
          }
        }
        table_data {align="left"} {class="CLASS20904"} {
          puts "\${dialogSettingsCMHintRestart}"
        }
      }

      if {[getProduct] >= 3} {
        table_row {class="CLASS20902 j_noForcedUpdate j_fwUpdateOnly"} {
          table_data {class="CLASS20903"} $styleMaxWidth {
            puts "\${dialogSettingsCMTDCCUShutdown}"
          }
          table_data {class="CLASS20904"} {
            division {class="popupControls CLASS20905"} {
              division {class="CLASS20910"} {onClick="OnShutdown();"} {
                puts "\${dialogSettingsCMBtnCCUShutdown}"
              }
            }
          }
          table_data {align="left"} {class="CLASS20904"} {
            puts "\${dialogSettingsCMHintShutdown}"
          }
        }
      }

      # Abgesicherter Modus
      table_row {class="CLASS20902 j_noForcedUpdate j_fwUpdateOnly"} {
        table_data {class="CLASS20903"} $styleMaxWidth {
          #puts "Abgesicherter<br>"
          #puts "Modus"
          puts "\${dialogSettingsCMTDCCUSafeMode}"
        }
        table_data {class="CLASS20904"} {
          division {class="popupControls CLASS20905"} {
            division {class="CLASS20910 colorGradient50px"} {onClick="OnEnterSafeMode();"} {
              puts "\${dialogSettingsCMBtnCCURestartSafe}"
            }
          }
        }
        table_data {align="left"} {class="CLASS20904"} {
          puts "\${dialogSettingsCMHintRestartSafeMode}"
        }
      }

      # Version Logikschicht
      table_row {class="CLASS20902 j_noForcedUpdate j_fwUpdateOnly"} {

        table_data {class="CLASS20903"} $styleMaxWidth {
        puts "\${lblTDRegaVersion}"
        }

        table_data {class="CLASS20904"} {

        table {class="CLASS20909"} {
          table_row {
          table_data {
            puts "\${dialogHelpInfoLblVersion}"
          }
          table_data {align="left"} {
            puts "<select id='selectedReGaVersion'>"
            puts "<option value='NORMAL'>\${optionReGaNORMAL}</option>"
            # puts "<option value='LEGACY'>\${optionReGaLEGACY}</option>"
            puts "<option value='COMMUNITY'>\${optionReGaCOMMUNITY}</option>"
            puts "</select>"
          }
          }

          table_row {
          table_data {}
          table_data {align="left"} {
            division {class="popupControls CLASS20905"} {
            division {class="CLASS20919"} {style="margin-top:10px; margin-left:0px;"} {onClick="saveRegaVersion(this);"} {
              puts "\${btnSave}"
            }
            }
          }
          }
        }
        }

        table_data {align="left"} {class="CLASS20904"} {
        # division {Class="StdTableBtnHelp"} {puts "<img id='showReGaVersionHelp' src='/ise/img/help.png'>"}
        division {Class="StdTableBtnHelp"} {puts "\${lblTDReGaVersionHelp}"}
        }
      }

      cgi_javascript {
        puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
        puts {

         jQuery("#showReGaVersionHelp").click(function() {
        MessageBox.show(translateKey("tooltipHelp"), translateKey("lblTDReGaVersionHelp"), "", 600, 250);
         });

        homematic("User.getReGaVersion",{}, function(result) {
          if (result) {
          jQuery("#selectedReGaVersion").val(result);
          } else {
          jQuery("#selectedReGaVersion").val("NORMAL");
          }
        });

        saveRegaVersion = function(elm) {
          jQuery(elm).css({"border-width" : "2px"});
          var selectedReGa = jQuery("#selectedReGaVersion").val();
          homematic("User.setReGaVersion", {"ReGaVersion": selectedReGa}, function() {
          jQuery(elm).css({"border-width" : "1px"});

          var dlgYesNo = new YesNoDialog(translateKey("dialogPerformRebootTitle"), translateKey("dialogRestart2ChanceReGaVersion"), function(result) {
            if (result == YesNoDialog.RESULT_YES)
            {
            dlgPopup.hide();
            dlgPopup.setWidth(400);
            dlgPopup.LoadFromFile(url, "action=reboot_confirm");
            }
          });
          dlgYesNo.btnTextYes(translateKey("dialogBtnPerformRestart"));
          dlgYesNo.btnTextNo(translateKey("dialogBtnPerformLaterRestart"));
          });
        }
        }
      }

      table_row {class="CLASS20902 j_noForcedUpdate j_fwUpdateOnly"} {
        table_data {class="CLASS20903"} $styleMaxWidth  {
          #puts "Fehler-<br>"
          #puts "protokoll"
          puts "\${dialogSettingsCMTDErrorProtocol}"
        }
        table_data {class="CLASS20904"} {
          table {class="CLASS20909"} {
            table_row {
              table_data {
                table {class="CLASS20909"} {
                  table_row {
                    table_data {align="left"} {
                      puts "\${dialogSettingsCMLblLogBidCosRF}"
                    }
                    table_data {align="right"} {
                      if [catch { set cur_level [xmlrpc $RFD_URL logLevel]  } ] {set cur_level 0}
                      cgi_select log_rfd= {id="select_log_rfd"} {
                        foreach level [lsort [array names LOGLEVELS]] {
                          set selected [expr { $level == $cur_level ? "selected":""}]
                          # process a country entry
                          cgi_option $LOGLEVELS($level) value=$level $selected
                        }
                      }
                    }
                  }
                  table_row {
                    table_data {align="left"} {
                      puts "\${dialogSettingsCMLblLogBidCosWired}"
                    }
                    table_data {align="right"} {
                    if [catch { set cur_level [xmlrpc $HS485D_URL logLevel]  } ] {set cur_level 0}
                      cgi_select log_hs485d= {id="select_log_hs485d"} {disabled} {
                        foreach level [lsort [array names LOGLEVELS]] {
                          set selected [expr { $level == $cur_level ? "selected":""}]
                          cgi_option $LOGLEVELS($level) value=$level $selected
                        }
                      }
                    }
                  }
                  set comment {
                    # This was the entry for the display of the ccu1
                    table_row {
                      table_data {align="left"} {
                        puts "\${dialogSettingsCMLblLogCentralControl}"
                      }
                      table_data {align="right"} {
                      if [catch { set cur_level [xmlrpc $PFMD_URL logLevel]  } ] {set cur_level 0}
                        cgi_select log_pfmd= {id="select_log_pfmd"} {
                          foreach level [lsort [array names LOGLEVELS]] {
                            set selected [expr { $level == $cur_level ? "selected":""}]
                            cgi_option $LOGLEVELS($level) value=$level $selected
                          }
                        }
                      }
                    }
                  }
                  table_row {
                    table_data {align="left"} {
                      puts "\${dialogSettingsCMLblLogLogic}"
                    }
                    table_data {align="right"} {
                    if [catch { set cur_level [rega system.LogLevel()]  } ] {set cur_level 2}
                      cgi_select log_rega= {id="select_log_rega"} {
                        foreach level [lsort [array names REGA_LOGLEVELS]] {
                          set selected [expr { $level == $cur_level ? "selected":""}]
                          cgi_option $REGA_LOGLEVELS($level) value=$level $selected
                        }
                      }
                    }
                  }
                  table_row {
                    table_data {align="left"} {
                      puts "\${dialogSettingsCMLblLogSysLogServerAddress}"
                    }
                    table_data {align="right"} {
                      catch {cgi_text log_server=[get_logserver] {size="25"} {id="text_log_server"}}
                    }
                  }
                  table_row {
                    table_data {
                    }
                    table_data {align="left"} {
                      division {class="popupControls CLASS20905"} {
                        division {class="CLASS20910"} {onClick="apply_logging();"} {
                          puts "\${dialogSettingsCMBtnLogSysLogServerAddress}"
                        }
                      }
                    }
                  }
                  table_row {
                    table_data {align="left"} {colspan="2"} {
                      division {class="popupControls CLASS20905"} {
                        division {class="CLASS20910"} "onClick=\"window.location.href='$env(SCRIPT_NAME)?sid=$sid&action=download_logfile';\"" {
                          puts "\${dialogSettingsCMBtnLogLoadLogFile}"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        table_data {align="left"} {class="CLASS20904"} {
          #puts "Hier stellen Sie die Anzahl der Logmeldungen ein, die die verschiedenen Softwareteile der Zentrale generieren.<br>"
          #puts "Sie k&ouml;nnen au&szlig;erdem einen Rechner angeben, dem die Zentrale ihre Logmeldungen per Syslog schickt."
          #puts "Auf diesem Rechner mu&szlig; entsprechende Software installiert sein, die die Meldungen entgegennimmt.<br>"
          #puts "Zu Diagnosezwecken k&ouml;nnen Sie sich die aktuellen Logmeldungen der Zentrale in einer Textdatei herunterladen."

          puts "\${dialogSettingsCMHintErrorLog}"
        }
      }
    }
    checkIfFwOnly
  }
  division {class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS20907 j_translate"} {
          division {class="CLASS20908"} {onClick="PopupClose();"} {
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
      apply_logging = function() {
        var pb = "action=apply_logging";
        pb += "&level_rfd="+document.getElementById("select_log_rfd").value;
        pb += "&level_hs485d="+document.getElementById("select_log_hs485d").value;
        //pb += "&level_pfmd="+document.getElementById("select_log_pfmd").value;
        pb += "&level_rega="+document.getElementById("select_log_rega").value;
        pb += "&log_server="+document.getElementById("text_log_server").value;
        
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            if (!transport.responseText.match(/^Success/g)){
              alert(translateKey("setLoggingFailure") + transport.responseText);
            } else if (transport.responseText.match(/^Success -confirm/g))
              alert(translateKey("setLoggingSuccess"));
          }
        };
        new Ajax.Request(url, opts);
      }
    }
    puts {
      OnReboot = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=reboot_confirm");
      }
      
      OnShutdown = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=shutdown_confirm");
      }
      
      OnEnterSafeMode = function() {
        new YesNoDialog(translateKey("dialogSafetyCheck"), translateKey("dialogQuestionRestartSafeMode"), function(result) {
        if (result == YesNoDialog.RESULT_YES)
        {
          MessageBox.show(translateKey("dialogRestartSafeModeTitle"), translateKey("dialogRestartSafeModeContent"), function() {
          window.location.href = "/";
          });
          homematic("SafeMode.enter");
        }
        });
      }
    }


    puts {

      showUserHint = function() {
        var elem = jQuery('#fwUpload');
        if (elem.length == 0) {
          MessageBox.show(
          translateKey('dialogSettingsCMDialogHintPerformFirmwareUploadTitle'),
          translateKey('dialogSettingsCMDialogHintPerformFirmwareUploadContent')+
          ' <br/><br/><img id="msgBoxBarGraph" src="/ise/img/anim_bargraph.gif"><br/>',
          '','320','105','fwUpload', 'msgBoxBarGraph');
        } else {
          elem.show();
        }
      }

      
      hideUserHint = function() {
        var elem = jQuery('#fwUpload');
        if (elem.length == 0) {
        } else {
          elem.hide();
          elem.remove();
        }
      }

      stopHmIPServer = function() {
        if( getProduct() < 3 ) {
          InterfaceMonitor.stop();
          homematic('User.stopHmIPServer' , {} );
        }
      }

      startHmIPServer = function() {
        if( getProduct() < 3 ) {
          homematic('User.startHmIPServer',{});
          InterfaceMonitor.start();
        }
      }
    }

    puts {
      showCCULicense = function(directDownload) {
      ShowWaitAnim();
      HideWaitAnimAutomatically(60);
      if (showDummyLicense == "true") {
        homematic.com.showCCUDummyLicense(function (result) {
        HideWaitAnim();
        var dlg = new EulaDialog(translateKey('dialogEulaTitle'), result ,function(userAction) {
          if (userAction == 1) {
            if(directDownload) {
              jQuery("#btnFwDirectDownload").click();
            } else {
              jQuery("#btnFwDownload").click();
            }
          }
        }, "html");
        });
      } else {
        homematic.com.showCCULicense(function (result) {
        window.clearTimeout(timeoutBargraph);
        MessageBox.close();
        HideWaitAnim();
        jQuery("#homematic_license_script").remove();
        var dlg = new EulaDialog(translateKey('dialogEulaTitle'), result ,function(userAction) {
          if (userAction == 1) {
            if(directDownload) {
              jQuery("#btnFwDirectDownload").click();
            } else {
              jQuery("#btnFwDownload").click();
            }
          }
        }, "html");
        });
      }

      }
    }
  }

  cgi_javascript {

    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      performDirectDownload = function(result) {
        showUserHint();
        ShowWaitAnim();
        HideWaitAnimAutomatically(60);
        stopHmIPServer();
        homematic('CCU.downloadFirmware' , {}, function(result) {
          if(result === true) {
              dlgPopup.LoadFromFile(url, "action=firmware_upload&directDownload=true");
          } else {
              console.log(result);
              startHmIPServer();
          }
        });
      }
    }
  }

  cgi_javascript {
    puts "translatePage('#messagebox');"
    puts "jQuery('#messagebox').show();"
    puts "var latestVersion = translateKey('lblAvailableFirmwareVersionNotKnown');"
    puts "latestVersion = homematic.com.getLatestVersion();"
    puts "if (latestVersion == undefined || isNaN(parseInt(latestVersion.split('.')\[0\]))) {latestVersion = translateKey('lblAvailableFirmwareVersionNotKnown');}"
    puts "jQuery('#availableSWVersion').html(latestVersion);"

    # Hide all elements with class j_noForcedUpdate when an update is enforced
    puts "if (forceUpdate) {"
    puts "jQuery('.j_noForcedUpdate').hide();"
    puts "jQuery('.j_forcedUpdate').show();"
    puts "} else {jQuery('.j_forcedUpdate').hide();}"

    puts "dlgPopup.readaptSize();"

    #puts "var arrTransIDs = \['actualSWVersion', 'availableSWVersion'\];"
    #puts "jQuery.each(arrTransIDs, function(index, id) \{ jQuery('#'+id).text(translateKey(jQuery('#'+id).text())) ;\});"
  }

  cgi_javascript {
    puts {
    homematic("Interface.getLGWStatus", {"interface": "BidCos-Wired"}, function(lgwStatus) {
      var wiredLogSelector = jQuery("#select_log_hs485d");
      if (lgwStatus != null) {
      // Enable logging for the wired gateway
      wiredLogSelector.removeAttr('disabled');
      }
    });
    }
  }
}

proc get_serial { } {
  return [read_var /var/ids SerialNumber]
}

proc action_askCreateBackup {} {
  global env sid
  
  http_head
  division {class="popupTitle"} {
    puts "\${dialogSettingsSecurityMessageCreateSysBackupTitle}"
  }
  division {class="CLASS20900"} {
    table {class="popupTable CLASS20901"} {border="1"} {
      table_row {
        table_data {
          table {class="CLASS20913"} {
            table_row {
              table_data {
                  puts {
                    <div class="CLASS01805">
                      <label for="accept">
                        <input type="checkbox" id="accept" name="accept" value="yes" checked="true">${dialogAskCreateBakupCheckboxText}</label>
                    </div>
                    <div class="CLASS01805"><label>${dialogAskCreateBakupText}</label></div>
                    <div class="CLASS01805"/>
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
        table_data {class="CLASS20907"} {
          division {class="CLASS20908"} {onClick="OnOk();"} {
            puts "\${btnNext}"
          }
        }
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
      puts {
        OnOk = function() {
          const cb = document.getElementById('accept');
          const action = "acceptEula";
          if(cb.checked) {
            //window.location.href=url+"&action=createBackup";
            var pb = "action=createBackup";
            var opts = {
              postBody: pb,
              sendXML: false,
              asynchronous: false
            };
            new Ajax.Request(url, opts);
          } 
          dlgPopup.hide();
          dlgPopup.setWidth(800);
          dlgPopup.LoadFromFile(url, "&action=acceptEula");
          
        }
      }
    puts "translatePage('#messagebox');"
    puts "jQuery('#fwUpload').hide();"
    puts "dlgPopup.readaptSize();"
  }

}

proc action_createBackup {} {
  http_head
  catch { exec touch /tmp/createBackup }
}

proc action_firmware_upload {} {

  global env sid downloadOnly

  if { [catch { import directDownload } error] } {
    set directDownload false
  }
  
  http_head
  
  if { $directDownload } {
    set filename "/tmp/fup.tgz"
  } else {
    import_file -client firmware_file
    set filename [lindex $firmware_file 0]
  }

  if {[getProduct] < 3} {
    cd /tmp/
    # check if the uploaded file looks like a firmware file
    set file_valid 0
    catch {
      exec tar zxvf $filename update_script EULA.en EULA.de -C /var/
    }
    set file_valid [file exists "/var/update_script"]

    if {$file_valid} {
      file rename -force -- $filename "/var/new_firmware.tar.gz"
      set action "askCreateBackup"
    } else {
      file delete -force -- [lindex $firmware_file 0]
      cgi_javascript {
        puts {
          startHmIPServer();
        }
      }
      set action "firmware_update_invalid"
    }
  } else {

    cd /usr/local/tmp/
    set TMPDIR "[file tail $filename-dir]"
    exec mkdir -p $TMPDIR

    #
    # check if the uploaded file is a valid firmware update file
    #

    set file_invalid [catch {exec tar zxvf $filename update_script EULA.en EULA.de -C /usr/local/}]

    # check for .tar.gz or .tar
    if {$file_invalid == 0} {
      set file_invalid [catch {exec file -b $filename | egrep -q "(gzip compressed|tar archive)"} result]
      if {$file_invalid == 0} {
        # the file seems to be a tar archive (perhaps with gzip compression)
        set file_invalid [catch {exec /bin/tar -C $TMPDIR --no-same-owner -xmf $filename} result]
        file delete -force -- $filename
      }
    }

    #
    # test if the above checks were successfull or not
    #
    if {$file_invalid == 0} {
      catch { exec ln -sf tmp/$TMPDIR /usr/local/.firmwareUpdate }
      #set action "acceptEula"
      set action "askCreateBackup"
    } else {
      file delete -force -- $filename
      file delete -force -- $filename-dir
      set action "firmware_update_invalid"
    }

  }

  if { $directDownload } {
    
    cgi_javascript {
      puts "hideUserHint();"
    }
  }

  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=$sid\";"
    puts "parent.top.dlgPopup.hide();"
    puts "parent.top.dlgPopup.setWidth(450);"
    puts "parent.top.dlgPopup.downloadOnly = $downloadOnly;"
    puts "parent.top.dlgPopup.LoadFromFile(url, \"action=$action\");"
  }
}

proc action_reboot_confirm {} {
  global env
   
  http_head
  division {class="popupTitle"} {
    puts "\${dialogSafetyCheck}"
  }
  division {class="CLASS20900"} {
    table {class="popupTable CLASS20901"} {border="1"} {
      table_row {
        table_data {
          table {class="CLASS20909"} {width="100%"} {
            table_row {
              table_data {colspan="3"} {
                puts "\${dialogQuestionRestart}"
              }
            }            
            table_row {
              table_data {align="right"} {class="CLASS20911"} {colspan="3"} {
                division {class="popupControls CLASS20905"} {
                  division {class="CLASS20910"} {onClick="OnNextStep()"} {
                    puts "\${dialogBtnPerformRestart}"
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
        table_data {class="CLASS20907"} {
          division {class="CLASS20908"} {onClick="dlgPopup.hide();showMaintenanceCP();"} {
            puts "\${btnCancel}"
          }
        }
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      OnNextStep = function() {
        if (typeof regaMonitor != "undefined") {
          regaMonitor.stop();
          InterfaceMonitor.stop();
        }
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=reboot_go");
      }
    }
    puts "dlgPopup.readaptSize();"
    puts "translatePage('#messagebox')"
  }
# Speichern wird beim Neustart durchgef�hrt, siehe action_reboot  
#  rega system.Save()
}

proc action_reboot_go {} {
  global env
  cd /tmp/
  
  http_head

  put_message "\${dialogPerformRebootTitle}" {
    ${dialogPerformRebootContent}
  } {"\${btnNewLogin}" "window.location.href='/';"}

  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      var pb = "action=reboot";
      var opts = {
        postBody: pb,
        sendXML: false
      };
      new Ajax.Request(url, opts);
    }
  }
}

proc action_shutdown_confirm {} {
   global env
   
  http_head
  division {class="popupTitle"} {
    puts "\${dialogSafetyCheck}"
  }
  division {class="CLASS20900"} {
    table {class="popupTable CLASS20901"} {border="1"} {
      table_row {
        table_data {
          table {class="CLASS20909"} {width="100%"} {
            table_row {
              table_data {colspan="3"} {
              puts "\${dialogQuestionShutdown}"
              }
            }            
            table_row {
              table_data {align="right"} {class="CLASS20911"} {colspan="3"} {
                division {class="popupControls CLASS20905"} {
                  division {class="CLASS20910"} {onClick="OnNextStep()"} {
                    puts "\${dialogBtnPerformShutdown}"
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
        table_data {class="CLASS20907"} {
          division {class="CLASS20908"} {onClick="dlgPopup.hide();showMaintenanceCP();"} {
            puts "\${btnCancel}"
          }
        }
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      OnNextStep = function() {
        if (typeof regaMonitor != "undefined") {
          regaMonitor.stop();
          InterfaceMonitor.stop();
        }
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=shutdown_go");
      }
    }
    puts "dlgPopup.readaptSize();"
    puts "translatePage('#messagebox')"
  }
}

proc action_shutdown_go {} {
  global env
  cd /tmp/
  
  http_head

  put_message "\${dialogPerformShutdownTitle}" {
    ${dialogPerformShutdownContent}
  } "_empty_"

  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      var pb = "action=shutdown";
      var opts = {
        postBody: pb,
        sendXML: false
      };
      new Ajax.Request(url, opts);
    }
  }
}

proc action_update_start {} {
  if { [file exists "/tmp/createBackup"] } {
    catch { [create_backup] }
  }

  catch { exec killall hss_lcd }
  catch { exec lcdtool {Saving   Data...  } }
  rega system.Save()
  catch { exec lcdtool {Reboot...       } }

  if {[getProduct] < 3} {
    exec /bin/kill -SIGQUIT 1
  } else {
    exec touch /usr/local/.recoveryMode
    exec sleep 5
    exec /sbin/reboot
  }

}

proc action_reboot {} {
  catch { exec killall hss_lcd }
  catch { exec lcdtool {Saving   Data...  } }
  rega system.Save()
  catch { exec lcdtool {Reboot...       } }
  exec sleep 5
  exec /sbin/reboot
}
proc action_shutdown {} {
  catch { exec killall hss_lcd }
  catch { exec lcdtool {Saving   Data...  } }
  rega system.Save()
  catch { exec lcdtool {Shutdown...       } }
  exec sleep 5
  catch { exec touch /tmp/shutdown }
  exec /sbin/poweroff
}

proc get_logserver {} {
  return [read_var //etc/config/syslog LOGHOST]
}

# proc set_log_config {loghost level_rfd level_hs485d level_pfmd level_rega}
proc set_log_config {loghost level_rfd level_hs485d level_rega} {
  #global RFD_URL HS485D_URL PFMD_URL
  global RFD_URL HS485D_URL

  set fd -1
  catch {set fd [open "/etc/config/syslog" w]}
  if { $fd <0 } { return 0 }
  
  if { "$loghost" != "" } {
  puts $fd "LOGHOST=$loghost"
  }
  puts $fd "LOGLEVEL_RFD=$level_rfd"
  puts $fd "LOGLEVEL_HS485D=$level_hs485d"
  # puts $fd "LOGLEVEL_PFMFD=$level_pfmd"
  puts $fd "LOGLEVEL_REGA=$level_rega"
  close $fd
  
  catch { xmlrpc $RFD_URL logLevel [list int $level_rfd]}
  catch { xmlrpc $HS485D_URL logLevel [list int $level_hs485d]}
  # catch { xmlrpc $PFMD_URL logLevel [list int $level_pfmd]}
  rega "system.LogLevel($level_rega)"
  
  return 1
}

proc action_apply_logging {} {
  import log_server
  import level_rfd
  import level_hs485d
  # import level_pfmd
  import level_rega
  
  http_head
  
  # if {![set_log_config $log_server $level_rfd $level_hs485d $level_pfmd $level_rega]}
  if {![set_log_config $log_server $level_rfd $level_hs485d $level_rega]} {
    puts "Failure"
    return
  }
  catch {exec killall syslogd}
  catch {exec killall klogd}
  exec /etc/init.d/S07logging start
  puts "Success -confirm"
}

proc action_download_logfile {} {
  set HOSTNAME [exec hostname]
  set iso8601_date [exec date -Iseconds]
  regexp {^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)([+-]\d+)$} $iso8601_date dummy year month day hour minute second zone
  
  puts "Content-Type:application/x-download"
  puts "Content-Disposition:attachment;filename=[set HOSTNAME]-$year-$month-$day.log\n"
  
  cd /var/log
  foreach f {messages.1 messages.0 messages hmserver.log.1 hmserver.log} {
    catch {
      set fd [open $f r]
      puts -nonewline "\r\n***** $f *****\r\n"
      while { ! [eof $fd]} {
        puts -nonewline "[gets $fd]\r\n"
      }
      close $fd
    }
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
  set downloadOnly 0
  set filename ""
  catch {import action}
  catch {import downloadOnly}
  catch {import filename}

  if {[session_requestisvalid 8] > 0} then action_$action
}


