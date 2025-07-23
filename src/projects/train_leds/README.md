# Train LEDs Pattern

This project creates a moving light pattern across 8 LEDs on PMOD3, simulating a train of lights that moves from one end to the other.

## Features

- Moving light pattern across 8 LEDs
- Simulates a train of lights
- Uses PMOD3 pins for LED control
- Demonstrates sequential LED control

## Files

- `train_leds.v` - Main Verilog module for train LED pattern
- `.ssh_push_config.json` - SSH configuration for remote development

## Usage

1. Build and program the design using the [Lattice_NanoIce](https://github.com/abhinav937/Lattice_NanoIce) flash tool:
   ```bash
   cd src/projects/train_leds
   flash train_leds.v train_leds.pcf
   ```
   
   Or use ssh-push for remote development:
   ```bash
   cd src/projects/train_leds
   ssh-push train_leds.v train_leds.pcf
   ```

2. Connect LEDs to PMOD3 pins and observe the moving light pattern.

## Pin Mapping

- `clk` → D1 (12 MHz from iCELink)
- `LED0` → B4 (PMOD3 pin 1)
- `LED1` → B3 (PMOD3 pin 2)
- `LED2` → B2 (PMOD3 pin 3)
- `LED3` → B1 (PMOD3 pin 4)
- `LED4` → A4 (PMOD3 pin 5)
- `LED5` → A3 (PMOD3 pin 6)
- `LED6` → A2 (PMOD3 pin 7)
- `LED7` → A1 (PMOD3 pin 8)

## Building Options

```bash
# Basic build and program
flash train_leds.v train_leds.pcf

# Verbose output for debugging
flash train_leds.v train_leds.pcf --verbose

# Build only (skip programming)
flash train_leds.v train_leds.pcf --build-only

# Set clock frequency (1=8MHz, 2=12MHz, 3=36MHz, 4=72MHz)
flash train_leds.v train_leds.pcf -c 2
```

## How It Works

The module implements a shift register that moves a single "1" bit through the LED outputs, creating the illusion of a moving light. The pattern repeats continuously, creating a train-like effect.

## Troubleshooting

- **No LED pattern**: Check PMOD3 connections and LED wiring
- **Build errors**: Ensure the constraint file is correct
- **Programming issues**: Check USB connection and run `flash -c 2` to test device status

## License

See the main repository LICENSE file. 