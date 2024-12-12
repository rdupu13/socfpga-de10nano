# Hardware Documentation

Connected to the DE10-Nano via ADC input 0 is a potentiometer, which splits the voltage between +5v and GND. See
the [DE10-Nano pinout](../resources/de10nano_gpio.png) for more information. 




## Potentiometer and ADC


#### Registers
	0xFF200000 - ADC Input 0        u12

## Pulse-Width Modulated RGB LED Controller
The PWM RGB LED, if you're lucky, is already pre-built upon the beginning of the final project. I connected my
red-green-blue LED (that's three diodes that emit red, green, and blue - combining to form any color) to one of my
breadboards and directed GPIO pins [2:0] to the blue, green, and red LED inputs through 220 ohm resistors. The red
LED, Trevor claims, has a forward voltage of 2v rather than the usual 3.3v. In my opinion, after wiring and
programming, the color balance is better if all three LEDs are resisted by 220 ohms. The fourth pin on the LED is,
of course, for a common ground.

In homework 9, I designed a VHDL component that generates a single, pulse-width-modulated signal given a clock
period, a PWM period, and a duty cycle. The **period** signal is a 17-bit, 11-fractional-bit fixed point number that
controls the rate at which the PWM pattern repeats. The **duty_cycle** signal is a 12-bit, 11-fractional-bit fixed
point number that determines what fraction of the PWM period that the signal is high (it's low in the other fraction).
This way, we can control the brightness of a binary signal using speed, usually 30+ Hz. The idea with using a PWM
controller is that the LED appears dimmer with a lower duty cycle.

In homework 10, I instantiated three of the PWM controllers and fed them a common clock and period. Three components
makes one for each color of the RGB LED. 

### Registers
	0xFF200020 - Red duty cycle     u17.11
	0xFF200024 - Green duty cycle   u12.11
	0xFF200028 - Blue duty cycle    u12.11
	0xFF20002C - Period in ms       u12.11



## Calculator Keyboard
> [!IMPORTANT]
> Documentation coming soon!

#### Registers
	0xFF200030 - Keyboard "buffer"  u9



## LCD Module Controller


### Registers
	0xFF200040 - LCD control bits   u3
	0xFF200044 - LCD data in        u8
