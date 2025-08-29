STM32MP257F Evaluation board v1

Intro
=====

This configuration supports the STM32MP257F Evaluation Board 1 (EV1)
platform:

  https://www.st.com/en/evaluation-tools/stm32mp257f-ev1.html

How to build
============

 $ make stm32mp257f_ev1_defconfig
 $ make

How to write the microSD card
=============================

Once the build process is finished you will have an image called
"sdcard.img" in the output/images/ directory.

Copy the bootable "sdcard.img" onto an microSD card with "dd":

  $ sudo dd if=output/images/sdcard.img of=/dev/sdX

Boot the board
==============

 (1) Insert the microSD card in connector CN1

 (2) Configure the bootpins (SW1 - where PCB says BOOT) to boot on ARM
     Cortex-A35 SDMMC:  0b1000 where MSB is BOOT0 and LSB is BOOT4

 (3) Depending on the positions of the power jumper (JP4) provides the board
     with either:

      * a 5V/3A power supply unit on the jack CN20 (where PCB says 5V_3A)
      * a USB Power Delivery Type-C connector CN21 (where PCB says USB_PWR|STLINK)

     Position [1-2] selects CN21 as the main board supply.
     Position [2-3] selects CN20 as the main board supply.

 (4) According to the previous step configuration, plug either a USB Type-C
     cable in connector CN21 or both cables (eg. a USB Type-C on CN21 and a
     5V/3A power jack on CN20)

 (5) Run your serial communication program on /dev/ttyACM0.

 (6) The system will start, with the console on UART, but also visible
     on the screen.
