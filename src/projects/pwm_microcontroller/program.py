import serial
import time

# Change to your serial port (e.g., 'COM3' on Windows, '/dev/ttyUSB0' on Linux)
SERIAL_PORT = '/dev/ttyACM0'
BAUD_RATE = 115200

def send_command(ser, cmd, value=None):
    """Send a command and wait for ACK"""
    ser.write(bytes([cmd]))
    if value is not None:
        ser.write(bytes([value]))
    # Wait for ACK
    ack = ser.read(1)
    if ack:
        ack_byte = ack[0]
        if ack_byte == 0x55:
            print(f"ACK received: PWM_SET_OK (0x{ack.hex().upper()})")
        elif ack_byte == 0xAA:
            print(f"ACK received: PWM_RESET_OK (0x{ack.hex().upper()})")
        else:
            print(f"ACK received: UNKNOWN (0x{ack.hex().upper()})")
        return True
    else:
        print("No ACK received!")
        return False

def test_pwm_brightness(ser, channel, brightness):
    """Test PWM brightness for a specific channel"""
    cmd = 0x01 if channel == 0 else 0x02
    print(f"Setting PWM{channel} to {brightness} ({brightness/255*100:.1f}%)")
    return send_command(ser, cmd, brightness)

def main():
    try:
        with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1) as ser:
            print("Connecting to PWM Microcontroller...")
            time.sleep(2)  # Wait for FPGA to be ready

            print("\n=== PWM Microcontroller Test ===")
            
            # Test PWM0 with different brightness levels
            print("\n--- Testing PWM0 ---")
            test_pwm_brightness(ser, 0, 0)      # Off
            time.sleep(0.5)
            test_pwm_brightness(ser, 0, 64)     # 25%
            time.sleep(0.5)
            test_pwm_brightness(ser, 0, 128)    # 50%
            time.sleep(0.5)
            test_pwm_brightness(ser, 0, 192)    # 75%
            time.sleep(0.5)
            test_pwm_brightness(ser, 0, 255)    # 100%
            time.sleep(0.5)

            # Test PWM1 with different brightness levels
            print("\n--- Testing PWM1 ---")
            test_pwm_brightness(ser, 1, 0)      # Off
            time.sleep(0.5)
            test_pwm_brightness(ser, 1, 64)     # 25%
            time.sleep(0.5)
            test_pwm_brightness(ser, 1, 128)    # 50%
            time.sleep(0.5)
            test_pwm_brightness(ser, 1, 192)    # 75%
            time.sleep(0.5)
            test_pwm_brightness(ser, 1, 255)    # 100%
            time.sleep(0.5)

            # Reset both PWM channels
            print("\n--- Resetting both PWM channels ---")
            send_command(ser, 0xFF)

            print("\nTest completed!")

    except serial.SerialException as e:
        print(f"Serial error: {e}")
        print(f"Make sure the device is connected to {SERIAL_PORT}")
        print("Common ports:")
        print("  Windows: COM3, COM4, COM5...")
        print("  Linux/Mac: /dev/ttyACM0, /dev/ttyUSB0...")
    except KeyboardInterrupt:
        print("\nTest interrupted by user")

if __name__ == "__main__":
    main()