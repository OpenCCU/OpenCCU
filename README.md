<img height="60px" src="release/logo.png" align="left">
<br/>

### Your flexible, cloud-free Homematic IP® CCU smart-home solution

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
[![GitHub sponsors](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&link=https://github.com/sponsors/jens-maus)](https://github.com/sponsors/jens-maus)
[![GitHub stars](https://img.shields.io/github/stars/OpenCCU/OpenCCU.svg?style=social&label=Star)](https://github.com/OpenCCU/OpenCCU/stargazers/)

<sub>[Deutschsprachiges 🇩🇪🇦🇹🇨🇭 ReadMe](README.de.md)</sub>
___

OpenCCU is a free, non-commercial, open-source operating system for running a **cloud-free smart-home hub** compatible with eQ-3’s [Homematic IP](https://www.homematic-ip.com/) / [HomeMatic](http://homematic.com/) devices. It targets **100% compatibility** with the vendor’s _CCU3_ and can be installed directly on [CCU3](https://homematic-ip.com/en/product/smart-home-ccu3-central-control-unit) and [ELV Charly](https://www.elv.de/elv-smart-home-zentrale-charly-starter-set-bausatz.html) hardware. It also runs on common SBCs (e.g., [Raspberry Pi](https://www.raspberrypi.org/), [Hardkernel ODROID](https://www.hardkernel.com/product-category/odroid-board/), [ASUS Tinker Board](https://www.asus.com/Single-Board-Computer/Tinker-Board-S/)) and generic x86 hardware such as [Intel NUC](https://www.intel.com/content/www/us/en/products/details/nuc.html). In addition, OpenCCU is available as a virtual appliance for popular hypervisors and container platforms (e.g., Proxmox VE, VMware ESXi, VirtualBox, Synology VMM, Docker/OCI, Kubernetes) and as a native [Home Assistant](https://www.home-assistant.io/) add-on. Beyond CCU3 parity, it provides **modern WebUI, OS-level, and connectivity enhancements** for a more advanced user experience.

[more...](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung)

## :cookie: Features

- **Drop-in compatibility.** Works with the same Homematic / Homematic IP hardware, WebUI features, and add-on ecosystem as the vendor CCU firmware.
- **Backup interchangeability.** Backups are cross-compatible, enabling straightforward migration between the vendor CCU firmware and OpenCCU.
- **Enhancements beyond vendor firmware.** Includes WebUI improvements, Linux OS updates, stability and performance fixes, and new capabilities that do not yet exist upstream.

[more...](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#features)

## :computer: Requirements

OpenCCU can be installed on vendor CCU hardware, common SBCs, and x86 systems—or deployed virtually:

**Hardware**
- [CCU3](https://homematic-ip.com/en/product/smart-home-ccu3-central-control-unit), [ELV Charly](https://www.elv.de/elv-smart-home-zentrale-charly-starter-set-bausatz.html)
- [Raspberry Pi](https://www.raspberrypi.org/)
- [ASUS Tinker Board](https://www.asus.com/Single-Board-Computer/Tinker-Board-S/)
- [Hardkernel ODROID](https://www.hardkernel.com/product-category/odroid-board/)
- [Intel NUC](https://www.intel.de/content/www/de/de/products/boards-kits/nuc.html)

**Virtualization & Containers**
- [Proxmox VE](https://www.proxmox.com/en/proxmox-ve), [QEMU/KVM](https://www.qemu.org/), [XCP-ng/XenServer](https://xcp-ng.org/), [VMware ESXi](https://www.vmware.com/de/products/esxi-and-esx.html) / [Workstation Player](https://www.vmware.com/de/products/workstation-player/workstation-player-evaluation.html), [Hyper-V](https://learn.microsoft.com/de-de/virtualization/hyper-v-on-windows/), [VirtualBox](https://www.virtualbox.org/)
- [Synology Virtual Machine Manager](https://www.synology.com/de-de/dsm/feature/virtual_machine_manager), [QNAP Virtualization Station](https://www.qnap.com/event/station/de-de/virtualization.php), [Unraid](https://unraid.net/)
- [Docker/OCI](https://www.docker.com/), [LXC](https://linuxcontainers.org/), [Kubernetes (K8s)](https://kubernetes.io/)
- [Home Assistant](https://home-assistant.io/) (add-on)

[more...](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#vorraussetzungen)

## :cloud: Quick-Start

1) **Download**
   - Get the image for your target under **[Releases](https://github.com/OpenCCU/OpenCCU/releases)**.
   - Filename pattern: `OpenCCU-X.XX.XX.YYYYMMDD-<TARGET>.zip`.

2) **Install (choose one)**
   - **Own hardware (e.g., Raspberry Pi):** unzip and flash the `*.img` to a microSD card (e.g., with [Etcher](https://etcher.io) or `dd`).
   - **Migrate from CCU2/CCU3:** upload the OpenCCU package as a regular firmware update.
   - **Virtualized environment:** follow the installation procedure for your hypervisor/container platform.

3) **Boot**
   - Start the device/VM. On first boot, OpenCCU detects available **Homematic / Homematic IP** RF modules (e.g., `RPI-RF-MOD`, `HmIP-RFUSB`) on GPIO or USB.

4) **Access the WebUI**
   - Open `http://openccu/` in your browser (or use the device’s DHCP-assigned IP if name resolution is unavailable).
   - You will land in the familiar CCU WebUI and can start configuring your Homematic / Homematic IP devices.
   - *Optional:* restore an existing CCU backup to migrate your setup.

[more...](https://github.com/OpenCCU/OpenCCU/wiki/Installation#schnellstart)

## :memo: Documentation ([🇩🇪](https://github.com/OpenCCU/OpenCCU/wiki/Home)/[🇺🇸](https://github.com/OpenCCU/OpenCCU/wiki/en.Home))

1. [Introduction](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung)
   * [Requirements](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#vorraussetzungen)
   * [Features](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#features)
   * [Limitations](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#limitationeneinschränkungen)
   * [License and Warranty](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#lizenz--haftung)
   * [Commercial Distribution](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#kommerzieller-vertrieb)
2. [Installation](https://github.com/OpenCCU/OpenCCU/wiki/Installation)
   * [Quick-Start](https://github.com/OpenCCU/OpenCCU/wiki/Installation#schnellstart)
   * [Basic Installation (Hardware)](https://github.com/OpenCCU/OpenCCU/wiki/Installation#grundinstallation-hardware)
     * [CCU3](https://github.com/OpenCCU/OpenCCU/wiki/Installation-CCU3)
     * [ELV-Charly](https://github.com/OpenCCU/OpenCCU/wiki/Installation-ELV-Charly)
     * [RaspberryPi](https://github.com/OpenCCU/OpenCCU/wiki/Installation-RaspberryPi)
     * [ASUS Tinkerboard](https://github.com/OpenCCU/OpenCCU/wiki/Installation-Tinkerboard)
     * [Hardkernel ODROID](https://github.com/OpenCCU/OpenCCU/wiki/Installation-ODROID)
     * [Intel NUC](https://github.com/OpenCCU/OpenCCU/wiki/Installation-IntelNUC)
   * [Basic Installation (Virtual)](https://github.com/OpenCCU/OpenCCU/wiki/Installation#grundinstallation-virtuell)
     * [Proxmox Virtual Environment](https://github.com/OpenCCU/OpenCCU/wiki/Installation-Proxmox-VE)
     * [Home Assistant Add-on](https://github.com/OpenCCU/OpenCCU/wiki/Installation-HomeAssistant)
     * [Docker Container (OCI)](https://github.com/OpenCCU/OpenCCU/wiki/Installation-Docker-OCI)
     * [Linux Container (LXC)](https://github.com/OpenCCU/OpenCCU/wiki/Installation-LXC)
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
   * [Configuration Upgrade](https://github.com/OpenCCU/OpenCCU/wiki/Installation#konfigurationsübernahme)
     * [Upgrade from CCU3](https://github.com/OpenCCU/OpenCCU/wiki/Installation#umstieg-von-ccu3)
     * [Upgrade from CCU2](https://github.com/OpenCCU/OpenCCU/wiki/Installation#umstieg-von-ccu2)
     * [Upgrade from CCU1](https://github.com/OpenCCU/OpenCCU/wiki/Installation#umstieg-von-ccu1)
     * [Upgrade to virtual OpenCCU](https://github.com/OpenCCU/OpenCCU/wiki/Installation#umstieg-zu-virtuellem-raspberrymatic)
   * [Deinstallation](https://github.com/OpenCCU/OpenCCU/wiki/Deinstallation)
3. [Administration](https://github.com/OpenCCU/OpenCCU/wiki/Administration)
   * [Firmware Update/Upgrade](https://github.com/OpenCCU/OpenCCU/wiki/Administration#firmware-updateupgrade)
   * [Backup/Restore](https://github.com/OpenCCU/OpenCCU/wiki/Administration#backup--restore)
   * [Security Advices](https://github.com/OpenCCU/OpenCCU/wiki/Administration#sicherheitshinweise)
   * [CCU-Addon Software](https://github.com/OpenCCU/OpenCCU/wiki/Administration#ccu-addons--zusatzsoftware)
4. Usage
   * [WebUI Usage](https://github.com/OpenCCU/OpenCCU/wiki/WebUI-Benutzung)
     * [Log-Level setup](https://github.com/OpenCCU/OpenCCU/wiki/WebUI-Benutzung#log-daten-und-log-level)
   * [Tips & Tricks](https://github.com/OpenCCU/OpenCCU/wiki/Tipps)
   * [Expert-Features](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features)
     * [WLAN/WiFi Setup](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#wlanwifi-nutzung)
     * [Bluetooth Setup](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#bluetooth-nutzung)
     * [LAN-Gateway Mode](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#lan-gateway-betrieb)
     * [USV Client/Server Setup](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#usv-clientserver-nut)
     * [USB-Boot Setup](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#usb-boot)
     * [Monit-WatchDog WebUI](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#monit-watchdog-weboberfl%C3%A4che)
     * [HB-RF-ETH Setup](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#hb-rf-eth-anbindung)
     * [Individual Diagramm/Backup-Path](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#individueller-diagrammbackup-speicherpfad)
     * [Own commands during bootup](https://github.com/OpenCCU/OpenCCU/wiki/Experten-Features#eigene-aktionen-während-des-bootvorgangs)
5. [Support, Contributions](https://github.com/OpenCCU/OpenCCU/wiki/Support)
   * [Known Issues](https://github.com/OpenCCU/OpenCCU/wiki/Support#bekannte-probleme)
   * [Request Help](https://github.com/OpenCCU/OpenCCU/wiki/Support#hilfe-suchen)
   * [FAQ – Frequently Asked Questions](https://github.com/OpenCCU/OpenCCU/wiki/Support#faq)
   * [Report Issues](https://github.com/OpenCCU/OpenCCU/wiki/Support#bugreports)
   * [Request Features](https://github.com/OpenCCU/OpenCCU/wiki/Support#featurerequests)
   * [Contributions / Development](https://github.com/OpenCCU/OpenCCU/wiki/Support#mitarbeit--weiterentwicklung)

## :yum: Support & Contributions

**Where to discuss / ask**
- Use **[GitHub Discussions](https://github.com/OpenCCU/OpenCCU/discussions)** for general questions and feedback.
- German-speaking users: the OpenCCU area in the **[HomeMatic-Forum](https://homematic-forum.de/forum/viewforum.php?f=65)**.

**When to open an issue**
- After a discussion confirms a **clear feature request** or a **reproducible bug**, open an issue in **[Issues](https://github.com/OpenCCU/OpenCCU/issues)**.
- Please search for existing issues first and include: OpenCCU version, target/hardware or hypervisor, steps to reproduce, expected vs. actual behavior, and relevant logs.

**Ways to contribute**
- Test releases and help **reproduce/triage** [open issues](https://github.com/OpenCCU/OpenCCU/issues).
- Improve the wiki-based **[documentation](https://github.com/OpenCCU/OpenCCU/wiki)**.
- [Review pull requests](https://github.com/OpenCCU/OpenCCU/pulls) and provide feedback.
- Submit **code contributions** (bug fixes, features) via pull requests.

**Pull requests**
- Keep PRs focused (one topic per PR), link the related issue/discussion, and follow our guidelines in **[CONTRIBUTING](CONTRIBUTING.md)**.
- By contributing, you agree that your work is licensed under the project’s **Apache-2.0** license.

**Community standards**
- Please read and follow our **[CODE OF CONDUCT](CODE_OF_CONDUCT.md)**.

[more...](https://github.com/OpenCCU/OpenCCU/wiki/Support)

## :scroll: Licenses

- **Project & release images.** The OpenCCU project (this repository) and the downloadable images under **[Releases](https://github.com/OpenCCU/OpenCCU/releases)** are provided under the **[Apache License 2.0](https://opensource.org/licenses/Apache-2.0)**, unless stated otherwise. OpenCCU is distributed free of charge and without commercial intent.

- **Third-party components.** Some included components are licensed differently and remain under their respective terms. For example, **Buildroot/Linux** is licensed under **[GPLv2](http://www.gnu.org/licenses/gpl-2.0.html)**, which may have implications when modifying sources or redistributing derived images. The **[eQ-3 OCCU](https://github.com/eq-3/occu)** components used for connectivity are redistributed under the **[HMSL](https://github.com/eq-3/occu/blob/master/LicenseEN.txt)**.

- **Branding & artwork.** The OpenCCU logo and other graphics in this repository and in the downloadable images are copyrighted by their respective authors. Any commercial or non-commercial reuse—especially in redistributed binaries or forks—**is prohibited without prior written permission**.

### Disclaimer of Warranty

Unless required by applicable law or agreed to in writing, OpenCCU is provided by the Contributors (and each Contributor provides its Contributions) on an **"AS IS"** BASIS, **WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND**, either express or implied, including, without limitation, any warranties or conditions of **TITLE, NON-INFRINGEMENT, MERCHANTABILITY,** or **FITNESS FOR A PARTICULAR PURPOSE**. You are solely responsible for determining the appropriateness of using or redistributing OpenCCU and assume any risks associated with Your exercise of permissions under this License.

[more...](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#lizenz--haftung)

## :book: Literature

If, after reading this documentation, you are still unsure about the pros and cons of using OpenCCU compared to the vendor-provided CCU firmware—or if you would like to explore OpenCCU’s additional features in more depth—please refer to the following (mostly German-language) resources:

<a href="https://www.youtube.com/watch?v=regDw7rcIb0"><img alt="Usertreffen Kassel 2019 – OpenCCU" src="https://img.youtube.com/vi/regDw7rcIb0/hqdefault.jpg" width="320"></a>
<a href="https://www.youtube.com/watch?v=hSmDcrkHb7M"><img alt="Usertreffen Kassel 2018 – OpenCCU" src="https://img.youtube.com/vi/hSmDcrkHb7M/hqdefault.jpg" width="320"></a>

* [Vortragsfolien HomeMatic-Usertreffen 2019](https://homematic-forum.de/forum/download/file.php?id=59500)
* [Vortragsfolien HomeMatic-Usertreffen 2018](https://homematic-forum.de/forum/download/file.php?id=48428)
* [Vortragsfolien HomeMatic-Usertreffen 2017](https://homematic-forum.de/forum/download/file.php?id=40869)
* [Vortragsfolien HomeMatic-Usertreffen 2016](https://homematic-forum.de/forum/download/file.php?id=40868)

## :clap: Acknowledgements

In addition to all **[Contributors](https://github.com/OpenCCU/OpenCCU/graphs/contributors)** who helped make OpenCCU possible, we would like to thank:

- **Alexander Reinert (@alexreinert)** — for the low-latency
  **[generic_raw_uart kernel module](https://github.com/alexreinert/piVCCU/tree/master/kernel)** enabling the use of eQ-3 RF modules
  (RPI-RF-MOD, HM-MOD-RPI-PCB, HmIP-RFUSB), and for the open-hardware adapter boards
  **[HB-RF-USB](https://github.com/alexreinert/PCB/tree/master/HB-RF-USB)**,
  **[HB-RF-USB-2](https://github.com/alexreinert/PCB/tree/master/HB-RF-USB-2)**, and
  **[HB-RF-ETH](https://github.com/alexreinert/PCB/tree/master/HB-RF-ETH)** providing USB/Ethernet interfaces for these modules.
  
## :family: Authors

OpenCCU is developed by a broad community. For the complete and up-to-date list of authors and contributors, please see **[Contributors](https://github.com/OpenCCU/OpenCCU/graphs/contributors)**.

## :construction: Changelog

For a detailed, version-by-version list of changes, see **[Releases](https://github.com/OpenCCU/OpenCCU/releases/)** in this repository. Each release includes notes on new features, fixes, and other changes.
