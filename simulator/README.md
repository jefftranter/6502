This is a 6502 simulator to simulate an Ohio Scientific Superboard II
computer.

It is a work in progress. It is able to run the OSI Monitor and BASIC,
but is still pretty rough around the edges.

It is written in standard C++ and should be portable, but has only
been tested on Linux with the gcc compiler.

Usage: sim6502 [<options>]
Options:
-h                   Show command line usage
-v                   Show software version and copyright
-l <file>            Load raw file into memory
-a <address>         Address to load raw file
-r <address>         Set PC to address
-R                   Don't reset on startup

Commands:
Breakpoint   B [-][<address>]
Dump         D [<start>] [<end>]
Go           G [<address>]
Logging      L [<+/-><category>]
Memory       M <address> <data> ...
Options      O
Quit         Q
Registers    R [<register> <value>]
Unassemble   U [<address>] [<end>]
Dump Video   V
Watchpoint   W [-][<address>] r,w,rw
Reset        X
Step         . [<instructions>]
Step Over    +
Send IRQ     IRQ
Send NMI     NMI

Breakpoints or watchpoints can be added by specifying an address, or
removed by preceding the address with a minus sign. Breakpoints cause
execution to stop when an instruction is fetched at that address.
Watchpoints stop when memory is read or written from that address. You
append "r", "w", or "rw" to a watchpoint to indicate that it should
trigger on a read, write, or both.

Logging can be enabled or disabled by prepending a category name with
"+" or "-" respectively. Tying just "L" will list the logging
categories.

The Dump command will dump a range of addresses, dump 16 addresses if
the end address is not specified, or continue after the last address
if no arguments are specified.

The serial port is simulated by reading input from a file serial.in
and output to the file serial.out. This allows using the BASIC LOAD
and SAVE commands to load and save programs.
