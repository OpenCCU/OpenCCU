##
# rega.tcl
# Zuriff auf die Logikschicht der HomeMatic Zentrale (ise ReGa).
#
# (c) 2009
# eQ-3 Entwicklung GmbH
# Falk Werner
##


##
#
##
proc rega_escape {value} {
  return [string map {
    "\'"  "\\\'"
    "\""  "\\\""
    "\f"  "\\\f"
    "\t"  "\\\t"
    "\r"  "\\\r"
    "\n"  "\\\n"
  } $value]
}

##
# rega_exec
# Führt ein ReGa-Script (HomeMatic Script / ise Script) aus und liefert als
# Ergebnis die Standardausgabe. Falls Fehler aufgetreten sind, wird die leere
# Zeichenkette zurückgegeben.
##
proc rega_exec {script} {
  set result ""
  catch {
    array set response [rega_script $script]
    set result $response(STDOUT)
  }
  
  return $result
}
