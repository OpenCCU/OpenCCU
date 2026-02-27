#!/bin/tclsh
source once.tcl
sourceOnce cgi.tcl
sourceOnce session.tcl
sourceOnce common.tcl

load tclrega.so

array set TIMEZONES {
  "ACST" {ACST-9:30}
  "ACST/ACDT" {ACST-9:30ACDT-10:30,M10.5.0/02:00:00,M3.5.0/03:00:00}
  "AEST" {AEST-10}
  "AEST/AEDT" {AEST-10AEDT-11,M10.1.0/02:00:00,M3.5.0/03:00:00}
  "AKST/AKDT" {AKST+9AKDT+8,M3.2.0,M11.1.0}
  "AST/ADT" {AST+4ADT+3,M4.1.0/00:01:00,M10.5.0/00:01:00}
  "AWST/AWDT" {AWST-8AWDT-9,M12.1.0,M3.5.0/03:00:00}
  "BRST/BRDT" {BRST+3BRDT+2,M10.3.0,M2.3.0}
  "CET/CEST" {CET-1CEST-2,M3.5.0/02:00:00,M10.5.0/03:00:00}
  "CST" {CST+6}
  "CST/CDT" {CST+6CDT+5,M3.2.0,M11.1.0}
  "EET/EEST" {EET-2EEST-3,M3.5.0/03:00:00,M10.5.0/04:00:00}
  "EST/EDT" {EST+5EDT+4,M3.2.0,M11.1.0}
  "GMT/BST" {GMT+0BST-1,M3.5.0/01:00:00,M10.5.0/02:00:00}
  "GMT/IST" {GMT+0IST-1,M3.5.0/01:00:00,M10.5.0/02:00:00}
  "HAW" {HAW+10}
  "HKT" {HKT-8}
  "MSK/MSD" {MSK-3MSD-4,M3.5.0/2,M10.5.0/3}
  "RMST/RMDT" {RMST-3RMDT-4,M3.5.0/2,M10.5.0/3}
  "MST" {MST+7}
  "MST/MDT" {MST+7MDT+6,M3.2.0,M11.1.0}
  "NST/NDT" {NST+3:30NDT+2:30,M3.2.0/00:01:00,M11.1.0/00:01:00}
  "NZST/NZDT" {NZST-12NZDT-13,M10.1.0/02:00:00,M3.3.0/03:00:00}
  "PST/PDT" {PST+8PDT+7,M3.2.0,M11.1.0}
  "SGT" {SGT-8}
  "ULAT/ULAST" {ULAT-8ULAST-9,M3.5.0/2,M9.5.0/2}
  "WET/WEST" {WET-0WEST-1,M3.5.0/01:00:00,M10.5.0/02:00:00}
  "WIB" {WIB-7}
}


set LOCATIONS {
  {"Australia"}
  {- "Melbourne" "-37.8" "144.0" "AEST/AEDT" default}
  {"Belgium" "CET/CEST"}
  {- "Bruxelles" "50.8" "4.3" default}
  {"Bulgaria" "EET/EEST"}
  {- "Sofia" "42.7" "23.3" default}
  {"Denmark" "CET/CEST"}
  {- "Kopenhagen" "55.7" "12.6" default}
  {"Germany" "CET/CEST" default}
  {- "Aachen" "50.8" "6.1"}
  {- "Augsburg" "48.4" "10.9"}
  {- "Berlin" "52.5" "13.4" default}
  {- "Bonn" "50.7" "7.1"}
  {- "Bremen" "53.1" "8.8"}
  {- "Chemnitz" "50.8" "12.9"}
  {- "Dortmund" "51.5" "7.5"}
  {- "Dresden" "51.1" "13.8"}
  {- "Duisburg" "51.4" "6.8"}
  {- "Duesseldorf" "51.2" "6.8"}
  {- "Erfurt" "51.0" "11.0"}
  {- "Flensburg" "54.8" "9.4"}
  {- "FrankfurtM" "50.1" "8.7"}
  {- "FreiburgB" "48.0" "7.9"}
  {- "Hamburg" "53.6" "10.0"}
  {- "Hannover" "52.2" "9.7"}
  {- "Jena" "50.9" "11.6"}
  {- "Karlsruhe" "49.0" "8.4"}
  {- "Kassel" "51.3" "9.5"}
  {- "Kiel" "54.3" "10.1"}
  {- "Cologne" "50.9" "7.0"}
  {- "Leer" "53.2" "7.5"}
  {- "Leipzig" "51.3" "12.4"}
  {- "Magdeburg" "52.1" "11.6"}
  {- "Mainz" "50.0" "8.3"}
  {- "Munich" "48.1" "11.6"}
  {- "Nuremberg" "49.5" "11.1"}
  {- "Oberhausen" "51.5" "6.8"}
  {- "Oldenburg" "53.1" "8.2"}
  {- "Saarbruecken" "49.3" "7.0"}
  {- "Schwerin" "53.6" "11.4"}
  {- "Stuttgart" "48.8" "9.2"}
  {- "Wiesbaden" "50.1" "8.3"}
  {"Estonia" "EET/EEST"}
  {- "Tallinn" "59.25" "24.45" default}
  {"Finland" "EET/EEST"}
  {- "Helsinki" "60.2" "25.0" default}
  {"France" "CET/CEST"}
  {- "Paris" "48.9" "2.3" default}
  {"Greek" "EET/EEST"}
  {- "Athens" "38.0" "23.7" default}
  {"GreatBritain" "GMT/BST"}
  {- "London" "51.5" "0.0" default}
  {"Ireland" "GMT/IST"}
  {- "Dublin" "53.3" "-6.3" default}
  {"Italy" "CET/CEST"}
  {- "Rome" "41.9" "12.5" default}
  {"Netherland" "CET/CEST"}
  {- "Amsterdam" "52.4" "5.0" default}
  {"Norway" "CET/CEST"}
  {- "Oslo" "60.0" "10.8" default}
  {"Austria" "CET/CEST"}
  {- "Vienna" "48.2" "16.4" default}
  {- "Salzburg" "47.8" "13.1"}
  {"Poland" "CET/CEST"}
  {- "Warsaw" "52.2" "21.0" default}
  {"Portugal" "WET/WEST"}
  {- "Lisbon" "38.7" "-9.1" default}
  {"Russia"}
  {- "Moscow" "55.8" "37.6" "MSK/MSD" default}
  {- "StPetersburg" "60.0" "30.2" "RMST/RMDT"}
  {"Sweden" "CET/CEST"}
  {- "Stockholm" "59.3" "18.0" default}
  {"Switzerland" "CET/CEST"}
  {- "Zurich" "47.4" "8.5" default}
  {- "Bern" "47.0" "7.4"}
  {- "Genf" "46.2" "6.2"}
  {"Spain" "CET/CEST"}
  {- "Barcelona" "41.4" "2.2"}
  {- "Madrid" "40.4" "-3.7" default}

  {"Turkey" "EET/EEST"}
  {- "Adana" "37.0" "35.3" default}
  {- "Ankara" "39.9" "32.8" default}
  {- "Antalya" "36.9" "30.7" default}
  {- "Bursa" "40.2" "29.1" default}
  {- "Istanbul" "41.0" "29.0" default}
  {- "Izmir" "38.4" "27.2" default}
  {- "Konya" "37.9" "32.5" default}
  {- "Mersin" "36.8" "34.6" default}

  {"CzechRepublic" "CET/CEST"}
  {- "Praque" "50.0" "14.5" default}
  {"Ukraine" "EET/EEST"}
  {- "Kiev" "50.5" "30.5" default}
  {"Hungary" "CET/CEST"}
  {- "Budapest" "47.5" "19.0" default}
  {"USA"}
  {- "SanFrancisco" "37.7" "-122.5" "PST/PDT" default}
  {- "NewYork" "40.7" "-74.0" "EST/EDT"}
}

proc action_put_page {} {
  global env LOCATIONS TIMEZONES
  
  set iso8601_date [exec date -Iseconds]
  regexp {^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)([+-]\d+)$} $iso8601_date dummy year month day hour minute second zone
  
  puts "<div id=\"dragTime\">"

  division {class="popupTitle j_translate"} {
    puts "\${dialogSettingsTimePositionTitle}"
  }

  
  division {class="CLASS21500"} {
    table {class="popupTable"} {border="1"} {
      table_row {class="CLASS21502"} {
        table_data {class="CLASS21503"} {
          puts "\${dialogSettingsTimePositionTDTime}"
        }
        table_data {class="CLASS21504"} {
          table {class="CLASS21505"} {
            table_row {
              table_data {
                table {class="CLASS21505"} {
                  table_row {
                    table_data {align="left"} {
                      #puts "Uhrzeit (hh:mm:ss):"
                      puts "\${dialogSettingsTimePositionLblTime}"
                    }
                    table_data {align="right"} {
                      cgi_text hour=$hour {size="2"} {maxlength="2"} {id="text_hour"}
                      puts ":"
                      cgi_text minute=$minute {size="2"} {maxlength="2"} {id="text_minute"}
                      puts ":"
                      cgi_text second=$second {size="2"} {maxlength="2"} {id="text_second"}
                    }
                    table_data {}
                  }
                  table_row {
                    table_data {align="left"} {
                      #puts "Datum (tt.mm.jjjj):"
                      puts "\${dialogSettingsTimePositionLblDate}"
                    }
                    table_data {align="right"} {
                      cgi_text day=$day {size="2"} {maxlength="2"} {id="text_day"}
                      puts "."
                      cgi_text month=$month {size="2"} {maxlength="2"} {id="text_month"}
                      puts "."
                      cgi_text year=$year {size="4"} {maxlength="4"} {id="text_year"}
                    }
                    table_data {align="left"} {
                      division {class="popupControls CLASS21506"} {
                        division {class="CLASS21507"} {onClick="apply_time()"} {
                          #puts "Uhrzeit &uuml;bernehmen"
                          puts "\${dialogSettingsTimePositionBtnSaveTime}"
                        }
                      }
                    }
                  }
                  table_row {
                    table_data {colspan="2"} {}
                    table_data {align="left"} {class="CLASS21510"} {
                      division {class="popupControls CLASS21506"} {
                        division {class="CLASS21507"} {onClick="time_from_pc()"} {
                          #puts "Zeit vom PC &uuml;bernehmen"
                          puts "\${dialogSettingsTimePositionBtnGetPCTime}"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      table_row {class="CLASS21502"} {
        table_data {class="CLASS21503"} {
          #puts "NTP-Server"
          puts "\${dialogSettingsTimePositionTDNTPServer}"
        }
        table_data {class="CLASS21504"} {
          table {class="CLASS21505"} {
            table_row {
              table_data {
                table {class="CLASS21505"} {
                  table_row {
                    table_data {align="left"} {
                      #puts "NTP Zeitserver Adressen:"
                      puts "\${dialogSettingsTimePositionLblNTPServer}"
                    }
                    table_data {align="right"} {
                      cgi_text ntp_servers=[get_timeservers] {size="25"} {id="text_ntp_servers"}
                    }
                    table_data {align="left"} {
                      division {class="popupControls CLASS21506"} {
                        division {class="CLASS21507"} {onClick="apply_timeserver()"} {
                          #puts "Zeitserver &uuml;bernehmen"
                          puts "\${dialogSettingsTimePositionBtnNTPServer}"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      set country ""
      foreach location $LOCATIONS {
        if { [lindex $location 0] == "-" } {
           if { "$country" == "" } continue
          # process a city entry
          if {"[lindex $location end]" == "default"} {
            set city [lindex $location 1]
            set lat [lindex $location 2]
            set lon [lindex $location 3]
            if { [llength $location] > 5 } {
              set timezone [lindex $location 4]
            }
            break
          }
        } else {
          if {"[lindex $location end]" == "default"} {
             set country [lindex $location 0]
            if { [llength $location] > 2 } {
              set timezone [lindex $location 1]
            }
          }
        }
      }
      get_location_config country city lat lon timezone
      
      table_row {class="CLASS21502"} {
        table_data {class="CLASS21503"} {
          #puts "Positionsangabe"
          puts "\${dialogSettingsTimePositionTDPosition}"
        }
        table_data {class="CLASS21504"} {
          table {class="CLASS21505"} {
            table_row {
              table_data {
                table {class="CLASS21505"} {
                  table_row {
                    table_data {align="left"} {
                      #puts "L&auml;nderauswahl:"
                      puts "\${dialogSettingsTimePositionLblCountry}"
                    }
                    table_data {align="right"} {
                      cgi_select country= {id="select_country"} {onchange="on_change_country();"} {
                        set i 0
                        foreach location $LOCATIONS {
                          if { [lindex $location 0] != "-" } {
                            set selected [expr {"[lindex $location 0]"=="$country"?"selected":""}]
                            # process a country entry
                            cgi_option [lindex $location 0] value=$i $selected
                          }
                          incr i
                        }
                      }
                    }
                    td {}
                  }
                  table_row {
                    table_data {align="left"} {
                      #puts "St&auml;dteauswahl:"
                      puts "\${dialogSettingsTimePositionLblCity}"
                    }
                    table_data {align="right"} {
                      cgi_select city= {id="select_city"} {onchange="on_change_city();"} {
                        set cur_country ""
                        set i 0
                        foreach location $LOCATIONS {
                          if { "$cur_country"=="$country" && [lindex $location 0] == "-" } {
                            # process a city entry
                            set selected [expr {"[lindex $location 1]"=="$city"?"selected":""}]
                            cgi_option [lindex $location 1] value=$i $selected
                          } else {
                            set cur_country [lindex $location 0]
                          }
                          incr i
                        }
                      }
                    }
                    td {}
                  }
                  table_row {
                    table_data {align="left"} {
                      #puts "L&auml;ngengrad:"
                      puts "\${dialogSettingsTimePositionLblLongtitude}"
                    }
                    table_data {class="hidden"} {
                      cgi_text lon=[expr abs($lon)] {id="tmp_text_lon"}
                    }
                    table_data {align="right"} {
                      cgi_text lon=[expr abs($lon)] {size="12"} {maxlength="12"} {id="text_lon"} {onkeyup="checkPosData(this);"}
                      cgi_select lon_sign= {id="select_lon_sign"} {
                        #cgi_option "Ost" [expr ($lon>=0)?"selected":""]
                        #cgi_option "West" [expr ($lon<0)?"selected":""]

                        cgi_option "\${dialogSettingsTimePositionLblOptionEast}" [expr ($lon>=0)?"selected":""]
                        cgi_option "\${dialogSettingsTimePositionLblOptionWest}" [expr ($lon<0)?"selected":""]

                      }
                    }
                    td {}
                  }
                  table_row {
                    table_data {align="left"} {
                      #puts "Breitengrad:"
                      puts "\${dialogSettingsTimePositionLblLatitude}"
                    }
                    table_data {class="hidden"} {
                      cgi_text lat=[expr abs($lat)] {id="tmp_text_lat"}
                    }
                    table_data {align="right"} {
                      cgi_text lat=[expr abs($lat)] {size="12"} {maxlength="12"} {id="text_lat"} {onkeyup="checkPosData(this);"}
                      cgi_select lat_sign= {id="select_lat_sign"} {
                        #cgi_option "Nord" [expr ($lat>=0)?"selected":""]
                        #cgi_option "Süd" [expr ($lat<0)?"selected":""]

                        cgi_option "\${dialogSettingsTimePositionLblOptionNorth}" [expr ($lat>=0)?"selected":""]
                        cgi_option "\${dialogSettingsTimePositionLblOptionSouth}" [expr ($lat<0)?"selected":""]
                      }
                    }
                    td {}
                  }
                  table_row {
                    table_data {align="left"} {
                      #puts "Zeitzone:"
                      puts "\${dialogSettingsTimePositionLblTimezone}"
                    }
                    table_data {align="right"} {
                      cgi_select timezone= {id="select_tz"} {onchange="jQuery('#changeTimeZoneHint').show();"} {
                        foreach tz [lsort [array names TIMEZONES]] {
                          set selected [expr ("$tz"=="$timezone")?"selected":""]
                          set st_name ""
                          regexp {^(\w+)([+-])([0-9:]+)(?:(\w+)([+-])([0-9:]+))?} $TIMEZONES($tz) dummy st_name st_sign st_offset dt_name dt_sign dt_offset
                          if { "$st_name" == "" } {
                            cgi_option $TIMEZONES($tz) value=$tz $selected
                            continue
                          }
                          set utc_rel "UTC[expr {"$st_sign"=="-"?"+":"-"}]$st_offset"
                          if { "$dt_name" != "" } {
                            if {"$dt_offset" == ""} {
                              
                            }
                            append utc_rel "/[expr {"$dt_sign"=="-"?"+":"-"}]$dt_offset"
                          }
                          set entry "$tz ($utc_rel)"
                          cgi_option $entry value=$tz $selected
                        }
                      }
                    }
                    table_data {align="left"} {valign="bottom"} {
                      division {class="popupControls CLASS21506"} {
                        division {class="CLASS21507"} {onClick="apply_position()"} {
                          #puts "Einstellungen &uuml;bernehmen"
                          puts "\${dialogSettingsTimePositionBtnSavePosition}"
                        }
                      }
                    }
                  }
                  table_row {
                    table_data {} {}
                    table_data {} {colspan="2"} {
                    division {id="changeTimeZoneHint"} {class="hidden attention alignLeft"} {puts "\${changeTimeZoneHint}"}
                    }
                  }
                }
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
        table_data {class="CLASS21508 j_translate"} {
          division {class="CLASS21509"} {onClick="PopupClose();"} {
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
      add_leading_zero = function( v) {
        var s=String(v);
        return ( s.length < 2)?"0"+s:s;
      }
      time_from_pc = function() {
        var d=new Date;
        document.getElementById("text_hour").value=add_leading_zero(d.getHours());
        document.getElementById("text_minute").value=add_leading_zero(d.getMinutes());
        document.getElementById("text_second").value=add_leading_zero(d.getSeconds());

        document.getElementById("text_year").value=d.getFullYear();
        document.getElementById("text_month").value=add_leading_zero(d.getMonth()+1);
        document.getElementById("text_day").value=add_leading_zero(d.getDate());
        
        apply_time();
      };

      checkPosData = function(elm) {
        if (typeof tmr != "undefined") {window.clearTimeout(tmr);}
        tmr = window.setTimeout(function() {
          var type = elm.id.split("_")[1],
          value = (elm.value != "") ? parseFloat(elm.value) : elm.value ;
          switch (type) {
            case "lon":
              if ((value != "") && ((isNaN(value)) || (value < 0 ) || (value > 180)) ) {elm.value = jQuery("#tmp_" + elm.id).val();} else {elm.value = value;}
              break;
            case "lat":
              if ((value != "") && ((isNaN(value)) || (value < 0 ) || (value > 90 )) ) {elm.value = jQuery("#tmp_" + elm.id).val();} else {elm.value = value;}
              break;
          }
        }, 750);
      }
    }
    puts {
      apply_time = function() {
        var pb = "action=apply_time";
        pb += "&year="+parseInt(document.getElementById("text_year").value, 10);
        pb += "&month="+parseInt(document.getElementById("text_month").value, 10);
        pb += "&day="+parseInt(document.getElementById("text_day").value, 10);
        pb += "&hour="+parseInt(document.getElementById("text_hour").value, 10);
        pb += "&minute="+parseInt(document.getElementById("text_minute").value, 10);
        pb += "&second="+parseInt(document.getElementById("text_second").value, 10);
        
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            if (!transport.responseText.match(/^Success/g)){
              //MessageBox.show("Info", "Setzen der Uhrzeit fehlgeschlagen:\n" + transport.responseText)
              MessageBox.show(translateKey("Info"), translateKey("dialogSettingsTimePositionMessageSetClockFailure") + "\n" +transport.responseText)

            }else{
              //MessageBox.show("Info", "Uhrzeit wurde gespeichert.")
              MessageBox.show(translateKey("Info"), translateKey("dialogSettingsTimePositionMessageSetClockSucceed"))

            }
          }
        };
        new Ajax.Request(url, opts);
      }
      apply_timeserver = function() {
        var pb = "action=apply_timeserver";
        pb += "&ntp_servers="+document.getElementById("text_ntp_servers").value;
         
        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            if (!transport.responseText.match(/^Success/g)){
              MessageBox.show(translateKey("Info"), translateKey("dialogSettingsTimePositionMessageSetNTPServerFailure") + "\n" + transport.responseText);
            }else{
              //MessageBox.show("Info", "NTP-Server wurden gespeichert.");
              MessageBox.show(translateKey("Info"), translateKey("dialogSettingsTimePositionMessageSetNTPServerSucceed"));
            }
          }
        };
        new Ajax.Request(url, opts);
      }
    }
    
    puts {
      apply_position = function() {
        var lon = document.getElementById("text_lon").value*(document.getElementById("select_lon_sign").selectedIndex?-1:1),
        lat = lat = document.getElementById("text_lat").value*(document.getElementById("select_lat_sign").selectedIndex?-1:1),
        tZone = document.getElementById("select_tz").value;

        var setAllHmIPDevices = window.confirm(translateKey("setAllHmIPDevices"));

        var pb = "action=apply_position";
        pb += "&country="+document.getElementById("select_country").value;
        pb += "&city="+document.getElementById("select_city").value;
        pb += "&lon="+ lon;
        pb += "&lat="+ lat;
        pb += "&timezone="+tZone;

        var opts = {
          postBody: pb,
          sendXML: false,
          onSuccess: function(transport) {
            if (!transport.responseText.match(/^Success/g)){
              MessageBox.show(translateKey("Info"), translateKey("dialogSettingsTimePositionMessageSetPositionFailure") + "\n" + unescape(transport.responseText));
            }else{
              if (setAllHmIPDevices) {
              counterSetPosition = 0;
              setPositionAllDevices(lon, lat, tZone);
              MessageBox.show(translateKey("Info"), translateKey("dialogSettingsTimePositionMessageSetPositionSucceedIncludingAllDevices"));
              } else {
              MessageBox.show(translateKey("Info"), translateKey("dialogSettingsTimePositionMessageSetPositionSucceed"));
              }
              jQuery("#tmp_text_lon").val(Math.abs(parseFloat(lon)));
              jQuery("#tmp_text_lat").val(Math.abs(parseFloat(lat)));
            }
          }
        };
        new Ajax.Request(url, opts);
      }
    }
    
    puts {
      var locations=new Array();
    }
    set i 0
    set city_index 0
    set country_index 0
    foreach location $LOCATIONS {
      if { [lindex $location 0] == "-" } {
        # process a city entry
        set city [lindex $location 1]
        set lat [lindex $location 2]
        set lon [lindex $location 3]
        set def_city [expr {"[lindex $location end]" == "default"}]
        if { [llength $location] > ($def_city?5:4) } {
          set tz [lindex $location 4]
        } else {
          set tz $country_tz
        }
#        puts "locations\[$i\] = new Array($country_index, '[js_to_iso_8859_1 $city]', $lat, $lon, '$tz', $def_city, $city_index);"
        puts "locations\[$i\] = new Array($country_index, '$city', $lat, $lon, '$tz', $def_city, $city_index);"
        incr i
      } else {
        # process a country entry
        set country [lindex $location 0]
        set country_tz [lindex $location 1]
        set country_index $city_index
      }
      incr city_index
    }
    puts {
      on_change_country = function() {
        document.getElementById("select_city").options.length=0;
        var country_index = document.getElementById("select_country").value;
        var j=0;
        for(i=0;i<locations.length;i++) {
          if(locations[i][0] == country_index) {
            document.getElementById("select_city").options[j] = new Option(locations[i][1],locations[i][6],locations[i][5]);
            j++;
          }
        }
        translatePage("#select_city");
        on_change_city();
      }
    }
    puts {
      on_change_city = function() {
        var city_index = document.getElementById("select_city").value;
        var tz="";
        for(i=0;i<locations.length;i++) {
          if(locations[i][6] == city_index) {
            var lat = locations[i][2];
            var lon = locations[i][3];
            tz = locations[i][4];
            document.getElementById("select_lat_sign").selectedIndex=(lat<0.0);
            document.getElementById("select_lon_sign").selectedIndex=(lon<0.0);
            document.getElementById("text_lat").value=Math.abs(lat);
            document.getElementById("tmp_text_lat").value=Math.abs(lat);
            document.getElementById("text_lon").value=Math.abs(lon);
            document.getElementById("tmp_text_lon").value=Math.abs(lon);
          }
        }
        for(i=0;i<document.getElementById("select_tz").options.length;i++) {
          if(document.getElementById("select_tz").options[i].value == tz){
            document.getElementById("select_tz").selectedIndex=i;
            break;
          }
        }

        jQuery("#select_city").find("option").each(function(index, option) {
          jQuery(option).text( translateKey(jQuery(option).text()) );
        });
      }
    }
    puts {

      jQuery("#select_country").find("option").each(function(index, option) {
      jQuery(option).text( translateKey(jQuery(option).text()) );
      });

      jQuery("#select_city").find("option").each(function(index, option) {
      jQuery(option).text( translateKey(jQuery(option).text()) );
      });

      translatePage('#messagebox');
    }
  }
  puts "</div><script type=\"text/javascript\">new Draggable(\"dragTime\");</script>" 
}

proc js_to_iso_8859_1 {s} {
  return [string map {Ä \xC4 Ü \xDC Ö \xD6 ä \xE4 ü \xFC ö \xF6 ß \xDF} $s]
}

proc get_location_config {var_country var_city var_lat var_lon var_timezone} {
  upvar $var_country country $var_city city $var_lat lat $var_lon lon $var_timezone timezone
  set fd -1
  catch {set fd [open "/etc/config/time.conf" r]}
  if { $fd <0 } { return 0 }
  set config [read $fd]
  set lon 0.0
  set lat 0.0
  regexp -line {^\s*COUNTRY\s*=\s*'?([^']*)'?\s*$} $config dummy country
  regexp -line {^\s*CITY\s*=\s*'?([^']*)'?\s*$} $config dummy city
  regexp -line {^\s*LATITUDE\s*=\s*'?([+-]?[0-9]+(?:\.[0-9]+)?)'?\s*$} $config dummy lat
  regexp -line {^\s*LONGITUDE\s*=\s*'?([+-]?[0-9]+(?:\.[0-9]+)?)'?\s*$} $config dummy lon
  regexp -line {^\s*TIMEZONE\s*=\s*'?([^']*)'?\s*$} $config dummy timezone
  
  return 1
}

proc set_location_config {country city lat lon timezone} {
  global TIMEZONES
  set fd -1
  catch {set fd [open "/etc/config/time.conf" w]}
  if { $fd <0 } { return 0 }
  
  puts $fd "COUNTRY=$country"
  puts $fd "CITY=$city"
  puts $fd "LATITUDE=$lat"
  puts $fd "LONGITUDE=$lon"
  puts $fd "TIMEZONE=$timezone"
  close $fd

  set fd -1
  catch {set fd [open "/etc/config/TZ" w]}
  if { $fd <0 } { return 0 }
  puts $fd "$TIMEZONES($timezone)"
  close $fd
  
  rega_script "var x=system.Longitude($lon);var y=system.Latitude($lat);var a=dom.ChangedTimeManually();"
  
  catch {exec /sbin/hwclock -wu}

  set portnumber 2001
  catch { source "/etc/eq3services.ports.tcl" }
  if { [info exists EQ3_SERVICE_RFD_PORT] } {
    set portnumber $EQ3_SERVICE_RFD_PORT
  }

  catch {exec SetInterfaceClock 127.0.0.1:$portnumber}
  return 1
}

proc get_timeservers {} {
  set fd -1
  catch {set fd [open "/etc/config/ntpclient" r]}
  if { $fd <0 } { return "" }
  set config [read $fd]
  set value ""
  regexp -line {^\s*NTPSERVERS\s*=\s*'?([^']*)'?\s*$} $config dummy value
  return $value
}

proc set_timeservers {ntp_servers} {
  global TIMEZONES
  set fd -1
  catch {set fd [open "/etc/config/ntpclient" w]}
  if { $fd <0 } { return 0 }
  
  puts $fd "NTPSERVERS='$ntp_servers'"
  close $fd
  return 1
}

proc action_apply_time {} {
  import year
  import month
  import day
  import hour
  import minute
  import second
  
  catch { rega_script "var a=dom.SettingTimeManually();" }
  
  if {$year < 100} {set year [expr $year + 2000]}
  if {[isOldCCU]} {
    if { [catch {exec date -s [format "%02d%02d%02d%02d%04d.%02d" $month $day $hour $minute $year $second]} fid] } {
      puts "Failure date -s: $fid"
      return
    }
  } else {
    if { [catch {exec date -s [format "%04d%02d%02d%02d%02d.%02d" $year $month $day $hour $minute $second]} fid] } {
      puts "Failure date -s: $fid"
      return
    }
  }
    
  catch { rega_script "var a=dom.ChangedTimeManually();" }
   
  catch {exec /sbin/hwclock -wu}

  set portnumber 2001
  catch { source "/etc/eq3services.ports.tcl" }
  if { [info exists EQ3_SERVICE_RFD_PORT] } {
    set portnumber $EQ3_SERVICE_RFD_PORT
  }

  if { [catch {exec SetInterfaceClock 127.0.0.1:$portnumber} fid] } {
    puts "Failure SetInterfaceClock: $fid"
    return
  }
  puts "Success"
}

proc action_apply_timeserver {} {
  import ntp_servers
  if {![set_timeservers $ntp_servers]} {
    puts "Failure"
    return
  }
  catch {exec setclock noloop}

  set portnumber 2001
  catch { source "/etc/eq3services.ports.tcl" }
  if { [info exists EQ3_SERVICE_RFD_PORT] } {
    set portnumber $EQ3_SERVICE_RFD_PORT
  }

  catch {exec SetInterfaceClock 127.0.0.1:$portnumber}
  puts "Success"
}

proc action_apply_position {} {
  global LOCATIONS
  import country
  import city
  import lon
  import lat
  import timezone
  set country [lindex [lindex $LOCATIONS $country] 0]
  set city [lindex [lindex $LOCATIONS $city] 1]
  if {![regexp {^[+-]?[0-9]+(?:\.[0-9]+)?$} $lon]} {
    puts "Fehlerhafte L%E4ngengradangabe."
    return
  }
  if {![regexp {^[+-]?[0-9]+(?:\.[0-9]+)?$} $lat]} {
    puts "Fehlerhafte Breitengradangabe."
    return
  }
  if {[set_location_config $country $city $lat $lon $timezone]} {
    puts "Success"
  } else {
    puts "Failure"
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
  catch {import action}
  
  http_head
  if {[session_requestisvalid 8] > 0} then action_$action
}


