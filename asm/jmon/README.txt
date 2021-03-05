JMON - Jeff's Monitor Program
------------------------------

A machine language monitor program for the Apple Replica 1, Apple II,
Ohio Scientific Challenger 1P/Superboard II, Briel Superboard ///, or
MOS Technology KIM-1.

Copyright (C) 2012-2021 by Jeff Tranter <tranter@pobox.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Commands:

ASSEMBLER: A

Call a mini assembler which can assemble lines of 6502 or 65C02 code.
Prompts for the start address and then prompts for instructions. Does
not support symbols or labels. All values must be in hex with 2 or 4
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

Set a breakpoint on an address where you want to go into the trace
routine. Puts a BRK there and saved original instruction. When BRK is
hit, puts original instruction back and jumps into JMON and saves the
values of the current registers. From there you can single step,
change registers, etc. Once hit, a breakpoint is cleared and needs to
be set again. Breakpoints must be in RAM and the IRQ/BRK vector must
be in RAM (an error is displayed if it is not). If the break handler
is called from an interrupt rather than a BRK instruction, a message
is displayed and a return from interrupt executed. If JMON is
restarted, breakpoints are cleared. If a BRK instruction is encountered
that does not match a breakpoint set in JMON, a message is displayed.

COPY: C <START> <END> <DEST>

Copy memory from address START through END to DEST. Range can overlap
but start address must be less than or equal to the end address.

DUMP: D <START>

Dump memory in hex and ASCII a screen at a time. Press <Space> to
continue or <Esc> to cancel when prompted.

ACI MENU: E

Calls the ACI (Apple Cassette Interface) firmware. Reports an error if
an ACI card is not present. Note that the ACI firmware always goes to
the Woz Monitor on exit. This command applies to the Replica 1 only.

FILL: F <START> <END> <DATA>...

Fill a range of memory with a hex data pattern. Data pattern can be of
any length up to 127 bytes. Press <Enter> after entering the pattern.

GO: G <ADDRESS>

Run from an address. Before execution, restores the values of the
registers set by the R command. Uses JSR so the called routine can
return to JMON. Uses the PC value set by the Registers command if
you hit <Enter> when prompted for the address.

HEX TO DEC: H <ADDRESS>

Convert 16-bit hexadecimal number to signed binary.

BASIC: I

Jump to the Applesoft or OSI BASIC cold start entry point (address
$E000/$BD11). This will typically overwrite JMON.

S RECORD LOADER: J

Load a Motorola hex (RUN or S record) format file into memory. Exits
if <ESC> is received at any time or after an S9 record is received.
Executes the loaded code if the start address is non-zero.

CHECKSUM: K <START> <END>

Calculate a 16-bit checksum of memory from addresses START to END.

CLR SCREEN: L

Clear the screen by printing 24 newlines (or clearing video memory on
the Replica ///).

CFFA1 MENU: M

Calls the menu for the CFFA1 flash interface (address $9006). First
performs a check that a CFFA1 card is present and reports an error if
not. Quitting from the CFFA1 menu returns to JMON. This command
applies to the Replica 1 only.

INFO: N

Display information about the system. Sample output:

         CPU type: 65C02
      Clock speed: 2.0 MHz
RAM detected from: $0000 to $8FFF
       NMI vector: $0F00
     RESET vector: $FF00
   IRQ/BRK vector: $0100
         ACI card: not present
       CFFA1 card: present
   Multi I/O Card: not present
        BASIC ROM: present
     Krusader ROM: present
       WozMon ROM: present

Some information applies to the Replica 1 only.

OPTION: O

Sets a number of program options. Prompts the user for the value of
each option.

You can specify whether output is all uppercase or a mixture of upper
and lower (the original Apple 1 and clones cannot display lowercase).

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
the future to control assembly and disassembly.

REGISTERS: R

Displays the current value of the CPU registers A, X, Y, S, and P.
Also disassembles the instruction at the current PC. Then prompts to
enter new values. Uses any saved values when executing the Go command.
<Esc> cancels at any time. Pressing <Enter> when prompted for a new
register value will keep the current value and advance to the next
register. The trace function uses the values of the registers.

SEARCH: S <START> <END> <DATA>...

Search range of memory for a hex data pattern. Data pattern can be of
any length up to 127 bytes. Press <Enter> after entering the pattern.
After a match is found, prompts whether to continue the search.

TEST: T <START> <END>

Test a range of memory. No check that memory is not used by the
running program. Not recommended to test writable EEPROM as it has a
limited number of write cycles.

UNASSEMBLE: U <START>

Disassemble memory a page at a time. Supports 65C02 and 65816 op
codes.

VERIFY: V <START> <END> <DEST>

Verify that memory from start to end matches memory at destination.
Displays any mismatch. Prompts after each mismatch whether to
continue.

S RECORD WRITE: W <START> <END> <GO>

Outputs a Motorola hex (RUN or S record) format file from memory.
Range of memory is from <START> to <END> with the go or execution
start address <GO>.

WOZ MON: $

Jump to the Woz monitor (Address $FF00) or OSI monitor (Address
$FE00).

WRITE: : <ADDRESS> <DATA>...

Write hex data bytes to memory. Enter the start address followed by
data bytes. Starts a new line every multiple of 8 bytes. Press <Esc>
to cancel input.

MATH: = <ADDRESS> +/- <ADDRESS>

Math command. Add or subtract two 16-bit hex numbers.
Examples:
= 1234 + 0077 = 12AB
= FF00 - 0002 = FEFE

TRACE: .

The "." command single steps one instruction at a time showing the CPU
registers. Starts with the register values listed by the R command.
Updates them after single stepping. The command supports
tracing/stepping through ROM as well as RAM.

HELP: ?

Displays a summary of JMON commands.

------------------------------------------------------------------------

Other notes:

JMON will run out of RAM or ROM.

The breakpoint feature may interfere with any other interrupt handlers
that might be installed. It will fail if code writes over the break
handler code (three bytes starting at $0100).

The Fill, Search, and ":" commands accept characters as well as hex
values. Type ' to enter a single character.

Running on a KIM-1 requires a system with at least 9K of additional
RAM.
