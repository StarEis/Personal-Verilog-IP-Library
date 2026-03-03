import serial
import time

ser = serial.Serial('COM4', 115200, timeout=1)

while True:
    msg = input("Message: ")
    ser.write(msg.encode())
    
    response = ser.read(1)
    if response:
        print(f"FPGA Echoed: {response.decode()}")
    else:
        print("No response from FPGA :(")