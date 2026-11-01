##
# Interface.getDutyCycle
# Gibt ein JSON array mit den DutyCycle Werten aller interfaces zurueck.
#
# Parameter: 
#   keine
#
# Rückgabewert: [array], null ohne /tmp/dutycycle.json
#   Jedes Element ist ein Objekt mit den folgenden Elementen:
#   address:      [string] Seriennummer
#   name:         [string] Name des Gateways ("CCU" für die CCU)
#   sysVar:       [string] Name der Systemvariable
#   dutyCycle:    [string] Duty Cycle (0 - 100, -1 wenn nicht verbunden)
#   carrierSense: [string] Carrier Sense (0 - 100, -1 wenn nicht verfügbar)
#   type:         [string] Typ des interfaces ("CCU2", "HMIP-HAP" oder
#                          der Typ des LAN-Gateways)
##

set result ""

if { [file exists /tmp/dutycycle.json] } {
  set file [open /tmp/dutycycle.json r]
  set result [gets $file]
  close $file
}

jsonrpc_response "$result"
