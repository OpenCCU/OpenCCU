#!/usr/bin/env tclsh
# Copyright 2018 MDZ info@ccu-historian.de
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

# this script adds or removes an addon configuration

package require HomeMatic

# parse arguments
foreach {n v} $argv {
    switch -- $n {
        -a { set id $v; set add true }
        -d { set id $v; set add false }
        -name { set name $v }
        -url { set url $v }
        -en { set descr(en) "<li>$v</li>" }
        -de { set descr(de) "<li>$v</li>" }
        default {
            puts stderr "error: invalid argument: $n"
            exit 1
        }
    }
}

# check arguments
set argError false
# id is always needed
if {![info exists id] || $id==""} {
    set argError true
} elseif {$add} {
    # for adding all remaining parameters are needed
    foreach n {name url descr(de) descr(en)} {
        if {![info exists $n]} {
            set argError true
            break
        }
    }
}
if {$argError} {
    puts stderr "usage: [file tail [info script]] \[OPTIONS]"
    puts stderr "options:"
    puts stderr "  add (or update) add-on:"
    puts stderr "    -a ID -url URL -name NAME -de DESCR(DE) -en DESCR(EN)"
    puts stderr "  delete add-on:"
    puts stderr "    -d ID"
    exit 1
}


# add or remove addon config
if {$add} {
  ::HomeMatic::Addon::AddConfigPage $id $url $name [array get descr]
} else {
  ::HomeMatic::Addon::RemoveConfigPage $id
}
