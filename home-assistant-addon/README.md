# Home Assistant Add-on: OpenCCU CCU

HomeMatic/homematicIP CCU central based on [OpenCCU](openccu).

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]
[![License](https://img.shields.io/github/license/OpenCCU/OpenCCU.svg)](https://github.com/OpenCCU/OpenCCU/blob/master/LICENSE)
[![Donate](https://img.shields.io/badge/donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RAQSDY9YNZVCL)
[![GitHub stars](https://img.shields.io/github/stars/OpenCCU/OpenCCU.svg?style=social&label=Star)](https://github.com/OpenCCU/OpenCCU/stargazers/)

## About

This add-on allows to run a [HomeMatic/homematicIP][homematic] control center (CCU) on
your Home Assistant. It is based on [OpenCCU][openccu] which
is open-source and 100% compatible with the homematic vendor ([eQ3][eq3]) own CCU
system (CCU3) to connect to HomeMatic/homematicIP devices without any cloud connection.
Furthermore, it is based on [OCCU][occu] while providing additional exclusive features in
the WebUI and underlying operating system for an improved user experience.

## Features

- Use your Home Assistant central as a full-fledged HomeMatic/homematicIP control center unit (CCU).
- Access the CCU WebUI directly from your Home Assistant user interface.
- Provides all features of a OpenCCU system within your Home Assistant environment.
- Interconnect to HomeMatic/homematicIP devices using the standard, vendor-provided RF modules (`RPI-RF-MOD`, `HM-MOD-RPI-PCB`, `HmIP-RFUSB`, `HM-CFG-USB-2`, `HM-CFG-LAN`), Wired gateways (`HmIPW-DRAP`, `HMW-LGW-O-DR-GS-EU`) or LAN gateway solutions (`HmIP-HAP`, `HM-LGW-O-TW-W-EU`) – see [Requirements](https://github.com/OpenCCU/OpenCCU/wiki/Einleitung#vorraussetzungen).
- Supports additional third-party open-hardware based USB/Ethernet adapter devices (`HB-RF-USB`, `HB-RF-USB-2`, `HB-RF-ETH`).

## Documentation / Installation

For a detailed documentation please refer to the "Documentation" tab of the installed Add-on or
consult the [online documentation](https://github.com/OpenCCU/OpenCCU/wiki/Installation-HomeAssistant) available in the OpenCCU GitHub project. Also note, that after having installed the Add-on you also have to setup the [HomeMatic integration](https://github.com/OpenCCU/OpenCCU/wiki/HomeAssistant-Integration) part in Home Assistant itself so that your Home Assistant is able to see and use the HomeMatic/homematicIP devices of your OpenCCU CCU.

:warning: Please note, that if you are going to use a `RPI-RF-MOD` or `HM-MOD-RPI-PCB` RF module connected to the GPIO of a Raspberry Pi or other SBC you have to make sure to explicitly [enable the UART interface](https://github.com/OpenCCU/OpenCCU/wiki/Installation-HomeAssistant#using-homeassistant-os) of these systems.

## License

This Home Assistant add-on as well as the OpenCCU base system is licensed under the Apache-2.0 open-source license.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[openccu]: https://github.com/OpenCCU/OpenCCU
[occu]: https://github.com/eq-3/occu
[eq3]: https://www.eq-3.com/
[homematic]: https://www.homematic-ip.com/en/start.html
