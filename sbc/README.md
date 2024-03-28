These are files and programs related to a 6502-based Single Board
Computer based on a design by Grant Searle. I built a slightly
modified version and designed a PCB layout. Changes include:

- Serial interface using an FTDI USB to serial converter only (no
  RS-232).
- Removed serial hardware handshaking as I could not get it to work
  over FTDI.
- Jumper option to run the CPU from a separate clock (2 MHz) or from
  the 1.8432 MHz serial clock.
- Power LED.
- Jumper option to power from USB.
- Reset is applied at power on as well as via pushbutton.
- Added a 6522 VIA and associated header for VIA signals.
- Expansion header for CPU signals.
- Pushbutton and LED that can be connected to the VIA for test
  purposes.
- IRQ from ACIA and VIA are connected to the CPU.

Memory Map:

```
$0000 - $7FFF  RAM (32K)
$8000 - $9FFF  6522 VIA
$A000 - $BFFF  6850 ACIA
$C000 - $FFFF  ROM (16K)
```

It supports my JMON machine language monitor. It can run a version of
Microsoft BASIC ported by Grant Searle, included here. It can also run
a version of Enhanced Basic by Lee Davison or a port of BBC Basic 2.
These can all run out of ROM.

The schematic and PCB layout were developed using EasyEDA and can be
found at https://oshwlab.com/tranter/6502-single-board-computer

The PCB layout has been verified as working. If you want to build your
own version you are welcome to use the design files. Here are some
notes on building it:

PCBs can be manufactured very inexpensively and quickly from JLCPCB,
which is partnered with EasyEDA.com.

You will need an FTDI USB to serial breakout board with 6 pin
connector, like the DFRobot FTDI Basic Breakout or AdaFruit FTDI
friend. Set it for 5V VCC out.

The board can be powered from USB. Connect a jumper H1 to do this. The
power LED will indicate power on. You can also power it from a
separate 5 Volt supply, in which case the jumper should be removed.

My design added a power on reset circuit. I also wired the /IRQ line
to the 6850 UART, although the firmware does not currently make use of
this feature.

I suggest using small nylon standoffs on the corners of the board to
keep it up off the bench.

All parts should be readily available from sources like Ebay. Some.
are no longer manufactured but can be obtained as NOS (New Old Stock)
from vendors such as Unicorn Electronics. All parts are through-hole.

You will need a suitable UV eraser and programmer to program the
EPROM.

I recommend using sockets for all ICs.

Some board bringup and debugging tips:

1. Examine all solder connections after assembly. Use an ohmmeter to
check the board for shorts between data, address, and control lines
after soldering and before inserting any ICs.

2. Carefully check the ICS for any bent pins (e.g. under the socket).

3. Check all ICS for correct type and orientation.

4. Remember to install the two jumpers.

5. Make sure that the EPROM is programmed.

6. The power LED should indicate power when connected to a USB port.

7. Check for a 2.0 MHz clock from the oscillator module. Check for a
1.8432 MHz clock from the baud rate generator. Check that reset goes
low when the reset button is pressed and high when released.

8. Some programs are provided to test the 6522 VIA using the LED and
pushbutton.

9. Connect to the serial port using a terminal emulator program such
as Minicom on Linux. Set it to 115200 BPS 8N1, no handshaking. With
the JMON and MS Basic firmware you should see a prompt "[C]old start,
[W]arm start, or [M]onitor?".

KNOWN ISSUES AND POTENTIAL GOTCHAS

The polarity of the two LEDs is important. Unfortunately, the "+" sign
on the silkscreen is incorrect. The positive or anode lead of the LEDs
(usually the longer of the two leads) should go in the other hole (the
one without the "+" marking). As LEDs vary, I also suggest you
experiment with the value of the current limiting resistors associated
with each LED in order to get the desired brightness.

There is no hardware handshaking on the serial port, so you can get
data overruns if you send data (such as a Basic program) too fast for
the software to keep up. This can be handling by using a data transfer
program that supports adding delays between characters and lines. On
Linux you can use the program ascii-xfer, for example. I find that a
line delay of 100ms and a character delay of 20ms is sufficient for
Basic programs.

FUTURE WORK

The SYNC signal from the 6502 would be useful in some applications and
should be brought out to one of the connectors (probably the VIA as
there are no spare pins on the expansion connector.

It would be interesting to modify the design to use 14 MHz WDC 65C02,
65C51, and 65C22 parts and see how high a clock rate I can run it at.

LICENSING

The PCB layout is Open Source Hardware, licensed under the The TAPR
Open Hardware License. You are welcome to build the circuit and use my
PCB layout.
See https://web.tapr.org/OHL/TAPR_Open_Hardware_License_v1.0.txt

Some code here is entirely written by me and others are ports of
existing software. Software written by me is released under the
following license:

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
