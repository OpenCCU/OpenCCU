> **☕ Please Support OpenCCU !**
>
> If you find OpenCCU useful, consider supporting its further development:
>
> [![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-sponsor-pink.svg)](https://github.com/sponsors/OpenCCU)
> [![Donate](https://img.shields.io/badge/donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RAQSDY9YNZVCL)
>
> Your support helps to constantly maintain and further improve OpenCCU. Thank you! 🙏

---

# ChangeLog

## 0.3.0
- add optional `openccu_mac` configuration for pinning the OpenCCU macvlan MAC address.
- improve automatic MAC handling by incrementing only the parent MAC's last octet, ignoring stopped containers, reusing the current OpenCCU MAC on helper restarts, and avoiding reuse of the parent NIC MAC.
- allow empty and `null` optional add-on settings, including an unset `check_interval`, and default the interval to 15 seconds when omitted.
- refine validation, error handling, and documentation for MAC selection and helper configuration.

## 0.2.0
- initial release of the dedicated OpenCCU HAP/DRAP-Helper add-on.
- create and maintain a dedicated macvlan Docker network for the OpenCCU Home Assistant add-on.
- connect OpenCCU with a stable LAN IP and keep the required multicast and default routes in place for HmIP-HAP and HmIPW-DRAP communication.

For a recent ChangeLog please review the following information:

- [OpenCCU Releases](https://github.com/OpenCCU/OpenCCU/releases)
