##
# system.getPositionData
# Gibt die gespreicherten Positionsdaten Longitude und Latitude zurück
#
# Parameter:
#   keine
#
# Rückgabewert: [array]
#  Die einzelnen Elemente sind Zeichenketten, welche die Longitude, Latitude, TimeZone enthalten
#
##

proc read_var {filename varname} {
    set fd [open $filename r]
    set var ""
    if { $fd >=0 } {
        while { [gets $fd buf] >=0 } {
          if [regexp "^ *$varname *= *(.*)$" $buf dummy var] break
        }
      close $fd
    }
    return $var
}

set script {
  Write("['Longitude:"#system.Longitude()#"','Latitude:"#system.Latitude()#"'");
}

set posData [hmscript $script]

# get utcOffset and utcOffsetDST using clock command
# converts a %z value such as +0100, +0000 or -0330 to minutes
proc tz2offset {tstr} {
  if {![regexp {^([+-])([0-9]{2})([0-9]{2})$} $tstr -> sign hour min]} { return 0 }
  set time [expr {[scan $hour %d] * 60 + [scan $min %d]}]
  if {$sign eq "-"} { set time [expr {-$time}] }
  return $time
}
set offsetJan [tz2offset [clock format [clock scan "01 Jan"] -format "%z"]]
set offsetJul [tz2offset [clock format [clock scan "01 Jul"] -format "%z"]]
# daylight saving time has the larger offset, in the southern hemisphere it is in January
if {$offsetJan <= $offsetJul} {
  set utcOffset $offsetJan
  set utcOffsetDST $offsetJul
} else {
  set utcOffset $offsetJul
  set utcOffsetDST $offsetJan
}

# append the utcOffset and utcOffsetDST
append posData ",'utcOffset:$utcOffset','utcOffsetDST:$utcOffsetDST']"

jsonrpc_response $posData
