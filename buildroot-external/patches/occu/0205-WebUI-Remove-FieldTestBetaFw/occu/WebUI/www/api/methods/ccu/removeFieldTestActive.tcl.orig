##
# CCU.removeFieldTestActive
# Entfernt die Datei /etc/config/fieldTestActive
#
# Parameter:
# keine
#
# Rückgabewert: result
#                 false - error
#                 true - ok
##

set file "/etc/config/fieldTestActive"
set result false

catch {exec rm $file} e

if {[string trim $e] == ""} {
  set result true
}

jsonrpc_response $result
