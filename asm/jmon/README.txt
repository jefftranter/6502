JMON - Simple Monitor Program
-----------------------------

Fills some gaps missing from Woz monitor.

Commands:

ASSEMBLER:  A

Jumps to Krusader assembler.

BREAKPOINT: B <N> <ADDRESS>

Set up to 4 breakpoints, numbered 0 through 3.
"B ?" lists status of all breakpoints.
"B <n> <address>" sets breakpoint number <n> at address <address>
"B <n> 0000" removes breakpoint <n>.
Breakpoint number <n> is 0 through 3.

Set a breakpoint on an address where you want to go into the debugger (mini-monitor).
Puts a BRK there and saved original instruction.
When BRK is hit, puts original instruction back and jumps into the mini-monitor at the address of the breakpoint.
From there you can continue, single step, etc.
Once hit, a breakpoint is cleared and needs to be set again.
Breakpoints must be in RAM. IRQ/BRK vector must be in RAM. Error is displayed if not.

COPY:       C <START> <END> <DEST>

Copy memory from START through END to DEST.
Range can overlap but start address must be <= end address.

DUMP:       D <START>

Dump memory in hex and ASCII a screen at a time.

FILL:       F <START> <END> <DATA>

Fill a range of memory with a 16-bit pattern.

HEX TO DEC  H <ADDRESS>

Convert 16-bit hexadecimal number to signed binary.

BASIC:      I

Jump to Applesoft BASIC.

MINI MON:   K

Jump to mini-monitor. Only valid for Krusader 6502 version 1.3.

RUN:        R <ADDRESS>

Run from an address.

SEARCH:     S <START> <END> <DATA>

Search range of memory for a 16-bit data pattern.

TEST:       T <START> <END>

Test a range of memory. No check that memory is not used by running program.
Not recommended to test writable EEPROM as it has a limited number of write cycles.

UNASSEMBLE: U <START>

Disassemble memory a page at a time. Supports 65C02 op codes.

VERIFY:     V <START> <END> <DEST>

Verify that memory from start to end matches memory at destination.

WRITE DELAY:   W <DATA>

Add a delay after all writes to accommodate slow EEPROMs.
Applies to COPY, FILL, and TEST commands.
Depending on the manufacturer, anywhere from 0.5ms to 10ms may be needed.
Value of $20 works well for me (approx 1.5ms delay with 2MHz clock).
See routine WAIT for details on delay values versus delay time.

WOZ MON:    $

Jump to the Woz monitor.

HELP:       ?

Displays summary of  commands.

------------------------------------------------------------------------

Other notes:

Will run out of RAM or ROM.
Breakpoint feature will interfere with any interrupt handlers.
