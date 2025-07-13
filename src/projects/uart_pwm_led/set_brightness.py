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

def set_brightness(percentage, port=None):
    """Send brightness percentage (0-100) to FPGA as a byte (0-255)."""
    try:
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
            ser.write(bytes([byte_value]))  # Send single byte
            ser.flush()
            print(f"Set brightness to {percentage}% (byte value: {byte_value}) via {port}")

    except serial.SerialException as e:
        print(f"Error: Could not open serial port {port}: {e}")
        sys.exit(1)
    except ValueError as e:
        print(f"Error: Invalid percentage value: {e}")
        sys.exit(1)

def main():
    """Parse command-line arguments and set brightness."""
    parser = argparse.ArgumentParser(description="Set FPGA LED brightness via serial.")
    parser.add_argument('-b', '--brightness', type=int, required=True,
                        help='Brightness percentage (0-100)')
    parser.add_argument('-p', '--port', type=str,
                        help='Serial port (e.g., /dev/ttyACM0)')
    args = parser.parse_args()
    set_brightness(args.brightness, args.port)

if __name__ == "__main__":
    main() 