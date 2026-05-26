# Home Assistant App: OpenCCU (HAP/DRAP Helper)

## About

This app is a helper component for OpenCCU in Home Assistant environments where
HmIP-HAP or HmIPW-DRAP devices are used.

It does **not** provide a full OpenCCU system by itself. Instead, it manages the
Docker network setup required so the regular OpenCCU app can communicate
reliably with HmIP-HAP/HmIPW-DRAP devices via multicast UDP.

## Important notes

- This app requires elevated permissions because it manages Docker networking.
- Run this helper together with the regular OpenCCU app.

## Installation and setup

1. Install and start the regular OpenCCU app.
2. Install this OpenCCU HAP/DRAP Helper app.
3. In this app configuration, set **OpenCCU IP** to a free and dedicated LAN IPv4 address.
4. Optionally set **OpenCCU MAC** to a fixed MAC address if you want it to stay stable across host changes.
5. Disable **Protection mode** for this helper app.
6. Enable **Start on boot** so it starts with Home Assistant.

## Configuration

| Option | Required | Description |
|---|---|---|
| `openccu_ip` | Yes | Static free LAN IPv4 address used for the OpenCCU app macvlan interface. |
| `openccu_mac` | No | Static MAC address used for the OpenCCU app macvlan interface. If empty, the helper derives it from the parent interface by incrementing the last octet and trying the next values when needed. |
| `check_interval` | No | Interval in seconds for periodic network setup checks (`10..3600`, default `15`). |
| `openccu_slug` | No | Slug of the OpenCCU app if different from default naming (default: `openccu`). |
| `network_name` | No | Name of the macvlan Docker network used for OpenCCU connectivity (default: `ccu`). |
| `parent_interface` | No | Parent NIC for macvlan (for example `enp0s18`). If empty, auto-detection is used. |
| `subnet` | No | Subnet for macvlan network. If empty, derived automatically. |
| `gateway` | No | Gateway for macvlan network. If empty, derived automatically. |

## More information

- OpenCCU project: <https://github.com/OpenCCU/OpenCCU>
