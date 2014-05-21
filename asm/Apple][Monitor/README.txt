This is the source code for a port of Apple II Monitor to the Apple 1.

The original port was done by Winston Gayler with additional
adaptations by Wendell Sander. The Apple II source was code
reverse-engineered and ported to the CA65 assembler by me, Jeff
Tranter <tranter@pobox.com>.

See http://www.apple1notes.com/old_apple/Monitor_II_on_1.html

I adapted the original monitor source from the "Red Book" to build
under the CA65 assembler, then applied the patches for the Apple 1.

The default build address is $7500. It can also be built for other
addresses. The table below lists the supported link addresses and the
start addresses of the Monitor and Mini-Assembler for each address.
The build at $F400 includes the Apple 1 Woz Monitor at the end. This
build is intended to be burned into ROM.

Origin  Monitor  Mini-Assembler
------  -------  --------------
$3500   $3F65    $7666
$6500   $6F65    $6666
$7500   $7F65    $7666
$B500   $BF65    $B666
$F400   $FE59    $F566

Known Issues:

The generated code matches the binaries posted by Wendell Sander
except for the area of memory where SWEET16 would normally be, which
seems to have "ghost" data from another build of the monitor.

I have tested this code on a Briel Replica 1. Control commands do not
work when using a PS/2 keyboard as the Replica 1 does not support
them. They will work if entered from the serial port. The Briel
Replica 1 has RAM from $0000 to $7FFF and so can run any version built
within this address range. The Fxxx version will work if burned to a
ROM.

I have also tested it running on the POM1 Apple 1 emulator.
