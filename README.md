# 1802-pico-basic
A FPGA System-on-Chip design encompassing a CDP1802 CPU core, RAM, 16 bit GPIO (General Purpose Input Output)
and ROM containing UT4 and Tiny BASIC images. The project and constraint files are for Lattice Diamond (3.8)
the intended target is the Lattice MachXO2 Pico board. After building and downloading the configuration to
the FPGA, a terminal emulation program is used for communication using the USB/Serial converter built into
the development board. The UT4 monitor is used to examine memory, modify RAM and run programs. From UT4 the
Tiny BASIC interpreter can be invoked. 4K of RAM is available for user programs written in either machine code
or BASIC. The 16 GPIO bits are available on the Pico board header each can be set to input or output, controlled
by 16 consecutive memory locations accessible from UT4 and BASIC.

Although designed with the MachXO2 in mind this project should easily build for other FPGA targets with very 
little modification. The RAM can be expanded and extra peripherals added.

## Status

The CDP1802 core (MX18) has these limitations / differences compared with a real CDP1802:

* Interrupts and DMA are not implemented
* SAV and MARK instructions not fully implemented or tested
* Designed to work with synchronous memory and peripherals
* 3 clock cycles per processor state (a real 1802 uses 8)

The 1802 core itself has been tested by running several monitor programs and FIG-Forth. Development will
continue a version with working interrupts and DMA will be available soon.
## Files

| Filename             | Description                               |
| -------------------- | ----------------------------------------- |
| pico_basic.vhd       | Top level                                 |
| mx18.vhd             | CDP1802 CPU Core                          |
| ram.vhd              | 4K x 8 RAM                                |
| tiny_basic.vhd       | Tiny BASIC ROM - Copyright Tom Pittman    |
| ut4.vhd              | UT4 Monitor ROM                           |
| gpio.vhd             | GPIO unit (2 X 8-bit)                     |
| pico_basic.lpf       | Lattice Diamond constraints file          |
| pico_basic.ldf       | Lattice Diamond project file              |

## Further information
## Usefull links

