; 2KSA - A 2K Symbolic Assembler for the 6502
;
; by Robert Ford Denison

; Global Symbols on Page Zero
IOBUF   = $00           ; I/O Buffer; prompt or command field.
LABEL   = $07           ; I/O buffer; label field.
OPCODE  = $0E           ; I/O buffer; opcode field.
OPRAND  = $15           ; I/O buffer; operand field.
USER    = $23           ; Six bytes available for use by user commands.
ADL     = $29           ; Low address pointer for various subroutines.
ADH     = $2A           ; High address pointer.
MISCL   = $2B           ; Miscellaneous uses.
MISCH   = $2C           ; Ditto.
TEMP    = $2D           ; Various temporary uses.
MNE     = $2E           ; Mnemonic code.
BYTES   = $2F           ; Lengths of lines, etc.
TBL     = $30           ; Low address pointer for table; used by MATCH.
TBH     = $31           ; High address pointer (Subroutine MATCH).
RFL     = $32           ; Low address pointer for string to be matched.
RFH     = $33           ; High address pointer (MATCH).
LEN     = $34           ; Length of each record in table (MATCH).
HBC     = $35           ; Number of highest bye in record which must match.
NUM     = $36           ; Number of highest record in table (MATCH).
OPCPTR  = $37           ; Pointer to opcode in OPCTAB.
PRNTOK  = $38           ; Flag to enable printing by Subroutine PRNTCK.
WRONG   = $39           ; Flag for illegal line numbers (PRNTCK).
MODE    = $3A           ; Code for address mode.
SAVX    = $3B           ; Used to preserve X register.
GLOBAL  = $3C           ; Number of last global symbol.
PRGLEN  = $3D           ; Length of source code.
CRNTAL  = $3E           ; Low address pointer to current source code line.
CRNTAH  = $3F           ; High address pointer.
MDLADL  = $40           ; Module pointer, low address.
MDLADH  = $41           ; Module pointer, high address.
MNETBL  = $42           ; Parameters for MNETAB (see TBL to NUM above).
MODTBL  = $49           ; Parameters for MODTAB.
SYMTBL  = $50           ; Low address pointer to last entry in symbol table.
SYMTBH  = $51           ; High address pointer.
SYMRFL  = $52           ; Low address pointer for symbol to be compared.
SYMRFH  = $53           ; High address pointer.
SYMNUM  = $56           ; Number of last symbol.
OBJECT  = $57           ; Low address pointer to object code.
OBJCT1  = $58           ; High address pointer.
FIRST   = $59           ; First line in range for print (PRNTCK).
LAST    = $5A           ; First line after print range.
LAST2   = $5B           ; High order address; same as CRNTAH.

        .org $0200

MNETAB: ; Three-character ASCII mnemonics for instructions
	.byte   "BRK"
        .byte   "CLC"
        .byte   "CLD"
        .byte   "CLI"
        .byte   "CLV"
        .byte   "DEX"
        .byte   "DEY"
        .byte   "INX"
        .byte   "INY"
        .byte   "NOP"
        .byte   "PHA"
        .byte   "PHP"
        .byte   "PLA"
        .byte   "PLP"
        .byte   "RTI"
        .byte   "RTS"
        .byte   "SEC"
        .byte   "SED"
        .byte   "SEI"
        .byte   "TAX"
        .byte   "TAY"
        .byte   "TSX"
        .byte   "TXA"
        .byte   "TXS"
        .byte   "TYA"
        .byte   "CPX"
        .byte   "STX"
        .byte   "LDX"
        .byte   "CPY"
        .byte   "LDY"
        .byte   "STY"
        .byte   "ADC"
        .byte   "AND"
        .byte   "CMP"
        .byte   "EOR"
        .byte   "LDA"
        .byte   "ORA"
        .byte   "SBC"
        .byte   "STA"
        .byte   "ASL"
        .byte   "LSR"
        .byte   "ROL"
        .byte   "ROR"
        .byte   "DEC"
        .byte   "INC"
        .byte   "BIT"
        .byte   "JMP"
        .byte   "JSR"
        .byte   "BCC"
        .byte   "BCS"
        .byte   "BEQ"
        .byte   "BMI"
        .byte   "BNE"
        .byte   "BPL"
        .byte   "BVC"
        .byte   "BVS"
        
MODTAB: ; Two-character ASCII mode codes.
        .byte   "  "
        .byte   "A "
        .byte   "# "
        .byte   "Z "
        .byte   "ZX"
        .byte   "ZY"
        .byte   "IX"
        .byte   "IY"
        .byte   "  "
        .byte   "  "
        .byte   "X "
        .byte   "Y "
        .byte   "I "

MIN: ; Minimum legal value for MNE for each mode.
        .byte   $00,$27,$19,$19,$1D,$1A,$1F,$1F,$30,$19,$1D,$1B,$2E

MAX: ; Lowest illegal value of MNE for each mode.
        .byte   $19,$2B,$26,$2E,$2D,$1C,$27,$27,$38,$30,$2D,$27,$2F

BASE: ; Base value for mode added to MNE to get OPCPTR
        .byte   $00,$F2,$04,$11,$22,$35,$32,$3A,$31,$50,$63,$75,$6E

PRMTAB: ; Initialization values for CRNTAH through SYMNUM.
        .byte   $0C,$80,$0C,$A5,$02,$0E,$00,$03,$02,$37,$C0,$02,$11,$00,$02,$01,$0C,$F8,$09,$15,$00,$08,$05,$08

USRPRM: ; Four bytes available for user parameters.
        .byte   $FF,$FF,$FF,$FF

OPCTAB: ; Machine language opcodes pointed to by OPCPTR
        .byte   $00,$18,$D8,$58,$B8,$CA,$88,$E8,$C8,$EA,$48
        .byte   $08,$68,$28,$40,$60,$38,$F8,$78,$AA,$A8,$BA,$BA,$9A,$98,$0A,$4A
        .byte   $2A,$6A,$E0,$FF,$A2,$C0,$A0,$FF,$69,$29,$C9,$49,$A9,$09,$E9,$E4
        .byte   $86,$A6,$C4,$A4,$84,$65,$25,$C5,$45,$A5,$05,$E5,$85,$06,$46,$26
        .byte   $66,$C6,$E6,$24,$B4,$94,$75,$35,$D5,$55,$B5,$15,$F5,$95,$16,$56
        .byte   $36,$76,$D6,$F6,$B6,$96,$61,$21,$C1,$41,$A1,$01,$E1,$81,$71,$31
        .byte   $D1,$51,$B1,$11,$F1,$91,$90,$B0,$F0,$30,$D0,$10,$50,$70,$EC,$8E
        .byte   $AE,$CC,$AC,$8C,$6D,$2D,$CD,$4D,$AD,$0D,$ED,$8D,$0E,$4E,$2E,$6E
        .byte   $CE,$EE,$2C,$4C,$20,$BC,$FF,$7D,$3D,$DD,$5D,$BD,$1D,$FD,$9D,$1E
        .byte   $5E,$3E,$7E,$DE,$FE,$BE,$FF,$FF,$FF,$79,$39,$D9,$59,$B9,$19,$F9
        .byte   $99,$6C,$FF
        
; Subroutine MATCH. Search table for match to reference, X points to
; search parameters on page zero. Sets z if match found, returns
; number of matching record in X.
        .proc   MATCH
        STX     ADL             ; Put address of
        LDX     #0              ; search parameter
        STX     ADH             ; list in ADL, H.
        LDY     #6              
PARAM:  LDA     (ADL),Y         ; Move parameters
        STA     TBL,Y           ; to workspace.
        DEY
        BPL     PARAM
        LDX     NUM             ; Compare X records
RECORD: LDY     HBC
BYTE:   LDA     (TBL),Y         ; First Y+1 bytes
        CMP     (RFL),Y         ; must match.
        BEQ     OK
        LDY     #$FF            ; Mismatch.
 OK:    DEY
        BPL     BYTE
        INY                     ; All ok?
        BNE     INCADR
        RTS
INCADR: SEC                     ; z set.
        LDA     TBL             ; Find base address
        SBC     LEN             ; of next record.
        STA     TBL
        BCS     DECNUM
        DEC     TBH
DECNUM: DEX
        BPL     RECORD          ; Last record?
        RTS                     ; z clear.
        .endproc

; Subroutine HEX. Convert ASCII character pointed to by X to 4 binary bits in A.
        .proc HEX
        LDA     IOBUF,X         ; Get character.
        CMP     #$40            ; Number of letter?
        BMI     NUMER
        SEC                     ; Letter; adjust.
        SBC     #7
NUMER:  AND     #$0F            ; Convert to binary.
        RTS
        .endproc

; Subroutine HX2BIN. Convert 2 ASCII characters on page zero, pointedto by X, to 8 binary bits in X.
        .proc HX2BIN
        JSR     HEX             ; Find high byte.
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        STA     TEMP
        INX                     ; and low byte.
        JSR     HEX
        ORA     TEMP            ; Combine.
        TAX
        RTS
        .endproc

; Subroutine BIN2HX. Convert 4 bits in A to an ASCII character. Store in page zero, X.
        .proc   BIN2HX
        CMP     #$0A            ; Number of letter?
        BMI     NUMER
        CLC                     ; Letter; adjust.
        ADC     #7
NUMER:  CLC                     ; Convert to ASCII
        ADC     #'0'
        STA     IOBUF,X         ; Store character.
        RTS
        .endproc

; Subroutine DSPHEX. Convert binary number in A to two ASCII (hexadecimal) characters in page zero locations X, X+1.
        .proc   DSPHEX
        PHA                     ; Save number.
        LSR     A               ; Find high character.
        LSR     A
        LSR     A
        LSR     A
        JSR     BIN2HX          ; Find low character.
        INX
        PLA
        AND     #$0F
        JSR     BIN2HX
        RTS
        .endproc

; Subroutine SYM. Puts base address of symbol table entry X in MISCL, H.
        .proc SYM
        SEC                     ; Find difference.
        STX   TEMP              ; Between last
        LDA   SYMNUM            ; record and X.
        SBC   TEMP
        STA   MISCL
        LDA   #0
        STA   MISCH
        CLC
        LDY   #2
X8:     ROL   MISCL             ; Multiply by 8
        ROL   MISCH             ; bytes per record.
        DEY
        BPL   X8
        SEC                     ; Subtract from
        LDA   SYMTBL            ; address of
        SBC   MISCL             ; last record.
        STA   MISCL
        LDA   SYMTBH
        SBC   MISCH
        STA   MISCH
        RTS
        .endproc

; Subroutine ADDRSS. Puts address corresponding to symbol X in ADL. H.
        .proc ADDRSS
        JSR   SYM               ; Get base address
        LDY   #6                ; Get symbol address.
        LDA   (MISCL),Y
        STA   ADL               ; Put in ADL, H.
        INY
        LDA   (MISCL),Y
        STA   ADH
        RTS
        .endproc

; Subroutine ADDLAB. Add symbol to table. A points to 6 zpage bytes containing symbol. Returns number of new symbol in X.
        .proc ADDLAB
        STA   ADL               ; ADL,H points
        LDA   #0                ; to symbol.
        STA   ADH
        CLC
        LDA   SYMTBL            ; Find new base
        ADC   #8                ; address of
        STA   SYMTBL            ; symbol table.
        BCC   NOADDR
        INC   SYMTBH
NOADDR: LDY   #7
        LDA   #$FF              ; Set high address
        STA   (SYMTBL),Y        ; =FF (unassigned)
        DEY
        DEY
XFRSYM: LDA   (ADL),Y           ; Add symbol to
        STA   (SYMTBL),Y        ; symbol table
        DEY
        BPL   XFRSYM
        LDX   SYMNUM            ; Increment number
        INX                     ; of symbols.
        STX   SYMNUM
        RTS
        .endproc

; Subroutine NEWSYM. Puts base address of symbol table record for
; symbol pointed to by A in MISCL, H and returns symbol in X. If new,
; adds to table and sets Z.
       .proc  NEWSYM
       STA    SYMRFL            ; Set up search.
       LDX    #$50
       JSR    MATCH             ; Look up symbol.
       BEQ    OLD
       LDA    SYMRFL            ; No found; add
       JSR    ADDLAB            ; to symbol table.
OLD:   JSR    SYM               ; Address in MISCL, H.
       CPX    SYMNUM            ; Set z if new.
       RTS
       .endproc

; Subroutine ENCODE (part 1). Put mnemonic code in MNE, address mode in X.
        .proc ENCODE
        LDX   #$42              ; Find mnemonic.
        JSR   MATCH
        BEQ   MNEFND
        LDA   #'1'              ; "1" Error-
        RTS                     ; not found.
MNEFND: STX   MNE               ; Save menmonic.
        LDX   #$49
        JSR   MATCH             ; Find address mode.
        BEQ   MODFND
        LDA   #'2'              ; "2" Error-
        RTS                     ; not found.
MODFND: LDA  MNE                ; Special cases:
        CMP  #$19
        BPL  NOTIMP
        LDX  #0                 ; Implied mode.
NOTIMP: CMP  #$30
        BMI  NOTREL
        LDX  #8                 ; Relative mode.
NOTREL: NOP


        .endproc

MODLIM: ; Lower opcode pointer limits for modes.
        .byte $00,$19,$1D,$2A,$3F,$4F,$51,$59,$61,$69,$80,$90,$9C

DECODE:
