#!/usr/bin/env python3
"""Generate the list of Homematic (BidCos) and Homematic IP devices supported by OpenCCU.

The list is derived from the OpenCCU-Base sources that actually decide whether
a device can be used:

  * BidCos-RF:    src/devicetypes/rftypes/*.xml     (rfd device descriptions)
  * BidCos-Wired: src/devicetypes/hs485types/*.xml  (hs485d device descriptions)
  * HmIP/HmIPW:   opt/HMServer/HMIPServer.jar       (devicespecification/*.xml)
  * WebUI:        www/config/devdescr/DEVDB.tcl and
                  www/webui/js/lang/{de,en}/translate.lang.deviceDescription.js

A device type counts as supported if one of the interface processes knows it.
The WebUI database is used for the descriptions and to flag devices without
dedicated WebUI integration. WebUI entries without any interface process
support are listed separately as not supported.

Usage:
  scripts/generate-supported-devices.py --base ../OpenCCU-Base [--out-dir docs]
"""

import argparse
import datetime
import re
import subprocess
import urllib.parse
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path


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
        'title': 'Von OpenCCU unterstützte Homematic- und Homematic-IP-Geräte',
        'other': '[English version](supported-devices.md)',
        'intro': (
            'Diese Liste enthält alle Homematic (BidCos-RF, BidCos-Wired) und Homematic IP '
            '(HmIP-RF, HmIP-Wired) Gerätetypen, die von der aktuellen OpenCCU unterstützt werden. '
            'Sie soll vor dem Kauf neuer Geräte helfen zu prüfen, ob ein Gerät mit OpenCCU '
            'verwendet werden kann.'),
        'how': (
            'Die Liste wird automatisch aus den OpenCCU-Base Quellen erzeugt. Ein Gerätetyp '
            'gilt als unterstützt, wenn ihn der zuständige Schnittstellenprozess kennt:'),
        'src': [
            '`BidCos-RF`: Gerätebeschreibungen des `rfd` (`src/devicetypes/rftypes/*.xml`)',
            '`BidCos-Wired`: Gerätebeschreibungen des `hs485d` (`src/devicetypes/hs485types/*.xml`)',
            '`HmIP-RF`/`HmIP-Wired`: Gerätespezifikationen im `HMIPServer.jar` (`{jar}`)',
            'Beschreibungen: WebUI-Gerätedatenbank (`DEVDB.tcl`) und WebUI-Übersetzungen',
        ],
        'basis': 'Datenbasis',
        'base': 'OpenCCU-Base Commit',
        'hmip': 'HMIPServer.jar Version',
        'gen': 'erzeugt am',
        'regen': 'Neu erzeugen mit',
        'notes_h': 'Hinweise',
        'notes': [
            'Für Homematic IP wird ein HmIP-fähiges Funkmodul (z.B. RPI-RF-MOD, HM-MOD-RPI-PCB, '
            'HmIP-RFUSB) benötigt, für Homematic IP Wired zusätzlich ein Homematic IP Wired '
            'Access Point (HmIPW-DRAP) und für Homematic Wired (BidCos-Wired/RS485) ein '
            'Homematic Wired LAN Gateway (HMW-LGW-O-DR-GS-EU).',
            'Bei einigen Gerätetypen hängt der Funktionsumfang von der Firmware des Geräts ab. '
            'OpenCCU kann Geräte-Firmware-Updates für viele Geräte direkt einspielen.',
            'Typbezeichnungen mit Ländersuffix (`-UK`, `-CH`, `-PE`, `-IT`) und Varianten '
            '(`-A` = anthrazit, `-2`/`-3` = neuere Hardwarerevision) sind jeweils eigene Einträge.',
            'Geräte in Abschnitt „Eingeschränkte Unterstützung“ werden zwar vom '
            'Schnittstellenprozess erkannt, haben aber keine eigene Integration in die WebUI '
            '(kein Gerätebild, keine Gerätebeschreibung). Sie lassen sich anlernen, die Bedienung '
            'in der WebUI kann jedoch eingeschränkt sein.',
        ],
        'summary': 'Übersicht',
        'proto': 'Protokoll',
        'count': 'Anzahl Gerätetypen',
        'sum': 'Gesamt',
        'type': 'Typ',
        'desc': 'Beschreibung',
        'aka': 'auch als',
        'oem': 'OEM',
        'sec': {
            'HmIP-RF': 'Homematic IP (HmIP-RF)',
            'HmIP-Wired': 'Homematic IP Wired (HmIP-Wired)',
            'BidCos-RF': 'Homematic (BidCos-RF)',
            'BidCos-Wired': 'Homematic Wired (BidCos-Wired, RS485)',
        },
        'limited_h': 'Eingeschränkte Unterstützung (ohne WebUI-Integration)',
        'limited': (
            'Diese Gerätetypen sind in den Schnittstellenprozessen hinterlegt, haben aber '
            'keinen Eintrag in der WebUI-Gerätedatenbank. Vor dem Kauf sollte geprüft werden, '
            'ob der benötigte Funktionsumfang in der WebUI verfügbar ist.'),
        'unsupported_h': 'Nicht unterstützt (nur WebUI-Eintrag vorhanden)',
        'unsupported': (
            'Diese Gerätetypen sind zwar in der WebUI-Gerätedatenbank vorhanden, aber keinem '
            'Schnittstellenprozess als Gerätetyp bekannt und gelten daher nicht als unterstützt '
            '(z.B. abgekündigte Altgeräte oder neue Geräte, deren Unterstützung im HMIPServer '
            'noch fehlt). Sie sollten nicht für eine Neuanschaffung eingeplant werden.'),
    },
    'en': {
        'title': 'Homematic and Homematic IP devices supported by OpenCCU',
        'other': '[Deutsche Version](supported-devices.de.md)',
        'intro': (
            'This list contains all Homematic (BidCos-RF, BidCos-Wired) and Homematic IP '
            '(HmIP-RF, HmIP-Wired) device types supported by the current OpenCCU. Use it to '
            'check whether a device can be used with OpenCCU before buying it.'),
        'how': (
            'The list is generated automatically from the OpenCCU-Base sources. A device type '
            'counts as supported if the responsible interface process knows it:'),
        'src': [
            '`BidCos-RF`: `rfd` device descriptions (`src/devicetypes/rftypes/*.xml`)',
            '`BidCos-Wired`: `hs485d` device descriptions (`src/devicetypes/hs485types/*.xml`)',
            '`HmIP-RF`/`HmIP-Wired`: device specifications in `HMIPServer.jar` (`{jar}`)',
            'Descriptions: WebUI device database (`DEVDB.tcl`) and WebUI translations',
        ],
        'basis': 'Data basis',
        'base': 'OpenCCU-Base commit',
        'hmip': 'HMIPServer.jar version',
        'gen': 'generated on',
        'regen': 'Regenerate with',
        'notes_h': 'Notes',
        'notes': [
            'Homematic IP requires an HmIP capable radio module (e.g. RPI-RF-MOD, HM-MOD-RPI-PCB, '
            'HmIP-RFUSB), Homematic IP Wired additionally requires a Homematic IP Wired Access '
            'Point (HmIPW-DRAP) and Homematic Wired (BidCos-Wired/RS485) requires a Homematic '
            'Wired LAN Gateway (HMW-LGW-O-DR-GS-EU).',
            'For some device types the available functions depend on the device firmware. '
            'OpenCCU can install device firmware updates for many devices directly.',
            'Type names with a country suffix (`-UK`, `-CH`, `-PE`, `-IT`) and variants '
            '(`-A` = anthracite, `-2`/`-3` = newer hardware revision) are listed separately.',
            'Devices in the section "Limited support" are known to the interface process but '
            'have no dedicated WebUI integration (no device image, no device description). They '
            'can be paired, but their handling in the WebUI may be limited.',
        ],
        'summary': 'Summary',
        'proto': 'Protocol',
        'count': 'Device types',
        'sum': 'Total',
        'type': 'Type',
        'desc': 'Description',
        'aka': 'also as',
        'oem': 'OEM',
        'sec': {
            'HmIP-RF': 'Homematic IP (HmIP-RF)',
            'HmIP-Wired': 'Homematic IP Wired (HmIP-Wired)',
            'BidCos-RF': 'Homematic (BidCos-RF)',
            'BidCos-Wired': 'Homematic Wired (BidCos-Wired, RS485)',
        },
        'limited_h': 'Limited support (no WebUI integration)',
        'limited': (
            'These device types are known to the interface processes but have no entry in the '
            'WebUI device database. Check whether the functions you need are available in the '
            'WebUI before buying.'),
        'unsupported_h': 'Not supported (WebUI entry only)',
        'unsupported': (
            'These device types exist in the WebUI device database but are not known as a '
            'device type by any interface process and therefore do not count as supported '
            '(e.g. discontinued legacy devices or new devices whose support is still missing '
            'in the HMIPServer). Do not plan new purchases around them.'),
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
    langs = {}
    for lang in ('de', 'en'):
        text = (base / LANG.format(lang)).read_text(encoding='latin-1')
        langs[lang] = {
            key: clean(urllib.parse.unquote(re.sub(r'<br\s*/?>', ' ', value), encoding='latin-1'))
            for key, value in re.findall(r'^\s*"([^"]+)"\s*:\s*"(.*)",?\s*$', text, re.M)
        }
    return devlist, dict(zip(descr[::2], descr[1::2])), langs


def git_rev(base):
    try:
        return subprocess.run(['git', '-C', str(base), 'rev-parse', '--short=12', 'HEAD'],
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


def collect(base):
    rf = load_bidcos(base, 'rftypes')
    wired = load_bidcos(base, 'hs485types')
    hmip, version = load_hmip(base)
    devlist, devdescr, langs = load_webui(base)
    webui = {t.lower(): t for t in devlist}

    def describe(dev_type, fallback):
        webui_type = dev_type if dev_type in devdescr else webui.get(dev_type.lower())
        key = devdescr.get(webui_type) if webui_type else None
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

    known = {d['type'].lower() for d in devices} | {k.lower() for k in list(rf) + list(wired) + list(hmip)}
    unsupported = []
    for dev_type in devlist:
        if dev_type.lower() in known or WEBUI_VIRTUAL.match(dev_type):
            continue
        key = devdescr.get(dev_type)
        unsupported.append({'type': dev_type, 'proto': guess_proto(dev_type),
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


def table(rows, t, lang):
    idx = 0 if lang == 'de' else 1
    head = [t['type'], t['desc'], t['proto']]
    lines = ['| ' + ' | '.join(head) + ' |', '| ' + ' | '.join('---' for _ in head) + ' |']
    for d in sorted(rows, key=lambda r: r['type'].lower()):
        desc = d['desc'][idx]
        if d.get('oem'):
            desc += f" ({t['oem']}: {d['oem']})"
        if d.get('aka'):
            desc += f" ({t['aka']} " + ', '.join(f'`{a}`' for a in d['aka']) + ')'
        lines.append(f"| `{esc(d['type'])}` | {esc(desc)} | {d['proto']} |")
    return lines


def render(lang, devices, unsupported, base_rev, version):
    t = TEXT[lang]
    full = [d for d in devices if d['webui']]
    limited = [d for d in devices if not d['webui']]
    out = [f"# {t['title']}", '', t['other'], '', t['intro'], '', t['how'], '']
    out += [f'- {s.format(jar=JAR)}' for s in t['src']]
    out += ['', f"**{t['basis']}:** {t['base']} `{base_rev}`, {t['hmip']} `{version}`, "
            f"{t['gen']} {datetime.date.today().isoformat()}.  ",
            f"**{t['regen']}:** `scripts/generate-supported-devices.py --base <OpenCCU-Base>`", '']
    out += [f"## {t['notes_h']}", ''] + [f'- {n}' for n in t['notes']] + ['']
    out += [f"## {t['summary']}", '', f"| {t['proto']} | {t['count']} |", '| --- | ---: |']
    for proto in PROTO_ORDER:
        out.append(f"| [{t['sec'][proto]}](#{anchor(t['sec'][proto])}) | "
                   f"{sum(1 for d in full if d['proto'] == proto)} |")
    out.append(f"| [{t['limited_h']}](#{anchor(t['limited_h'])}) | {len(limited)} |")
    out.append(f"| **{t['sum']}** | **{len(devices)}** |")
    out.append('')
    for proto in PROTO_ORDER:
        out += [f"## {t['sec'][proto]}", ''] + table([d for d in full if d['proto'] == proto], t, lang) + ['']
    out += [f"## {t['limited_h']}", '', t['limited'], ''] + table(limited, t, lang) + ['']
    out += [f"## {t['unsupported_h']}", '', t['unsupported'], '']
    out += table(unsupported, t, lang) + ['']
    return '\n'.join(out)


def anchor(heading):
    slug = heading.strip().lower()
    slug = re.sub(r'[^\w\- ]', '', slug)
    return slug.replace(' ', '-')


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--base', required=True, type=Path, help='path to an OpenCCU-Base checkout')
    parser.add_argument('--out-dir', default=Path(__file__).resolve().parent.parent / 'docs', type=Path)
    args = parser.parse_args()
    devices, unsupported, version = collect(args.base)
    base_rev = git_rev(args.base)
    for lang, name in (('en', 'supported-devices.md'), ('de', 'supported-devices.de.md')):
        (args.out_dir / name).write_text(render(lang, devices, unsupported, base_rev, version), encoding='utf-8')
        print(f'wrote {args.out_dir / name}')


if __name__ == '__main__':
    main()
