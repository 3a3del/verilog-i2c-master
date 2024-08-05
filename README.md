# Project Name: Single Port RAM and I2C EEPROM Controller

## Overview
This project includes two primary modules: a Single Port RAM module and an I2C EEPROM Controller. The project is designed to facilitate memory operations via a single port RAM and communication with an EEPROM using the I2C protocol.

## Modules

### 1. Single Port RAM
The Single Port RAM module provides basic read and write functionality. It is parameterizable in terms of data width.

#### Features
- Parameterizable data width (default is 8 bits)
- 256 memory locations
- Separate read and write enable signals

#### Ports
- `clk` (input): System clock
- `addr` (input): Address bus
- `wdata` (input): Data input for write
- `rdata` (output): Data output for read
- `we` (input): Write enable
- `re` (input): Read enable

### 2. I2C EEPROM Controller
The I2C EEPROM Controller module manages read and write operations to an EEPROM over the I2C bus. It includes a state machine to handle the I2C protocol.

#### Features
- Supports both read and write operations
- Uses a single port RAM for temporary data storage
- Includes an I2C state machine for protocol management

#### Ports
- `clk` (input): System clock
- `rst` (input): Reset signal
- `newd` (input): New data signal
- `ack` (input): Acknowledgment signal
- `wr` (input): Write/read control signal (1 = write, 0 = read)
- `scl` (output): Serial clock line for I2C
- `sda` (inout): Serial data line for I2C
- `wdata` (input): Data to be written
- `addr` (input): 7-bit address (8th bit is mode)
- `rdata` (output): Data read from EEPROM
- `done` (output): Operation done signal

## Design Details
### Single Port RAM
The RAM module is designed with a synchronous read and write capability. It utilizes an array of 256 memory locations, each capable of storing N-bit wide data.

### I2C EEPROM Controller
The EEPROM controller includes a state machine with states for handling idle, read, and write operations. It divides the system clock to generate the I2C clock and manages data transfer on the I2C bus. The state machine transitions through various states to handle the start, address sending, acknowledgment, data sending/receiving, and stop conditions as per the I2C protocol.

## Dependencies
This project does not have external dependencies.

## Revision History
- Revision 0.01: Initial file creation

## Additional Comments
- The memory initialization block in the Single Port RAM module is commented out. It can be uncommented for testing purposes.
- The I2C EEPROM Controller's state machine includes both write and read sequences, with a clock division for generating the I2C clock signal.

## Author
Engineer: Muhammed Adel
