# SoC FPGA DE10-Nano Projects
This repository is dedicated to hardware-software codesign projects for the Terasic DE10-Nano SoCFPGA.
Created by Ryan Dupuis (rdupu13).

## Origin
It all started as Ryan Dupuis' final project for EELE 467. This project combines all that I learned fall 2024
semester, including but not limited to Github, Markdown, Linux, VHDL, Quartus, Platform Designer, Kernel Modules/
Drivers and C programming.

Initially intended to be a breadboard calculator, this project proved to be a beast that I wouldn't see coming.
Although it's not a calculator yet, or maybe ever, I met the requirements by including at least one piece of custom
[hardware](docs/bb-calc/hardware.md) other than the RGB LED and the potentiometer. That custom hardware is an LCD
display that can show any message with a simple [program](docs/bb-calc/software.md) that reads a binary file. Once
the message is written on the display, it enters an infinite loop that tracks the potentiometer value and _attempts_
to cycle through the colors of the rainbow corresponding to that value. I say _attempts_ because there is an
unresolved issue with the trigonometric calculations that makes the green and blue parts change discontinuously.

I had a lot of fun with this project and intend on adding to this repository after the semester ends. It's by far the
task I put the most time into in the last month.

## Projects So Far

### final-project: Final Project for EELE 467


### bb-calc: Breadboard Calculator



## docs/
The documentation folder.

## [hdl/](hdl/README.md)
This directory is for hardware description language files. These encode the registers and state machines that Quartus
compiles See [hardware.md](docs/bb-calc/hardware.md)

## [linux/](linux/README.md)
This directory is for the Linux-related files, including kernel modules and device tree nodes.

## [quartus/](quartus/README.md)
The Quartus project directory, where the mountain of files created by Platform Designer call home.

## [sim/](sim/README.md)
This directory is unused at the moment.

## [sw/](sw/README.md)
This directory is for software that interacts with my custom hardware.

## [utils/](utils/README.md)
This directory contains development utilities. I haven't added or used anything here yet.

