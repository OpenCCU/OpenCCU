#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
array set TYPE_MAP {
    "BOOL" "bool"
    "ENUM" "int"
    "INTEGER" "int"
    "FLOAT" "double"
    "STRING" "string"
    "ACTION" "bool"
}

#source cgi.tcl
loadOnce tclrpc.so

proc decr {x {cnt 1}} { 
	upvar $x xx
	set xx [expr $xx - $cnt]
}
proc max {x y} { expr { $x > $y ? $x : $y } }
proc min {x y} { expr { $x > $y ? $y : $x } }

proc cgi_cgi {args} {return $args}

proc in {list element} {expr [lsearch -exact $list $element] >= 0}

proc array_clear {name} {
    upvar $name arr
    foreach key [array names arr] {
		unset arr($key)
    }
}

proc array_copy {src_name dst_name} {

	global $src_name $dst_name
    array_clear $dst_name
	array set $dst_name [array get $src_name]
}

#Liest eine Datei ein mit dem Format
#Key=Value
#Key=Value
#...
#<.
#und speichert die Werte in einem übergebenen Array ab.
proc read_assignment_file {filename value_array} {

    upvar $value_array arr
	
	set ret -1

	if { ! [catch {open $filename RDONLY} f] } then {

		while {1} {

			gets $f zeile

			#                 Weiche EOF-Marke
			if { [eof $f] || [string equal $zeile "<."] } break

			set data [split $zeile =]

			if {$zeile == "" || [lindex $data 0] == ""} then {continue}

			set arr([lindex $data 0]) [lindex $data 1]
		}
		
		close $f
	}
	
	return $ret
}

#Schreibt ein Array in eine Datei. Format, siehe read_assignment_file
proc write_assignment_file {filename value_array {soft_eof 1}} {

    upvar $value_array arr

	set ret -1
	
	if { ! [catch {open $filename w} f] } then {
	
		foreach key [array names arr] {
			puts $f "$key=$arr($key)"
		}

		#Weiche EOF-Marke
		if {$soft_eof} then { puts $f "<." }

		close $f

		set ret 1
	}

	return $ret
}

#Abgewandelt von http://wiki.tcl.tk/1017
#proc verbose_eval
#15.02.2007
proc eval_script {script} {

	set cmd ""
	set ret -1

	foreach line [split $script \n] {

		if {$line == ""} {continue}
		append cmd $line\n
		
		if { [info complete $cmd] } {
			#puts -nonewline $cmd
			set ret [uplevel 1 $cmd]
			set cmd ""
		}
	}

	return $ret
}

proc BitsSet {b_testee b_set} {

	if {$b_testee == "" || $b_set == "" || $b_testee == 0 || $b_set == 0} then { return 0 }

	return [expr [expr $b_set & $b_testee] == $b_testee]
}

proc putimage {img_path} {

	set in [open $img_path]

	catch {fconfigure stdout -translation binary}
	catch {fconfigure stdout -encoding binary}
	catch {fconfigure $in    -translation binary}
	catch {fconfigure $in    -encoding binary}

	puts -nonewline stdout [read $in]
	
	close $in
}

proc uniq {liste} {

	set u_list ""
	set last_e ""
	
	foreach e [lsort $liste] {
		if {$e != $last_e} then {
			lappend u_list $e
			set last_e $e
		}
	}

	return $u_list
}

proc read_var { filename varname} {
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


proc get_version { } {
    #return [read_var /boot/VERSION VERSION]
    return [read_var /VERSION VERSION]
}

proc get_CoProVersion {} {
  set cfgFile "/var/hm_mode"
  set unknownVersion "0.0.0"
  set result $unknownVersion
  if {[file exists $cfgFile]} {
    catch {set result [string trim [read_var /var/hm_mode HM_HMIP_VERSION] "'"]}
  }

  if {$result == ""} {
    set result $unknownVersion
  }
  return $result
}

proc showHmIPWired {} {
  set result false

  if {[getProduct] >= 3} {
    set coProVer [get_CoProVersion]
    set coProFwMajor [expr [lindex [split $coProVer .] 0] * 1]
    set coProFwMinor [expr [lindex [split $coProVer .] 1] * 1]
    if {($coProFwMajor > 3) || (($coProFwMajor == 3) && ($coProFwMinor >= 5))} {
      set result true
    }
  }
  return $result
}

# Prüft, ob es sich um die alte oder neue CCU handelt
# Ursprünglich das Verzeichnis webinterface ein svn external. Daher musste im
# Sourcecode unterschieden. Nun gibt es den svn external nicht mehr.
proc isOldCCU {} {
  set platform "0"
  return $platform
}

proc get_bat_level {} {
    global PFMD_URL
    if {[isOldCCU]} {
      set level 0
      catch {set level [xmlrpc $PFMD_URL getValue "System:1" "BAT_LEVEL"]}
      return [expr int($level * 100)]
    }
   # new CCU2 has no battery
   return 100;
}

proc getProduct {} {
  set product 3
  catch {
    set product [lindex [split [get_version] .] 0]
  }
  return "[expr $product*1]"
}

