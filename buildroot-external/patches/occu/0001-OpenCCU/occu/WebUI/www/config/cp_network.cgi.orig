#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce common.tcl

load tclrpc.so
load tclrega.so

proc action_cert_update_failed {} {
  global env
   
  http_head
  division {class="popupTitle"} {
    #puts "Netzwerk-Sicherheit"
    puts "\${dialogSettingsNetworkMessageCertificateTitle}"
  }
  division {class="CLASS21100"} {
    table {class="popupTable"} {border="0"} {
      table_row {
        table_data {
          table {class="CLASS21111"} {
            table_row {
              table_data {colspan="2"} {
                 #puts { Das Zertifikat wurde nicht erfolgreich auf die Zentrale hochgeladen bzw. es handelt sich nicht um ein g&uuml;ltiges Zertifikat.}
                 puts "\${dialogSettingsNetworkMessageCertificateUploadError}"

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
        table_data {class="CLASS21103"} {
          division {class="CLASS21104"} {onClick="OnBack();"} {
            #puts "Zur&uuml;ck"
            puts "\${dialogBack}"
          }
        }
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      OnBack = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(800);
        dlgPopup.LoadFromFile(url);
      }
    }
    puts "translatePage('#messagebox');"
  }
}

proc action_cert_update_go {} {
  global env
  
  http_head
  cgi_javascript {
    puts {
      homematic("User.restartLighttpd", {}, function(){
        MessageBox.show(translateKey("dialogRestartWebserverTitle"),translateKey("dialogRestartWebserverContent"));
        window.setTimeout(function() {window.location.protocol = "http";},2000);
      }); 
    }
  } 
}


proc put_message {title msg args} {
  division {class="popupTitle"} {
    puts $title
  }
  division {class="CLASS21100"} {
    table {class="popupTable CLASS21101"} {border="1"} {
      table_row {class="CLASS21102"} {
        table_data {
          puts $msg
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        if { [llength $args] < 1 } { set args {{"Zur&uuml;ck" "PopupClose();"}}}
        foreach b $args {
          table_data {class="CLASS21103"} {
            division {class="CLASS21104"} "onClick=\"[lindex $b 1]\"" {
              puts [lindex $b 0]
            }
          }
        }
      }
    }
  }
}

proc get_serial { } {
  return [read_var /var/ids SerialNumber]
}

proc get_user_email {} {
  global sid

  set session [string trim $sid "@" ]
  
  set isecmd ""
  append isecmd "var user=system.GetSessionVarStr('$session');"
  array set user [rega_script $isecmd]
  
  set userid [lindex [split $user(user) ";"] 0]
  
  set isecmd ""
  append isecmd "string mail = '';"
  append isecmd "object user = dom.GetObject($userid);"
  append isecmd "if (user)"
  append isecmd "{"
  append isecmd "mail = user.UserMailAddress();"
  #append isecmd "if (mail == \"\")"
  #append isecmd "{"
  #append isecmd "mail = 'info@eq-3.com';"
  #append isecmd "}"
  append isecmd "}"
  array set result [rega_script $isecmd]  
  
  return $result(mail);
}



proc read_var { filename varname} {
  set fd [open $filename r]
  set var ""
  if { $fd >=0 } {
    while { [gets $fd buf] >=0 } {
      if [regexp "^ *$varname *= *(.*)$" $buf dummy var] break
    }
    close $fd
  }
  return $var
}

proc action_cert_upload {} {
  global env sid
  cd /tmp/
  
  http_head
  import_file -client cert_file
  file rename -force -- [lindex $cert_file 0] "/var/server.pem"
  
  set filename [open "/var/server.pem" r]
  gets $filename line
  close $filename
  #puts $line;
  if { [string equal $line "-----BEGIN RSA PRIVATE KEY-----"] == 1 || [string equal $line "-----BEGIN PRIVATE KEY-----"] == 1} {
    file copy -force -- "/var/server.pem" "/etc/config/server.pem"
    file delete "/var/server.pem"
    
    cgi_javascript {
      puts "var url = \"$env(SCRIPT_NAME)?sid=$sid\";"
      puts {
        parent.top.dlgPopup.hide();
        parent.top.dlgPopup.setWidth(600);
        parent.top.dlgPopup.LoadFromFile(url, "action=cert_update_go");
      }
    }
  } else {
    cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=$sid\";"
    puts {
      parent.top.dlgPopup.hide();
      parent.top.dlgPopup.setWidth(600);
      parent.top.dlgPopup.LoadFromFile(url, "action=cert_update_failed");
    }
    }
  }
}

proc action_update_start {} {
  exec /sbin/init -q
}


proc action_put_page {} {
  global env sid
  
  set ip ""
  set mask ""
  set gw ""
  set hostname ""
  set dhcp ""
  set dns1 ""
  set dns2 ""
  
  read_config dhcp hostname ip mask gw dns1 dns2
  
  http_head
  
  division {class="popupTitle"} {
    #puts "Netzwerkeinstellungen"
    puts "\${dialogSettingsNetworkTitle}"
  }
  division {class="CLASS21114 j_translate"} {
    table {class="popupTable"} {border=1} {width="100%"} {
      table_row {class="CLASS21115"} {
        table_data {class="CLASS21116"} {
          #puts "IP-<br/>Einstellungen"
          puts "\${dialogSettingsNetworkTDIPSettings}"
        }
        table_data {align=left} {
          table {
            table_row {
              table_data {class="CLASS21112"} {colspan="2"} {
                #puts "Hostname:"
                puts "\${dialogSettingsNetworkIPSettingsLblHostname}"
              }
              table_data {
                cgi_text hostname=$hostname {id="text_hostname"}
              }
            }
            table_row {
              set checked ""
              if {! $dhcp} { set checked "checked=true" }
              table_data {class="CLASS21112"} {colspan="3"} {
                cgi_checkbox mode=dhcp {id="radio_manual"} {onClick=enable_disable()} $checked
                #puts "Folgende IP-Adresse verwenden:"
                puts "\${dialogSettingsNetworkIPSettingsLblUseIPAdd}"
              }
            }
            table_row {
              table_data {width="20"} { }
              table_data {class="CLASS21112"} {
                #puts "IP-Adresse:"
                puts "\${dialogSettingsNetworkIPSettingsLblIPAdd}"
              }
              table_data {
                cgi_text ip_address=$ip {id="text_ip"} {onpaste="isIPValid(this.value, this.id, true);"} {onkeyup="isIPValid(this.value, this.id);"}
              }

              table_data {id="text_ip_hint"} {class="attention hidden"} {
                puts "\${invalidIP}"
              }

            }
            table_row {
              table_data {width="20"} { }
              table_data {class="CLASS21112"} {
                #puts "Subnetmaske:"
                puts "\${dialogSettingsNetworkIPSettingsLblSubnet}"
              }
              table_data {
                cgi_text mask=$mask {id="text_mask"} {onpaste="isNetMaskValid(this.value, this.id, true);"} {onkeyup="isNetMaskValid(this.value, this.id);"}
              }

              table_data {id="text_mask_hint"} {class="attention hidden"} {
                puts "\${invalidNetMask}"
              }

            }
            table_row {
              table_data {width="20"} { }
              table_data {class="CLASS21112"} {
                #puts "Gateway:"
                puts "\${dialogSettingsNetworkIPSettingsLblGateway}"
              }
              table_data {
                cgi_text gw=$gw {id="text_gw"} {onpaste="isIPValid(this.value, this.id, true);"} {onkeyup="isIPValid(this.value, this.id);"}
              }

              table_data {id="text_gw_hint"} {class="attention hidden"} {
                puts "\${invalidIP}"
              }

            }
            table_row {
              table_data {class="CLASS21112"} {colspan="3"} {
                #puts "Folgende DNS-Serveraddressen verwenden:"
                puts "\${dialogSettingsNetworkIPSettingsLblUseDNS}"
              }
            }
            table_row {
              table_data {width="20"} { }
              table_data {class="CLASS21112"} {
                #puts "Bevorzugter DNS-Server:"
                puts "\${dialogSettingsNetworkIPSettingsLblDNS1}"
              }
              table_data {
                cgi_text dns1=$dns1 {id="text_dns1"} {onpaste="isIPValid(this.value, this.id, true);"} {onkeyup="isIPValid(this.value, this.id);"}
              }

              table_data {id="text_dns1_hint"} {class="attention hidden"} {
                puts "\${invalidIP}"
              }

            }
            table_row {
              table_data {width="30"} { }
              table_data {class="CLASS21112"} {
                #puts "Alternativer DNS-Server:"
                puts "\${dialogSettingsNetworkIPSettingsLblDNS2}"
              }
              table_data {
                cgi_text dns2=$dns2 {id="text_dns2"} {onpaste="isIPValid(this.value, this.id, true);"} {onkeyup="isIPValid(this.value, this.id);"}
              }

              table_data {id="text_dns2_hint"} {class="attention hidden"} {
                puts "\${invalidIP}"
              }

            }
          }
        }
        table_data {class="CLASS21113"} {align="left"} {
          p { ${dialogSettingsNetworkHintIPSettingsP1} }
          p { ${dialogSettingsNetworkHintIPSettingsP2} }
          p { ${dialogSettingsNetworkHintIPSettingsP3} }

        }
      }
      table_row {class="CLASS21119"} {
        table_data {class="CLASS21116"} {
          #puts "Zertifikat<br />erstellen"
          puts "\${dialogSettingsNetworkTDCreateCertificate}"
        }
        table_data {class="CLASS21113"} {width="400"} {
          table {class="CLASS21111"} {
            set email [get_user_email]

            table_row {
              table_data {width="20"} {}
              table_data {colspan="2" align="left"} {
                #puts "Schritt 2: Heruntergeladenes Zertifikat ausw&auml;hlen"
                puts "\${dialogSettingsNetworkCertificateLblStep2}"
              }
            }
            table_row {
              table_data {width="20"} {}
              table_data {colspan="2"} {
                form "$env(SCRIPT_NAME)?sid=$sid" name=cert_form {target=cert_upload_iframe} enctype=multipart/form-data method=post {
                  export action=cert_upload
                  file_button cert_file size=30 maxlength=1000000
                }
                puts {<iframe name="cert_upload_iframe" style="display: none;"></iframe>}
              }
            }
            table_row {
              table_data {width="20"} {}
              table_data {colspan="2" align="left"} {
                #puts "Schritt 3: Zertifikat auf Zentrale laden"
                puts "\${dialogSettingsNetworkCertificateLblStep3}"
              }
              table_data {align="right"} {
                division {class="popupControls CLASS21107"} {
                  table {
                    table_row {
                      table_data {
                        division {class="CLASS21108"} {onClick="document.cert_form.submit();"} {
                          #puts "Hochladen"
                          puts "\${dialogSettingsNetworkCertificateLblUpload}"
                        }
                      }
                    }
                  }
                }
              }
            }

            table_row {name="deleteCertificate"} {class="hidden"} {
              table_data {colspan="4"} {
                puts "<hr>"
              }
            }

            table_row {name="deleteCertificate"} {class="hidden"} {
              table_data {width="20"} {}
              table_data {colspan="2" align="left"} {
                #puts "Delete certificate"
                puts "\${dialogSettingsNetworkLblDeleteCertificate}"
              }

              table_data {align="right"} {
                division {class="popupControls CLASS21107"} {
                  table {
                    table_row {
                      table_data {
                        division {class="CLASS21108"} {onClick="deleteCert();"} {
                          #puts "Btn delete certificate"
                          puts "\${btnRemove}"
                        }
                      }
                    }
                  }
                }
              }


            }

          }
        }
        table_data {class="CLASS21113"} {align="left"} {
          p {${dialogSettingsNetworkHintCertificateP1}}
          p {${dialogSettingsNetworkHintCertificateP2}}
          p {${dialogSettingsNetworkHintCertificateP3}}
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS21103"} {
          division {class="CLASS21108"} {onClick="PopupClose()"} {
            #puts "Abbrechen"
            puts "\${btnCancel}"
          }
        }
        table_data {class="CLASS21103"} {
          division {id="btnOK"} {class="CLASS21108"} {onClick="OnOK()"} {
            #puts "OK"
            puts "\${btnOk}"
          }
        }
        table_data {class="CLASS21109"} {}
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      dlgResult = 0;
      OnOK = function() {
        var pb = "action=save_settings";
        pb += "&hostname="+document.getElementById("text_hostname").value;
        pb += "&dhcp="+(document.getElementById("radio_manual").checked?"0":"1");
        pb += "&ip="+document.getElementById("text_ip").value;
        pb += "&mask="+document.getElementById("text_mask").value;
        pb += "&gw="+document.getElementById("text_gw").value;
        pb += "&dns1="+document.getElementById("text_dns1").value;
        pb += "&dns2="+document.getElementById("text_dns2").value;
        
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            if (transport.responseText.match(/^Success/g))PopupClose();
            //else alert("Netzwerkkonfiguration konnte nicht gespeichert werden:\n"+transport.responseText);
            else alert(translateKey("dialogSettingsNetworkMessageAlertMessageError1") + "\n" +transport.responseText);
          }
        };
        new Ajax.Request(url, opts);
      }
    }
    puts {
      var timer_text_ip,
      timer_text_gw,
      timer_text_dns1,
      timer_text_dns2,
      timer_text_url;

      dlgResult = 0;

      enable_disable = function() {
        var disabled= !document.getElementById("radio_manual").checked;
        document.getElementById("text_ip").disabled=disabled;
        document.getElementById("text_mask").disabled=disabled;
        document.getElementById("text_gw").disabled=disabled;
        document.getElementById("text_dns1").disabled=disabled;
        document.getElementById("text_dns2").disabled=disabled;
      };

      checkIPAddress = function(ipAddress, elmId) {
        var isValid = isIPAddressValid(ipAddress),
        btnOKElm = jQuery("#btnOK"),
        invalidHintElm = jQuery("#"+elmId+"_hint");

        if (isValid != null) {
         invalidHintElm.hide();
         btnOKElm.show();
        } else {
         invalidHintElm.show();
         btnOKElm.hide();
        }
      };

      isIPValid = function(ipAddress, elmId, isPaste) {
        if (isPaste) {
          setTimeout(function() {ipAddress = jQuery("#"+elmId).val();},100);
        }

        var timeDelay = 1000;
        switch(elmId) {
          case "text_ip":
            clearTimeout(timer_text_ip);
            timer_text_ip = setTimeout(function() {checkIPAddress(ipAddress, elmId)},timeDelay);
            break;
          case "text_gw":
            clearTimeout(timer_text_gw);
            timer_text_gw = setTimeout(function() {checkIPAddress(ipAddress, elmId)},timeDelay);
            break;
          case "text_dns1":
            clearTimeout(timer_text_dns1);
            timer_text_dns1 = setTimeout(function() {checkIPAddress(ipAddress, elmId)},timeDelay);
            break;
          case "text_dns2":
            clearTimeout(timer_text_dns2);
            timer_text_dns2 = setTimeout(function() {checkIPAddress(ipAddress, elmId)},timeDelay);
            break;
          case "text_url":
            clearTimeout(timer_text_url);
            timer_text_url = setTimeout(function() {checkIPAddress(ipAddress, elmId)},timeDelay);
            break;
        }
      };

      isNetMaskValid = function(netMask, elmId, isPaste) {
        var timer_netMask,
        timeDelay = 1000;

        if (isPaste) {
          setTimeout(function() {netMask = jQuery("#"+elmId).val();},100);
        }

        clearTimeout(timer_netMask);
        timer_netMask = setTimeout(function() {

          var isValid = isSubnetMaskValid(netMask),
          btnOKElm = jQuery("#btnOK"),
          invalidHintElm = jQuery("#"+elmId+"_hint");

          if (isValid != null) {
           invalidHintElm.hide();
           btnOKElm.show();
          } else {
           invalidHintElm.show();
           btnOKElm.hide();
          }
        },timeDelay);
      };
    }
    puts "enable_disable();"
    puts "translatePage('#messagebox');"
    puts "dlgPopup.readaptSize();"
  }
  set serial [get_serial]
  cgi_javascript {
    puts {
  
      deleteCert = function() {
        var textA = "<div style=\"text-align:center\">" + translateKey('confirmCertificationPurgeB') + "</div>"

        var textB = "<div>" + translateKey('certificationFileDeletedA')  + "<br/><br/></div>" +
        "<div style=\"text-align:center\">" + translateKey('certificationFileDeletedB') + "</div>"

        var dlg = new YesNoDialog(translateKey('dialogDeleteCertificateTitle'), textA, function(result) {

          if (result == YesNoDialog.RESULT_YES) {
            // Delete the certificate

            homematic("User.deleteCertificate", {}, function(){
              jQuery("[name='deleteCertificate']").hide();
              homematic("User.restartLighttpd", {}, function(){
                MessageBox.show(translateKey("dialogRestartWebserverTitle"),translateKey("dialogRestartWebserverContent"));
                window.setTimeout(function() {window.location.protocol = "http";},2000);
              });

            });
          }
        }, "html");
      }

      homematic("User.existsCertificate", {}, function(result) {
        conInfo("server.pem exists: " + result);
        if (result) {
          jQuery("[name='deleteCertificate']").show();
        }
      });
    }
  }
}

proc action_save_settings {} {
  catch {
    import ip
    import mask
    import gw
    import hostname
    import dhcp
    import dns1
    import dns2
    if { [write_config $dhcp $hostname $ip $mask $gw $dns1 $dns2] } {
      #activate the new settings
    catch {exec "/etc/init.d/S40network" "restart" 2> &1 > /dev/null}
      puts "Success"
      # puts "\${dialogSettingsNetworkMessageSaveSettingsSucceed}"
      return
    } else {
      #puts "Fehler beim Schreiben der neuen Einstellungen"
      puts "\${dialogSettingsNetworkMessageSaveSettingsError}"
      return
    }
  } errMsg
  puts "$errMsg"
}

proc get_property {s id var} {
  upvar $var value
  return [regexp -line "^\\s*$id\\s*=(.*)\$" $s dummy value]
}

proc set_property {s_var id value} {
  upvar $s_var s
  #we include the equal sign here to make sure range contains at least one character
  if { [regexp -indices -line "^\\s*$id\\s*(=.*)\$" $s dummy range] } {
    set s [string replace $s [lindex $range 0] [lindex $range 1] "=$value"]
    return 1
  } else {
    if { ($s != "") && (![regexp {\n$} $s dummy]) } {
      set s "$s\n"
    }
    set s "$s$id=$value\n"
    return 1
  }
  return 0
}

proc get_current_config {dhcp_var hostname_var ip_var mask_var gw_var dns1_var dns2_var} {
  upvar $dhcp_var dhcp $hostname_var hostname $ip_var ip $mask_var mask $gw_var gw $dns1_var dns1 $dns2_var dns2
  set ifconfig_result [exec /sbin/ifconfig eth0]
  if {! [regexp -line {inet addr:([\d.]+).*Mask:([\d.]+)[^\d.]*$} $ifconfig_result dummy ip mask]} {return 0}
  set fd -1
  catch {set fd [open "/proc/net/route" r]}
  if { $fd <0 } { return 0 }
  set routes [read $fd]
  if {! [regexp -line {^eth0\s+0+\s+([\dabcdefABCDEF]+)\s+} $routes dummy gw_hex]} {return 0}
  scan $gw_hex "%02x%02x%02x%02x" gw_ip_3 gw_ip_2 gw_ip_1 gw_ip_0
  set gw "$gw_ip_0.$gw_ip_1.$gw_ip_2.$gw_ip_3"
  
  set fd -1
  catch {set fd [open "/etc/config/netconfig" r]}
  if { $fd <0 } { return 0 }
  set netconfig [read $fd]
  
  if {! [get_property $netconfig "HOSTNAME" hostname] } {return 0}
  if {! [get_property $netconfig "MODE" mode] } {return 0}
  set dhcp [expr {"$mode"=="DHCP"}]
  get_property $netconfig "NAMESERVER1" dns1
  get_property $netconfig "NAMESERVER2" dns2
  return 1
}

proc read_config {dhcp_var hostname_var ip_var mask_var gw_var dns1_var dns2_var} {
  upvar $dhcp_var dhcp $hostname_var hostname $ip_var ip $mask_var mask $gw_var gw $dns1_var dns1 $dns2_var dns2
  set fd -1
  catch {set fd [open "/etc/config/netconfig" r]}
  if { $fd <0 } { return 0 }
  set netconfig [read $fd]
  
  if {! [get_property $netconfig "HOSTNAME" hostname] } {return 0}
  if {! [get_property $netconfig "MODE" mode] } {return 0}
  set dhcp [expr {"$mode"=="DHCP"}]
  if {! [get_property $netconfig "IP" ip] } {return 0}
  if {! [get_property $netconfig "NETMASK" mask] } {return 0}
  if {! [get_property $netconfig "GATEWAY" gw] } {return 0}
  get_property $netconfig "NAMESERVER1" dns1
  get_property $netconfig "NAMESERVER2" dns2
  return 1
}

proc write_config {dhcp hostname ip mask gw dns1 dns2} {
  set fd -1
  catch {set fd [open "/etc/config/netconfig" r]}
  if { $fd <0 } { return 0 }
  set netconfig [read $fd]
  close $fd
  set fd -1
  
  if { $dhcp } {
    set_property netconfig "MODE" "DHCP"
  } else {
    set_property netconfig "MODE" "MANUAL"
  }
  set_property netconfig "HOSTNAME" $hostname
  set_property netconfig "IP" $ip
  set_property netconfig "NETMASK" $mask
  set_property netconfig "GATEWAY" $gw

  set_property netconfig "NAMESERVER1" $dns1
  set_property netconfig "NAMESERVER2" $dns2

  catch {set fd [open "/etc/config/netconfig" w]}
  if { $fd <0 } { return 0 }
  
  puts -nonewline $fd $netconfig
  close $fd

  return 1
}

cgi_eval {
  #cgi_debug -on
  cgi_input
  catch {
    import debug
    cgi_debug -on
  }
  set action "put_page"

  catch { import action }
  if {[session_requestisvalid 8] > 0} then action_$action
}


