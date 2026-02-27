source once.tcl
sourceOnce common.tcl
sourceOnce session.tcl
sourceOnce file_io.tcl
load tclrpc.so
load tclrega.so

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

proc read_version { filename } {
  return [read_var $filename VERSION]
}

proc create_backup {} {
  set HOSTNAME [exec hostname]
  set system_version [read_version "/VERSION"]
  set iso8601_date [exec date -Iseconds]
  regexp {^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)([+-]\d+)$} $iso8601_date dummy year month day hour minute second zone
  set backupfile [set HOSTNAME]-$system_version-$year-$month-$day-$hour$minute.sbk
  # cleanup previous runs
  catch { exec rm -f /usr/local/tmp/last_backup.sbk }
  # call createBackup.sh to create consistent backup
  if { [catch {exec /bin/createBackup.sh /usr/local/tmp/last_backup.sbk 2>/dev/null} results] } {
    if { [lindex $::errorCode 0] == "CHILDSTATUS" } {
      set result [lindex $::errorCode 2]
    } else {
      # Some kind of unexpected failure
      set result 100
    }
  } else {
    set result 0
  }

  # cleanup last_backup.sbk file if createBackup.sh returned an error code
  if { $result != 0 } {
    catch { exec rm -f /usr/local/tmp/last_backup.sbk }
    puts ""
    puts "ERROR: creating backup returned unexpected error code $result"
    puts ""
    puts $results
  } else {
    puts "X-Sendfile: /usr/local/tmp/last_backup.sbk"
    puts "Content-Type: application/octet-stream"
    puts "Content-Disposition: attachment; filename=\"$backupfile\"\n"
  }
}
