#!/bin/tclsh

if { [catch {
source /lib/libfirewall.tcl

Firewall_setLoggingEnabled 1
Firewall_loadConfiguration
Firewall_configureFirewall

catch {exec -- logger -t firewall -p user.info configuration set}

} errMsg] } then {
	
  catch {exec -- logger -t firewall -p user.err '$errMsg'}
  error $errMsg
}
