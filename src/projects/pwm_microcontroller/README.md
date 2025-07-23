
# PWM Microcontroller Example

This project demonstrates a simple 8-bit microcontroller implemented in Verilog, capable of controlling two PWM channels. The microcontroller is programmed via UART (serial) using the RX pin, and sends acknowledgments via the TX pin.

## Files
- `pwm_microcontroller.v`: Top-level Verilog module implementing the microcontroller, two PWM channels, and UART RX/TX logic.
- `pwm_microcontroller.pcf`: Constraints file mapping the PWM outputs and UART pins.
- `program.py`: Python script to test PWM functionality with different brightness levels

## How it works
- The microcontroller receives commands over UART to set the duty cycle of two PWM outputs.
- After each command, an acknowledgment byte is sent back via UART TX.
- PWM frequency is 1kHz for visible brightness changes.
- LED outputs are active-low (0 = LED ON, 1 = LED OFF).

### UART Protocol
- Send `0x01` followed by a value (0–255) to set PWM0 duty cycle.
- Send `0x02` followed by a value (0–255) to set PWM1 duty cycle.
- Send `0xFF` to reset both PWM channels to 0.
- After each command, the FPGA sends an ACK byte:
  - `0x55` for PWM set (PWM_SET_OK)
  - `0xAA` for reset (PWM_RESET_OK)

## Usage
1. Synthesize and upload the design to your iCESugar Nano FPGA using the `pwm_microcontroller.v` file as the top-level module.
2. Connect UART RX (A3) and TX (B3) to your host (USB-UART, microcontroller, etc.).
3. Use a serial terminal or Python script to send commands and receive ACKs.

### Building the Project
```bash
# Navigate to the project directory
cd src/projects/pwm_microcontroller

# Build using your preferred FPGA toolchain
# Example with yosys/nextpnr:
yosys -p "synth_ice40 -top pwm_microcontroller -json pwm_microcontroller.json" pwm_microcontroller.v
nextpnr-ice40 --up5k --package sg48 --pcf pwm_microcontroller.pcf --json pwm_microcontroller.json --asc pwm_microcontroller.asc
icepack pwm_microcontroller.asc pwm_microcontroller.bin
```

### Example Python Host Code
```python
import serial
import time

SERIAL_PORT = 'COM3'  # Change to your port
BAUD_RATE = 115200

def send_command(ser, cmd, value=None):
    ser.write(bytes([cmd]))
    if value is not None:
        ser.write(bytes([value]))
    ack = ser.read(1)
    if ack[0] == 0x55:
        print("PWM_SET_OK")
    elif ack[0] == 0xAA:
        print("PWM_RESET_OK")

with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1) as ser:
    time.sleep(2)
    send_command(ser, 0x01, 128)  # Set PWM0 to 128
    send_command(ser, 0x02, 64)   # Set PWM1 to 64
    send_command(ser, 0xFF)       # Reset both
```

### Testing
Run the comprehensive test script:
```bash
python program.py
```

This will test both PWM channels with different brightness levels (0%, 25%, 50%, 75%, 100%) and display readable ACK messages.

## Pin Mapping
- `clk`  → D1 (12 MHz from iCELink)
- `RX`   → A3 (UART RX)
- `TX`   → B3 (UART TX)
- `pwm0` → B4
- `pwm1` → C6

## ACK Messages
- **PWM_SET_OK (0x55)**: Sent when PWM duty cycle is successfully set
- **PWM_RESET_OK (0xAA)**: Sent when both PWM channels are reset to 0

## Recent Fixes
- **Fixed PWM frequency**: Changed from 47kHz to 1kHz for visible brightness changes
- **Integrated top-level functionality**: Made pwm_microcontroller.v the top-level module
- **Removed reset functionality**: No physical reset pin needed
- **Fixed PWM scaling**: Updated PWM output logic to properly scale 8-bit duty cycles to the larger period
- **Updated pin mappings**: Corrected documentation to match actual pin assignments
- **Enhanced testing**: Improved program.py with better error handling and brightness testing
- **Fixed LED polarity**: Inverted PWM outputs for active-low LEDs (0 = ON, 1 = OFF)
- **Readable ACK messages**: Added human-readable acknowledgment messages

## License
See the main repository LICENSE file.
