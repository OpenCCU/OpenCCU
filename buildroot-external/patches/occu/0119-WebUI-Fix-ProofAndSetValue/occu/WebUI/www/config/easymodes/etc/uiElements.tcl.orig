sourceOnce [file join $env(DOCUMENT_ROOT) config/easymodes/etc/hmip_helper.tcl]

proc getMinValue {param} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set min [format {%1.1f} $param_descr(MIN)]
  return "$min"
}

proc getMaxValue {param} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set max [format {%1.1f} $param_descr(MAX)]
  return "$max"
}

proc getUserDefinedMaxValue {devType {extraparam ""}} {
  if {[string equal $extraparam "TX_THRESHOLD_POWER"] == 1} {
    switch [string tolower $devType] {
      hmip-psm -
      hmip-fsm16 {return 3680.0}
      hmip-psm-2 -
      "hmip-psm-2 qhj" {return 3000.0}
      hmip-bsm -
      hmip-fsm  {return 1150.0}
      hmip-usbsm  {return 60.0}
     default {return "<span class=\"attention\">max value not available</span>"}
    }
  }

  if {([string equal $extraparam "COND_TX_THRESHOLD_LO"] == 1) || ([string equal $extraparam "COND_TX_THRESHOLD_HI"] == 1)} {
    switch [string tolower $devType] {
      hmip-psm -
      hmip-fsm16 {return "3680.0"}
      hmip-psm-2 -
      "hmip-psm-2 qhj" {return "3000.0"}
      hmip-bsm -
      hmip-fsm  {return "1150.0"}
      hmip-usbsm  {return "60.0"}
     default {return "<span class=\"attention\">max value not available</span>"}
    }
  }

}

proc getMinMaxValueDescr {param {extraparam ""}} {
  global psDescr dev_descr ps
  upvar psDescr descr
  upvar ps PS

  array_clear param_descr
  array set param_descr $descr($param)
  set min $param_descr(MIN)
  set max $param_descr(MAX)


  if {[string equal $dev_descr(TYPE) "HmIP-STV"] == 1} {

    if {$param == "TRIGGER_ANGLE"} {
      if {$PS(CHANNEL_OPERATION_MODE) ==  2} {
        set min 10
        set max 45

        cgi_javascript {
          puts {
            var min = 10, max = 45,
            triggerAngleElm = jQuery("[name='TRIGGER_ANGLE']").first();

            triggerAngleElm.unbind("blur");
            triggerAngleElm.removeAttr("onblur");
            triggerAngleElm.bind("blur",function() {
              ProofAndSetValue(this.id, this.id, min, max, 1);
            });
          }
        }

      }
    }

    if {$param == "TRIGGER_ANGLE_HYSTERESIS"} {
      set min 0
      set max 5

      cgi_javascript {
        puts {
          var min = 0, max = 5,
          triggerAngleHysElm = jQuery("[name='TRIGGER_ANGLE_HYSTERESIS']").first();

          triggerAngleHysElm.unbind("blur")
          triggerAngleHysElm.removeAttr("onblur");
          triggerAngleHysElm.bind("blur",function() {
            ProofAndSetValue(this.id, this.id, min, max, 1);
          });
        }
      }
    }
  }

  # SPHM-118 / SPHM-410 (the max value of the DRBL4 = autoconfig which isn't supported by this device)
  if {([string equal $dev_descr(TYPE) "HmIPW-DRBL4"] == 1) || ([string equal $dev_descr(TYPE) "HmIP-DRBLI4"] == 1)} {
    if {($param == "REFERENCE_RUNNING_TIME_TOP_BOTTOM_VALUE") || ($param == "REFERENCE_RUNNING_TIME_BOTTOM_TOP_VALUE")} {
      set max [expr $param_descr(MAX) - 1]
    }
  }

  if {[string equal $dev_descr(TYPE) "HmIP-SCTH230"] == 1} {
    if {$param == "INTERVAL_VALUE"} {set min 1}
    if {$param == "CALIBRATION_PPM_VAL"} {set max 10000}
  }


  if {[string equal $dev_descr(TYPE) "HmIP-WUA"] == 1} {
    if {$param == "VOLTAGE_0"} {set max 99.5}
    if {$param == "VOLTAGE_100"} {set min 0.5}
  }

  set unit "noUnit"

  catch {set unit $param_descr(UNIT)}

  if {($unit == "100%") && ($max <= 1)} {
    set min [format %.0f [expr $min * 100]]
    set max [format %.0f [expr $max * 100]]
  }

  # Limit float to 1 decimal places
  if {([llength [split $min "."]] == 2) || ([llength [split $max "."]] == 2)} {
    if {$param != "METER_CONSTANT_VOLUME"} {
      set min [format {%1.1f} $min]
      set max [format {%1.1f} $max]
    } else {
      set min [format {%1.3f} $min]
      set max [format {%1.3f} $max]
    }
  }

  if {[string equal $dev_descr(TYPE) "HmIP-MIO16-PCB"] == 1} {
    if {([string equal $param "COND_TX_THRESHOLD_LO"] == 1) || ([string equal $param "COND_TX_THRESHOLD_HI"] == 1)} {
      append min "V"
      append max "V"
    }
  }

  if {[string equal $dev_descr(TYPE) "ELV-SH-CAP"] == 1} {
    # In this case extraparam should be the channel of the device
    if {$extraparam == "3"} {
      if {([string equal $param "COND_TX_THRESHOLD_LO"] == 1) || ([string equal $param "COND_TX_THRESHOLD_HI"] == 1)} {
        set min [format {%1.2f} [expr $min / 100]]
        set max [format {%1.2f} [expr $max / 100]]
      }
    }
  }

  if {$param == "TRIGGER_ANGLE_2"} {
    upvar valTriggerAngle triggerAngle
    set min "<span id='minTriggerAngle2' >$triggerAngle</span>"
  }

  if {$param == "NUMERIC_PIN_CODE"} {
    return "\${unitNumericPinCode}"
  }

  return "($min - $max)"
}

proc getUnit {param} {
  global psDescr dev_descr ch_descr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)

  if { [catch {set unit $param_descr(UNIT)}]} {
    set unit "<span class=\"attention\">missing unit</span>"
  }

  if {$unit == "100%"} {
    set unit "%"
  }

  if {$unit == "minutes"} {
   set unit "\${lblMinutes}"
  }

  if {[string equal $ch_descr(TYPE) "UNIVERSAL_LIGHT_RECEIVER"] != 1} {
    if {($unit == "K") || ($unit == "??C") || ($unit == "°C")} {
      set unit "&#176;C"
    }
  }

  if {$unit == "_Grad_"} {
    set unit "&#176;"
  }
  if {([string equal $dev_descr(TYPE) "HmIP-STI"] == 1) && ([string equal $param "REPEATED_LONG_PRESS_TIMEOUT_VALUE"] == 1)} {
    set unit "s (0.0 - 6.0)"
  }

  if {[string equal $param "METER_CONSTANT_VOLUME"] == 1} {
     set unit "m<sup>3</sup>/Imp"
  }

  if {[string equal $param "METER_CONSTANT_ENERGY"] == 1} {
     set unit "Imp/kWh"
  }

  if {[string equal $param "ALTITUDE"] == 1} {
     set unit "\${lblMeter}"
  }
  return "$unit"
}

proc getCondTXThresholdUnit {devType chn} {
   switch [string tolower $devType] {
        hmip-stho -
        hmip-stho-a -
        elv-sh-cth {
          if {$chn == "2"} {return "°C"}
          if {$chn == "3"} {return "%"}
        }
        elv-sh-cap {
          if {$chn == "2"} {return "°C"}
          if {$chn == "3"} {return "hPa"}
        }
        hmip-slo {return "Lux"}
        hmip-scth230 {
          if {$chn == "2" || $chn == "3"} {return "ppm"}
          if {$chn == "5"} {return "°C"}
          if {$chn == "6"} {return "%"}
        }
      default {return ""}
    }
}

proc getUserDefinedCondTXThresholdUnitMinMaxDescr {devType param} {
   switch [string tolower $devType] {
      hmip-psm -
      hmip-psm-2 -
      "hmip-psm-2 qhj" -
      hmip-fsm16 -
      hmip-bsm -
      hmip-fsm -
      hmip-usbsm
       {
        if {$param == "TX_THRESHOLD_POWER"} {return "W (0.0 - [getUserDefinedMaxValue $devType $param])"}
        if {($param == "COND_TX_THRESHOLD_LO") || ($param == "COND_TX_THRESHOLD_HI")} {return "W (0 - [getUserDefinedMaxValue $devType $param])"}
      }
      default {return "<span class=\"attention\">missing description</span>"}
   }
}

proc getTextField {param value chn prn {extraparam ""} {superExtra ""}} {

  # exec echo "getTextField: $extraparam" >> /tmp/textField.log

  if {[string equal $value ""] == 1} {set value ''}

  global psDescr dev_descr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set minValue $param_descr(MIN)
  set maxValue $param_descr(MAX)
  set maxLength ""
  set sizeTextfield 5

  if {[string first "." $param_descr(MIN)] != -1} {
    set minValue [format {%1.1f} $minValue]
  }

  if {[string first "." $param_descr(MAX)] != -1} {
    set maxValue [format {%1.1f} $maxValue]
  }

  if {[devIsPowerMeter $dev_descr(TYPE)]} {
    if {[string equal $param "TX_THRESHOLD_POWER"] == 1} {
      set maxValue [getUserDefinedMaxValue $dev_descr(TYPE) $param]
    }
  }

  # SPHM-118 (the max value of the DRBL4 = autoconfig which isn't supported by this device)
  if {([string equal $dev_descr(TYPE) "HmIPW-DRBL4"] == 1) || ([string equal $dev_descr(TYPE) "HmIP-DRBLI4"] == 1)} {
    if {($param == "REFERENCE_RUNNING_TIME_TOP_BOTTOM_VALUE") ||  ($param == "REFERENCE_RUNNING_TIME_BOTTOM_TOP_VALUE")} {
      set maxValue [expr $param_descr(MAX) - 1]
    }
  }

  if {[string first "-WGD" $dev_descr(TYPE)] != 1} {
    if {$param == "MAIN_TEXT" || $param == "SUB_TEXT"} {
      set minValue "stringUTF8"
      set maxValue "stringUTF8"
      set maxLength "maxLength=16"
    }
  }

  if {([string equal $dev_descr(TYPE) "HmIP-ESI"] == 1)} {
    if {$param == "METER_OBIS_SEARCH_STRING"} {
      set minValue "stringUTF8"
      set maxValue "stringUTF8"
      set maxLength "maxLength=16"
      set sizeTextfield 16
    }
  }

  if {[string equal $dev_descr(TYPE) "HmIP-SCTH230"] == 1} {
    if {$param == "INTERVAL_VALUE"} {set minValue 1}
    if {$param == "CALIBRATION_PPM_VAL"} {set maxValue 10000}
  }

set comment {
  if {$param == "DIM_LEVEL_LOWEST"} {
    set onMinLevel [expr $extraparam * 1.0]
    if {($onMinLevel < 0.5)} {
      set minValue $minValue
    } else {
      set minValue $onMinLevel
    }
  }
}
  set elemId 'separate_CHANNEL\_$chn\_$prn'

  # Limit float to 2 decimal places
  if {[llength [split $value "."]] == 2} {
    if {$param != "METER_CONSTANT_VOLUME"} {
      catch {set value [format {%1.1f} $value]}
    } else {
      catch {set value [format {%1.3f} $value]}
      catch {set minValue [format {%1.3f} $param_descr(MIN)]}
      catch {set maxValue [format {%1.3f} $param_descr(MAX)]}
    }
  }

  # Convert float to int - sometimes the parameter UTC_* comes as float instead of int (for whatever reason). This will cause an error.
  if {([string equal $param UTC_OFFSET] == 1) || ([string equal $param UTC_DST_OFFSET] == 1)} {
    set value [expr {int([expr $value])}]
  }

  if {$param == "TRIGGER_ANGLE_2"} {
    upvar valTriggerAngle triggerAngle
    set minValue $triggerAngle
  }

  if {[string equal $dev_descr(TYPE) "ELV-SH-CAP"] == 1} {
    if {$chn == 3} {
      if {($param == "COND_TX_THRESHOLD_LO") || ($param == "COND_TX_THRESHOLD_HI")} {
        set value [expr $value * 1.0]
        set value [expr $value / 100]
        set minValue [format {%1.2f} [expr $minValue / 100]]
        set maxValue [format {%1.2f} [expr $maxValue / 100]]
      }
    }
  }

  if {$param == "TRIGGER_ANGLE" && [info exists descr(TRIGGER_ANGLE_2)] == 1} {
    upvar valTriggerAngle2 triggerAngle2
    set s "<input id=$elemId type=\"text\" size=\"$sizeTextfield\" value=$value name=$param onblur=\"SetTriggerAngle2(this.value, $triggerAngle2);ProofAndSetValue(this.id, this.id, $minValue, $maxValue, 1)\" $extraparam>"
    cgi_javascript {
      puts "var maxTriggerAngle = parseInt($maxValue), minTriggerAngle = parseInt($minValue);"
      puts {
        SetTriggerAngle2 = function(value, triggerAngle2) {
          var triggerAngleElm = jQuery("[name='TRIGGER_ANGLE']").first(),
          triggerAngleElm2 = jQuery("[name='TRIGGER_ANGLE_2']").first(),
          valTriggerAngle = parseInt(triggerAngleElm.val()),
          valTriggerAngle2 = parseInt(triggerAngleElm2.val()),
          value = parseInt(value);

          if (isNaN(valTriggerAngle) || (valTriggerAngle < minTriggerAngle)) {valTriggerAngle = minTriggerAngle; valTriggerAngle2 = minTriggerAngle;}
          if (valTriggerAngle > maxTriggerAngle) {valTriggerAngle = maxTriggerAngle; valTriggerAngle2 = maxTriggerAngle;}

          jQuery("\#minTriggerAngle2").text(valTriggerAngle);

          if ((valTriggerAngle > valTriggerAngle2) || (valTriggerAngle < minTriggerAngle) || (valTriggerAngle == maxTriggerAngle)) {
            triggerAngleElm2.val(valTriggerAngle);
          }

          triggerAngleElm2.unbind("blur")
          triggerAngleElm2.removeAttr("onblur");
          triggerAngleElm2.bind("blur",function() {
            ProofAndSetValue(this.id, this.id, valTriggerAngle, maxTriggerAngle, 1);
          });

        }
      }
    }
  } else {
    if {$param == "NUMERIC_PIN_CODE"} {
       set s "<input id=$elemId type=\"text\" size=\"$sizeTextfield\" maxlength=\"8\" value=\"$value\" name=$param onblur=\"if (! isNumber(this.value)) \{this.value = '';\}\" $extraparam>"
    } elseif {($param == "VOLTAGE_0") || ($param == "VOLTAGE_100")} {
        set s "<input id=$elemId type=\"text\" size=\"$sizeTextfield\" value=$value name=$param onblur=\"ProofAndSetValue(this.id, this.id, '$minValue', '$maxValue', 1);$extraparam\">"
    } elseif {$minValue == "stringUTF8"} {
        set s "<input id=$elemId type=\"text\" size=\"$sizeTextfield\" value=\"$value\" $maxLength name=$param>"
    } else {
      set s "<input id=$elemId type=\"text\" size=\"$sizeTextfield\" value=$value name=$param onblur=\"ProofAndSetValue(this.id, this.id, '$minValue', '$maxValue', 1);\" $extraparam $superExtra>"
    }
  }

  return $s
}

proc getTextField100Percent {param value chn prn {extraparam ""}} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set minValue [format {%1.1f} $param_descr(MIN)]
  set maxValue [format {%1.1f} $param_descr(MAX)]

  set minValue [expr $minValue * 100]
  set maxValue [expr $maxValue * 100]

  set elemIdTmp 'separate_CHANNEL\_$chn\_$prn\_tmp'
  set elemId 'separate_CHANNEL\_$chn\_$prn'

  # Limit float to 2 decimal places
  if {[llength [split $value "."]] == 2} {
    set value [format {%1.2f} $value]
  }

  set s "<input id=$elemIdTmp type=\"text\" size=\"5\" value=[format %.0f [expr $value * 100]] name=$param\_tmp onblur="
  append s "\"ProofAndSetValue(this.id, this.id, $minValue, $maxValue, 1);"
  append s "jQuery('#separate_CHANNEL\_$chn\_$prn').val(this.value / 100);\">"

  append s "<input id=$elemId type=\"text\" size=\"5\" class=\"hidden\" value=$value name=$param>"
  return $s
}

proc getOptionBox {param options value chn prn {extraparam ""}} {
  upvar $options optionValues

  set s "<select id='separate_CHANNEL\_$chn\_$prn' name=$param $extraparam>"
  set select ""
  foreach val [lsort -real [array names optionValues]] {

     if {$val == $value} {
      set select "selected=\"selected\""
     } else {
      set select ""
     }

     append s "<option class=\"[extractParamFromTranslationKey $optionValues($val)]\" value=$val $select>$optionValues($val)</option>"
  }

  append s "</select>"

  return $s
}

proc getCheckBox {param value chn prn {extraparam ""}} {
  set checked ""
  if { $value } then { set checked "checked=\"checked\"" }
  set s "<input id='separate_CHANNEL\_$chn\_$prn' type='checkbox' $checked value='dummy' name=$param $extraparam>"
  return $s
}

# This is necessary because the parameter CYCLIC_INFO_MSG is an int instead of a bool
# Here we are mapping the int (text field 0 - 255) to a checkbox (bool)
proc getCheckBoxCyclicInfoMsg {param value chn prn {extraparam ""}} {
  global psDescr
  upvar psDescr psDescr

  set hlpBoxWidth  640
  set hlpBoxHeight  400

  set s  "[getCheckBox '$param' $value $chn $prn\_tmp "onchange=\"setCyclicInfoMsg(this, '$chn', '$prn');\""]&nbsp;[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]"
  append s  "<td class=\"hidden\">[getTextField $param $value $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

  append s "<script type=\"text/javascript\">"
    append s "setCyclicInfoMsg = function(elm, chn, prn) \{"
      append s " var value = (jQuery(elm).prop('checked')) ? 1 : 0; "
      # don`t use jQuery - the dirty flag will not be recognized
      append s " document.getElementById('separate_CHANNEL_' + chn + '_' + prn ).value = value; "
    append s "\};"
  append s "</script>"
  return $s
}

proc getButton {id btnTxt callBack} {
  set s "<input id='$id' type=button onclick=$callBack>"
  # This translates the text of the button to the parameter btnTxt
  puts "<script type=\"text/javascript\">translateAttribute(\"\#$id\", \"value\", $btnTxt);</script>"
  return $s
}

proc getButtonChannelConfiguration {{extraDescription ""}} {
  global dev_descr_sender
  set html ""

  # The extraDescription allows it to place a description freely as you wish
  # Without it, the default description will be used.
  # Example:
  #  Default description: [getButtonChannelConfiguration]
  #  Special description: [getButtonChannelConfiguration helpDecisionValAndThreshold]

  if {$extraDescription == ""} {
    append html "<tr><td colspan='2'>\${helpBtnChannelConfiguration}</td></tr>"
  } else {
    append html "<tr><td colspan='2'>\${$extraDescription}</td></tr>"
  }

  append html "<tr>"
  append html "<td>\${SENDER_CHANNEL_SETTINGS}</td>"
  append html "<td><input type=\"button\" value=\${btnEdit} onclick=\"WebUI.enter(DeviceConfigPage, {'iface': 'HmIP-RF','address': '$dev_descr_sender(ADDRESS)', 'redirect_url': 'IC_SETPROFILES'});\" ></td>"
  append html "</tr>"

  return $html
}

proc getDeactivateLongKeypress {p profile special_input_id prn {optionDisable 0} {optionEnable 1} {callback ""}} {
  upvar $profile PROFILE
  upvar $p ps
  upvar pref pref

  # The default value for optionDisable = 0, for optionEnable = 1
  # You can set user defined values instead. See DIMMER_VIRTUAL_RECEIVER/KEY_TRANSMITTER

  set html ""

  # Long key press activ/inactive
  set param LONG_PROFILE_ACTION_TYPE
  if { [info exists ps($param)] == 1  } {
    incr pref
    append html "<tr>"
      append html "<td>\${longKeyPressActiveInactive}</td>"
      array_clear options
      set options($optionDisable) "\${optionDisable}"
      set options($optionEnable) "\${optionEnable}"
      append html "<td>[get_ComboBox options $param ${special_input_id}_$prn\_$pref PROFILE $param $callback]</td>"
    append html "</tr>"
  }
  return $html
}

proc getNumberOfDimmingSteps {p profile special_input_id prn stepParam} {
  upvar $profile PROFILE
  upvar $p ps
  upvar pref pref

  set html ""

  set param $stepParam
  if { [info exists ps($param)] == 1  } {
    incr pref
    append html "<tr>"
      append html "<td>\${longKeyPressDimmingSteps}</td>"
      array_clear options
      set options(0.05) 20
      set options(0.1) 10
      set options(0.11) 9
      set options(0.125) 8
      set options(0.14) 7
      set options(0.16) 6
      set options(0.2) 5
      set options(0.25) 4
      set options(0.33) 3
      set options(0.5) 2
      set options(1.0) 1
      append html "<td>[get_ComboBox options $param ${special_input_id}_$prn\_$pref PROFILE $param]&nbsp;[getHelpIcon DIM_STEP]</td>"
    append html "</tr>"
  }
  return $html
}

proc getHorizontalLine {{extraparam ""}} {
  return "<tr $extraparam><td colspan=\"2\"><hr></td></tr>"
}

proc getHelpIcon {topic {x 0} {y 0}} {

  # Default
  if {$x == 0} {set x 450}
  if {$y == 0} {set y 260}


  # Set the size for known parameters
  switch $topic {
   "ABORT_EVENT_SENDING_CHANNELS" {set x 500; set y 140}
   "ABORT_EVENT_SENDING_CHANNELS_ACCESS_TRANSCEIVER" {set x 500; set y 160}
   "ACTIVATE_LEVEL_VALUE" {set x 500; set y 80}
   "AUTO_HYDRAULIC_ADJUSTMENT" {set x 500; set y 75}
   "BLIND_AUTOCALIBRATION" {set x 450; set y 75}
   "BLIND_REFERENCE_RUNNING_TIME" {set x 450; set y 160}
   "BLOCKING_ON_SABOTAGE" {set x 450; set y 100}
   "BLOCKING_PERIOD" {set x 450; set y 100}
   "BLOCKING_PERMANENT" {set x 450; set y 150}
   "BLOCKING_PERMANENT_WKP" {set x 450; set y 180}
   "BLOCKING_PERMANENT_FWI" {set x 450; set y 150}
   "BLOCKING_TEMPORARY" {set x 450; set y 150}
   "BLOCKING_TEMPORARY_FWI" {set x 450; set y 150}
   "BOOST_TIME_PERIOD" {set x 450; set y 120}
   "CALIBRATION_PPM" {set x 500; set y 250}
   "CLIMATE_CONTROL_TYPE" {set x 500; set y 75}
   "CLIMATE_FUNCTION" {set x 450; set y 75}
   "COND_TX_DECISION_ABOVE_BELOW" {set x 450; set y 80}
   "CONTACT_BOOST" {set x 450; set y 180}
   "DELAY_COMPENSATION" {set x 450; set y 100}
   "DEVICE_OPERATION_MODE_RGBW" {set x 650; set y 200}
   "DEVICE_SENSOR_SENSITIVITY" {set x 450; set y 180}
   "DIM_LEVEL_HIGHEST" {set x 450; set y 55}
   "DIM_LEVEL_LOWEST" {set x 450; set y 125}
   "DIM_STEP" {set x 500; set y 150}
   "DISABLE_DEVICE_ALIVE_SIGNAL" {set x 500; set y 75 }
   "DISPLAY_MODE" {set x 500; set y 200 }
   "DISPLAY_INVERTED_COLORS" {set x 550; set y 60 }
   "DURATION_5MIN" {set x 500; set y 160}
   "ENABLE_ROUTING" {set x 500; set y 120}
   "EVENT_FILTER_NUMBER_motionDetect" {set x 400; set y 60}
   "EVENT_FILTER_PERIOD" {set x 450; set y 120}
   "EVENT_FILTER_TIME" {set x 400; set y 90}

   "FEEDBACK_LEVEL_VALUE" {set x 450; set y 55}

   "HEATING_COOLING" {set x 450; set y 160}
   "HUMIDITY_LIMIT_DISABLE" {set x 500; set y 200}
   "HUMIDITY_LIMIT_VALUE" {set x 450; set y 85}
   "INPUT_COPRO_ENABLED" {set x 500; set y 250}
   "LOCAL_RESET_DISABLED" {set x 500; set y 130}
   "MOUNTING_ORIENTATION" {set x 450; set y 75}
   "MOUNTING_ORIENTATION_A" {set x 450; set y 75}
   "ON_MIN_LEVEL" {set x 400; set y 80}
   "OPTIMUM_START_STOP" {set x 450; set y 80}
   "PSM_CHANNEL_OPERATION_MODE" {set x 450; set y 100}
   "PYRO_CHANNEL_OPERATION_MODE" {set x 500; set y 375}
   "OUTPUT_SWAP" {set x 450; set y 100}
   "OUTPUT_SWAP_SERVO" {set x 450; set y 50}
   "PERMANENT_FULL_RX" {set x 500; set y 160}
   "PIR_SENSITIVITY" {set x 500; set y 210}
   "POWERUP_JUMPTARGET_RGBW" {set x 450; set y 75}
   "PWM_AT_LOW_VALVE_POSITION" {set x 500; set y 130}
   "REPEAT_ENABLE" {set x 500; set y 210}
   "ROUTER_MODULE_ENABLED" {set x 500; set y 120}
   "SPDR_CHANNEL_MODE" {set x 600; set y 600}
   "TEMPERATURE_OFFSET" {set x 500; set y 160}
   "TEMPERATURE_OFFSET_STE2" {set x 500; set y 130}
   "TWO_POINT_HYSTERESIS" {set x 450; set y 160}
   "TWO_POINT_HYSTERESIS_A" {set x 500; set y 160}
   "TWO_POINT_HYSTERESIS_HUMIDITY" {set x 500; set y 160}
   "VOLTAGE_0" {set x 450; set y 120}
   "VOLTAGE_100" {set x 450; set y 120}
   "WEEK_PROGRAM_POINTER" {set x 400; set y 100}
   "WEEK_PROGRAM_POINTER_group" {set x 400; set y 100}
  }

  set ret "<img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:18px; height:18px; position:relative; top:2px\" onclick=\"showParamHelp('$topic', '$x', '$y')\">"
  return $ret
}

proc _getParamDescrKey {param} {

  set lParam [lreplace [split $param "_"] 0 0]
  set _paramDescr ""
  foreach val $lParam {
    append _paramDescr "$val"
    append _paramDescr "_"
  }
  return [string trimright $_paramDescr "_"]
}

proc getTimeSelector {paramDescr p profile type prn special_input_id timebase optionValues {extraparam ""}} {

  # paramDescr        Text vor der Auswahlbox
  # p                 Paramset
  # profile           the profile (e. g. PROFILE_1)
  # type              delay delayShort timeOnOff timeOnOffShort (determines the kind of the optionbox)
  # prn               profile number
  # special_input_id  special_input_id
  # timebase          SHORT_ON_TIME
  # optionValues      Option values when entering a user specific value (Enter value)

  # Example
  # [getTimeSelector ON_TIME_FACTOR_DESCR ps PROFILE_$prn timeOnOff $prn $special_input_id SHORT_ONDELAY_TIME TIMEBASE_LONG]

  upvar $profile PROFILE
  upvar $p ps
  upvar pref pref
  upvar cur_profile cur_profile

  set timeBaseParam "$timebase\_BASE"
  set timeFactorParam "$timebase\_FACTOR"

  if {[string equal $extraparam "SERVOSPEED"] == 0} {
    set paramBaseDescr [_getParamDescrKey $timeBaseParam]
    set paramFactorDescr [_getParamDescrKey $timeFactorParam]
  } else {
    set paramBaseDescr "SERVO_SPEED_UNIT"
    set paramFactorDescr "SERVO_SPEED_FACTOR"
  }

  set javascriptDelay 10

  incr pref
  append html "<tr $extraparam>"
  append html "<td>\${$paramDescr}</td>"
  append html [getComboBox $prn $pref $special_input_id $type $extraparam] ;# hmip_helper
  append html "</tr>"

  append html "<tr id=\"timeBase\_$prn\_$pref\" class=\"hidden\"><td>\${$paramBaseDescr}</td><td>"
  option $optionValues
  append html [get_ComboBox options $timeBaseParam separate_${special_input_id}_$prn\_$pref PROFILE $timeBaseParam]

  append html "</td></tr>"

  if {$prn == $cur_profile} {
    switch $type {
      delay {
        # setCurrentDelayOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }
      delayShort {
        # setCurrentDelayShortOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }
      timeOnOff {
        # setCurrentTimeOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }
      timeOnOffShort {
        # setCurrentTimeShortOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeShortOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }
      rampOnOff {
        # setCurrentRampOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentRampOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      switchingInterval {
        # setCurrentSwitchingIntervalOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      switchingIntervalOnTime {
        # setCurrentSwitchingIntervalOnTimeOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOnTimeOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      delay0To20M_step2M {
        # setDelay0to20M_step2MOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      alarmTimeMax10Min {
        # setDelay0to20M_step2MOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentAlarmTimeMax10MinOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      blink {
        # setCurrentBlinkOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

      blink0 {
        # setCurrentBlinkOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

    }
  } else {
    switch $type {
      delay {
        # setCurrentDelayOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }
      delayShort {
        # setCurrentDelayShortOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }
      timeOnOff {
        # setCurrentTimeOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }
      timeOnOffShort {
        # setCurrentTimeShortOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeShortOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }
      rampOnOff {
        # setCurrentRampOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentRampOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }

      switchingInterval {
        # setCurrentSwitchingIntervalOption
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentSwitchingIntervalOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }

      delay0To20M_step2M {
        append html "<script type=\"text/javascript\">setTimeout(function() {setDelay0to20M_step2MOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }

      alarmTimeMax10Min {
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentAlarmTimeMax10MinOption($prn, $pref, \"$special_input_id\",[lindex $PROFILE($timeBaseParam) 0],[lindex $PROFILE($timeFactorParam) 0]);}, $javascriptDelay)</script>"
      }

      blink {
        # default 1s on / off
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($prn, $pref, \"$special_input_id\",1,1);}, $javascriptDelay)</script>"
      }

      blink0 {
        # default 0s on / off
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($prn, $pref, \"$special_input_id\");}, $javascriptDelay)</script>"
      }

    }
  }
  incr pref
  append html "<tr id=\"timeFactor\_$prn\_$pref\" class=\"hidden\"><td>\${$paramFactorDescr}</td>"

  append html "<td>[get_InputElem $timeFactorParam separate_${special_input_id}_$prn\_$pref ps $timeFactorParam onchange=ProofAndSetValue(this.id,this.id,0,31,1)]&nbsp;(0-31)</td>"
  append html "</tr>"
  append html "<tr id=\"space_$prn\_$pref\" class=\"hidden\"><td><br/></td></tr>"

  return $html

}

proc getPowerUpSelector {chn p special_input_id} {
  global psDescr dev_descr ch_descr
  upvar psDescr psDescr
  upvar $p ps
  upvar prn prn

  set chType $ch_descr(TYPE)

  set idWindowDriveReceiver WINDOW_DRIVE_RECEIVER

  set specialID "[getSpecialID $special_input_id]"

  set param POWERUP_JUMPTARGET
  incr prn
  set powerupModePrn $prn
  set html "<tr>"
    append html "<td>\${stringTableDimmerPowerUpAction}</td>"
    if {[string equal $chType $idWindowDriveReceiver] != 1} {
      option POWERUP_JUMPTARGET_HMIP
    } else {
      option POWERUP_JUMPTARGET_WINDOW_DRIVE_RECEIVER_OnOff
    }
    append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn "onchange=\"powerUP_showRelevantData($chn, this.value,true);\""]</td>"
  append html "</tr>"

  append html "<tr id=\"powerUpPanelON_$chn\"><td colspan=\"2\"><table>"
    ###
    if {[string equal $chType $idWindowDriveReceiver] != 1} {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOnDelay}</td>"
      append html [getComboBox $chn $prn "$specialID" "delayShort"]
      append html "</tr>"

      set param POWERUP_ONDELAY_UNIT
      if { [info exists ps($param)] == 1 } {

          append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

          incr prn
          set param POWERUP_ONDELAY_VALUE
          append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
          append html "<td>\${stringTableOnDelayValue}</td>"

          append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

          append html "</tr>"
          append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
         append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
      }
    }
    ###
    set param POWERUP_ONTIME_UNIT
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOnTime}</td>"
      append html [getComboBox $chn $prn "$specialID" "timeOnOff"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_ONTIME_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOnTimeValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 50)</script>"
    }

    ###
    set param POWERUP_ON_LEVEL
    if { [info exists ps($param)] == 1  } {
      incr prn
      set powerUpLevelPRN $prn

      append html "<tr>"
        if {[string equal $ch_descr(TYPE) SERVO_VIRTUAL_RECEIVER] == 1} {
          append html "<td>\${stringTableServoLevel}</td>"
        } else {
          # Device TYPE == DIMMER
          if {([string equal $dev_descr(TYPE) HmIP-WUA] != 1) && ([string equal $dev_descr(TYPE) ELV-SH-WUA] != 1)} {
            append html "<td>\${stringTableDimmerLevel}</td>"
          } else {
            # Device TYPE == DIMMER but is no dimmer but a univeral actor (0 - 10V) - WUA
            append html "<td>\${lblOperatingVoltage}</td>"
          }
        }
        option RAW_0_100Percent
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
    }

    set param POWERUP_OPTICAL_SIGNAL_COLOR
    if { [info exists ps($param)] == 1 } {
      set tmp $ps($param)
      set listColor "optionColorBLACK  optionColorBLUE optionColorGREEN optionColorTURQUOISE optionColorRED optionColorPURPLE optionColorYELLOW optionColorWHITE"
      set select ""
      incr prn
      append html "<tr>"
        append html "<td>\${lblColorValue}</td>"
        append html "<td>"
          append html "<select id='separate_CHANNEL\_$chn\_$prn' name=$param>"
            # append html "<option value=\"14\" $select>\${colorOldValue}</option>"
            # append html "<option value=\"15\" $select>\${lblIgnore}</option>"
            for {set loop 0} {$loop <= [expr [llength $listColor] -1]} {incr loop} {
              if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
              append html "<option value=\"$loop\" $select>\${[lindex $listColor $loop]}</option>"
            }
          append html "</select>"
        append html "</td>"
      append html "</tr>"
    }

    set param POWERUP_OPTICAL_SIGNAL_BEHAVIOUR
    if { [info exists ps($param)] == 1 } {
      set tmp $ps($param)
      set listBehaviour "optionColorOFF optionColorON optionBlinkSlow optionBlinkMiddle optionBlinkFast optionBlinkFlashSlow optionBlinkFlashMiddle optionBlinkFlashFast optionBlinkBillowSlow optionBlinkBillowMiddle optionBlinkBillowFast"
      set select ""
      incr prn
      append html "<tr>"
        append html "<td>\${lblBehaviour}</td>"
        append html "<td>"
          append html "<select id='separate_CHANNEL\_$chn\_$prn' name=$param>"
            # append html "<option value=\"14\" $select>\${blinkOldValue}</option>"
            # append html "<option value=\"15\" $select>\${lblIgnore}</option>"
            for {set loop 0} {$loop <= [expr [llength $listBehaviour] -1]} {incr loop} {
              if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
              append html "<option value=\"$loop\" $select>\${[lindex $listBehaviour $loop]}</option>"
            }
          append html "</select>"
        append html "</td>"
      append html "</tr>"
    }


    set param POWERUP_OUTPUT_BEHAVIOUR
    if { [info exists ps($param)] == 1 } {
      if {[string equal $dev_descr(TYPE) HmIP-MP3P] == 1} {
        set tmp $ps($param)
        # set listColor "optionColorBLACK  optionColorBLUE optionColorGREEN optionColorTURQUOISE optionColorRED optionColorPURPLE optionColorYELLOW optionColorWHITE randomPlayback colorOldValue lblIgnore"
        set listColor "optionColorBLACK  optionColorBLUE optionColorGREEN optionColorTURQUOISE optionColorRED optionColorPURPLE optionColorYELLOW optionColorWHITE"
        set select ""
        incr prn
        append html "<tr>"
          append html "<td>\${lblColorValue}</td>"
          append html "<td>"
            append html "<select id='separate_CHANNEL\_$chn\_$prn' name=$param>"
              append html "<option value=\"253\" $select>\${randomPlayback}</option>"
              append html "<option value=\"254\" $select>\${colorOldValue}</option>"
              # append html "<option value=\"255\" $select>\${lblIgnore}</option>"
              for {set loop 0} {$loop <= [expr [llength $listColor] -1]} {incr loop} {
                if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
                append html "<option value=\"$loop\" $select>\${[lindex $listColor $loop]}</option>"
              }
            append html "</select>"
          append html "</td>"

          set param POWERUP_PROFILE_REPETITIONS
          if { [info exists ps($param)] == 1  } {
            set tmp $ps($param)
            incr prn
            append html "<td>\${lblRepetition}</td>"
            append html "<td>"
              append html "<select id='separate_CHANNEL\_$chn\_$prn' name=$param>"
              if {$tmp == 0} {set select "selected=\"selected\""} else {set select ""}
              append html "<option value=\"0\" $select>\${optionNoRepetition}</option>"
              if {$tmp == 255} {set select "selected=\"selected\""} else {set select ""}
              append html "<option value=\"255\" $select>\${optionInfiniteRepetition}</option>"
                  for {set loop 1} {$loop <= 254} {incr loop} {
                    if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
                    append html "<option value=\"$loop\" $select>$loop</option>"
                  }
              append html "</select>"
              append html "[getHelpIcon repetitionOffTimeDimmer 450 100]"
            append html "</td>"
          }

          # Show this element only if the parameter POWERUP_PROFILE_REPETITIONS exits.
          # POWERUP_PROFILE_REPETITIONS works only if the value of the parameter OFFTIME is set != permanently
          set param POWERUP_OFFTIME_UNIT
          if { ! [catch {set tmp $ps(POWERUP_PROFILE_REPETITIONS)}]  } {
            incr prn
            append html "<tr>"
            append html "<td>\${stringTableOffTime}</td>"
            append html [getComboBox $chn $prn "$specialID" "blink"]
            append html "</tr>"

            append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

            incr prn
            set param POWERUP_OFFTIME_VALUE
            append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
            append html "<td>\${stringTableOffTimeValue}</td>"

            append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

            append html "</tr>"
            append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
            append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
          }

        append html "</tr>"
      }
    }


  append html "</table></td></tr>"

# *******
  if { ! [catch {set tmp $ps(POWERUP_OFFTIME_UNIT)}]  } {
    append html "<tr id=\"powerUpPanelOFF_$chn\"><td colspan=\"2\"><table>"

      set comment { The actor is always off after powerup, so there is no need for a offdelay parameter
        set param POWERUP_OFFDELAY_UNIT
        if { [info exists ps($param)] == 1  } {
          incr prn
          append html "<tr>"
          append html "<td>\${stringTableOffDelay}</td>"
          append html [getComboBox $chn $prn "$specialID" "delayShort"]
          append html "</tr>"

          append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

          incr prn
          set param POWERUP_OFFDELAY_VALUE
          append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
          append html "<td>\${stringTableOffDelayValue}</td>"

          append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

          append html "</tr>"
          append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
          append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
        }

      ###

        set param POWERUP_OFFTIME_UNIT
        if { [info exists ps($param)] == 1  } {
          incr prn
          append html "<tr>"
          append html "<td>\${stringTableOffTime}</td>"
          append html [getComboBox $chn $prn "$specialID" "timeOnOff"]
          append html "</tr>"

          append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

          incr prn
          set param POWERUP_OFFTIME_VALUE
          append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
          append html "<td>\${stringTableOffTimeValue}</td>"

          append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

          append html "</tr>"
          append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
          append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 50)</script>"
        }

        ###
        set param POWERUP_OFF_LEVEL
        if { [info exists ps($param)] == 1  } {
          incr prn
          append html "<tr>"
            append html "<td>\${stringTableDimmerLevel}</td>"
            option RAW_0_100Percent
            append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
          append html "</tr>"
        }
      }
    append html "</table></td></tr>"
  }
# *******

  append html "<script type=\"text/javascript\">"

    append html "powerUP_showRelevantData = function(chn, val, valChanged) {"
      append html "var panelOnElm = jQuery(\"#powerUpPanelON_\" + chn),"
      append html "panelOffElm = jQuery(\"#powerUpPanelOFF_\" + chn);"
      append html "switch (parseInt(val)) {"
        append html "case 0:"
          # OFF
          append html "jQuery(\"#timeDelay_\" + chn + \"_7\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_8\").val(0).change().prop(\"disabled\", true);"
          # append html "jQuery(\"#timeDelay_\" + chn + \"_9\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_10\").val(0).change().prop(\"disabled\", true);"
          #catch {append html "jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(0);"}
          append html "panelOnElm.hide();"
          append html "panelOffElm.show();"
          append html "break;"
        append html "case 1:"
          # ON_DELAY
          append html "jQuery(\"#timeDelay_\" + chn + \"_2\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_3\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_4\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_6\").prop(\"disabled\", false);"
          catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(100);}"}
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 2:"
          # ON
          append html "jQuery(\"#timeDelay_\" + chn + \"_2\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_3\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_4\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_6\").val(0).change().prop(\"disabled\", true);"
          catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(100);}"}
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 3:"
          # OFF_DELAY
          append html "jQuery(\"#timeDelay_\" + chn + \"_7\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_8\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_9\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_10\").prop(\"disabled\", false);"
          append html "panelOnElm.hide();"
          append html "panelOffElm.show();"
          append html "break;"
        append html "default:"
          append html "panelOnElm.show();"
          append html "panelOffElm.show();"
      append html "}"
    append html "};"

    append html "window.setTimeout(function() {"
      append html "var selectedPowerMode = jQuery(\"#separate_CHANNEL_$chn\_$powerupModePrn\").val();"
      append html "powerUP_showRelevantData($chn, selectedPowerMode, false);"
    append html "},100);"
  append html "</script>"
  return $html
}


# ***********

proc getPowerUpSelectorAcousticSignal {chn p special_input_id} {
  global psDescr
  upvar psDescr psDescr
  upvar $p ps
  upvar prn prn

  set specialID "[getSpecialID $special_input_id]"

  set powerOutputBehaviourPrn 0

  set param POWERUP_JUMPTARGET
  incr prn
  set powerupModePrn $prn
  set html "<tr>"
    append html "<td>\${stringTableDimmerPowerUpAction}"
      set options(0) "\${stringTableStateFalse}"
      set options(1) "\${stringTableOnDelay}"
      set options(2) "\${stringTableStateTrue}"
      # set options(3) "\${stringTableOffDelay}"
      append html  "&nbsp;[getOptionBox '$param' options $ps($param) $chn $prn "onchange=\"powerUPAcousticSignal_showRelevantData($chn, this.value, true, true);\""]"
    append html "</td>"
  append html "</tr>"

  append html "<tr id=\"powerUpPanelON_$chn\"><td colspan=\"2\"><table>"
    ###
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableOnDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "delayShort"]
    append html "</tr>"

    set param POWERUP_ONDELAY_UNIT
    if { [info exists ps($param)] == 1  } {

        append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

        incr prn
        set param POWERUP_ONDELAY_VALUE
        append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
        append html "<td>\${stringTableOnDelayValue}</td>"

        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

        append html "</tr>"
        append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"

      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"

    }

    ###
    set param POWERUP_ONTIME_UNIT
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOnTime}</td>"
      append html [getComboBox $chn $prn "$specialID" "timeOnOff"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_ONTIME_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOnTimeValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 50)</script>"
    }

    ###
    set param POWERUP_ON_LEVEL
    if { [info exists ps($param)] == 1  } {
      incr prn
      set powerUpLevelPRN $prn
      append html "<tr>"
        append html "<td>\${lblVolume}</td>"
        option RAW_0_100Percent
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
    }

    set param POWERUP_OUTPUT_BEHAVIOUR
    if { [info exists ps($param)] == 1  } {
      set select ""
      set tmp $ps($param)
      incr prn
      set powerOutputBehaviourPrn $prn
      append html "<tr>"
        append html "<td>\${lblSoundFileNr}</td>"
        append html "<td>"
          append html "<select id='separate_CHANNEL\_$chn\_$prn' name=$param onchange='selectedFileHint(this.value, $chn)'>"
            if {$tmp == 0} {set select "selected=\"selected\""}
            append html "<option value=\"0\" $select>\${internalSystemSound}</option>"
            if {$tmp == 253} {set select "selected=\"selected\""} else {set select ""}
            append html "<option value=\"253\" $select>\${randomPlayback}</option>"
            if {$tmp == 254} {set select "selected=\"selected\""} else {set select ""}
            append html "<option value=\"254\" $select>\${soundOldValue}</option>"
            # if {$tmp == 255} {set select "selected=\"selected\""} else {set select ""}
            # append html "<option value=\"255\" $select>\${lblIgnore}</option>"
            for {set loop 1} {$loop <= 252} {incr loop} {
              if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
              append html "<option value=\"$loop\" $select>$loop</option>"
            }
          append html "</select>"
        append html "</td>"

        set param POWERUP_PROFILE_REPETITIONS
        if { [info exists ps($param)] == 1  } {
          set tmp $ps($param)
          incr prn
          append html "<td>\${lblRepetition}</td>"
          append html "<td>"
            append html "<select id=\"separate_CHANNEL\_$chn\_$prn\" name=$param>"
              if {$tmp == 0} {set select "selected=\"selected\""} else {set select ""}
              append html "<option value=\"0\" $select>\${optionNoRepetition}</option>"
              if {$tmp == 255} {set select "selected=\"selected\""} else {set select ""}
              append html "<option value=\"255\" $select>\${optionInfiniteRepetition}</option>"
                for {set loop 1} {$loop <= 254} {incr loop} {
                  if {$tmp == $loop} {set select "selected=\"selected\""} else {set select ""}
                  append html "<option value=\"$loop\" $select>$loop</option>"
                }
            append html "</select>"
            append html "[getHelpIcon repetitionOffTimeSound 450 100]"
          append html "</td>"
        }
      append html "</tr>"

      append html "<tr id=\"soundFileHint_$chn\" class=\"hidden\">"
        append html "<td></td><td colspan=\"2\">\${hintSoundFileRandom20}</td>"
      append html "</tr>"

          set param POWERUP_OFFTIME_UNIT
          if { [info exists ps($param)] == 1  } {
            incr prn
            append html "<tr>"
            append html "<td>\${stringTableOffTime}</td>"
            append html [getComboBox $chn $prn "$specialID" "blink"]
            append html "</tr>"

            append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

            incr prn
            set param POWERUP_OFFTIME_VALUE
            append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
            append html "<td>\${stringTableOffTimeValue}</td>"

            append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

            append html "</tr>"
            append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
            append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
          }

    }



  append html "</table></td></tr>"

set comment {
  append html "<tr id=\"powerUpPanelOFF_$chn\"><td colspan=\"2\"><table>"
    ### OFF
    set param POWERUP_OFFDELAY_UNIT
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOffDelay}</td>"
      append html [getComboBox $chn $prn "$specialID" "delayShort"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_OFFDELAY_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOffDelayValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }

    set param POWERUP_OFFTIME_UNIT
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOffTime}</td>"
      append html [getComboBox $chn $prn "$specialID" "timeOnOff"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_OFFTIME_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOffTimeValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentBlinkOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }

    set param POWERUP_OFF_LEVEL
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        append html "<td>\${lblVolume}</td>"
        option RAW_0_100Percent
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
    }
  append html "</table></td></tr>"
}

  append html "<script type=\"text/javascript\">"

    append html "selectedFileHint = function(val, chn) {"
      append html "if (val == \"253\") {"
        # 253 = RANDOM_SOUNDFILE
        append html "jQuery(\"#soundFileHint_\" + chn).show();"
      append html "} else {"
        append html "jQuery(\"#soundFileHint_\" + chn).hide();"
      append html "}"
    append html "};"

    append html "powerUPAcousticSignal_showRelevantData = function(chn, val, valChanged) {"
      append html "var panelOnElm = jQuery(\"#powerUpPanelON_\" + chn),"
      append html "panelOffElm = jQuery(\"#powerUpPanelOFF_\" + chn);"
      append html "switch (parseInt(val)) {"
        append html "case 0:"
          # OFF
          append html "jQuery(\"#timeDelay_\" + chn + \"_7\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_8\").val(0).change().prop(\"disabled\", true);"
          # append html "jQuery(\"#timeDelay_\" + chn + \"_9\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(0);"
          append html "panelOnElm.hide();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 1:"
          # ON_DELAY
          append html "jQuery(\"#timeDelay_\" + chn + \"_2\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_3\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_4\").prop(\"disabled\", false);"
          catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(100);}"}
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 2:"
          # ON
          append html "jQuery(\"#timeDelay_\" + chn + \"_2\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_3\").val(0).change().prop(\"disabled\", true);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_4\").val(0).change().prop(\"disabled\", true);"
          catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_$powerUpLevelPRN\").val(100);}"}
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "case 3:"
          # OFF_DELAY
          append html "jQuery(\"#timeDelay_\" + chn + \"_7\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_8\").prop(\"disabled\", false);"
          append html "jQuery(\"#timeDelay_\" + chn + \"_9\").prop(\"disabled\", false);"
          append html "panelOnElm.hide();"
          append html "panelOffElm.hide();"
          append html "break;"
        append html "default:"
          append html "panelOnElm.show();"
          append html "panelOffElm.show();"
      append html "}"
    append html "};"

    append html "window.setTimeout(function() {"
      append html "var selectedPowerMode = jQuery(\"#separate_CHANNEL_$chn\_$powerupModePrn\").val();"
      append html "var selectedSoundFile = jQuery(\"#separate_CHANNEL_$chn\_$powerOutputBehaviourPrn\").val();"
      append html "powerUPAcousticSignal_showRelevantData($chn, selectedPowerMode, false);"
      append html "if (selectedSoundFile == '253') {"
        append html "selectedFileHint(selectedSoundFile, $chn)"
      append html "}"
    append html "},100);"
  append html "</script>"
  return $html
}

proc getAcousticdDisplayReceiverConfig {special_input_id chn valText valAlignment valBgColor valTextColor valIcon} {
  upvar prn prn

  set specialID "[getSpecialID $special_input_id]"

    set html "<tr>"
      append html "<td colspan=\"2\"><table><tbody style=\"background-color:white\">"
        append html "<tr>"
          append html "<th>\${lblText}&nbsp;<img src=\"/ise/img/help.png\" onclick=\"showDisplayConfigTextHelp();\" width=\"16\" height=\"16\"></th>"
          append html "<th>\${lblAlign}</th>"
          append html "<th>\${lblBGColorBR}</th>"
          append html "<th>\${lblTextColorBR}</th>"
          append html "<th>\${lblIcon}</th>"
          append html "</tr>"
        append html "<tr>"
          # TEXT
          append html "<td>"
            append html "<input id='separate_$special_input_id\_$prn' name='TEXT' type='text' value=\"$valText\" maxlength='15' size='15'>"
            append html "<script type=\"text/javascript\">"
              append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
              append html "elm.defaultValue = elm.value;"
            append html "</script>"

          append html "</td>"
          incr prn

          # Align
          set selLeft ""
          set selCenter ""
          set selRight ""
          if {$valAlignment == 0} {set selLeft  "selected=\"selected\"" }
          if {$valAlignment == 1} {set selCenter  "selected=\"selected\"" }
          if {$valAlignment == 2} {set selRight  "selected=\"selected\"" }
          append html "<td>"
            append html "<select class='centerSelect' id='separate_$special_input_id\_$prn' name='TEXT_ALIGNMENT' onchange='setTextAlign(this.value, $chn, [expr $prn - 1]);'>"
              append html "<option value='0' $selLeft>\${lblLeft}</option>"
              append html "<option value='1' $selCenter>\${lblCenter}</option>"
              append html "<option value='2' $selRight>\${lblRight}</option>"
            append html "</select>"
          append html "</td>"
          append html "<script type=\"text/javascript\">"
            append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
            append html "elm.defaultSelected = elm.value;"

            append html "setTextAlign = function(alignment, chn, prevElmPrn) \{"
              append html "var align = \['left', 'center', 'right'\];"
              append html "var textElm = jQuery(\"\#separate\_$specialID\_\"\+chn+\"_\"+prevElmPrn);"
              append html "textElm.attr(\"style\", \"text-align:\" + align\[alignment\]);"
            append html "\};"

            append html "setTextAlign($valAlignment, $chn, [expr $prn - 1]);"

          append html "</script>"
          incr prn

          # BgColor
          set colorWhite ""
          set colorBlack ""
          if {$valBgColor == 0} {set colorWhite  "selected=\"selected\"" }
          if {$valBgColor == 1} {set colorBlack  "selected=\"selected\"" }
          append html "<td>"
            append html "<select class='centerSelect' id='separate_$special_input_id\_$prn' name='TEXT_BACKGROUND_COLOR'>"
              append html "<option value='0' $colorWhite >\${optionColorWHITE}</option>"
              append html "<option value='1' $colorBlack>\${optionColorBLACK_A}</option>"
            append html "</select>"
          append html "</td>"
          append html "<script type=\"text/javascript\">"
            append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
            append html "elm.defaultSelected = elm.value;"
           append html "</script>"
          incr prn

          # TextColor
          set colorWhite ""
          set colorBlack ""
          if {$valTextColor == 0} {set colorWhite  "selected=\"selected\"" }
          if {$valTextColor == 1} {set colorBlack  "selected=\"selected\"" }
          append html "<td>"
            append html "<select class='centerSelect' id='separate_$special_input_id\_$prn' name='TEXT_COLOR'>"
              append html "<option value='0' $colorWhite >\${optionColorWHITE}</option>"
              append html "<option value='1' $colorBlack>\${optionColorBLACK_A}</option>"
            append html "</select>"
          append html "</td>"
          append html "<script type=\"text/javascript\">"
            append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
            append html "elm.defaultSelected = elm.value;"
           append html "</script>"
          incr prn

          # Icon
          append html "<td>"
            append html "<select class='centerSelect' id='separate_$special_input_id\_$prn' name='TEXT_ICON' onchange='setIconPreview(this.value, \"$chn\")'>"
              set iconCounter 0
              foreach icon {stringTableNotUsed iconLampOff iconLampOn iconPadlockOpen iconPadlockClosed iconX iconTick iconInfo iconEnvelope iconWrench iconSun iconMoon iconWind
              iconCloud iconCloudBolt iconCloudLightRain iconCloudMoon iconCloudRain iconCloudSnow iconCloudSun iconCloundSunRain iconSnowFlake iconRainDrop iconFlame
              iconWindowOpen iconShutter iconEco iconProtectionOff iconProtectionExternal iconProtectionInternal iconBell iconClock} {
                append html "<option value='$iconCounter'>\${$icon}</option>"
                incr iconCounter
              }
            append html "</select>"
          append html "</td>"
          append html "<td id=\"iconPreview_$chn\"></td>"

          append html "<script type=\"text/javascript\">"
            append html "setIconPreview = function(picNr, chn) \{"
              append html "var picPath = \"/ise/img/icons_hmip_wrcd/24/\","
              append html "previewElm = jQuery(\"\#iconPreview_\"+chn);"

              append html "if (picNr != 0) \{"
                append html "previewElm.html(\" <img src='\" + picPath + picNr + \".png' alt='' style = 'height:20px; background-color:\#f0f0f0;'>\");"
              append html "\} else \{"
                append html "previewElm.html(\"\");"
              append html "\}"

            append html "\};"

            append html "window.setTimeout(function() \{"
              append html "jQuery(\"\#separate\_$special_input_id\_$prn option\[value='$valIcon'\]\").prop(\"selected\",true).change();"

              append html "var elm = document.getElementById('separate_$special_input_id\_$prn');"
              append html "elm.options\[elm.selectedIndex\].defaultSelected = elm.value;"
            append html "\},100);"
          append html "</script>"
          incr prn
        append html "</tr>"
      append html "</tbody></table></td>"
    append html "</tr>"
  return $html
}

# model must be shutter or blind
proc getPowerUpSelectorShutterBlind {chn p special_input_id model} {
  global psDescr dev_descr
  upvar psDescr psDescr
  upvar $p ps
  upvar prn prn

  set specialID "[getSpecialID $special_input_id]"

  set param POWERUP_JUMPTARGET
  incr prn
  set powerupModePrn $prn
  set html "<tr>"
    append html "<td>\${stringTablePowerUpAction}</td>"
    option POWERUP_JUMPTARGET_BLIND_OnOff
    append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn "onchange=\"powerUP_showRelevantData($chn, this.value,true);\""]</td>"
  append html "</tr>"

  append html "<tr id=\"powerUpPanelON_$chn\"><td colspan=\"2\"><table>"
    ###
    incr prn
    append html "<tr>"
    append html "<td>\${stringTableBlindLevelOnDelay}</td>"
    append html [getComboBox $chn $prn "$specialID" "delayShort"]
    append html "</tr>"

    set param POWERUP_ONDELAY_UNIT
    if { [info exists ps($param)] == 1  } {

        append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

        incr prn
        set param POWERUP_ONDELAY_VALUE
        append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
        append html "<td>\${stringTableOnDelayValue}</td>"

        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

        append html "</tr>"
        append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
       append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }

    ###
    set param POWERUP_ON_LEVEL
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        append html "<td>\${stringTableBlindLevelUp}</td>"
        option RAW_0_100Percent
        append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
      append html "</tr>"
    }

    if {[string equal $model "blind"] == 1} {
      set param POWERUP_ON_LEVEL_2
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr>"
          append html "<td>\${stringTableJalousieSlatsLevelUp}</td>"
          option RAW_0_100Percent_2
          append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
        append html "</tr>"
      }
    }

  append html "</table></td></tr>"

# *******
  if { ! [catch {set tmp $ps(POWERUP_OFFTIME_UNIT)}]  } {
    append html "<tr id=\"powerUpPanelOFF_$chn\"><td colspan=\"2\"><table>"

      set param POWERUP_OFFDELAY_UNIT
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr>"
        #append html "<td>\${stringTableBlindLevelOffDelay}</td>"
        append html "<td>\${stringTableBlindLevelOffDelay}</td>"
        append html [getComboBox $chn $prn "$specialID" "delayShort"]
        append html "</tr>"

        append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

        incr prn
        set param POWERUP_OFFDELAY_VALUE
        append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
        append html "<td>\${stringTableOffDelayValue}</td>"

        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

        append html "</tr>"
        append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
        append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayShortOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
      }

      ###
      set param POWERUP_OFF_LEVEL
      if { [info exists ps($param)] == 1  } {
        incr prn
        append html "<tr>"
          append html "<td>\${stringTableBlindLevelDown}</td>"
          option RAW_0_100Percent
          append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
        append html "</tr>"
      }

      if {[string equal $model "blind"] == 1} {
        set param POWERUP_OFF_LEVEL_2
        if { [info exists ps($param)] == 1  } {
          incr prn
          append html "<tr>"
            append html "<td>\${stringTableJalousieSlatsLevelDown}</td>"
            option RAW_0_100Percent_2
            append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
          append html "</tr>"
        }
      }

    append html "</table></td></tr>"
  }
# *******

  append html "<script type=\"text/javascript\">"

    append html "powerUP_showRelevantData = function(chn, val, valChanged) {"
      append html "var panelOnElm = jQuery(\"#powerUpPanelON_\" + chn),"
      append html "panelOffElm = jQuery(\"#powerUpPanelOFF_\" + chn);"

      append html "switch (parseInt(val)) {"

        append html "case 0:"
          # OFF
          append html "jQuery(\"#powerUpPanelOFF_\" + chn + \" select \").first().val(0).change().prop(\"disabled\", true);"
          append html "panelOnElm.hide();"
          append html "panelOffElm.show();"

          catch {append html "if (valChanged) {jQuery(\"#powerUpPanelOFF_\" + chn + \" select :visible\").eq(1).val(0);}"}
          catch {append html "if (valChanged) {jQuery(\"#powerUpPanelOFF_\" + chn + \" select :visible\").eq(2).val(101);}"}

        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_9\").val(0);}"}
        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_11\").val(0);}"}
        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_12\").val(101);}"}

          append html "break;"
        append html "case 1:"
          # ON_DELAY
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"

          append html "jQuery(\"#powerUpPanelON_\" + chn + \" select \").first().val(0).change().prop(\"disabled\", false);"
          catch {append html "if (valChanged) {jQuery(\"#powerUpPanelON_\" + chn + \" select :visible\").eq(1).val(100);}"}
          catch {append html "if (valChanged) {jQuery(\"#powerUpPanelON_\" + chn + \" select :visible\").eq(2).val(101);}"}

        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_6\").val(100);}"}
        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_7\").val(100);}"}
        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_8\").val(101);}"}

          append html "break;"
        append html "case 2:"
          # ON
          append html "panelOnElm.show();"
          append html "panelOffElm.hide();"
          append html "jQuery(\"#powerUpPanelON_\" + chn + \" select \").first().val(0).change().prop(\"disabled\", true);"
          catch {append html "if (valChanged) {jQuery(\"#powerUpPanelON_\" + chn + \" select :visible\").eq(1).val(100);}"}
          catch {append html "if (valChanged) {jQuery(\"#powerUpPanelON_\" + chn + \" select :visible\").eq(2).val(101);}"}

        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_6\").val(100);}"}
        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_7\").val(100);}"}
        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_8\").val(101);}"}
          append html "break;"
        append html "case 3:"
          # OFF_DELAY
          append html "panelOnElm.hide();"
          append html "panelOffElm.show();"
          append html "jQuery(\"#powerUpPanelOFF_\" + chn + \" select \").first().val(0).change().prop(\"disabled\", false);"
          catch {append html "if (valChanged) {jQuery(\"#powerUpPanelOFF_\" + chn + \" select :visible\").eq(1).val(0);}"}
          catch {append html "if (valChanged) {jQuery(\"#powerUpPanelOFF_\" + chn + \" select :visible\").eq(2).val(101);}"}

        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_9\").val(0);}"}
        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_11\").val(0);}"}
        #  catch {append html "if (valChanged) {jQuery(\"#separate_CHANNEL_\" + chn + \"_12\").val(101);}"}
          append html "break;"
        append html "default:"
          append html "panelOnElm.show();"
          append html "panelOffElm.show();"

      append html "}"
    append html "};"

    append html "window.setTimeout(function() {"
      append html "var selectedPowerMode = jQuery(\"#separate_CHANNEL_$chn\_$powerupModePrn\").val();"
      append html "powerUP_showRelevantData($chn, selectedPowerMode, false);"
    append html "},100);"
  append html "</script>"
  return $html
}

proc getPowerUpSelectorUniversalLightReceiver {chn p special_input_id mode {isDALI 0}} {

  # isDALI should be 1 for the HmIP-DRG-DALI

  global psDescr dev_descr ch_descr
  upvar psDescr psDescr
  upvar $p ps
  upvar prn prn

  set chType $ch_descr(TYPE)
  set specialID "[getSpecialID $special_input_id]"
  set html ""

  set param POWERUP_JUMPTARGET
  incr prn
  set powerupModePrn $prn
  append html "<tr>"
    append html "<td>\${stringTableDimmerPowerUpAction}</td>"
    option POWERUP_JUMPTARGET_HMIP
    append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn "onchange=\"powerUP_showRelevantData($chn, this.value,$prn);\""]&nbsp;[getHelpIcon $param\_RGBW]</td>"
  append html "</tr>"

  append html "<tr id=\"powerUpPanelON_$chn\"><td colspan=\"2\"><table>"

    set param POWERUP_ON_LEVEL
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
        if {$mode == 0} {
          # The actor acts as switch actor (ON/OFF). Here we set the ON value to 100%. This is invisible for the user.
          append html "<td class='hidden'>[getTextField $param 100 $chn $prn]</td>"
        } else {
          append html "<td>\${lblPowerUpOnLevel}</td>"
          option RAW_0_100Percent
          append html  "<td>[getOptionBox '$param' options $ps($param) $chn $prn]</td>"
        }
      append html "</tr>"
    }

    set param POWERUP_ONDELAY_UNIT
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr id=\"onDelay_$chn\">"
      append html "<td>\${stringTableOnDelay}</td>"
      append html [getComboBox $chn $prn "$specialID" "delay"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_ONDELAY_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOnDelayValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentDelayOption($chn, [expr $prn - 1], '$specialID');}, 100)</script>"
    }

    set param POWERUP_ONTIME_UNIT
    if { [info exists ps($param)] == 1  } {
      incr prn
      append html "<tr>"
      append html "<td>\${stringTableOnTime}</td>"
      append html [getComboBox $chn $prn "$specialID" "timeOnOff"]
      append html "</tr>"

      append html [getTimeUnitComboBox $param $ps($param) $chn $prn $special_input_id]

      incr prn
      set param POWERUP_ONTIME_VALUE
      append html "<tr id=\"timeFactor_$chn\_$prn\" class=\"hidden\">"
      append html "<td>\${stringTableOnTimeValue}</td>"

      append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]</td>"

      append html "</tr>"
      append html "<tr id=\"space_$chn\_$prn\" class=\"hidden\"><td><br/></td></tr>"
      append html "<script type=\"text/javascript\">setTimeout(function() {setCurrentTimeOption($chn, [expr $prn - 1], '$specialID');}, 50)</script>"
    }

    set param POWERUP_ON_COLOR_TEMPERATURE
    # mode 2 = DIMMER_TUNABLE_WHITE
    # The RGB mode (mode 3) of the DALI device is capable of TUNABLE_WHITE - the HmIP-RGBW is not.
    # mode 5 = HmIP-LSC
    if { ([info exists ps($param)] == 1)  && (($mode == 2) || ($mode == 5) || (($isDALI == 1) && ($mode == 3))) } {
      incr prn
      append html "<tr>"
        append html "<td>\${lblPowerUpOnColorTemperature}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getUnit $param]&nbsp;[getHelpIcon $param\_RGBW 450 75]</td>"
      append html "</tr>"
    }

    set param POWERUP_ON_HUE
    # mode 3 = DIMMER_RGB - mode 4 = DIMMER_RGBW mode5 = HmIP-LSC
    if { ([info exists ps($param)] == 1) && (($mode == 3) || ($mode == 4) || ($mode == 5)) } {
      incr prn
      append html "<tr>"
        append html "<td>\${lblPowerUpOnHue}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param 450 75]</td>"
      append html "</tr>"
    }

    # The device documentations describes this parameter as POWERUP_ON_LEVEL_2
    set param POWERUP_ON_SATURATION
    if { ([info exists ps($param)] == 1) && (($mode == 3)  || ($mode == 4) || ($mode == 5)) } {
      incr prn
      append html "<tr>"
        append html "<td>\${lblPowerUpOnSaturation}</td>"
        append html "<td>[getTextField $param $ps($param) $chn $prn]&nbsp;[getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param 450 75]</td>"
      append html "</tr>"
    }

  append html "</table></td></tr>"

  ### JS ###

  append html "<script type=\"text/javascript\">"

    append html "powerUP_showRelevantData = function(chn, selectedMode, prn) {"
      append html "var panelOnElm = jQuery(\"#powerUpPanelON_\" + chn),"
      append html "trOnnDelayElm = jQuery(\"#onDelay_\" + chn),"
      append html "trOnDelaySiblings = jQuery(trOnnDelayElm).nextAll().slice(0,3),"
      append html "onDelayElm = jQuery(\"#timeDelay_\" + chn + \"_\" + (parseInt(prn) + 2));"

      append html "switch (parseInt(selectedMode)) {"
        append html "case 0:"
          # OFF
          append html "panelOnElm.hide();"
          append html "trOnnDelayElm.hide();"
          append html "trOnDelaySiblings.hide();"
          append html "break;"

        append html "case 1:"
          # ON DELAY
          append html "panelOnElm.show();"
          append html "trOnnDelayElm.show();"
          append html "if (parseInt(onDelayElm.val()) == 11) \{"
            append html "trOnDelaySiblings.show();"
          append html "\}"
          append html "break;"

        append html "case 2:"
          # ON
          append html "panelOnElm.show();"
          append html "trOnnDelayElm.hide();"
          append html "trOnDelaySiblings.hide();"
          append html "break;"

        append html "default:"
          append html "panelOnElm.show();"
      append html "}"
    append html "};"

    append html "window.setTimeout(function() {"
      append html "var selectedPowerMode = jQuery(\"#separate_CHANNEL_$chn\_$powerupModePrn\").val();"
      append html "powerUP_showRelevantData($chn, selectedPowerMode, $powerupModePrn);"
    append html "},250);"

  append html "</script>"

  return $html
}


proc addHintHeatingGroupDevice {address} {
    append html "<script type='text/javascript'>"
    append html "addHintHeatingGroupDevice('$address');"
    append html "</script>"
}

proc addHintCondTransmitterLinkAvailable {iface address} {
  upvar prn prn
  upvar special_input_id special_input_id
  set chn [getChannel $special_input_id]
  set linkCount [getLinkCountByAddress $iface "$address:$chn"]
  if {$linkCount > 0} {
    set result "<tr><td><span id='hint_$chn\_$prn' class='attention hidden'><b>\${hintCondTransmitterLinkAvailable}</b><span></td></tr>"
    append result "<script type=\"text/javascript\">"
      append result "var elm = jQuery('\#separate_CHANNEL_$chn\_$prn');"
      append result "if (elm.prop('checked') == false) {"
        append result "window.setTimeout(function() {jQuery('#hint_$chn\_$prn').show();},100);"
      append result "}"
    append result "</script>"
    return $result
  }
}