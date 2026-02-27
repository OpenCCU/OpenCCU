#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce ic_common.tcl
sourceOnce common.tcl
loadOnce tclrpc.so

proc logDeviceAttributes {} {
  global dev_descr

  foreach val [array names dev_descr] {
    puts "$val: $dev_descr($val)<br/>"
  }
  puts "<br/><br/>"
}

proc put_error {iface address} {
  puts "<div id=\"ic_deviceparameters\">"
    puts "<div id=\"id_body\">"
      puts "Das Ger&auml;t mit der Seriennummer '$address' vom Interface '$iface' konnte nicht abgefragt werden!"
      puts "</div>"

    puts "</div>"
  puts "</div>"
}

proc put_headerElem {} {
  # The hidden input fields are necessary for the js function "FirmwareUpdate()"
  puts "<input type=\"text\" id=\"global_iface\" class=\"hidden\">"
  puts "<input type=\"text\" id=\"global_address\" class=\"hidden\">"

  puts "<table id=\"devFwOverview\" cellspacing=\"0\" cellpadding=\"0\" class=\"tTable filterTable\">"
   puts "<colgroup>"
    puts "<col style=\"width:35%;\"/>"
    puts "<col style=\"width:20%;\"/>"
    puts "<col style=\"width:55px;\"/>"
    puts "<col style=\"width:10%;\"/>"
     puts "<col style=\"width:10%;\"/>"
     puts "<col style=\"width:10%;\"/>"
   #  puts "<col style=\"width:10%;\"/>"
     puts "<col style=\"width:auto;\"/>"
   puts "</colgroup>"

   puts "<th class=\"DeviceListHead\">\${thName}</th>"
   puts "<th class=\"DeviceListHead\">\${thTypeDescriptor}</th>"
   puts "<th class=\"DeviceListHead\">\${thPicture}</th>"
   puts "<th class=\"DeviceListHead\">\${thSerialNumber}</th>"
   puts "<th class=\"DeviceListHead\">\${thFirmware}</th>"
   puts "<th class=\"DeviceListHead\">\${firmwareAvailOnCCU}</th>"
  # puts "<th class=\"DeviceListHead\">Firmware state</th>"
   puts "<th class=\"DeviceListHead\">\${thAction}</th>"

   put_filter

   puts "<script type=\"text/javascript\">"
     puts "setGlobalIfaceAddress = function(iface, address) {"
       puts "jQuery(\"#global_iface\").val(iface);"
       puts "jQuery(\"#global_address\").val(address);"
     puts "};"
   puts "</script>"
}

proc getFilterElement {param} {
  set html ""
  append html "<div class=\"FilterCaption\" name=\"thFilter\" onclick=\"showFilter('filter_$param');\">Filter</div>"
  append html "<div class=\"FilterBodyWrapper\" id=\"filter_$param\" style=\"display:none;\">"
    append html "<div class=\"FilterBody\">"
      append html "<input class=\"FilterText\" id=\"searchText_$param\"  name=\"DeviceListPage.NameFilterText\" value=\"\" type=\"text\" onkeypress=\"checkEnterEsc(this.id, event.keyCode);\">"
      append html "<div class=\"FilterButton\" name=\"filterSet\" onclick=\"setFilter('filter_$param');\">\${filterSet}</div>"
      append html "<div class=\"FilterButton\" name=\"filterClose\" onclick=\"closeFilter('filter_$param');\">\${filterClose}</div>"
    append html "</div>"
  append html "</div>"
  return $html
}

proc put_filter {} {
  puts "<tr>"
    puts "<th class=\"Filter\" style=\"height:20px\">[getFilterElement NAME]</th>"
    puts "<th class=\"Filter\">[getFilterElement TYPE]</th>"
    puts "<th class=\"Filter\"></th>"
    puts "<th class=\"Filter\">[getFilterElement ADDRESS]</th>"
    puts "<th class=\"Filter\"></th>"
    puts "<th class=\"Filter\"></th>"
    puts "<th class=\"Filter\"></th>"
  puts "</tr>"
}

proc put_end_body {} {
  puts "</table>"
  puts "<script type=\"text/javascript\">"
    puts "translatePage(\"#devFwOverview\");"
  puts "</script>"

}

proc getHTML {val} {
  global iface dev_descr
  set bidcosWiredID "BidCos-Wired"
  set tdID ""

  set html ""
  if { ! [catch {set tmp $dev_descr($val)}]  } {
    set value $dev_descr($val)

    if {[string equal $val "AVAILABLE_FIRMWARE"] == 1} {
      if {([string equal $value "0.0"] == 1) || ([string equal $value "0.0.0"] == 1) || ([string equal $iface $bidcosWiredID] == 1)} {
        # set value $dev_descr(FIRMWARE)
        set value " -- "
      }
    }
    if {[string equal $val "FIRMWARE"] == 1} {
      set html "<td id='deviceFirmware_$dev_descr(ADDRESS)' name='$val'>$value</td>"
    } else {
      set html "<td name='$val'>$value</td>"
    }
  } else {
   set html  "<td name='$val'> -- </td>"
  }
  return $html
}

proc getActionPanel {} {
    global dev_descr iface

    set HmIPIdentifier "HmIP-RF"
    set fw_update_rows ""

   # This was the initial test button > set html "<td><div class=\"DeviceListButton\" name=\"btnConfigure\" onclick=\"alert('OK');\">Einstellen</div><td>"

   set tableCell "<table id=\"id_firmware_table_$dev_descr(ADDRESS)\" class=\"j_translate tTable filterTable noBorder marginAuto\" style=cellspacing=\"0\">"

   if {$iface != $HmIPIdentifier} {
      catch {
        if {([string equal $dev_descr(AVAILABLE_FIRMWARE) "0.0.0"] != 1)  && ($dev_descr(AVAILABLE_FIRMWARE) != $dev_descr(FIRMWARE))} then {
          set fw_update_rows "<tr><td colspan=\"2\" class=\"_CLASS22007 noBorder\" ><span onclick=\"setGlobalIfaceAddress('$iface', '$dev_descr(ADDRESS)');FirmwareUpdate('$dev_descr(TYPE)');\" class=\"CLASS21000\">\${lblUpdate}</span></td></tr>"
        } else {
          # set fw_update_rows "<tr><td colspan=\"2\" class=\"_CLASS22008 noBorder\">- -</td></tr>"
          set fw_update_rows "<tr><td colspan=\"2\" class=\"_CLASS22008 noBorder\"></td></tr>"
        }
      }
   } else {
      # This is a HmIP device
      if {[catch {set firmwareUpdateState $dev_descr(FIRMWARE_UPDATE_STATE)}] == 0} {
        switch $firmwareUpdateState {
          "PERFORMING_UPDATE" {
            set fw_update_rows "<tr><td class=\"_CLASS22006 noBorder\">\${lblDeviceFwPerformUpdate}</td></tr>"
          }

          "NEW_FIRMWARE_AVAILABLE" -
          "DELIVER_FIRMWARE_IMAGE" {
            set helpIdentifier "j_hmIPDeliverFirmwareHelp"

            if {[catch {set devType $dev_descr(TYPE)}] == 0} {
              if {[string first HmIPW- $devType] != -1} {
                set helpIdentifier "j_hmIPWDeliverFirmwareHelp"
              }
            }
             set fw_update_rows "<tr><td class=\"_CLASS22008 noBorder\"><div>\${lblDeviceFwDeliverFwImage}</div><div class=\"StdTableBtnHelp\"><img class=$helpIdentifier height=\"24\" width=\"24\"src=\"/ise/img/help.png\"></div></td></tr>"
          }

          "DO_UPDATE_PENDING" -
          "READY_FOR_UPDATE" {
            # set fw_update_rows "<tr><td>\${lblAvailableFirmwareVersion}</td><td class=\"_CLASS22006\">$dev_descr(AVAILABLE_FIRMWARE)</td></tr>"
            append fw_update_rows "<tr><td colspan=\"2\" class=\"_CLASS22007 noBorder\"><span onclick=\"setGlobalIfaceAddress('$iface', '$dev_descr(ADDRESS)');FirmwareUpdate('$dev_descr(TYPE)');\" class=\"CLASS21000\">\${lblUpdate}</span></td></tr>"
          }
          
          "LIVE_NEW_FIRMWARE_AVAILABLE" {
            #new live update firmware available -> show update button if device supports it
            #i.e. hap and drap versions smaller than 2.1 do not support it, so we check that here
            if { (([string compare "HmIPW-DRAP" $dev_descr(TYPE)] == 0)
            || ([string compare "HmIP-HAP" $dev_descr(TYPE)] == 0)
            || ([string compare "HmIP-HAP-A" $dev_descr(TYPE)] == 0)
            || ([string compare "HmIP-HAP-B1" $dev_descr(TYPE)] == 0)
            || ([string compare "HmIP-HAP JS1" $dev_descr(TYPE)] == 0))
            && ([regexp {[0-1]\.[0-9]*\.[0-9]*} $dev_descr(FIRMWARE)] || [regexp {2\.0\.[0-9]*} $dev_descr(FIRMWARE)]) } {
              append fw_update_rows "<tr><td colspan=\"2\" class=\"_CLASS22007 noBorder\"><span onclick=\"ShowInfoMsg(translateKey('hintDeviceDoesNotSupportAction'))\" class=\"CLASS21000\">\${lblUpdate}</span></td></tr>"
            } else {
              if {([string compare "HmIP-HAP2" $dev_descr(TYPE)] == 0)
              || ([string compare "HmIP-HAP2-A" $dev_descr(TYPE)] == 0)
              } {
                append fw_update_rows "<tr><td colspan=\"2\" class=\"_CLASS22007 noBorder\"><span onclick=\"ShowInfoMsg(translateKey('hintAutomaticDeviceUpdate'))\" class=\"CLASS21000\">\${lblUpdate}</span></td></tr>"
              } else {
                append fw_update_rows "<tr><td colspan=\"2\" class=\"_CLASS22007 noBorder\"><span onclick=\"setGlobalIfaceAddress('$iface', '$dev_descr(ADDRESS)');FirmwareUpdate('$dev_descr(TYPE)');\" class=\"CLASS21000\">\${lblUpdate}</span></td></tr>"
              }
            }
           
          }
          "LIVE_DELIVER_FIRMWARE_IMAGE" {
            set fw_update_rows "<tr><td class=\"_CLASS22006 noBorder\">\${lblDeviceFwPerformUpdate}</td></tr>"
          }
        }
      } else {
        # This should never be reached....
        puts "<script type=\"text/javascript\">conInfo(\"HmIP - FIRMWARE_UPDATE_STATE unknown error\");</script>"
      }
    }

    append tableCell $fw_update_rows

    append tableCell "</table>"
    return "<td style=\"text-align:center;\" name=\"j_actionTD\">$tableCell</td>"
}

proc put_table_row {} {
  global dev_descr iface

  puts "<tr>"
    puts "<td id=\"name\" name=\"NAME\"></td>"
    puts "[getHTML TYPE]"
    puts "<td class=\"DeviceListThumbnail\"><div id=\"pic\" class=\"thumbnail\" onmouseout=\"picDivHide(jg_250);\"></td>"
    puts "[getHTML ADDRESS]"
    puts "[getHTML FIRMWARE]"
    puts "[getHTML AVAILABLE_FIRMWARE]"
    # puts "[getHTML FIRMWARE_UPDATE_STATE]"
    puts "[getActionPanel]"

  puts "</tr>"

  puts "<script type=\"text/javascript\>"
    puts "var dev = DeviceList.getDeviceByAddress(\"$dev_descr(ADDRESS)\");"
    puts "var nameTD = jQuery(\"#name\");"
    puts "var picDIV = jQuery(\"#pic\");"

    puts "nameTD.prop(\"id\", \"name\" + dev.id);"
    puts "nameTD.html(dev.name);"

    puts "picDIV.prop(\"id\", \"pic\" + dev.id);"
    puts "picDIV.html(dev.thumbnailHTML);"
    puts "picDIV.bind(\"mouseover\", function() {picDivShow(jg_250, dev.typeName, 250, '', this);});"

    puts ""

  puts "</script>"

}

proc put_actionHelp {} {
  global dev_descr

  puts "<script type=\"text/javascript\">"
    puts "var tooltipHTML = \"<div>\"+translateKey(\"tooltipHmIPDeliverFirmwareImage\");+\"</div>\","
    puts "tooltipElem = jQuery(\".j_hmIPDeliverFirmwareHelp\") ;"
    puts "tooltipElem.data('powertip', tooltipHTML);"
    puts "tooltipElem.powerTip({placement: 'sw', followMouse: false});"

    # Wired-Tooltip
    puts "var wired_tooltipHTML = \"<div>\"+translateKey(\"tooltipHmIPWDeliverFirmwareImage\");+\"</div>\","
    puts "wired_tooltipElem = jQuery(\".j_hmIPWDeliverFirmwareHelp\") ;"
    puts "wired_tooltipElem.data('powertip', wired_tooltipHTML);"
    puts "wired_tooltipElem.powerTip({placement: 'sw', followMouse: false});"

  puts "</script>"
}

cgi_eval {
  cgi_input
  #cgi_debug -on

    http_head

  if {[session_requestisvalid 0] > 0} then {

    catch {import deviceList}

    # convert the imported deviceList (which is in fact a string) into a tcl list.
    set lDeviceList [lrange [string map {\{ "" \} ""} $deviceList] 0 end]

    put_headerElem

    for { set i 0 } { $i <= [llength $lDeviceList] } { incr i 2} {
      array_clear dev_descr
      set address [lindex $lDeviceList $i]
      set iface [lindex $lDeviceList [expr $i + 1]]
      if {([string equal $address ""] != 1) && ([string equal $iface ""] != 1)} {
        if { [catch {array set dev_descr [xmlrpc $iface_url($iface) getDeviceDescription [list string $address]] } ] } then {
          # put_error $iface $address
        } else {
          if {
            ([string length $dev_descr(TYPE)] > 0)
            && ([string equal $dev_descr(TYPE) "HM-RCV-50"] != 1)
            && ([string equal $dev_descr(TYPE) "HMW-RCV-50"] != 1)
            && ([string equal $dev_descr(TYPE) "HmIP-RCV-50"] != 1)
            && ([string first "VIR-" $dev_descr(TYPE)] == -1)
            && ([string equal $dev_descr(TYPE) "HM-CC-VG-1"] != 1)
            && ([string equal $dev_descr(TYPE) "HmIP-HEATING"] != 1)
            } {
            put_table_row
          }
          #logDeviceAttributes
        }
      }
    }
    put_end_body
    put_actionHelp

    puts "<script type=\"text/javascript\">"

      puts "checkEnterEsc = function(elmId, key) {"
        puts "var filterName = elmId.split(\"_\")\[1\];"
        puts "switch (key) {"
          puts "case 13:"
            puts "setFilter(\"filter_\" + filterName);"
            #puts "closeFilter(\"filter_\" + filterName);"
            puts "break;"
          puts "case 27:"
            puts "closeFilter(\"filter_\" + filterName);"
            puts "break;"
        puts "}"
      puts "};"

      puts "showFilter = function(filter) {"
        puts "jQuery(\"#\"+ filter).show();"
        puts "jQuery(\"#searchText_\" + filter.split(\"_\")\[1\]).focus();"
      puts "};"

      puts "closeFilter = function(filter) {"
        puts "jQuery(\"#\"+ filter).hide();"
      puts "};"

      puts "resetFilter = function() {"
        puts "jQuery(\"\[name='invisible'\]\").show().attr(\"name\", \"\");"
      puts "};"

      puts "setFilter = function(filter) {"
        puts "jQuery(\"#\"+ filter).hide();"

        # searchFilter = NAME, TYPE or ADDRESS
        puts "var searchFilter = filter.split(\"_\")\[1\];"
        puts "var searchText = jQuery(\"#searchText_\" + searchFilter).val().toLowerCase();"

        # filterElem = NAME, TYPE or ADDRESS
        puts "arElements = jQuery(\"\[name='\"+searchFilter+\"'\]\");"
          puts "jQuery.each(arElements, function(index, tableCell) {"
            puts "var cellText = jQuery(tableCell).html().toLowerCase();"
            puts "if (cellText.indexOf(searchText) < 0) {"
              puts "jQuery(tableCell).parent().attr(\"name\", \"invisible\").hide();"
            puts "} else {"
              puts "jQuery(tableCell).parent().attr(\"name\", \"\").show();"
            puts "}"

          puts "})"

      puts "};"

      set footerHtml  ""
      append footerHtml "<table style='backgroud-color:white' border='0' cellspacing='8'>"
        append footerHtml "<tr>"
         append footerHtml "<td  style='text-align:center; vertical-align:middle;'><div class='FooterButton' onclick='WebUI.goBack();'>\${footerBtnPageBack}</div></td>"
          append footerHtml "<td  style='text-align:center; vertical-align:middle;'><div class='FooterButton CLASS04312' onclick='resetFilter();'>\${footerBtnResetFilter}</div></td>"
          append footerHtml "<td  style='text-align:center; vertical-align:middle;'><div class='FooterButton' onclick='WebUI.enter(DeviceFirmware);'>\${submenuDeviceFirmware}</div></td>"

        append footerHtml "</tr>"
      append footerHtml "</table>"

      puts "setFooter(\"$footerHtml\");"
      puts "setPath(\"<span onclick='WebUI.enter(SystemConfigPage);'>\"+translateKey('menuSettingsPage')+\"</span> &gt; \"+translateKey('submenuDeviceFirmwareInformation'));"

    puts "</script>"

  }
}