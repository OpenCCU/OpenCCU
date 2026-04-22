#!/bin/tclsh

##
# @file  setfirewall.tcl
# @brief Firewall-Konfiguration
##

##
# @const Firewall_CONFIG_FILE
# Konfigurationsdatei für die Firewall
##
set Firewall_CONFIG_FILE /etc/config/firewall.conf

##
# @const Firewall_SERVICES
# Enthält die verfügbaren Services und deren TCP-Ports
#
# Jeder Service kann als assoziatives Array mit den folgenden
# Elementen aufgefasst werden:
#   PORTS : Liste der TCP-Portnummern des Services
#   ACCESS: Zugriffsrechte für den Service:
#           full      : Vollzugriff; keine Einschränkungen
#           restricted: Eingeschränkter Zugriff
#           none      : Kein Zugriff möglich
##
array set Firewall_SERVICES {}
set Firewall_SERVICES(XMLRPC) [list PORTS [list 2000 2001 2002 2010 9292 42000 42001 42010 49292] ACCESS none]
set Firewall_SERVICES(REGA)   [list PORTS [list 8181 1999 48181 41999] ACCESS none]
set Firewall_SERVICES(NEOSERVER) [list PORTS [list 8088 9099 1901 1902 5987 10000 48899 49880] ACCESS none] 
set Firewall_SERVICES(SNMP) [list PORTS [list 161] ACCESS none] 

##
# @const Firewall_USER_PORTS
# Liste mit User-defined ports.
##
set Firewall_USER_PORTS {}

##
# @const Firewall_MODE_RESTRICTIVE
# Firewall Modus RESTRICTIVE. INPUT Policy DROP. Last Rule REJECTs all.
##
set Firewall_MODE_RESTRICTIVE "RESTRICTIVE"

## @const Firewall_MODE_MOST_OPEN
# Firewall Modus MOST_OPEN (Kompatibilitätsmodus). INPUT Policy ACCEPT
##
set Firewall_MODE_MOST_OPEN "MOST_OPEN"

##
# @var Firewall_MODE
# Firewall Modus. Werte duerfen RESTRICTIVE oder MOST_OPEN annehmen.
##
set Firewall_MODE $Firewall_MODE_RESTRICTIVE

##
# @var Firewall_LOG_ENABLED
# Aktiviert Logging über syslog, default ist 'aus'.
##
set Firewall_LOG_ENABLED 1

##
# @var Firewall_IPS
# IP-Adressen für den eingeschränkten Zugriff
#
# Beinhaltet eine Liste der IP-Adressen oder Addressgruppen, denen bei
# eingeschränktem Zugriff eine Verwendung des jeweiligen Serices noch erlaubt
# ist.
##
set Firewall_IPS [list 192.168.0.1 192.168.0.0/16 fc00::/7 fe80::/10]

#------------------------------------------------------------------------------

##
# @fn Firewall_setLoggingEnabled
# Aktiviert Logging über Syslog (1)
# oder deaktiviert Logging über Syslog (0)
# 
##
proc Firewall_setLoggingEnabled { enabled } {
  global Firewall_LOG_ENABLED
  if { $enabled == 1 } {
    set Firewall_LOG_ENABLED 1
  } else {
    set Firewall_LOG_ENABLED 0
  }
}

##
# @fn loadConfiguration
# Lädt die Firwall-Einstellunfen aus der Konfigurationsdatei
##
proc Firewall_loadConfiguration { } {
  global Firewall_CONFIG_FILE Firewall_SERVICES Firewall_IPS Firewall_MODE Firewall_USER_PORTS
  
  array set config  {}
  array set section {}
  set sectionName   {}
  set migrationPerformed 0
  
  if { ![catch { set fd [open $Firewall_CONFIG_FILE r] }] } then {
    catch {
      while { ![eof $fd] } {

        set line [string trimleft [gets $fd]]

        if { "\#" != [string index $line 0] } then {

          if { [regexp {\[([^\]]+)\]} $line dummy newSectionName] } then {
          set config($sectionName) [array get section]
            array_clear section
            set sectionName $newSectionName
          }
  
          if { [regexp {([^=]+)=(.+)} $line dummy name value] } then {
            set section([string trim $name]) [string trim $value]
          }

        }      
    
      }
      set config($sectionName) [array get section]
      array_clear section
    }
  
    close $fd
  }
  
  foreach sectionName [array names config] {

    if { {} != $sectionName } then {
      array set section $config($sectionName)
      set ports  [array_getValue section Ports]
      set id     [array_getValue section Id]

      # Hinzufuegen von Ports, die oben definiert, jedoch nicht in der Config Datei stehen.
      # (Migration etc.)
      #puts "Search in $ports"
      set service $Firewall_SERVICES($id)
      set defaultServicePorts [lindex $service 1]
      foreach p $defaultServicePorts {
        #puts "Searching for $p"
        if { [lsearch -exact $ports "$p"] == -1 } { 
          #puts "$p not in list appending"  
          lappend ports $p
          #puts $ports
          set migrationPerformed 1
        } 
      }
      #end of migration

      set access [array_getValue section Access]
      set Firewall_SERVICES($id) [list PORTS [lsort -integer $ports] ACCESS $access]
      
      array_clear section
    }
  }

  if { [info exists config()] } then {
    array set emptySection $config()
    set Firewall_IPS [array_getValue emptySection IPs]
    
    set aModes [array_getValue emptySection MODE]
    if { [string equal $aModes ""] == 0 } {
      set Firewall_MODE $aModes
    } 

    set userPorts [array_getValue emptySection USERPORTS]
    if { [string equal $userPorts ""] == 0 } {
      set Firewall_USER_PORTS $userPorts
    } 
  }

  if { $migrationPerformed == 1 } {
    Firewall_saveConfiguration
  }
}

##
# @fn saveConfiguration
# Speichert die Firewall-Einstellungen in der Konfigurationsdatei
##
proc Firewall_saveConfiguration {} {
  global Firewall_CONFIG_FILE Firewall_SERVICES Firewall_IPS Firewall_MODE Firewall_USER_PORTS
  
  set fd [open $Firewall_CONFIG_FILE w]
  catch {
  
    puts $fd "# Firewall Configuration file"
    puts $fd "#   created [clock format [clock seconds]]"
    puts $fd "# This file was automatically gernerated"
    puts $fd "# Please do not change anything"
    puts $fd ""
    
    puts $fd "MODE = $Firewall_MODE"
    puts $fd ""
    
    puts $fd "IPs = $Firewall_IPS"
    puts $fd ""
    
    if { [llength $Firewall_USER_PORTS] > 0 } {
      puts -nonewline $fd "USERPORTS ="
      foreach port $Firewall_USER_PORTS {
        puts -nonewline $fd " $port"
      }
    }
    puts $fd "\n"
    
    foreach serviceName [array names Firewall_SERVICES] {
      array set service $Firewall_SERVICES($serviceName)
      puts $fd "\[SERVICE $serviceName\]"
      puts $fd "Id = $serviceName"
      puts $fd "Ports = $service(PORTS)"
      puts $fd "Access = $service(ACCESS)"
      puts $fd ""
    }
    
  }

  close $fd
}

##
# @fn setFirewallMode
# Setzt die Firewall Modus Einstellung.
# Die Firewall kann im Modus "MOST_OPEN" (auch Kompatibilitätsmodus) oder im Modus "RESTRICTIVE" betrieben werden.
##
proc Firewall_setMode { modeName } {
  global Firewall_MODE Firewall_MODE_RESTRICTIVE Firewall_MODE_MOST_OPEN

  if {[string equal $modeName $Firewall_MODE_RESTRICTIVE] == 1} {
    set Firewall_MODE $Firewall_MODE_RESTRICTIVE
    #Firewall_saveConfiguration
  } elseif {[string equal $modeName $Firewall_MODE_MOST_OPEN] == 1} {
    set Firewall_MODE $Firewall_MODE_MOST_OPEN
    #Firewall_saveConfiguration
  } else {
    puts "Firewall_setMode: Unsupported mode."
  }
}

##
# @fn Firewall_set_service_access
# Setzt den ACCESS Modus 'accessLevel' (none/restricted/full) des Dienstes 'service'
# innerhalb der Liste Firewall_SERVICES
##
proc Firewall_set_service_access { service accessLevel } {
  global Firewall_SERVICES
  set serviceList [array get Firewall_SERVICES $service]
  if { [llength serviceList ] > 0 && [ lindex serviceList 0  ] != ""  } {
    #write new value
    set accessIndex [lsearch $Firewall_SERVICES($service) ACCESS]
    set valueIndex [ expr { int($accessIndex + 1) } ]
    set Firewall_SERVICES($service) [lreplace $Firewall_SERVICES($service) $valueIndex $valueIndex $accessLevel]
    #puts "New value is"
    #puts $Firewall_SERVICES($service)
  } else {
    puts "No such service $level"
    return
  }
}

##
# @fn Firewall_get_service_access
# Gibt den ACCESS Modus (none/restricted/full) des Dienstes 'service'
# innerhalb der Liste Firewall_SERVICES zurück
##
proc Firewall_get_service_access { service  } {
  global Firewall_SERVICES
  
  set serviceList [array get Firewall_SERVICES $service]
  if { [llength serviceList ] > 0 && [ lindex serviceList 0  ] != ""  } {
    #read value and return it
    set accessIndex [lsearch $Firewall_SERVICES($service) ACCESS]
    set valueIndex [ expr { int($accessIndex + 1) } ]
    return [lindex $Firewall_SERVICES($service) $valueIndex ]
  } else {
    puts "No such service $level"
    return ""
  }
}

namespace eval FirewallInternal {}

##
# @fn sshEnabled
# Prüft, ob SSH aktiviert ist
##
proc FirewallInternal::sshEnabled {} {
  set fx [ file exists "/etc/config/sshEnabled" ]
  return $fx
}

##
# @fn sshEnabled
# Prüft, ob ip6tables vorhanden ist und ausgeführt werden kann
##
proc FirewallInternal::ip6Supported {} {
  set a [ file exists "/proc/net/if_inet6" ]
  set b [ expr [catch { exec which ip6tables } ] == 0 ? 1 : 0 ]
  set r [ expr { $a && $b } ]
  return $r
}

##
# @fn configureFirewallMostOpen
# Gibt 1 zurueck, wenn es sich um einen UDP Port handelt, ansonsten 0.
##
proc FirewallInternal::Firewall_isUdpPort { port } {
  switch $port {
    161 {
      return 1
    }
    1901 {
      return 1
    }
    1902 {
      return 1
    }
    5987 {
      return 1
    }
    10000 {
      return 1
    }
    48899 {
      return 1
    }
    49880 {
      return 1
    }
    default {
      return 0
    }
  }
} 

##
# @fn configureFirewall
# Konfiguriert die Firewall
##
proc Firewall_configureFirewall { } {
  global Firewall_SERVICES Firewall_IPS Firewall_MODE Firewall_MODE_RESTRICTIVE Firewall_MODE_MOST_OPEN

  if { [string equal $Firewall_MODE $Firewall_MODE_MOST_OPEN] == 1 } {
    FirewallInternal::Firewall_configureFirewallMostOpen
  } else {
    FirewallInternal::Firewall_configureFirewallRestrictive
  }
}

##
# @fn configureFirewallMostOpen
# Konfiguriert die Firewall mit weniger restriktiven Einstellungen. (Kompatibilitätsmodus)
##
proc FirewallInternal::Firewall_configureFirewallMostOpen { } {
  global Firewall_SERVICES Firewall_IPS Firewall_USER_PORTS
  
  try_exec_cmd "/usr/sbin/iptables -F"
  try_exec_cmd "/usr/sbin/iptables -P INPUT ACCEPT"
  try_exec_cmd "/usr/sbin/iptables -A INPUT -i lo -j ACCEPT"
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 8182 -j DROP"
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 8183 -j DROP"

  try_exec_cmd "/usr/sbin/ip6tables -F"
  try_exec_cmd "/usr/sbin/ip6tables -P INPUT ACCEPT"
  try_exec_cmd "/usr/sbin/ip6tables -A INPUT -i lo -j ACCEPT"
  try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport 8182 -j DROP"
  try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport 8183 -j DROP"
  if { [FirewallInternal::sshEnabled] == 1 } {
    try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 22 -j ACCEPT"  
  } else {
    try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 22 -j DROP"
  }

  set has_ip6tables [FirewallInternal::ip6Supported]

  # user defined ports (the only reason to do this is to enable the user to override settings for services)
  foreach userport $Firewall_USER_PORTS {
    set userport [string trim $userport]
    if { $userport eq "" } {
      continue
    }
    if { ![string is integer -strict $userport] || $userport < 1 || $userport > 65535 } {
      exec logger -t firewall -p user.err "invalid user port '$userport' specified"
      continue
    }

    try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport $userport -j ACCEPT"
    try_exec_cmd "/usr/sbin/iptables -A INPUT -p udp --dport $userport -j ACCEPT"
    if { $has_ip6tables } {
      try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport $userport -j ACCEPT"
      try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p udp --dport $userport -j ACCEPT"
    }
  }

  foreach serviceName [array names Firewall_SERVICES] {
    array set service $Firewall_SERVICES($serviceName)
  
    if { $service(ACCESS) == "restricted" } then {
      foreach port $service(PORTS) {
        set prot tcp
        if { [ FirewallInternal::Firewall_isUdpPort $port ] } {
          set prot udp
        }
        foreach ip $Firewall_IPS {
          set ip [string trim $ip]
          if { $ip eq "" } {
            continue
          }
          if { [regexp {:} $ip] } then {
            try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p $prot --dport $port -s $ip -j ACCEPT"
          } else {
            try_exec_cmd "/usr/sbin/iptables -A INPUT -p $prot --dport $port -s $ip -j ACCEPT"
          }
        }
      }
    }
    
    if { $service(ACCESS) == "none" || $service(ACCESS) == "restricted"} then {
      foreach port $service(PORTS) {
        set prot tcp
        if { [FirewallInternal::Firewall_isUdpPort $port] } {
          set prot udp
        }
        try_exec_cmd "/usr/sbin/iptables -A INPUT -p $prot --dport $port -j DROP"
        try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p $prot --dport $port -j DROP"
      }
    }
  
    #block internal ports
    if { [string equal "XMLRPC" $serviceName] || [string equal "REGA" $serviceName] } {
      foreach port $service(PORTS) {
        if { $port < 30000 } {
          try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 3$port -j DROP"
          if {$has_ip6tables} {
            try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport 3$port -j DROP"
          }
        }
      }
    }
  }
}

##
# @fn configureFirewallRestrictive
# Konfiguriert die Firewall mit restriktiveren Einstellungen. 
##
proc FirewallInternal::Firewall_configureFirewallRestrictive { } {
  global Firewall_SERVICES Firewall_IPS Firewall_USER_PORTS
  
  # IPv4
  # flush rules
  try_exec_cmd "/usr/sbin/iptables -F"

  # allow all loopback
  try_exec_cmd "/usr/sbin/iptables -A INPUT -i lo -j ACCEPT"
  # allow all established and related packets to pass  
  try_exec_cmd "/usr/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT" 
  # tcp ports for internal hmip update server (9293: HmIP-HAP, HmIPW-DRAP, 9294: HmIP-HAP2)
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 9293 -m state --state NEW -j ACCEPT"
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 9294 -m state --state NEW -j ACCEPT"
  # ssh
  if { [FirewallInternal::sshEnabled] == 1 } {
    try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT"  
  } 
  # http(s)
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT"
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT"

  # udp port for eq3configd
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p udp --sport 43439 -j ACCEPT"
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p udp --dport 43439 -j ACCEPT"
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p udp --sport 23272 -j ACCEPT"
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p udp --dport 23272 -j ACCEPT"

  # hmip drap
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p udp --dport 43438 -j ACCEPT"

  # udp uPnP/ssdp port
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p udp --dport 1900 -j ACCEPT"
  
  # IPv6
  set has_ip6tables [FirewallInternal::ip6Supported]
  #exec logger -t firewall -p user.info "has ip6 $has_ip6tables"
  if { $has_ip6tables } {
    # flush rules
    try_exec_cmd "/usr/sbin/ip6tables -F"    
    # allow all loopback
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -i lo -j ACCEPT"
    # allow all established and related packets to pass  
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT"
    # tcp ports for internal hmip update server (9293: HmIP-HAP, HmIPW-DRAP, 9294: HmIP-HAP2)
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport 9293 -m state --state NEW -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport 9294 -m state --state NEW -j ACCEPT"
    # ssh
    if { [FirewallInternal::sshEnabled] == 1 } {
      try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT" 
    }
    # http(s)
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT" 
    # udp port for eq3configd
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p udp --sport 43439 -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p udp --dport 43439 -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p udp --sport 23272 -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p udp --dport 23272 -j ACCEPT"

    # hmip drap
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p udp --dport 43438 -j ACCEPT"
  
    # udp uPnP/ssdp port
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p udp --dport 1900 -j ACCEPT"
  }

  # user defined ports
  foreach userport $Firewall_USER_PORTS {
    set userport [string trim $userport]
    if { $userport eq "" } {
      continue
    }
    if { ![string is integer -strict $userport] || $userport < 1 || $userport > 65535 } {
      exec logger -t firewall -p user.err "invalid user port '$userport' specified"
      continue
    }

    try_exec_cmd "/usr/sbin/iptables -A INPUT -p tcp --dport $userport -m state --state NEW -j ACCEPT"
    try_exec_cmd "/usr/sbin/iptables -A INPUT -p udp --dport $userport -j ACCEPT"
    if { $has_ip6tables } {
      try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p tcp --dport $userport -m state --state NEW -j ACCEPT"
      try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p udp --dport $userport -j ACCEPT"
    }
  }

  # services ports
  foreach serviceName [array names Firewall_SERVICES] {
    array set service $Firewall_SERVICES($serviceName)
  
    if { $service(ACCESS) == "restricted" } then {
      foreach port $service(PORTS) {
        set prot "tcp"
        set options "-m state --state NEW"
        if { [FirewallInternal::Firewall_isUdpPort $port] } {
            set prot "udp"
            set options ""
        }
        foreach ip $Firewall_IPS {
          set ip [string trim $ip]
          if { $ip eq "" } {
            continue
          }
          if { [ FirewallInternal::IsIPV4 $ip ] == 1 } then {
            try_exec_cmd "/usr/sbin/iptables -A INPUT -p $prot --dport $port -s $ip $options -j ACCEPT"
          } elseif { $has_ip6tables } {
            try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p $prot --dport $port -s $ip $options -j ACCEPT"
          }
        }
      }
    }
    
    if { $service(ACCESS) == "full"} then {
      foreach port $service(PORTS) {
        set prot "tcp"
        set options "-m state --state NEW"
        if { [FirewallInternal::Firewall_isUdpPort $port] } {
            set prot "udp"
            set options ""
        }
        try_exec_cmd "/usr/sbin/iptables -A INPUT -p $prot --dport $port $options -j ACCEPT"
        if { $has_ip6tables } {
          try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p $prot --dport $port $options -j ACCEPT"
        }
      }
    }
  }

  # Allow some ICMPv6 types in the INPUT chain for local IPv6 Communication
  if {$has_ip6tables} {
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type destination-unreachable -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type packet-too-big -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type time-exceeded -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type parameter-problem -j ACCEPT"
  }
  
  # allow echo request
  try_exec_cmd "/usr/sbin/iptables -A INPUT -p icmp --icmp-type echo-request -m state --state NEW -j ACCEPT"
  if {$has_ip6tables} {
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type echo-request -m state --state NEW -m limit --limit 900/min -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type echo-reply -m state --state NEW -m limit --limit 900/min -j ACCEPT"
  }

  # allow DHCPv6 / Router Advertisement and NDP but only if the hop limit field is 255
  if {$has_ip6tables} {
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type router-advertisement -m hl --hl-eq 255 -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type neighbor-advertisement -m hl --hl-eq 255 -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type neighbor-solicitation -m hl --hl-eq 255 -j ACCEPT"
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -p icmpv6 --icmpv6-type redirect -m hl --hl-eq 255 -j ACCEPT"
  }
  
  # default INPUT policy DROP and last Rule REJECTS all (do this at very last step)
  try_exec_cmd "/usr/sbin/iptables -P INPUT DROP" 
  try_exec_cmd "/usr/sbin/iptables -A INPUT -j REJECT" 
  if {$has_ip6tables} {
    try_exec_cmd "/usr/sbin/ip6tables -P INPUT DROP" 
    try_exec_cmd "/usr/sbin/ip6tables -A INPUT -j REJECT" 
  }
}

##
# @fn exec_cmd
# Prüft ob es sich um eine IPv4 Adresse handelt. Gibt 1 zurück bei IPv4, ansonsten 0.
##
proc FirewallInternal::IsIPV4 { address } {
  if { [string first "." $address] == -1 } {
    return 0  
  } else {
    return 1
  }
}

##
# @fn exec_cmd
# Führt eine Kommandozeile aus
##
proc exec_cmd {cmdline} {
  set fd [open "|$cmdline" r]
  close $fd
}

##
# @fn exec_cmd
# Führt eine Kommandozeile aus
##
proc try_exec_cmd {cmdline} {
  global Firewall_LOG_ENABLED
  if { [ catch {
   set fd [open "|$cmdline" r]
   close $fd
  } err ] } {
    catch { close $fd }
    if { $Firewall_LOG_ENABLED == 1 } {
      catch { [exec logger -t firewall -p user.err $err] }
    }
  }
}

##
# @fn array_clear
# Löscht die Elemente in einem Array
##
proc array_clear {name} {
  upvar $name arr
  foreach key [array names arr] {
    unset arr($key)
  }
}

##
# @fn array_getValue
# Liefert einen Wert aus einem Array
# Ist der Wert nicht vorhanden, wird {} zurückgegeben
##
proc array_getValue { pArray name } {
  upvar $pArray arr

  set value {}
  catch { set value $arr($name) }

  return $value
}
