;
; 6502/65C02/65816 Disassembler
;
; Copyright (C) 2012-2020 by Jeff Tranter <tranter@pobox.com>
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
; 1.0     03-Jul-2012  Added 65816 support

; *** ASSEMBLY TIME OPTIONS ***

; Uncomment this if you don't want instructions that operate on the
; accumulator like ASL to be shown as "ASL A" but instead just "ASL".
; NOACCUMULATOR = 1

; Uncomment this if you want the output to include source code only
; and not the data bytes in memory. This allows the output to be fed
; back to an assembler.
; SOURCEONLY = 1

; Define this if you want 65816 instructions to be disassembled.
; D65816 = 1

; Define this if you want 65C02 instructions to be disassembled.
D65C02 = 1

; Define this if you want the WDC and Rockwell-specific bit instructions
; to be disassembled (BBR, BBS, RMB, SMB). This is mutually exclusive
; with the 65816 option.
; ROCKWELL = 1

; Uncomment next line to link with start address of $A000 for Multi I/0 Board EEPROM.
; .org $A000

.if .defined(ROCKWELL) .and .defined(D65816)
.error "The 65816 and ROCKWELL options are mutually exclusive."
.endif

; Instructions. Match indexes into entries in table MNEMONICS1/MENMONICS2.
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
 OP_STP = $45 ; [WDC 65C02 and 65816 only]
 OP_WAI = $46 ; [WDC 65C02 and 65816 only]
 OP_BRL = $47 ; [WDC 65816 only]
 OP_COP = $48 ; [WDC 65816 only]
 OP_JML = $49 ; [WDC 65816 only]
 OP_JSL = $4A ; [WDC 65816 only]
 OP_MVN = $4B ; [WDC 65816 only]
 OP_MVP = $4C ; [WDC 65816 only]
 OP_PEA = $4D ; [WDC 65816 only]
 OP_PEI = $4E ; [WDC 65816 only]
 OP_PER = $4F ; [WDC 65816 only]
 OP_PHB = $50 ; [WDC 65816 only]
 OP_PHD = $51 ; [WDC 65816 only]
 OP_PHK = $52 ; [WDC 65816 only]
 OP_PLB = $53 ; [WDC 65816 only]
 OP_PLD = $54 ; [WDC 65816 only]
 OP_REP = $56 ; [WDC 65816 only]
 OP_RTL = $57 ; [WDC 65816 only]
 OP_SEP = $58 ; [WDC 65816 only]
 OP_TCD = $59 ; [WDC 65816 only]
 OP_TCS = $5A ; [WDC 65816 only]
 OP_TDC = $5B ; [WDC 65816 only]
 OP_TSC = $5C ; [WDC 65816 only]
 OP_TXY = $5D ; [WDC 65816 only]
 OP_TYX = $5E ; [WDC 65816 only]
 OP_WDM = $5F ; [WDC 65816 only]
 OP_XBA = $60 ; [WDC 65816 only]
 OP_XCE = $61 ; [WDC 65816 only]

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
 AM_STACK_RELATIVE = 16            ; LDA 3,S [65816 only]
 AM_DIRECT_PAGE_INDIRECT_LONG = 17 ; LDA [$55] [65816 only]
 AM_ABSOLUTE_LONG = 18             ; LDA $02F000 [65816 only]
 AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y = 19 ; LDA (5,S),Y [65816 only]
 AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y = 20 ; LDA [$55],Y [65816 only]
 AM_ABSOLUTE_LONG_INDEXED_WITH_X = 21 ; LDA $12D080,X [65816 only]
 AM_BLOCK_MOVE = 22                ; MVP 0,0 [65816 only]
 AM_PROGRAM_COUNTER_RELATIVE_LONG = 23 ; BRL JMPLABEL [65816 only]
 AM_ABSOLUTE_INDIRECT_LONG = 24    ; JMP [$2000] [65816 only]

; *** CODE ***

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

; Handle 16-bit modes of 65816
; When M=0 (16-bit accumulator) the following instructions take an extra byte:
; 09 29 49 69 89 A9 C9 E9
; When X=0 (16-bit index) the following instructions take an extra byte:
; A0 A2 C0 E0

  LDA MBIT              ; Is M bit zero?
  BNE TRYX              ; If not, skip adjustment.
  LDA OPCODE            ; See if the opcode is one that needs to be adjusted
  CMP #$09
  BEQ ADJUST
  CMP #$29
  BEQ ADJUST
  CMP #$49
  BEQ ADJUST
  CMP #$69
  BEQ ADJUST
  CMP #$89
  BEQ ADJUST
  CMP #$A9
  BEQ ADJUST
  CMP #$C9
  BEQ ADJUST
  CMP #$E9
  BEQ ADJUST
  BNE TRYX
ADJUST:
  INC LEN               ; Increment length by one
  JMP REPSEP

TRYX:
  LDA XBIT              ; Is X bit zero?
  BNE REPSEP            ; If not, skip adjustment.
  LDA OPCODE            ; See if the opcode is one that needs to be adjusted
  CMP #$A0
  BEQ ADJUST
  CMP #$A2
  BEQ ADJUST
  CMP #$C0
  BEQ ADJUST
  CMP #$E0
  BEQ ADJUST

; Special check for REP and SEP instructions.
; These set or clear the M and X bits which change the length of some instructions.

REPSEP:
  LDA OPCODE
  CMP #$C2              ; Is it REP?
  BNE TRYSEP
  LDY #1
  LDA (ADDR),Y          ; get operand
  EOR #$FF              ; Complement the bits
  AND #%00100000        ; Mask out M bit
  LSR                   ; Shift into bit 0
  LSR
  LSR
  LSR
  LSR
  STA MBIT              ; Store it
  LDA (ADDR),Y          ; get operand again
  EOR #$FF              ; Complement the bits
  AND #%00010000        ; Mask out X bit
  LSR                   ; Shift into bit 0
  LSR
  LSR
  LSR
  STA XBIT              ; Store it
  JMP PRADDR

TRYSEP:
  CMP #$E2              ; Is it SEP?
  BNE PRADDR
  LDY #1
  LDA (ADDR),Y          ; get operand
  AND #%00100000        ; Mask out M bit
  LSR                   ; Shift into bit 0
  LSR
  LSR
  LSR
  LSR
  STA MBIT              ; Store it
  LDA (ADDR),Y          ; get operand again
  AND #%00010000        ; Mask out X bit
  LSR                   ; Shift into bit 0
  LSR
  LSR
  LSR
  STA XBIT              ; Store it

PRADDR:
  LDX ADDR
  LDY ADDR+1
  .ifndef SOURCEONLY
  JSR PrintAddress      ; print address
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  LDX #3
  JSR PrintSpaces       ; then three spaces
.elseif .defined(OSI)
  JSR PrintSpace
.endif
  LDA OPCODE            ; get instruction op code
  JSR PrintByte         ; display the opcode byte
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  JSR PrintSpace
.endif
  LDA LEN               ; how many bytes in the instruction?
  CMP #4
  BEQ FOUR
  CMP #3
  BEQ THREE
  CMP #2
  BEQ TWO
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  LDX #5
.elseif .defined(OSI)
  LDX #4
.endif
  JSR PrintSpaces
  JMP ONE
TWO:
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte
  JSR PrintByte         ; display it
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  LDX #3
.elseif .defined(OSI)
  LDX #2
.endif
  JSR PrintSpaces
  JMP ONE
THREE:
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte
  JSR PrintByte         ; display it
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  JSR PrintSpace
.endif
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte
  JSR PrintByte         ; display it
  JMP ONE
FOUR:
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte
  JSR PrintByte         ; display it
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  JSR PrintSpace
.endif
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte
  JSR PrintByte         ; display it
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  JSR PrintSpace
.endif
  LDY #3
  LDA (ADDR),Y          ; get 3nd operand byte
  JSR PrintByte         ; display it
  LDX #1
  BNE SPC
ONE:
  .endif                ; .ifndef SOURCEONLY
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  LDX #4
.elseif .defined(OSI)
  LDX #1
.endif
SPC:
  JSR PrintSpaces
  LDA OP                ; get the op code
  CMP #$55              ; Is it in the first half of the table?
  BMI LOWERM

  ASL A                 ; multiply by 2
  CLC
  ADC OP                ; add one more to multiply by 3 since table is three bytes per entry
  LDY #3                ; going to loop 3 times
  TAX                   ; save index into table
MNEM2:
  LDA MNEMONICS2+1,X    ; print three chars of mnemonic
  JSR PrintChar
  INX
  DEY
  BNE MNEM2
  BEQ AMODE

LOWERM:
  ASL A                 ; multiply by 2
  CLC
  ADC OP                ; add one more to multiply by 3 since table is three bytes per entry
  LDY #3                ; going to loop 3 times
  TAX                   ; save index into table
MNEM1:
  LDA MNEMONICS1,X      ; print three chars of mnemonic
  JSR PrintChar
  INX
  DEY
  BNE MNEM1

; Display any operands based on addressing mode
AMODE:
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
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  LDX #2
.elseif .defined(OSI)
  LDX #1
.endif
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
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  LDX #2
.elseif .defined(OSI)
  LDX #1
.endif
  JSR PrintSpaces
  JSR PrintDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (address)
  JSR PrintByte         ; display it
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  LDA #','
  JSR PrintChar
  JSR PrintDollar
.endif
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
  STA DEZT              ; and store
  LDA ADDR+1            ; also high byte (including carry)
  ADC REL+1
  STA DEZT+1
  LDA DEZT              ; now need to add 3 more to the address
  CLC
  ADC #3
  STA DEZT
  LDA DEZT+1
  ADC #0                ; add any carry
  STA DEZT+1
  JSR PrintByte         ; display high byte
  LDA DEZT
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
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
  LDX #3
.elseif .defined(OSI)
  LDX #1
.endif
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
  LDA LEN               ; Operand could be 8 or 16-bits
  CMP #3                ; 16-bit?
  BEQ IM16              ; Branch if so, otherwise it is 8-bit
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JMP DONEOPS
IM16:
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (high address)
  JSR PrintByte         ; display it
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
  JSR PrintDollar
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
  STA DEZT              ; and store
  LDA ADDR+1            ; also high byte (including carry)
  ADC REL+1
  STA DEZT+1
  LDA DEZT              ; now need to add 2 more to the address
  CLC
  ADC #2
  STA DEZT
  LDA DEZT+1
  ADC #0                ; add any carry
  STA DEZT+1
  JSR PrintByte         ; display high byte
  LDA DEZT
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
  BNE TRYSTACKREL
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

TRYSTACKREL:
  CMP #AM_STACK_RELATIVE ; [WDC 65816 only]
  BNE TRYDPIL
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (address)
  JSR PrintDollar
  JSR PrintByte         ; display it
  JSR PrintCommaS
  JMP DONEOPS

TRYDPIL:
  CMP #AM_DIRECT_PAGE_INDIRECT_LONG ; [WDC 65816 only]
  BNE TRYABSLONG
  JSR PrintLBraceDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintRBrace
  JMP DONEOPS

TRYABSLONG:
  CMP #AM_ABSOLUTE_LONG ; [WDC 65816 only]
  BNE SRIIY
  JSR PrintDollar
  LDY #3
  LDA (ADDR),Y          ; get 3nd operand byte (bank address)
  JSR PrintByte         ; display it
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (high address)
  JSR PrintByte         ; display it
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JMP DONEOPS

SRIIY:
  CMP #AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; [WDC 65816 only]
  BNE DPILIY
  JSR PrintLParenDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintCommaS
  JSR PrintRParen
  JSR PrintCommaY
  JMP DONEOPS

DPILIY:
  CMP #AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; [WDC 65816 only]
  BNE ALIX
  JSR PrintLBraceDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintRBrace
  JSR PrintCommaY
  JMP DONEOPS

ALIX:
  CMP #AM_ABSOLUTE_LONG_INDEXED_WITH_X ; [WDC 65816 only]
  BNE BLOCKMOVE
  JSR PrintDollar
  LDY #3
  LDA (ADDR),Y          ; get 3nd operand byte (bank address)
  JSR PrintByte         ; display it
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (high address)
  JSR PrintByte         ; display it
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintCommaX
  JMP DONEOPS

BLOCKMOVE:
  CMP #AM_BLOCK_MOVE ; [WDC 65816 only]
  BNE PCRL
  JSR PrintDollar
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte
  JSR PrintByte         ; display it
  LDA #','
  JSR PrintChar
  JSR PrintDollar
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte
  JSR PrintByte         ; display it
  JMP DONEOPS

PCRL:
  CMP #AM_PROGRAM_COUNTER_RELATIVE_LONG ; [WDC 65816 only]
  BNE AIL
  JSR PrintDollar
; Handle relative addressing
; Destination address is current address + relative + 3
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte
  STA REL               ; save low byte of offset
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte
  STA REL+1             ; save offset high byte
  LDA ADDR              ; take adresss
  CLC
  ADC REL               ; add offset
  STA DEZT              ; and store
  LDA ADDR+1            ; also high byte (including carry)
  ADC REL+1
  STA DEZT+1
  LDA DEZT              ; now need to add 3 more to the address
  CLC
  ADC #3
  STA DEZT
  LDA DEZT+1
  ADC #0                ; add any carry
  STA DEZT+1
  JSR PrintByte         ; display high byte
  LDA DEZT
  JSR PrintByte         ; display low byte
  JMP DONEOPS

AIL:
  CMP #AM_ABSOLUTE_INDIRECT_LONG ; [WDC 65816 only]
  BNE DONEOPS
  JSR PrintLBraceDollar
  LDY #2
  LDA (ADDR),Y          ; get 2nd operand byte (high address)
  JSR PrintByte         ; display it
  LDY #1
  LDA (ADDR),Y          ; get 1st operand byte (low address)
  JSR PrintByte         ; display it
  JSR PrintRBrace
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

; DATA

; Table of instruction strings. 3 bytes per table entry
 .export MNEMONICS1
MNEMONICS:
MNEMONICS1:
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
 .byte "STP" ; $45 [WDC 65C02 and 65816 only]
 .byte "WAI" ; $46 [WDC 65C02 and 65816 only]
 .byte "BRL" ; $47 [WDC 65816 only]
 .byte "COP" ; $48 [WDC 65816 only]
 .byte "JMP" ; $49 [WDC 65816 only]
 .byte "JSL" ; $4A [WDC 65816 only]
 .byte "MVN" ; $4B [WDC 65816 only]
 .byte "MVP" ; $4C [WDC 65816 only]
 .byte "PEA" ; $4D [WDC 65816 only]
 .byte "PEI" ; $4E [WDC 65816 only]
 .byte "PER" ; $4F [WDC 65816 only]
 .byte "PHB" ; $50 [WDC 65816 only]
 .byte "PHD" ; $51 [WDC 65816 only]
 .byte "PHK" ; $52 [WDC 65816 only]
 .byte "PLB" ; $53 [WDC 65816 only]
 .byte "PLD" ; $54 [WDC 65816 only]
MNEMONICS2:
 .byte "???" ; $55 Unused because index is $FF
 .byte "REP" ; $56 [WDC 65816 only]
 .byte "RTL" ; $57 [WDC 65816 only]
 .byte "SEP" ; $58 [WDC 65816 only]
 .byte "TCD" ; $59 [WDC 65816 only]
 .byte "TCS" ; $5A [WDC 65816 only]
 .byte "TDC" ; $5B [WDC 65816 only]
 .byte "TSC" ; $5C [WDC 65816 only]
 .byte "TXY" ; $5D [WDC 65816 only]
 .byte "TYX" ; $5E [WDC 65816 only]
 .byte "WDM" ; $5F [WDC 65816 only]
 .byte "XBA" ; $60 [WDC 65816 only]
 .byte "XCE" ; $61 [WDC 65816 only]
MNEMONICSEND: ; address of the end of the table

; Lengths of instructions given an addressing mode. Matches values of AM_*
; Assumes 65816 is in 8-bit mode.
LENGTHS:
 .byte 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 3, 2, 2, 4, 2, 2, 4, 3, 3, 3

; Opcodes. Listed in order. Defines the mnemonic and addressing mode.
; 2 bytes per table entry
 .export OPCODES1
OPCODES:
OPCODES1:
 .byte OP_BRK, AM_IMPLICIT           ; $00

 .byte OP_ORA, AM_INDEXED_INDIRECT   ; $01

.ifdef D65816
 .byte OP_COP, AM_ZEROPAGE           ; $02 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $02
.endif

.ifdef D65816
 .byte OP_ORA, AM_STACK_RELATIVE     ; $03 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $03
.endif

.ifdef D65C02
 .byte OP_TSB, AM_ZEROPAGE           ; $04 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $04
.endif

 .byte OP_ORA, AM_ZEROPAGE           ; $05

 .byte OP_ASL, AM_ZEROPAGE           ; $06

.ifdef ROCKWELL
 .byte OP_RMB, AM_ZEROPAGE           ; $07 [65C02 only]
.elseif .defined(D65816)
 .byte OP_ORA, AM_DIRECT_PAGE_INDIRECT_LONG ; $07 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $07
.endif

 .byte OP_PHP, AM_IMPLICIT           ; $08

 .byte OP_ORA, AM_IMMEDIATE          ; $09

 .byte OP_ASL, AM_ACCUMULATOR        ; $0A

.ifdef D65816
 .byte OP_PHD, AM_IMPLICIT           ; $0B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $0B
.endif

.ifdef D65C02
 .byte OP_TSB, AM_ABSOLUTE           ; $0C [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $0C
.endif

 .byte OP_ORA, AM_ABSOLUTE           ; $0D

 .byte OP_ASL, AM_ABSOLUTE           ; $0E

.ifdef ROCKWELL
 .byte OP_BBR, AM_ABSOLUTE           ; $0F [65C02 only]
.elseif .defined(D65816)
 .byte OP_ORA, AM_ABSOLUTE_LONG      ; $0F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $0F
.endif

 .byte OP_BPL, AM_RELATIVE           ; $10

 .byte OP_ORA, AM_INDIRECT_INDEXED   ; $11

.ifdef D65C02
 .byte OP_ORA, AM_INDIRECT_ZEROPAGE  ; $12 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $12
.endif

.ifdef D65816
 .byte OP_ORA, AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; $13 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $12
.endif

.ifdef D65C02
 .byte OP_TRB, AM_ZEROPAGE           ; $14 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $12
.endif

 .byte OP_ORA, AM_ZEROPAGE_X         ; $15

 .byte OP_ASL, AM_ZEROPAGE_X         ; $16

.ifdef ROCKWELL
 .byte OP_RMB, AM_ZEROPAGE           ; $17 [65C02 only]
.elseif .defined(D65816)
 .byte OP_ORA, AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; $17 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $17
.endif

 .byte OP_CLC, AM_IMPLICIT           ; $18

 .byte OP_ORA, AM_ABSOLUTE_Y         ; $19

.ifdef D65C02
 .byte OP_INC, AM_ACCUMULATOR        ; $1A [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $1A
.endif

.ifdef D65816
 .byte OP_TCS, AM_IMPLICIT           ; $1B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $1B
.endif

.ifdef D65C02
 .byte OP_TRB, AM_ABSOLUTE           ; $1C [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $1C
.endif

 .byte OP_ORA, AM_ABSOLUTE_X         ; $1D

 .byte OP_ASL, AM_ABSOLUTE_X         ; $1E

.ifdef ROCKWELL
 .byte OP_BBR, AM_ABSOLUTE           ; $1F [65C02 only]
.elseif .defined(D65816)
 .byte OP_ORA, AM_ABSOLUTE_LONG_INDEXED_WITH_X ; $1F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $1F
.endif

 .byte OP_JSR, AM_ABSOLUTE           ; $20

 .byte OP_AND, AM_INDEXED_INDIRECT   ; $21

 .byte OP_JSR, AM_ABSOLUTE_LONG      ; $22

 .byte OP_AND, AM_STACK_RELATIVE     ; $23

 .byte OP_BIT, AM_ZEROPAGE           ; $24

 .byte OP_AND, AM_ZEROPAGE           ; $25

 .byte OP_ROL, AM_ZEROPAGE           ; $26

.ifdef ROCKWELL
 .byte OP_RMB, AM_ZEROPAGE           ; $27 [65C02 only]
.elseif .defined (D65816)
 .byte OP_AND, AM_DIRECT_PAGE_INDIRECT_LONG ; $27 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $27
.endif

 .byte OP_PLP, AM_IMPLICIT           ; $28

 .byte OP_AND, AM_IMMEDIATE          ; $29

 .byte OP_ROL, AM_ACCUMULATOR        ; $2A

.ifdef D65816
 .byte OP_PLD, AM_IMPLICIT           ; $2B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $2B
.endif

 .byte OP_BIT, AM_ABSOLUTE           ; $2C

 .byte OP_AND, AM_ABSOLUTE           ; $2D

 .byte OP_ROL, AM_ABSOLUTE           ; $2E

.ifdef ROCKWELL
 .byte OP_BBR, AM_ABSOLUTE           ; $2F [65C02 only]
.elseif .defined (D65816)
 .byte OP_AND, AM_ABSOLUTE_LONG      ; $2F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $2F
.endif

 .byte OP_BMI, AM_RELATIVE           ; $30

.ifdef D65C02
 .byte OP_AND, AM_INDIRECT_INDEXED   ; $31 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $31
.endif

.ifdef D65C02
 .byte OP_AND, AM_INDIRECT_ZEROPAGE  ; $32 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $32
.endif

.ifdef D65816
 .byte OP_AND, AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; $33 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $33
.endif

.ifdef D65C02
 .byte OP_BIT, AM_ZEROPAGE_X         ; $34 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $34
.endif

 .byte OP_AND, AM_ZEROPAGE_X         ; $35

 .byte OP_ROL, AM_ZEROPAGE_X         ; $36

.ifdef ROCKWELL
 .byte OP_RMB, AM_ZEROPAGE           ; $37 [65C02 only]
.elseif .defined(D65816)
 .byte OP_AND, AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; $37 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $37
.endif

 .byte OP_SEC, AM_IMPLICIT           ; $38

 .byte OP_AND, AM_ABSOLUTE_Y         ; $39

.ifdef D65C02
 .byte OP_DEC, AM_ACCUMULATOR        ; $3A [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $3A
.endif

.ifdef D65816
 .byte OP_TSC, AM_IMPLICIT           ; $3B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $3B
.endif

.ifdef D65C02
 .byte OP_BIT, AM_ABSOLUTE_X         ; $3C [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $3C
.endif

 .byte OP_AND, AM_ABSOLUTE_X         ; $3D

 .byte OP_ROL, AM_ABSOLUTE_X         ; $3E

.ifdef ROCKWELL
 .byte OP_BBR, AM_ABSOLUTE           ; $3F [65C02 only]
.elseif .defined(D65816)
 .byte OP_AND, AM_ABSOLUTE_LONG_INDEXED_WITH_X ; $3F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $3F
.endif

 .byte OP_RTI, AM_IMPLICIT           ; $40

 .byte OP_EOR, AM_INDEXED_INDIRECT   ; $41

.ifdef D65816
 .byte OP_WDM, AM_ZEROPAGE           ; $42 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $42
.endif

.ifdef D65816
 .byte OP_EOR, AM_STACK_RELATIVE     ; $43 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $43
.endif

.ifdef D65816
 .byte OP_MVP, AM_BLOCK_MOVE         ; $44 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $44
.endif

 .byte OP_EOR, AM_ZEROPAGE           ; $45

 .byte OP_LSR, AM_ZEROPAGE           ; $46

.ifdef ROCKWELL
 .byte OP_RMB, AM_ZEROPAGE           ; $47 [65C02 only]
.elseif .defined(D65816)
 .byte OP_EOR, AM_DIRECT_PAGE_INDIRECT_LONG ; $47 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $47
.endif

 .byte OP_PHA, AM_IMPLICIT           ; $48

 .byte OP_EOR, AM_IMMEDIATE          ; $49

 .byte OP_LSR, AM_ACCUMULATOR        ; $4A

.ifdef D65816
 .byte OP_PHK, AM_IMPLICIT           ; $4B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4B
.endif

 .byte OP_JMP, AM_ABSOLUTE           ; $4C

 .byte OP_EOR, AM_ABSOLUTE           ; $4D

 .byte OP_LSR, AM_ABSOLUTE           ; $4E

.ifdef ROCKWELL
 .byte OP_BBR, AM_ABSOLUTE           ; $4F [65C02 only]
.elseif .defined(D65816)
 .byte OP_EOR, AM_ABSOLUTE_LONG      ; $4F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_BVC, AM_RELATIVE           ; $50

 .byte OP_EOR, AM_INDIRECT_INDEXED   ; $51

.ifdef D65C02
 .byte OP_EOR, AM_INDIRECT_ZEROPAGE  ; $52 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $52
.endif

.ifdef D65816
 .byte OP_EOR, AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; $53 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_MVN, AM_BLOCK_MOVE         ; $54 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_EOR, AM_ZEROPAGE_X         ; $55

 .byte OP_LSR, AM_ZEROPAGE_X         ; $56

.ifdef ROCKWELL
 .byte OP_RMB, AM_ZEROPAGE           ; $57 [65C02 only]
.elseif .defined(D65816)
 .byte OP_EOR, AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; $57 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $57
.endif

 .byte OP_CLI, AM_IMPLICIT           ; $58

 .byte OP_EOR, AM_ABSOLUTE_Y         ; $59

.ifdef D65C02
 .byte OP_PHY, AM_IMPLICIT           ; $5A [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $5A
.endif

.ifdef D65816
 .byte OP_TCD, AM_IMPLICIT           ; $5B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_JML, AM_ABSOLUTE_LONG      ; $5C [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_EOR, AM_ABSOLUTE_X         ; $5D

 .byte OP_LSR, AM_ABSOLUTE_X         ; $5E

.ifdef ROCKWELL
 .byte OP_BBR, AM_ABSOLUTE           ; $5F [65C02 only]
.elseif .defined(D65816)
 .byte OP_EOR, AM_ABSOLUTE_LONG_INDEXED_WITH_X ; $5F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $5F
.endif

 .byte OP_RTS, AM_IMPLICIT           ; $60

 .byte OP_ADC, AM_INDEXED_INDIRECT   ; $61

.ifdef D65816
 .byte OP_PER, AM_PROGRAM_COUNTER_RELATIVE_LONG ; $62 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_ADC, AM_STACK_RELATIVE     ; $63 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65C02
 .byte OP_STZ, AM_ZEROPAGE           ; $64 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $64
.endif

 .byte OP_ADC, AM_ZEROPAGE           ; $65

 .byte OP_ROR, AM_ZEROPAGE           ; $66

.ifdef ROCKWELL
 .byte OP_RMB, AM_ZEROPAGE           ; $67 [65C02 only]
.elseif .defined(D65816)
 .byte OP_ADC, AM_DIRECT_PAGE_INDIRECT_LONG ; $67 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $67
.endif

 .byte OP_PLA, AM_IMPLICIT           ; $68

 .byte OP_ADC, AM_IMMEDIATE          ; $69

 .byte OP_ROR, AM_ACCUMULATOR        ; $6A

.ifdef D65816
 .byte OP_RTL, AM_IMPLICIT           ; $6B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_JMP, AM_INDIRECT           ; $6C

 .byte OP_ADC, AM_ABSOLUTE           ; $6D

 .byte OP_ROR, AM_ABSOLUTE           ; $6E

.ifdef ROCKWELL
 .byte OP_BBR, AM_ABSOLUTE           ; $6F [65C02 only]
.elseif .defined(D65816)
 .byte OP_ADC, AM_ABSOLUTE_LONG      ; $6F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $6F
.endif

 .byte OP_BVS, AM_RELATIVE           ; $70

 .byte OP_ADC, AM_INDIRECT_INDEXED   ; $71

.ifdef D65C02
 .byte OP_ADC, AM_INDIRECT_ZEROPAGE  ; $72 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_ADC, AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; $73 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65C02
 .byte OP_STZ, AM_ZEROPAGE_X         ; $74 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $74
.endif

 .byte OP_ADC, AM_ZEROPAGE_X         ; $75

 .byte OP_ROR, AM_ZEROPAGE_X         ; $76

.ifdef ROCKWELL
 .byte OP_RMB, AM_ZEROPAGE           ; $77 [65C02 only]
.elseif .defined(D65816)
 .byte OP_ADC, AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; $77 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $77
.endif

 .byte OP_SEI, AM_IMPLICIT           ; $78

 .byte OP_ADC, AM_ABSOLUTE_Y         ; $79

.ifdef D65C02
 .byte OP_PLY, AM_IMPLICIT           ; $7A [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $7A
.endif

.ifdef D65816
 .byte OP_TDC, AM_IMPLICIT           ; $7B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65C02
 .byte OP_JMP, AM_ABSOLUTE_INDEXED_INDIRECT ; $7C [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $7C
.endif

 .byte OP_ADC, AM_ABSOLUTE_X         ; $7D

 .byte OP_ROR, AM_ABSOLUTE_X         ; $7E

.ifdef ROCKWELL
 .byte OP_BBR, AM_ABSOLUTE           ; $7F [65C02 only]
.elseif .defined(D65816)
 .byte OP_ADC, AM_ABSOLUTE_LONG_INDEXED_WITH_X ; $7F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $7F
.endif

 .export OPCODES2

OPCODES2:

.ifdef D65C02
 .byte OP_BRA, AM_RELATIVE           ; $80 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $80
.endif

 .byte OP_STA, AM_INDEXED_INDIRECT   ; $81

.ifdef D65816
 .byte OP_BRL, AM_PROGRAM_COUNTER_RELATIVE_LONG ; $82 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_STA, AM_STACK_RELATIVE     ; $83 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_STY, AM_ZEROPAGE           ; $84

 .byte OP_STA, AM_ZEROPAGE           ; $85

 .byte OP_STX, AM_ZEROPAGE           ; $86

.ifdef ROCKWELL
 .byte OP_SMB, AM_ZEROPAGE           ; $87 [65C02 only]
.elseif .defined(D65816)
 .byte OP_STA, AM_DIRECT_PAGE_INDIRECT_LONG ; $87 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $87
.endif

 .byte OP_DEY, AM_IMPLICIT           ; $88

.ifdef D65C02
 .byte OP_BIT, AM_IMMEDIATE          ; $89 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $89
.endif

 .byte OP_TXA, AM_IMPLICIT           ; $8A

.ifdef D65816
 .byte OP_PHB, AM_IMPLICIT           ; $8B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_STY, AM_ABSOLUTE           ; $8C

 .byte OP_STA, AM_ABSOLUTE           ; $8D

 .byte OP_STX, AM_ABSOLUTE           ; $8E

.ifdef ROCKWELL
 .byte OP_BBS, AM_ABSOLUTE           ; $8F [65C02 only]
.elseif .defined(D65816)
 .byte OP_STA, AM_ABSOLUTE_LONG      ; $8F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $8F
.endif

 .byte OP_BCC, AM_RELATIVE           ; $90

 .byte OP_STA, AM_INDIRECT_INDEXED   ; $91

.ifdef D65C02
 .byte OP_STA, AM_INDIRECT_ZEROPAGE  ; $92 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $92
.endif

.ifdef D65816
 .byte OP_STA, AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; $93 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_STY, AM_ZEROPAGE_X         ; $94

 .byte OP_STA, AM_ZEROPAGE_X         ; $95

 .byte OP_STX, AM_ZEROPAGE_Y         ; $96

.ifdef ROCKWELL
 .byte OP_SMB, AM_ZEROPAGE           ; $97 [65C02 only]
.elseif .defined(D65816)
 .byte OP_STA, AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; $97 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $97
.endif

 .byte OP_TYA, AM_IMPLICIT           ; $98

 .byte OP_STA, AM_ABSOLUTE_Y         ; $99

 .byte OP_TXS, AM_IMPLICIT           ; $9A

.ifdef D65816
 .byte OP_TXY, AM_IMPLICIT           ; $9B [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65C02
 .byte OP_STZ, AM_ABSOLUTE           ; $9C [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $9c
.endif

 .byte OP_STA, AM_ABSOLUTE_X         ; $9D

.ifdef D65C02
 .byte OP_STZ, AM_ABSOLUTE_X         ; $9E [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $9E
.endif

.ifdef ROCKWELL
 .byte OP_BBS, AM_ABSOLUTE           ; $9F [65C02 only]
.elseif .defined(D65816)
 .byte OP_STA, AM_ABSOLUTE_LONG_INDEXED_WITH_X ; $9F [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_LDY, AM_IMMEDIATE          ; $A0

 .byte OP_LDA, AM_INDEXED_INDIRECT   ; $A1

 .byte OP_LDX, AM_IMMEDIATE          ; $A2

.ifdef D65816
 .byte OP_LDA, AM_STACK_RELATIVE     ; $A3 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_LDY, AM_ZEROPAGE           ; $A4

 .byte OP_LDA, AM_ZEROPAGE           ; $A5

 .byte OP_LDX, AM_ZEROPAGE           ; $A6

.ifdef ROCKWELL
 .byte OP_SMB, AM_ZEROPAGE           ; $A7 [65C02 only]
.elseif .defined(D65816)
 .byte OP_LDA, AM_DIRECT_PAGE_INDIRECT_LONG ; $A7 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $A7
.endif

 .byte OP_TAY, AM_IMPLICIT           ; $A8

 .byte OP_LDA, AM_IMMEDIATE          ; $A9

 .byte OP_TAX, AM_IMPLICIT           ; $AA

.ifdef D65816
 .byte OP_PLB, AM_IMPLICIT           ; $AB [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_LDY, AM_ABSOLUTE           ; $AC

 .byte OP_LDA, AM_ABSOLUTE           ; $AD

 .byte OP_LDX, AM_ABSOLUTE           ; $AE

.ifdef ROCKWELL
 .byte OP_BBS, AM_ABSOLUTE           ; $AF [65C02 only]
.elseif .defined(D65816)
 .byte OP_LDA, AM_ABSOLUTE_LONG      ; $AF [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_BCS, AM_RELATIVE           ; $B0

 .byte OP_LDA, AM_INDIRECT_INDEXED   ; $B1

.ifdef D65C02
 .byte OP_LDA, AM_INDIRECT_ZEROPAGE  ; $B2 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $B2
.endif

.ifdef D65816
 .byte OP_LDA, AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; $B3 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_LDY, AM_ZEROPAGE_X         ; $B4

 .byte OP_LDA, AM_ZEROPAGE_X         ; $B5

 .byte OP_LDX, AM_ZEROPAGE_Y         ; $B6

.ifdef ROCKWELL
 .byte OP_SMB, AM_ZEROPAGE           ; $B7 [65C02 only]
.elseif .defined(D65816)
 .byte OP_LDA, AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; $B7 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $B7
.endif

 .byte OP_CLV, AM_IMPLICIT           ; $B8

 .byte OP_LDA, AM_ABSOLUTE_Y         ; $B9

 .byte OP_TSX, AM_IMPLICIT           ; $BA

.ifdef D65816
 .byte OP_TYX, AM_IMPLICIT           ; $BB [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_LDY, AM_ABSOLUTE_X         ; $BC

 .byte OP_LDA, AM_ABSOLUTE_X         ; $BD

 .byte OP_LDX, AM_ABSOLUTE_Y         ; $BE

.ifdef ROCKWELL
 .byte OP_BBS, AM_ABSOLUTE           ; $BF [65C02 only]
.elseif .defined(D65816)
 .byte OP_LDA, AM_ABSOLUTE_LONG_INDEXED_WITH_X ; $BF [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $BF
.endif

 .byte OP_CPY, AM_IMMEDIATE          ; $C0

 .byte OP_CMP, AM_INDEXED_INDIRECT   ; $C1

.ifdef D65816
 .byte OP_REP, AM_IMMEDIATE          ; $C2 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_CMP, AM_STACK_RELATIVE     ; $C3 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_CPY, AM_ZEROPAGE           ; $C4

 .byte OP_CMP, AM_ZEROPAGE           ; $C5

 .byte OP_DEC, AM_ZEROPAGE           ; $C6

.ifdef ROCKWELL
 .byte OP_SMB, AM_ZEROPAGE           ; $C7 [65C02 only]
.elseif .defined(D65816)
 .byte OP_CMP, AM_DIRECT_PAGE_INDIRECT_LONG ; $C7 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $C7
.endif

 .byte OP_INY, AM_IMPLICIT           ; $C8

 .byte OP_CMP, AM_IMMEDIATE          ; $C9

 .byte OP_DEX, AM_IMPLICIT           ; $CA

.if .defined(D65C02) .or .defined(D65816)
 .byte OP_WAI, AM_IMPLICIT           ; $CB [WDC 65C02 and 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $CB
.endif

 .byte OP_CPY, AM_ABSOLUTE           ; $CC

 .byte OP_CMP, AM_ABSOLUTE           ; $CD

 .byte OP_DEC, AM_ABSOLUTE           ; $CE

.ifdef ROCKWELL
 .byte OP_BBS, AM_ABSOLUTE           ; $CF [65C02 only]
.elseif .defined(D65816)
 .byte OP_CMP, AM_ABSOLUTE_LONG      ; $CF [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $CF
.endif

 .byte OP_BNE, AM_RELATIVE           ; $D0

 .byte OP_CMP, AM_INDIRECT_INDEXED   ; $D1

.ifdef D65C02
 .byte OP_CMP, AM_INDIRECT_ZEROPAGE  ; $D2 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $D2
.endif

.ifdef D65816
 .byte OP_CMP, AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; $D3 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_PEI, AM_INDIRECT_ZEROPAGE  ; $D4 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_CMP, AM_ZEROPAGE_X         ; $D5

 .byte OP_DEC, AM_ZEROPAGE_X         ; $D6

.ifdef ROCKWELL
 .byte OP_SMB, AM_ZEROPAGE           ; $D7 [65C02 only]
.elseif .defined(D65816)
 .byte OP_CMP, AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; $D7 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $D7
.endif

 .byte OP_CLD, AM_IMPLICIT           ; $D8

 .byte OP_CMP, AM_ABSOLUTE_Y         ; $D9

.ifdef D65C02
 .byte OP_PHX, AM_IMPLICIT           ; $DA [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $CF
.endif

.if .defined(D65C02) .or .defined(D65816)
 .byte OP_STP, AM_IMPLICIT           ; $DB [WDC 65C02 and 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $DB
.endif

.ifdef D65816
 .byte OP_JML, AM_ABSOLUTE_INDIRECT_LONG ; $DC [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_CMP, AM_ABSOLUTE_X         ; $DD

 .byte OP_DEC, AM_ABSOLUTE_X         ; $DE

.ifdef ROCKWELL
 .byte OP_BBS, AM_ABSOLUTE           ; $DF [65C02 only]
.elseif .defined(D65816)
 .byte OP_CMP, AM_ABSOLUTE_LONG_INDEXED_WITH_X ; $DF [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $DF
.endif

 .byte OP_CPX, AM_IMMEDIATE          ; $E0

 .byte OP_SBC, AM_INDEXED_INDIRECT   ; $E1

.ifdef D65816
 .byte OP_SEP, AM_IMMEDIATE          ; $E2 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_SBC, AM_STACK_RELATIVE     ; $E3 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_CPX, AM_ZEROPAGE           ; $E4

 .byte OP_SBC, AM_ZEROPAGE           ; $E5

 .byte OP_INC, AM_ZEROPAGE           ; $E6

.ifdef ROCKWELL
 .byte OP_SMB, AM_ZEROPAGE           ; $E7 [65C02 only]
.elseif .defined(D65816)
 .byte OP_SBC, AM_DIRECT_PAGE_INDIRECT_LONG ; $E7 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $E7
.endif

 .byte OP_INX, AM_IMPLICIT           ; $E8

 .byte OP_SBC, AM_IMMEDIATE          ; $E9

 .byte OP_NOP, AM_IMPLICIT           ; $EA

.ifdef D65816
 .byte OP_XBA, AM_IMPLICIT           ; $EB [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_CPX, AM_ABSOLUTE           ; $EC

 .byte OP_SBC, AM_ABSOLUTE           ; $ED

 .byte OP_INC, AM_ABSOLUTE           ; $EE

.ifdef ROCKWELL
 .byte OP_BBS, AM_ABSOLUTE           ; $EF [65C02 only]
.elseif .defined(D65816)
 .byte OP_SBC, AM_ABSOLUTE_LONG      ; $EF [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $EF
.endif

 .byte OP_BEQ, AM_RELATIVE           ; $F0

 .byte OP_SBC, AM_INDIRECT_INDEXED   ; $F1

.ifdef D65C02
 .byte OP_SBC, AM_INDIRECT_ZEROPAGE  ; $F2 [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $F2
.endif

.ifdef D65816
 .byte OP_SBC, AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; $F3 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_PEA, AM_ABSOLUTE           ; $F4 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_SBC, AM_ZEROPAGE_X         ; $F5

 .byte OP_INC, AM_ZEROPAGE_X         ; $F6

.ifdef ROCKWELL
 .byte OP_SMB, AM_ZEROPAGE           ; $F7 [65C02 only]
.elseif .defined(D65816)
 .byte OP_SBC, AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; $F7 [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $F7
.endif

 .byte OP_SED, AM_IMPLICIT           ; $F8

 .byte OP_SBC, AM_ABSOLUTE_Y         ; $F9

.ifdef D65C02
 .byte OP_PLX, AM_IMPLICIT           ; $FA [65C02 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $FA
.endif

.ifdef D65816
 .byte OP_XCE, AM_IMPLICIT           ; $FB [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

.ifdef D65816
 .byte OP_JSR, AM_ABSOLUTE_INDEXED_INDIRECT ; $FC [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $4F
.endif

 .byte OP_SBC, AM_ABSOLUTE_X         ; $FD

 .byte OP_INC, AM_ABSOLUTE_X         ; $FE

.ifdef ROCKWELL
 .byte OP_BBS, AM_ABSOLUTE           ; $FF [65C02 only]
.elseif .defined(D65816)
 .byte OP_SBC, AM_ABSOLUTE_LONG_INDEXED_WITH_X ; $FF [WDC 65816 only]
.else
 .byte OP_INV, AM_IMPLICIT           ; $FF
.endif
