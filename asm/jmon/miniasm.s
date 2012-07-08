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

Mini assembler syntax format:

A <address>
XXXX: instruction
XXXX: instruction
XXXX: <Esc>

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
- 65816 instructions
- binary, character, decimal constants

Addressing modes:

LDA #nn         Immediate           AM_IMMEDIATE
LDA nn          Zero page           AM_ZEROPAGE
LDA nnnn        Absolute            AM_ABSOLUTE
LDA nn,X        Zero page X         AM_ZEROPAGE_X
LDX nn,Y        Zero page Y         AM_ZEROPAGE_Y
LDA nnnn,X      Absolute X          AM_ABSOLUTE_X
LDA nnnn,Y      Absolute X          AM_ABSOLUTE_Y
LDA (nn,X)      Indexed indirect    AM_INDEXED_INDIRECT
LDA (nn),Y      Indirect indexed    AM_INDIRECT_INDEXED
LSR A           Accumulator         AM_ACCUMULATOR
BEQ nnnn        Relative            AM_RELATIVE
JMP (nnnn)      Indirect            AM_INDIRECT
NOP             Implicit            AM_IMPLICIT

Errors:

Invalid instruction
Invalid operand
Invalid addressing mode
Unable to write to $XXXX

Variables:

ADDR - instruction address
OPCODE - instruction op code
OP - instruction type (OP_*)
LEN -length of instruction
IN - input buffer holding operands
AM - addressing mode (AM_*)

Routines:

Assemble:
- called from JMON command loop
- get and store ADDRESS
- output return
- call AssembleLine
- return

AssembleLine:
- output ADDRESS
- output colon and space
- input three letter for mnemonic (filter for valid alphabetic characters). Esc will terminate.
- if not valid mnemonic:
    output "Invalid instruction"
    return
- mnemonic is valid. Save lookup value in a variable.
- does instruction only support implicit addressing mode (i.e. no operand)?
- if so
  we are done
  Go to Code to generate code
- if not, need operand so continue
- output a space
- input characters up to newline, filter on only these characters: # 0-9 A-F ( ) , X Y. Support Esc to terminate. Use modified GetLine.
- save in buffer
- check if was terminated in Esc
- if so, return
- Check for addressing mode. Have already checked for implicit.

LSR A           Accumulator
Is operand just "A"? Set to AM_ACCUMULATOR
If so, go to CheckOperandValid

LDA #nn         Immediate
Is operand # followed by2 hex digits?
If so, set to immediate and go to CheckOperandValid

LDA nn          Zero page
2 hex digits?

LDA nnnn        Absolute
BEQ nnnn        Relative

4 hex digits?
check if it is absolute or relative
Then call CheckOperandValid

LDA nn,X        Zero page X
2 hex digits followed by ,X

LDX nn,Y        Zero page Y
2 hex digits followed by ,X

LDA nnnn,X      Absolute X
4 hex digits followed by ,X

LDA nnnn,Y      Absolute X
4 hex digits followed by ,Y

LDA (nn,X)      Indexed indirect

LDA (nn),Y      Indirect indexed

JMP (nnnn)      Indirect

If not any of the above
  report "Invalid operand"
  return

IsHexDigit:
  return true if A is 0-A or A-F

CheckOperandValid:
Search table to determine if addressing mode is valid for opcode.
If not
  report "Invalid addressing mode"
  return

Look up op code
Look up instruction length

Write opcode
Check that code written can be read back.
If not
  Report "Unable to write to $XXXX"
  return

Generate code starting at address
  
NOP             Implicit
LSR A           Accumulator

Only needed to write op code, so done.

LDA #nn         Immediate
LDA nn          Zero page
LDA nn,X        Zero page X
LDX nn,Y        Zero page Y
LDA (nn,X)      Indexed indirect
LDA (nn),Y      Indirect indexed

Write 1 byte from operand

LDA nnnn        Absolute
LDA nnnn,X      Absolute X
LDA nnnn,Y      Absolute X
JMP (nnnn)      Indirect

Write 2 bytes from operand (switch order)

BEQ nnnn        Relative

Write 1 byte calculated as destination (nnnn) - current address - instruction length (2)

Update current address with instruction length

go to AssembleLine

.endif

