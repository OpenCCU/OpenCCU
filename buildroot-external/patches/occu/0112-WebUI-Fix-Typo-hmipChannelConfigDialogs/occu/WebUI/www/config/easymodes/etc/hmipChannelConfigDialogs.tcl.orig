source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/uiElements.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmip_helper.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/options.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipDRAP_HAPMaintenance.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipHeatingClimateControlTransceiverEffect.tcl]
# source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipAlarmPanel.tcl]

proc getMaintenance {chn p descr address} {

  global dev_descr env iface

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set devType $dev_descr(TYPE)

  set devIsHmIPWired [isDevHmIPW $devType]

  set cyclicInfo false

  set deviceIsHAP false
  set deviceIsDRAP false
  set deviceIsDrapOrHap false

  if { [string first "HmIP-HAP" $devType] != -1 } {
    set deviceIsHAP true
  }

  if { [string first "HmIPW-DRAP" $devType] != -1 } {
    set deviceIsDRAP true
  }

  if {$deviceIsHAP || $deviceIsDRAP} { set deviceIsDrapOrHap true}

  set specialID "[getSpecialID $special_input_id]"
  set html ""

  set CHANNEL $special_input_id

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-ParamHelp.js');</script>"

  if {([string equal $devType "HmIP-CCU3"] == 1) || ([string equal $devType "RPI-RF-MOD"] == 1)} {
    append html "[getNoParametersToSet]"
    return $html
  }

  if {[string equal $devType "HmIP-DRG-DALI"] == 1} {
      append html "<tr>"
        append html "<td>\${lblRefreshDaliDevices}</td>"
        append html "<td><input id=\"btnDaliRefreshDevices\" type=\"button\" name=\"btnSearchDaliDevices\"  onclick=\"daliRefreshDevices('$dev_descr(ADDRESS)');\"></td>"
      append html "</tr>"
      append html "[getHorizontalLine]"
      append html "<script type=\"text/javascript\">translateButtons(\"btnSearchDaliDevices\");</script>"
  }

  set param CYCLIC_INFO_MSG
  if { [info exists ps($param)] == 1  } {
    set cyclicInfo true
    append html "<tr>"
      append html "<td>\${stringTableCyclicInfoMsg}</td>"
      append html  "<td>[getCheckBoxCyclicInfoMsg $param $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param CYCLIC_INFO_MSG_DIS
  if { [info exists ps($param)] == 1  } {
    set cyclicInfo true
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableCyclicInfoMsgDis}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param CYCLIC_INFO_MSG_DIS_UNCHANGED
  if { [info exists ps($param)] == 1  } {
    set cyclicInfo true
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableCyclicInfoMsgDisUnChanged}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  if {$cyclicInfo == "true"} {
    append html "[getHorizontalLine]"
  }

  if {[string equal $devType "HmIP-RGBW"] != 1} {
    set param OVERTEMP_LEVEL
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr name=\"expertParam\" class=\"hidden\">"
        append html "<td>\${stringTableDimmerOverTempLevel}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
      append html "</tr>"
    }
  }

  set param DEVICE_OPERATION_MODE
  if {[info exists ps($param)] == 1} {
    if {[string equal $devType "HmIP-RGBW"] == 1} {
      incr prn
      append html "<tr>"
        append html "<td>\${lblMode}</td>"
          array_clear options
          set options(0) "\${optionRGBW}"
          set options(1) "\${optionRGB}"
          set options(2) "\${option2xTunableWhite}"
          set options(3) "\${option4xPWM}"
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_RGBW]</td>"

      append html "</tr>"

      # Check if links or programs exist
      set linksAvailable 0
      set parentAddress $dev_descr(ADDRESS)

      for {set loop 1} {$loop <= 4} {incr loop} {
        set chnAddress "$parentAddress:[expr $chn + $loop]"
        if {[getLinkCountByAddress $iface $chnAddress] > 0} {
          set linksAvailable 1
          break;
        }
      }

      append html "<tr><td colspan='3'>"
        append html "<span id='hintLinksPrograms' class='attention hidden'></span>"
      append html "</td></tr>"

      append html "<script type=\"text/javascript\">"
        append html "var hint = '';"
        append html "var hasLinks = ($linksAvailable == 1) ? true : false;"
        append html "var oDevice = DeviceList.getDeviceByAddress('$parentAddress');"
        append html "var hasPrograms = homematic('Device.hasPrograms', {'id': oDevice.id});"

        append html "if (hasPrograms || hasLinks) \{"
          append html "jQuery('\[name=\"DEVICE_OPERATION_MODE\"\]').first().prop('disabled', true);"
          append html "hint = (hasPrograms && hasLinks) ? translateKey('hintWiredBlindLinksAndProgramsAvailable') : (hasPrograms)  ? translateKey('hintWiredBlindProgramsAvailable') : (hasLinks)  ? translateKey('hintWiredBlindLinksAvailable') : '';"
          append html "jQuery('#hintLinksPrograms').html(hint).show();"
        append html "\}"

      append html "</script>"

      append html "<script type=\"text/javascript\">"
        append html " oChn = DeviceList.getChannelByAddress('$address'); "
        append html "storeRGBWDeviceMode = function() {"
          append html "var mode = jQuery('\[name=\"DEVICE_OPERATION_MODE\"\]').first().val();"
          append html " homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': 'deviceMode', 'value': mode}); "
        append html "};"

        # Extend the footer buttons
        append html " window.setTimeout(function() { "
         append html " var elm = jQuery('#footerButtonOK, #footerButtonTake'); "
         append html " elm.off('click').click(function() {storeRGBWDeviceMode();}); "
        append html " },10); "
      append html "</script>"

      append html "[getHorizontalLine]"
    }
  }
  set param LOW_BAT_LIMIT
  if { [info exists ps($param)] == 1  } {
    # SPHM-875
    if {([string equal $devType "HmIP-SWO-PL"] != 1) && ([string equal $devType "HmIP-SWO-PR"] != 1) && ([string equal $devType "HmIP-SWO-B"] != 1)} {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableBatteryLowBatLimit}</td>"
        append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
      append html "</tr>"
    }
  }

  set param LOCAL_RESET_DISABLED
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr name=\"expertParam\" class=\"hidden\">"
      append html "<td>\${stringTableLocalResetDisable}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param GLOBAL_BUTTON_LOCK
  if { [info exists ps($param)] == 1  } {
     incr prn
     append html "<tr>"
       append html "<td>\${stringTableGlobalButtonLock}</td>"
       append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
     append html "</tr>"
  }

  # SPHM-590
  if {[string is false $deviceIsDrapOrHap]} {
    set param ROUTER_MODULE_ENABLED
    if { [info exists ps($param)] == 1  } {
       incr prn
       append html "<tr>"
         append html "<td>\${stringTableRouterModuleEnabled}</td>"
         append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
       append html "</tr>"
    }
  }

  set param MULTICAST_ROUTER_MODULE_ENABLED
  if { [info exists ps($param)] == 1} {
    incr prn
    append html "<tr>"
     append html "<td>\${stringTableMulticastRouterModuleEnabled}</td>"
     append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 600 300]</td>"
    append html "</tr>"
  }

  set param ENABLE_ROUTING
  if { [info exists ps($param)] == 1} {
    if {$devIsHmIPWired == "false"} {
       incr prn
       append html "<tr>"
         append html "<td>\${stringTableEnableRouting}</td>"
         append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
       append html "</tr>"
    }
  }

  # HmIP-WGS and HmIP-WGS-A
  set param DEVICE_INPUT_LAYOUT_MODE
  if {[info exists ps($param)] == 1} {
    incr prn
    append html "[getHorizontalLine]"
    append html "<tr>"
      append html "<td>\${lblDisplayLayoutMode}</td>"
        array_clear options
        set options(0) "\${optionOneBtn}"
        set options(1) "\${optionTwoBtnLeftRRight}"
        set options(2) "\${optionTwoBtnUpDDown}"
        set options(3) "\${optionFourBtn}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_WGS 450 50] </td>"

      append html "<tr><td colspan='3'>"
        append html "<span id='hintLinksPrograms' class='attention hidden'></span>"
      append html "</td></tr>"

      # Check if links or programs exist
      set linksAvailable 0
      set parentAddress $dev_descr(ADDRESS)

      for {set loop 1} {$loop <= 4} {incr loop} {
        set chnAddress "$parentAddress:[expr $chn + $loop]"
        if {[getLinkCountByAddress $iface $chnAddress] > 0} {
          set linksAvailable 1
          break;
        }
      }

      append html "<script type=\"text/javascript\">"
        append html "var hint = '';"
        append html "var hasLinks = ($linksAvailable == 1) ? true : false;"
        append html "var oDevice = DeviceList.getDeviceByAddress('$parentAddress');"
        append html "var hasPrograms = homematic('Device.hasPrograms', {'id': oDevice.id});"

        append html "if (hasPrograms || hasLinks) \{"
          append html "jQuery('\[name=\"DEVICE_INPUT_LAYOUT_MODE\"\]').first().prop('disabled', true);"
          append html "hint = (hasPrograms && hasLinks) ? translateKey('hintLayoutModeLinksAndProgramsAvailable') : (hasPrograms)  ? translateKey('hintLayoutModeProgramsAvailable') : (hasLinks)  ? translateKey('hintLayoutModeLinksAvailable') : '';"
          append html "jQuery('#hintLinksPrograms').html(hint).show();"
        append html "\}"

      append html "</script>"
    append html "</tr>"
  }

set comment {
  # Currently not in use. Parameter is replaced by the next parameter BUTTON_RESPONSE_WITHOUT_BACKLIGHT
  set param DEVICE_SWITCH_TRIGGERING_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    array_clear options
    set options(0) "\${optionBacklightFirst}"
    set options(1) "\${optionDirect}"
    append html "<tr><td>\${stringTableButtonResponseWithoutBacklight}</td><td>"
    append html "[get_ComboBox options $param separate_$special_input_id\_$prn ps $param]&nbsp;[getHelpIcon $param]"
    append html "</td></tr>"
  }
}

  set param BUTTON_RESPONSE_WITHOUT_BACKLIGHT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td name=\"expertParam\" class=\"hidden\">\${stringTableButtonResponseWithoutBacklight}</td>"
    append html "<td name=\"expertParam\" class=\"hidden\">"
    append html  "[getCheckBox '$param' $ps($param) $chn $prn]"
    append html "</td>"
    append html "</tr>"
  }

  # INPUT_1_COPRO_ENABLED - INPUT_X_COPRO_ENABLED
  if {[string equal $devType "ELV-SH-BM-S"] == 1} {
    for {set loop 1} {$loop <= 4} {incr loop} {
      if {[info exists ps(INPUT_$loop\_COPRO_ENABLED)] == 1} {
        if {$loop == 1} {append html "[getHorizontalLine]"}
        incr prn
        append html "<tr>"
          append html "<td>\${stringTableInputCoProEnabled_$loop}</td>"
          append html  "<td>[getCheckBox 'INPUT_$loop\_COPRO_ENABLED' $ps(INPUT_$loop\_COPRO_ENABLED) $chn $prn]&nbsp;[getHelpIcon INPUT_COPRO_ENABLED]</td>"
        append html "</tr>"
        if {$loop == 4} {append html "[getHorizontalLine]"}
      }
    }
  }

  set param DISABLE_DEVICE_ALIVE_SIGNAL
  if { [info exists ps($param)] == 1} {
    if {$devIsHmIPWired == "false"} {
       incr prn
       append html "<tr>"
         append html "<td>\${stringTableDisableDeviceAliveSignal}</td>"
         append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
       append html "</tr>"
    }
  }

set comment {
  # This parameter shouldn't be visible in the WebUI. This was once clarified with the PM
  set param DISABLE_MSG_TO_AC
  if { [info exists ps($param)] == 1} {
    if {$devIsHmIPWired == "false"} {
       incr prn
       append html "<tr>"
         append html "<td>\${stringTableDisableMsgToAC}</td>"
         append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
       append html "</tr>"
    }
  }
}

  set param DEVICE_SENSOR_SENSITIVITY
  if { [info exists ps($param)] == 1} {
    incr prn
    if {[string equal $devType "HmIP-STI"] != 1} {
      option RAW_0_100Percent
    } else {
      # HmIP-STI = 0 - 4
      for {set val 0} {$val <= 4} {incr val} {
             set options($val) "[expr $val + 1]"
      }
    }

    append html "<tr>"
      if {([string first "HmIP-SMO230" $devType] != -1) || ([string first "HmIPW-SMO230" $devType] != -1)} {
        append html "<td>\${stringTableDeviceSensorSensibilitySabotage}</td>"
      } else {
        append html "<td>\${stringTableDeviceSensorSensibility}</td>"
      }

      if {[string equal $devType "HmIP-STI"] != 1} {
        append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]</td>"
      } else {
        # HmIP-STI
        append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param]</td>"
      }
    append html "</tr>"
  }

  set param DISPLAY_CONTRAST
  if { [info exists ps($param)] == 1  } {
    incr prn
    if {[string equal $devType "HmIP-DRG-DALI"] != 1} {
      array_clear options
      if {([string equal $devType "HmIP-eTRV-3"] == 1) || ([string equal $devType "HmIP-eTRV-E"] == 1) || ([string equal $devType "HmIP-eTRV-E-S"] == 1) || ([string equal $devType "HmIP-eTRV-E-A"] == 1) } {
        set optVal 0
        for {set val 1} {$val <= 16} {incr val} {
            if {$val < 7} {incr optVal 5} elseif {$val < 14} {incr optVal 10} else {incr optVal 20}
            set options($optVal) "$val"
        }
      } else {
        # This is currently in use for the HmIPW-DRAP
        for {set val 0} {$val <= 31} {incr val} {
            set options($val) "$val"
        }
      }

      append html "<tr>"
        append html "<td>\${stringTableDisplayContrast}</td>"
        append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]</td>"
      append html "</tr>"
    } else {
      # HmIP-DRG-DALI
      append html "<tr>"
        append html "<td>\${stringTableDisplayContrast}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
      append html "</tr>"
    }
  }

  set param BACKLIGHT_ON_TIME
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDisplayLightingDuration}</td>"
    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param ALTITUDE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableAltitude}</td>"
    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param SIGNAL_BRIGHTNESS
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableBrightnessVisKey}</td>"
      option RAW_0_100Percent_1
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param MOUNTING_ORIENTATION
  if { [info exists ps($param)] == 1 } {
    incr prn
    if {
      (([string first "HmIP-BBL" $devType] == -1) && ([string first "HmIP-BRC2-2" $devType] == -1))
      && ([string first "HmIP-BROLL" $devType] == -1)
      && ([string first "HmIP-BDT" $devType] == -1)
      && ([string first "HmIP-eTRV-F" $devType] == -1)
      && ([string first "HmIP-UDI-PB2" $devType] == -1)
      && ([string first "HmIP-UDI-SMI55" $devType] == -1)
      } {
      append html "<tr>"
        append html "<td>\${lblMountingOrientation}</td>"
          array_clear options
          set options(0) "\${stringTableWinMaticMountSideLeft}"
          set options(1) "\${stringTableWinMaticMountSideRight}"
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
      append html "</tr>"
    } else {
      append html "<tr>"
        append html "<td>\${lblMountingOrientationA}</td>"
          array_clear options
          set options(0) "\${option0Degree}"
          set options(1) "\${option90Degree}"
          set options(2) "\${option180Degree}"
          set options(3) "\${option270Degree}"
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_A]</td>"
      append html "</tr>"
    }
  }

  set param DISPLAY_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblDisplayModeETRV}</td>"
        array_clear options
        set options(0) "\${optionReducedMode}"
        set options(1) "\${optionFunctionalMode}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param DISPLAY_INVERTED_COLORS
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblDisplayColor}</td>"
        array_clear options
        set options(0) "\${optionNormalColors}"
        set options(1) "\${optionInvertedColors}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param PERMANENT_FULL_RX
  if { [info exists ps($param)] == 1  } {
     append html "[getHorizontalLine]"
     incr prn
    array_clear options
    set options(0) "\${operationModeBattery}"
    set options(1) "\${operationModeMains}"
    append html "<tr>"
      append html "<td>\${powerSupply}</td>"
        if {([string equal $devType "HmIP-SMI55"] == 1) || ([string equal $devType "HmIP-SMI55-A"] == 1) || ([string equal $devType "HmIP-SMI55-2"] == 1)} {
          append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param onchange=paramPermanentFullRXChanged(this.id\,this.value)] [getHelpIcon $param]</td><td id='placeHolder' style='width:55%'></td>"
        } else {
          append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param onchange=showParameterHint(this.id\,this.value)]</td>"
        }
    append html "</tr>"

    if {([string equal $devType "HmIP-SMI55"] == 1) || ([string equal $devType "HmIP-SMI55-A"] == 1) || ([string equal $devType "HmIP-SMI55-2"] == 1)} {
      append html "<tr id=\"hint_separate_$CHANNEL\_$prn\">"
        append html "<td colspan='3'>\${hintPERMANENT_FULL_RX}</td>"
      append html "</tr>"
    } else {
      append html "[getHorizontalLine]"
    }

    append html "<script type='text/javascript'>"

      append html "var setMetaPermanentFullRx = false;"

      append html "paramPermanentFullRXChanged = function(elmID, value) {"
        append html "showParameterHint(elmID, value);"
        append html "setMetaPermanentFullRx = true;"
        append html ""
      append html "};"

      append html " showParameterHint = function(elmID, value) { "
        append html " var elm = jQuery(\"#hint_\"+elmID), "
        append html " placeHolder = jQuery(\"#placeHolder\"); "
        append html " if (parseInt(value) == 0) { "
          append html " elm.show(); "
          append html " placeHolder.show(); "
        append html "} else {"
          append html " elm.hide(); "
          append html " placeHolder.hide(); "
        append html " } "
      append html " }; "

      append html " var elm = jQuery('#separate_$CHANNEL\_$prn');"
      append html " showParameterHint('separate_$CHANNEL\_$prn', elm.val());"

      append html " storeModePermanentFullRx = function() { "
        append html " var dev = DeviceList.getDeviceByAddress('$dev_descr(ADDRESS)'); "
        append html " if (setMetaPermanentFullRx) { "

          append html " var elm = jQuery('\[name=\"PERMANENT_FULL_RX\"\]')\[0\];"


          append html " if (typeof elm != 'undefined') \{ "
            append html " homematic('Interface.setMetadata', {'objectId': dev.id, 'dataId': 'permanentFullRX', 'value': jQuery(elm).val()}); "
          append html " \} "

        append html " } else { "
          # Check if the meta data permanentFullRX is available (it's not with new devices)
          append html " var permanentFullRXAvailable = homematic('Interface.getMetadata', {'objectId': 12604, 'dataId': 'permanentFullRX'});"
          append html " if (permanentFullRXAvailable != 0 && permanentFullRXAvailable != 1) { "
            # Setting the meta data to the default value which is 0
            append html " homematic('Interface.setMetadata', {'objectId': dev.id, 'dataId': 'permanentFullRX', 'value': 0}); "
          append html " } "
        append html " } "
      append html " }; "

      # Extend the footer buttons
      append html " window.setTimeout(function() { "
       append html " var elm = jQuery('#footerButtonOK, #footerButtonTake'); "
       append html " elm.off('click').click(function() {storeModePermanentFullRx();}); "
      append html " },1200); "

    append html "</script>"
  }

  # DRAP/HAP Integration #
  if {([string equal $devType "HmIPW-DRAP"] == 1) || ([string equal $devType "HmIP-HAP"] == 1) || ([string equal $devType "HmIP-HAP2"] == 1) || ([string equal $devType "HmIP-HAP2-A"] == 1) || ([string equal $devType "HmIP-HAP-A"] == 1) || ([string equal $devType "HmIP-HAP-B1"] == 1) || ([string equal $devType "HmIP-HAP JS1"] == 1)} {
    append html "[getDRAP_HAPMaintenance $chn ps psDescr]"
  }
  # End DRAP/HAP Integration #


  if {([string equal $devType "HmIP-DLD"] != 1) && ([string equal $devType "HmIP-DLD-A"] != 1) && ([string equal $devType "HmIP-DLD-S"] != 1) && ([string equal $devType "HmIP-SMO230"] != 1)  && ([string equal $devType "HmIP-SMO230-A"] != 1) && ([string equal $devType "HmIPW-SMO230"] != 1) && ([string equal $devType "HmIPW-SMO230-A"] != 1)} {
    set param LONGITUDE
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "[getHorizontalLine]"
      append html "<tr name='positionFixing'>"
       append html "<td>\${lblLocation} - \${dialogSettingsTimePositionLblLongtitude}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
      append html "</tr>"

      set param LATITUDE
      incr prn
      append html "<tr name='positionFixing'>"
       append html "<td>\${lblLocation} - \${dialogSettingsTimePositionLblLatitude}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
      append html "</tr>"
      append html "[getHorizontalLine]"
    }
  }

  ### Blocking ###
  set param BLOCKING_ON_SABOTAGE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "[getHorizontalLine]"
    append html "<tr>"
      append html "<td>\${stringTableBlockingOnSabotage}</td>"

      if {[string equal $devType "HmIP-FWI"] == 1} {
       append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_FWI]</td>"
      } else {
       append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
      }

    append html "</tr>"
  }

  set param SABOTAGE_CONTACT_TYPE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableSabotageContactType}</td>"
      option NORMALLY_CLOSE_OPEN
      append html  "<td>[getOptionBox $param options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param BLOCKING_TEMPORARY
  if { [info exists ps($param)] == 1 } {
    set min [expr {[expr int([getMinValue $param]) + 1]}]
    set max [expr {[expr int([getMaxValue $param])]}]

    array_clear options
    set options(0) \${optionNotActive}
    for {set val $min} {$val <= $max} {incr val} {
      set options($val) "$val"
    }
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableBlockingTemporary}</td>"
      if {[string equal $devType "HmIP-FWI"] == 1} {
       append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param\_FWI]</td>"
      } else {
       append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param]</td>"
      }
    append html "</tr>"
  }

  set param BLOCKING_PERMANENT
  if { [info exists ps($param)] == 1 } {
    set min [expr {[expr int([getMinValue $param]) + 1]}]
    set max [expr {[expr int([getMaxValue $param])]}]

    array_clear options
    set options(0) \${optionNotActive}
    for {set val $min} {$val <= $max} {incr val} {
        set options($val) "$val"
    }
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableBlockingPermanent}</td>"
      if {[string equal $devType "HmIP-FWI"] == 1} {
       append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param\_FWI]</td>"
      } elseif {[string equal $devType "HmIP-WKP"] == 1} {
       append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param\_WKP]</td>"
      } else {
        append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param]</td>"
      }
    append html "</tr>"
    append html "[getHorizontalLine]"
  }
  ### End Blocking ###



  if {[session_is_expert]} {
    append html "<script type=\"text/javascript\">"
      append html "jQuery(\"\[name='expertParam'\]\").show();"
    append html "</script>"
  }

  return $html
}

proc getKeyTransceiver {chn p descr} {

  global env dev_descr
  # source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipAlarmPanel.tcl]

  upvar $p ps
  upvar $descr psDescr
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""
  set specialParam 0
  set prn 1


  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1 } {
    append html "<tr>"
      append html "<td>\${lblChannelActivInactiv}</td>"
      array_clear options
      set options(0) "\${optionInactiv}"
      set options(1) "\${optionActiv}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
    incr prn
  }

set comment {
  # Intruduced with the DBB but currently not supported
  set param DISABLE_ACOUSTIC_CHANNELSTATE
  if { [info exists ps($param)] == 1 } {
    append html "<tr>"
      append html "<td>\${stringTableDisableAcousticChannelState}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"
    set specialParam 1
    incr prn
  }
}

  set param DISABLE_ACOUSTIC_SENDSTATE
  if { [info exists ps($param)] == 1 } {
    append html "<tr>"
      append html "<td>\${stringTableDisableAcousticSendState}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"
    set specialParam 1
    incr prn
  }

  set param LED_DISABLE_CHANNELSTATE
  if { [info exists ps($param)] == 1 } {
    append html "<tr>"
      append html "<td>\${stringTableLEDDisableChannelState}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"
    set specialParam 1
    incr prn
  }


  set param LED_DISABLE_SENDSTATE
  if { [info exists ps($param)] == 1 } {
    append html "<tr>"
      append html "<td>\${stringTableLEDDisableSendState}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"
    set specialParam 1
    incr prn
  }

  # This is for the display configuration for the keys of a ACOUSTIC_DISPLAY_RECEIVER (e. g. HmIP-WRCD)
  set paramText TEXT
  set paramIcon TEXT_ICON
  if {(! [catch {set tmp $ps($paramText)}]) && (! [catch {set tmp $ps($paramIcon)}])} {
    set psText $ps(TEXT)
    set psAlignment $ps(TEXT_ALIGNMENT)
    set psBgColor $ps(TEXT_BACKGROUND_COLOR)
    set psTextColor $ps(TEXT_COLOR)
    set psIcon $ps(TEXT_ICON)
    append html [getAcousticdDisplayReceiverConfig $special_input_id $chn $psText $psAlignment $psBgColor $psTextColor $psIcon]

    set specialParam 1
  }

  if {$specialParam == 1} {
  append html "[getHorizontalLine]"
  }

  set param DBL_PRESS_TIME
  if { [info exists ps($param)] == 1  } {
    append html "<tr>"
      append html "<td>\${stringTableKeyDblPressTime}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
    incr prn
  }

  set param LONG_PRESS_TIME
  if { [info exists ps($param)] == 1  } {
    append html "<tr>"
      append html "<td>\${stringTableKeyLongPressTimeA}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[]</td>"
    append html "</tr>"
    incr prn
  }

  set param REPEATED_LONG_PRESS_TIMEOUT_UNIT
  if { [info exists ps($param)] == 1  } {
    if {[string equal $dev_descr(TYPE) "HmIP-STI"] == 0} {
      append html "<tr>"
      append html "<td>\${stringTableKeyLongPressTimeOut}</td>"
      append html [getComboBox $chn $prn "$specialID" "timeOnOffShort"]
      append html "</tr>"

      append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param REPEATED_LONG_PRESS_TIMEOUT_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableKeyLongPressTimeOutValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    } else {
      append html "<tr>"
        append html "<td>\${stringTableKeyLongPressTimeOut}</td>"
        set param REPEATED_LONG_PRESS_TIMEOUT_VALUE
        # append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"

        append html "<td>"
          append html "<input id='$param\_$chn\_$prn' type='text' size='5' value=[expr [format {%1.1f} $ps($param)] / 10] onblur=\"ProofAndSetValue(this.id, this.id, '0.0', '6.0', 1); setVal(this.value, $chn, $prn);\">&nbsp[getUnit $param]"
          append html "<input id='separate_CHANNEL_$chn\_$prn' name='$param' type='text' class='hidden'>"
        append html "</td>"
      append html "</tr>"

      append html "<script type=\"text/javascript\">"
        append html "var chn=$chn,prn=$prn;"
       append html "setVal = function (val, chn, prn) \{"
         append html "jQuery('#\separate_CHANNEL_'+chn+'_'+prn).val(parseInt(val * 10));"
       append html "\};"

       append html "setTimeout(function() {setVal(jQuery('#'+'$param\_$chn\_$prn').val(), chn, prn);},50);"

      append html "</script>"
    }
  }

  # append html "[getAlarmPanel ps]"


  set param ABORT_EVENT_SENDING_CHANNELS
  if { [info exists ps($param)] == 1  } {
    incr prn

   append html "[getHorizontalLine]"

   append html "<tr name='abortEventSendingChannels'>"
     append html "<td colspan='2'  style='text-align:center;'>\${stringTableAbortEventSendingChannels}&nbsp;[getHelpIcon $param]</td>"
   append html "</tr>"

   append html "<tr>"
   append html "<td>\${lblStopRunningLink}</td>"
   append html "<td colspan='2'><table>"
     append html "<tr id='hookAbortEventSendingChannels_1_$chn'/>"
     append html "<tr id='hookAbortEventSendingChannels_2_$chn'/>"
   append html "</table></td>"
   append html "</tr>"

    append html "<script type='text/javascript'>"
      append html "addAbortEventSendingChannels('$chn','$prn', '$dev_descr(ADDRESS)', $ps($param));"
    append html "</script>"
  }
  return $html
}

proc getGenericInputTransmitter {chn p descr} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-FAL_MIOB.js');</script>"

  set param MIOB_DIN_CONFIG
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableMiobDinConfig}</td>"
      option MIOB_DIN_CONFIG
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn "onchange=\"showHideKeyParams($chn);\""]</td>"
    append html "</tr>"
  }

  set param MIOB_DIN_MODE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableMiobDinMode}</td>"
      option NORMALLY_OPEN_CLOSE
      append html  "<td>[getOptionBox $param options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param DBL_PRESS_TIME
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr class=\"hidden\" name=\"paramKey_$chn\">"
      append html "<td>\${stringTableKeyDblPressTime}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"

    incr prn
    set param LONG_PRESS_TIME
    append html "<tr class=\"hidden\" name=\"paramKey_$chn\">"
      append html "<td>\${stringTableKeyLongPressTimeA}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[]</td>"
    append html "</tr>"
  }

  set param REPEATED_LONG_PRESS_TIMEOUT_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr class=\"hidden\" name=\"paramKey_$chn\">"
    append html "<td>\${stringTableKeyLongPressTimeOut}</td>"
    append html [getComboBox $chn $prn "$specialID" "delayShort"]
    append html "</tr>"
      append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]
  }

  set param REPEATED_LONG_PRESS_TIMEOUT_VALUE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
     append html "<td>\${stringTableKeyLongPressTimeOutValue}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  append html "<script type=\"text/javascript\">"

    # This is necessary for the parameters of keys.
    # When the last value of the time select box is chosen (Enter value) then show additional elements to allow
    # the user to enter a time.
    append html "initKeyParams = function(chn) \{"
     append html "var timeSelectElm = jQuery(\"#timeDelay_\"+chn+\"_6\");"
     append html "var timeDelayVal = timeSelectElm.val();"
     append html "var valueForEnterUserVal = parseInt(jQuery(\"#\" +timeSelectElm.attr(\"id\") + \" option:last-child\").val());"

     append html "if (parseInt(timeDelayVal) == valueForEnterUserVal) \{"
       append html "jQuery(\"#timeBase_\"+chn+\"_6\").attr(\"name\",\"paramKey_\" + chn);"
       append html "jQuery(\"#timeFactor_\"+chn+\"_7\").attr(\"name\",\"paramKey_\" + chn);"
       append html "jQuery(\"#space_\"+chn+\"_7\").attr(\"name\",\"paramKey_\" + chn);"
     append html "\}"

    append html "\};"

    # Show the parameters for the configuration of the keys only when the mode TACTILE_SWITCH_INPUT is chosen
    append html "showHideKeyParams = function(chn) \{"
      append html "var arKeyParams = jQuery(\"\[name='paramKey_\" + chn +\"'\]\");"
      # append html "var selectedMode = parseInt(jQuery(\"#separate_CHANNEL_\" + chn + \"_1\").val());"
      # append html "if (selectedMode == 4) \{arKeyParams.show();\} else \{arKeyParams.hide();\}"

      append html "var optionClass = jQuery(\"#separate_CHANNEL_\" + chn + \"_1\ option:selected\").attr(\"class\");"
      append html "if (optionClass == \"TACTILE_SWITCH_INPUT\") \{arKeyParams.show();\} else \{arKeyParams.hide();\}"
    append html "\};"

    append html "setTimeout(function() {initKeyParams($chn);showHideKeyParams($chn);},200);"
  append html "</script>"

  return $html
}

proc getMultiModeInputTransmitter {chn p descr address} {

  global dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set hlpBoxWidth 450
  set hlpBoxHeight 80
  set eventDelayPrn 0

  set specialID "[getSpecialID $special_input_id]"
  set CHANNEL $special_input_id

  set param LED_DISABLE_CHANNELSTATE
  if { [info exists ps($param)] == 1  } {
     incr prn
     append html "<tr>"
       append html "<td>\${stringTableLEDDisableChannelState}</td>"
       append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
     append html "</tr>"
  }

  set param LED_DISABLE_SENDSTATE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableLEDDisableSendState}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1 } {
    set valueListIndex [expr [lsearch $psDescr($param) VALUE_LIST] +1]
    set valueList "[lindex $psDescr($param) $valueListIndex]"
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableKeyTransceiverChannelOperationMode}</td>"
      array_clear options
      set options(0) "\${lblNotActiv}"
      set options(1) "\${stringTableKeyTransceiverChannelOperationModeKeyBehavior}"
      set options(2) "\${stringTableKeyTransceiverChannelOperationModeSwitchBehavior}"

      if {[lsearch $valueList BINARY_BEHAVIOR] != -1} {
        set options(3) "\${stringTableKeyTransceiverChannelOperationModeBinaryBehavior}"
      }

      if {[lsearch $valueList LEVEL_KEY_BEHAVIOR ] != -1} {
        set options(4) "\${stringTableKeyTransceiverChannelOperationModeLevelKeyBehavior}"
      }

      if {[lsearch $valueList CONDITIONAL_BEHAVIOR ] != -1} {
        set options(5) "\${stringTableKeyTransceiverChannelOperationModeConditionalBehavior}"
      }

      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn onchange=\"channelOperationModeChange(this.value,'$address')\"]</td>"
    append html "</tr>"
  }

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    set eventDelayPrn $prn
    append html "<tr name=\"multiModeInputTransceiverEventDelay_$chn\">"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

# ** KEY **

  set param DBL_PRESS_TIME
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr name=\"multiModeInputTransceiverKey_$chn\">"
      append html "<td>\${stringTableKeyDblPressTime}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param LONG_PRESS_TIME
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr name=\"multiModeInputTransceiverKey_$chn\">"
      append html "<td>\${stringTableKeyLongPressTimeA}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[]</td>"
    append html "</tr>"
  }

  set param REPEATED_LONG_PRESS_TIMEOUT_UNIT
  if { [info exists ps($param)] == 1  } {

      incr prn
      append html "<tr name=\"multiModeInputTransceiverKey_$chn\">"
      append html "<td>\${stringTableKeyLongPressTimeOut}</td>"
      append html [getComboBox $chn $prn "$specialID" "timeOnOffShort"]
      append html "</tr>"
      append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param REPEATED_LONG_PRESS_TIMEOUT_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableKeyLongPressTimeOutValue}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

  }

# ** END KEY **

  set param MSG_FOR_POS_A
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr name=\"multiModeInputTransceiverBinary_$chn\">"
      append html "<td>\${stringTableShutterContactHmIPMsgPosA0}</td>"
      array_clear options
      set options(0) "\${stringTableShutterContactMsgPosA2}" ; # NO_MSG
      set options(1) "\${stringTableShutterContactMsgPosA1}" ; # CLOSED
      set options(2) "\${stringTableShutterContactMsgPosA3}"   ; # OPEN
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param MSG_FOR_POS_B
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr name=\"multiModeInputTransceiverBinary_$chn\">"
      append html "<td>\${stringTableShutterContactHmIPMsgPosB0}</td>"
      array_clear options
      set options(0) "\${stringTableShutterContactMsgPosA2}" ; # NO_MSG
      set options(1) "\${stringTableShutterContactMsgPosA1}" ; # CLOSED
      set options(2) "\${stringTableShutterContactMsgPosA3}" ; # OPEN
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param CONTACT_BOOST
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableContactBoost}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param ABORT_EVENT_SENDING_CHANNELS
  if { [info exists ps($param)] == 1  } {
    incr prn

    append html "[getHorizontalLine]"

    append html "<tr name='abortEventSendingChannels'>"
      append html "<td colspan='3'  style='text-align:center;'>\${stringTableAbortEventSendingChannels}&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"

    append html "<tr>"
    append html "<td>\${lblStopRunningLink}</td>"
    append html "<td colspan='2'><table>"
      append html "<tr id='hookAbortEventSendingChannels_1_$chn'/>"
      append html "<tr id='hookAbortEventSendingChannels_2_$chn'/>"
    append html "</table></td>"
    append html "</tr>"

    append html "<script type='text/javascript'>"
      append html "addAbortEventSendingChannels('$chn','$prn', '$dev_descr(ADDRESS)', $ps($param));"
    append html "</script>"
  }

  append html "<script type=\"text/javascript\">"

    append html "showHideKeyParams = function(mode, ch) {"
      append html "var elmEventDelay = jQuery(\"\[name='multiModeInputTransceiverEventDelay_\"+ch+\"'\]\"),"
      append html " elmEventDelayTimeBaseVal = jQuery('\#timeDelay_'+ch+'_$eventDelayPrn').val(),"
      append html " elmEventDelayTimeBase = jQuery('\#timeBase_'+ch+'_$eventDelayPrn'),"
      append html " elmEventDelayTimeFactor = jQuery('\#timeFactor_'+ch+'_[expr $eventDelayPrn + 1]'),"
      append html " elmEventDelaySpace = jQuery('\#space_'+ch+'_[expr $eventDelayPrn + 1]'),"
      append html " elmKey = jQuery(\"\[name='multiModeInputTransceiverKey_\"+ch+\"'\]\"),"
      append html " elmBinary = jQuery(\"\[name='multiModeInputTransceiverBinary_\"+ch+\"'\]\");"

      append html "switch(parseInt(mode)) {"
        append html "case 0:"
        append html "case 5:"
          append html "elmEventDelay.hide();"
          append html "elmEventDelayTimeBase.hide();"
          append html "elmEventDelayTimeFactor.hide();"
          append html "elmEventDelaySpace.hide();"
          append html "elmKey.hide();"
          append html "elmBinary.hide();"
          append html "break;"

        append html "case 1:"
        append html "case 4:"
          append html "elmEventDelay.hide();"
          append html "elmKey.show();"
          append html "elmBinary.hide();"
          append html "break;"

        append html "case 2:"
          append html "elmEventDelay.hide();"
          append html "elmKey.hide();"
          append html "elmBinary.hide();"
          append html "break;"

        append html "case 3:"
          append html "elmEventDelay.show();"
          append html "if (elmEventDelayTimeBaseVal == 12) {"
            append html "elmEventDelayTimeBase.show();"
            append html "elmEventDelayTimeFactor.show();"
            append html "elmEventDelaySpace.show();"
          append html "}"
          append html "elmKey.hide();"
          append html "elmBinary.show();"
          append html "break;"

      append html "}"

    append html "};"

    append html "setMetaChannelMode = function(mode, address) {"
      append html "var channel = DeviceList.getChannelByAddress(address);"
      append html "if (typeof oChnMultiModeTransmitter == \"undefined\")  {oChnMultiModeTransmitter = \[\];}"

      append html "oChnMultiModeTransmitter\[channel.address.toString()] = {};"
      append html "oChnMultiModeTransmitter\[channel.address.toString()].channelId = channel.id;"
      append html "oChnMultiModeTransmitter\[channel.address.toString()].dataId = \"channelMode\";"
      append html "oChnMultiModeTransmitter\[channel.address.toString()].mode = mode;"
    append html "};"

    append html "channelOperationModeChange = function(mode, address) {"
      append html "showHideKeyParams(mode, address.split(\":\")\[1\]);"
      append html "setMetaChannelMode(mode, address);"
    append html "};"

    append html "window.setTimeout(function() {"
      append html "var elmOperationMode = jQuery(\"\[name='CHANNEL_OPERATION_MODE'\]\"),"
      append html "mode = elmOperationMode.val(),"
      append html "chn = elmOperationMode.prop(\"id\").split(\"_\")\[2\];"
      append html "showHideKeyParams(mode, chn);"
    append html "},25);"

  append html "</script>"

  return $html
}

proc getAnalogInputTransmitter {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  set prn 1;
  set param FILTER_SIZE
  append html "<tr>"
    append html "<td>\${stringTableAnalogInputTransmitterFilterSize}</td>"
    append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_ANALOG_INPUT_TRANSMITTER 550 250]</td>"
  append html "</tr>"

  return $html
}

proc getAnalogOutputTransceiver {chn p descr} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  set param VOLTAGE_0
  append html "<tr>"
    append html "<td>\${stringTableVoltage0}</td>"
    append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[]</td>"
  append html "</tr>"

  incr prn
  set param VOLTAGE_100
  append html "<tr>"
    append html "<td>\${stringTableVoltage100}</td>"
    append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[]</td>"
  append html "</tr>"

  return $html
}

proc getSwitchTransmitter {chn p descr} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  set param CURRENTDETECTION_BEHAVIOR
  if { [info exists ps($param)] == 1  } {
    append html "<tr>"
      append html "<td>\${stringTableCurrentDetectionBehavior}</td>"
      array_clear option
      set option(0) "\${stringTableCurrentDetectionBehaviorActive}"
      set option(1) "\${stringTableCurrentDetectionBehaviorOutput1}"
      set option(2) "\${stringTableCurrentDetectionBehaviorOutput2}"
      append html  "<td>[getOptionBox '$param' option $ps($param) $chn $prn]</td>"
    append html "</tr>"
    incr prn
  }

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param LED_DISABLE_CHANNELSTATE
  if { [info exists ps($param)] == 1  } {
     incr prn
     append html "<tr>"
       append html "<td>\${stringTableLEDDisableChannelState}</td>"
       append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
     append html "</tr>"
  }
  return $html
}

proc getSwitchTransceiver {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

##  set CHANNEL $special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""

##  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HEATINGTHERMOSTATE_2ND_GEN_HELP.js');</script>"

  set param POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html [getPowerUpSelector $chn ps $special_input_id]
  }

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  return $html
}




proc getClimateReceiver {chn p descr} {
  global dev_descr
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"
  set CHANNEL $special_input_id
  set devType $dev_descr(TYPE)
  set chn [getChannel $special_input_id]

  set html ""

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HEATINGTHERMOSTATE_2ND_GEN_HELP.js');</script>"


  set param TEMPERATURE_OFFSET
  if { [info exists ps($param)] == 1  } {
    if {[string first "ELV-SH-PTI2" $devType ] == -1} {
      append html "<tr>"
        array_clear options
        for {set val -3.5} {$val <= 3.5} {set val [expr $val + 0.5]} {
          set options($val) "$val &#176;C"
        }
        append html "<td>\${stringTableTemperatureOffset}</td>"
        append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param]</td>"
      append html "</tr>"
    } else {
      append html "<tr>"
        append html "<td>\${stringTableTemperatureOffset}</td>"
        append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_STE2]</td>"
      append html "</tr>"
    }
  }

  set param TX_MINDELAY_UNIT
  if { ([info exists ps($param)] == 1)  && ([string equal $dev_descr(TYPE) "ELV-SH-PTI2"] == 0) } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableTxMinDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "txMinDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param TX_MINDELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableTxMinDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  if {[string length $html] == 0} {
    append html "[getNoParametersToSet]"
  }

  return $html
}

proc getBlindTransmitter {chn p descr address} {
  global iface dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set parent [lindex [split $address :] 0]

  set Fw [getDevFwMajorMinorPatch]
  set fwMajor [lindex $Fw 0]
  set fwMinor [lindex $Fw 1]
  set fwPatch [lindex $Fw 2]

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-ParamHelp.js');load_JSFunc('/config/easymodes/js/BlindAutoCalibration.js')</script>"

  puts "<div id=\"page_$parent\" class=\"hidden\">$parent</div>"

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  set param OUTPUT_SWAP
  if { [info exists ps($param)] == 1  } {
    incr prn
    array_clear options
    set options(0) "\${optionOutputNotSwapped}"
    set options(1) "\${optionOutputSwapped}"
    append html "<tr><td>\${lblOutputSwap}</td><td>"
    append html "[get_ComboBox options $param separate_$special_input_id\_$prn ps $param]&nbsp;[getHelpIcon $param]"
    append html "</td></tr>"
  }

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param CHANGE_OVER_DELAY
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableBlindChangeOverDelay}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
  }

  set param REFERENCE_RUN_COUNTER
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableBlindRefRunCounter}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param POSITION_SAVE_TIME
  catch {
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTablePositionSaveTime}</td>"
        append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param  320 50]</td>"
      append html "</tr>"
    }
  }

  set param ENDPOSITION_AUTO_DETECT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableBlindEndPositionAutoDetect}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn onchange=setVisibilityAutoCalibration(this);]</td>"
    append html "</tr>"
  }

  append html "[getHorizontalLine]"

  set cssAutoCalibration "hidden"
  if {$fwMajor == 1 && $fwMinor == 0 && $fwPatch <= 10 } {
    # set cssAutoCalibration ""
  }

  # AUTOCALIBRATION
  append html "<tr id=\"autoCalibrationPanel_$parent\" class =$cssAutoCalibration>"
    append html "<td>\${stringTableSelfCalibrationStart}</td>"
    append html "<td id='tdBtnBlindAutoCalibration_$parent'><input name='btnBlindAutoCalibration' onclick='autoCalib\[\"$parent\"\].triggerAutoCalibration()' value='Auto Calibration' type='button'>[getHelpIcon BLIND_AUTOCALIBRATION]</td>"
    append html "<td id='tdBlindStopCalibration_$parent' class=\"hidden\"><input name='btnBlindStopCalibration' onclick='autoCalib\[\"$parent\"\].stopAutoCalibration()' value='Stop Calibration' type='button'></td>"
  append html "</tr>"

  append html "<tr id=\"autoCalibrationActive_$parent\" class=\"hidden\">"
    append html "<td>\${lblAutoCalibrationActiv}</td>"
    append html "<td><div><img src='/ise/img/anim_bargraph.gif'></div></td>"
  append html "</tr>"

  append html "<script type=\"text/javascript\">window.setTimeout(function() {autoCalib = {}; autoCalib\[\"$parent\"\] = new AutoCalibrateBlind(\"$iface\", \"$address\", jQuery(\"#separate_CHANNEL\_$chn\_$prn\").prop(\"checked\")); autoCalib\['$parent'\].initAutoCalibration();},100)</script>"

  # /AUTOCALIBRATION

  set param REFERENCE_RUNNING_TIME_BOTTOM_TOP_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableBlindRunnintTimeBottomTop}</td>"
    append html [getComboBox $chn $prn "$specialID" "blindRunningTime"]
    append html "</tr>"

    append html [getTimeUnit10ms_100ms_1s_10s $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param REFERENCE_RUNNING_TIME_BOTTOM_TOP_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableTimeBottomTopValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlindRunningTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param REFERENCE_RUNNING_TIME_TOP_BOTTOM_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableBlindRunningTimeTopBottom}</td>"
    append html [getComboBox $chn $prn "$specialID" "blindRunningTime"]
    append html "</tr>"

    append html [getTimeUnit10ms_100ms_1s_10s $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param REFERENCE_RUNNING_TIME_TOP_BOTTOM_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableTimeBottomTopValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlindRunningTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param REFERENCE_RUNNING_TIME_SLATS_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableJalousieRunningTimeSlats}</td>"
    append html [getComboBox $chn $prn "$specialID" "slatRunningTime"]
    append html "</tr>"

    append html [getTimeUnit10ms_100ms_1s_10s $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param REFERENCE_RUNNING_TIME_SLATS_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableTimeSlatsValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSlatRunningTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  append html "[getHorizontalLine]"

  set param DELAY_COMPENSATION
  if { [info exists ps($param)] == 1 } {
    # The max value represents the automatic modus.
    set autoDelayCompensation 0
    incr prn

    set bckColor "silver"
    append html "<tr>"
      append html "<td colspan='2' style=\"text-align:center; background-color:$bckColor\">\${stringTableBlindDelayCompensation}</td>"
    append html "</tr>"

    append html "<tr name=\"trAutoCompensate\">"
      if {[format {%1.1f} $ps($param)] == [getMaxValue $param]} {set autoDelayCompensation 1}
      append html "<td>\${btnAutoDetect}</td>"
      append html "<td>[getCheckBox '_$param' $autoDelayCompensation $chn tmp onchange=setAutoDelayCompensation(this);]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"

    # Hide this while in auto mode
    append html "<tr id=\"autoDelayCompensation_$chn\" class=\"hidden\">"
      append html "<td>\${lblTimeDelay}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"

    append html "<script type=\"text/javascript\">"

      # SPHM-118 / SPHM-410
      if {([string equal $dev_descr(TYPE) "HmIPW-DRBL4"] == 1) || ([string equal $dev_descr(TYPE) "HmIP-DRBLI4"] == 1)} {
        append html "jQuery(\"\[name='trAutoCompensate'\]\").hide();"
      }

      append html "setVisibilityAutoCalibration = function(elm) {"
        append html " var autoCalibElm = jQuery(\"\#autoCalibrationPanel\_$parent\" ), "
        append html " delayCompensationElm = jQuery(\"\[name='_DELAY_COMPENSATION'\]\").first(); "
        append html " if(jQuery(elm).prop('checked')) { "
            append html " autoCalibElm.show(); "
            append html " delayCompensationElm.prop('disabled', false); "
            append html " if (! delayCompensationElm.prop('checked')) { "
              append html " delayCompensationElm.prop('checked', true).change(); "
            append html " } "
          append html " } else { "
            append html " autoCalibElm.hide(); "
            append html " if (delayCompensationElm.prop('checked')) { "
              append html " delayCompensationElm.click(); "
            append html " } "
            append html " delayCompensationElm.prop('disabled', true); "
        append html " } "
      append html "};"

      append html "setAutoDelayCompensation = function(elm, init) {"

        append html "var arElmID = elm.id.split(\"_\"),"
        append html "chn = arElmID\[2\],"

        append html "autoDelayCompensationTRElm = jQuery(\"\#autoDelayCompensation_\" + chn),"
        # append html "autoDelayCompensationTextElm = jQuery(\"\#separate_CHANNEL_\"+ chn + \"_$prn\"),"
        append html "autoDelayCompensationTextElm = document.getElementById(\"separate_CHANNEL_\" + chn + \"_$prn\"),"
        append html "auto = jQuery(elm).prop('checked');"
        append html "if (auto) {"
          # Hide time element
          append html "jQuery(autoDelayCompensationTRElm).hide();"
          append html "jQuery(autoDelayCompensationTextElm).val([getMaxValue $param]);"
          append html "autoDelayCompensationTextElm.value = [getMaxValue $param];"
          append html "if (init) {autoDelayCompensationTextElm.defaultValue = parseFloat([getMaxValue $param]);}"
        append html "} else {"
          # Show time element
          append html "jQuery(autoDelayCompensationTRElm).show();"
        append html "}"
      append html "};"

      append html "window.setTimeout(function() {"
        append html "if (typeof delayCompensationSet == \"undefined\") \{"
          append html "var elm = jQuery(\"\[name=\'_DELAY_COMPENSATION\'\]\");"
          append html "elm.each(function(index, element) \{"
            append html "setAutoDelayCompensation(element, true);"
            append html "delayCompensationSet = true;"
          append html "\});"
        append html "\};"
      append html "}, 250);"

      append html "window.setTimeout(function() \{delete delayCompensationSet\},1000);"

    append html "</script>"
  }

  # append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
  append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSlatRunningTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

  return $html
}

proc getShutterTransmitter {chn p descr address} {
  global iface dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set parent [lindex [split $address :] 0]

  set Fw [getDevFwMajorMinorPatch]
  set fwMajor [lindex $Fw 0]
  set fwMinor [lindex $Fw 1]
  set fwPatch [lindex $Fw 2]

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-ParamHelp.js');load_JSFunc('/config/easymodes/js/BlindAutoCalibration.js')</script>"

  puts "<div id=\"page_$parent\" class=\"hidden\">$parent</div>"

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  set param OUTPUT_SWAP
  if { [info exists ps($param)] == 1  } {
    incr prn
    array_clear options
    set options(0) "\${optionOutputNotSwapped}"
    set options(1) "\${optionOutputSwapped}"
    append html "<tr><td>\${lblOutputSwap}</td><td>"
    append html "[get_ComboBox options $param separate_$special_input_id\_$prn ps $param]&nbsp;[getHelpIcon $param]"
    append html "</td></tr>"
  }

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"
    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]
    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param CHANGE_OVER_DELAY
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableBlindChangeOverDelay}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
  }

  set param REFERENCE_RUN_COUNTER
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableBlindRefRunCounter}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param POSITION_SAVE_TIME
  catch {
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTablePositionSaveTime}</td>"
        append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param  320 50]</td>"
      append html "</tr>"
    }
  }

  set param ENDPOSITION_AUTO_DETECT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableBlindEndPositionAutoDetect}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn onchange=setVisibilityAutoCalibration(this);]</td>"
    append html "</tr>"
  }

  append html "[getHorizontalLine]"

  set cssAutoCalibration "hidden"
  if {$fwMajor == 1 && $fwMinor == 0 && $fwPatch <= 10 } {
    # set cssAutoCalibration ""
  }

  # AUTOCALIBRATION
  append html "<tr id=\"autoCalibrationPanel_$parent\" class =$cssAutoCalibration>"
    append html "<td>\${stringTableSelfCalibrationStart}</td>"
    append html "<td id='tdBtnBlindAutoCalibration_$parent'><input name='btnBlindAutoCalibration' onclick='autoCalib\[\"$parent\"\].triggerAutoCalibration()' value='Auto Calibration' type='button'>[getHelpIcon BLIND_AUTOCALIBRATION]</td>"
    append html "<td id='tdBlindStopCalibration_$parent' class=\"hidden\"><input name='btnBlindStopCalibration' onclick='autoCalib\[\"$parent\"\].stopAutoCalibration()' value='Stop Calibration' type='button'></td>"
  append html "</tr>"

  append html "<tr id=\"autoCalibrationActive_$parent\" class=\"hidden\">"
    append html "<td>\${lblAutoCalibrationActiv}</td>"
    append html "<td><div><img src='/ise/img/anim_bargraph.gif'></div></td>"
  append html "</tr>"

  append html "<script type=\"text/javascript\">window.setTimeout(function() {autoCalib = {}; autoCalib\[\"$parent\"\] = new AutoCalibrateBlind(\"$iface\", \"$address\", jQuery(\"#separate_CHANNEL\_$chn\_$prn\").prop(\"checked\")); autoCalib\['$parent'\].initAutoCalibration();},100)</script>"
  # /AUTOCALIBRATION

  set param REFERENCE_RUNNING_TIME_BOTTOM_TOP_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableBlindRunnintTimeBottomTop}</td>"
    append html [getComboBox $chn $prn "$specialID" "blindRunningTime"]
    append html "</tr>"

    append html [getTimeUnit10ms_100ms_1s_10s $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param REFERENCE_RUNNING_TIME_BOTTOM_TOP_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableTimeBottomTopValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlindRunningTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param REFERENCE_RUNNING_TIME_TOP_BOTTOM_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableBlindRunningTimeTopBottom}</td>"
    append html [getComboBox $chn $prn "$specialID" "blindRunningTime"]
    append html "</tr>"

    append html [getTimeUnit10ms_100ms_1s_10s $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param REFERENCE_RUNNING_TIME_TOP_BOTTOM_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableTimeBottomTopValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlindRunningTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    append html "</tr>"
  }

  set param DELAY_COMPENSATION
  if { [info exists ps($param)] == 1 } {

    append html "[getHorizontalLine]"

    # The max value represents the automatic modus.
    set autoDelayCompensation 0
    incr prn

    set bckColor "silver"
    append html "<tr>"
      append html "<td colspan='2' style=\"text-align:center; background-color:$bckColor\">\${stringTableBlindDelayCompensation}</td>"
    append html "</tr>"

    append html "<tr name=\"trAutoCompensate\">"
      if {[format {%1.1f} $ps($param)] == [getMaxValue $param]} {set autoDelayCompensation 1}
      append html "<td>\${btnAutoDetect}</td>"
      append html "<td>[getCheckBox '_$param' $autoDelayCompensation $chn tmp onchange=setAutoDelayCompensation(this);]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"

    # Hide this while in auto mode
    append html "<tr id=\"autoDelayCompensation_$chn\" class=\"hidden\">"
      append html "<td>\${lblTimeDelay}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"

    append html "<script type=\"text/javascript\">"

      set comment {
        # We now check if the parameter ENDPOSITION_AUTO_DETECT is available. If not, autocompesantion is not available.

        # SPHM-118 / SPHM-410 / SPHM-1082
        if {([string equal $dev_descr(TYPE) "HmIPW-DRBL4"] == 1) || ([string equal $dev_descr(TYPE) "HmIP-DRBLI4"] == 1) || ([string equal $dev_descr(TYPE) "HmIP-FROLL"] == 1)} {
          append html "jQuery(\"\[name='trAutoCompensate'\]\").hide();"
        }
      }

      # Show the checkbox 'Auto discover' only when the parameter ENDPOSITION_AUTO_DETECT is available
      if { [info exists ps(ENDPOSITION_AUTO_DETECT)] != 1 } {
        append html "jQuery(\"\[name='trAutoCompensate'\]\").hide();"
      }

      append html "setVisibilityAutoCalibration = function(elm) {"
        append html " var autoCalibElm = jQuery(\"\#autoCalibrationPanel\_$parent\" ), "
        append html " delayCompensationElm = jQuery(\"\[name='_DELAY_COMPENSATION'\]\").first(); "
        append html " if(jQuery(elm).prop('checked')) { "
            append html " autoCalibElm.show(); "
            append html " delayCompensationElm.prop('disabled', false); "
            append html " if (! delayCompensationElm.prop('checked')) { "
              append html " delayCompensationElm.prop('checked', true).change(); "
            append html " } "
          append html " } else { "
            append html " autoCalibElm.hide(); "
            append html " if (delayCompensationElm.prop('checked')) { "
              append html " delayCompensationElm.click(); "
            append html " } "
            append html " delayCompensationElm.prop('disabled', true); "
        append html " } "
      append html "};"

      append html "setAutoDelayCompensation = function(elm, init) {"

        append html "var arElmID = elm.id.split(\"_\"),"
        append html "chn = arElmID\[2\],"

        append html "autoDelayCompensationTRElm = jQuery(\"\#autoDelayCompensation_\" + chn),"
        # append html "autoDelayCompensationTextElm = jQuery(\"\#separate_CHANNEL_\"+ chn + \"_$prn\"),"
        append html "autoDelayCompensationTextElm = document.getElementById(\"separate_CHANNEL_\" + chn + \"_$prn\"),"
        append html "auto = jQuery(elm).prop('checked');"
        append html "if (auto) {"
          # Hide time element
          append html "jQuery(autoDelayCompensationTRElm).hide();"
          append html "jQuery(autoDelayCompensationTextElm).val([getMaxValue $param]);"
          append html "autoDelayCompensationTextElm.value = [getMaxValue $param];"
          append html "if (init) {autoDelayCompensationTextElm.defaultValue = parseFloat([getMaxValue $param]);}"
        append html "} else {"
          # Show time element
          append html "jQuery(autoDelayCompensationTRElm).show();"
        append html "}"
      append html "};"

      append html "window.setTimeout(function() {"
        append html "if (typeof delayCompensationSet == \"undefined\") \{"
          append html "var elm = jQuery(\"\[name=\'_DELAY_COMPENSATION\'\]\");"
          append html "elm.each(function(index, element) \{"
            append html "setAutoDelayCompensation(element, true);"
            append html "delayCompensationSet = true;"
          append html "\});"
        append html "\};"
      append html "}, 250);"

      append html "window.setTimeout(function() \{delete delayCompensationSet\},1000);"

    append html "</script>"

  }
  # append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"

  return $html
}

proc getDimmerTransmitter {chn p descr} {
  global dev_descr
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"
  set CHANNEL $special_input_id
  set devType $dev_descr(TYPE)

  set html ""

  set _chn $chn

  set prn 0

  set Fw [getDevFwMajorMinorPatch]
  set fwMajor [lindex $Fw 0]
  set fwMinor [lindex $Fw 1]
  set fwPatch [lindex $Fw 2]

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    array_clear options

    set isWUA [string equal $devType "HmIP-WUA"]
    set lblActivInactiv \${lblChannelActivInactiv}

    if {! $isWUA} {
      set options(0) "\${optionInactiv}"
      set options(1) "\${optionActiv}"

      if { ($fwMajor >= 2) ||  (($fwMajor == 2) && ($fwMinor >= 1)) || (($fwMajor == 2) && ($fwMinor == 1) && ($fwPatch >= 12)) } {
        set options(2) "\${optionAdjustDimmerLevel}"
      }

    } else {
      set options(0) "\${optionRelayInactive}"
      set options(1) "\${optionRelayOffDelay05S}"
      set options(2) "\${optionRelayOffDelay1S}"
      set options(3) "\${optionRelayOffDelay10S}"

      set lblActivInactiv \${lblChannelActivInactivWhenNoOutput}
    }

    append html "<tr><td>$lblActivInactiv</td><td>"
    append html "[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param onchange=\"showAdjustDimmingRange(this.value,$chn)\"]&nbsp;[getHelpIcon DIM_$param 600 100]"
    append html "</td></tr>"
  }

  set param DIM_LEVEL_LOWEST
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr name='adjustDimLevel_$chn'>"
      append html "<td>\${stringTableDimmerLevelLowest}</td>"
      append html "<td class='j_dimLevelLowest_$chn'>[getTextField $param $ps($param) $chn $prn $ps(ON_MIN_LEVEL) onchange=checkDimLevelLowest(this)]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param DIM_LEVEL_HIGHEST
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr name='adjustDimLevel_$chn'>"
      append html "<td>\${stringTableDimmerLevelHighest}</td>"
    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
    append html "<tr name='adjustDimLevel_$chn'><td colspan='2'><hr></td></tr>"
  }

  set param VOLTAGE_0
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableVoltage0}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn proofMinMax4Voltage_X('$param');]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param VOLTAGE_100
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableVoltage100}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn proofMinMax4Voltage_X('$param')]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"

    append html "<script type=\"text/javascript\">"

    append html "</script>"

  }

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"
    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"
    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param ON_MIN_LEVEL
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblDimmerOnMinLevel}</td>"
      append html "<td class='j_onMinLevel_$chn'>[getTextField $param $ps($param) $chn $prn onchange=setDimmerLevelLowest(this.value)]&nbsp;%&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_RGBW 450 75]</td>"
    append html "</tr>"
  }

  set param UDI_DIMMING_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblMode}</td>"
      array_clear option
      set option(0) "\${optionAutoDetection}"
      set option(1) "\${optionTrailingEdge}"
      set option(2) "\${optionLeadingEdge}"
      append html  "<td>[getOptionBox '$param' option $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param FUSE_DELAY
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDimmerFuseDelay}</td>"
    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param OVERTEMP_LEVEL
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDimmerOverTempLevel}</td>"
    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  append html "<script type=\"text/javascript\">"

    append html "checkDimLevelLowest = function(elm) {"
      append html "var onMinLevelElm = jQuery(\".j_onMinLevel_$chn\").children().first(),"
      append html "valOnMinLevel = parseFloat(onMinLevelElm.val()),"
      append html "elmValue = parseFloat(elm.value);"

      append html "if ((isNaN(elmValue)) || (elmValue < valOnMinLevel)) {"
        append html "window.setTimeout(function() {"
        append html "elm.value = (valOnMinLevel < 0.5) ? 0.5 : valOnMinLevel;"
        append html "},50);"
      append html "}"
    append html "};"

    append html "setDimmerLevelLowest = function(value) {"
      append html "var dimLevelLowestElm = jQuery(\".j_dimLevelLowest_$chn\").children().first(),"
      append html "valLevelLowestElm = dimLevelLowestElm.val();"
      append html " if (parseFloat(value) > parseFloat(valLevelLowestElm)) {"
        append html "dimLevelLowestElm.val(value).blur();"
      append html "}"
    append html "};"

    append html "showAdjustDimmingRange = function(value, chn) {"
      append html "var adjustDimmLevelElms = jQuery(\"\[name='adjustDimLevel_$chn'\]\");"
      append html "if (value != 2) {"
        append html "adjustDimmLevelElms.hide();"
      append html "} else {"
        append html "adjustDimmLevelElms.show();"
      append html "}"
    append html "};"
    append html "showAdjustDimmingRange(jQuery(\"#separate_$CHANNEL\_1\").val(), $chn);"
  append html "</script>"

  return $html
}

proc getAlarmSwitchVirtualReceiver {chn p descr} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  puts "<script type=\"text/javascript\">getLangInfo_Special('VIRTUAL_HELP.txt');</script>"

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1 } {
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]
    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  return $html
}

  proc getAlarmCondSwitchReceiver {chn p descr} {
    upvar $p ps
    upvar $descr psDescr
    upvar prn prn
    upvar special_input_id special_input_id

    puts "<script type=\"text/javascript\">getLangInfo_Special('VIRTUAL_HELP.txt');</script>"

    set hlpBoxWidth 450
    set hlpBoxHeight 160

    set specialID "[getSpecialID $special_input_id]"
    set html ""

  set param SD_MULTICAST_ZONE_1
  if { [info exists ps($param)] == 1 } {

     # This is for the parameter SD_MULTICAST_ZONE_1..7
     append html "<tr>"
       append html "<td>\${paramSDMulticastZone}</td>"
       append html "<td>"
         append html "<table><tr>"
            for {set loop 1} {$loop < 8} {incr loop} {
              incr prn
              set zoneActive ""
              set checked ""
              set zoneActive "$ps(SD_MULTICAST_ZONE_$loop)"
              if {[string equal $zoneActive "1"] == 1} {
                set checked "checked"
              }
             append html "<td>"
               append html "<label for=\"separate\_${special_input_id}_$prn\">$loop</label>"
               append html "<input type=\"checkbox\" id=\"separate\_${special_input_id}_$prn\" name=\"SD_MULTICAST_ZONE_$loop\" $checked style=\"vertical-align:middle;\"></td>"
             append html "</td>"
            }
            append html "<td>[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]</td>"
         append html "</tr></table>"
       append html "<td>"
     append html "</tr>"
  }

  set param SILENT_ALARM_ZONE_1
  if { [info exists ps($param)] == 1 } {

     # This is for the parameter SILENT_ALARM_ZONE_1..7
     append html "<tr>"
       append html "<td>\${paramSilentAlarmZone}</td>"
       append html "<td>"
         append html "<table><tr>"
            for {set loop 1} {$loop < 8} {incr loop} {
              incr prn
              set zoneActive ""
              set checked ""
              set zoneActive "$ps(SILENT_ALARM_ZONE_$loop)"
              if {[string equal $zoneActive "1"] == 1} {
                set checked "checked"
              }
             append html "<td>"
               append html "<label for=\"separate\_${special_input_id}_$prn\">$loop</label>"
               append html "<input type=\"checkbox\" id=\"separate\_${special_input_id}_$prn\" name=\"SILENT_ALARM_ZONE_$loop\" $checked style=\"vertical-align:middle;\"></td>"
             append html "</td>"
            }
            append html "<td>[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]</td>"
         append html "</tr></table>"
       append html "<td>"
     append html "</tr>"
  }
    return $html
  }


proc getDimmerVirtualReceiver {chn p descr} {

  global dev_descr
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  puts "<script type=\"text/javascript\">getLangInfo_Special('VIRTUAL_HELP.txt');</script>"

  set specialID "[getSpecialID $special_input_id]"

  set html ""
  set prn 0

  set devType $dev_descr(TYPE)

  if {[session_is_expert]} {
    set hr 0
    set param "LOGIC_COMBINATION"
    if { [info exists ps($param)] == 1  } {
      incr prn
      set hr 1
      append html "<tr>"
        append html "<td>\${stringTableLogicCombination} \${stringTableBrightness}</td>"
          array_clear options
          option LOGIC_COMBINATION
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
        append html "<td>&nbsp<input class=\"j_helpBtn\" id=\"virtual_help_button_$chn\" type=\"button\" value=\${help} onclick=\"VirtualChannel_help($chn);\"></td>"

      append html "</tr>"
    }

    set param "LOGIC_COMBINATION_2"
    if { [info exists ps($param)] == 1  } {
      incr prn
      set onClick "VirtualChannel_help($chn);"
      set hr 1
      append html "<tr>"
        append html "<td>\${stringTableLogicCombination} \${stringTableColor}</td>"
          array_clear options
          if {([string equal "HmIP-BSL" $devType] == 1) || ([string equal "HmIP-MP3P" $devType] == 1)} {
            set onClick "VirtualChannel_help($chn,'lc2');"
            option LOGIC_COMBINATION_NO_AND_OR
          } else {
            option LOGIC_COMBINATION
          }
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
        append html "<td>&nbsp<input class=\"j_helpBtn\" id=\"virtual_help_button2_$chn\" type=\"button\" value=\${help} onclick=$onClick></td>"

      append html "</tr>"
    }
    if {$hr == 1} {
      append html "[getHorizontalLine]"
    }
  }

  set param POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html [getPowerUpSelector $chn ps $special_input_id]
  }

  #### HELP
  append html "<tr><td colspan=\"3\">"
    append html "<table class=\"ProfileTbl\" id=\"virtual_ch_help_$chn\" style=\"display:none\">"
    append html "<tr><td>\${virtualHelpTxtDimmer}</td></tr>"
    append html "</table>"
  append html "</td></tr>"

  append html "<tr><td colspan=\"3\">"
    append html "<table class=\"ProfileTbl\" id=\"virtual_ch_help2_$chn\" style=\"display:none\">"
    append html "<tr><td>\${virtualHelpTxtDimmerColor}</td></tr>"
    append html "</table>"
  append html "</td></tr>"

  puts "<script type=\"text/javascript\">"
    puts "jQuery(\".j_helpBtn\").val(translateKey(\"helpBtnTxt\"));"
  puts "</script>"

  return $html
}

proc getBlindVirtualReceiver {chn p descr} {

  global dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set devType $dev_descr(TYPE)

  set showPosSaveTime 1

  set Fw [getDevFwMajorMinorPatch]
  set fwMajor [lindex $Fw 0]
  set fwMinor [lindex $Fw 1]
  set fwPatch [lindex $Fw 2]

  if { ([string equal "HmIP-BBL" $devType] == 1) && (($fwMajor == 1) && ($fwMinor >= 10)) || ($fwMajor >= 2)} {
    set showPosSaveTime 0
  }

  puts "<script type=\"text/javascript\">getLangInfo_Special('VIRTUAL_HELP.txt');</script>"

  set html ""

  set prn 0

  if {[session_is_expert]} {
    set param "LOGIC_COMBINATION"
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableLogicCombinationBlind}</td>"
        option LOGIC_COMBINATION
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
        append html "<td rowspan='2'>&nbsp<input class=\"j_helpBtn\" id=\"virtual_help_button_$chn\" type=\"button\" value=\${help} onclick=\"VirtualChannel_help($chn);\"></td>"
      append html "</tr>"
      incr prn
      set param "LOGIC_COMBINATION_2"
      append html "<tr>"
        append html "<td>\${stringTableLogicCombinationSlat}</td>"
        option LOGIC_COMBINATION
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
      append html "[getHorizontalLine]"
    }
  }

  if {$showPosSaveTime == 1} {
    set param POSITION_SAVE_TIME
    catch {
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr>"
          append html "<td>\${stringTablePositionSaveTime}</td>"
          append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param  320 50]</td>"
        append html "</tr>"
        append html "[getHorizontalLine]"
      }
    }
  }

  set param POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html [getPowerUpSelectorShutterBlind $chn ps $special_input_id blind]
  }

  #### HELP
  append html "<tr><td colspan=\"2\">"
    append html "<table class=\"ProfileTbl\" id=\"virtual_ch_help_$chn\" style=\"display:none\">"
    append html "<tr><td>\${virtualHelpTxtDimmer}</td></tr>"
    append html "</table>"
  append html "</td></tr>"

  puts "<script type=\"text/javascript\">"
    puts "jQuery(\".j_helpBtn\").val(translateKey(\"helpBtnTxt\"));"
  puts "</script>"

  return $html
}

proc getShutterVirtualReceiver {chn p descr} {

  global dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set devType $dev_descr(TYPE)

  puts "<script type=\"text/javascript\">getLangInfo_Special('VIRTUAL_HELP.txt');</script>"


  set showPosSaveTime 1

  set Fw [getDevFwMajorMinorPatch]
  set fwMajor [lindex $Fw 0]
  set fwMinor [lindex $Fw 1]
  set fwPatch [lindex $Fw 2]

  if { ([string equal "HmIP-BBL" $devType] == 1) && (($fwMajor == 1) && ($fwMinor >= 10)) || ($fwMajor >= 2)} {
    set showPosSaveTime 0
  }

  set html ""

  set prn 0

  if {[session_is_expert]} {
    set param "LOGIC_COMBINATION"
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableLogicCombination}</td>"
        option LOGIC_COMBINATION
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
        append html "<td>&nbsp<input class=\"j_helpBtn\" id=\"virtual_help_button_$chn\" type=\"button\" value=\${help} onclick=\"VirtualChannel_help($chn);\"></td>"
      append html "</tr>"
      append html "[getHorizontalLine]"
    }
  }

  if {$showPosSaveTime == 1} {
    set param POSITION_SAVE_TIME
    catch {
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr>"
          append html "<td>\${stringTablePositionSaveTime}</td>"
          append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param 320 50]</td>"
        append html "</tr>"
        append html "[getHorizontalLine]"
      }
    }
  }


  set param POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html [getPowerUpSelectorShutterBlind $chn ps $special_input_id shutter]
  }

  #### HELP
  append html "<tr><td colspan=\"2\">"
    append html "<table class=\"ProfileTbl\" id=\"virtual_ch_help_$chn\" style=\"display:none\">"
    append html "<tr><td>\${virtualHelpTxtDimmer}</td></tr>"
    append html "</table>"
  append html "</td></tr>"

  puts "<script type=\"text/javascript\">"
    puts "jQuery(\".j_helpBtn\").val(translateKey(\"helpBtnTxt\"));"
  puts "</script>"

  return $html
}

proc getHeatingClimateControlSwitchTransmitter {chn p descr {extraparam ""}} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  set climateFunction ""
  set onlyHeatingCooling 0

  if {[string equal $extraparam "humidity"] == 1} {
      set climateFunction 1
      set onlyHeatingCooling 1
  } elseif {[string equal $extraparam "temperature"] == 1} {
    set climateFunction 0
    set onlyHeatingCooling 2
  }

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HEATINGTHERMOSTATE_2ND_GEN.js');load_JSFunc('/config/easymodes/MASTER_LANG/HEATINGTHERMOSTATE_2ND_GEN_HELP.js');load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-FAL_MIOB.js');</script>"
  set param CLIMATE_FUNCTION
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr id='climateFunktion'>"
      append html "<td>\${lblOperationMode}</td>"
      array_clear options
      set options(0) "\${optionThermostat}"
      set options(1) "\${optionHygrostat}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn onchange=showRelevantParams(this.value)]&nbsp;[getHelpIcon $param]</td>"
      set climateFunction $ps($param)
    append html "</tr>"
  }

  set param HUMIDITY_LIMIT_VALUE
  if { [info exists ps($param)] == 1  } {

    incr prn
    if {$climateFunction == 1} {set paramVisibility ''} else {set paramVisibility 'hidden'}

    append html "<tr id='humidityLimitValue' class=$paramVisibility>"
      append html "<td>\${stringTableHumidityLimitValue}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param TWO_POINT_HYSTERESIS
  if {[info exists ps($param)] == 1} {
    incr prn
    if {$climateFunction == 0} {set paramVisibility ''} else {set paramVisibility 'hidden'}
    array_clear options
    for {set val 0.0} {$val <= 2.0} {set val [expr $val + 0.2]} {
        set options($val) "$val K"
    }
    append html "<tr id='twoPointHysteresis' class=$paramVisibility>"
      append html "<td>\${stringTableSwitchTransmitTwoPointHysteresis}</td>"
      if {$onlyHeatingCooling == 0} {
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_A]</td>"
      } else {
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
      }
    append html "</tr>"
  }

  set param TWO_POINT_HYSTERESIS_HUMIDITY ;# See SPHM-911 and check the name of the parameter
  if {[info exists ps($param)] == 1} {
    incr prn
    if {$climateFunction == 1} {set paramVisibility ''} else {set paramVisibility 'hidden'}
    array_clear options
    set comment {
      # See SPHM-1079
      for {set val 2} {$val <= 20} {set val [expr $val + 2]} {
        set options([expr $val / 2]) "[expr $val] % rF"
      }
    }

    # See SPHM-1293
    for {set val 0} {$val <= 10} {incr val} {
      set options($val) "$val % rF"
    }

    append html "<tr id='twoPointHysteresisHumidity' class=$paramVisibility>"
      append html "<td>\${stringTableSwitchTransmitTwoPointHysteresis}</td>"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param HEATING_COOLING
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableHeatingCooling}</td>"
      array_clear options
      if {$climateFunction == 1} {
        set options(0) "\${optionDrying}"
        set options(1) "\${optionMoistening}"
        set options(2) "\${optionDryingMoistening}"
      } else {
        set options(0) "\${optionHeating}"
        set options(1) "\${optionCooling}"
        set options(2) "\${optionHeatingCooling}"
      }
      if {$onlyHeatingCooling == 0} {
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_A 600 300]</td>"
      } elseif {$onlyHeatingCooling == 1} {
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_B 600 300]</td>"
      } elseif {$onlyHeatingCooling == 2} {
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
      }
    append html "</tr>"
  }

  append html "<script type=\"text/javascript\">"
    append html "showRelevantParams = function(selectedMode) \{"
      append html "var humidityLimitValueElm = jQuery('\#humidityLimitValue'),"
      append html "heatingCoolingElm = jQuery(\"\[name='HEATING_COOLING'\]\").first(),"
      append html "valTwoPointHysteresisElm = jQuery(\"\[name='TWO_POINT_HYSTERESIS'\]\").first(),"
      append html "valTwoPointHysteresisHumidityElm = jQuery(\"\[name='TWO_POINT_HYSTERESIS_HUMIDITY'\]\").first(),"
      append html "heatingCoolingElmOption0 = heatingCoolingElm.find(\"option\[value='0'\]\"),"
      append html "heatingCoolingElmOption1 = heatingCoolingElm.find(\"option\[value='1'\]\"),"
      append html "heatingCoolingElmOption2 = heatingCoolingElm.find(\"option\[value='2'\]\"),"
      append html "heatingTwoPointHysteresisElm = jQuery(\"\#twoPointHysteresis\"),"
      append html "heatingTwoPointHysteresisHumidityElm = jQuery(\"\#twoPointHysteresisHumidity\");"

      append html "if (parseInt(selectedMode) == 1) \{"
        append html "humidityLimitValueElm.show();"
        # append html "heatingCoolingElm.val(\"1\");" SPHM-1015
        append html "heatingTwoPointHysteresisElm.hide();"
        append html "heatingTwoPointHysteresisHumidityElm.show();"
        append html "heatingCoolingElmOption0.html(translateKey('optionDrying'));"
        append html "heatingCoolingElmOption1.html(translateKey('optionMoistening'));"
        append html "heatingCoolingElmOption2.html(translateKey('optionDryingMoistening'));"

        # See SPHM-911 - comment D. S. 20211215
        append html "jQuery(valTwoPointHysteresisHumidityElm).find(\"option\[value='0'\]\").remove();"
        append html "jQuery(valTwoPointHysteresisElm).prepend(\"<option value='0.0'>0.0 K</option>\");"
        append html "valTwoPointHysteresisElm.val('0.0');"
      append html "\} else \{"
        append html "humidityLimitValueElm.hide();"
        # append html "heatingCoolingElm.val(\"0\");" SPHM-1015
        append html "heatingTwoPointHysteresisElm.show();"
        append html "heatingTwoPointHysteresisHumidityElm.hide();"
        append html "heatingCoolingElmOption0.html(translateKey('optionHeating'));"
        append html "heatingCoolingElmOption1.html(translateKey('optionCooling'));"
        append html "heatingCoolingElmOption2.html(translateKey('optionHeatingCooling'));"

        # See SPHM-911 - comment D. S. 20211215
        append html "jQuery(valTwoPointHysteresisElm).find(\"option\[value='0.0'\]\").remove();"
        append html "jQuery(valTwoPointHysteresisHumidityElm).prepend(\"<option value='0'>0 % rF</option>\");"
        append html "valTwoPointHysteresisHumidityElm.val('0');"
      append html "\}"
    append html "\};"

    if { [info exists ps(CLIMATE_FUNCTION)] == 1  } {
     append html "showRelevantParams($ps(CLIMATE_FUNCTION));"
    }
  append html "</script>"

  if {([info exists ps(COOLING_ENABLE)] == 1) && ([info exists ps(HEATING_ENABLE)] == 1)} {
    append html "<tr>"

      array_clear options
      set options(0) "\${optionInactiv}"
      set options(1) "\${optionActiv}"

      # left
      incr prn
      set param COOLING_ENABLE
      append html "<td>\${lblCoolingDisable}</td>"
     # append html "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"

    append html "<tr>"
      # right
      incr prn
      set param HEATING_ENABLE

      append html "<td>\${lblHeatingDisable}</td>"
     # append html "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  return $html
}

proc getHeatingClimateControlTransceiver {chn p descr address {extraparam ""}} {
  global iface dev_descr
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set devType $dev_descr(TYPE)
  set specialID "[getSpecialID $special_input_id]"

  set hlpBoxWidth 450
  set hlpBoxHeight 160

  set isGroup ""

  if {[string equal [string range $address 0 2] "INT"] == 1} {
    set isGroup "_group"
  }

  set weeklyPrograms 3

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/js/CC.js');</script>"

  set param P6_TEMPERATURE_MONDAY_1
  if { [info exists ps($param)] == 1  } {
      set weeklyPrograms 6
  }

  if {[string compare $extraparam 'only3WeeklyProgramms'] == 0} {
    set weeklyPrograms 3
  }

  set html ""

    set CHANNEL $special_input_id

    puts "<script type=\"text/javascript\">"
      puts "ShowActiveWeeklyProgram = function(activePrg) {"
        puts " for (var i = 1; i <= $weeklyPrograms; i++) {"
          puts "jQuery('#P' + i + '_Timeouts_Area').hide();"
        puts " }"
        puts " jQuery('#P' + activePrg + '_Timeouts_Area').show();"
      puts "};"

      puts "setDisplayMode = function(elem) {"
        puts "var mode = jQuery(elem).val();"
        puts "modeElem = jQuery(\".j_showHumidity\");"
        puts "if (mode == 0) {"
          puts "jQuery(modeElem).show();"
        puts "} else {jQuery(modeElem).hide();}"
      puts "};"
    puts "</script>"

    append html "[addHintHeatingGroupDevice $address]"

    set prn 0

    set param WEEK_PROGRAM_POINTER
    append html "<table class=\"ProfileTbl\">"
      append html "<tr>"
        append html "<td class='hidden'><input type='text' id='separate_$CHANNEL\_$prn' name='$param'></td>"
      append html "</tr>"

      # left
      append html "<tr>"
        append html "<td name=\"_expertParam\" class=\"_hidden\">\${stringTableWeekProgramToEdit}</td>"
        append html "<td name=\"_expertParam\" class=\"_hidden\">"
          append html "<select id=\"editProgram\" onchange=\"ShowActiveWeeklyProgram(parseInt(\$(this).value)+1);\">"
            append html "<option value='0'>\${stringTableWeekProgram1}</option>"
            append html "<option value='1'>\${stringTableWeekProgram2}</option>"
            append html "<option value='2'>\${stringTableWeekProgram3}</option>"
            if {$weeklyPrograms > 3} {
              append html "<option value='3'>\${stringTableWeekProgram4}</option>"
              append html "<option value='4'>\${stringTableWeekProgram5}</option>"
              append html "<option value='5'>\${stringTableWeekProgram6}</option>"
            }
        append html "</select>&nbsp;[getHelpIcon $param$isGroup]"
        append html "</td>"
      append html "</tr>"
    append html "</table>"


  ## Create the weekly Programs ##

    for {set loop 1} {$loop <=$weeklyPrograms} {incr loop} {
      set pNr "P$loop";
      append html "<div id=\"$pNr\_Timeouts_Area\" style=\"display:none\">"
      foreach day {SATURDAY SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY} {
        append html "<div id=\"$pNr\_temp_prof_$day\"></div>"
      }
      append html "</div>"

      append html "<script type=\"text/javascript\">"
      append html "$pNr\_tom = new TimeoutManager('$iface', '$address', false, '$pNr\_');"
      foreach day {SATURDAY SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY} {

        for {set i 1} {$i <= 13} {incr i} {

          set timeout     $ps($pNr\_ENDTIME_${day}_$i)
          set temperature $ps($pNr\_TEMPERATURE_${day}_$i)
          append html "$pNr\_tom.setTemp('$day', $timeout, $temperature);"

          if {$timeout == 1440} then {
            break;
          }
        }

        append html "$pNr\_tom.setDivname('$day', '$pNr\_temp_prof_$day');"
        append html "$pNr\_tom.writeDay('$day');"
      }
      append html "</script>"
    }

    append html "<script type=\"text/javascript\">ShowActiveWeeklyProgram(1);</script>"

    append html "<hr>"

    # *************** #

    append html "<table class=\"ProfileTbl\">"
      # left

      set param SHOW_SET_TEMPERATURE
      if { [info exists ps($param)] == 1  } {
        incr prn
        array_clear options
        set options(0) "\${stringTableClimateControlRegDisplayTempInfoActualTemp}"
        set options(1) "\${stringTableClimateControlRegDisplayTempInfoSetPoint}"

        append html "<tr>"
          append html "<td name=\"_expertParam\" class=\"_hidden\">\${stringTableClimateControlRegDisplayTempInfo}</td>"
          append html "<td name=\"_expertParam\" class=\"_hidden\">[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param onchange=\"setDisplayMode(this)\"]</td>"

          # right
          set param SHOW_HUMIDITY
          if {[info exists ps($param)] == 1} {
            incr prn
            array_clear options
            set options(0) "\${stringTableClimateControlRegDisplayTempHumT}"
            set options(1) "\${stringTableClimateControlRegDisplayTempHumTH}"
            append html "<td name=\"_expertParam\" class=\"hidden j_showHumidity\">\${stringTableClimateControlRegDisplayTempHum}</td>"
            append html "<td name=\"_expertParam\" class=\"hidden j_showHumidity\">[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]</td>"
          }
        append html "</tr>"
      }

      set param CLIMATE_CONTROL_DISPLAY
      if {[info exists ps($param)] == 1} {
        incr prn
        array_clear options
        if {[string first "HmIP-WGTC" $devType ] != -1} {
          set options(0) "\${optionActual}"
          set options(1) "\${optionSetpoint}"
          set options(2) "\${optionActualHumidity}"
          set options(3) "\${optionCO2}"
          set options(4) "\${optionActualHumidityCO2}"
          set options(5) "\${optionHumidity}"
        } else {
          set options(0) "\${optionActual}"
          set options(1) "\${optionSetpoint}"
          set options(2) "\${optionActualHumidity}"
          set options(3) "\${optionHumidity}"
        }

        append html "<tr><td>\${stringTableClimateControlRegDisplayTempInfo}</td><td>"
        append html "[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]"
       }

      # left
      set comment {
        # After a talk with the developer (B. B.) we decided not to show this parameter
        set param ADAPTIVE_REGULATION
        if { [info exists ps($param)] == 1 } {
          incr prn
          array_clear options
          set options(0) "\${stringTableAdaptiveRegulationOpt0}"
          set options(1) "\${stringTableAdaptiveRegulationOpt1}"
          set options(2) "\${stringTableAdaptiveRegulationOpt2}"
          append html "<tr>"
          append html "<td name=\"expertParam\" class=\"hidden\">\${stringTableAdaptiveRegulation}</td><td>"
          append html "<td name=\"expertParam\" class=\"hidden\">[get_ComboBox options $param separate_CHANNEL\_$prn ps $param]</td>"
          append html "</td>"
          append html "</tr>"
        }
      }

      set param BUTTON_RESPONSE_WITHOUT_BACKLIGHT
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr>"
        append html "<td name=\"expertParam\" class=\"hidden\">\${stringTableButtonResponseWithoutBacklight}</td>"
        append html "<td name=\"expertParam\" class=\"hidden\">"
        # append html "[_getCheckBox $CHANNEL '$param' $ps($param) $prn]"
        append html  "[getCheckBox '$param' $ps($param) $chn $prn]"
        append html "</td>"
        append html "</tr>"
      }

    append html "</table>"

    append html "<hr>"

    append html "<table class=\"ProfileTbl\">"

      set param TEMPERATURE_LOWERING_COOLING
      if { [info exists ps($param)] == 1  } {
        # left
        incr prn
        append html "<tr><td>\${ecoCoolingTemperature}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]<input id=\"comfortOld\" type=\"hidden\" value=\"$ps($param)\"</td>"

        # right
        incr prn
        set param TEMPERATURE_LOWERING
        append html "<td>\${ecoHeatingTemperature}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
        append html "</tr>"

        append html "<tr id=\"errorRow\" class=\"hidden\"> <td></td> <td colspan=\"2\"><span id=\"errorComfort\" class=\"attention\"></span></td> <td colspan=\"2\"><span id=\"errorEco\" class=\"attention\"></span></td> </tr>"
      }

      # left
      incr prn
      set param TEMPERATURE_MINIMUM
      array_clear options
      set i 0
      for {set val [getMinValue $param]} {$val <= [getMaxValue $param]} {set val [expr $val + 0.5]} {
        set options($i) "$val &#176;C"
        incr i;
      }
      append html "<tr><td>\${stringTableTemperatureMinimum}</td>"
      append html  "<td>[get_ComboBox options $param tmp_$CHANNEL\_$prn ps $param onchange=setMinMaxTemp('tmp_$CHANNEL\_$prn','separate_$CHANNEL\_$prn')]</span> <span class='hidden'>[getTextField $param $ps($param) $chn $prn]</span></td>"
      append html "<script type=\"text/javascript\">"
      append html "setMinMaxTempOption('tmp_$CHANNEL\_$prn', 'separate_$CHANNEL\_$prn' );"
      append html "</script>"

      # right
      incr prn
      set param TEMPERATURE_MAXIMUM
      array_clear options
      set i 0
      for {set val [getMinValue $param]} {$val <= [getMaxValue $param]} {set val [expr $val + 0.5]} {
        set options($i) "$val &#176;C"
        incr i;
      }
      append html "<td>\${stringTableTemperatureMaximum}</td>"
      append html  "<td>[get_ComboBox options $param tmp_$CHANNEL\_$prn ps $param onchange=setMinMaxTemp('tmp_$CHANNEL\_$prn','separate_$CHANNEL\_$prn')]</span> <span class='hidden'>[getTextField $param $ps($param) $chn $prn]</span></td>"
      append html "</tr>"
      append html "<script type=\"text/javascript\">"
      append html "setMinMaxTempOption('tmp_$CHANNEL\_$prn', 'separate_$CHANNEL\_$prn' );"
      append html "</script>"
      append html "<tr>"

      set param MIN_MAX_VALUE_NOT_RELEVANT_FOR_MANU_MODE
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr>"
        append html "<td name=\"expertParam\" class=\"hidden\">\${stringTableMinMaxNotRelevantForManuMode}</td>"
        append html "<td name=\"expertParam\" class=\"hidden\">"
        append html  "[getCheckBox '$param' $ps($param) $chn $prn]"
        append html "</td>"
        append html "</tr>"
      }

      set param OPTIMUM_START_STOP
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr>"
        append html "<td name=\"expertParam\" class=\"hidden\">\${stringTableOptimumStartStop}</td>"
        append html "<td name=\"expertParam\" class=\"hidden\">"
        append html  "[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]"
        append html "</td>"
        append html "</tr>"
      }

      set param DURATION_5MIN
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr name=\"expertParam\" class=\"hidden\">"
          append html "<td>\${stringTableDuration5Min}</td>"
          append html "<td colspan=\"2\" >[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param]</td>"

          append html "<script type=\"text/javascript\">"
            append html "jQuery(\"#separate_$CHANNEL\_$prn\").bind(\"blur\",function() {"
            append html "var value = this.value;"
            append html "this.value = Math.round(this.value / 5) * 5;"
            append html "ProofAndSetValue(this.id, this.id, [getMinValue $param], [getMaxValue $param], 1);"
            append html "});"
          append html "</script>"

        append html "</tr>"
      }

    append html "</table>"

    append html "<hr>"

    append html "<table class=\"ProfileTbl\">"
    # left
    incr prn
    set param TEMPERATURE_OFFSET
    array_clear options
    for {set val -3.5} {$val <= 3.5} {set val [expr $val + 0.5]} {
      set options($val) "$val &#176;C"
    }
    append html "<td>\${stringTableTemperatureOffset}</td>"
    append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"

    #left
    set param TEMPERATURE_WINDOW_OPEN
    if { [info exists ps($param)] == 1  } {
      incr prn
      if { [info exists ps(TEMPERATURE_WINDOW_OPEN_COOLING)] == 1  } {
        append html "<tr><td>\${lblTemperatureWindowOpenHeating}</td>"
      } else {
        append html "<tr><td>\${stringTableTemperatureFallWindowOpen}</td>"
      }
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]<input id=\"comfortOld\" type=\"hidden\" value=\"$ps($param)\"</td>"
      append html "</tr>"
    }

    #left
    set param TEMPERATURE_WINDOW_OPEN_COOLING
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr><td>\${lblTemperatureWindowOpenCooling}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]<input id=\"comfortOld\" type=\"hidden\" value=\"$ps($param)\"</td>"
      append html "</tr>"
    }

  append html "</table>"

  append html "<hr>"

  append html "<table class=\"ProfileTbl\">"
    # left
    incr prn
    set param BOOST_TIME_PERIOD
    array_clear options
    for {set val 0} {$val <= 30} {incr val 5} {
        set options($val) "$val min"
    }
    append html "<tr><td>\${stringTableBoostTimePeriod}</td>"
      append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  append html "</table>"

  if { ([info exists ps(CHANNEL_OPERATION_MODE)] == 1) || ([info exists ps(ACOUSTIC_ALARM_SIGNAL)] == 1) || ([info exists ps(EFFECT_ADAPTION_FADE_OUT_TIME_FACTOR)] == 1)  } {
    append html "<hr>"
    append html "<table class=\"ProfileTbl\">"
      set param CHANNEL_OPERATION_MODE
      if { [info exists ps($param)] == 1  } {
        incr prn
        array_clear options
        set options(0) "\${optionETRVNormalMode}"
        set options(1) "\${optionETRVSilentMode}"
        append html "<tr><td>\${lblOperatingMode}</td><td>"
        append html "[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param ]&nbsp;[getHelpIcon $param $hlpBoxWidth [expr $hlpBoxHeight * 0.75]]"
        append html "</td></tr>"
      }

      set param ACOUSTIC_ALARM_SIGNAL
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr>"
          append html "<td>\${lblAcousticAlarmSignal}</td>"
          append html "<td>"
          append html "[getCheckBox $CHANNEL '$param' $ps($param) $prn]&nbsp;[getHelpIcon $param $hlpBoxWidth [expr $hlpBoxHeight * 0.5]]"
          append html "</td>"
        append html "</tr>"
      }

      set param EFFECT_ADAPTION_FADE_OUT_TIME_FACTOR
      if { [info exists ps($param)] == 1  } {
        append html "<tr>"
          append html "<td>"
            append html "\${lblSignalColor}"
          append html "</td>"
          append html "<td><input id=\"btnShowEtrvEffects\" type=\"button\" name=\"btnShowEtrvEffects\" onclick=\"jQuery('.j_effectPanel').toggle();\"></td>"
          append html "<script type=\"text/javascript\">translateButtons(\"btnShowEtrvEffects\");</script>"
        append html "</tr>"
      }
    append html "</table>"

    if { [info exists ps($param)] == 1  } {
      append html "<table class='ProfileTbl j_effectPanel hidden'>"
       append html "[getHeatingControlEffects $chn]"
      append html "</table>"
    }
  }

  if {[session_is_expert]} {
    append html "<script type=\"text/javascript\">"
      append html "jQuery(\"\[name='expertParam'\]\").show();"
      append html "setDisplayMode(jQuery(\"\[name='SHOW_SET_TEMPERATURE'\]\").first());"
    append html "</script>"
  } else {
    append html "<script type=\"text/javascript\">"
      append html "jQuery(\"\[name='expertParam'\]\").hide();"
    append html "</script>"
  }
  append html "<script type=\"text/javascript\">"
  append html "setDisplayMode(jQuery(\"\[name='SHOW_SET_TEMPERATURE'\]\").first());</script>"

  return $html
}

proc getSwitchVirtualReceiver {chn p descr} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  puts "<script type=\"text/javascript\">getLangInfo_Special('VIRTUAL_HELP.txt');</script>"

  set specialID "[getSpecialID $special_input_id]"

  set html ""
  set prn 0
  set hr 0

  if {[session_is_expert]} {
    set param "LOGIC_COMBINATION"
    if { [info exists ps($param)] == 1  } {
      set hr 1
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableLogicCombination}</td>"
        option LOGIC_COMBINATION_SWITCH
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
        append html "<td>&nbsp<input class=\"j_helpBtn\" id=\"virtual_help_button_$chn\" type=\"button\" value=\${help} onclick=\"VirtualChannel_help($chn);\"></td>"
      append html "</tr>"
      append html "[getHorizontalLine]"
    }
  }

  set param POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html [getPowerUpSelector $chn ps $special_input_id]
  }

  if {$hr == 1} {
    #### HELP
    # append html "[getHorizontalLine]"
    append html "<tr><td colspan=\"3\">"
      append html "<table class=\"ProfileTbl\" id=\"virtual_ch_help_$chn\" style=\"display:none\">"
      append html "<tr><td>\${virtualHelpTxtSwitch}</td></tr>"
      append html "</table>"
    append html "</td></tr>"

    puts "<script type=\"text/javascript\">"
      puts "jQuery(\".j_helpBtn\").val(translateKey(\"helpBtnTxt\"));"
    puts "</script>"

  }

  if {$html == ""} {
    append html [getNoParametersToSet]
  }
  return $html
}

proc getEnergieMeterTransmitter {chn p descr} {
  global dev_descr
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set CHANNEL $special_input_id
  set specialID "[getSpecialID $special_input_id]"

  set devType $dev_descr(TYPE)

  set html ""

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HM_ES_PMSw.js')</script>"

  append html "<tr><td colspan='2'><b>\${energyMeterTransmitterHeader}<b/><br/><br/></td></tr>"

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    array_clear options
    set options(0) "\${optionModeConsumption}"
    set options(1) "\${optionModeFeeding}"
    append html "<tr><td>\${lblMode}</td>"
    append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon PSM_$param]</td>"
    append html "</tr>"
    append html "[getHorizontalLine]"
  }

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param TX_MINDELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableTxMinDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "txMinDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param TX_MINDELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableTxMinDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }
  append html [getHorizontalLine]

  set param AVERAGING
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTablePowerMeterAveraging}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  append html "<tr><td colspan='2'><br/><br/>\${PMSwChannel2HintHeader}</td></tr>"

  set param TX_THRESHOLD_POWER
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html  "<td>\${PMSwChannel2Hint_Power}</td>"
      array_clear option
      set option(0) "\${stringTableNotUsed}"
      set option(1) "\${optionEnterValue}"

      append prnTmp $prn _tmp

      append html  "<td>[getOptionBox '$param' option $ps($param) $chn $prnTmp "onchange=\"test(this, '$prn');\""]</td>"
      if {[devIsPowerMeter $devType]} {
        append html "<td><span id=\"field_$prn\">[getTextField $param $ps($param) $chn $prn]&nbsp;[getUserDefinedCondTXThresholdUnitMinMaxDescr $devType $param]</span></td>"
      } else {
        append html "<td><span id=\"field_$prn\">[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</span></td>"
      }
    append html "</tr>"
    append html "<script type=\"text/javascript\">"
      append html "if ($ps($param) > 0) {document.getElementById('separate_CHANNEL_$chn\_$prnTmp').options\[1\].selected = true;document.getElementById('field_$prn').style.visibility='visible';} else {document.getElementById('separate_CHANNEL_$chn\_$prnTmp').options\[0\].selected = true;document.getElementById('field_$prn').style.visibility='hidden';}"
    append html "</script>"
  }

  if { [info exists ps($param)] == 1  } {
    incr prn
    set param TX_THRESHOLD_ENERGY
    append html "<tr>"
    append html  "<td>\${PMSwChannel2Hint_Energy}</td>"
      array_clear option
      set option(0) "\${stringTableNotUsed}"
      set option(1) "\${optionEnterValue}"
      append prnTmp $prn _tmp
      append html  "<td>[getOptionBox '$param' option $ps($param) $chn $prnTmp "onchange=\"test(this, '$prn');\""]</td>"
      append html "<td><span id=\"field_$prn\">[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</span></td>"
    append html "</tr>"
      append html "<script type=\"text/javascript\">"
        append html "if ($ps($param) > 0) {document.getElementById('separate_CHANNEL_$chn\_$prnTmp').options\[1\].selected = true;document.getElementById('field_$prn').style.visibility='visible';} else {document.getElementById('separate_CHANNEL_$chn\_$prnTmp').options\[0\].selected = true;document.getElementById('field_$prn').style.visibility='hidden';}"
      append html "</script>"

    append html "<tr><td>\${PMSwChannel2Hint_Footer}<br/><br/></td></tr>"

    append html "<script type=\"text/javascript\">"
    append html "test = function(elm, prn) \{"
      append html "document.getElementById('field_' + prn).style.visibility=(elm.selectedIndex < 1)?'hidden':'visible';document.getElementById('separate_CHANNEL_$chn\_' +prn).value=parseFloat(elm.options\[elm.selectedIndex\].value);"
    append html "\};"

  append html "</script>"
  }
  return $html
}

proc getEnergieMeterTransmitterESI {chn p descr chnAddress} {
  global dev_descr
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set CHANNEL $special_input_id
  set specialID "[getSpecialID $special_input_id]"

  set devType $dev_descr(TYPE)

  set sensorUnknown  0
  set sensorGas 1
  set sensorLED 2
  set sensorIEC 3

  set chnOperationMode 0

  set html ""


  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HM_ES_PMSw.js')</script>"


  if {$chn == 1} {
    append html "<tr>"
      append html "<td>\${lblPowerMeterSensorIdentification}</td>"
      append html "<td><input id=\"btnSensorIdent\" type=\"button\" name=\"btnSensorDetection\" onclick=\"powerIdentSensor('$chnAddress');\"></td>"
    append html "</tr>"
    append html "<script type=\"text/javascript\">"
      append html "translateButtons(\"btnSensorDetection\");"
    append html "</script>"
  }


  set param CHANNEL_OPERATION_MODE
  if { ([info exists ps($param)] == 1) && ($chn >= 1) } {
    incr prn

    set chnOperationMode $ps($param)

    # for testing
    # append html "<tr><td><div class='attention'>CHANNEL_OPERATION_MODE: $chnOperationMode</div></td></tr>"

    array_clear options
    set options(0) "\${optionSensorUnknown}"
    set options(1) "\${optionSensorGas}"
    set options(2) "\${optionSensorLED}"
    set options(3) "\${optionSensorIEC}"
    set options(4) "\${optionSensorIEC_SML}"
    set options(5) "\${optionSensorIEC_SML_WH}"
    set options(6) "\${optionSensorIEC_D0_A}"
    set options(7) "\${optionSensorIEC_D0_B}"
    set options(8) "\${optionSensorIEC_D0_C}"
    set options(9) "\${optionSensorIEC_D0_D}"
    append html "<tr><td>\${lblSensorMode}</td>"
   # append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param onchange=showSensorType(this.value);]&nbsp;[getHelpIcon ESI_$param]</td>"
    append html "<td class='hidden'>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param disabled=true]</td>"
    append html "<td><div id='lblSensorType' style='background-color:\#d9d9d9; text-align:center'></div></td><td>&nbsp;[getHelpIcon ESI_$param 450 100]</td>"
    append html "</tr>"

   # append html "[getHorizontalLine]"
  }

  set param METER_CONSTANT_VOLUME
  if { ([info exists ps($param)] == 1) && ($chn >= 1) } {
    incr prn
    append html "<tr class='j_esiSensorGas j_sensorType hidden'>"
    #  append html "<td>\${stringTablePowerMeterConstantVolume}</td>"
      append html "<td>\${stringTablePowerMeterConstant}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param METER_CONSTANT_ENERGY
  if { ([info exists ps($param)] == 1) && ($chn >= 1) } {
    incr prn
    append html "<tr class='j_esiSensorLED j_sensorType hidden'>"
    #  append html "<td>\${stringTablePowerMeterConstantEnergy}</td>"
      append html "<td>\${stringTablePowerMeterConstant}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param METER_OBIS_SEARCH_STRING
  if { ([info exists ps($param)] == 1) && ($ps(CHANNEL_OPERATION_MODE) >= 3) } {
    set paramValue $ps($param)
    if {$paramValue == "$$$$$"} {
      set paramValue " "
    }
    incr prn
    append html "<tr class='j_esiSensorIEC j_sensorType hidden'>"
      append html "<td>\${stringTableMeterObisSearchString}</td>"
      # append html "<td>[getTextField $param $paramValue $chn $prn]&nbsp;&nbsp;[getMinMaxValueDescr $param]</td>"
      append html "<td>[getTextField $param $paramValue $chn $prn]&nbsp;[getHelpIcon ESI_$param 450 180]</td>"
    append html "</tr>"
  }

  if {$html == ""} {
    append html [getNoParametersToSet]
  } else {
    append html "<script type='text/javascript'>"

      if {[info exists ps(CHANNEL_OPERATION_MODE)] == 1} {
        append html "var sensor = $ps(CHANNEL_OPERATION_MODE),"
        append html "arSensorTypes = \['SENSOR_UNKNOWN', 'SENSOR_ES_GAS', 'SENSOR_ES_LED', 'SENSOR_ES_IEC', 'SENSOR_ES_IEC_SML', 'SENSOR_ES_IEC_SML_WH', 'SENSOR_ES_IEC_D0_A', 'SENSOR_ES_IEC_D0_B', 'SENSOR_ES_IEC_D0_C', 'SENSOR_ES_IEC_D0_D'\],"
        append html "arTranslationSensorTypes = \['optionSensorUnknown', 'optionSensorGas', 'optionSensorLED', 'optionSensorIEC', 'optionSensorIEC_SML', 'optionSensorIEC_SML_WH', 'optionSensorIEC_D0_A', 'optionSensorIEC_D0_B', 'optionSensorIEC_D0_C', 'optionSensorIEC_D0_D'  \];"

        append html "jQuery('\#lblSensorType').text(translateKey(arTranslationSensorTypes\[sensor\]));"
      }

      append html "showSensorType = function(val) {"
        append html "jQuery('.j_sensorType').hide();"
        append html "if (val > $sensorIEC) {"
          append html "jQuery('.j_esiSensorIEC').show();"
        append html "} else if (val == $sensorGas) {"
          append html "jQuery('.j_esiSensorGas').show();"
        append html "} else if (val == $sensorLED) {"
          append html "jQuery('.j_esiSensorLED').show();"
        append html "}"

        append html "footerElm = jQuery('#footerButtonOK, #footerButtonTake');"

      append html "};"

      if {$chn == 1} {
        append html "window.setTimeout(function() {"
          append html "showSensorType('$chnOperationMode');"
        append html "},50);"
     }

    append html "</script>"
  }

  return $html
}

proc getEnergieMeterTransmitterESIStartValue {chn p descr chnAddress chnOpMode} {
  global dev_descr
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set CHANNEL $special_input_id
  set specialID "[getSpecialID $special_input_id]"

  set devType $dev_descr(TYPE)

  # set startValue "0.000"

  append html "<tr>"
    append html "<td>\${lblSetStartValue}</td>"
    append html "<td>"
      append html "<input id='showStartVal_$chn' type='checkbox' class='j_chkBoxStartVal' onclick='hideShowStartVal(this,$chn)'>"
    append html "</td>"
  append html "</tr>"

  append html "<tr class='j_setStartVal_$chn hidden'>"
    append html "<td>\${lblStartValue}</td>"
    # append html "<td><input id=\"esiCounterStartVal_$chn\" type=\"text\" size=\"10\" value=\"$startValue\"></td>"
    append html "<td><input id=\"esiCounterStartVal_$chn\" type=\"text\" size=\"10\"></td>"
  append html "</tr>"

  append html "<tr class='j_setStartVal_$chn hidden'>"
    append html "<td></td>"
    append html "<td id='esiStartTime_$chn'>TIME</td>"
  append html "</tr>"

  if {$chnOpMode > 3} {
    set param METER_OBIS_SEARCH_STRING
    if { ([info exists ps($param)] == 1) && ($chn >= 1) } {
      set paramValue $ps($param)
      if {$paramValue == "$$$$$"} {
        set paramValue " "
      }

      append html "<tr><td colspan='2'><hr></td></tr>"

      incr prn
      append html "<tr>"
        append html "<td>\${stringTableMeterObisSearchString}</td>"
        # append html "<td>[getTextField $param $paramValue $chn $prn]&nbsp;&nbsp;[getMinMaxValueDescr $param]</td>"
        append html "<td>[getTextField $param $paramValue $chn $prn]&nbsp;[getHelpIcon ESI_$param 450 180]</td>"
      append html "</tr>"
    }
  }
  append html "<script type='text/javascript'>"

    append html "var selectedSensor = parseInt(jQuery('\#separate_CHANNEL_1_1').val()),"
    append html "arStartValueElms = jQuery('.j_chkBoxStartVal').parent().parent(),"
    append html "noParamsAvailable = '<td name=\"noParamElm\" class=\"CLASS22003\"><div>\${deviceAndChannelParamsLblNoParamsToSet}</div></td>',"
    append html "chnDescr = DeviceList.getChannelByAddress('$chnAddress'),"
    append html "chnID = chnDescr.id,"
    append html "chnIndex = parseInt(chnDescr.index),"
    append html "startValue = -1;"

    append html "var chn1_ps = homematic('Interface.getParamset', {'interface':'HmIP-RF', 'address': '$dev_descr(ADDRESS):1', 'paramsetKey': 'MASTER'}),"
    append html "sensor = chn1_ps.CHANNEL_OPERATION_MODE;"


    append html "if (chnIndex == 2) {"
      append html "startValue = homematic('Interface.getMetadata', {'objectId': chnDescr.id, 'dataId': 'startValA'});"
      append html "startTime = homematic('Interface.getMetadata', {'objectId': chnDescr.id, 'dataId': 'startTimeA'});"
      append html "if (startTime == 'null') {"
        append html "startTime = homematic('Interface.setMetadata', {'objectId': chnDescr.id, 'dataId': 'startTimeA', 'value' : getEsiStartTime()});"
        append html "jQuery('#esiStartTime_' + chnIndex).text(getEsiStartTime());"
      append html "} else {"
        append html "jQuery('#esiStartTime_' + chnIndex).text(startTime);"
      append html "}"

    append html "} else if (chnIndex == 3) {"
      append html "startValue = homematic('Interface.getMetadata', {'objectId': chnDescr.id, 'dataId': 'startValB'});"
      append html "startTime = homematic('Interface.getMetadata', {'objectId': chnDescr.id, 'dataId': 'startTimeB'});"
      append html "if (startTime == 'null') {"
        append html "startTime = homematic('Interface.setMetadata', {'objectId': chnDescr.id, 'dataId': 'startTimeB', 'value' : getEsiStartTime()});"
        append html "jQuery('#esiStartTime_' + chnIndex).text(getEsiStartTime());"
      append html "} else {"
        append html "jQuery('#esiStartTime_' + chnIndex).text(startTime);"
      append html "}"

    append html "} else if (chnIndex == 4) {"
    append html "startValue = homematic('Interface.getMetadata', {'objectId': chnDescr.id, 'dataId': 'startValC'});"
        append html "startTime = homematic('Interface.getMetadata', {'objectId': chnDescr.id, 'dataId': 'startTimeC'});"
        append html "if (startTime == 'null') {"
          append html "startTime = homematic('Interface.setMetadata', {'objectId': chnDescr.id, 'dataId': 'startTimeC', 'value' : getEsiStartTime()});"
          append html "jQuery('#esiStartTime_' + chnIndex).text(getEsiStartTime());"
        append html "} else {"
          append html "jQuery('#esiStartTime_' + chnIndex).text(startTime);"
        append html "}"

    append html "}"

    append html "if (isNaN(startValue) && (sensor < 3)) {"
      append html "startValue = 0.000;"
    append html "}"

    append html "if ((startValue != -1) && (startValue != 'null')) {"

      append html "if (sensor == 1) {"
        append html "startValue = parseFloat(startValue);"
      append html "} else {"
        append html "startValue = startValue / 1000;"
      append html "}"
      append html "jQuery('#esiCounterStartVal_' + chnIndex).val(startValue.toFixed(3));"
    append html "} else if (sensor >= 3) {"
      # sensor >= 3 = IEC-Sensor
      append html "var chValueParamSet = homematic('Interface.getParamset', {'interface':'HmIP-RF', 'address': '$chnAddress', 'paramsetKey': 'VALUES'}),"
      append html "energyCounter = chValueParamSet.ENERGY_COUNTER;"

      append html "if (energyCounter != '') {"
        append html "if (isNaN(startValue)) {startValue = energyCounter;}"
        append html "if (isNaN(startValue)) {startValue = 0;}"
          append html "jQuery('#esiCounterStartVal_' + chnIndex).val(parseFloat(startValue).toFixed(3));"
      append html "} else {"
        append html "jQuery('#esiCounterStartVal_' + chnIndex).val(energyCounter);"
      append html "}"

    append html "}"

    append html "if (selectedSensor < 3) {"
      append html "if (selectedSensor == 0) {"
        append html "jQuery(arStartValueElms).html(noParamsAvailable);"
      append html "} else {"
        append html "jQuery(arStartValueElms\[1\]).html(noParamsAvailable);"
        append html "jQuery(arStartValueElms\[2\]).html(noParamsAvailable);"
      append html "}"
    append html "}"


    append html "function storeCounterStartValue4Chn(chnNo, chnAddress, multiplier, dataID, sensor) {"

            append html "var rawStartVal = jQuery('\#esiCounterStartVal_' + chnNo).val(),"
            append html "startVal = (parseFloat(rawStartVal.replace(',','.')) * multiplier),"
            append html "oChn = DeviceList.getChannelByAddress(chnAddress),"
            append html "energyCounterID = 'svEnergyCounter_' + oChn.id + '_' + oChn.address,"
            append html "energyCounterOldValID = 'svEnergyCounterOldVal_' + oChn.id,"
            append html "metaStartVal = homematic('Interface.getMetadata', {'objectId': oChn.id, 'dataId': dataID}),"
            append html "metaStartTime = dataID.replace('Val','Time');"

            append html "if (rawStartVal.length != 0) {"
              append html "if (isNaN(startVal)) {"
                append html "alert(translateKey('msgStartValueInvalid_A') + oChn.index + translateKey('msgStartValueInvalid_B'));"
                append html "startVal = 0.000;"
              append html "}"

              append html "if (parseInt(startVal) != parseInt(metaStartVal)) {"
               append html "homematic('SysVar.setFloat', {'name': energyCounterID, 'value': startVal});"
               append html "homematic('SysVar.setFloat', {'name': energyCounterOldValID, 'value': startVal});"
               append html "homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': dataID, 'value': startVal});"
                append html "resetChnMetaEnergyCounter(oChn, sensor);"
                append html "startTime = homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': metaStartTime, 'value' : getEsiStartTime()});"
                append html "if (sensor > 3) {"
                  append html "homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': 'iecPrgFirstStart', 'value' : 0});"
                  append html "homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': 'firstStart', 'value' : 0});"
                append html "}"
              append html "}"
            append html "}"


    append html "}"


    append html "storeCounterStartValue = function() {"
      set devAddress [lindex [split $chnAddress :] 0]
      set chnAddressA "$devAddress:2"
      set chnAddressB "$devAddress:3"
      set chnAddressC "$devAddress:4"

      append html "var oChn = DeviceList.getChannelByAddress('$chnAddress'),"
      append html "selectedSensor = parseInt(jQuery('\#separate_CHANNEL_1_1').val()),"
      append html "multiplier = (selectedSensor == 1) ? 1 : 1000;"

      append html "jQuery.each(jQuery('.j_chkBoxStartVal:checked'), function(index, chkBox) {"
        append html "var chnId = chkBox.id.split('_')\[1\];"

        append html "switch (chnId) {"
          append html "case '2':"
            append html "storeCounterStartValue4Chn(chnId,'$chnAddressA', multiplier, 'startValA', selectedSensor);"
            append html "if (selectedSensor > 3) {homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': 'firstStart', 'value' : 1});}"
            append html "break;"
          append html "case '3':"
            append html "storeCounterStartValue4Chn(chnId,'$chnAddressB', multiplier, 'startValB', selectedSensor);"
            append html "if (selectedSensor > 3) {homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': 'firstStart', 'value' : 1});}"
            append html "break;"
          append html "case '4':"
            append html "storeCounterStartValue4Chn(chnId,'$chnAddressC', multiplier, 'startValC', selectedSensor);"
            append html "if (selectedSensor > 3) {homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': 'firstStart', 'value' : 1});}"
            append html "break;"
          append html "default: console.log('storeCounterStartValue; Error');"
        append html "}"
      append html "});"
    append html "};"

    append html "hideShowStartVal = function(elm, chnId) {"
      append html "var startValElms = jQuery('.j_setStartVal_' + chnId),"
      append html "footerElm = jQuery('#footerButtonOK, #footerButtonTake');"
      append html "if (jQuery(elm).is(':checked')) {"
        append html "startValElms.show();"

        append html "if(jQuery('.j_chkBoxStartVal:checked').length == 1) {"
          append html " footerElm.off('click').click(function() {storeCounterStartValue();});"
        append html "}"
      append html "} else {;"
        append html "startValElms.hide();"
        append html "if(jQuery('.j_chkBoxStartVal:checked').length == 0) {"
          append html "footerElm.off('click').click(function() {});"
        append html "}"
      append html "}"
    append html "};"
  append html "</script>"

  return $html
}

proc getCondSwitchTransmitter {chn p descr} {

  global iface dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set devType $dev_descr(TYPE)
  set chn [getChannel $special_input_id]

  set specialID "[getSpecialID $special_input_id]"

  set helpDlgWidth 450
  set helpDlgHeight 170

  set html ""

  set smsiSpecificText 0

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HM_ES_PMSw.js')</script>"

  if {[string equal $devType "ELV-SH-SMSI"] == 1} {
    if {($chn == 4) || ($chn == 5)} {
      set smsiSpecificText 1
    }
  }

  set param COND_TX_FALLING
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      if {$smsiSpecificText == 0} {
        append html "<td>\${stringTableCondTxFalling}</td>"
      } else {
        append html "<td>\${stringTableCondTxFallingC}</td>"
      }
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param $helpDlgWidth $helpDlgHeight]</td>"
    append html "</tr>"

    # Show hint when this channel has links
    append html [addHintCondTransmitterLinkAvailable $iface $dev_descr(ADDRESS)]

  }

  set param COND_TX_CYCLIC_BELOW
    if { [info exists ps($param)] == 1 } {
      incr prn;
      append html "<tr>"
        append html "<td>&nbsp;&nbsp;\${stringTableCondTxCyclicBelow}</td>"
        append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
      append html "</tr>"

      append html "<script type=\"text/javascript\">"
        append html "var condTxFallingRisingElm = jQuery('#separate_$specialID\_$chn\_[expr $prn - 1]');"
        append html "var condTxCyclicBelowAboveElm = jQuery('#separate_$specialID\_$chn\_$prn');"

        append html "if (condTxCyclicBelowAboveElm.is(':checked')) \{"
          append html "condTxFallingRisingElm.prop('disabled', true);"
        append html "\}"

        append html "condTxCyclicBelowAboveElm.click(function() \{"
          append html "var elmIsChecked = jQuery(this).is(':checked');"
          append html "if (elmIsChecked) \{"
            append html "condTxFallingRisingElm.prop('checked', true).prop('disabled',true);"
          append html "\} else \{"
            append html "condTxFallingRisingElm.prop('disabled',false);"
          append html "\}"
        append html "\});"
      append html "</script>"
    }

  append html [getHorizontalLine]

  set param COND_TX_RISING
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      if {$smsiSpecificText == 0} {
        append html "<td>\${stringTableCondTxRising}</td>"
      } else {
        append html "<td>\${stringTableCondTxRisingC}</td>"
      }
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param  $helpDlgWidth $helpDlgHeight]</td>"
    append html "</tr>"

    # Show hint when this channel has links
    append html [addHintCondTransmitterLinkAvailable $iface $dev_descr(ADDRESS)]
  }

  set param COND_TX_CYCLIC_ABOVE
  if { [info exists ps($param)] == 1 } {
    incr prn;
    append html "<tr>"
      append html "<td>&nbsp;&nbsp;\${stringTableCondTxCyclicAbove}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"

      append html "<script type=\"text/javascript\">"
        append html "var condTxFallingRisingElm = jQuery('#separate_$specialID\_$chn\_[expr $prn - 1]');"
        append html "var condTxCyclicBelowAboveElm = jQuery('#separate_$specialID\_$chn\_$prn');"

        append html "if (condTxCyclicBelowAboveElm.is(':checked')) \{"
          append html "condTxFallingRisingElm.prop('disabled', true);"
        append html "\}"

        append html "condTxCyclicBelowAboveElm.click(function() \{"
        append html "var elmIsChecked = jQuery(this).is(':checked');"
        append html "if (elmIsChecked) \{"
          append html "condTxFallingRisingElm.prop('checked', true).prop('disabled',true);"
        append html "\} else \{"
          append html "condTxFallingRisingElm.prop('disabled',false);"
        append html "\}"
        append html "\});"
      append html "</script>"

  }

  append html [getHorizontalLine]

  set param COND_TX_DECISION_BELOW
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    if {$smsiSpecificText == 0} {
      append html "<td>\${stringTableCondTxDecisionBelow}</td>"
    } else {
      append html "<td>\${stringTableCondTxDecisionBelowA}</td>"
    }
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon COND_TX_DECISION_ABOVE_BELOW]</td>"
    append html "</tr>"
  }

  set param COND_TX_DECISION_ABOVE
  if { [info exists ps($param)] == 1 } {
    incr prn;
    append html "<tr>"
     if {$smsiSpecificText == 0} {
       append html "<td>\${stringTableCondTxDecisionAbove}</td>"
     } else {
       append html "<td>\${stringTableCondTxDecisionAboveA}</td>"
     }
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon COND_TX_DECISION_ABOVE_BELOW]</td>"
    append html "</tr>"
  }


  if {[devIsPowerMeter $devType]} {
    set param COND_TX_THRESHOLD_LO
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableCondThresholdLo}</td>"
        append html "<td>"

          append html "<input id=\"thresLo_$chn\_$prn\" type=\"text\" size=\"5\" value=\"[expr $ps($param). / 100]\" onblur=\"ProofAndSetValue(this.id, this.id, '0.0', [getUserDefinedMaxValue $devType $param], 1); jQuery(this).next().val(this.value * 100)\"/>&nbsp;[getUserDefinedCondTXThresholdUnitMinMaxDescr $devType $param]"
          append html "[getTextField $param $ps($param) $chn $prn class=\"hidden\"]"

        append html "</td>"
      append html "</tr>"
    }

    set param COND_TX_THRESHOLD_HI
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableCondThresholdHi}</td>"
        append html "<td>"

          append html "<input id=\"thresHi_$chn\_$prn\" type=\"text\" size=\"5\" value=\"[expr $ps($param). / 100]\" onblur=\"ProofAndSetValue(this.id, this.id, '0.0', [getUserDefinedMaxValue $devType $param], 1); jQuery(this).next().val(this.value * 100)\"/>&nbsp;[getUserDefinedCondTXThresholdUnitMinMaxDescr $devType $param]"
          append html "[getTextField $param $ps($param) $chn $prn class=\"hidden\"]"

       append html "</td>"
      append html "</tr>"
    }
  } else {
    set param COND_TX_THRESHOLD_LO
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableCondThresholdLo}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getCondTXThresholdUnit $devType $chn]&nbsp;&nbsp;[getMinMaxValueDescr $param $chn]</td>"
      append html "</tr>"
    }

    set param COND_TX_THRESHOLD_HI
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableCondThresholdHi}</td>"
       append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getCondTXThresholdUnit $devType $chn]&nbsp;&nbsp;[getMinMaxValueDescr $param $chn]</td>"
      append html "</tr>"
    }

  }
  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    set param EVENT_RANDOMTIME_UNIT
    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]
  }

  set param EVENT_RANDOMTIME_VALUE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }
  return $html
}

proc getLevelCommandTransmitter_CO2 {chn p descr} {

  global iface dev_descr
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set devType $dev_descr(TYPE)
  set chn [getChannel $special_input_id]

  set specialID "[getSpecialID $special_input_id]"

  set helpDlgWidth 450
  set helpDlgHeight 170

  set html ""

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HM_ES_PMSw.js')</script>"

  set param COND_TX_FALLING
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableCondTxFalling}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param $helpDlgWidth $helpDlgHeight]</td>"
    append html "</tr>"

    # Show hint when this channel has links
    append html [addHintCondTransmitterLinkAvailable $iface $dev_descr(ADDRESS)]

  }

  set param COND_TX_CYCLIC_BELOW
  if { [info exists ps($param)] == 1 } {
    incr prn;
    append html "<tr>"
      append html "<td>&nbsp;&nbsp;\${stringTableCondTxCyclicBelow}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"

    append html "<script type=\"text/javascript\">"
      append html "var condTxFallingRisingElm = jQuery('#separate_$specialID\_$chn\_[expr $prn - 1]');"
      append html "var condTxCyclicBelowAboveElm = jQuery('#separate_$specialID\_$chn\_$prn');"

      append html "if (condTxCyclicBelowAboveElm.is(':checked')) \{"
        append html "condTxFallingRisingElm.prop('disabled', true);"
      append html "\}"

      append html "condTxCyclicBelowAboveElm.click(function() \{"
        append html "var elmIsChecked = jQuery(this).is(':checked');"
        append html "if (elmIsChecked) \{"
          append html "condTxFallingRisingElm.prop('checked', true).prop('disabled',true);"
        append html "\} else \{"
          append html "condTxFallingRisingElm.prop('disabled',false);"
        append html "\}"
      append html "\});"
    append html "</script>"
    append html [getHorizontalLine]
  }


  set param COND_TX_RISING
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableCondTxRising}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param  $helpDlgWidth $helpDlgHeight]</td>"
    append html "</tr>"

    # Show hint when this channel has links
    append html [addHintCondTransmitterLinkAvailable $iface $dev_descr(ADDRESS)]
  }

  set param COND_TX_CYCLIC_ABOVE
  if { [info exists ps($param)] == 1 } {
    incr prn;
    append html "<tr>"
      append html "<td>&nbsp;&nbsp;\${stringTableCondTxCyclicAbove}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"

    append html "<script type=\"text/javascript\">"
      append html "var condTxFallingRisingElm = jQuery('#separate_$specialID\_$chn\_[expr $prn - 1]');"
      append html "var condTxCyclicBelowAboveElm = jQuery('#separate_$specialID\_$chn\_$prn');"

      append html "if (condTxCyclicBelowAboveElm.is(':checked')) \{"
        append html "condTxFallingRisingElm.prop('disabled', true);"
      append html "\}"

      append html "condTxCyclicBelowAboveElm.click(function() \{"
      append html "var elmIsChecked = jQuery(this).is(':checked');"
      append html "if (elmIsChecked) \{"
        append html "condTxFallingRisingElm.prop('checked', true).prop('disabled',true);"
      append html "\} else \{"
        append html "condTxFallingRisingElm.prop('disabled',false);"
      append html "\}"
      append html "\});"
    append html "</script>"
    append html [getHorizontalLine]
  }


  set param COND_TX_DECISION_BELOW
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableCondTxDecisionBelow}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon COND_TX_DECISION_ABOVE_BELOW]</td>"
    append html "</tr>"
  }

  set param COND_TX_DECISION_ABOVE
  if { [info exists ps($param)] == 1 } {
    incr prn;
    append html "<tr>"
      append html "<td>\${stringTableCondTxDecisionAbove}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon COND_TX_DECISION_ABOVE_BELOW]</td>"
    append html "</tr>"
  }


  if {[devIsPowerMeter $devType]} {
    set param COND_TX_THRESHOLD_LO
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableCondThresholdLo}</td>"
        append html "<td>"

          append html "<input id=\"thresLo_$chn\_$prn\" type=\"text\" size=\"5\" value=\"[expr $ps($param). / 100]\" onblur=\"ProofAndSetValue(this.id, this.id, '0.0', [getUserDefinedMaxValue $devType $param], 1); jQuery(this).next().val(this.value * 100)\"/>&nbsp;[getUserDefinedCondTXThresholdUnitMinMaxDescr $devType $param]"
          append html "[getTextField $param $ps($param) $chn $prn class=\"hidden\"]"

        append html "</td>"
      append html "</tr>"
    }

    set param COND_TX_THRESHOLD_HI
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableCondThresholdHi}</td>"
        append html "<td>"

          append html "<input id=\"thresHi_$chn\_$prn\" type=\"text\" size=\"5\" value=\"[expr $ps($param). / 100]\" onblur=\"ProofAndSetValue(this.id, this.id, '0.0', [getUserDefinedMaxValue $devType $param], 1); jQuery(this).next().val(this.value * 100)\"/>&nbsp;[getUserDefinedCondTXThresholdUnitMinMaxDescr $devType $param]"
          append html "[getTextField $param $ps($param) $chn $prn class=\"hidden\"]"

       append html "</td>"
      append html "</tr>"
    }
  } else {
    set param COND_TX_THRESHOLD_LO
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableCondThresholdLo}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getCondTXThresholdUnit $devType $chn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
      append html "</tr>"
    }

    set param COND_TX_THRESHOLD_HI
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableCondThresholdHi}</td>"
       append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getCondTXThresholdUnit $devType $chn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
      append html "</tr>"
    }

  }
  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }
  return $html
}


# ACCELERATION_TRANSCEIVER
proc getAccelerationTransceiver {chn p descr address} {

  global dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set CHANNEL $special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set parent [lindex [split $address :] 0]

  set newFw false

  set Fw [getDevFwMajorMinorPatch]
  set fwMajor [lindex $Fw 0]
  set fwMinor [lindex $Fw 1]
  # not needed - set fwPatch [lindex $Fw 2]

  set devType $dev_descr(TYPE)

  set hlpBoxWidth 450
  set hlpBoxHeight 160

  if {($fwMajor > 1 || ($fwMajor == 1 && $fwMinor >= 2) ) || ([string equal $devType "ELV-SH-TACO"] == 1) || ([string equal $devType "ELV-SH-CTV"] == 1)} {
    set newFw true
  }

  set prn 0

  set operationMode $ps(CHANNEL_OPERATION_MODE)
  set html ""
  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1 } {
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_FILTER_NUMBER
  if { [info exists ps($param)] == 1  } {
    incr prn
    # convert float to int (0.0 = 0)
    set min [expr {int([expr [getMinValue $param]])}]
    set max [expr {int([expr [getMaxValue $param]])}]

    array_clear options
    for {set val $min} {$val <= $max} {incr val 1} {
        set options($val) "$val"
    }

    append html "<tr>"
      append html "<td>\${stringTableEventFilterNumber}</td>"
      append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param\_motionDetect $hlpBoxWidth $hlpBoxHeight]</td>"
    append html "</tr>"
  }

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${motionDetectorChannelOperationMode}</td>"
      array_clear options
      # not in use for HmIP-SAM set options(0) "\${motionDetectorChannelOperationModeOff}"
      set options(1) "\${motionDetectorChannelOperationModeAnyMotion}"
      set options(2) "\${motionDetectorChannelOperationModeFlat}"

      if {$newFw && ([string equal $devType "HmIP-SAM"] != 1) } {
        set options(3) "\${motionDetectorChannelOperationModeTilt}"
      }

      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn onchange=\"changeParamDescription(this.value)\"]</td>"

      append html "<script type=\"text/javascript\">"
        append html "changeParamDescription = function(value) {"

          append html "var optionNoMotion = translateKey(\"motionDetectorOptionNoMotion_\"+value),"
          append html "optionMotion = translateKey(\"motionDetectorOptionMotion_\"+value);"

          append html "var optMsgPosA = jQuery(\"\[name='MSG_FOR_POS_A'\] option\");"
          append html "jQuery(optMsgPosA\[1\]).text(optionNoMotion);"
          append html "jQuery(optMsgPosA\[2\]).text(optionMotion);"

          append html "var optMsgPosB = jQuery(\"\[name='MSG_FOR_POS_B'\] option\");"
          append html "jQuery(optMsgPosB\[1\]).text(optionNoMotion);"
          append html "jQuery(optMsgPosB\[2\]).text(optionMotion);"

          append html "if (value == 3) \{"
            append html "jQuery(\"\[name='MSG_FOR_POS_A'\]\").append(new Option(translateKey('motionDetectorOptionNotTilted'), 3));"
            append html "jQuery(\"\[name='MSG_FOR_POS_B'\]\").append(new Option(translateKey('motionDetectorOptionNotTilted'), 3));"
          append html "\} else \{"
            append html "jQuery(\"\[name='MSG_FOR_POS_A'\] option\[value='3'\]\").remove();"
            append html "jQuery(\"\[name='MSG_FOR_POS_B'\] option\[value='3'\]\").remove();"
          append html "\}"

          append html "jQuery(\"\[name='messageMovement'\]\").html(translateKey(\"motionDetectorMessageMovement_\"+value));"
          append html "jQuery(\"\[name='messageNoMovement'\]\").html(translateKey(\"motionDetectorMessageNoMovement_\"+value));"
          append html "jQuery(\"\[name='NotiMovement'\]\").html(translateKey(\"motionDetectorNotificationMovement_\"+value));"
          append html "jQuery(\"\[name='NotiNoMovement'\]\").html(translateKey(\"motionDetectorNotificationNoMovement_\"+value));"

          # SPHM-1343
          append html "if (value == 1) \{"
            append html "jQuery('\#triggerAngle, #triggerAngleHysteresis').hide();"
          append html "\} else \{"
            append html "jQuery('\#triggerAngle, #triggerAngleHysteresis').show();"
          append html "\}"

          # SPHM-1343
          append html "if (([string equal $devType "HmIP-STV"] == 1) && (value == 2)) \{"
              append html "var min = 10, max = 45,"
              append html "triggerAngleElm = jQuery(\"\[name='TRIGGER_ANGLE'\]\").first(),"
              append html "triggerAngleMinMaxElm = jQuery('\#triggerAngleMinMax');"

              append html "jQuery('#lbltriggerAngleHysteresis').text(translateKey('motionDetectorTriggerAngleHysteresis'));"

              append html "triggerAngleMinMaxElm.text('(10 - 45)');"

              append html "triggerAngleElm.unbind(\"blur\");"
              append html "triggerAngleElm.removeAttr(\"onblur\");"
              append html "triggerAngleElm.bind(\"blur\",function() \{"
                append html "SetTriggerAngle2(this.value, 180);"
                append html "ProofAndSetValue(this.id, this.id, min, max, 1);"
              append html "\});"
          append html "\} else \{"
              append html "var min = 1, max = 180,"
              append html "triggerAngleElm = jQuery(\"\[name='TRIGGER_ANGLE'\]\").first(),"
              append html "triggerAngleMinMaxElm = jQuery('\#triggerAngleMinMax');"

              append html "jQuery('#lbltriggerAngleHysteresis').text(translateKey('motionDetectorTriggerAngleHysteresisA'));"

              append html "triggerAngleMinMaxElm.text('(1 - 180)');"

              append html "triggerAngleElm.unbind(\"blur\");"
              append html "triggerAngleElm.removeAttr(\"onblur\");"
              append html "triggerAngleElm.bind(\"blur\",function() \{"
                append html "SetTriggerAngle2(this.value, 180);"
                append html "ProofAndSetValue(this.id, this.id, min, max, 1);"
              append html "\});"
          append html "\}"

           append html "if (value == 3) \{"
            append html "jQuery(\"\[name='tiltElem'\]\").show();"
          append html "\} else \{"
            append html "jQuery(\"\[name='tiltElem'\]\").hide();"
          append html "\}"
        append html "};"

        append html "window.setTimeout(function() \{jQuery(\"\[name='CHANNEL_OPERATION_MODE'\]\").change();\},50);"

      append html "</script>"
    append html "</tr>"
  }

  set comment {
    # For the HmIP-SAM this parameter is always 1 and not changeable
    incr prn
    set param EVENT_FILTER_NUMBER
    append html "<tr>"
      append html "<td>\${stringTableEventFilterNumber}</td>"
     append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param EVENT_FILTER_PERIOD
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${motionDetectorFilterPeriod}</td>"
     append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param MSG_FOR_POS_A
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${motionDetectorMessageMovement_$operationMode}</td>"
      array_clear options
      set options(0) "\${motionDetectorOptionNoMessage}"
      set options(1) "\${motionDetectorOptionNoMotion_$operationMode}"
      set options(2) "\${motionDetectorOptionMotion_$operationMode}"

      if {$operationMode == 3} {
        set options(3) "\${motionDetectorOptionNotTilted}"
      }

      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param MSG_FOR_POS_B
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${motionDetectorMessageNoMovement_$operationMode}</td>"
      array_clear options
      set options(0) "\${motionDetectorOptionNoMessage}"
      set options(1) "\${motionDetectorOptionNoMotion_$operationMode}"
      set options(2) "\${motionDetectorOptionMotion_$operationMode}"

      if {$operationMode == 3} {
        set options(3) "\${motionDetectorOptionNotTilted}"
      }

      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param MSG_FOR_POS_C
  if { [info exists ps($param)] == 1 } {

    set paramVisible "hidden"

    if {$operationMode == 3} {
      set paramVisible ""
    }

    incr prn
    append html "<tr name='tiltElem' class='$paramVisible'>"
      append html "<td>\${motionDetectorMessageTilted}</td>"
      array_clear options
      set options(0) "\${motionDetectorOptionNoMessage}"
      set options(1) "\${motionDetectorOptionNoMotion_2}"
      set options(2) "\${motionDetectorOptionMotion_2}"
      set options(3) "\${motionDetectorOptionNotTilted}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }


  set param NOTIFICATION_SOUND_TYPE_LOW_TO_HIGH
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${motionDetectorNotificationMovement_$operationMode}</td>"
      array_clear options
      set options(0) "\${stringTableSoundNoSound}"
      set options(1) "\${stringTableSoundShort}"
      set options(2) "\${stringTableSoundShortShort}"
      set options(3) "\${stringTableSoundLong}"
      set options(4) "\${stringTableSoundLongShort}"
      set options(5) "\${stringTableSoundLongLong}"
      set options(6) "\${stringTableSoundLongShortShort}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param NOTIFICATION_SOUND_TYPE_HIGH_TO_LOW
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${motionDetectorNotificationNoMovement_$operationMode}</td>"
      array_clear options
      set options(0) "\${stringTableSoundNoSound}"
      set options(1) "\${stringTableSoundShort}"
      set options(2) "\${stringTableSoundShortShort}"
      set options(3) "\${stringTableSoundLong}"
      set options(4) "\${stringTableSoundLongShort}"
      set options(5) "\${stringTableSoundLongLong}"
      set options(6) "\${stringTableSoundLongShortShort}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param SENSOR_SENSITIVITY
  if { [info exists ps($param)] == 1 } {
    incr prn

    # SENSOR_SENSITIVITY can be an enum or a float value.
    # Enum values are e. g. SENSOR_RANGE_16G SENSOR_RANGE_8G .... SENSOR_RANGE_2G_2PLUS_SENSE (e. g. HmIP-SAM or HmIP-FLC)
    # The HmIP-DLP(-A) e. g. is using a float value (0.0 - 255.0)

    # convert float to int (0.0 = 0) - when valType == 1 the the parameter is an enum
    set valType [catch {set maxValue [expr {int([expr [getMaxValue $param]])}]}]

    append html "<tr>"
    if {$valType == 0} {
      append html "<tr>"
        append html "<td>\${stringTableDeviceSensorSensibility}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_door_lock]</td>"
      append html "</tr>"
    } else {
        append html "<td>\${motionDetectorSensorSensivity}</td>"
        array_clear options
        set options(0) "\${motionDetectorSensorRange16G}"
        set options(1) "\${motionDetectorSensorRange8G}"
        set options(2) "\${motionDetectorSensorRange4G}"
        set options(3) "\${motionDetectorSensorRange2G}"
        set options(4) "\${motionDetectorSensorRange2GPlusSens}"
        set options(5) "\${motionDetectorSensorRange2G2PlusSense}"
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 170]</td>"
    }
    append html "</tr>"
  }

  set param TRIGGER_ANGLE
  if { [info exists ps($param)] == 1 } {

    if {[info exists ps(TRIGGER_ANGLE_2)] == 1} {
      global  valTriggerAngle2
      set valTriggerAngle2 $ps(TRIGGER_ANGLE_2)
    }

    incr prn
    append html "<tr id='triggerAngle'>"
      append html "<td>\${motionDetectorTriggerAngle}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;<span id='triggerAngleMinMax'>[getMinMaxValueDescr $param]</span>&nbsp;[getHelpIcon $param 320 100]</td>"
    append html "</tr>"
  }

  set param TRIGGER_ANGLE_HYSTERESIS
  if { [info exists ps($param)] == 1 } {

    incr prn
    append html "<tr id='triggerAngleHysteresis'>"
      append html "<td id='lbltriggerAngleHysteresis'>\${motionDetectorTriggerAngleHysteresis}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param 320 100]</td>"
    append html "</tr>"
  }


  set param TRIGGER_ANGLE_2
  if { [info exists ps($param)] == 1 } {
    global valTriggerAngle
    set paramVisible "hidden"
    set valTriggerAngle $ps(TRIGGER_ANGLE)

    if {$operationMode == 3} {
      set paramVisible ""
    }
    incr prn
    append html "<tr name='tiltElem' class='$paramVisible'>"
      append html "<td>\${motionDetectorTriggerAngle2}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param 320 100]</td>"
    append html "</tr>"
  }

  set param LED_DISABLE_CHANNELSTATE
  if { [info exists ps($param)] == 1  } {
     incr prn
     append html "<tr>"
       append html "<td>\${stringTableLEDDisableChannelState}</td>"
       append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
     append html "</tr>"
  }

  return $html
}

# ACCELERATION_TRANSCEIVER e. g. DLP
proc getAccelerationTransceiver_A {chn p descr address} {

  global dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set CHANNEL $special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set parent [lindex [split $address :] 0]

  set newFw false

  set Fw [getDevFwMajorMinorPatch]
  set fwMajor [lindex $Fw 0]
  set fwMinor [lindex $Fw 1]
  # not needed - set fwPatch [lindex $Fw 2]

  set devType $dev_descr(TYPE)

  set hlpBoxWidth 450
  set hlpBoxHeight 160



  set prn 0

  set operationMode $ps(CHANNEL_OPERATION_MODE)
  set html ""

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    array_clear options
    set options(0) "\${optionInactiv}"
    set options(1) "\${optionVibrationControl}"
    set options(2) "\${optionPositionControl}"
    set options(3) "\${optionPositionVibrationControl}"
    append html "<tr><td>\${lblSabotage_A}</td><td>"
      append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
    append html "</td></tr>"
    append html "[getHorizontalLine]"
  }

  set param EVENT_TIMEOUT_BASE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${lblEventTimeOut_DLP}</td>"
    append html [getComboBox $chn $prn "$specialID" "delayShort"]
    append html "</tr>"

    #param = EVENT_TIMEOUT_BASE
    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_TIMEOUT_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventTimeoutValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_FILTER_NUMBER
  if { [info exists ps($param)] == 1  } {
    incr prn
    set prnA [expr $prn + 1]

    # convert float to int (0.0 = 0)
    set min [expr {int([expr [getMinValue $param]])}]
    set max [expr {int([expr [getMaxValue $param]])}]
    array_clear options
    for {set val $min} {$val <= $max} {incr val 1} {
        set options($val) "$val"
    }

    append html "<tr>"
    append html "<td>\${lblEventFilterPeriodB1}</td>"
     append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;\${lblEventFilterPeriodB2}&nbsp;[getTextField EVENT_FILTER_PERIOD $ps(EVENT_FILTER_PERIOD) $chn $prnA]&nbsp;[getUnit EVENT_FILTER_PERIOD]&nbsp;[getMinMaxValueDescr EVENT_FILTER_PERIOD]</td>"
    append html "</tr>"
    incr prn
   # append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentEventFilterTime($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param SENSOR_SENSITIVITY
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblDeviceSensorSensibility_DLP}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_DLP 320 100]</td>"
    append html "</tr>"
  }

  append html "[getHorizontalLine]"

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
    append html "<td>\${lblEventDelay_A}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]
    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableEventDelayValue}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param TRIGGER_ANGLE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblTriggerAngle_DLP}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;<span id='triggerAngleMinMax'>[getMinMaxValueDescr $param]</span>&nbsp;[getHelpIcon $param 320 100]</td>"
    append html "</tr>"
  }

  return $html
}

proc getClimateControlFloorDirectTransmitter {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set CHANNEL $special_input_id

  set html ""
  set prn 0

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-FAL_MIOB.js');</script>"

  set param COOLING_DISABLE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableCoolingDisable}</td>"
      option OPTION_DISABLE_ENABLE
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param HEATING_DISABLE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableHeatingDisable}</td>"
      option OPTION_DISABLE_ENABLE
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param FLOOR_HEATING_MODE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableFloorHeatingMode}</td>"
      option FLOOR_HEATING_MODE
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param HEATING_MODE_SELECTION
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableHeatingModeSelection}</td>"
      option HEATING_MODE_SELECTION
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param FROST_PROTECTION_TEMPERATURE
  if { [info exists ps($param)] == 1 } {
    set min [expr {[expr [getMinValue $param]]}]
    set max [expr {[expr [getMaxValue $param]]}]

    array_clear options
    set options(1.5) \${optionNotActive}
    for {set val $min} {$val <= $max} {set val [expr $val + 0.5]} {
      if {$val != 1.5} {
        set options($val) "$val"
      }
    }

    incr prn
    append html "<tr>"
      append html "<td>\${stringTableFrostProtectionTemperature}</td>"
      append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getUnit $param]</td>"
    append html "</tr>"
  }

  set param HEATING_VALVE_TYPE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableHeatingValveType}</td>"
      option NORMALLY_CLOSE_OPEN
      append html  "<td>[getOptionBox $param options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  set param HUMIDITY_LIMIT_DISABLE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableHumidityLimitDisable}</td>"
      option OPTION_DISABLE_ENABLE
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param HUMIDITY_LIMIT_VALUE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableHumidityLimitValue}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param MINIMAL_FLOOR_TEMPERATURE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableMinimalFloorTemperature}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param CLIMATE_CONTROL_TYPE
  if { [info exists ps($param)] == 1 } {
    append html "[getHorizontalLine]"
    incr prn
    append html "<tr>"
      append html "<td>\${lblOperationMode}</td>"
      array_clear options
      set options(0) "\${optionPWMControl}"
      set options(1) "\${optionTwoPointControl}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param TWO_POINT_HYSTERESIS
  if {[info exists ps($param)] == 1} {
    incr prn
    array_clear options
    for {set val 0.2} {$val <= 2.0} {set val [expr $val + 0.2]} {
        set options($val) "$val K"
    }
    append html "<tr>"
      append html "<td>\${stringTableSwitchTransmitTwoPointHysteresis}</td>"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

#######################################################################################
  append html "[getHorizontalLine]"

  # SWITCHING_INTERVAL_BASE and INTERVAL_FACTOR

  incr prn
  append html "<tr>"
  append html "<td>\${lblDecalcificationInterval}</td>"
  append html [getComboBox $chn $prn "$specialID" "switchingInterval"]
  append html "</tr>"

  set param SWITCHING_INTERVAL_BASE
  append html [getTimeUnitComboBoxB $param $ps($param) $chn $prn $special_input_id]

  incr prn
  set param SWITCHING_INTERVAL_FACTOR
  append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
  append html "<td>\${stringTableSwitchingIntervalValue}</td>"

  append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

  append html "</tr>"
  append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
  append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

  # END SWITCHING_INTERVAL_BASE and INTERVAL_FACTOR

  # ON_TIME_BASE and ON_TIME_FACTOR

  incr prn
  append html "<tr>"
  append html "<td>\${stringTableOnTime}</td>"
  append html [getComboBox $chn $prn "$specialID" "switchingIntervalOnTime"]
  append html "</tr>"

  set param ON_TIME_BASE
  append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

  incr prn
  set param ON_TIME_FACTOR
  append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
  append html "<td>\${stringTableOnTimeValue}</td>"

  append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

  append html "</tr>"
  append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
  append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOnTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

  # END ON_TIME_BASE and ON_TIME_FACTOR

  return $html
}


proc getClimateHeatDemandBoilerTransmitter {chn p descr} {

  global iface dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set devType $dev_descr(TYPE)
  set chn [getChannel $special_input_id]

  set specialID "[getSpecialID $special_input_id]"

  set helpDlgWidth 450
  set helpDlgHeight 170

  set html ""

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HM_ES_PMSw.js')</script>"

  # ONDELAY_TIME_BASE / ONDELAY_TIME_FACTOR
  set param ONDELAY_TIME_BASE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableOnDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "delay0To20M_step2M"]
    append html "</tr>"

    append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param ONDELAY_TIME_FACTOR
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableOnDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

    # OFFDELAY_TIME_BASE / OFFDELAY_TIME_FACTOR
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableOffDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "delay0To20M_step2M"]
    append html "</tr>"

    set param OFFDELAY_TIME_BASE
    append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param OFFDELAY_TIME_FACTOR
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableOffDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  } else {
    append html "[getNoParametersToSet]"
  }
  return $html
}

proc getShutterContact {chn p descr} {
  global env
  # source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipAlarmPanel.tcl]

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set CHANNEL $special_input_id

  set hlpBoxWidth 450
  set hlpBoxHeight 160

  set html ""

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_FILTER_NUMBER
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventFilterTimeA}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventFilterTime"]
    append html "</tr>"

    append html [getEventFilterNumber $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_FILTER_PERIOD
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventFilterPeriodA}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentEventFilterTime($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param SAMPLE_INTERVAL
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${genericSampleInterval}</td>"
     append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
     append html "<td>[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param MSG_FOR_POS_A
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr><td>"
      array_clear options
      set options(0) "\${stringTableShutterContactMsgPosA2}"
      set options(1) "\${stringTableShutterContactMsgPosA1}"
      set options(2) "\${stringTableShutterContactMsgPosA3}"
      append html "<tr><td>\${stringTableShutterContactHmIPMsgPosA0}</td><td>"
      append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
    append html "</td></tr>"
  }

  set param MSG_FOR_POS_B
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr><td>"
      array_clear options
      set options(0) "\${stringTableShutterContactMsgPosA2}"
      set options(1) "\${stringTableShutterContactMsgPosA1}"
      set options(2) "\${stringTableShutterContactMsgPosA3}"
      append html "<tr><td>\${stringTableShutterContactHmIPMsgPosB0}</td><td>"
      append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
    append html "</td></tr>"
  }

  # append html "[getAlarmPanel ps]"

  return $html
}

proc getPassageDetector {chn p descr} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"
  set CHANNEL $special_input_id

  set html ""

  set param ATC_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      array_clear options
      set options(0) "\${optionInactiv}"
      set options(1) "\${optionActiv}"
      append html "<td>\${stringTableATCMode}</td>"
      append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param onchange=\"setATCAdatptionInterval()\"]</td>"
    append html "</tr>"
  }

  set param ATC_ADAPTION_INTERVAL
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      array_clear options
      set options(0) "\${optionUnit15M}"
      set options(1) "\${optionUnit30M}"
      set options(2) "\${optionUnit60M}"
      set options(3) "\${optionUnit120M}"
      append html "<td name=\"paramATCAdaptionInterval\" class=\"hidden\">\${stringTableATCAdaptionInterval}</td>"
      append html "<td name=\"paramATCAdaptionInterval\" class=\"hidden\">[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]</td>"
    append html "</tr>"

    append html "[getHorizontalLine "name=\"paramATCAdaptionInterval\" class=\"hidden\""]"

    append html "<script type=\"text/javascript\">"
      append html "window.setTimeout(function() {"
        append html "setATCAdatptionInterval = function() {"
          append html "var elmATCMode = jQuery(\"\[name='ATC_MODE'\]\");"
          append html "var elmATCInterval = jQuery(\"\[name='paramATCAdaptionInterval'\]\");"
          append html "if (elmATCMode.val() == 1) {elmATCInterval.show();} else {elmATCInterval.hide();}"
        append html "};"

        append html "setATCAdatptionInterval();"
      append html "},100);"
    append html "</script>"
  }

  set param EVENT_BLINDTIME_BASE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventBlindTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "delayShort"]
    append html "</tr>"

    # param = EVENT_BLINDTIME_BASE
    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_BLINDTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableBlindTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_TIMEOUT_BASE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventTimeoutPassageDetector}</td>"
    append html [getComboBox $chn $prn "$specialID" "delayShort"]
    append html "</tr>"

    #param = EVENT_TIMEOUT_BASE
    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_TIMEOUT_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventTimeoutValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param LED_DISABLE_CHANNELSTATE
  if { [info exists ps($param)] == 1  } {
     incr prn
     append html "<tr>"
       append html "<td>\${stringTableLEDDisableChannelState}</td>"
       append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
     append html "</tr>"
  }

  set param SENSOR_SENSITIVITY
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableSensorSensivity}</td>"
      option RAW_0_100Percent
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }
  return $html
}

proc getPassageDetectorDirectionTransmitter {chn p descr} {
  global env
  # source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipAlarmPanel.tcl]

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"
  set CHANNEL $special_input_id

  set html ""

  set lblPassageDetection "\${stringTablePassageDetectionRight}"

  if { ! [catch {set tmp $ps(COND_TX_DECISION_BELOW)}]  } {
    set lblPassageDetection "\${stringTablePassageDetectionLeft}"
  }

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    array_clear options
    set options(0) "\${optionInactiv}"
    set options(1) "\${optionActiv}"
    append html "<tr><td>$lblPassageDetection</td><td>"
    append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param onchange=\"showDecisionValue(this.value,$chn)\"]
    append html "</td></tr>"
  }

  if {[session_is_expert]} {
    set param COND_TX_DECISION_ABOVE
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr id=\"decisionVal_$chn\" class=\"hidden\">"
        append html "<td>\${stringTableCondValuePassageDetectionRight}</td>"
        append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon COND_TX_DECISION_ABOVE_BELOW]</td>"
      append html "</tr>"
    }

    set param COND_TX_DECISION_BELOW
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr id=\"decisionVal_$chn\" class=\"hidden\">"
        append html "<td>\${stringTableCondValuePassageDetectionLeft}</td>"
        append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon COND_TX_DECISION_ABOVE_BELOW]</td>"
      append html "</tr>"
    }
  }

  # append html "[getAlarmPanel ps]"

  append html "<script type=\"text/javascript\">"
    append html "showDecisionValue = function(value, chn) {"
      append html "var decisionValElm = jQuery(\"#decisionVal_\"+chn);"
      append html "if (value == 0) {"
        append html "decisionValElm.hide();"
      append html "} else {"
        append html "decisionValElm.show();"
      append html "}"
    append html "};"
    append html "showDecisionValue(jQuery(\"#separate_$CHANNEL\_1\").val(), $chn);"
  append html "</script>"

  return $html
}

proc getPassageDetectorCounterTransmitter {chn p descr} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"
  set CHANNEL $special_input_id

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HM_ES_PMSw.js')</script>"

  set html ""

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr><td>"
      array_clear options
      set options(0) "1 - \${optionInactiv}"
      set options(1) "2 - \${optionPassageCounterDetectionLR}"
      set options(2) "3 - \${optionPassageCounterDetectionL}"
      set options(3) "4 - \${optionPassageCounterDetectionR}"
      # set options(4) "5 - \${optionPassageCounterDeltaLR}"
      set options(5) "5 - \${optionPassageCounterDeltaL}"
      set options(6) "6 - \${optionPassageCounterDeltaR}"
      append html "<tr>"
        append html "<td>\${stringTablePassageDetectorCounterTransmitterChannelOperationMode}</td>"
        append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param onchange=\"showOpModesValues(this.value,$chn)\"]&nbsp;[getHelpIcon SPDR_CHANNEL_MODE]</td>"
      append html "</tr>"
  }

  if {[session_is_expert]} {
    set param COND_TX_DECISION_ABOVE
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr id=\"condTxDecisionAbove_$chn\" class=\"_hidden\">"
        append html "<td id=\"condTxDecisionAboveDescr_$chn\"></td>"
        append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon COND_TX_DECISION_ABOVE_BELOW]</td>"
      append html "</tr>"
    }

    set param COND_TX_DECISION_BELOW
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr id=\"condTxDecisionBelow_$chn\" class=\"_hidden\">"
        append html "<td id=\"condTxDecisionBelowDescr_$chn\"></td>"
        append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon COND_TX_DECISION_ABOVE_BELOW]</td>"
      append html "</tr>"
    }
  }

  append html "[getHorizontalLine id=\"condTxHorizontalLine_$chn\"]"
  append html "<tr id=\"condTxThresholdHeaderA_$chn\"><td colspan=\"2\">\${numberOfPassesBeforeSendingDecisionVal}</td></tr>"
  append html "<tr id=\"condTxThresholdHeaderB_$chn\"><td colspan=\"2\">\${deltaOfPassesBeforeSendingDecisionVal}</td></tr>"

  set param COND_TX_THRESHOLD_HI
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr id=\"condTxThresholdHi_$chn\" class=\"_hidden\">"
      append html "<td id=\"condTxThresholdDescrHi_$chn\"></td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param COND_TX_THRESHOLD_LO
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr id=\"condTxThresholdLo_$chn\" class=\"_hidden\">"
      append html "<td id=\"condTxThresholdDescrLo_$chn\"></td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  append html "<script type=\"text/javascript\">"
    append html "showOpModesValues = function(value, chn) {"
      append html "var opModeElems = jQuery(\"\[name='chnOpMode_\"+chn +\"'\]\");"
      append html "var condTxDecisionHeaderA = jQuery(\"#condTxThresholdHeaderA_\"+chn),"
      append html "condTxDecisionHeaderB = jQuery(\"#condTxThresholdHeaderB_\"+chn),"
      append html "condTxDecisionAboveElm = jQuery(\"#condTxDecisionAbove_\"+chn),"
      append html "condTxDecisionAboveDescrElm = jQuery(\"#condTxDecisionAboveDescr_\"+chn),"
      append html "condTxDecisionBelowElm = jQuery(\"#condTxDecisionBelow_\"+chn),"
      append html "condTxDecisionBelowDescrElm = jQuery(\"#condTxDecisionBelowDescr_\"+chn),"
      append html "condTxThresholdHiElm = jQuery(\"#condTxThresholdHi_\"+chn),"
      append html "condTxThresholdLoElm = jQuery(\"#condTxThresholdLo_\"+chn),"
      append html "condTxHorizontalLineElm = jQuery(\"#condTxHorizontalLine_\"+chn),"
      append html "condTxThresholdHiDescrElm = jQuery(\"#condTxThresholdDescrHi_\"+chn),"
      append html "condTxThresholdLoDescrElm = jQuery(\"#condTxThresholdDescrLo_\"+chn);"

      append html "condTxDecisionAboveElm.hide();"
      append html "condTxDecisionBelowElm.hide();"
      append html "condTxDecisionHeaderA.hide();"
      append html "condTxDecisionHeaderB.hide();"
      append html "condTxThresholdHiElm.hide();"
      append html "condTxThresholdLoElm.hide();"
      append html "condTxHorizontalLineElm.hide();"

      append html "switch (parseInt(value)) {"
        append html "case 1: {"
          append html "condTxDecisionAboveDescrElm.html(translateKey('stringTableCondTxDecisionPassageRL_A'));"
          append html "condTxDecisionBelowDescrElm.html(translateKey('stringTableCondTxDecisionPassageLR_A'));"
          append html "condTxThresholdHiDescrElm.html(translateKey('stringTableCondThresholdPassageRL_A'));"
          append html "condTxThresholdLoDescrElm.html(translateKey('stringTableCondThresholdPassageLR_A'));"
          append html "condTxDecisionAboveElm.show();"
          append html "condTxDecisionBelowElm.show();"
          append html "condTxDecisionHeaderA.show();"
          append html "condTxThresholdHiElm.show();"
          append html "condTxThresholdLoElm.show();"
          append html "condTxHorizontalLineElm.show();"
          append html "jQuery(\"#content\").animate({scrollTop: 600},1000);"
          append html "break;"
        append html "}"
        append html "case 2: {"
          append html "condTxDecisionAboveDescrElm.html(translateKey('stringTableCondTxDecisionPassageRL_A'));"
          append html "condTxDecisionBelowDescrElm.html(translateKey('stringTableCondTxDecisionPassageLR_A'));"
          append html "condTxThresholdHiDescrElm.html(translateKey('stringTableCondThresholdPassageRL_A'));"
          append html "condTxThresholdLoDescrElm.html(translateKey('stringTableCondThresholdPassageLR_A'));"
          append html "condTxDecisionAboveElm.show();"
          append html "condTxDecisionHeaderA.show();"
          append html "condTxThresholdHiElm.show();"
          append html "condTxThresholdLoElm.hide();"
          append html "condTxHorizontalLineElm.show();"
          append html "jQuery(\"#content\").animate({scrollTop: 600},1000);"
          append html "break;"
        append html "}"
        append html "case 3: {"
          append html "condTxDecisionAboveDescrElm.html(translateKey('stringTableCondTxDecisionPassageRL_A'));"
          append html "condTxDecisionBelowDescrElm.html(translateKey('stringTableCondTxDecisionPassageLR_A'));"
          append html "condTxThresholdHiDescrElm.html(translateKey('stringTableCondThresholdPassageRL_A'));"
          append html "condTxThresholdLoDescrElm.html(translateKey('stringTableCondThresholdPassageLR_A'));"
          append html "condTxDecisionBelowElm.show();"
          append html "condTxDecisionHeaderA.show();"
          append html "condTxThresholdHiElm.hide();"
          append html "condTxThresholdLoElm.show();"
          append html "condTxHorizontalLineElm.show();"
          append html "jQuery(\"#content\").animate({scrollTop: 600},1000);"
          append html "break;"
        append html "}"
        append html "case 4: {"
          append html "condTxDecisionAboveDescrElm.html(translateKey('stringTableCondTxDecisionPassageRL_B'));"
          append html "condTxDecisionBelowDescrElm.html(translateKey('stringTableCondTxDecisionPassageLR_B'));"
          append html "condTxThresholdHiDescrElm.html(translateKey('stringTableCondThresholdPassageRL_B'));"
          append html "condTxThresholdLoDescrElm.html(translateKey('stringTableCondThresholdPassageLR_B'));"
          append html "condTxDecisionAboveElm.show();"
          append html "condTxDecisionBelowElm.show();"
          append html "condTxDecisionHeaderB.show();"
          append html "condTxThresholdHiElm.show();"
          append html "condTxThresholdLoElm.show();"
          append html "condTxHorizontalLineElm.show();"
          append html "jQuery(\"#content\").animate({scrollTop: 600},1000);"
          append html "break;"
        append html "}"
        append html "case 5: {"
          append html "condTxDecisionAboveDescrElm.html(translateKey('stringTableCondTxDecisionPassageRL_B'));"
          append html "condTxDecisionBelowDescrElm.html(translateKey('stringTableCondTxDecisionPassageLR_B'));"
          append html "condTxThresholdHiDescrElm.html(translateKey('stringTableCondThresholdPassageRL_B'));"
          append html "condTxThresholdLoDescrElm.html(translateKey('stringTableCondThresholdPassageLR_B'));"
          append html "condTxDecisionAboveElm.show();"
          append html "condTxDecisionBelowElm.show();"
          append html "condTxDecisionHeaderB.show();"
          append html "condTxThresholdHiElm.show();"
          append html "condTxThresholdLoElm.show();"
          append html "condTxHorizontalLineElm.show();"
          append html "jQuery(\"#content\").animate({scrollTop: 600},1000);"
          append html "break;"
        append html "}"
        append html "case 6: {"
          append html "condTxDecisionAboveDescrElm.html(translateKey('stringTableCondTxDecisionPassageRL_B'));"
          append html "condTxDecisionBelowDescrElm.html(translateKey('stringTableCondTxDecisionPassageLR_B'));"
          append html "condTxThresholdHiDescrElm.html(translateKey('stringTableCondThresholdPassageRL_B1'));"
          append html "condTxThresholdLoDescrElm.html(translateKey('stringTableCondThresholdPassageLR_B1'));"
          append html "condTxDecisionAboveElm.show();"
          append html "condTxDecisionBelowElm.show();"
          append html "condTxDecisionHeaderB.show();"
          append html "condTxThresholdHiElm.show();"
          append html "condTxThresholdLoElm.show();"
          append html "condTxHorizontalLineElm.show();"
          append html "jQuery(\"#content\").animate({scrollTop: 600},1000);"
          append html "break;"
        append html "}"
      append html "}"

    append html "};"
    append html "showOpModesValues(jQuery(\"#separate_$CHANNEL\_1\").val(), $chn);"
  append html "</script>"

  return $html
}

proc getStateResetReceiver {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set prn 0
  set html ""

  puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-ParamHelp.js');</script>"

  incr prn
  append html "<tr>"
  append html "<td>\${stringTableBlockingPeriod}</td>"
  append html [getComboBox $chn $prn "$specialID" "delayShort"]
  append html "<td>[getHelpIcon BLOCKING_PERIOD]</td>"
  append html "</tr>"

  set param BLOCKING_PERIOD_UNIT
  append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

  incr prn
  set param BLOCKING_PERIOD_VALUE
  append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
  append html "<td>\${stringTableBlockingPeriodValue}</td>"

  append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

  append html "</tr>"
  append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
  append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  return $html
}

proc getWaterDetectionTransmitter {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"
  set CHANNEL $special_input_id

  set hlpBoxWidth 450
  set hlpBoxHeight 160

  set prn 0
  set html ""

  # puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIP-ParamHelp.js');</script>"

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_FILTER_NUMBER
  if { [info exists ps($param)] == 1  } {
    incr prn
    # convert float to int (0.0 = 0)
    set min [expr {int([expr [getMinValue $param]])}]
    set max [expr {int([expr [getMaxValue $param]])}]

    array_clear options
    for {set val $min} {$val <= $max} {incr val 1} {
        set options($val) "$val"
    }

    append html "<tr>"
      append html "<td>\${stringTableEventFilterNumber}</td>"
      append html "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param\_motionDetect $hlpBoxWidth $hlpBoxHeight]</td>"
    append html "</tr>"
  }

  set param EVENT_FILTER_PERIOD
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${motionDetectorFilterPeriod}</td>"
     append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
  }

  set param ACOUSTIC_ALARM_SIGNAL
  if { [info exists ps($param)] == 1 } {
    incr prn
    array_clear options
    set options(0) "\${stringTableAlarmDisableAcousticSignal}"
    set options(1) "\${stringTableAlarmFrequencyRising}"
    set options(2) "\${stringTableAlarmFrequencyFalling}"
    set options(3) "\${stringTableAlarmFrequencyRisingAndFalling}"
    set options(4) "\${stringTableAlarmFrequencyAlternatingLowHigh}"
    set options(5) "\${stringTableAlarmFrequencyAlternatingLowMidHigh}"
    set options(6) "\${stringTableAlarmFrequencyHighOnOff}"
    set options(7) "\${stringTableAlarmFrequencyHighOnLongOff}"
    set options(8) "\${stringTableAlarmFrequencyLowOnOffHighonOff}"
    set options(9) "\${stringTableAlarmFrequencyLowOnLongOffHighOnLongOff}"
    append html "<tr><td>\${stringTableSoundID}</td><td>"
    append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
    append html "</td></tr>"

  }
  set param ACOUSTIC_ALARM_TIMING
  if { [info exists ps($param)] == 1 } {
    incr prn
    array_clear options
    set options(0) "\${stringTableAlarmPermanent}"
    set options(1) "\${stringTableAlarmThreeMinutes}"
    set options(2) "\${stringTableAlarmSixMinutes}"
    set options(3) "\${stringTableAlarmOncePerMinute}"
    append html "<tr><td>\${lblAlarmTiming}</td><td>"
    append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
    append html "</td></tr>"
  }

  set param ACOUSTIC_ALARM_TRIGGER
  if { [info exists ps($param)] == 1 } {
    incr prn
    array_clear options
    set options(0) "\${stringTableNoAcousticAlarm}"
    set options(1) "\${stringTableTriggerEvent1}"
    set options(2) "\${stringTableTriggerEvent2}"
    set options(3) "\${stringTableTriggerEvent1_2}"
    append html "<tr><td>\${lblAlarmTrigger}</td><td>"
    append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
    append html "</td></tr>"
  }

  set param TRIGGER_ANGLE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${motionDetectorTriggerAngle}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "<td>"
      append html "<input id=\"btnTriggerAngle_$prn\" type=\"button\" onclick=\"deactivateTriggerAngle($chn, $prn);\">"
      append html "</td>"
    append html "</tr>"

    append html "<script type=\"text/javascript\">"

     append html "window.setTimeout(function() {"
       append html "jQuery(\"#btnTriggerAngle\_$prn\").val(translateKey(\"positionDetectionOFF\"));"
       append html "deactivateTriggerAngle = function(chn, prn) {"
          append html "document.getElementById('separate_CHANNEL_'+chn+'_'+prn).value = '0';"
       append html "};"
     append html "}, 100);"

    append html "</script>"


    set param MSG_FOR_POS_B ;# B = Dry
    if { [info exists ps($param)] == 1  } {
      incr prn

        array_clear options
        set options(1) "\${stringTableMsg_Dry}"
        set options(2) "\${stringTableMsg_Water}"
        set options(3) "\${stringTableMsg_Moisture}"
        append html "<tr><td>\${lblWaterDetectorMsg_Dry}</td><td>"
        append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
      append html "</td></tr>"
    }

    set param MSG_FOR_POS_C ;# C = Moisture
    if { [info exists ps($param)] == 1  } {
      incr prn
        array_clear options
        set options(1) "\${stringTableMsg_Dry}"
        set options(2) "\${stringTableMsg_Water}"
        set options(3) "\${stringTableMsg_Moisture}"
        append html "<tr><td>\${lblWaterDetectorMsg_Moisture}</td><td>"
        append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
      append html "</td></tr>"
    }

    set param MSG_FOR_POS_A ;# A = Waterlevel
    if { [info exists ps($param)] == 1  } {
      incr prn
        array_clear options
        set options(1) "\${stringTableMsg_Dry}"
        set options(2) "\${stringTableMsg_Water}"
        set options(3) "\${stringTableMsg_Moisture}"
        append html "<tr><td>\${lblWaterDetectorMsg_Water}</td><td>"
        append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
      append html "</td></tr>"
    }

  }

  # append html "[getAlarmPanel ps]"

  return $html
}

proc getDoorReceiver {chn p descr} {
    upvar $p ps
    upvar $descr psDescr
    upvar prn prn
    upvar special_input_id special_input_id

    set specialID "[getSpecialID $special_input_id]"

    set html ""
    set prn 0

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }
}

proc getSimpleSwitchReceiver {chn p descr} {
    upvar $p ps
    upvar $descr psDescr
    upvar prn prn
    upvar special_input_id special_input_id

    set specialID "[getSpecialID $special_input_id]"

    set html ""
    set prn 0

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }
}

proc getAcousticSignalTransmitter {chn p descr} {
    upvar $p ps
    upvar $descr psDescr
    upvar prn prn
    upvar special_input_id special_input_id

    set specialID "[getSpecialID $special_input_id]"

    set html ""
    set prn 0

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }
}

proc getAcousticSignalVirtualReceiver {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""
  set prn 0

  if {[session_is_expert]} {
    set param "LOGIC_COMBINATION"
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableLogicCombination}</td>"
        option LOGIC_COMBINATION
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
      append html "[getHorizontalLine]"
    }
  }

  set param POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html [getPowerUpSelectorAcousticSignal $chn ps $special_input_id]
  }
  return $html
}

proc getRainDetectionTransmitter {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id
  set specialID "[getSpecialID $special_input_id]"
  set html ""
  set prn 0

  set param LED_DISABLE_CHANNELSTATE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableLEDDisableChannelState}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"
    set specialParam 1
  }

  set param EVENT_TIMEOUT_BASE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventTimeoutRainDetector}</td>"
    append html [getComboBox $chn $prn "$specialID" "delayShortA"]
    # append html "<td>[getHelpIcon $param]</td>"
    append html "</tr>"

    #param = EVENT_TIMEOUT_BASE
    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_TIMEOUT_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventTimeoutValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param SAMPLE_INTERVAL
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${rainDetectorSampleInterval}</td>"
     append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
     # append html "<td>[getHelpIcon $param]</td>"
    append html "</tr>"
  }

  set param SENSOR_SENSITIVITY
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableSensorSensivity}</td>"
      option RAW_0_100Percent
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_rain]</td>"
    append html "</tr>"
  }
  return $html

}

proc getDoorLockStateTransmitter {chn p descr} {

  global env dev_descr
  # source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipAlarmPanel.tcl]

  upvar $p ps
  upvar $descr psDescr
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""
  set specialParam 0
  set prn 0

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  append html "[getHorizontalLine]"

  set param POWERUP_ONTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableAutoRelockDelay}</td>"
    append html "[getComboBox $chn $prn "$specialID" "timeOnOff"]<td>[getHelpIcon $param 320 170]</td>"
    append html "</tr>"

    append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param POWERUP_ONTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableOnTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param DOOR_LOCK_DIRECTION
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDoorLockDirection}</td>"
      array_clear options
      set options(0) "\${lblRight}"
      set options(1) "\${lblLeft}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
    append html "</tr>"
  }

  set param DOOR_LOCK_TURNS
  if { [info exists ps($param)] == 1 } {

    # convert float to int (0.0 = 0)
    set min [expr {int([expr [getMinValue $param]])}]
    set max [expr {int([expr [getMaxValue $param]])}]

    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDoorLockTurns}</td>"
      array_clear options
      for {set val $min} {$val <= $max} {incr val 1} {
          set options($val) "$val"
      }
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
    append html "</tr>"
  }

  set param DOOR_LOCK_NEUTRAL_POS
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDoorLockNeutralPos}</td>"
      array_clear options
      set options(0) "\${lblVerticalA}"
      set options(1) "\${lblHorizontalA}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
    append html "</tr>"
  }

  append html "[getHorizontalLine]"

    set param DOOR_LOCK_END_STOP_OFFSET_LOCKED
    if { [info exists ps($param)] == 1 } {

      # convert float to int (0.0 = 0)
      set min [expr {int([expr [getMinValue $param]])}]
      set max [expr {int([expr [getMaxValue $param]])}]

      incr prn
      append html "<tr>"
        append html "<td>\${stringTableKeyMaticAngleMax}</td>"
        option DOOR_LOCK_ANGLE_RANGE
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
      append html "</tr>"
    }

    set param DOOR_LOCK_END_STOP_OFFSET_OPEN
    if { [info exists ps($param)] == 1 } {

      # convert float to int (0.0 = 0)
      set min [expr {int([expr [getMinValue $param]])}]
      set max [expr {int([expr [getMaxValue $param]])}]

      incr prn
      append html "<tr>"
        append html "<td>\${stringTableKeyMaticAngleOpen}</td>"
        option DOOR_LOCK_ANGLE_RANGE
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
      append html "</tr>"
    }

    set param HOLD_TIME
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableDoorLockHoldTime}</td>"
        array_clear options
        set options(0) "\${optionOpenOnly}"
        #set options(1) "\${optionNormal}"
        set options(30) "\${optionLongA}"
        set options(50) "\${optionExtraLong}"
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn onchange=\"showHintHoldTime($prn)\"]&nbsp;[getHelpIcon DOOR_LOCK_$param 320 75]</td>"
      append html "</tr>"
      append html "<tr id=\"trHint_$prn\" class=\"hidden\"><td></td><td><span class='attention'>\${hintDoorLockHoldTime}</span></td></tr>"

      append html "<script type=\"text/javascript\">"
        append html "showHintHoldTime = function (prn) \{"
          append html "var valHoldTime = jQuery('\#separate_CHANNEL_$chn\_'+prn).val();"
          append html "if (parseInt(valHoldTime) > 1) \{jQuery('\#trHint_'+prn).show();\} else \{jQuery('\#trHint_'+prn).hide();\}"
      append html "\};"
      append html "showHintHoldTime($prn);"
      append html "</script>"

    }

    set param DISABLE_ACOUSTIC_CHANNELSTATE
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableDisableDoorLockAcousticChannelState}</td>"
        append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon DOOR_LOCK_$param 320 75]</td>"
      append html "</tr>"
      set specialParam 1
    }

  return $html
}

proc getDoorLockStateTranseiver {chn p descr} {

  global env dev_descr
  # source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipAlarmPanel.tcl]

  upvar $p ps
  upvar $descr psDescr
  upvar special_input_id special_input_id

  set CHANNEL $special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""
  set specialParam 0
  set prn 0

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  append html "[getHorizontalLine]"


  set param DOOR_LOCK_DIRECTION
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDoorLockDirection}</td>"
      array_clear options
      set options(0) "\${lblRight}"
      set options(1) "\${lblLeft}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_1 320 75]</td>"
    append html "</tr>"
  }

  set param DOOR_LOCK_TURNS
  if { [info exists ps($param)] == 1 } {

    # convert float to int (0.0 = 0)
    set min [expr {int([expr [getMinValue $param]])}]
    set max [expr {int([expr [getMaxValue $param]])}]

    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDoorLockTurns}</td>"
      array_clear options
      for {set val $min} {$val <= $max} {incr val 1} {
          set options($val) "$val"
      }
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
    append html "</tr>"
  }

  set param DOOR_LOCK_NEUTRAL_POS
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDoorLockNeutralPos}</td>"
      array_clear options
      set options(0) "\${lblVertical}"
      set options(1) "\${lblHorizontal}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
    append html "</tr>"
  }

    set param MSG_FOR_POS_A
    if { [info exists ps($param)] == 1  } {
      incr prn
        array_clear options
        set options(0) "\${stringTableTiltSensorMsgPosA2}"
        set options(1) "\${stringTableDoorLockStateTransmitterLockStateLocked}"
        set options(2) "\${stringTableDoorLockStateTransmitterLockStateUnlocked}"
        append html "<tr><td>\${stringTableDoorLockStateTransceiverMsgPosA}</td><td>"
        append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
      append html "</td></tr>"
    }

    set param MSG_FOR_POS_B
    if { [info exists ps($param)] == 1  } {
      incr prn
        array_clear options
        set options(0) "\${stringTableTiltSensorMsgPosA2}"
        set options(1) "\${stringTableDoorLockStateTransmitterLockStateLocked}"
        set options(2) "\${stringTableDoorLockStateTransmitterLockStateUnlocked}"
        append html "<tr><td>\${stringTableDoorLockStateTransceiverMsgPosB}</td><td>"
        append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
      append html "</td></tr>"
    }

  return $html
}

proc getOpticalSignalReceiver {chn p descr} {
  global env dev_descr
  # source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmipAlarmPanel.tcl]

  upvar $p ps
  upvar $descr psDescr
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""
  set specialParam 0
  set prn 0

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  append html "[getHorizontalLine]"

  set param POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html [getPowerUpSelector $chn ps $special_input_id]
  }


  return $html

}

proc getCarbonDioxideReceiver {chn p descr} {
  global env dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"
  set CHANNEL $special_input_id

  set html ""
  set prn 0

  set param INTERVAL_UNIT
  if { [info exists ps($param)] == 1 } {
    append html "<tr>"
      append html "<td>\${lblAutoCalibration}</td>"
      # append html  "<td>[getCheckBox 'autoCalibration' $ps($param) $chn $prn onchange=setCO2AutoCalibration(this);]</td>"
      append html  "<td><input type='checkbox' id='autoCal' onchange=setCO2AutoCalibration();>&nbsp;[getHelpIcon CALIBRATION_PPM]</td>"
    append html "</tr>"


    # Wert = VAL * 10 ^ EXP
    set param CALIBRATION_PPM_VAL
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr name='CO2SensorCal'>"
        append html "<td>\${lblCalibrationValue}</td>"
        append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"

        set comment { # The exponent is currently not in use
          set param CALIBRATION_PPM_EXP
          if { [info exists ps($param)] == 1  } {
            incr prn
            array_clear option
            set option(0) "1"
            set option(1) "10"
            set option(2) "100"
            set option(3) "1000"
            append html  "&nbsp; x [getOptionBox '$param' option $ps($param) $chn $prn]&nbsp;[getHelpIcon CALIBRATION_PPM]"
          }
        }
        append html "</td>"
      append html "</tr>"
    }

    # ******* Automatic Calibration *********

    set param INTERVAL_UNIT
    if { [info exists ps($param)] == 1 } {
      incr prn

      set param INTERVAL_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" name='CO2SensorCal'>"
        append html "<td>\${stringTableCalibrationIntervalValue}</td>"

        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;&nbsp; x "

        incr prn
        set param INTERVAL_UNIT
        array_clear options
        set options(0) "not active"
        set options(4) "\${optionUnitH}"
        set options(5) "\${optionUnitD}"
        set options(6) "\${optionUnit7D}"
        set options(7) "\${optionUnit28D}"
        append html "[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]</td>"
      append html "</tr>"


      append html "<script type=\"text/javascript\">"

        append html "setCO2AutoCalibration = function() \{"
          append html "var setAutoCalValElm = jQuery('#autoCal'),"
          append html " autoCalActive = setAutoCalValElm.is(':checked');"
          append html " autocalPanel = jQuery(\"\[name='CO2SensorCal'\]\"),"
          append html " autoCalValElm = jQuery(\"\[name='INTERVAL_VALUE'\]\")\[0\],"
          append html " autoCalUnitElm = jQuery(\"\[name='INTERVAL_UNIT'\]\")\[0\],"
          append html " autoCalVal = jQuery(autoCalValElm).val(),"
          append html " autoCalUnit = jQuery(autoCalUnitElm).val();"

          append html "if (autoCalActive) {"
            append html "jQuery('\[name=\"INTERVAL_UNIT\"\] option\[value=0\]').remove();"
            append html "autocalPanel.show();"
            append html "if (parseInt(autoCalVal) == 0) {jQuery(autoCalValElm).val(8);}"
            append html "if (parseInt(autoCalUnit) == 0) {jQuery(autoCalUnitElm).val('4');}"
          append html "} else {"
            append html "jQuery(autoCalUnitElm).append('<option value=\"0\">not active</option>');"
            append html "autocalPanel.hide();"
            append html "jQuery(autoCalValElm).val(0);"
            append html "jQuery(autoCalUnitElm).val(0);"
          append html "}"

        append html "\};"

        append html "window.setTimeout(function(){"
          append html "var setAutoCalValElm = jQuery('#autoCal'),"
          append html " autocalPanel = jQuery(\"\[name='CO2SensorCal'\]\"),"
          append html " autoCalValElm = jQuery(\"\[name='INTERVAL_VALUE'\]\")\[0\],"
          append html " autoCalUnitElm = jQuery(\"\[name='INTERVAL_UNIT'\]\")\[0\],"
          append html " autoCalVal = jQuery(autoCalValElm).val(),"
          append html " autoCalUnit = jQuery(autoCalUnitElm).val();"

          append html "if (parseInt(autoCalVal) > 0 && parseInt(autoCalUnit) >= 3) {setAutoCalValElm.prop('checked', true);jQuery('\[name=\"INTERVAL_UNIT\"\] option\[value=0\]').remove();autocalPanel.show();} else {setAutoCalValElm.prop('checked', false); autocalPanel.hide();}"

        append html "},50);"

      append html "</script>"

  }
}
  return $html
}

proc getServoTransmitter {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id
  set specialID "[getSpecialID $special_input_id]"
  set html ""
  set prn 0

  set CHANNEL $special_input_id

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    array_clear options
    set options(0) "\${optionInactiv}"
    set options(1) "\${optionActiv}"
    append html "<tr><td>\${lblChannelActivInactiv}</td><td>"
    append html [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]
    append html "</td></tr>"
  }

  append html "[getHorizontalLine]"

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  append html "[getHorizontalLine]"

  set param OUTPUT_SWAP
  if { [info exists ps($param)] == 1  } {
    incr prn
    array_clear options
    set options(0) "\${optionOutputNotSwapped}"
    set options(1) "\${optionOutputSwapped}"
    append html "<tr><td>\${lblRotationSwap}</td><td>"
    append html "[get_ComboBox options $param separate_$special_input_id\_$prn ps $param]&nbsp;[getHelpIcon $param\_SERVO]"
    append html "</td></tr>"
  }

  set param POWER_OFFDELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableServoPowerOff}</td>"
    append html "[getComboBox $chn $prn "$specialID" "timeOnOff"]"
    append html "</tr>"

    append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param POWER_OFFDELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableOffDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }
  return $html
}

proc getServoVirtualReceiver {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id
  set specialID "[getSpecialID $special_input_id]"
  set html ""
  set prn 0

  set CHANNEL $special_input_id

  if {[session_is_expert]} {
    set param "LOGIC_COMBINATION"
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableLogicCombination}</td>"
        option LOGIC_COMBINATION
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
      append html "[getHorizontalLine]"
    }
  }

  set param POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html [getPowerUpSelector $chn ps $special_input_id]
  }

  return $html
}

proc getAccessTransceiver {chn p descr} {
  global dev_descr
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id
  set specialID "[getSpecialID $special_input_id]"
  set html ""
  set prn 0
  set min 1
  set max 21

  # ABORT_EVENT_SENDING_CHANNELS
  set colspanAESC 21
  set colspanAESC_A 5
  set colspanAESC_B 21

  set devType $dev_descr(TYPE)

  if {[string equal $devType "HmIP-WKP"] == 1} {
    set colspanAESC 16
    set colspanAESC_A 0
    set colspanAESC_B 0
  }

  set checked ""

  set param NUMERIC_PIN_CODE
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableNumericPinCode}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"
    append html "</tr>"
    append html "<tr><td colspan='2'><hr></td></tr>"
  }

  set param INPUT_SELECT_FIELD
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr><td colspan=\"$max\" class=\"alignCenter virtualChannelBckGnd\"><span><b>\${thEntitlement}</b></span></td></tr>"
    append html "<tr>"
      append html "<td>\${lblCode}</td>"
      for {set loop $min} {$loop <= $max -1 } {incr loop 1} {
        set val [expr {int(pow(2,[expr $loop - 1]))}]
        append html "<td>"
         append html "<label for=\"separate\_${special_input_id}_$prn\">$loop</label>"
         append html "<input type=\"checkbox\"  name=\"INPUT_SELECT_FIELD_$chn\" value=\"$val\" $checked style=\"vertical-align:middle;\" onchange=\"setInputSelectField($chn);\"></td>"
        append html "</td>"
      }
      append html "<td>"
        append html "<input id=\"separate\_${special_input_id}_$prn\" name=$param type=\"text\" class=\"hidden\" size=\"6\" value=$ps($param)>"
      append html "</td>"
    append html "</tr>"

    append html "<tr><td colspan='$max - 1'><hr></td></tr>"

    append html "<tr>"
      append html "<td colspan='2'>\${lblBellButton}</td>"
      append html "<td colspan='$max - 1'>"
        set val [expr {int(pow(2,[expr $max - 1]))}]
        # append html "<td>"
        # append html "<label for=\"separate\_${special_input_id}_$prn\">$max</label>"
         append html "<input type=\"checkbox\"  name=\"INPUT_SELECT_FIELD_$chn\" value=\"$val\" $checked style=\"vertical-align:middle;\" onchange=\"setInputSelectField($chn);\"></td>"
        # append html "</td>"
      append html "</td>"
    append html "</tr>"

      append html "<script type=\"text/javascript\">"
        append html "setInputSelectField = function(chn) \{"
          append html "var arChkBox = jQuery(\"\[name='INPUT_SELECT_FIELD_\"+chn+\"'\]:checked\"),"
          append html "valueFieldElm = jQuery(\"\#separate_CHANNEL_\" + chn + \"_1\"),"
          append html "value = 0;"
          append html "jQuery.each(arChkBox, function(index,elm) \{"
            append html "value += parseInt(jQuery(elm).val());"
          append html "\});"
         append html "valueFieldElm.val(value);"
        append html "\};"

        append html "var val = $ps($param),"
        append html "valReversed = val.toString(2).split(\"\").reverse().join(\"\"),"
        append html "arChkBox = jQuery(\"\[name='INPUT_SELECT_FIELD_$chn'\]\"),"
        append html "loop = 0;"

        append html "valReversed.split(\"\").forEach(function(chr) \{"
          append html "if (chr == \"1\") \{"
            append html "jQuery(arChkBox\[loop\]).prop(\"checked\", true);"
          append html "\}"
          append html "loop++;"
        append html "\});"
      append html "</script>"


    append html "<tr><td colspan='21'><hr></td></tr>"
  }

  set param ABORT_EVENT_SENDING_CHANNELS
  if { [info exists ps($param)] == 1  } {

    if {[string equal $devType "HmIP-WKP"] == 1} {
      if { [info exists ps(NUMERIC_PIN_CODE)] != 1  } {
        append html "<tr><td colspan='$colspanAESC' class='alignCenter'><b>\${lblPinOfChannelLockA} [expr $chn / 2] \${lblPinOfChannelLockB}</b></td></tr>"
        append html "<tr><td colspan='$colspanAESC'><hr></td></tr>"
      }
    }

    incr prn
    append html "<tr name='abortEventSendingChannels'>"
      append html "<td colspan='$colspanAESC'  style='text-align:center;'>\${stringTableAbortEventSendingChannelsAccessTransceiver}&nbsp;[getHelpIcon $param\_ACCESS_TRANSCEIVER]</td>"
    append html "</tr>"

    append html "<tr>"
    append html "<td colspan='$colspanAESC_A'>\${lblStopRunningLinkAccessTransceiver}</td>"
    append html "<td colspan='$colspanAESC_B'><table>"
      append html "<tr id='hookAbortEventSendingChannels_1_$chn'/>"
      append html "<tr id='hookAbortEventSendingChannels_2_$chn'/>"
    append html "</table></td>"
    append html "</tr>"

    append html "<script type='text/javascript'>"
      append html "addAbortEventSendingChannels('$chn','$prn', '$dev_descr(ADDRESS)', $ps($param));"
    append html "</script>"
  }


  return $html
}

proc getSmokeDetector {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id
  set specialID "[getSpecialID $special_input_id]"
  set html ""
  set prn 0

  set CHANNEL $special_input_id
  set groupExists 1

  set param GROUP_1

  if { [info exists ps($param)] == 1  } {
    # Help
    append html "<tr>"
      append html "<td>"
        append html "\${GROUP_SMOKE_DETECTOR}"
      append html "</td>"
    append html "</tr>"
  }

  append html "<td><table><tr><td>"
    for {set val 1} {$groupExists == 1} {incr val} {
      if { [info exists ps(GROUP_$val)] == 1  } {
        incr prn
        append html "<tr>"
          append html "<td>\${lblGroup}_$val</td>"
          append html "<td></td>"
          append html  "<td>[getCheckBox 'GROUP_$val' $ps(GROUP_$val) $chn $prn]</td>"
        append html "</tr>"
      } else {
        set groupExists 0
      }
    }

    set param "REPEAT_ENABLE"
    if { [info exists ps($param)] == 1  } {
      incr prn
      if { [info exists ps(GROUP_1)] == 1  } {
        append html "<tr><td colspan='3'><hr></td></tr>"
      }
      append html "<td>\${stringTableSmokeDetectorRepeatEnable}</td>"
      append html "<td></td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    }

  append html "</td></tr></table></td>"
  return $html
}

proc getWindowDriveReceiver {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id
  set specialID "[getSpecialID $special_input_id]"
  set html ""
  set prn 0

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html "[getHorizontalLine]"
    append html [getPowerUpSelector $chn ps $special_input_id]
  }

}

proc getGenericMeasuringTransmitter {chn p descr address} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id
  set specialID "[getSpecialID $special_input_id]"
  set html ""
  set prn 0

  # Add Textbox for the Unit
  append html "<tr>"
    append html "<td>\${lblGenericUnit}</td>"
    append html "<td><input type='text' id='genMeasureUnit_$chn' name='genMeasureUnit' data-address='$address' size='3' class='alignCenter'>&nbsp;[getHelpIcon GENERIC_UNIT] </td>"
  append html "</tr>"

  # Add Selectbox for the number of decimal places
  append html "<tr>"
    append html "<td>\${lblNoOfDecimalPlaces}</td>"
    append html "<td>"
      append html "<select id='noOfDecPlaces_$chn' name='noOfDecPlaces' data-address='$address'>"
        append html "<option value='0'>0</option>"
        append html "<option value='1'>1</option>"
        append html "<option value='2'>2</option>"
        append html "<option value='3'>3</option>"
      append html "</select>"
    append html "</td>"
  append html "</tr>"

  # Store and read the unit as meta data
  append html "<script type=\"text/javascript\">"
    append html "var elm = jQuery('\#genMeasureUnit_$chn'),"
    append html "elmNoOfDecPl = jQuery('\#noOfDecPlaces_$chn'),"
    append html "oChn = DeviceList.getChannelByAddress(elm.data('address')),"
    append html "chnUnit, chnDecPl;"

    # Read the stored measurementUnit
    append html " chnUnit = homematic('Interface.getMetadata', {'objectId': oChn.id, 'dataId': 'measurementUnit'});"
    append html "if (chnUnit == 'null') {"
      # If no data available the unit is ''
      append html "chnUnit = '';"
    append html "}"

    # Read the stored decimal places
    append html " chnDecPl = homematic('Interface.getMetadata', {'objectId': oChn.id, 'dataId': 'measurementUnitDecimalPlaces'});"
    append html "if (chnDecPl == 'null') {"
      # If no data available the chnDecPl is 0
      append html "chnDecPl = '0';"
    append html "}"


    # Then set the value of the appropriate text field to the unit
    append html "elm.val(chnUnit);"
    append html "elmNoOfDecPl.val(chnDecPl);"

    # When pressing the Apply or OK button of the footer store the value of the units
    append html "storeMeasurementUnit = function() {"
      append html "var arElm = jQuery(\"\[name='genMeasureUnit'\]\"),"
      append html "arElmDecPl = jQuery(\"\[name='noOfDecPlaces'\]\");"
      append html "jQuery.each(arElm,function(index, elm) {"
        append html "oChn = DeviceList.getChannelByAddress(elm.dataset.address);"
        append html "homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': 'measurementUnit', 'value': jQuery(elm).val()});"
      append html "});"

      append html "jQuery.each(arElmDecPl,function(index, elm) {"
        append html "oChn = DeviceList.getChannelByAddress(elm.dataset.address);"
        append html "homematic('Interface.setMetadata', {'objectId': oChn.id, 'dataId': 'measurementUnitDecimalPlaces', 'value': jQuery(elm).val()});"
      append html "});"

    append html "};"

    # Extend the footer buttons
    append html " window.setTimeout(function() { "
     append html " var elm = jQuery('#footerButtonOK, #footerButtonTake'); "
     append html " elm.off('click').click(function() {storeMeasurementUnit();}); "
    append html " },10); "
  append html "</script>"
  return $html
}

proc getBacklightingReceiver {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id
  set specialID "[getSpecialID $special_input_id]"
  set html ""
  set prn 0

  set activateLevelMode 0
  set feedbackLevelMode 0

  set param _POWERUP_JUMPTARGET
  if { [info exists ps($param)] == 1  } {
    append html [getPowerUpSelector $chn ps $special_input_id]
  }

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param LED_DISABLE_CHANNELSTATE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableLEDDisableChannelState}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]</td>"
    append html "</tr>"
    set specialParam 1
  }

  append html "[getHorizontalLine]"

  set param POWERUP_ON_LEVEL
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDimmerLevel}</td>"
      array_clear options
      for {set val 0} {$val <= 100} {incr val 5} {
        set options($val) "$val%"
      }
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
    append html "</tr>"
  }

  append html "[getHorizontalLine]"

  set param _FEEDBACK_LEVEL_MODE; # Don't show this parameter
  if { [info exists ps($param)] == 1  } {

    append html "<tr><td colspan='2'><b>\${lblHeaderFeedbackLevelMode}<b/><br/></td></tr>"

    incr prn
    set feedbackLevelMode $ps($param)
    array_clear options
    set options(0) "\${optionAbsolut}"
    set options(1) "\${optionRelativ}"
    append html "<tr><td>\${lblFeedbackLevelMode}</td><td>"
    append html "[get_ComboBox options $param separate_$special_input_id\_$prn ps $param onchange=changeFeedbackLevelOptions(this.value)]&nbsp;[getHelpIcon $param]"
    append html "</td></tr>"

    append html "<script type=\"text/javascript\">"
      append html "changeFeedbackLevelOptions = function(value) \{"
        append html "var feedbckLvlElm = jQuery('\[name=\"FEEDBACK_LEVEL_VALUE\"\]').first();"
        append html "feedbckLvlElm.empty();"
        append html "var min =  (value == 0) ? 0 : -100;"
        append html "for (var loop = min; loop <= 100; loop += 5) \{"
          append html "feedbckLvlElm.append(new Option(loop+'%', loop));"
        append html "\}"
      append html "\};"
   append html "</script>"
  }

  set param FEEDBACK_LEVEL_VALUE
  if { [info exists ps($param)] == 1  } {
    incr prn
    set min [expr {int([expr [getMinValue $param]])}]
    set max [expr {int([expr [getMaxValue $param]])}]

    if {$feedbackLevelMode == 0} {
      set min 0
    }
    array_clear options
    for {set val $min} {$val <= $max} {incr val 5} {
        set options($val) "$val%"
    }

    append html "<tr>"
      append html "<td>\${lblFeedbackLevelValue}</td>"
    append html "<td>[get_ComboBox options $param separate_$special_input_id\_$prn ps $param]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
    # append html "[getHorizontalLine]"
  }

  set param _ACTIVATE_LEVEL_MODE; # Don't show this parameter
  if { [info exists ps($param)] == 1  } {
    append html "<tr><td colspan='2'><b>\${lblHeaderActivateLevelMode}&nbsp;[getHelpIcon helpAcitveLevelMode]<b/><br/></td></tr>"

    incr prn
    set activateLevelMode $ps($param)
    array_clear options
    set options(0) "\${optionAbsolut}"
    set options(1) "\${optionRelativ}"
    append html "<tr><td>\${lblActivateLevelMode}</td><td>"
    append html "[get_ComboBox options $param separate_$special_input_id\_$prn ps $param onchange=changeActivateLevelOptions(this.value)]&nbsp;[getHelpIcon $param]"
    append html "</td></tr>"

    append html "<script type=\"text/javascript\">"
      append html "changeActivateLevelOptions = function(value) \{"
        append html "var activateLvlElm = jQuery('\[name=\"ACTIVATE_LEVEL_VALUE\"\]').first();"
        append html "activateLvlElm.empty();"
        append html "var min =  (value == 0) ? 0 : -100;"
        append html "for (var loop = min; loop <= 100; loop += 5) \{"
          append html "activateLvlElm.append(new Option(loop+'%', loop));"
        append html "\}"
      append html "\};"
    append html "</script>"
  }

  set param ACTIVATE_LEVEL_VALUE
  if { [info exists ps($param)] == 1  } {
    append html "[getHorizontalLine]"

    incr prn

    set min [expr {int([expr [getMinValue $param]])}]
    set max [expr {int([expr [getMaxValue $param]])}]

    if {$min < 0} {
      set min 0
    }
    array_clear options
    for {set val $min} {$val <= $max} {incr val 5} {
        set options($val) "$val%"
    }
    append html "<tr>"
      append html "<td>\${lblActivateLevelValue}</td>"
    append html "<td>[get_ComboBox options $param separate_$special_input_id\_$prn ps $param]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }

set comment {
    # Currently not in use
    set param _ACTIVATE_LEVEL_ONTIME_UNIT
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableActivateLevelOnTime}</td>"
      append html "[getComboBox $chn $prn "$specialID" "timeOnOffShort"]<td>[getHelpIcon $param 320 170]</td>"
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param ACTIVATE_LEVEL_ONTIME_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOnTimeValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }
}
    set param ACTIVATE_LEVEL_ONTIME_VALUE
    if { [info exists ps($param)] == 1  } {
      incr prn
      array_clear options
      for {set val 0} {$val <= 30} {incr val} {
          set options($val) "$val \${optionUnitS}"
      }
      append html "<tr>"
        append html "<td>\${lblOnTime}</td>"
        append html "<td>[get_ComboBox options $param separate_$special_input_id\_$prn ps $param]</td>"
      append html "</tr>"
    }
  return $html
}

proc getSoilMoistureTransmitter {chn p descr} {
  upvar $p ps
  upvar $descr psDescr
  upvar prn prn
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""

  set prn 0
  set param FILTER_SIZE
  if { [info exists ps($param)] == 1  } {
    incr prn
    set min [expr {int([expr [getMinValue $param]])}]
    set max [expr {int([expr [getMaxValue $param]])}]
    array_clear options
    for {set val $min} {$val <= $max} {incr val} {
        set options($val) "$val"
    }

    append html "<tr>"
      append html "<td>\${stringTableSoilMoistureTransmitterFilterSize}</td>"
      append html "<td>[get_ComboBox options $param separate_$special_input_id\_$prn ps $param]&nbsp;[getHelpIcon $param\_SOIL_MOISTURE 400 120]</td>"
    append html "</tr>"
  }


  set param INTERVAL_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableMeasurementInterval}</td>"
    append html [getComboBox $chn $prn "$specialID" "autoIntervalA" "helpSoilMoisture"]
    append html "</tr>"

    append html [getTimeUnitComboBoxC $param $ps($param) $chn $prn $special_input_id 'measurementInterval']

    incr prn
    set param INTERVAL_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableMeasurementIntervalValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentAutoIntervalAOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param REFERENCE_16BIT_MIN
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableRefMin0}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_SOIL_MOISTURE 320 170]</td>"
    append html "</tr>"
  }

  set param REFERENCE_16BIT_MAX
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableRefMax100}</td>"
      append html  "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_SOIL_MOISTURE 320 170]</td>"
    append html "</tr>"
  }


  return $html
}

proc getDoorStateTranseiver {chn p descr} {

  global env dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar special_input_id special_input_id

  set html ""
  set prn 0

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblAutoCalibration}</td>"
      array_clear options
      set options(0) "\${optionDisable}"

      set options(0) "\${optionDisable}"
      set options(1) "\${optionDriftCompensationOn}"
      set options(2) "\${optionDriftCompensationAndCalibrationOn}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_door_state]</td>"
    append html "</tr>"
  }

    set param SAMPLE_INTERVAL
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        append html "<td>\${genericSampleInterval}</td>"
       append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_door_state]</td>"
      append html "</tr>"
    }

  set param SENSOR_SENSITIVITY
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblTableDeviceMagnetSensibility}</td>"
    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_door_state]</td>"
    append html "</tr>"
  }
}

proc getDoorLockTranseiver {chn p descr} {

  global env dev_descr

  upvar $p ps
  upvar $descr psDescr
  upvar special_input_id special_input_id

  set specialID "[getSpecialID $special_input_id]"

  set html ""
  set prn 0

  set param EVENT_DELAY_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableEventDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventDelay"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShortwoHour $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_DELAY_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableEventDelayValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelB($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param EVENT_RANDOMTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableRandomTime}</td>"
    append html [getComboBox $chn $prn "$specialID" "eventRandomTime"]
    append html "</tr>"

    append html [getTimeUnitComboBoxShort $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param EVENT_RANDOMTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableRamdomTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOptionPanelA($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  append html "[getHorizontalLine]"

  set param POWERUP_ONTIME_UNIT
  if { [info exists ps($param)] == 1  } {
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableAutoRelockDelay}</td>"
    append html "[getComboBox $chn $prn "$specialID" "timeOnOff_autorelock"]"
    append html "</tr>"

    append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

    incr prn
    set param POWERUP_ONTIME_VALUE
    append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
    append html "<td>\${stringTableOnTimeValue}</td>"

    append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

    append html "</tr>"
    append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
    append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
  }

  set param DOOR_LOCK_DIRECTION
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDoorLockDirection}</td>"
      array_clear options
      set options(0) "\${lblRight}"
      set options(1) "\${lblLeft}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
    append html "</tr>"
  }

  set param DOOR_LOCK_TURNS
  if { [info exists ps($param)] == 1 } {

    # convert float to int (0.0 = 0)
    set min [expr {int([expr [getMinValue $param]])}]
    set max [expr {int([expr [getMaxValue $param]])}]

    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDoorLockTurns}</td>"
      array_clear options
      for {set val $min} {$val <= $max} {incr val 1} {
          set options($val) "$val"
      }
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
    append html "</tr>"
  }

  set param DOOR_LOCK_NEUTRAL_POS
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDoorLockNeutralPos}</td>"
      array_clear options
      set options(0) "\${lblVerticalA}"
      set options(1) "\${lblHorizontalA}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
    append html "</tr>"
  }

  append html "[getHorizontalLine]"

    set param DOOR_LOCK_END_STOP_OFFSET_LOCKED
    if { [info exists ps($param)] == 1 } {

      # convert float to int (0.0 = 0)
      set min [expr {int([expr [getMinValue $param]])}]
      set max [expr {int([expr [getMaxValue $param]])}]

      incr prn
      append html "<tr>"
        append html "<td>\${stringTableKeyMaticAngleMax}</td>"
        option DOOR_LOCK_ANGLE_RANGE
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
      append html "</tr>"
    }

    set param DOOR_LOCK_END_STOP_OFFSET_OPEN
    if { [info exists ps($param)] == 1 } {

      # convert float to int (0.0 = 0)
      set min [expr {int([expr [getMinValue $param]])}]
      set max [expr {int([expr [getMaxValue $param]])}]

      incr prn
      append html "<tr>"
        append html "<td>\${stringTableKeyMaticAngleOpen}</td>"
        option DOOR_LOCK_ANGLE_RANGE
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param 320 75]</td>"
      append html "</tr>"
    }

    set param HOLD_TIME
    if { [info exists ps($param)] == 1 } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableDoorLockHoldTime}</td>"
        array_clear options
        set options(0) "\${optionOpenOnly}"
        #set options(1) "\${optionNormal}"
        set options(30) "\${optionLongA}"
        set options(50) "\${optionExtraLong}"
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn onchange=\"showHintHoldTime($prn)\"]&nbsp;[getHelpIcon DOOR_LOCK_$param 320 75]</td>"
      append html "</tr>"
      append html "<tr id=\"trHint_$prn\" class=\"hidden\"><td></td><td><span class='attention'>\${hintDoorLockHoldTime}</span></td></tr>"

      append html "<script type=\"text/javascript\">"
        append html "showHintHoldTime = function (prn) \{"
          append html "var valHoldTime = jQuery('\#separate_CHANNEL_$chn\_'+prn).val();"
          append html "if (parseInt(valHoldTime) > 1) \{jQuery('\#trHint_'+prn).show();\} else \{jQuery('\#trHint_'+prn).hide();\}"
      append html "\};"
      append html "showHintHoldTime($prn);"
      append html "</script>"
    }

  set param DISABLE_ACOUSTIC_CHANNELSTATE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${stringTableDisableDoorLockAcousticChannelState}</td>"
      append html  "<td>[getCheckBox '$param' $ps($param) $chn $prn]&nbsp;[getHelpIcon DOOR_LOCK_$param 320 75]</td>"
    append html "</tr>"
    set specialParam 1
    }

  append html "[getHorizontalLine]"

  set param CHANNEL_OPERATION_MODE
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblAutomaticLock}</td>"
      array_clear options
      set options(0) "\${optionIgnoreDoorOpen}"
      set options(1) "\${optionSkipHoldTimeOpening}"
      set options(2) "\${optionSkipRelockDelayClosing}"
      set options(3) "\${optionSkipHoldTimeOpeningRelockDelayClosing}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param\_door_lock]</td>"
    append html "</tr>"
  }

  set param DOOR_OPENING_DIRECTION
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblDoorOpeningDirection}</td>"
      array_clear options
      set options(0) "\${optionInwards}"
      set options(1) "\${optionOutwards}"
      append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]&nbsp;[getHelpIcon $param]</td>"
    append html "</tr>"
  }


  set param SENSOR_SENSITIVITY
  if { [info exists ps($param)] == 1 } {
    incr prn
    append html "<tr>"
      append html "<td>\${lblSensorSensibility_A}</td>"
      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param\_door_lock]</td>"
    append html "</tr>"
  }

}

proc getNoParametersToSet {} {
  set html "<tr><td name=\"noParamElm\" class=\"CLASS22003\"><div class=\"CLASS22004\">\${deviceAndChannelParamsLblNoParamsToSet}</div></td></tr>"
  # center content
  append html "<script type=\"text/javascript\">window.setTimeout(function(){jQuery(\"\[name='noParamElm'\]\").parent().parent().parent().width(\"100%\");},100);</script>"
  return $html
}
