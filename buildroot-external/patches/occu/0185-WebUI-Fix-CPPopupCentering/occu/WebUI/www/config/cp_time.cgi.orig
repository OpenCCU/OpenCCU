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

# read additional timezones from iana zone file
if { [file exists /usr/share/zoneinfo/zone.tab] == 1 } {
  set f [open /usr/share/zoneinfo/zone.tab]
  while {[gets $f line] > -1} {
    if {[regexp {^[^#]\S+\t\S+\t(\S+)} $line -> tz]} {
      append TIMEZONES($tz) "$tz"
    }
  }
  close $f
}

set LOCATIONS {
  {"Albania"}
  {- "Tirana" "41.33" "19.82" "Europe/Tirane" default}

  {"Algeria"}
  {- "Algiers" "36.75" "3.06" "Africa/Algiers" default}

  {"Andorra"}
  {- "Andorra la Vella" "42.50" "1.52" "Europe/Andorra" default}

  {"Antarctica"}
  {- "Casey" "-66.28" "110.53" "Antarctica/Casey" default}
  {- "Davis" "-68.58" "77.97" "Antarctica/Davis" }
  {- "DumontDUrville" "-66.66" "140.00" "Antarctica/DumontDUrville" }
  {- "Mawson" "-67.60" "62.87" "Antarctica/Mawson" }
  {- "Palmer" "-64.77" "-64.05" "Antarctica/Palmer" }
  {- "Rothera" "-67.57" "-68.13" "Antarctica/Rothera" }
  {- "Syowa" "-69.00" "39.58" "Antarctica/Syowa" }
  {- "Troll" "-72.01" "2.54" "Antarctica/Troll" }
  {- "Vostok" "-78.46" "106.84" "Antarctica/Vostok" }

  {"Afganisthan"}
  {- "Kabul" "34.53" "69.17" "Asia/Kabul" default}

  {"Argentina"}
  {- "Buenos Aires" "-34.60" "-58.38" "America/Argentina/Buenos_Aires" default}
  {- "Catamarca" "-28.47" "-65.78" "America/Argentina/Catamarca" }
  {- "Cordoba" "-31.42" "-64.18" "America/Argentina/Cordoba" }
  {- "Salta" "-24.78" "-65.42" "America/Argentina/Salta" }
  {- "Jujuy" "-24.18" "-65.30" "America/Argentina/Jujuy" }
  {- "La Rioja" "-29.43" "-66.85" "America/Argentina/La_Rioja" }
  {- "Mendoza" "-32.88" "-68.82" "America/Argentina/Mendoza" }
  {- "Rio Gallegos" "-51.63" "-69.22" "America/Argentina/Rio_Gallegos" }
  {- "San Juan" "-31.53" "-68.53" "America/Argentina/San_Juan" }
  {- "San Luis" "-33.30" "-66.33" "America/Argentina/San_Luis" }
  {- "Tucuman" "-26.94" "-65.34" "America/Argentina/Tucuman" }
  {- "Ushuaia" "-54.80" "-68.30" "America/Argentina/Ushuaia" }

  {"Armenia"}
  {- "Yerevan" "40.18" "44.51" "Asia/Yerevan" default}

  {"Australia"}
  {- "Adelaide" "-34.93" "138.60" "Australia/Adelaide" }
  {- "Brisbane" "-27.47" "153.03" "Australia/Brisbane" }
  {- "Broken Hill" "-31.96" "141.47" "Australia/Broken_Hill" }
  {- "Christmas" "-10.48" "105.63" "Indian/Christmas" }
  {- "Cocos" "-12.12" "96.90" "Indian/Cocos" }
  {- "Currie" "-39.93" "143.85" "Australia/Currie" }
  {- "Darwin" "-12.42" "130.89" "Australia/Darwin" }
  {- "Eucla" "-31.68" "128.88" "Australia/Eucla" }
  {- "Hobart" "-42.88" "147.33" "Australia/Hobart" }
  {- "Lindeman" "-20.45" "149.03" "Australia/Lindeman" }
  {- "Lord Howe" "-31.55" "159.08" "Australia/Lord_Howe" }
  {- "Macquarie" "-54.64" "158.85" "Antarctica/Macquarie" }
  {- "Melbourne" "-37.81" "144.96" "Australia/Melbourne" }
  {- "Perth" "-31.95" "115.86" "Australia/Perth" }
  {- "Sydney" "-33.87" "151.21" "Australia/Sydney" default}

  {"Austria" "Europe/Vienna"}
  {- "Vienna" "48.21" "16.37" default}
  {- "Salzburg" "47.80" "13.03"}

  {"Azerbaijan"}
  {- "Baku" "40.40" "49.88" "Asia/Baku" default}

  {"Bahamas"}
  {- "Nassau" "25.06" "-77.35" "America/Nassau" default}

  {"Bangladesh"}
  {- "Dhaka" "23.72" "90.40" "Asia/Dhaka" default}

  {"Barbados"}
  {- "Barbados" "13.16" "-59.55" "America/Barbados" default}

  {"Belarus"}
  {- "Minsk" "53.90" "27.55" "Europe/Minsk" default}

  {"Belgium"}
  {- "Brussels" "50.85" "4.35" "Europe/Brussels" default}

  {"Belize"}
  {- "Belize" "17.07" "-88.70" "America/Belize" default}

  {"Bermuda"}
  {- "Bermuda" "32.33" "-64.75" "Atlantic/Bermuda" default}

  {"Bhutan"}
  {- "Thimphu" "27.47" "89.64" "Asia/Thimphu" default}

  {"Bolivia"}
  {- "La Paz" "-16.50" "-68.15" "America/La_Paz" default}

  {"Bosnia and Herzegovina"}
  {- "Sarajevo" "43.86" "18.43" "Europe/Sarajevo" default}

  {"Bougainville"}
  {- "Bougainville" "-6.00" "155.00" "Pacific/Bougainville" default}

  {"Brazil"}
  {- "Araguaina" "-7.19" "-48.21" "America/Araguaina" }
  {- "Bahia" "-12.00" "-41.00" "America/Bahia" }
  {- "Belem" "-1.46" "-48.50" "America/Belem" }
  {- "Boa Vista" "2.82" "-60.67" "America/Boa_Vista" }
  {- "Campo Grande" "-20.48" "-54.62" "America/Campo_Grande" }
  {- "Cuiaba" "-15.60" "-56.10" "America/Cuiaba" }
  {- "Eirunepe" "-6.66" "-69.87" "America/Eirunepe" }
  {- "Fortaleza" "-3.72" "-38.54" "America/Fortaleza" }
  {- "Maceio" "-9.67" "-35.74" "America/Maceio" }
  {- "Manaus" "-3.10" "-60.02" "America/Manaus" }
  {- "Noronha" "-3.85" "-32.42" "America/Noronha" }
  {- "Porto Velho" "-8.76" "-63.90" "America/Porto_Velho" }
  {- "Recife" "-8.05" "-34.90" "America/Recife" }
  {- "Rio Branco" "-9.97" "-67.81" "America/Rio_Branco" }
  {- "Santarem" "-2.43" "-54.72" "America/Santarem" }
  {- "Sao Paulo" "-23.55" "-46.63" "America/Sao_Paulo" default}

  {"Brunei"}
  {- "Brunei" "4.50" "114.67" "Asia/Brunei" default }

  {"Bulgaria"}
  {- "Sofia" "42.70" "23.32" "Europe/Sofia" default}

  {"Canada"}
  {- "Atikokan" "48.75" "-91.62" "America/Atikokan" }
  {- "Blanc-Sablon" "51.42" "-57.13" "America/Blanc-Sablon" }
  {- "Cambridge Bay" "69.12" "-105.05" "America/Cambridge_Bay" }
  {- "Creston" "49.09" "-116.51" "America/Creston" }
  {- "Dawson" "64.06" "-139.41" "America/Dawson" }
  {- "Dawson Creek" "55.76" "-120.24" "America/Dawson_Creek" }
  {- "Edmonton" "50.29" "-107.79" "America/Edmonton" }
  {- "Fort Nelson" "58.81" "-122.70" "America/Fort_Nelson" }
  {- "Glace Bay" "46.20" "-59.97" "America/Glace_Bay" }
  {- "Goose Bay" "53.18" "-60.25" "America/Goose_Bay" }
  {- "Halifax" "44.65" "-63.57" "America/Halifax" }
  {- "Inuvik" "68.36" "-133.73" "America/Inuvik" }
  {- "Iqaluit" "63.75" "-68.52" "America/Iqaluit" }
  {- "Moncton" "46.13" "-64.77" "America/Moncton" }
  {- "Nipigon" "49.02" "-88.27" "America/Nipigon" }
  {- "Pangnirtung" "66.15" "-65.69" "America/Pangnirtung" }
  {- "Rainy River" "48.72" "-94.57" "America/Rainy_River" }
  {- "Rankin Inlet" "62.81" "-92.10" "America/Rankin_Inlet" }
  {- "Regina" "50.45" "-104.61" "America/Regina" }
  {- "Resolute" "74.70" "-94.83" "America/Resolute" }
  {- "St Johns" "47.56" "-52.71" "America/St_Johns" }
  {- "Swift Current" "50.29" "-107.80" "America/Swift_Current" }
  {- "Thunder Bay" "48.38" "-89.25" "America/Thunder_Bay" }
  {- "Toronto" "43.74" "-79.37" "America/Toronto" }
  {- "Vancouver" "49.25" "-123.10" "America/Vancouver" default}
  {- "Whitehorse" "60.72" "-135.03" "America/Whitehorse" }
  {- "Winnipeg" "49.90" "-97.14" "America/Winnipeg" }
  {- "Yellowknife" "62.44" "-114.40" "America/Yellowknife" }

  {"Cape Verde"}
  {- "Cape Verde" "15.11" "-23.62" "Atlantic/Cape_Verde" default}

  {"Chad"}
  {- "Ndjamena" "12.11" "15.05" "Africa/Ndjamena" default}

  {"Chile"}
  {- "Easter" "-27.12" "-109.37" "Pacific/Easter" }
  {- "Punta Arenas" "-53.17" "-70.93" "America/Punta_Arenas" }
  {- "Santiago" "-33.45" "-70.67" "America/Santiago" default}

  {"China"}
  {- "Hong Kong" "22.30" "114.20" "Asia/Hong_Kong" }
  {- "Macau" "22.17" "113.60" "Asia/Macau" }
  {- "Shanghai" "31.23" "121.47" "Asia/Shanghai" default}
  {- "Taipei" "25.07" "121.52" "Asia/Taipei" }
  {- "Urumqi" "43.43" "87.60" "Asia/Urumqi" }

  {"Columbia"}
  {- "Bogota" "4.71" "-74.07" "America/Bogota" default}

  {"Cook Islands"}
  {- "Rarotonga" "-21.23" "-159.77" "Pacific/Rarotonga" default}

  {"Costa Rica"}
  {- "Costa Rica" "10.00" "-84.00" "America/Costa_Rica" default}

  {"Croatia"}
  {- "Zagreb" "45.81" "15.98" "Europe/Zagreb" default}

  {"Cuba"}
  {- "Havana" "23.14" "-82.36" "America/Havana" default}

  {"Cyprus"}
  {- "Famagusta" "35.13" "33.94" "Asia/Famagusta" }
  {- "Nicosia" "35.17" "33.35" "Europe/Nicosia" default}

  {"Czech Republic"}
  {- "Prague" "50.09" "14.42" "Europe/Prague" default}

  {"Denmark"}
  {- "Copenhagen" "55.68" "12.57" "Europe/Copenhagen" default}
  {- "Faroe" "62.00" "-6.78" "Atlantic/Faroe" }

  {"Dominican Republic"}
  {- "Santo Domingo" "18.47" "-69.95" "America/Santo_Domingo" default}

  {"East Timor"}
  {- "Dili" "-8.57" "125.57" "Asia/Dili" default}

  {"Ecuador"}
  {- "Galapagos" "-0.67" "-90.55" "Pacific/Galapagos" }
  {- "Guayaquil" "-2.18" "-79.88" "America/Guayaquil" default}

  {"Efate"}
  {- "Efate" "-17.67" "168.42" "Pacific/Efate" default}

  {"Egypt"}
  {- "Cairo" "30.03" "31.23" "Africa/Cairo" default}

  {"El Salvador"}
  {- "San Salvador" "13.69" "-89.19" "America/El_Salvador" default}

  {"Estonia"}
  {- "Tallinn" "59.44" "24.75" "Europe/Tallinn" default}

  {"Falkland Islands"}
  {- "Stanley" "-51.69" "-57.85" "Atlantic/Stanley" default}

  {"Finland"}
  {- "Helsinki" "60.17" "24.94" "Europe/Helsinki" default}

  {"Fiji"}
  {- "Suva" "-18.14" "178.44" "Pacific/Fiji" default}

  {"France"}
  {- "Cayenne" "4.94" "-52.33" "America/Cayenne" }
  {- "Gambier" "-23.15" "-134.95" "Pacific/Gambier" }
  {- "Kerguelen" "-49.25" "69.17" "Indian/Kerguelen" }
  {- "Marquesas" "-9.45" "-139.39" "Pacific/Marquesas" }
  {- "Martinique" "14.67" "-61.00" "America/Martinique" }
  {- "Miquelon" "47.10" "-56.38" "America/Miquelon" }
  {- "Noumea" "-22.28" "166.46" "Pacific/Noumea" }
  {- "Paris" "48.86" "2.35" "Europe/Paris" default}
  {- "Reunion" "-21.11" "55.53" "Indian/Reunion" }
  {- "Tahiti" "-17.67" "-149.42" "Pacific/Tahiti" }
  {- "Wallis" "-13.27" "-176.20" "Pacific/Wallis" }

  {"Georgia"}
  {- "Tbilisi" "41.72" "44.78" "Asia/Tbilisi" default}

  {"Germany" "Europe/Berlin" default}
  {- "Aachen" "50.77" "6.08"}
  {- "Augsburg" "48.37" "10.90"}
  {- "Berlin" "52.52" "13.41" default}
  {- "Bonn" "50.73" "7.10"}
  {- "Bremen" "53.07" "8.81"}
  {- "Chemnitz" "50.83" "12.92"}
  {- "Dortmund" "51.51" "7.46"}
  {- "Dresden" "51.05" "13.74"}
  {- "Duisburg" "51.44" "6.76"}
  {- "Duesseldorf" "51.23" "6.78"}
  {- "Erfurt" "50.98" "11.03"}
  {- "Flensburg" "54.78" "9.44"}
  {- "FrankfurtM" "50.11" "8.68"}
  {- "FreiburgB" "47.99" "7.85"}
  {- "Hamburg" "53.55" "9.99"}
  {- "Hannover" "52.37" "9.73"}
  {- "Jena" "50.93" "11.59"}
  {- "Karlsruhe" "49.01" "8.40"}
  {- "Kassel" "51.32" "9.50"}
  {- "Kiel" "54.32" "10.14"}
  {- "Cologne" "50.94" "6.96"}
  {- "Leer" "53.23" "7.45"}
  {- "Leipzig" "51.34" "12.37"}
  {- "Magdeburg" "52.13" "11.62"}
  {- "Mainz" "50.00" "8.27"}
  {- "Munich" "48.14" "11.58"}
  {- "Nuremberg" "49.46" "11.08"}
  {- "Oberhausen" "51.47" "6.85"}
  {- "Oldenburg" "53.14" "8.21"}
  {- "Saarbruecken" "49.23" "7.00"}
  {- "Schwerin" "53.63" "11.42"}
  {- "Stuttgart" "48.78" "9.18"}
  {- "Wiesbaden" "50.08" "8.24"}

  {"Ghana"}
  {- "Accra" "5.55" "-0.20" "Africa/Accra" default}

  {"Great Britain"}
  {- "Chagos" "-6.28" "72.08" "Indian/Chagos" }
  {- "Gibraltar" "36.13" "-5.36" "Europe/Gibraltar" }
  {- "Grand Turk" "21.47" "-71.14" "America/Grand_Turk" }
  {- "London" "51.51" "-0.13" "Europe/London" default}
  {- "Norfolk" "-29.03" "167.95" "Pacific/Norfolk" }
  {- "Pitcairn" "-25.06" "-130.10" "Pacific/Pitcairn" }
  {- "South Georgia" "-54.25" "-36.75" "Atlantic/South_Georgia" }

  {"Greek"}
  {- "Athens" "37.98" "23.73" "Europe/Athens" default}

  {"Greenland"}
  {- "Godthab" "64.18" "-51.74" "America/Godthab" default}
  {- "Danmarkshavn" "76.77" "-18.67" "America/Danmarkshavn" }
  {- "Scoresbysund" "70.49" "-21.97" "America/Scoresbysund" }
  {- "Thule" "76.53" "-68.70" "America/Thule" }

  {"Guatemala"}
  {- "Guatemala" "14.61" "-90.54" "America/Guatemala" default}

  {"Guinea-Bissau"}
  {- "Bissau" "11.85" "-15.57" "Africa/Bissau" default}

  {"Guyana"}
  {- "Georgetown" "6.80" "-58.16" "America/Guyana" default}

  {"Haiti"}
  {- "Port-au-Prince" "18.53" "-72.33" "America/Port-au-Prince" default}

  {"Honduras"}
  {- "Tegucigalpa" "14.10" "-87.22" "America/Tegucigalpa" default}

  {"Hungary"}
  {- "Budapest" "47.29" "19.05" "Europe/Budapest" default}

  {"Iceland"}
  {- "Reykjavik" "64.15" "-21.93" "Atlantic/Reykjavik" default}

  {"India"}
  {- "Kolkata" "22.57" "88.36" "Asia/Kolkata" default}
  {- "New Dehli" "28.61" "77.21" "Asia/Kolkata" }

  {"Indonesia"}
  {- "Jakarta" "-6.20" "106.82" "Asia/Jakarta" default}
  {- "Jayapura" "-2.53" "140.72" "Asia/Jayapura" }
  {- "Makassar" "-5.13" "119.41" "Asia/Makassar" }
  {- "Pontianak" "-0.02" "109.34" "Asia/Pontianak" }

  {"Iran"}
  {- "Tehran" "35.69" "51.39" "Asia/Tehran" default}

  {"Iraq"}
  {- "Baghdad" "33.33" "44.38" "Asia/Baghdad" default}

  {"Ireland"}
  {- "Dublin" "53.34" "-6.27" "Europe/Dublin" default}

  {"Israel"}
  {- "Jerusalem" "31.78" "35.22" "Asia/Jerusalem" default}

  {"Italy"}
  {- "Rome" "41.88" "12.48" "Europe/Rome" default}

  {"Ivory Coast"}
  {- "Abidjan" "5.19" "-4.02" "Africa/Abidjan" default}

  {"Jamaica"}
  {- "Jamaica" "18.18" "-77.40" "America/Jamaica" default}

  {"Japan"}
  {- "Tokyo" "35.68" "139.68" "Asia/Tokyo" default}

  {"Jordan"}
  {- "Amman" "31.95" "35.93" "Asia/Amman" default}

  {"Kazakhstan"}
  {- "Almaty" "43.28" "76.90" "Asia/Almaty" default}
  {- "Aqtobe" "50.28" "57.17" "Asia/Aqtobe" }
  {- "Aqtau" "43.65" "51.15" "Asia/Aqtau" }
  {- "Atyrau" "47.12" "51.88" "Asia/Atyrau" }
  {- "Qostanay" "53.20" "63.62" "Asia/Qostanay" }
  {- "Oral" "51.23" "51.37" "Asia/Oral" }
  {- "Qyzylorda" "44.85" "65.52" "Asia/Qyzylorda" }

  {"Kenya"}
  {- "Nairobi" "-1.29" "36.82" "Africa/Nairobi" default}

  {"Kiribati"}
  {- "Enderbury" "-3.13" "-171.08" "Pacific/Enderbury" default}
  {- "Kiritimati" "1.87" "-157.40" "Pacific/Kiritimati" }

  {"Kyrgyzstan"}
  {- "Bishkek" "42.87" "74.61" "Asia/Bishkek" default}

  {"Latvia"}
  {- "Riga" "56.95" "24.10" "Europe/Riga" default}

  {"Lebanon"}
  {- "Beirut" "33.89" "35.51" "Asia/Beirut" default}

  {"Liberia"}
  {- "Monrovia" "6.31" "-10.80" "Africa/Monrovia" default}

  {"Libya"}
  {- "Tripoli" "32.88" "13.19" "Africa/Tripoli" default}

  {"Liechtenstein"}
  {- "Vaduz" "47.14" "9.52" "Europe/Vaduz" default}

  {"Lithuania"}
  {- "Vilnius" "54.68" "25.27" "Europe/Vilnius" default}

  {"Luxembourg"}
  {- "Luxembourg" "49.61" "6.13" "Europe/Luxembourg" default}

  {"Korea"}
  {- "Pyongyang" "39.02" "125.74" "Asia/Pyongyang" }
  {- "Seoul" "37.57" "126.97" "Asia/Seoul" default}

  {"Malaysia"}
  {- "Kuala Lumpur" "3.15" "101.70" "Asia/Kuala_Lumpur" default}
  {- "Kuching" "1.56" "110.34" "Asia/Kuching" }

  {"Maldives"}
  {- "Male" "4.18" "73.51" "Indian/Maldives" default}

  {"Malta"}
  {- "Valletta" "35.88" "14.51" "Europe/Malta" default}

  {"Marshall Islands"}
  {- "Kwajalein" "8.72" "167.73" "Pacific/Kwajalein" }
  {- "Majuro" "7.08" "171.38" "Pacific/Majuro" default}

  {"Mauritius"}
  {- "Port Louis" "-20.16" "57.50" "Indian/Mauritius" default}

  {"Mexico"}
  {- "Bahia Banderas" "20.65" "-105.38" "America/Bahia_Banderas" }
  {- "Cancun" "21.16" "-86.85" "America/Cancun" }
  {- "Chihuahua" "28.64" "-106.09" "America/Chihuahua" }
  {- "Hermosillo" "29.10" "-110.95" "America/Hermosillo" }
  {- "Matamoros" "25.88" "-97.50" "America/Matamoros" }
  {- "Mazatlan" "23.22" "-106.42" "America/Mazatlan" }
  {- "Merida" "20.97" "-89.62" "America/Merida" }
  {- "Mexico City" "19.43" "-99.13" "America/Mexico_City" default}
  {- "Monterrey" "25.67" "-100.30" "America/Monterrey" }
  {- "Ojinaga" "29.56" "-104.42" "America/Ojinaga" }
  {- "Tijuana" "32.53" "-117.03" "America/Tijuana" }

  {"Micronesia"}
  {- "Chuuk" "7.42" "151.78" "Pacific/Chuuk" default}
  {- "Pohnpei" "6.88" "158.23" "Pacific/Pohnpei" }
  {- "Kosrae" "5.32" "162.98" "Pacific/Kosrae" }

  {"Moldova"}
  {- "Chisinau" "47.01" "28.85" "Europe/Chisinau" default}

  {"Monaco"}
  {- "Monaco" "43.73" "7.42" "Europe/Monaco" default}

  {"Mongolia"}
  {- "Choibalsan" "48.08" "114.54" "Asia/Choibalsan" }
  {- "Hovd" "48.00" "91.64" "Asia/Hovd" }
  {- "Ulaanbaatar" "47.92" "106.92" "Asia/Ulaanbaatar" default}

  {"Montenegro"}
  {- "Podgorica" "42.44" "19.27" "Europe/Podgorica" default}

  {"Morocco"}
  {- "Casablanca" "33.53" "-7.58" "Africa/Casablanca" default}
  {- "El Aaiun" "27.15" "-13.20" "Africa/El_Aaiun"}

  {"Mozambique"}
  {- "Maputo" "-25.97" "32.58" "Africa/Maputo" default}

  {"Myanmar"}
  {- "Yangon" "16.85" "96.18" "Asia/Yangon" default}

  {"Namibia"}
  {- "Windhoek" "-22.57" "17.08" "Africa/Windhoek" default}

  {"Nauru"}
  {- "Nauru" "-0.53" "166.93" "Pacific/Nauru" default}

  {"Netherland"}
  {- "Amsterdam" "52.37" "4.89" "Europe/Amsterdam" default}
  {- "Curacao" "12.18" "-69.00" "America/Curacao" }

  {"Nepal"}
  {- "Kathmandu" "27.77" "85.27" "Asia/Kathmandu" default}

  {"New Zealand"}
  {- "Auckland" "-36.84" "174.74" "Pacific/Auckland" default}
  {- "Chatham" "-44.03" "-176.43" "Pacific/Chatham" }
  {- "Fakaofo" "-9.36" "-171.22" "Pacific/Fakaofo" }
  {- "Niue" "-19.05" "-169.85" "Pacific/Niue" }

  {"Nicaragua"}
  {- "Managua" "12.14" "-86.25" "America/Managua" default}

  {"Nigeria"}
  {- "Lagos" "6.46" "3.38" "Africa/Lagos" default}

  {"North Macedonia"}
  {- "Skopje" "41.99" "21.43" "Europe/Skopje" default}

  {"Norway"}
  {- "Oslo" "59.91" "10.75" "Europe/Oslo" default}

  {"Pakistan"}
  {- "Karachi" "24.86" "67.01" "Asia/Karachi" default}

  {"Palestine"}
  {- "Gaza" "31.52" "34.45" "Asia/Gaza" default}
  {- "Hebron" "31.53" "35.10" "Asia/Hebron" }

  {"Panama"}
  {- "Panama City" "8.98" "-79.52" "America/Panama" default}

  {"Papua New Guinea"}
  {- "Port Moresby" "-9.48" "147.15" "Pacific/Port_Moresby" default}

  {"Paraguay"}
  {- "Asuncion" "-25.30" "-57.63" "America/Asuncion" default}

  {"Peru"}
  {- "Lima" "-12.05" "-77.03" "America/Lima" default}

  {"Philippines"}
  {- "Manila" "14.60" "121.00" "Asia/Manila" default}

  {"Poland"}
  {- "Warsaw" "52.22" "21.03" "Europe/Warsaw" default}

  {"Portugal"}
  {- "Azores" "38.60" "-28.00" "Atlantic/Azores" }
  {- "Lisbon" "38.73" "-9.15" "Europe/Lisbon" default}
  {- "Madeira" "32.65" "-16.92" "Atlantic/Madeira" }

  {"Puerto Rico"}
  {- "Puerto Rico" "18.20" "-66.50" "America/Puerto_Rico" default}

  {"Qatar"}
  {- "Doha" "25.29" "51.53" "Asia/Qatar" default}

  {"Romania"}
  {- "Bucharest" "44.43" "26.10" "Europe/Bucharest" default}

  {"Russia"}
  {- "Anadyr" "64.73" "177.52" "Asia/Anadyr" }
  {- "Astrakhan" "46.35" "48.05" "Europe/Astrakhan" }
  {- "Barnaul" "53.33" "83.75" "Asia/Barnaul" }
  {- "Chita" "52.05" "113.47" "Asia/Chita" }
  {- "Irkutsk" "52.28" "104.28" "Asia/Irkutsk" }
  {- "Kaliningrad" "54.70" "20.45" "Europe/Kaliningrad" }
  {- "Kamchatka" "57.00" "160.00" "Asia/Kamchatka" }
  {- "Khandyga" "62.67" "135.55" "Asia/Khandyga" }
  {- "Kirov" "58.60" "49.68" "Europe/Kirov" }
  {- "Krasnoyarsk" "56.02" "92.87" "Asia/Krasnoyarsk" }
  {- "Magadan" "59.57" "150.80" "Asia/Magadan" }
  {- "Moscow" "55.75" "37.62" "Europe/Moscow" default}
  {- "Novokuznetsk" "53.77" "87.13" "Asia/Novokuznetsk" }
  {- "Novosibirsk" "55.05" "82.95" "Asia/Novosibirsk" }
  {- "Omsk" "54.98" "73.37" "Asia/Omsk" }
  {- "Sakhalin" "51.00" "143.00" "Asia/Sakhalin" }
  {- "Samara" "53.20" "50.14" "Europe/Samara" }
  {- "Saratov" "51.53" "46.02" "Europe/Saratov" }
  {- "Srednekolymsk" "67.47" "153.72" "Asia/Srednekolymsk" }
  {- "St. Petersburg" "59.94" "30.31" "Europe/Moscow"}
  {- "Tomsk" "56.50" "84.97" "Asia/Tomsk" }
  {- "Ulyanovsk" "54.32" "48.37" "Europe/Ulyanovsk" }
  {- "Ust-Nera" "64.58" "143.25" "Asia/Ust-Nera" }
  {- "Vladivostok" "43.13" "131.90" "Asia/Vladivostok" }
  {- "Volgograd" "48.70" "44.52" "Europe/Volgograd" }
  {- "Yakutsk" "62.03" "129.73" "Asia/Yakutsk" }
  {- "Yekaterinburg" "56.83" "60.58" "Asia/Yekaterinburg" }

  {"San Marino"}
  {- "San Marino" "43.94" "12.45" "Europe/San_Marino" default}

  {"Samoa"}
  {- "Apia" "-13.83" "-171.75" "Pacific/Apia" default}

  {"Sao Tome"}
  {- "Sao Tome" "0.34" "6.73" "Africa/Sao_Tome" default}

  {"Saudi Arabia"}
  {- "Riyadh" "24.63" "46.72" "Asia/Riyadh" default}

  {"Serbia"}
  {- "Belgrade" "44.82" "20.47" "Europe/Belgrade" default}

  {"Seychelles"}
  {- "Mahe" "-4.67" "55.47" "Indian/Mahe" default}

  {"Singapore"}
  {- "Singapore" "1.30" "103.80" "Asia/Singapore" default}

  {"Slovakia"}
  {- "Bratislava" "48.15" "17.15" "Europe/Bratislava" default}

  {"Slovenia"}
  {- "Ljubljana" "46.06" "14.51" "Europe/Ljubljana" default}

  {"Solomon Islands"}
  {- "Guadalcanal" "-9.62" "160.18" "Pacific/Guadalcanal" default}

  {"South Africa"}
  {- "Johannesburg" "-26.20" "28.05" "Africa/Johannesburg" default}

  {"South Sudan"}
  {- "Juba" "4.85" "31.60" "Africa/Juba" default}

  {"Spain" "Europe/Madrid"}
  {- "Barcelona" "41.38" "2.18" }
  {- "Canary" "28.15" "-15.42" "Atlantic/Canary" }
  {- "Ceuta" "35.89" "-5.32" "Africa/Ceuta" }
  {- "Madrid" "40.41" "-3.70" "Europe/Madrid" default}

  {"Sri Lanka"}
  {- "Colombo" "6.93" "79.84" "Asia/Colombo" default}

  {"Sudan"}
  {- "Khartoum" "15.50" "32.56" "Africa/Khartoum" default}

  {"Suriname"}
  {- "Paramaribo" "5.85" "-55.20" "America/Paramaribo" default}

  {"Sweden"}
  {- "Stockholm" "59.32" "18.05" "Europe/Stockholm" default}

  {"Switzerland" "Europe/Zurich"}
  {- "Bern" "46.95" "7.45"}
  {- "Genf" "46.20" "6.15"}
  {- "Zurich" "47.37" "8.55" "Europe/Zurich" default}

  {"Syria"}
  {- "Damascus" "33.51" "36.29" "Asia/Damascus" default}

  {"Tajikistan"}
  {- "Dushanbe" "38.54" "68.78" "Asia/Dushanbe" default}

  {"Tarawa"}
  {- "Tarawa" "1.33" "173.00" "Pacific/Tarawa" default}

  {"Thailand"}
  {- "Bangkok" "13.75" "100.49" "Asia/Bangkok" default}

  {"Tonga"}
  {- "Tongatapu" "-21.21" "-175.15" "Pacific/Tongatapu" default}

  {"Trinidad and Tobago"}
  {- "Port of Spain" "10.67" "-61.52" "America/Port_of_Spain" default}

  {"Tunisia"}
  {- "Tunis" "36.81" "10.18" "Africa/Tunis" default}

  {"Turkey" "Europe/Istanbul"}
  {- "Adana" "37.00" "35.32" }
  {- "Ankara" "39.93" "32.87" default}
  {- "Antalya" "36.89" "30.71" }
  {- "Bursa" "40.18" "29.05" }
  {- "Istanbul" "41.01" "28.96" }
  {- "Izmir" "38.42" "27.14" }
  {- "Konya" "37.87" "32.48" }
  {- "Mersin" "36.80" "34.63" }

  {"Turkmenistan"}
  {- "Ashgabat" "37.93" "58.37" "Asia/Ashgabat" default}

  {"Tuvalu"}
  {- "Funafuti" "-8.52" "179.20" "Pacific/Funafuti" default}

  {"Ukraine"}
  {- "Kiev" "50.45" "30.52" "Europe/Kiev" default}
  {- "Simferopol" "44.95" "34.10" "Europe/Simferopol" }
  {- "Uzhgorod" "48.62" "22.30" "Europe/Uzhgorod" }
  {- "Zaporozhye" "47.83" "35.17" "Europe/Zaporozhye" }

  {"United Arab Emirates"}
  {- "Dubai" "25.26" "55.30" "Asia/Dubai" default}

  {"Uruguay"}
  {- "Montevideo" "-34.88" "-56.18" "America/Montevideo" default}

  {"USA"}
  {- "Adak" "51.78" "-176.64" "America/Adak" }
  {- "Anchorage" "61.22" "-149.90" "America/Anchorage" }
  {- "Beulah" "47.27" "-101.78" "America/North_Dakota/Beulah" }
  {- "Boise" "43.62" "-116.20" "America/Boise" }
  {- "Center" "47.12" "-101.30" "America/North_Dakota/Center" }
  {- "Chicago" "41.84" "-87.68" "America/Chicago" }
  {- "Denver" "39.76" "-104.88" "America/Denver" }
  {- "Detroit" "42.33" "-83.05" "America/Detroit" }
  {- "Guam" "13.50" "144.80" "Pacific/Guam" }
  {- "Honolulu" "21.30" "-157.82" "Pacific/Honolulu" }
  {- "Indianapolis" "39.79" "-86.15" "America/Indiana/Indianapolis" }
  {- "Juneau" "58.30" "-134.42" "America/Juneau" }
  {- "Knox" "41.29" "-86.62" "America/Indiana/Knox" }
  {- "Louisville" "38.23" "-85.74" "America/Kentucky/Louisville" }
  {- "Los Angeles" "34.05" "-118.25" "America/Los_Angeles" }
  {- "Marengo" "38.37" "-86.34" "America/Indiana/Marengo" }
  {- "Menominee" "45.11" "-87.61" "America/Menominee" }
  {- "Metlakatla" "55.12" "-131.58" "America/Metlakatla" }
  {- "Monticello" "36.84" "-84.85" "America/Kentucky/Monticello" }
  {- "New Salem" "46.84" "-101.41" "America/North_Dakota/New_Salem" }
  {- "NewYork" "40.71" "-74.00" "America/New_York" default}
  {- "Nome" "64.50" "-165.40" "America/Nome" }
  {- "Pago Pago" "-14.28" "-170.70" "Pacific/Pago_Pago" }
  {- "Palau" "7.50" "134.50" "Pacific/Palau" }
  {- "Petersburg" "38.49" "-87.28" "America/Indiana/Petersburg" }
  {- "Phoenix" "33.45" "-112.07" "America/Phoenix" }
  {- "SanFrancisco" "37.78" "-122.42" "America/Los_Angeles"}
  {- "Sitka" "57.05" "-135.34" "America/Sitka" }
  {- "Tell City" "37.95" "-86.76" "America/Indiana/Tell_City" }
  {- "Vevay" "38.75" "-85.07" "America/Indiana/Vevay" }
  {- "Vincennes" "38.68" "-87.52" "America/Indiana/Vincennes" }
  {- "Wake Island" "19.30" "166.63" "Pacific/Wake" }
  {- "Winamac" "41.05" "-86.60" "America/Indiana/Winamac" }
  {- "Yakutat" "59.55" "-139.73" "America/Yakutat" }

  {"Usbekistan"}
  {- "Samarkand" "39.70" "66.98" "Asia/Samarkand" default}
  {- "Tashkent" "41.30" "69.27" "Asia/Tashkent" }

  {"Vatican"}
  {- "Vatican City" "41.90" "12.45" "Europe/Vatican" default}

  {"Venezuela"}
  {- "Caracas" "10.48" "-66.90" "America/Caracas" default}

  {"Vietnam"}
  {- "Ho Chi Minh" "10.80" "106.65" "Asia/Ho_Chi_Minh" default}
}

proc action_put_page {} {
  global env LOCATIONS TIMEZONES
  
  set iso8601_date [exec date -Iseconds]
  regexp {^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)([+-].+)$} $iso8601_date dummy year month day hour minute second zone
  
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
                    if {[get_platform] != "oci" && [get_platform] != "lxc"} {
                    table_data {align="left"} {
                      division {class="popupControls CLASS21506"} {
                        division {class="CLASS21507"} {onClick="apply_time()"} {
                          #puts "Uhrzeit &uuml;bernehmen"
                          puts "\${dialogSettingsTimePositionBtnSaveTime}"
                        }
                      }
                    }
                    }
                  }
                  if {[get_platform] != "oci" && [get_platform] != "lxc"} {
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
      }
      if {[get_platform] != "oci" && [get_platform] != "lxc"} {
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
              setPositionAllDevices();
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
  
  catch {exec /bin/updateTZ.sh}

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


