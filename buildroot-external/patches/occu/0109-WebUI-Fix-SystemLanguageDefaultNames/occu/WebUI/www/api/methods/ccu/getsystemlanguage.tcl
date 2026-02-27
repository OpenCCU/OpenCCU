##
# CCU.getSystemLanguage
# Gibt die momentan eingestellte Systemsprache der CCU aus der
# /etc/config/systemLanguage Datei zurueck.
#
# Parameter:
#  keine
#
# Rückgabewert: [string]
#  Kuerzel der Systemsprache (de, en) oder none
##

set lang "none"
if {[catch {set fp [open /etc/config/systemLanguage r]}] == 0} {
  if { $fp >= 0 } {
    set lang [string trim [read $fp]]
    close $fp
  }
}

jsonrpc_response [json_toString $lang]
