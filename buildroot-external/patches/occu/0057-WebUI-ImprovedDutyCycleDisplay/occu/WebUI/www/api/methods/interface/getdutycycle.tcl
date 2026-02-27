##
# Interface.getDutyCycle
# Gibt ein JSON array mit den DutyCycle Werten aller interfaces zurueck.
#
# Parameter: 
#   keine
#
# Rückgabewert: [array]
#   Jedes Element ist ein Objekt mit den folgenden Elementen:
#   sysvar:      [string]  Name der Systemvariable
#   address:     [string]  Seriennummer
#   dutyCycle:   [integer] Duty Cycle (0 - 100)
#   type:        [string]  Typ ("CCU2") des interfaces
##

set result ""

if { [file exists /tmp/dutycycle.json] } {
  set file [open /tmp/dutycycle.json r]
  set result [gets $file]
  close $file
}

jsonrpc_response "$result"
