JMON - Jeff's Monitor Program
------------------------------

A machine language monitor program for the Apple Replica 1.

Commands:

ASSEMBLER:  A

Call a mini assembler which can assemble lines of 6502 code. Prompts
for the start address and then prompts for instructions. Does not
support symbols or labels, all values must be in hex with 2 or 4
digits and there is no backspace or other editing features. Press
<Enter> to terminate and assemble a line. Pressing <Esc> will cancel.

Sample session:

A 6000
6000: NOP
6001: LDX #0A
6003: JSR FFEF
6006: DEX
6007: BNE 6003
6009: <Esc>

BREAKPOINT: B <N> <ADDRESS>

Set up to 4 breakpoints, numbered 0 through 3.
"B ?" lists status of all breakpoints.
"B <n> <address>" sets breakpoint number <n> at address <address>
"B <n> 0000" removes breakpoint <n>.
Breakpoint number <n> is 0 through 3.

Set a breakpoint on an address where you want to go into the debugger
(mini-monitor). Puts a BRK there and saved original instruction. When
BRK is hit, puts original instruction back and jumps into the
mini-monitor at the address of the breakpoint. From there you can
continue, single step, etc. Once hit, a breakpoint is cleared and
needs to be set again. Breakpoints must be in RAM. IRQ/BRK vector must
be in RAM. Error is displayed if not. If the break handler is called
from an interrupt rather than a BRK instruction, a message is
displayed. If JMON is restarted, breakpoints are cleared.

COPY:       C <START> <END> <DEST>

Copy memory from address START through END to DEST. Range can overlap
but start address must be less than or equal to the end address.

DUMP:       D <START>

Dump memory in hex and ASCII a screen at a time. Press <Space> to
continue or <Esc> to cancel when prompted.

ACI MENU:    E

Calls the ACI (Apple Cassette Interface) firmware.
Reports an error if an ACI card is not present.
Note that the ACI firmware always quits to the Woz Monitor.

FILL:       F <START> <END> <DATA>...

Fill a range of memory with a hex data pattern. Data pattern can be of
any length up to 127 bytes. Press <Enter> after entering the pattern.

GO:        G <ADDRESS>

Run from an address. Before execution, restores the values of the
registers set by the R command. Uses JSR to the called routine can
return to JMON.

HEX TO DEC  H <ADDRESS>

Convert 16-bit hexadecimal number to signed binary.

BASIC:      I

Jump to Applesoft BASIC cold start entry point (address $E000). Does
not perform any check that the ROM-based BASIC is present.

MINI MON:   K

Jump to mini-monitor. Only valid for Krusader 6502 version 1.3.

CLR SCREEN:  L

Clear the screen by printing 24 newlines.

CFFA1 MENU: M

Calls the menu for the CFFA1 flash interface (address $9006). First
performs a check that a CFFA1 card is present and reports an error if
not. Quitting from the CFFA1 menu returns to JMON.

OPTION: O

Sets a number of program options. Prompts the user for the value of
each opion.

You can specify whether output is all uppercase or a mixture of upper
and lower (the Replica 1 supports lowercase, the original Apple 1 and
clones cannot display lowercase).

You specify the value for the delay after all writes to accommodate
slow EEPROMs. Applies to COPY, FILL, and TEST commands. Depending on
the manufacturer, anywhere from 0.5ms to 10ms may be needed. Value of
$20 works well for me (approx 1.5ms delay with 2MHz clock). See
routine WAIT for details on delay values versus delay time.

You can specify whether characters entered for the Fill, Search, and
":" commands have the high bit set (common for Apple 1 / Apple II
systems) or cleared (standard ASCII).

You can also specify the CPU type, either 6502, Rockwell 65C02, WDC
65C02, or 65816. This value is not currently used but may be used in
the future to control disassembly.

REGISTERS:  R

Displays the current value of the CPU registers A, X, Y, S, and P.
Then prompts to enter new values. Initial values are set from those
when JMON is entered. Uses any saved values when executing the Go
command. <Esc> cancels at any time.

SEARCH:     S <START> <END> <DATA>...

Search range of memory for a hex data pattern. Data pattern can be of
any length up to 127 bytes. Press <Enter> after entering the pattern.
After a match is found, prompts whether to continue the search.

TEST:       T <START> <END>

Test a range of memory. No check that memory is not used by the
running program. Not recommended to test writable EEPROM as it has a
limited number of write cycles.

UNASSEMBLE: U <START>

Disassemble memory a page at a time. Supports 65C02 op codes.

VERIFY:     V <START> <END> <DEST>

Verify that memory from start to end matches memory at destination.
Displays any mismatch. Prompts after each mismatch whether to
continue.

WOZ MON:    $

Jump to the Woz monitor (Address $FF00).

WRITE       : <ADDRESS> <DATA>...

Write hex data bytes to memory. Enter the start address followed by
data bytes. Starts a new line every multiple of 8 bytes. Press <Esc>
to cancel input.

MATH:        = <ADDRESS> +/- <ADDRESS>

Math command. Add or substract two 16-bit hex numbers.
Examples:
= 1234 + 0077 = 12AB
= FF00 - 0002 = FEFE

HELP:       ?

Displays a summary of JMON commands.

------------------------------------------------------------------------

Other notes:

Will run out of RAM or ROM.

The breakpoint feature may interfere with any other interrupt handlers
that might be installed.

The Fill, Search, and ":" commands accept characters as well as hex
values. Type ' to enter a single character.
