#!/bin/tclsh
#
# DutyCycle Script v3.19
# Copyright (c) 2018-2023 Andreas Buenting, Jens Maus
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Dieses Script liest den DutyCycle Status der HomeMatic CCU und Gateways
# aus und erstellt automatisch eine Systemvariable vom Typ Zahl mit dem
# Gateway Namen bzw. alternativ mit der Geräte-Seriennummer. Wird der
# Gateway Name nachträglich gesetzt, wird die zuvor erstellte Systemvariable
# automatisch umbenannt. Zudem wird eine DutyCycle System-Log Meldung erzeugt,
# sofern der DutyCycle über 80% steigt. Für den HM-CFG-LAN wird der DutyCycle
# Status bei einer Verbindungsunterbrechung auf -1 gesetzt. Sofern
# Wired-Gateway eingebunden, wird eine Systemvariabel mit dem Namen
# "Wired-Status" und den Zuständen "online/offline" angelegt.

# if user doesn't want this script to be running
if { [file exists /etc/config/NoUpdateDCVars] == 1 ||
     [file exists /usr/local/HMLGW] == 1 } {
  exit 0
}

load tclrpc.so
load tclrega.so

###################################################################
# Helper functions to parse an ini-type file
# like /etc/config/rfd.conf
namespace eval cfg {
  variable version 1.0
  variable sections [list DEFAULT]
  variable cursection DEFAULT
  variable DEFAULT;   # DEFAULT section
}

proc cfg::sections {} {
  return $cfg::sections
}

proc cfg::variables {{section DEFAULT}} {
  return [array names ::cfg::$section]
}

proc cfg::add_section {str} {
  variable sections
  variable cursection

  set cursection [string trim $str \[\]]
  if {[lsearch -exact $sections $cursection] == -1} {
    lappend sections $cursection
    variable ::cfg::${cursection}
  }
}

proc cfg::setvar {varname value {section DEFAULT}} {
  variable sections
  if {[lsearch -exact $sections $section] == -1} {
    cfg::add_section $section
  }
  set ::cfg::${section}($varname) $value
}

proc cfg::getvar {varname {section DEFAULT}} {
  variable sections
  if {[lsearch -exact $sections $section] == -1} {
    error "No such section: $section"
  }
  return [set ::cfg::${section}($varname)]
}

proc cfg::parse_file {filename} {
  foreach section [::cfg::sections] {
    foreach var [cfg::variables "$section"] {
      unset ::cfg::${section}($var)
    }
    if {$section != "DEFAULT"} {
      unset ::cfg::${section}
    }
  }
  set ::cfg::sections [list DEFAULT]
  set ::cfg::cursection DEFAULT
  variable sections
  variable cursection
  set line_no 1
  catch {
    set fd [open $filename r]
    while {![eof $fd]} {
      set line [string trim [gets $fd] " "]
      if {$line == ""} continue
      switch -regexp -- $line {
        ^#.* { }
        ^\\[.*\\]$ {
          cfg::add_section $line
        }
        .*=.* {
          set pair [split $line =]
          set name [string trim [lindex $pair 0] " "]
          set value [string trim [lindex $pair 1] " "]
          cfg::setvar $name $value $cursection
        }
        default {
          error "Error parsing $filename (line: $line_no): $line"
        }
      }
      incr line_no
    }
    close $fd
  }
}

###################################################################
# Helper function encode a JSON string
proc json_toString { str } {
  set map {
    "\"" "\\\""
    "\\" "\\\\"
    "/"  "\\/"
    "\b"  "\\b"
    "\f"  "\\f"
    "\n"  "\\n"
    "\r"  "\\r"
    "\t"  "\\t"
  }
  return "\"[string map $map $str]\""
}

###################################################################
# Helper function to create/set/rename a ReGa variable using the
# tclrega interface
proc setDutyCycleSV {name desc value serial} {
  set prefix "DutyCycle"

  # check how we should name the
  # system variable
  if {$name != ""} {
    set svName "$prefix-$name"

    if {$serial != ""} {
      # if the system variable should have a clear-text
      # name we check if there is already a one with the serial
      # number and rename it accordingly.
      set script "
        object svObj=dom.GetObject(ID_SYSTEM_VARIABLES).Get(\"$prefix-$serial\");
        if(svObj) {
          svObj.Name(\"$svName\");
          dom.RTUpdate(1);
        }
      "
      rega_script $script
    }
  } elseif {$serial != ""} {
    set svName "$prefix-$serial"
  } else {
    set svName "$prefix"
  }

  # create the rega script
  set script "
    object svObj=dom.GetObject(ID_SYSTEM_VARIABLES).Get(\"$svName\");
    if(!svObj) {
      svObj=dom.CreateObject(OT_VARDP);
      if(svObj) {
        svObj.Name(\"$svName\");
        svObj.ValueMin(-1);
        svObj.Internal(false);
        svObj.Visible(true);
        dom.GetObject(ID_SYSTEM_VARIABLES).Add(svObj.ID());
        dom.RTUpdate(1);
      }
    }

    if(svObj) {
      svObj.DPInfo(\"$desc\");
      svObj.ValueType(ivtFloat);
      svObj.ValueSubType(istGeneric);
      svObj.ValueUnit(\"%\");
      svObj.ValueMin(-1);
      svObj.ValueMax(100);
      svObj.State($value);
    }
  "

  # execute the ReGa script
  rega_script $script

  return $svName
}

###################################################################
# BIDCOS/HMIP-RF
#

# get all bidcos interface status using a listBidcosInterfaces
# XMLRPC query
cfg::parse_file /var/etc/rfd.conf
if {[llength [cfg::sections]] > 1} {
  set portFound [catch {set port [cfg::getvar "Listen Port"]}]
} else {
  # if we have no BidCos-RF interface we have to check if there
  # is a HmIP interface (e.g. HmIP-RFUSB) from which we can query
  # duty cycles values as well.
  cfg::parse_file /var/etc/crRFD.conf
  set portFound [catch {set port [cfg::getvar "Legacy.Port"]}]
}

if {$portFound == 0} {

  set gwFound [catch {set gateways [xmlrpc http://127.0.0.1:$port/ listBidcosInterfaces]}]
  if {$gwFound == 0} {

    set ccuCarrierSense -1

    # check for any HmIP-HAP LAN gateway first so that
    # we can add them to the gateway list as well
    # (currently this can only be done via rega scripting)
    set script "
      integer ccuCarrierSense = -1;
      string dev;
      foreach(dev, devices.Get().EnumUsedIDs()) {
        object oDev = dom.GetObject(dev);
        if(oDev.Label().StartsWith('HmIP-HAP')) {
          string name = oDev.Name();
          string chn;
          foreach(chn, oDev.Channels()) {
            object oChn = dom.GetObject(chn);
            if(oChn.Address().Contains(':0')) {
              integer dcValue = -1;
              integer csValue = -1;
              integer connected = 0;
              object dp = oChn.DPByControl('MAINTENANCE.UNREACH');
              if(dp) {
                if(dp.Value() == false) {
                  connected = 1;
                  object dp = oChn.DPByControl('MAINTENANCE.DUTY_CYCLE_LEVEL');
                  if(dp) {
                    dcValue = dp.Value().ToInteger();
                  }
                  object dp = oChn.DPByControl('MAINTENANCE.CARRIER_SENSE_LEVEL');
                  if(dp) {
                    csValue = dp.Value().ToInteger();
                  }
                }
              }
              Write('{ADDRESS '#oDev.Address());
              Write(' NAME {'#oDev.Name()#'}');
              Write(' IP {'#oChn.DPByControl(\"MAINTENANCE.IP_ADDRESS\").Value()#'}');
              Write(' CONNECTED '#connected);
              Write(' DEFAULT 1');
              Write(' DESCRIPTION {}');
              Write(' CARRIER_SENSE '#csValue);
              Write(' DUTY_CYCLE '#dcValue);
              Write(' TYPE HMIP-HAP} ');
              break;
            }
          }
        } elseif((oDev.Label() == 'RPI-RF-MOD') || (oDev.Label() == 'HmIP-CCU3') || (oDev.Label() == 'HmIP-RFUSB')) {
          string chn;
          foreach(chn, oDev.Channels()) {
            object oChn = dom.GetObject(chn);
            if(oChn.Address().Contains(':0')) {
              object dp = oChn.DPByControl('MAINTENANCE.CARRIER_SENSE_LEVEL');
              if(dp) {
                ccuCarrierSense = dp.Value().ToInteger();
              }
              break;
            }
          }
        }
      }
    "
    catch {
      array set response [rega_script $script]
      if {[string trim $response(STDOUT)] != ""} {
        set gateways [concat $gateways $response(STDOUT)]
      }
      set ccuCarrierSense $response(ccuCarrierSense)
      unset response
    }

    # catch all dutyCycle values in an additional JSON array
    set jsonResult "\["
    set first 1

    # iterate over all gateways returned by listBidcosInterfaces
    foreach _gateway $gateways {
      array set gateway $_gateway
      if {[info exists gateway(DUTY_CYCLE)]} {

        # if the gw is flagged as NOT connected set dutycycle to -1
        if {$gateway(CONNECTED) == 1} {
          set dutycycle $gateway(DUTY_CYCLE)
        } else {
          set dutycycle -1
        }

        set name ""
        if {$gateway(TYPE) == "CCU2" || $gateway(TYPE) == "HMIP_CCU2"} {
          set sysVarName [setDutyCycleSV "" "DutyCycle CCU" $dutycycle ""]
          set gateway(TYPE) "CCU2"
          set gateway(CARRIER_SENSE) $ccuCarrierSense
          set name "CCU"

          # overwrite the address with board_serial to match
          # serial number expectations in DC/CS alarms.
          set fp [open "/var/board_serial" r]
          set fileData [read $fp]
          close $fp
          if {$fileData != "" } {
            set gateway(ADDRESS) $fileData
          }
        } elseif {$gateway(TYPE) == "HMIP-HAP"} {
          set name $gateway(NAME)
          set sysVarName [setDutyCycleSV $name "DutyCycle HAP ($gateway(ADDRESS))" $dutycycle $gateway(ADDRESS)]
        } else {
          # get the cleartext name a user assigned for that gateway
          # we try to find it based on the defined serial number
          foreach section [cfg::sections] {
            set result [catch {set serNum [cfg::getvar "Serial Number" "$section"]}]
            if {$result == 0} {
              if {$serNum == $gateway(ADDRESS)} {
                catch {set name [cfg::getvar "Name" "$section"]}
              }
            }
          }
          set sysVarName [setDutyCycleSV $name "DutyCycle LGW ($gateway(ADDRESS))" $dutycycle $gateway(ADDRESS)]
        }

        # set carrier sense
        if {[info exists gateway(CARRIER_SENSE)]} {
          set carriersense $gateway(CARRIER_SENSE)
        } else {
          set carriersense -1
        }

        # add the dutyCycle to our jsonResult array
        if { 1 != $first } then { append jsonResult "," } else { set first 0 }
        append jsonResult "\{"
        append jsonResult "\"address\":[json_toString $gateway(ADDRESS)]"
        append jsonResult ",\"name\":[json_toString $name]"
        append jsonResult ",\"sysVar\":[json_toString $sysVarName]"
        append jsonResult ",\"dutyCycle\":[json_toString $gateway(DUTY_CYCLE)]"
        append jsonResult ",\"carrierSense\":[json_toString $carriersense]"
        append jsonResult ",\"type\":[json_toString $gateway(TYPE)]"
        append jsonResult "\}"

        set infoTxt "DutyCycle-$gateway(ADDRESS), NAME: '$name', TYPE: $gateway(TYPE), CONNECTED: $gateway(CONNECTED), DC: $dutycycle %, CS: $carriersense %"
        if {$gateway(CONNECTED) == 0} {
          exec /bin/triggerAlarm.tcl "RF-Gateway $name ($gateway(ADDRESS)) not connected" "WatchDog: connect-$name" true
          exec logger -t watchdog -p error "$infoTxt"
        } elseif {$dutycycle >= 98} {
          exec /bin/triggerAlarm.tcl "DutyCycle $dutycycle% ($gateway(ADDRESS))" "WatchDog: dutycycle-$name" true
          exec logger -t watchdog -p error "$infoTxt"
        } elseif {$dutycycle >= 80} {
          exec logger -t watchdog -p warn "$infoTxt"
        }

        # check carrier sense level
        if {$carriersense >= 98} {
          exec /bin/triggerAlarm.tcl "CarrierSense $carriersense% ($gateway(ADDRESS))" "WatchDog: carriersense-$name" true
          exec logger -t watchdog -p error "$infoTxt"
        } elseif {$carriersense >= 80} {
          exec logger -t watchdog -p warn "$infoTxt"
        }

        puts "$infoTxt"
      }
      unset gateway
    }

    # finish jsonResult array
    append jsonResult "\]"

    # write to file
    set jsonOutputFile [open /tmp/dutycycle.json w]
    puts $jsonOutputFile $jsonResult
    close $jsonOutputFile
  }
} else {
  setDutyCycleSV "" "DutyCycle CCU" -1 ""
}

###################################################################
# HmIP-WIRED
#

# check for any HmIP-DRAP LAN gateway so that we can check for
# certain error conditions
# (currently this can only be done via rega scripting)
set script "
 string dev;
  foreach(dev, devices.Get().EnumUsedIDs()) {
    object oDev = dom.GetObject(dev);
    if(oDev.Label() == 'HmIPW-DRAP') {
      string name = oDev.Name();
      string chn;
      foreach(chn, oDev.Channels()) {
        object oChn = dom.GetObject(chn);
        if(oChn.Address().Contains(':0')) {
          integer connected = 0;
          integer overheat = 0;
          integer undervoltage = 0;
          if(oChn.DPByControl('MAINTENANCE.UNREACH').Value() == false) {
            connected = 1;
            temp = oChn.DPByControl('MAINTENANCE.ERROR_OVERHEAT').Value().ToInteger();
            undervoltage = oChn.DPByControl('MAINTENANCE.ERROR_UNDERVOLTAGE').Value().ToInteger();
          }
          Write('{ADDRESS '#oDev.Address());
          Write(' NAME {'#oDev.Name()#'}');
          Write(' IP {'#oChn.DPByControl('MAINTENANCE.IP_ADDRESS').Value()#'}');
          Write(' CONNECTED '#connected);
          Write(' OVERHEAT '#overheat);
          Write(' UNDERVOLTAGE '#undervoltage);
          Write(' TYPE HMIPW-DRAP} ');
        }
      }
    }
  }
"
set gateways {}

catch {
  array set response [rega_script $script]
  if {[string trim $response(STDOUT)] != ""} {
    set gateways [concat $gateways $response(STDOUT)]
  }
  unset response
}
if { [llength $gateways] > 0 } {
  foreach _gateway $gateways {
    array set gateway $_gateway
    set infoTxt "HmIPW-DRAP-Status: $gateway(CONNECTED) ($gateway(ADDRESS), IP: $gateway(IP))"
    if {$gateway(CONNECTED) == 0} {
      exec /bin/triggerAlarm.tcl "HmIPW-DRAP ($gateway(ADDRESS), IP: $gateway(IP)) not connected" "WatchDog: connect-$gateway(ADDRESS)" true
      exec logger -t watchdog -p error "$infoTxt"
    } elseif {$gateway(OVERHEAT) == 1} {
      exec /bin/triggerAlarm.tcl "HmIPW-DRAP ($gateway(ADDRESS), IP: $gateway(IP)) overheated" "WatchDog: overheat-$gateway(ADDRESS)" true
      exec logger -t watchdog -p error "$infoTxt"
    } elseif {$gateway(UNDERVOLTAGE) == 1} {
      exec /bin/triggerAlarm.tcl "HmIPW-DRAP ($gateway(ADDRESS), IP: $gateway(IP)) undervoltaged" "WatchDog: voltage-$gateway(ADDRESS)" true
      exec logger -t watchdog -p error "$infoTxt"
    }

    puts $infoTxt
    unset gateway
  }
}

###################################################################
# BidCos-WIRED
#

# parse the hs485d.conf file to identify if there are
# any wired gateways configured
cfg::parse_file /var/etc/hs485d.conf
if {[llength [cfg::sections]] > 1} {
  set connected "false"
  set port [cfg::getvar "Listen Port"]
  set result [catch {set gateways [xmlrpc http://127.0.0.1:$port/ getLGWStatus]}]
  if {$result == 0} {
    set gateways "{ $gateways }"
    foreach _gateway $gateways {
      array set gateway $_gateway
      if {[info exists gateway(CONNECTED)]} {
        if {$gateway(CONNECTED) == 1} {
          set connected "true"
        }

        break
      }
      unset gateway
    }
  }

  set script "
    string svName=\"Wired-Status\";
    object svObj=dom.GetObject(ID_SYSTEM_VARIABLES).Get(svName);
    if(!svObj) {
      svObj=dom.CreateObject(OT_VARDP);
      if(svObj) {
        svObj.Name(svName);
        dom.GetObject(ID_SYSTEM_VARIABLES).Add(svObj.ID());
        dom.RTUpdate(1);
      }
    }

    if(svObj) {
      svObj.DPInfo(\"Wired-LGW Status\");
      svObj.ValueType(ivtBinary);
      svObj.ValueSubType(istBool);
      svObj.ValueName0(\"offline\");
      svObj.ValueName1(\"online\");
      svObj.ValueUnit(\"\");
      svObj.State($connected);
    }
  "

  rega_script $script

  set infoTxt "Wired-LGW-Status: $connected"
  if {$connected == "false"} {
    exec /bin/triggerAlarm.tcl "Wired-Gateway ($gateway(ADDRESS)) not connected" "WatchDog: wired-connect" true
    exec logger -t watchdog -p error "$infoTxt"
  }
  puts $infoTxt
}

exit 0
