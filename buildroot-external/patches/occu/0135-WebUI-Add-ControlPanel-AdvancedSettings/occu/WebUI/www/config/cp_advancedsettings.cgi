#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce common.tcl

load tclrpc.so
load tclrega.so

set INETCHECKFILENAME "/etc/config/internetCheckDisabled"
set RPI4USB3CHECKFILENAME "/etc/config/rpi4usb3CheckDisabled"
#set MEDIOLAFILENAME "/usr/local/addons/mediola/Disabled"
set MEDIOLAFILENAME "/etc/config/neoDisabled"
set CLOUDMATICFILENAME "/etc/config/cloudmaticDisabled"
set NOUPDATEDCVARSFILENAME "/etc/config/NoUpdateDCVars"
set NOBADBLOCKSCHECKFILENAME "/etc/config/NoBadBlocksCheck"
set NOPORTFORWARDINGCHECKFILENAME "/etc/config/NoPortForwardingCheck"
set ALLOWEXTERNALACCESSFILENAME "/etc/config/AllowExternalAccess"
set NOFSTRIMFILENAME "/etc/config/NoFSTRIM"
set NOADDONUPDATECHECKFILENAME "/etc/config/NoAddonUpdateCheck"
set DISABLELEDFILENAME "/etc/config/disableLED"
set DISABLEONBOARDLEDFILENAME "/etc/config/disableOnboardLED"
set CUSTOMSTORAGEPATHFILENAME "/etc/config/CustomStoragePath"
set HBRFETHIPADDRESSFILENAME "/etc/config/hb_rf_eth"

set NOCRONBACKUPFILENAME "/etc/config/NoCronBackup"
set CRONBACKUPMAXBACKUPSFILENAME "/etc/config/CronBackupMaxBackups"
set CRONBACKUPPATHFILENAME "/etc/config/CronBackupPath"

set TWEAKFILENAME "/etc/config/tweaks"

proc get_systemname {} {
  set isecmd "string systemname = system.Name();"
  array set result [rega_script $isecmd]
  if { $result(systemname) == "ReGaRA Demo" || $result(systemname) == "" } {
    set res ""
  } else {
    set res $result(systemname)
  }
  return $res;
}

proc set_systemname { systemname } {
  # SECURITY: the value is interpolated into a single-quoted ReGaScript string
  # literal below and executed by ReGaHss as root. Escape backslash and single
  # quote so an attacker-supplied systemName cannot break out of the literal and
  # inject arbitrary ReGaScript (e.g. system.Exec). Single pass: \ -> \\, ' -> \'
  set systemname [string map {\\ \\\\ ' \\'} $systemname]
  set isecmd "system.Name('$systemname');"
  array set result [rega_script $isecmd]
  return $result(STDOUT);
}

proc createfile { filename } {
 set result ""

 if {![file exists $filename]} {
   catch {exec touch $filename} e

   if {[string trim $e] != ""} {
    set result "error createfile $filename \n"
   }
 }
 return $result
}

proc deletefile { filename } {
 set result ""
 
 if {[file exists $filename]} {
   catch {exec rm -f $filename} e

   if {[string trim $e] != ""} {
     set result "error deletefile $filename \n"
   }
 } 
 return $result
}

proc read_var_from_file { filename varname } {
  set var ""

  set fd -1
  catch { set fd [open $filename r] }
  if { $fd >=0 } {
      while { [gets $fd buf] >=0 } {
        if [regexp "^ *$varname *= *(.*)$" $buf dummy var] break
      }
    close $fd
  }

  return $var
}

proc readfile { filename } {
  set content ""
  if { [file exists $filename] } {
    set fd [open $filename r]
    set content [read $fd]
  }
  return $content
}

proc writefile { filename content } { 
  set fd -1
  catch {set fd [open $filename w]}
  if { $fd <0 } {return "$filename write error\n" }
  
  puts $fd $content
  close $fd
  return ""
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
        if {"_empty_" == $args} { set args "" }
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

proc action_put_page {} {
  global env sid INETCHECKFILENAME RPI4USB3CHECKFILENAME MEDIOLAFILENAME CLOUDMATICFILENAME NOCRONBACKUPFILENAME NOUPDATEDCVARSFILENAME NOBADBLOCKSCHECKFILENAME NOPORTFORWARDINGCHECKFILENAME ALLOWEXTERNALACCESSFILENAME NOFSTRIMFILENAME NOADDONUPDATECHECKFILENAME CRONBACKUPMAXBACKUPSFILENAME CRONBACKUPPATHFILENAME CUSTOMSTORAGEPATHFILENAME HBRFETHIPADDRESSFILENAME TWEAKFILENAME DISABLELEDFILENAME DISABLEONBOARDLEDFILENAME
   
  set inetcheckDisabled [file exists $INETCHECKFILENAME]
  set rpi4usb3CheckDisabled [file exists $RPI4USB3CHECKFILENAME]
  set mediolaDisabled [file exists $MEDIOLAFILENAME]
  set cloudmaticDisabled [file exists $CLOUDMATICFILENAME]
  set noCronBackup [file exists $NOCRONBACKUPFILENAME]
  set noDCVars [file exists $NOUPDATEDCVARSFILENAME]
  set noBadBlocksCheck [file exists $NOBADBLOCKSCHECKFILENAME]
  set noPortforwardingCheck [file exists $NOPORTFORWARDINGCHECKFILENAME]
  set allowExternalAccess [file exists $ALLOWEXTERNALACCESSFILENAME]
  set noFSTRIM [file exists $NOFSTRIMFILENAME]
  set noAddonUpdateCheck [file exists $NOADDONUPDATECHECKFILENAME]
  set disableLED [file exists $DISABLELEDFILENAME]
  set disableOnboardLED [file exists $DISABLEONBOARDLEDFILENAME]
  
  set cronBackupMaxBackups [readfile $CRONBACKUPMAXBACKUPSFILENAME]
  set cronBackupPath [readfile $CRONBACKUPPATHFILENAME]
  set customStoragePath [readfile $CUSTOMSTORAGEPATHFILENAME]
  set hbrfethIPAddress [readfile $HBRFETHIPADDRESSFILENAME]

  set tweaks [read_var_from_file $TWEAKFILENAME CP_DEVCONFIG]
  set systemName [get_systemname]

  http_head
  
  division {class="popupTitle"} {
    puts "\${dialogSettingsAdvancedSettingsTitle}"
  }
  division {class="CLASS21114 j_translate"} {
    division {style="height:75vh;width:100%;overflow:auto;"} {
    table {class="popupTable"} {border=1} {width="100%"} {height="100%"} {
      table_row {class="CLASS21115"} {
        table_data {class="CLASS21116"} {
          puts "\${dialogSettingsAdvancedSettingsWatchDog}"
          puts "<br/><img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:21px; height:21px; vertical-align:middle;\" onclick=\"OnToggleHelp();\">"
        }
        table_data {align=left} {class="CLASS02533"} {
          table {
            table_row {
              set checked ""
              if {!$inetcheckDisabled} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=inetcheckDisabled {id="cb_inetcheckDisabled"} $checked
                puts "\${dialogSettingsAdvancedSettingsInternetCheck}"
              }
            }
            table_row {
              set checked ""
              if {!$rpi4usb3CheckDisabled} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=rpi4usb3CheckDisabled {id="cb_rpi4usb3CheckDisabled"} $checked
                puts "\${dialogSettingsAdvancedSettingsRpi4usb3Check}"
              }
            }
          }
        }
        table_data {class="CLASS21113"} {align="left"} {
          p { ${dialogSettingsAdvancedSettingsHintWatchDogCheck1} }
          p { ${dialogSettingsAdvancedSettingsHintWatchDogCheck2} }
        }
      }
      table_row {class="CLASS21115"} {
        table_data {class="CLASS21116"} {
          puts "\${dialogSettingsAdvancedSettingsSystem}"
          puts "<br/><img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:21px; height:21px; vertical-align:middle;\" onclick=\"OnToggleHelp();\">"
        }
        table_data {align=left} {class="CLASS02533"} {
          table {
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
            table_row {
              table_data {class="CLASS21112"} {
                puts "\${dialogSettingsAdvancedSettingsSystemName}"
              }
              table_data  {
                cgi_text systemName=$systemName {id="text_systemName"} {size=30}
              }
            }
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
            table_row {
              set checked ""
              if {!$noCronBackup} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=noCronBackup {id="cb_noCronBackup"} $checked
                puts "\${dialogSettingsAdvancedSettingsCronBackup}"
              }
            }
            table_row {
              table_data {class="CLASS21112"} {
                puts "\${dialogSettingsAdvancedSettingsCronBackupPath}"
              }

              table_data  {
                cgi_text cronBackupPath=$cronBackupPath {id="text_cronBackupPath"} {size=30}
              }
            }
            table_row {
              table_data {class="CLASS21112"} {
                puts "\${dialogSettingsAdvancedSettingsCronBackupMaxBackups}"
              }

              table_data  {
                cgi_text cronBackupMaxBackups=$cronBackupMaxBackups {id="text_cronBackupMaxBackups"} {size=5} {onpaste="validateNumber(this.value, this.id);"} {onkeyup="validateNumber(this.value, this.id);"}
              }
            }
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
            table_row {
              set checked ""
              if {!$noDCVars} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=noDCVars {id="cb_noDCVars"} $checked
                puts "\${dialogSettingsAdvancedSettingsDCVars}"
              }
            }
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
            table_row {
              set checked ""
              if {!$disableLED} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=disableLED {id="cb_disableLED"} $checked
                puts "\${dialogSettingsAdvancedSettingsDisableLED}"
              }
            }
            table_row {
              set checked ""
              if {!$disableOnboardLED} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=disableOnboardLED {id="cb_disableOnboardLED"} $checked
                puts "\${dialogSettingsAdvancedSettingsDisableOnboardLED}"
              }
            }
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
            table_row {
              set checked ""
              if {!$noPortforwardingCheck} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=noPortforwardingCheck {id="cb_noPortforwardingCheck"} $checked
                puts "\${dialogSettingsAdvancedSettingsPortforwardingCheck}"
              }
            }
            table_row {
              set checked ""
              if {!$allowExternalAccess} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=allowExternalAccess {id="cb_allowExternalAccess"} $checked
                puts "\${dialogSettingsAdvancedSettingsAllowExternalAccess}"
              }
            }
            table_row {
              set checked ""
              if {!$noAddonUpdateCheck} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=noAddonUpdateCheck {id="cb_noAddonUpdateCheck"} $checked
                puts "\${dialogSettingsAdvancedSettingsAddonUpdateCheck}"
              }
            }
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
            table_row {
              set checked ""
              if {!$noBadBlocksCheck} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=noBadBlocksCheck {id="cb_noBadBlocksCheck"} $checked
                puts "\${dialogSettingsAdvancedSettingsBadBlocksCheck}"
              }
            }
            table_row {
              set checked ""
              if {!$noFSTRIM} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=noFSTRIM {id="cb_noFSTRIM"} $checked
                puts "\${dialogSettingsAdvancedSettingsFSTRIM}"
              }
            }
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
            table_row {
              table_data {class="CLASS21112"} {
                puts "\${dialogSettingsAdvancedSettingsCustomStoragePath}"
              }

              table_data  {
                cgi_text customStoragePath=$customStoragePath {id="text_customStoragePath"} {size=30}
              }
            }
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
            table_row {
              set checked ""
              if {!$mediolaDisabled} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=mediolaDisabled {id="cb_mediolaDisabled"} $checked
                puts "\${dialogSettingsAdvancedSettingsMediola}"
              }
            }
            table_row {
              set checked ""
              if {!$cloudmaticDisabled} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=cloudmaticDisabled {id="cb_cloudmaticDisabled"} $checked
                puts "\${dialogSettingsAdvancedSettingsCloudmatic}"
              }
            }
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
            table_row {
              table_data {class="CLASS21112"} {
                puts "\${dialogSettingsAdvancedSettingHBRFETHIPAddress}"
              }

              table_data  {
                cgi_text hbrfethIPAddress=$hbrfethIPAddress {id="text_hbrfethIPAddress"} {size=30}
              }
            }
            table_row { table_data {class="CLASS21112"} {colspan="3"} { puts "\<hr>" } }
          }
        }
        table_data {class="CLASS21113"} {align="left"} {
          p { ${dialogSettingsAdvancedSettingsHintSystem11} }
          p { ${dialogSettingsAdvancedSettingsHintSystem1} }
          p { ${dialogSettingsAdvancedSettingsHintSystem2} }
          p { ${dialogSettingsAdvancedSettingsHintSystem3} }
          p { ${dialogSettingsAdvancedSettingsHintSystem4} }
          p { ${dialogSettingsAdvancedSettingsHintSystem5} }
          p { ${dialogSettingsAdvancedSettingsHintSystem6} }
          p { ${dialogSettingsAdvancedSettingsHintSystem12} }
          p { ${dialogSettingsAdvancedSettingsHintSystem16} }
          p { ${dialogSettingsAdvancedSettingsHintSystem13} }
          p { ${dialogSettingsAdvancedSettingsHintSystem7} }
          p { ${dialogSettingsAdvancedSettingsHintSystem8} }
          p { ${dialogSettingsAdvancedSettingsHintSystem9} }
          p { ${dialogSettingsAdvancedSettingsHintSystem10} }
          p { ${dialogSettingsAdvancedSettingsHintSystem14} }
          p { ${dialogSettingsAdvancedSettingsHintSystem15} }
        }
      }

      table_row {class="CLASS21115"} {
        table_data {class="CLASS21116"} {
          puts "\${dialogSettingsAdvancedSettingsExpert}"
          puts "<br/><img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:21px; height:21px; vertical-align:middle;\" onclick=\"OnToggleHelp();\">"
        }
        table_data {align=left} {class="CLASS02533"} {
          table {
            table_row {
              set checked ""
              if {$tweaks == ""} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=devConfig {id="cb_devConfig"} $checked
                puts "\${dialogSettingsAdvancedSettingsDevConfig}"
              }
            }

          }
        }
        table_data {class="CLASS21113"} {align="left"} {
          p { ${dialogSettingsAdvancedSettingsHintExpert1} }
        }
      }
    }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS21103"} {
          division {class="CLASS21108"} {onClick="PopupClose()"} {
            #puts "Abbrechen"
            puts "\${btnCancel}"
          }
        }
        table_data {class="CLASS21103"} {
          division {id="btnOK"} {class="CLASS21108"} {onClick="OnOK()"} {
            #puts "OK"
            puts "\${btnOk}"
          }
        }
        table_data {class="CLASS21109"} {align=right} {
          division {class="CLASS21108"} {onClick="OnToggleHelp()"} {
            puts "\${tooltipHelp}&nbsp;<img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:21px; height:21px; vertical-align:middle;\" >"
          }
        }
      }
    }
  }

  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      dlgResult = 0;
      isHelpVisible = false;
      showHelp = function(enable) {
        isHelpVisible=enable;
        var infos = document.getElementsByClassName("CLASS21113");
        if (infos !== null) {
          for (const info of infos) { info.style.display = enable ? "block" : "none"; }
          dlgPopup.setWidth(enable ? 1020 : 600);
          dlgPopup.readaptSize();
        }
      }
      
      OnToggleHelp = function() {
        isHelpVisible = !isHelpVisible;
		showHelp(isHelpVisible);
      }
      
      OnOK = function() {
        var pb = "action=save_settings";
        pb += "&inetcheckDisabled="+(document.getElementById("cb_inetcheckDisabled").checked?"0":"1");
        pb += "&rpi4usb3CheckDisabled="+(document.getElementById("cb_rpi4usb3CheckDisabled").checked?"0":"1");
        pb += "&mediolaDisabled="+(document.getElementById("cb_mediolaDisabled").checked?"0":"1");
        pb += "&cloudmaticDisabled="+(document.getElementById("cb_cloudmaticDisabled").checked?"0":"1");
        pb += "&noCronBackup="+(document.getElementById("cb_noCronBackup").checked?"0":"1");
        pb += "&noDCVars="+(document.getElementById("cb_noDCVars").checked?"0":"1");
        pb += "&noBadBlocksCheck="+(document.getElementById("cb_noBadBlocksCheck").checked?"0":"1");
        pb += "&noPortforwardingCheck="+(document.getElementById("cb_noPortforwardingCheck").checked?"0":"1");
        pb += "&allowExternalAccess="+(document.getElementById("cb_allowExternalAccess").checked?"0":"1");
        pb += "&disableLED="+(document.getElementById("cb_disableLED").checked?"0":"1");
        pb += "&disableOnboardLED="+(document.getElementById("cb_disableOnboardLED").checked?"0":"1");
        pb += "&noFSTRIM="+(document.getElementById("cb_noFSTRIM").checked?"0":"1");
        pb += "&noAddonUpdateCheck="+(document.getElementById("cb_noAddonUpdateCheck").checked?"0":"1");
        pb += "&devConfig="+(document.getElementById("cb_devConfig").checked?"0":"1");
        pb += "&cronBackupPath="+encodeURIComponent(document.getElementById("text_cronBackupPath").value);
        pb += "&cronBackupMaxBackups="+encodeURIComponent(document.getElementById("text_cronBackupMaxBackups").value);
        pb += "&customStoragePath="+encodeURIComponent(document.getElementById("text_customStoragePath").value);
        pb += "&hbrfethIPAddress="+encodeURIComponent(document.getElementById("text_hbrfethIPAddress").value);
        pb += "&systemName="+escape(document.getElementById("text_systemName").value);

        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            if (transport.responseText === "") {   
              dlgPopup.hide();
              dlgPopup.setWidth(400);
              PopupClose();
            } else { 
              alert(translateKey("dialogSettingsAdvancedSettingsMessageAlertMessageError1") + "\n" +transport.responseText); 
            }
          }
        };
        new Ajax.Request(url, opts);
      }      
    }
    
    puts {
      translatePlaceholder = function() {
        document.getElementById("text_customStoragePath").placeholder=translateKey("dialogSettingsAdvancedSettingsCustomStoragePathPlaceholder");
        document.getElementById("text_hbrfethIPAddress").placeholder=translateKey("dialogSettingsAdvancedSettingHBRFETHIPAddressPlaceholder");
        document.getElementById("text_cronBackupPath").placeholder=translateKey("dialogSettingsAdvancedSettingsCronBackupPathPlaceholder");
        document.getElementById("text_cronBackupMaxBackups").placeholder="30";
        document.getElementById("text_systemName").placeholder=translateKey("dialogSettingsAdvancedSettingsSystemNamePlaceholder");
      };
    }
    
    puts {
      validateNumber = function(num, elmId) {
        var validator = /^(\s*|\d+)$/;
        var isValid = num.match(validator);
        btnOKElm = jQuery("#btnOK"),
        inputElm = jQuery("#"+elmId);

        if (isValid != null) {
         inputElm.css('background-color', '');
         btnOKElm.show();
        } else {
         inputElm.css('background-color', 'red');
         btnOKElm.hide();
        }
      };
    }

    puts "translatePlaceholder();"
    puts "translatePage('#messagebox');"
    puts "showHelp(false);"
  }
  
}

proc action_save_settings {} {
  global INETCHECKFILENAME RPI4USB3CHECKFILENAME MEDIOLAFILENAME CLOUDMATICFILENAME NOCRONBACKUPFILENAME NOUPDATEDCVARSFILENAME NOBADBLOCKSCHECKFILENAME NOPORTFORWARDINGCHECKFILENAME ALLOWEXTERNALACCESSFILENAME NOFSTRIMFILENAME NOADDONUPDATECHECKFILENAME CRONBACKUPMAXBACKUPSFILENAME CRONBACKUPPATHFILENAME CUSTOMSTORAGEPATHFILENAME HBRFETHIPADDRESSFILENAME TWEAKFILENAME DISABLELEDFILENAME DISABLEONBOARDLEDFILENAME
  set errMsg ""

  import inetcheckDisabled
  import rpi4usb3CheckDisabled
  import mediolaDisabled
  import cloudmaticDisabled
  import noCronBackup
  import noDCVars
  import disableLED
  import disableOnboardLED
  import noBadBlocksCheck
  import noPortforwardingCheck
  import allowExternalAccess
  import noFSTRIM
  import noAddonUpdateCheck
  import devConfig
  import cronBackupPath
  import cronBackupMaxBackups
  import customStoragePath
  import hbrfethIPAddress
  import systemName
  
  if {$systemName == ""} {
    append errMsg [set_systemname "ReGaRA Demo"]
  } else {
    append errMsg [set_systemname $systemName]
  }
  
  if {$inetcheckDisabled} {
    append errMsg [createfile $INETCHECKFILENAME]
  } else {
    append errMsg [deletefile $INETCHECKFILENAME]
  }
  
  if {$rpi4usb3CheckDisabled} {
    append errMsg [createfile $RPI4USB3CHECKFILENAME]
  } else {
    append errMsg [deletefile $RPI4USB3CHECKFILENAME]
  }

  set mediolaDisabledCurrent [file exists $MEDIOLAFILENAME]
  if {$mediolaDisabled} {
    append errMsg [createfile $MEDIOLAFILENAME]
  } else {
    append errMsg [deletefile $MEDIOLAFILENAME]
  }
  if {$mediolaDisabled != $mediolaDisabledCurrent} {
    catch {exec /etc/init.d/S97NeoServer restart 2>/dev/null >/dev/null}
  }
  
  set cloudmaticDisabledCurrent [file exists $CLOUDMATICFILENAME]
  if {$cloudmaticDisabled} {
    append errMsg [createfile $CLOUDMATICFILENAME]
  } else {
    append errMsg [deletefile $CLOUDMATICFILENAME]
  }
  if {$cloudmaticDisabled != $cloudmaticDisabledCurrent} {
    catch {exec /etc/init.d/S97CloudMatic restart 2>/dev/null >/dev/null}
  }

  if {$noCronBackup} {
    append errMsg [createfile $NOCRONBACKUPFILENAME]
  } else {
    append errMsg [deletefile $NOCRONBACKUPFILENAME]
  }
  
  if {$noDCVars} {
    append errMsg [createfile $NOUPDATEDCVARSFILENAME]
  } else {
    append errMsg [deletefile $NOUPDATEDCVARSFILENAME]
  }
  
  if {$disableLED} {
    append errMsg [createfile $DISABLELEDFILENAME]
  } else {
    append errMsg [deletefile $DISABLELEDFILENAME]
  }  

  if {$disableOnboardLED} {
    append errMsg [createfile $DISABLEONBOARDLEDFILENAME]
  } else {
    append errMsg [deletefile $DISABLEONBOARDLEDFILENAME]
  }  
  
  if {$noBadBlocksCheck} {
    append errMsg [createfile $NOBADBLOCKSCHECKFILENAME]
  } else {
    append errMsg [deletefile $NOBADBLOCKSCHECKFILENAME]
  }
  
  if {$noPortforwardingCheck} {
    append errMsg [createfile $NOPORTFORWARDINGCHECKFILENAME]
  } else {
    append errMsg [deletefile $NOPORTFORWARDINGCHECKFILENAME]
  }

  set allowExternalAccessCurrent [file exists $ALLOWEXTERNALACCESSFILENAME]
  if {$allowExternalAccess} {
    append errMsg [createfile $ALLOWEXTERNALACCESSFILENAME]
  } else {
    append errMsg [deletefile $ALLOWEXTERNALACCESSFILENAME]
  }
  if {$allowExternalAccess != $allowExternalAccessCurrent} {
    catch {exec /bin/setfirewall.tcl 2>/dev/null >/dev/null}
  }

  if {$noFSTRIM} {
    append errMsg [createfile $NOFSTRIMFILENAME]
  } else {
    append errMsg [deletefile $NOFSTRIMFILENAME]
  }

  if {$noAddonUpdateCheck} {
    append errMsg [createfile $NOADDONUPDATECHECKFILENAME]
  } else {
    append errMsg [deletefile $NOADDONUPDATECHECKFILENAME]
  }

  if {$devConfig} {
    append errMsg [writefile $TWEAKFILENAME "CP_DEVCONFIG=1"]
  } else {
    append errMsg [deletefile $TWEAKFILENAME]
  }
  
  if { $cronBackupMaxBackups == "" } {
    append errMsg [deletefile $CRONBACKUPMAXBACKUPSFILENAME]
  } else {
    append errMsg [writefile $CRONBACKUPMAXBACKUPSFILENAME $cronBackupMaxBackups]
  }
  
  if { $cronBackupPath == "" } {
    append errMsg [deletefile $CRONBACKUPPATHFILENAME]
  } else {
    append errMsg [writefile $CRONBACKUPPATHFILENAME $cronBackupPath]
  }
  
  if { $customStoragePath == "" } {
    append errMsg [deletefile $CUSTOMSTORAGEPATHFILENAME]
  } else {
    append errMsg [writefile $CUSTOMSTORAGEPATHFILENAME $customStoragePath]
  }

  if { $hbrfethIPAddress == "" } {
    append errMsg [deletefile $HBRFETHIPADDRESSFILENAME]
  } else {
    append errMsg [writefile $HBRFETHIPADDRESSFILENAME $hbrfethIPAddress]
  }
  
  # reload monit
  catch { exec /usr/bin/monit reload }

  puts "$errMsg"
}

cgi_eval {
  cgi_input
  set action "put_page"
  catch { import action }
  if {[session_requestisvalid 8] > 0} then action_$action
}
