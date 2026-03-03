# Personal-Verilog-IP-Library

A collection of foundational modules I have made to learn the concepts of digital design.

## Modules Included

* **`simple_handshake`**: A clock domain crossing (CDC) module utilizing a full request/acknowledge handshake protocol to safely transfer data between asynchronous clock domains.
* **`simple_synchronizer`**: A basic 2-stage flip-flop synchronizer used to mitigate metastability when passing single-bit control signals across clock domains.
* **`simple_fifo`**: A synchronous First-In-First-Out memory buffer with configurable depth and data width, featuring parameterized full/empty flag generation.
* **`simple_interface`**: An 8-byte/64-bit communication interface state machine that decodes custom read/write commands, extracts addressing, and validates payloads via a checksum before executing bus transactions.
* **`simple_bus`**: A parameterized, memory-mapped slave device that interfaces with a simple read/write bus to store and retrieve data.

## Tools & Simulation

All modules are written in standard Verilog HDL and include corresponding testbenches (`*_tb.v`) for simulation and verification. 
