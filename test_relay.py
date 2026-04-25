import serial
import time

print("--- Relay Serial Test ---")
print("Make sure the Arduino Serial Monitor is CLOSED!")

try:
    print("Connecting to COM5...")
    ser = serial.Serial('COM5', 9600, timeout=1)
    time.sleep(2)  # Give ESP8266 time to reboot after serial connects
    print("Connected successfully!")
    
    for i in range(3):
        print("\nTurning ON Relay (Sending 'K1')...")
        ser.write(b"K1\n")
        time.sleep(2)
        
        print("Turning OFF Relay (Sending 'K0')...")
        ser.write(b"K0\n")
        time.sleep(2)
        
    print("\nTest complete! Closing connection.")
    ser.close()

except serial.SerialException as e:
    print(f"\n[ERROR] Could not connect to COM5. Is the Serial Monitor open? Error details: {e}")
except Exception as e:
    print(f"\n[ERROR] An unexpected error occurred: {e}")
