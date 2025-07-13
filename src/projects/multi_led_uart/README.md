# Multi-LED UART PWM Controller

Controls multiple LED brightnesses via UART commands on iCESugar-nano board using a two-byte protocol.

## Features

- UART receiver (115200 baud, 8N1)
- PWM output (1 kHz frequency) for 3 LEDs
- Two-byte command protocol (LED ID + brightness)
- Independent brightness control for each LED
- Compatible with iCELink USB CDC interface

## Protocol

Two-byte protocol:
1. **First byte**: LED ID (0-2)
2. **Second byte**: Brightness value (0-255)

### LED Mapping
- **ID 0**: LED_B6 (onboard LED, active-high)
- **ID 1**: LED_B4 (PMOD pin, active-low)
- **ID 2**: LED_C6 (PMOD pin, active-low)

### Example Commands
- `[0, 128]` - Set onboard LED to 50% brightness
- `[1, 255]` - Set LED_B4 to full brightness
- `[2, 0]` - Turn off LED_C6

## Usage

1. Connect iCESugar-nano to host via USB
2. Send two-byte commands to control individual LEDs
3. 0 = LED off, 255 = full brightness

## Files

- `multi_led_uart.v` - Main multi-LED UART/PWM controller
- `multi_led_uart.pcf` - Pin constraints
- `set_led_brightness.py` - Python controller script
- `test_multi_led.py` - Comprehensive test script

## Pin Mapping

- `CLK` → D1 (12 MHz from iCELink)
- `RX` → A3 (UART receive)
- `LED_B6` → B6 (onboard LED)
- `LED_B4` → B4 (PMOD pin)
- `LED_C6` → C6 (PMOD pin)

## Testing

### Quick Control Script
```bash
# Set onboard LED to 50% brightness
python set_led_brightness.py -l 0 -b 50

# Set LED_B4 to full brightness
python set_led_brightness.py -l 1 -b 100

# Turn off LED_C6
python set_led_brightness.py -l 2 -b 0

# Specify port manually
python set_led_brightness.py -l 0 -b 75 -p /dev/ttyACM0
```

### Comprehensive Test Script
```bash
# Run full test sequence
python test_multi_led.py /dev/ttyACM0

# Test specific LED
python test_multi_led.py /dev/ttyACM0 --led 1

# Set specific brightness
python test_multi_led.py /dev/ttyACM0 --led 2 --brightness 128
```

### Manual Serial Control
```python
import serial
ser = serial.Serial('/dev/ttyACM0', 115200)

# Set onboard LED to 50% brightness
ser.write(bytes([0, 128]))

# Set LED_B4 to full brightness
ser.write(bytes([1, 255]))

# Turn off LED_C6
ser.write(bytes([2, 0]))
```

## Troubleshooting

- **LED not responding**: Verify LED ID is valid (0-2)
- **UART issues**: Ensure baud rate is 115200
- **Invalid commands**: Controller ignores invalid LED IDs
- **Port detection**: The controller script automatically detects common iCELink ports 