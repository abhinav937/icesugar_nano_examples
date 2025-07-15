#!/usr/bin/env python3
import serial
import argparse
import sys
import os

# Configure serial port for iCELink (adjust port as needed)
DEFAULT_PORTS = ['/dev/ttyACM0', '/dev/ttyAMA10', '/dev/ttyprintk']  # Common iCELink ports
BAUD_RATE = 115200            # Matches UART baud rate in FPGA design

def find_icelink_port():
    """Try to find the iCELink port automatically."""
    for port in DEFAULT_PORTS:
        if os.path.exists(port):
            try:
                with serial.Serial(port, BAUD_RATE, timeout=0.1) as ser:
                    return port
            except serial.SerialException:
                continue
    return None

def set_led_brightness(led_id, percentage, port=None):
    """Send LED ID (0-2) and brightness percentage (0-100) to FPGA as two bytes (ID + brightness 0-255)."""
    try:
        # Validate LED ID
        led_id = int(led_id)
        if not 0 <= led_id <= 2:
            print("Error: LED ID must be 0 (B6), 1 (B4), or 2 (C6)")
            sys.exit(1)

        # Validate percentage
        percentage = int(percentage)
        if not 0 <= percentage <= 100:
            print("Error: Brightness must be between 0 and 100%")
            sys.exit(1)

        # Convert percentage to byte (0-255)
        byte_value = int(round(percentage * 255 / 100))
        
        # Ensure byte_value is within valid range
        byte_value = max(0, min(255, byte_value))

        # Use provided port or try to find iCELink port
        if port is None:
            port = find_icelink_port()
            if port is None:
                print("Error: Could not find iCELink port. Try specifying with -p option.")
                print("Common ports:", ', '.join(DEFAULT_PORTS))
                sys.exit(1)

        # Open serial port
        with serial.Serial(port, BAUD_RATE, timeout=1) as ser:
            ser.write(bytes([led_id, byte_value]))  # Send two bytes: ID + brightness
            ser.flush()
            print(f"Set LED {led_id} (pin {'B6' if led_id == 0 else 'B4' if led_id == 1 else 'C6'}) brightness to {percentage}% (byte value: {byte_value}) via {port}")

    except serial.SerialException as e:
        print(f"Error: Could not open serial port {port}: {e}")
        sys.exit(1)
    except ValueError as e:
        print(f"Error: Invalid input value: {e}")
        sys.exit(1)

def main():
    """Parse command-line arguments and set LED brightness."""
    parser = argparse.ArgumentParser(
        description="Set FPGA LED brightness via serial.",
        epilog="""
Example usage:
  python3 set_led_brightness.py -l 1 -b 75
  python3 set_led_brightness.py --led 2 --brightness 100 --port /dev/ttyACM0

LED IDs:
  0 = B6 (default LED)
  1 = B4
  2 = C6

Brightness:
  0 = off
  100 = full brightness

If --port is not specified, the script will try to auto-detect the iCELink serial port.
""",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument('-l', '--led', type=int, required=True,
                        help='LED ID (0 = B6, 1 = B4, 2 = C6)')
    parser.add_argument('-b', '--brightness', type=int, required=True,
                        help='Brightness percentage (0-100, where 0 = off, 100 = full brightness)')
    parser.add_argument('-p', '--port', type=str,
                        help='Serial port (e.g., /dev/ttyACM0). If omitted, auto-detects common iCELink ports.')
    args = parser.parse_args()
    set_led_brightness(args.led, args.brightness, args.port)

if __name__ == "__main__":
    main() 