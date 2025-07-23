# PWM LED Breathing Effect

This project demonstrates PWM (Pulse Width Modulation) to create a smooth breathing effect on an LED. The LED brightness smoothly increases and decreases in a continuous cycle.

## Features

- PWM-based LED breathing effect
- Smooth brightness transitions
- Continuous breathing cycle
- Demonstrates PWM generation and control

## Files

- `pwm_led.v` - Main Verilog module for PWM breathing effect
- `.ssh_push_config.json` - SSH configuration for remote development

## Usage

1. Build and program the design using the [Lattice_NanoIce](https://github.com/abhinav937/Lattice_NanoIce) flash tool:
   ```bash
   cd src/projects/pwm_led
   flash pwm_led.v pwm_led.pcf
   ```
   
   Or use ssh-push for remote development:
   ```bash
   cd src/projects/pwm_led
   ssh-push pwm_led.v pwm_led.pcf
   ```

2. The onboard LED (B6) should start breathing with smooth brightness transitions.

## Pin Mapping

- `clk` → D1 (12 MHz from iCELink)
- `LED` → B6 (onboard LED)

## Building Options

```bash
# Basic build and program
flash pwm_led.v pwm_led.pcf

# Verbose output for debugging
flash pwm_led.v pwm_led.pcf --verbose

# Build only (skip programming)
flash pwm_led.v pwm_led.pcf --build-only

# Set clock frequency (1=8MHz, 2=12MHz, 3=36MHz, 4=72MHz)
flash pwm_led.v pwm_led.pcf -c 2
```

## How It Works

The PWM module generates a triangular wave that controls the duty cycle of the PWM output. As the duty cycle increases, the LED gets brighter, and as it decreases, the LED dims, creating a smooth breathing effect.

## Troubleshooting

- **LED not breathing**: Check if the FPGA was programmed successfully
- **Build errors**: Ensure the constraint file is correct
- **Programming issues**: Check USB connection and run `flash -c 2` to test device status

## License

See the main repository LICENSE file. 