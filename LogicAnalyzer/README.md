This is prototype 6502 logic analyzer design using the Teensy 4.1
microcontroller.

It clips on to a 6502 chip and monitors the address, data, and control
lines in real time.

There is a simple command line interface over the microcontroller's
USB serial interface that allows you to set parameters, such as the
address to trigger on, and to capture and list the recorded data.

It has been built on a protoboard and tested with my 6502 single board
computer with a 65C02 running at 2 MHz.

Included here are the Arduino sketch and circuit schematic diagram.

Parts List:

```
1  Teensy 4.1 Microcontroller
4  74LVC245AN Octal Level Shifter
1  40-in DIP clip
-  Ribbon cables to DIP clip
-  Breadboard or proto board
4  0.1uF bypass caps (optional)
```

Sample Session:

```
6502 Logic Analyzer version 0.1 by Jeff Tranter <tranter@pobox.com>
Type help or ? for help.
% ?
6502 Logic Analyzer version 0.1 by Jeff Tranter <tranter@pobox.com>
Trigger address: FFFC
Sample buffer size: 20
Commands:
  s[amples] <number>
  t[rigger] <address>|none
  g[o]
  l[ist]
  e[xport]
  h[elp] or ?
% go
Waiting for trigger address FFFC...
Data recorded.
% list
FFFC  R  00                RESET ACTIVE
FFFD  R  FF                RESET VECTOR
FF00  I  A2  LDX #FC       
FF01  R  FC                
FF02  I  9A  TXS           
FF03  R  A9                
FF03  I  A9  LDA #15       
FF04  R  15                
FF05  I  8D  STA A000      
FF06  R  00                
FF07  R  A0                
A000  W  15                
FF08  I  A5  LDA 0         
FF09  R  00                
0000  R  00                
FF0A  I  8D  STA 100       
FF0B  R  00                
FF0C  R  01                
0100  W  00                
FF0D  I  A5  LDA 0
```

Construction Notes

I initially built the circuit on a solderless breadboard and then made
a more permanent unit on a proto board. See the photos.

I used a 40-pin DIP clip that had pins that fit standard 0.1" headers.
I used two old floppy disk ribbon cables that had suitable female
connectors on each end, but you could wire up two 20-pin ribbon cables
as needed.

The only hardware on the board, other than connectors, are the
74LVC245 chips which are needed to convert the 5V levels of the 6502
to the 3.3V levels used by the Teensy 4.1. Bypass capacitors across
each of the ICs are good practice. A pushbutton allows you to manually
force a trigger while the unit is waiting for a trigger.

The code is specific to the Teensy 4.1 and will not work with other
microcontrollers without changes as it uses direct access to the GPIO
registers. It uses the Teensyduino add-on to the Arduino IDE.
