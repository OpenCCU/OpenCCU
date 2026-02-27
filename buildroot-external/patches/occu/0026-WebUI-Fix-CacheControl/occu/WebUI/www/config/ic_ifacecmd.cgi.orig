#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce ic_common.tcl
loadOnce tclrpc.so

#Datenbank der Geraetebeschreibungen fuers WebUI
sourceOnce devdescr/DEVDB.tcl 
  
set cmd ""

proc cmd_removeLink {} {

  global iface_url USERPROFILESPATH
  set sender_address ""
  set receiver_address ""
  set iface ""

  catch { import iface }
  catch { import sender_address }
  catch { import receiver_address }

  set url $iface_url($iface)
  set HmIPIdentifier "HmIP-RF"
  set HmIPWiredIdentifier "HmIP-Wired"

  if { ![info exist env(IC_OPTIONS)] || ([string first NO_PROFILE_MAPPING $env(IC_OPTIONS)] < 0) } {

      # Verknuepfungen einlesen und in map_link ablegen
      if { ! [catch {open $USERPROFILESPATH/link.db RDONLY} fd] } then {
        while {![eof $fd]} {
            set map_link([gets $fd]) "true"
        }
        close $fd
      } 
  
      # Geloeschte Verknuepfung aus link.db entfernen
      if {[info exists map_link($sender_address-$receiver_address)]} {
            set fd [open $USERPROFILESPATH/link_tmp.db w+]
        foreach tmp [array names map_link] {
          if {$tmp != "$sender_address-$receiver_address" } {
                    puts $fd $tmp
          }
        }
        close $fd
        file rename -force $USERPROFILESPATH/link_tmp.db $USERPROFILESPATH/link.db
      } 
  }
    
  #cgi_debug -on

  set errorCode [catch {xmlrpc $url removeLink [list string $sender_address] [list string $receiver_address]}]

   if { (! $errorCode) || $iface == $HmIPIdentifier || $iface == $HmIPWiredIdentifier} then {
    #puts "<script type=\"text/javascript\">alert('Loeschen der Verknuepfung war erfolgreich!');</script>"
    cmd_ShowConfigPendingMsg
  } else {
    #puts "<script type=\"text/javascript\">alert('Loeschen der Verknuepfung war nicht erfolgreich!');</script>"
    puts "<script type=\"text/javascript\">alert(translateKey(\"dialogRemoveLinkFailed\"));</script>"
  }
}

proc cmd_setLinkInfo {} {

  global iface_url sid sidname

  set iface              ""
  set sender_address     ""
  set receiver_address   ""
  set name               ""
  set description        ""

  catch { import iface }
  catch { import sender_address }
  catch { import receiver_address }
  catch { import name }
  catch { import description }

  set url $iface_url($iface)

  if { [catch { xmlrpc $url setLinkInfo [list string $sender_address] [list string $receiver_address] [list string $name] [list string $description] } ] } then {
    #puts "<script type=\"text/javascript\">alert('Fehler beim Speichern des Verkn�pfungsnamen von $sender_address mit $receiver_address.');</script>"
    puts "<script type=\"text/javascript\">alert(translateKey('dialogSetLinkNameErrorA') + ' $sender_address ' + translateKey('dialogSetLinkNameErrorB') + ' $receiver_address.');</script>"
  } else {
  }
  #puts "<script type=\"text/javascript\">if (ProgressBar) ProgressBar.IncCounter(\"Name und Beschreibung von Verknuepfung $sender_address mit $receiver_address gesetzt.\");</script>"
  puts "<script type=\"text/javascript\">if (ProgressBar) ProgressBar.IncCounter(translateKey(\"dialogSetLinkInfoMsgSuccessA\")+\" $sender_address \"+translateKey(\"dialogSetLinkInfoMsgSuccessB\") + \" $receiver_address \" +translateKey(\"dialogSetLinkInfoMsgSuccessC\"));</script>"
}

proc cmd_addLink {} {

  global iface_url sid sidname

  #cgi_debug -on

  set iface              ""
  set sender_address     ""
  set sender_group       ""
  set receiver_address   ""
  set name               ""
  set description        ""
  set group_name         ""
  set group_description  ""
  set redirect_url       ""
  set actorDeviceTypeId  ""
  set specialVal ""

  set HmIPIdentifier "HmIP-RF"
  set HmIPWiredIdentifier "HmIP-Wired"

  catch { import iface }
  catch { import sender_address }
  catch { import sender_group }
  catch { import receiver_address }
  catch { import name }
  catch { import description }
  catch { import group_name }
  catch { import group_description }
  catch { import redirect_url }
  catch { import actorDeviceTypeId }
  catch { import specialVal }

  set url $iface_url($iface)

  set errorCode [catch { xmlrpc $url addLink [list string $sender_address] [list string $receiver_address] }]

  # errorCode -10 = config pending
  if { (! $errorCode) || ((($iface == $HmIPIdentifier)  || ($iface == $HmIPWiredIdentifier)) && ($errorCode == -10))  } then {

    #Verkn�pfung erfolgreich angelegt. Namen und Beschreibungen noch nicht gesetzt.
    set ret 1

    if {$actorDeviceTypeId == "HmIP-RGBW"} {

      # Mode RGBW/RGB
      if {($specialVal == 0) || ($specialVal == 1)} {
        set param "{LONG_DIM_MIN_HUE {int 0}}"
        xmlrpc $url putParamset [list string $receiver_address] [list string $sender_address] [list struct $param]
      }

      # Mode Tunable White
      if {$specialVal == 2} {
        array set masterParamset [xmlrpc $url getParamset [list string $receiver_address] [list string MASTER]]
        set param "{LONG_DIM_STEP_COLOR_TEMPERATURE {int 500}} {SHORT_ON_COLOR_TEMPERATURE {int $masterParamset(HARDWARE_COLOR_TEMPERATURE_COLD_WHITE)}} {SHORT_OFF_COLOR_TEMPERATURE {int $masterParamset(HARDWARE_COLOR_TEMPERATURE_WARM_WHITE)}}"
        xmlrpc $url putParamset [list string $receiver_address] [list string $sender_address] [list struct $param]
      }
    }

    if { $description != "" || $name != "" } then {

      if { [catch { xmlrpc $url setLinkInfo [list string $sender_address] [list string $receiver_address] [list string $name] [list string $description] } ] } then {
        #Verkn�pfung erfolgreich angelegt. Name und Beschreibung der ersten Verkn�pfung konnte nicht gesetzt werden.
        set ret -2
      } else {
        #Verkn�pfung erfolgreich angelegt. Name und Beschreibung der ersten Verkn�pfung erfolgreich gesetzt.
        set ret 2
      }
    }

    if { $group_description != "" || $group_name != "" } then {

      if { [catch { xmlrpc $url setLinkInfo [list string $sender_group] [list string $receiver_address] [list string $group_name] [list string $group_description] } ] } then {
        #Verkn�pfung erfolgreich angelegt. Name und Beschreibung der zweiten Verkn�pfung konnte nicht gesetzt werden.
        set ret -3
      } else {
        #Verkn�pfung erfolgreich angelegt. Name und Beschreibung der zweiten Verkn�pfung erfolgreich gesetzt.
        set ret 3
      }
    }

  } else {
    set ret -1
  }

  #puts "<script type=\"text/javascript\">var ConfigPendingFrm = AddLinkSuccessForm('$iface', '$sender_address', '$receiver_address', '$sidname', '$sid', '$redirect_url');</script>"

  #puts "<script type=\"text/javascript\">if (ProgressBar) ProgressBar.IncCounter(\"Verknuepfung wurde angelegt.\");</script>"
  puts "<script type=\"text/javascript\">if (ProgressBar) ProgressBar.IncCounter(translateKey(\"dialogCreateLinkSuccessProgressBar\"));</script>"
  cmd_ShowConfigPendingMsg "ADD_LINK"
}
proc cmd_ShowConfigPendingMsg {{extraParam ""}} {

  global iface_url sid sidname dev_descr_sender  
  
  array set ise_CHANNELNAMES ""
  ise_getChannelNames ise_CHANNELNAMES

  set HmIPIdentifier "HmIP-RF"
  set HmIPGroupID "HM-CC-VG"
  set VirtualDevicesID "VirtualDevices"

  set iface            ""
  set sender_address   ""
  set receiver_address ""
  set redirect_url     ""
  set go_back          "false"
  
  catch { import iface }
  catch { import sender_address }
  catch { import receiver_address }
  catch { import redirect_url }
  catch { import go_back }

  set url $iface_url($iface)
  
  #SENDER================================================================
  set sender_has_configpending 0

    catch { 
    array set dev_descr_sender [xmlrpc $url getDeviceDescription [list string $sender_address]]

    if {$dev_descr_sender(PARENT) == ""} then {
      #Ger�teadresse �bergeben
      set sender_type $dev_descr_sender(TYPE)
      set sender_parent $sender_address
    
    } else {
      #Kanaladresse �bergeben
      set sender_type $dev_descr_sender(PARENT_TYPE)
      set sender_parent $dev_descr_sender(PARENT)
    }

    if { [catch { set sendername $ise_CHANNELNAMES($iface;$sender_address)} ] } then {
      #ise kennt Ger�t nicht. Das hat nur Auswirkung auf den vollen Namen.
      #set sendername "Unbenanntes Ger&auml;t"
      set sendername "\${lblUnknownDevice}"
    }

    array set valueset_sender [xmlrpc $url getParamset [list string $sender_parent:0] [list string VALUES]]
    set sender_configpending [expr {$valueset_sender(CONFIG_PENDING)?"1":"0"} ]

    set sender_has_configpending 1
  }
  #======================================================================

  #RECEIVER==============================================================
  set receiver_has_configpending 0
  
  catch {
    array set dev_descr_receiver [xmlrpc $url getDeviceDescription [list string $receiver_address]]
    
    if {$dev_descr_receiver(PARENT) == ""} then {
      #Ger�teadresse �bergeben
      set receiver_type $dev_descr_receiver(TYPE)
      set receiver_parent $receiver_address
    } else {
      #Kanaladresse �bergeben
      set receiver_type $dev_descr_receiver(PARENT_TYPE)
      set receiver_parent $dev_descr_receiver(PARENT)
    }

    if { [catch { set receivername $ise_CHANNELNAMES($iface;$receiver_address)} ] } then {
      #ise kennt Ger�t nicht. Das hat nur Auswirkung auf den vollen Namen.
      #set receivername "Unbenanntes Ger&auml;t"
      set receivername "\${lblUnknownDevice}"
    }

    array set valueset_receiver [xmlrpc $url getParamset [list string $receiver_parent:0] [list string VALUES]]
    set receiver_configpending [expr {$valueset_receiver(CONFIG_PENDING)?"1":"0"} ]

    set receiver_has_configpending 1
  }
  #======================================================================

  #puts "<script type=\"text/javascript\">if (ProgressBar) ProgressBar.IncCounter(\"ConfigPending-PopUp wird angezeigt.\");</script>"
  puts "<script type=\"text/javascript\">"
  if {$iface == $VirtualDevicesID && (([string range $receiver_type 0 7] == $HmIPGroupID) || ([string range $receiver_type 0 7] == $HmIPGroupID)) } {
    puts "var data = '{ \"virtualDeviceSerialNumber\" : \"$sender_address\" }';"
    puts "CreateCPPopup(\"/pages/jpages/group/configureDevices\", data);"
  } else {
    puts "try \{"
    puts "  ConfigPendingFrm.ResetTable();"
    puts "\} catch (e) \{"
    puts "  ConfigPendingFrm = new ConfigPendingMsgBox(800, 600, '$extraParam');"
    puts "\}"

    if { $sender_has_configpending == 1 } then {
      puts "ConfigPendingFrm.ShowConfigPending('$iface', '$sender_address',   '[cgi_quote_html $sendername]',   '$sender_type',   parseInt($sender_configpending),   parseInt(-1), ConfigPendingFrm.CONFIGPENDING_SENDER);"
    } else {
      puts "ConfigPendingFrm.SetDevice('$iface', '$sender_address', ConfigPendingFrm.CONFIGPENDING_SENDER);"
    }

    if { $receiver_has_configpending == 1 } then {
      puts "ConfigPendingFrm.ShowConfigPending('$iface', '$receiver_address', '[cgi_quote_html $receivername]', '$receiver_type', parseInt($receiver_configpending), parseInt(-1), ConfigPendingFrm.CONFIGPENDING_RECEIVER);"
    } else {
      puts "ConfigPendingFrm.SetDevice('$iface', '$receiver_address', ConfigPendingFrm.CONFIGPENDING_RECEIVER);"
    }
    puts "ConfigPendingFrm.setReturnURL('$sidname', '$sid', '$redirect_url', $go_back);"
    puts "ConfigPendingFrm.show();"

  }
  puts "</script>"
}

proc cmd_activateLinkParamset {} {

  global iface_url

  set sender_address ""
  set receiver_address ""
  set iface ""

  catch { import iface }
  catch { import sender_address }
  catch { import receiver_address }

  set url $iface_url($iface)
  
  if { [catch { xmlrpc $url activateLinkParamset [list string $receiver_address] [list string $sender_address] [list bool 0] }  ] } then {
    #puts "<script type=\"text/javascript\">ShowErrorMsg(\"[cgi_quote_html "Das Profil konnte nicht ausgel�st werden. Sorgen Sie dazu bitte daf�r, dass sich das Ger�t innerhalb der Funkreichweite befindet und aktiv ist."]\");</script>"
    puts "<script type=\"text/javascript\">ShowErrorMsg(translateKey(\"dialogActivateLinkParamsetError\"));</script>"
  } else {
    #puts "<script type=\"text/javascript\">ShowInfoMsg(\"[cgi_quote_html "Das Profil wurde erfolgreich ausgel�st."]\");</script>"
    puts "<script type=\"text/javascript\">ShowInfoMsg(translateKey(\"dialogActivateLinkParamsetSuccess\"));</script>"
  }
}

proc getFwUpdateError {errorKey result} {

  # result looks like the following:
    # Fault received on xmlrpc call updateFirmware({"XYZ0004711"})
    # faultCode=-1
    # faultString=Bootloader in device XYZ0004711 didn't start

  # this will extract the given errorKey (faultCode or faultString)
  set errorCode [string range $result [expr [string first $errorKey $result]+ [string length $errorKey]] [string length $result]]
  set lineFeedPos [string first "\n" $errorCode ]
  if {$lineFeedPos == -1} {
    set lineFeedPos [string length $errorCode]
  }
  return [string range $errorCode 0 $lineFeedPos]
}

proc cmd_firmware_update {} {

  global iface_url

  set iface   ""
  set address ""

  set HmIPIdentifier "HmIP-RF"
  set HmIPWiredIdentifier "HmIP-Wired"

  set deviceIsHAP false
  set deviceIsDRAP false

  catch { import iface }
  catch { import address }

  set url $iface_url($iface)

  array set devDescr [xmlrpc $url getDeviceDescription [list string $address]]

  if { [string first "HmIP-HAP" $devDescr(TYPE)] != -1 } {
    set deviceIsHAP true
  }

  if { [string first "HmIPW-DRAP" $devDescr(TYPE)] != -1 } {
    set deviceIsDRAP true
  }

  if {($iface != $HmIPIdentifier)  && ($iface != $HmIPWiredIdentifier)} {
    catch {xmlrpc $url updateFirmware [list string $address]} result
  } else {
    # HmIP device
    catch {xmlrpc $url installFirmware [list string $address]} result
  }

  puts "<script type=\"text/javascript\">if (ProgressBar) ProgressBar.IncCounter(translateKey(\"dialogFirmwareUpdateCheckSuccess\"));</script>"
  if { $result == 1 } then {

    if {$deviceIsHAP || $deviceIsDRAP} {
        #This is for HAP and DRAP updates, which must be treated differently
        #Since the update was started successfully and the update is performed asynchronously, we need to check for the update state here
        #States UP_TO_DATE, LIVE_UP_TO_DATE and LIVE_NEW_FIRMWARE_AVAILABLE (negative case) cause an exit of wait loop. In addion there is a timeout of 10.5 minutes (crRFD has 10 minutes).  

      cgi_javascript {
        puts "var iface = \"$iface\","
        puts "address = \"$address\";"
        puts "var devDescr = homematic(\"Interface.getDeviceDescription\", {\"interface\": iface, \"address\": address});"
         puts {
            var fwInfoPanelElm = jQuery("#id_firmware_table_" + address),
            fwOverviewPageTDFirmware = jQuery("#deviceFirmware_" + address);
        
            var fw_update_rows = "<tr><td style=\"border-style:none\">"+translateKey('lblDeviceFwPerformUpdate')+"</td></tr>";  
            fwInfoPanelElm.html(fw_update_rows);

            var maxChecks = 126, // 126 Checks alle 5 Sekunden = 630 Sekunden = 10.5 Mins weil crRFD Timout liegt bei 10 Minuten
            numberOfChecks = 0,
            interval = 5000, // Check every 5 seconds
            updateTimer = null,
            messageUpdateProblem = false,
            firmwareUpdateFailed = false;

            var intervalCheckState = setInterval(function() {
          
              conInfo("Check state");
              var result = homematic("Interface.getDeviceDescription", {"interface": iface, "address": address}),
              firmwareUpdateState = result.firmwareUpdateState,
              firmware = result.firmware,
              availableFW = result.availableFirmware;

              conInfo("firmwareUpdateState: " + firmwareUpdateState);
              switch(firmwareUpdateState) {
                case "LIVE_DELIVER_FIRMWARE_IMAGE":
                //case "LIVE_NEW_FIRMWARE_AVAILABLE":
                    fw_update_rows = "<tr><td style=\"border-style:none\">"+translateKey('lblDeviceFwPerformUpdate')+"</td></tr>";  
                    fwInfoPanelElm.html(fw_update_rows);
                    conInfo("case LIVE_DELIVER_FIRMWARE_IMAGE");
                  break;
                case "UP_TO_DATE":
                case "LIVE_UP_TO_DATE":
                case "LIVE_NEW_FIRMWARE_AVAILABLE":
                    conInfo("HAP-/DRAP-Update finished");
                    clearInterval(intervalCheckState);
                    clearTimeout(updateTimer);
                    updateTimer = null;
                    conInfo("case LIVE_UP_TO_DATE,UP_TO_DATE/LIVE_NEW_FIRMWARE_AVAILABLE");
                    WebUI.enter(DeviceFirmwareInformation);
                  break;
              }
 
              numberOfChecks++;
              if (numberOfChecks >= maxChecks) {
                clearInterval(intervalCheckState);
                clearTimeout(updateTimer);
                updateTimer = null;
                WebUI.enter(DeviceFirmwareInformation);
              }

            }, interval);

         } 
		  }

    } else {
      puts "<script type=\"text/javascript\">"
        puts "ShowInfoMsg(translateKey(\"dialogFirmwareUpdateSuccess\"));"
        puts "if (InfoMsg) InfoMsg.OnOK = function () {InfoMsg.hide(); window.setTimeout(function() {WebUI.enter(DeviceFirmwareInformation);},100); }"
      puts "</script>"
    }
  } else {
    # The errorCode is the error as an integer as returned from the xmlrpc call 'updateFirmware' and can be -1, -2 and so on
    # errorCode -1 = Device not reachable
    # errorCode -2 = Invalid access point, device or channel
    # errorCode -3 = Unknown Parametset
    # errorCode -5 = Invalid parameter or value
    # errorCode -10 = Legacy API says 'Transmission Pending'

    set errorCode [getFwUpdateError "faultCode=" $result]
    set userHint "dialogFirmwareUpdateUnknownError"
    if {$errorCode == -1 || $errorCode == -10} {
      set userHint "fwUpdatePressSystemKey"
    }

    # The errorString is the error in plain text as returned from the xmlrpc call 'updateFirmware'
    set errorString [getFwUpdateError "faultString=" $result]

    if {$errorCode == -1} {
      # puts "<script type=\"text/javascript\">ShowErrorMsg(\"$errorString\" + \"<br/><br/>\" + translateKey(\"dialogFirmwareUpdateFailed\") +\"<br/><br/>\"+ translateKey(\"$userHint\"));</script>"
      puts "<script type=\"text/javascript\">ShowErrorMsg(translateKey(\"dialogFirmwareUpdateFailed\") +\"<br/><br/>\"+ translateKey(\"$userHint\"));</script>"
    } else {
     cgi_javascript {
      # puts "ShowInfoMsg('$errorString' + '<br/><br/>' + translateKey('$userHint'));"
      puts "ShowInfoMsg(translateKey('$userHint'));"
      
      # This is for the HmIP-SWSD
      if {([string equal $devDescr(TYPE) "HmIP-SWSD"] == 1) || ([string equal $devDescr(TYPE) "HmIP-SWSD-2"] == 1)} {
        puts "var iface = \"$iface\","
        puts "address = \"$address\";"
        puts "var devDescr = homematic(\"Interface.getDeviceDescription\", {\"interface\": iface, \"address\": address});"
        puts {

            var fwInfoPanelElm = jQuery("#id_firmware_table_" + address),
            fwOverviewPageTDFirmware = jQuery("#deviceFirmware_" + address);

            var firmwareUpdateState = devDescr.firmwareUpdateState,
            firmware = devDescr.firmware,
            availableFW = devDescr.availableFirmware;

            // Zeige "Ger�t nicht erreichbar, dr�cke Konfig-Button" und pr�fe 5 Minuten lang, ob sich der Status �ndert.
            //�ndert sich der Status nicht, zeige wieder den Update-Button,
            //�ndert sich der Status, starte entsprechende Aktion

            // Zeige initial Config Pending
            if (firmwareUpdateState == "READY_FOR_UPDATE") {
              fwInfoPanelElm.html("<tr><td style=\"border-style:none\">"+translateKey('lblPressSystemButton')+"</td></tr>");
            } else {
              fwInfoPanelElm.html("<tr><td></td></tr>");
            }

            var maxChecks = 60, // 60 Checks alle 5 Sekunden = 300 Sekunden = 5 Mins
            numberOfChecks = 0,
            interval = 5000, // Check every 5 seconds
            timeForReInclusion = 60000, // One minute
            updateTimer = null,
            messageUpdateProblem = false,
            firmwareUpdateFailed = false;

            var intervalCheckState = setInterval(function() {
              conInfo("Check state");

              // Hole devDescr des Ger�tes
              var result = homematic("Interface.getDeviceDescription", {"interface": iface, "address": address}),
              firmwareUpdateState = result.firmwareUpdateState,
              firmware = result.firmware,
              availableFW = result.availableFirmware;

              conInfo("firmwareUpdateState: " + firmwareUpdateState);

              switch (firmwareUpdateState) {
                case "READY_FOR_UPDATE":
                  // As long as the user didn't press the config button of the SWSD the firmwareUpdateState is "READY_FOR_UPDATE"
                  fw_update_rows = "<tr><td style=\"border-style:none\">"+translateKey('lblPressSystemButton')+"</td></tr>";
                  fwInfoPanelElm.html(fw_update_rows);
                  break;
                case "DO_UPDATE_PENDING":
                case "PERFORMING_UPDATE":
                  // This shouldn't last very long - some seconds maximum.

                  if (!updateTimer) {
                    // Timer, which shows a message after one minute that the update wasn't successful.
                    updateTimer = setTimeout(function() {
                      messageUpdateProblem = true;

                      homematic("Interface.setMetadata_crRFD", {
                        'interface': 'HmIP-RF',
                        'objectId' : address + ":1",
                        'dataId' : 'smokeTestDone',
                        'value' : false
                      });

                      MessageBox.show(translateKey("dialogHint"),translateKey("hintReInclusionDetectorFailed"),function(){
                        messageUpdateProblem = false;
                        clearTimeout(updateTimer);
                        updateTimer = null;
                        firmwareUpdateFailed = true;
                      }, 400, 80);
                    },timeForReInclusion);
                  }
                  if (InfoMsg) {
                      InfoMsg.hide();
                  }
                  if (firmwareUpdateFailed == true) {
                    fw_update_rows = "<tr><td class=\"CLASS22006\">"+translateKey('dialogFirmwareUpdateFailed')+"</td></tr>";
                    fw_update_rows +=  "<tr id=\"swsdHintCheckDevice\"><td colspan=\"2\"><span class=\"attention\">"+translateKey("checkSmokeDetectorSelfTest")+"</span></td></tr>";
                  } else {
                    fw_update_rows = "<tr><td class=\"_CLASS22006 noBorder\">"+translateKey('lblDeviceFwPerformUpdate')+"</td></tr>";
                  }
                  fwInfoPanelElm.html(fw_update_rows);
                  break;
                case "UP_TO_DATE":
                  // Firmware successful delivered - Show actual firmware, clear the updateTimer and stop checking.
                  clearTimeout(updateTimer);
                  updateTimer = null;

                  if (messageUpdateProblem) {
                    MessageBox.close();
                  }

                  if (InfoMsg) {
                      InfoMsg.hide();
                  }
                  fw_update_rows = "<tr><td>"+translateKey('lblFirmwareVersion')+"</td><td class=\"CLASS22006\">"+firmware+"</td></tr>";
                  fw_update_rows += "<tr id=\"swsdHintCheckDevice\"><td colspan=\"2\"><span class=\"attention\">"+translateKey("checkSmokeDetectorSelfTest")+"</span></td></tr>";

                  if (fwOverviewPageTDFirmware.length == 1) {
                    // This is the firmware overview page
                    fwOverviewPageTDFirmware.text(firmware);
                    fwInfoPanelElm.html("");
                  } else {
                    // this is the device parameter page
                    fwInfoPanelElm.html(fw_update_rows);
                  }
                  clearInterval(intervalCheckState);

                  homematic("Interface.setMetadata_crRFD", {
                    'interface': 'HmIP-RF',
                    'objectId' : address + ":1",
                    'dataId' : 'smokeTestDone',
                    'value' : false
                  });

                  MessageBox.show(translateKey("dialogHint"),translateKey("hintActivateDetectorSelfTest"),'', 400, 80);
                  break;
              }

              numberOfChecks++;
              if (numberOfChecks >= maxChecks) {
                clearInterval(intervalCheckState);
                clearTimeout(updateTimer);
                updateTimer = null;

                if (messageUpdateProblem) {
                  MessageBox.close();
                }

                if (InfoMsg) {
                    InfoMsg.hide();
                }
                var fw_update_rows = "";
                if (fwOverviewPageTDFirmware.length != 1) {
                  // this is the device parameter page
                  // Show the normal fwInfoPanelElm (Version: xxx, available Version and Update Button)
                  fw_update_rows += "<tr><td>"+translateKey('lblFirmwareVersion')+"</td><td class=\"CLASS22006\">"+firmware+"</td></tr>" +
                  "<tr><td>"+translateKey('lblAvailableFirmwareVersion')+"</td><td class=\"CLASS22006\">"+availableFW+"</td></tr>";
                }
                // This is for the firmware overview page AND the device parameter page (Update Button)
                fw_update_rows += "<tr><td colspan=\"2\" class=\"CLASS22007\" style=\"border-style:none\"><span onclick=\"FirmwareUpdate();\" class=\"CLASS21000\">"+translateKey('lblUpdate')+"</span></td></tr>";
                fwInfoPanelElm.html(fw_update_rows);
              }
            }, interval);
          }
        }
      }
    }
  }
}

proc set_internalKeys {status address iface pnr} {
  
  # status must be 0 or 1 
  # 0 = internal keys not visible
  # 1 = internal keys visible
  
  global iface_url 
  set url $iface_url($iface)
  set master_addr [string toupper [string range $address 0 [expr [string first ":" $address] -1] ]] 
  
  set internal_keys_visible "{INTERNAL_KEYS_VISIBLE {bool $status}}"
  puts "[xmlrpc $url putParamset [list string $master_addr] [list string MASTER] [list struct $internal_keys_visible]]"
    
  set ui_hint "{UI_HINT {string $pnr}}"
  puts "[xmlrpc $url putParamset [list string $address] [list string $address] [list struct $ui_hint]]"
}

proc cmd_set_profile {} {

  global iface_url sender_address USERPROFILESPATH env  

  set iface   ""
  set address ""
  set peer    ""
  set ps_type ""
  set paramid ""
  set pnr     ""
  set HmIPIdentifier "HmIP-RF"
  set HmIPWiredIdentifier "HmIP-Wired"

  catch { import iface }
  catch { import address }
  catch { import peer }
  catch { import ps_type }
  catch { import paramid }
  catch { import pnr }
  catch { import new_profilepath } ;# handelt es sich um die neue Profilstruktur?

  # wenn interne Ger�tetaste?
  if {! [catch {import internalKey}] } then {
    ## set_internalKeys 1 $address $iface $pnr
    ## after 1500
  }
  
  if { $paramid != "" && [file exists easymodes/$paramid.tcl] } then {
    
    catch {source easymodes/$new_profilepath.tcl}
    
    # Kanal aus der Senderadresse entfernen, aus EDD0001234:1 wird EDD0001234
    set sender_ad [lindex [split $peer ":"] 0]
    set USERPROFILEFILE $USERPROFILESPATH/$new_profilepath-$sender_ad.tcl

    catch {source $USERPROFILEFILE}
  }

  set ret [base_put_profile $iface $address $pnr $peer $ps_type 0]
    
  puts "<script type=\"text/javascript\">"

  if {$ret == -1 && (($iface != $HmIPIdentifier)  && ($iface != $HmIPWiredIdentifier))} then {
    
    #Kein ConfigPending anzeigen nach dem Laufbalken (sinnlos, weil keine �bertragung erfolgte):
    puts "ProgressBar.OnFinish = function () \{ return; \}"
    
    #puts "if (ProgressBar) ProgressBar.IncCounter(\"Fehler beim Speichern des Profils $address mit $peer.\");"
    puts "if (ProgressBar) ProgressBar.IncCounter(translateKey(\"dialogSetProfileErrorProgressBarA\") + \"$address\" + translateKey(\"dialogSetProfileErrorProgressBarB\") + \"$peer.\");"
    #puts "ShowErrorMsg(\"[cgi_quote_html "Das Profil konnte nicht gespeichert werden."]\");"
    puts "ShowErrorMsg(translateKey(\"dialogSetProfileMsgError\"));"

  } else {
    #puts "if (ProgressBar) ProgressBar.IncCounter(\"Profil gespeichert von $address mit $peer.\");"
    puts "if (ProgressBar) ProgressBar.IncCounter(translateKey(\"dialogSetProfileSuccessProgressBarA\")+ \" $address \" +translateKey(\"dialogSetProfileSuccessProgressBarB\") + \" $peer.\");"
  }
  puts "</script>"

  # wenn interne Ger�tetaste?
  if {! [catch {import internalKey}] } then {
    #after 1500
    ## set_internalKeys 0 $address $iface $pnr
    ## after 3000
  }
}

proc cmd_set_team {} {
  
  global iface_url
  
  catch {import iface}
  catch {import address}
  catch {import TEAM}
  
  set url $iface_url($iface)  
  
  if {$TEAM == "_RESET_"} then {set TEAM ""}
  
  puts "<script type=\"text/javascript\">"
  
  xmlrpc $url setTeam [list string $address] [list string $TEAM]
  
  puts "if (ProgressBar) ProgressBar.IncCounter(translateKey(\"dialogSetTeamSuccessProgressBar\"));"
  
  puts "</script>"
}


proc cmd_determineParameter {} {
  
  #cgi_debug -on 

  global iface_url

  set iface    ""
  set address  ""
  set ps_id    ""
  set param_id ""

  catch { import iface }
  catch { import address }
  catch { import ps_id }
  catch { import param_id }
  catch { import html_inputelem_id }

  puts "<script type=\"text/javascript\">"
  if { [catch { xmlrpc $iface_url($iface) determineParameter [list string $address] [list string $ps_id] [list string $param_id] }] } then {
    #puts "if (ProgressBar) ProgressBar.IncCounter(\"Parameter konnte nicht bestimmt werden!\");"
    puts "if (ProgressBar) ProgressBar.IncCounter(translateKey(\"dialogDetermineParameterProgressBarError\"));"
    #puts "ShowErrorMsg(\"Der Parameter konnte nicht bestimmt werden.\");"
    puts "ShowErrorMsg(translateKey(\"dialogDetermineParameterMsgError\"));"
  } else {
    #puts "if (ProgressBar) ProgressBar.IncCounter(\"Parameter wurde bestimmt!\");"
    puts "if (ProgressBar) ProgressBar.IncCounter(translateKey(\"dialogDetermineParameterProgressBarSuccess\"));"
    #puts "ShowInfoMsg(\"Der Parameter wurde erfolgreich bestimmt.\");"
    puts "ShowInfoMsg(translateKey(\"dialogDetermineParameterMsgSuccess\"));"

    #Neuen Wert auslesen-----
    set newval ""

    catch {
        array set ps [xmlrpc $iface_url($iface) getParamset [list string $address] [list string $ps_id]]
      set newval $ps($param_id)
    }

    if {$newval != ""} then {
      puts "SetInputValue('$html_inputelem_id', '$newval');"
      catch {puts "SetInputValue('$html_inputelem_id' + '_tmp', '$newval');"}

      #INTEGER- und FLOAT-Input-Elemente m�ssen mit onkeyup in das eigentliche Daten-Input-Element �bertragen werden.
      catch {puts "document.getElementById('$html_inputelem_id').onkeyup;"}
      catch {puts "document.getElementById('$html_inputelem_id' + '_tmp' ).onkeyup;"}
    } else {
      #Wert konnte nicht bestimmt werden.
      puts "reloadPage();"
    }
  }
  puts "</script>"
}

proc cmd_SendInternalKeyPress {} {
  global iface_url
  catch {import iface}
  catch {import sender}
  catch {import receiver}
  catch {import longKeyPress}

  set simLongKeyPress "false"

  catch {
    if {[info exists longKeyPress] == 1} {
      if {$longKeyPress == 1} {
        set simLongKeyPress "true"
      }
    }
  }
    
  if {[catch {xmlrpc $iface_url($iface) activateLinkParamset [list string $receiver] [list string $sender] [list bool $simLongKeyPress]}]} then {
    set error "<div class=\"CLASS20700\">\${dialogSimulateKeyPressError}</div>"
    puts "<script type=\"text/javascript\">MessageBox.show('\${dialogHint}','$error' ,'', 400, 80);</script>"
  } else {
    set success "<div class=\"CLASS20700\">\${dialogSimulateKeyPressSuccess}</div>"
    puts "<script type=\"text/javascript\">MessageBox.show('\${dialogHint}','$success' ,'', 420, 40);</script>"
  }
}

proc cmd_unknowncmd {cmd} {
  #puts "<script type=\"text/javascript\">alert('Fehler. Unbekannter Befehl: $cmd');</script>"
  puts "<script type=\"text/javascript\">alert(translateKey('errorMessageUnknownCommand') +' $cmd');</script>"
}

cgi_eval {

  cgi_input
  catch { import cmd }

  if {[session_requestisvalid 0] > 0} then {

    html {
      head {
        put_meta_nocache
        puts "<title>response of request with command: $cmd</title>"
      }
      body {
        puts "<script src=\"/config/js/ic_common.js\" type=\"text/javascript\"></script>"
          cmd_$cmd
      }
    }
  }
}
