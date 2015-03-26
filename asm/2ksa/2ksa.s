; 2KSA - A 2K Symbolic Assembler for the 6502
;
; by Robert Ford Denison
;
; Apple 1/Replica 1 port by Jeff Tranter <tranter@pobox.com>
;

; Uncomment one of the following lines or define on the assembler
; command line, to define whether to build for KIM-1, SYM-1 or Apple
; 1/Replica 1.

;KIM1 = 1
;SYM1 = 1
;REPLICA1 = 1

.if .defined(REPLICA1)
    .out "Building for Apple 1/Replica 1"
.elseif .defined(KIM1)
    .out "Building for KIM-1"
.elseif .defined(SYM1)
    .out "Building for SYM-1"
.else
    .error "Platform not defined"
.endif

; Uncoment if you want the address assignment bug fix. See P.57 of manual
ADDRESSASSIGNBUG = 1

; Key used to jump to monitor program. Default is <Escape>
ESC = $1B

; Key used to delete characters. Default is <Backspace>
BS = $08

; Global Symbols on Page Zero
IOBUF   = $00           ; I/O Buffer; prompt or command field.
IOBUF1  = $01           ; ??? Not Documented
LABEL   = $07           ; I/O buffer; label field.
OPCODE  = $0E           ; I/O buffer; opcode field.
OPCOD1  = $0F           ; ??? Not Documented
OPCOD2  = $10           ; ??? Not Documented
OPCOD3  = $11           ; ??? Not Documented
OPCOD4  = $12           ; ??? Not Documented
OPRAND  = $15           ; I/O buffer; operand field.
OFFSET  = $1C           ; ??? Not Documented
;USER   = $23           ; Six bytes available for use by user commands.
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
;RFH    = $33           ; High address pointer (MATCH).
LEN     = $34           ; Length of each record in table (MATCH).
HBC     = $35           ; Number of highest bye in record which must match.
NUM     = $36           ; Number of highest record in table (MATCH).
OPCPTR  = $37           ; Pointer to opcode in OPCTAB.
PRNTOK  = $38           ; Flag to enable printing by Subroutine PRNTCK.
SYMPTR  = $38           ; ??? Undocumented
OPRDSP  = $39           ; ??? Undocumented
WRONG   = $39           ; Flag for illegal line numbers (PRNTCK).
MODE    = $3A           ; Code for address mode.
;SAVX   = $3B           ; Used to preserve X register.
GLOBAL  = $3C           ; Number of last global symbol.
PRGLEN  = $3D           ; Length of source code.
CRNTAL  = $3E           ; Low address pointer to current source code line.
CRNTAH  = $3F           ; High address pointer.
MDLADL  = $40           ; Module pointer, low address.
MDLADH  = $41           ; Module pointer, high address.
;MNETBL = $42           ; Parameters for MNETAB (see TBL to NUM above).
;MODTBL = $49           ; Parameters for MODTAB.
SYMTBL  = $50           ; Low address pointer to last entry in symbol table.
SYMTBH  = $51           ; High address pointer.
SYMRFL  = $52           ; Low address pointer for symbol to be compared.
;SYMRFH = $53           ; High address pointer.
SYMNUM  = $56           ; Number of last symbol.
OBJECT  = $57           ; Low address pointer to object code.
OBJCT1  = $58           ; High address pointer.
FIRST   = $59           ; First line in range for print (PRNTCK).
LAST    = $5A           ; First line after print range.
LAST1   = $5B           ; High order address; same as CRNTAH.
;LAST2  = $5B           ; High order address; same as CRNTAH.

        .ifdef KIM1
; I/O Routines - KIM-1
CRLF     = $1E2F        ; Output Carriage return, line feed.
OUTCH    = $1EA0        ; Output ASCII from A. Preserve X.
GETCH    = $1E5A        ; Input ASCII to A. Preserve X.
OUTSP    = $1E9E        ; Output one space.
         .endif

        .ifdef SYM1
; I/O Routines - SYM-1
CRLF     = $834D        ; Output Carriage return, line feed.
OUTCH    = $8A47        ; Output ASCII from A. Preserve X.
GETCH    = $8A1B        ; Input ASCII to A. Preserve X.
OUTSP    = $8342        ; Output one space.
         .endif

; I/O Routines - Replica 1
         .ifdef REPLICA1
ECHO     = $FFEF
WOZMON   = $FF00
         .endif

; Note: Program must be linked starting at a page boundary.

.ifdef STARTADDRESS
       .org STARTADDRESS
.else
        .ifdef KIM1
; The original KIM-1 version links at $0200 or alternatively at $2000
        .org $0200
        .elseif .defined(SYM1)
        .org $0200
        .elseif .defined(REPLICA1)
; Start address here is adjusted so that 2KSA code proper starts at $0300 but can be changed if desired.
        .org $02E2
        .export ORG
ORG:
        .else
        .error "Must define KIM1, SYM1, or REPLICA1"
        .endif
.endif

        .ifdef REPLICA1

; I/O Routines - Replica 1

; Output Carriage return, line feed.
CRLF:    LDA    #$0D
         JSR    OUTCH
         RTS

; Output ASCII from A. Preserve X.
OUTCH:   JSR    ECHO
         RTS

; Input ASCII to A. Preserve X.
GETCH:   LDA    $D011           ; Read keyboard status
         BPL    GETCH           ; until key pressed.
         LDA    $D010           ; Key character.
         AND    #$7F            ; Clear MSB to convert to standard ASCII.
         JSR    OUTCH           ; Echo it
         RTS

; Output one space.
OUTSP:   LDA    #' '
         JSR    OUTCH
         RTS
         .endif

MNETAB: ; Three-character ASCII mnemonics for instructions.
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
        .byte   >(MNETAB+$0A00)
        .word   MNETAB+$0A80
        .word   MODTAB-3
        .byte   $0E,$00,$03,$02,$37
        .word   MIN-2
        .byte   $11,$00,$02,$01,$0C
        .word   COMAND+$40
        .byte   $15,$00,$08,$05,$08

USRPRM: ; Four bytes available for user parameters.
        .byte   $FF,$FF,$FF,$FF

OPCTAB: ; Machine language opcodes pointed to by OPCPTR
        .byte   $00,$18,$D8,$58,$B8,$CA,$88,$E8,$C8,$EA,$48
        .byte   $08,$68,$28,$40,$60,$38,$F8,$78,$AA,$A8,$BA,$8A,$9A,$98,$0A,$4A
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

; Subroutine HX2BIN. Convert 2 ASCII characters on page zero, pointed to by X, to 8 binary bits in X.
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
        CMP     #$0A            ; Number or letter?
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
        STA   (SYMTBL),Y        ; symbol table.
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
       LDA    SYMRFL            ; Not found; add
       JSR    ADDLAB            ; to symbol table.
       .ifdef ADDRESSASSIGNBUG  ; Bug fix. See P.57 of manual
OLD:   JSR    ADDRSS
       CMP    #$FF
       .else
OLD:   JSR    SYM               ; Address in MISCL, H.
       CPX    SYMNUM            ; Set z if new.
       .endif
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
MODFND: LDA   MNE               ; Special cases:
        CMP   #$19
        BPL   NOTIMP
        LDX   #0                ; Implied mode.
NOTIMP: CMP   #$30
        BMI   NOTREL
        LDX   #8                ; Relative mode.
NOTREL: NOP

; Subroutine ENCODE (part 2). Check legality of mnemonic/address mode combination.

        LDA   MNE               ; Legal mnemonic
        CMP   MIN,X             ; for address mode?
        BPL   NOT2LO
        LDA   #'3'              ; "3" Too low.
        RTS
NOT2LO: CMP   MAX,X
        BMI   NOT2HI
        LDA   #'3'              ; "3" Too high.
        RTS
NOT2HI: CLC
        ADC   BASE,X
        STA   OPCPTR            ; Store pointer
        TAX                     ; to opcode
        LDA   OPCTAB,X
        CMP   #$FF
        BNE   OPCLGL
        LDA   #'3'              ; "3" Illegal.
        RTS
OPCLGL: NOP

; Subroutine ENCODE (part 3). Find operand code, if required, for
; address modes other than relative and 3-byte address modes.

        LDA     OPCPTR          ; Consider opcode.
        CMP     #$1D
        BPL     OPRRQD          ; Operand required?
        LDA     #'-'            ; "-"
        RTS                     ; No; return.
OPRRQD: INC     BYTES           ; At least 2 bytes.
        CMP     #$2A
        BPL     NOTIMM
        LDX     #$15            ; Immediate addressing.
        JSR     HX2BIN          ; Find binary value
        STX     SYMPTR
        LDA     #'-'            ; "-"
        RTS
NOTIMM: LDX     #$15            ; Set up operand search.
        STX     SYMRFL
        CMP     #$61
        BPL     NOTZPG          ; Zpage addressing?
        LDX     #$50            ; Yes.
        JSR     MATCH           ; Look up operand.
        BEQ     FOUND
        LDA     #'4'            ; "4" Not found.
        RTS
FOUND:  JSR     ADDRSS
        BEQ     OK
        LDA     #'5'            ; "5" Not zpage.
        RTS
OK:     STX     SYMPTR          ; Store operand.
        LDA     OFFSET          ; Check for offset.
        CMP     #' '            ; "SP"
        BEQ     DONE
        LDA     #'6'            ; "6" offset illegal.
        RTS
DONE:   LDA     #'-'            ; "-"
        RTS                     ; OK, return.
NOTZPG: NOP                     ; Continue.
        
; Subroutine ENCODE (part 4). Look up operand; add if required.

        LDX     #$50            ; Look up operand.
        JSR     MATCH
        BEQ     FOUND1
        LDA     #$15            ; Not found; add
        JSR     ADDLAB          ; to symbol table.
FOUND1: STX     SYMPTR
        LDA     OPCPTR
        CMP     #$69            ; Relative addressing?
        BPL     NOTREL1
        CPX     GLOBAL
        BPL     OK1
        LDA     #'7'            ; "7" Error-
        RTS                     ; branch not local.
OK1:    LDA     #'-'            ; "-"
        RTS
NOTREL1: NOP

; Subroutine ENCODE (part 5). For absolute addressing, check legality and find offset.

        CPX     GLOBAL          ; Operand must
        BMI     OK2             ; be global or
        JSR     ADDRSS          ; outside block.
        CMP     CRNTAH
        BNE     OK2
        LDA     #'8'            ; "8" Absolute
        RTS                     ; mode w/in block.
 OK2:   LDA     OFFSET
        LDX     #0
        CMP     #' '            ; "SP"
        BEQ     STROFS
        LDX     #$1C            ; Find offset;
        JSR     HX2BIN
STROFS: STX     OPRDSP
        INC     BYTES
        LDA     #'-'            ; "-" Stay in
        RTS                     ; edit mode.
        .endproc

; Subroutine CMAND. Look up and execute command.
        .proc   CMAND
        LDA     MODE            ; Command legal
        CMP     IOBUF           ; for mode?
        BEQ     OK
        CLC                     ; No; illegal.
        ADC     #$0C            ; Return "9" or "K"
        RTS
OK:     LDA     #0              ; Look up command.
        STA     SYMRFL
        LDX     #$50
        JSR     MATCH
        BEQ     FOUND
        LDA     IOBUF           ; Not found.
        CMP     #'?'
        BPL     CMODE
        LDA     #'0'            ; "0" Error-
        RTS                     ; input mode.
CMODE:  LDA     #'A'            ; "A" Error-
        RTS                     ; command mode.
FOUND:  LDA     #>*             ; Set up return.
        PHA
        LDA     #$75
        PHA
        JSR     ADDRSS          ; Get address.
        JMP     (ADL)           ; Execute command.
        RTS
        .endproc

; Subroutine FIN. Add line to program; assign addreess to label, if any.
        .proc   FIN
        JSR     INSERT          ; Adjust if inserting.
        LDY     BYTES
        DEY
ADDLIN: LDA     OPCPTR,Y        ; Add line
        STA     (CRNTAL),Y      ; to program.
        DEY
        BPL     ADDLIN
        LDA     LABEL
        CMP     #' '            ; "SP"
        BEQ     INCADR          ; Any label?
        LDA     #7              ; Yes. Add to
        JSR     NEWSYM          ; symbol table
        LDY     #7              ; if new, and
        LDA     CRNTAH          ; assign address.
        STA     (MISCL),Y
        DEY
        LDA     CRNTAL
        STA     (MISCL),Y
INCADR: CLC
        LDA     CRNTAL          ; Increment pointers.
        ADC     BYTES
        STA     CRNTAL
        CLC
        LDA     PRGLEN
        ADC     BYTES
        STA     PRGLEN
        BPL     OK
        LDA     #'B'            ; "B" Error-
        RTS                     ; program overflow.
OK:     BIT     SYMNUM
        BVC     OK2
        LDA     #'C'            ; "C" Error-
        RTS                     ; symbol overflow.
OK2:    LDA     #'-'
        RTS
        .endproc

; Main program. Process command, or translate input into source code.
        .export MAIN
        .proc MAIN
        CLD
        LDX      #$18           ; Initialize
 INIT:  LDA      PRMTAB,X       ; program parameters.
        STA      CRNTAH,X
        DEX
        BPL     INIT
        LDA     #'?'            ; "?" Set.
START:  STA     IOBUF           ; command mode.
        LDY     #' '            ; "SP"
        LDX     #$21
CLEAR:  STY     IOBUF1,X        ; Clear I/O buffer
        DEX                     ; except error code.
        BPL     CLEAR
        LDX     #'?'            ; "?" Command.
        CMP     #'?'            ; Command mode?
        BPL     GETLIN
        LDA     CRNTAH          ; No; input mode.
        LDX     #2              ; Display address.
        JSR     DSPHEX
        LDA     CRNTAL
        LDX     #4
        JSR     DSPHEX
        LDX     #'-'            ; "-" Input.
GETLIN: STX     MODE            ; Save mode.
        LDA     #1              ; Initialize.
        STA     BYTES
        JSR     INPUT           ; Input line.
        LDA     MODE            ; Mode?
        CMP     #'-'            ; "-"
        BNE     CMODE           ; Command mode?
        LDA     IOBUF1          ; Input mode command?
        CMP     #' '            ; "SP"
CMODE:  BNE     EXEC            ; If neither,
        JSR     ENCODE          ; translate line.
        CMP     #'-'            ; "-"
        BNE     NG              ; If line legal,
        JSR     FIN             ; add to program.
NG:     LDX     #0
EXEC:   BEQ     DONE            ; If command,
        JSR     CMAND           ; execute it.
DONE:   CLC
        BCC     START           ; Repeat until reset.
        NOP
        .endproc

; ? BEGIN. Add module name to symbol table; enter input mode.
        .proc   BEGIN
        LDA     #7              ; Add name to
        JSR     NEWSYM          ; symbol table.
        BEQ     OK
        LDA     #'D'            ; "D" Error-
        RTS                     ; label in use.
OK:     STX     GLOBAL          ; Set local cutoff.
        LDA     #0              ; Clear pointers.
        STA     CRNTAL
        STA     PRGLEN
        LDY     #6
        STA     (MISCL),Y       ; Set start address
        LDA     CRNTAH          ; =CRNTAL, H.
        INY
        STA     (MISCL),Y
        LDA     #'-'            ; "-" Set
        RTS                     ; input mode.
        .endproc

; ? ASSGN.Assign address to labels.
        .proc   ASSGN
        LDA     LABEL
START:  CMP     #' '            ; "SP"
        BNE     MORE            ; Label supplied?
        LDA     #'?'            ; No, done.
        RTS
MORE:   LDA     #7
        JSR     NEWSYM          ; Add symbol to table.
        BEQ     NOTOLD
        LDA     #'D'            ; "D" Error-
        RTS                     ; label in use.
NOTOLD: LDX     #$0E            ; Assign address.
        JSR     HX2BIN
        LDY     #7
        TXA
        STA     (MISCL),Y
        LDX     #$10
        JSR     HX2BIN
        DEY
        TXA
        STA     (MISCL),Y
        LDA     #' '            ; "SP"
        LDX     #$0C            ; clear I/O buffer
CLEAR:  STA     LABEL,X         ; except prompt.
        DEX
        BPL     CLEAR
        JSR     INPUT           ; Next symbol.
        LDA     LABEL
        BPL     START
        NOP
        .endproc

; -LOCAL. Add local symbols to symbol table; assign addresses.
        .proc   LOCAL
        JSR     ASSGN           ; Add to
        CMP     #$44            ; symbol table
        BNE     OK              ; if new.
        LDA     #':'            ; ":" Error-
        RTS                     ; symbol in use.
OK:     LDA     #'-'            ; "-" stay in
        RTS                     ; input mode.        
        .endproc

; ?REDEF. Redefine module start address.
        .proc REDEF
        LDX     #7              ; Find high address.
        JSR     HX2BIN
        STX     MDLADH          ; Store.
        LDX     #9              ; Find low address.
        JSR     HX2BIN
        STX     MDLADL          ; Store.
        LDA     #'?'            ; "?" stay in
        RTS                     ; command mode.
        .endproc

; Subroutine ASMBL. Translate line into machine code; store result at
; (OBJECT). Return length-1 in Y.

        .proc   ASMBL
        LDY     #0              ; Get first byte
        LDA     (CRNTAL),Y
        TAX
        LDA     OPCTAB,X        ; Look up opcode.
        STA     (OBJECT),Y
        CPX     #$1D
        BPL     OPREQ
        RTS                     ; No operand.
OPREQ:  INY
        LDA     (CRNTAL),Y
        CPX     #$2A
        BPL     NOTIMM          ; Address mode?
        STA     (OBJECT),Y      ; Immediate.
        RTS
NOTIMM: STX     MNE
        TAX
        JSR     ADDRSS          ; Get address.
        LDA     ADL
        LDY     #1
        LDX     MNE
        CPX     #$61
        BPL     NOTZPG
        STA     (OBJECT),Y      ; Zero page.
        RTS
NOTZPG: CPX     #$69
        BPL     NOTREL
        SEC                     ; Relative.
        SBC     #2              ; Compute branch.
        SEC
        SBC     CRNTAL
        STA     (OBJECT),Y
        RTS
NOTREL: CLC                     ; Absolute.
        INY
        ADC     (CRNTAL),Y      ; Add offset.
        DEY
        STA     (OBJECT),Y
        INY
        LDA     ADH
        ADC     #0
        STA     (OBJECT),Y
        RTS
        .endproc

; Subroutine LOCSYM. Displays undefined local symbols.
        .proc   LOCSYM
        LDX     GLOBAL          ; For local symbols,
NXTSYM: INX
        JSR     ADDRSS          ; see if defined.
        CMP     #$FF
        BNE     DEFIND          ; If not,
        LDY     #5              ; display symbol.
SHOW:   LDA     (MISCL),Y
        STA     IOBUF,Y
        DEY
        BPL     SHOW
        STX     MISCL
        JSR     OUTLIN
        LDX     MISCL
DEFIND: CPX     SYMNUM          ; If more
        BMI     NXTSYM          ; symbols, repeat.
        RTS
        .endproc

; -ASSEM. Assemble module; store result in RAM locationsbeginning at (MDLADL, H).

        .proc   ASSEM
        JSR     LOCSYM          ; Check for local
        LDA     #'-'            ; undefined symbols.
        CMP     IOBUF
        BEQ     ALLOK           ; If any; return.
        RTS
ALLOK:  LDA     #0              ; Else, assemble.
        STA     CRNTAL
        LDA     MDLADL
        STA     OBJECT
        LDA     MDLADH
        STA     OBJCT1
NEXTLN: JSR     ASMBL           ; Translate a line.
        STY     TEMP            ; Save bytes -1.
        SEC                     ; Increment pointers.
        LDA     OBJECT          ; For object code.
        ADC     TEMP
        STA     OBJECT
        BCC     SKIP
        INC     OBJCT1
SKIP:   SEC                     ; For source code.
        LDA     CRNTAL
        ADC     TEMP
        STA     CRNTAL
        CMP     PRGLEN
        BMI     NEXTLN          ; Finished?
        LDA     #'-'            ; "-" Stay in
        RTS                     ; edit mode.
        .endproc

; ? TABLE. Allocate space for tables.
        .proc   TABLE
        LDA     LABEL
START:  CMP     #' '            ; "SP"
        BNE     MORE            ; Any label?
        LDA     #'?'            ; No; done.
        RTS
MORE:   LDA     #7
        JSR     NEWSYM          ; Add symbol to
        BEQ     NOTOLD          ; symbol table.
        LDA     #'D'            ; "D" Error-
        RTS                     ; not new.
NOTOLD: LDY     #6              ; Assign address.
        LDA     MDLADL
        STA     (MISCL),Y
        INY
        LDA     MDLADH
        STA     (MISCL),Y
        LDX     #$0E            ; Allocate space
        JSR     HX2BIN          ; by incrementing
        TXA                     ; MDLADL, H.
        CLC
        ADC     MDLADL
        STA     MDLADL
        BCC     NOINC
        INC     MDLADH
NOINC:  LDA     #' '            ; "SP"
        LDX     #$0C
CLEAR:  STA     LABEL,X         ; Clear I/O buffer
        DEX                     ; except prompt.
        BPL     CLEAR
        JSR     INPUT
        LDA     LABEL           ; Another symbol?
        BPL     START
        NOP
        .endproc

; Subroutine INPUT. Prompt w/ first word in IOBUF. Input up to 5
; words. Special keys: ESC, CR, BKSP, SP.

        .proc   INPUT
        JSR     CRLF            ; New line.
        LDX     #0              ; Prompt w/
PROMPT: LDA     IOBUF,X         ; first 6 chars
        JSR     OUTCH
        INX
        CPX     #6
        BMI     PROMPT
        LDX     #0              ; Initialize pointer.
        LDA     #6              ; 7 chars/word
        STA     TEMP            ; includes space.
START:  JSR     GETCH           ; Input a char.
        CMP     #ESC            ; "ESC"
        BNE     NOTBRK
        .ifdef REPLICA1
        JMP     WOZMON          ; For Replica 1 go to Woz monitor
        .else
        BRK                     ; Break.
        .endif
NOTBRK: CMP     #$0D            ; "CR"
        BNE     NOTCR
        RTS                     ; End of line.
NOTCR:  CMP     #BS             ; "BS"
        BNE     NOTBSP
        DEX                     ; Backspace.
        INC     TEMP
        LDA     #$08
NOTBSP: CMP     #' '            ; "SP"
        BNE     NOTSP
        .ifndef REPLICA1        ; Remove NOP to compensate for extra instructions above.
        NOP                     ; Next word.
        .endif
TAB:    JSR     OUTSP           ; Add spaces
        INX                     ; to fill word.
        DEC     TEMP
        BPL     TAB
        LDA     #$06
        STA     TEMP
NOTSP:  CMP     #$20            ; If not a
        BMI     DONE            ; control char:
        STA     IOBUF,X         ; Add char to
        INX                     ; I/O buffer.
        DEC     TEMP
DONE:   CLC
        BCC     START           ; Next character.
        .ifndef REPLICA1        ; Remove NOP to compensate for extra instructions above.
        NOP
        .endif
        .endproc

; -STORE. Clear local symbols; assign address to
; module. IncrementMDLADL,H to prevent overwrite by next
; module. Return to command mode.

        .proc   STORE
        LDX     GLOBAL          ; Clear local
        JSR     SYM             ; symbols from
        STX     SYMNUM          ; symbol table.
        LDA     MISCL
        STA     SYMTBL
        LDA     MISCH
        STA     SYMTBH
        LDY     #$07            ; Assign address
        LDA     MDLADH          ; to module.
        STA     (MISCL),Y
        DEY
        LDA     MDLADL
        STA     (MISCL),Y
        CLC
        ADC     PRGLEN          ; Increment MDLADL,H
        STA     MDLADL          ; by length of
        BCC     SKIP            ; module.
        INC     MDLADH
SKIP:   LDA     #'?'            ; "?" Return to
        RTS                     ; command mode.
        .endproc

 ; Lower opcode pointer limits for modes.
        .proc   MODLIM
        .byte   $00,$19,$1D,$2A,$3F,$4F,$51,$59,$61,$69,$80,$90,$9C
        .endproc

; Subroutine DECODE. Decode line pointed to by CRNTAL and OBJECT. Put
; line in IOBUF, length in BYTES.

        .proc   DECODE
        LDA     #1              ; Assume 1 byte.
        STA     BYTES
        LDX     #$22            ; Clear I/O buffer.
        LDA     #$20
CLEAR:  STA     IOBUF,X
        DEX
        BPL     CLEAR
        LDX     SYMNUM          ; Check for label.
START:  JSR     ADDRSS          ; Compare address
        LDA     CRNTAL          ; to current line
        CMP     ADL
        BNE     SKIP
        LDA     CRNTAH
        CMP     ADH
SKIP:   BNE     SKIP2           ; If they match,
        LDY     #5              ; put label in
LABL:   LDA     (MISCL),Y       ; I/O buffer.
        STA     LABEL,Y
        DEY
        BPL     LABL
        LDX     #1              ; End search.
SKIP2:  DEX
        CPX     GLOBAL          ; Consider local
        BPL     START           ; symbols only.
        LDY     #0              ; Get opcode.
        LDA     (OBJECT),Y
        LDX     #0              ; Put opcode in
        JSR     DSPHEX          ; I/O buffer.
        LDA     (CRNTAL),Y      ; Decode opcode.
        STA     OPCPTR

; Subroutine DECODE (part 2). Decode address mode and opcode; put in I/O buffer.

        LDX     #$0C            ; Find mode.
        CMP     #$1D            ; Any operand?
        BPL     FNDMOD          ; If not, only check
        LDX     #1              ; implied and accum.
FNDMOD: CMP     MODLIM,X        ; In range
        BMI     NOPE            ; for mode?
        STX     MODE            ; Yes; save mode.
        LDX     #0              ; End search.
NOPE:   DEX
        BPL     FNDMOD
        LDA     MODE            ; Put mode in
        ASL     A               ; I/O buffer
        TAX
        LDA     MODTAB,X
        STA     OPCOD3
        LDA     MODTAB+1,X
        STA     OPCOD4
        LDA     (CRNTAL),Y      ; Find mnemonic.
        SEC
        LDX     MODE
        SBC     BASE,X          ; Mnemonic number.
        STA     TEMP            ; Multiply by 3.
        ASL     A
        CLC
        ADC     TEMP
        TAX                     ; Get ASCII.
        LDA     MNETAB,X        ; Put mnemonic in
        STA     OPCODE          ; I/O buffer.
        LDA     MNETAB+1,X
        STA     OPCOD1
        LDA     MNETAB+2,X
        STA     OPCOD2
        LDA     OPCPTR          ; Operand needed?
        CMP     #$1D
        BPL     OPRND
        RTS                     ; No; finished.
OPRND:  INC     BYTES           ; At least 2 bytes.

; Subroutine DECODE (part 3). Decode operands and offset, if any.
        LDY     #1
        LDA     (OBJECT),Y      ; Machine code
        LDX     #2              ; for operand in
        JSR     DSPHEX          ; I/O buffer.
        LDA     OPCPTR
        CMP     #$2A            ; Immediate mode?
        BPL     NOTIMM
        LDA     (CRNTAL),Y      ; Yes; put hex.
        LDX     #$15            ; number in
        JSR     DSPHEX          ; I/O buffer.
        RTS
NOTIMM: LDA     (CRNTAL),Y      ; No; look up
        TAX                     ; operand
        JSR     SYM
        LDY     #5              ; Put operand
SHOWOP: LDA     (MISCL),Y       ; in IOBUF.
        STA     OPRAND,Y
        DEY
        BPL     SHOWOP
        LDA     OPCPTR          ; 3-byte instruction.
        CMP     #$69
        BPL     ABS
        RTS                     ; No, done.
ABS:    INC     BYTES           ; Yes.
        LDY     #2
        LDA     (OBJECT),Y      ; Add code to
        LDX     #4              ; I/O buffer.
        JSR     DSPHEX
        LDA     (CRNTAL),Y      ; Offset?
        BEQ     DONE
        LDX     #$1C            ; Show offset.
        JSR     DSPHEX
DONE:   RTS
        .endproc

; Subroutine OUTLIN. Output line from IOBUF.

        .proc   OUTLIN
        JSR     CRLF            ; New line.
        LDX     #0
NXTCHR: LDA     IOBUF,X         ; Output one
        JSR     OUTCH           ; character at
        INX                     ; at time,
        CPX     #$23            ; until done.
        BMI     NXTCHR
        RTS
        .endproc

; Subroutine PRNTCK. Check that FIRST and LAST are legal line numbers. Print lines in range if PRNTOK=1.

        .proc   PRNTCK
        LDA     #0              ; Initialize.
        STA     CRNTAL
        LDA     MDLADL
        STA     OBJECT
        LDA     MDLADH
        STA     OBJCT1
        LDX     #7              ; Decode range.
        JSR     HX2BIN
        STX     FIRST
        LDX     #$0B
        JSR     HX2BIN
        STX     LAST
        LDA     #2              ; Initialize flag
        STA     WRONG           ; for mismatch.
NXTLIN: JSR     DECODE          ; Decode line.
        LDA     CRNTAL
        CMP     FIRST           ; Decrement WRONG
        BNE     SKIP            ; each time a
        DEC     WRONG           ; match is found.
SKIP:   CMP     LAST
        BNE     SKIP2
        DEC     WRONG
SKIP2:  CMP     FIRST           ; In range
        BMI     LOW             ; for print?
        CMP     LAST
        BPL     HIGH
        BIT     PRNTOK          ; Yes, but
        BMI     NOPRNT          ; print wanted?
        LDX     #$1F            ; Yes; add
        JSR     DSPHEX          ; line number.
        JSR     OUTLIN          ; Print line.
NOPRNT: NOP
HIGH:   NOP
LOW:    CLC                     ; Update pointers.
        LDA     OBJECT
        ADC     BYTES
        STA     OBJECT
        BCC     NOINC
        INC     OBJCT1
NOINC:  CLC
        LDA     CRNTAL
        ADC     BYTES
        STA     CRNTAL
        CMP     PRGLEN          ; Last line?
        BMI     NXTLIN          ; If not, repeat.
        RTS
        .endproc

; -PRINT. Output lines in specified range.

        .proc   PRINT
        LDA     #1              ; Set print flag.
        STA     PRNTOK
        JSR     PRNTCK          ; Run print routine.
        LDA     #'-'            ; "-" Stay in
        RTS                     ; edit mode.
        .endproc

; Subroutine FIXSYM. Adds BYTES to addresses of line labels. Used by -INSRT and subroutine INSERT.

        .proc   FIXSYM
        LDX     SYMNUM          ; For local symbols,
START:  JSR     ADDRSS          ; find address.
        CMP     CRNTAH          ; Line label?
        BNE     NOTLAB
        LDA     ADL             ; Yes, but in
        CMP     CRNTAL          ; move zone?
        BMI     NOREV
        LDY     ADL             ; Yes.
        CPY     LAST            ; Line deleted?
        BPL     NEWADR
        LDA     #$FE            ; Yes.
        LDY     #7              ; Delete symbol.
        STA     (MISCL),Y
NEWADR: CLC                     ; Fix address
        ADC     BYTES
        LDY     #6
        STA     (MISCL),Y
NOREV:  NOP
NOTLAB: DEX                     ; More local
        CPX     GLOBAL          ; symbols?
        BPL     START
        RTS
        .endproc

; Subroutine INSERT. Open gap in program to insert current line. Adjust symbol table.

        .proc   INSERT
        LDA     CRNTAL          ; Inserting line?
        CMP     PRGLEN
        BNE     INS
        RTS                     ; Nope.
INS:    STA     LAST
        JSR     FIXSYM          ; Fix symbols.
        CLC
        LDA     CRNTAL          ; Set up offset
        ADC     BYTES           ; pointer for move.
        STA     ADL
        LDA     CRNTAH
        STA     ADH
        LDA     PRGLEN
        SEC
        SBC     CRNTAL
        TAY
MOVE:   LDA     (CRNTAL),Y      ; Move lines to
        STA     (ADL),Y         ; open gap.
        DEY
        BPL     MOVE
        RTS
        .endproc

; -INSRT. Check supplied line numbers for legality. Set program
; pointer to first line number; delete to second.

        .proc   INSRT
        LDA     #$FF            ; Legal line?
        STA     PRNTOK
        JSR     PRNTCK
        CMP     LAST            ; Last+1 is
        BNE     NOTLST          ; legal line
        DEC     WRONG           ; number.
NOTLST: LDA     WRONG
        BEQ     OK
        LDA     #'%'            ; "%" Error-
        RTS                     ; illegal address.
OK:     LDA     FIRST
        STA     CRNTAL
        LDX     LAST            ; Deletion needed?
        BEQ     DONE
        SEC                     ; Fix addresses
        SBC     LAST            ; for labels.
        STA     BYTES
        JSR     FIXSYM
        LDA     CRNTAH          ; Set pointer
        STA     LAST1           ; for move.
        LDA     PRGLEN          ; Find bytes
        SEC                     ; to move.
        SBC     CRNTAL
        STA     TEMP
        LDA     PRGLEN          ; Correct length
        CLC                     ; of program.
        ADC     BYTES
        STA     PRGLEN
        LDY     #0              ; Move lines to
MOVE:   LDA     (LAST),Y        ; close gap.
        STA     (CRNTAL),Y
        INY
        CPY     TEMP
        BMI     MOVE
        NOP
DONE:   LDA     #'-'            ; "-" Stay in
        RTS                     ; edit mode.
        .endproc

; Move first nine entries in symbol table to RAM. Entry point for assembler in ROM.

        LDX     #$47
MOVSYM: LDA     ROM,X
        STA     RAM,X
        DEX
        BPL     MOVSYM
        JMP     MAIN

; See page 55 for defining RAM and ROM.

RAM:
ROM:

; Table COMAND. First nine entries in symbol table; commands.

COMAND:
        .byte   "?ASSGN"
        .word   ASSGN
        .byte   "?BEGIN"
        .word   BEGIN
        .byte   "-LOCAL"
        .word   LOCAL
        .byte   "?REDEF"
        .word   REDEF
        .byte   "-ASSEM"
        .word   ASSEM
        .byte   "?TABLE"
        .word   TABLE
        .byte   "-STORE"
        .word   STORE
        .byte   "-PRINT"
        .word   PRINT
        .byte   "-INSRT"
        .word   INSRT
