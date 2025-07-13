#!/usr/bin/env python3
"""
Multi-LED UART PWM Controller Test Script
Sends two-byte commands (LED ID + brightness) to control multiple LEDs
"""

import serial
import time
import sys
import argparse

def send_command(ser, led_id, brightness):
    """Send a two-byte command to control LED brightness"""
    command = bytes([led_id, brightness])
    ser.write(command)
    print(f"Sent: LED {led_id} = {brightness} ({brightness/255*100:.1f}%)")

def test_individual_leds(ser):
    """Test each LED individually"""
    print("\n=== Testing Individual LEDs ===")
    
    # Test each LED with different brightness levels
    for led_id in range(3):
        print(f"\nTesting LED {led_id}:")
        
        # Turn on gradually
        for brightness in [0, 64, 128, 192, 255]:
            send_command(ser, led_id, brightness)
            time.sleep(0.5)
        
        # Turn off
        send_command(ser, led_id, 0)
        time.sleep(0.5)

def test_patterns(ser):
    """Test various LED patterns"""
    print("\n=== Testing LED Patterns ===")
    
    # Pattern 1: All LEDs on at different levels
    print("\nPattern 1: All LEDs at different levels")
    send_command(ser, 0, 64)   # 25%
    send_command(ser, 1, 128)  # 50%
    send_command(ser, 2, 192)  # 75%
    time.sleep(2)
    
    # Pattern 2: Wave effect
    print("\nPattern 2: Wave effect")
    for i in range(3):
        send_command(ser, i, 255)
        time.sleep(0.3)
        send_command(ser, i, 0)
    
    # Pattern 3: All off
    print("\nPattern 3: All LEDs off")
    for led_id in range(3):
        send_command(ser, led_id, 0)

def main():
    parser = argparse.ArgumentParser(description='Test Multi-LED UART PWM Controller')
    parser.add_argument('port', help='Serial port (e.g., /dev/ttyACM0)')
    parser.add_argument('-b', '--baud', type=int, default=115200, help='Baud rate (default: 115200)')
    parser.add_argument('--led', type=int, choices=[0, 1, 2], help='Test specific LED only')
    parser.add_argument('--brightness', type=int, choices=range(0, 256), help='Set specific brightness (0-255)')
    
    args = parser.parse_args()
    
    try:
        # Open serial connection
        ser = serial.Serial(args.port, args.baud, timeout=1)
        print(f"Connected to {args.port} at {args.baud} baud")
        
        # Wait for connection to stabilize
        time.sleep(1)
        
        if args.led is not None and args.brightness is not None:
            # Set specific LED to specific brightness
            send_command(ser, args.led, args.brightness)
        elif args.led is not None:
            # Test specific LED with ramp
            print(f"\nTesting LED {args.led}:")
            for brightness in [0, 64, 128, 192, 255, 0]:
                send_command(ser, args.led, brightness)
                time.sleep(0.5)
        else:
            # Run full test sequence
            test_individual_leds(ser)
            test_patterns(ser)
        
        ser.close()
        print("\nTest completed!")
        
    except serial.SerialException as e:
        print(f"Serial error: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nTest interrupted by user")
        if 'ser' in locals():
            ser.close()

if __name__ == "__main__":
    main() 