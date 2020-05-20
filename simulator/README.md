This is a 6502 simulator to simulate an Ohio Scientific Superboard II
computer.

It is written in standard C++ and should be portable, but has only
been tested on Linux with the gcc compiler.

Command Line Options (proposed)
---------------------

-h --help            Show command line usage
-l <file> <address>  Load raw file in memory
-r <address>         Run from address immediately on startup, do not enter CLI
-v                   Show software version and copyright
-R                   Reset on startup
-l +/-<category>     Enable/disable logging of a category, e.g. registers instructions, video


Command Line Interface (proposed)
----------------------

Load <file>

- Make debug output optional
- Main program with command line/debug interface: load, run, reset,
  step, show registers, dump, breakpoints, watchpoints, edit memory,
  registers, disassemble, IRQ, NMI, save memory, show video screen
- Qt-based GUI
- Add support for multiple RAM ranges?
- Simulate OSI 6850 UART serial port for LOAD/SAVE
- Simulated Sound/Bank/Color/Video register
- Simulate BRK
- Simulate IRQ and NMI
- Option for Rockwell instructions
- Option for 65C02 instructions

ASSEMBLER: A
BREAKPOINT: B <N> <ADDRESS>

Set up to 4 breakpoints, numbered 0 through 3.
"B ?" lists status of all breakpoints.
"B <n> <address>" sets breakpoint number <n> at address <address>
"B <n> 0000" removes breakpoint <n>.
Breakpoint number <n> is 0 through 3.




Assemble     A <address>
Breakpoint   B <n or ?> <address>
Checksum     K <start> <end>",CR
Clear screen L
Copy         C <start> <end> <dest>
Dump         D <start>
Fill         F <start> <end> <data>...
Go           G <address>
Help         ?
Hex to dec   H <address>
Info         N
Math         = <address> +/- <address>
Options      O
Registers    R
Search       S <start> <end> <data>...
Test         T <start> <end>
Trace        .
Unassemble   U <start>
Show video   V
Verify       V <start> <end> <dest>
Write        : <address> <data>...
Reset        X
