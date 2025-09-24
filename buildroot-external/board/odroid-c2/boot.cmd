# fallback defaults
setenv load_addr "0x37000000"
setenv console "tty2"
setenv loglevel "0"
setenv bootfs 1
setenv rootfs 2
setenv userfs 3
#setenv gpio_button "23" # pin 32 (GPIOY_13)
setenv gpio_button "disabled"
setenv recoveryfs_initrd "recoveryfs-initrd"
setenv overlays ""
setenv usbstoragequirks "0x2537:0x1066:u,0x2537:0x1068:u"

echo "Boot script loaded from ${devtype} ${devnum}"

# decide kernel image on rootfs
if test -e ${devtype} ${devnum}:${rootfs} /Image; then
  setenv kernel_img /Image
  setenv kernel_bootcmd booti
else
  setenv kernel_img /zImage
  setenv kernel_bootcmd bootz
fi

# import environment from /boot/bootEnv.txt
if test -e ${devtype} ${devnum}:${bootfs} bootEnv.txt; then
  load ${devtype} ${devnum}:${bootfs} ${load_addr} bootEnv.txt
  env import -t ${load_addr} ${filesize}
fi

# test if the gpio button is 0 (pressed) or if .recoveryMode exists in userfs
# or if Image doesn't exist in the root partition
gpio input ${gpio_button}
if test $? -eq 0 \
   -o -e ${devtype} ${devnum}:${userfs} /.recoveryMode \
   -o ! -e ${devtype} ${devnum}:${rootfs} ${kernel_img}; then
  echo "==== STARTING RECOVERY SYSTEM ===="
  # load the initrd file
  load ${devtype} ${devnum}:${bootfs} ${ramdisk_addr_r} ${recoveryfs_initrd}
  setenv rootfs_str "/dev/ram0"
  setenv initrd_addr_r ${ramdisk_addr_r}
  setenv kernel_img "/recoveryfs-Image"
  setenv kernel_bootcmd booti
  setenv kernelfs ${bootfs}
else
  echo "==== NORMAL BOOT ===="
  # get partuuid of root_num
  part uuid ${devtype} ${devnum}:${rootfs} partuuid
  setenv rootfs_str "PARTUUID=${partuuid}"
  setenv initrd_addr_r "-"
  setenv kernelfs ${rootfs}
fi

# load kernel cmdline from /boot/cmdline.txt
fileenv ${devtype} ${devnum}:${bootfs} ${load_addr} cmdline.txt cmdline

# load devicetree
echo "Loading standard device tree ${fdtfile}"
setenv fdtfile "meson-gxbb-odroidc2.dtb"
load ${devtype} ${devnum}:${bootfs} ${fdt_addr_r} ${fdtfile}
fdt addr ${fdt_addr_r}

# load dt overlays
fdt resize 65536
for overlay_file in ${overlays}; do
  if load ${devtype} ${devnum}:${bootfs} ${load_addr} overlays/${overlay_file}.dtbo; then
    echo "Applying kernel provided DT overlay ${overlay_file}.dtbo"
    fdt apply ${load_addr} || setenv overlay_error "true"
  fi
done
if test "${overlay_error}" = "true"; then
  echo "Error applying DT overlays, restoring original DT"
  load ${devtype} ${devnum}:${bootfs} ${fdt_addr_r} ${fdtfile}
fi

# set bootargs
setenv bootargs "console=${console} root=${rootfs_str} ro rootfstype=ext4 fsck.repair=yes init_on_alloc=1 init_on_free=1 slab_nomerge iomem=relaxed rootwait rootdelay=5 consoleblank=120 quiet loglevel=${loglevel} net.ifnames=0 usb-storage.quirks=${usbstoragequirks} ${cmdline} ${bootargs}"

# load kernel
load ${devtype} ${devnum}:${kernelfs} ${kernel_addr_r} ${kernel_img}

# boot kernel
${kernel_bootcmd} ${kernel_addr_r} ${initrd_addr_r} ${fdt_addr_r}

echo "Boot failed, resetting..."
reset
