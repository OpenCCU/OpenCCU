proc get_info {script array_var} {
  upvar $array_var arr
  foreach key [array names arr] { unset arr($key) }
  set lang "de"
  catch {
    set fd [open "|$script info.$lang" r]

   while { ! [eof $fd] } {
    set line [gets $fd]
    if { [regexp {^([^:]+): (.*)$} $line dummy key value] } {
      if { [info exists arr($key)] } {append arr($key) "\n"}
      append arr($key) $value
    }
  }
    close $fd
  }

  catch {
   set fd [open "|$script info" r]
   while { ! [eof $fd] } {
    set line [gets $fd]
    if { [regexp {^([^:]+): (.*)$} $line dummy key value] } {
      if { [info exists arr($key)] } {append arr($key) "\n"}
      append arr($key) $value
    }
  }
    close $fd
  }
}

set file "/tmp/addon_updates.json"
set result false
if { [file exists $file] == 1 } {
  catch {
    set result "{ \"online\":"
    set fd [open $file r]
    while { ! [eof $fd] } {
      append result [gets $fd]
    }
    close $fd

    append result ", \"local\": \["

    set first 1
    set scripts ""
    catch { set scripts [glob /etc/config/rc.d/*] }
    foreach s $scripts {
      catch {
        if { ! [file executable $s] } continue
        array set sw_info ""
        get_info $s sw_info
        if { ![info exists sw_info(Name)] } continue
        if { [info exists sw_info(Version) ] } {
          if {1 != $first} then { append result "," } else { set first 0 }
          append result "\{\"name\":"
          append result "\"$sw_info(Name)\","
          append result "\"localversion\":"
          append result "\"$sw_info(Version)\""
          append result "\}"
        }
      }
    }
    append result "\]}"
  }
}
jsonrpc_response $result
#puts "$result"
