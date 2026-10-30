#!/bin/tclsh


puts "<script type=\"text/javascript\">load_JSFunc('/config/easymodes/MASTER_LANG/HmIPWeeklyDeviceProgram.js');load_JSFunc('/config/easymodes/js/HmIPWeeklyProgram.js');</script>"

proc getHmIPWeeklyProgram {address chn p descr devType {extraparam ""}} {

  upvar $p ps
  upvar $descr psDescr
  upvar prn prn

  set html ""

  set specialParam "--"

  set objPS "\{"
  foreach val [array names ps] {
    #puts "$val: $ps($val)<br/>"
    append objPS "'$val': '$ps($val)',"
  }
  append objPS "'end' : ''"
  append objPS "\}"

  set objPSDescr "\{"

    if {[string compare $devType 'blind'] != 0} {
      array_clear param_descr
      array set param_descr $psDescr(01_WP_DURATION_FACTOR)
      append objPSDescr "'DURATION_FACTOR_MIN' : '$param_descr(MIN)',"
      append objPSDescr "'DURATION_FACTOR_MAX' : '$param_descr(MAX)',"
    }

    if {[string compare $devType 'dimmer'] == 0} {
      array_clear param_descr
      array set param_descr $psDescr(01_WP_RAMP_TIME_FACTOR)
      append objPSDescr "'RAMP_TIME_FACTOR_MIN' : '$param_descr(MIN)',"
      append objPSDescr "'RAMP_TIME_FACTOR_MAX' : '$param_descr(MAX)',"
    }

    if {[string equal $extraparam 'hideAstroOffset'] != 1} {
      array_clear param_descr
      array set param_descr $psDescr(01_WP_ASTRO_OFFSET)
      append objPSDescr "'ASTRO_OFFSET_MIN' : '$param_descr(MIN)',"
      append objPSDescr "'ASTRO_OFFSET_MAX' : '$param_descr(MAX)',"
      append objPSDescr "'ASTRO_OFFSET_UNIT' : 'min',"
    }

    append objPSDescr "'end' : ''"

  append objPSDescr "\}"

  if {[string equal $extraparam 'showOnlyBackLightingReceiver'] == 1} {
    set specialParam "showOnlyBackLightingReceiver"
  }

  append html "<div id=\"weeklyProgram_$chn\"></div>"

  append html "<script type=\"text/javascript\">"
    if {[string equal $extraparam dali] == 1} {
      # global var within the weekly program for the dali targetchannels
      append html "if (typeof daliTargetChannels == 'undefined') {daliTargetChannels = null;}"
    }

    append html "window.setTimeout(function() {"
      append html "weeklyProgram = new HmIPWeeklyProgram('$address', $objPS, $objPSDescr, [session_is_expert], '[getDevFirmware]', '$specialParam');"
    append html "},100)"
  append html "</script>"

  return $html
}

