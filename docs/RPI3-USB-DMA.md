# Raspberry Pi 3 USB DMA fix and dwc2 evaluation

## Scope of the fix

[Issue #4212](https://github.com/OpenCCU/OpenCCU/issues/4212) reports a KFENCE
boundary corruption while an 18-byte USB device descriptor is freed. The
Raspberry Pi USB controller writes complete 32-bit words, so an 18-byte receive
buffer needs space for a 20-byte write.

Kernel patch `0006-usb-dwc_otg-pad-control-IN-DMA-buffers.patch` protects ordinary
control-IN URBs whose buffer length is not a multiple of four. It allocates a
padded buffer before DMA mapping, maps the padded length, and restores the
original transfer length before the controller sees the URB. After unmapping,
it copies at most the received length and the original buffer capacity back to
the caller. Mapping failures restore the original buffer without copying data.

Pre-mapped buffers (`URB_NO_TRANSFER_DMA_MAP`), scatter-gather buffers, other
transfer types and PIO control transfers retain their existing handling. This
is a targeted fix for the reported enumeration path, not a claim that every
possible DMA alignment issue in the legacy driver is solved.

The normal rpi3 image obtains the patch through its `patches` symlink to the
shared rpi5 patch directory. The recovery rpi3 configuration references this
individual patch explicitly; it previously referenced an obsolete
`board/rpi3/kernel-patches` directory.

## Validation

The patch is based on Raspberry Pi Linux `stable_20260609`
(`c8c7494100e99ee05b11aaa4f0588a223a63d1af`, Linux 6.18.34).

The host regression test compiles the actual helpers from a patched kernel
tree against a simulated DMA writer:

```sh
python3 scripts/testcases/build/test_dwc_otg_control_dma.py /path/to/patched/linux
```

It covers full, short and empty responses for lengths 1, 2, 3, 4, 7, 8, 18, 63,
64, 65, 255 and 65535, with cache alignment of 32, 64 and 128 bytes. Additional
cases cover allocation/mapping failure, cancellation, bounded copy-back and
excluded transfer types. Sanitizers can be enabled through `CFLAGS`:

```sh
CFLAGS='-fsanitize=address,undefined -g' \
  python3 scripts/testcases/build/test_dwc_otg_control_dma.py /path/to/patched/linux
```

This tests software buffer handling, not the controller or real DMA coherency.
Before merging, test repeated cold and warm boots on Pi 3B and 3B+, with KFENCE
enabled. Verify descriptor and hub-status data, Ethernet traffic, USB storage,
and connected radio adapters. Check both normal and recovery boot, plus USB
disconnect/reconnect and failed/short control requests where practical.

## Trying dwc2 on a Pi 3B or 3B+

The same controller can be driven by `dwc2`. The pinned kernel already contains
[the Raspberry Pi dwc2 length/alignment fix](https://github.com/raspberrypi/linux/commit/279fbca16aed002bab902d393a20fe2db506b28b).
The resolved bcm2711 defconfig plus OpenCCU rpi3 fragments enables
`CONFIG_USB_DWC2=y`, `CONFIG_USB_DWC2_DUAL_ROLE=y`, and `CONFIG_USB_DWCOTG=y`.
The recovery configuration uses the same defconfig and fragments.

1. Have local access to the SD card or console for rollback. Both onboard
   Ethernet and external USB on these boards depend on this controller.
2. Check the running image, rather than relying only on the build defaults:

   ```sh
   zcat /proc/config.gz | grep -E '^CONFIG_USB_(DWC2|DWC2_DUAL_ROLE|DWCOTG)='
   test -f /boot/overlays/dwc2.dtbo && echo 'dwc2 overlay available'
   ```

3. Remount `/boot` writable, back up `/boot/extraconfig.txt` if present, and add
   the following at its end. Check for existing USB-controller overlays first
   so that conflicting selections are not combined:

   ```ini
   [all]
   dtoverlay=dwc2,dr_mode=host
   ```

   Use `mount -o remount,rw /boot` before editing, then `sync` and
   `mount -o remount,ro /boot` afterwards. Reboot to select the driver.

4. Confirm the controller has actually bound to `dwc2`:

   ```sh
   dmesg | grep -E 'dwc2|dwc_otg|KFENCE'
   ls -l /sys/bus/platform/drivers/dwc2/
   ```

   Look for the controller-device symlink, normally `3f980000.usb` on Pi 3,
   and USB enumeration reporting `using dwc2`. A driver directory alone does
   not prove that the device is bound. `lsmod` is insufficient for built-in
   drivers.

5. Test normal and recovery boot, cold and warm reboot, Ethernet throughput
   and CPU load, USB storage, and HmIP-RFUSB/HB-RF-USB adapters. Include full-
   and low-speed devices behind hubs, since `dwc2` uses a different scheduling
   implementation from the legacy driver's FIQ path. Keep KFENCE enabled.

Rollback is to restore the saved `extraconfig.txt`, or remove only the added
overlay selection, then reboot. If networking is unavailable, edit the FAT
boot partition using another computer. The same firmware-applied device tree
is passed by `boot.cmd` to the normal and recovery kernels, so recovery is not
an independent escape from an incompatible overlay.

## Making dwc2 the default later

A default-driver change should be a separate, hardware-tested change:

- Make `CONFIG_USB_DWC2=y` explicit in `board/rpi3/kernel.config`; initially
  preserve dual-role support and keep `CONFIG_USB_DWCOTG=y` for rollback.
- Add the host overlay to `board/rpi3/config.txt` only for the intended boards.
  The rpi3 image also supports Zero 2 and Compute Module variants, and OpenCCU
  has a USB gadget mode. A blanket host-only selection requires auditing those
  use cases first; do not replace dual-role kernel support with host-only
  support without that decision.
- Remove the obsolete `dwc_otg.lpm_enable=0` boot argument when committing to
  the switch. It configures the old driver, not dwc2, and is not needed for the
  opt-in trial.
- Confirm `dwc2.dtbo` is shipped and retained across updates, and verify both
  normal and recovery images. No additional U-Boot overlay mechanism is needed:
  firmware already applies overlays before U-Boot passes the device tree on.
- Compare KFENCE results, USB reliability, Ethernet performance and CPU load
  with the patched legacy driver. Require successful testing across the
  supported board/device matrix before considering removal of `dwc_otg`.

The dwc2 fix provides a useful precedent, but changing controller drivers is
broader than the descriptor-buffer repair. Public dwc2 reports such as
[raspberrypi/linux#7475](https://github.com/raspberrypi/linux/issues/7475)
also describe issues involving pre-mapped isochronous audio buffers, so a
successful enumeration test alone is not sufficient evidence for all devices.
