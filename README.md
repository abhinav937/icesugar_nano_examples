# iCESugar Nano Development Examples

A comprehensive collection of Verilog projects for the iCESugar Nano FPGA board demonstrating LED control, PWM effects, UART communication, and microcontroller implementations.

## Structure

- `constraints/` - Pin Constraint File (`.pcf`) for iCESugar Nano
- `src/PE-Library/` - Verilog library templates
- `src/projects/` - Example projects organized by complexity

## Quick Start

```bash
git clone https://github.com/abhinav937/icesugar_nano_examples.git
cd icesugar_nano_examples
cd src/projects/blinky
```

## Projects Overview

### Basic LED Projects
| Project | Description | Pin Mapping |
|---------|-------------|-------------|
| `blinky` | Simple LED blink at 1 Hz | LED → B6 |
| `pwm_led` | PWM-based LED breathing effect | LED → B6 |
| `train_leds` | Pulsating effect across PMOD3 pins | B4, B3, B2, B1, A4, A3, A2, A1 |
| `fpga_done_led` | Turn off B4 LED when FPGA is programmed | LED → B4 |

### UART Communication Projects
| Project | Description | Pin Mapping |
|---------|-------------|-------------|
| `uart_pwm_led` | UART-controlled LED brightness | LED → B6, UART → B7, B8 |
| `multi_led_uart` | Multi-LED UART control with brightness setting | PMOD3 pins, UART → B7, B8 |
| `lowpass_pwm_uart` | Low-pass filtered PWM demo with bar graph | B6 (filtered PWM), PMOD1-8 (bar graph) |

### Advanced Control Projects
| Project | Description | Pin Mapping |
|---------|-------------|-------------|
| `pwm_microcontroller` | 8-bit microcontroller with dual PWM channels | PWM0 → B4, PWM1 → C6, UART → A3, B3 |
| `closed_loop_control` | Closed-loop control system with UART feedback | PWM → B6, UART → A3, B3 |

## Project Details

### Basic LED Projects

**blinky** - Simple LED toggle at 1 Hz frequency, perfect for first-time FPGA users.

**pwm_led** - Demonstrates PWM (Pulse Width Modulation) to create a smooth breathing effect on an LED.

**train_leds** - Creates a moving light pattern across 8 LEDs on PMOD3, simulating a train of lights.

**fpga_done_led** - Shows how to control an LED based on the FPGA's programming state.

### UART Communication Projects

**uart_pwm_led** - Controls LED brightness via UART commands, demonstrating serial communication.

**multi_led_uart** - Advanced UART control for multiple LEDs with individual brightness control.

**lowpass_pwm_uart** - Combines PWM with low-pass filtering and includes a visual bar graph display.

### Advanced Control Projects

**pwm_microcontroller** - Implements a simple 8-bit microcontroller with:
- Dual PWM channels (1kHz frequency)
- UART RX/TX communication
- Command protocol for PWM control
- Acknowledgment system

**closed_loop_control** - Demonstrates closed-loop control with:
- UART voltage input (0-255 representing 0.0V-25.5V)
- Proportional control law: d[n] = 0.4167 + Kp*(5 - Vout[n])
- 10kHz PWM output
- Real-time duty cycle feedback via UART

## UART Settings

- **Baud rate**: 115200
- **Data format**: 8N1 (8 data bits, no parity, 1 stop bit)
- **Compatible with**: iCELink USB CDC interface

## Building and Programming Projects

This repository uses a custom workflow with the [Lattice_NanoIce](https://github.com/abhinav937/Lattice_NanoIce) flash tool and [ssh-push](https://github.com/abhinav937/ssh-push) for FPGA programming.

### Prerequisites

1. **Install Lattice_NanoIce Flash Tool**:
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/abhinav937/Lattice_NanoIce/main/install.sh)
   ```

2. **Install ssh-push** (if not already installed):
   ```bash
   # Clone and install ssh-push
   git clone https://github.com/abhinav937/ssh-push.git
   cd ssh-push
   ./install.sh
   ```

### Building and Programming

```bash
# Navigate to any project directory
cd src/projects/[project_name]

# Build and program using the flash tool
flash [module_name].v [module_name].pcf

# Example for blinky project:
cd src/projects/blinky
flash blinky.v blinky.pcf

# Example for pwm_microcontroller:
cd src/projects/pwm_microcontroller
flash pwm_microcontroller.v pwm_microcontroller.pcf
```

### Advanced Flash Tool Options

```bash
# Verbose output for debugging
flash [module_name].v [module_name].pcf --verbose

# Build only (skip programming)
flash [module_name].v [module_name].pcf --build-only

# Set clock frequency (1=8MHz, 2=12MHz, 3=36MHz, 4=72MHz)
flash [module_name].v [module_name].pcf -c 2

# Force drag-and-drop programming
flash [module_name].v [module_name].pcf --force-dragdrop
```

### Alternative: Using ssh-push

For remote development or automated builds:

```bash
# Push and program via SSH
ssh-push [remote_host] [module_name].v [module_name].pcf

# Example
ssh-push my-fpga-device blinky.v blinky.pcf
```

## Testing

Most projects include Python test scripts for UART communication:
- `uart_pwm_led/set_brightness.py`
- `multi_led_uart/set_led_brightness.py`
- `multi_led_uart/test_multi_led.py`
- `pwm_microcontroller/program.py`

## Troubleshooting

- **LED not responding**: Check pin mapping in `.pcf` file
- **UART issues**: Verify baud rate is 115200 and port settings
- **Build errors**: Ensure correct constraint file is used
- **Programming issues**: Check USB connection and driver installation
- **Flash tool issues**: Run `flash --help` for available options
- **Device not detected**: Check USB connection and run `flash -c 2` to test device status

## Hardware Requirements

- iCESugar Nano FPGA board
- USB cable for programming and UART communication
- Optional: External LEDs or PMOD modules for expanded functionality

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve these examples.

## License

See the LICENSE file for details. 