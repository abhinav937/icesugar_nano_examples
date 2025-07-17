# iCESugar Nano Development Examples

Example Verilog projects for the iCESugar Nano FPGA board demonstrating LED control, PWM effects, and UART communication.

## Structure

- `constraints/` - Pin Constraint File (`.pcf`) for iCESugar Nano
- `src/PE-Library/` - Verilog library templates
- `src/projects/` - Example projects
  - `blinky/` - Simple LED blink at 1 Hz
  - `pwm_led/` - PWM-based LED breathing effect
  - `train_leds/` - Pulsating effect across PMOD3 pins
  - `uart_pwm_led/` - UART-controlled LED brightness
  - `multi_led_uart/` - Multi-LED UART control with brightness setting

## Quick Start

```bash
git clone https://github.com/abhinav937/icesugar_nano_dev.git
cd icesugar_nano_dev
cd src/projects/blinky
```

## Projects

| Project | Description | Pin Mapping |
|---------|-------------|-------------|
| `blinky` | LED toggle at 1 Hz | LED → B6 |
| `pwm_led` | Breathing effect | LED → B6 |
| `train_leds` | PMOD3 strip effect | B4, B3, B2, B1, A4, A3, A2, A1 |
| `uart_pwm_led` | UART brightness control | LED → B6, UART → B7, B8 |
| `multi_led_uart` | Multi-LED UART control | PMOD3 pins, UART → B7, B8 |
| `lowpass_pwm_uart` | Low-pass filtered PWM demo with bar graph | B6 (filtered PWM), PMOD1-8 (bar graph) |

## UART Settings

- Baud rate: 115200
- Compatible with iCELink USB CDC interface
- Single-byte brightness values (0-255)

## Troubleshooting

- **LED not responding**: Check pin mapping in `.pcf` file
- **UART issues**: Verify baud rate is 115200
- **Build errors**: Ensure correct constraint file is used 