source once.tcl
sourceOnce common.tcl
sourceOnce session.tcl
sourceOnce file_io.tcl
load tclrpc.so
load tclrega.so

proc create_backup {} {
  set HOSTNAME [exec hostname]
  set iso8601_date [exec date -Iseconds]
  regexp {^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)([+-].+)$} $iso8601_date dummy year month day hour minute second zone
  #save DOM
  rega system.Save()
  cd /
  if {[getProduct] < 3 } {
    catch { exec tar czf /tmp/usr_local.tar.gz usr/local }
  } else {
    catch { exec tar --owner=root --group=root --exclude=usr/local/tmp --exclude=/usr/local/.firmwareUpdate --exclude=usr/local/lost+found --exclude=usr/local/eQ-3-Backup --exclude-tag=.nobackup --one-file-system --ignore-failed-read -czf /tmp/usr_local.tar.gz usr/local }
  }
  
  cd /tmp/
  #sign the configuration with the current key
  exec crypttool -s -t 1 <usr_local.tar.gz >signature
  #store the current key index
  exec crypttool -g -t 1 >key_index
  file copy -force /boot/VERSION firmware_version
  set fd [open "|tar c usr_local.tar.gz signature firmware_version key_index"]
  catch {fconfigure $fd -translation binary}
  catch {fconfigure $fd -encoding binary}
  puts "Content-Type:application/x-download"
  puts "Content-Disposition:attachment;filename=[set HOSTNAME]-$year-$month-$day.sbk\n"
  catch {fconfigure stdout -translation binary}
  catch {fconfigure stdout -encoding binary}
  while { ! [eof $fd]} {
    puts -nonewline [read $fd 65536]
  }
  close $fd
  file delete -force /tmp/usr_local.tar.gz /tmp/firmware_version /tmp/signature
}