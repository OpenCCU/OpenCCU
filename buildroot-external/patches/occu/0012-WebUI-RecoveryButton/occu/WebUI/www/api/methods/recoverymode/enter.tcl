##
# RecoveryMode.enter
# Startet die HomeMatic Zentrale im Recovery Modus
#
# Parameter:
#   paasword: [string] Passwort für den Recovery Modus
#
# Rückgabewert: [bool]
#   true
##

set FLAG_FILE "/usr/local/.recoveryMode"

# Flag-Datei erzeugen
set fd [open $FLAG_FILE w]
puts $fd 1
close $fd

# Neustart
rega system.Save()
exec /sbin/reboot -d 2 2>/dev/null >/dev/null &

jsonrpc_response true
