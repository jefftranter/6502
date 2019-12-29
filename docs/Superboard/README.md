Ohio Scientific Superboard

These are files related to my build of a replica of the Ohio Scientific Superboard 2 Model 600 Rev D.

It uses the PCB design by Grant Klyball found at https://github.com/osiweb/Hardware/tree/master/repro/OSI_600D

*Assembly Notes*

There is an excellent Superboard II Kit Assembly Manual that you can
follow to assemble and test the board. It is 126 pages long. I had
mine commercially printed and bound at Staples for about $20.

The PCB has no solder mask. Check with your board vendor if they can
accept Gerber files without soldermask layers (some do and some do
not). Grant Klyball <grant@klyball.com> is one source for the PCBs.

As there is no soldermask, be particularly careful about solder
bridges.

The silkscreen orientation of pin 1 for the ICs is incorrect
(reversed). Follow the instructions in the assembly manual.

You will need a 5 Volt power supply rated for at least 3 Amps. One
inexpensive option is a USB power supply. Some USB C supplies (like
those designed for a Raspberry Pi 4) can provide this much current.

You will need an eraser and programmer for the EPROMs (or just a
programmer if you use EEPROMs). Unlike the original, no modifications
to the board are needed to use EPROMs (the original board used masked
ROMs).

Cherry MX (red, brown, blue, or black) keyswitches should fit the
board. The latching caps lock keys are no longer made - you can use a
slide switch instead. There is a position on the board for it. You may
be able to find parts from a vendor or an old keyboard to support a
space bar. OSI reproduction key caps are available from Dave on the
OSIWEB forums.

You need some jumpers for serial or cassette, as per the OSI assembly
manual.

Obtaining the exact crystal is problematic. Unicorn Electronics has
3.6864 MHz and 4.000 MHz crystals that may be close enough depending
on your monitor, or even a 3.54 MHz TV color burst crystal. Another
option is to use a programmable oscillator chip (see
https://www.digikey.com/products/en?keywords=SGR-8002DC-PTB-ND) with
some circuit modifications.

*References*

https://github.com/osiweb/Hardware/tree/master/repro/OSI_600D
http://www.osiweb.org/osiforum/
http://www.osiweb.org/misc/osi-replacement-parts.txt
http://klyball.com/
http://osiweb.org/osiforum/viewtopic.php?f=3&t=210
http://www.glitchwrks.com/2017/02/26/osi-560z-build
http://www.technology.niagarac.on.ca/people/mcsele/hobby/ohio-scientific-computers-series-600-challenger-1p-superboard/
http://www.unicornelectronics.com
https://www.electronicsurplus.com/futaba-md-4pcs-switch-p-b-no-keyboard-package-of-20
