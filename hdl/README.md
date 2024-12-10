# Directory for Hardware Description Language Files

## Documentation:

### Breadboard Calculator

See [hardware.md](../docs/bb-calc/hardware.md)

_de10nano_top_   - Top-level VHDL entity for Ryan's Breadboard Calculator FP

_keyboard_       - State machine that controls the keyboard row and column lines

_lcd_            - State machine that controls and writes to the LCD module

_pwm_controller_ - Given a period and duty cycle, generates a pulse-width modulated signal
_pwm_rgb_led_    - 3 x _pwm_controller_, one for each color of an RGB LED (share common period)

### Noah's Project

See [hardware.md](docs/noahs-project/hardware.md)



## Common Files:

Contains VHDL modules that that multiple projects might use

_de10nano_top_template_ - Top-level VHDL entity template for the DE10-Nano
_fsm_template_          - Finite state machine template

_synchronizer_          - Syncs an input with the de10nano 50 MHz clock
_debouncer_             - Adds grace period for physical buttons or switches that bounce
_one_pulse_             - Shortens a synched 
_async_conditioner_     - _synchronizer_ + _debouncer_ + _one_pulse_
