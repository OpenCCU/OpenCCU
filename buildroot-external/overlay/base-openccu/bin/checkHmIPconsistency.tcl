#!/bin/tclsh
#
# checkHmIPconsistency.tcl v1.0
# Copyright (c) 2023 Jens Maus <mail@jens-maus.de>
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
# Simple helper script to walk through all homematicIP devices
# registered at HmIPServer/crRFD and verify that the parameters returned
# via getParamsetDescription() are consistent with what getParamset()
# returns. Thus, if not consistent the device needs a hardware
# factory reset so that HmIPServer will re-read all its parameters
# accordingly. If differences are found an alarm will be triggered
# via /bin/triggerAlarm.tcl accordingly.
#

# if no HMIPServer is running, exist immediately
if {![file exists /var/run/HMIPServer.pid]} {
  exit 0
}

load tclrpc.so

set url "http://127.0.0.1:2010/"

set devicesFound [catch {set devices [xmlrpc $url listDevices]}]
if {$devicesFound == 0} {
  array set brokenDevices {}

  # iterate over all devices returned by listDevices
  foreach _device $devices {
    array set device $_device
    set address $device(ADDRESS)
    set paramsets $device(PARAMSETS)
    if {[string first MASTER $paramsets] != -1 } {
      array unset paramsetDesc
      set paramsetDescFound [catch {array set paramsetDesc [xmlrpc $url getParamsetDescription [list string $address] [list string "MASTER"]]}]
      if {$paramsetDescFound == 0 && [array size paramsetDesc] > 0} {
        array unset paramset
        set paramsetFound [catch {array set paramset [xmlrpc $url getParamset [list string $address] [list string "MASTER"]]}]
        if {$paramsetFound == 0} {
          # iterate over all paramsetDesc
          foreach desc [array names paramsetDesc] {
            # and search in paramset if it is present
            if {[info exists paramset($desc)] == 0} {
                set brokenDevices([string range $address 1 13]) $device(PARENT_TYPE)
                #puts "$address|$device(PARENT_TYPE) = $desc"
            }
          }
        }
      }
    }
  }

  if {[array size brokenDevices] > 0} {
    foreach dev [array names brokenDevices] {
      puts "WARNING: Inconsistent device parameters found ($dev, $brokenDevices($dev))"
      exec /bin/triggerAlarm.tcl "Device $dev ($brokenDevices($dev)) registration inconsistent. Please perform hardware factory reset to resolve." "WatchDog: hmip-consistency" true
    }
  }
}
