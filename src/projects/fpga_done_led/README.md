# FPGA Done LED Example

This project demonstrates how to turn OFF the B4 LED on the iCESugar Nano board as soon as the FPGA is programmed ("done" state).

## Files
- `fpga_done_led.v`: Simple Verilog module that drives the B4 LED low when the FPGA is programmed.
- `fpga_done_led.pcf`: Constraints file mapping the `LED` signal to the B4 pin on the board.

## How it works
- The Verilog module assigns a constant low (`1'b0`) to the `LED` output.
- When the FPGA is programmed, the B4 LED will turn on, indicating the device is ready.

## Usage
1. Build and program the design using the [Lattice_NanoIce](https://github.com/abhinav937/Lattice_NanoIce) flash tool:
   ```bash
   cd src/projects/fpga_done_led
   flash fpga_done_led.v fpga_done_led.pcf
   ```
2. The B4 LED should turn off immediately after programming.

## Pin Mapping
- `LED` → B4 

## License
See the main repository LICENSE file.
