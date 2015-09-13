This is the code from the book "Beyond Games: Systems and Software for
your 6502 Personal Computer" by Ken Skier.

The same software, with some changes, was also published in the book
"Top Down Assembly Language Programming for your VIC-20 and Commodore
64", by the same author.

I do not own a copy, but the book "Top-Down Assembly Language
Programming for the 6502 Personal Computer" may also contain the same
or similar programs.

The .bas files are BASIC programs that can be used to load the
programs into memory, using OBJECTCODELOADER.bas.

The .s files are assembler source. They are intended to be assembled
with CC65 (See http://www.cc65.org). The source files are currently
incomplete.

This only includes the versions for the Ohio Scientific C-1P and Apple
II. Support for the PET 2001 and Atari 800 should only require
entering the appropriate system data blocks.

The software has been tested using the Ohio Scientific/Compukit UK101
emulator (http://osi.marks-lab.com/) as well as Briel Computers
Superboard III (http://www.brielcomputers.com/). It has also been
tested on an Apple //c.

On the Ohio Scientific platform, the easiest way to load the monitor
is to enter the OSI machine language monitor (answer "M" to the
D/C/W/M? prompt on power up). Then load the file visiblemonitor.lod by
pressing L and loading it from the serial port or cassette interface.
It will load and start automatically.

The file visiblemonitor-apple2.hex can be loaded into an Apple II
using the machine language monitor, over a serial port, for example.

Here is a summary of how to use the monitor:

Sample display:

                   A     X     Y     P
1135    4A    J   00    00    00    00
   ^
/|\    /|\   /|\ /|\   /|\   /|\   /|\
 |      |     |   |     |     |     +- P register
 |      |     |   |     |     +- Y register
 |      |     |   |     +- X register
 |      |     |   +- A register
 |      |     +- current address in ASCII
 |      +- Contents of the current address.
 +- Current address.

The caret ("^") shows which field is active for entry.

Key       Function
---       --------
0-9,A-F   Enter hex digit
>         Make next field active
<         Make previous field active
<space>   Advance to next address
<Return>  Move to previous address
G         Go (call) specified address
H         Call the hex dump tool
M         Call the move tool
P         Toggle the printer flag
T         Call the text editor
U         Toggle the user output flag
?         Call the disassembler

Editor Keys:

Control-F Flush buffer
Control-C Toggle between insert and overstrike
>         Move to next character in buffer
<         Move to previous character in buffer
Control-P Print the buffer
<Delete>  Delete the current character.
QQ        Quit the editor (enter two Q characters in a row).

Other notes:

The start address is 1207. From the OSI monitor you can start it by
typing .1207G

Jeff Tranter <tranter@pobox.com>
