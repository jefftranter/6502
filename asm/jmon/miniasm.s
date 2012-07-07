;
; 6502 Mini Assembler
;
; Copyright (C) 2012 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
;
; Revision History
; Version Date         Comments
; 0.0     07-Jul-2012  First version started

.ifdef NONE

Mini assembler proposed format:

A <address>
XXXX: instruction
XXXX: instruction
<Esc>

example:

A 6000
6000: NOP
6001: LDX #0A
6003: JSR FFEF
6006: DEX
6007: BNE 6003
6009: <Esc>

Restrictions:
- no symbols or labels
- all values in hex, 2 or 4 digits
- no backspace or other editing features
- 6502 only (initially)

Future enhancements:
- optional $ in front of values (to accept back disassembled code)
- 65C02 instructions

Addressing modes:

LDA #nn         Immediate
LDA nn          Zero page
LDA nnnn        Absolute
LDA nn,X        Zero page X
LDX nn,Y        Zero page Y
LDA nnnn,X      Absolute X
LDA nnnn,Y      Absolute X
LDA (n,X)       Indexed indirect
LDA (n),Y       Indirect indexed
LSR A           Accumulator
BEQ nnnn        Relative
JMP (nnnn)      Indirect
NOP             Implicit

Errors:

Invalid instruction
Invalid operand
Invalid addressing mode
Unable to write to $A000

Routines:

Assemble:
- called from JMON command loop
- get and store start address
- output return
- call AssembleLine

AssembleLine:
- output current address
- output colon and space
- input three letter mnemonic (filter for valid alphabetic characters)
- Esc will terminate
- if not valid mnemonic:
    output "Invalid instruction"
    return
- mnemonic is valid. Save lookup value in a variable.
- does instruction only support implicit addressing mode (i.e. no operand)?
- if so
  we are done
  Go to code to generate code
- if not, need operand
- output a space
- input characters up to newline, filter on only these characters: # 0-9 A-F ( ) ,  X Y
- save in buffer
- check if was termined in Esc
- if so, return


.endif

