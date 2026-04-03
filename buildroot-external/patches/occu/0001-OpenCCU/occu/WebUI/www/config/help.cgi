#!/bin/tclsh
source cgi.tcl
source common.tcl
load tclrega.so

set PRODUCT_NAME "OpenCCU"
set PRODUCT_ID "CCU"
# set HOMEMATIC_URL "http://www.homematic.com"
set HOMEMATIC_URL "http://www.eq-3.de"
set HOMEMATIC_IP_URL "https://www.homematic-ip.com"


set HM_INFO_URL "$HOMEMATIC_URL/produkte/homematic.html"
set IP_INFO_URL "$HOMEMATIC_IP_URL/start.html"

set HM_HELP_URL "$HOMEMATIC_URL/service.html"
set IP_HELP_URL "$HOMEMATIC_IP_URL/service.html"

set LANGUAGE "de"
set CUR_YEAR [clock format [clock seconds] -format %Y]

proc loadVarsFromShellFile {filename arrayName} {
    upvar 1 $arrayName array
    if {[catch {set f [open $filename r]} err]} {
        return
    }
    while {[gets $f line] >= 0} {
        if {[regexp {^\s*(\w+)=([""'']?)(.*)\2\s*$} $line -> key quote value]} {
            if {$value == ""} {
              set array($key) "n/a"
            } else {
              set array($key) $value
            }
        }
    }
    close $f
}

proc execCmd {varName cmd} {
  upvar 1 $varName variable
  set rc [catch {eval $cmd} resVar]
  if {$rc == 0} {
    set variable [string trim $resVar]
  } else {
    set variable "n/a"
  }
}

proc html_escape {s} {
  regsub -all -- <  $s "&lt;"  s
  regsub -all -- >  $s "&gt;"  s
  regsub -all -- \" $s "&quot;" s
  regsub -all -- '  $s "&#39;" s
  return $s
}

proc putsVar {name value} {
  set ename  [html_escape $name]
  set evalue [html_escape $value]
  puts "<div style='display: table-row;'><div style='display:table-cell; width: 50%; text-align: right;'>$ename:</div><div style='display:table-cell; width: 50%; text-align: left;'>$evalue</div></div>"
}

proc action_put_page {} {
  global PRODUCT_NAME PRODUCT_ID HOMEMATIC_URL HOMEMATIC_IP_URL HM_HELP_URL IP_HELP_URL HM_INFO_URL IP_INFO_URL LANGUAGE CUR_YEAR env

  # get all variables from /var/hm_mode into $hm array
  loadVarsFromShellFile /var/hm_mode hm

  # get all variables from /VERSION into ver array
  loadVarsFromShellFile /VERSION ver

  # get all variables from /etc/config/netconfig into net array
  loadVarsFromShellFile /etc/config/netconfig net

  set SERIAL ""
  catch {set SERIAL $hm(HM_HMIP_SERIAL)}
  if {$SERIAL == ""} {
    if {[file exists /var/board_sgtin]} {
      set SERIAL [string trim [exec cat /var/board_sgtin]]
    } elseif {[file exists /var/board_serial]} {
      set SERIAL [string trim [exec cat /var/board_serial]]
    } elseif {[file exists /sys/module/plat_eq3ccu2/parameters/board_serial]} {
      set SERIAL [string trim [exec cat /sys/module/plat_eq3ccu2/parameters/board_serial]]
    } else {
      set SERIAL "n/a"
    }
  }

  set HWMODEL "n/a"
  if {[file exists /proc/device-tree/model]} {
    execCmd HWMODEL {exec cat /proc/device-tree/model}
  } elseif {[file exists /sys/devices/virtual/dmi/id/board_vendor]} {
    execCmd VENDOR {exec cat /sys/devices/virtual/dmi/id/board_vendor}
    set NAME ""
    if {[file exists /sys/devices/virtual/dmi/id/board_name]} {
      execCmd NAME {exec cat /sys/devices/virtual/dmi/id/board_name}
    }
    set HWMODEL "$VENDOR $NAME"
  } elseif {[file exists /sys/devices/virtual/dmi/id/sys_vendor]} {
    execCmd VENDOR {exec cat /sys/devices/virtual/dmi/id/sys_vendor}
    set NAME ""
    if {[file exists /sys/devices/virtual/dmi/id/product_name]} {
      execCmd NAME {exec cat /sys/devices/virtual/dmi/id/product_name}
    }
    set HWMODEL "$VENDOR $NAME"
  } else {
    execCmd MODEL {exec grep ^Model /proc/cpuinfo | cut -d: -f2 | xargs}
    if {$MODEL != ""} {
      set HWMODEL $MODEL
    }
  }

  execCmd CPUMODEL {exec /usr/bin/lscpu --all --parse=MODELNAME | grep -m1 -ve "^#"}
  execCmd CPUMHZ {exec /usr/bin/lscpu --all --parse=MHZ | grep -m1 -ve "^#" | xargs printf "%.0f"}
  execCmd CPUSCALMHZ {exec /usr/bin/lscpu --all --parse=SCALMHZ% | grep -m1 -ve "^#"}
  execCmd NUMCPU {exec nproc}
  execCmd LOADAVG {exec awk {{ printf $1 " " $2 " " $3 }} /proc/loadavg}
  execCmd MEM {exec free -h | grep Mem: | awk {{ print $2 }}}
  execCmd MEMUSE {exec egrep "Mem(Total|Available)" /proc/meminfo | tr -d "\n" | awk {{ printf("%.1f %", 100-$4/$2*100) }}}
  execCmd SWAPUSE {exec egrep "Swap(Total|Free)" /proc/meminfo | tr -d "\n" | awk {{ printf("%.1f %", 100-$4/$2*100) }}}
  execCmd UPTIME {exec awk {{s=int($1);d=int(s/86400);h=int(s % 86400/3600);m=int(s % 3600 / 60); printf "%d d, %d h %d min", d, h, m}} /proc/uptime}
  execCmd NTPOFFSET {exec /usr/bin/chronyc -n tracking | grep "Last offset" | awk {{ printf("%.3f ms", $4*1000) }}}
  execCmd NTPSERVER {exec /usr/bin/chronyc -n tracking | grep "Reference ID" | awk -F "\[\(\)\]" {{ print $2 }}}
  execCmd MAINETH {exec /sbin/ip -4 route get 1 | head -1 | awk {{ print $5 }}}
  execCmd MAINHOSTNAME {exec /bin/hostname}
  catch {set OSTYPE [string trim [read_var /etc/os-release PRETTY_NAME] '"']}
  execCmd OSKERNEL {exec uname -s -r -m}
  set TCLVER [info patchlevel]
  execCmd JAVAVER {exec 2>@stdout /opt/java/bin/java -version | head -1 | cut -d\" -f2}
  execCmd NODEVER {exec /usr/bin/node -v}
  execCmd TEMP {exec awk {{ printf("%.1f &deg;C", $1/1000) }} /sys/class/thermal/thermal_zone0/temp}

  set STATUS ""
  foreach {label path} {
    IP       /var/status/hasIP
    Internet /var/status/hasInternet
    Link     /var/status/hasLink
    NTP      /var/status/hasNTP
    SD       /var/status/hasSD
  } {
    if {[file exists $path]} {
      set STATUS "${label}(1) $STATUS"
    } else {
      set STATUS "${label}(0) $STATUS"
    }
  }
  execCmd ROOTFSFREE {exec monit status rootfs 2>/dev/null | grep -m1 "space free for non superuser" | awk {{ print substr($0,index($0,$6)) }}}
  execCmd ROOTFSTOTAL {exec monit status rootfs 2>/dev/null | grep -m1 "space total" | awk {{ print $3 " " $4 }}}
  execCmd USERFSFREE {exec monit status userfs 2>/dev/null | grep -m1 "space free for non superuser" | awk {{ print substr($0,index($0,$6)) }}}
  execCmd USERFSTOTAL {exec monit status userfs 2>/dev/null | grep -m1 "space total" | awk {{ print $3 " " $4 }}}
  execCmd USBDEVFREE {exec monit status usb1 2>/dev/null | grep -m1 "space free for non superuser" | awk {{ print substr($0,index($0,$6)) }}}
  execCmd USBDEVTOTAL {exec monit status usb1 2>/dev/null | grep -m1 "space total" | awk {{ print $3 " " $4 }}}
  execCmd STORAGEDEV {exec mountpoint -n /usr/local | awk {{ print $1 }} | xargs lsblk -l -n -o PKNAME -p}
  execCmd STORAGE "exec lsblk -l -n -o SIZE,MODEL,KNAME -d -p $STORAGEDEV"
  set HMRF_DUTYCYCLE "n/a"
  catch { set HMRF_DUTYCYCLE [exec /usr/bin/jq -r ".\[\] | select(.address == \"$hm(HM_HMRF_SERIAL)\") | .dutyCycle" /tmp/dutycycle.json] }
  set HMRF_CARRIERSENSE "n/a"
  catch { set HMRF_CARRIERSENSE [exec /usr/bin/jq -r ".\[\] | select(.address == \"$hm(HM_HMRF_SERIAL)\") | .carrierSense" /tmp/dutycycle.json] }
  set HMIP_DUTYCYCLE "n/a"
  catch { set HMIP_DUTYCYCLE [exec /usr/bin/jq -r ".\[\] | select(.address == \"$hm(HM_HMIP_SERIAL)\") | .dutyCycle" /tmp/dutycycle.json] }
  set HMIP_CARRIERSENSE "n/a"
  catch { set HMIP_CARRIERSENSE [exec /usr/bin/jq -r ".\[\] | select(.address == \"$hm(HM_HMIP_SERIAL)\") | .carrierSense" /tmp/dutycycle.json] }

  set sid ""
  catch {import sid}
  set from ""
  catch {import from}

  #<%
  #  system.SetSessionVar("sessionTAB", "help");
  #%>

  if { "$from" == "internal" } {
    puts {
      <script type="text/javascript">
        setPath(translateKey('dialogHelpPath'));
      </script>
    }
  }

  puts "<table id='overviewHelpPage' class='CLASS21300' style='display:none'>"
    puts "<colgroup>"
    puts "<col style='width:50%;'/>"
    puts "<col style='width:50%;'/>"
    puts "</colgroup>"
    puts "<tr>"

      puts "<td id='tdInfo' class='CLASS21305a' >"
        puts "<img src='/ise/img/occu-logo_small.png'/><br/>"
        puts "\${dialogHelpInfoLblVersion} $ver(VERSION) ($ver(PLATFORM))<br/>"
        puts "<br/>\${dialogHelpInfoLblCopyright} &copy; 2016 - $CUR_YEAR<br/>"
        puts "OpenCCU Contributors (<a target='_blank' href='https://github.com/openccu/openccu/graphs/contributors'>see here</a>)<br/>"
        puts "Licensed under Apache 2.0 OpenSource license<br/>"
        puts "<a target='_blank' href=\"https://github.com/openccu\">https://github.com/openccu</a><br/>"
        puts "<a target='_blank' href=\"https://openccu.de/\">https://openccu.de/</a><br/>"
        puts "<br/>Based on <a target='_blank' href=\"https://github.com/eq-3/occu\">OCCU-SDK</a>:<br/>"
        puts "\${dialogHelpInfoLblCopyright} &copy; 2007 - $CUR_YEAR<br/>"
        puts "eQ-3 AG, 26789 Leer, Germany<br/>"
        puts "<a target='_blank' href=\"$HM_INFO_URL\">\${homepage} \${LabelHomeMatic}</a><br/>"
        puts "<a target='_blank' href=\"$IP_INFO_URL\">\${homepage} \${dialogHelpLinkOnlineHelpB}</a><br/>"
        puts "<br/>Menu icons made by <a target='_blank' href=\"https://icons8.com/license/\">icons8.com</a><br/>"
        puts "<br/>\${dialogSettingsCMHintSoftwareUpdateOpenCCU}<br/><br/>"
        puts "<h1 class='helpTitle'><u>\${menuHelpPage}</u></h1>"
        puts "<a target='_blank' href='https://github.com/openccu/openccu/wiki'>OpenCCU Documentation</a><br/>"
        puts "<a target='_blank' href=\'$HM_HELP_URL\'>\${dialogHelpLinkOnlineHelpA}</a><br/>"
        puts "<a target='_blank' href=\'$IP_HELP_URL\'>\${dialogHelpLinkOnlineHelpB}</a><br/>"
        puts "<a target='_blank' href='/licenseinfo.htm'>\${lblLicenseInformation}</a><br/>"
      puts "</td>"

      puts "<td id='tdOnline' class='CLASS21301a'  style='text-align:center;'>"
        puts "<h1 class='helpTitle'><u>CCU Hardware Info</u></h1>"
        puts "<div style='display: table; width: 100%;'>"
          putsVar "Hardware Model" "$HWMODEL ($hm(HM_HOST))"
          putsVar "CPU (Cores), Memory" "$CPUMODEL ($NUMCPU), $MEM"
          putsVar "Storage" "$STORAGE"
          putsVar "Real-Time-Clock" $hm(HM_RTC)
          putsVar "Serial Number" $SERIAL
        puts "</div>"
        puts "<h1 class='helpTitle'><u>CCU Software Info</u></h1>"
        puts "<div style='display: table; width: 100%;'>"
          putsVar "Product" "$ver(PRODUCT) ($ver(VERSION))"
          putsVar "ReGaHss" [rega dom.BuildLabel()]
          putsVar "Engines" "Tcl ($TCLVER), Java ($JAVAVER), NodeJS ($NODEVER)"
          putsVar "Status" $STATUS
        puts "</div>"
        puts "<h1 class='helpTitle'><u>Operating System Info</u></h1>"
        puts "<div style='display: table; width: 100%;'>"
          putsVar "OS Type (Kernel)" "$OSTYPE ($OSKERNEL)"
          putsVar "Uptime" $UPTIME
          if {$CPUSCALMHZ != ""} {
            putsVar "Load Average @ CPU Speed" "$LOADAVG @ $CPUMHZ MHz ($CPUSCALMHZ)"
          } else {
            putsVar "Load Average @ CPU Speed" "$LOADAVG @ $CPUMHZ MHz"
          }
          putsVar "System Temperature" $TEMP
          putsVar "Memory, Swap Utilization" "$MEMUSE, $SWAPUSE"
          putsVar "NTP Offset (Server)" "$NTPOFFSET ($NTPSERVER)"
          putsVar "rootfs Free Space" "$ROOTFSFREE / $ROOTFSTOTAL"
          putsVar "userfs Free Space" "$USERFSFREE / $USERFSTOTAL"
          putsVar "USB Free Space" "$USBDEVFREE / $USBDEVTOTAL"
          putsVar "IP address" "$net(CURRENT_IP) ($MAINETH, $net(MODE))"
          putsVar "Gateway (Netmask)" "$net(CURRENT_GATEWAY) ($net(CURRENT_NETMASK))"
          putsVar "Nameservers" "$net(CURRENT_NAMESERVER1), $net(CURRENT_NAMESERVER2)"
          putsVar "Hostname" "$MAINHOSTNAME"
        puts "</div>"
        puts "<h1 class='helpTitle'><u>homematicIP-RF (HmIP) Info</u></h1>"
        puts "<div style='display: table; width: 100%;'>"
          putsVar "RF-Module (Firmware)" "$hm(HM_HMIP_DEV) ($hm(HM_HMIP_VERSION))"
          putsVar "Device-Node" "$hm(HM_HMIP_DEVNODE) ($hm(HM_HMIP_DEVTYPE))"
          putsVar "Address" "$hm(HM_HMIP_ADDRESS) ($hm(HM_HMIP_ADDRESS_ACTIVE))"
          putsVar "SGTIN" $hm(HM_HMIP_SGTIN)
          putsVar "Serial" $hm(HM_HMIP_SERIAL)
          putsVar "DutyCycle, CarrierSense" "$HMIP_DUTYCYCLE %, $HMIP_CARRIERSENSE %"
        puts "</div>"
        puts "<h1 class='helpTitle'><u>HomeMatic-RF (HmRF) Info</u></h1>"
        puts "<div style='display: table; width: 100%;'>"
          putsVar "RF-Module (Firmware)" "$hm(HM_HMRF_DEV) ($hm(HM_HMRF_VERSION))"
          putsVar "Device-Node" "$hm(HM_HMRF_DEVNODE) ($hm(HM_HMRF_DEVTYPE))"
          putsVar "Address" "$hm(HM_HMRF_ADDRESS) ($hm(HM_HMRF_ADDRESS_ACTIVE))"
          putsVar "Serial" $hm(HM_HMRF_SERIAL)
          putsVar "DutyCycle, CarrierSense" "$HMRF_DUTYCYCLE %, $HMRF_CARRIERSENSE %"
        puts "</div>"
      puts "</td>"

  puts "</table>"


  cgi_javascript {
    if { "$from" == "internal" } {
      set href ""
      puts "setFooter('');"
    } else {
      if { "$from" != "login" } {
        set href "/pages/index.htm?NoAutoLogin=true"
      } else {
        set href "/"
        set queryparams ""
        set queryparams [cgi_unquote_input $env(QUERY_STRING)]
        set querysid ""
        if { [regexp "sid=(@\[A-Za-z0-9\]*@)" $queryparams dummy querysid] } then {
          set href "login.htm?sid=$querysid"
        }
      }

      puts "var s = \"\";"
      puts "s += \"<table cellspacing='8' >\";"
      puts "s += \"<tbody>\";"
      puts "s += \"<tr>\";"
      puts "s += \"<td style='vertical-align:middle;'>\";"
      puts "s += \"<div class='FooterButton' onclick='goStart()'  style='text-align:center;'>Zur&uuml;ck\";"
      puts "s += \"</div>\";"
      puts "s += \"</td>\";"
      puts "s += \"</tr>\";"
      puts "s += \"</tbody>\";"
      puts "s += \"</table>\";"
      puts "jQuery(\"#footer\").html(s);"
    }

    puts "goStart = function() \{"
    puts "window.location.href=\"$href\";"
    puts "\}"

    puts "loadExtHelp = function()\{"
    puts "  wndHelp = window.open(\"$HM_HELP_URL?lang=$LANGUAGE&vers=$ver(VERSION)&serial=$SERIAL\", \"Hilfe\", \"toolbar=yes,menubar=yes,location=yes,scrollbars=yes,resizable=yes,width=800,height=600\");"
    puts "\}"

    puts "translatePage('#overviewHelpPage');"
    puts "jQuery('#overviewHelpPage').css('display', 'table');"
  }
}


cgi_eval {
#cgi_debug -on
cgi_input
catch {
    import debug
    cgi_debug -on
}

set action "put_page"

http_head

catch { import action }
action_$action
}
