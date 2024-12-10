# Hardware Documentation

Connected to the DE10-Nano via ADC input 0 is a potentiometer, which splits the voltage between +5v and GND. See
the [DE10-Nano pinout](../resources/de10nano_gpio.png) for more information. 




## Potentiometer and ADC

#### Registers
0x00 - ADC Input 0        u12


## Pulse-Width Modulated RGB LED Controller

#### Registers
0x20 - Red duty cycle     u17.11
0x24 - Green duty cycle   u12.11
0x28 - Blue duty cycle    u12.11
0x2C - Period in ms       u12.11



## Calculator Keyboard

#### Registers
0x30 - Keyboard "buffer"  u9



## LCD Module Controller

#### Registers
0x40 - LCD control bits   u3
0x44 - LCD data in        u8
