# Homematic and Homematic IP devices supported by OpenCCU

[Deutsche Version](supported-devices.de.md)

This list contains all Homematic (BidCos-RF, BidCos-Wired) and Homematic IP (HmIP-RF, HmIP-Wired) device types supported by the current OpenCCU. Use it to check whether a device can be used with OpenCCU before buying it.

The list is generated automatically from the OpenCCU-Base sources. A device type counts as supported if the responsible interface process knows it:

- `BidCos-RF`: `rfd` device descriptions (`src/devicetypes/rftypes/*.xml`)
- `BidCos-Wired`: `hs485d` device descriptions (`src/devicetypes/hs485types/*.xml`)
- `HmIP-RF`/`HmIP-Wired`: device specifications in `HMIPServer.jar` (`opt/HMServer/HMIPServer.jar`)
- Descriptions: WebUI device database (`DEVDB.tcl`) and WebUI translations

**Data basis:** OpenCCU-Base commit `ea614511caa2`, HMIPServer.jar version `1.5.1-SNAPSHOT 2026-06-30T07:34:55Z`, generated on 2026-10-04.  
**Regenerate with:** `scripts/generate-supported-devices.py --base <OpenCCU-Base>`

## Notes

- Homematic IP requires an HmIP capable radio module (e.g. RPI-RF-MOD, HM-MOD-RPI-PCB, HmIP-RFUSB), Homematic IP Wired additionally requires a Homematic IP Wired Access Point (HmIPW-DRAP) and Homematic Wired (BidCos-Wired/RS485) requires a Homematic Wired LAN Gateway (HMW-LGW-O-DR-GS-EU).
- For some device types the available functions depend on the device firmware. OpenCCU can install device firmware updates for many devices directly.
- Type names with a country suffix (`-UK`, `-CH`, `-PE`, `-IT`) and variants (`-A` = anthracite, `-2`/`-3` = newer hardware revision) are listed separately.
- Devices in the section "Limited support" are known to the interface process but have no dedicated WebUI integration (no device image, no device description). They can be paired, but their handling in the WebUI may be limited.

## Summary

| Protocol | Device types |
| --- | ---: |
| [Homematic IP (HmIP-RF)](#homematic-ip-hmip-rf) | 229 |
| [Homematic IP Wired (HmIP-Wired)](#homematic-ip-wired-hmip-wired) | 38 |
| [Homematic (BidCos-RF)](#homematic-bidcos-rf) | 203 |
| [Homematic Wired (BidCos-Wired, RS485)](#homematic-wired-bidcos-wired-rs485) | 10 |
| [Limited support (no WebUI integration)](#limited-support-no-webui-integration) | 60 |
| **Total** | **540** |

## Homematic IP (HmIP-RF)

| Type | Description | Protocol |
| --- | --- | --- |
| `ALPHA-IP-RBG` | Room Control Unit Display (OEM: Möhlenhoff) | HmIP-RF |
| `ALPHA-IP-RBGa` | Room Control Unit Analogue (OEM: Möhlenhoff) | HmIP-RF |
| `ELV-SH-BM-S` | ELV Smart Home Sensor-Base | HmIP-RF |
| `ELV-SH-BS2` | Homematic IP Remote Control for brand switches - 2 channels | HmIP-RF |
| `ELV-SH-CAP` | ELV Smart Home Air Pressure Sensor Compact | HmIP-RF |
| `ELV-SH-CRC` | ELV smart home remote control compact | HmIP-RF |
| `ELV-SH-CTH` | ELV Smart Home Temperature and Humidity Sensor Compact | HmIP-RF |
| `ELV-SH-CTV` | ELV Smart Home Tilt and Vibration Sensor Compact | HmIP-RF |
| `ELV-SH-CWD` | Watersensor compact | HmIP-RF |
| `ELV-SH-DUSI` | Ultrasonic distance sensor interface | HmIP-RF |
| `ELV-SH-KRC` | ELV smart home key ring remote control | HmIP-RF |
| `ELV-SH-PSMCI` | Homematic IP Switch and Meter | HmIP-RF |
| `ELV-SH-PTI2` | ELV Smart Home Temperature Sensor with external probes - 2 channels | HmIP-RF |
| `ELV-SH-SB8` | ELV Smart Home Status Board | HmIP-RF |
| `ELV-SH-SMS2` | ELV Smart Home Surface mounted switch 2 channels | HmIP-RF |
| `ELV-SH-SMSI` | ELV Smart Home Soil moisture sensor | HmIP-RF |
| `ELV-SH-SPS25` | ELV smart home Switched power supply | HmIP-RF |
| `ELV-SH-SW1-BAT` | Homematic IP Switch Circuit for battery operation | HmIP-RF |
| `ELV-SH-TACO` | ELV Smart Home Temperature and Acceleration Sensor Outdoor | HmIP-RF |
| `ELV-SH-WSC` | Homematic IP Servo Control | HmIP-RF |
| `ELV-SH-WSM` | ELV Smart Home Watering Actuator | HmIP-RF |
| `ELV-SH-WUA` | Homematic IP Universal Actuator - 0-10 V | HmIP-RF |
| `HmIP-ASIR` | Homematic IP Alarm Siren | HmIP-RF |
| `HmIP-ASIR-2` | Homematic IP Alarm Siren | HmIP-RF |
| `HmIP-ASIR-B1` | Homematic IP Alarm Siren (OEM: Targa) | HmIP-RF |
| `HmIP-ASIR-O` | Homematic IP Alarm Siren - outdoor | HmIP-RF |
| `HmIP-BBL` | Homematic IP Blinds Actuator for brand switches | HmIP-RF |
| `HmIP-BBL-2` | Homematic IP Blinds Actuator for brand switches | HmIP-RF |
| `HmIP-BBL-I` | Homematic IP Blinds Actuator for brand switches | HmIP-RF |
| `HmIP-BDT` | Homematic IP Dimming Actuator for brand switch systems, flush-mount | HmIP-RF |
| `HmIP-BDT-I` | Homematic IP Dimming Actuator for brand switch systems, flush-mount | HmIP-RF |
| `HmIP-BRC2` | Homematic IP Remote Control for brand switches - 2 channels | HmIP-RF |
| `HmIP-BRC2-2` | Homematic IP Remote Control for brand switches - 2 channels | HmIP-RF |
| `HmIP-BROLL` | Homematic IP Blind Actuator for brand switch systems, flush-mount | HmIP-RF |
| `HmIP-BROLL-2` | Homematic IP Blind Actuator for brand switch systems, flush-mount | HmIP-RF |
| `HmIP-BS2` | Homematic IP Remote Control for brand switches - 2 channels | HmIP-RF |
| `HmIP-BSL` | Homematic IP Switch Actuator with Signal Lamp - for brand switches | HmIP-RF |
| `HmIP-BSM` | Homematic IP Switch Actuator with power measurement | HmIP-RF |
| `HmIP-BSM-I` | Homematic IP Switch Actuator with power measurement | HmIP-RF |
| `HmIP-BWTH` | Homematic IP Wall Thermostat | HmIP-RF |
| `HmIP-BWTH-A` | Homematic IP Wall Thermostat | HmIP-RF |
| `HmIP-BWTH24` | Homematic IP Wall Thermostat | HmIP-RF |
| `HmIP-DBB` | Homematic IP Doorbell Button | HmIP-RF |
| `HmIP-DLD` | Homematic IP Door Lock Drive | HmIP-RF |
| `HmIP-DLD-A` | Homematic IP Door Lock Drive | HmIP-RF |
| `HmIP-DLD-S` | Homematic IP Door Lock Drive | HmIP-RF |
| `HmIP-DLP` | Door Lock Drive – Pro | HmIP-RF |
| `HmIP-DLP-A` | Door Lock Drive – Pro | HmIP-RF |
| `HmIP-DLP-AS` | Door Lock Drive – Pro | HmIP-RF |
| `HmIP-DLP-WS` | Door Lock Drive – Pro | HmIP-RF |
| `HmIP-DLS` | Homematic IP Door Lock Sensor | HmIP-RF |
| `HmIP-DRBLI4` | Homematic IP Blind and Shutter Actuator for DIN rail mount - 4 channels | HmIP-RF |
| `HmIP-DRDI3` | Homematic IP Dimming Actuator for DIN rail mount - 3 channels | HmIP-RF |
| `HmIP-DRG-DALI` | Homematic IP DALI Gateway | HmIP-RF |
| `HmIP-DRSI1` | Homematic IP Switch Actuator for DIN rail mount - 1 channel | HmIP-RF |
| `HmIP-DRSI4` | Homematic IP Switch Actuator for DIN rail mount - 4 channels | HmIP-RF |
| `HmIP-DSD-PCB` | Homematic IP Doorbell Sensor | HmIP-RF |
| `HmIP-ESI` | Homematic IP Energy Sensor Interface | HmIP-RF |
| `HmIP-ESI-IND` | Homematic IP Energy Sensor Interface | HmIP-RF |
| `HmIP-eTRV` | Homematic IP Radiator Thermostat | HmIP-RF |
| `HmIP-eTRV-2` | Homematic IP Radiator Thermostat (also as `HmIP-eTRV-2 I9F`) | HmIP-RF |
| `HmIP-eTRV-2-UK` | Homematic IP Radiator Thermostat UK | HmIP-RF |
| `HmIP-eTRV-3` | Homematic IP Radiator Thermostat | HmIP-RF |
| `HmIP-eTRV-B` | Homematic IP Radiator Thermostat - basic | HmIP-RF |
| `HmIP-eTRV-B-2` | Homematic IP Radiator Thermostat - basic (also as `HmIP-eTRV-B-2 R4M`) | HmIP-RF |
| `HmIP-eTRV-B-UK` | Homematic IP Radiator Thermostat - basic UK | HmIP-RF |
| `HmIP-eTRV-B1` | Homematic IP Radiator Thermostat - basic (OEM: Targa) | HmIP-RF |
| `HmIP-eTRV-C` | Homematic IP Radiator Thermostat - compact | HmIP-RF |
| `HmIP-eTRV-C-2` | Homematic IP Radiator Thermostat - compact | HmIP-RF |
| `HmIP-eTRV-CL` | Homematic IP Radiator Thermostat - compact plus | HmIP-RF |
| `HmIP-eTRV-E` | Homematic IP Radiator Thermostat - Evo | HmIP-RF |
| `HmIP-eTRV-E-A` | Homematic IP Radiator Thermostat - Evo | HmIP-RF |
| `HmIP-eTRV-E-S` | Homematic IP Radiator Thermostat - Evo | HmIP-RF |
| `HmIP-eTRV-F` | Homematic IP Radiator Thermostat | HmIP-RF |
| `HmIP-eTRV-F-A` | Homematic IP Radiator Thermostat | HmIP-RF |
| `HmIP-FAL230-C10` | Homematic IP Floor Heating Actuator - 10 channels 230 V | HmIP-RF |
| `HmIP-FAL230-C6` | Homematic IP Floor Heating Actuator - 6 channels 230 V | HmIP-RF |
| `HmIP-FAL24-C10` | Homematic IP Floor Heating Actuator - 10 channels 24 V | HmIP-RF |
| `HmIP-FAL24-C6` | Homematic IP Floor Heating Actuator - 6 channels 24 V | HmIP-RF |
| `HmIP-FALMOT-C12` | Homematic IP Floor Heating Actuator - 12 channels, motorised | HmIP-RF |
| `HmIP-FALMOT-C8` | Homematic IP Floor Heating Actuator - 8 channels, motorised | HmIP-RF |
| `HmIP-FBL` | Homematic IP Blinds Actuator - flush-mount | HmIP-RF |
| `HmIP-FCI1` | Homematic IP Contact Interface flush-mount - 1 channel | HmIP-RF |
| `HmIP-FCI6` | Homematic IP Contact Interface flush-mount - 6 channels | HmIP-RF |
| `HmIP-FDC` | Homematic IP Universal Lock Controller | HmIP-RF |
| `HmIP-FDT` | Homematic IP Dimming Actuator, flush-mount | HmIP-RF |
| `HmIP-FLC` | Homematic IP Universal Lock Controller | HmIP-RF |
| `HmIP-FROLL` | Homematic IP Blind Actuator, flush-mount | HmIP-RF |
| `HmIP-FS6` | Switch Actuator – flush-mount | HmIP-RF |
| `HmIP-FSI16` | Homematic IP Switch Actuator with Push-button Input (16 A) - flush-mount | HmIP-RF |
| `HmIP-FSI16-2` | Homematic IP Switch Actuator with Push-button Input (16 A) - flush-mount | HmIP-RF |
| `HmIP-FSI6` | Homematic IP switch actuator with push-button input - flush-mount | HmIP-RF |
| `HmIP-FSM` | Homematic IP Switch Actuator with power measurement, flush-mount | HmIP-RF |
| `HmIP-FSM16` | Homematic IP Switch Actuator with power measurement, flush-mount | HmIP-RF |
| `HmIP-FWI` | Homematic IP Wiegand Interface | HmIP-RF |
| `HmIP-HAP` | Homematic IP Access Point (usable as LAN router) (also as `HmIP-HAP JS1`) | HmIP-RF |
| `HmIP-HAP-A` | Homematic IP Access Point (usable as LAN router) | HmIP-RF |
| `HmIP-HAP-B1` | Homematic IP Access Point (usable as LAN router) (OEM: Targa) | HmIP-RF |
| `HmIP-HAP2` | Homematic IP Access Point (usable as LAN router) | HmIP-RF |
| `HmIP-HAP2-A` | Homematic IP Access Point (usable as LAN router) | HmIP-RF |
| `HmIP-KRC4` | Homematic IP Key Ring Remote Control - 4 buttons | HmIP-RF |
| `HmIP-KRC4-2` | Homematic IP Key Ring Remote Control - 4 buttons | HmIP-RF |
| `HmIP-KRCA` | Homematic IP Key Ring Remote Control - alarm | HmIP-RF |
| `HmIP-KRCA-2` | Homematic IP Key Ring Remote Control - alarm | HmIP-RF |
| `HmIP-KRCK` | Homematic IP Key Ring Remote Control - access control | HmIP-RF |
| `HmIP-KRCK-2` | Homematic IP Key Ring Remote Control - access control | HmIP-RF |
| `HmIP-LSC` | Homematic IP Light Strip Controller | HmIP-RF |
| `HmIP-M-TD15` | Homematic IP Tubular Drive - 15 Nm | HmIP-RF |
| `HmIP-MIO16-PCB` | Homematic IP Multi IO Module Board - 4x4 | HmIP-RF |
| `HmIP-MIOB` | Homematic IP Multi I/O-Box | HmIP-RF |
| `HmIP-MOD-HO` | Homematic IP Module for Hoermann drives | HmIP-RF |
| `HmIP-MOD-OC8` | Homematic IP Switch Actuator with OC-Output | HmIP-RF |
| `HmIP-MOD-RC8` | Homematic IP Module Board Transmitter - 8 channels | HmIP-RF |
| `HmIP-MOD-TM` | Homematic IP Tormatic Module (OEM: Novoferm) | HmIP-RF |
| `HmIP-MOD-WD-VK` | Homematic IP Module for VEKA window drives (OEM: VEKA) | HmIP-RF |
| `HmIP-MP3P` | Homematic IP Combination Signalling Device MP3 | HmIP-RF |
| `HmIP-PCBS` | Homematic IP Switch Circuit Board | HmIP-RF |
| `HmIP-PCBS-BAT` | Homematic IP Switch Circuit for battery operation | HmIP-RF |
| `HmIP-PCBS2` | Homematic IP Switch Circuit Board - 2 channels | HmIP-RF |
| `HmIP-PDT` | Homematic IP Dimming Actuator | HmIP-RF |
| `HmIP-PDT-A` | Homematic IP Dimming Actuator | HmIP-RF |
| `HmIP-PDT-CH` | Homematic IP Dimming Actuator (CH) | HmIP-RF |
| `HmIP-PDT-PE` | Homematic IP Dimming Actuator (Pin Earth) | HmIP-RF |
| `HmIP-PDT-UK` | Homematic IP Dimming Actuator | HmIP-RF |
| `HmIP-PMFS` | Homematic IP Mains Failure Surveillance | HmIP-RF |
| `HmIP-PS` | Homematic IP Pluggable Switch | HmIP-RF |
| `HmIP-PS-2` | Homematic IP Pluggable Switch (also as `HmIP-PS-2 9YM`) | HmIP-RF |
| `HmIP-PS-A` | Homematic IP Pluggable Switch | HmIP-RF |
| `HmIP-PSM` | Homematic IP Pluggable Switch and Meter | HmIP-RF |
| `HmIP-PSM-2` | Homematic IP Pluggable Switch and Meter (also as `HmIP-PSM-2 QHJ`) | HmIP-RF |
| `HmIP-PSM-A` | Homematic IP Pluggable Switch and Meter | HmIP-RF |
| `HmIP-PSM-CH` | Homematic IP Pluggable Switch and Meter (CH) | HmIP-RF |
| `HmIP-PSM-CH-2` | Homematic IP Pluggable Switch and Meter (CH) | HmIP-RF |
| `HmIP-PSM-IT` | Homematic IP Pluggable Switch and Meter (IT) | HmIP-RF |
| `HmIP-PSM-PE` | Homematic IP Pluggable Switch and Meter (Pin Earth) | HmIP-RF |
| `HmIP-PSM-PE-2` | Homematic IP Pluggable Switch and Meter (Pin Earth) | HmIP-RF |
| `HmIP-PSM-UK` | Homematic IP Pluggable Switch and Meter (UK) | HmIP-RF |
| `HmIP-PSMCO` | Homematic IP Switch and Meter | HmIP-RF |
| `HmIP-RC8` | Homematic IP Remote Contro, 8-channel | HmIP-RF |
| `HmIP-RCB1` | Remote Control with mounting belt – 1 channel | HmIP-RF |
| `HmIP-RGBW` | Homematic IP LED Controller - RGBW | HmIP-RF |
| `HmIP-SAM` | Homematic IP Acceleration Sensor | HmIP-RF |
| `HmIP-SCI` | Homematic IP Contact Interface | HmIP-RF |
| `HmIP-SCTH230` | Homematic IP CO2 Sensor, 230 V | HmIP-RF |
| `HmIP-SFD` | Homematic IP Particulate Matter Sensor | HmIP-RF |
| `HmIP-SLO` | Homematic IP Light Sensor - outdoor | HmIP-RF |
| `HmIP-SMI` | Homematic IP Motion Detector - indoor | HmIP-RF |
| `HmIP-SMI55` | Homematic IP Motion Detector for 55mm frames - indoor | HmIP-RF |
| `HmIP-SMI55-2` | Homematic IP Motion Detector for 55mm frames - indoor | HmIP-RF |
| `HmIP-SMI55-A` | Homematic IP Motion Detector for 55mm frames - indoor | HmIP-RF |
| `HmIP-SMO` | Homematic IP Motion Detector, outdoor | HmIP-RF |
| `HmIP-SMO-2` | Homematic IP Motion Detector, outdoor | HmIP-RF |
| `HmIP-SMO-A` | Homematic IP Motion Detector, outdoor | HmIP-RF |
| `HmIP-SMO-A-2` | Homematic IP Motion Detector, outdoor | HmIP-RF |
| `HmIP-SMO230` | Homematic IP Motion Detector, outdoor | HmIP-RF |
| `HmIP-SMO230-A` | Homematic IP Motion Detector, outdoor | HmIP-RF |
| `HmIP-SPDR` | Homematic IP Passage Sensor with Direction Recognition | HmIP-RF |
| `HmIP-SPI` | Homematic IP Presence sensor - indoor | HmIP-RF |
| `HmIP-SRD` | Homematic IP Rain Sensor | HmIP-RF |
| `HmIP-SRH` | Homematic IP Rotary Handle Sensor | HmIP-RF |
| `HmIP-STE2-PCB` | Homematic IP Temperature Sensor with external probes - 2 channels | HmIP-RF |
| `HmIP-STH` | Homematic IP Temperature and Humidity Sensor - indoor (also as `HmIP-STH 8DU`) | HmIP-RF |
| `HmIP-STH-A` | Homematic IP Temperature and Humidity Sensor - indoor (also as `HmIP-STH-A 8DU`) | HmIP-RF |
| `HmIP-STHD` | Homematic IP Temperature and Humidity Sensor with Display - indoor (also as `HmIP-STHD L9D`) | HmIP-RF |
| `HmIP-STHD-A` | Homematic IP Temperature and Humidity Sensor with Display - indoor (also as `HmIP-STHD-A L9D`) | HmIP-RF |
| `HmIP-STHO` | Homematic IP Temperature and Humidity Sensor - outdoor | HmIP-RF |
| `HmIP-STHO-A` | Homematic IP Temperature and Humidity Sensor - outdoor | HmIP-RF |
| `HmIP-STI` | Homematic IP Touch-Sensor | HmIP-RF |
| `HmIP-STV` | Homematic IP Tilt and Vibration Sensor | HmIP-RF |
| `HmIP-SWD` | Homematic IP Water Sensor | HmIP-RF |
| `HmIP-SWD-2` | Homematic IP Water Sensor | HmIP-RF |
| `HmIP-SWDM` | Homematic IP Window / Door Contact with magnet | HmIP-RF |
| `HmIP-SWDM-2` | Homematic IP Window / Door Contact with magnet | HmIP-RF |
| `HmIP-SWDM-B2` | Homematic IP Window / Door Contact with magnet (OEM: Targa) | HmIP-RF |
| `HmIP-SWDO` | Homematic IP Window / Door Contact - optical | HmIP-RF |
| `HmIP-SWDO-2` | Homematic IP Window / Door Contact - optical | HmIP-RF |
| `HmIP-SWDO-A` | Homematic IP Window / Door Contact - optical | HmIP-RF |
| `HmIP-SWDO-I` | Homematic IP Window / Door Contact - invisible installation | HmIP-RF |
| `HmIP-SWDO-PL` | Homematic IP Window / Door Contact - optical, plus | HmIP-RF |
| `HmIP-SWDO-PL-2` | Homematic IP Window / Door Contact - optical, plus | HmIP-RF |
| `HmIP-SWO-B` | Homematic IP Weather Sensor - basic | HmIP-RF |
| `HmIP-SWO-PL` | Homematic IP Weather Sensor - plus | HmIP-RF |
| `HmIP-SWO-PR` | Homematic IP Weather Sensor - pro | HmIP-RF |
| `HmIP-SWSD` | Homematic IP Smoke Detector | HmIP-RF |
| `HmIP-SWSD-2` | Homematic IP Smoke Detector | HmIP-RF |
| `HmIP-SWSD-2-NL` | Homematic IP Smoke Detector | HmIP-RF |
| `HmIP-UDI-PB2` | Homematic IP Universal Dimming Control Element - push-button | HmIP-RF |
| `HmIP-UDI-PB2-A` | Homematic IP Universal Dimming Control Element - push-button | HmIP-RF |
| `HmIP-UDI-SMI55` | Universal Dimming Control Element - Motion Detector | HmIP-RF |
| `HmIP-UDI-SMI55-A` | Universal Dimming Control Element - Motion Detector | HmIP-RF |
| `HmIP-USBSM` | Homematic IP Switch Actuator and Meter for USB | HmIP-RF |
| `HmIP-WGC` | Homematic IP Garage Door Controller | HmIP-RF |
| `HmIP-WGD` | Homematic IP Wireless Glass Display | HmIP-RF |
| `HmIP-WGD-PL` | Homematic IP Wireless Glass Display - plus | HmIP-RF |
| `HmIP-WGS` | Homematic IP Glass Switch | HmIP-RF |
| `HmIP-WGS-A` | Homematic IP Glass Switch | HmIP-RF |
| `HmIP-WGT` | Homematic IP Glas Thermostat - 230 V | HmIP-RF |
| `HmIP-WGT-A` | Homematic IP Glas Thermostat - 230 V | HmIP-RF |
| `HmIP-WGTC` | Homematic IP Glass Wall Thermostat with CO2 Sensor | HmIP-RF |
| `HmIP-WGTC-A` | Homematic IP Glass Wall Thermostat with CO2 Sensor | HmIP-RF |
| `HmIP-WHS2` | Homematic IP Switch Actuator for heating systems - 2 channels | HmIP-RF |
| `HmIP-WKP` | Homematic IP Keypad | HmIP-RF |
| `HmIP-WRC2` | Homematic IP Wall-mount Remote Control 2 buttons | HmIP-RF |
| `HmIP-WRC2-2` | Homematic IP Wall-mount Remote Control 2 buttons | HmIP-RF |
| `HmIP-WRC2-A` | Homematic IP Wall-mount Remote Control 2 buttons | HmIP-RF |
| `HmIP-WRC2-A-2` | Homematic IP Wall-mount Remote Control 2 buttons | HmIP-RF |
| `HmIP-WRC6` | Homematic IP Wall-mount Remote Control 6 buttons | HmIP-RF |
| `HmIP-WRC6-230` | Homematic IP Wall-mount Remote Control 6 buttons, 230V | HmIP-RF |
| `HmIP-WRC6-230-A` | Homematic IP Wall-mount Remote Control 6 buttons, 230V | HmIP-RF |
| `HmIP-WRC6-A` | Homematic IP Wall-mount Remote Control 6 buttons | HmIP-RF |
| `HmIP-WRCC2` | Homematic IP Wall-mount Remote Control - flat | HmIP-RF |
| `HmIP-WRCD` | Homematic IP Wall-mount Remote Control with status display | HmIP-RF |
| `HmIP-WRCR` | Homematic IP Rotary Button | HmIP-RF |
| `HmIP-WSC` | Homematic IP Servo Control | HmIP-RF |
| `HmIP-WSM` | Homematic IP Watering Actuator | HmIP-RF |
| `HmIP-WSS` | Water Stop and Supply Unit | HmIP-RF |
| `HmIP-WSS-GB` | Water Stop and Supply Unit | HmIP-RF |
| `HmIP-WT` | Homematic IP Wall Thermostat | HmIP-RF |
| `HmIP-WTH` | Homematic IP Wall Thermostat | HmIP-RF |
| `HmIP-WTH-1` | Homematic IP Wall Thermostat with Humidity Sensor | HmIP-RF |
| `HmIP-WTH-2` | Homematic IP Wall Thermostat with Humidity Sensor | HmIP-RF |
| `HmIP-WTH-3` | Homematic IP Wall Thermostat with Humidity Sensor | HmIP-RF |
| `HmIP-WTH-3-A` | Homematic IP Wall Thermostat with Humidity Sensor | HmIP-RF |
| `HmIP-WTH-A` | Homematic IP Wall Thermostat with Humidity Sensor | HmIP-RF |
| `HmIP-WTH-B` | Homematic IP Wall Thermostat - basic | HmIP-RF |
| `HmIP-WTH-B-2` | Homematic IP Wall Thermostat - basic | HmIP-RF |
| `HmIP-WTH-B-A` | Homematic IP Wall Thermostat - basic | HmIP-RF |
| `HmIP-WUA` | Homematic IP Universal Actuator - 0-10 V | HmIP-RF |
| `RM-110-45/15` | TEXINO Tubular Drive HmIP Octagonal Shaft 60mm/15Nm | HmIP-RF |

## Homematic IP Wired (HmIP-Wired)

| Type | Description | Protocol |
| --- | --- | --- |
| `HmIPW-BRC2` | Homematic IP Wired Remote Control for brand switches - 2 channels | HmIP-Wired |
| `HmIPW-DRAP` | Homematic IP Wired Access Point | HmIP-Wired |
| `HmIPW-DRBL4` | Homematic IP Wired Blind and Shutter Actuator - 4 channels | HmIP-Wired |
| `HmIPW-DRD3` | Homematic IP Wired Dimming Actuator - 3 channels | HmIP-Wired |
| `HmIPW-DRI16` | Homematic IP Wired Input Module - 16 channels | HmIP-Wired |
| `HmIPW-DRI32` | Homematic IP Wired Input Module - 32 channels | HmIP-Wired |
| `HmIPW-DRS4` | Homematic IP Wired Switch Actuator - 4 channels | HmIP-Wired |
| `HmIPW-DRS8` | Homematic IP Wired Switch Actuator - 8 channels | HmIP-Wired |
| `HmIPW-FAL230-C10` | Homematic IP Wired Floor Heating Actuator - 10 channels, 230 V | HmIP-Wired |
| `HmIPW-FAL230-C6` | Homematic IP Wired Floor Heating Actuator - 6 channels, 230 V | HmIP-Wired |
| `HmIPW-FAL24-C10` | Homematic IP Wired Floor Heating Actuator - 10 channels, 24 V | HmIP-Wired |
| `HmIPW-FAL24-C6` | Homematic IP Wired Floor Heating Actuator - 6 channels, 24 V | HmIP-Wired |
| `HmIPW-FALMOT-C12` | Homematic IP Floor Heating Actuator - 12 channels, motorised | HmIP-Wired |
| `HmIPW-FIO6` | Homematic IP Wired IO Module flush-mount - 6 channels | HmIP-Wired |
| `HmIPW-SCTHD` | Homematic IP Wired CO2-Sensor | HmIP-Wired |
| `HmIPW-SMI55` | Homematic IP Wired Motion Detector for 55mm frames - indoor | HmIP-Wired |
| `HmIPW-SMI55-A` | Homematic IP Wired Motion Detector for 55mm frames - indoor | HmIP-Wired |
| `HmIPW-SMO230` | Homematic IP Motion Detector, outdoor | HmIP-Wired |
| `HmIPW-SMO230-A` | Homematic IP Motion Detector, outdoor | HmIP-Wired |
| `HmIPW-SPI` | Homematic IP Wired Presence sensor - indoor | HmIP-Wired |
| `HmIPW-STH` | Homematic IP Wired Temperature and Humidity Sensor - indoor | HmIP-Wired |
| `HmIPW-STH-A` | Homematic IP Wired Temperature and Humidity Sensor - indoor | HmIP-Wired |
| `HmIPW-STHD` | Homematic IP Wired Temperature and Humidity Sensor with display - indoor | HmIP-Wired |
| `HmIPW-STHD-A` | Homematic IP Wired Temperature and Humidity Sensor with display - indoor | HmIP-Wired |
| `HmIPW-WGD` | Homematic IP Wired Glass Display | HmIP-Wired |
| `HmIPW-WGD-PL` | Homematic IP Wired Glass Display - plus | HmIP-Wired |
| `HmIPW-WGS` | Homematic IP Wired Glass Switch | HmIP-Wired |
| `HmIPW-WGS-A` | Homematic IP Wired Glass Switch | HmIP-Wired |
| `HmIPW-WGT` | Homematic IP Wired Glas Thermostat | HmIP-Wired |
| `HmIPW-WGT-A` | Homematic IP Wired Glas Thermostat | HmIP-Wired |
| `HmIPW-WGTC` | Homematic IP Wired Glass Wall Thermostat with CO2 Sensor | HmIP-Wired |
| `HmIPW-WGTC-A` | Homematic IP Wired Glass Wall Thermostat with CO2 Sensor | HmIP-Wired |
| `HmIPW-WRC2` | Homematic IP Wired Wall-mount Remote Control - 2 buttons | HmIP-Wired |
| `HmIPW-WRC2-A` | Homematic IP Wired Wall-mount Remote Control - 2 buttons | HmIP-Wired |
| `HmIPW-WRC6` | Homematic IP Wired Wall-mount Remote Control - 6 buttons | HmIP-Wired |
| `HmIPW-WRC6-A` | Homematic IP Wired Wall-mount Remote Control - 6 buttons | HmIP-Wired |
| `HmIPW-WTH` | Homematic IP Wired Wall Thermostat with Humidity Sensor | HmIP-Wired |
| `HmIPW-WTH-A` | Homematic IP Wired Wall Thermostat with Humidity Sensor | HmIP-Wired |

## Homematic (BidCos-RF)

| Type | Description | Protocol |
| --- | --- | --- |
| `263 130` | Wireless Switch Actuator 1-channel, flush-mount (OEM: Schüco) | BidCos-RF |
| `263 131` | Wireless Switch Actuator 1-channel, flush-mount (OEM: Schüco) | BidCos-RF |
| `263 132` | Wireless Dimming Actuator 1-channel leading edge, ceiling void mount (OEM: Schüco) | BidCos-RF |
| `263 133` | Wireless Dimming Actuator 1-channel, trailing edge, flush-mount (OEM: Schüco) | BidCos-RF |
| `263 134` | Wireless Dimming Actuator 2-channel, trailing edge, surface-mount (OEM: Schüco) | BidCos-RF |
| `263 135` | Wireless Push-button 2-channel in 55mm frame (OEM: Schüco) | BidCos-RF |
| `263 144` | Wireless Switch interface 3-channel, flush-mount (OEM: Schüco) | BidCos-RF |
| `263 145` | Wireless Push-button interface 4-channel, flush-mount (OEM: Schüco) | BidCos-RF |
| `263 146` | Wireless Blind Actuator 1-channel, flush-mount (OEM: Schüco) | BidCos-RF |
| `263 147` | Wireless Shutter Actuator 1-channel, surface-mount (OEM: Schüco) | BidCos-RF |
| `263 155` | Wireless Display Push-button 2-channel, surface-mount (OEM: Schüco) | BidCos-RF |
| `263 157` | Wireless Temperature Sensor - indoor (OEM: Schüco) | BidCos-RF |
| `263 158` | Wireless Temperature/Humidity Sensor, outdoor (OEM: Schüco) | BidCos-RF |
| `263 160` | Wireless Sensor for Carbon Dioxide (OEM: Schüco) | BidCos-RF |
| `263 162` | Wireless Motion Detector - indoor (OEM: Schüco) | BidCos-RF |
| `263 167` | Wireless Smoke Detector (OEM: Schüco) | BidCos-RF |
| `263_149_/_263_150` | Schüco WCS TipTronic board (OEM: Schüco) | BidCos-RF |
| `atent` | Remote Control DORMA (OEM: DORMA) | BidCos-RF |
| `BRC-H` | Remote Control DORMA, 4-channel (OEM: DORMA) | BidCos-RF |
| `HM-CC-RT-DN` | Wireless Heating Thermostat | BidCos-RF |
| `HM-CC-SCD` | Wireless Sensor for Carbon Dioxide | BidCos-RF |
| `HM-CC-TC` | Wireless Wall Thermostat | BidCos-RF |
| `HM-CC-VD` | Wireless Valve Drive | BidCos-RF |
| `HM-Dis-EP-WM55` | Display Status Monitor with E-Paper-Display | BidCos-RF |
| `HM-Dis-TD-T` | Wireless Status Monitor | BidCos-RF |
| `HM-Dis-WM55` | Display Status Monitor | BidCos-RF |
| `HM-DW-WM` | Wireless Dimming Actuator 2-channel PWM LED | BidCos-RF |
| `HM-ES-PMSw1-DR` | Wireless Switch Actuator with power measurement, DIN rail mount | BidCos-RF |
| `HM-ES-PMSw1-Pl` | Wireless Switch Actuator with power measurement | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R1` | Wireless Switch Actuator with power measurement | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R2` | Wireless Switch Actuator with power measurement | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R3` | Wireless Switch Actuator with power measurement | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R4` | Wireless Switch Actuator with power measurement | BidCos-RF |
| `HM-ES-PMSw1-Pl-DN-R5` | Wireless Switch Actuator with power measurement | BidCos-RF |
| `HM-ES-PMSw1-SM` | Wireless Switch Actuator with power measurement | BidCos-RF |
| `HM-ES-TX-WM` | Wireless Transmitter for Energy Meter Sensor | BidCos-RF |
| `HM-LC-AO-SM` | Wireless 0-10V Actuator | BidCos-RF |
| `HM-LC-Bl1-FM` | Wireless Blind Actuator 1-channel, flush-mount | BidCos-RF |
| `HM-LC-Bl1-FM-2` | Wireless Blind Actuator 1-channel, flush-mount | BidCos-RF |
| `HM-LC-Bl1-PB-FM` | Wireless Blind Actuator 1-channel, flush-mount with push-button | BidCos-RF |
| `HM-LC-Bl1-SM` | Wireless Blind Actuator 1-channel, surface-mount | BidCos-RF |
| `HM-LC-Bl1-SM-2` | Wireless Blind Actuator 1-channel, surface-mount | BidCos-RF |
| `HM-LC-Bl1PBU-FM` | Wireless Shutter Actuator 1-channel for brand switch systems, flush-mount | BidCos-RF |
| `HM-LC-DDC1-PCB` | Wireless Receiver 1-channel | BidCos-RF |
| `HM-LC-Dim1L-CV` | Wireless Dimming Actuator 1-channel leading edge, ceiling void mount | BidCos-RF |
| `HM-LC-Dim1L-CV-2` | Wireless Dimming Actuator 1-channel leading edge, ceiling void mount | BidCos-RF |
| `HM-LC-Dim1L-Pl` | Wireless Dimming Actuator 1-channel, plug adapter, phase control | BidCos-RF |
| `HM-LC-Dim1L-Pl-2` | Wireless Dimming Actuator 1-channel, plug adapter, phase control | BidCos-RF |
| `HM-LC-Dim1L-Pl-3` | Wireless Dimming Actuator 1-channel, plug adapter, phase control | BidCos-RF |
| `HM-LC-Dim1PWM-CV` | Wireless Dimming Actuator 1-channel PWM LED, ceiling-void mount | BidCos-RF |
| `HM-LC-Dim1PWM-CV-2` | Wireless Dimming Actuator 1-channel PWM LED, ceiling-void mount | BidCos-RF |
| `HM-LC-Dim1T-CV` | Wireless Dimming Actuator 1-channel, trailing edge, ceiling void mount | BidCos-RF |
| `HM-LC-Dim1T-CV-2` | Wireless Dimming Actuator 1-channel, trailing edge, ceiling void mount | BidCos-RF |
| `HM-LC-Dim1T-DR` | Wireless Dimming Actuator 1-channel, trailing edge, DIN rail mount | BidCos-RF |
| `HM-LC-Dim1T-FM` | Wireless Dimming Actuator 1-channel, trailing edge, flush-mount | BidCos-RF |
| `HM-LC-Dim1T-FM-2` | Wireless Dimming Actuator 1-channel, trailing edge, flush-mount | BidCos-RF |
| `HM-LC-Dim1T-FM-LF` | Wireless Dimming Actuator 1-channel, trailing edge, flush-mount | BidCos-RF |
| `HM-LC-Dim1T-Pl` | Wireless Dimming Actuator 1-channel, plug adapter, trailing edge | BidCos-RF |
| `HM-LC-Dim1T-Pl-2` | Wireless Dimming Actuator 1-channel, plug adapter, trailing edge | BidCos-RF |
| `HM-LC-Dim1T-Pl-3` | Wireless Dimming Actuator 1-channel, plug adapter, trailing edge | BidCos-RF |
| `HM-LC-Dim1TPBU-FM` | Wireless Dimming Actuator 1-channel, trailing edge, flush-mount | BidCos-RF |
| `HM-LC-Dim1TPBU-FM-2` | Wireless Dimming Actuator 1-channel, trailing edge, flush-mount | BidCos-RF |
| `HM-LC-Dim2L-SM` | Wireless Dimming Actuator 2-channel, leading edge, surface-mount | BidCos-RF |
| `HM-LC-Dim2L-SM-2` | Wireless Dimming Actuator 2-channel, leading edge, surface-mount | BidCos-RF |
| `HM-LC-Dim2T-SM` | Wireless Dimming Actuator 2-channel, trailing edge, surface-mount | BidCos-RF |
| `HM-LC-Dim2T-SM-2` | Wireless Dimming Actuator 2-channel, trailing edge, surface-mount | BidCos-RF |
| `HM-LC-DW-WM` | Wireless controller for dual white LEDs | BidCos-RF |
| `HM-LC-Ja1PBU-FM` | Wireless Blind Actuator 1-channel, flush-mount with push-button | BidCos-RF |
| `HM-LC-RGBW-WM` | Wireless RGBW Controller for wall mounting | BidCos-RF |
| `HM-LC-Sw1-Ba-PCB` | Wireless Switch Actuator 1-channel, PCB, battery | BidCos-RF |
| `HM-LC-Sw1-DR` | Wireless Switch Actuator 1-channel, DIN rail mount | BidCos-RF |
| `HM-LC-Sw1-FM` | Wireless Switch Actuator 1-channel, flush-mount | BidCos-RF |
| `HM-LC-Sw1-FM-2` | Wireless Switch Actuator 1-channel, flush-mount | BidCos-RF |
| `HM-LC-Sw1-PB-FM` | Wireless Switch Actuator 1-channel, flush-mount | BidCos-RF |
| `HM-LC-Sw1-PCB` | Wireless Switch Actuator 1-channel, PCB | BidCos-RF |
| `HM-LC-Sw1-Pl` | Wireless Switch Actuator 1-channel, socket adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-2` | Wireless Switch Actuator 1-channel, socket adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-3` | Wireless Switch Actuator 1-channel, socket adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R1` | Wireless Switch Actuator 1-channel with clamp terminal | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R1` | Wireless Switch Actuator 1-channel, socket adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R2` | Wireless Switch Actuator 1-channel, socket adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R3` | Wireless Switch Actuator 1-channel, socket adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R4` | Wireless Switch Actuator 1-channel, socket adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-DN-R5` | Wireless Switch Actuator 1-channel, socket adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-OM54` | Wireless Switch, 1-channel | BidCos-RF |
| `HM-LC-Sw1-SM` | Wireless Switch Actuator 1-channel, surface-mount | BidCos-RF |
| `HM-LC-Sw1-SM-2` | Wireless Switch Actuator 1-channel, surface-mount | BidCos-RF |
| `HM-LC-Sw1-SM-ATmega168` | Wireless Switch Actuator 1-channel, surface-mount | BidCos-RF |
| `HM-LC-Sw1PBU-FM` | Wireless Switch Actuator 1-channel for brand switch systems, flush-mount | BidCos-RF |
| `HM-LC-Sw2-DR` | Wireless Switch Actuator 2-channel, DIN rail mount | BidCos-RF |
| `HM-LC-Sw2-DR-2` | Wireless Switch Actuator 2-channel, DIN rail mount | BidCos-RF |
| `HM-LC-Sw2-FM` | Wireless Switch Actuator 2-channel, flush-mount | BidCos-RF |
| `HM-LC-Sw2-FM-2` | Wireless Switch Actuator 2-channel, flush-mount | BidCos-RF |
| `HM-LC-Sw2-PB-FM` | Wireless Switch Actuator 2-channel, flush-mount | BidCos-RF |
| `HM-LC-Sw2PBU-FM` | Wireless Switch Actuator 2-channel, flush-mount | BidCos-RF |
| `HM-LC-Sw4-Ba-PCB` | Wireless Switch Actuator 4-channel, PCB, battery | BidCos-RF |
| `HM-LC-Sw4-DR` | Wireless Switch Actuator 4-channel, DIN rail mount | BidCos-RF |
| `HM-LC-Sw4-DR-2` | Wireless Switch Actuator 4-channel, DIN rail mount | BidCos-RF |
| `HM-LC-Sw4-PCB` | Wireless Switch Actuator 4-channel, PCB | BidCos-RF |
| `HM-LC-Sw4-PCB-2` | Wireless Switch Actuator 4-channel, PCB | BidCos-RF |
| `HM-LC-Sw4-SM` | Wireless Switch Actuator 4-channel, surface-mount | BidCos-RF |
| `HM-LC-Sw4-SM-2` | Wireless Switch Actuator 4-channel, surface-mount | BidCos-RF |
| `HM-LC-Sw4-SM-ATmega168` | Wireless Switch Actuator 4-channel, surface-mount | BidCos-RF |
| `HM-LC-Sw4-WM` | Wireless Switch Actuator 4-channel, wall-mount | BidCos-RF |
| `HM-LC-Sw4-WM-2` | Wireless Switch Actuator 4-channel, wall-mount | BidCos-RF |
| `HM-MOD-EM-8` | Wireless Transmitter 8-channel, PCB, battery | BidCos-RF |
| `HM-MOD-EM-8Bit` | Wireless Transmitter, 8-Bit | BidCos-RF |
| `HM-MOD-Re-8` | Wireless Switch Actuator 8-channel, PCB, battery | BidCos-RF |
| `HM-OU-CF-Pl` | Wireless Door Chime with light flash | BidCos-RF |
| `HM-OU-CFM-Pl` | MP3 Wireless Chime with light flash | BidCos-RF |
| `HM-OU-CFM-TW` | MP3 Wireless Chime with light flash, battery | BidCos-RF |
| `HM-OU-CM-PCB` | Wireless chime module mp3 with memory | BidCos-RF |
| `HM-OU-LED16` | Wireless Status Monitor, LED16 | BidCos-RF |
| `HM-PB-2-FM` | Wireless Push-button 2-channel | BidCos-RF |
| `HM-PB-2-WM` | Wireless Push-button 2-channel | BidCos-RF |
| `HM-PB-2-WM55` | Wireless Push-button 2-channel in 55mm frame | BidCos-RF |
| `HM-PB-2-WM55-2` | Wireless Push-button 2-channel in 55mm frame | BidCos-RF |
| `HM-PB-4-WM` | Wireless Push-button 4-channel | BidCos-RF |
| `HM-PB-4Dis-WM` | Wireless Display Push-button 2-channel, surface-mount | BidCos-RF |
| `HM-PB-4Dis-WM-2` | Wireless Display Push-button 2-channel, surface-mount | BidCos-RF |
| `HM-PB-6-WM55` | HM Push Button 6 | BidCos-RF |
| `HM-PBI-4-FM` | Wireless Push-button interface 4-channel, flush-mount | BidCos-RF |
| `HM-RC-12` | Remote Control 12 buttons | BidCos-RF |
| `HM-RC-12-B` | Remote Control 12 buttons, black | BidCos-RF |
| `HM-RC-19` | Remote Control 19 buttons | BidCos-RF |
| `HM-RC-19-B` | Remote Control 19 buttons | BidCos-RF |
| `HM-RC-19-SW` | Remote Control 19 buttons | BidCos-RF |
| `HM-RC-2-PBU-FM` | Wireless Transmitter 2-channel for brand switch systems, flush-mount | BidCos-RF |
| `HM-RC-2-PBU-FM-2` | Wireless Transmitter 2-channel for brand switch systems, flush-mount | BidCos-RF |
| `HM-RC-4` | Remote Control 4 buttons | BidCos-RF |
| `HM-RC-4-2` | HM Remote 4-2 | BidCos-RF |
| `HM-RC-4-3` | Remote Control 4 buttons | BidCos-RF |
| `HM-RC-4-3-D` | Remote Control 4 buttons | BidCos-RF |
| `HM-RC-4-B` | Remote Control 4 buttons | BidCos-RF |
| `HM-RC-8` | Remote Control 8 buttons | BidCos-RF |
| `HM-RC-Dis-H-x-EU` | Remote Control with display | BidCos-RF |
| `HM-RC-Key3` | Wireless Remote Control for KeyMatic | BidCos-RF |
| `HM-RC-Key3-B` | Wireless Remote Control for KeyMatic | BidCos-RF |
| `HM-RC-Key4-2` | HM Remote KeyMatic 4-2 | BidCos-RF |
| `HM-RC-Key4-3` | Remote Control 4 buttons | BidCos-RF |
| `HM-RC-P1` | Wireless Panic Hand Transmitter | BidCos-RF |
| `HM-RC-Sec3` | Wireless Remote Control for the alarm function | BidCos-RF |
| `HM-RC-Sec3-B` | Wireless Remote Control for the alarm function | BidCos-RF |
| `HM-RC-Sec4-2` | HM Remote Security 4-2 | BidCos-RF |
| `HM-RC-Sec4-3` | Remote Control 4 buttons | BidCos-RF |
| `HM-SCI-3-FM` | Wireless Shutter Contact Interface 3-channel, flush-mount | BidCos-RF |
| `HM-Sec-Key` | KeyMatic | BidCos-RF |
| `HM-Sec-Key-O` | KeyMatic | BidCos-RF |
| `HM-Sec-Key-S` | KeyMatic | BidCos-RF |
| `HM-Sec-MDIR` | Wireless Motion Detector - indoor | BidCos-RF |
| `HM-Sec-MDIR-2` | Wireless Motion Detector - indoor | BidCos-RF |
| `HM-Sec-MDIR-3` | Wireless Motion Detector - indoor | BidCos-RF |
| `HM-Sec-RHS` | Wireless Window Rotary Handle Sensor | BidCos-RF |
| `HM-Sec-RHS-2` | Wireless Window Rotary Handle Sensor | BidCos-RF |
| `HM-Sec-SC` | Wireless Door/Window Contact | BidCos-RF |
| `HM-Sec-SC-2` | Wireless Door/Window Contact | BidCos-RF |
| `HM-Sec-SCo` | Wireless Door/Window Contact optical | BidCos-RF |
| `HM-Sec-SD` | Wireless Smoke Detector | BidCos-RF |
| `HM-Sec-SD-2` | Wireless Smoke Detector | BidCos-RF |
| `HM-Sec-SFA-SM` | Wireless Siren/Flash Actuator | BidCos-RF |
| `HM-Sec-Sir-WM` | Wireless Indoor Siren | BidCos-RF |
| `HM-Sec-TiS` | Wireless Tilt Sensor | BidCos-RF |
| `HM-Sec-WDS` | Wireless Water Detection Sensor | BidCos-RF |
| `HM-Sec-WDS-2` | Wireless Water Detection Sensor | BidCos-RF |
| `HM-Sec-Win` | WinMatic | BidCos-RF |
| `HM-Sen-DB-PCB` | Wireless Doorbell Sensor | BidCos-RF |
| `HM-Sen-EP` | Wireless sensor for electrical pulses | BidCos-RF |
| `HM-Sen-LI-O` | Wireless Light Intensity Sensor, outdoor | BidCos-RF |
| `HM-Sen-MDIR-O` | Wireless Motion Detector, outdoor | BidCos-RF |
| `HM-Sen-MDIR-O-2` | Wireless Motion Detector, outdoor | BidCos-RF |
| `HM-Sen-MDIR-O-3` | Wireless Motion Detector, outdoor | BidCos-RF |
| `HM-Sen-MDIR-SM` | Wireless Motion Detector | BidCos-RF |
| `HM-Sen-MDIR-WM55` | Wireless Motion Detector with button pair | BidCos-RF |
| `HM-Sen-RD-O` | Rain sensor | BidCos-RF |
| `HM-Sen-Wa-Od` | Wireless Capacitive Filling Level Sensor | BidCos-RF |
| `HM-SwI-3-FM` | Wireless Switch interface 3-channel, flush-mount | BidCos-RF |
| `HM-Sys-sRP-Pl` | Wireless Repeater, socket adapter | BidCos-RF |
| `HM-TC-IT-WM-W-EU` | Wireless Wall Thermostat | BidCos-RF |
| `HM-WDC7000` | Wireless Weather Data Center WDC 7000 | BidCos-RF |
| `HM-WDS10-TH-O` | Wireless Temperature/Humidity Sensor, outdoor | BidCos-RF |
| `HM-WDS100-C6-O` | Wireless Weather Data Sensor OC 3 | BidCos-RF |
| `HM-WDS100-C6-O-2` | Wireless Weather Data Sensor OC 3 | BidCos-RF |
| `HM-WDS30-OT2-SM` | Wireless Temperature Difference Sensor | BidCos-RF |
| `HM-WDS30-OT2-SM-2` | Wireless Temperature Difference Sensor | BidCos-RF |
| `HM-WDS30-T-O` | Wireless Temperature Sensor, outdoor | BidCos-RF |
| `HM-WDS40-TH-I` | Wireless Temperature Sensor - indoor | BidCos-RF |
| `HM-WDS40-TH-I-2` | Wireless Temperature Sensor - indoor | BidCos-RF |
| `KS550` | Wireless Weather Data Sensor 550 | BidCos-RF |
| `OLIGO.smart.iq.HM` | Wireless Dimming Actuator | BidCos-RF |
| `WS550` | Wireless weather station | BidCos-RF |
| `WS888` | Wireless Weather Data Center | BidCos-RF |
| `ZEL STG RM DWT 10` | Wireless Display Push-button 2-channel, surface-mount (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FDK` | Wireless Window Rotary Handle Sensor (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FEP 230V` | Wireless Blind Actuator 1-channel, flush-mount (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FFK` | Wireless Door/Window Contact (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FSA` | Wireless Valve Drive (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FSS UP3` | Wireless Switch interface 3-channel, flush-mount (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FST UP4` | Wireless Push-button interface 4-channel, flush-mount (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FWT` | Wireless Wall Thermostat (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FZS` | Wireless Switch Actuator 1-channel, socket adapter (OEM: Roto) | BidCos-RF |
| `ZEL STG RM FZS-2` | Wireless Switch Actuator 1-channel, socket adapter (OEM: Roto) | BidCos-RF |
| `ZEL STG RM HS 4` | Remote Control 4 buttons (OEM: Roto) | BidCos-RF |
| `ZEL STG RM WT 2` | Wireless Push-button 2-channel in 55mm frame (OEM: Roto) | BidCos-RF |

## Homematic Wired (BidCos-Wired, RS485)

| Type | Description | Protocol |
| --- | --- | --- |
| `HMW-IO-12-FM` | Wired RS485 I/O Module 12-channel, flush-mount | BidCos-Wired |
| `HMW-IO-12-Sw14-DR` | Wired RS485 I/O Module with 12 inputs, 14 outputs, DIN rail mount | BidCos-Wired |
| `HMW-IO-12-Sw7-DR` | Wired RS485 I/O Module with 12 inputs, 7 outputs, DIN rail mount | BidCos-Wired |
| `HMW-IO-4-FM` | Wired RS485 I/O Module 4-channel, flush-mount | BidCos-Wired |
| `HMW-LC-Bl1-DR` | Wired RS485 Blind Actuator 1-channel, DIN rail mount | BidCos-Wired |
| `HMW-LC-Bl1-DR-2` | Wired RS485 Blind Actuator 1-channel, DIN rail mount | BidCos-Wired |
| `HMW-LC-Dim1L-DR` | Wired RS485 Dimming Actuator 1-channel, leading edge, DIN rail mount | BidCos-Wired |
| `HMW-LC-Sw2-DR` | Wired RS485 Switch Actuator 2-channel, DIN rail mount | BidCos-Wired |
| `HMW-Sen-SC-12-DR` | Wired RS485 Shutter Contact 12-channel, DIN rail mount | BidCos-Wired |
| `HMW-Sen-SC-12-FM` | Wired RS485 Shutter Contact 12-channel, flush-mount | BidCos-Wired |

## Limited support (no WebUI integration)

These device types are known to the interface processes but have no entry in the WebUI device database. Check whether the functions you need are available in the WebUI before buying.

| Type | Description | Protocol |
| --- | --- | --- |
| `ASH550` | Wireless temperature/humidity sensor, outdoor | BidCos-RF |
| `ASH550I` | Wireless temperature/humidity sensor, indoor | BidCos-RF |
| `CMM` | Wireless energy management module | BidCos-RF |
| `ELV-SH-IAS` | Interface for analog sensors (0-10V or 4-20mA) | HmIP-RF |
| `HM-CC-RT-DN-BoM` | ClimateControl-RadiatorThermostat | BidCos-RF |
| `HM-LC-Dim2L-CV` | 2 channel dimmer L (ceiling voids) | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R2` | Wireless Switch Actuator 1-channel with clamp terminal, plug adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R3` | Wireless Switch Actuator 1-channel with clamp terminal, plug adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R4` | Wireless Switch Actuator 1-channel with clamp terminal, plug adapter | BidCos-RF |
| `HM-LC-Sw1-Pl-CT-R5` | Wireless Switch Actuator 1-channel with clamp terminal, plug adapter | BidCos-RF |
| `HM-LC-Sw2-SM` | radio-controlled switch actuator 2-channel (surface-mount) | BidCos-RF |
| `HM-RC-12-SW` | HM Remote 12 buttons (softtouch white) | BidCos-RF |
| `HM-WDS20-TH-O` | Wireless temperature/humidity sensor, outdoor | BidCos-RF |
| `HmIP-E27` | Homematic IP Bulb - RGBWW | HmIP-RF |
| `HmIP-ESI-Linky` | Interface for Linky | HmIP-RF |
| `HmIP-GU10` | Homematic IP Bulb - RGBWW | HmIP-RF |
| `HmIP-HDM1` | Module for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM2` | Module for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM3` | Module for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM4` | Module for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM5` | Module for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM6` | Module for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM7` | Module for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM8` | Module for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDM9` | Module for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-HDRC` | Remote Control for Hunter Douglas drives (OEM: HunterDouglas) | HmIP-RF |
| `HmIP-PR` | Pluggable Router | HmIP-RF |
| `HmIP-PR-CH` | Pluggable Router | HmIP-RF |
| `HmIP-PR-PE` | Pluggable Router | HmIP-RF |
| `HmIP-PR-UK` | Pluggable Router | HmIP-RF |
| `HmIP-PS-CH` | Pluggable Switch | HmIP-RF |
| `HmIP-PS-PE` | Pluggable Switch | HmIP-RF |
| `HmIP-PS-UK` | Pluggable Switch | HmIP-RF |
| `HmIP-SWSD-3` | Smoke Detektor | HmIP-RF |
| `HmIP-WLAN-HAP` | Wireless Access Point | HmIP-RF |
| `HmIP-WLAN-HAP-B` | Wireless Access Point Basic | HmIP-RF |
| `HmIPW-AV` | Wired Flow Regulator | HmIP-Wired |
| `HmIPW-AV-CO2` | Wired Flow Regulator, CO2 | HmIP-Wired |
| `HmIPW-AV-RH` | Wired Flow Regulator, rH | HmIP-Wired |
| `HmIPW-AV-S` | Wired Flow Sensor | HmIP-Wired |
| `HmIPW-AV-SVN` | Wired Flow Sensor, VOC | HmIP-Wired |
| `HmIPW-DRAVC` | Wired DCV Controller | HmIP-Wired |
| `HMW-IO-SR-FM` | RS485 I/O SR | BidCos-Wired |
| `IS-WDS-TH-OD-S-R3` | Wireless temperature/humidity sensor, outdoor | BidCos-RF |
| `KS550LC` | Wireless combination weather sensor | BidCos-RF |
| `KS550Tech` | Wireless combination weather sensor | BidCos-RF |
| `KS888` | Wireless combination weather sensor | BidCos-RF |
| `KW-BLR2CH` | Switch Actuator for heating systems – 2 channels (OEM: Warmup) | HmIP-RF |
| `KW-STATH` | Wallmounted Room Thermostat (OEM: Warmup) | HmIP-RF |
| `KW-UKETRV` | Electronic Wireless Radiator Thermostat - basic (OEM: Warmup) | HmIP-RF |
| `KW-UKETRV-2` | Electronic Wireless Radiator Thermostat - basic (OEM: Warmup) | HmIP-RF |
| `KW-UKHUB` | Generic Access Point Device (OEM: Warmup) | HmIP-RF |
| `KW-WC10CH` | Floor Heating Actuator - 10 channels (OEM: Warmup) | HmIP-RF |
| `RC-H` | DORMA Remote 4 buttons (OEM: DORMA) | BidCos-RF |
| `S550IA` | Wireless temperature sensor | BidCos-RF |
| `ST6-SH` | SensoTimer ST 6 Smart Home | BidCos-RF |
| `WDF solar` | ROTO WDF solar (OEM: Roto) | BidCos-RF |
| `WS550LCB` | Wireless weather station | BidCos-RF |
| `WS550LCW` | Wireless weather station | BidCos-RF |
| `WS550Tech` | Wireless weather station | BidCos-RF |

## Not supported (WebUI entry only)

These device types exist in the WebUI device database but are not known as a device type by any interface process and therefore do not count as supported (e.g. discontinued legacy devices or new devices whose support is still missing in the HMIPServer). Do not plan new purchases around them.

| Type | Description | Protocol |
| --- | --- | --- |
| `ELV-SH-FS` | ELV-SH-FS | HmIP-RF |
| `ELV-SH-FSI` | ELV-SH-FSI | HmIP-RF |
| `ELV-SH-KRCO` | ELV smart home key ring remote control outdoor | HmIP-RF |
| `HM-EM-CCM` | Metering Sensor camera module | BidCos-RF |
| `HM-EM-CMM` | Metering Sensor management module | BidCos-RF |
| `HM-LC-Dim1L-CV-644` | Wireless Dimming Actuator 1-channel leading edge, ceiling void mount | BidCos-RF |
| `HM-LC-Dim1L-Pl-644` | Wireless Dimming Actuator 1-channel, plug adapter, phase control | BidCos-RF |
| `HM-LC-Dim1T-CV-644` | Wireless Dimming Actuator 1-channel, trailing edge, ceiling void mount | BidCos-RF |
| `HM-LC-Dim1T-FM-644` | Wireless Dimming Actuator 1-channel, trailing edge, flush-mount | BidCos-RF |
| `HM-LC-Dim1T-Pl-644` | Wireless Dimming Actuator 1-channel, plug adapter, trailing edge | BidCos-RF |
| `HM-LC-Dim2L-SM-644` | Wireless Dimming Actuator 2-channel, leading edge, surface-mount | BidCos-RF |
| `HM-LC-Dim2T-SM-644` | Wireless Dimming Actuator 2-channel, trailing edge, surface-mount | BidCos-RF |
| `HM-WS550-US` | Wireless Weather Data Center USA | BidCos-RF |
| `HM-WS550ST-IO` | Wireless Temperature Sensor, outdoor | BidCos-RF |
| `HM-WS550STH-I` | Wireless Temperature Sensor - indoor | BidCos-RF |
| `HM-WS550STH-O` | Wireless Temperature/Humidity Sensor, outdoor | BidCos-RF |
| `HmIP-eTRV-B-UK-2` | Homematic IP Radiator Thermostat - basic UK | HmIP-RF |
| `HMW-Sec-TR-FM` | Wired RS 485 Transponder Reader, flush-mount | BidCos-Wired |
| `HMW-Sys-PS7-DR` | Wired RS485 Power Supply 7 VA, DIN rail mount | BidCos-Wired |
| `HMW-WSE-SM` | Wired RS485 Light Sensor, surface mount | BidCos-Wired |
| `HMW-WSTH-SM` | Wired RS485 Temperature/Humidity Sensor | BidCos-Wired |
