;
; 6502/65C02 Mini Assembler
;
; Copyright (C) 2012-2016 by Jeff Tranter <tranter@pobox.com>
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

; Mini assembler syntax format:
;
; A <address>
; XXXX: instruction
; XXXX: instruction
; XXXX: <Esc>
;
; example:
;
; A 6000
; 6000: NOP
; 6001: LDX #0A
; 6003: JSR FFEF
; 6006: DEX
; 6007: BNE 6003
; 6009: <Esc>
;
; Restrictions:
; - no symbols or labels
; - all values in hex, 2 or 4 digits
; - no backspace or other editing features
;

; Variables used (defined in jmon.s)
; ADDR - instruction address
; OPCODE - instruction op code
; OP - instruction type (OP_*)
; LEN -length of instruction
; IN - input buffer holding operands
; AM - addressing mode (AM_*)
; MNEM - hold three letter mnemonic string used by assembler
; OPERAND - Holds any operands for assembled instruction (2 bytes)


; Assemble code entered a line at a time.
; On entry ADDR contains start address of code.
; Registers changed: A, X, Y.

AssembleLine:
        LDX ADDR                ; output address
        LDY ADDR+1
        JSR PrintAddress
        LDA #':'                ; Output colon
        JSR PrintChar
        JSR PrintSpace          ; And space

; Input three letter for mnemonic (filter for valid alphabetic characters). Esc will terminate.

        LDX #0                  ; Index into MNEM
GetMnem:
        JSR GetKey              ; Get a character
        CMP #ESC                ; <Esc> key?
        BEQ EscPressed          ; If so, handle it
        JSR ToUpper
        CMP #'A'
        BMI GetMnem             ; Ignore if less than 'A'
        CMP #'Z'+1
        BPL GetMnem             ; or greater than 'Z'
        STA MNEM,X              ; Valid, so store it.
.ifdef ECHO
        JSR PrintChar           ; Echo it
.endif
        INX                     ; Advance index
        CPX #3                  ; Done?
        BNE GetMnem             ; If not, continue until we get 3 chars

        JSR LookupMnemonic      ; Look up mnemonic to see if it is valid
        LDA OP                  ; Get the returned opcode
        CMP #OP_INV             ; Not valid?
        BNE OpOk                ; Branch if okay

        JSR PrintCR
        JSR Imprint            ; Not a valid mnemonic
        .byte "Invalid instruction", 0

EscPressed:
        JMP PrintCR             ; Return via caller

; Mnemonic is valid. Does instruction use implicit addressing mode (i.e. no operand needed)?

OpOk:
        LDA #AM_IMPLICIT
        STA AM
        JSR CheckAddressingModeValid
        BEQ GetOperands
        JMP GenerateCode                ; It is implicit, so we can jump to generating the code

; Not implicit addressing mode. Need to get operand from user.

GetOperands:
        JSR PrintSpace          ; Output a space
        JSR GetLine             ; Get line of input for operand(s)
        BCS EscPressed          ; Check if cancelled by Esc key

; Check for addressing mode. Have already checked for implicit.

; AM_ACCUMULATOR, e.g. LSR A
; Operand is just "A"
        LDA IN                        ; Get length
        CMP #1                        ; Is it 1?
        BNE TryImm
        LDA IN+1                      ; Get first char of operand
        JSR ToUpper
        CMP #'A'                      ; Is it 'A'?
        BNE TryImm
        LDA #AM_ACCUMULATOR           ; Yes, is is accumulator mode
        STA AM                        ; Save it
        JMP GenerateCode

; AM_IMMEDIATE, e.g. LDA #nn
; Operand is '#' followed by 2 hex digits.
TryImm:
        LDA IN                        ; Get length
        CMP #3                        ; Is it 3?
        BNE TryZeroPage
        LDA IN+1                      ; Get first char of operand
        CMP #'#'                      ; is it '#'?
        BNE TryZeroPage
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryZeroPage
        LDA IN+3                      ; Get third char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryZeroPage
        LDA #AM_IMMEDIATE             ; Yes, this is immediate mode
        STA AM                        ; Save it
        LDX IN+2                      ; Get operand characters
        LDY IN+3
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_ZEROPAGE e.g. LDA nn
; Operand is 2 hex digits.
TryZeroPage:
        LDA IN                        ; Get length
        CMP #2                        ; Is it 2?
        BNE TryAbsRel
        LDA IN+1                      ; Get first char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsRel
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsRel
        LDA #AM_ZEROPAGE              ; Yes, this is zero page
        STA AM                        ; Save it
        LDX IN+1                      ; Get operand characters
        LDY IN+2
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_ABSOLUTE, e.g. LDA nnnn or AM_RELATIVE, e.g. BEQ nnnn
; Operand is 4 hex digits.

TryAbsRel:
        LDA IN                        ; Get length
        CMP #4                        ; Is it 4?
        BNE TryZeroPageX
        LDA IN+1                      ; Get first char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryZeroPageX
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryZeroPageX
        LDA IN+3                      ; Get third char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryZeroPageX
        LDA IN+4                      ; Get fourth char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryZeroPageX

; It could be absolute or relative, depending on the instruction.
; Test both to see which one, if any, is valid.

        LDA #AM_ABSOLUTE              ; Try absolute addressing mode
        STA AM                        ; Save it
        JSR CheckAddressingModeValid
        BEQ TryRelative               ; No, try relative

Save2Operands:
        LDX IN+1                      ; Get operand characters
        LDY IN+2
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND+1                 ; Save it as the operand
        LDX IN+3                      ; Get operand characters
        LDY IN+4
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

TryRelative:
        LDA #AM_RELATIVE              ; Try relative addressing mode
        STA AM                        ; Save it
        JSR CheckAddressingModeValid
        BEQ TryZeroPageX              ; No, try other modes
        JMP Save2Operands

; AM_ZEROPAGE_X e.g. LDA nn,X
; Operand is 2 hex digits followed by ,X

TryZeroPageX:
        LDA IN                        ; Get length
        CMP #4                        ; Is it 4?
        BNE TryZeroPageY
        LDA IN+1                      ; Get first char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryZeroPageY
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryZeroPageY
        LDA IN+3                      ; Get third char of operand
        CMP #','                      ; Is it a comma?
        BNE TryZeroPageY
        LDA IN+4                      ; Get fourth char of operand
        JSR ToUpper
        CMP #'X'                      ; Is it an X?
        BNE TryZeroPageY
        LDA #AM_ZEROPAGE_X            ; Yes, this is zero page X
        STA AM                        ; Save it
        LDX IN+1                      ; Get operand characters
        LDY IN+2
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_ZEROPAGE_Y e.g. LDA nn,Y
; 2 hex digits followed by ,Y
TryZeroPageY:
        LDA IN                        ; Get length
        CMP #4                        ; Is it 4?
        BNE TryAbsoluteX
        LDA IN+1                      ; Get first char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsoluteX
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsoluteX
        LDA IN+3                      ; Get third char of operand
        CMP #','                      ; Is it a comma?
        BNE TryAbsoluteX
        LDA IN+4                      ; Get fourth char of operand
        JSR ToUpper
        CMP #'Y'                      ; Is it an Y?
        BNE TryAbsoluteX
        LDA #AM_ZEROPAGE_Y            ; Yes, this is zero page Y
        STA AM                        ; Save it
        LDX IN+1                      ; Get operand characters
        LDY IN+2
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_ABSOLUTE_X, e.g. LDA nnnn,X
; 4 hex digits followed by ,X
TryAbsoluteX:
        LDA IN                        ; Get length
        CMP #6                        ; Is it 6?
        BNE TryAbsoluteY
        LDA IN+1                      ; Get first char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsoluteY
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsoluteY
        LDA IN+3                      ; Get third char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsoluteY
        LDA IN+4                      ; Get fourth char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsoluteY
        LDA IN+5
        CMP #','
        BNE TryAbsoluteY
        LDA IN+6
        JSR ToUpper
        CMP #'X'
        BNE TryAbsoluteY
        LDA #AM_ABSOLUTE_X
        STA AM
        LDX IN+1                      ; Get operand characters
        LDY IN+2
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND+1                 ; Save it as the operand
        LDX IN+3                      ; Get operand characters
        LDY IN+4
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_ABSOLUTE_Y, e.g. LDA nnnn,Y
; 4 hex digits followed by ,Y
TryAbsoluteY:
        LDA IN                        ; Get length
        CMP #6                        ; Is it 6?
        BNE TryIndexedIndirect
        LDA IN+1                      ; Get first char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndexedIndirect
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndexedIndirect
        LDA IN+3                      ; Get third char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndexedIndirect
        LDA IN+4                      ; Get fourth char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndexedIndirect
        LDA IN+5
        CMP #','
        BNE TryIndexedIndirect
        LDA IN+6
        JSR ToUpper
        CMP #'Y'
        BNE TryIndexedIndirect
        LDA #AM_ABSOLUTE_Y
        STA AM
        LDX IN+1                      ; Get operand characters
        LDY IN+2
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND+1                 ; Save it as the operand
        LDX IN+3                      ; Get operand characters
        LDY IN+4
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_INDEXED_INDIRECT, e.g. LDA (nn,X)
TryIndexedIndirect:
        LDA IN                        ; Get length
        CMP #6                        ; Is it 6?
        BNE TryIndirectIndexed
        LDA IN+1                      ; Get first char of operand
        CMP #'('
        BNE TryIndirectIndexed
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndirectIndexed
        LDA IN+3                      ; Get third char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndirectIndexed
        LDA IN+4                      ; Get fourth char of operand
        CMP #','                      ; Is it a comma?
        BNE TryIndirectIndexed
        LDA IN+5                      ; Get fifth char of operand
        JSR ToUpper
        CMP #'X'                      ; Is it an X?
        BNE TryIndirectIndexed
        LDA IN+6                      ; Get sixth char of operand
        CMP #')'                      ; Is it an )?
        BNE TryIndirectIndexed
        LDA #AM_INDEXED_INDIRECT      ; Yes, this is indexed indirect
        STA AM                        ; Save it
        LDX IN+2                      ; Get operand characters
        LDY IN+3
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_INDIRECT_INDEXED, e.g. LDA (nn),Y
TryIndirectIndexed:
        LDA IN                        ; Get length
        CMP #6                        ; Is it 6?
        BNE TryIndirect
        LDA IN+1                      ; Get first char of operand
        CMP #'('
        BNE TryIndirect
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndirect
        LDA IN+3                      ; Get third char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndirect
        LDA IN+4                      ; Get fourth char of operand
        CMP #')'                      ; Is it a )?
        BNE TryIndirect
        LDA IN+5                      ; Get fifth char of operand
        CMP #','                      ; Is it a comma?
        BNE TryIndirect
        LDA IN+6                      ; Get sixth char of operand
        JSR ToUpper
        CMP #'Y'                      ; Is it a Y?
        BNE TryIndirect
        LDA #AM_INDIRECT_INDEXED      ; Yes, this is indirect indexed
        STA AM                        ; Save it
        LDX IN+2                      ; Get operand characters
        LDY IN+3
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_INDIRECT, e.g. JMP (nnnn)
; l paren, 4 hex digits, r paren
TryIndirect:
        LDA IN                        ; Get length
        CMP #6                        ; Is it 6?
        BNE TryIndirectZP
        LDA IN+1                      ; Get first char of operand
        CMP #'('
        BNE TryIndirectZP
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndirectZP
        LDA IN+3                      ; Get third char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndirectZP
        LDA IN+4                      ; Get fourth char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndirectZP
        LDA IN+5                      ; Get fifth char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryIndirectZP
        LDA IN+6                      ; Get fourth char of operand
        CMP #')'                      ; Is it a )?
        BNE TryIndirectZP
        LDA #AM_INDIRECT              ; Yes, this is indirect
        STA AM                        ; Save it

        LDX IN+2                      ; Get operand characters
        LDY IN+3
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND+1                 ; Save it as the operand
        LDX IN+4                      ; Get operand characters
        LDY IN+5
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_INDIRECT_ZEROPAGE, e.g. LDA (nn) [65C02 only]
TryIndirectZP:
        LDA IN                        ; Get length
        CMP #4                        ; Is it 4?
        BNE TryAbsIndInd
        LDA IN+1                      ; Get first char of operand
        CMP #'('
        BNE TryAbsIndInd
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsIndInd
        LDA IN+3                      ; Get third char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ TryAbsIndInd
        LDA IN+4                      ; Get fourth char of operand
        CMP #')'                      ; Is it a )?
        BNE TryAbsIndInd
        LDA #AM_INDIRECT_ZEROPAGE     ; Yes, this is indirect zeropage
        STA AM                        ; Save it

        LDX IN+2                      ; Get operand characters
        LDY IN+3
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; AM_ABSOLUTE_INDEXED_INDIRECT, e.g. JMP (nnnn,X) [65C02 only]
TryAbsIndInd:
        LDA IN                        ; Get length
        CMP #8                        ; Is it 8?
        BNE InvalidOp
        LDA IN+1                      ; Get first char of operand
        CMP #'('
        BNE InvalidOp
        LDA IN+2                      ; Get second char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ InvalidOp
        LDA IN+3                      ; Get third char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ InvalidOp
        LDA IN+4                      ; Get fourth char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ InvalidOp
        LDA IN+5                      ; Get fifth char of operand
        JSR IsHexDigit                ; Is it a hex digit?
        BEQ InvalidOp
        LDA IN+6                      ; Get sixth char of operand
        CMP #','                      ; Is it a ,?
        BNE InvalidOp
        LDA IN+7                      ; Get 7th char of operand
        JSR ToUpper
        CMP #'X'                      ; Is it a X?
        BNE InvalidOp
        LDA IN+8                      ; Get 8th char of operand
        CMP #')'                      ; Is it a )?
        BNE InvalidOp
        LDA #AM_ABSOLUTE_INDEXED_INDIRECT ; Yes, this is abolute indexed indirect
        STA AM                        ; Save it

        LDX IN+2                      ; Get operand characters
        LDY IN+3
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND+1                 ; Save it as the operand
        LDX IN+4                      ; Get operand characters
        LDY IN+5
        JSR TwoCharsToBin             ; Convert to binary
        STA OPERAND                   ; Save it as the operand
        JMP GenerateCode

; If not any of the above, report "Invalid operand" and return.

InvalidOp:
        JSR PrintCR
        JSR Imprint
        .byte "Invalid operand", 0
        JMP PrintCR             ; Return via caller

GenerateCode:
        JSR PrintCR             ; Output newline

        JSR CheckAddressingModeValid   ; See if addressing mode is valid
        BNE OperandOkay

        JSR Imprint             ; Not a valid addressing mode
        .byte "Invalid addressing mode", 0

        JMP PrintCR             ; Return via caller

OperandOkay:

; Look up instruction length based on addressing mode and save it

        LDX AM                   ; Addressing mode
        LDA LENGTHS,X            ; Get instruction length for this addressing mode
        STA LEN                  ; Save it

; Write the opcode to memory

        LDA OPCODE               ; get opcode
        LDY #0
        STA (ADDR),Y             ; store it

; Check that we can write it back (in case destination memory is not writable).

        CMP (ADDR),Y             ; Do we read back what we wrote?
        BEQ WriteOperands        ; Yes, okay

; Memory is not writable for some reason, Report error and quit.

        JSR Imprint              ; Print error message
        .byte "Unable to write to $", 0
        LDX ADDR
        LDY ADDR+1
        JSR PrintAddress
        JMP PrintCR             ; Return via caller

; Generate code for operands

WriteOperands:
        LDA AM                  ; get addressing mode
        CMP #AM_IMPLICIT        ; These modes take no operands
        BNE TryAcc
        JMP ZeroOperands
TryAcc:
        CMP #AM_ACCUMULATOR
        BNE TryImmed
        JMP ZeroOperands

TryImmed:
        CMP #AM_IMMEDIATE       ; These modes take one operand
        BNE TryZp
        JMP OneOperand
TryZp:  CMP #AM_ZEROPAGE
        BNE TryZpX
        JMP OneOperand
TryZpX: CMP #AM_ZEROPAGE_X
        BNE TryZpY
        JMP OneOperand
TryZpY: CMP #AM_ZEROPAGE_Y
        BEQ OneOperand
        CMP #AM_INDEXED_INDIRECT
        BEQ OneOperand
        CMP #AM_INDIRECT_INDEXED
        BEQ OneOperand
        CMP #AM_INDIRECT_ZEROPAGE ; [65C02 only]
        BEQ OneOperand

        CMP #AM_ABSOLUTE       ; These modes take two operands
        BEQ TwoOperands
        CMP #AM_ABSOLUTE_X
        BEQ TwoOperands
        CMP #AM_ABSOLUTE_Y
        BEQ TwoOperands
        CMP #AM_INDIRECT
        BEQ TwoOperands
        CMP #AM_ABSOLUTE_INDEXED_INDIRECT
        BEQ TwoOperands

        CMP #AM_RELATIVE       ; Relative is special case
        BNE ZeroOperands

; BEQ nnnn        Relative
; Write 1 byte calculated as destination - current address - instruction length
; i.e. (OPERAND,OPERAND+1) - ADDR,ADDR+1 - 2
; Report error if branch is out of 8-bit offset range.

Relative:
         LDA OPERAND                 ; destination low byte
         SEC
         SBC ADDR                    ; subtract address low byte
         STA OPERAND                 ; Save it
         LDA OPERAND+1               ; destination high byte
         SBC ADDR+1                  ; subtract address high byte (with any borrow)
         STA OPERAND+1               ; store it

         LDA OPERAND
         SEC
         SBC #2                      ; subtract 2 more
         STA OPERAND                 ; store it
         LDA OPERAND+1               ; destination high byte
         SBC #0                      ; subtract 0 (with any borrow)
         STA OPERAND+1               ; store it

; Report error if branch is out of 8-bit offset range.
; Valid range is $0000 - $007F and $FF80 - $FFFF

         LDA OPERAND+1              ; High byte
         BEQ OkayZero               ; Should be $))
         CMP #$FF
         BEQ OkayFF                 ; Or $FF
OutOfRange:
         JSR Imprint
         .byte "Relative branch out of range", 0
         JMP PrintCR                ; Return via caller

OkayZero:
         LDA OPERAND                ; Low byte
         BMI OutOfRange             ; must be $00-$7F (i.e. positive)
         JMP OneOperand

OkayFF:
         LDA OPERAND                ; Low byte
         BPL OutOfRange             ; must be $80-$FF (i.e. negative)

; Now fall through to one operand code

OneOperand:
        LDA OPERAND                  ; Get operand
        LDY #1                       ; Offset from instruction
        STA (ADDR),Y                 ; write it
        JMP ZeroOperands             ; done

TwoOperands:
        LDA OPERAND                  ; Get operand low byte
        LDY #1                       ; Offset from instruction
        STA (ADDR),Y                 ; write it
        INY
        LDA OPERAND+1                ; Get operand high byte
        STA (ADDR),Y                 ; write it

ZeroOperands:                        ; Nothing to do

; Update current address with instruction length

       CLC
       LDA ADDR                      ; Low byte
       ADC LEN                       ; Add length
       STA ADDR                      ; Store it
       LDA ADDR+1                    ; High byte
       ADC #0                        ; Add any carry
       STA ADDR+1                    ; Store it
       JMP AssembleLine              ; loop back to start of AssembleLine

; Look up three letter mnemonic, e.g. "NOP". On entry mnemonic is stored in MNEM.
; Write index value, e.g. OP_NOP, to OP. Set sit to OP_INV if not found.
; Registers changed: A, X, Y.
LookupMnemonic:
        LDX #0                  ; Holds current table index
        LDA #<MNEMONICS         ; Store address of start of table in T1 (L/H)
        STA T1
        LDA #>MNEMONICS
        STA T1+1
Loop:
        LDY #0                  ; Holds offset of string in table entry
        LDA MNEM,Y              ; Compare first char of mnemonic to table entry
        CMP (T1),Y
        BNE NextOp              ; If different, try next opcode
        INY
        LDA MNEM,Y              ; Compare second char of mnemonic to table entry
        CMP (T1),Y
        BNE NextOp              ; If different, try next opcode
        INY
        LDA MNEM,Y              ; Compare third char of mnemonic to table entry
        CMP (T1),Y
        BNE NextOp              ; If different, try next opcode

                                ; We found a match
        STX OP                  ; Store index in table (X) in OP
        RTS                     ; And return

NextOp:
        INX                     ; Increment table index
        CLC
        LDA T1                  ; Increment pointer to table entry (T1) as 16-bit value
        ADC #3                  ; Adding three because each entry is 3 bytes
        STA T1
        LDA T1+1                ; Add possible carry to high byte
        ADC #0
        STA T1+1

        LDA T1                  ; Did we reach the last entry (MNEMONICSEND?)
        CMP #<MNEMONICSEND      ; If not, keep searching
        BNE Loop
        LDA T1+1
        CMP #>MNEMONICSEND
        BNE Loop

                                ; End of table reached
        LDA #OP_INV             ; Value is not valid
        STA OP
        RTS

; Given an instruction and addressing mode, return if it is valid.
; When called OP should contain instruction (e.g. OP_NOP) and
; AM contain the addressing mode (e.g. AM_IMPLICIT).
; If valid, sets OPCODE to the opcode (eg. $EA for NOP) and returns 1
; in A. If not valid, returns 0 in A.
; Registers changed: A, X, Y.

CheckAddressingModeValid:
        LDX #0                  ; Holds current table index
        LDA #<OPCODES           ; Store address of start of table in T1 (L/H)
        STA T1
        LDA #>OPCODES
        STA T1+1
OpLoop:
        LDY #0                  ; Holds offset into table entry
        LDA (T1),Y              ; Get a table entry (instruction)
        CMP OP                  ; Is it the instruction we are looking for?
        BNE NextInst            ; If different, try next opcode
                                ; Instruction matched. Does the addressing mode match?
        INY                     ; Want second byte of table entry (address mode)
        LDA (T1),Y              ; Get a table entry (address mode
        CMP AM                  ; Is it the address mode we are looking for?
        BNE NextInst            ; If different, try next opcode
                                ; We found a match
        TXA                     ; Get index in table (X), the opcode
        STA OPCODE              ; Store it
        LDA #1                  ; Set true return value
        RTS                     ; And return

NextInst:
        INX                     ; Increment table index
        BEQ OpNotFound          ; If wrapped past $FF, we did not find what we were looking for
        CLC
        LDA T1                  ; Increment pointer to table entry (T1) as 16-bit value
        ADC #2                  ; Add two because each entry is 2 bytes
        STA T1
        LDA T1+1                ; Add possible carry to high byte
        ADC #0
        STA T1+1
        JMP OpLoop

OpNotFound:                     ; End of table reached
        LDA #0                  ; Set false return value
        RTS

; Return if a character is a valid hex digit (0-9, A-F, or a-f).
; Pass character in A.
; Returns 1 in A if valid, 0 if not valid.
; Registers affected: A
IsHexDigit:
        JSR ToUpper
        CMP #'0'
        BMI @Invalid
        CMP #'9'+1
        BMI @Okay
        CMP #'A'
        BMI @Invalid
        CMP #'F'+1
        BMI @Okay
@Invalid:
        LDA #0
        RTS
@Okay:
        LDA #1
        RTS

; Convert two characters containing hex digits to binary
; Chars passed in X (first char) and Y (second char).
; Returns value in A.
; e.g. X='1' Y='A' Returns A = $1A
; Does not check that characters are valid hex digits
TwoCharsToBin:
        TXA                     ; get first digit
        JSR CharToBin           ; convert to binary
        ASL A                   ; shift to upper nibble
        ASL A
        ASL A
        ASL A
        STA T1                  ; Save it
        TYA                     ; get second digit
        JSR CharToBin           ; convert to binary
        CLC
        ADC T1                  ; Add the upper nibble
        RTS

; Convert character containing a hex digit to binary.
; Char passed in A. Returns value in A.
; e.g. A='A' Returns A=$0A
; Does not check that character is valid hex digit.
CharToBin:
        JSR ToUpper
        CMP #'9'+1              ; Is it '0'-'9'?
        BMI @Digit              ; Branch if so
        SEC                     ; Otherwise must be 'A'-'F'
        SBC #'A'-10             ; convert to value
        RTS
@Digit:
        SEC
        SBC #'0'                ; convert to value
        RTS
