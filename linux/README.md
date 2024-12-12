# Linux Files

This directory is for the Linux-related files, including kernel modules and device tree nodes.

## ko: Kernel Objects

**ko/** contains the platform driver C code. A Makefile automatically links the program with the Linux kernel,
located in the linux-socfpga repository. There's a separate folder for each driver because the compilation process
creates about a dozen intermediate files.

Each driver is the bridge between the hardware and the software, allowing the Linux kernel to identify my hardware
and communicate with it through subsystems. I had trouble implementing the final program with the drivers being
registered under the sysfs subsystem, so I switched to the miscdev subsystem. In this interface, our device appears
as a character device file in the /dev directory.

### More information on each driver
#### [ko/adc/](ko/adc/README.md)
#### [ko/lcd/](ko/lcd/README.md)
#### [ko/pwm/](ko/pwm/README.md)

## dts: Device Trees

**dts/** contains the custom device tree nodes for our custom hardware components. Nodes in the **.dts** file give
information to the kernel on which drivers match to which component, as well as where they're located. There is one
node for the adc, pwm, keybaord, and lcd, in that order address-wise.

### sh: Shell Scripts

**sh/** is for shell scripts. I haven't written any.
