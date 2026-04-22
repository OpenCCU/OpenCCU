<img height="60px" src="release/logo.png" align="left">
<br/>

### Die flexible, cloudfreie Homematic IP® CCU-Smart-Home-Lösung

[![Current Release](https://img.shields.io/github/release/OpenCCU/OpenCCU.svg)](https://github.com/OpenCCU/OpenCCU/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/OpenCCU/OpenCCU/latest/total.svg)](https://github.com/OpenCCU/OpenCCU/releases/latest)
[![DownloadsSnapshots](https://img.shields.io/github/downloads/OpenCCU/OpenCCU/snapshots/total.svg)](https://github.com/OpenCCU/OpenCCU/releases/snapshots)
[![CI Build](https://github.com/OpenCCU/OpenCCU/workflows/CI%20Build/badge.svg)](https://github.com/OpenCCU/OpenCCU/actions)
[![Snapshot Build](https://github.com/OpenCCU/OpenCCU/workflows/Snapshot%20Build/badge.svg)](https://github.com/OpenCCU/OpenCCU/releases/tag/snapshots)
[![Contributors](https://img.shields.io/github/contributors/OpenCCU/OpenCCU.svg)](https://github.com/OpenCCU/OpenCCU/graphs/contributors)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/OpenCCU/OpenCCU.svg)](https://github.com/OpenCCU/OpenCCU/issues)
[![Percentage of issues still open](http://isitmaintained.com/badge/open/OpenCCU/OpenCCU.svg)](https://github.com/OpenCCU/OpenCCU/issues)
[![Commits since last release](https://img.shields.io/github/commits-since/OpenCCU/OpenCCU/latest.svg)](https://github.com/OpenCCU/OpenCCU/releases/latest)
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/openccu)](https://artifacthub.io/packages/search?repo=openccu)
[![License](https://img.shields.io/github/license/OpenCCU/OpenCCU.svg)](https://github.com/OpenCCU/OpenCCU/blob/master/LICENSE)
[![Donate](https://img.shields.io/badge/donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RAQSDY9YNZVCL)
[![GitHub sponsors](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&link=https://github.com/sponsors/OpenCCU)](https://github.com/sponsors/OpenCCU)
[![GitHub stars](https://img.shields.io/github/stars/OpenCCU/OpenCCU.svg?style=social&label=Star)](https://github.com/OpenCCU/OpenCCU/stargazers/)

<sub>[Click here for 🇬🇧🇺🇸 english readme](README.md)</sub>
___

OpenCCU ist ein freies, nicht-kommerzielles Open-Source-Betriebssystem für einen **cloudfreien Smart-Home-Hub**, der mit eQ-3s [Homematic IP](https://www.homematic-ip.com/) / [HomeMatic](http://homematic.com/)-Geräten kompatibel ist. Ziel ist die **100%ige Kompatibilität** zur herstellerseitigen _CCU3_. OpenCCU kann direkt auf [CCU3](https://homematic-ip.com/en/product/smart-home-ccu3-central-control-unit)- und [ELV Charly](https://www.elv.de/elv-smart-home-zentrale-charly-starter-set-bausatz.html)-Hardware installiert werden. Zudem läuft es auf gängigen SBCs (z. B. [Raspberry Pi](https://www.raspberrypi.org/), [Hardkernel ODROID](https://www.hardkernel.com/product-category/odroid-board/), [ASUS Tinker Board](https://www.asus.com/Single-Board-Computer/Tinker-Board-S/)) sowie auf generischer x86-Hardware wie [Intel NUC](https://www.intel.com/content/www/us/en/products/details/nuc.html). Darüber hinaus ist OpenCCU als virtuelle Appliance für verbreitete Hypervisor- und Container-Plattformen verfügbar (z. B. Proxmox VE, VMware ESXi, VirtualBox, Synology VMM, Docker/OCI, Kubernetes) und als natives [Home Assistant](https://www.home-assistant.io/)-Add-on. Über die CCU3-Parität hinaus bietet OpenCCU **moderne WebUI-, OS- und Konnektivitäts-Erweiterungen** für ein fortschrittlicheres Nutzererlebnis.

[mehr...](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung)

## :cookie: Funktionen

- **Drop-in-Kompatibilität.** Unterstützt dieselbe Homematic-/Homematic-IP-Hardware, WebUI-Funktionen und Add-on-Ökosystem wie die Hersteller-Firmware der CCU.
- **Austauschbare Backups.** Sicherungen sind zwischen Hersteller-Firmware und OpenCCU **kompatibel**, was die Migration erheblich vereinfacht.
- **Verbesserungen gegenüber der Hersteller-Firmware.** Umfasst WebUI-Verbesserungen, Linux-OS-Updates, Stabilitäts-/Performance-Fixes und neue Funktionen, die upstream noch nicht oder ggf. nie vorhanden sind.

[mehr...](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#features)

## :computer: Systemvoraussetzungen

OpenCCU kann auf Hersteller-CCU-Hardware, gängigen SBCs und x86-Systemen installiert oder virtuell betrieben werden:

**Hardware**
- [CCU3](https://homematic-ip.com/en/product/smart-home-ccu3-central-control-unit), [ELV Charly](https://www.elv.de/elv-smart-home-zentrale-charly-starter-set-bausatz.html)
- [Raspberry Pi](https://www.raspberrypi.org/)
- [ASUS Tinker Board](https://www.asus.com/Single-Board-Computer/Tinker-Board-S/)
- [Hardkernel ODROID](https://www.hardkernel.com/product-category/odroid-board/)
- [Intel NUC](https://www.intel.de/content/www/de/de/products/boards-kits/nuc.html)

**Virtualisierung & Container**
- [Proxmox VE](https://www.proxmox.com/en/proxmox-ve), [QEMU/KVM](https://www.qemu.org/), [XCP-ng/XenServer](https://xcp-ng.org/), [VMware ESXi](https://www.vmware.com/de/products/esxi-and-esx.html) / [Workstation Player](https://www.vmware.com/de/products/workstation-player/workstation-player-evaluation.html), [Hyper-V](https://learn.microsoft.com/de-de/virtualization/hyper-v-on-windows/), [VirtualBox](https://www.virtualbox.org/)
- [Synology Virtual Machine Manager](https://www.synology.com/de-de/dsm/feature/virtual_machine_manager), [QNAP Virtualization Station](https://www.qnap.com/event/station/de-de/virtualization.php), [Unraid](https://unraid.net/)
- [Docker/OCI](https://www.docker.com/), [LXC](https://linuxcontainers.org/), [Kubernetes (K8s)](https://kubernetes.io/)
- [Home Assistant](https://home-assistant.io/) (Add-on)

[mehr...](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#vorraussetzungen)

## :cloud: Schnellstart

1) **Download**
   - Lade das passende Image unter **[Releases](https://github.com/OpenCCU/OpenCCU/releases)**.
   - Dateinamensmuster: `OpenCCU-X.XX.XX.YYYYMMDD-<TARGET>.zip`.

2) **Installation (eine Option wählen)**
   - **Eigene Hardware (z. B. Raspberry Pi):** Zip entpacken und die `*.img` auf eine microSD-Karte flashen (z. B. mit [Etcher](https://etcher.io) oder `dd`).
   - **Migration von CCU2/CCU3:** Das OpenCCU-Paket wie ein reguläres Firmware-Update hochladen.
   - **Virtualisierte Umgebung:** Der Installationsanleitung für die jeweilige Hypervisor-/Container-Plattform folgen.

3) **Boot**
   - Gerät/VM starten. Beim ersten Start erkennt OpenCCU verfügbare **Homematic / Homematic IP**-RF-Module (z. B. `RPI-RF-MOD`, `HmIP-RFUSB`) an GPIO oder USB.

4) **WebUI aufrufen**
   - `http://openccu/` im Browser öffnen (oder die per DHCP vergebene IP verwenden, falls keine Namensauflösung verfügbar ist).
   - Es erscheint die gewohnte CCU-WebUI; nun können Homematic-/Homematic-IP-Geräte konfiguriert werden.
   - *Optional:* Bestehendes CCU-Backup einspielen, um die Konfiguration zu übernehmen.

[mehr...](https://github.com/OpenCCU/OpenCCU/wiki/Installation#schnellstart)

## :memo: Dokumentation ([🇩🇪](https://github.com/OpenCCU/OpenCCU/wiki/Home)/[🇺🇸](https://github.com/OpenCCU/OpenCCU/wiki/en.Home))

1. [Einleitung](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung)
   * [Voraussetzungen](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#vorraussetzungen)
   * [Funktionen](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#features)
   * [Einschränkungen](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#limitationeneinschränkungen)
   * [Lizenz & Haftung](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#lizenz--haftung)
   * [Kommerzieller Vertrieb](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#kommerzieller-vertrieb)
2. [Installation](https://github.com/OpenCCU/OpenCCU/wiki/Installation)
   * [Schnellstart](https://github.com/OpenCCU/OpenCCU/wiki/Installation#schnellstart)
   * [Grundinstallation (Hardware)](https://github.com/OpenCCU/OpenCCU/wiki/Installation#grundinstallation-hardware)
     * [CCU3](https://github.com/OpenCCU/OpenCCU/wiki/Installation-CCU3)
     * [ELV-Charly](https://github.com/OpenCCU/OpenCCU/wiki/Installation-ELV-Charly)
     * [RaspberryPi](https://github.com/OpenCCU/OpenCCU/wiki/Installation-RaspberryPi)
     * [ASUS Tinkerboard](https://github.com/OpenCCU/OpenCCU/wiki/Installation-Tinkerboard)
     * [Hardkernel ODROID](https://github.com/OpenCCU/OpenCCU/wiki/Installation-ODROID)
     * [Intel NUC](https://github.com/OpenCCU/OpenCCU/wiki/Installation-IntelNUC)
   * [Grundinstallation (Virtuell)](https://github.com/OpenCCU/OpenCCU/wiki/Installation#grundinstallation-virtuell)
     * [Proxmox Virtual Environment](https://github.com/OpenCCU/OpenCCU/wiki/Installation-Proxmox-VE)
     * [Home-Assistant-Add-on](https://github.com/OpenCCU/OpenCCU/wiki/Installation-HomeAssistant)
     * [Docker-Container (OCI)](https://github.com/OpenCCU/OpenCCU/wiki/Installation-Docker-OCI)
     * [Linux-Container (LXC)](https://github.com/OpenCCU/OpenCCU/wiki/Installation-LXC)
     * [QEmu/KVM](https://github.com/OpenCCU/OpenCCU/wiki/Installation-QEmu)
     * [Kubernetes/K8s](https://github.com/OpenCCU/OpenCCU/wiki/Installation-Kubernetes)
     * [Synology Virtual Machine Manager](https://github.com/OpenCCU/OpenCCU/wiki/Installation-Synology-VMM)
     * [QNAP VirtualizationStation](https://github.com/OpenCCU/OpenCCU/wiki/Installation-QNAP-VirtualizationStation)
     * [UNRAID](https://github.com/OpenCCU/OpenCCU/wiki/Installation-UNRAID)
     * [XCP-ng/XenServer](https://github.com/OpenCCU/OpenCCU/wiki/Installation-XCPng)
     * [Oracle VirtualBox](https://github.com/OpenCCU/OpenCCU/wiki/Installation-VirtualBox)
     * [vmWare Workstation Player](https://github.com/OpenCCU/OpenCCU/wiki/Installation-vmWare-Workstation-Player)
     * [vmWare ESXi](https://github.com/OpenCCU/OpenCCU/wiki/Installation-vmWare-ESXi)
     * [HyperV](https://github.com/OpenCCU/OpenCCU/wiki/Installation-HyperV)
   * [Konfigurationsübernahme](https://github.com/OpenCCU/OpenCCU/wiki/Installation#konfigurationsübernahme)
     * [Umstieg von CCU3](https://github.com/OpenCCU/OpenCCU/wiki/Installation#umstieg-von-ccu3)
     * [Umstieg von CCU2](https://github.com/OpenCCU/OpenCCU/wiki/Installation#umstieg-von-ccu2)
     * [Umstieg von CCU1](https://github.com/OpenCCU/OpenCCU/wiki/Installation#umstieg-von-ccu1)
     * [Umstieg auf virtuelle OpenCCU](https://github.com/OpenCCU/OpenCCU/wiki/Installation#umstieg-zu-virtuellem-raspberrymatic)
   * [Deinstallation](https://github.com/OpenCCU/OpenCCU/wiki/Deinstallation)
3. [Administration](https://github.com/OpenCCU/OpenCCU/wiki/Administration)
   * [Firmware-Update/-Upgrade](https://github.com/OpenCCU/OpenCCU/wiki/Administration#firmware-updateupgrade)
    * [Backup/Restore](https://github.com/OpenCCU/OpenCCU/wiki/Administration#backup--restore)
   * [Sicherheitshinweise](https://github.com/OpenCCU/OpenCCU/wiki/Administration#sicherheitshinweise)
   * [CCU-Add-ons / Zusatzsoftware](https://github.com/OpenCCU/OpenCCU/wiki/Administration#ccu-addons--zusatzsoftware)
4. Nutzung
   * [WebUI-Benutzung](https://github.com/OpenCCU/OpenCCU/wiki/WebUI-Benutzung)
     * [Log-Daten und Log-Level](https://github.com/OpenCCU/OpenCCU/wiki/WebUI-Benutzung#log-daten-und-log-level)
   * [Tipps & Tricks](https://github.com/OpenCCU/OpenCCU/wiki/Tipps)
   * [Experten-Features](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features)
     * [WLAN/WiFi-Nutzung](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#wlanwifi-nutzung)
     * [Bluetooth-Nutzung](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#bluetooth-nutzung)
     * [LAN-Gateway-Betrieb](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#lan-gateway-betrieb)
     * [USV-Client/Server-Nutzung](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#usv-clientserver-nut)
     * [USB-Boot](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#usb-boot)
     * [Monit-Watchdog-Weboberfläche](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#monit-watchdog-weboberfl%C3%A4che)
     * [HB-RF-ETH-Anbindung](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#hb-rf-eth-anbindung)
     * [Individueller Diagramm-/Backup-Speicherpfad](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#individueller-diagrammbackup-speicherpfad)
     * [Eigene Aktionen während des Bootvorgangs](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#eigene-aktionen-während-des-bootvorgangs)
5. [Support, Beiträge](https://github.com/OpenCCU/OpenCCU/wiki/Support)
   * [Bekannte Probleme](https://github.com/OpenCCU/OpenCCU/wiki/Support#bekannte-probleme)
   * [Hilfe suchen](https://github.com/OpenCCU/OpenCCU/wiki/Support#hilfe-suchen)
   * [FAQ – Häufige Fragen](https://github.com/OpenCCU/OpenCCU/wiki/Support#faq)
   * [Fehler melden](https://github.com/OpenCCU/OpenCCU/wiki/Support#bugreports)
   * [Funktionen anfragen](https://github.com/OpenCCU/OpenCCU/wiki/Support#featurerequests)
   * [Mitarbeit & Weiterentwicklung](https://github.com/OpenCCU/OpenCCU/wiki/Support#mitarbeit--weiterentwicklung)

## :yum: Support & Beiträge

**Wo diskutieren / fragen**
- Für allgemeine Fragen und Feedback **[GitHub Discussions](https://github.com/OpenCCU/OpenCCU/discussions)** nutzen.
- Deutschsprachige Nutzer: der OpenCCU-Bereich im **[HomeMatic-Forum](https://homematic-forum.de/forum/viewforum.php?f=65)**.

**Wann ein Issue eröffnen**
- Wenn eine Diskussion einen **klaren Feature-Wunsch** oder einen **reproduzierbaren Fehler** bestätigt, ein Issue unter **[Issues](https://github.com/OpenCCU/OpenCCU/issues)** anlegen.
- Bitte vorher nach bestehenden Issues suchen und angeben: OpenCCU-Version, Zielhardware/Hypervisor, Schritte zur Reproduktion, erwartetes vs. tatsächliches Verhalten, relevante Logs.

**Möglichkeiten zur Mitarbeit**
- Releases testen und bei der **Reproduktion/Triage** von [offenen Issues](https://github.com/OpenCCU/OpenCCU/issues) helfen.
- Die wiki-basierte **[Dokumentation](https://github.com/OpenCCU/OpenCCU/wiki)** verbessern.
- **[Pull Requests prüfen](https://github.com/OpenCCU/OpenCCU/pulls)** und Feedback geben.
- **Code-Beiträge** (Bugfixes, Features) per Pull Request einreichen.

**Pull Requests**
- PRs fokussiert halten (ein Thema pro PR), das zugehörige Issue/die Diskussion verlinken und die Vorgaben in **[CONTRIBUTING](CONTRIBUTING.md)** beachten.
- Mit dem Beitrag stimmst du der Lizenzierung unter **Apache-2.0** zu.

**Community-Standards**
- Bitte **[CODE OF CONDUCT](CODE_OF_CONDUCT.md)** lesen und befolgen.

[mehr...](https://github.com/OpenCCU/OpenCCU/wiki/Support)

## :scroll: Lizenzen

- **Projekt & Release-Images.** Das OpenCCU-Projekt (dieses Repository) und die unter **[Releases](https://github.com/OpenCCU/OpenCCU/releases)** bereitgestellten Images stehen – sofern nicht anders angegeben – unter der **[Apache License 2.0](https://opensource.org/licenses/Apache-2.0)**. OpenCCU wird kostenlos und ohne kommerzielle Absichten bereitgestellt.

- **Drittkomponenten.** Einige enthaltene Komponenten haben andere Lizenzen und verbleiben unter deren Bedingungen. Beispiel: **Buildroot/Linux** steht unter **[GPLv2](http://www.gnu.org/licenses/gpl-2.0.html)**, was beim Ändern von Quelltexten oder beim Weiterverteilen abgeleiteter Images relevant sein kann. Die für die Konnektivität genutzten **[eQ-3 OCCU](https://github.com/eq-3/occu)**-Komponenten werden unter den Bedingungen der **[HMSL](https://github.com/eq-3/occu/blob/master/LicenseEN.txt)** weitergegeben.

- **Branding & Artwork.** Das OpenCCU-Logo und weitere Grafiken in diesem Repository und in den Images unterliegen dem Urheberrecht der jeweiligen Autoren. Jede kommerzielle oder nicht-kommerzielle Wiederverwendung – insbesondere in weiterverteilten Binaries oder Forks – ist **ohne vorherige schriftliche Genehmigung untersagt**.

### Haftungsausschluss

Sofern nicht gesetzlich vorgeschrieben oder schriftlich vereinbart, wird OpenCCU von den Beitragenden (und jeder Beitragende stellt seine Beiträge) **„WIE BESEHEN“** bereitgestellt, **OHNE JEGLICHE GEWÄHRLEISTUNGEN ODER BEDINGUNGEN**, weder ausdrücklich noch stillschweigend, einschließlich unter anderem **Eigentum, Nichtverletzung von Rechten Dritter, Marktgängigkeit** oder **Eignung für einen bestimmten Zweck**. Du bist allein dafür verantwortlich zu beurteilen, ob die Nutzung oder Weitergabe von OpenCCU für dich geeignet ist, und trägst alle Risiken, die sich aus der Ausübung der unter dieser Lizenz gewährten Rechte ergeben.

[mehr...](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#lizenz--haftung)

## :book: Literatur

Wenn nach der Lektüre dieser Dokumentation noch Unklarheit über Vor- und Nachteile von OpenCCU gegenüber der herstellerseitigen CCU-Firmware besteht – oder wenn du die zusätzlichen Funktionen von OpenCCU vertieft kennenlernen möchtest – verweisen wir auf folgende (überwiegend deutschsprachige) Ressourcen:

<a href="https://www.youtube.com/watch?v=regDw7rcIb0"><img alt="Usertreffen Kassel 2019 – OpenCCU" src="https://img.youtube.com/vi/regDw7rcIb0/hqdefault.jpg" width="320"></a>
<a href="https://www.youtube.com/watch?v=hSmDcrkHb7M"><img alt="Usertreffen Kassel 2018 – OpenCCU" src="https://img.youtube.com/vi/hSmDcrkHb7M/hqdefault.jpg" width="320"></a>

* [Vortragsfolien HomeMatic-Usertreffen 2019](https://homematic-forum.de/forum/download/file.php?id=59500)
* [Vortragsfolien HomeMatic-Usertreffen 2018](https://homematic-forum.de/forum/download/file.php?id=48428)
* [Vortragsfolien HomeMatic-Usertreffen 2017](https://homematic-forum.de/forum/download/file.php?id=40869)
* [Vortragsfolien HomeMatic-Usertreffen 2016](https://homematic-forum.de/forum/download/file.php?id=40868)

## :clap: Danksagungen

Zusätzlich zu allen **[Contributors](https://github.com/OpenCCU/OpenCCU/graphs/contributors)**, die OpenCCU möglich gemacht haben, danken wir besonders:

- **Alexander Reinert (@alexreinert)** — für das latenzarme
  **[generic_raw_uart-Kernelmodul](https://github.com/alexreinert/piVCCU/tree/master/kernel)** zur Anbindung von eQ-3-RF-Modulen
  (RPI-RF-MOD, HM-MOD-RPI-PCB, HmIP-RFUSB) sowie für die Open-Hardware-Adapterplatinen
  **[HB-RF-USB](https://github.com/alexreinert/PCB/tree/master/HB-RF-USB)**,
  **[HB-RF-USB-2](https://github.com/alexreinert/PCB/tree/master/HB-RF-USB-2)** und
  **[HB-RF-ETH](https://github.com/alexreinert/PCB/tree/master/HB-RF-ETH)**, die USB-/Ethernet-Schnittstellen für diese Module bereitstellen.
  
## :family: Autoren

OpenCCU wird von einer breiten Community entwickelt. Die vollständige und aktuelle Liste der Autoren und Mitwirkenden findet sich unter **[Contributors](https://github.com/OpenCCU/OpenCCU/graphs/contributors)**.

## :construction: Changelog

Eine detaillierte, versionsbezogene Liste der Änderungen findet sich unter **[Releases](https://github.com/OpenCCU/OpenCCU/releases/)** in diesem Repository. Jeder Release enthält Hinweise zu neuen Funktionen, Fehlerbehebungen und weiteren Anpassungen.

