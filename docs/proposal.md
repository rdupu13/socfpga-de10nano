# Final project proposal

## Ryan's Calculator Proposal
I plan to create an FPGA hardware design that performs addition, subtraction, multiplication, and division on
16-bit floating point numbers. The calculator will communicate with the rest of the hardware in the same way as
LED patterns, through registers implemented using Platform Designer.

"So you're gonna make an FPU." -Trevor

#### That did not happen. In hindsight, I would say:
In addition to the potentiometer, ADC, and RGB LED, I plan to connect an LCD display to the GPIO pins of the FPGA
and interface with it using custom hardware and software that allow me to write messages to it. Eleven transistors
will be required in order to step the voltage up from 3.3v to the 5v that the LCD expects. The design will be
implemented on a breadboard. There will also be a calculator keyboard nearby that works but is missing a working
driver.

## Noah's Proposal
?

## Division of labor
No plan was made ahead of time. See [teamwork](teamwork.mc).
