These are files and programs related to a 6502-based Single Board
Computer based on a design by Grant Searle. I built a slightly
modified version and designed a PCB layout. Changes include:

- Serial interface using an FTDI USB to serial converter only (no
  RS-232).
- Removed serial hardware handshaking as I could not get it to work
  over FTDI.
- Jumper option to run the CPU from a separate clock (e.g 2MHz) from the
  1.8432 MHz serial clock.
- Power LED.
- Jumper option to power from USB.
- Reset is applied at power on as well as via pushbutton.
- Added a 6522 VIA and associated header for VIA signals.
- Expansion header for CPU signals.
- Pushbutton and LED that can be connected to the VIA for test
  purposes.
- IRQ from ACIA and VIA are connected to the CPU.

Memory Map:

$0000 - $7FFF  RAM (32K)
$8000 - $9FFF  6522 VIA
$A000 - $BFFF  6850 ACIA
$C000 - $FFFF  ROM (16K)

It can run a version of Microsoft BASIC ported by Grant Searle,
included here.

The schematic and PCB layout were developed using EasyEDA and can be
found at https://oshwlab.com/tranter/6502-single-board-computer

The PCB layout has been verified as working. If you want to build your
own version you are welcome to use the design files. Here are some
notes on building it:

PCBs can be manufactured very inexpensively and quickly from JLPCB,
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
are no longer manufactured but can be obtained as NOS (New Old Stock).
All parts are through-hole.

You will need a suitable UV eraser and programmer to program the
EPROM. An equivalent EEPROM may work, but has not been tested.

I recommend using sockets for all ICs.

The PCB layout is Open Source Hardware, licensed under the The TAPR
Open Hardware License. You are welcome to build the circuit and use my
PCB layout.
See https://web.tapr.org/TAPR_Open_Hardware_License_v1.0.txt

Some code here is entirely written by me and others are ports of
existing software. Software written by me is released under the
following license:

Copyright (C) 2012-2020 by Jeff Tranter <tranter@pobox.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
