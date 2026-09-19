##
# hmscript.tcl
# Ausführen von HomeMatic Script.
#
# Autor: Falk Werner
##

package require HomeMatic

proc hmscript {script {p_args -}} {
  set _script_ ""
  
  if { "-" != $p_args } then {
    upvar $p_args args
    
    foreach name [array names args] {
      set varname [hmscript_sanitizeIdentifier $name]
      append _script_ "var $varname = \"[hmscript_escapeString $args($name)]\";\n"
    }
  }
  
  append _script_ $script
 
  return [hmscript_run _script_]  
}

##
# FÃ¼hrt ein HomeMatic Script aus und liefert das Ergebnis
##
proc hmscript_run { p_script } {
  upvar $p_script script
  
  if { ![catch {array set result [rega_script $script]}] } then {
    return $result(STDOUT)
  }
  return ""
}

proc hmscript_runInline { script } {
  if { ![catch {array set result [rega_script $script]}] } then {
    return $result(STDOUT)
  }
  return ""    
}

proc hmscript_runFromFile { filename {p_args -}} {
	set script ""
	
	if { "-" != $p_args } then {
		upvar $p_args args
    
		foreach name [array names args] {
			set varname [hmscript_sanitizeIdentifier $name]
			append script "var $varname = \"[hmscript_escapeString $args($name)]\";\n"
		}
	}
  append script [file_load $filename]
  
  return [hmscript_run script]
}

proc hmscript_escapeString { str } {
  return [string map {
    "\\" "\\\\"
    "\'" "\\\'"
    "\"" "\\\""
    "\n" "\\n"
    "\r" "\\r"
    "\t" "\\t"
  } $str]
}

proc hmscript_assertFloat { value } {
  if { ![string is double -strict $value] } then {
    error "Value '$value' is not a valid float"
  }
}

proc hmscript_assertInteger { value } {
  if { ![string is integer -strict $value] } then {
    error "Value '$value' is not a valid integer"
  }
}

proc hmscript_assertBoolean { value } {
  if { ![string is boolean -strict $value] } then {
    error "Value '$value' is not a valid boolean"
  }
}

# Strips characters not matched by sanitizeIdentifiers regex and fixes an invalid leading character.
proc hmscript_sanitizeIdentifier { name } {
  set replacements [regsub -all {[^A-Za-z0-9_]} $name {} newname ]
  if { ![regexp {^[A-Za-z_]} $newname] } then {
    set newname "_$newname"
  }
  return [string range $newname 0 63]
}
