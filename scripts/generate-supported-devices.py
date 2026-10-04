#!/usr/bin/env python3
"""Generate the list of Homematic (BidCos) and Homematic IP devices supported by OpenCCU.

The list is derived from the OpenCCU-Base sources that actually decide whether
a device can be used:

  * BidCos-RF:    src/devicetypes/rftypes/*.xml     (rfd device descriptions)
  * BidCos-Wired: src/devicetypes/hs485types/*.xml  (hs485d device descriptions)
  * HmIP/HmIPW:   opt/HMServer/HMIPServer.jar       (devicespecification/*.xml)
  * WebUI:        www/config/devdescr/DEVDB.tcl and
                  www/webui/js/lang/{de,en}/translate.lang.deviceDescription.js
  * Firmware:     an OpenCCU/HMDeviceFirmware checkout (optional)

A device type counts as supported if one of the interface processes knows it.
The WebUI database is used for the descriptions and device images and to flag
devices without dedicated WebUI integration. WebUI entries without any
interface process support are listed separately as not supported. With
--firmware, the newest device firmware installable on the current OpenCCU
version is listed for each device type.

Usage:
  scripts/generate-supported-devices.py --base ../OpenCCU-Base \
      [--firmware ../HMDeviceFirmware] (--wiki ../OpenCCU.wiki | --out-dir DIR)

With --wiki, the pages are written as the OpenCCU wiki pages
"Unterstützte-Geräte" and "en.Supported-Devices" into a wiki checkout; commit
and push them from there.
"""

import argparse
import datetime
import html
import re
import subprocess
import tarfile
import urllib.parse
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
BASE_MK = ROOT / 'buildroot-external/package/openccu-base/openccu-base.mk'
BASE_RAW = 'https://raw.githubusercontent.com/OpenCCU/OpenCCU-Base/{rev}/www'
FW_REPO = 'https://github.com/OpenCCU/HMDeviceFirmware'
FW_PAGES = 'https://openccu.github.io/HMDeviceFirmware/'
FW_CHANGELOG = FW_PAGES + 'changelogs/changelog_{stem}.html'
SHOP_SEARCH = 'https://de.elv.com/search?q={}'
# Homematic type names; everything else is a partner/OEM designation
OFFICIAL_TYPES = re.compile(r'^(HM-|HMW-|HmIP|HMIP-|ELV-SH-)')
JAR = Path('opt/HMServer/HMIPServer.jar')
JAR_SPECS = 'de/eq3/cbcs/devicedescription/devicespecification/'
DEVDB = Path('www/config/devdescr/DEVDB.tcl')
LANG = 'www/webui/js/lang/{}/translate.lang.deviceDescription.js'

# Interface process internals: generic fallback types, virtual devices,
# groups, the central/radio adapters themselves and development boards.
EXCLUDE = {
    # BidCos-RF / BidCos-Wired
    'CENTRAL', 'HM-RCV-50', 'HMW-RCV-50', 'HMW-Generic', 'HSS-DX',
    'HM-ES-PMSwX', 'HM-LC-BlX', 'HM-LC-JaX', 'HM-LC-SwX', 'HM-MD',
    'HM-OU-X', 'HM-PBI-X', 'HM-RC-SB-X', 'HM-RC-X', 'HM-Sen-X', 'HM-SwI-X',
    'HM-Sec-MD', 'HM-Sec-xx', 'HM-Sec-Key-Generic', 'HM-Sec-Win-Generic',
    'HM-Sec-SD-Generic', 'HM-Sec-SD-2-Generic', 'HM-ReSC-Win-PCB-xx',
    'HM-Sec-SD-Team', 'HM-Sec-SD-2-Team', '263 167 Gruppe',
    # HmIP: central / radio adapters, sniffers, development boards
    'HM-CCU2', 'HM-MOD-UART', 'HmIP-CCU3', 'HmIP-RFUSB', 'HmIPW-USB',
    'RPI-RF-MOD', 'HmIP-HCU1', 'HmIP-HCU1-A', 'RF-LAN-Sniffer',
    'Wired-LAN-Sniffer', 'HmIP-Bulb-Evalboard', 'HmIP-eTRV-B-DEV',
}

# WebUI-only entries that describe virtual devices or groups (not hardware).
WEBUI_VIRTUAL = re.compile(r'^(VIR-|DEVICE$|HM-CCU-1$|HmIP-RCV-50$|HmIP-HEATING$|HM-CC-VG-1$)')

# WebUI description keys whose text is misleading in a device list.
OVERRIDE = {
    'HmIP-HAP': ('Homematic IP Access Point (als LAN-Router nutzbar)',
                 'Homematic IP Access Point (usable as LAN router)'),
}

# Devices whose sources carry no (or only a broken) description.
TYPE_DESC = {
    'ASH550': ('Funk-Temperatur-/Feuchtesensor außen', 'Wireless temperature/humidity sensor, outdoor'),
    'ASH550I': ('Funk-Temperatur-/Feuchtesensor innen', 'Wireless temperature/humidity sensor, indoor'),
    'HM-WDS20-TH-O': ('Funk-Temperatur-/Feuchtesensor außen', 'Wireless temperature/humidity sensor, outdoor'),
    'IS-WDS-TH-OD-S-R3': ('Funk-Temperatur-/Feuchtesensor außen', 'Wireless temperature/humidity sensor, outdoor'),
    'S550IA': ('Funk-Temperatursensor', 'Wireless temperature sensor'),
    'KS550LC': ('Funk-Kombisensor', 'Wireless combination weather sensor'),
    'KS550Tech': ('Funk-Kombisensor', 'Wireless combination weather sensor'),
    'KS888': ('Funk-Kombisensor', 'Wireless combination weather sensor'),
    'WS550LCB': ('Funk-Wetterstation', 'Wireless weather station'),
    'WS550LCW': ('Funk-Wetterstation', 'Wireless weather station'),
    'WS550Tech': ('Funk-Wetterstation', 'Wireless weather station'),
    'CMM': ('Funk-Energiemanagement-Modul', 'Wireless energy management module'),
    'WS550': ('Funk-Wetterstation', 'Wireless weather station'),
    '263_149_/_263_150': ('Schüco WCS-TipTronic-Platine', 'Schüco WCS TipTronic board'),
}

# German texts for devices whose description only exists in English.
DE_FALLBACK = {
    'Watersensor compact': 'ELV Smart Home Wassersensor Kompakt',
    'Ultrasonic distance sensor interface': 'ELV Smart Home Ultraschall-Abstandssensor-Schnittstelle',
    'Door Lock Drive – Pro': 'Homematic IP Türschlossantrieb - Pro',
    'Switch Actuator – flush-mount': 'Homematic IP Schaltaktor - Unterputz',
    'Remote Control with mounting belt – 1 channel': 'Homematic IP Fernbedienung mit Befestigungsband - 1-fach',
    'Universal Dimming Control Element - Motion Detector': 'Homematic IP Universal Dimmeraufsatz - Bewegungsmelder',
    'Water Stop and Supply Unit': 'Homematic IP Wasserabsperr- und Versorgungseinheit',
    'Wireless RGBW Controller for wall mounting': 'Funk-RGBW-Controller, Wandmontage',
    'HM Push Button 6': 'Funk-Wandtaster 6-fach im 55er Rahmen',
    'HM Remote 4-2': 'Funk-Handsender 4 Tasten',
    'HM Remote KeyMatic 4-2': 'Funk-Handsender 4 Tasten für KeyMatic',
    'HM Remote Security 4-2': 'Funk-Handsender 4 Tasten für Alarmzentrale',
    'Interface for analog sensors (0-10V or 4-20mA)': 'ELV Smart Home Schnittstelle für analoge Sensoren (0-10 V bzw. 4-20 mA)',
    'Smoke Detektor': 'Homematic IP Rauchwarnmelder',
    'Homematic IP Bulb - RGBWW': 'Homematic IP Leuchtmittel - RGBWW',
    'Interface for Linky': 'Homematic IP Schnittstelle für Linky-Stromzähler',
    'Module for Hunter Douglas drives': 'Modul für Hunter-Douglas-Antriebe',
    'Remote Control for Hunter Douglas drives': 'Fernbedienung für Hunter-Douglas-Antriebe',
    'Pluggable Router': 'Homematic IP Zwischenstecker Router (Repeater)',
    'Pluggable Switch': 'Homematic IP Zwischenstecker Schalten',
    'Wireless Access Point': 'Homematic IP WLAN Access Point',
    'Wireless Access Point Basic': 'Homematic IP WLAN Access Point - basic',
    'Generic Access Point Device': 'Access Point',
    'Wired Flow Regulator': 'Homematic IP Wired Volumenstromregler',
    'Wired Flow Regulator, CO2': 'Homematic IP Wired Volumenstromregler mit CO2-Sensor',
    'Wired Flow Regulator, rH': 'Homematic IP Wired Volumenstromregler mit Feuchtesensor',
    'Wired Flow Sensor': 'Homematic IP Wired Volumenstromsensor',
    'Wired Flow Sensor, VOC': 'Homematic IP Wired Volumenstromsensor mit VOC-Sensor',
    'Wired DCV Controller': 'Homematic IP Wired Lüftungsregler (DCV)',
    'Switch Actuator for heating systems – 2 channels': 'Schaltaktor für Heizungssysteme - 2-fach',
    'Wallmounted Room Thermostat': 'Wandthermostat',
    'Electronic Wireless Radiator Thermostat - basic': 'Heizkörperthermostat - basic',
    'Floor Heating Actuator - 10 channels': 'Fußbodenheizungsaktor - 10-fach',
    'ClimateControl-RadiatorThermostat': 'Funk-Heizkörperthermostat',
    'radio-controlled switch actuator 2-channel (surface-mount)': 'Funk-Schaltaktor 2-fach, Aufputzmontage',
    'Wireless Switch Actuator 1-channel with clamp terminal, plug adapter': 'Funk-Schaltaktor 1-fach mit Klemmanschluss',
    '2 channel dimmer L (ceiling voids)': 'Funk-Dimmaktor 2-fach, Phasenanschnitt, Zwischendeckenmontage',
    'HM Remote 12 buttons (softtouch white)': 'Funk-Fernbedienung 12 Tasten, softtouch weiß',
    'RS485 I/O SR': 'Wired RS485 I/O-Modul für Rollladen, Unterputzmontage',
    'SensoTimer ST 6 Smart Home': 'Bewässerungscomputer SensoTimer ST 6 Smart Home',
    'DORMA Remote 4 buttons': 'Funk-Handsender DORMA, 4 Tasten',
    'ROTO WDF solar': 'Roto Wohndachfenster solar',
}

PROTO_ORDER = ['HmIP-RF', 'HmIP-Wired', 'BidCos-RF', 'BidCos-Wired']

TEXT = {
    'de': {
        'title': 'OpenCCU unterstützte HomeMatic / Homematic IP Geräte',
        'other': '[English version]({other})',
        'intro': (
            'Alle {count} Homematic (BidCos-RF, BidCos-Wired) und Homematic IP (HmIP-RF, '
            'HmIP-Wired) Gerätetypen, die von OpenCCU {occu} unterstützt werden – als Hilfe vor '
            'dem Kauf neuer Geräte. Die Bereiche lassen sich auf- und zuklappen; Erläuterungen '
            'stehen in den [Hinweisen](#hinweise) am Ende der Seite.'),
        'toc': 'Bereiche',
        'basis_top': ('OpenCCU {occu} · {base} (Gerätebeschreibungen von `rfd`/`hs485d`, '
                      'WebUI-Gerätedatenbank) · `HMIPServer.jar` {hmip}{fw} · Stand {date}'),
        'notes_h': 'Hinweise',
        'notes': [
            'Ein Gerätetyp gilt als unterstützt, wenn ihn der zuständige Schnittstellenprozess '
            'von OpenCCU kennt. Die Liste wird automatisch aus diesen Quellen erzeugt:',
            'Für Homematic IP wird ein HmIP-fähiges Funkmodul (z.B. RPI-RF-MOD, HM-MOD-RPI-PCB, '
            'HmIP-RFUSB) benötigt, für Homematic IP Wired zusätzlich ein Homematic IP Wired '
            'Access Point (HmIPW-DRAP) und für Homematic Wired (BidCos-Wired/RS485) ein '
            'Homematic Wired LAN Gateway (HMW-LGW-O-DR-GS-EU).',
            'Typbezeichnungen mit Ländersuffix (`-UK`, `-CH`, `-PE`, `-IT`) und Varianten '
            '(`-A` = anthrazit, `-2`/`-3` = neuere Hardwarerevision) sind jeweils eigene Einträge.',
            'Die Bilder stammen aus der WebUI-Gerätedatenbank; ein Klick auf ein Bild öffnet die '
            'größere Ansicht.',
            'Die Typbezeichnung verlinkt auf die Produktsuche im ELV-Shop (Vertriebspartner von '
            'eQ-3) mit Beschreibung, technischen Daten und Bedienungsanleitung. Für ältere, nicht '
            'mehr erhältliche Geräte liefert die Suche ggf. keinen Treffer.',
            'Die Spalte „Firmware“ nennt die neueste Geräte-Firmware aus dem '
            '[HMDeviceFirmware-Archiv]({fwpages}), die mit OpenCCU {occu} installiert werden kann '
            '(benötigte CCU-Mindestversion laut Firmware-Paket). Die Versionsnummer verlinkt auf '
            'das Changelog. „–“ bedeutet, dass im Archiv keine Firmware für diesen Gerätetyp liegt.',
            'Partner- und OEM-Geräte sind Geräte anderer Hersteller (z.B. Roto, Schüco, DORMA, '
            'Möhlenhoff, Warmup) oder ältere ELV-Wetterstationen, die keine Homematic-'
            'Typenbezeichnung tragen, sondern unter ihrer Hersteller- bzw. Artikelbezeichnung '
            'geführt werden.',
            'Geräte unter „Eingeschränkte Unterstützung“ werden zwar vom Schnittstellenprozess '
            'erkannt, haben aber keine eigene Integration in die WebUI (kein Gerätebild, keine '
            'Gerätebeschreibung). Sie lassen sich anlernen, die Bedienung in der WebUI kann '
            'jedoch eingeschränkt sein.',
            'Geräte unter „Nicht unterstützt“ sind zwar in der WebUI-Gerätedatenbank vorhanden, '
            'aber keinem Schnittstellenprozess als Gerätetyp bekannt (z.B. abgekündigte Altgeräte '
            'oder neue Geräte, deren Unterstützung im HMIPServer noch fehlt). Sie sollten nicht '
            'für eine Neuanschaffung eingeplant werden.',
        ],
        'src': [
            '`BidCos-RF`: Gerätebeschreibungen des `rfd` (`src/devicetypes/rftypes/*.xml`)',
            '`BidCos-Wired`: Gerätebeschreibungen des `hs485d` (`src/devicetypes/hs485types/*.xml`)',
            '`HmIP-RF`/`HmIP-Wired`: Gerätespezifikationen im `HMIPServer.jar` (`{jar}`)',
            'Beschreibungen und Bilder: WebUI-Gerätedatenbank (`DEVDB.tcl`) und WebUI-Übersetzungen',
        ],
        'basis': 'Datenbasis',
        'regen': 'Neu erzeugen mit',
        'repo': 'im OpenCCU-Repository',
        'count': 'Gerätetypen',
        'proto': 'Protokoll',
        'type': 'Typ',
        'img': 'Bild',
        'fw': 'Firmware',
        'desc': 'Beschreibung',
        'aka': 'auch als',
        'oem': 'OEM',
        'sec': {
            'HmIP-RF': 'Homematic IP (HmIP-RF)',
            'HmIP-Wired': 'Homematic IP Wired (HmIP-Wired)',
            'BidCos-RF': 'Homematic (BidCos-RF)',
            'BidCos-Wired': 'Homematic Wired (BidCos-Wired, RS485)',
        },
        'oem_h': 'Partner- und OEM-Geräte (ohne Homematic-Typenbezeichnung)',
        'limited_h': 'Eingeschränkte Unterstützung (ohne WebUI-Integration)',
        'unsupported_h': 'Nicht unterstützt (nur WebUI-Eintrag vorhanden)',
    },
    'en': {
        'title': 'OpenCCU supported HomeMatic / Homematic IP devices',
        'other': '[Deutsche Version]({other})',
        'intro': (
            'All {count} Homematic (BidCos-RF, BidCos-Wired) and Homematic IP (HmIP-RF, '
            'HmIP-Wired) device types supported by OpenCCU {occu} – to check devices before '
            'buying them. Each section can be expanded and collapsed; explanations are in the '
            '[notes](#notes) at the end of the page.'),
        'toc': 'Sections',
        'basis_top': ('OpenCCU {occu} · {base} (`rfd`/`hs485d` device descriptions, WebUI '
                      'device database) · `HMIPServer.jar` {hmip}{fw} · as of {date}'),
        'notes_h': 'Notes',
        'notes': [
            'A device type counts as supported if the responsible OpenCCU interface process knows '
            'it. The list is generated automatically from these sources:',
            'Homematic IP requires an HmIP capable radio module (e.g. RPI-RF-MOD, HM-MOD-RPI-PCB, '
            'HmIP-RFUSB), Homematic IP Wired additionally requires a Homematic IP Wired Access '
            'Point (HmIPW-DRAP) and Homematic Wired (BidCos-Wired/RS485) requires a Homematic '
            'Wired LAN Gateway (HMW-LGW-O-DR-GS-EU).',
            'Type names with a country suffix (`-UK`, `-CH`, `-PE`, `-IT`) and variants '
            '(`-A` = anthracite, `-2`/`-3` = newer hardware revision) are listed separately.',
            'The images are taken from the WebUI device database; click an image to open the '
            'larger view.',
            'The type name links to the product search of the ELV shop (eQ-3 distribution '
            'partner, German) with description, technical data and user manual. For older '
            'devices that are no longer sold the search may return no result.',
            'The "Firmware" column shows the newest device firmware from the '
            '[HMDeviceFirmware archive]({fwpages}) that can be installed with OpenCCU {occu} '
            '(minimum CCU version required by the firmware package). The version links to its '
            'changelog. "–" means the archive holds no firmware for this device type.',
            'Partner and OEM devices are devices of other manufacturers (e.g. Roto, Schüco, DORMA, '
            'Möhlenhoff, Warmup) or older ELV weather stations that carry no Homematic type name '
            'but are listed under their manufacturer or article designation.',
            'Devices under "Limited support" are known to the interface process but have no '
            'dedicated WebUI integration (no device image, no device description). They can be '
            'paired, but their handling in the WebUI may be limited.',
            'Devices under "Not supported" exist in the WebUI device database but are not known '
            'as a device type by any interface process (e.g. discontinued legacy devices or new '
            'devices whose support is still missing in the HMIPServer). Do not plan new '
            'purchases around them.',
        ],
        'src': [
            '`BidCos-RF`: `rfd` device descriptions (`src/devicetypes/rftypes/*.xml`)',
            '`BidCos-Wired`: `hs485d` device descriptions (`src/devicetypes/hs485types/*.xml`)',
            '`HmIP-RF`/`HmIP-Wired`: device specifications in `HMIPServer.jar` (`{jar}`)',
            'Descriptions and images: WebUI device database (`DEVDB.tcl`) and WebUI translations',
        ],
        'basis': 'Data basis',
        'regen': 'Regenerate with',
        'repo': 'in the OpenCCU repository',
        'count': 'device types',
        'proto': 'Protocol',
        'type': 'Type',
        'img': 'Image',
        'fw': 'Firmware',
        'desc': 'Description',
        'aka': 'also as',
        'oem': 'OEM',
        'sec': {
            'HmIP-RF': 'Homematic IP (HmIP-RF)',
            'HmIP-Wired': 'Homematic IP Wired (HmIP-Wired)',
            'BidCos-RF': 'Homematic (BidCos-RF)',
            'BidCos-Wired': 'Homematic Wired (BidCos-Wired, RS485)',
        },
        'oem_h': 'Partner and OEM devices (no Homematic type name)',
        'limited_h': 'Limited support (no WebUI integration)',
        'unsupported_h': 'Not supported (WebUI entry only)',
    },
}


def tcl_list(text):
    """Split a Tcl list into its elements (braces only, no escapes needed)."""
    items, i = [], 0
    while i < len(text):
        if text[i].isspace():
            i += 1
        elif text[i] == '{':
            depth, j = 1, i + 1
            while depth:
                depth += {'{': 1, '}': -1}.get(text[j], 0)
                j += 1
            items.append(text[i + 1:j - 1])
            i = j
        else:
            j = i
            while j < len(text) and not text[j].isspace():
                j += 1
            items.append(text[i:j])
            i = j
    return items


def clean(text):
    text = re.sub(r'\s+', ' ', text or '').strip()
    return re.sub(r'\bFunk- (?=[A-ZÄÖÜ])', 'Funk-', text)


def load_bidcos(base, family):
    types = {}
    for path in sorted((base / 'src/devicetypes' / family).glob('*.xml')):
        for node in ET.parse(path).getroot().iter('type'):
            types.setdefault(node.get('id'), clean(node.get('name')))
    return types


def load_hmip(base):
    types, version = {}, ''
    with zipfile.ZipFile(base / JAR) as jar:
        manifest = jar.read('META-INF/MANIFEST.MF').decode()
        match = re.search(r'^Build-Version: *(.+?)\s*$', manifest, re.M)
        stamp = re.search(r'^Build-Timestamp: *(.+?)\s*$', manifest, re.M)
        version = ' '.join(m.group(1) for m in (match, stamp) if m)
        for name in sorted(jar.namelist()):
            if not (name.startswith(JAR_SPECS) and name.endswith('.xml')):
                continue
            root = ET.fromstring(jar.read(name))
            for node in root.iter('devType'):
                entry = types.setdefault(node.get('label'), {'desc': clean(root.get('description')), 'oems': set()})
                entry['oems'].add(node.get('oem'))
    return types, version


def load_webui(base):
    src = (base / DEVDB).read_text(encoding='latin-1')
    devlist = tcl_list(re.search(r'^set DEV_LIST \{(.*)\}$', src, re.M).group(1))
    descr = tcl_list(re.search(r'^array set DEV_DESCRIPTION \{(.*)\}$', src, re.M).group(1))
    paths = tcl_list(re.search(r'^array set DEV_PATHS +\{(.*)\}$', src, re.M).group(1))
    images = {}
    for dev_type, value in zip(paths[::2], paths[1::2]):
        sizes = dict(tcl_list(item)[:2] for item in tcl_list(value))
        if (base / 'www' / sizes.get('50', '').lstrip('/')).is_file():
            images[dev_type] = (sizes['50'], sizes.get('250', sizes['50']))
    langs = {}
    for lang in ('de', 'en'):
        text = (base / LANG.format(lang)).read_text(encoding='latin-1')
        langs[lang] = {
            key: clean(urllib.parse.unquote(re.sub(r'<br\s*/?>', ' ', value), encoding='latin-1'))
            for key, value in re.findall(r'^\s*"([^"]+)"\s*:\s*"(.*)",?\s*$', text, re.M)
        }
    return devlist, dict(zip(descr[::2], descr[1::2])), langs, images


def version_key(version):
    return tuple(int(part) for part in re.findall(r'\d+', version))


def fw_key(dev_type):
    return re.sub(r'[ _]', '-', dev_type.lower())


def load_firmware(fwdir, openccu_version):
    """Newest firmware per device type that the given OpenCCU version accepts."""
    newest = {}
    for path in sorted(fwdir.glob('*/*.t*gz')):
        with tarfile.open(path) as archive:
            member = next((m for m in archive.getmembers() if Path(m.name).name == 'info'), None)
            if member is None:
                continue
            text = archive.extractfile(member).read().decode('latin-1')
        info = dict(line.split('=', 1) for line in text.splitlines() if '=' in line)
        version = info.get('FirmwareVersion', '').strip()
        minimum = info.get('CCU3FirmwareVersionMin', '0').strip()
        if not version or version_key(minimum) > version_key(openccu_version):
            continue
        key = fw_key(info.get('Name', '').strip())
        if key not in newest or version_key(version) > version_key(newest[key]['version']):
            newest[key] = {'version': version, 'stem': path.name.split('.')[0]}
    return newest


def git_rev(base):
    try:
        return subprocess.run(['git', '-C', str(base), 'rev-parse', 'HEAD'],
                              capture_output=True, text=True, check=True).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return 'unknown'


def display_name(dev_type):
    return re.sub(r'^HMIP-', 'HmIP-', dev_type)


def oem_of(dev_type, oem):
    if oem:
        return oem
    if dev_type.startswith('ZEL STG RM') or dev_type == 'WDF solar':
        return 'Roto'
    if dev_type.startswith('263'):
        return 'Schüco'
    if dev_type in ('atent', 'BRC-H', 'RC-H'):
        return 'DORMA'
    return None


def collect(base, firmware):
    rf = load_bidcos(base, 'rftypes')
    wired = load_bidcos(base, 'hs485types')
    hmip, version = load_hmip(base)
    devlist, devdescr, langs, images = load_webui(base)
    webui = {t.lower(): t for t in devlist}

    def webui_type(dev_type):
        return dev_type if dev_type in devdescr else webui.get(dev_type.lower())

    def describe(dev_type, fallback):
        key = devdescr.get(webui_type(dev_type)) if webui_type(dev_type) else None
        if dev_type in TYPE_DESC:
            return TYPE_DESC[dev_type]
        if key in OVERRIDE:
            return OVERRIDE[key]
        result = []
        for lang in ('de', 'en'):
            text = langs[lang].get(key) if key else None
            if not text and key and ' ' in key and lang == 'de':
                text = clean(key)  # some entries carry the German text as key
            if not text or text.lower() == dev_type.lower():
                text = DE_FALLBACK.get(fallback, fallback) if lang == 'de' else fallback
            result.append(text)
        return tuple(result)

    devices = []
    for proto, types in (('BidCos-RF', rf), ('BidCos-Wired', wired)):
        for dev_type, name in types.items():
            if dev_type not in EXCLUDE:
                devices.append({'type': dev_type, 'proto': proto, 'oem': oem_of(dev_type, None),
                                'webui': dev_type.lower() in webui, 'desc': describe(dev_type, name),
                                'aka': []})
    variants = {}
    for dev_type, info in hmip.items():
        if dev_type in EXCLUDE:
            continue
        # labels such as "HmIP-STH 8DU" are market variants of the base type
        if ' ' in dev_type and dev_type.split(' ')[0] in hmip:
            variants.setdefault(dev_type.split(' ')[0], []).append(dev_type)
            continue
        proto = 'HmIP-Wired' if dev_type.startswith('HmIPW-') else 'HmIP-RF'
        devices.append({'type': display_name(dev_type), 'key': dev_type, 'proto': proto,
                        'oem': oem_of(dev_type, None if None in info['oems'] else ', '.join(sorted(info['oems']))), 'webui': dev_type.lower() in webui,
                        'desc': describe(dev_type, info['desc']), 'aka': []})
    for device in devices:
        device['aka'] = sorted(variants.get(device.get('key'), []))
        device['img'] = images.get(webui_type(device.get('key', device['type'])))
        device['fw'] = firmware.get(fw_key(device.get('key', device['type'])))

    known = {d['type'].lower() for d in devices} | {k.lower() for k in list(rf) + list(wired) + list(hmip)}
    unsupported = []
    for dev_type in devlist:
        if dev_type.lower() in known or WEBUI_VIRTUAL.match(dev_type):
            continue
        key = devdescr.get(dev_type)
        unsupported.append({'type': dev_type, 'proto': guess_proto(dev_type), 'img': images.get(dev_type),
                            'desc': tuple(langs[lang].get(key) or dev_type for lang in ('de', 'en'))})
    return devices, unsupported, version


def esc(text):
    return text.replace('|', '\\|')


def guess_proto(dev_type):
    if dev_type.startswith('HmIPW-'):
        return 'HmIP-Wired'
    if dev_type.lower().startswith(('hmip-', 'elv-sh-')):
        return 'HmIP-RF'
    return 'BidCos-Wired' if dev_type.startswith('HMW-') else 'BidCos-RF'


def table(rows, t, lang, base_rev, proto=True, firmware=True):
    idx = 0 if lang == 'de' else 1
    head = [t['img'], t['type'], t['desc']] + ([t['proto']] if proto else []) + ([t['fw']] if firmware else [])
    lines = ['| ' + ' | '.join(head) + ' |', '| ' + ' | '.join('---' for _ in head) + ' |']
    raw = BASE_RAW.format(rev=base_rev)
    # devices with a Homematic type name first, partner/OEM designations last
    for d in sorted(rows, key=lambda r: (not OFFICIAL_TYPES.match(r['type']), r['type'].lower())):
        desc = d['desc'][idx]
        if d.get('oem'):
            desc += f" ({t['oem']}: {d['oem']})"
        if d.get('aka'):
            desc += f" ({t['aka']} " + ', '.join(f'`{a}`' for a in d['aka']) + ')'
        img = ''
        if d.get('img'):
            thumb, large = d['img']
            img = f'<a href="{raw}{large}"><img src="{raw}{thumb}" width="50" alt="{html.escape(d["type"])}"></a>'
        name = f"`{esc(d['type'])}`"
        if OFFICIAL_TYPES.match(d['type']):
            name = f"[{name}]({SHOP_SEARCH.format(urllib.parse.quote(d['type']))})"
        cells = [img, name, esc(desc)] + ([d['proto']] if proto else [])
        if firmware:
            fw = d.get('fw')
            cells.append(f"[{fw['version']}]({FW_CHANGELOG.format(stem=fw['stem'])})" if fw else '–')
        lines.append('| ' + ' | '.join(cells) + ' |')
    return lines


SECTION_IDS = {'HmIP-RF': 'hmip-rf', 'HmIP-Wired': 'hmip-wired', 'BidCos-RF': 'bidcos-rf',
               'BidCos-Wired': 'bidcos-wired', 'oem': 'partner-oem', 'limited': 'limited',
               'unsupported': 'unsupported'}


def section(title, rows, t, opened, anchor, **kwargs):
    attr = ' open' if opened else ''
    return ([f'<a name="{anchor}"></a>', '',
             f"<details{attr}><summary><b>{title}</b> – {len(rows)} {t['count']}</summary>", '']
            + table(rows, t, **kwargs) + ['', '</details>', ''])


# output file names per language: (wiki page, plain markdown file); links use the
# name without the .md suffix in the wiki
PAGES = {'de': ('Unterstützte-Geräte', 'supported-devices.de.md'),
         'en': ('en.Supported-Devices', 'supported-devices.md')}


def render(lang, devices, unsupported, base_rev, version, fw_rev, occu_version, wiki):
    t = TEXT[lang]
    has_fw = fw_rev is not None
    official = [d for d in devices if d['webui'] and OFFICIAL_TYPES.match(d['type'])]
    partner = [d for d in devices if d['webui'] and not OFFICIAL_TYPES.match(d['type'])]
    limited = [d for d in devices if not d['webui']]
    args = {'lang': lang, 'base_rev': base_rev, 'firmware': has_fw}
    sections = [(proto, t['sec'][proto], [d for d in official if d['proto'] == proto], True,
                 dict(args, proto=False)) for proto in PROTO_ORDER]
    sections += [('oem', t['oem_h'], partner, False, args),
                 ('limited', t['limited_h'], limited, False, args),
                 ('unsupported', t['unsupported_h'], unsupported, False, dict(args, firmware=False))]

    base = f"[OpenCCU-Base](https://github.com/OpenCCU/OpenCCU-Base/tree/{base_rev}) `{base_rev[:12]}`"
    fw = f" · [HMDeviceFirmware]({FW_REPO}/tree/{fw_rev}) `{fw_rev[:12]}`" if has_fw else ''
    basis = t['basis_top'].format(occu=occu_version, base=base, hmip=f'`{version}`', fw=fw,
                                  date=datetime.date.today().isoformat())
    other = PAGES['en' if lang == 'de' else 'de'][0 if wiki else 1]
    out = [f"# {t['title']}", '', t['other'].format(other=other), '',
           t['intro'].format(count=len(devices), occu=occu_version), '',
           f"**{t['toc']}:**", '']
    out += [f"- [{title}](#{SECTION_IDS[key]}) – {len(rows)}" for key, title, rows, _, _ in sections]
    out += ['', f"**{t['basis']}:** {basis}", '']
    for key, title, rows, opened, kwargs in sections:
        out += section(title, rows, t, opened, SECTION_IDS[key], **kwargs)

    notes = [n for n in t['notes'] if has_fw or '{fwpages}' not in n]
    out += [f"## {t['notes_h']}", '']
    out += [f'- {notes[0]}'] + [f'  - {s.format(jar=JAR)}' for s in t['src']]
    out += [f'- {n.format(fwpages=FW_PAGES, occu=occu_version)}' for n in notes[1:]] + ['']
    out += [f"**{t['regen']}:** `scripts/generate-supported-devices.py --base <OpenCCU-Base> "
            f"--firmware <HMDeviceFirmware> --wiki <OpenCCU.wiki>` ({t['repo']})", '']
    return '\n'.join(out)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--base', required=True, type=Path, help='path to an OpenCCU-Base checkout')
    parser.add_argument('--firmware', type=Path, help='path to an OpenCCU/HMDeviceFirmware checkout')
    parser.add_argument('--openccu-version', help='OpenCCU version for firmware compatibility '
                        '(default: OPENCCU_BASE_COMPAT_VERSION from openccu-base.mk)')
    target = parser.add_mutually_exclusive_group(required=True)
    target.add_argument('--wiki', type=Path, help='write the wiki pages into this OpenCCU wiki checkout')
    target.add_argument('--out-dir', type=Path, help='write supported-devices[.de].md into this directory')
    args = parser.parse_args()
    occu_version = args.openccu_version or re.search(
        r'^OPENCCU_BASE_COMPAT_VERSION *= *(\S+)', BASE_MK.read_text(), re.M).group(1)
    firmware = load_firmware(args.firmware, occu_version) if args.firmware else {}
    fw_rev = git_rev(args.firmware) if args.firmware else None
    devices, unsupported, version = collect(args.base, firmware)
    base_rev = git_rev(args.base)
    for lang, (page, name) in PAGES.items():
        path = args.wiki / f'{page}.md' if args.wiki else args.out_dir / name
        text = render(lang, devices, unsupported, base_rev, version, fw_rev, occu_version, bool(args.wiki))
        path.write_text(text, encoding='utf-8')
        print(f'wrote {path}')


if __name__ == '__main__':
    main()
