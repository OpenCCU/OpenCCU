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
[![GitHub sponsors](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&link=https://github.com/sponsors/OpenCCU)](https://github.com/sponsors/OpenCCU)
[![GitHub stars](https://img.shields.io/github/stars/OpenCCU/OpenCCU.svg?style=social&label=Star)](https://github.com/OpenCCU/OpenCCU/stargazers/)

<sub>[Deutschsprachiges 🇩🇪🇦🇹🇨🇭 ReadMe](README.de.md)</sub>
___

OpenCCU – formerly known as _RaspberryMatic_ – is a free, non-commercial, open-source operating system for running a **cloud-free smart-home hub** compatible with eQ-3’s [Homematic IP](https://www.homematic-ip.com/) and [HomeMatic](http://homematic.com/) devices. It targets **100% compatibility** with the vendor’s _CCU3_ and can be installed directly on [CCU3](https://homematic-ip.com/en/product/smart-home-ccu3-central-control-unit) and [ELV Charly](https://www.elv.de/elv-smart-home-zentrale-charly-starter-set-bausatz.html) hardware. It also runs on common 64-bit capable SBCs (e.g., [Raspberry Pi](https://www.raspberrypi.org/), [Hardkernel ODROID](https://www.hardkernel.com/product-category/odroid-board/), [ASUS Tinkerboard 2/2S](https://tinker-board.asus.com/series/tinker-board-2.html)) and generic x86_64 or aarch64 hardware. In addition, OpenCCU is available as a pure virtual appliance for popular hypervisors and container platforms (e.g., Proxmox VE, VirtualBox, Synology VMM, Docker/OCI, Kubernetes) and as a native [Home Assistant](https://www.home-assistant.io/) App. Beyond CCU3 parity, it provides **WebUI, OS-level, and connectivity enhancements** for a more advanced user experience.

[more...](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction)

## :cookie: Features

- **Drop-in compatibility.** Works with the same Homematic / Homematic IP hardware, WebUI features, and add-on ecosystem as the vendor CCU firmware.
- **Backup interchangeability.** Backups are cross-compatible, enabling straightforward migration between the vendor CCU firmware and OpenCCU.
- **Enhancements beyond vendor firmware.** Includes WebUI improvements, Linux OS updates, stability and performance fixes, and new capabilities that do not yet exist upstream.

[more...](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction#features)

## :computer: Requirements

OpenCCU can be installed on vendor CCU hardware, common 64-bit capable SBCs, and x86_64 / aarch64 systems—or deployed virtually:

**Hardware**
- [CCU3](https://homematic-ip.com/en/product/smart-home-ccu3-central-control-unit), [ELV Charly](https://www.elv.de/elv-smart-home-zentrale-charly-starter-set-bausatz.html)
- [Raspberry Pi](https://www.raspberrypi.org/)
- [Hardkernel ODROID](https://www.hardkernel.com/product-category/odroid-board/)
- [ASUS Tinkerboard 2/2S](https://tinker-board.asus.com/series/tinker-board-2.html)
- Generic x86_64 / aarch64
  
**Virtualization & Containers**
- [Proxmox VE](https://www.proxmox.com/en/proxmox-ve), [QEMU/KVM](https://www.qemu.org/), [XCP-ng/XenServer](https://xcp-ng.org/), [VMware ESXi](https://www.vmware.com/de/products/esxi-and-esx.html) / [Workstation Player](https://www.vmware.com/de/products/workstation-player/workstation-player-evaluation.html), [Hyper-V](https://learn.microsoft.com/de-de/virtualization/hyper-v-on-windows/), [VirtualBox](https://www.virtualbox.org/)
- [Synology Virtual Machine Manager](https://www.synology.com/de-de/dsm/feature/virtual_machine_manager), [QNAP Virtualization Station](https://www.qnap.com/event/station/de-de/virtualization.php), [Unraid](https://unraid.net/)
- [Docker/OCI](https://www.docker.com/), [LXC](https://linuxcontainers.org/), [Kubernetes (K8s)](https://kubernetes.io/)
- [Home Assistant](https://home-assistant.io/) (App)

[more...](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction#requirements)

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

[more...](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#quick-start)

## :memo: Documentation ([🇩🇪](https://github.com/OpenCCU/OpenCCU/wiki/Home)/[🇺🇸](https://github.com/OpenCCU/OpenCCU/wiki/en.Home))

1. [Introduction](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction)
   * [Release Variants](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction#release-variants)
   * [Requirements](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction#requirements)
   * [Supported Devices](https://github.com/OpenCCU/OpenCCU/wiki/en.Supported-Devices)
   * [Features](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction#features)
   * [Limitations](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction#limitations)
   * [License & Liability](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction#license--liability)
   * [Commercial Distribution](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction#commercial-distribution)
2. [Installation](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation)
   * [Quick Start](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#quick-start)
   * [Basic Installation (Hardware)](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#basic-installation-hardware)
     * [CCU3](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-CCU3)
     * [ELV-Charly](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-ELV-Charly)
     * [Raspberry Pi](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-RaspberryPi)
     * [ODROID](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-ODROID)
     * [ASUS Tinker Board 2/2S](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-Tinkerboard2)
     * [Generic x86_64/aarch64](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-Generic-x86_64)
   * [Basic Installation (Virtual)](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#basic-installation-virtual)
     * [Proxmox Virtual Environment](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-Proxmox-VE)
     * [Home Assistant App](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-HomeAssistant)
     * [Docker Container (OCI)](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-Docker-OCI)
     * [Linux Container (LXC)](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-LXC)
     * [QEMU/KVM](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-QEmu)
     * [Kubernetes/K8s](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-Kubernetes)
     * [Synology Virtual Machine Manager](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-Synology-VMM)
     * [QNAP Virtualization Station](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-QNAP-VirtualizationStation)
     * [Unraid](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-UNRAID)
     * [XCP-ng/XenServer](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-XCPng)
     * [Oracle VirtualBox](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-VirtualBox)
     * [VMware ESXi](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-vmWare-ESXi)
     * [VMware Workstation Player](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-vmWare-Workstation-Player)
     * [Hyper-V](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-HyperV)
   * [Configuration Transfer](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#configuration-transfer)
     * [Upgrade from CCU3](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#upgrade-from-ccu3)
     * [Upgrade from CCU2](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#upgrade-from-ccu2)
     * [Upgrade from CCU1](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#upgrade-from-ccu1)
     * [Upgrade to a Virtual OpenCCU](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#upgrade-to-a-virtual-openccu)
     * [Migration from FHEM](https://github.com/OpenCCU/OpenCCU/wiki/en.Migration-FHEM)
     * [Migration from RaspberryMatic](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#migration-from-raspberrymatic)
     * [Migration of the RaspberryMatic HA Add-on](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#migration-of-the-raspberrymatic-ha-add-on)
   * [First Steps after Installation](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation#first-steps-after-installation)
   * [Uninstallation](https://github.com/OpenCCU/OpenCCU/wiki/en.Uninstallation)
3. [Administration](https://github.com/OpenCCU/OpenCCU/wiki/en.Administration)
   * [Firmware Update/Upgrade](https://github.com/OpenCCU/OpenCCU/wiki/en.Administration#firmware-updateupgrade)
   * [Backup/Restore](https://github.com/OpenCCU/OpenCCU/wiki/en.Administration#backup--restore)
   * [Home Assistant Integration](https://github.com/OpenCCU/OpenCCU/wiki/en.HomeAssistant-Integration)
   * [Security Advice](https://github.com/OpenCCU/OpenCCU/wiki/en.Administration#security-advice)
   * [CCU Add-ons / Additional Software](https://github.com/OpenCCU/OpenCCU/wiki/en.Administration#ccu-add-ons--additional-software)
   * [Status LEDs](https://github.com/OpenCCU/OpenCCU/wiki/en.Administration#status-led-function)
4. [Usage](https://github.com/OpenCCU/OpenCCU/wiki/en.Usage)
   * [WebUI Usage](https://github.com/OpenCCU/OpenCCU/wiki/en.WebUI-Usage)
     * [Log Data and Log Level](https://github.com/OpenCCU/OpenCCU/wiki/en.WebUI-Usage#log-data-and-log-level)
     * [Advanced Settings](https://github.com/OpenCCU/OpenCCU/wiki/en.WebUI-Usage#advanced-settings)
     * [Remote Access via Tailscale](https://github.com/OpenCCU/OpenCCU/wiki/en.WebUI-Usage#remote-access-via-tailscale)
     * [Custom HTTPS Certificate](https://github.com/OpenCCU/OpenCCU/wiki/en.WebUI-Usage#installing-a-certificate-of-a-private-pki)
   * [Tips & Tricks](https://github.com/OpenCCU/OpenCCU/wiki/en.Tips)
     * [HmIP-HAP as HmIP Gateway](https://github.com/OpenCCU/OpenCCU/wiki/en.Tips#homematicip-accesspoint-hmip-hap-as-hmip-gateway)
     * [Negated Conditions in Programs](https://github.com/OpenCCU/OpenCCU/wiki/en.Tips#negated-conditions-in-programs)
     * [Time Module with Extended Astro Function](https://github.com/OpenCCU/OpenCCU/wiki/en.Tips#time-module-with-extended-astro-function-offset-and-limit)
     * [Disable Internet Connection Monitoring](https://github.com/OpenCCU/OpenCCU/wiki/en.Tips#disabling-the-internet-connection-monitoring)
   * [Expert Features](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features)
     * [WLAN/WiFi Support](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#wlanwifi-usage)
     * [Bluetooth Support](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#bluetooth-usage)
     * [LAN Gateway Mode](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#lan-gateway-mode)
     * [UPS Client/Server Mode](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#ups-clientserver-nut)
     * [USB Boot](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#usb-boot)
     * [Monit WatchDog Web Interface](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#monit-watchdog-web-interface)
     * [SNMP](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#snmp)
     * [HB-RF-ETH Connection](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#hb-rf-eth-connection)
     * [Individual Diagram/Backup Storage Path](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#individual-diagrambackup-storage-path)
     * [Custom Actions during Boot](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#custom-actions-during-boot)
     * [Custom Actions during Shutdown](https://github.com/OpenCCU/OpenCCU/wiki/en.Expert-Features#custom-actions-during-shutdown)
5. [Support, Contributions](https://github.com/OpenCCU/OpenCCU/wiki/en.Support)
   * [Known Issues](https://github.com/OpenCCU/OpenCCU/wiki/en.Support#known-issues)
   * [Request Help](https://github.com/OpenCCU/OpenCCU/wiki/en.Support#request-help)
   * [FAQ – Frequently Asked Questions](https://github.com/OpenCCU/OpenCCU/wiki/en.FAQ)
   * [Report Issues](https://github.com/OpenCCU/OpenCCU/wiki/en.Support#bug-reports)
   * [Request Features](https://github.com/OpenCCU/OpenCCU/wiki/en.Support#feature-requests)
   * [Contributions / Development](https://github.com/OpenCCU/OpenCCU/wiki/en.Support#contributions--development)
6. [Miscellaneous](https://github.com/OpenCCU/OpenCCU/wiki/en.Miscellaneous)
   * [Acknowledgements](https://github.com/OpenCCU/OpenCCU/wiki/en.Miscellaneous#acknowledgements)
   * [Project History](https://github.com/OpenCCU/OpenCCU/wiki/en.Miscellaneous#project-history)
   * [Literature & Talks](https://github.com/OpenCCU/OpenCCU/wiki/en.Miscellaneous#literature--talks)
   * [Further Links](https://github.com/OpenCCU/OpenCCU/wiki/en.Miscellaneous#further-links)

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

[more...](https://github.com/OpenCCU/OpenCCU/wiki/en.Support)

## :scroll: Licenses

- **Project & release images.** The OpenCCU project (this repository) and the downloadable images under **[Releases](https://github.com/OpenCCU/OpenCCU/releases)** are provided under the **[Apache License 2.0](https://opensource.org/licenses/Apache-2.0)**, unless stated otherwise. OpenCCU is distributed free of charge and without commercial intent.

- **Third-party components.** Some included components are licensed differently and remain under their respective terms. For example, **Buildroot/Linux** is licensed under **[GPLv2](http://www.gnu.org/licenses/gpl-2.0.html)**, which may have implications when modifying sources or redistributing derived images. **[OpenCCU-Base](https://github.com/OpenCCU/OpenCCU-Base)** is redistributed under its respective component licenses—primarily **[HMSL 2.0, with documented exceptions](https://github.com/OpenCCU/OpenCCU-Base/blob/main/licenses/licenses.md)**.

- **Branding & artwork.** The OpenCCU logo and other graphics in this repository and in the downloadable images are copyrighted by their respective authors. Any commercial or non-commercial reuse—especially in redistributed binaries or forks—**is prohibited without prior written permission**.

### Disclaimer of Warranty

Unless required by applicable law or agreed to in writing, OpenCCU is provided by the Contributors (and each Contributor provides its Contributions) on an **"AS IS"** BASIS, **WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND**, either express or implied, including, without limitation, any warranties or conditions of **TITLE, NON-INFRINGEMENT, MERCHANTABILITY,** or **FITNESS FOR A PARTICULAR PURPOSE**. You are solely responsible for determining the appropriateness of using or redistributing OpenCCU and assume any risks associated with Your exercise of permissions under this License.

[more...](https://github.com/OpenCCU/OpenCCU/wiki/en.Introduction#license--liability)

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
