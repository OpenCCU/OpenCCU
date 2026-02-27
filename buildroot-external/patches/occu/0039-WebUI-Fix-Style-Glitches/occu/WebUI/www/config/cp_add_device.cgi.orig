#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl

load tclrega.so
load tclrpc.so

set portnumber 2001
catch { source "/etc/eq3services.ports.tcl" }
if { [info exists EQ3_SERVICE_RFD_PORT] } {
  set portnumber $EQ3_SERVICE_RFD_PORT
}
set RFD_URL "bin://127.0.0.1:$portnumber"

set portnumber 2000
catch { source "/etc/eq3services.ports.tcl" }
if { [info exists EQ3_SERVICE_HS485D_PORT] } {
  set portnumber $EQ3_SERVICE_HS485D_PORT
}
set HS485D_URL "bin://127.0.0.1:$portnumber"


proc getButton {class onclick title} {
  set html ""
  append html "<div class='$class' style='display:table; text-align:center; height:50px; width:110px' onclick='$onclick'>"
    append html "<span style='font-size: 11.9px !important; display:table-cell; vertical-align:middle'>$title</span>"
  append html "</div>"

  return $html
}

proc getButtonWired {class onclick title} {
  set html ""
  append html "<div class='$class' style='display:table; text-align:center; height:50px; width:110px' onclick='$onclick'>"
    append html "<span style='font-size:11px! important; display:table-cell; vertical-align:middle'>$title</span>"
  append html "</div>"

  return $html
}

proc initJavascript {} {
  cgi_javascript {
    puts {
      showSection = function(section){
        var thisSection = jQuery("body").data(section);
        if(thisSection) {
          jQuery('#section'+section).show();
        } else {
          if (typeof thisSection == "undefined") {
            homematic('Interface.isPresent', {"interface": section}, function(result, error) {
              if (result == true)
              {
                jQuery('#section'+section).show();
                dlgPopup.readaptSize();
              }
            });
          }
        }
      }
    }
  }
}

proc putSectionBidCosRF {} {

  set html ""
    append html "<tr id='sectionBidCos-RF' class='CLASS21202 hidden'>"
      append html "<td class='CLASS21207'>"
        #append html "\${dialogNewDevicesTDBidCosRF}"
        append html "<img src='/ise/img/homematic90Deg.png'>"
      append html "</td>"
      append html "<td class='CLASS21208' align='left'>"
        append html "\${dialogNewDevicesBidCosRFLbl1}"
        append html "\${dialogNewDevicesBidCosRFLbl2}"
        append html "<br /><br />"

        append html "<div class='popupControls CLASS21205'>"
          append html "<table>"
            append html "<tr>"
              append html "<td class='CLASS21206'>"
                append html "<div id='time_bar' class='CLASS21215' style='width:100%;'>"
                  append html "\${dialogNewDevicesBidCosRFFetchmodeNotActive}"
                append html "</div>"
              append html "</td>"
              append html "<td class='CLASS21209'>"
                append html [getButton {CLASS21210 colorGradient50px} {buttonPressed(this); rf_install_mode(true)} \${dialogNewDevicesAddDeviceBtn}]
              append html "</td>"
            append html "</tr>"
          append html "</table>"
        append html "</div>"
      append html "</td>"

      append html "<td  style='text-align:left;' class='CLASS21208'>"
        append html "\${dialogNewDevicesBidCosRFLbl3}"
        append html "\${dialogNewDevicesBidCosRFLbl5}"

        append html "<table style='table-layout:fixed; width: 100%; padding-right:15px'>"
        append html "<colgroup>"
          append html "<col style='width: 23%;'>"
          append html "<col style='width: auto;'>"
          append html "<col style='width: 110px;'>"
        append html "</colgroup>"

          append html "<tr>"
            append html "<td>\${dialogNewDevicesBidCosRFLbl4}</td>"
            append html "<td>"
              append html "<input id='text_serial' size='28' name='serial'>"
            append html "</td>"

            append html "<td>"
              append html "<div class='popupControls CLASS21205'>"
                append html "<table>"
                  append html "<tr>"
                    append html "<td class='CLASS21209'>"
                    append html [getButton {CLASS21210 colorGradient50px} {buttonPressed(this);  rf_serial()} \${dialogNewDevicesAddDeviceBtn}]
                    append html "</td>"
                  append html "</tr>"
                append html "</table>"
              append html "</div>"
            append html "</td>"


          append html "</tr>"
        append html "</table>"
      append html "</td>"
    append html "</tr>"
    append html "<script type='text/javascript'>"
      append html "showSection('BidCos-RF');"
    append html "</script>"
  return $html
}

proc putSectionWiredRF {} {
  set html ""
  append html "<tr id='sectionBidCos-Wired' class='CLASS21202 hidden'>"

    append html "<td class='CLASS21212'>"
      append html "<img src='/ise/img/homematicWired90Deg.png'>"
    append html "</td>"
    append html "<td  style='text-align:left;' class='CLASS21208'>"
      append html "\${dialogNewDevicesBidCosWiredLbl3}"
      append html "\${dialogNewDevicesBidCosWiredLbl4}"

      append html "<div class='popupControls CLASS21205'>"
        append html "<table>"
          append html "<tr>"
            append html "<td class='CLASS21206'></td>"
            append html "<td class='CLASS21209'>"
              append html [getButtonWired {CLASS21210 colorGradient50px} {buttonPressed(this);  wir_search()} \${dialogNewDevicesBidCosWiredBtn}]
            append html "</td>"
           append html "</tr>"
        append html "</table>"
      append html "</div>"

    append html "</td>"
    append html "<td  style='text-align:left;' class='CLASS21208'>"
      append html "\${dialogNewDevicesBidCosWiredLbl1}"
      append html "\${dialogNewDevicesBidCosWiredLbl2}"
    append html "</td>"

  append html "</tr>"

  append html "<script type='text/javascript'>"
    append html "showSection('BidCos-Wired');"
  append html "</script>"

}

# Creates the HmIP Section
proc putSectionHMIP {} {
  set html ""
  set iFace "HmIP-RF"

  append html "<tr id='section$iFace' class='CLASS21202 hidden'>"

   append html "<td class='CLASS21207'>"
   #append html "HmIP"
   append html "<img src='/ise/img/homematicIP90Deg.png'>"
   append html "</td>"

    append html "<td class='CLASS21208' align='left'>"
    append html "\${dialogNewDevicesHmIPWithInternet}"
    append html "<div class='popupControls CLASS21205'>"
      append html "<table>"
        append html "<tr>"
          append html "<td colspan='2'>"
            append html "\${dialogNewDevicesHmIPRFLbl1}"
          append html "</td>"
         append html "</tr>"

        append html "<tr>"
          append html "<td class='CLASS21206'><div id='teachCounter_$iFace' class='CLASS21215' style='width:100%;'>\${dialogNewDevicesBidCosRFFetchmodeNotActive}</div></td>"
          append html "<td>"
          append html [getButton {CLASS21210 colorGradient50px} {buttonPressed(this); hmip_install_mode("HmIP-RF")} \${dialogNewDevicesHmIPAddDeviceBtn}]
          append html "</td>"
        append html "</tr>"
      append html "</table>"
    append html "</div>"
   append html "</td>"

   append html "<td class='CLASS21208' align='left'>"
    append html "\${dialogNewDevicesHmIPWithoutInternet}"
    append html "<div class='popupControls CLASS21205'>"
      append html "<table>"

        append html "<tr>"
          append html "<td colspan='2'>"
            append html "\${dialogNewDevicesHmIPRFLbl2}"
          append html "</td>"
        append html "</tr>"

        append html "<tr>"
          append html "<td class='CLASS21206'>"

            append html "<table>"
              append html "<colgroup>"
                append html "<col style='width: 50px;'>"
                append html "<col style='width: auto;'>"
              append html "</colgroup>"

              append html "<tr>"
                append html "<td style='text-align: right'>"
                  append html "<span>\${lblTeachInKEY}</span>"
                append html "</td>"
                append html "<td>"
                  append html "<input id='keyHmIPLocal_$iFace' type='text' style='width:390px'>"
                append html "</td>"
              append html "</tr>"

              append html "<tr>"
                append html "<td style='text-align: right'>"
                  append html "<span>\${lblTeachInSGTIN}</span>"
                append html "</td>"
                append html "<td>"
                  append html "<input id='serialHmIPLocal_$iFace' type='text' style='width:390px;'>"
                append html "</td>"
              append html "</tr>"

            append html "</table>"

            append html "<table style='table-layout:fixed; width: 100%; padding-right:15px'>"
            append html "<colgroup>"
              append html "<col style='width: auto;'>"
              append html "<col style='width: 105px;'>"
            append html "</colgroup>"
              append html "<tr>"
                append html "<td><div id='teachCounterLocal_$iFace' class='CLASS21215'>\${dialogNewDevicesBidCosRFFetchmodeNotActive}</div></td>"
                append html "<td class='CLASS21209'>"
                  append html [getButton {CLASS21210 colorGradient50px} {buttonPressed(this); hmip_install_mode("HmIP-RF", "local")} {${dialogNewDevicesHmIPAddDeviceBtn}${lblLocal}}]
                append html "</td>"

              append html "</tr>"
            append html "</table>"

          append html "</td>"
        append html "</tr>"

      append html "</table>"
    append html "</div>"
   append html "</td>"
  append html "</tr>"

  append html "<script type='text/javascript'>"
    append html "showSection('HmIP-RF');"
  append html "</script>"

  return $html
}

# Creates the HmIP-Wired Section
proc putSectionHMIPWired {} {
  set html ""

  set iFace "HmIP-Wired"

  append html "<tr id='section$iFace' class='CLASS21202 hidden'>"

   append html "<td class='CLASS21207'>"
   append html "HmIP-Wired"
   #append html "<img src='/ise/img/homematicIP90Deg.png'>"
   append html "</td>"

    append html "<td class='CLASS21208' align='left'>"
    append html "\${dialogNewDevicesHmIPWithInternet}"
    append html "<div class='popupControls CLASS21205'>"
      append html "<table>"
        append html "<tr>"
          append html "<td colspan='2'>"
            append html "\${dialogNewDevicesHmIPRFLbl1}"
          append html "</td>"
         append html "</tr>"

        append html "<tr>"
          append html "<td class='CLASS21206'><div id='teachCounter_$iFace' class='CLASS21215' style='width:100%;'>\${dialogNewDevicesBidCosRFFetchmodeNotActive}</div></td>"
          append html "<td>"
          append html [getButton {CLASS21210 colorGradient50px} {buttonPressed(this); hmip_install_mode("HmIP-Wired")} \${dialogNewDevicesHmIPAddDeviceBtn}]
          append html "</td>"
        append html "</tr>"
      append html "</table>"
    append html "</div>"
   append html "</td>"

   append html "<td class='CLASS21208' align='left'>"
    append html "\${dialogNewDevicesHmIPWithoutInternet}"
    append html "<div class='popupControls CLASS21205'>"
      append html "<table>"

        append html "<tr>"
          append html "<td colspan='2'>"
            append html "\${dialogNewDevicesHmIPRFLbl2}"
          append html "</td>"
        append html "</tr>"

        append html "<tr>"
          append html "<td class='CLASS21206'>"

            append html "<table>"
              append html "<colgroup>"
                append html "<col style='width: 50px;'>"
                append html "<col style='width: auto;'>"
              append html "</colgroup>"

              append html "<tr>"
                append html "<td style='text-align: right'>"
                  append html "<span>\${lblTeachInKEY}</span>"
                append html "</td>"
                append html "<td>"
                  append html "<input id='keyHmIPLocal_$iFace' type='text' style='width:390px'>"
                append html "</td>"
              append html "</tr>"

              append html "<tr>"
                append html "<td style='text-align: right'>"
                  append html "<span>\${lblTeachInSGTIN}</span>"
                append html "</td>"
                append html "<td>"
                  append html "<input id='serialHmIPLocal_$iFace' type='text' style='width:390px;'>"
                append html "</td>"
              append html "</tr>"

            append html "</table>"

            append html "<table style='table-layout:fixed; width: 100%; padding-right:15px'>"
            append html "<colgroup>"
              append html "<col style='width: auto;'>"
              append html "<col style='width: 105px;'>"
            append html "</colgroup>"
              append html "<tr>"
                append html "<td><div id='teachCounterLocal_$iFace' class='CLASS21215'>\${dialogNewDevicesBidCosRFFetchmodeNotActive}</div></td>"
                append html "<td class='CLASS21209'>"
                  append html [getButton {CLASS21210 colorGradient50px} {buttonPressed(this); hmip_install_mode("HmIP-Wired", "local")} {${dialogNewDevicesHmIPAddDeviceBtn}${lblLocal}}]
                append html "</td>"

              append html "</tr>"
            append html "</table>"

          append html "</td>"
        append html "</tr>"

      append html "</table>"
    append html "</div>"
   append html "</td>"
  append html "</tr>"

  append html "<script type='text/javascript'>"
    append html "showSection('HmIP-Wired');"
  append html "</script>"
  return $html
}

proc action_put_page {} {
  global env RFD_URL
  
  set serial ""
  catch { import serial }


  division {class="popupTitle j_translate"} {
    #puts "Ger&auml;te anlernen"
    puts "\${dialogNewDevicesTitle}"
  }

puts "<div class='CLASS21200 j_translate'>"

  initJavascript

  puts "<table class='popupTable' border='1' style='table-layout:fixed; width:100%;'>"
    puts "<colgroup>"
      puts "<col style='width:90px;'>"
      puts "<col style='width:359px;'>"
      puts "<col style='width:462px;'>"
    puts "</colgroup>"

    # Start section BidCos-RF
    puts [putSectionBidCosRF]
    # End section BidCos-RF

    # Start section Wired-RF
    puts [putSectionWiredRF]
    # End section Wired-RF

    # Start section HM IP
    puts [putSectionHMIP]
    # End section HM IP

    # Start section HM IP Wired
    puts [putSectionHMIPWired]
    # End section HM IP Wired
  puts "</table>"

puts "</div>"

  division {class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS21209"} {
          division {class="CLASS21213 colorGradient50px"} {onClick="buttonPressed(this); OnBack();"} {
            #puts "Zur&uuml;ck"
            puts "\${dialogBack}"
          }
        }
        table_data {class="CLASS21209"} {
          division {id="cp_new_devices_button"} {class="CLASS21216 colorGradient50px"} {onClick="buttonPressed(this); OnInbox();"} {
            #puts "Posteingang"
            puts "\${dialogNewDevicesfooterBtnDeviceInputA}"
            br
            #puts "([get_new_device_count] neue Ger&auml;te)"
            puts "([get_new_device_count] \${dialogNewDevicesfooterBtnDeviceInputB})"
          }
        }
        table_data {class="CLASS21206"} {}
      }
    }
  }
  puts ""
  cgi_javascript {

    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts "var installTimerHmIP = 0;"
    puts {
      update_new_device_count = function() {
        var pb = "action=get_new_device_count";
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            var devcount=transport.responseText.replace(/[^0-9]/g, "");
            for(var i=0;i<document.getElementById("cp_new_devices_button").childNodes.length;i++){
              var oldval=document.getElementById("cp_new_devices_button").childNodes[i].nodeValue;
              if(oldval)document.getElementById("cp_new_devices_button").childNodes[i].nodeValue=oldval.replace(/\d+/g, devcount);
            }
          }
        };
        new Ajax.Request(url, opts);
      }
    }
    puts {
      install_time_remain=0;

      buttonPressed = function(elem) {
        var jElem = jQuery(elem),
        classBtnPressed = "borderWidth2Px"
        jElem.addClass(classBtnPressed);
        var loop = 0;
        var detectChange = setInterval(function() {
          loop++;
          if (jElem.hasClass(classBtnPressed) || loop >= 20) {
            window.setTimeout(function() {jElem.removeClass("borderWidth2Px");},500);
            clearInterval(detectChange);
          }
        }, 10);

      }

      update_time_bar = function() {
        install_time_remain-=1;
        if((install_time_remain%5)==0){
          var pb = "action=get_install_status";
          var opts = {
            postBody: pb,
            sendXML: false,
            onSuccess: function(transport) {
              if (!transport.responseText.match(/^Success/g)){
                cp_adddev_updater.stop();
                return;
              }
              var result=transport.responseText.split(" ");
              var serial="";
              if(result.length >= 3)serial=result[2];
              if(serial != ""){
                cp_adddev_updater.stop();
                dlgPopup.hide();
                dlgPopup.setWidth(400);
                dlgPopup.LoadFromFile(url, "action=put_key_dialog&serial="+serial);
              }else{
                install_time_remain=result[1];
                if(install_time_remain<=0){
                  if ($("time_bar")) { document.getElementById("time_bar").firstChild.nodeValue= translateKey("dialogNewDevicesBidCosRFFetchmodeNotActive"); } /*"Anlernmodus nicht aktiv"*/
                  cp_adddev_updater.stop();
                  update_new_device_count();
                  install_time_remain=0;
                }
              }
            }
          };
          new Ajax.Request(url, opts);
        }
        if(install_time_remain<=0){
          if ($("time_bar")) { $("time_bar").firstChild.nodeValue= translateKey("dialogNewDevicesBidCosRFFetchmodeNotActive");} /*"Anlernmodus nicht aktiv"*/
          cp_adddev_updater.stop();
          update_new_device_count();
          install_time_remain=0;
        }else{
          //if ($("time_bar")) { $("time_bar").firstChild.nodeValue="Anlernmodus noch "+String(install_time_remain)+"s aktiv"; }
          if ($("time_bar")) { $("time_bar").firstChild.nodeValue=translateKey("dialogNewDevicesBidCosRFFetchmodeActiveA")+String(install_time_remain)+translateKey("dialogNewDevicesBidCosRFFetchmodeActiveB"); }
        }
      }


      getInstallModeTimer = function(interface, mode) {
        var remainingTimeElm = (mode == "local") ? jQuery("#teachCounterLocal_" + interface) : jQuery("#teachCounter_" + interface),
        iFace = interface;
        window.setTimeout(function() {
          homematic ('Interface.getInstallMode', {'interface': iFace}, function(result) {
            if (result >= 1) {
              remainingTimeElm.text(translateKey("dialogNewDevicesBidCosRFFetchmodeActiveA") + result + translateKey("dialogNewDevicesBidCosRFFetchmodeActiveB"));
              getInstallModeTimer(iFace, mode);
              if (result == 40 || result == 30 || result == 20) {
                update_new_device_count();
              }
            } else {
              remainingTimeElm.text(translateKey("dialogNewDevicesBidCosRFFetchmodeNotActive"));
              update_new_device_count();
            }
            installTimerHmIP = result;
          });
        }, 400);
      };

      hmip_install_mode_stop = function() {
         var iFace = 'HmIP-RF'
         if(jQuery("body").data("HmIP-RF")) {
          homematic('Interface.setInstallModeHMIP',{
            'installMode' : 'STOP',
            'interface': iFace,
            'on': 'false',
            'time' : 0,
            'address': '',
            'key' : '',
            'keymode' : ''
            }
          );
        }
      };

      hmip_install_mode_start = function(interface, mode) {
        var devAddress = "",
         devKey = "",
         devKeyMode = "",
         installTime = 60;

         var iFace = interface;

        if (mode == "local") {
          devAddress = jQuery("#serialHmIPLocal_" + iFace).val().replace(/-/g,"").toUpperCase();
          devKey = jQuery("#keyHmIPLocal_" + iFace).val().replace(/-/g,"").toUpperCase();
          devKey = (devKey.length < 32) ? convertHmIPKeyBase32ToBase16(devKey) : devKey;
          devKeyMode = 'LOCAL';

          homematic('Interface.setInstallModeHMIP',{
            'installMode' : 'LOCAL',
            'interface': iFace,
            'on': 'true',
            'time' : installTime,
            'address': devAddress,
            'key' : devKey,
            'keymode' : devKeyMode
            }
          );
        } else {
          homematic('Interface.setInstallModeHMIP',{
            'installMode' : 'ALL',
            'interface': iFace,
            'on': 'true',
            'time' : installTime,
            'address': "",
            'key' : "",
            'keymode' : ""
          });
        }
        getInstallModeTimer(iFace, mode);
      };

      hmip_install_mode = function(interface, mode) {

        var iFace = interface;

        if(jQuery("body").data("BidCos-RF")) {
          rf_install_mode(false);
        }
        if (installTimerHmIP > 0) {
          // Stop a running hmip install mode so the timer is set to 0
          homematic('Interface.setInstallModeHMIP',{
            'installMode' : 'STOP',
            'interface': iFace,
            'on': 'false',
            'time' : 0,
            'address': '',
            'key' : '',
            'keymode' : ''
            }, function() {
              hmip_install_mode_start(iFace, mode);
            }
          );
        } else {
          hmip_install_mode_start(iFace,mode);
        }
      };

      rf_install_mode = function(activate) {
        if (activate) {
          hmip_install_mode_stop();
        }
        var pb = "action=rf_install_mode";
        pb += "&activate="+activate;
        if(!activate && cp_adddev_updater)cp_adddev_updater.stop();
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            if (!transport.responseText.match(/^Success/g)){
              //alert("BidCoS-RF Anlernmodus konnte nicht aktiviert werden.");
              alert(translateKey("dialogNewDevicesError4"));
            }
            result=transport.responseText.split(" ");
            install_time_remain=result[1];
            if(install_time_remain > 0){  
              install_time_remain++;
              if(!cp_adddev_updater){
                cp_adddev_updater=new PeriodicalExecuter(update_time_bar, 1);
              }else if(!cp_adddev_updater.timer){
                cp_adddev_updater.registerCallback();
              }
            }else{
              install_time_remain=0;
            }
            update_time_bar();
          },
          onFailure: function(transport) {
            //alert("BidCoS-RF Anlernmodus konnte nicht aktiviert werden.");
            alert(translateKey("dialogNewDevicesError4"));
          }
        };
        new Ajax.Request(url, opts);
      }
    }
    puts {
      rf_serial = function() {
        hmip_install_mode_stop();
        var pb = "action=rf_serial&";
        pb += "serial="+document.getElementById("text_serial").value;
        Cursor.set(Cursor.WAIT);
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            Cursor.set(Cursor.NORMAL);
            if (transport.responseText.match(/^Success/g)){
              update_new_device_count();
              document.getElementById("text_serial").value="";
            } else if (transport.responseText.match(/^KeyMismatch/g)){
              rf_install_mode(false);
              if(cp_addev_updater)cp_adddev_updater.stop();
              dlgPopup.hide();
              dlgPopup.setWidth(400);
              dlgPopup.LoadFromFile(url, "action=put_key_dialog&serial="+document.getElementById("text_serial").value+"&with_serial=1");
            } else {
              //alert("BidCoS-RF Anlernen mit Seriennummer "+document.getElementById("text_serial").value+ unescape(" fehlgeschlagen. Bitte %FCberpr%FCfen Sie die Seriennummer."));
              alert(translateKey("dialogNewDevicesError1a")+document.getElementById("text_serial").value+ translateKey("dialogNewDevicesError1b"));
            }
          },
          onFailure: function(transport) {
            Cursor.set(Cursor.NORMAL); 
          }
        };
        new Ajax.Request(url, opts);
      }
    }
    puts {
      wir_search = function() {
        var pb = "action=wir_search";
        CreateCPPopup2(url, "action=wait_page_wir_search");
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            Popup2Close();
            if (transport.responseText.match(/^Success/g)){
              update_new_device_count();
            } else {
              //alert(unescape("BidCoS-Wired Ger%E4te suchen fehlgeschlagen."));
              alert(translateKey("dialogNewDevicesError2"));
            }
          },
          onFailure: function(transport) {
            Popup2Close();
          }
        };
        new Ajax.Request(url, opts);
      }
    }
    puts {
      OnInbox = function() {
        rf_install_mode(false);
        hmip_install_mode_stop();
        PopupClose();
        WebUI.enter(NewDeviceListPage, {"fromTeachIn":true});
      }
      OnBack = function() {
        if (jQuery("body").data("BidCos-RF")) {
          rf_install_mode(false);
        }
        if (jQuery("body").data("HmIP-RF")) {
          hmip_install_mode_stop();
        }
        PopupClose();
      }
    }
    catch { 
      set install_time_remain [xmlrpc $RFD_URL getInstallMode] 
      if { $install_time_remain } {
        puts "install_time_remain=$install_time_remain;"
        puts {
          if(!cp_adddev_updater)cp_adddev_updater=new PeriodicalExecuter(update_time_bar, 1);
          else if(!cp_adddev_updater.timer)cp_adddev_updater.registerCallback();
          update_time_bar();
        }
      }        
    }
    catch {
      import call_js
      puts "$call_js;"
    }

    puts "translatePage('#messagebox');"
    puts "dlgPopup.readaptSize();"

  }
}



proc action_put_key_dialog {} {
  global env
  
  import serial
  set with_serial 0
  catch { import with_serial }
  
  division {class="popupTitle"} {
    #puts "Ger&auml;te anlernen - Sicherheitsabfrage"
    puts "\${dialogNewDevicesErrorSecKeyTitle}"
  }
  division {class="CLASS21200"} {
    table {class="popupTable"} {border="1"} {
      table_row {class="CLASS21202"} {
        table_data {align="left"} {class="CLASS21203"} {
          #puts "Sie haben gerade versucht, das Ger&auml;t $serial"
          puts "\${dialogNewDevicesErrorSecKeyLbl1} $serial"
          if { $with_serial } {
            # durch Eingabe der Seriennummer
            puts "\${dialogNewDevicesErrorSecKeyLbl1a}"
          } else {
            # im Anlernmodus
            puts "\${dialogNewDevicesErrorSecKeyLbl1b}"
          }
          # anzulernen. Dieser Vorgang konnte nicht durchgef&uuml;hrt werden.
          puts "\${dialogNewDevicesErrorSecKeyLbl1c}"

          br
          #puts "Wahrscheinlich ist diesem Ger&auml;t ein dem System unbekannter System-Sicherheitsschl&uuml;ssel"
          #puts "zugeordnet. Bitte geben Sie den zum Ger&auml;t geh&ouml;renden System-Sicherheitsschl&uuml;ssel ein und"
          #puts "starten den Anlernvorgang erneut."

          puts "\${dialogNewDevicesErrorSecKeyLbl1d}"
          puts "\${dialogNewDevicesErrorSecKeyLbl1e}"
          puts "\${dialogNewDevicesErrorSecKeyLbl1f}"

          table {class="CLASS21204"} {width="100%"} {
            table_row {
              td {width="10"} {}
              #td "System-Sicherheitsschl&uuml;ssel:"
              td "\${dialogNewDevicesErrorSecKeyLbl1g}"
              table_data {
                cgi_text aes_key= {id="text_aes_key"} {width="50"} {type="password"}
              }
            }
          }
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS21209"} {
          division {class="CLASS21213"} {onClick="buttonPressed(this); cancel();"} {
            #puts "Abbrechen"
            puts "\${btnCancel}"
          }
        }
        table_data {class="CLASS21209"} {
          division {class="CLASS21214"} {onClick="buttonPressed(this); try_again();"} {
            #puts "Schl&uuml;ssel setzen und erneut versuchen"
            puts "\${dialogNewDevicesBtnSetKeyAndTryAgain}"
          }
        }
        table_data {class="CLASS21206"} {}
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    
    puts {
      try_again = function() {
        var pb = "action=set_temp_key&";
        pb += "key="+document.getElementById("text_aes_key").value;
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            if (transport.responseText.match(/^Success/g)){
              go_back();
            } else {
              //alert(unescape("Tempor%E4rer System-Sicherheitsschl%FCssel konnte nicht gesetzt werden."));
              alert(translateKey('dialogNewDevicesError3'));
            }
          }
        };
        new Ajax.Request(url, opts);
      }
      cancel = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(800);
        dlgPopup.LoadFromFile(url);
      }
    }
    
    puts "go_back = function() \{"
    if {$with_serial} {
      puts "  var pb=\"&serial=$serial&call_js=rf_serial()\";"
    } else {
      puts "  var pb=\"&call_js=rf_install_mode(true)\";"
    }
    puts {
      dlgPopup.hide();
      dlgPopup.setWidth(800);
      dlgPopup.LoadFromFile(url, pb);
    }
    puts "\}"
    puts "translatePage('#messagebox');"
  }
}

proc action_wait_page_wir_search {} {
  division {class="popupTitle j_translate"} {
    #puts "Ger&auml;te werden gesucht ... bitte warten"
    puts "\${dialogNewDevicesLblSearchDevices}"
  }
  puts ""

   cgi_javascript {
    puts "translatePage('.popupTitle');"
   }

}

proc get_new_device_count {} {
  array set result [rega_script {
    integer iNewCount = 0;
    object obj = dom.GetObject(ID_DEVICES);
    if ( obj ) {
      string tmp = "";
      foreach( tmp, obj.EnumEnabledIDs() ) {
      object elem = dom.GetObject(tmp);
      if (elem && (elem.ReadyConfig() == false) && (elem.Name() != 'Gateway')) {
        iNewCount = iNewCount + 1;
      }
      }
    }
  }]
  return $result(iNewCount);
}

proc action_rf_install_mode {} {
  global RFD_URL
  set activate true
  catch { import activate }
  catch {
    xmlrpc $RFD_URL setInstallMode [list bool $activate]
    set time [xmlrpc $RFD_URL getInstallMode]
    puts "Success $time "
    return
  } errMsg
  puts "$errMsg"
}

proc action_get_install_status {} {
  global RFD_URL
  catch {
    set time [xmlrpc $RFD_URL getInstallMode]
    set serial [xmlrpc $RFD_URL getKeyMismatchDevice [list bool true]]
    puts "Success $time $serial "
    return
  } errMsg
  puts "$errMsg"
}

proc action_rf_serial {} {
  global RFD_URL
  if {[catch {
    import serial
    xmlrpc $RFD_URL addDevice [list string $serial]
    puts "Success"
    return
  } errMsg] == -7 } {
    puts "KeyMismatch"
  } else {
#    puts "KeyMismatch"
    puts "$errMsg"
  }
}

proc action_set_temp_key {} {
  global RFD_URL
  if {[catch {
    import key
    xmlrpc $RFD_URL setTempKey [list string $key]
    puts "Success"
    return
  } errMsg]} {
    puts "$errMsg"
  }
}

proc action_wir_search {} {
  if {[catch {
    global HS485D_URL
    xmlrpc $HS485D_URL searchDevices
    puts "Success"
    return
  } errMsg]} {
    puts "$errMsg"
  }
}

proc action_get_new_device_count {} {
  puts [get_new_device_count]
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
  if {[session_requestisvalid 8] > 0} then action_$action
}

