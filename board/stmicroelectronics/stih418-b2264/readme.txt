STih418-B2264 / 4kOpen

Intro
=====

This configuration supports the STIh418-B2264 (4kOpen) board
platform:

  https://www.4kopen.com/

How to build
============

 $ make stih418_b2264_defconfig / make stih418_b2264_ramfs_defconfig
 $ make

How to write the microSD card / USB
===================================

Once the build process is finished you will have an image called
"sdcard.img" in the output/images/ directory.

Copy the bootable "sdcard.img" onto an microSD card with "dd":

  $ sudo dd if=output/images/sdcard.img of=/dev/sdX

Boot the board from RAMFS
=========================

 (1) Insert the microSD card

 (2) Power-up the board / Reset

 (3) The system will start, with the console on UART


Under the wood
==============

check "diff -uprN configs/stih418_b2264_defconfig configs/stih418_b2264_ramfs_defconfig"

if BR2_TARGET_ROOTFS_CPIO_UIMAGE=y is selected, then initrd is generated
and kernel bootargs will use "board/stmicroelectronics/stih418-b2264/uenv-ramfs.txt"

else (default), 2nd partition (ext4) is created for rootfs, and kernel bootargs will 
use "board/stmicroelectronics/stih418-b2264/uenv.txt"


Memory map
==========

  Position in memory (max DTB 1Mo, max uImage 15Mo)

  +-0x40000000----+
  |   ~1.34Go     | ^
  |               | |
  +-0x94000000----+ |
  | uImage - 15Mo | |
  +-0x94f00000----+ | 2Go
  | dtb    -  1Mo | |
  +-0x95000000----+ |
  | rootfs        | |
  |               | |
  |    ~688Mo     | |
  +-0xc0000000----+ v

Wayland tips
============

  # Start Weston from root console (plug USB mouse/keyboard first)
  if test -z "${XDG_RUNTIME_DIR}"; then
      export XDG_RUNTIME_DIR=/tmp/${UID}-runtime-dir
      if ! test -d "${XDG_RUNTIME_DIR}"; then
          mkdir "${XDG_RUNTIME_DIR}"
          chmod 0700 "${XDG_RUNTIME_DIR}"
      fi
  fi

  weston --idle-time=0

  # Demos from Weston terminal
  glmark2-es2-wayland --run-forever
  es2gears_wayland

  # Games
  chocolate-doom -window
  supertuxkart
  enigma -window

  # Video Player
  mpv http://jau.free.fr/Pixar.-.The.Chubb.Chubbs.avi


 # Start Wayland app from console
 #---------------------------------
  /tmp
  |-- 101-runtime-dir
  |   |-- wayland-1
  |   `-- wayland-1.lock

  # Export these variables
  export WAYLAND_DISPLAY=wayland-1
  export XDG_RUNTIME_DIR=/tmp/101-runtime-dir

Audio tips
==========

1st, put FDMA firmware into /lib/firmware

Aplay (alsa-utils) can show you device playback ( 1 x Analog, 1 x HDMI)
  # aplay -l
  **** List of PLAYBACK Hardware Devices ****
  card 0: STIB2264 [STI-B2264], device 0: Uni Player #2 (DAC)-sas-dai-dac sas-dai-dac-0 [Uni Player #2 (DAC)-sas-dai-dac sas-dai-dac-0]
    Subdevices: 1/1
    Subdevice #0: subdevice #0
  card 0: STIB2264 [STI-B2264], device 1: Uni Player #0 (HDMI)-i2s-hifi i2s-hifi-1 [Uni Player #0 (HDMI)-i2s-hifi i2s-hifi-1]
    Subdevices: 1/1
    Subdevice #0: subdevice #0

  # playback on Analog outpout
  aplay --device=plughw:0,0 sound.wav

  # playback on HDMI outpout
  aplay --device=plughw:0,1 sound.wav

--------- LEGACY Chapter ----------

How to write the microSD card / USB
===================================

Once the build process is finished you will have an image called
"sdcard.img" in the output/images/ directory.

Copy the bootable "sdcard.img" onto an microSD card with "dd":

  $ sudo dd if=output/images/sdcard.img of=/dev/sdX

Or simply put "uImage", "stih418-b2264-box.dtb", "rootfs.cpio.uboot"
on USB FAT partition.

Boot the board from RAMFS
=========================

 (1) Insert the microSD card or USB into USB3 port

 (2) From u-boot console (once, then type "saveenv")
     µSD: setenv buildroot 'mmc rescan; fatload mmc 0:1 0x94000000 uimage; \
	  fatload mmc 0:1 0x94f00000 devicetree.dtb; \
	  fatload mmc 0:1 0x95000000 uramdisk.image.gz; \
	  setenv bootargs "console=ttyAS0,115200 loglevel=7 \
	  earlyprintk quiet root=/dev/ram0 rw \
	  initrd=0x95000040,0x${filesize}"; bootm 0x94000000 0x95000000 0x94f00000'

     USB: setenv buildroot 'usb start; fatload usb 0:1 0x94000000 uImage; \
	  fatload usb 0:1 0x94f00000 stih418-b2264-box.dtb; \
	  fatload usb 0:1 0x95000000 rootfs.cpio.uboot; \
	  setenv bootargs "console=ttyAS0,115200 loglevel=7 \
	  earlyprintk quiet root=/dev/ram0 rw \
	  initrd=0x95000040,0x${filesize}"; bootm 0x94000000 0x95000000 0x94f00000'

 (3) from u-boot console "run buildroot"

Boot the board from rootfs as 2nd partition
===========================================

 (1) Create a 2nd partition on µSD (ext4)
     then extract rootfs from output/images/rootfs.tar

 (2) From u-boot console (once, then type "saveenv")
     µSD: setenv buildroot_ext4 'mmc rescan; fatload mmc 0:1 0x94000000 uimage; \
          fatload mmc 0:1 0x94f00000 devicetree.dtb; \
          setenv bootargs "console=ttyAS0,115200 loglevel=7 earlyprintk \
          quiet root=/dev/mmcblk0p2 rootwait"; bootm 0x94000000 - 0x94f00000'

 (3) from u-boot console "run buildroot_ext4"

u-boot 2025.04
==============

WARNING / Limitation:
 - no flash support (NOR) / check: "Back to u-boot legacy" chapter
 - memory seen by Linux is 1Go only (fixme)
 - only 1 x CPU core (vs 4 cores avaiable)
 - 2 x USB2 port: expose as HOST
 - 1 x USB3 port: expose as Gadget (or mmc relay)

u-boot-spl.bin: U-boot SPL, to be placed at the beginning of the NOR flash on the 4KOpen card
u-boot.img: a FIT image of U-boot, which will be loaded by the SPL (mmc 0:1 / FAT partition)
uboot.env: environnement variables for uboot (mmc 0:1 / FAT partition)

0 - Preparation of the libbtfmw-h418.a file
-------------------------------------------

U-boot SPL requires to have a valid libbtfmw-h418.a file available.  Indeed
the libbtfmw is in charge of the early platform preparation.
This is part of the targetpack-20160812-3 tarball which can be found within
the starkl delivery available at https://bitbucket.org/4kopen/starkl/get/v1.0.3.tar.bz2

Before being able to use the libbtfmw-h418.a, due to a duplicated symbol
(div64_u64) available in both u-boot and libbtfmw, it is necessary to run the
following command in order to rename the symbol available within libbtfmw

arm-buildroot-linux-gnueabihf-objcopy --redefine-sym div64_u64=libbtfwm_div64_u64 libbtfmw-h418.a

within the uboot make menuconfig, set the TARGET_STIH418_B2264_LIBBTFMW_PATH parameter to the folder containing the libbtfmw-h418.a file

1 - flash from legacy u-boot
-----------------------------

Err:   serial
Net:   stmac-1
Hit any key to stop autoboot:  0
4KOpen>
4KOpen>
4KOpen>
4KOpen> mmc rescan
4KOpen> fatls mmc 0:1
4KOpen> fatload mmc 0:1 0x98000000 u-boot-spl.bin
4KOpen> sf probe
SPI is boot device.
 FSM SF: Detected ST N25Q256 with sector size  64 KiB, total  32 MiB
4KOpen> sf update 0x98000000 0 $filesize
129628 bytes written, 0 bytes skipped in 0.514s, speed 256748 B/s
4KOpen> reset


2 - boot from uboot 2025.04 SPL, then u-boot.img
------------------------------------------------

boot SPL from flash
-----8<-----8<-----8<-----8<-----8<-----8<-----
Boot firmware version 20160527-1

!*:#)$<@[|{%<$P\;AP;Z:-6KQ>*>$Q"+&4.
U-Boot SPL 2024.04-rc1-g2f685cf0c4 (Feb 05 2024 - 21:37:59 +0100)
Trying to boot from MMC1
-----8<-----8<-----8<-----8<-----8<-----8<-----

boot 2nd stage from mmc 0:1 / fat:u-boot.img
and use mmc 0:1 / fat:uboot.env for uboot environnement
-----8<-----8<-----8<-----8<-----8<-----8<-----
U-Boot 2024.04-rc1-g2f685cf0c4 (Feb 05 2024 - 21:37:59 +0100)STMicroelectronics STiH418-B2264

Model: STiH418 B2264
DRAM:  2 GiB
Core:  276 devices, 18 uclasses, devicetree: embed
MMC:   Can't get the gpio bank phandle: -2
sdhci@9060000: 0
Loading Environment from FAT... OK
In:    serial@9530000
Out:   serial@9530000
Err:   serial@9530000
Net:   No ethernet found.
Hit any key to stop autoboot:  0
stih418-b2264 =>
-----8<-----8<-----8<-----8<-----8<-----8<-----

Back to u-boot legacy (from Linux Kernel)
=========================================

Compile your Linux kernel removing readonly access on partition 0

diff --git a/arch/arm/boot/dts/st/stih418-b2264.dts b/arch/arm/boot/dts/st/stih418-b2264.dts
index 9cd0d0def7e3..042efd231cd8 100644
--- a/arch/arm/boot/dts/st/stih418-b2264.dts
+++ b/arch/arm/boot/dts/st/stih418-b2264.dts
@@ -188,7 +188,6 @@ partitions {
                partition@0 {
                        label = "PBL"; /* 768Ko */
                        reg = < 0x0 0xc0000 >;
-                       read-only;
                };

                partition@1 {


Then, boot Linux, and flash legacy PBL
# flashcp /boot/4kopen-pbl-secure.bin /dev/mtd0



FIXME
=====
 - Understand the 0x40 offset for Initrd, should be take in account in bootm....

