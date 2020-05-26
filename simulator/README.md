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
Help         ?
Memory       M <address> <data> ...
Quit         Q
Registers    R [<register> <value>]
Dump Video   V
Reset        X
Trace        . [<instructions>]
Send IRQ     IRQ
Send NMI     NMI
Logging      L [<+/-><category>]
