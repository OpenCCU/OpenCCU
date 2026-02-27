#!/bin/tclsh


sourceOnce [file join /www/config/easymodes/em_common.tcl]

#Namen der EasyModes tauchen nicht mehr auf. Der Durchgängkeit werden sie hier noch definiert.
set PROFILES_MAP(0)  "Experte"
set PROFILES_MAP(1)  "TheOneAndOnlyEasyMode"

proc getCheckBox {type param value prn} {
  set checked ""
  if { $value } then { set checked "checked=\"checked\"" }
  set s "<input id='separate_$type\_$prn' type='checkbox' $checked value='dummy' name=$param/>"
  return $s
}

proc _getMinValue {param} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set min [format {%1.1f} $param_descr(MIN)]
  return "$min"
}

proc _getMaxValue {param} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set max [format {%1.1f} $param_descr(MAX)]
  return "$max"
}

proc _getTextField {type param value prn} {
  set elemId 'separate_$type\_$prn'
  # Limit float to 1 decimal places
  if {[llength [split $value "."]] == 2} {
    set value [format {%1.1f} $value]
  }

  set s "<input id=$elemId type=\"text\" size=\"5\" value=$value name=$param>"
  return $s
}

proc _getUnit {param} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set unit $param_descr(UNIT)

  if {$unit == "minutes"} {
   set unit "\${lblMinutes}"
  }

  if {($unit == "K") || ($unit == "??C") || ($unit == "Â°C")} {
    set unit "&#176;C"
  }

  if {$unit == "100%"} {
   set unit "%"
  }

  return "$unit"
}

proc _getMinMaxValueDescr {param} {
  global psDescr
  upvar psDescr descr
  array_clear param_descr
  array set param_descr $descr($param)
  set min $param_descr(MIN)
  set max $param_descr(MAX)

  if {[string equal $param VALVE_OFFSET] != 0} {
    return "(0 - 100)"
  }

  # Limit float to 2 decimal places
  if {[llength [split $min "."]] != 1} {
    set min [format {%1.1f} $min]
    set max [format {%1.1f} $max]
  }
  return "($min - $max)"
}

proc getHelpIcon {topic x y} {
  set ret "<img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:18px; height:18px; position:relative; top:2px\" onclick=\"showParamHelp('$topic', '$x', '$y')\">"
  return $ret
}

proc set_htmlParams {iface address pps pps_descr special_input_id peer_type} {

  global env iface_url
  
  upvar PROFILES_MAP  PROFILES_MAP
  upvar HTML_PARAMS   HTML_PARAMS
  upvar PROFILE_PNAME PROFILE_PNAME
  upvar $pps          ps
  upvar $pps_descr    psDescr
  
  #upvar PROFILE_0     PROFILE_0
  upvar PROFILE_1     PROFILE_1

  set CHANNEL $special_input_id

  set chn [lindex [split $special_input_id _] 0]

  set hlpBoxWidth 450
  set hlpBoxHeight 160

  foreach val [array names psDescr] {
    #puts "$val: $psDescr($val)\n"
  }

  puts "<script type=\"text/javascript\">"
    puts "ShowActiveWeeklyProgram = function(activePrg) {"
      puts " for (var i = 1; i <= 3; i++) {"
        puts "jQuery('#P' + i + '_Timeouts_Area').hide();"
      puts " }"
      puts " jQuery('#P' + activePrg + '_Timeouts_Area').show();"
    puts "};"
  puts "</script>"


  append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/js/CC.js');load_JSFunc('/config/easymodes/MASTER_LANG/HEATINGTHERMOSTATE_2ND_GEN.js');load_JSFunc('/config/easymodes/MASTER_LANG/HEATINGTHERMOSTATE_2ND_GEN_HELP.js');</script>"

  append HTML_PARAMS(separate_1) "[addHintHeatingGroupDevice $address]"

  set prn 0

  set param WEEK_PROGRAM_POINTER
  append HTML_PARAMS(separate_1) "<table class=\"ProfileTbl\">"
    append HTML_PARAMS(separate_1) "<td class='hidden'><input type='text' id='separate_$CHANNEL\_$prn' name='$param'></td>"
    append HTML_PARAMS(separate_1) "</tr>"

    # left
    append HTML_PARAMS(separate_1) "<tr>"
      append HTML_PARAMS(separate_1) "<td name=\"_expertParam\" class=\"_hidden\">\${stringTableWeekProgramToEdit}</td>"
      #append HTML_PARAMS(separate_1) "<td name=\"_expertParam\" class=\"_hidden\">[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param "onchange=\"ShowActiveWeeklyProgram(parseInt(\$(this).value)+1);\""]&nbsp;[getHelpIcon $param [expr $hlpBoxWidth * 0.8] [expr $hlpBoxHeight / 2]]</td>"
      append HTML_PARAMS(separate_1) "<td name=\"_expertParam\" class=\"_hidden\">"
        append HTML_PARAMS(separate_1) "<select id=\"editProgram\" onchange=\"ShowActiveWeeklyProgram(parseInt(\$(this).value)+1);\">"
          append HTML_PARAMS(separate_1) "<option value='0'>\${stringTableWeekProgram1}</option>"
          append HTML_PARAMS(separate_1) "<option value='1'>\${stringTableWeekProgram2}</option>"
          append HTML_PARAMS(separate_1) "<option value='2'>\${stringTableWeekProgram3}</option>"
      append HTML_PARAMS(separate_1) "</select>[getHelpIcon $param [expr $hlpBoxWidth * 0.8] [expr $hlpBoxHeight / 2]]"
      append HTML_PARAMS(separate_1) "</td>"
    append HTML_PARAMS(separate_1) "</tr>"
  append HTML_PARAMS(separate_1) "</table>"

  ## Create 3 Weekly Programs ##

  for {set loop 1} {$loop <=3} {incr loop} {
    set pNr "P$loop";
    append HTML_PARAMS(separate_1) "<div id=\"$pNr\_Timeouts_Area\" style=\"display:none\">"
    foreach day {SATURDAY SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY} {
      append HTML_PARAMS(separate_1) "<div id=\"$pNr\_temp_prof_$day\"></div>"
    }
    append HTML_PARAMS(separate_1) "</div>"

    append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">"
    append HTML_PARAMS(separate_1) "$pNr\_tom = new TimeoutManager('$iface', '$address', false, '$pNr\_');"
    foreach day {SATURDAY SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY} {

      for {set i 1} {$i <= 13} {incr i} {

        set timeout     $ps($pNr\_ENDTIME_${day}_$i)
        set temperature $ps($pNr\_TEMPERATURE_${day}_$i)
        append HTML_PARAMS(separate_1) "$pNr\_tom.setTemp('$day', $timeout, $temperature);"

        if {$timeout == 1440} then {
          break;
        }
      }

      append HTML_PARAMS(separate_1) "$pNr\_tom.setDivname('$day', '$pNr\_temp_prof_$day');"
      append HTML_PARAMS(separate_1) "$pNr\_tom.writeDay('$day');"
    }
    append HTML_PARAMS(separate_1) "</script>"
  }

  append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">ShowActiveWeeklyProgram(1);</script>"

  append HTML_PARAMS(separate_1) "<hr>"

  # *************** #

  append HTML_PARAMS(separate_1) "<table class=\"ProfileTbl\">"

  set comment {
    # left
    incr prn
    set param SHOW_SET_TEMPERATURE
    append HTML_PARAMS(separate_1) "<tr>"
    append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">\${stringTableShowSetpointTemp}</td>"
    append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">"
    append HTML_PARAMS(separate_1) "[getCheckBox $CHANNEL '$param' $ps($param) $prn]"
    append HTML_PARAMS(separate_1) "</td>"

    # right
    incr prn
    set param SHOW_HUMIDITY
    append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">\${stringTableShowHumidity}</td>"
    append HTML_PARAMS(separate_1)  "<td name=\"expertParam\" class=\"hidden\">[getCheckBox $CHANNEL '$param' $ps($param) $prn]</td>"
    append HTML_PARAMS(separate_1) "</tr>"
  }

    # left
    set param BUTTON_RESPONSE_WITHOUT_BACKLIGHT
    if { [info exists ps($param)] == 1  } {
      incr prn
      append HTML_PARAMS(separate_1) "<tr>"
      append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">\${stringTableButtonResponseWithoutBacklight}</td>"
      append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">"
      append HTML_PARAMS(separate_1) "[getCheckBox $CHANNEL '$param' $ps($param) $prn]"
      append HTML_PARAMS(separate_1) "</td>"
      append HTML_PARAMS(separate_1) "</tr>"
    }
  append HTML_PARAMS(separate_1) "</table>"

  append HTML_PARAMS(separate_1) "<hr>"

  append HTML_PARAMS(separate_1) "<table class=\"ProfileTbl\">"

    set param TEMPERATURE_LOWERING_COOLING
    if { [info exists ps($param)] == 1  } {
      # left
      incr prn
      append HTML_PARAMS(separate_1) "<tr><td>\${ecoCoolingTemperature}</td>"
      append HTML_PARAMS(separate_1)  "<td>[_getTextField $CHANNEL $param $ps($param) $prn]&nbsp;[_getUnit $param]&nbsp;[_getMinMaxValueDescr $param]<input id=\"comfortOld\" type=\"hidden\" value=\"$ps($param)\"></td>"
      append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">"
        append HTML_PARAMS(separate_1) "jQuery(\"#separate_$CHANNEL\_$prn\").bind(\"blur\",function() {ProofAndSetValue(this.id, this.id, '[_getMinValue $param]', '[_getMaxValue $param]', 1);});"
      append HTML_PARAMS(separate_1) "</script>"

      # right
      incr prn
      set param TEMPERATURE_LOWERING
      append HTML_PARAMS(separate_1) "<td>\${ecoHeatingTemperature}</td>"
      append HTML_PARAMS(separate_1)  "<td>[_getTextField $CHANNEL $param $ps($param) $prn]&nbsp;[_getUnit $param]&nbsp;[_getMinMaxValueDescr $param]<input id=\"ecoOld\" type=\"hidden\" value=\"$ps($param)\"></td>"
      append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">"
        append HTML_PARAMS(separate_1) "jQuery(\"#separate_$CHANNEL\_$prn\").bind(\"blur\",function() {ProofAndSetValue(this.id, this.id, '[_getMinValue $param]', '[_getMaxValue $param]', 1);});"
      append HTML_PARAMS(separate_1) "</script>"
      append HTML_PARAMS(separate_1) "</tr>"

      append HTML_PARAMS(separate_1) "<tr id=\"errorRow\" class=\"hidden\"> <td></td> <td colspan=\"2\"><span id=\"errorComfort\" class=\"attention\"></span></td> <td colspan=\"2\"><span id=\"errorEco\" class=\"attention\"></span></td> </tr>"
    }
    # left
    incr prn
    set param TEMPERATURE_MINIMUM
    array_clear options
    set i 0
    for {set val [_getMinValue $param]} {$val <= [_getMaxValue $param]} {set val [expr $val + 0.5]} {
      set options($i) "$val &#176;C"
      incr i;
    }
    append HTML_PARAMS(separate_1) "<tr><td>\${stringTableTemperatureMinimum}</td>"
    append HTML_PARAMS(separate_1)  "<td>[get_ComboBox options $param tmp_$CHANNEL\_$prn ps $param onchange=setMinMaxTemp('tmp_$CHANNEL\_$prn','separate_$CHANNEL\_$prn')]</span> <span class='hidden'>[_getTextField $CHANNEL '$param' $ps($param) $prn]</span></td>"
    append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">"
    append HTML_PARAMS(separate_1) "try{window.setTimeout(function() {setMinMaxTempOption('tmp_$CHANNEL\_$prn', 'separate_$CHANNEL\_$prn' );},100);} catch(e){}"
    append HTML_PARAMS(separate_1) "</script>"

    # right
    incr prn
    set param TEMPERATURE_MAXIMUM
    array_clear options
    set i 0
    for {set val [_getMinValue $param]} {$val <= [_getMaxValue $param]} {set val [expr $val + 0.5]} {
      set options($i) "$val &#176;C"
      incr i;
    }
    append HTML_PARAMS(separate_1) "<td>\${stringTableTemperatureMaximum}</td>"
    append HTML_PARAMS(separate_1)  "<td>[get_ComboBox options $param tmp_$CHANNEL\_$prn ps $param onchange=setMinMaxTemp('tmp_$CHANNEL\_$prn','separate_$CHANNEL\_$prn')]</span> <span class='hidden'>[_getTextField $CHANNEL '$param' $ps($param) $prn]</span></td>"
    append HTML_PARAMS(separate_1) "</tr>"
    append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">"
    append HTML_PARAMS(separate_1) "try{window.setTimeout(function() {setMinMaxTempOption('tmp_$CHANNEL\_$prn', 'separate_$CHANNEL\_$prn' );},100);} catch(e){}"
    append HTML_PARAMS(separate_1) "</script>"

    #left
    incr prn
    set param TEMPERATURE_OFFSET
    array_clear options
    set i 0
    for {set val -3.5} {$val <= 3.5} {set val [expr $val + 0.5]} {
      set options($val) "$val &#176;C"
      incr i;
    }
    append HTML_PARAMS(separate_1) "<td>\${stringTableTemperatureOffset}</td>"
    append HTML_PARAMS(separate_1) "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]</td>"
    append HTML_PARAMS(separate_1) "</tr>"

  # left
    incr prn
    set param TEMPERATURE_WINDOW_OPEN
    append HTML_PARAMS(separate_1) "<tr><td>\${stringTableTemperatureFallWindowOpen}</td>"
    append HTML_PARAMS(separate_1)  "<td colspan=\"2\">[_getTextField $CHANNEL $param $ps($param) $prn]&nbsp;[_getUnit $param]&nbsp;[_getMinMaxValueDescr $param]<input id=\"comfortOld\" type=\"hidden\" value=\"$ps($param)\"></td>"
    append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">"
    append HTML_PARAMS(separate_1) "jQuery(\"#separate_$CHANNEL\_$prn\").bind(\"blur\",function() {ProofAndSetValue(this.id, this.id, '[_getMinValue $param]', '[_getMaxValue $param]', 1);});"
    append HTML_PARAMS(separate_1) "</script>"
    append HTML_PARAMS(separate_1) "</tr>"

    # left
    incr prn
    set param TEMPERATUREFALL_MODUS
    append HTML_PARAMS(separate_1) "<tr name=\"expertParam\" class=\"hidden\"><td>\${stringTableTemperatureFallModeOptions}</td><td>"
    #append HTML_PARAMS(separate_1)  [get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param $hlpBoxWidth [expr $hlpBoxHeight + 20]]

    append HTML_PARAMS(separate_1) "<select id='separate_$CHANNEL\_$prn' name='$param'>"
    append HTML_PARAMS(separate_1) "<option value='0'>\${stringTableTemperatureFallModeOpt0}</option>"
    append HTML_PARAMS(separate_1) "<option value='1'>\${stringTableTemperatureFallModeOpt1}</option>"
    append HTML_PARAMS(separate_1) "<option value='2'>\${stringTableTemperatureFallModeOpt2}</option>"
    append HTML_PARAMS(separate_1) "<option value='3'>\${stringTableTemperatureFallModeOpt3}</option>"
    append HTML_PARAMS(separate_1) "<option value='4'>\${stringTableTemperatureFallModeOpt4}</option>"
    append HTML_PARAMS(separate_1) "</select>"

    append HTML_PARAMS(separate_1) "</td>"
    append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">jQuery('\#separate_$CHANNEL\_$prn\').val($ps($param));</script>"

    # right
    incr prn
    set param TEMPERATUREFALL_VALUE
    append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">\${stringTableTemperatureFallValue}</td>"
    append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">[_getTextField $CHANNEL $param $ps($param) $prn]&nbsp;[_getUnit $param]&nbsp;[_getMinMaxValueDescr $param]</td>"
    append HTML_PARAMS(separate_1) "</tr>"



    set param DURATION_5MIN
    if { [info exists ps($param)] == 1  } {
      # In older versions this parameter is not available
      incr prn
      append HTML_PARAMS(separate_1) "<tr name=\"expertParam\" class=\"hidden\">"
        append HTML_PARAMS(separate_1) "<td>\${stringTableDuration5Min}</td>"
        append HTML_PARAMS(separate_1) "<td colspan=\"2\" >[_getTextField $CHANNEL $param $ps($param) $prn]&nbsp;[_getUnit $param]&nbsp;[_getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]</td>"

        append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">"
          append HTML_PARAMS(separate_1) "jQuery(\"#separate_$CHANNEL\_$prn\").bind(\"blur\",function() {"
          append HTML_PARAMS(separate_1) "var value = this.value;"
          append HTML_PARAMS(separate_1) "this.value = Math.round(this.value / 5) * 5;"
          append HTML_PARAMS(separate_1) "ProofAndSetValue(this.id, this.id, [getMinValue $param], [getMaxValue $param], 1);"
          append HTML_PARAMS(separate_1) "});"
        append HTML_PARAMS(separate_1) "</script>"

      append HTML_PARAMS(separate_1) "</tr>"
    }

  append HTML_PARAMS(separate_1) "</table>"
  append HTML_PARAMS(separate_1) "<hr>"

  append HTML_PARAMS(separate_1) "<table class=\"ProfileTbl\">"
    # left
    incr prn
    set param BOOST_TIME_PERIOD
    array_clear options
    set i 0
    for {set val 0} {$val <= 30} {incr val 5} {
        set options($val) "$val min"
      incr i;
    }
    append HTML_PARAMS(separate_1) "<tr><td>\${stringTableBoostTimePeriod}</td>"
    append HTML_PARAMS(separate_1) "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]</td>"
    append HTML_PARAMS(separate_1) "</td>"

    # right
    incr prn
    set param BOOST_POSITION
    array_clear options
    set i 0
    for {set val 0} {$val <= 100} {incr val 10} {
        set options($val) "$val %"
      incr i;
    }
    append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">\${stringTableBoostPosition}</td>"
    append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]</td>"
    append HTML_PARAMS(separate_1) "</td>"

    append HTML_PARAMS(separate_1) "</tr>"

    # left
    incr prn
    set param DECALCIFICATION_WEEKDAY
    array_clear options
    set i 0
    set comment {
      foreach day {\${optionSat} \${optionSun} \${optionMon} \${optionTue} \${optionWed} \${optionThu} \${optionFri}} {
        set options($i) $day
        incr i
      }
    }
    append HTML_PARAMS(separate_1) "<tr><td>\${stringTableClimateControlRegDecalcDay}</td>"
    #append HTML_PARAMS(separate_1) "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]</td>"

    append HTML_PARAMS(separate_1) "<td>"
       append HTML_PARAMS(separate_1) "<select id='separate_$CHANNEL\_$prn' class='SUNDAY' name='DECALCIFICATION_WEEKDAY'>"
        append HTML_PARAMS(separate_1) "<option value='0'>\${optionSun}</option>"
        append HTML_PARAMS(separate_1) "<option value='1'>\${optionMon}</option>"
        append HTML_PARAMS(separate_1) "<option value='2'>\${optionTue}</option>"
        append HTML_PARAMS(separate_1) "<option value='3'>\${optionWed}</option>"
        append HTML_PARAMS(separate_1) "<option value='4'>\${optionThu}</option>"
        append HTML_PARAMS(separate_1) "<option value='5'>\${optionFri}</option>"
        append HTML_PARAMS(separate_1) "<option value='6'>\${optionSat}</option>"
      append HTML_PARAMS(separate_1) "</select>"

    append HTML_PARAMS(separate_1) "</td>"
    append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">jQuery('\#separate_$CHANNEL\_$prn\').val($ps($param));</script>"

    # right
    incr prn
    set param  DECALCIFICATION_TIME
    array_clear options
    for {set i 0} {$i <= 23} {incr i} {
      set hour $i
      if {$i < 10} {set hour "0$i"}
      set options([expr $i * 2]) "$hour:00"
    }
    append HTML_PARAMS(separate_1) "<td>\${stringTableClimateControlRegDecalcTime}</td>"
    append HTML_PARAMS(separate_1) "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]</td>"

    append HTML_PARAMS(separate_1) "</tr>"

    append HTML_PARAMS(separate_1) "<tr>"
      array_clear options
      for {set val 0} {$val <= 1} {set val [expr $val + 0.05]} {
        set options($val) "[expr int($val * 100)] %"
      }
      set param VALVE_ERROR_RUN_POSITION
      if { [info exists ps($param)] == 1  } {
        incr prn
        append HTML_PARAMS(separate_1) "<td>\${stringTableValveStateErrorPosition}</td>"
        append HTML_PARAMS(separate_1) "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]</td>"
      }

      set param VALVE_MAXIMUM_POSITION
      if { [info exists ps($param)] == 1  } {
        incr prn
        append HTML_PARAMS(separate_1) "<td>\${stringTableValveMaximumPosition}</td>"
        append HTML_PARAMS(separate_1) "<td>[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param]&nbsp;[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]</td>"
      }
    append HTML_PARAMS(separate_1) "</tr>"

    set param VALVE_OFFSET
    if { [info exists ps($param)] == 1  } {
      incr prn
      append HTML_PARAMS(separate_1) "<tr>"
        append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">\${stringTableValveOffset}</td>"
        append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\" colspan=\"2\" >[_getTextField $CHANNEL $param $ps($param) $prn]&nbsp; [_getUnit $param]&nbsp;[_getMinMaxValueDescr $param]&nbsp;[getHelpIcon $param $hlpBoxWidth [expr $hlpBoxHeight + 50]]</td>"
      append HTML_PARAMS(separate_1) "</tr>"
    }

    set param BOOST_AFTER_WINDOW_OPEN
    if { [info exists ps($param)] == 1  } {
      incr prn
      append HTML_PARAMS(separate_1) "<tr>"
        append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">\${stringTableBoostAfterWindowOpen}</td>"
        append HTML_PARAMS(separate_1) "<td name=\"expertParam\" class=\"hidden\">"
        append HTML_PARAMS(separate_1) "[getCheckBox $CHANNEL '$param' $ps($param) $prn]&nbsp;[getHelpIcon $param $hlpBoxWidth $hlpBoxHeight]"
        append HTML_PARAMS(separate_1) "</td>"
      append HTML_PARAMS(separate_1) "</tr>"
    }
  append HTML_PARAMS(separate_1) "</table>"

  if { (! [catch {set tmp $ps(CHANNEL_OPERATION_MODE)}]) || (! [catch {set tmp $ps(ACOUSTIC_ALARM_SIGNAL)}])  } {
    append HTML_PARAMS(separate_1) "<hr>"
    append HTML_PARAMS(separate_1) "<table class=\"ProfileTbl\">"
        set param CHANNEL_OPERATION_MODE
        if { [info exists ps($param)] == 1  } {
          incr prn
          array_clear options
          set options(0) "\${optionETRVNormalMode}"
          set options(1) "\${optionETRVSilentMode}"
          append HTML_PARAMS(separate_1) "<tr><td>\${lblMode}</td><td>"
          append HTML_PARAMS(separate_1) "[get_ComboBox options $param separate_$CHANNEL\_$prn ps $param onchange=\"alert(this.value,$chn)\"]&nbsp;[getHelpIcon $param $hlpBoxWidth [expr $hlpBoxHeight * 0.75]]"
          append HTML_PARAMS(separate_1) "</td></tr>"
        }

        set param ACOUSTIC_ALARM_SIGNAL
        if { [info exists ps($param)] == 1  } {
          incr prn
          append HTML_PARAMS(separate_1) "<tr>"
            append HTML_PARAMS(separate_1) "<td>\${lblAcousticAlarmSignal}</td>"
            append HTML_PARAMS(separate_1) "<td>"
            append HTML_PARAMS(separate_1) "[getCheckBox $CHANNEL '$param' $ps($param) $prn]&nbsp;[getHelpIcon $param $hlpBoxWidth [expr $hlpBoxHeight * 0.5]]"
            append HTML_PARAMS(separate_1) "</td>"
          append HTML_PARAMS(separate_1) "</tr>"
        }

    append HTML_PARAMS(separate_1) "</table>"
  }

  if {[session_is_expert]} {
    append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">"
      append HTML_PARAMS(separate_1) "jQuery(\"\[name='expertParam'\]\").show();"
    append HTML_PARAMS(separate_1) "</script>"
  } else {
    append HTML_PARAMS(separate_1) "<script type=\"text/javascript\">"
      append HTML_PARAMS(separate_1) "jQuery(\"\[name='expertParam'\]\").hide();"
    append HTML_PARAMS(separate_1) "</script>"
  }

}

constructor
