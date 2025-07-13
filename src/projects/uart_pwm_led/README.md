# UART PWM LED Controller

Controls LED brightness via UART commands on iCESugar-nano board.

## Features

- UART receiver (115200 baud, 8N1)
- PWM output (1 kHz frequency)
- Single-byte brightness control (0-255)
- Compatible with iCELink USB CDC interface

## Usage

1. Connect iCESugar-nano to Raspberry Pi via USB
2. Send single bytes (0-255) to control LED brightness
3. 0 = LED off, 255 = full brightness

## Files

- `uart_pwm_led.v` - Main UART/PWM controller
- `uart_pwm_led.pcf` - Pin constraints


## Testing

### Percentage-based Control
```bash
# Set brightness using percentage (0-100%)
python set_brightness.py -b 50

# Specify port manually
python set_brightness.py -b 75 -p /dev/ttyACM0
```

## Troubleshooting

### LED not changing brightness
1. **Check UART reception**: Verify UART data is being sent correctly
2. **Verify PWM calculation**: The PWM threshold is calculated as `(brightness * PWM_PERIOD) / 256`
3. **Check initial brightness**: LED should start at 25% brightness (64/255)

## Pin Mapping

- `clk` → D1 (12 MHz from iCELink)
- `RX` → A3 (UART receive)
- `LED` → B6 (onboard LED) 