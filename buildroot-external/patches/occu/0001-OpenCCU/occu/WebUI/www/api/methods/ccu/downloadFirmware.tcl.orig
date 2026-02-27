##
# CCU.downloadFirmware
# Laedt die neuste verfuegbare CCU Firmware herunter.
#
# Parameter:
#  
#
# Rueckgabewert: True wenn eine Firmware erfolgreich herunterladen wurde, ansonsten False.
##

set result [catch {exec cat /VERSION | grep VERSION | sed s/VERSION=//} version]
set result [catch {exec cat /VERSION | grep VERSION | sed s/VERSION=// | sed s/\\..*//} major]
if { [string compare $major "3"] == 0 } {
  set result [catch {exec cat /var/board_serial} serial]
  set url "https://ccu3-update.homematic.com/firmware/download?cmd=download&version=$version&serial=$serial&lang=de&product=HM-CCU3"
} elseif { [string compare $major "2"] == 0 } {
  set result [catch {exec cat /sys/module/plat_eq3ccu2/parameters/board_serial} serial]
  set url "https://update.homematic.com/firmware/download?cmd=download&version=$version&serial=$serial&lang=de&product=HM-CCU2"
} else {
  set result [catch {exec echo "nomatch" >> /tmp/test} msg]
  jsonrpc_response false
}

set result [catch {exec wget -q --https-only -O /tmp/fup.tgz $url} error]
if { $result != 0 } {
  exec echo $error > /tmp/dwnld.error
}

if { $result == 0 } {
  jsonrpc_response true
} else {
  jsonrpc_response false
}
