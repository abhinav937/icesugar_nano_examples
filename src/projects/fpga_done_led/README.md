# FPGA Done LED Example

This project demonstrates how to light up the B4 LED on the iCESugar Nano board as soon as the FPGA is programmed ("done" state).

## Files
- `fpga_done_led.v`: Simple Verilog module that drives the B4 LED high when the FPGA is programmed.
- `fpga_done_led.pcf`: Constraints file mapping the `LED_B4` signal to the B4 pin on the board.

## How it works
- The Verilog module assigns a constant high (`1'b1`) to the `LED_B4` output.
- When the FPGA is programmed, the B4 LED will turn on, indicating the device is ready.

## Usage
1. Synthesize and upload the design to your iCESugar Nano FPGA.
2. The B4 LED should light up immediately after programming.

## Pin Mapping
- `LED_B4` → B4 (on-board LED)

## License
See the main repository LICENSE file.
