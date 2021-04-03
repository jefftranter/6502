This is prototype 6502 logic analyzer design using the Teensy 4.1
microcontroller.

It clips on to a 6502 chip and monitors the address, data, and control
lines in real time.

There is a simple command line interface over the microcontroller's
USB serial interface that allows you to set parameters, such as the
state to trigger on, and to capture and list the recorded data.

It has been built on a protoboard and tested with my 6502 single board
computer with a 65C02 running at 2 MHz.

Included here are the Arduino sketch and circuit schematic diagram.

A version is also avalable for the 6809 microprocessor, including an
Arduino sketch.

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
6502 Logic Analyzer version 0.22 by Jeff Tranter <tranter@pobox.com>
Type h or ? for help.
% ?
6502 Logic Analyzer version 0.22 by Jeff Tranter <tranter@pobox.com>
Trigger: on address FFFC read or write
Sample buffer size: 20
Pretrigger samples: 0
Commands:
s <number>           - Set number of samples
p <samples>          - Set pre-trigger samples
t a <address> [r|w]  - Trigger on address
t d <data> [r|w]     - Trigger on data
t reset 0|1          - Trigger on /RESET level
t irq 0|1            - Trigger on /IRQ level
t nmi 0|1            - Trigger on /NMI level
t spare1 0|1         - Trigger on SPARE1 level
t spare2 0|1         - Trigger on SPARE2 level
t none               - Trigger freerun
g                    - Go/start analyzer
l [start] [end]      - List samples
e                    - Export samples as CSV
w                    - Write data to SD card
h or ?               - Show command usage
% g
Waiting for trigger...
Data recorded (20 samples).
% l
01FA  W  FF                STACK ACCESS
01F9  W  5A                RESET ACTIVE
01F8  W  A4                RESET ACTIVE
FFFC  R  00                <--- TRIGGER ----
FFFD  R  FF                RESET VECTOR
FF00  I  A2  LDX #FC       RESET ACTIVE
FF01  R  FC                RESET ACTIVE
FF02  I  9A  TXS           RESET ACTIVE
FF03  R  A9                RESET ACTIVE
FF03  I  A9  LDA #15       RESET ACTIVE
FF04  R  15                RESET ACTIVE
FF05  I  8D  STA A000      RESET ACTIVE
FF06  R  00                RESET ACTIVE
FF07  R  A0                RESET ACTIVE
A000  W  15                RESET ACTIVE
FF08  I  A5  LDA 00        RESET ACTIVE
FF09  R  00                
0000  R  00                RESET ACTIVE
FF0A  I  8D  STA FF00      RESET ACTIVE
FF0B  R  00
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

The 6809 version is similar, but does not support disassembly as this
is harder to do for the 6502 than the 6809.
