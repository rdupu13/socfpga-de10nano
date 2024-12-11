# Final Project Report

## Introduction

In this project, I implemented a PWM-controlled RGB LED driver, an ADC component that reads a potentiometer value,
and an entirely new component with its own custom hardware and software. The new component is an LCD display module,
brandishing the ultra-high resolution of 16x2 characters! Connected to the GPIO pins via a step-up transistor
circuit, the LCD receives 5v inputs instead of the normal 3.3v. All three components share a breadboard.

Interacting with this hardware are three platform drivers, a device tree, and a plain C program that brings
everything together. There's one platform driver for each component: the PWM RGB LED, the ADC potentiometer, and the
LCD module. These are kernel modules that are very similar to each other but must be compiled individually by the
linux-socfpga repository. Once the kernel object files (.ko) are transfered to the SoC FPGA, they can be inserted
using ```sudo insmod [name].ko```. These modules create device files in /dev, where they can then be controlled by
the C program bb_calc. This program initializes the LCD if no arguments are given and writes a message contained in
a binary file if an argument is given (the filename). After writing to the display, it enters an infinite loop where
it reads the ADC value and _attempts_ to color the LED in rainbow order, corresponding to the potentiometer position.

## [Hardware](bb-calc/hardware.md)

## [Software](bb-calc/software.md)

## Conclusion

In conclusion, this project brought me from zero to hero as far as linux programming and hardware. It was very fun
redoing the entire class but with different pieces of hardware. It sounds tedious, but the second time through is
always much faster and equally as valuable as the first, like watching a movie or show. I now feel as though I truly
know the fundamentals of the subject.

My Github and Markdown skills at the beginning of this semester were sub-par to non-existent. This class and project
helped me harness them in a way like never before. Completely wiping my laptop and starting from Ubuntu turned out
to do wonders on this front, giving me easy, direct access to the Linux CLI. I'll value these skills for the rest of
my life, I'm sure.

### Course Improvements

Like I said in my course evalution, my only complaint about this class is that the lab and homework instructions were
often unclear. As far as individual's misinterpretation, not all bases were covered, and mundane-seeming intermediate
steps were left out. Overall, it's a wonderful and fun class with an excellent teacher.
