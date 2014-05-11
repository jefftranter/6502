This is the source code for a port of Apple II Monitor to the Apple 1.

The original port was done by Winston Gayler with additional
adaptations by Wendell Sander. The source code reverse-engineered and
ported to CA65 assembler by Jeff Tranter <tranter@pobox.com>.

See http://www.apple1notes.com/old_apple/Monitor_II_on_1.html

I adapted the original monitor source from the "Red Book" to build
under the CA65 assembler, then reverse engineered the patches for the
Apple 1. The code can be conditionally compiled for Apple II or Apple
1 and it can be relocated.

The default build address is $7500. The entry point for the Apple II
monitor is $7F65. The Mini-Assembler entry point is $7666. It has also
been tested at addresses $3500 and $6500.

Known Issues:

I have only tested this code on a Briel Replica 1, but it does match
the binaries posted by Wendell Sander (except for the area of memory
where SWEET16 would normally be, which seems to have "ghost" data from
another build of the monitor.) The source code here cannot generate
the build at $F000 which includes the Apple 1 Woz Monitor.

The Briel Replica 1 has RAM from $0000 - $7FFF and so can run any
version built for these addresses.

Control commands do not work from a Briel Replica 1 keyboard as it
does not support them. They will work if entered from serial port.
