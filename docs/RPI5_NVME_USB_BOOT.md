# Raspberry Pi 5 NVMe and USB Boot with U-Boot

This document describes the NVMe (PCIe) and USB boot support for the
Raspberry Pi 5 in OpenCCU, the U-Boot patchsets integrated, known
limitations, and how to test and troubleshoot.

## Overview

The Raspberry Pi 5 (BCM2712 SoC) can boot from NVMe SSDs via the PCIe
interface and from USB mass storage. OpenCCU uses U-Boot as an
intermediate bootloader (specified via `kernel=u-boot.bin` in config.txt).

**Boot flow:**

1. RPi5 EEPROM firmware initializes hardware and PCIe
2. Firmware loads `u-boot.bin` from the configured boot device
3. U-Boot runs `pci enum; usb start;` (via PREBOOT) to enumerate devices
4. U-Boot boot script (boot.cmd) loads and boots the OpenCCU kernel

## Integrated Patchsets

### 1. BCM2712 PCIe Support (`0001-pcie-brcmstb-Add-BCM2712-RPi5-PCIe-support.patch`)

**Problem:** U-Boot 2025.04's `pcie_brcmstb.c` driver only supports the
BCM2711 (RPi4) PCIe controller. The RPi5 uses BCM2712 which has different
register offsets and initialization requirements.

**Solution:** Ported BCM2712-specific handling from the Linux kernel's
`drivers/pci/controller/pcie-brcmstb.c`, including:

- Different `PCIE_HARD_DEBUG` register offset (0x4304 vs 0x4204)
- Different `PCIE_RGR1_SW_INIT_1` bridge init bit (bit 0 vs bit 1)
- PERST# via `PCIE_MISC_PCIE_CTRL` (active-high PERSTB) instead of
  `PCIE_RGR1_SW_INIT_1`
- MDIO initialization for 54 MHz xosc reference clock (instead of SSC)
- UBUS-AXI bridge error suppression to prevent lockups
- Different MSI interrupt register offsets

**Provenance:** Derived from Linux kernel `pcie-brcmstb.c`:
- `struct pcie_cfg_data bcm2712_cfg`
- `brcm_pcie_post_setup_bcm2712()` for MDIO and UBUS init
- `brcm_pcie_perst_set_7278()` for PERST via PCIE_MISC_PCIE_CTRL
- `pcie_offsets_bcm7712[]` for HARD_DEBUG register offset

## Configuration

### U-Boot config options (rpi5/uboot.config)

The following U-Boot Kconfig options are enabled for RPi5:

| Config | Purpose |
|--------|---------|
| `CONFIG_PCI=y` | PCIe subsystem (from rpi_arm64 defconfig) |
| `CONFIG_PCI_BRCMSTB=y` | Broadcom STB PCIe host driver (now with BCM2712 support) |
| `CONFIG_NVME=y` | NVMe storage subsystem |
| `CONFIG_NVME_PCI=y` | NVMe over PCIe |
| `CONFIG_CMD_NVME=y` | `nvme` U-Boot command |
| `CONFIG_CMD_PCI=y` | `pci` U-Boot command |
| `CONFIG_USB_XHCI_HCD=y` | XHCI USB host controller |
| `CONFIG_USB_DWC3=y` | DWC3 USB3 controller core |
| `CONFIG_USB_DWC3_GENERIC=y` | Generic DWC3 glue |
| `CONFIG_USB_XHCI_DWC3=y` | XHCI via DWC3 |
| `CONFIG_USB_STORAGE=y` | USB mass storage |

### config.txt (RPi firmware)

The `[pi5]` section in `board/rpi5/config.txt` enables PCIe:

```
dtparam=pciex1
```

This enables the external PCIe x1 port used by NVMe M.2 HATs.

### EEPROM Boot Order

For NVMe boot, the RPi5 EEPROM must be configured to include NVMe in its
boot order. Use `raspi-config` or `rpi-eeprom-config`:

```bash
# Check current config
sudo rpi-eeprom-config

# Edit to add NVMe boot (value 6) before SD card:
# BOOT_ORDER=0xf416  (means: NVMe -> USB -> SD -> restart)
sudo rpi-eeprom-config --edit
```

Boot order values:
- `1` = SD card
- `4` = USB MSD
- `6` = NVMe PCIe
- `f` = restart

## Testing

### Testing NVMe Boot

1. Connect NVMe SSD via M.2 HAT to RPi5 PCIe slot
2. Flash OpenCCU to NVMe: `dd if=OpenCCU-rpi5.img of=/dev/nvme0n1`
3. Configure EEPROM boot order to include NVMe (see above)
4. Boot the RPi5

Expected U-Boot output when booting from NVMe:
```
PCIe BRCM: link up, 5.0 Gbps x1 (!SSC)
U-boot loaded from NVMe (PCIe)
```

### Manual NVMe Verification in U-Boot

Press Ctrl-X during the boot delay to enter U-Boot shell, then:

```
RM> pci enum
RM> nvme scan
RM> nvme info
RM> ls nvme 0:1
```

Expected output if NVMe is detected:
```
Device 0: Vendor: xxxx Rev: xxxx Prod: [NVMe device name]
          Type: Hard Disk
          Capacity: [size]
```

### Testing USB Boot

1. Flash OpenCCU to USB drive: `dd if=OpenCCU-rpi5.img of=/dev/sdX`
2. Connect USB drive to RPi5
3. Configure EEPROM to include USB in boot order
4. Boot the RPi5

Expected U-Boot output:
```
U-boot loaded from USB
```

Manual USB verification in U-Boot shell:
```
RM> usb start
RM> usb info
RM> ls usb 0:1
```

### Fallback Behavior

If NVMe or USB is not present:
- `pci enum` will report no PCIe devices (link down)
- `usb start` will report no USB devices
- U-Boot will continue to the `devtype`/`devnum` from firmware boot
- If no boot device is found, U-Boot resets after timeout

### Recovery Mode

The recovery mode behavior is unchanged regardless of boot device:
- GPIO12 button pressed → recovery mode
- `/.recoveryMode` file exists on userfs partition → recovery mode
- Kernel image missing → recovery mode

Recovery mode works from any boot device (SD, NVMe, USB).

## Known Limitations

### USB Boot from RPi5 USB3 Ports (RP1/DWC3)

**Status: Not yet fully functional**

The RPi5 USB3 ports are connected to the RP1 "south bridge" chip via the
internal PCIe bus (pcie2). The RP1 is a PCI Multi-Function Device (MFD)
that presents USB controllers, Ethernet, GPIO, and other peripherals.

USB boot from the RPi5 USB-A 3.0 ports requires:
1. PCIe enumeration of pcie2 (internal, RP1-connected port)
2. RP1 MFD device initialization
3. DWC3 USB controller initialization within RP1

While the CONFIG options for DWC3/XHCI are enabled in this release, full
RP1 initialization from U-Boot is not yet implemented. The DWC3 config
options are included to prepare for future support when RP1 initialization
lands upstream in U-Boot.

**Workaround:** USB boot currently works only when the RPi5 firmware itself
loads U-Boot from the USB device (the EEPROM bootloader handles USB init
before passing control to U-Boot). In this case, `devtype=usb` and
`devnum=0` are set by the firmware, and U-Boot uses them to load the kernel.

### NVMe Boot Reliability

NVMe boot is functional but depends on:
- PCIe link training completing successfully (should be reliable)
- Correct `dma-ranges` propagation from firmware DT (handled by rpi.c)
- NVMe device responding to initialization within timeout

Some NVMe devices with slow initialization may fail. If this occurs,
the PCIe BCM2712 driver will print "PCIe BRCM: link down" and U-Boot
will attempt the next boot device.

### No Upstream U-Boot BCM2712 Support Yet

As of U-Boot 2025.04, there is no upstream BCM2712 PCIe support. The
patch in `board/rpi5/uboot-patches/` is a backport from the Linux kernel
driver. When upstream U-Boot adds BCM2712 support, these patches should be
retired in favor of the upstream implementation.

## Troubleshooting

### NVMe Not Detected

1. Check `pci enum` output in U-Boot shell - if empty, PCIe link is down
2. Verify `dtparam=pciex1` is in config.txt `[pi5]` section
3. Try disabling then re-enabling power to the NVMe drive
4. Check if the M.2 HAT supports Gen2 speed (RPi5 PCIe is officially Gen2)

### "PCIe BRCM: BCM2712 MDIO init warning" in U-Boot

If you see this warning, the BCM2712 SerDes MDIO initialization failed.
This may still work if the firmware pre-initialized PCIe. Check if NVMe
is still detected after the warning.

### Boot Loop

If the system boots into a loop, the EEPROM boot order may be causing
attempts to boot from a blank or corrupted NVMe. Use a USB keyboard to
interrupt U-Boot (Ctrl-X) and fix the NVMe partitions, or reconfigure
EEPROM to boot from SD first.
