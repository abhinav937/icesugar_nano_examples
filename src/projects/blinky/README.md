# Blinky LED Example

A simple LED blink example for the iCESugar Nano FPGA board. This project demonstrates basic FPGA programming by toggling an LED at 1 Hz frequency.

## Features

- Simple LED toggle at 1 Hz frequency
- Perfect for first-time FPGA users
- Demonstrates basic Verilog synthesis and programming

## Files

- `blinky.v` - Main Verilog module for LED blinking
- `.ssh_push_config.json` - SSH configuration for remote development

## Usage

1. Build and program the design using the [Lattice_NanoIce](https://github.com/abhinav937/Lattice_NanoIce) flash tool:
   ```bash
   cd src/projects/blinky
   flash blinky.v blinky.pcf
   ```
   
   Or use ssh-push for remote development:
   ```bash
   cd src/projects/blinky
   ssh-push blinky.v blinky.pcf
   ```

2. The onboard LED (B6) should start blinking at 1 Hz frequency.

## Pin Mapping

- `clk` → D1 (12 MHz from iCELink)
- `LED` → B6 (onboard LED)

## Building Options

```bash
# Basic build and program
flash blinky.v blinky.pcf

# Verbose output for debugging
flash blinky.v blinky.pcf --verbose

# Build only (skip programming)
flash blinky.v blinky.pcf --build-only

# Set clock frequency (1=8MHz, 2=12MHz, 3=36MHz, 4=72MHz)
flash blinky.v blinky.pcf -c 2
```

## Troubleshooting

- **LED not blinking**: Check if the FPGA was programmed successfully
- **Build errors**: Ensure the constraint file is correct
- **Programming issues**: Check USB connection and run `flash -c 2` to test device status

## License

See the main repository LICENSE file. 