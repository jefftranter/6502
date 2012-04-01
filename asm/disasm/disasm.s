;
; 6502/65C02 Disassembler
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
; 0.0     25-Mar-2012  First version started
; 0.9     28-Mar-2012  First public beta version

; *** ASSEMBLY TIME OPTIONS ***

; Uncomment this if you don't want instructions that operate on the
; accumulator like ASL to be shown as "ASL A" but instead just "ASL".
; NOACCUMULATOR = 1

; Uncomment this if you want the output to include source code only
; and not the data bytes in memory. This allows the output to be fed
; back to an assembler.
; SOURCEONLY = 1
        
; Uncomment next line to link with start address of $A000 for Multi I/0 Board EEPROM.
; .org $A000

; *** CONSTANTS ***

; Characters
  CR  = $0D ; Carriage Return
  SP  = $20 ; Space
  ESC = $1B ; Escape

; External Routines
  ECHO     = $FFEF ; Woz monitor ECHO routine
  PRBYTE   = $FFDC ; Woz monitor print byte as two hex chars
  PRHEX    = $FFE5 ; Woz monitor print nybble as hex digit

; Instructions. Matches entries in table of MNEMONICS
 OP_INV = $00
 OP_ADC = $01
 OP_AND = $02
 OP_ASL = $03
 OP_BCC = $04
 OP_BCS = $05
 OP_BEQ = $06
 OP_BIT = $07
 OP_BMI = $08
 OP_BNE = $09
 OP_BPL = $0A
 OP_BRK = $0B
 OP_BVC = $0C
 OP_BVS = $0D
 OP_CLC = $0E
 OP_CLD = $0F
 OP_CLI = $10
 OP_CLV = $11
 OP_CMP = $12
 OP_CPX = $13
 OP_CPY = $14
 OP_DEC = $15
 OP_DEX = $16
 OP_DEY = $17
 OP_EOR = $18
 OP_INC = $19
 OP_INX = $1A
 OP_INY = $1B
 OP_JMP = $1C
 OP_JSR = $1D
 OP_LDA = $1E
 OP_LDX = $1F
 OP_LDY = $20
 OP_LSR = $21
 OP_NOP = $22
 OP_ORA = $23
 OP_PHA = $24
 OP_PHP = $25
 OP_PLA = $26
 OP_PLP = $27
 OP_ROL = $28
 OP_ROR = $29
 OP_RTI = $2A
 OP_RTS = $2B
 OP_SBC = $2C
 OP_SEC = $2D
 OP_SED = $2E
 OP_SEI = $2F
 OP_STA = $30
 OP_STX = $31
 OP_STY = $32
 OP_TAX = $33
 OP_TAY = $34
 OP_TSX = $35
 OP_TXA = $36
 OP_TXS = $37
 OP_TYA = $38
 OP_BBR = $39 ; [65C02 only]
 OP_BBS = $3A ; [65C02 only]
 OP_BRA = $3B ; [65C02 only]
 OP_PHX = $3C ; [65C02 only]
 OP_PHY = $3D ; [65C02 only]
 OP_PLX = $3E ; [65C02 only]
 OP_PLY = $3F ; [65C02 only]
 OP_RMB = $40 ; [65C02 only]
 OP_SMB = $41 ; [65C02 only]
 OP_STZ = $42 ; [65C02 only]
 OP_TRB = $43 ; [65C02 only]
 OP_TSB = $44 ; [65C02 only]
 OP_STP = $45 ; [WDC 65C02 only]
 OP_WAI = $46 ; [WDC 65C02 only]

; Addressing Modes. OPCODES1/OPCODES2 tables list these for each instruction. LENGTHS lists the instruction length for each addressing mode.
 AM_INVALID = 0                    ; example:
 AM_IMPLICIT = 1                   ; RTS
 AM_ACCUMULATOR = 2                ; ASL A
 AM_IMMEDIATE = 3                  ; LDA #$12
 AM_ZEROPAGE = 4                   ; LDA $12
 AM_ZEROPAGE_X = 5                 ; LDA $12,X
 AM_ZEROPAGE_Y = 6                 ; LDA $12,Y
 AM_RELATIVE = 7                   ; BNE $FD
 AM_ABSOLUTE = 8                   ; JSR $1234
 AM_ABSOLUTE_X = 9                 ; STA $1234,X
 AM_ABSOLUTE_Y = 10                ; STA $1234,Y
 AM_INDIRECT = 11                  ; JMP ($1234)
 AM_INDEXED_INDIRECT = 12          ; LDA ($12,X)
 AM_INDIRECT_INDEXED = 13          ; LDA ($12),Y
 AM_INDIRECT_ZEROPAGE = 14         ; LDA ($12) [65C02 only]
 AM_ABSOLUTE_INDEXED_INDIRECT = 15 ; JMP ($1234,X) [65C02 only]

; *** VARIABLES ***

; Page zero variables
 T1     = $35     ; temp variable 1
 T2     = $36     ; temp variable 2
 ADDR   = $37     ; instruction address, 2 bytes (low/high)
 OPCODE = $39     ; instruction opcode
 OP     = $3A     ; instruction type OP_*
 AM     = $41     ; addressing mode AM_*
 LEN    = $42     ; instruction length
 REL    = $43     ; relative addressing branch offset (2 bytes)
 DEST   = $45     ; relative address destination address (2 bytes)

; *** CODE ***

; Main program disassembles starting from itself. Prompts user to hit
; key to continue after each screen.
START:
  JSR PrintCR
  LDX #<WelcomeString
  LDY #>WelcomeString
  JSR PrintString
  JSR PrintCR
  LDA #<START
  STA ADDR
  LDA #>START
  STA ADDR+1
OUTER:
  JSR PrintCR
  LDA #23
LOOP:
  PHA
  JSR DISASM
  PLA
  SEC
  SBC #1
  BNE LOOP
  LDX #<ContinueString
  LDY #>ContinueString
  JSR PrintString
@SpaceOrEscape:
  JSR GetKey
  CMP #' '
  BEQ OUTER
  CMP #ESC
  BNE @SpaceOrEscape
  RTS

; Disassemble instruction at address ADDR (low) / ADDR+1 (high). On
; return ADDR/ADDR+1 points to next instruction so it can be called
; again.
DISASM:
  LDX #0
  LDA (ADDR,X)          ; get instruction op code
  STA OPCODE
  BMI UPPER             ; if bit 7 set, in upper half of table
  ASL A                 ; double it since table is two bytes per entry
  TAX
  LDA OPCODES1,X        ; get the instruction type (e.g. OP_LDA)
  STA OP                ; store it
  INX
  LDA OPCODES1,X        ; get addressing mode
  STA AM                ; store it
  JMP AROUND
UPPER: 
  ASL A                 ; double it since table is two bytes per entry
  TAX
  LDA OPCODES2,X        ; get the instruction type (e.g. OP_LDA)
  STA OP                ; store it
  INX
  LDA OPCODES2,X        ; get addressing mode
  STA AM                ; store it
AROUND:
  TAX                   ; put addressing mode in X
  LDA LENGTHS,X         ; get instruction length given addressing mode
  STA LEN               ; store it
  LDX ADDR
  LDY ADDR+1
  .ifndef SOURCEONLY
  JSR PrintAddress      ; print address
  LDX #3
  JSR PrintSpaces       ; then three spaces
  LDA OPCODE            ; get instruction op code
  JSR PrintByte         ; display the opcode byte
  JSR PrintSpace
  LDA LEN               ; how many bytes in the instruction?
  CMP #3
  BEQ THREE
  CMP #2
  BEQ TWO
  LDX #5
  JSR PrintSpaces
  JMP ONE
TWO:
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte
  JSR PrintByte         ; display it
  LDX #3
  JSR PrintSpaces
  JMP ONE
THREE:
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte
  JSR PrintByte         ; display it
  JSR PrintSpace
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte
  JSR PrintByte         ; display it
ONE:
  .endif                ; .ifndef SOURCEONLY
  LDX #4
  JSR PrintSpaces
  LDA OP                ; get the op code
  ASL A                 ; multiply by 2
  CLC
  ADC OP                ; add one more to multiply by 3 since table is three bytes per entry
  TAX
  LDY #3
MNEM:
  LDA MNEMONICS,X       ; print three chars of mnemonic
  JSR PrintChar
  INX
  DEY
  BNE MNEM
; Display any operands based on addressing mode
  LDA OP                ; is it RMB or SMB?
  CMP #OP_RMB
  BEQ DOMB
  CMP #OP_SMB
  BNE TRYBB
DOMB:
  LDA OPCODE            ; get the op code
  AND #$70              ; Upper 3 bits is the bit number
  LSR                   
  LSR
  LSR
  LSR
  JSR PRHEX
  LDX #2
  JSR PrintSpaces
  JSR PrintDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JMP DONEOPS
TRYBB:
  LDA OP                ; is it BBR or BBS?
  CMP #OP_BBR
  BEQ DOBB
  CMP #OP_BBS
  BNE TRYIMP
DOBB:                   ; handle special BBRn and BBSn instructions
  LDA OPCODE            ; get the op code
  AND #$70              ; Upper 3 bits is the bit number
  LSR                   
  LSR
  LSR
  LSR
  JSR PRHEX
  LDX #2
  JSR PrintSpaces
  JSR PrintDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (address)
  JSR PrintByte         ; display it
  LDA #','
  JSR PrintChar
  JSR PrintDollar
; Handle relative addressing
; Destination address is Current address + relative (sign extended so upper byte is $00 or $FF) + 3
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (relative branch offset)
  STA REL               ; save low byte of offset
  BMI @NEG              ; if negative, need to sign extend
  LDA #0                ; high byte is zero
  BEQ @ADD
@NEG:
  LDA #$FF              ; negative offset, high byte if $FF
@ADD:
  STA REL+1             ; save offset high byte
  LDA ADDR              ; take adresss
  CLC
  ADC REL               ; add offset
  STA DEST              ; and store
  LDA ADDR+1            ; also high byte (including carry)
  ADC REL+1
  STA DEST+1
  LDA DEST              ; now need to add 3 more to the address
  CLC
  ADC #3
  STA DEST
  LDA DEST+1
  ADC #0                ; add any carry
  STA DEST+1
  JSR PrintByte         ; display high byte
  LDA DEST
  JSR PrintByte         ; display low byte
  JMP DONEOPS
TRYIMP:
  LDA AM
  CMP #AM_IMPLICIT
  BNE TRYINV
  JMP DONEOPS           ; no operands
TRYINV: 
  CMP #AM_INVALID
  BNE TRYACC
  JMP DONEOPS           ; no operands
TRYACC:
  LDX #3
  JSR PrintSpaces
  CMP #AM_ACCUMULATOR
  BNE TRYIMM
 .ifndef NOACCUMULATOR
  LDA #'A'
  JSR PrintChar
 .endif                 ; .ifndef NOACCUMULATOR
  JMP DONEOPS
TRYIMM:
  CMP #AM_IMMEDIATE
  BNE TRYZP
  LDA #'#'
  JSR PrintChar
  JSR PrintDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JMP DONEOPS
TRYZP:
  CMP #AM_ZEROPAGE
  BNE TRYZPX
  JSR PrintDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JMP DONEOPS
TRYZPX:
  CMP #AM_ZEROPAGE_X
  BNE TRYZPY
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (address)
  JSR PrintDollar
  JSR PrintByte         ; display it
  JSR PrintCommaX
  JMP DONEOPS       
TRYZPY:
  CMP #AM_ZEROPAGE_Y
  BNE TRYREL
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (address)
  JSR PrintByte         ; display it
  JSR PrintCommaY
  JMP DONEOPS       
TRYREL:
  CMP #AM_RELATIVE
  BNE TRYABS
  JSR PrintDollar
; Handle relative addressing
; Destination address is Current address + relative (sign extended so upper byte is $00 or $FF) + 2
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (relative branch offset)
  STA REL               ; save low byte of offset
  BMI NEG               ; if negative, need to sign extend
  LDA #0                ; high byte is zero
  BEQ ADD
NEG:
  LDA #$FF              ; negative offset, high byte if $FF
ADD:
  STA REL+1             ; save offset high byte
  LDA ADDR              ; take adresss
  CLC
  ADC REL               ; add offset
  STA DEST              ; and store
  LDA ADDR+1            ; also high byte (including carry)
  ADC REL+1
  STA DEST+1
  LDA DEST              ; now need to add 2 more to the address
  CLC
  ADC #2
  STA DEST
  LDA DEST+1
  ADC #0                ; add any carry
  STA DEST+1
  JSR PrintByte         ; display high byte
  LDA DEST
  JSR PrintByte         ; display low byte
  JMP DONEOPS
TRYABS:
  CMP #AM_ABSOLUTE
  BNE TRYABSX
  JSR PrintDollar
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (high address)
  JSR PrintByte         ; display it
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JMP DONEOPS
TRYABSX:
  CMP #AM_ABSOLUTE_X
  BNE TRYABSY
  JSR PrintDollar
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (high address)
  JSR PrintByte         ; display it
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintCommaX
  JMP DONEOPS
TRYABSY:
  CMP #AM_ABSOLUTE_Y
  BNE TRYIND
  JSR PrintDollar
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (high address)
  JSR PrintByte         ; display it
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintCommaY
  JMP DONEOPS
TRYIND:
  CMP #AM_INDIRECT
  BNE TRYINDXIND
  JSR PrintLParenDollar
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (high address)
  JSR PrintByte         ; display it
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintRParen
  JMP DONEOPS
TRYINDXIND:
  CMP #AM_INDEXED_INDIRECT
  BNE TRYINDINDX
  JSR PrintLParenDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintCommaX
  JSR PrintRParen
  JMP DONEOPS
TRYINDINDX:
  CMP #AM_INDIRECT_INDEXED
  BNE TRYINDZ
  JSR PrintLParenDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintRParen
  JSR PrintCommaY
  JMP DONEOPS
TRYINDZ:
  CMP #AM_INDIRECT_ZEROPAGE ; [65C02 only]
  BNE TRYABINDIND
  JSR PrintLParenDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintRParen
  JMP DONEOPS
TRYABINDIND:
  CMP #AM_ABSOLUTE_INDEXED_INDIRECT ; [65C02 only]
  BNE DONEOPS
  JSR PrintLParenDollar
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (high address)
  JSR PrintByte         ; display it
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintCommaX
  JSR PrintRParen
  JMP DONEOPS
DONEOPS:
  JSR PrintCR           ; print a final CR
  LDA ADDR              ; update address to next instruction
  CLC
  ADC LEN
  STA ADDR
  LDA ADDR+1
  ADC #0                ; to add carry
  STA ADDR+1
  RTS

;------------------------------------------------------------------------
; Utility functions

; Print a dollar sign
; Registers changed: None
PrintDollar:
  PHA
  LDA #'$'
  JSR PrintChar
  PLA
  RTS

; Print ",X"
; Registers changed: None
PrintCommaX:
  PHA
  LDA #','
  JSR PrintChar
  LDA #'X'
  JSR PrintChar
  PLA
  RTS

; Print ",Y"
; Registers changed: None
PrintCommaY:
  PHA
  LDA #','
  JSR PrintChar
  LDA #'Y'
  JSR PrintChar
  PLA
  RTS

; Print "($"
; Registers changed: None
PrintLParenDollar:
  PHA
  LDA #'('
  JSR PrintChar
  LDA #'$'
  JSR PrintChar
  PLA
  RTS

; Print a right parenthesis
; Registers changed: None
PrintRParen:
  PHA
  LDA #')'
  JSR PrintChar
  PLA
  RTS

; Print a carriage return
; Registers changed: None
PrintCR:
  PHA
  LDA #CR
  JSR PrintChar
  PLA
  RTS

; Print a space
; Registers changed: None
PrintSpace:
  PHA
  LDA #SP
  JSR PrintChar
  PLA
  RTS

; Print number of spaces in X
; Registers changed: X
PrintSpaces:
  PHA
  LDA #SP
@LOOP:
  JSR ECHO
  DEX
  BNE @LOOP
  PLA
  RTS

; Output a character
; Calls Woz monitor ECHO routine
; Registers changed: none
PrintChar:
  JSR ECHO
  RTS

; Get character from keyboard
; Returns in A
; Clears high bit to be valid ASCII
; Registers changed: A
GetKey:
  LDA $D011 ; Keyboard CR
  BPL GetKey
  LDA $D010 ; Keyboard data
  AND #%01111111
  RTS

; Print 16-bit address in hex
; Pass byte in X (low) and Y (high)
; Registers changed: None
PrintAddress:
  PHA
  TYA
  JSR PRBYTE
  TXA
  JSR PRBYTE
  PLA
  RTS

; Print byte in hex
; Pass byte in A
; Registers changed: None
PrintByte:
  JSR PRBYTE
  RTS

; Print a string
; Pass address of string in X (low) and Y (high).
; String must be terminated in a null.
; Cannot be longer than 256 characters.
; Registers changed: A, Y
;
PrintString:
  STX T1
  STY T1+1
  LDY #0
@loop:
  LDA (T1),Y
  BEQ done
  JSR PrintChar
  INY
  BNE @loop       ; if doesn't branch, string is too long
done:
  RTS

;  get opcode
;  get mnemonic, addressing mode, instruction length
;  display opcode string
;  display arguments based on addressing mode
;  increment instruction pointer based on instruction length
;  loop back

; DATA

; Table of instruction strings. 3 bytes per table entry
 .export MNEMONICS
MNEMONICS:
 .byte "???" ; $00
 .byte "ADC" ; $01
 .byte "AND" ; $02
 .byte "ASL" ; $03
 .byte "BCC" ; $04
 .byte "BCS" ; $05
 .byte "BEQ" ; $06
 .byte "BIT" ; $07
 .byte "BMI" ; $08
 .byte "BNE" ; $09
 .byte "BPL" ; $0A
 .byte "BRK" ; $0B
 .byte "BVC" ; $0C
 .byte "BVS" ; $0D
 .byte "CLC" ; $0E
 .byte "CLD" ; $0F
 .byte "CLI" ; $10
 .byte "CLV" ; $11
 .byte "CMP" ; $12
 .byte "CPX" ; $13
 .byte "CPY" ; $14
 .byte "DEC" ; $15
 .byte "DEX" ; $16
 .byte "DEY" ; $17
 .byte "EOR" ; $18
 .byte "INC" ; $19
 .byte "INX" ; $1A
 .byte "INY" ; $1B
 .byte "JMP" ; $1C
 .byte "JSR" ; $1D
 .byte "LDA" ; $1E
 .byte "LDX" ; $1F
 .byte "LDY" ; $20
 .byte "LSR" ; $21
 .byte "NOP" ; $22
 .byte "ORA" ; $23
 .byte "PHA" ; $24
 .byte "PHP" ; $25
 .byte "PLA" ; $26
 .byte "PLP" ; $27
 .byte "ROL" ; $28
 .byte "ROR" ; $29
 .byte "RTI" ; $2A
 .byte "RTS" ; $2B
 .byte "SBC" ; $2C
 .byte "SEC" ; $2D
 .byte "SED" ; $2E
 .byte "SEI" ; $2F
 .byte "STA" ; $30
 .byte "STX" ; $31
 .byte "STY" ; $32
 .byte "TAX" ; $33
 .byte "TAY" ; $34
 .byte "TSX" ; $35
 .byte "TXA" ; $36
 .byte "TXS" ; $37
 .byte "TYA" ; $38
 .byte "BBR" ; $39 [65C02 only]
 .byte "BBS" ; $3A [65C02 only]
 .byte "BRA" ; $3B [65C02 only]
 .byte "PHX" ; $3C [65C02 only]
 .byte "PHY" ; $3D [65C02 only]
 .byte "PLX" ; $3E [65C02 only]
 .byte "PLY" ; $3F [65C02 only]
 .byte "RMB" ; $40 [65C02 only]
 .byte "SMB" ; $41 [65C02 only]
 .byte "STZ" ; $42 [65C02 only]
 .byte "TRB" ; $43 [65C02 only]
 .byte "TSB" ; $44 [65C02 only]
 .byte "STP" ; $45 [WDC 65C02 only]
 .byte "WAI" ; $46 [WDC 65C02 only]

; Lengths of instructions given an addressing mode. Matches values of AM_*
LENGTHS: 
 .byte 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 3

; Opcodes. Listed in order. Defines the mnemonic and addressing mode.
; 2 bytes per table entry
 .export OPCODES1
OPCODES1:
 .byte OP_BRK, AM_IMPLICIT           ; $00
 .byte OP_ORA, AM_INDEXED_INDIRECT   ; $01
 .byte OP_INV, AM_INVALID            ; $02
 .byte OP_INV, AM_INVALID            ; $03
 .byte OP_TSB, AM_ZEROPAGE           ; $04 [65C02 only]
 .byte OP_ORA, AM_ZEROPAGE           ; $05
 .byte OP_ASL, AM_ZEROPAGE           ; $06
 .byte OP_RMB, AM_ZEROPAGE           ; $07 [65C02 only]
 .byte OP_PHP, AM_IMPLICIT           ; $08
 .byte OP_ORA, AM_IMMEDIATE          ; $09
 .byte OP_ASL, AM_ACCUMULATOR        ; $0A
 .byte OP_INV, AM_INVALID            ; $0B
 .byte OP_TSB, AM_ABSOLUTE           ; $0C [65C02 only]
 .byte OP_ORA, AM_ABSOLUTE           ; $0D
 .byte OP_ASL, AM_ABSOLUTE           ; $0E
 .byte OP_BBR, AM_ABSOLUTE           ; $0F [65C02 only]

 .byte OP_BPL, AM_RELATIVE           ; $10
 .byte OP_ORA, AM_INDIRECT_INDEXED   ; $11
 .byte OP_ORA, AM_INDIRECT_ZEROPAGE  ; $12 [65C02 only]
 .byte OP_INV, AM_INVALID            ; $13
 .byte OP_TRB, AM_ZEROPAGE           ; $14 [65C02 only]
 .byte OP_ORA, AM_ZEROPAGE_X         ; $15
 .byte OP_ASL, AM_ZEROPAGE_X         ; $16
 .byte OP_RMB, AM_ZEROPAGE           ; $17 [65C02 only]
 .byte OP_CLC, AM_IMPLICIT           ; $18
 .byte OP_ORA, AM_ABSOLUTE_Y         ; $19
 .byte OP_INC, AM_ACCUMULATOR        ; $1A [65C02 only]
 .byte OP_INV, AM_INVALID            ; $1B
 .byte OP_TRB, AM_ABSOLUTE           ; $1C [65C02 only]
 .byte OP_ORA, AM_ABSOLUTE_X         ; $1D
 .byte OP_ASL, AM_ABSOLUTE_X         ; $1E
 .byte OP_BBR, AM_ABSOLUTE           ; $1F [65C02 only]

 .byte OP_JSR, AM_ABSOLUTE           ; $20
 .byte OP_AND, AM_INDEXED_INDIRECT   ; $21
 .byte OP_INV, AM_INVALID            ; $22
 .byte OP_INV, AM_INVALID            ; $23
 .byte OP_BIT, AM_ZEROPAGE           ; $24
 .byte OP_AND, AM_ZEROPAGE           ; $25
 .byte OP_ROL, AM_ZEROPAGE           ; $26
 .byte OP_RMB, AM_ZEROPAGE           ; $27 [65C02 only]
 .byte OP_PLP, AM_IMPLICIT           ; $28
 .byte OP_AND, AM_IMMEDIATE          ; $29
 .byte OP_ROL, AM_ACCUMULATOR        ; $2A
 .byte OP_INV, AM_INVALID            ; $2B
 .byte OP_BIT, AM_ABSOLUTE           ; $2C
 .byte OP_AND, AM_ABSOLUTE           ; $2D
 .byte OP_ROL, AM_ABSOLUTE           ; $2E
 .byte OP_BBR, AM_ABSOLUTE           ; $2F [65C02 only]

 .byte OP_BMI, AM_RELATIVE           ; $30
 .byte OP_AND, AM_INDIRECT_INDEXED   ; $31 [65C02 only]
 .byte OP_AND, AM_INDIRECT_ZEROPAGE  ; $32 [65C02 only]
 .byte OP_INV, AM_INVALID            ; $33
 .byte OP_BIT, AM_ZEROPAGE_X         ; $34 [65C02 only]
 .byte OP_AND, AM_ZEROPAGE_X         ; $35
 .byte OP_ROL, AM_ZEROPAGE_X         ; $36
 .byte OP_RMB, AM_ZEROPAGE           ; $37 [65C02 only]
 .byte OP_SEC, AM_IMPLICIT           ; $38
 .byte OP_AND, AM_ABSOLUTE_Y         ; $39
 .byte OP_DEC, AM_ACCUMULATOR        ; $3A [65C02 only]
 .byte OP_INV, AM_INVALID            ; $3B
 .byte OP_BIT, AM_ABSOLUTE_X         ; $3C [65C02 only]
 .byte OP_AND, AM_ABSOLUTE_X         ; $3D
 .byte OP_ROL, AM_ABSOLUTE_X         ; $3E
 .byte OP_BBR, AM_ABSOLUTE           ; $3F [65C02 only]

 .byte OP_RTI, AM_IMPLICIT           ; $40
 .byte OP_EOR, AM_INDEXED_INDIRECT   ; $41
 .byte OP_INV, AM_INVALID            ; $42
 .byte OP_INV, AM_INVALID            ; $43
 .byte OP_INV, AM_INVALID            ; $44
 .byte OP_EOR, AM_ZEROPAGE           ; $45
 .byte OP_LSR, AM_ZEROPAGE           ; $46
 .byte OP_RMB, AM_ZEROPAGE           ; $47 [65C02 only]
 .byte OP_PHA, AM_IMPLICIT           ; $48
 .byte OP_EOR, AM_IMMEDIATE          ; $49
 .byte OP_LSR, AM_ACCUMULATOR        ; $4A
 .byte OP_INV, AM_INVALID            ; $4B
 .byte OP_JMP, AM_ABSOLUTE           ; $4C
 .byte OP_EOR, AM_ABSOLUTE           ; $4D
 .byte OP_LSR, AM_ABSOLUTE           ; $4E
 .byte OP_BBR, AM_ABSOLUTE           ; $4F [65C02 only]

 .byte OP_BVC, AM_RELATIVE           ; $50
 .byte OP_EOR, AM_INDIRECT_INDEXED   ; $51
 .byte OP_EOR, AM_INDIRECT_ZEROPAGE  ; $52 [65C02 only]
 .byte OP_INV, AM_INVALID            ; $53
 .byte OP_INV, AM_INVALID            ; $54
 .byte OP_EOR, AM_ZEROPAGE_X         ; $55
 .byte OP_LSR, AM_ZEROPAGE_X         ; $56
 .byte OP_RMB, AM_ZEROPAGE           ; $57 [65C02 only]
 .byte OP_CLI, AM_IMPLICIT           ; $58
 .byte OP_EOR, AM_ABSOLUTE_Y         ; $59
 .byte OP_PHY, AM_IMPLICIT           ; $5A [65C02 only]
 .byte OP_INV, AM_INVALID            ; $5B
 .byte OP_INV, AM_INVALID            ; $5C
 .byte OP_EOR, AM_ABSOLUTE_X         ; $5D
 .byte OP_LSR, AM_ABSOLUTE_X         ; $5E
 .byte OP_BBR, AM_ABSOLUTE           ; $5F [65C02 only]

 .byte OP_RTS, AM_IMPLICIT           ; $60
 .byte OP_ADC, AM_INDEXED_INDIRECT   ; $61
 .byte OP_INV, AM_INVALID            ; $62
 .byte OP_INV, AM_INVALID            ; $63
 .byte OP_STZ, AM_ZEROPAGE           ; $64 [65C02 only]
 .byte OP_ADC, AM_ZEROPAGE           ; $65
 .byte OP_ROR, AM_ZEROPAGE           ; $66
 .byte OP_RMB, AM_ZEROPAGE           ; $67 [65C02 only]
 .byte OP_PLA, AM_IMPLICIT           ; $68
 .byte OP_ADC, AM_IMMEDIATE          ; $69
 .byte OP_ROR, AM_ACCUMULATOR        ; $6A
 .byte OP_INV, AM_INVALID            ; $6B
 .byte OP_JMP, AM_INDIRECT           ; $6C
 .byte OP_ADC, AM_ABSOLUTE           ; $6D
 .byte OP_ROR, AM_ABSOLUTE           ; $6E
 .byte OP_BBR, AM_ABSOLUTE           ; $6F [65C02 only]

 .byte OP_BVS, AM_RELATIVE           ; $70
 .byte OP_ADC, AM_INDIRECT_INDEXED   ; $71
 .byte OP_ADC, AM_INDIRECT_ZEROPAGE  ; $72 [65C02 only]
 .byte OP_INV, AM_INVALID            ; $73
 .byte OP_STZ, AM_ZEROPAGE_X         ; $74 [65C02 only]
 .byte OP_ADC, AM_ZEROPAGE_X         ; $75
 .byte OP_ROR, AM_ZEROPAGE_X         ; $76
 .byte OP_RMB, AM_ZEROPAGE           ; $77 [65C02 only]
 .byte OP_SEI, AM_IMPLICIT           ; $78
 .byte OP_ADC, AM_ABSOLUTE_Y         ; $79
 .byte OP_PLY, AM_IMPLICIT           ; $7A [65C02 only]
 .byte OP_INV, AM_INVALID            ; $7B
 .byte OP_JMP, AM_ABSOLUTE_INDEXED_INDIRECT ; $7C [65C02 only]
 .byte OP_ADC, AM_ABSOLUTE_X         ; $7D
 .byte OP_ROR, AM_ABSOLUTE_X         ; $7E
 .byte OP_BBR, AM_ABSOLUTE           ; $7F [65C02 only]
 .export OPCODES2
OPCODES2:
 .byte OP_BRA, AM_RELATIVE           ; $80 [65C02 only]
 .byte OP_STA, AM_INDEXED_INDIRECT   ; $81
 .byte OP_INV, AM_INVALID            ; $82
 .byte OP_INV, AM_INVALID            ; $83
 .byte OP_STY, AM_ZEROPAGE           ; $84
 .byte OP_STA, AM_ZEROPAGE           ; $85
 .byte OP_STX, AM_ZEROPAGE           ; $86
 .byte OP_SMB, AM_ZEROPAGE           ; $87 [65C02 only]
 .byte OP_DEY, AM_IMPLICIT           ; $88
 .byte OP_BIT, AM_IMMEDIATE          ; $89 [65C02 only]
 .byte OP_TXA, AM_IMPLICIT           ; $8A
 .byte OP_INV, AM_INVALID            ; $8B
 .byte OP_STY, AM_ABSOLUTE           ; $8C
 .byte OP_STA, AM_ABSOLUTE           ; $8D
 .byte OP_STX, AM_ABSOLUTE           ; $8E
 .byte OP_BBS, AM_ABSOLUTE           ; $8F [65C02 only]

 .byte OP_BCC, AM_RELATIVE           ; $90
 .byte OP_STA, AM_INDIRECT_INDEXED   ; $91
 .byte OP_STA, AM_INDIRECT_ZEROPAGE  ; $92 [65C02 only]
 .byte OP_INV, AM_INVALID            ; $93
 .byte OP_STY, AM_ZEROPAGE_X         ; $94
 .byte OP_STA, AM_ZEROPAGE_X         ; $95
 .byte OP_STX, AM_ZEROPAGE_Y         ; $96
 .byte OP_SMB, AM_ZEROPAGE           ; $97 [65C02 only]
 .byte OP_TYA, AM_IMPLICIT           ; $98
 .byte OP_STA, AM_ABSOLUTE_Y         ; $99
 .byte OP_TXS, AM_IMPLICIT           ; $9A
 .byte OP_INV, AM_INVALID            ; $9B
 .byte OP_STZ, AM_ABSOLUTE           ; $9C [65C02 only]
 .byte OP_STA, AM_ABSOLUTE_X         ; $9D
 .byte OP_STZ, AM_ABSOLUTE_X         ; $9E [65C02 only]
 .byte OP_BBS, AM_ABSOLUTE           ; $9F [65C02 only]

 .byte OP_LDY, AM_IMMEDIATE          ; $A0
 .byte OP_LDA, AM_INDEXED_INDIRECT   ; $A1
 .byte OP_LDX, AM_IMMEDIATE          ; $A2
 .byte OP_INV, AM_INVALID            ; $A3
 .byte OP_LDY, AM_ZEROPAGE           ; $A4
 .byte OP_LDA, AM_ZEROPAGE           ; $A5
 .byte OP_LDX, AM_ZEROPAGE           ; $A6
 .byte OP_SMB, AM_ZEROPAGE           ; $A7 [65C02 only]
 .byte OP_TAY, AM_IMPLICIT           ; $A8
 .byte OP_LDA, AM_IMMEDIATE          ; $A9
 .byte OP_TAX, AM_IMPLICIT           ; $AA
 .byte OP_INV, AM_INVALID            ; $AB
 .byte OP_LDY, AM_ABSOLUTE           ; $AC
 .byte OP_LDA, AM_ABSOLUTE           ; $AD
 .byte OP_LDX, AM_ABSOLUTE           ; $AE
 .byte OP_BBS, AM_ABSOLUTE           ; $AF [65C02 only]

 .byte OP_BCS, AM_RELATIVE           ; $B0
 .byte OP_LDA, AM_INDIRECT_INDEXED   ; $B1
 .byte OP_LDA, AM_INDIRECT_ZEROPAGE  ; $B2 [65C02 only]
 .byte OP_INV, AM_INVALID            ; $B3
 .byte OP_LDY, AM_ZEROPAGE_X         ; $B4
 .byte OP_LDA, AM_ZEROPAGE_X         ; $B5
 .byte OP_LDX, AM_ZEROPAGE_Y         ; $B6
 .byte OP_SMB, AM_ZEROPAGE           ; $B7 [65C02 only]
 .byte OP_CLV, AM_IMPLICIT           ; $B8
 .byte OP_LDA, AM_ABSOLUTE_Y         ; $B9
 .byte OP_TSX, AM_IMPLICIT           ; $BA
 .byte OP_INV, AM_INVALID            ; $BB
 .byte OP_LDY, AM_ABSOLUTE_X         ; $BC
 .byte OP_LDA, AM_ABSOLUTE_X         ; $BD
 .byte OP_LDX, AM_ABSOLUTE_Y         ; $BE
 .byte OP_BBS, AM_ABSOLUTE           ; $BF [65C02 only]

 .byte OP_CPY, AM_IMMEDIATE          ; $C0
 .byte OP_CMP, AM_INDEXED_INDIRECT   ; $C1
 .byte OP_INV, AM_INVALID            ; $C2
 .byte OP_INV, AM_INVALID            ; $C3
 .byte OP_CPY, AM_ZEROPAGE           ; $C4
 .byte OP_CMP, AM_ZEROPAGE           ; $C5
 .byte OP_DEC, AM_ZEROPAGE           ; $C6
 .byte OP_SMB, AM_ZEROPAGE           ; $C7 [65C02 only]
 .byte OP_INY, AM_IMPLICIT           ; $C8
 .byte OP_CMP, AM_IMMEDIATE          ; $C9
 .byte OP_DEX, AM_IMPLICIT           ; $CA
 .byte OP_WAI, AM_IMPLICIT           ; $CB [WDC 65C02 only]
 .byte OP_CPY, AM_ABSOLUTE           ; $CC
 .byte OP_CMP, AM_ABSOLUTE           ; $CD
 .byte OP_DEC, AM_ABSOLUTE           ; $CE
 .byte OP_BBS, AM_ABSOLUTE           ; $CF [65C02 only]

 .byte OP_BNE, AM_RELATIVE           ; $D0
 .byte OP_CMP, AM_INDIRECT_INDEXED   ; $D1
 .byte OP_CMP, AM_INDIRECT_ZEROPAGE  ; $D2 [65C02 only]
 .byte OP_INV, AM_INVALID            ; $D3
 .byte OP_INV, AM_INVALID            ; $D4
 .byte OP_CMP, AM_ZEROPAGE_X         ; $D5
 .byte OP_DEC, AM_ZEROPAGE_X         ; $D6
 .byte OP_SMB, AM_ZEROPAGE           ; $D7 [65C02 only]
 .byte OP_CLD, AM_IMPLICIT           ; $D8
 .byte OP_CMP, AM_ABSOLUTE_Y         ; $D9
 .byte OP_PHX, AM_IMPLICIT           ; $DA [65C02 only]
 .byte OP_STP, AM_IMPLICIT           ; $DB [WDC 65C02 only]
 .byte OP_INV, AM_INVALID            ; $DC
 .byte OP_CMP, AM_ABSOLUTE_X         ; $DD
 .byte OP_DEC, AM_ABSOLUTE_X         ; $DE
 .byte OP_BBS, AM_ABSOLUTE           ; $DF [65C02 only]

 .byte OP_CPX, AM_IMMEDIATE          ; $E0
 .byte OP_SBC, AM_INDEXED_INDIRECT   ; $E1
 .byte OP_INV, AM_INVALID            ; $E2
 .byte OP_INV, AM_INVALID            ; $E3
 .byte OP_CPX, AM_ZEROPAGE           ; $E4
 .byte OP_SBC, AM_ZEROPAGE           ; $E5
 .byte OP_INC, AM_ZEROPAGE           ; $E6
 .byte OP_SMB, AM_ZEROPAGE           ; $E7 [65C02 only]
 .byte OP_INX, AM_IMPLICIT           ; $E8
 .byte OP_SBC, AM_IMMEDIATE          ; $E9
 .byte OP_NOP, AM_IMPLICIT           ; $EA
 .byte OP_INV, AM_INVALID            ; $EB
 .byte OP_CPX, AM_ABSOLUTE           ; $EC
 .byte OP_SBC, AM_ABSOLUTE           ; $ED
 .byte OP_INC, AM_ABSOLUTE           ; $EE
 .byte OP_BBS, AM_ABSOLUTE           ; $EF [65C02 only]

 .byte OP_BEQ, AM_RELATIVE           ; $F0
 .byte OP_SBC, AM_INDIRECT_INDEXED   ; $F1
 .byte OP_SBC, AM_INDIRECT_ZEROPAGE  ; $F2 [65C02 only]
 .byte OP_INV, AM_INVALID            ; $F3
 .byte OP_INV, AM_INVALID            ; $F4
 .byte OP_SBC, AM_ZEROPAGE_X         ; $F5
 .byte OP_INC, AM_ZEROPAGE_X         ; $F6
 .byte OP_SMB, AM_ZEROPAGE           ; $F7 [65C02 only]
 .byte OP_SED, AM_IMPLICIT           ; $F8
 .byte OP_SBC, AM_ABSOLUTE_Y         ; $F9
 .byte OP_PLX, AM_IMPLICIT           ; $FA [65C02 only]
 .byte OP_INV, AM_INVALID            ; $FB
 .byte OP_INV, AM_INVALID            ; $FC
 .byte OP_SBC, AM_ABSOLUTE_X         ; $FD
 .byte OP_INC, AM_ABSOLUTE_X         ; $FE
 .byte OP_BBS, AM_ABSOLUTE           ; $FF [65C02 only]

; *** Strings ***

ContinueString:
  .asciiz "  <SPACE> TO CONTINUE, <ESC> TO STOP"
WelcomeString:
  .asciiz "DISASM VERSION 0.9 by JEFF TRANTER"
