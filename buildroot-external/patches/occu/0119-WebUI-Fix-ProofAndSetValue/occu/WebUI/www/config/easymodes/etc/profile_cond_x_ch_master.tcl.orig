proc getDescription {param} {
  global MEASUREMENT_TYPE

  set result $param

   if {$param == "upperVal_$MEASUREMENT_TYPE"} {
        set param "UPPER_VAL"
   }

   if {$param == "lowerVal_$MEASUREMENT_TYPE"} {
        set param "LOWER_VAL"
   }

    if {$param == "COND_TX_THRESHOLD_HI_$MEASUREMENT_TYPE"} {
         set param "COND_TX_THRESHOLD_HI"
    }

    if {$param == "COND_TX_THRESHOLD_LO_$MEASUREMENT_TYPE"} {
         set param "COND_TX_THRESHOLD_LO"
    }

  set desc(COND_TX_CYCLIC_ABOVE) "stringTableCondTxCyclicAbove"
  set desc(COND_TX_CYCLIC_BELOW) "stringTableCondTxCyclicBelow"
  set desc(COND_TX_DECISION_ABOVE) "stringTableCondTxDecisionAbove"
  set desc(COND_TX_DECISION_BELOW) "stringTableCondTxDecisionBelow"
  set desc(COND_TX_FALLING) "stringTableCondTxFalling"
  set desc(COND_TX_RISING) "stringTableCondTxRising"
  set desc(COND_TX_THRESHOLD_HI) "stringTableCondThresholdHi"
  set desc(COND_TX_THRESHOLD_LO) "stringTableCondThresholdLo"
  set desc(UPPER_VAL) "stringTableUpperVal"
  set desc(LOWER_VAL) "stringTableLowerVal"
  set desc(LED_ONTIME) "stringTableLEDOntime"
  set desc(TRANSMIT_TRY_MAX) "stringTableTransmitTryMax"

  if {[catch {set result $desc($param)}]} {
   return $result
  }
  return $result
}

proc getThreshold {} {
  global ps MEASUREMENT_TYPE
  upvar ps psValues
  #return  [expr $psValues(COND_TX_THRESHOLD_HI_$MEASUREMENT_TYPE) - $psValues(COND_TX_THRESHOLD_LO_$MEASUREMENT_TYPE)]
}

# This wll be called by the function getUnit()
proc checkParam {param} {
  global MEASUREMENT_TYPE
  if {$param == "upperVal_$MEASUREMENT_TYPE" || $param == "lowerVal_$MEASUREMENT_TYPE"} {
    # Unit should be 'W' - COND_TX_THRESHOLD_LO_$MEASUREMENT_TYPE has the same unit
    return "COND_TX_THRESHOLD_HI_$MEASUREMENT_TYPE"
  }
  return $param
}

proc getUnit {param} {
  global psDescr
  array_clear param_descr
  set param [checkParam $param]
  if {![catch {array set param_descr $psDescr($param)}]} {
    set unit $param_descr(UNIT)
    return "$unit"
  }
  return ""
}

proc getMinMaxValueDescr {param} {
  global psDescr
  array_clear param_descr

  if {[string first "lowerVal" $param 0] != -1} {
    set chType [lindex [split $param _] 1]
    set param "COND_TX_THRESHOLD_LO_$chType"
  } elseif {[string first "upperVal" $param 0] != -1} {
    set chType [lindex [split $param _] 1]
    set param "COND_TX_THRESHOLD_HI_$chType"
  }

	if {![catch {array set param_descr $psDescr($param)}]} {
    set min $param_descr(MIN)
    set max $param_descr(MAX)

    # Limit float to 2 decimal places
         if {[llength [split $min "."]] == 2} {
           set min [format {%1.2f} $min]
           set max [format {%1.2f} $max]
         }
    return "($min - $max)"
  }
  return ""
}

proc getMinValue {param} {
  global psDescr
  set min ""
  array_clear param_descr
	if {![catch {array set param_descr $psDescr($param)}]} {
    set min $param_descr(MIN)
  }
  return $min
}

proc getMaxValue {param} {
  global psDescr
  set max ""
  array_clear param_descr
	if {![catch {array set param_descr $psDescr($param)}]} {
    set max $param_descr(MAX)
  }
  return $max
}

proc trimParam {param} {
  set s [string trimleft $param ']
  set s [string trimright $s ']
  return $s
}

proc getParamName {param} {
  set arrParameter [split $param _]
  if {[llength $arrParameter] == 2 && (([lindex $arrParameter 0] == "lowerVal") || ([lindex $arrParameter 0] == "upperVal"))} {
    set result [lindex $arrParameter 0]
  } else {
    set result $param
  }
  return $result
}

proc getCheckBox {param value prn special_input_id class} {
  set checked ""
  if { $value } then { set checked "checked=\"checked\"" }
  set param [trimParam $param]
  set elemId 'separate_$special_input_id\_$prn'
  set s "<tr>"
  append s "<td class='$class'>\${[getDescription $param]}</td>"
  append s "<td class='$class'><input id=$elemId type='checkbox' $checked value='dummy' name=$param></td>"
  append s "</tr>"
  return $s
}

proc getTextField {param value prn special_input_id class} {
  global psDescr
	upvar psDescr descr
  set param [trimParam $param]
  set paramName [getParamName $param]
  set elemId 'separate_$special_input_id\_$prn'

  # Limit float to 2 decimal places
  if {[llength [split $value "."]] == 2} {
    set value [format {%1.2f} $value]
  }
  set s "<tr>"
  set style ''
  if {([string first "COND_TX_THRESHOLD_" $param 0] != -1)} {
    #set style 'width:150px'
  }
  
  append s "<td class='$class' style=$style>\${[getDescription $param]}</td>"

   if {[string first "COND_TX_THRESHOLD_HI" $param 0] != -1  || [string first "COND_TX_THRESHOLD_LO" $param 0] != -1 } {
    append s "<td class='$class'><input id=$elemId type=\"text\" size=\"5\" value=$value name=$param onblur='setVal(this)' >&nbsp;[getMinMaxValueDescr $param]</td>"
   } else {
    if {[string first "lowerVal_" $param 0] != -1 || [string first "upperVal_" $param 0] != -1} {
      append s "<td class='$class'><input id=$elemId type=\"text\" size=\"5\" value=$value name=$param onblur='setVal(this)'>&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    } else {
      append s "<td class='$class'><input id=$elemId type=\"text\" size=\"5\" value=$value name=$param onblur='ProofAndSetValue(this.id, this.id, [getMinValue $param], [getMaxValue $param], 1);'>&nbsp;[getUnit $param]&nbsp;[getMinMaxValueDescr $param]</td>"
    }
  }
  append s "</tr>"
  return $s
}