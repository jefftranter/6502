This is the source code for a port of Apple II Monitor to the Apple 1.

The original port was done by Winston Gayler with additional
adaptations by Wendell Sander. The source code reverse-engineered and
ported to CA65 assembler by Jeff Tranter <tranter@pobox.com>.

See http://www.apple1notes.com/old_apple/Monitor_II_on_1.html

I adapted the original monitor source from the "Red Book" to build
under the CA65 assembler, then applied the patches for the Apple 1.

The default build address is $7500. The entry point for the Apple II
monitor is $7F65. The Mini-Assembler entry point is $7666. It has also
been tested at addresses $3500 and $6500. The Briel Replica 1 has RAM
from $0000 to $7FFF and so can run any version built within this
address range.

The source code here can also generate the build at $F400 which
includes the Apple 1 Woz Monitor at the end. This build is intended to
be burned into ROM.

Known Issues:

I have only tested this code on a Briel Replica 1, but it does match
the binaries posted by Wendell Sander (except for the area of memory
where SWEET16 would normally be, which seems to have "ghost" data from
another build of the monitor.)

I have not tested whether it will run out of ROM, only RAM.

Control commands do not work from a Briel Replica 1 keyboard as it
does not support them. They will work if entered from the serial port.
