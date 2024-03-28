This is a 6502/65C02/6800/6809/Z80 logic analyzer design using a Teensy
4.1 microcontroller.

It clips onto a 6502, 65C02, 6800, 6809, or Z80 chip and monitors the
address, data, and control lines in real-time.

There is a simple command line interface over the microcontroller's
USB serial interface that allows you to set parameters, such as the
state to trigger on, and to capture and list the recorded data.

It has been built on a PCB and tested with 6502, 65C02, 6800, and Z80
single board computers running at up to 2 MHz.

It should work with other 6502 and Z80 compatible CPUs and the 6809E,
but would need some wiring changes to work with a 6802.
The CPU can be selected at run time.

Included are an Arduino sketch and circuit schematic diagram.

Parts List:

```
1  Teensy 4.1 Microcontroller
4  74LVC245AN Octal Level Shifter
1  40-in DIP clip (pins rather than nails) e.g. 3M 923690-40 or 923739-40, Digikey 923690-40-ND
2  20 pin 0.1" ribbon cables, e.g. Digikey A9BBG-2008F-ND or A9BBG-2006F-ND
1  Momentary push button
4  0.1uF bypass caps
-  0.1" headers (cut to desired length)
3  Flea clips
1  PCB or proto board
```

You can use my PCB design if desired, or build it on a protoboard.

-----------------------------------------------------------------------

Sample Session:

```
Logic Analyzer version 0.30 by Jeff Tranter <tranter@pobox.com>                                     
Type h or ? for help.                                                                               
% ?                                                                                                 
Logic Analyzer version 0.30 by Jeff Tranter <tranter@pobox.com>
CPU: 65C02
Trigger: none (freerun)
Sample buffer size: 20
Pretrigger samples: 0
Commands:
c <cpu>              - Set CPU to 6502, 65C02, 6800, 6809, or Z80
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
0000  R   5F                <--- TRIGGER ----
0001  R   CF                
0001  R   CF                
D03C  R   20                
B685  F   11  ORA ($00),Y   
B686  R   00                
0000  R   5F                
0001  R   CF                
0001  R   CF                
D03C  R   20                
B687  F   11  ORA ($00),Y   
B688  R   00                
0000  R   5F                
0001  R   CF                
0001  R   FF                
D03C  R   20                
B689  F   11  ORA ($00),Y   
B68A  R   00                
0000  R   5F                
0001  R   CF                
% t a a000 w
% g
Waiting for trigger...
Data recorded (20 samples).
% l
A000  W   15                <--- TRIGGER ----
FEBB  F   A0  LDY #$00      
FEBC  R   00                
FEBD  F   B9  LDA $FED7,Y   RESET ACTIVE
FEBE  R   D7                RESET ACTIVE
FEBF  R   FE                RESET ACTIVE
FED7  R   42                RESET ACTIVE
FEC0  F   F0  BEQ $FEC8     
FEC1  R   06                RESET ACTIVE
FEC2  F   20  JSR $00EE     RESET ACTIVE
FEC3  R   EE                RESET ACTIVE
01FF  R   CB                RESET ACTIVE
01FF  W   FE                RESET ACTIVE
01FE  W   C4                STACK ACCESS
FEC4  R   FF                
FFEE  F   4C  JMP $FF45     RESET ACTIVE
FFEF  R   45                RESET ACTIVE
FFF0  R   FF                
FF5F  F   48  PHA           
FF60  R   AD                
% 
```

Construction Notes

I initially built the circuit on a solderless breadboard and then made
a more permanent unit on a proto board. See the photos.

I used a 40-pin DIP clip that had pins that fit standard 0.1" headers
attaches to two 20-pin ribbon cables.

Plug the DIP cables into the appropriate pair of connectors for the
CPU being used. The 6800 and 6502/65C02 share the same connectors as
the pinouts are almost the same - you need to connect two flea clips
to select between 6800 or 6502.

On the Z80 you can use a flea clip to select whether to monitor the
/INT or /NMI signal.

The only hardware on the board, other than connectors, are the
74LVC245 chips which are needed to convert the 5V levels of the 6502
to the 3.3V levels used by the Teensy 4.1. Bypass capacitors across
each of the ICs are good practice. A pushbutton allows you to manually
force a trigger while the unit is waiting for a trigger.

The code is specific to the Teensy 4.1 and will not work with other
microcontrollers without changes as it uses direct access to the GPIO
registers. It uses the Teensyduino add-on to the Arduino IDE.

On processors other than the 6502/65C02 and Z80, disassembly is
incomplete as there is no easy way to distinguish an instruction fetch
from any other read cycle.

Licensing

Copyright (c) 2021-2023 by Jeff Tranter <tranter@pobox.com>

The hardware design is Open Source Hardware, licensed under the The TAPR
Open Hardware License. You are welcome to build the circuit and use my
PCB layout.
See https://web.tapr.org/OHL/TAPR_Open_Hardware_License_v1.0.txt


The software is released under the following license:

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


Documentation is licensed under a Creative Commons Attribution 4.0
International License.
See https://creativecommons.org/licenses/by/4.0/
