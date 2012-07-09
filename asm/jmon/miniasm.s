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
; - 6502 only (initially)
; 
; Future enhancements:
; - optional $ in front of values (to accept back disassembled code)
; - 65C02 instructions
; - 65816 instructions
; - binary, character, decimal constants
; 
; Addressing modes:
; 
; LDA #nn         Immediate           AM_IMMEDIATE
; LDA nn          Zero page           AM_ZEROPAGE
; LDA nnnn        Absolute            AM_ABSOLUTE
; LDA nn,X        Zero page X         AM_ZEROPAGE_X
; LDX nn,Y        Zero page Y         AM_ZEROPAGE_Y
; LDA nnnn,X      Absolute X          AM_ABSOLUTE_X
; LDA nnnn,Y      Absolute X          AM_ABSOLUTE_Y
; LDA (nn,X)      Indexed indirect    AM_INDEXED_INDIRECT
; LDA (nn),Y      Indirect indexed    AM_INDIRECT_INDEXED
; LSR A           Accumulator         AM_ACCUMULATOR
; BEQ nnnn        Relative            AM_RELATIVE
; JMP (nnnn)      Indirect            AM_INDIRECT
; NOP             Implicit            AM_IMPLICIT
;

; Variables:
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

        CMP #'A'
        BMI GetMnem             ; Ignore if less than 'A'
        CMP #'Z'+1
        BPL GetMnem             ; or greater than 'Z'
        STA MNEM,X              ; Valid, so store it.
        JSR PrintChar           ; Echo it
        INX                     ; Advance index
        CPX #3                  ; Done?
        BNE GetMnem             ; If not, continue until we get 3 chars

        JSR LookupMnemonic      ; Look up mnemonic to see if it is valid
        LDA OP                  ; Get the returned opcode
        CMP #OP_INV             ; Not valid?
        BNE OpOk                ; Branch if okay

        JSR PrintCR
        LDX #<InvalidInstructionString  ; Not a valid mnemonic
        LDY #>InvalidInstructionString
        JSR PrintString         ; Print error message
EscPressed:
        JSR PrintCR
        RTS                     ; and return

; Mnemonic is valid. Does instruction use implicit addressing mode (i.e. no operand needed)?

OpOk:
        LDA #AM_IMPLICIT
        STA AM
        JSR CheckAddressingModeValid
        BNE GenerateCode                ; It is implicit, so we can jump to generating the code

; Not implicit addressing mode. Need to get operand from user.

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
  CMP #'A'                      ; Is is 'A'?
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
  JSR IsHexDigit                ; Is is a hex digit?
  BEQ TryZeroPage
  LDA IN+3                      ; Get third char of operand
  JSR IsHexDigit                ; Is is a hex digit?
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


; 
; LDA nnnn        Absolute
; BEQ nnnn        Relative


; 
; 4 hex digits?
; check if it is absolute or relative
; Then call CheckOperandValid
; 
; LDA nn,X        Zero page X
; 2 hex digits followed by ,X
; 
; LDX nn,Y        Zero page Y
; 2 hex digits followed by ,X
; 
; LDA nnnn,X      Absolute X
; 4 hex digits followed by ,X
; 
; LDA nnnn,Y      Absolute X
; 4 hex digits followed by ,Y
; 
; LDA (nn,X)      Indexed indirect
; 
; LDA (nn),Y      Indirect indexed
; 
; JMP (nnnn)      Indirect
; 
; If not any of the above
;   report "Invalid operand"
;   return

GenerateCode:
        JSR PrintCR             ; Output newline

        JSR CheckAddressingModeValid   ; See if addressing mode is valid
        BNE OperandOkay

        LDX #<InvalidAddressingModeString ; Not a valid addressing mode
        LDY #>InvalidAddressingModeString
        JSR PrintString         ; Print error message
        JSR PrintCR
        RTS                     ; and return

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

        LDX #<UnableToWriteString
        LDY #>UnableToWriteString
        JSR PrintString         ; Print error message
        JSR PrintCR
        RTS                     ; and return

; Generate code for operands

WriteOperands:
        LDA AM                  ; get addressing mode
        CMP #AM_IMPLICIT
        BEQ ZeroOperands
        CMP #AM_ACCUMULATOR
        BEQ ZeroOperands

        CMP #AM_IMMEDIATE
        BEQ OneOperand
        CMP #AM_ZEROPAGE
        BEQ OneOperand
        CMP #AM_ZEROPAGE_X
        BEQ OneOperand
        CMP #AM_ZEROPAGE_Y
        BEQ OneOperand
        CMP #AM_INDEXED_INDIRECT
        BEQ OneOperand
        CMP #AM_INDIRECT_INDEXED
        BEQ OneOperand

        CMP #AM_ABSOLUTE
        BEQ TwoOperands
        CMP #AM_ABSOLUTE_X
        BEQ TwoOperands
        CMP #AM_ABSOLUTE_Y
        BEQ TwoOperands
        CMP #AM_INDIRECT
        BEQ TwoOperands

        CMP #AM_RELATIVE
        BEQ Relative

Relative:

; BEQ nnnn        Relative
; Write 1 byte calculated as destination (nnnn) - current address - instruction length (2)


        JMP ZeroOperands             ; done

OneOperand:
        LDA OPERAND                  ; Get operand
        LDY #1                       ; Offset from instruction
        STA (ADDR),Y                 ; write it
        JMP ZeroOperands             ; done

TwoOperands:
        LDA OPERAND+1                ; Get operand low byte
        LDY #1                       ; Offset from instruction
        STA (ADDR),Y                 ; write it
        INY
        LDA OPERAND+1                ; Get operand high byte
        STA (ADDR),Y                 ; write it
        JMP ZeroOperands             ; done

ZeroOperands:           ; nothing to do

; Update current address with instruction length

       CLC
       LDA ADDR                      ; Low byte
       ADC LEN                       ; Add length
       STA ADDR                      ; Store it
       LDA ADDR+1                    ; High byte
       ADC #0                        ; Add any carry
       STA ADDR+1                    ; Store it
       JMP AssembleLine              ; loop back to start of AssembleLine

; Look up three letter mnemonic, e.g. "NOP". In entry mnemonic is stored in MNEM.
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

; Return if a character is a valid hex digit (0-9 or A-F).
; Pass character in A.
; Returns 1 in A if valid, 0 if not valid.
; Registers affected: A
IsHexDigit:
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
        CMP #'9'+1              ; Is is '0'-'9'?
        BMI @Digit              ; Branch if so
        SEC                     ; Otherwise must be 'A'-'F'
        SBC #'A'-10             ; convert to value
        RTS
@Digit:
        SEC
        SBC #'0'                ; convert to value
        RTS
