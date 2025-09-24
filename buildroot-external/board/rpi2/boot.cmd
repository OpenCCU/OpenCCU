# modify bootargs, load kernel and boot it
# fallback defaults
setenv load_addr ${ramdisk_addr_r}
setenv console "tty2"
setenv loglevel "0"
setenv bootfs 1
setenv rootfs 2
setenv userfs 3
setenv gpio_button "GPIO12"
setenv kernel_img "Image"
setenv recoveryfs_initrd "recoveryfs-initrd"
setenv usbstoragequirks "174c:55aa:u,2109:0715:u,152d:0578:u,152d:0579:u,152d:1561:u,174c:0829:u,14b0:0206:u,174c:225c:u,7825:a2a4:u,152d:0562:u,125f:a88a:u,152d:a583:u"

# output where we are booting from
itest.b ${devnum} == 0 && echo "U-boot loaded from SD"
itest.b ${devnum} == 1 && echo "U-boot loaded from eMMC"

# test if the kernel does not exist and if not we use zImage
if test ! -e ${devtype} ${devnum}:${rootfs} /${kernel_img}; then
  setenv kernel_img "z${kernel_img}"
fi

# import environment from /boot/bootEnv.txt
if test -e ${devtype} ${devnum}:${bootfs} bootEnv.txt; then
  load ${devtype} ${devnum}:${bootfs} ${load_addr} bootEnv.txt
  env import -t ${load_addr} ${filesize}
fi

# test if the gpio button is 0 (pressed) or if .recoveryMode exists in userfs
# or if zImage doesn't exist in the root partition
gpio input ${gpio_button}
if test $? -eq 0 \
   -o -e ${devtype} ${devnum}:${userfs} /.recoveryMode \
   -o ! -e ${devtype} ${devnum}:${rootfs} /${kernel_img}; then
  echo "==== STARTING RECOVERY SYSTEM ===="
  # load the initrd file
  load ${devtype} ${devnum}:${bootfs} ${load_addr} ${recoveryfs_initrd}
  setenv rootfs_str "/dev/ram0"
  setenv initrd_addr_r ${load_addr}
  setenv kernel_img "recoveryfs-zImage"
  setenv kernelfs ${bootfs}
else
  echo "==== NORMAL BOOT ===="
  # get partuuid of root_num
  part uuid ${devtype} ${devnum}:${rootfs} partuuid
  setenv rootfs_str "PARTUUID=${partuuid}"
  setenv initrd_addr_r "-"
  setenv kernelfs ${rootfs}
fi

# load devicetree
fdt addr ${fdt_addr}
fdt get value bootargs /chosen bootargs

# set bootargs
setenv bootargs "dwc_otg.lpm_enable=0 sdhci_bcm2708.enable_llm=0 console=${console} root=${rootfs_str} ro rootfstype=ext4 fsck.repair=yes rootwait rootdelay=5 consoleblank=120 logo.nologo quiet loglevel=${loglevel} init_on_alloc=1 init_on_free=1 slab_nomerge iomem=relaxed net.ifnames=0 usb-storage.quirks=${usbstoragequirks} ${extraargs} ${bootargs}"

# load kernel
load ${devtype} ${devnum}:${kernelfs} ${kernel_addr_r} ${kernel_img}

# boot kernel
bootz ${kernel_addr_r} ${initrd_addr_r} ${fdt_addr}

echo "Boot failed, resetting..."
reset
