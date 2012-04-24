; 2KSA - A 2K Symbolic Assembler for the 6502
;
; by Robert Ford Denison

; Global Symbols on Page Zero
IOBUF    = $00           ; I/O Buffer  prompt or command field.
LABEL    = $07           ; I/O buffer; label field.
OPCODE   = $0E           ; I/O buffer; opcode field.
OPRAND   = $15           ; I/O buffer; operand field.
USER     = $23           ; Six bytes available for use by user commands.
ADL      = $29           ; Low address pointer for various subroutines.
ADH      = $2A           ; High address pointer.

         .org $0200
MNETAB:                  ; Three-character ASCII mnemonics for instructions
         .byte "BRK"
         .byte "CLC"
         .byte "CLD"
         .byte "CLI"
         .byte "CLV"
         .byte "DEX"
         .byte "DEY"
         .byte "INX"
         .byte "INY"
         .byte "NOP"
         .byte "PHA"
         .byte "PHP"
         .byte "PLA"
         .byte "PLP"
         .byte "RTI"
         .byte "RTS"
         .byte "SEC"
         .byte "SED"
         .byte "SEI"
         .byte "TAX"
         .byte "TAY"
         .byte "TSX"
         .byte "TXA"
         .byte "TXS"
         .byte "TYA"
         .byte "CPX"
         .byte "STX"
         .byte "LDX"
         .byte "CPY"
         .byte "LDY"
         .byte "STY"
         .byte "ADC"
         .byte "AND"
         .byte "CMP"
         .byte "EOR"
         .byte "LDA"
         .byte "ORA"
         .byte "SBC"
         .byte "STA"
         .byte "ASL"
         .byte "LSR"
         .byte "ROL"
         .byte "ROR"
         .byte "DEC"
         .byte "INC"
         .byte "BIT"
         .byte "JMP"
         .byte "JSR"
         .byte "BCC"
         .byte "BCS"
         .byte "BEQ"
         .byte "BMI"
         .byte "BNE"
         .byte "BPL"
         .byte "BVC"
         .byte "BVS"
        
MODTAB:                         ; Two-character ASCII mode codes.
         .byte "  "
         .byte "A "
         .byte "# "
         .byte "Z "
         .byte "ZX"
         .byte "ZY"
         .byte "IX"
         .byte "IY"
         .byte "  "
         .byte "  "
         .byte "X "
         .byte "Y "
         .byte "I "

MIN:                         ; Minimum legal value for MNE for each mode.
         .byte $00,$27,$19,$19,$1D,$1A,$1F,$1F,$30,$19,$1D,$1B,$2E

MAX:                         ; Lowest illegal value of MNE for each mode.
         .byte $19,$2B,$26,$2E,$2D,$1C,$27,$27,$38,$30,$2D,$27,$2F

BASE:                        ; Base value for mode added to MNE to get OPCPTR
         .byte $00,$F2,$04,$11,$22,$35,$32,$3A,$31,$50,$63,$75,$6E

PRMTAB:
         .byte $0C,$80,$0C,$A5,$02,$0E,$00

OPCTAB:

; Subroutine MATCH. Search table for match to reference, X points to
; search parameters on page zero. Sets z if match found, returns
; number of matching record in X.
MATCH:
        STX     ADL             ; Put address of
        LDX     #$00            ; search parameter
        STX     ADH             ; list in ADL, H.
