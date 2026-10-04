# Von OpenCCU unterstützte Homematic- und Homematic-IP-Geräte

[English version](supported-devices.md)

Diese Liste enthält alle Homematic (BidCos-RF, BidCos-Wired) und Homematic IP (HmIP-RF, HmIP-Wired) Gerätetypen, die von der aktuellen OpenCCU unterstützt werden. Sie soll vor dem Kauf neuer Geräte helfen zu prüfen, ob ein Gerät mit OpenCCU verwendet werden kann.

Die Liste wird automatisch aus den OpenCCU-Base Quellen erzeugt. Ein Gerätetyp gilt als unterstützt, wenn ihn der zuständige Schnittstellenprozess kennt:

- `BidCos-RF`: Gerätebeschreibungen des `rfd` (`src/devicetypes/rftypes/*.xml`)
- `BidCos-Wired`: Gerätebeschreibungen des `hs485d` (`src/devicetypes/hs485types/*.xml`)
- `HmIP-RF`/`HmIP-Wired`: Gerätespezifikationen im `HMIPServer.jar` (`opt/HMServer/HMIPServer.jar`)
- Beschreibungen: WebUI-Gerätedatenbank (`DEVDB.tcl`) und WebUI-Übersetzungen

**Datenbasis:** OpenCCU-Base Commit `ea614511caa2`, HMIPServer.jar Version `1.5.1-SNAPSHOT 2026-06-30T07:34:55Z`, erzeugt am 2026-10-04.  
**Neu erzeugen mit:** `scripts/generate-supported-devices.py --base <OpenCCU-Base>`

## Hinweise

- Für Homematic IP wird ein HmIP-fähiges Funkmodul (z.B. RPI-RF-MOD, HM-MOD-RPI-PCB, HmIP-RFUSB) benötigt, für Homematic IP Wired zusätzlich ein Homematic IP Wired Access Point (HmIPW-DRAP) und für Homematic Wired (BidCos-Wired/RS485) ein Homematic Wired LAN Gateway (HMW-LGW-O-DR-GS-EU).
- Bei einigen Gerätetypen hängt der Funktionsumfang von der Firmware des Geräts ab. OpenCCU kann Geräte-Firmware-Updates für viele Geräte direkt einspielen.
- Typbezeichnungen mit Ländersuffix (`-UK`, `-CH`, `-PE`, `-IT`) und Varianten (`-A` = anthrazit, `-2`/`-3` = neuere Hardwarerevision) sind jeweils eigene Einträge.
- Geräte in Abschnitt „Eingeschränkte Unterstützung“ werden zwar vom Schnittstellenprozess erkannt, haben aber keine eigene Integration in die WebUI (kein Gerätebild, keine Gerätebeschreibung). Sie lassen sich anlernen, die Bedienung in der WebUI kann jedoch eingeschränkt sein.

## Übersicht

| Protokoll | Anzahl Gerätetypen |
| --- | ---: |
| [Homematic IP (HmIP-RF)](#homematic-ip-hmip-rf) | 229 |
| [Homematic IP Wired (HmIP-Wired)](#homematic-ip-wired-hmip-wired) | 38 |
| [Homematic (BidCos-RF)](#homematic-bidcos-rf) | 203 |
| [Homematic Wired (BidCos-Wired, RS485)](#homematic-wired-bidcos-wired-rs485) | 10 |
| [Eingeschränkte Unterstützung (ohne WebUI-Integration)](#eingeschränkte-unterstützung-ohne-webui-integration) | 60 |
| **Gesamt** | **540** |

## Homematic IP (HmIP-RF)

| Typ | Beschreibung | Protokoll |
| --- | --- | --- |
| `ALPHA-IP-RBG` | Raumbediengerät Display (OEM: Möhlenhoff) | HmIP-RF |
| `ALPHA-IP-RBGa` | Raumbediengerät Analog (OEM: Möhlenhoff) | HmIP-RF |
| `ELV-SH-BM-S` | ELV Smart Home Sensor-Base | HmIP-RF |
| `ELV-SH-BS2` | Homematic IP Wandtaster für Markenschalter - 2-fach | HmIP-RF |
| `ELV-SH-CAP` | ELV Smart Home Luftdrucksensor Kompakt | HmIP-RF |
| `ELV-SH-CRC` | ELV Smart Home Taster Kompakt | HmIP-RF |
| `ELV-SH-CTH` | ELV Smart Home Temperatur- und Luftfeuchtigkeitssensor Kompakt | HmIP-RF |
| `ELV-SH-CTV` | ELV Smart Home Neigungs- und Erschütterungssensor Kompakt | HmIP-RF |
| `ELV-SH-CWD` | ELV Smart Home Wassersensor Kompakt | HmIP-RF |
| `ELV-SH-DUSI` | ELV Smart Home Ultraschall-Abstandssensor-Schnittstelle | HmIP-RF |
| `ELV-SH-KRC` | ELV Smart Home Schlüsselbundfernbedienung | HmIP-RF |
| `ELV-SH-PSMCI` | Homematic IP Schalten/Messen | HmIP-RF |
| `ELV-SH-PTI2` | ELV Smart Home Temperatursensor mit externen Fühlern - 2-fach | HmIP-RF |
| `ELV-SH-SB8` | ELV Smart Home Status-Board | HmIP-RF |
| `ELV-SH-SMS2` | ELV Smart Home Oberflächen-montierter Schalt-Aktor 2-fach | HmIP-RF |
| `ELV-SH-SMSI` | ELV Smart Home Bodenfeuchtesensor | HmIP-RF |
| `ELV-SH-SPS25` | ELV Smart Home Spannungsversorgung, schaltbar | HmIP-RF |
| `ELV-SH-SW1-BAT` | Homematic IP Schaltplatine für Batteriebetrieb | HmIP-RF |
| `ELV-SH-TACO` | ELV Smart Home Temperatur- und Beschleunigungssensor Außen | HmIP-RF |
| `ELV-SH-WSC` | Homematic IP Servosteuerung | HmIP-RF |
| `ELV-SH-WSM` | ELV Smart Home Bewässerungsaktor | HmIP-RF |
| `ELV-SH-WUA` | Homematic IP Universalaktor - 0-10 V | HmIP-RF |
| `HmIP-ASIR` | Homematic IP Alarmsirene | HmIP-RF |
| `HmIP-ASIR-2` | Homematic IP Alarmsirene | HmIP-RF |
| `HmIP-ASIR-B1` | Homematic IP Alarmsirene (OEM: Targa) | HmIP-RF |
| `HmIP-ASIR-O` | Homematic IP Alarmsirene außen | HmIP-RF |
| `HmIP-BBL` | Homematic IP Jalousieaktor für Markenschalter | HmIP-RF |
| `HmIP-BBL-2` | Homematic IP Jalousieaktor für Markenschalter | HmIP-RF |
| `HmIP-BBL-I` | Homematic IP Jalousieaktor für Markenschalter | HmIP-RF |
| `HmIP-BDT` | Homematic IP Dimmaktor für Markenschalter, Unterputzmontage | HmIP-RF |
| `HmIP-BDT-I` | Homematic IP Dimmaktor für Markenschalter, Unterputzmontage | HmIP-RF |
| `HmIP-BRC2` | Homematic IP Wandtaster für Markenschalter - 2-fach | HmIP-RF |
| `HmIP-BRC2-2` | Homematic IP Wandtaster für Markenschalter - 2-fach | HmIP-RF |
| `HmIP-BROLL` | Homematic IP Rollladenaktor für Markenschalter | HmIP-RF |
| `HmIP-BROLL-2` | Homematic IP Rollladenaktor für Markenschalter | HmIP-RF |
| `HmIP-BS2` | Homematic IP Wandtaster für Markenschalter - 2-fach | HmIP-RF |
| `HmIP-BSL` | Homematic IP Schaltaktor für Markenschalter - mit Signalleuchte | HmIP-RF |
| `HmIP-BSM` | Homematic IP Schaltaktor mit Leistungsmessung | HmIP-RF |
| `HmIP-BSM-I` | Homematic IP Schaltaktor mit Leistungsmessung | HmIP-RF |
| `HmIP-BWTH` | Homematic IP Wandthermostat | HmIP-RF |
| `HmIP-BWTH-A` | Homematic IP Wandthermostat | HmIP-RF |
| `HmIP-BWTH24` | Homematic IP Wandthermostat | HmIP-RF |
| `HmIP-DBB` | Homematic IP Türklingeltaster | HmIP-RF |
| `HmIP-DLD` | Homematic IP Türschlossantrieb | HmIP-RF |
| `HmIP-DLD-A` | Homematic IP Türschlossantrieb | HmIP-RF |
| `HmIP-DLD-S` | Homematic IP Türschlossantrieb | HmIP-RF |
| `HmIP-DLP` | Homematic IP Türschlossantrieb - Pro | HmIP-RF |
| `HmIP-DLP-A` | Homematic IP Türschlossantrieb - Pro | HmIP-RF |
| `HmIP-DLP-AS` | Homematic IP Türschlossantrieb - Pro | HmIP-RF |
| `HmIP-DLP-WS` | Homematic IP Türschlossantrieb - Pro | HmIP-RF |
| `HmIP-DLS` | Homematic IP Türschlosssensor | HmIP-RF |
| `HmIP-DRBLI4` | Homematic IP Jalousie- u. Rollladenaktor für Hutschienenmontage - 4-fach | HmIP-RF |
| `HmIP-DRDI3` | Homematic IP Dimmaktor für Hutschienenmontage - 3-fach | HmIP-RF |
| `HmIP-DRG-DALI` | Homematic IP DALI Gateway | HmIP-RF |
| `HmIP-DRSI1` | Homematic IP Schaltaktor für Hutschienenmontage - 1-fach | HmIP-RF |
| `HmIP-DRSI4` | Homematic IP Schaltaktor für Hutschienenmontage - 4-fach | HmIP-RF |
| `HmIP-DSD-PCB` | Homematic IP Klingelsignalsensor | HmIP-RF |
| `HmIP-ESI` | Homematic IP Energiezählerschnittstelle | HmIP-RF |
| `HmIP-ESI-IND` | Homematic IP Energiezählerschnittstelle | HmIP-RF |
| `HmIP-eTRV` | Homematic IP Heizkörperthermostat | HmIP-RF |
| `HmIP-eTRV-2` | Homematic IP Heizkörperthermostat (auch als `HmIP-eTRV-2 I9F`) | HmIP-RF |
| `HmIP-eTRV-2-UK` | Homematic IP Heizkörperthermostat UK | HmIP-RF |
| `HmIP-eTRV-3` | Homematic IP Heizkörperthermostat | HmIP-RF |
| `HmIP-eTRV-B` | Homematic IP Heizkörperthermostat - basic | HmIP-RF |
| `HmIP-eTRV-B-2` | Homematic IP Heizkörperthermostat - basic (auch als `HmIP-eTRV-B-2 R4M`) | HmIP-RF |
| `HmIP-eTRV-B-UK` | Homematic IP Heizkörperthermostat - basic UK | HmIP-RF |
| `HmIP-eTRV-B1` | Homematic IP Heizkörperthermostat - basic (OEM: Targa) | HmIP-RF |
| `HmIP-eTRV-C` | Homematic IP Heizkörperthermostat - kompakt | HmIP-RF |
| `HmIP-eTRV-C-2` | Homematic IP Heizkörperthermostat - kompakt | HmIP-RF |
| `HmIP-eTRV-CL` | Homematic IP Heizkörperthermostat - kompakt plus | HmIP-RF |
| `HmIP-eTRV-E` | Homematic IP Heizkörperthermostat - Evo | HmIP-RF |
| `HmIP-eTRV-E-A` | Homematic IP Heizkörperthermostat - Evo | HmIP-RF |
| `HmIP-eTRV-E-S` | Homematic IP Heizkörperthermostat - Evo | HmIP-RF |
| `HmIP-eTRV-F` | Homematic IP Heizkörperthermostat | HmIP-RF |
| `HmIP-eTRV-F-A` | Homematic IP Heizkörperthermostat | HmIP-RF |
| `HmIP-FAL230-C10` | Homematic IP Fußbodenheizungsaktor - 10-fach, 230 V | HmIP-RF |
| `HmIP-FAL230-C6` | Homematic IP Fußbodenheizungsaktor - 6-fach, 230 V | HmIP-RF |
| `HmIP-FAL24-C10` | Homematic IP Fußbodenheizungsaktor - 10-fach, 24 V | HmIP-RF |
| `HmIP-FAL24-C6` | Homematic IP Fußbodenheizungsaktor - 6-fach, 24 V | HmIP-RF |
| `HmIP-FALMOT-C12` | Homematic IP Fußbodenheizungsaktor - 12-fach, motorisch | HmIP-RF |
| `HmIP-FALMOT-C8` | Homematic IP Fußbodenheizungsaktor - 8-fach, motorisch | HmIP-RF |
| `HmIP-FBL` | Homematic IP Jalousieaktor, Unterputzmontage | HmIP-RF |
| `HmIP-FCI1` | Homematic IP Kontakt-Schnittstelle Unterputz - 1-fach | HmIP-RF |
| `HmIP-FCI6` | Homematic IP Kontakt-Schnittstelle Unterputz - 6-fach | HmIP-RF |
| `HmIP-FDC` | Homematic IP Universal Motorschloss Controller | HmIP-RF |
| `HmIP-FDT` | Homematic IP Dimmaktor, Unterputzmontage | HmIP-RF |
| `HmIP-FLC` | Homematic IP Universal Motorschloss Controller | HmIP-RF |
| `HmIP-FROLL` | Homematic IP Rollladenaktor, Unterputzmontage | HmIP-RF |
| `HmIP-FS6` | Homematic IP Schaltaktor - Unterputz | HmIP-RF |
| `HmIP-FSI16` | Homematic IP Schaltaktor mit Tastereingang (16 A) - Unterputz | HmIP-RF |
| `HmIP-FSI16-2` | Homematic IP Schaltaktor mit Tastereingang (16 A) - Unterputz | HmIP-RF |
| `HmIP-FSI6` | Homematic IP Schaltaktor mit Tastereingang - Unterputz | HmIP-RF |
| `HmIP-FSM` | Homematic IP Schaltaktor mit Leistungsmessung, Unterputzmontage | HmIP-RF |
| `HmIP-FSM16` | Homematic IP Schaltaktor mit Leistungsmessung, Unterputzmontage | HmIP-RF |
| `HmIP-FWI` | Homematic IP Wiegand-Schnittstelle | HmIP-RF |
| `HmIP-HAP` | Homematic IP Access Point (als LAN-Router nutzbar) (auch als `HmIP-HAP JS1`) | HmIP-RF |
| `HmIP-HAP-A` | Homematic IP Access Point (als LAN-Router nutzbar) | HmIP-RF |
| `HmIP-HAP-B1` | Homematic IP Access Point (als LAN-Router nutzbar) (OEM: Targa) | HmIP-RF |
| `HmIP-HAP2` | Homematic IP Access Point (als LAN-Router nutzbar) | HmIP-RF |
| `HmIP-HAP2-A` | Homematic IP Access Point (als LAN-Router nutzbar) | HmIP-RF |
| `HmIP-KRC4` | Homematic IP Schlüsselbundfernbedienung - 4 Tasten | HmIP-RF |
| `HmIP-KRC4-2` | Homematic IP Schlüsselbundfernbedienung - 4 Tasten | HmIP-RF |
| `HmIP-KRCA` | Homematic IP Schlüsselbundfernbedienung - Alarm | HmIP-RF |
| `HmIP-KRCA-2` | Homematic IP Schlüsselbundfernbedienung - Alarm | HmIP-RF |
| `HmIP-KRCK` | Homematic IP Schlüsselbundfernbedienung - Zutritt | HmIP-RF |
| `HmIP-KRCK-2` | Homematic IP Schlüsselbundfernbedienung - Zutritt | HmIP-RF |
| `HmIP-LSC` | Homematic IP Lightstrip Controller | HmIP-RF |
| `HmIP-M-TD15` | Homematic IP Rohrmotor - 15 Nm | HmIP-RF |
| `HmIP-MIO16-PCB` | Homematic IP Multi IO Modulpatine - 4x4 | HmIP-RF |
| `HmIP-MIOB` | Homematic IP Multi I/O-Box | HmIP-RF |
| `HmIP-MOD-HO` | Homematic IP Modul für Hörmann-Antriebe | HmIP-RF |
| `HmIP-MOD-OC8` | Homematic IP Schaltaktor mit OC-Ausgang | HmIP-RF |
| `HmIP-MOD-RC8` | Homematic IP Modulplatine Sender - 8-fach | HmIP-RF |
| `HmIP-MOD-TM` | Homematic IP Tormatic Modul (OEM: Novoferm) | HmIP-RF |
| `HmIP-MOD-WD-VK` | Homematic IP Modul für VEKA Fensterantriebe (OEM: VEKA) | HmIP-RF |
| `HmIP-MP3P` | Homematic IP MP3 Kombisignalgeber | HmIP-RF |
| `HmIP-PCBS` | Homematic IP Schaltplatine | HmIP-RF |
| `HmIP-PCBS-BAT` | Homematic IP Schaltplatine für Batteriebetrieb | HmIP-RF |
| `HmIP-PCBS2` | Homematic IP Schaltplatine - 2-fach | HmIP-RF |
| `HmIP-PDT` | Homematic IP Dimmaktor | HmIP-RF |
| `HmIP-PDT-A` | Homematic IP Dimmaktor | HmIP-RF |
| `HmIP-PDT-CH` | Homematic IP Dimmaktor (CH) | HmIP-RF |
| `HmIP-PDT-PE` | Homematic IP Dimmaktor (Pin Earth) | HmIP-RF |
| `HmIP-PDT-UK` | Homematic IP Dimmaktor | HmIP-RF |
| `HmIP-PMFS` | Homematic IP Netzausfallüberwachung | HmIP-RF |
| `HmIP-PS` | Homematic IP Zwischenstecker Schalten | HmIP-RF |
| `HmIP-PS-2` | Homematic IP Zwischenstecker Schalten (auch als `HmIP-PS-2 9YM`) | HmIP-RF |
| `HmIP-PS-A` | Homematic IP Zwischenstecker Schalten | HmIP-RF |
| `HmIP-PSM` | Homematic IP Zwischenstecker Schalten/Messen | HmIP-RF |
| `HmIP-PSM-2` | Homematic IP Zwischenstecker Schalten/Messen (auch als `HmIP-PSM-2 QHJ`) | HmIP-RF |
| `HmIP-PSM-A` | Homematic IP Zwischenstecker Schalten/Messen | HmIP-RF |
| `HmIP-PSM-CH` | Homematic IP Zwischenstecker Schalten/Messen (CH) | HmIP-RF |
| `HmIP-PSM-CH-2` | Homematic IP Zwischenstecker Schalten/Messen (CH) | HmIP-RF |
| `HmIP-PSM-IT` | Homematic IP Zwischenstecker Schalten/Messen (IT) | HmIP-RF |
| `HmIP-PSM-PE` | Homematic IP Zwischenstecker Schalten/Messen (Pin Earth) | HmIP-RF |
| `HmIP-PSM-PE-2` | Homematic IP Zwischenstecker Schalten/Messen (Pin Earth) | HmIP-RF |
| `HmIP-PSM-UK` | Homematic IP Zwischenstecker Schalten/Messen (UK) | HmIP-RF |
| `HmIP-PSMCO` | Homematic IP Schalten/Messen | HmIP-RF |
| `HmIP-RC8` | Homematic IP Fernbedienung, 8 Kanal | HmIP-RF |
| `HmIP-RCB1` | Homematic IP Fernbedienung mit Befestigungsband - 1-fach | HmIP-RF |
| `HmIP-RGBW` | Homematic IP LED Controller - RGBW | HmIP-RF |
| `HmIP-SAM` | Homematic IP Erschütterungs- / Beschleunigungssensor | HmIP-RF |
| `HmIP-SCI` | Homematic IP Kontakt-Schnittstelle | HmIP-RF |
| `HmIP-SCTH230` | Homematic IP CO2-Sensor, 230 V | HmIP-RF |
| `HmIP-SFD` | Homematic IP Feinstaubsensor | HmIP-RF |
| `HmIP-SLO` | Homematic IP Lichtsensor außen | HmIP-RF |
| `HmIP-SMI` | Homematic IP Bewegungsmelder innen | HmIP-RF |
| `HmIP-SMI55` | Homematic IP Bewegungsmelder für 55er Rahmen - innen | HmIP-RF |
| `HmIP-SMI55-2` | Homematic IP Bewegungsmelder für 55er Rahmen - innen | HmIP-RF |
| `HmIP-SMI55-A` | Homematic IP Bewegungsmelder für 55er Rahmen - innen | HmIP-RF |
| `HmIP-SMO` | Homematic IP Bewegungsmelder außen | HmIP-RF |
| `HmIP-SMO-2` | Homematic IP Bewegungsmelder außen | HmIP-RF |
| `HmIP-SMO-A` | Homematic IP Bewegungsmelder außen | HmIP-RF |
| `HmIP-SMO-A-2` | Homematic IP Bewegungsmelder außen | HmIP-RF |
| `HmIP-SMO230` | Homematic IP Bewegungsmelder außen | HmIP-RF |
| `HmIP-SMO230-A` | Homematic IP Bewegungsmelder außen | HmIP-RF |
| `HmIP-SPDR` | Homematic IP Durchgangssensor mit Richtungserkennung | HmIP-RF |
| `HmIP-SPI` | Homematic IP Präsenzmelder - innen | HmIP-RF |
| `HmIP-SRD` | Homematic IP Regensensor | HmIP-RF |
| `HmIP-SRH` | Homematic IP Fenster-/ Drehgriffkontakt | HmIP-RF |
| `HmIP-STE2-PCB` | Homematic IP Temperatursensor mit externen Fühlern - 2-fach | HmIP-RF |
| `HmIP-STH` | Homematic IP Temperatur- und Luftfeuchtigkeitssensor - innen (auch als `HmIP-STH 8DU`) | HmIP-RF |
| `HmIP-STH-A` | Homematic IP Temperatur- und Luftfeuchtigkeitssensor - innen (auch als `HmIP-STH-A 8DU`) | HmIP-RF |
| `HmIP-STHD` | Homematic IP Temperatur- und Luftfeuchtigkeitssensor mit Display - innen (auch als `HmIP-STHD L9D`) | HmIP-RF |
| `HmIP-STHD-A` | Homematic IP Temperatur- und Luftfeuchtigkeitssensor mit Display - innen (auch als `HmIP-STHD-A L9D`) | HmIP-RF |
| `HmIP-STHO` | Homematic IP Temperatur- und Luftfeuchtigkeitssensor außen | HmIP-RF |
| `HmIP-STHO-A` | Homematic IP Temperatur- und Luftfeuchtigkeitssensor außen | HmIP-RF |
| `HmIP-STI` | Homematic IP Touch-Sensor | HmIP-RF |
| `HmIP-STV` | Homematic IP Neigungs- und Erschütterungssensor | HmIP-RF |
| `HmIP-SWD` | Homematic IP Wassersensor | HmIP-RF |
| `HmIP-SWD-2` | Homematic IP Wassersensor | HmIP-RF |
| `HmIP-SWDM` | Homematic IP Fenster- und Türkontakt mit Magnet | HmIP-RF |
| `HmIP-SWDM-2` | Homematic IP Fenster- und Türkontakt mit Magnet | HmIP-RF |
| `HmIP-SWDM-B2` | Homematic IP Fenster- und Türkontakt mit Magnet (OEM: Targa) | HmIP-RF |
| `HmIP-SWDO` | Homematic IP Fenster- und Türkontakt - optisch | HmIP-RF |
| `HmIP-SWDO-2` | Homematic IP Fenster- und Türkontakt - optisch | HmIP-RF |
| `HmIP-SWDO-A` | Homematic IP Fenster- und Türkontakt - optisch | HmIP-RF |
| `HmIP-SWDO-I` | Homematic IP Fenster- und Türkontakt - verdeckter Einbau | HmIP-RF |
| `HmIP-SWDO-PL` | Homematic IP Fenster- und Türkontakt - optisch, plus | HmIP-RF |
| `HmIP-SWDO-PL-2` | Homematic IP Fenster- und Türkontakt - optisch, plus | HmIP-RF |
| `HmIP-SWO-B` | Homematic IP Wettersensor - basic | HmIP-RF |
| `HmIP-SWO-PL` | Homematic IP Wettersensor - plus | HmIP-RF |
| `HmIP-SWO-PR` | Homematic IP Wettersensor - pro | HmIP-RF |
| `HmIP-SWSD` | Homematic IP Rauchmelder | HmIP-RF |
| `HmIP-SWSD-2` | Homematic IP Rauchmelder | HmIP-RF |
| `HmIP-SWSD-2-NL` | Homematic IP Rauchmelder | HmIP-RF |
| `HmIP-UDI-PB2` | Homematic IP Universal Dimmeraufsatz - Taster | HmIP-RF |
| `HmIP-UDI-PB2-A` | Homematic IP Universal Dimmeraufsatz - Taster | HmIP-RF |
| `HmIP-UDI-SMI55` | Homematic IP Universal Dimmeraufsatz - Bewegungsmelder | HmIP-RF |
| `HmIP-UDI-SMI55-A` | Homematic IP Universal Dimmeraufsatz - Bewegungsmelder | HmIP-RF |
| `HmIP-USBSM` | Homematic IP Schalt-Mess-Aktor für USB | HmIP-RF |
| `HmIP-WGC` | Homematic IP Garagentortaster | HmIP-RF |
| `HmIP-WGD` | Homematic IP Funk Glasdisplay | HmIP-RF |
| `HmIP-WGD-PL` | Homematic IP Funk Glasdisplay - plus | HmIP-RF |
| `HmIP-WGS` | Homematic IP Glastaster | HmIP-RF |
| `HmIP-WGS-A` | Homematic IP Glastaster | HmIP-RF |
| `HmIP-WGT` | Homematic IP Glasthermostat - 230 V | HmIP-RF |
| `HmIP-WGT-A` | Homematic IP Glasthermostat - 230 V | HmIP-RF |
| `HmIP-WGTC` | Homematic IP Glas-Wandthermostat mit CO2-Sensor | HmIP-RF |
| `HmIP-WGTC-A` | Homematic IP Glas-Wandthermostat mit CO2-Sensor | HmIP-RF |
| `HmIP-WHS2` | Homematic IP Schaltaktor für Heiz-Systeme - 2 Kanal | HmIP-RF |
| `HmIP-WKP` | Homematic IP Keypad | HmIP-RF |
| `HmIP-WRC2` | Homematic IP Wandtaster 2-fach | HmIP-RF |
| `HmIP-WRC2-2` | Homematic IP Wandtaster 2-fach | HmIP-RF |
| `HmIP-WRC2-A` | Homematic IP Wandtaster 2-fach | HmIP-RF |
| `HmIP-WRC2-A-2` | Homematic IP Wandtaster 2-fach | HmIP-RF |
| `HmIP-WRC6` | Homematic IP Wandtaster 6-fach | HmIP-RF |
| `HmIP-WRC6-230` | Homematic IP Wandtaster 6-fach, 230V | HmIP-RF |
| `HmIP-WRC6-230-A` | Homematic IP Wandtaster 6-fach, 230V | HmIP-RF |
| `HmIP-WRC6-A` | Homematic IP Wandtaster 6-fach | HmIP-RF |
| `HmIP-WRCC2` | Homematic IP Wandtaster - flach | HmIP-RF |
| `HmIP-WRCD` | Homematic IP Wandtaster mit Statusdisplay | HmIP-RF |
| `HmIP-WRCR` | Homematic IP Drehtaster | HmIP-RF |
| `HmIP-WSC` | Homematic IP Servosteuerung | HmIP-RF |
| `HmIP-WSM` | Homematic IP Bewässerungsaktor | HmIP-RF |
| `HmIP-WSS` | Homematic IP Wasserabsperr- und Versorgungseinheit | HmIP-RF |
| `HmIP-WSS-GB` | Homematic IP Wasserabsperr- und Versorgungseinheit | HmIP-RF |
| `HmIP-WT` | Homematic IP Wandthermostat | HmIP-RF |
| `HmIP-WTH` | Homematic IP Wandthermostat | HmIP-RF |
| `HmIP-WTH-1` | Homematic IP Wandthermostat mit Luftfeuchtigkeitssensor | HmIP-RF |
| `HmIP-WTH-2` | Homematic IP Wandthermostat mit Luftfeuchtigkeitssensor | HmIP-RF |
| `HmIP-WTH-3` | Homematic IP Wandthermostat mit Luftfeuchtigkeitssensor | HmIP-RF |
| `HmIP-WTH-3-A` | Homematic IP Wandthermostat mit Luftfeuchtigkeitssensor | HmIP-RF |
| `HmIP-WTH-A` | Homematic IP Wandthermostat mit Luftfeuchtigkeitssensor | HmIP-RF |
| `HmIP-WTH-B` | Homematic IP Wandthermostat - basic | HmIP-RF |
| `HmIP-WTH-B-2` | Homematic IP Wandthermostat - basic | HmIP-RF |
| `HmIP-WTH-B-A` | Homematic IP Wandthermostat - basic | HmIP-RF |
| `HmIP-WUA` | Homematic IP Universalaktor - 0-10 V | HmIP-RF |
| `RM-110-45/15` | TEXINO Rohrmotor HmIP 8-Kantwelle 60mm/15Nm | HmIP-RF |

## Homematic IP Wired (HmIP-Wired)

| Typ | Beschreibung | Protokoll |
| --- | --- | --- |
| `HmIPW-BRC2` | Homematic IP Wired Wandtaster für Markenschalter - 2-fach | HmIP-Wired |
| `HmIPW-DRAP` | Homematic IP Wired Access Point | HmIP-Wired |
| `HmIPW-DRBL4` | Homematic IP Wired Jalousie- u. Rollladenaktor - 4-fach | HmIP-Wired |
| `HmIPW-DRD3` | Homematic IP Wired Dimmaktor - 3-fach | HmIP-Wired |
| `HmIPW-DRI16` | Homematic IP Wired Eingangsmodul - 16-fach | HmIP-Wired |
| `HmIPW-DRI32` | Homematic IP Wired Eingangsmodul - 32-fach | HmIP-Wired |
| `HmIPW-DRS4` | Homematic IP Wired Schaltaktor - 4-fach | HmIP-Wired |
| `HmIPW-DRS8` | Homematic IP Wired Schaltaktor - 8-fach | HmIP-Wired |
| `HmIPW-FAL230-C10` | Homematic IP Wired Fußbodenheizungsaktor - 10-fach, 230 V | HmIP-Wired |
| `HmIPW-FAL230-C6` | Homematic IP Wired Fußbodenheizungsaktor - 6-fach, 230 V | HmIP-Wired |
| `HmIPW-FAL24-C10` | Homematic IP Wired Fußbodenheizungsaktor - 10-fach, 24 V | HmIP-Wired |
| `HmIPW-FAL24-C6` | Homematic IP Wired Fußbodenheizungsaktor - 6-fach, 24 V | HmIP-Wired |
| `HmIPW-FALMOT-C12` | Homematic IP Fußbodenheizungsaktor - 12-fach, motorisch | HmIP-Wired |
| `HmIPW-FIO6` | Homematic IP Wired IO Modul Unterputz - 6-fach | HmIP-Wired |
| `HmIPW-SCTHD` | Homematic IP Wired CO2-Sensor | HmIP-Wired |
| `HmIPW-SMI55` | Homematic IP Wired Bewegungsmelder für 55er Rahmen - innen | HmIP-Wired |
| `HmIPW-SMI55-A` | Homematic IP Wired Bewegungsmelder für 55er Rahmen - innen | HmIP-Wired |
| `HmIPW-SMO230` | Homematic IP Bewegungsmelder außen | HmIP-Wired |
| `HmIPW-SMO230-A` | Homematic IP Bewegungsmelder außen | HmIP-Wired |
| `HmIPW-SPI` | Homematic IP Wired Präsenzmelder - innen | HmIP-Wired |
| `HmIPW-STH` | Homematic IP Wired Temperatur- und Luftfeuchtigkeitssensor - innen | HmIP-Wired |
| `HmIPW-STH-A` | Homematic IP Wired Temperatur- und Luftfeuchtigkeitssensor - innen | HmIP-Wired |
| `HmIPW-STHD` | Homematic IP Wired Temperatur- und Luftfeuchtigkeitssensor mit Display - innen | HmIP-Wired |
| `HmIPW-STHD-A` | Homematic IP Wired Temperatur- und Luftfeuchtigkeitssensor mit Display - innen | HmIP-Wired |
| `HmIPW-WGD` | Homematic IP Wired Glasdisplay | HmIP-Wired |
| `HmIPW-WGD-PL` | Homematic IP Wired Glasdisplay - plus | HmIP-Wired |
| `HmIPW-WGS` | Homematic IP Wired Glastaster | HmIP-Wired |
| `HmIPW-WGS-A` | Homematic IP Wired Glastaster | HmIP-Wired |
| `HmIPW-WGT` | Homematic IP Wired Glasthermostat | HmIP-Wired |
| `HmIPW-WGT-A` | Homematic IP Wired Glasthermostat | HmIP-Wired |
| `HmIPW-WGTC` | Homematic IP Wired Glas-Wandthermostat mit CO2-Sensor | HmIP-Wired |
| `HmIPW-WGTC-A` | Homematic IP Wired Glas-Wandthermostat mit CO2-Sensor | HmIP-Wired |
| `HmIPW-WRC2` | Homematic IP Wired Wandtaster - 2-fach | HmIP-Wired |
| `HmIPW-WRC2-A` | Homematic IP Wired Wandtaster - 2-fach | HmIP-Wired |
| `HmIPW-WRC6` | Homematic IP Wired Wandtaster - 6-fach | HmIP-Wired |
| `HmIPW-WRC6-A` | Homematic IP Wired Wandtaster - 6-fach | HmIP-Wired |
| `HmIPW-WTH` | Homematic IP Wired Wandthermostat mit Luftfeuchtigkeitssensor | HmIP-Wired |
| `HmIPW-WTH-A` | Homematic IP Wired Wandthermostat mit Luftfeuchtigkeitssensor | HmIP-Wired |

## Homematic (BidCos-RF)

| Typ | Beschreibung | Protokoll |
| --- | --- | --- |
| `263 130` | Funk-Schaltaktor 1-fach, Unterputzmontage (OEM: Schüco) | BidCos-RF |
| `263 131` | Funk-Schaltaktor 1-fach, Unterputzmontage (OEM: Schüco) | BidCos-RF |
| `263 132` | Funk-Dimmaktor 1-fach, Phasenanschnitt, Zwischendeckenmontage (OEM: Schüco) | BidCos-RF |
| `263 133` | Funk-Dimmaktor 1-fach für Markenschalter, Phasenabschnitt, Unterputzmontage (OEM: Schüco) | BidCos-RF |
| `263 134` | Funk-Dimmaktor 2-fach, Phasenabschnitt, Aufputzmontage (OEM: Schüco) | BidCos-RF |
| `263 135` | Funk-Wandtaster 2-fach im 55er Rahmen (OEM: Schüco) | BidCos-RF |
| `263 144` | Funk-Schalterschnittstelle 3-fach, Unterputzmontage (OEM: Schüco) | BidCos-RF |
| `263 145` | Funk-Tasterschnittstelle 4-fach, Unterputzmontage (OEM: Schüco) | BidCos-RF |
| `263 146` | Funk-Rollladenaktor 1-fach, Unterputzmontage (OEM: Schüco) | BidCos-RF |
| `263 147` | Funk-Rollladenaktor 1-fach, Aufputzmontage (OEM: Schüco) | BidCos-RF |
| `263 155` | Funk-Display-Wandtaster 2-fach, Aufputzmontage (OEM: Schüco) | BidCos-RF |
| `263 157` | Funk-Temperatursensor innen (OEM: Schüco) | BidCos-RF |
| `263 158` | Funk-Temperatur-/ Feuchtesensor außen (OEM: Schüco) | BidCos-RF |
| `263 160` | Funk-Kohlendioxid-Sensor (OEM: Schüco) | BidCos-RF |
| `263 162` | Funk-Bewegungsmelder innen (OEM: Schüco) | BidCos-RF |
| `263 167` | Funk-Rauchmelder (OEM: Schüco) | BidCos-RF |
| `263_149_/_263_150` | Schüco WCS-TipTronic-Platine (OEM: Schüco) | BidCos-RF |
| `atent` | Funk-Handsender DORMA (OEM: DORMA) | BidCos-RF |
| `BRC-H` | Funk-Handsender DORMA, 4-Kanal (OEM: DORMA) | BidCos-RF |
| `HM-CC-RT-DN` | Funk-Heizkörperthermostat | BidCos-RF |
| `HM-CC-SCD` | Funk-Kohlendioxid-Sensor | BidCos-RF |
| `HM-CC-TC` | Funk-Wandthermostat | BidCos-RF |
| `HM-CC-VD` | Funk-Stellantrieb | BidCos-RF |
| `HM-Dis-EP-WM55` | Display-Statusanzeige mit E-Paper-Display | BidCos-RF |
| `HM-Dis-TD-T` | Funk-Statusanzeige | BidCos-RF |
| `HM-Dis-WM55` | Display-Statusanzeige | BidCos-RF |
| `HM-DW-WM` | Funk-Dimmaktor 2-fach PWM LED | BidCos-RF |
| `HM-ES-PMSw1-DR` | Funk-Schaltaktor mit Leistungsmessung, Hutschienenmontage | BidCos-RF |
| `HM-ES-PMSw1-Pl` | Funk-Schaltaktor mit Leistungsmessung | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R1` | Funk-Schaltaktor mit Leistungsmessung | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R2` | Funk-Schaltaktor mit Leistungsmessung | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R3` | Funk-Schaltaktor mit Leistungsmessung | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R4` | Funk-Schaltaktor mit Leistungsmessung | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R5` | Funk-Schaltaktor mit Leistungsmessung | BidCos-RF |
| `HM-ES-PMSw1-SM` | Funk-Schaltaktor mit Leistungsmessung | BidCos-RF |
| `HM-ES-TX-WM` | Funk-Sender für Energiezähler-Sensor | BidCos-RF |
| `HM-LC-AO-SM` | Funk 0-10V Aktor | BidCos-RF |
| `HM-LC-Bl1-FM` | Funk-Rollladenaktor 1-fach, Unterputzmontage | BidCos-RF |
| `HM-LC-Bl1-FM-2` | Funk-Rollladenaktor 1-fach, Unterputzmontage | BidCos-RF |
| `HM-LC-Bl1-PB-FM` | Funk-Rollladenaktor 1-fach, Unterputzmontage mit Tasteraufsatz | BidCos-RF |
| `HM-LC-Bl1-SM` | Funk-Rollladenaktor 1-fach, Aufputzmontage | BidCos-RF |
| `HM-LC-Bl1-SM-2` | Funk-Rollladenaktor 1-fach, Aufputzmontage | BidCos-RF |
| `HM-LC-Bl1PBU-FM` | Funk-Rollladenaktor 1-fach für Markenschalter, Unterputz | BidCos-RF |
| `HM-LC-DDC1-PCB` | Funk-Empfänger 1-Kanal | BidCos-RF |
| `HM-LC-Dim1L-CV` | Funk-Dimmaktor 1-fach, Phasenanschnitt, Zwischendeckenmontage | BidCos-RF |
| `HM-LC-Dim1L-CV-2` | Funk-Dimmaktor 1-fach, Phasenanschnitt, Zwischendeckenmontage | BidCos-RF |
| `HM-LC-Dim1L-Pl` | Funk-Zwischenstecker-Dimmaktor 1-fach, Phasenanschnitt | BidCos-RF |
| `HM-LC-Dim1L-Pl-2` | Funk-Zwischenstecker-Dimmaktor 1-fach, Phasenanschnitt | BidCos-RF |
| `HM-LC-Dim1L-Pl-3` | Funk-Zwischenstecker-Dimmaktor 1-fach, Phasenanschnitt | BidCos-RF |
| `HM-LC-Dim1PWM-CV` | Funk-Dimmaktor 1-fach PWM LED, Zwischendeckenmontage | BidCos-RF |
| `HM-LC-Dim1PWM-CV-2` | Funk-Dimmaktor 1-fach PWM LED, Zwischendeckenmontage | BidCos-RF |
| `HM-LC-Dim1T-CV` | Funk-Dimmaktor 1-fach, Phasenabschnitt, Zwischendeckenmontage | BidCos-RF |
| `HM-LC-Dim1T-CV-2` | Funk-Dimmaktor 1-fach, Phasenabschnitt, Zwischendeckenmontage | BidCos-RF |
| `HM-LC-Dim1T-DR` | Funk-Dimmaktor 1-fach, Phasenabschnitt, Hutschienenmontage | BidCos-RF |
| `HM-LC-Dim1T-FM` | Funk-Dimmaktor 1-fach, Phasenabschnitt, Unterputzmontage | BidCos-RF |
| `HM-LC-Dim1T-FM-2` | Funk-Dimmaktor 1-fach, Phasenabschnitt, Unterputzmontage | BidCos-RF |
| `HM-LC-Dim1T-FM-LF` | Funk-Dimmaktor 1-fach, Phasenabschnitt, Unterputzmontage | BidCos-RF |
| `HM-LC-Dim1T-Pl` | Funk-Dimmaktor 1-fach, Zwischenstecker, Phasenabschnitt | BidCos-RF |
| `HM-LC-Dim1T-Pl-2` | Funk-Dimmaktor 1-fach, Zwischenstecker, Phasenabschnitt | BidCos-RF |
| `HM-LC-Dim1T-Pl-3` | Funk-Dimmaktor 1-fach, Zwischenstecker, Phasenabschnitt | BidCos-RF |
| `HM-LC-Dim1TPBU-FM` | Funk-Dimmaktor 1-fach für Markenschalter, Phasenabschnitt, Unterputzmontage | BidCos-RF |
| `HM-LC-Dim1TPBU-FM-2` | Funk-Dimmaktor 1-fach für Markenschalter, Phasenabschnitt, Unterputzmontage | BidCos-RF |
| `HM-LC-Dim2L-SM` | Funk-Dimmaktor 2-fach, Phasenanschnitt, Aufputzmontage | BidCos-RF |
| `HM-LC-Dim2L-SM-2` | Funk-Dimmaktor 2-fach, Phasenanschnitt, Aufputzmontage | BidCos-RF |
| `HM-LC-Dim2T-SM` | Funk-Dimmaktor 2-fach, Phasenabschnitt, Aufputzmontage | BidCos-RF |
| `HM-LC-Dim2T-SM-2` | Funk-Dimmaktor 2-fach, Phasenabschnitt, Aufputzmontage | BidCos-RF |
| `HM-LC-DW-WM` | Funk-Controller für Dual-White-LEDs | BidCos-RF |
| `HM-LC-Ja1PBU-FM` | Funk-Jalousieaktor 1-fach für Markenschalter, Unterputz | BidCos-RF |
| `HM-LC-RGBW-WM` | Funk-RGBW-Controller, Wandmontage | BidCos-RF |
| `HM-LC-Sw1-Ba-PCB` | Funk-Schaltaktor 1-fach, Platine Batterie | BidCos-RF |
| `HM-LC-Sw1-DR` | Funk-Schaltaktor 1-fach, Hutschienenmontage | BidCos-RF |
| `HM-LC-Sw1-FM` | Funk-Schaltaktor 1-fach, Unterputzmontage | BidCos-RF |
| `HM-LC-Sw1-FM-2` | Funk-Schaltaktor 1-fach, Unterputzmontage | BidCos-RF |
| `HM-LC-Sw1-PB-FM` | Funk-Schaltaktor 1-fach, Unterputzmontage | BidCos-RF |
| `HM-LC-Sw1-PCB` | Funk-Schaltaktor 1-fach, Platine | BidCos-RF |
| `HM-LC-Sw1-Pl` | Funk-Schaltaktor 1-fach, Zwischenstecker | BidCos-RF |
| `HM-LC-Sw1-Pl-2` | Funk-Schaltaktor 1-fach, Zwischenstecker | BidCos-RF |
| `HM-LC-Sw1-Pl-3` | Funk-Schaltaktor 1-fach, Zwischenstecker | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R1` | Funk-Schaltaktor 1-fach mit Klemmanschluss | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R1` | Funk-Schaltaktor 1-fach, Zwischenstecker | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R2` | Funk-Schaltaktor 1-fach, Zwischenstecker | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R3` | Funk-Schaltaktor 1-fach, Zwischenstecker | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R4` | Funk-Schaltaktor 1-fach, Zwischenstecker | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R5` | Funk-Schaltaktor 1-fach, Zwischenstecker | BidCos-RF |
| `HM-LC-Sw1-Pl-OM54` | Funk-Schalter, 1-Kanal | BidCos-RF |
| `HM-LC-Sw1-SM` | Funk-Schaltaktor 1-fach, Aufputzmontage | BidCos-RF |
| `HM-LC-Sw1-SM-2` | Funk-Schaltaktor 1-fach, Aufputzmontage | BidCos-RF |
| `HM-LC-Sw1-SM-ATmega168` | Funk-Schaltaktor 1-fach, Aufputzmontage | BidCos-RF |
| `HM-LC-Sw1PBU-FM` | Funk-Schaltaktor 1-fach für Markenschalter, Unterputzmontage | BidCos-RF |
| `HM-LC-Sw2-DR` | Funk-Schaltaktor 2-fach, Hutschienenmontage | BidCos-RF |
| `HM-LC-Sw2-DR-2` | Funk-Schaltaktor 2-fach, Hutschienenmontage | BidCos-RF |
| `HM-LC-Sw2-FM` | Funk-Schaltaktor 2-fach, Unterputzmontage | BidCos-RF |
| `HM-LC-Sw2-FM-2` | Funk-Schaltaktor 2-fach, Unterputzmontage | BidCos-RF |
| `HM-LC-Sw2-PB-FM` | Funk-Schaltaktor 2-fach, Unterputzmontage | BidCos-RF |
| `HM-LC-Sw2PBU-FM` | Funk-Schaltaktor 2-fach, Unterputzmontage | BidCos-RF |
| `HM-LC-Sw4-Ba-PCB` | Funk-Schaltaktor 4fach Platine Batterie | BidCos-RF |
| `HM-LC-Sw4-DR` | Funk-Schaltaktor 4-fach, Hutschienenmontage | BidCos-RF |
| `HM-LC-Sw4-DR-2` | Funk-Schaltaktor 4-fach, Hutschienenmontage | BidCos-RF |
| `HM-LC-Sw4-PCB` | Funk-Schaltaktor 4-fach, Platine | BidCos-RF |
| `HM-LC-Sw4-PCB-2` | Funk-Schaltaktor 4-fach, Platine | BidCos-RF |
| `HM-LC-Sw4-SM` | Funk-Schaltaktor 4-fach, Aufputzmontage | BidCos-RF |
| `HM-LC-Sw4-SM-2` | Funk-Schaltaktor 4-fach, Aufputzmontage | BidCos-RF |
| `HM-LC-Sw4-SM-ATmega168` | Funk-Schaltaktor 4-fach, Aufputzmontage | BidCos-RF |
| `HM-LC-Sw4-WM` | Funk-Schaltaktor 4-fach, Wandmontage | BidCos-RF |
| `HM-LC-Sw4-WM-2` | Funk-Schaltaktor 4-fach, Wandmontage | BidCos-RF |
| `HM-MOD-EM-8` | Funk-Sendemodul 8-Kanal, Platine Batterie | BidCos-RF |
| `HM-MOD-EM-8Bit` | Funk-Sendemodul, 8-Bit | BidCos-RF |
| `HM-MOD-Re-8` | Funk-Schaltaktor 8-fach, Platine Batterie | BidCos-RF |
| `HM-OU-CF-Pl` | Funk-Türgong mit Signalleuchte | BidCos-RF |
| `HM-OU-CFM-Pl` | MP3 Funk-Gong mit Signalleuchte | BidCos-RF |
| `HM-OU-CFM-TW` | MP3 Funk-Gong mit Signalleuchte für Batteriebetrieb | BidCos-RF |
| `HM-OU-CM-PCB` | Funk-Gongmodul MP3 mit Speicher | BidCos-RF |
| `HM-OU-LED16` | Funk-Statusanzeige LED 16 | BidCos-RF |
| `HM-PB-2-FM` | Funk-Wandtaster 2-fach | BidCos-RF |
| `HM-PB-2-WM` | Funk-Wandtaster 2-fach | BidCos-RF |
| `HM-PB-2-WM55` | Funk-Wandtaster 2-fach im 55er Rahmen | BidCos-RF |
| `HM-PB-2-WM55-2` | Funk-Wandtaster 2-fach im 55er Rahmen | BidCos-RF |
| `HM-PB-4-WM` | Funk-Wandtaster 4-fach | BidCos-RF |
| `HM-PB-4Dis-WM` | Funk-Display-Wandtaster 2-fach, Aufputzmontage | BidCos-RF |
| `HM-PB-4Dis-WM-2` | Funk-Display-Wandtaster 2-fach, Aufputzmontage | BidCos-RF |
| `HM-PB-6-WM55` | Funk-Wandtaster 6-fach im 55er Rahmen | BidCos-RF |
| `HM-PBI-4-FM` | Funk-Tasterschnittstelle 4-fach, Unterputzmontage | BidCos-RF |
| `HM-RC-12` | Funk-Fernbedienung 12 Tasten | BidCos-RF |
| `HM-RC-12-B` | Funk-Fernbedienung 12 Tasten, schwarz | BidCos-RF |
| `HM-RC-19` | Funk-Fernbedienung 19 Tasten | BidCos-RF |
| `HM-RC-19-B` | Funk-Fernbedienung 19 Tasten | BidCos-RF |
| `HM-RC-19-SW` | Funk-Fernbedienung 19 Tasten | BidCos-RF |
| `HM-RC-2-PBU-FM` | Funk-Sender 2-fach für Markenschalter, Unterputzmontage | BidCos-RF |
| `HM-RC-2-PBU-FM-2` | Funk-Sender 2-fach für Markenschalter, Unterputzmontage | BidCos-RF |
| `HM-RC-4` | Funk-Handsender 4 Tasten | BidCos-RF |
| `HM-RC-4-2` | Funk-Handsender 4 Tasten | BidCos-RF |
| `HM-RC-4-3` | Funk-Handsender 4 Tasten | BidCos-RF |
| `HM-RC-4-3-D` | Funk-Handsender 4 Tasten | BidCos-RF |
| `HM-RC-4-B` | Funk-Handsender 4 Tasten | BidCos-RF |
| `HM-RC-8` | Funk-Handsender 8 Tasten | BidCos-RF |
| `HM-RC-Dis-H-x-EU` | Funk-Fernbedienung mit Display | BidCos-RF |
| `HM-RC-Key3` | Funk-Handsender für KeyMatic | BidCos-RF |
| `HM-RC-Key3-B` | Funk-Handsender für KeyMatic | BidCos-RF |
| `HM-RC-Key4-2` | Funk-Handsender 4 Tasten für KeyMatic | BidCos-RF |
| `HM-RC-Key4-3` | Funk-Handsender 4 Tasten | BidCos-RF |
| `HM-RC-P1` | Funk-Panikhandsender | BidCos-RF |
| `HM-RC-Sec3` | Funk-Handsender für Alarmzentrale | BidCos-RF |
| `HM-RC-Sec3-B` | Funk-Handsender für Alarmzentrale | BidCos-RF |
| `HM-RC-Sec4-2` | Funk-Handsender 4 Tasten für Alarmzentrale | BidCos-RF |
| `HM-RC-Sec4-3` | Funk-Handsender 4 Tasten | BidCos-RF |
| `HM-SCI-3-FM` | Funk-Schließerkontaktschnittstelle 3-fach, Unterputzmontage | BidCos-RF |
| `HM-Sec-Key` | KeyMatic | BidCos-RF |
| `HM-Sec-Key-O` | KeyMatic | BidCos-RF |
| `HM-Sec-Key-S` | KeyMatic | BidCos-RF |
| `HM-Sec-MDIR` | Funk-Bewegungsmelder innen | BidCos-RF |
| `HM-Sec-MDIR-2` | Funk-Bewegungsmelder innen | BidCos-RF |
| `HM-Sec-MDIR-3` | Funk-Bewegungsmelder innen | BidCos-RF |
| `HM-Sec-RHS` | Funk-Fenster-/ Drehgriffkontakt | BidCos-RF |
| `HM-Sec-RHS-2` | Funk-Fenster-/ Drehgriffkontakt | BidCos-RF |
| `HM-Sec-SC` | Funk-Tür-/ Fensterkontakt | BidCos-RF |
| `HM-Sec-SC-2` | Funk-Tür-/ Fensterkontakt | BidCos-RF |
| `HM-Sec-SCo` | Funk-Tür-/Fensterkontakt optisch | BidCos-RF |
| `HM-Sec-SD` | Funk-Rauchmelder | BidCos-RF |
| `HM-Sec-SD-2` | Funk-Rauchmelder | BidCos-RF |
| `HM-Sec-SFA-SM` | Funk-Sirenen-/Blitzansteuerung | BidCos-RF |
| `HM-Sec-Sir-WM` | Funk-Innensirene | BidCos-RF |
| `HM-Sec-TiS` | Funk-Neigungssensor | BidCos-RF |
| `HM-Sec-WDS` | Funk-Wassermelder | BidCos-RF |
| `HM-Sec-WDS-2` | Funk-Wassermelder | BidCos-RF |
| `HM-Sec-Win` | WinMatic | BidCos-RF |
| `HM-Sen-DB-PCB` | Funk-Klingelsignalsensor | BidCos-RF |
| `HM-Sen-EP` | Funk-Sensor für elektrische Impulse | BidCos-RF |
| `HM-Sen-LI-O` | Funk-Helligkeitsensor für Außenmontage | BidCos-RF |
| `HM-Sen-MDIR-O` | Funk-Bewegungsmelder außen | BidCos-RF |
| `HM-Sen-MDIR-O-2` | Funk-Bewegungsmelder außen | BidCos-RF |
| `HM-Sen-MDIR-O-3` | Funk-Bewegungsmelder außen | BidCos-RF |
| `HM-Sen-MDIR-SM` | Funk-Bewegungsmelder | BidCos-RF |
| `HM-Sen-MDIR-WM55` | Funk-Bewegungsmelder mit Tastenpaar | BidCos-RF |
| `HM-Sen-RD-O` | Regensensor | BidCos-RF |
| `HM-Sen-Wa-Od` | Kapazitiver Füllstandsmesser | BidCos-RF |
| `HM-SwI-3-FM` | Funk-Schalterschnittstelle 3-fach, Unterputzmontage | BidCos-RF |
| `HM-Sys-sRP-Pl` | Funk-Zwischenstecker Repeater | BidCos-RF |
| `HM-TC-IT-WM-W-EU` | Funk-Wandthermostat | BidCos-RF |
| `HM-WDC7000` | Funk-Wetterstation WDC 7000 | BidCos-RF |
| `HM-WDS10-TH-O` | Funk-Temperatur-/ Feuchtesensor außen | BidCos-RF |
| `HM-WDS100-C6-O` | Funk-Kombisensor (OC3) | BidCos-RF |
| `HM-WDS100-C6-O-2` | Funk-Kombisensor (OC3) | BidCos-RF |
| `HM-WDS30-OT2-SM` | Funk-Temperaturdifferenz-Sensor | BidCos-RF |
| `HM-WDS30-OT2-SM-2` | Funk-Temperaturdifferenz-Sensor | BidCos-RF |
| `HM-WDS30-T-O` | Funk-Temperatursensor außen | BidCos-RF |
| `HM-WDS40-TH-I` | Funk-Temperatursensor innen | BidCos-RF |
| `HM-WDS40-TH-I-2` | Funk-Temperatursensor innen | BidCos-RF |
| `KS550` | Funk-Kombisensor 550 | BidCos-RF |
| `OLIGO.smart.iq.HM` | Funk-Dimmaktor | BidCos-RF |
| `WS550` | Funk-Wetterstation | BidCos-RF |
| `WS888` | Funk-Wetterstation | BidCos-RF |
| `ZEL STG RM DWT 10` | Funk-Display-Wandtaster 2-fach, Aufputzmontage (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FDK` | Funk-Fenster-/ Drehgriffkontakt (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FEP 230V` | Funk-Rollladenaktor 1-fach, Unterputzmontage (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FFK` | Funk-Tür-/ Fensterkontakt (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FSA` | Funk-Stellantrieb (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FSS UP3` | Funk-Schalterschnittstelle 3-fach, Unterputzmontage (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FST UP4` | Funk-Tasterschnittstelle 4-fach, Unterputzmontage (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FWT` | Funk-Wandthermostat (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FZS` | Funk-Schaltaktor 1-fach, Zwischenstecker (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FZS-2` | Funk-Schaltaktor 1-fach, Zwischenstecker (OEM: Roto) | BidCos-RF |
| `ZEL STG RM HS 4` | Funk-Handsender 4 Tasten (OEM: Roto) | BidCos-RF |
| `ZEL STG RM WT 2` | Funk-Wandtaster 2-fach im 55er Rahmen (OEM: Roto) | BidCos-RF |

## Homematic Wired (BidCos-Wired, RS485)

| Typ | Beschreibung | Protokoll |
| --- | --- | --- |
| `HMW-IO-12-FM` | Wired RS485 I/O-Modul 12 Eingänge, Unterputzmontage | BidCos-Wired |
| `HMW-IO-12-Sw14-DR` | Wired RS485 I/O-Modul 12 Eingänge, 14 Ausgänge, Hutschienenmontage | BidCos-Wired |
| `HMW-IO-12-Sw7-DR` | Wired RS485 I/O-Modul 12 Eingänge, 7 Ausgänge, Hutschienenmontage | BidCos-Wired |
| `HMW-IO-4-FM` | Wired RS485 I/O-Modul 4 Eingänge, Unterputzmontage | BidCos-Wired |
| `HMW-LC-Bl1-DR` | Wired RS485 Rollladenaktor 1-fach, Hutschienenmontage | BidCos-Wired |
| `HMW-LC-Bl1-DR-2` | Wired RS485 Rollladenaktor 1-fach, Hutschienenmontage | BidCos-Wired |
| `HMW-LC-Dim1L-DR` | Wired RS485 Dimmaktor 1-fach, Phasenanschnitt, Hutschienenmontage | BidCos-Wired |
| `HMW-LC-Sw2-DR` | Wired RS485 Schaltaktor 2-fach, Hutschienenmontage | BidCos-Wired |
| `HMW-Sen-SC-12-DR` | Wired RS485 Schließerkontakt, Hutschienenmontage | BidCos-Wired |
| `HMW-Sen-SC-12-FM` | Wired RS485 Schließerkontakt 12 Eingänge, Unterputzmontage | BidCos-Wired |

## Eingeschränkte Unterstützung (ohne WebUI-Integration)

Diese Gerätetypen sind in den Schnittstellenprozessen hinterlegt, haben aber keinen Eintrag in der WebUI-Gerätedatenbank. Vor dem Kauf sollte geprüft werden, ob der benötigte Funktionsumfang in der WebUI verfügbar ist.

| Typ | Beschreibung | Protokoll |
| --- | --- | --- |
| `ASH550` | Funk-Temperatur-/Feuchtesensor außen | BidCos-RF |
| `ASH550I` | Funk-Temperatur-/Feuchtesensor innen | BidCos-RF |
| `CMM` | Funk-Energiemanagement-Modul | BidCos-RF |
| `ELV-SH-IAS` | ELV Smart Home Schnittstelle für analoge Sensoren (0-10 V bzw. 4-20 mA) | HmIP-RF |
| `HM-CC-RT-DN-BoM` | Funk-Heizkörperthermostat | BidCos-RF |
| `HM-LC-Dim2L-CV` | Funk-Dimmaktor 2-fach, Phasenanschnitt, Zwischendeckenmontage | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R2` | Funk-Schaltaktor 1-fach mit Klemmanschluss | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R3` | Funk-Schaltaktor 1-fach mit Klemmanschluss | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R4` | Funk-Schaltaktor 1-fach mit Klemmanschluss | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R5` | Funk-Schaltaktor 1-fach mit Klemmanschluss | BidCos-RF |
| `HM-LC-Sw2-SM` | Funk-Schaltaktor 2-fach, Aufputzmontage | BidCos-RF |
| `HM-RC-12-SW` | Funk-Fernbedienung 12 Tasten, softtouch weiß | BidCos-RF |
| `HM-WDS20-TH-O` | Funk-Temperatur-/Feuchtesensor außen | BidCos-RF |
| `HmIP-E27` | Homematic IP Leuchtmittel - RGBWW | HmIP-RF |
| `HmIP-ESI-Linky` | Homematic IP Schnittstelle für Linky-Stromzähler | HmIP-RF |
| `HmIP-GU10` | Homematic IP Leuchtmittel - RGBWW | HmIP-RF |
| `HmIP-HDM1` | Modul für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM2` | Modul für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM3` | Modul für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM4` | Modul für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM5` | Modul für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM6` | Modul für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM7` | Modul für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM8` | Modul für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM9` | Modul für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDRC` | Fernbedienung für Hunter-Douglas-Antriebe (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-PR` | Homematic IP Zwischenstecker Router (Repeater) | HmIP-RF |
| `HmIP-PR-CH` | Homematic IP Zwischenstecker Router (Repeater) | HmIP-RF |
| `HmIP-PR-PE` | Homematic IP Zwischenstecker Router (Repeater) | HmIP-RF |
| `HmIP-PR-UK` | Homematic IP Zwischenstecker Router (Repeater) | HmIP-RF |
| `HmIP-PS-CH` | Homematic IP Zwischenstecker Schalten | HmIP-RF |
| `HmIP-PS-PE` | Homematic IP Zwischenstecker Schalten | HmIP-RF |
| `HmIP-PS-UK` | Homematic IP Zwischenstecker Schalten | HmIP-RF |
| `HmIP-SWSD-3` | Homematic IP Rauchwarnmelder | HmIP-RF |
| `HmIP-WLAN-HAP` | Homematic IP WLAN Access Point | HmIP-RF |
| `HmIP-WLAN-HAP-B` | Homematic IP WLAN Access Point - basic | HmIP-RF |
| `HmIPW-AV` | Homematic IP Wired Volumenstromregler | HmIP-Wired |
| `HmIPW-AV-CO2` | Homematic IP Wired Volumenstromregler mit CO2-Sensor | HmIP-Wired |
| `HmIPW-AV-RH` | Homematic IP Wired Volumenstromregler mit Feuchtesensor | HmIP-Wired |
| `HmIPW-AV-S` | Homematic IP Wired Volumenstromsensor | HmIP-Wired |
| `HmIPW-AV-SVN` | Homematic IP Wired Volumenstromsensor mit VOC-Sensor | HmIP-Wired |
| `HmIPW-DRAVC` | Homematic IP Wired Lüftungsregler (DCV) | HmIP-Wired |
| `HMW-IO-SR-FM` | Wired RS485 I/O-Modul für Rollladen, Unterputzmontage | BidCos-Wired |
| `IS-WDS-TH-OD-S-R3` | Funk-Temperatur-/Feuchtesensor außen | BidCos-RF |
| `KS550LC` | Funk-Kombisensor | BidCos-RF |
| `KS550Tech` | Funk-Kombisensor | BidCos-RF |
| `KS888` | Funk-Kombisensor | BidCos-RF |
| `KW-BLR2CH` | Schaltaktor für Heizungssysteme - 2-fach (OEM: Warmup) | HmIP-RF |
| `KW-STATH` | Wandthermostat (OEM: Warmup) | HmIP-RF |
| `KW-UKETRV` | Heizkörperthermostat - basic (OEM: Warmup) | HmIP-RF |
| `KW-UKETRV-2` | Heizkörperthermostat - basic (OEM: Warmup) | HmIP-RF |
| `KW-UKHUB` | Access Point (OEM: Warmup) | HmIP-RF |
| `KW-WC10CH` | Fußbodenheizungsaktor - 10-fach (OEM: Warmup) | HmIP-RF |
| `RC-H` | Funk-Handsender DORMA, 4 Tasten (OEM: DORMA) | BidCos-RF |
| `S550IA` | Funk-Temperatursensor | BidCos-RF |
| `ST6-SH` | Bewässerungscomputer SensoTimer ST 6 Smart Home | BidCos-RF |
| `WDF solar` | Roto Wohndachfenster solar (OEM: Roto) | BidCos-RF |
| `WS550LCB` | Funk-Wetterstation | BidCos-RF |
| `WS550LCW` | Funk-Wetterstation | BidCos-RF |
| `WS550Tech` | Funk-Wetterstation | BidCos-RF |

## Nicht unterstützt (nur WebUI-Eintrag vorhanden)

Diese Gerätetypen sind zwar in der WebUI-Gerätedatenbank vorhanden, aber keinem Schnittstellenprozess als Gerätetyp bekannt und gelten daher nicht als unterstützt (z.B. abgekündigte Altgeräte oder neue Geräte, deren Unterstützung im HMIPServer noch fehlt). Sie sollten nicht für eine Neuanschaffung eingeplant werden.

| Typ | Beschreibung | Protokoll |
| --- | --- | --- |
| `ELV-SH-FS` | ELV-SH-FS | HmIP-RF |
| `ELV-SH-FSI` | ELV-SH-FSI | HmIP-RF |
| `ELV-SH-KRCO` | ELV Smart Home Taster Kompakt - Outdoor | HmIP-RF |
| `HM-EM-CCM` | Zählersensor Kamera Modul | BidCos-RF |
| `HM-EM-CMM` | Zählersensor Management Modul | BidCos-RF |
| `HM-LC-Dim1L-CV-644` | Funk-Dimmaktor 1-fach, Phasenanschnitt, Zwischendeckenmontage | BidCos-RF |
| `HM-LC-Dim1L-Pl-644` | Funk-Zwischenstecker-Dimmaktor 1-fach, Phasenanschnitt | BidCos-RF |
| `HM-LC-Dim1T-CV-644` | Funk-Dimmaktor 1-fach, Phasenabschnitt, Zwischendeckenmontage | BidCos-RF |
| `HM-LC-Dim1T-FM-644` | Funk-Dimmaktor 1-fach, Phasenabschnitt, Unterputzmontage | BidCos-RF |
| `HM-LC-Dim1T-Pl-644` | Funk-Dimmaktor 1-fach, Zwischenstecker, Phasenabschnitt | BidCos-RF |
| `HM-LC-Dim2L-SM-644` | Funk-Dimmaktor 2-fach, Phasenanschnitt, Aufputzmontage | BidCos-RF |
| `HM-LC-Dim2T-SM-644` | Funk-Dimmaktor 2-fach, Phasenabschnitt, Aufputzmontage | BidCos-RF |
| `HM-WS550-US` | Funk-Wetterstation USA | BidCos-RF |
| `HM-WS550ST-IO` | Funk-Temperatursensor außen | BidCos-RF |
| `HM-WS550STH-I` | Funk-Temperatursensor innen | BidCos-RF |
| `HM-WS550STH-O` | Funk-Temperatur-/ Feuchtesensor außen | BidCos-RF |
| `HmIP-eTRV-B-UK-2` | Homematic IP Heizkörperthermostat - basic UK | HmIP-RF |
| `HMW-Sec-TR-FM` | Wired RS485 Transponderleser Unterputzmontage | BidCos-Wired |
| `HMW-Sys-PS7-DR` | Wired RS485-Netzteil 7 VA, Hutschienenmontage | BidCos-Wired |
| `HMW-WSE-SM` | Wired RS485 Lichtsensor Aufputzmontage | BidCos-Wired |
| `HMW-WSTH-SM` | Wired RS485 Temperatur-/ Feuchte- Sensor | BidCos-Wired |
