import serial
import time
import struct

try:
    ser = serial.Serial('COM4', 115200, timeout=1) # Check your COM port!
except:
    print("❌ Could not open port.")
    exit()

def send_packet(payload):
    # 1. Prepare Data
    length = len(payload)
    
    # 2. Calculate Checksum: (Length + Sum(Payload)) % 256
    checksum = (length + sum(payload)) % 256
    
    print(f"Sending Packet: Len={length}, Payload={payload}, Checksum={checksum}")
    
    # 3. Construct Packet: [Header 0xAA] [Len] [Payload...] [Checksum]
    packet = bytearray([0xAA, length]) + bytearray(payload) + bytearray([checksum])
    
    ser.write(packet)
    
    # 4. Wait for ACK (0x06) or NACK (0x15)
    response = ser.read(1)
    
    if response == b'\x06':
        print("✅ FPGA said: ACK (Valid)")
        return True
    elif response == b'\x15':
        print("❌ FPGA said: NACK (Invalid)")
        return False
    else:
        print(f"⚠️ No Response or Garbage: {response}")
        return False

print("--- STARTING PROTOCOL TEST ---")

# Test 1: Simple Valid Packet
print("\nTest 1: Valid Packet [10, 20, 30]")
send_packet([10, 20, 30]) 

# Test 2: Another Valid Packet
print("\nTest 2: Valid Packet [1, 1, 1, 1, 1]")
send_packet([1, 1, 1, 1, 1])

# Test 3: INVALID Packet (We intentionally send the WRONG checksum)
print("\nTest 3: Corrupted Packet (Simulating Noise)")
# Manually send bad data
bad_pkt = bytearray([0xAA, 0x02, 0x10, 0x10, 0xFF]) # 0xFF is wrong checksum
ser.write(bad_pkt)
resp = ser.read(1)
if resp == b'\x15':
    print("✅ FPGA said: NACK (Correctly detected error)")
else:
    print(f"❌ Failed to detect error. Got: {resp}")

ser.close()