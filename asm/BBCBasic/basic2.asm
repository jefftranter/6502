; Source for 6502 BASIC II
; BBC BASIC Copyright (C) 1982/1983 Acorn Computer and Roger Wilson
; Source reconstruction and commentary Copyright (C) J.G.Harston
; Port to CC65 and 6502 SBC by Jeff Tranter

; Define this to build for my 6502 Single Board Computer.
; Comment out to build original code for Acorn Computer.
        PSBC    = 1

; Macros to pack instruction mnemonics into two high bytes
.macro MNEML c1,c2,c3
        .byte ((c2 & $1F) << 5 + (c3 & $1F)) & $FF
.endmacro

.macro MNEMH c1,c2,c3
        .byte ((c1 & $1F) << 2 + (c2 & $1F) / 8) & $FF
.endmacro

; Symbols
        FAULT   = $FD           ; Pointer to error block
        ESCFLG  = $FF           ; Escape pending flag
        F_LOAD  = $39           ; LOAD/SAVE control block
        F_EXEC  = F_LOAD+4
        F_START = F_LOAD+8
        F_END   = F_LOAD+12

; MOS Entry Points:
.if .not .defined(PSBC)
        OS_CLI  = $FFF7
        OSBYTE  = $FFF4
        OSWORD  = $FFF1
        OSWRCH  = $FFEE
        OSWRCR  = $FFEC
        OSNEWL  = $FFE7
        OSASCI  = $FFE3
        OSRDCH  = $FFE0
        OSFILE  = $FFDD
        OSARGS  = $FFDA
        OSBGET  = $FFD7
        OSBPUT  = $FFD4
        OSGBPB  = $FFD1
        OSFIND  = $FFCE
.endif

        BRKV    = $0202
        WRCHV   = $020E

; Dummy variables for non-Atom code
        OSECHO  = $0000
        OSLOAD  = $0000
        OSSAVE  = $0000
        OSRDAR  = $0000
        OSSTAR  = $0000
        OSSHUT  = $0000

; BASIC token values
        tknAND  = $80
        tknDIV  = $81
        tknEOR  = $82
        tknMOD  = $83
        tknOR   = $84
        tknERROR = $85
        tknLINE = $86
        tknOFF  = $87
        tknSTEP = $88
        tknSPC  = $89
        tknTAB  = $8A
        tknELSE = $8B
        tknTHEN = $8C
        tknERL  = $9E
        tknEXP  = $A1
        tknEXT  = $A2
        tknFN   = $A4
        tknLOG  = $AB
        tknTO   = $B8
        tknAUTO = $C6
        tknPTRc = $CF
        tknDATA = $DC
        tknDEF  = $DD
        tknRENUMBER = $CC
        tknDIM  = $DE
        tknEND  = $E0
        tknFOR  = $E3
        tknGOSUB = $E4
        tknGOTO = $E5
        tknIF   = $E7
        tknLOCAL = $EA
        tknMODE = $EB
        tknON   = $EE
        tknPRINT = $F1
        tknPROC = $F2
        tknREPEAT = $F5
        tknSTOP = $FA
        tknLOMEM = $92
        tknHIMEM = $93
        tknREPORT = $F6

.if .defined(PSBC)
        .org    $C000
.else
        .org    $8000
.endif

; BBC Code Header

L8000:
        cmp     #$01            ; Language entry
        beq     L8023
        rts
        nop

        .byte   $60             ; ROM type=Lang+Tube+6502 BASIC
        .byte   L800E-L8000     ; Offset to copyright string
        .byte   $01             ; ROM version number, 2=$01, 3=$03
        .byte   "BASIC"         ; ROM title
L800E:
        .byte   0
        .byte   "(C)1982 Acorn" ; ROM copyright string
        .byte   10
        .byte   13
        .byte   0
        .word   $8000
        .word   $0000

; Language startup

L8023:
        lda     #$84            ; Read top of memory
        jsr     OSBYTE
        stx     $06             ; Set HIMEM
        sty     $07
        lda     #$83
        jsr     OSBYTE          ; Read bottom of memory
        sty     $18             ; Set PAGE
        ldx     #$00
        stx     $1F             ; Set LISTO to 0
        stx     $0402           ; Set @5 to 0000xxxx
        stx     $0403
        dex                     ; Set WIDTH to $FF
        stx     $23
        ldx     #$0A            ; Set @% to $0000090A
        stx     $0400
        dex
        stx     $0401
        lda     #$01            ; Check RND seed
        and     $11
        ora     $0D
        ora     $0E
        ora     $0F             ; If nonzero, skip past
        ora     $10
        bne     L8063
        lda     #$41            ; Set RND seed to $575241
        sta     $0D
        lda     #$52
        sta     $0E
        lda     #$57            ; "ARW" - Acorn Roger Wilson?
        sta     $0F
L8063:
        lda     #LB402 & 255    ; Set up error handler
        sta     BRKV
        lda     #LB402 / 256
        sta     BRKV+1
        cli                     ; Enable IRQs, jump to immediate loop
        jmp     L8ADD

; TOKEN TABLE
; ===========
; string, token (b7=1), flag
;
; Token flag:
; Bit 0 - Conditional tokenisation (don't tokenise if followed by an alphabetic character).
; Bit 1 - Go into "middle of Statement" mode.
; Bit 2 - Go into "Start of Statement" mode.
; Bit 3 - FN/PROC keyword - don't tokenise the name of the subroutine.
; Bit 4 - Start tokenising a line number now (after a GOTO, etc...).
; Bit 5 - Don't tokenise rest of line (REM, DATA, etc...)
; Bit 6 - Pseudo variable flag - add &40 to token if at the start of a statement/hex number
; Bit 7 - Unused - used externally for quote toggle.

L8071:
        .byte   "AND",$80,$00   ; 00000000
        .byte   "ABS",$94,$00   ; 00000000
        .byte   "ACS",$95,$00   ; 00000000
        .byte   "ADVAL",$96,$00 ; 00000000
        .byte   "ASC",$97,$00   ; 00000000
        .byte   "ASN",$98,$00   ; 00000000
        .byte   "ATN",$99,$00   ; 00000000
        .byte   "AUTO",$C6,$10  ; 00010000
        .byte   "BGET",$9A,$01  ; 00000001
        .byte   "BPUT",$D5,$03  ; 00000011
        .byte   "COLOUR",$FB,$02 ; 00000010
        .byte   "CALL",$D6,$02  ; 00000010
        .byte   "CHAIN",$D7,$02 ; 00000010
        .byte   "CHR$",$BD,$00  ; 00000000
        .byte   "CLEAR",$D8,$01 ; 00000001
        .byte   "CLOSE",$D9,$03 ; 00000011
        .byte   "CLG",$DA,$01   ; 00000001
        .byte   "CLS",$DB,$01   ; 00000001
        .byte   "COS",$9B,$00   ; 00000000
        .byte   "COUNT",$9C,$01 ; 00000001
        .byte   "DATA",$DC,$20  ; 00100000
        .byte   "DEG",$9D,$00   ; 00000000
        .byte   "DEF",$DD,$00   ; 00000000
        .byte   "DELETE",$C7,$10 ; 00010000
        .byte   "DIV",$81,$00   ; 00000000
        .byte   "DIM",$DE,$02   ; 00000010
        .byte   "DRAW",$DF,$02  ; 00000010
        .byte   "ENDPROC",$E1,$01 ; 00000001
        .byte   "END",$E0,$01   ; 00000001
        .byte   "ENVELOPE",$E2,$02 ; 00000010
        .byte   "ELSE",$8B,$14  ; 00010100
        .byte   "EVAL",$A0,$00  ; 00000000
        .byte   "ERL",$9E,$01   ; 00000001
        .byte   "ERROR",$85,$04 ; 00000100
        .byte   "EOF",$C5,$01   ; 00000001
        .byte   "EOR",$82,$00   ; 00000000
        .byte   "ERR",$9F,$01   ; 00000001
        .byte   "EXP",$A1,$00   ; 00000000
        .byte   "EXT",$A2,$01   ; 00000001
        .byte   "FOR",$E3,$02   ; 00000010
        .byte   "FALSE",$A3,$01 ; 00000001
        .byte   "FN",$A4,$08    ; 00001000
        .byte   "GOTO",$E5,$12  ; 00010010
        .byte   "GET$",$BE,$00  ; 00000000
        .byte   "GET",$A5,$00   ; 00000000
        .byte   "GOSUB",$E4,$12 ; 00010010
        .byte   "GCOL",$E6,$02  ; 00000010
        .byte   "HIMEM",$93,$43 ; 00100011
        .byte   "INPUT",$E8,$02 ; 00000010
        .byte   "IF",$E7,$02    ; 00000010
        .byte   "INKEY$",$BF,$00 ; 00000000
        .byte   "INKEY",$A6,$00 ; 00000000
        .byte   "INT",$A8,$00   ; 00000000
        .byte   "INSTR(",$A7,$00 ; 00000000
        .byte   "LIST",$C9,$10  ; 00010000
        .byte   "LINE",$86,$00  ; 00000000
        .byte   "LOAD",$C8,$02  ; 00000010
        .byte   "LOMEM",$92,$43 ; 01000011
        .byte   "LOCAL",$EA,$02 ; 00000010
        .byte   "LEFT$(",$C0,$00 ; 00000000
        .byte   "LEN",$A9,$00   ; 00000000
        .byte   "LET",$E9,$04   ; 00000100
        .byte   "LOG",$AB,$00   ; 00000000
        .byte   "LN",$AA,$00    ; 00000000
        .byte   "MID$(",$C1,$00 ; 00000000
        .byte   "MODE",$EB,$02  ; 00000010
        .byte   "MOD",$83,$00   ; 00000000
        .byte   "MOVE",$EC,$02  ; 00000010
        .byte   "NEXT",$ED,$02  ; 00000010
        .byte   "NEW",$CA,$01   ; 00000001
        .byte   "NOT",$AC,$00   ; 00000000
        .byte   "OLD",$CB,$01   ; 00000001
        .byte   "ON",$EE,$02    ; 00000010
        .byte   "OFF",$87,$00   ; 00000000
        .byte   "OR",$84,$00    ; 00000000
        .byte   "OPENIN",$8E,$00 ; 00000000
        .byte   "OPENOUT",$AE,$00 ; 00000000
        .byte   "OPENUP",$AD,$00 ; 00000000
        .byte   "OSCLI",$FF,$02 ; 00000010
        .byte   "PRINT",$F1,$02 ; 00000010
        .byte   "PAGE",$90,$43  ; 01000011
        .byte   "PTR",$8F,$43   ; 01000011
        .byte   "PI",$AF,$01    ; 00000001
        .byte   "PLOT",$F0,$02  ; 00000010
        .byte   "POINT(",$B0,$00 ; 00000000
        .byte   "PROC",$F2,$0A  ; 00001010
        .byte   "POS",$B1,$01   ; 00000001
        .byte   "RETURN",$F8,$01 ; 00000001
        .byte   "REPEAT",$F5,$00 ; 00000000
        .byte   "REPORT",$F6,$01 ; 00000001
        .byte   "READ",$F3,$02  ; 00000010
        .byte   "REM",$F4,$20   ; 00100000
        .byte   "RUN",$F9,$01   ; 00000001
        .byte   "RAD",$B2,$00   ; 00000000
        .byte   "RESTORE",$F7,$12 ; 00010010
        .byte   "RIGHT$(",$C2,$00 ; 00000000
        .byte   "RND",$B3,$01   ; 00000001
        .byte   "RENUMBER",$CC,$10 ; 00010000
        .byte   "STEP",$88,$00  ; 00000000
        .byte   "SAVE",$CD,$02  ; 00000010
        .byte   "SGN",$B4,$00   ; 00000000
        .byte   "SIN",$B5,$00   ; 00000000
        .byte   "SQR",$B6,$00   ; 00000000
        .byte   "SPC",$89,$00   ; 00000000
        .byte   "STR$",$C3,$00  ; 00000000
        .byte   "STRING$(",$C4,$00 ; 00000000
        .byte   "SOUND",$D4,$02 ; 00000010
        .byte   "STOP",$FA,$01  ; 00000001
        .byte   "TAN",$B7,$00   ; 00000000
        .byte   "THEN",$8C,$14  ; 00010100
        .byte   "TO",$B8,$00    ; 00000000
        .byte   "TAB(",$8A,$00  ; 00000000
        .byte   "TRACE",$FC,$12 ; 00010010
        .byte   "TIME",$91,$43  ; 01000011
        .byte   "TRUE",$B9,$01  ; 00000001
        .byte   "UNTIL",$FD,$02 ; 00000010
        .byte   "USR",$BA,$00   ; 00000000
        .byte   "VDU",$EF,$02   ; 00000010
        .byte   "VAL",$BB,$00   ; 00000000
        .byte   "VPOS",$BC,$01  ; 00000001
        .byte   "WIDTH",$FE,$02 ; 00000010
        .byte   "PAGE",$D0,$00  ; 00000000
        .byte   "PTR",$CF,$00   ; 00000000
        .byte   "TIME",$D1,$00  ; 00000000
        .byte   "LOMEM",$D2,$00 ; 00000000
        .byte   "HIMEM",$D3,$00 ; 00000000

; FUNCTION/COMMAND DISPATCH TABLE, ADDRESS LOW BYTES
; ==================================================
L836D:
        .byte   LBF78 & $FF     ; &8E - OPENIN
        .byte   LBF47 & $FF     ; &8F - PTR
        .byte   LAEC0 & 255     ; &90 - PAGE
        .byte   LAEB4 & 255     ; &91 - TIME
        .byte   LAEFC & 255     ; &92 - LOMEM
        .byte   LAF03 & 255     ; &93 - HIMEM
        .byte   LAD6A & $FF     ; &94 - ABS
        .byte   LA8D4 & $FF     ; &95 - ACS
        .byte   LAB33 & $FF     ; &96 - ADVAL
        .byte   LAC9E & $FF     ; &97 - ASC
        .byte   LA8DA & $FF     ; &98 - ASN
        .byte   LA907 & $FF     ; &99 - ATN
        .byte   LBF6F & $FF     ; &9A - BGET
        .byte   LA98D & $FF     ; &9B - COS
        .byte   LAEF7 & $FF     ; &9C - COUNT
        .byte   LABC2 & $FF     ; &9D - DEG
        .byte   LAF9F & $FF     ; &9E - ERL
        .byte   LAFA6 & $FF     ; &9F - ERR
        .byte   LABE9 & $FF     ; &A0 - EVAL
        .byte   LAA91 & $FF     ; &A1 - EXP
        .byte   LBF46 & $FF     ; &A2 - EXT
        .byte   LAECA & $FF     ; &A3 - FALSE
        .byte   LB195 & $FF     ; &A4 - FN
        .byte   LAFB9 & $FF     ; &A5 - GET
        .byte   LACAD & $FF     ; &A6 - INKEY
        .byte   LACE2 & $FF     ; &A7 - INSTR(
        .byte   LAC78 & $FF     ; &A8 - INT
        .byte   LAED1 & $FF     ; &A9 - LEN
        .byte   LA7FE & $FF     ; &AA - LN
        .byte   LABA8 & $FF     ; &AB - LOG
        .byte   LACD1 & $FF     ; &AC - NOT
        .byte   LBF80 & $FF     ; &AD - OPENUP
        .byte   LBF7C & $FF     ; &AE - OPENOUT
        .byte   LABCB & $FF     ; &AF - PI
        .byte   LAB41 & $FF     ; &B0 - POINT(
        .byte   LAB6D & $FF     ; &B1 - POS
        .byte   LABB1 & $FF     ; &B2 - RAD
        .byte   LAF49 & $FF     ; &B3 - RND
        .byte   LAB88 & $FF     ; &B4 - SGN
        .byte   LA998 & $FF     ; &B5 - SIN
        .byte   LA7B4 & $FF     ; &B6 - SQR
        .byte   LA6BE & $FF     ; &B7 - TAN
        .byte   LAEDC & $FF     ; &B8 - TO
        .byte   LACC4 & $FF     ; &B9 - TRUE
        .byte   LABD2 & $FF     ; &BA - USR
        .byte   LAC2F & $FF     ; &BB - VAL
        .byte   LAB76 & $FF     ; &BC - VPOS
        .byte   LB3BD & $FF     ; &BD - CHR$
        .byte   LAFBF & $FF     ; &BE - GET$
        .byte   LB026 & $FF     ; &BF - INKEY$
        .byte   LAFCC & $FF     ; &C0 - LEFT$(
        .byte   LB039 & $FF     ; &C1 - MID$(
        .byte   LAFEE & $FF     ; &C2 - RIGHT$(
        .byte   LB094 & $FF     ; &C3 - STR$(
        .byte   LB0C2 & $FF     ; &C4 - STRING$(
        .byte   LACB8 & $FF     ; &C5 - EOF
        .byte   L90AC & $FF     ; &C6 - AUTO
        .byte   L8F31 & $FF     ; &C7 - DELETE
        .byte   LBF24 & $FF     ; &C8 - LOAD
        .byte   LB59C & $FF     ; &C9 - LIST
        .byte   L8ADA & $FF     ; &CA - NEW
        .byte   L8AB6 & $FF     ; &CB - OLD
        .byte   L8FA3 & $FF     ; &CC - RENUMBER
        .byte   LBEF3 & $FF     ; &CD - SAVE
        .byte   L982A & $FF     ; &CE - unused
        .byte   LBF30 & $FF     ; &CF - PTR
        .byte   L9283 & $FF     ; &D0 - PAGE
        .byte   L92C9 & $FF     ; &D1 - TIME
        .byte   L926F & $FF     ; &D2 - LOMEM
        .byte   L925D & $FF     ; &D3 - HIMEM
        .byte   LB44C & $FF     ; &D4 - SOUND
        .byte   LBF58 & $FF     ; &D5 - BPUT
        .byte   L8ED2 & $FF     ; &D6 - CALL
        .byte   LBF2A & $FF     ; &D7 - CHAIN
        .byte   L928D & $FF     ; &D8 - CLEAR
        .byte   LBF99 & $FF     ; &D9 - CLOSE
        .byte   L8EBD & $FF     ; &DA - CLG
        .byte   L8EC4 & $FF     ; &DB - CLS
        .byte   L8B7D & $FF     ; &DC - DATA
        .byte   L8B7D & $FF     ; &DD - DEF
        .byte   L912F & $FF     ; &DE - DIM
        .byte   L93E8 & $FF     ; &DF - DRAW
        .byte   L8AC8 & $FF     ; &E0 - END
        .byte   L9356 & $FF     ; &E1 - ENDPROC
        .byte   LB472 & $FF     ; &E2 - ENVELOPE
        .byte   LB7C4 & $FF     ; &E3 - FOR
        .byte   LB888 & $FF     ; &E4 - GOSUB
        .byte   LB8CC & $FF     ; &E5 - GOTO
        .byte   L937A & $FF     ; &E6 - GCOL
        .byte   L98C2 & $FF     ; &E7 - IF
        .byte   LBA44 & $FF     ; &E8 - INPUT
        .byte   L8BE4 & $FF     ; &E9 - LET
        .byte   L9323 & $FF     ; &EA - LOCAL
        .byte   L939A & $FF     ; &EB - MODE
        .byte   L93E4 & $FF     ; &EC - MOVE
        .byte   LB695 & $FF     ; &ED - NEXT
        .byte   LB915 & $FF     ; &EE - ON
        .byte   L942F & $FF     ; &EF - VDU
        .byte   L93F1 & $FF     ; &F0 - PLOT
        .byte   L8D9A & $FF     ; &F1 - PRINT
        .byte   L9304 & $FF     ; &F2 - PROC
        .byte   LBB1F & $FF     ; &F3 - READ
        .byte   L8B7D & $FF     ; &F4 - REM
        .byte   LBBE4 & $FF     ; &F5 - REPEAT
        .byte   LBFE4 & $FF     ; &F6 - REPORT
        .byte   LBAE6 & $FF     ; &F7 - RESTORE
        .byte   LB8B6 & $FF     ; &F8 - RETURN
        .byte   LBD11 & $FF     ; &F9 - RUN
        .byte   L8AD0 & $FF     ; &FA - STOP
        .byte   L938E & $FF     ; &FB - COLOUR
        .byte   L9295 & $FF     ; &FC - TRACE
        .byte   LBBB1 & $FF     ; &FD - UNTIL
        .byte   LB4A0 & $FF     ; &FE - WIDTH
        .byte   LBEC2 & $FF     ; &FF - OSCLI

; FUNCTION/COMMAND DISPATCH TABLE, ADDRESS HIGH BYTES
; ===================================================
L83DF: ; &83E6
        .byte   LBF78 / 256     ; &8E - OPENIN
        .byte   LBF47 / 256     ; &8F - PTR
        .byte   LAEC0 / 256     ; &90 - PAGE
        .byte   LAEB4 / 256     ; &91 - TIME
        .byte   LAEFC / 256     ; &92 - LOMEM
        .byte   LAF03 / 256     ; &93 - HIMEM
        .byte   LAD6A / 256     ; &94 - ABS
        .byte   LA8D4 / 256     ; &95 - ACS
        .byte   LAB33 / 256     ; &96 - ADVAL
        .byte   LAC9E / 256     ; &97 - ASC
        .byte   LA8DA / 256     ; &98 - ASN
        .byte   LA907 / 256     ; &99 - ATN
        .byte   LBF6F / 256     ; &9A - BGET
        .byte   LA98D / 256     ; &9B - COS
        .byte   LAEF7 / 256     ; &9C - COUNT
        .byte   LABC2 / 256     ; &9D - DEG
        .byte   LAF9F / 256     ; &9E - ERL
        .byte   LAFA6 / 256     ; &9F - ERR
        .byte   LABE9 / 256     ; &A0 - EVAL
        .byte   LAA91 / 256     ; &A1 - EXP
        .byte   LBF46 / 256     ; &A2 - EXT
        .byte   LAECA / 256     ; &A3 - FALSE
        .byte   LB195 / 256     ; &A4 - FN
        .byte   LAFB9 / 256     ; &A5 - GET
        .byte   LACAD / 256     ; &A6 - INKEY
        .byte   LACE2 / 256     ; &A7 - INSTR(
        .byte   LAC78 / 256     ; &A8 - INT
        .byte   LAED1 / 256     ; &A9 - LEN
        .byte   LA7FE / 256     ; &AA - LN
        .byte   LABA8 / 256     ; &AB - LOG
        .byte   LACD1 / 256     ; &AC - NOT
        .byte   LBF80 / 256     ; &AD - OPENUP
        .byte   LBF7C / 256     ; &AE - OPENOUT
        .byte   LABCB / 256     ; &AF - PI
        .byte   LAB41 / 256     ; &B0 - POINT(
        .byte   LAB6D / 256     ; &B1 - POS
        .byte   LABB1 / 256     ; &B2 - RAD
        .byte   LAF49 / 256     ; &B3 - RND
        .byte   LAB88 / 256     ; &B4 - SGN
        .byte   LA998 / 256     ; &B5 - SIN
        .byte   LA7B4 / 256     ; &B6 - SQR
        .byte   LA6BE / 256     ; &B7 - TAN
        .byte   LAEDC / 256     ; &B8 - TO
        .byte   LACC4 / 256     ; &B9 - TRUE
        .byte   LABD2 / 256     ; &BA - USR
        .byte   LAC2F / 256     ; &BB - VAL
        .byte   LAB76 / 256     ; &BC - VPOS
        .byte   LB3BD / 256     ; &BD - CHR$
        .byte   LAFBF / 256     ; &BE - GET$
        .byte   LB026 / 256     ; &BF - INKEY$
        .byte   LAFCC / 256     ; &C0 - LEFT$(
        .byte   LB039 / 256     ; &C1 - MID$(
        .byte   LAFEE / 256     ; &C2 - RIGHT$(
        .byte   LB094 / 256     ; &C3 - STR$(
        .byte   LB0C2 / 256     ; &C4 - STRING$(
        .byte   LACB8 / 256     ; &C5 - EOF
        .byte   L90AC / 256     ; &C6 - AUTO
        .byte   L8F31 / 256     ; &C7 - DELETE
        .byte   LBF24 / 256     ; &C8 - LOAD
        .byte   LB59C / 256     ; &C9 - LIST
        .byte   L8ADA / 256     ; &CA - NEW
        .byte   L8AB6 / 256     ; &CB - OLD
        .byte   L8FA3 / 256     ; &CC - RENUMBER
        .byte   LBEF3 / 256     ; &CD - SAVE
        .byte   L982A / 256     ; &CE - unused
        .byte   LBF30 / 256     ; &CF - PTR
        .byte   L9283 / 256     ; &D0 - PAGE
        .byte   L92C9 / 256     ; &D1 - TIME
        .byte   L926F / 256     ; &D2 - LOMEM
        .byte   L925D / 256     ; &D3 - HIMEM
        .byte   LB44C / 256     ; &D4 - SOUND
        .byte   LBF58 / 256     ; &D5 - BPUT
        .byte   L8ED2 / 256     ; &D6 - CALL
        .byte   LBF2A / 256     ; &D7 - CHAIN
        .byte   L928D / 256     ; &D8 - CLEAR
        .byte   LBF99 / 256     ; &D9 - CLOSE
        .byte   L8EBD / 256     ; &DA - CLG
        .byte   L8EC4 / 256     ; &DB - CLS
        .byte   L8B7D / 256     ; &DC - DATA
        .byte   L8B7D / 256     ; &DD - DEF
        .byte   L912F / 256     ; &DE - DIM
        .byte   L93E8 / 256     ; &DF - DRAW
        .byte   L8AC8 / 256     ; &E0 - END
        .byte   L9356 / 256     ; &E1 - ENDPROC
        .byte   LB472 / 256     ; &E2 - ENVELOPE
        .byte   LB7C4 / 256     ; &E3 - FOR
        .byte   LB888 / 256     ; &E4 - GOSUB
        .byte   LB8CC / 256     ; &E5 - GOTO
        .byte   L937A / 256     ; &E6 - GCOL
        .byte   L98C2 / 256     ; &E7 - IF
        .byte   LBA44 / 256     ; &E8 - INPUT
        .byte   L8BE4 / 256     ; &E9 - LET
        .byte   L9323 / 256     ; &EA - LOCAL
        .byte   L939A / 256     ; &EB - MODE
        .byte   L93E4 / 256     ; &EC - MOVE
        .byte   LB695 / 256     ; &ED - NEXT
        .byte   LB915 / 256     ; &EE - ON
        .byte   L942F / 256     ; &EF - VDU
        .byte   L93F1 / 256     ; &F0 - PLOT
        .byte   L8D9A / 256     ; &F1 - PRINT
        .byte   L9304 / 256     ; &F2 - PROC
        .byte   LBB1F / 256     ; &F3 - READ
        .byte   L8B7D / 256     ; &F4 - REM
        .byte   LBBE4 / 256     ; &F5 - REPEAT
        .byte   LBFE4 / 256     ; &F6 - REPORT
        .byte   LBAE6 / 256     ; &F7 - RESTORE
        .byte   LB8B6 / 256     ; &F8 - RETURN
        .byte   LBD11 / 256     ; &F9 - RUN
        .byte   L8AD0 / 256     ; &FA - STOP
        .byte   L938E / 256     ; &FB - COLOUR
        .byte   L9295 / 256     ; &FC - TRACE
        .byte   LBBB1 / 256     ; &FD - UNTIL
        .byte   LB4A0 / 256     ; &FE - WIDTH
        .byte   LBEC2 / 256     ; &FF - OSCLI

; ASSEMBLER
; =========
;
; Packed mnemonic table, low bytes
; --------------------------------
L8451:
        MNEML 'B','R','K'
        MNEML 'C','L','C'
        MNEML 'C','L','D'
        MNEML 'C','L','I'
        MNEML 'C','L','V'
        MNEML 'D','E','X'
        MNEML 'D','E','Y'
        MNEML 'I','N','X'
        MNEML 'I','N','Y'
        MNEML 'N','O','P'
        MNEML 'P','H','A'
        MNEML 'P','H','P'
        MNEML 'P','L','A'
        MNEML 'P','L','P'
        MNEML 'R','T','I'
        MNEML 'R','T','S'
        MNEML 'S','E','C'
        MNEML 'S','E','D'
        MNEML 'S','E','I'
        MNEML 'T','A','X'
        MNEML 'T','A','Y'
        MNEML 'T','S','X'
        MNEML 'T','X','A'
        MNEML 'T','X','S'
        MNEML 'T','Y','A'
        MNEML 'B','C','C'
        MNEML 'B','C','S'
        MNEML 'B','E','Q'
        MNEML 'B','M','I'
        MNEML 'B','N','E'
        MNEML 'B','P','L'
        MNEML 'B','V','C'
        MNEML 'B','V','S'
        MNEML 'A','N','D'
        MNEML 'E','O','R'
        MNEML 'O','R','A'
        MNEML 'A','D','C'
        MNEML 'C','M','P'
        MNEML 'L','D','A'
        MNEML 'S','B','C'
        MNEML 'A','S','L'
        MNEML 'L','S','R'
        MNEML 'R','O','L'
        MNEML 'R','O','R'
        MNEML 'D','E','C'
        MNEML 'I','N','C'
        MNEML 'C','P','X'
        MNEML 'C','P','Y'
        MNEML 'B','I','T'
        MNEML 'J','M','P'
        MNEML 'J','S','R'
        MNEML 'L','D','X'
        MNEML 'L','D','Y'
        MNEML 'S','T','A'
        MNEML 'S','T','X'
        MNEML 'S','T','Y'
        MNEML 'O','P','T'
        MNEML 'E','Q','U'

; Packed mnemonic table, high bytes
; ---------------------------------
L848B:
        MNEMH 'B','R','K'
        MNEMH 'C','L','C'
        MNEMH 'C','L','D'
        MNEMH 'C','L','I'
        MNEMH 'C','L','V'
        MNEMH 'D','E','X'
        MNEMH 'D','E','Y'
        MNEMH 'I','N','X'
        MNEMH 'I','N','Y'
        MNEMH 'N','O','P'
        MNEMH 'P','H','A'
        MNEMH 'P','H','P'
        MNEMH 'P','L','A'
        MNEMH 'P','L','P'
        MNEMH 'R','T','I'
        MNEMH 'R','T','S'
        MNEMH 'S','E','C'
        MNEMH 'S','E','D'
        MNEMH 'S','E','I'
        MNEMH 'T','A','X'
        MNEMH 'T','A','Y'
        MNEMH 'T','S','X'
        MNEMH 'T','X','A'
        MNEMH 'T','X','S'
        MNEMH 'T','Y','A'
        MNEMH 'B','C','C'
        MNEMH 'B','C','S'
        MNEMH 'B','E','Q'
        MNEMH 'B','M','I'
        MNEMH 'B','N','E'
        MNEMH 'B','P','L'
        MNEMH 'B','V','C'
        MNEMH 'B','V','S'
        MNEMH 'A','N','D'
        MNEMH 'E','O','R'
        MNEMH 'O','R','A'
        MNEMH 'A','D','C'
        MNEMH 'C','M','P'
        MNEMH 'L','D','A'
        MNEMH 'S','B','C'
        MNEMH 'A','S','L'
        MNEMH 'L','S','R'
        MNEMH 'R','O','L'
        MNEMH 'R','O','R'
        MNEMH 'D','E','C'
        MNEMH 'I','N','C'
        MNEMH 'C','P','X'
        MNEMH 'C','P','Y'
        MNEMH 'B','I','T'
        MNEMH 'J','M','P'
        MNEMH 'J','S','R'
        MNEMH 'L','D','X'
        MNEMH 'L','D','Y'
        MNEMH 'S','T','A'
        MNEMH 'S','T','X'
        MNEMH 'S','T','Y'
        MNEMH 'O','P','T'
        MNEMH 'E','Q','U'

; Opcode base table
; -----------------
L84C5:

; No arguments
; ------------
        BRK
        CLC
        CLD
        CLI
        CLV
        DEX
        DEY
        INX
        INY
        NOP
        PHA
        PHP
        PLA
        PLP
        RTI
        RTS
        SEC
        SED
        SEI
        TAX
        TAY
        TSX
        TXA
        TXS
        TYA

; Branches
; --------
        .byte   $90, $B0, $F0, $30 ; BMI, BCC, BCS, BEQ
        .byte   $D0, $10, $50, $70 ; BNE, BPL, BVC, BVS

; Arithmetic
; ----------
        .byte   $21, $41, $01, $61 ; AND, EOR, ORA, ADC
        .byte   $C1, $A1, $E1, $06 ; CMP, LDA, SBC, ASL
        .byte   $46, $26, $66, $C6 ; LSR, ROL, ROR, DEC
        .byte   $E6, $E0, $C0, $20 ; INC, CPX, CPY, BIT

; Others
; ------
        .byte   $4C, $20, $A2, $A0 ; JMP, JSR, LDX, LDY
        .byte   $81, $86, $84      ; STA, STX, STY

; Exit Assembler
; --------------
L84FD:
        lda     #$FF            ; Set OPT to 'BASIC'
L84FF:
        sta     $28             ; Set OPT, return to execution loop
        jmp     L8BA3
L8504:
        lda     #$03            ; Set OPT 3, default on entry to '['
        sta     $28
L8508:
        jsr    L8A97            ; Skip spaces
        cmp    #']'             ; ']' - exit assembler
        beq    L84FD
        jsr    L986D
L8512:
        dec    $0A
        jsr    L85BA
        dec    $0A
        lda    $28
        lsr    a
        bcc    L857E
        lda    $1E
        adc    #$04
        sta    $3F
        lda    $38
        jsr    LB545
        lda    $37
        jsr    LB562
        ldx    #$FC
        ldy    $39
        bpl    L8536
        ldy    $36
L8536:
        sty    $38
        beq    L8556
        ldy    #$00
L853C:
        inx
        bne    L854C
        jsr    LBC25            ; Print newline
        ldx    $3F

L8544:
        jsr    LB565            ; Print a space
        dex                     ; Loop to print spaces
        bne    L8544
        ldx    #$FD
L854C:
        lda    ($3A),y
        jsr    LB562
        iny
        dec    $38
        bne    L853C
L8556:
        inx
        bpl    L8565
        jsr    LB565
        jsr    LB558
        jsr    LB558
        jmp    L8556
L8565:
        ldy    #$00
L8567:
        lda    ($0B),y
        cmp    #$3A
        beq    L8577
        cmp    #$0D
        beq    L857B
L8571:
        jsr    LB50E            ; Print character or token
        iny
        bne    L8567
L8577:
        cpy    $0A
        bcc    L8571
L857B:
        jsr    LBC25            ; Print newline
L857E:
        ldy    $0A
        dey
L8581:
        iny
        lda    ($0B),y
        cmp    #$3A
        beq    L858C
        cmp    #$0D
        bne    L8581
L858C:
        jsr    L9859
        dey
        lda    ($0B),y
        cmp    #$3A
        beq    L85A2
        lda    $0C
        cmp    #$07
        bne    L859F
        jmp    L8AF6
L859F:
        jsr    L9890
L85A2:
        jmp    L8508
L85A5:
        jsr    L9582
        beq    L8604
        bcs    L8604
        jsr    LBD94
        jsr    LAE3A            ; Find P%
        sta    $27
        jsr    LB4B4
        jsr    L8827
L85BA:
        ldx    #$03             ; Prepare to fetch three characters
        jsr    L8A97            ; Skip spaces
        ldy    #$00
        sty    $3D
        cmp    #':'             ; End of statement
        beq    L862B
        cmp    #$0D             ; End of line
        beq    L862B
        cmp    #'\'             ; Comment
        beq    L862B
        cmp    #'.'             ; Label
        beq    L85A5
        dec    $0A
L85D5:
        ldy    $0A              ; Get current character, inc. index
        inc    $0A
        lda    ($0B),y          ; Token, check for tokenised AND, EOR, OR
        bmi    L8607
        cmp    #$20             ; Space, step past
        beq    L85F1
        ldy    #$05
        asl    a                ; Compact first character
        asl    a
        asl    a
L85E6:
        asl    a
        rol    $3D
        rol    $3E
        dey
        bne    L85E6
        dex                     ; Loop to fetch three characters
        bne    L85D5

; The current opcode has now been compressed into two bytes
; ---------------------------------------------------------
L85F1:
        ldx    #$3A             ; Point to end of opcode lookup table
        lda    $3D              ; Get low byte of compacted mnemonic
L85F5:
        cmp    L8451-1,x        ; Low half doesn't match
        bne    L8601
        ldy    L848B-1,x        ; Check high half
        cpy    $3E              ; Mnemonic matches
        beq    L8620
L8601:
        dex                     ; Loop through opcode lookup table
        bne    L85F5
L8604:
        jmp    L982A            ; Mnemonic not matched, Mistake
L8607:
        ldx    #$22             ; opcode number for 'AND'
        cmp    #tknAND          ; Tokenised 'AND'
        beq    L8620
        inx                     ; opcode number for 'EOR'
        cmp    #tknEOR          ; Tokenized 'EOR'
        beq    L8620
        inx                     ; opcode number for 'ORA'
        cmp    #tknOR           ; Not tokenized 'OR'
        bne    L8604
        inc    $0A              ; Get next character
        iny
        lda    ($0B),y
        cmp    #'A'             ; Ensure 'OR' followed by 'A'
        bne    L8604

; Opcode found
; ------------
L8620:
        lda    L84C5-1,x        ; Get base opcode
        sta    $29
        ldy    #$01             ; Y=1 for one byte
        cpx    #$1A             ; Opcode $1A+ have arguments
        bcs    L8673
L862B:
        lda    $0440            ; Get P% low byte
        sta    $37
        sty    $39
        ldx    $28              ; Offset assembly (opt>3)
        cpx    #$04
        ldx    $0441            ; Get P% high byte
        stx    $38
        bcc    L8643            ; No offset assembly
        lda    $043C
        ldx    $043D            ; Get O%
L8643:
        sta    $3A              ; Store destination pointer
        stx    $3B
        tya
        beq    L8672
        bpl    L8650
        ldy    $36
        beq    L8672
L8650:
        dey                     ; Get opcode byte
        lda    $0029,y
        bit    $39              ; Opcode - jump to store it
        bpl    L865B
        lda    $0600,y          ; Get EQU byte
L865B:
        sta    ($3A),y          ; Store byte
        inc    $0440            ; Increment P%
        bne    L8665
        inc    $0441
L8665:
        bcc    L866F
        inc    $043C            ; Increment O%
        bne    L866F
        inc    $043D
L866F:
        tya
        bne    L8650
L8672:
        rts
L8673:
        cpx    #$22
        bcs    L86B7
        jsr    L8821
        clc
        lda    $2A
        sbc    $0440
        tay
        lda    $2B
        sbc    $0441
        cpy    #$01
        dey
        sbc    #$00
        beq    L86B2
        cmp    #$FF
        beq    L86AD
L8691:
        lda    $28              ; Get OPT
        lsr    a
        beq    L86A5            ; If OPT.b0=0, ignore error
        brk
        .byte  $01,"Out of range"
        brk
L86A5:
        tay
L86A6:
        sty    $2A
L86A8:
        ldy    #$02
        jmp    L862B
L86AD:
        tya
        bmi    L86A6
        bpl    L8691
L86B2:
        tya
        bpl    L86A6
        bmi    L8691
L86B7:
        cpx    #$29
        bcs    L86D3
        jsr    L8A97            ; Skip spaces
        cmp    #'#'
        bne    L86DA
        jsr    L882F
L86C5:
        jsr    L8821
L86C8:
        lda    $2B
        beq    L86A8
L86CC:
        brk
        .byte  $02,"Byte"
         brk

; Parse (zp),Y addressing mode
; ----------------------------
L86D3:
        cpx    #$36
        bne    L873F
        jsr    L8A97            ; Skip spaces
L86DA:
        cmp    #'('
        bne    L8715
        jsr    L8821
        jsr    L8A97            ; Skip spaces
        cmp    #')'
        bne    L86FB
        jsr    L8A97            ; Skip spaces
        cmp    #','             ; No comma, jump to Index error
        bne    L870D
        jsr    L882C
        jsr    L8A97            ; Skip spaces
        cmp    #'Y'             ; (z),Y missing Y, jump to Index error
        bne    L870D
        beq    L86C8

; Parse (zp,X) addressing mode
; ----------------------------
L86FB:
        cmp    #','             ; No comma, jump to Index error
        bne    L870D
        jsr    L8A97            ; Skip spaces
        cmp    #'X'             ; zp,X missing X, jump to Index error
        bne    L870D
        jsr    L8A97
        cmp    #')'             ; zp,X) - jump to process
        beq    L86C8
L870D:
        brk
        .byte  $03,"Index"
        brk
L8715:
        dec    $0A
        jsr    L8821
        jsr    L8A97            ; Skip spaces
        cmp    #','             ; No comma - jump to process as abs,X
        bne    L8735
        jsr    L882C
        jsr    L8A97            ; Skip spaces
        cmp    #'X'             ; abs,X - jump to process
        beq    L8735
        cmp    #'Y'             ; Not abs,Y - jump to Index error
        bne    L870D
L872F:
        jsr    L882F
        jmp    L879A

; abs and abs,X
; -------------
L8735:
        jsr    L8832
L8738:
        lda    $2B
        bne    L872F
        jmp    L86A8
L873F:
        cpx    #$2F
        bcs    L876E
        cpx    #$2D
        bcs    L8750
        jsr    L8A97            ; Skip spaces
        cmp    #'A'             ; ins A -
        beq    L8767
        dec    $0A
L8750:
        jsr    L8821
        jsr    L8A97            ; Skip spaces
        cmp    #','
        bne    L8738            ; No comma, jump to ...
        jsr    L882C
        jsr    L8A97            ; Skip spaces
        cmp    #'X'
        beq    L8738            ; Jump with address,X
        jmp    L870D            ; Otherwise, jump to Index error
L8767:
        jsr    L8832
        ldy    #$01
        bne    L879C
L876E:
        cpx    #$32
        bcs    L8788
        cpx    #$31
        beq    L8782
        jsr    L8A97            ; Skip spaces
        cmp    #'#'
        bne    L8780            ; Not #, jump with address
        jmp    L86C5
L8780:
        dec    $0A
L8782:
        jsr    L8821
        jmp    L8735
L8788:
        cpx    #$33
        beq    L8797
        bcs    L87B2
        jsr    L8A97            ; Skip spaces
        cmp    #'('
        beq    L879F            ; Jump With (... addressing mode
        dec    $0A
L8797:
        jsr    L8821
L879A:
        ldy    #$03
L879C:
        jmp    L862B
L879F:
        jsr    L882C
        jsr    L882C
        jsr    L8821
        jsr    L8A97            ; Skip spaces
        cmp    #')'
        beq    L879A
        jmp    L870D            ; No ) - jump to Index error
L87B2:
        cpx    #$39
        bcs    L8813
        lda    $3D
        eor    #$01
        and    #$1F
        pha
        cpx    #$37
        bcs    L87F0
        jsr    L8A97            ; Skip spaces
        cmp    #'#'
        bne    L87CC
        pla
        jmp    L86C5
L87CC:
        dec    $0A
        jsr    L8821
        pla
        sta    $37
        jsr    L8A97
        cmp    #','
        beq    L87DE
        jmp    L8735
L87DE:
        jsr    L8A97
        and    #$1F
        cmp    $37
        bne    L87ED
        jsr    L882C
        jmp    L8735
L87ED:
        jmp    L870D            ; Jump to Index error
L87F0:
        jsr    L8821
        pla
        sta    $37
        jsr    L8A97
        cmp    #','
        bne    L8810
        jsr    L8A97
        and    #$1F
        cmp    $37
        bne    L87ED
        jsr    L882C
        lda    $2B
        beq    L8810            ; High byte=0, continue
        jmp    L86CC            ; value>255, jump to Byte error
L8810:
        jmp    L8738
L8813:
        bne    L883A
        jsr    L8821
        lda    $2A
        sta    $28
        ldy    #$00
        jmp    L862B
L8821:
        jsr    L9B1D
        jsr    L92F0
L8827:
        ldy    $1B
        sty    $0A
        rts
L882C:
        jsr    L882F
L882F:
        jsr    L8832
L8832:
        lda    $29
        clc
        adc    #$04
        sta    $29
        rts
L883A:
        ldx    #$01             ; Prepare for one byte
        ldy    $0A
        inc    $0A              ; Increment address
        lda    ($0B),y          ; Get next character
        cmp    #'B'
        beq    L8858            ; EQUB
        inx                     ; Prepare for two bytes
        cmp    #'W'
        beq    L8858            ; EQUW
        ldx    #$04             ; Prepare for four bytes
        cmp    #'D'
        beq    L8858            ; EQUD
        cmp    #'S'
        beq    L886A            ; EQUS
        jmp    L982A            ; Syntax error
L8858:
        txa
        pha
        jsr    L8821
        ldx    #$29
        jsr    LBE44
        pla
        tay
L8864:
        jmp    L862B
L8867:
        jmp    L8C0E
L886A:
        lda    $28
        pha
        jsr    L9B1D
        bne    L8867
        pla
        sta    $28
        jsr    L8827
        ldy    #$FF
        bne    L8864
L887C:
        pha
        clc
        tya
        adc    $37
        sta    $39
        ldy    #$00
        tya
        adc    $38
        sta    $3A
        pla
        sta    ($37),y
L888D:
        iny
        lda    ($39),y
        sta    ($37),y
        cmp    #$0D
        bne    L888D
        rts
L8897:
        and    #$0F
        sta    $3D
        sty    $3E
L889D:
        iny
        lda    ($37),y
        cmp    #'9'+1
        bcs    L88DA
        cmp    #'0'
        bcc    L88DA
        and    #$0F
        pha
        ldx    $3E
        lda    $3D
        asl    a
        rol    $3E
        bmi    L88D5
        asl    a
        rol    $3E
        bmi    L88D5
        adc    $3D
        sta    $3D
        txa
        adc    $3E
        asl    $3D
        rol    a
        bmi    L88D5
        bcs    L88D5
        sta    $3E
        pla
        adc    $3D
        sta    $3D
        bcc    L889D
        inc    $3E
        bpl    L889D
        pha
L88D5:
        pla
        ldy    #$00
        sec
        rts
L88DA:
        dey
        lda    #$8D
        jsr    L887C
        lda    $37
        adc    #$02
        sta    $39
        lda    $38
        adc    #$00
        sta    $3A
L88EC:
        lda    ($37),y
        sta    ($39),y
        dey
        bne    L88EC
        ldy    #$03
L88F5:
        lda    $3E
        ora    #$40
        sta    ($37),y
        dey
        lda    $3D
        and    #$3F
        ora    #$40
        sta    ($37),y
        dey
        lda    $3D
        and    #$C0
        sta    $3D
        lda    $3E
        and    #$C0
        lsr    a
        lsr    a
        ora    $3D
        lsr    a
        lsr    a
        eor    #$54
        sta    ($37),y
        jsr    L8944            ; Increment $37/8
        jsr    L8944            ; Increment $37/8
        jsr    L8944            ; Increment $37/8
        ldy    #$00
L8924:
        clc
        rts
L8926:
        cmp    #$7B
        bcs    L8924
        cmp    #$5F
        bcs    L893C
        cmp    #$5B
        bcs    L8924
        cmp    #$41
        bcs    L893C
L8936:
        cmp    #$3A
        bcs    L8924
        cmp    #$30
L893C:
        rts
L893D:
        cmp    #$2E
        bne    L8936
        rts
L8942:
        lda    ($37),y
L8944:
        inc    $37
        bne    L894A
        inc    $38
L894A:
        rts
L894B:
        jsr    L8944            ; Increment $37/8
        lda    ($37),y
        rts

; Tokenise line at &37/8
; ======================
L8951:
        ldy    #$00
        sty    $3B              ; Set tokenizer to left-hand-side
L8955:
        sty    $3C
L8957:
        lda    ($37),y          ; Get current character
        cmp    #$0D
        beq    L894A            ; Exit with <cr>
        cmp    #$20
        bne    L8966            ; Skip <spc>
L8961:
        jsr    L8944
        bne    L8957            ; Increment $37/8 and check next character
L8966:
        cmp    #'&'
        bne    L897C            ; Jump if not '&'
L896A:
        jsr    L894B            ; Increment $37/8 and get next character
        jsr    L8936
        bcs    L896A            ; Jump if numeric character
        cmp    #'A'
        bcc    L8957            ; Loop back if <'A'
        cmp    #'F'+1
        bcc    L896A            ; Step to next if 'A'..'F'
        bcs    L8957            ; Loop back for next character
L897C:
        cmp    #$22
        bne    L898C
L8980:
        jsr    L894B            ; Increment $37/8 and get next character
        cmp    #$22
        beq    L8961            ; Not quote, jump to process next character
        cmp    #$0D
        bne    L8980
        rts
L898C:
        cmp    #':'
        bne    L8996
        sty    $3B
        sty    $3C
        beq    L8961
L8996:
        cmp    #','
        beq    L8961
        cmp    #'*'
        bne    L89A3
        lda    $3B
        bne    L89E3
        rts
L89A3:
        cmp    #'.'
        beq    L89B5
        jsr    L8936
        bcc    L89DF
        ldx    $3C
        beq    L89B5
        jsr    L8897
        bcc    L89E9
L89B5:
        lda    ($37),y
        jsr    L893D
        bcc    L89C2
        jsr    L8944
        jmp    L89B5
L89C2:
        ldx    #$FF
        stx    $3B
        sty    $3C
        jmp    L8957
L89CB:
        jsr    L8926
        bcc    L89E3
L89D0:
        ldy    #$00
L89D2:
        lda    ($37),y
        jsr    L8926
        bcc    L89C2
        jsr    L8944
        jmp    L89D2
L89DF:
        cmp    #'A'
        bcs    L89EC            ; Jump if letter
L89E3:
        ldx    #$FF
        stx    $3B
        sty    $3C
L89E9:
        jmp    L8961
L89EC:
        cmp    #'X'
        bcs    L89CB            ; Jump if >='X', nothing starts with X,Y,Z
        ldx    #L8071 & 255     ; Point to token table
        stx    $39
        ldx    #L8071 / 256
        stx    $3A
L89F8:
        cmp    ($39),y
        bcc    L89D2
        bne    L8A0D
L89FE:
        iny
        lda    ($39),y
        bmi    L8A37
        cmp    ($37),y
        beq    L89FE
        lda    ($37),y
        cmp    #'.'
        beq    L8A18
L8A0D:
        iny
        lda    ($39),y
        bpl    L8A0D
        cmp    #$FE
        bne    L8A25
        bcs    L89D0
L8A18:
        iny
L8A19:
        lda    ($39),y
        bmi    L8A37
        inc    $39
        bne    L8A19
        inc    $3A
        bne    L8A19
L8A25:
        sec
        iny
        tya
        adc    $39
        sta    $39
        bcc    L8A30
        inc    $3A
L8A30:
        ldy    #$00
        lda    ($37),y
        jmp    L89F8
L8A37:
        tax
        iny
        lda    ($39),y
        sta    $3D              ; Get token flag
        dey
        lsr    a
        bcc    L8A48
        lda    ($37),y
        jsr    L8926
        bcs    L89D0
L8A48:
        txa
        bit    $3D
        bvc    L8A54
        ldx    $3B
        bne    L8A54
        clc                     ; Superfluous as all paths to here have CLC
        adc    #$40
L8A54:
        dey
        jsr    L887C
        ldy    #$00
        ldx    #$FF
        lda    $3D
        lsr    a
        lsr    a
        bcc    L8A66
        stx    $3B
        sty    $3C
L8A66:
        lsr    a
        bcc    L8A6D
        sty    $3B
        sty    $3C
L8A6D:
        lsr    a
        bcc    L8A81
        pha
        iny
L8A72:
        lda    ($37),y
        jsr    L8926
        bcc    L8A7F
        jsr    L8944
        jmp    L8A72
L8A7F:
        dey
        pla
L8A81:
        lsr    a
        bcc    L8A86
        stx    $3C
L8A86:
        lsr    a
        bcs    L8A96
        jmp    L8961

; Skip Spaces
; ===========
L8A8C:
        ldy    $1B              ; Get offset, increment it
        inc    $1B
        lda    ($19),y          ; Get current character
        cmp    #' '
        beq    L8A8C            ; Loop until not space
L8A96:
        rts

; Skip spaces at PtrA
; -------------------
L8A97:
        ldy    $0A
        inc    $0A
        lda    ($0B),y
        cmp    #$20
        beq    L8A97
L8AA1:
         rts
L8AA2:
        brk
        .byte  $05
        .byte "Missing ,"
        brk
L8AAE:
        jsr    L8A8C
        cmp    #','
        bne    L8AA2
        rts

; OLD - Attempt to restore program
; ================================
L8AB6:
        jsr    L9857            ; Check end of statement
        lda    $18
        sta    $38              ; Point $37/8 to PAGE
        lda    #$00
        sta    $37
        sta    ($37),y          ; Remove end marker
        jsr    LBE6F            ; Check program and set TOP
        bne    L8AF3            ; Jump to clear heap and go to immediate mode

; END - Return to immediate mode
; ==============================
L8AC8:
        jsr    L9857            ; Check end of statement
        jsr    LBE6F            ; Check program and set TOP
        bne    L8AF6            ; Jump to immediate mode, keeping variables, etc

; STOP - Abort program with an error
; ==================================
L8AD0:
        jsr    L9857            ; Check end of statement
        brk
        .byte  $00
        .byte  "STOP"
        brk

; NEW - Clear program, enter immediate mode
; =========================================
L8ADA:
        jsr    L9857            ; Check end if statement

; Start up with NEW program
; -------------------------
L8ADD:
        lda    #$0D             ; TOP hi=PAGE hi
        ldy    $18
        sty    $13
        ldy    #$00             ; TOP=PAGE, TRACE OFF
        sty    $12
        sty    $20
        sta    ($12),y          ; ?(PAGE+0)=<cr>
        lda    #$FF             ; ?(PAGE+1)=$FF
        iny
        sta    ($12),y
        iny                     ; TOP=PAGE+2
        sty    $12
L8AF3:
        jsr    LBD20            ; Clear variables, heap, stack

; IMMEDIATE LOOP
; ==============
L8AF6:
        ldy    #$07             ; PtrA=&0700 - input buffer
        sty    $0C
        ldy    #$00
        sty    $0B
        lda    #LB433 & 255     ; ON ERROR OFF
        sta    $16
        lda    #LB433 / 256
        sta    $17
        lda    #'>'             ; Print '>' prompt, read input to buffer at PtrA
        jsr    LBC02

; Execute line at program pointer in &0B/C
; ----------------------------------------
L8B0B:
        lda    #LB433 & 255     ; ON ERROR OFF again
        sta    $16
        lda    #LB433 / 256
        sta    $17
        ldx    #$FF             ; OPT=$FF - not within assembler
        stx    $28
        stx    $3C              ; Clear machine stack
        txs
        jsr    LBD3A            ; Clear DATA and stacks
        tay
        lda    $0B              ; Point $37/8 to program line
        sta    $37
        lda    $0C
        sta    $38
        sty    $3B
        sty    $0A
        jsr    L8957
        jsr    L97DF            ; Tokenise, jump forward if no line number
        bcc    L8B38
        jsr    LBC8D            ; Insert into program, jump back to immediate loop
        jmp    L8AF3

; Command entered at immediate prompt
; -----------------------------------
L8B38:
        jsr    L8A97            ; Skip spaces at PtrA
        cmp    #$C6             ; If command token, jump to execute command
        bcs    L8BB1
        bcc    L8BBF            ; Not command token, try variable assignment
L8B41:
        jmp    L8AF6            ; Jump back to immediate mode

; [ - enter assembler
; ===================
L8B44:
        jmp    L8504            ; Jump to assembler

; =<value> - return from FN
; =========================
; Stack needs to contain these items,
;  ret_lo, ret_hi, PtrB_hi, PtrB_lo, PtrB_off, numparams, PtrA_hi, PtrA_lo, PtrA_off, tknFN
L8B47:
        tsx                     ; If stack is empty, jump to give error
        cpx    #$FC
        bcs    L8B59
        lda    $01FF            ; If pushed token<>'FN', give error
        cmp    #tknFN
        bne    L8B59
        jsr    L9B1D            ; Evaluate expression
        jmp    L984C            ; Check for end of statement and return to pop from function
L8B59:
        brk
        .byte  $07,"No ",tknFN
        brk

; Check for =, *, [ commands
; ==========================
L8B60:
        ldy    $0A              ; Step program pointer back and fetch char
        dey
        lda    ($0B),y
        cmp    #'='             ; Jump for '=', return from FN
        beq    L8B47
        cmp    #'*'             ; Jump for '*', embedded *command
        beq    L8B73
        cmp    #'['             ; Jump for '[', start assembler
        beq    L8B44
        bne    L8B96            ; Otherwise, see if end of statement

; Embedded *command
; =================
L8B73:
        jsr    L986D            ; Update PtrA to current address
        ldx    $0B
        ldy    $0C
        jsr    OS_CLI           ; Pass command at ptrA to OSCLI


; DATA, DEF, REM, ELSE
; ====================
; Skip to end of line
; -------------------
L8B7D:
        lda    #$0D             ; Get program pointer
        ldy    $0A
        dey
L8B82:
        iny                     ; Loop until <cr> found
        cmp    ($0B),y
        bne    L8B82
L8B87:
        cmp    #tknELSE         ; If 'ELSE', jump to skip to end of line
        beq    L8B7D
        lda    $0C              ; Program in command buffer, jump back to immediate loop
        cmp    #$0700 /256
        beq    L8B41
        jsr    L9890            ; Check for end of program, step past <cr>
        bne    L8BA3
L8B96:
        dec    $0A
L8B98:
        jsr    L9857

; Main execution loop
; -------------------
L8B9B:
        ldy    #$00             ; Get current character
        lda    ($0B),y
        cmp    #':'             ; Not <colon>, check for ELSE
        bne    L8B87
L8BA3:
        ldy    $0A              ; Get program pointer, increment for next time
        inc    $0A
        lda    ($0B),y          ; Get current character
        cmp    #$20
        beq    L8BA3
        cmp    #$CF             ; Not program command, jump to try variable assignment
        bcc    L8BBF

; Dispatch function/command
; -------------------------
L8BB1:
        tax                     ; Index into dispatch table
        lda    L836D-$8E,x      ; Get routine address from table
        sta    $37
        lda    L83DF-$8E,x
        sta    $38
        jmp    ($0037)          ; Jump to routine

; Not a command byte, try variable assignment, or =, *, [
; -------------------------------------------------------
L8BBF:
        ldx    $0B              ; Copy PtrA to PtrB
        stx    $19
        ldx    $0C
        stx    $1A
        sty    $1B              ; Check if variable or indirection
        jsr    L95DD
        bne    L8BE9            ; NE - jump for existing variable or indirection assignment
        bcs    L8B60            ; CS - not variable assignment, try =, *, [ commands

; Variable not found, create a new one
; ------------------------------------
        stx    $1B              ; Check for and step past '='
        jsr    L9841
        jsr    L94FC            ; Create new variable
        ldx    #$05             ; X=&05 = float
        cpx    $2C              ; Jump if dest. not a float
        bne    L8BDF
        inx                     ; X=&06
L8BDF:
        jsr    L9531
        dec    $0A

; LET variable = expression
; =========================
L8BE4:
        jsr    L9582
        beq    L8C0B
L8BE9:
        bcc    L8BFB
        jsr    LBD94            ; Stack integer (address of data)
        jsr    L9813            ; Check for end of statement
        lda    $27              ; Get evaluation type
        bne    L8C0E            ; If not string, error
        jsr    L8C1E            ; Assign the string
        jmp    L8B9B            ; Return to execution loop
L8BFB:
        jsr    LBD94            ; Stack integer (address of data)
        jsr    L9813            ; Check for end of statement
        lda    $27              ; Get evaluation type
        beq    L8C0E            ; If not number, error
        jsr    LB4B4            ; Assign the number
        jmp    L8B9B            ; Return to execution loop
L8C0B:
        jmp    L982A
L8C0E:
        brk
        .byte   $06, "Type mismatch"
        brk
L8C1E:
        jsr    LBDEA            ; Unstack integer (address of data)
L8C21:
        lda    $2C
        cmp    #$80             ; Jump if absolute string $addr
        beq    L8CA2
        ldy    #$02
        lda    ($2A),y
        cmp    $36
        bcs    L8C84
        lda    $02
        sta    $2C
        lda    $03
        sta    $2D
        lda    $36
        cmp    #$08
        bcc    L8C43
        adc    #$07
        bcc    L8C43
        lda    #$FF
L8C43:
        clc
        pha
        tax
        lda    ($2A),y
        ldy    #$00
        adc    ($2A),y
        eor    $02
        bne    L8C5F
        iny
        adc    ($2A),y
        eor    $03
        bne    L8C5F
        sta    $2D
        txa
        iny
        sec
        sbc    ($2A),y
        tax
L8C5F:
        txa
        clc
        adc    $02
        tay
        lda    $03
        adc    #$00
        cpy    $04
        tax
        sbc    $05
        bcs    L8CB7
        sty    $02
        stx    $03
        pla
        ldy    #$02
        sta    ($2A),y
        dey
        lda    $2D
        beq    L8C84
        sta    ($2A),y
        dey
        lda    $2C
        sta    ($2A),y
L8C84:
        ldy    #$03
        lda    $36
        sta    ($2A),y
        beq    L8CA1
        dey
        dey
        lda    ($2A),y
        sta    $2D
        dey
        lda    ($2A),y
        sta    $2C
L8C97:
        lda    $0600,y
        sta    ($2C),y
        iny
        cpy    $36
        bne    L8C97
L8CA1:
        rts
L8CA2:
        jsr    LBEBA
        cpy    #$00
        beq    L8CB4
L8CA9:
        lda    $0600,y
        sta    ($2A),y
        dey
        bne    L8CA9
        lda    $0600
L8CB4:
        sta    ($2A),y
        rts
L8CB7:
        brk
        .byte   $00, "No room"
        brk
L8CC1:
        lda     $39
        cmp     #$80
        beq     L8CEE
        bcc     L8D03
        ldy     #$00
         lda    ($04),y
         tax
         beq    L8CE5
         lda    ($37),y
         sbc    #$01
         sta    $39
         iny
         lda    ($37),y
         sbc    #$00
         sta    $3A
L8CDD:
        lda    ($04),y
        sta    ($39),y
        iny
        dex
        bne    L8CDD
L8CE5:
        lda    ($04,x)
        ldy    #$03
L8CE9:
        sta    ($37),y
        jmp    LBDDC
L8CEE:
        ldy    #$00
        lda    ($04),y
        tax
        beq    L8CFF
L8CF5:
        iny
        lda    ($04),y
        dey
        sta    ($37),y
        iny
        dex
        bne    L8CF5
L8CFF:
        lda    #$0D
        bne    L8CE9
L8D03:
        ldy    #$00
        lda    ($04),y
        sta    ($37),y
        iny
        cpy    $39
        bcs    L8D26
        lda    ($04),y
        sta    ($37),y
        iny
        lda    ($04),y
        sta    ($37),y
        iny
        lda    ($04),y
        sta    ($37),y
        iny
        cpy    $39
        bcs    L8D26
        lda    ($04),y
        sta    ($37),y
        iny
L8D26:
        tya
        clc
        jmp    LBDE1
L8D2B:
        dec    $0A
        jsr    LBFA9
L8D30:
        tya
        pha
        jsr    L8A8C
        cmp    #$2C
        bne    L8D77
        jsr    L9B29
        jsr    LA385
        pla
        tay
        lda    $27
        jsr    OSBPUT
        tax
        beq    L8D64
        bmi    L8D57
        ldx    #$03
L8D4D:
        lda    $2A,x
        jsr    OSBPUT
        dex
        bpl    L8D4D
        bmi    L8D30
L8D57:
        ldx    #$04
L8D59:
        lda    $046C,x
        jsr    OSBPUT
        dex
        bpl    L8D59
        bmi    L8D30
L8D64:
        lda    $36
        jsr    OSBPUT
        tax
        beq    L8D30
L8D6C:
        lda    $05FF,x
        jsr    OSBPUT
        dex
        bne    L8D6C
        beq    L8D30
L8D77:
        pla
        sty    $0A
        jmp    L8B98

; End of PRINT statement
; ----------------------
L8D7D:
        jsr    LBC25            ; Output new line and set COUNT to zero
L8D80:
        jmp    L8B96            ; Check end of statement, return to execution loop
L8D83:
        lda    #$00             ; Set current field to zero, hex/dec flag to decimal
        sta    $14
        sta    $15
        jsr    L8A97            ; Get next non-space character
        cmp    #':'             ; <colon> found, finish printing
        beq    L8D80
        cmp    #$0D             ; <cr> found, finish printing
        beq    L8D80
        cmp    #tknELSE         ; 'ELSE' found, finish printing
        beq    L8D80
        bne    L8DD2            ; Otherwise, continue into main loop

; PRINT [~][print items]['][,][;]
; ===============================
L8D9A:
        jsr    L8A97            ; Get next non-space char
        cmp    #'#'             ; If '#' jump to do PRINT#
        beq    L8D2B
        dec    $0A              ; Jump into PRINT loop
        jmp    L8DBB

; Print a comma
; -------------
L8DA6:
        lda    $0400            ; If field width zero, no padding needed, jump back into main loop
        beq    L8DBB
        lda    $1E              ; Get COUNT
L8DAD:
        beq    L8DBB            ; Zero, just started a new line, no padding, jump back into main loop
        sbc    $0400            ; Get COUNT-field width
        bcs    L8DAD            ; Loop to reduce until (COUNT MOD fieldwidth)<0
        tay                     ; Y=number of spaces to get back to (COUNT MOD width)=zero
L8DB5:
        jsr    LB565            ; Loop to print required spaces
        iny
        bne    L8DB5
L8DBB:
        clc                     ; Prepare to print decimal
        lda    $0400            ; Set current field width from @%
        sta    $14
L8DC1:
        ror    $15              ; Set hex/dec flag from Carry
L8DC3:
        jsr    L8A97            ; Get next non-space character
        cmp    #':'             ; End of statement if <colon> found
        beq    L8D7D
        cmp    #$0D             ; End if statement if <cr> found
        beq    L8D7D
        cmp    #tknELSE         ; End of statement if 'ELSE' found
        beq    L8D7D
L8DD2:
        cmp    #'~'             ; Jump back to set hex/dec flag from Carry
        beq    L8DC1
        cmp    #','             ; Jump to pad to next print field
        beq    L8DA6
        cmp    #';'             ; Jump to check for end of print statement
        beq    L8D83
        jsr    L8E70            ; Check for ' TAB SPC, if print token found return to outer main loop
        bcc    L8DC3

; All print formatting have been checked, so it now must be an expression
; -----------------------------------------------------------------------
        lda    $14              ; Save field width and flags, as evaluator
        pha                     ;  may call PRINT (eg FN, STR$, etc.)
        lda    $15
        pha
        dec    $1B              ; Evaluate expression
        jsr    L9B29
        pla                     ; Restore field width and flags
        sta    $15
        pla
        sta    $14
        lda    $1B              ; Update program pointer
        sta    $0A
        tya                     ; If type=0, jump to print string
        beq    L8E0E
        jsr    L9EDF            ; Convert numeric value to string
        lda    $14              ; Get current field width
        sec                     ; A=width-stringlength
        sbc    $36
        bcc    L8E0E            ; length>width - print it
        beq    L8E0E            ; length=width - print it
        tay
L8E08:
        jsr    LB565            ; Loop to print required spaces to pad the number
        dey
        bne    L8E08

; Print string in string buffer
; -----------------------------
L8E0E:
        lda    $36              ; Null string, jump back to main loop
        beq    L8DC3
        ldy    #$00             ; Point to start of string
L8E14:
        lda    $0600,y          ; Print character from string buffer
        jsr    LB558
        iny                     ; Increment pointer, loop for full string
        cpy    $36
        bne    L8E14
        beq    L8DC3            ; Jump back for next print item
L8E21:
        jmp    L8AA2
L8E24:
        cmp    #','             ; No comma, jump to TAB(x)
        bne    L8E21
        lda    $2A              ; Save X
        pha
        jsr    LAE56
        jsr    L92F0

; BBC - send VDU 31,x,y sequence
; ------------------------------
        lda    #$1F             ; TAB()
        jsr    OSWRCH
        pla                     ; X coord
        jsr    OSWRCH
        jsr    L9456            ; Y coord
        jmp    L8E6A            ; Continue to next PRINT item
L8E40:
        jsr    L92DD
        jsr    L8A8C
        cmp    #')'
        bne    L8E24
        lda    $2A
        sbc    $1E
        beq    L8E6A
        tay
        bcs    L8E5F
        jsr    LBC25
        beq    L8E5B
L8E58:
        jsr    L92E3
L8E5B:
        ldy    $2A
        beq    L8E6A
L8E5F:
        jsr    LB565
        dey
        bne    L8E5F
        beq    L8E6A
L8E67:
        jsr    LBC25
L8E6A:
        clc
        ldy    $1B
        sty    $0A
        rts
L8E70:
        ldx    $0B
        stx    $19
        ldx    $0C
        stx    $1A
        ldx    $0A
        stx    $1B
        cmp    #$27
        beq    L8E67
        cmp    #$8A
        beq    L8E40
        cmp    #$89
        beq    L8E58
        sec
L8E89:
        rts
L8E8A:
        jsr    L8A97            ; Skip spaces
        jsr    L8E70
        bcc    L8E89
        cmp    #$22
        beq    L8EA7
        sec
        rts
L8E98:
        brk
        .byte $09, "Missing ", '"'
        brk
L8EA4:
        jsr    LB558
L8EA7:
        iny
        lda    ($19),y
        cmp    #$0D
        beq    L8E98
        cmp    #$22
        bne    L8EA4
        iny
        sty    $1B
        lda    ($19),y
        cmp    #$22
        bne    L8E6A
        beq    L8EA4

; CLG
; ===
L8EBD:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
         jsr   L9857            ; Check end of statement
         lda   #$10             ; Jump to do VDU 16
         bne   L8ECC
.endif

; CLS
; ===
L8EC4:
        jsr    L9857            ; Check end of statement
        jsr    LBC28            ; Set COUNT to zero
        lda    #$0C             ; Do VDU 12
L8ECC:
        jsr    OSWRCH           ; Send A to OSWRCH, jump to execution loop
        jmp    L8B9B

; CALL numeric [,items ... ]
; ==========================
L8ED2:
        jsr    L9B1D
        jsr    L92EE
        jsr    LBD94
        ldy    #$00
        sty    $0600
L8EE0:
        sty    $06FF
        jsr    L8A8C
        cmp    #$2C
        bne    L8F0C
        ldy    $1B
        jsr    L95D5
        beq    L8F1B
        ldy    $06FF
        iny
        lda    $2A
        sta    $0600,y
        iny
        lda    $2B
        sta    $0600,y
        iny
        lda    $2C
        sta    $0600,y
        inc    $0600
        jmp    L8EE0
L8F0C:
        dec    $1B
        jsr    L9852
        jsr    LBDEA
        jsr    L8F1E
        cld
        jmp    L8B9B
L8F1B:
        jmp    LAE43

;Call code
;---------
L8F1E:
        lda    $040C            ; Get Carry from C%, A from A%
        lsr    a
        lda    $0404
        ldx    $0460            ; Get X from X%, Y from Y%
        ldy    $0464
        jmp    ($002A)          ; Jump to address in IntA
L8F2E:
        jmp    L982A

; DELETE linenum, linenum
; =======================
L8F31:
        jsr    L97DF
        bcc    L8F2E
        jsr    LBD94
        jsr    L8A97
        cmp    #$2C
        bne    L8F2E
        jsr    L97DF
        bcc    L8F2E
        jsr    L9857
        lda    $2A
        sta    $39
        lda    $2B
        sta    $3A
        jsr    LBDEA
L8F53:
        jsr    LBC2D
        jsr    L987B
        jsr    L9222
        lda    $39
        cmp    $2A
        lda    $3A
        sbc    $2B
        bcs    L8F53
        jmp    L8AF3
L8F69:
        lda    #$0A
        jsr    LAED8
        jsr    L97DF
        jsr    LBD94
        lda    #$0A
        jsr    LAED8
        jsr    L8A97
        cmp    #$2C
        bne    L8F8D
        jsr    L97DF
        lda    $2B
        bne    L8FDF
        lda    $2A
        beq    L8FDF
         inc    $0A
L8F8D:
         dec    $0A
         jmp    L9857
L8F92:
        lda    $12
        sta    $3B
        lda    $13
        sta    $3C
L8F9A:
        lda    $18
        sta    $38
        lda    #$01
        sta    $37
        rts

; RENUMBER [linenume [,linenum]]
; ==============================
L8FA3:
        jsr    L8F69
        ldx    #$39
        jsr    LBE0D
        jsr    LBE6F
        jsr    L8F92
L8FB1:
        ldy    #$00
        lda    ($37),y          ; Line.hi>&7F, end of program
        bmi    L8FE7
        sta    ($3B),y
        iny
        lda    ($37),y
        sta    ($3B),y
        sec
        tya
        adc    $3B
        sta    $3B
        tax
        lda    $3C
        adc    #$00
        sta    $3C
        cpx    $06
        sbc    $07
        bcs    L8FD6
        jsr    L909F
        bcc    L8FB1
L8FD6:
        brk
        .byte  $00, tknRENUMBER
        .byte  " space"         ; Terminated by following BRK
L8FDF:
        brk
        .byte  $00, "Silly"
        brk
L8FE7:
        jsr    L8F9A
L8FEA:
        ldy    #$00
        lda    ($37),y
        bmi    L900D
        lda    $3A
        sta    ($37),y
        lda    $39
        iny
        sta    ($37),y
        clc
        lda    $2A
        adc    $39
        sta    $39
        lda    #$00
        adc    $3A
        and    #$7F
        sta    $3A
        jsr    L909F
        bcc    L8FEA
L900D:
        lda    $18
        sta    $0C
        ldy    #$00
        sty    $0B
        iny
        lda    ($0B),y
        bmi    L903A
L901A:
        ldy    #$04
L901C:
        lda    ($0B),y
        cmp    #$8D
        beq    L903D
        iny
        cmp    #$0D
        bne    L901C
        lda    ($0B),y
        bmi    L903A
        ldy    #$03
        lda    ($0B),y
        clc
        adc    $0B
        sta    $0B
        bcc    L901A
        inc    $0C
        bcs    L901A
L903A:
        jmp    L8AF3
L903D:
        jsr    L97EB
        jsr    L8F92
L9043:
        ldy    #$00
        lda    ($37),y
        bmi    L9080
        lda    ($3B),y
        iny
        cmp    $2B
        bne    L9071
        lda    ($3B),y
        cmp    $2A
        bne    L9071
        lda    ($37),y
        sta    $3D
        dey
        lda    ($37),y
        sta    $3E
        ldy    $0A
        dey
        lda    $0B
        sta    $37
        lda    $0C
        sta    $38
        jsr    L88F5
L906D:
        ldy    $0A
        bne    L901C
L9071:
        jsr    L909F
        lda    $3B
        adc    #$02
        sta    $3B
        bcc    L9043
        inc    $3C
        bcs    L9043
L9080:
L9082:
        jsr    LBFCF            ; Print inline text
        .byte  "Failed at "
        iny
        lda    ($0B),y
        sta    $2B
        iny
        lda    ($0B),y
        sta    $2A
        jsr    L991F            ; Print in decimal
        jsr    LBC25            ; Print newline
        beq    L906D
L909F:
        iny
        lda    ($37),y
        adc    $37
        sta    $37
        bcc    L90AB
        inc    $38
        clc
L90AB:
        rts

; AUTO [numeric [, numeric ]]
; ===========================
L90AC:
        jsr    L8F69
        lda    $2A
        pha
        jsr    LBDEA
L90B5:
        jsr    LBD94
        jsr    L9923
        lda    #$20
        jsr    LBC02
        jsr    LBDEA
        jsr    L8951
        jsr    LBC8D
        jsr    LBD20
        pla
        pha
        clc
        adc    $2A
        sta    $2A
        bcc    L90B5
        inc    $2B
        bpl    L90B5
L90D9:
        jmp    L8AF3
L90DC:
        jmp    L9218
L90DF:
        dec    $0A
        jsr    L9582
        beq    L9127
        bcs    L9127
        jsr    LBD94
        jsr    L92DD
        jsr    L9222
        lda    $2D
        ora    $2C
        bne    L9127
        clc
        lda    $2A
        adc    $02
        tay
        lda    $2B
        adc    $03
        tax
        cpy    $04
        sbc    $05
        bcs    L90DC
        lda    $02
        sta    $2A
        lda    $03
        sta    $2B
        sty    $02
        stx    $03
        lda    #$00
        sta    $2C
        sta    $2D
        lda    #$40
        sta    $27
        jsr    LB4B4
        jsr    L8827
        jmp    L920B
L9127:
        brk
        .byte  10, "Bad ", tknDIM
        brk

; DIM numvar [numeric] [(arraydef)]
; =================================
L912F:
        jsr    L8A97
        tya
        clc
        adc    $0B
        ldx    $0C
        bcc    L913C
        inx
        clc
L913C:
        sbc    #$00
        sta    $37
        txa
        sbc    #$00
        sta    $38
        ldx    #$05
        stx    $3F
        ldx    $0A
        jsr    L9559
        cpy    #$01
        beq    L9127
        cmp    #'('
        beq    L916B
        cmp    #$24
        beq    L915E
        cmp    #$25
        bne    L9168
L915E:
        dec    $3F
        iny
        inx
        lda    ($37),y
        cmp    #'('
        beq    L916B
L9168:
        jmp    L90DF
L916B:
        sty    $39
        stx    $0A
        jsr    L9469
        bne    L9127
        jsr    L94FC
        ldx    #$01
        jsr    L9531
        lda    $3F
        pha
        lda    #$01
        pha
        jsr    LAED8
L9185:
        jsr    LBD94
        jsr    L8821
        lda    $2B
        and    #$C0
        ora    $2C
        ora    $2D
        bne    L9127
        jsr    L9222
        pla
        tay
        lda    $2A
        sta    ($02),y
        iny
        lda    $2B
        sta    ($02),y
        iny
        tya
        pha
        jsr    L9231
        jsr    L8A97
        cmp    #$2C
        beq    L9185
        cmp    #')'
        beq    L91B7
        jmp    L9127
L91B7:
        pla
        sta    $15
        pla
        sta    $3F
        lda    #$00
        sta    $40
        jsr    L9236
        ldy    #$00
        lda    $15
        sta    ($02),y
        adc    $2A
        sta    $2A
        bcc    L91D2
        inc    $2B
L91D2:
        lda    $03
        sta    $38
        lda    $02
        sta    $37
        clc
        adc    $2A
        tay
        lda    $2B
        adc    $03
        bcs    L9218
        tax
        cpy    $04
        sbc    $05
        bcs    L9218
        sty    $02
        stx    $03
        lda    $37
        adc    $15
        tay
        lda    #$00
        sta    $37
        bcc    L91FC
        inc    $38
L91FC:
        sta    ($37),y
        iny
        bne    L9203
        inc    $38
L9203:
        cpy    $02
        bne    L91FC
        cpx    $38
        bne    L91FC
L920B:
        jsr    L8A97
        cmp    #$2C
        beq    L9215
        jmp    L8B96
L9215:
        jmp    L912F
L9218:
        brk
        .byte  11, tknDIM, " space"
        brk
L9222:
        inc    $2A
        bne    L9230
        inc    $2B
        bne    L9230
        inc    $2C
        bne    L9230
        inc    $2D
L9230:
        rts
L9231:
        ldx    #$3F
        jsr    LBE0D
L9236:
        ldx    #$00
        ldy    #$00
L923A:
        lsr    $40
        ror    $3F
        bcc    L924B
        clc
        tya
        adc    $2A
        tay
        txa
        adc    $2B
        tax
        bcs    L925A
L924B:
        asl    $2A
        rol    $2B
        lda    $3F
        ora    $40
        bne    L923A
        sty    $2A
        stx    $2B
        rts
L925A:
        jmp    L9127

; HIMEM=numeric
; =============
L925D:
        jsr    L92EB            ; Set past '=', evaluate integer
        lda    $2A              ; Set HIMEM and STACK
        sta    $06
        sta    $04
        lda    $2B
        sta    $07
        sta    $05
        jmp    L8B9B            ; Jump back to execution loop

; LOMEM=numeric
; =============
L926F:
        jsr    L92EB            ; Step past '=', evaluate integer
        lda    $2A              ; Set LOMEM and VAREND
        sta    $00
        sta    $02
        lda    $2B
        sta    $01
        sta    $03
        jsr    LBD2F            ; Clear dynamic variables, jump to execution loop
        beq    L928A

; PAGE=numeric
; ============
L9283:
        jsr    L92EB            ; Step past '=', evaluate integer
        lda    $2B              ; Set PAGE
        sta    $18
L928A:
        jmp    L8B9B            ; Jump to execution loop

; CLEAR
; =====
L928D:
        jsr    L9857            ; Check end of statement
        jsr    LBD20            ; Clear heap, stack, data, variables
        beq    L928A            ; Jump to execution loop

; TRACE ON | OFF | numeric
; ========================
L9295:
        jsr    L97DF            ; If line number, jump for TRACE linenum
        bcs    L92A5
        cmp    #$EE             ; Jump for TRACE ON
        beq    L92B7
        cmp    #$87             ; Jump for TRACE OFF
        beq    L92C0
        jsr    L8821            ; Evaluate integer

; TRACE numeric
; -------------
L92A5:
        jsr    L9857            ; Check end of statement
        lda    $2A              ; Set trace limit low byte
        sta    $21
        lda    $2B
L92AE:
        sta    $22              ; Set trace limit high byte, set TRACE ON
        lda    #$FF
L92B2:
        sta    $20              ; Set TRACE flag, return to execution loop
        jmp    L8B9B

; TRACE ON
; --------
L92B7:
        inc    $0A              ; Step past, check end of statement
        jsr    L9857
        lda    #$FF             ; Jump to set TRACE &FFxx
        bne    L92AE

; TRACE OFF
; ---------
L92C0:
        inc    $0A              ; Step past, check end of statement
        jsr    L9857
        lda    #$00             ; Jump to set TRACE OFF
        beq    L92B2

; TIME=numeric
; ============
L92C9:
        jsr    L92EB            ; Step past '=', evaluate integer
        ldx    #$2A             ; Point to integer, set 5th byte to 0
        ldy    #$00
        sty    $2E
        lda    #$02             ; Call OSWORD &02 to do TIME=
        jsr    OSWORD
        jmp    L8B9B

; Evaluate <comma><numeric>
; =========================
L92DA:
        jsr    L8AAE            ; Check for and step past comma
L92DD:
        jsr    L9B29
        jmp    L92F0
L92E3:
        jsr    LADEC
        beq    L92F7
        bmi    L92F4
L92EA:
        rts

; Evaluate <equals><integer>
; ==========================
L92EB:
        jsr    L9807            ; Check for equals, evaluate numeric
L92EE:
        lda    $27              ; Get result type
L92F0:
        beq    L92F7            ; String, jump to 'Type mismatch'
        bpl    L92EA            ; Integer, return
L92F4:
        jmp    LA3E4            ; Real, jump to convert to integer
L92F7:
        jmp    L8C0E            ; Jump to 'Type mismatch' error

; Evaluate <real>
; ===============
L92FA:
        jsr    LADEC            ; Evaluate expression

; Ensure value is real
; --------------------
L92FD:
        beq    L92F7            ; String, jump to 'Type mismatch'
        bmi    L92EA            ; Real, return
        jmp    LA2BE            ; Integer, jump to convert to real

; PROCname [(parameters)]
; =======================
L9304:
        lda    $0B              ; PtrB=PtrA=>after 'PROC' token
        sta    $19
        lda    $0C
        sta    $1A
        lda    $0A
        sta    $1B
        lda    #$F2             ; Call PROC/FN dispatcher
        jsr    LB197            ; Will return here after ENDPROC
        jsr    L9852            ; Check for end of statement
        jmp    L8B9B            ; Return to execution loop

; Make string zero length
; -----------------------
L931B:
        ldy    #$03             ; Set length to zero
        lda    #$00
        sta    ($2A),y          ; Jump to look for next LOCAL item
        beq    L9341

; LOCAL variable [,variable ...]
; ==============================
L9323:
        tsx                     ; Not inside subroutine, error
        cpx    #$FC
        bcs    L936B
        jsr    L9582            ; Find variable, jump if bad variable name
        beq    L9353
        jsr    LB30D            ; Push value on stack, push variable info on stack
        ldy    $2C              ; If a string, jump to make zero length
        bmi    L931B
        jsr    LBD94
        lda    #$00             ; Set IntA to zero
        jsr    LAED8
        sta    $27              ; Set current variable to IntA (zero)
        jsr    LB4B4

; Next LOCAL item
; ---------------
L9341:
        tsx                     ; Increment number of LOCAL items
        inc    $0106,x
        ldy    $1B              ; Update line pointer
        sty    $0A
        jsr    L8A97            ; Get next character
        cmp    #$2C             ; Comma, loop back to do another item
        beq    L9323
        jmp    L8B96            ; Jump to main execution loop
L9353:
        jmp    L8B98

; ENDPROC
; =======
; Stack needs to contain these items,
;  ret_lo, ret_hi, PtrB_hi, PtrB_lo, PtrB_off, numparams, PtrA_hi, PtrA_lo, PtrA_off, tknPROC
L9356:
        tsx                     ; If stack empty, jump to give error
        cpx    #$FC
        bcs    L9365
        lda    $01FF            ; If pushed token<>'PROC', give error
        cmp    #$F2
        bne    L9365
        jmp    L9857            ; Check for end of statement and return to pop from subroutine
L9365:
        brk
        .byte  13, "No ", tknPROC ; Terminated by following BRK
L936B:
        brk
        .byte  12, "Not ", tknLOCAL ; Terminated by following BRK
L9372:
        brk
        .byte  $19, "Bad ", tknMODE
        brk

; GCOL numeric, numeric
; =====================
L937A:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    L8821            ; Evaluate integer
        lda    $2A
        pha
        jsr    L92DA            ; Step past comma, evaluate integer
        jsr    L9852            ; Update program pointer, check for end of statement
        lda    #$12             ; Send VDU 18 for GCOL
        jsr    OSWRCH
        jmp    L93DA            ; Jump to send two bytes to OSWRCH
.endif

; COLOUR numeric
; ==============
L938E:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        lda    #$11             ; Stack VDU 17 for COLOUR
        pha
        jsr    L8821            ; Evaluate integer, check end of statement
        jsr    L9857
        jmp    L93DA            ; Jump to send two bytes to OSWRCH
.endif

; MODE numeric
; ============
L939A:
        lda    #$16             ; Stack VDU 22 for MODE
        pha
        jsr    L8821            ; Evaluate integer, check end of statement
        jsr    L9857

; BBC - Check if changing MODE will move screen into stack
; --------------------------------------------------------
        jsr    LBEE7            ; Get machine address high word
        cpx    #$FF             ; Not &xxFFxxxx, skip memory test
        bne    L93D7
        cpy    #$FF             ; Not &FFFFxxxx, skip memory test
        bne    L93D7

; MODE change in I/O processor, must check memory limits

        lda    $04              ; STACK<>HIMEM, stack not empty, give 'Bad MODE' error
        cmp    $06
        bne    L9372
        lda    $05
        cmp    $07
        bne    L9372
        ldx    $2A              ; Get top of memory if we used this MODE
        lda    #$85
        jsr    OSBYTE
        cpx    $02              ; Would be below VAREND, give error
        tya
        sbc    $03
        bcc    L9372
        cpx    $12              ; Would be below TOP, give error
        tya
        sbc    $13
        bcc    L9372

; BASIC stack is empty, screen would not hit heap or program

        stx    $06              ; Set STACK and HIMEM to new address
        stx    $04
        sty    $07
        sty    $05

; Change MODE
L93D7:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    LBC28            ; Set COUNT to zero

; Send two bytes to OSWRCH, stacked byte, then IntA
; -------------------------------------------------
L93DA:
        pla                     ; Send stacked byte to OSWRCH
        jsr    OSWRCH
        jsr    L9456            ; Send IntA to OSWRCH, jump to execution loop
        jmp    L8B9B
.endif

; MOVE numeric, numeric
; =====================
L93E4:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        lda    #$04             ; Jump forward to do PLOT 4 for MOVE
        bne    L93EA
.endif

; DRAW numeric, numeric
; =====================
L93E8:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        lda    #$05             ; Do PLOT 5 for DRAW
L93EA:
        pha                     ; Evaluate first expression
        jsr    L9B1D
        jmp    L93FD            ; Jump to evaluate second expression and send to OSWRCH
.endif

; PLOT numeric, numeric, numeric
; ==============================
L93F1:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    L8821            ; Evaluate integer
        lda    $2A
        pha
        jsr    L8AAE            ; Step past comma, evaluate expression
        jsr    L9B29
L93FD:
        jsr    L92EE            ; Confirm numeric and ensure is integer
        jsr    LBD94            ; Stack integer
        jsr    L92DA            ; Step past command and evaluate integer
        jsr    L9852            ; Update program pointer, check for end of statement
        lda    #$19             ; Send VDU 25 for PLOT
        jsr    OSWRCH
        pla                     ; Send PLOT action
        jsr    OSWRCH
        jsr    LBE0B            ; Pop integer to temporary store at &37/8
        lda    $37              ; Send first coordinate to OSWRCH
        jsr    OSWRCH
        lda    $38
        jsr    OSWRCH
        jsr    L9456            ; Send IntA to OSWRCH, second coordinate
        lda    $2B              ; Send IntA high byte to OSWRCH
        jsr    OSWRCH
        jmp    L8B9B            ; Jump to execution loop
.endif
L942A:
        lda    $2B              ; Send IntA byte 2 to OSWRCH
        jsr    OSWRCH

; VDU num[,][;][...]
; ==================
L942F:
        jsr    L8A97            ; Get next character
L9432:
        cmp    #$3A             ; If end of statement, jump to exit
        beq    L9453
        cmp    #$0D
        beq    L9453
        cmp    #$8B
        beq    L9453
        dec    $0A              ; Step back to current character
        jsr    L8821            ; Evaluate integer and output low byte
        jsr    L9456
        jsr    L8A97            ; Get next character
        cmp    #','             ; Comma, loop to read another number
        beq    L942F
        cmp    #';'             ; Not semicolon, loop to check for end of statement
        bne    L9432
        beq    L942A            ; Loop to output high byte and read another
L9453:
        jmp    L8B96            ; Jump to execution loop

; Send IntA to OSWRCH via WRCHV
; =============================
L9456:
        lda    $2A
        jmp    (WRCHV)

; VARIABLE PROCESSING
; ===================
; Look for a FN/PROC in heap
; --------------------------
; On entry, (&37)+1=>FN/PROC token (ie, first character of name)
;
L945B:
        ldy    #$01             ; Get PROC/FN character
        lda    ($37),y
        ldy    #$F6             ; Get PROC/FN character
        cmp    #tknPROC         ; If PROC, jump to scan list
        beq    L946F
        ldy    #$F8             ; Point to FN list start and scan list
        bne    L946F

; Look for a variable in the heap
; -------------------------------
; On entry, (&37)+1=>first character of name
;
L9469:
        ldy    #$01             ; Get first character of variable
        lda    ($37),y
        asl    a                ; Double it to index into index list
        tay

; Scan though linked lists in heap
; --------------------------------
L946F:
        lda    $0400,y          ; Get start of linked list
        sta    $3A
        lda    $0401,y
        sta    $3B
L9479:
        lda    $3B              ; End of list
        beq    L94B2
        ldy    #$00
        lda    ($3A),y
        sta    $3C
        iny
        lda    ($3A),y
        sta    $3D
        iny                     ; Jump if not null name
        lda    ($3A),y
        bne    L949A
        dey
        cpy    $39
        bne    L94B3
        iny
        bcs    L94A7
L9495:
        iny
        lda    ($3A),y
        beq    L94B3
L949A:
        cmp    ($37),y
        bne    L94B3
        cpy    $39
        bne    L9495
        iny
        lda    ($3A),y
        bne    L94B3
L94A7:
        tya
        adc    $3A
        sta    $2A
        lda    $3B
        adc    #$00
        sta    $2B
L94B2:
        rts
L94B3:
        lda    $3D
        beq    L94B2
        ldy    #$00
        lda    ($3C),y
        sta    $3A
        iny
        lda    ($3C),y
        sta    $3B
        iny
        lda    ($3C),y
        bne    L94D4
        dey
        cpy    $39
        bne    L9479
        iny
        bcs    L94E1
L94CF:
        iny
        lda    ($3C),y
        beq    L9479
L94D4:
        cmp    ($37),y
        bne    L9479
        cpy    $39
        bne    L94CF
        iny
        lda    ($3C),y
        bne    L9479
L94E1:
        tya
        adc    $3C
        sta    $2A
        lda    $3D
        adc    #$00
        sta    $2B
        rts
L94ED:
        ldy    #$01
        lda    ($37),y
        tax
        lda    #$F6
        cpx    #$F2
        beq    L9501
        lda    #$F8
        bne    L9501
L94FC:
        ldy    #$01
        lda    ($37),y
        asl    a
L9501:
        sta    $3A
        lda    #$04
        sta    $3B
L9507:
        lda    ($3A),y
        beq    L9516
        tax
        dey
        lda    ($3A),y
        sta    $3A
        stx    $3B
        iny
        bpl    L9507
L9516:
        lda    $03
        sta    ($3A),y
        lda    $02
        dey
        sta    ($3A),y
        tya
        iny
        sta    ($02),y
        cpy    $39
        beq    L9558
L9527:
        iny
        lda    ($37),y
        sta    ($02),y
        cpy    $39
        bne    L9527
        rts
L9531:
        lda    #$00
L9533:
        iny
        sta    ($02),y
        dex
        bne    L9533
L9539:
        sec
        tya
        adc    $02
        bcc    L9541
        inc    $03
L9541:
        ldy    $03
        cpy    $05
        bcc    L9556
        bne    L954D
        cmp    $04
        bcc    L9556
L954D:
        lda    #$00
        ldy    #$01
        sta    ($3A),y
        jmp    L8CB7
L9556:
        sta    $02
L9558:
        rts

; Check if variable name is valid
; ===============================
L9559:
        ldy    #$01
L955B:
        lda    ($37),y
        cmp    #$30
        bcc    L9579
        cmp    #$40
        bcs    L9571
        cmp    #$3A
        bcs    L9579
        cpy    #$01
        beq    L9579
L956D:
        inx
        iny
        bne    L955B
L9571:
        cmp    #$5F
        bcs    L957A
        cmp    #$5B
        bcc    L956D
L9579:
        rts
L957A:
        cmp    #$7B
        bcc    L956D
        rts
L957F:
        jsr    L9531
L9582:
        jsr    L95C9
        bne    L95A4
        bcs    L95A4
        jsr    L94FC
        ldx    #$05
        cpx    $2C
        bne    L957F
        inx
        bne    L957F
L9595:
        cmp    #$21
        beq    L95A5
        cmp    #$24
        beq    L95B0
        eor    #$3F
        beq    L95A7
        lda    #$00
        sec
L95A4:
        rts
L95A5:
        lda    #$04
L95A7:
        pha
        inc    $1B
        jsr    L92E3
        jmp    L969F
L95B0:
        inc    $1B
        jsr    L92E3
        lda    $2B
        beq    L95BF
        lda    #$80
        sta    $2C
        sec
        rts
L95BF:
        brk
        .byte  8, "$ range"
        brk
L95C9:
        lda    $0B
        sta    $19
        lda    $0C
        sta    $1A
        ldy    $0A
        dey
L95D4:
        iny
L95D5:
        sty    $1B
        lda    ($19),y
        cmp    #$20
        beq    L95D4
L95DD:
        cmp    #$40
        bcc    L9595
        cmp    #$5B
        bcs    L95FF
        asl    a
        asl    a
        sta    $2A
        lda    #$04
        sta    $2B
        iny
        lda    ($19),y
        iny
        cmp    #$25
        bne    L95FF
        ldx    #$04
        stx    $2C
        lda    ($19),y
        cmp    #'('
        bne    L9665
L95FF:
        ldx    #$05
        stx    $2C
        lda    $1B
        clc
        adc    $19
        ldx    $1A
        bcc    L960E
        inx
        clc
L960E:
        sbc    #$00
        sta    $37
        bcs    L9615
        dex
L9615:
        stx    $38
        ldx    $1B
        ldy    #$01
L961B:
        lda    ($37),y
        cmp    #$41
        bcs    L962D
        cmp    #$30
        bcc    L9641
        cmp    #$3A
        bcs    L9641
        inx
        iny
        bne    L961B
L962D:
        cmp    #$5B
        bcs    L9635
        inx
        iny
        bne    L961B
L9635:
        cmp    #$5F
        bcc    L9641
        cmp    #$7B
        bcs    L9641
        inx
        iny
        bne    L961B
L9641:
        dey
        beq    L9673
        cmp    #$24
        beq    L96AF
        cmp    #$25
        bne    L9654
        dec    $2C
        iny
        inx
        iny
        lda    ($37),y
        dey
L9654:
        sty    $39
        cmp    #'('
        beq    L96A6
        jsr    L9469
        beq    L9677
        stx    $1B
L9661:
        ldy    $1B
        lda    ($19),y
L9665:
        cmp    #$21
        beq    L967F
        cmp    #$3F
        beq    L967B
        clc
        sty    $1B
        lda    #$FF
        rts
L9673:
        lda    #$00
        sec
        rts
 L9677:
        lda    #$00
        clc
        rts
L967B:
        lda    #$00
        beq    L9681
L967F:
        lda    #$04
L9681:
        pha
        iny
        sty    $1B
        jsr    LB32C
        jsr    L92F0
        lda    $2B
        pha
        lda    $2A
        pha
        jsr    L92E3
        clc
        pla
        adc    $2A
        sta    $2A
        pla
        adc    $2B
        sta    $2B
L969F:
        pla
        sta    $2C
        clc
        lda    #$FF
        rts
L96A6:
        inx
        inc    $39
        jsr    L96DF
        jmp    L9661
L96AF:
        inx
        iny
        sty    $39
        iny
        dec    $2C
        lda    ($37),y
        cmp    #'('
        beq    L96C9
        jsr    L9469
        beq    L9677
        stx    $1B
        lda    #$81
        sta    $2C
        sec
        rts
L96C9:
        inx
        sty    $39
        dec    $2C
        jsr    L96DF
        lda    #$81
        sta    $2C
        sec
        rts
L96D7:
        brk
        .byte   14, "Array"
        brk
L96DF:
        jsr    L9469
        beq    L96D7
        stx    $1B
        lda    $2C
        pha
        lda    $2A
        pha
        lda    $2B
        pha
        ldy    #$00
        lda    ($2A),y
        cmp    #$04
        bcc    L976C
        tya
        jsr    LAED8
        lda    #$01
        sta    $2D
L96FF:
        jsr    LBD94
        jsr    L92DD
        inc    $1B
        cpx    #$2C
        bne    L96D7
        ldx    #$39
        jsr    LBE0D
        ldy    $3C
        pla
        sta    $38
        pla
        sta    $37
        pha
        lda    $38
        pha
        jsr    L97BA
        sty    $2D
        lda    ($37),y
        sta    $3F
        iny
        lda    ($37),y
        sta    $40
        lda    $2A
        adc    $39
        sta    $2A
        lda    $2B
        adc    $3A
        sta    $2B
        jsr    L9236
        ldy    #$00
        sec
        lda    ($37),y
        sbc    $2D
        cmp    #$03
        bcs    L96FF
        jsr    LBD94
        jsr    LAE56
        jsr    L92F0
        pla
        sta    $38
        pla
        sta    $37
        ldx    #$39
        jsr    LBE0D
        ldy    $3C
        jsr    L97BA
        clc
        lda    $39
        adc    $2A
        sta    $2A
        lda    $3A
        adc    $2B
        sta    $2B
        bcc    L977D
L976C:
        jsr    LAE56
        jsr    L92F0
        pla
        sta    $38
        pla
        sta    $37
        ldy    #$01
        jsr    L97BA
L977D:
        pla
        sta    $2C
        cmp    #$05
        bne    L979B
        ldx    $2B
        lda    $2A
        asl    $2A
        rol    $2B
        asl    $2A
        rol    $2B
        adc    $2A
        sta    $2A
        txa
        adc    $2B
        sta    $2B
        bcc    L97A3
L979B:
        asl    $2A
        rol    $2B
        asl    $2A
        rol    $2B
L97A3:
        tya
        adc    $2A
        sta    $2A
        bcc    L97AD
        inc    $2B
        clc
L97AD:
        lda    $37
        adc    $2A
        sta    $2A
        lda    $38
        adc    $2B
        sta    $2B
        rts
L97BA:
        lda    $2B
        and    #$C0
        ora    $2C
        ora    $2D
        bne    L97D1
        lda    $2A
        cmp    ($37),y
        iny
        lda    $2B
        sbc    ($37),y
        bcs    L97D1
        iny
        rts
L97D1:
        brk
        .byte   15, "Subscript"
        brk
L97DD:
        inc    $0A
L97DF:
        ldy    $0A
        lda    ($0B),y
        cmp    #$20
        beq    L97DD
        cmp    #$8D
        bne    L9805
L97EB:
        iny
        lda    ($0B),y
        asl    a
        asl    a
        tax
        and    #$C0
        iny
        eor    ($0B),y
        sta    $2A
        txa
        asl    a
        asl    a
        iny
        eor    ($0B),y
        sta    $2B
        iny
        sty    $0A
        sec
        rts
        L9805:
        clc
        rts
L9807:
        lda    $0B
        sta    $19
        lda    $0C
        sta    $1A
        lda    $0A
        sta    $1B
L9813:
        ldy    $1B
        inc    $1B
        lda    ($19),y
        cmp    #$20
        beq    L9813
        cmp    #$3D
        beq    L9849
L9821:
        brk
        .byte   4, "Mistake"
L982A:
        brk
        .byte   16, "Syntax error"

; Escape error
; ------------
L9838:
        brk
        .byte   17, "Escape"
        brk
L9841:
        jsr    L8A8C
        cmp    #'='
        bne    L9821
        rts
L9849:
        jsr    L9B29
L984C:
        txa
        ldy    $1B
        jmp    L9861
L9852:
        ldy    $1B
        jmp    L9859

; Check for end of statement, check for Escape
; ============================================
L9857:
        ldy    $0A              ; Get program pointer offset
L9859:
        dey                     ; Step back to previous character
L985A:
        iny                     ; Get next character
        lda    ($0B),y
        cmp    #' '             ; Skip spaces
        beq    L985A
L9861:
        cmp    #':'             ; Colon, jump to update program pointer
        beq    L986D
        cmp    #$0D             ; <cr>, jump to update program pointer
        beq    L986D
        cmp    #tknELSE         ; Not 'ELSE', jump to 'Syntax error'
        bne    L982A

; Update program pointer
; ----------------------
L986D:
        clc                     ; Update program pointer in PtrA
        tya
        adc    $0B
        sta    $0B
        bcc    L9877
        inc    $0C
L9877:
        ldy    #$01
        sty    $0A

; Check background Escape state
; -----------------------------
L987B:

; BBC - check background Escape state
; -----------------------------------
        bit    ESCFLG           ; If Escape set, jump to give error
        bmi    L9838
L987F:
        rts
L9880:
        jsr    L9857
        dey
        lda    ($0B),y
        cmp    #$3A
        beq    L987F
        lda    $0C
        cmp    #$07
        beq    L98BC
L9890:
        iny
        lda    ($0B),y
        bmi    L98BC
        lda    $20
        beq    L98AC
        tya
        pha
        iny
        lda    ($0B),y
        pha
        dey
        lda    ($0B),y
        tay
        pla
        jsr    LAEEA
        jsr    L9905
        pla
        tay
L98AC:
        iny
        sec
        tya
        adc    $0B
        sta    $0B
        bcc    L98B7
        inc    $0C
L98B7:
        ldy    #$01
        sty    $0A
L98BB:
        rts
L98BC:
        jmp    L8AF6
L98BF:
        jmp    L8C0E

; IF numeric
; ==========
L98C2:
        jsr    L9B1D
        beq    L98BF
        bpl    L98CC
        jsr    LA3E4
L98CC:
        ldy    $1B
        sty    $0A
        lda    $2A
        ora    $2B
        ora    $2C
        ora    $2D
        beq    L98F1
        cpx    #$8C
        beq    L98E1
L98DE:
        jmp    L8BA3
L98E1:
        inc    $0A
L98E3:
        jsr    L97DF
        bcc    L98DE
        jsr    LB9AF
        jsr    L9877
        jmp    LB8D2
L98F1:
        ldy    $0A
L98F3:
        lda    ($0B),y
        cmp    #$0D
        beq    L9902
        iny
        cmp    #$8B
        bne    L98F3
        sty    $0A
        beq    L98E3
L9902:
        jmp    L8B87
L9905:
        lda    $2A
        cmp    $21
        lda    $2B
        sbc    $22
        bcs    L98BB
        lda    #$5B
L9911:
        jsr    LB558
        jsr    L991F
        lda    #$5D
        jsr    LB558
        jmp    LB565

;Print 16-bit decimal number
;===========================
L991F:
        lda    #$00             ; No padding
        beq    L9925
L9923:
        lda    #$05             ; Pad to five characters
L9925:
        sta    $14
        ldx    #$04
L9929:
        lda    #$00
        sta    $3F,x
        sec
L992E:
        lda    $2A
        sbc    L996B,x          ; Subtract 10s low byte
        tay
        lda    $2B
        sbc    L99B9,x          ; Subtract 10s high byte
        bcc    L9943            ; Result<0, no more for this digit
        sta    $2B              ; Update number
        sty    $2A
        inc    $3F,x
        bne    L992E
L9943:
        dex
        bpl    L9929
        ldx    #$05
L9948:
        dex
        beq    L994F
        lda    $3F,x
        beq    L9948
L994F:
        stx    $37
        lda    $14
        beq    L9960
        sbc    $37
        beq    L9960
        tay
L995A:
        jsr    LB565
        dey
        bne    L995A
L9960:
        lda    $3F,x
        ora    #$30
        jsr    LB558
        dex
        bpl    L9960
         rts

; Low bytes of powers of ten
L996B:
        .byte   1, 10, 100, $E8, $10

; Line Search
L9970:
        ldy    #$00
        sty    $3D
        lda    $18
        sta    $3E
L9978:
        ldy    #$01
        lda    ($3D),y
        cmp    $2B
        bcs    L998E
L9980:
        ldy    #$03
        lda    ($3D),y
        adc    $3D
        sta    $3D
        bcc    L9978
        inc    $3E
        bcs    L9978
L998E:
        bne    L99A4
        ldy    #$02
        lda    ($3D),y
        cmp    $2A
        bcc    L9980
        bne    L99A4
        tya
        adc    $3D
        sta    $3D
        bcc    L99A4
        inc    $3E
        clc
L99A4:
        ldy    #$02
        rts

L99A7:
        brk
        .byte  $12, "Division by zero"

; High byte of powers of ten
L99B9:
        brk
        brk
        brk
        .byte  $03
        .byte  $27

L99BE:
        tay
        jsr    L92F0
        lda    $2D
        pha
        jsr    LAD71
        jsr    L9E1D
        stx    $27
        tay
        jsr    L92F0
        pla
        sta    $38
        eor    $2D
        sta    $37
        jsr    LAD71
        ldx    #$39
        jsr    LBE0D
        sty    $3D
        sty    $3E
        sty    $3F
        sty    $40
        lda    $2D
        ora    $2A
        ora    $2B
        ora    $2C
        beq    L99A7
        ldy    #$20
L99F4:
        dey
        beq    L9A38
        asl    $39
        rol    $3A
        rol    $3B
        rol    $3C
        bpl    L99F4
L9A01:
        rol    $39
        rol    $3A
        rol    $3B
        rol    $3C
        rol    $3D
        rol    $3E
        rol    $3F
        rol    $40
        sec
        lda    $3D
        sbc    $2A
        pha
        lda    $3E
        sbc    $2B
        pha
        lda    $3F
        sbc    $2C
        tax
        lda    $40
        sbc    $2D
        bcc    L9A33
        sta    $40
        stx    $3F
        pla
        sta    $3E
        pla
        sta    $3D
        bcs    L9A35
L9A33:
        pla
        pla
L9A35:
        dey
        bne    L9A01
L9A38:
        rts

L9A39:
        stx    $27
        jsr    LBDEA
        jsr    LBD51
        jsr    LA2BE
        jsr    LA21E
        jsr    LBD7E
        jsr    LA3B5
        jmp    L9A62
L9A50:
        jsr    LBD51
        jsr    L9C42
        stx    $27
        tay
        jsr    L92FD
        jsr    LBD7E
L9A5F:
        jsr    LA34E

; Compare FPA = FPB
; -----------------
L9A62:
        ldx    $27
        ldy    #$00
        lda    $3B
        and    #$80
        sta    $3B
        lda    $2E
        and    #$80
        cmp    $3B
        bne    L9A92
        lda    $3D
        cmp    $30
        bne    L9A93
        lda    $3E
        cmp    $31
        bne    L9A93
        lda    $3F
        cmp    $32
        bne    L9A93
        lda    $40
        cmp    $33
        bne    L9A93
        lda    $41
        cmp    $34
        bne    L9A93
L9A92:
        rts

L9A93:
        ror    a
        eor    $3B
        rol    a
        lda    #$01
        rts

L9A9A:
        jmp    L8C0E            ; Jump to 'Type mismatch' error

; Evaluate next expression and compare with previous
; --------------------------------------------------
L9A9D:
        txa
L9A9E:
        beq    L9AE7            ; Jump if current is string
        bmi    L9A50            ; Jump if current is float
        jsr    LBD94            ; Stack integer
        jsr    L9C42            ; Evaluate next expression
        tay
        beq    L9A9A            ; Error if string
        bmi    L9A39            ; Float, jump to compare floats

; Compare IntA with top of stack
; ------------------------------
        lda    $2D
        eor    #$80
        sta    $2D
        sec
        ldy    #$00
        lda    ($04),y
        sbc    $2A
        sta    $2A
        iny
        lda    ($04),y
        sbc    $2B
        sta    $2B
        iny
        lda    ($04),y
        sbc    $2C
        sta    $2C
        iny
        lda    ($04),y
        ldy    #$00
        eor    #$80
        sbc    $2D
        ora    $2A
        ora    $2B
        ora    $2C
        php                     ; Drop integer from stack
        clc
        lda    #$04
        adc    $04
        sta    $04
        bcc    L9AE5
        inc    $05
L9AE5:
        plp
        rts

; Compare string with next expression
; -----------------------------------
L9AE7:
        jsr    LBDB2
        jsr    L9C42
        tay
        bne    L9A9A
        stx    $37
        ldx    $36
        ldy    #$00
        lda    ($04),y
        sta    $39
        cmp    $36
        bcs    L9AFF
        tax
L9AFF:
        stx    $3A
        ldy    #$00
L9B03:
        cpy    $3A
        beq    L9B11
        iny
        lda    ($04),y
        cmp    $05FF,y
        beq    L9B03
        bne    L9B15
L9B11:
        lda    $39
        cmp    $36
L9B15:
        php
        jsr    LBDDC
        ldx    $37
        plp
        rts

; EXPRESSION EVALUATOR
; ====================

; Evaluate expression at PtrA
; ---------------------------
L9B1D:
        lda    $0B              ; Copy PtrA to PtrB
        sta    $19
        lda    $0C
        sta    $1A
        lda    $0A
        sta    $1B

; Evaluate expression at PtrB
; ---------------------------
; TOP LEVEL EVALUATOR
;
; Evaluator Level 7 - OR, EOR
; ---------------------------
L9B29:
        jsr    L9B72            ; Call Evaluator Level 6 - AND
                                ; Returns A=type, value in IntA/FPA/StrA, X=next char
L9B2C:
        cpx    #tknOR           ; Jump if next char is OR
        beq    L9B3A
        cpx    #tknEOR          ; Jump if next char is EOR
        beq    L9B55
        dec    $1B              ; Step PtrB back to last char
        tay
        sta    $27
        rts

; OR numeric
; ----------
L9B3A:
        jsr    L9B6B            ; Stack as integer, call Evaluator Level 6
        tay
        jsr    L92F0            ; If float, convert to integer
        ldy    #$03
L9B43:
        lda    ($04),y          ; OR IntA with top of stack
        ora    $002A,y
        sta    $002A,y          ; Store result in IntA
        dey
        bpl    L9B43
L9B4E:
        jsr    LBDFF            ; Drop integer from stack
        lda    #$40
        bne    L9B2C            ; Return type=Int, jump to check for more OR/EOR

; EOR numeric
; -----------
L9B55:
        jsr    L9B6B
        tay
        jsr    L92F0            ; If float, convert to integer
        ldy    #$03
L9B5E:
        lda    ($04),y          ; EOR IntA with top of stack
        eor    $002A,y
        sta    $002A,y          ; Store result in IntA
        dey
        bpl    L9B5E
        bmi    L9B4E            ; Jump to drop from stack and continue

; Stack current as integer, evaluate another Level 6
; --------------------------------------------------
L9B6B:
        tay                     ; If float, convert to integer, push into stack
        jsr    L92F0
        jsr    LBD94

; Evaluator Level 6 - AND
; -----------------------
L9B72:
        jsr    L9B9C            ; Call Evaluator Level 5, < <= = >= > <>
L9B75:
        cpx    #tknAND          ; Return if next char not AND
        beq    L9B7A
        rts

; AND numeric
; -----------
L9B7A:
        tay                     ; If float, convert to integer, push onto stack
        jsr    L92F0
        jsr    LBD94
        jsr    L9B9C            ; Call Evaluator Level 5, < <= = >= > <>

        tay                     ; If float, convert to integer
        jsr    L92F0
        ldy    #$03
L9B8A:
        lda    ($04),y          ; AND IntA with top of stack
        and    $002A,y
        sta    $002A,y          ; Store result in IntA
        dey
        bpl    L9B8A
        jsr    LBDFF            ; Drop integer from stack
        lda    #$40             ; Return type=Int, jump to check for another AND
        bne    L9B75


; Evaluator Level 5 - >... =... or <...
; -------------------------------------
L9B9C:
        jsr    L9C42            ; Call Evaluator Level 4, + -
        cpx    #'>'+1           ; Larger than '>', return
        bcs    L9BA7
        cpx    #'<'             ; Smaller than '<', return
        bcs    L9BA8
L9BA7:
        rts

; >... =... or <...
; -----------------
L9BA8:
        beq    L9BC0            ; Jump with '<'
        cpx    #'>'             ; Jump with '>'
        beq    L9BE8            ; Must be '='

; = numeric
; ---------
        tax                     ; Jump with result=0 for not equal
        jsr    L9A9E
        bne    L9BB5
L9BB4:
        dey                     ; Decrement to &FF for equal
L9BB5:
        sty    $2A              ; Store 0/-1 in IntA
        sty    $2B
        sty    $2C
        sty    $2D              ; Return type=Int
        lda    #$40
        rts

; < <= <>
; -------
L9BC0:
        tax                     ; Get next char from PtrB
        ldy    $1B
        lda    ($19),y
        cmp    #'='             ; Jump for <=
        beq    L9BD4
        cmp    #'>'             ; Jump for <>
        beq    L9BDF

; Must be < numeric
; -----------------
        jsr    L9A9D            ; Evaluate next and compare
        bcc    L9BB4            ; Jump to return TRUE if <, FALSE if not <
        bcs    L9BB5

; <= numeric
; ----------
L9BD4:
        inc    $1B              ; Step past '=', evaluate next and compare
        jsr    L9A9D
        beq    L9BB4            ; Jump to return TRUE if =, TRUE if <
        bcc    L9BB4
        bcs    L9BB5            ; Jump to return FALSE otherwise

; <> numeric
; ----------
L9BDF:
        inc    $1B              ; Step past '>', evaluate next and compare
        jsr    L9A9D
        bne    L9BB4            ; Jump to return TRUE if <>, FALSE if =
        beq    L9BB5

; > >=
; ----
L9BE8:
        tax                     ; Get next char from PtrB
        ldy    $1B
        lda    ($19),y
        cmp    #'='             ; Jump for >=
        beq    L9BFA

; > numeric
; ---------
        jsr    L9A9D            ; Evaluate next and compare
        beq    L9BB5            ; Jump to return FALSE if =, TRUE if >
        bcs    L9BB4
        bcc    L9BB5            ; Jump to return FALSE if <

; >= numeric
; ----------
L9BFA:
        inc    $1B              ; Step past '=', evaluate next and compare
        jsr    L9A9D
        bcs    L9BB4            ; Jump to return TRUE if >=, FALSE if <
        bcc    L9BB5

L9C03:
        brk
        .byte  $13, "String too long"
        brk

; String addition
; ---------------
L9C15:
        jsr    LBDB2            ; Stack string, call Evaluator Level 2
        jsr    L9E20
        tay                     ; string + number, jump to 'Type mismatch' error
        bne    L9C88
        clc
        stx    $37
        ldy    #$00             ; Get stacked string length
        lda    ($04),y
        adc    $36              ; If added string length >255, jump to error
        bcs    L9C03
        tax                     ; Save new string length
        pha
        ldy    $36
L9C2D:
        lda    $05FF,y          ; Move current string up in string buffer
        sta    $05FF,x
        dex
        dey
        bne    L9C2D
        jsr    LBDCB            ; Unstack string to start of string buffer
        pla                     ; Set new string length
        sta    $36
        ldx    $37
        tya                     ; Set type=string, jump to check for more + or -
        beq    L9C45

; Evaluator Level 4, + -
; ----------------------
L9C42:
        jsr    L9DD1            ; Call Evaluator Level 3, * / DIV MOD
L9C45:
        cpx    #'+'             ; Jump with addition
        beq    L9C4E
        cpx    #'-'             ; Jump with subtraction
        beq    L9CB5
        rts

; + <value>
; ---------
L9C4E:
        tay                     ; Jump if current value is a string
        beq    L9C15
        bmi    L9C8B            ; Jump if current value is a float

; Integer addition
; ----------------
        jsr    L9DCE            ; Stack current and call Evaluator Level 3
        tay                     ; If int + string, jump to 'Type mismatch' error
        beq    L9C88
        bmi    L9CA7            ; If int + float, jump ...
        ldy    #$00
        clc                     ; Add top of stack to IntA
        lda    ($04),y
        adc    $2A
        sta    $2A
        iny                     ; Store result in IntA
        lda    ($04),y
        adc    $2B
        sta    $2B
        iny
        lda    ($04),y
        adc    $2C
        sta    $2C
        iny
        lda    ($04),y
        adc    $2D
L9C77:
        sta    $2D
        clc
        lda    $04              ; Drop integer from stack
        adc    #$04
        sta    $04
        lda    #$40             ; Set result=integer, jump to check for more + or -
        bcc    L9C45
        inc    $05
        bcs    L9C45
L9C88:
        jmp    L8C0E            ; Jump to 'Type mismatch' error

;Real addition
;-------------
L9C8B:
        jsr    LBD51            ; Stack float, call Evaluator Level 3
        jsr    L9DD1
        tay                     ; float + string, jump to 'Type mismatch' error
        beq    L9C88
        stx    $27              ; float + float, skip conversion
        bmi    L9C9B
        jsr    LA2BE            ; float + int, convert int to float
L9C9B:
        jsr    LBD7E            ; Pop float from stack, point FPTR to it
        jsr    LA500            ; Unstack float to FPA2 and add to FP1A
L9CA1:
        ldx    $27              ; Get next char back
        lda    #$FF             ; Set result=float, loop to check for more + or -
        bne    L9C45

; int + float
; -----------
L9CA7:
        stx    $27              ; Unstack integer to IntA
        jsr    LBDEA
        jsr    LBD51            ; Stack float, convert integer in IntA to float in FPA1
        jsr    LA2BE
        jmp    L9C9B            ; Jump to do float + <stacked float>

; - numeric
; ---------
L9CB5:
        tay                     ; If current value is a string, jump to error
        beq    L9C88
        bmi    L9CE1            ; Jump if current value is a float

; Integer subtraction
; -------------------
        jsr    L9DCE            ; Stack current and call Evaluator Level 3
        tay                     ; int + string, jump to error
        beq    L9C88
        bmi    L9CFA            ; int + float, jump to convert and do real subtraction
        sec
        ldy    #$00
        lda    ($04),y
        sbc    $2A
        sta    $2A
        iny                     ; Subtract IntA from top of stack
        lda    ($04),y
        sbc    $2B
        sta    $2B
        iny                     ; Store in IntA
        lda    ($04),y
        sbc    $2C
        sta    $2C
        iny
        lda    ($04),y
        sbc    $2D
        jmp    L9C77            ; Jump to pop stack and loop for more + or -

; Real subtraction
; ----------------
L9CE1:
        jsr    LBD51            ; Stack float, call Evaluator Level 3
        jsr    L9DD1
        tay                     ; float - string, jump to 'Type mismatch' error
        beq    L9C88
        stx    $27              ; float - float, skip conversion
        bmi    L9CF1
        jsr    LA2BE            ; float - int, convert int to float
L9CF1:
        jsr    LBD7E            ; Pop float from stack and point FPTR to it
        jsr    LA4FD            ; Unstack float to FPA2 and subtract it from FPA1
        jmp    L9CA1            ; Jump to set result and loop for more + or -

; int - float
; -----------
L9CFA:
        stx    $27              ; Unstack integer to IntA
        jsr    LBDEA
        jsr    LBD51            ; Stack float, convert integer in IntA to float in FPA1
        jsr    LA2BE
        jsr    LBD7E            ; Pop float from stack, point FPTR to it
        jsr    LA4D0            ; Subtract FPTR float from FPA1 float
        jmp    L9CA1            ; Jump to set result and loop for more + or -
L9D0E:
        jsr    LA2BE
L9D11:
        jsr    LBDEA
        jsr    LBD51
        jsr    LA2BE
        jmp    L9D2C
L9D1D:
        jsr    LA2BE
L9D20:
        jsr    LBD51
        jsr    L9E20
        stx    $27
        tay
        jsr    L92FD
L9D2C:
        jsr    LBD7E
        jsr    LA656
        lda    #$FF
        ldx    $27
        jmp    L9DD4
L9D39:
        jmp    L8C0E

; * <value>
; ---------
L9D3C:
        tay                     ; If current value is string, jump to error
        beq    L9D39
        bmi    L9D20            ; Jump if current value is a float
        lda    $2D
        cmp    $2C
        bne    L9D1D
        tay
        beq    L9D4E
        cmp    #$FF
        bne    L9D1D
L9D4E:
        eor    $2B
        bmi    L9D1D
        jsr    L9E1D
        stx    $27
        tay
        beq    L9D39
        bmi    L9D11
        lda    $2D
        cmp    $2C
        bne    L9D0E
        tay
        beq    L9D69
        cmp    #$FF
        bne    L9D0E
L9D69:
        eor    $2B
        bmi    L9D0E
        lda    $2D
        pha
        jsr    LAD71
        ldx    #$39
        jsr    LBE44
        jsr    LBDEA
        pla
        eor    $2D
        sta    $37
        jsr    LAD71
        ldy    #$00
        ldx    #$00
        sty    $3F
        sty    $40
L9D8B:
        lsr    $3A
        ror    $39
        bcc    L9DA6
        clc
        tya
        adc    $2A
        tay
        txa
        adc    $2B
        tax
        lda    $3F
        adc    $2C
        sta    $3F
        lda    $40
        adc    $2D
        sta    $40
L9DA6:
        asl    $2A
        rol    $2B
        rol    $2C
        rol    $2D
        lda    $39
        ora    $3A
        bne    L9D8B
        sty    $3D
        stx    $3E
        lda    $37
        php
L9DBB:
        ldx    #$3D
L9DBD:
        jsr    LAF56
        plp
        bpl    L9DC6
        jsr    LAD93
L9DC6:
        ldx    $27
        jmp    L9DD4

; * <value>
; ---------
L9DCB:
        jmp    L9D3C            ; Bounce back to multiply code

; Stack current value and continue in Evaluator Level 3
; -------------------------------------------------------
L9DCE:
        jsr    LBD94

; Evaluator Level 3, * / DIV MOD
; ------------------------------
L9DD1:
        jsr    L9E20            ; Call Evaluator Level 2, ^
L9DD4:
        cpx    #'*'             ; Jump with multiply
        beq    L9DCB
        cpx    # '/'            ; Jump with divide
        beq    L9DE5
        cpx    #tknMOD          ; Jump with MOD
        beq    L9E01
        cpx    #tknDIV          ; Jump with DIV
        beq    L9E0A
        rts

;/ <value>
;---------
L9DE5:
        tay                     ; Ensure current value is real
        jsr    L92FD
        jsr    LBD51            ; Stack float, call Evaluator Level 2
        jsr    L9E20
        stx    $27              ; Ensure current value is real
        tay
        jsr    L92FD
        jsr    LBD7E            ; Unstack to FPTR, call divide routine
        jsr    LA6AD
        ldx    $27              ; Set result, loop for more * / MOD DIV
        lda    #$FF
        bne    L9DD4

;MOD <value>
; -----------
L9E01:
        jsr    L99BE            ; Ensure current value is integer
        lda    $38
        php
        jmp    L9DBB            ; Jump to MOD routine

; DIV <value>
; -----------
L9E0A:
        jsr    L99BE            ; Ensure current value is integer
        rol    $39              ; Multiply IntA by 2
        rol    $3A
        rol    $3B
        rol    $3C
        bit    $37
        php
        ldx    #$39             ; Jump to DIV routine
        jmp    L9DBD

; Stack current integer and evaluate another Level 2
; --------------------------------------------------
L9E1D:
        jsr    LBD94            ; Stack integer

; Evaluator Level 2, ^
; --------------------
L9E20:
        jsr    LADEC            ; Call Evaluator Level 1, - + NOT function ( ) ? ! $ | "
L9E23:
        pha
L9E24:
        ldy    $1B              ; Get character
        inc    $1B
        lda    ($19),y
        cmp    #' '             ; Skip spaces
        beq    L9E24
        tax
        pla
        cpx    #'^'             ; Return if not ^
        beq    L9E35
        rts

; ^ <value>
; ---------
L9E35:
        tay                     ; Ensure current value is a float
        jsr    L92FD
        jsr    LBD51            ; Stack float, evaluate a real
        jsr    L92FA
        lda    $30
        cmp    #$87
        bcs    L9E88
        jsr    LA486
        bne    L9E59
        jsr    LBD7E
        jsr    LA3B5
        lda    $4A
        jsr    LAB12
        lda    #$FF             ; Set result=real, loop to check for more ^
        bne    L9E23
L9E59:
        jsr    LA381
        lda    $04
        sta    $4B
        lda    $05
        sta    $4C
        jsr    LA3B5
        lda    $4A
        jsr    LAB12
L9E6C:
        jsr    LA37D
        jsr    LBD7E
        jsr    LA3B5
        jsr    LA801
        jsr    LAAD1
        jsr    LAA94
        jsr    LA7ED
        jsr    LA656
        lda    #$FF             ; Set result=real, loop to check for more ^
        bne    L9E23
L9E88:
        jsr    LA381
        jsr    LA699
        bne    L9E6C

;Convert number to hex string
;----------------------------
L9E90:
        tya                     ; Convert real to integer
        bpl    L9E96
        jsr    LA3E4
L9E96:
        ldx    #$00
        ldy    #$00
L9E9A:
        lda    $002A,y          ; Expand four bytes into eight digits
        pha
        and    #$0F
        sta    $3F,x
        pla
        lsr    a
        lsr    a
        lsr    a
        lsr    a
        inx
        sta    $3F,x
        inx
        iny
        cpy    #$04             ; Loop for four bytes
        bne    L9E9A
L9EB0:
        dex                     ; No digits left, output a single zero
        beq    L9EB7
        lda    $3F,x            ; Skip leading zeros
        beq    L9EB0
L9EB7:
        lda    $3F,x            ; Get byte from workspace
        cmp    #$0A
        bcc    L9EBF
        adc    #$06
L9EBF:
        adc    #'0'             ; Convert to digit and store in buffer
        jsr    LA066
        dex
        bpl    L9EB7
        rts

; Output nonzero real number
; --------------------------
L9EC8:
        bpl    L9ED1            ; Jump forward if positive
        lda    #'-'             ; A='-', clear sign flag
        sta    $2E
        jsr    LA066            ; Add '-' to string buffer
L9ED1:
        lda    $30              ; Get exponent
        cmp    #$81             ; If m*2^1 or larger, number>=1, jump to output it
        bcs    L9F25
        jsr    LA1F4            ; FloatA=FloatA*10
        dec    $49
        jmp    L9ED1

; Convert numeric value to string
; ===============================
; On entry, FloatA (&2E-&35)  = number
;           or IntA (&2A-&2D) = number
;                           Y = type
;                          @% = print format
;                     &15.b7 set if hex
; Uses,     &37=format type 0/1/2=G/E/F
;           &38=max digits
;           &49
; On exit,  StrA contains string version of number
;           &36=string length
;
L9EDF:
        ldx    $0402            ; Get format byte
        cpx    #$03             ; If <3, ok - use it
        bcc    L9EE8
        ldx    #$00             ; If invalid, &00 for General format
L9EE8:
        stx    $37              ; Store format type
        lda    $0401            ; If digits=0, jump to check format
        beq    L9EF5
        cmp    #$0A             ; If 10+ digits, jump to use 10 digits
        bcs    L9EF9
        bcc    L9EFB            ; If <10 digits, use specified number
L9EF5:
        cpx    #$02             ; If fixed format, use zero digits
        beq    L9EFB

; STR$ enters here to use general format
; --------------------------------------
L9EF9:
        lda    #$0A             ; Otherwise, default to ten digits
L9EFB:
        sta    $38              ; Store digit length
        sta    $4E
        lda    #$00             ; Set initial output length to 0, initial exponent to 0
        sta    $36
        sta    $49
        bit    $15              ; Jump for hex conversion if &15.b7 set
        bmi    L9E90
        tya                     ; Convert integer to real
        bmi    L9F0F
        jsr    LA2BE
L9F0F:
        jsr    LA1DA            ; Get -1/0/+1 sign, jump if not zero to output nonzero number
        bne    L9EC8
        lda    $37              ; If not General format, output fixed or exponential zero
        bne    L9F1D
        lda    #'0'             ; Store single '0' into string buffer and return
        jmp    LA066
L9F1D:
        jmp    L9F9C            ; Jump to output zero in fixed or exponential format
L9F20:
        jsr    LA699            ; FloatA=1.0
        bne    L9F34

; FloatA now is >=1, check that it is <10
; ---------------------------------------
L9F25:
        cmp    #$84             ; Exponent<4, FloatA<10, jump to convert it
        bcc    L9F39
        bne    L9F31            ; Exponent<>4, need to divide it
        lda    $31              ; Get mantissa top byte
        cmp    #$A0             ; Less than &A0, less than ten, jump to convert it
        bcc    L9F39
L9F31:
        jsr    LA24D            ; FloatA=FloatA / 10
L9F34:
        inc    $49              ; Jump back to get the number >=1 again
        jmp    L9ED1

; FloatA is now between 1 and 9.999999999
; ---------------------------------------
L9F39:
        lda    $35              ; Copy FloatA to FloatTemp at &27/&046C
        sta    $27
        jsr    LA385
        lda    $4E              ; Get number of digits
        sta    $38
        ldx    $37              ; Get print format
        cpx    #$02             ; Not fixed format, jump to do exponent/general
        bne    L9F5C
        adc    $49
        bmi    L9FA0
        sta    $38
        cmp    #$0B
        bcc    L9F5C
        lda    #$0A
        sta    $38
        lda    #$00
        sta    $37
L9F5C:
        jsr    LA686            ; Clear FloatA
        lda    #$A0
        sta    $31
        lda    #$83
        sta    $30
        ldx    $38
        beq    L9F71
L9F6B:
        jsr    LA24D            ; FloatA=FloatA/10
        dex
        bne    L9F6B
L9F71:
        jsr    LA7F5            ; Point to &46C
        jsr    LA34E            ; Unpack to FloatB
        lda    $27
        sta    $42
        jsr    LA50B            ; Add
L9F7E:
        lda    $30
        cmp    #$84
        bcs    L9F92
        ror    $31
        ror    $32
        ror    $33
        ror    $34
        ror    $35
        inc    $30
        bne    L9F7E
L9F92:
        lda    $31
        cmp    #$A0
        bcs    L9F20
        lda    $38
        bne    L9FAD

; Output zero in Exponent or Fixed format
; ---------------------------------------
L9F9C:
        cmp    #$01
        beq    L9FE6
L9FA0:
        jsr    LA686            ; Clear FloatA
        lda    #$00
        sta    $49
        lda    $4E
        sta    $38
        inc    $38
L9FAD:
        lda    #$01
        cmp    $37
        beq    L9FE6
        ldy    $49
        bmi    L9FC3
        cpy    $38
        bcs    L9FE6
        lda    #$00
        sta    $49
        iny
        tya
        bne    L9FE6
L9FC3:
        lda    $37
        cmp    #$02
        beq    L9FCF
        lda    #$01
        cpy    #$FF
        bne    L9FE6
L9FCF:
        lda    #'0'             ; Output '0'
        jsr    LA066
        lda    #'.'             ; Output '.'
        jsr    LA066
        lda    #'0'             ; Prepare '0'
L9FDB:
        inc    $49
        beq    L9FE4
        jsr    LA066            ; Output
         bne    L9FDB
L9FE4:
        lda    #$80
L9FE6:
        sta    $4E
L9FE8:
        jsr    LA040
        dec    $4E
        bne    L9FF4
        lda    #$2E
        jsr    LA066
L9FF4:
        dec    $38
        bne    L9FE8
        ldy    $37
        dey
        beq    LA015
        dey
        beq    LA011
        ldy    $36
LA002:
        dey
        lda    $0600,y
        cmp    #'0'
        beq    LA002
        cmp    #'.'
        beq    LA00F
        iny
LA00F:
        sty    $36
LA011:
        lda    $49
        beq    LA03F
LA015:
        lda    #'E'             ; Output 'E'
        jsr    LA066
        lda    $49
        bpl    LA028
        lda    #'-'             ; Output '-'
        jsr    LA066
        sec
        lda    #$00
        sbc    $49              ; Negate
LA028:
        jsr    LA052
        lda    $37
        beq    LA03F
        lda    #$20
        ldy    $49
        bmi    LA038
        jsr    LA066
LA038:
        cpx    #$00
        bne    LA03F
        jmp    LA066
LA03F:
        rts
LA040:
        lda    $31
        lsr    a
        lsr    a
        lsr    a
        lsr    a
        jsr    LA064
        lda    $31
        and    #$0F
        sta    $31
        jmp    LA197
LA052:
        ldx    #$FF
        sec
LA055:
        inx
        sbc    #$0A
        bcs    LA055
        adc    #$0A
        pha
        txa
        beq    LA063
        jsr    LA064
LA063:
        pla
LA064:
        ora    #'0'

; Store character in string buffer
; --------------------------------
LA066:
        stx    $3B              ; Store character
        ldx    $36
        sta    $0600,x
        ldx    $3B              ; Increment string length
        inc    $36
        rts
LA072:
        clc
        stx    $35
        jsr    LA1DA
        lda    #$FF
        rts

; Scan decimal number
; -------------------
LA07B:
        ldx    #$00             ; Clear FloatA
        stx    $31
        stx    $32
        stx    $33
        stx    $34
        stx    $35
        stx    $48              ; Clear 'Decimal point' flag
        stx    $49
        cmp    #'.'             ; Leading decimal point
        beq    LA0A0
        cmp    #'9'+1           ; Not a decimal digit, finish
        bcs    LA072
        sbc    #'0'-1           ; Convert to binary, if not digit finish
        bmi    LA072
        sta    $35              ; Store digit
LA099:
        iny                     ; Get next character
        lda    ($19),y
        cmp    #'.'             ; Not decimal point
        bne    LA0A8
LA0A0:
        lda    $48              ; Already got decimal point,
        bne    LA0E8
        inc    $48              ; Set Decimal Point flag, loop for next
        bne    LA099
LA0A8:
        cmp    #'E'             ; Jump to scan exponent
        beq    LA0E1
        cmp    #'9'+1           ; Not a digit, jump to finish
        bcs    LA0E8
        sbc    #'0'-1           ; Not a digit, jump to finish
        bcc    LA0E8
        ldx    $31              ; Get mantissa top byte
        cpx    #$18             ; If <25, still small enough to add to
        bcc    LA0C2
        ldx    $48              ; Decimal point found, skip digits to end of number
        bne    LA099
        inc    $49              ; No decimal point, increment exponent and skip digits
        bcs    LA099
LA0C2:
        ldx    $48
        beq    LA0C8
        dec    $49              ; Decimal point found, decrement exponent
LA0C8:
        jsr    LA197            ; Multiply FloatA by 10
        adc    $35              ; Add digit to mantissa low byte
        sta    $35
        bcc    LA099            ; No overflow
        inc    $34              ; Add carry through mantissa
        bne    LA099
        inc    $33
        bne    LA099
        inc    $32
        bne    LA099
        inc    $31              ; Loop to check next digit
        bne    LA099

; Deal with Exponent in scanned number
; ------------------------------------
LA0E1:
        jsr    LA140            ; Scan following number
        adc    $49              ; Add to current exponent
        sta    $49
; End of number found
; -------------------
LA0E8:
        sty    $1B              ; Store PtrB offset
        lda    $49              ; Check exponent and 'decimal point' flag
        ora    $48
        beq    LA11F            ; No exponent, no decimal point, return integer
        jsr    LA1DA
        beq    LA11B
LA0F5:
        lda    #$A8
        sta    $30
        lda    #$00
        sta    $2F
        sta    $2E
        jsr    LA303
        lda    $49
        bmi    LA111
        beq    LA118
LA108:
        jsr    LA1F4
        dec    $49
        bne    LA108
        beq    LA118
LA111:
        jsr    LA24D
        inc    $49
        bne    LA111
LA118:
        jsr    LA65C
LA11B:
        sec
        lda    #$FF
        rts
LA11F:
        lda    $32
        sta    $2D
        and    #$80
        ora    $31
        bne    LA0F5
        lda    $35
        sta    $2A
        lda    $34
        sta    $2B
        lda    $33
        sta    $2C
        lda    #$40
        sec
        rts
LA139:
        jsr    LA14B            ; Scan following number
        eor    #$FF             ; Negate it, return CS=Ok
        sec
        rts

; Scan exponent, allows E E+ E- followed by one or two digits
; -----------------------------------------------------------
LA140:
        iny                     ; Get next character
        lda    ($19),y
        cmp    #'-'             ; If '-', jump to scan and negate
        beq    LA139
        cmp    #'+'             ; If '+', just step past
        bne    LA14E
LA14B:
        iny                     ; Get next character
        lda    ($19),y
LA14E:
        cmp    #'9'+1           ; Not a digit, exit with CC and A=0
        bcs    LA174
        sbc    #'0'-1           ; Not a digit, exit with CC and A=0
        bcc    LA174
        sta    $4A              ; Store exponent digit
        iny                     ; Get next character
        lda    ($19),y
        cmp    #'9'+1           ; Not a digit, exit with CC and A=exp
        bcs    LA170
        sbc    #'0'-1           ; Not a digit, exit with CC and A=exp
        bcc    LA170
        iny                     ; Step past digit, store current digit
        sta    $43
        lda    $4A              ; Get current exponent
        asl    a                ; exp=exp*10
        asl    a
        adc    $4A
        asl    a                ; exp=exp*10+digit
        adc    $43
        rts
LA170:
        lda    $4A              ; Get exp and return CC=Ok
        clc
        rts
LA174:
        lda    #$00             ; Return exp=0 and CC=Ok
        clc
        rts
LA178:
        lda    $35
        adc    $42
        sta    $35
        lda    $34
        adc    $41
        sta    $34
        lda    $33
        adc    $40
        sta    $33
        lda    $32
        adc    $3F
        sta    $32
        lda    $31
        adc    $3E
        sta    $31
        rts
LA197:
        pha
        ldx    $34
        lda    $31
        pha
        lda    $32
        pha
        lda    $33
        pha
        lda    $35
        asl    a
        rol    $34
        rol    $33
        rol    $32
        rol    $31
        asl    a
        rol    $34
        rol    $33
        rol    $32
        rol    $31
        adc    $35
        sta    $35
        txa
        adc    $34
        sta    $34
        pla
        adc    $33
        sta    $33
        pla
        adc    $32
        sta    $32
        pla
        adc    $31
        asl    $35
        rol    $34
        rol    $33
        rol    $32
        rol    a
        sta    $31
        pla
        rts
LA1DA:
        lda    $31
        ora    $32
        ora    $33
        ora    $34
        ora    $35
        beq    LA1ED
        lda    $2E
        bne    LA1F3
        lda    #$01
        rts
LA1ED:
        sta    $2E
        sta    $30
        sta    $2F
LA1F3:
        rts
LA1F4:
        clc
        lda    $30
        adc    #$03
        sta    $30
        bcc    LA1FF
        inc    $2F
LA1FF:
        jsr    LA21E
        jsr    LA242
        jsr    LA242
LA208:
        jsr    LA178
LA20B:
        bcc    LA21D
        ror    $31
        ror    $32
        ror    $33
        ror    $34
        ror    $35
        inc    $30
        bne    LA21D
        inc    $2F
LA21D:
        rts
LA21E:
        lda    $2E
LA220:
        sta    $3B
        lda    $2F
        sta    $3C
        lda    $30
        sta    $3D
        lda    $31
        sta    $3E
        lda    $32
        sta    $3F
        lda    $33
        sta    $40
        lda    $34
        sta    $41
        lda    $35
        sta    $42
        rts
LA23F:
        jsr    LA21E
LA242:
        lsr    $3E
        ror    $3F
        ror    $40
        ror    $41
        ror    $42
        rts
LA24D:
        sec
        lda    $30
        sbc    #$04
        sta    $30
        bcs    LA258
        dec    $2F
LA258:
        jsr    LA23F
        jsr    LA208
        jsr    LA23F
        jsr    LA242
        jsr    LA242
        jsr    LA242
        jsr    LA208
        lda    #$00
        sta    $3E
        lda    $31
        sta    $3F
        lda    $32
        sta    $40
        lda    $33
        sta    $41
        lda    $34
        sta    $42
        lda    $35
        rol    a
        jsr    LA208
        lda    #$00
        sta    $3E
        sta    $3F
        lda    $31
        sta    $40
        lda    $32
        sta    $41
        lda    $33
        sta    $42
        lda    $34
        rol    a
        jsr    LA208
        lda    $32
        rol    a
        lda    $31
LA2A4:
        adc    $35
        sta    $35
        bcc    LA2BD
        inc    $34
        bne    LA2BD
        inc    $33
        bne    LA2BD
        inc    $32
        bne    LA2BD
        inc    $31
        bne    LA2BD
        jmp    LA20B
LA2BD:
        rts
LA2BE:
        ldx    #$00
        stx    $35
        stx    $2F
        lda    $2D
        bpl    LA2CD
        jsr    LAD93
        ldx    #$FF
LA2CD:
        stx    $2E
        lda    $2A
        sta    $34
        lda    $2B
        sta    $33
        lda    $2C
        sta    $32
        lda    $2D
        sta    $31
        lda    #$A0
        sta    $30
        jmp    LA303
LA2E6:
        sta    $2E
        sta    $30
        sta    $2F
LA2EC:
        rts
LA2ED:
        pha
        jsr    LA686
        pla
        beq    LA2EC
        bpl    LA2FD
        sta    $2E
        lda    #$00
        sec
        sbc    $2E
LA2FD:
        sta    $31
        lda    #$88
        sta    $30
LA303:
        lda    $31
        bmi    LA2EC
        ora    $32
        ora    $33
        ora    $34
        ora    $35
        beq    LA2E6
        lda    $30
LA313:
        ldy    $31
        bmi    LA2EC
        bne    LA33A
        ldx    $32
        stx    $31
        ldx    $33
        stx    $32
        ldx    $34
        stx    $33
        ldx    $35
        stx    $34
        sty    $35
        sec
        sbc    #$08
        sta    $30
        bcs    LA313
        dec    $2F
        bcc    LA313
LA336:
        ldy    $31
        bmi    LA2EC
LA33A:
        asl    $35
        rol    $34
        rol    $33
        rol    $32
        rol    $31
        sbc    #$00
        sta    $30
        bcs    LA336
        dec    $2F
        bcc    LA336
LA34E:
        ldy    #$04
        lda    ($4B),y
        sta    $41
        dey
        lda    ($4B),y
        sta    $40
        dey
        lda    ($4B),y
        sta    $3F
        dey
        lda    ($4B),y
        sta    $3B
        dey
        sty    $42
        sty    $3C
        lda    ($4B),y
        sta    $3D
        ora    $3B
        ora    $3F
        ora    $40
        ora    $41
        beq    LA37A
        lda    $3B
        ora    #$80
LA37A:
        sta    $3E
        rts
LA37D:
        lda    #$71
        bne    LA387
LA381:
        lda    #$76
        bne    LA387
LA385:
        lda    #$6C
LA387:
        sta    $4B
        lda    #$04
        sta    $4C
LA38D:
        ldy    #$00
        lda    $30
        sta    ($4B),y
        iny
        lda    $2E
        and    #$80
        sta    $2E
        lda    $31
        and    #$7F
        ora    $2E
        sta    ($4B),y
        lda    $32
        iny
        sta    ($4B),y
        lda    $33
        iny
        sta    ($4B),y
        lda    $34
        iny
        sta    ($4B),y
        rts
LA3B2:
        jsr    LA7F5
LA3B5:
        ldy    #$04
        lda    ($4B),y
        sta    $34
        dey
        lda    ($4B),y
        sta    $33
        dey
        lda    ($4B),y
        sta    $32
        dey
        lda    ($4B),y
        sta    $2E
        dey
        lda    ($4B),y
        sta    $30
        sty    $35
        sty    $2F
        ora    $2E
        ora    $32
        ora    $33
        ora    $34
        beq    LA3E1
        lda    $2E
        ora    #$80
 LA3E1:
        sta    $31
        rts

; Convert real to integer
; =======================
LA3E4:
        jsr    LA3FE            ; Convert real to integer
LA3E7:
        lda    $31              ; Copy to Integer Accumulator
        sta    $2D
        lda    $32
        sta    $2C
        lda    $33
        sta    $2B
        lda    $34
        sta    $2A
        rts
LA3F8:
        jsr    LA21E            ; Copy FloatA to FloatB
        jmp    LA686            ; Set FloatA to zero and return

; Convert float to integer
; ========================
; On entry, FloatA (&30-&34) holds a float
; On exit,  FloatA (&30-&34) holds integer part
; ---------------------------------------------
; The real value is partially denormalised by repeatedly dividing the mantissa
; by 2 and incrementing the exponent to multiply the number by 2, until the
; exponent is &80, indicating that we have got to mantissa * 2^0.
;
LA3FE:
        lda    $30              ; Exponent<&80, number<1, jump to return 0
        bpl    LA3F8
        jsr    LA453            ; Set &3B-&42 to zero
        jsr    LA1DA
        bne    LA43C
        beq    LA468
LA40C:
        lda    $30              ; Get exponent
        cmp    #$A0             ; Exponent is +32, float has been denormalised to an integer
        bcs    LA466
        cmp    #$99
        bcs    LA43C
        adc    #$08
        sta    $30
        lda    $40
        sta    $41
        lda    $3F
        sta    $40
        lda    $3E
        sta    $3F
        lda    $34
        sta    $3E
        lda    $33              ; Divide mantissa by 2^8
        sta    $34
        lda    $32
        sta    $33
        lda    $31
        sta    $32
        lda    #$00
        sta    $31
        beq    LA40C            ; Loop to keep dividing
LA43C:
        lsr    $31
        ror    $32
        ror    $33
        ror    $34
        ror    $3E
        ror    $3F
        ror    $40
        ror    $41
        inc    $30
        bne    LA40C
LA450:
        jmp    LA66C
LA453:
        lda    #$00
        sta    $3B
        sta    $3C
        sta    $3D
        sta    $3E
        sta    $3F
        sta    $40
        sta    $41
        sta    $42
        rts
LA466:
        bne    LA450            ; Exponent>32, jump to 'Too big' error
LA468:
        lda    $2E              ; If positive, jump to return
        bpl    LA485
LA46C:
        sec                     ; Negate the mantissa to get integer
        lda    #$00
        sbc    $34
        sta    $34
        lda    #$00
        sbc    $33
        sta    $33
        lda    #$00
        sbc    $32
        sta    $32
        lda    #$00
        sbc    $31
        sta    $31
LA485:
        rts
LA486:
        lda    $30
        bmi    LA491
        lda    #$00
        sta    $4A
        jmp    LA1DA
LA491:
        jsr    LA3FE
        lda    $34
        sta    $4A
        jsr    LA4E8
        lda    #$80
        sta    $30
        ldx    $31
        bpl    LA4B3
        eor    $2E
        sta    $2E
        bpl    LA4AE
        inc    $4A
        jmp    LA4B0
LA4AE:
        dec    $4A
LA4B0:
        jsr    LA46C
LA4B3:
        jmp    LA303
LA4B6:
        inc    $34
        bne    LA4C6
        inc    $33
        bne    LA4C6
        inc    $32
        bne    LA4C6
        inc    $31
        beq    LA450
LA4C6:
        rts
LA4C7:
        jsr    LA46C
        jsr    LA4B6
        jmp    LA46C
LA4D0 :
      jsr    LA4FD
      jmp    LAD7E
LA4D6:
        jsr    LA34E
        jsr    LA38D
LA4DC:
        lda    $3B
        sta    $2E
        lda    $3C
        sta    $2F
        lda    $3D
        sta    $30
LA4E8:
        lda    $3E
        sta    $31
        lda    $3F
        sta    $32
        lda    $40
        sta    $33
        lda    $41
        sta    $34
        lda    $42
        sta    $35
LA4FC:
        rts
LA4FD:
        jsr    LAD7E
LA500:
        jsr    LA34E
        beq    LA4FC
LA505:
        jsr    LA50B
        jmp    LA65C
LA50B:
        jsr    LA1DA
        beq    LA4DC
        ldy    #$00
        sec
        lda    $30
        sbc    $3D
        beq    LA590
        bcc    LA552
        cmp    #$25
        bcs    LA4FC
        pha
        and    #$38
        beq    LA53D
        lsr    a
        lsr    a
        lsr    a
        tax
LA528:
        lda    $41
        sta    $42
        lda    $40
        sta    $41
        lda    $3F
        sta    $40
        lda    $3E
        sta    $3F
        sty    $3E
        dex
        bne    LA528
LA53D:
        pla
        and    #$07
        beq    LA590
        tax
LA543:
        lsr    $3E
        ror    $3F
        ror    $40
        ror    $41
        ror    $42
        dex
        bne    LA543
        beq    LA590
LA552:
        sec
        lda    $3D
        sbc    $30
        cmp    #$25
        bcs    LA4DC
        pha
        and    #$38
        beq    LA579
        lsr    a
        lsr    a
        lsr    a
        tax
LA564:
        lda    $34
        sta    $35
        lda    $33
        sta    $34
        lda    $32
        sta    $33
        lda    $31
        sta    $32
        sty    $31
        dex
        bne    LA564
LA579:
        pla
        and    #$07
        beq    LA58C
        tax
LA57F:
        lsr    $31
        ror    $32
        ror    $33
        ror    $34
        ror    $35
        dex
        bne    LA57F
LA58C:
        lda    $3D
        sta    $30
LA590:
        lda    $2E
        eor    $3B
        bpl    LA5DF
        lda    $31
        cmp    $3E
        bne    LA5B7
        lda    $32
        cmp    $3F
        bne    LA5B7
        lda    $33
        cmp    $40
        bne    LA5B7
        lda    $34
        cmp    $41
        bne    LA5B7
        lda    $35
        cmp    $42
        bne    LA5B7
        jmp    LA686
LA5B7:
        bcs    LA5E3
        sec
        lda    $42
        sbc    $35
        sta    $35
        lda    $41
        sbc    $34
        sta    $34
        lda    $40
        sbc    $33
        sta    $33
        lda    $3F
        sbc    $32
        sta    $32
        lda    $3E
        sbc    $31
        sta    $31
        lda    $3B
        sta    $2E
        jmp    LA303
LA5DF:
        clc
        jmp    LA208
LA5E3:
        sec
        lda    $35
        sbc    $42
        sta    $35
        lda    $34
        sbc    $41
        sta    $34
        lda    $33
        sbc    $40
        sta    $33
        lda    $32
        sbc    $3F
        sta    $32
        lda    $31
        sbc    $3E
        sta    $31
        jmp    LA303
 LA605:
        rts
LA606:
        jsr    LA1DA
        beq    LA605
        jsr    LA34E
        bne    LA613
        jmp    LA686
LA613:
        clc
        lda    $30
        adc    $3D
        bcc    LA61D
        inc    $2F
        clc
LA61D:
        sbc    #$7F
        sta    $30
        bcs    LA625
        dec    $2F
LA625:
        ldx    #$05
        ldy    #$00
LA629:
        lda    $30,x
        sta    $42,x
        sty    $30,x
        dex
        bne    LA629
        lda    $2E
        eor    $3B
        sta    $2E
        ldy    #$20
LA63A:
        lsr    $3E
        ror    $3F
        ror    $40
        ror    $41
        ror    $42
        asl    $46
        rol    $45
        rol    $44
        rol    $43
        bcc    LA652
        clc
        jsr    LA178
LA652:
        dey
        bne    LA63A
        rts
LA656:
        jsr    LA606
LA659:
        jsr    LA303
LA65C:
        lda    $35
        cmp    #$80
        bcc    LA67C
        beq    LA676
        lda    #$FF
        jsr    LA2A4
        jmp    LA67C
LA66C:
        brk
        .byte  $14, "Too big"
        brk
LA676:
        lda    $34
        ora    #$01
        sta    $34
LA67C:
        lda    #$00
        sta    $35
        lda    $2F
        beq    LA698
        bpl    LA66C
LA686:
        lda    #$00
        sta    $2E
        sta    $2F
        sta    $30
        sta    $31
        sta    $32
        sta    $33
        sta    $34
        sta    $35
LA698:
        rts
LA699:
        jsr    LA686
        ldy    #$80
        sty    $31
        iny
        sty    $30
        tya
        rts
LA6A5:
        jsr    LA385
        jsr    LA699
        bne    LA6E7
LA6AD:
        jsr    LA1DA
        beq    LA6BB
        jsr    LA21E
        jsr    LA3B5
        bne    LA6F1
        rts
LA6BB:
        jmp    L99A7

; =TAN numeric
; ============
LA6BE:
        jsr    L92FA
        jsr    LA9D3
        lda    $4A
        pha
        jsr    LA7E9
        jsr    LA38D
        inc    $4A
        jsr    LA99E
        jsr    LA7E9
        jsr    LA4D6
        pla
        sta    $4A
        jsr    LA99E
        jsr    LA7E9
        jsr    LA6E7
        lda    #$FF
        rts
LA6E7:
        jsr    LA1DA
        beq    LA698
        jsr    LA34E
        beq    LA6BB
LA6F1:
        lda    $2E
        eor    $3B
        sta    $2E
        sec
        lda    $30
        sbc    $3D
        bcs    LA701
        dec    $2F
        sec
LA701:
        adc    #$80
        sta    $30
        bcc    LA70A
        inc    $2F
        clc
LA70A:
        ldx    #$20
LA70C:
        bcs    LA726
        lda    $31
        cmp    $3E
        bne    LA724
        lda    $32
        cmp    $3F
        bne    LA724
        lda    $33
        cmp    $40
        bne    LA724
        lda    $34
        cmp    $41
LA724:
        bcc    LA73F
LA726:
        lda    $34
        sbc    $41
        sta    $34
        lda    $33
        sbc    $40
        sta    $33
        lda    $32
        sbc    $3F
        sta    $32
        lda    $31
        sbc    $3E
        sta    $31
        sec
LA73F:
        rol    $46
        rol    $45
        rol    $44
        rol    $43
        asl    $34
        rol    $33
        rol    $32
        rol    $31
        dex
        bne    LA70C
        ldx    #$07
LA754:
        bcs    LA76E
        lda    $31
        cmp    $3E
        bne    LA76C
        lda    $32
        cmp    $3F
        bne    LA76C
        lda    $33
        cmp    $40
        bne    LA76C
        lda    $34
        cmp    $41
LA76C:
        bcc    LA787
LA76E:
        lda    $34
        sbc    $41
        sta    $34
        lda    $33
        sbc    $40
        sta    $33
        lda    $32
        sbc    $3F
        sta    $32
        lda    $31
        sbc    $3E
        sta    $31
        sec
LA787:
        rol    $35
        asl    $34
        rol    $33
        rol    $32
        rol    $31
        dex
        bne    LA754
        asl    $35
        lda    $46
        sta    $34
        lda    $45
        sta    $33
        lda    $44
        sta    $32
        lda    $43
        sta    $31
        jmp    LA659
LA7A9:
        brk
        .byte   $15, "-ve root"
        brk
; =SQR numeric
; ============
LA7B4:
        jsr    L92FA
LA7B7:
        jsr    LA1DA
        beq    LA7E6
        bmi    LA7A9
        jsr    LA385
        lda    $30
        lsr    a
        adc    #$40
        sta    $30
        lda    #$05
        sta    $4A
        jsr    LA7ED
LA7CF:
        jsr    LA38D
        lda    #$6C
        sta    $4B
        jsr    LA6AD
        lda    #$71
        sta    $4B
        jsr    LA500
        dec    $30
        dec    $4A
        bne    LA7CF
LA7E6:
        lda    #$FF
        rts

; Point &4B/C to a floating point temp
; ------------------------------------
LA7E9:
        lda    #$7B
        bne    LA7F7
LA7ED:
        lda    #$71
        bne    LA7F7
LA7F1:
        lda    #$76
        bne    LA7F7
LA7F5:
        lda    #$6C
LA7F7:
        sta    $4B
        lda    #$04
        sta    $4C
        rts

; =LN numeric
; ===========
LA7FE:
        jsr    L92FA
LA801:
        jsr    LA1DA
        beq    LA808
        bpl    LA814
LA808:
        brk
        .byte  $16, "Log range"
        brk
LA814:
        jsr    LA453
        ldy    #$80
        sty    $3B
        sty    $3E
        iny
        sty    $3D
        ldx    $30
        beq    LA82A
        lda    $31
        cmp    #$B5
        bcc    LA82C
LA82A:
        inx
        dey
LA82C:
        txa
        pha
        sty    $30
        jsr    LA505
        lda    #$7B
        jsr    LA387
        lda    #$73
        ldy    #$A8
        jsr    LA897
        jsr    LA7E9
        jsr    LA656
        jsr    LA656
        jsr    LA500
        jsr    LA385
        pla
        sec
        sbc    #$81
        jsr    LA2ED
        lda    #$6E
        sta    $4B
        lda    #$A8
        sta    $4C
        jsr    LA656
        jsr    LA7F5
        jsr    LA500
        lda    #$FF
        rts
LA869:
        .byte  $7F, $5E, $5B, $D8, $AA
LA86E:
        .byte  $80, $31, $72, $17, $F8
LA873:
        .byte  $06, $7A, $12
LA876:
        .byte  $38, $A5, $0B, $88, $79, $0E, $9F
        .byte  $F3, $7C, $2A, $AC, $3F, $B5, $86, $34
        .byte  $01, $A2, $7A, $7F, $63, $8E, $37, $EC
        .byte  $82, $3F, $FF, $FF, $C1, $7F, $FF, $FF
        .byte  $FF, $FF
LA897:
        sta    $4D
        sty    $4E
        jsr    LA385
        ldy    #$00
        lda    ($4D),y
        sta    $48
        inc    $4D
        bne    LA8AA
        inc    $4E
LA8AA:
        lda    $4D
        sta    $4B
        lda    $4E
        sta    $4C
        jsr    LA3B5
LA8B5:
        jsr    LA7F5
        jsr    LA6AD
        clc
        lda    $4D
        adc    #$05
        sta    $4D
        sta    $4B
        lda    $4E
        adc    #$00
        sta    $4E
        sta    $4C
        jsr    LA500
        dec    $48
        bne    LA8B5
        rts

;=ACS numeric
; ============
LA8D4:
        jsr    LA8DA
        jmp    LA927

; =ASN numeric
; ============
LA8DA:
        jsr    L92FA
        jsr    LA1DA
        bpl    LA8EA
        lsr    $2E
        jsr    LA8EA
        jmp    LA916
LA8EA:
        jsr    LA381
        jsr    LA9B1
        jsr    LA1DA
        beq    LA8FE
        jsr    LA7F1
        jsr    LA6AD
        jmp    LA90A
LA8FE:
        jsr    LAA55
        jsr    LA3B5
LA904:
        lda    #$FF
        rts

; =ATN numeric
; ============
LA907:
        jsr    L92FA
LA90A:
        jsr    LA1DA
        beq    LA904
        bpl    LA91B
        lsr    $2E
        jsr    LA91B
LA916:
        lda    #$80
        sta    $2E
        rts
LA91B:
        lda    $30
        cmp    #$81
        bcc    LA936
        jsr    LA6A5
        jsr    LA936
LA927:
        jsr    LAA48
        jsr    LA500
        jsr    LAA4C
        jsr    LA500
        jmp    LAD7E
LA936:
        lda    $30
        cmp    #$73
        bcc    LA904
        jsr    LA381
        jsr    LA453
        lda    #$80
        sta    $3D
        sta    $3E
        sta    $3B
        jsr    LA505
        lda    #LA95A & 255
        ldy    #LA95A / 256
        jsr    LA897
        jsr    LAAD1
        lda    #$FF
        rts
LA95A:
        ora    #$85
        .byte  $A3, $59, $E8, $67, $80, $1C, $9D, $07
        .byte  $36, $80, $57, $BB, $78, $DF, $80, $CA
        .byte  $9A, $0E, $83, $84, $8C, $BB, $CA, $6E
        .byte  $81, $95, $96, $06, $DE, $81, $0A, $C7
        .byte  $6C, $52, $7F, $7D, $AD, $90, $A1, $82
        .byte  $FB, $62, $57, $2F, $80, $6D, $63, $38
        .byte $2C

; =COS numeric
; ============
LA98D:
        jsr    L92FA            ; Evaluate float
        jsr    LA9D3
        inc    $4A
        jmp    LA99E

; =SIN numeric
; ============
LA998:
        jsr    L92FA            ; Evaluate float
        jsr    LA9D3
LA99E:
        lda    $4A
        and    #$02
        beq    LA9AA
        jsr    LA9AA
        jmp    LAD7E
LA9AA:
        lsr    $4A
        bcc    LA9C3
        jsr    LA9C3
LA9B1:
        jsr    LA385
        jsr    LA656
        jsr    LA38D
        jsr    LA699
        jsr    LA4D0
        jmp    LA7B7
LA9C3:
        jsr    LA381
        jsr    LA656
        lda    #LAA72 & 255
        ldy    #LAA72 / 256
        jsr    LA897
        jmp    LAAD1
LA9D3:
        lda    $30
        cmp    #$98
        bcs    LAA38
        jsr    LA385
        jsr    LAA55
        jsr    LA34E
        lda    $2E
        sta    $3B
        dec    $3D
        jsr    LA505
        jsr    LA6E7
        jsr    LA3FE
        lda    $34
        sta    $4A
        ora    $33
        ora    $32
        ora    $31
        beq    LAA35
        lda    #$A0
        sta    $30
        ldy    #$00
        sty    $35
        lda    $31
        sta    $2E
        bpl    LAA0E
        jsr    LA46C
LAA0E:
        jsr    LA303
        jsr    LA37D
        jsr    LAA48
        jsr    LA656
        jsr    LA7F5
        jsr    LA500
        jsr    LA38D
        jsr    LA7ED
        jsr    LA3B5
        jsr    LAA4C
        jsr    LA656
        jsr    LA7F5
        jmp    LA500
LAA35:
        jmp    LA3B2
LAA38:
        brk
        .byte  $17, "Accuracy lost"
        brk
LAA48:
        lda    #LAA59 & 255
        bne    LAA4E
LAA4C:
        lda    #LAA5E & 255
LAA4E:
        sta    $4B
        lda    #LAA59 / 256
        sta    $4C
        rts
LAA55:
        lda    #LAA63 & 255
        bne    LAA4E
LAA59:
        sta    ($C9,x)
        bpl    LAA5D
LAA5D:
        brk
LAA5E:
        .byte  $6F, $15, $77, $7A, $61
LAA63:
        .byte  $81, $49, $0F
        .byte  $DA, $A2
LAA68:
        .byte  $7B, $0E, $FA, $35, $12
LAA6D:
        .byte  $86
        .byte  $65, $2E, $E0, $D3
LAA72:
        .byte  $05, $84, $8A, $EA
        .byte  $0C, $1B, $84, $1A, $BE, $BB, $2B, $84
        .byte  $37, $45, $55, $AB, $82, $D5, $55, $57
        .byte  $7C, $83, $C0, $00, $00, $05, $81, $00
        .byte  $00, $00, $00

; = EXP numeric
; =============
LAA91:
        jsr    L92FA
LAA94:
        lda    $30
        cmp    #$87
        bcc    LAAB8
        bne    LAAA2
LAA9C:
        ldy    $31
        cpy    #$B3
        bcc    LAAB8
LAAA2:
        lda    $2E
        bpl    LAAAC
        jsr    LA686
        lda    #$FF
        rts
LAAAC:
        brk
        .byte  $18, "Exp range"
        brk
LAAB8:
        jsr     LA486
        jsr     LAADA
        jsr    LA381
        lda    #LAAE4 & 255
        sta    $4B
        lda    #LAAE4 / 256
        sta    $4C
        jsr    LA3B5
        lda    $4A
        jsr    LAB12
LAAD1:
        jsr    LA7F1
        jsr    LA656
        lda    #$FF
        rts
LAADA:
        lda    #LAAE9 & 255
        ldy    #LAAE9 / 256
        jsr    LA897
        lda    #$FF
        rts
LAAE4:
        .byte  $82, $2D, $F8, $54, $58
LAAE9:
        .byte  $07, $83, $E0
        .byte  $20, $86, $5B, $82, $80, $53, $93, $B8
        .byte  $83, $20, $00, $06, $A1, $82, $00, $00
        .byte  $21, $63, $82, $C0, $00, $00, $02, $82
        .byte  $80, $00, $00, $0C, $81, $00, $00, $00
        .byte  $00, $81, $00, $00, $00, $00
LAB12:
        tax
        bpl    LAB1E
        dex
        txa
        eor    #$FF
        pha
        jsr    LA6A5
        pla
LAB1E:
        pha
        jsr    LA385
        jsr    LA699
LAB25:
        pla
        beq    LAB32
        sec
        sbc    #$01
        pha
        jsr    LA656
        jmp    LAB25
LAB32:
        rts

; =ADVAL numeric - Call OSBYTE to read buffer/device
; ==================================================
LAB33:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    L92E3            ; Evaluate integer
        ldx    $2A              ; X=low byte, A=&80 for ADVAL
        lda    #$80
        jsr    OSBYTE
        txa
        jmp    LAEEA
.endif
LAB41:                          ; POINT()
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    L92DD
        jsr    LBD94
        jsr    L8AAE
        jsr    LAE56
        jsr    L92F0
        lda    $2A
        pha
        lda    $2B
        pha
        jsr    LBDEA
        pla
        sta    $2D
        pla
        sta    $2C
        ldx    #$2A
        lda    #$09
        jsr    OSWORD
        lda    $2E
        bmi    LAB9D
        jmp    LAED8
.endif

; =POS
; ====
LAB6D:
        lda    #$86
        jsr    OSBYTE
        txa
        jmp    LAED8

; =VPOS
; =====
LAB76:
        lda    #$86
        jsr    OSBYTE
        tya
        jmp    LAED8
LAB7F:
        jsr    LA1DA
        beq    LABA2
        bpl    LABA0
        bmi    LAB9D

; =SGN numeric
;\ ============
LAB88:
        jsr    LADEC
        beq    LABE6
        bmi    LAB7F
        lda    $2D
        ora    $2C
        ora    $2B
        ora    $2A
        beq    LABA5
        lda    $2D
        bpl    LABA0
LAB9D:
        jmp    LACC4
LABA0:
        lda    #$01
LABA2:
        jmp    LAED8
LABA5:
        lda    #$40
        rts

; =LOG numeric
; ============
LABA8:
        jsr    LA7FE
        ldy    #LA869 & 255
        lda    #LA869 / 256
        bne    LABB8

; =RAD numeric
; ============
LABB1:
        jsr    L92FA
        ldy    #LAA68 & 255
        lda    #LAA68 / 256
LABB8:
        sty    $4B
        sta    $4C
        jsr    LA656
        lda    #$FF
        rts

; =DEG numeric
; ============
LABC2:
        jsr    L92FA
        ldy    #LAA6D & 255
        lda    #LAA6D / 256
        bne    LABB8

; =PI
; ===
LABCB:
        jsr    LA8FE
        inc    $30
        tay
        rts

; =USR numeric
; ============
LABD2:
        jsr    L92E3
        jsr    L8F1E
        sta    $2A
        stx    $2B
        sty    $2C
        php
        pla
        sta    $2D
        cld
        lda    #$40
        rts
LABE6:
        jmp    L8C0E

; =EVAL string$ - Tokenise and evaluate expression
; ================================================
LABE9:
        jsr    LADEC            ; Evaluate value
        bne    LABE6            ; Error if not string
        inc    $36              ; Increment string length to add a <cr>
        ldy    $36
        lda    #$0D             ; Put in terminating <cr>
        sta    $05FF,y
        jsr    LBDB2            ; Stack the string
                                ; String has to be stacked as otherwise would
                                ; be overwritten by any string operations
                                ; called by Evaluator
        lda    $19              ; Save PTRB
        pha
        lda    $1A
        pha
        lda    $1B
        pha
        ldy    $04              ; YX=>stackbottom (wrong way around)
        ldx    $05
        iny                     ; Step over length byte
        sty    $19              ; PTRB=>stacked string
        sty    $37              ; GPTR=>stacked string
        bne    LAC0F
        inx
LAC0F:
        stx    $1A              ; PTRB and GPTR high bytes
        stx    $38
        ldy    #$FF
        sty    $3B
        iny                     ; Point PTRB offset back to start
        sty    $1B
        jsr    L8955            ; Tokenise string on stack at GPTR
        jsr    L9B29            ; Call expression evaluator
        jsr    LBDDC            ; Drop string from stack
LAC23:
        pla                     ; Restore PTRB
        sta    $1B
        pla
        sta    $1A
        pla
        sta    $19
        lda    $27              ; Get expression return value
        rts                     ; And return

; =VAL numeric
; ============
LAC2F:
        jsr    LADEC
        bne    LAC9B
LAC34:
        ldy    $36
        lda    #$00
        sta    $0600,y
        lda    $19
        pha
        lda    $1A
        pha
        lda    $1B
        pha
        lda    #$00
        sta    $1B
        lda    #$00
        sta    $19
        lda    #$06
        sta    $1A
        jsr    L8A8C
        cmp    #$2D
        beq    LAC66
        cmp    #$2B
        bne    LAC5E
        jsr    L8A8C
LAC5E:
        dec    $1B
        jsr    LA07B
        jmp    LAC73
LAC66:
        jsr    L8A8C
        dec    $1B
        jsr    LA07B
        bcc    LAC73
        jsr    LAD8F
LAC73:
        sta    $27
        jmp    LAC23

; =INT numeric
; ============
LAC78:
        jsr    LADEC
        beq    LAC9B
        bpl    LAC9A
        lda    $2E
        php
        jsr    LA3FE
        plp
        bpl    LAC95
        lda    $3E
        ora    $3F
        ora    $40
        ora    $41
        beq    LAC95
        jsr    LA4C7
LAC95:
        jsr    LA3E7
        lda    #$40
LAC9A:
        rts

LAC9B:
        jmp    L8C0E

; =ASC string$
; ============
LAC9E:
        jsr    LADEC
        bne    LAC9B
        lda    $36
        beq    LACC4
        lda    $0600
LACAA:
        jmp    LAED8

; =INKEY numeric
; ==============
LACAD:
        jsr    LAFAD
        cpy    #$00
        bne    LACC4
        txa
        jmp    LAEEA

; =EOF#numeric
; ============
LACB8:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    LBFB5
        tax
        lda    #$7F
        jsr    OSBYTE
        txa
        beq    LACAA
.endif

; =TRUE
; =====
LACC4:
        lda    #$FF
LACC6:
        sta    $2A
        sta    $2B
        sta    $2C
        sta    $2D
LACC8:
        lda    #$40
        rts

; =NOT numeric
; ============
LACD1:
        jsr    L92E3
        ldx    #$03
LACD6:
        lda    $2A,x
        eor    #$FF
        sta    $2A,x
        dex
        bpl    LACD6
        lda    #$40
        rts

; =INSTR(string$, string$ [, numeric])
; ====================================
LACE2:
        jsr    L9B29
        bne    LAC9B
        cpx    #$2C
        bne    LAD03
        inc    $1B
        jsr    LBDB2
        jsr    L9B29
        bne    LAC9B
        lda    #$01
        sta    $2A
        inc    $1B
        cpx    #')'
        beq    LAD12
        cpx    #$2C
        beq    LAD06
LAD03:
        jmp    L8AA2
LAD06:
        jsr    LBDB2
        jsr    LAE56
        jsr    L92F0
        jsr    LBDCB
LAD12:
        ldy    #$00
        ldx    $2A
        bne    LAD1A
        ldx    #$01
LAD1A:
        stx    $2A
        txa
        dex
        stx    $2D
        clc
        adc    $04
        sta    $37
        tya
        adc    $05
        sta    $38
        lda    ($04),y
        sec
        sbc    $2D
        bcc    LAD52
        sbc    $36
        bcc    LAD52
        adc    #$00
        sta    $2B
        jsr    LBDDC
LAD3C:
        ldy    #$00
        ldx    $36
        beq    LAD4D
LAD42:
        lda    ($37),y
        cmp    $0600,y
        bne    LAD59
        iny
        dex
        bne    LAD42
LAD4D:
        lda    $2A
LAD4F:
        jmp    LAED8
LAD52:
        jsr    LBDDC
LAD55:
        lda    #$00
        beq    LAD4F
LAD59:
        inc    $2A
        dec    $2B
        beq    LAD55
        inc    $37
        bne    LAD3C
        inc    $38
        bne    LAD3C
LAD67:
        jmp    L8C0E

; =ABS numeric
; ============
LAD6A:
        jsr    LADEC
        beq    LAD67
        bmi    LAD77
LAD71:
        bit    $2D
        bmi    LAD93
        bpl    LADAA
LAD77:
        jsr    LA1DA
        bpl    LAD89
        bmi    LAD83
LAD7E:
        jsr    LA1DA
        beq    LAD89
LAD83:
        lda    $2E
        eor    #$80
        sta    $2E
LAD89:
        lda    #$FF
        rts
LAD8C:
        jsr    LAE02
LAD8F:
        beq    LAD67
        bmi    LAD7E
LAD93:
        sec
        lda    #$00
        tay
        sbc    $2A
        sta    $2A
        tya
        sbc    $2B
        sta    $2B
        tya
        sbc    $2C
        sta    $2C
        tya
        sbc    $2D
        sta    $2D
LADAA:
        lda    #$40
        rts
LADAD:
        jsr    L8A8C
        cmp    #$22
         beq    LADC9
         ldx    #$00
LADB6:
        lda    ($19),y
        sta    $0600,x
        iny
        inx
        cmp    #$0D
        beq    LADC5
        cmp    #$2C
        bne    LADB6
LADC5:
        dey
        jmp    LADE1
LADC9:
        ldx    #$00
LADCB:
        iny
LADCC:
        lda    ($19),y
        cmp    #$0D
        beq    LADE9
        iny
        sta    $0600,x
        inx
        cmp    #$22
        bne    LADCC
        lda    ($19),y
        cmp    #$22
        beq    LADCB
LADE1:
        dex
        stx    $36
        sty    $1B
        lda    #$00
        rts
LADE9:
        jmp    L8E98

; Evaluator Level 1, - + NOT function ( ) ? ! $ | "
; -------------------------------------------------
LADEC:
        ldy    $1B              ; Get next character
        inc    $1B
        lda    ($19),y
        cmp    #$20             ; Loop to skip spaces
        beq    LADEC
        cmp    #'-'             ; Jump with unary minus
        beq    LAD8C
        cmp    #'"'             ; Jump with string
        beq    LADC9
        cmp    #'+'             ; Jump with unary plus
        bne    LAE05
LAE02:
        jsr    L8A8C            ; Get current character
LAE05:
        cmp    #$8E             ; Lowest function token, test for indirections
        bcc    LAE10
        cmp    #$C6             ; Highest function token, jump to error
        bcs    LAE43
        jmp    L8BB1            ; Jump via function dispatch table

; Indirection, hex, brackets
; --------------------------
LAE10:
        cmp    #'?'             ; Jump with ?numeric or higher
        bcs    LAE20
        cmp    #'.'             ; Jump with .numeric or higher
        bcs    LAE2A
        cmp    #'&'             ; Jump with hex number
        beq    LAE6D
        cmp    #'('             ; Jump with brackets
        beq    LAE56
LAE20:
        dec    $1B
        jsr    L95DD
        beq    LAE30            ; Jump with undefined variable or bad name
        jmp    LB32C
LAE2A:
        jsr    LA07B
        bcc    LAE43
        rts
LAE30:
        lda    $28              ; Check assembler option
        and    #$02             ; Is 'ignore undefined variables' set?
        bne    LAE43            ; b1=1, jump to give No such variable
        bcs    LAE43            ; Jump with bad variable name
        stx    $1B
LAE3A:
        lda    $0440            ; Use P% for undefined variable
        ldy    $0441
        jmp    LAEEA            ; Jump to return 16-bit integer

LAE43:
        brk
        .byte  $1A, "No such variable"
LAE54:
        brk
LAE56:
        jsr    L9B29
        inc    $1B
        cpx    #')'
        bne    LAE61
        tay
        rts
LAE61:
        brk
        .byte  $1B, "Missing )"
        brk
LAE6D:
        ldx    #$00
        stx    $2A
        stx    $2B
        stx    $2C
        stx    $2D
        ldy    $1B
LAE79:
        lda    ($19),y
        cmp    #$30
        bcc    LAEA2
        cmp    #$3A
        bcc    LAE8D
        sbc    #$37
        cmp    #$0A
        bcc    LAEA2
        cmp    #$10
        bcs    LAEA2
LAE8D:
        asl    a
        asl    a
        asl    a
        asl    a
        ldx    #$03
LAE93:
        asl    a
        rol    $2A
        rol    $2B
        rol    $2C
        rol    $2D
        dex
        bpl    LAE93
        iny
        bne    LAE79
LAEA2:
        txa
        bpl    LAEAA
        sty    $1B
        lda    #$40
        rts
LAEAA:
        brk
        .byte   $1C, "Bad HEX"
        brk

; =TIME - Read system TIME
; ========================
LAEB4:
        ldx    #$2A             ; Point to integer accumulator
        ldy    #$00
        lda    #$01             ; Read TIME to IntA via OSWORD &01
        jsr    OSWORD
        lda    #$40             ; Return 'integer'
        rts

; =PAGE - Read PAGE
; =================
LAEC0:
        lda    #$00
        ldy    $18
        jmp    LAEEA
LAEC7:
        jmp    LAE43

; =FALSE
; ======
LAECA:
        lda    #$00             ; Jump to return &00 as 16-bit integer
        beq    LAED8
LAECE:
        jmp    L8C0E

; =LEN string$
; ============
LAED1:
        jsr    LADEC
        bne    LAECE
        lda    $36

; Return 8-bit integer
; --------------------
LAED8:
        ldy    #$00             ; Clear b8-b15, jump to return 16-bit int
        beq    LAEEA

; =TOP - Return top of program
; ============================
LAEDC:
        ldy    $1B
        lda    ($19),y
        cmp    #$50
        bne    LAEC7
        inc    $1B
        lda    $12
        ldy    $13

; Return 16-bit integer in AY
; ---------------------------
LAEEA:
        sta    $2A              ; Store AY in integer accumulator
        sty    $2B
        lda    #$00             ; Set b16-b31 to 0
        sta    $2C
        sta    $2D
        lda    #$40             ; Return 'integer'
        rts

; =COUNT - Return COUNT
; =====================
LAEF7:
        lda    $1E              ; Get COUNT, jump to return 8-bit integer
        jmp    LAED8

; =LOMEM - Start of BASIC heap
; ============================
LAEFC:
        lda    $00              ; Get LOMEM to AY, jump to return as integer
        ldy    $01
        jmp    LAEEA

; =HIMEM - Top of BASIC memory
; ============================
LAF03:
       lda    $06               ; Get HIMEM to AY, jump to return as integer
       ldy    $07
       jmp    LAEEA

; =RND(numeric)
; -------------
LAF0A:
        inc    $1B
        jsr    LAE56
        jsr    L92F0
        lda    $2D
        bmi    LAF3F
        ora    $2C
        ora    $2B
        bne    LAF24
        lda    $2A
        beq    LAF6C
        cmp    #$01
        beq    LAF69
LAF24:
        jsr    LA2BE
        jsr    LBD51
        jsr    LAF69
        jsr    LBD7E
        jsr    LA606
        jsr    LA303
        jsr    LA3E4
        jsr    L9222
        lda    #$40
        rts
LAF3F:
        ldx    #$0D
        jsr    LBE44
        lda    #$40
        sta    $11
        rts

; RND [(numeric)]
; ===============
LAF49:
        ldy    $1B              ; Get current character
        lda    ($19),y
        cmp    #'('             ; Jump with RND(numeric)
        beq    LAF0A
        jsr    LAF87            ; Get random number
        ldx    #$0D
LAF56:
        lda    $00,x            ; Copy random number to IntA
        sta    $2A
        lda    $01,x
        sta    $2B
        lda    $02,x
        sta    $2C
        lda    $03,x
        sta    $2D
        lda    #$40             ;Return Integer
        rts
LAF69:
        jsr    LAF87
LAF6C:
        ldx    #$00
        stx    $2E
        stx    $2F
        stx    $35
        lda    #$80
        sta    $30
LAF78:
        lda    $0D,x
        sta    $31,x
        inx
        cpx    #$04
        bne    LAF78
        jsr    LA659
        lda    #$FF
        rts
LAF87:
        ldy    #$20
LAF89:
        lda    $0F
        lsr    a
        lsr    a
        lsr    a
        eor    $11
        ror    a
        rol    $0D
        rol    $0E
        rol    $0F
        rol    $10
        rol    $11
        dey
        bne    LAF89
        rts

; =ERL - Return error line number
; ===============================
LAF9F:
        ldy    $09              ; Get ERL to AY, jump to return 16-bit integer
        lda    $08
        jmp    LAEEA

;ERR - Return current error number
; ==================================
LAFA6:
        ldy    #$00             ; Get error number, jump to return 16-bit integer
        lda    (FAULT),y
        jmp    LAEEA

; INKEY
; =====
LAFAD:
        jsr    L92E3            ; Evaluate <numeric>

; BBC - Call MOS to wait for keypress
; -----------------------------------
        lda    #$81
LAFB2:
        ldx    $2A
        ldy    $2B
        jmp    OSBYTE

; =GET
; ====
LAFB9:
        jsr    OSRDCH
        jmp    LAED8

; =GET$
; =====
LAFBF:
        jsr    OSRDCH
LAFC2:
        sta    $0600
        lda    #$01
        sta    $36
        lda    #$00
        rts

; =LEFT$(string$, numeric)
; ========================
LAFCC:
        jsr    L9B29
        bne    LB033
        cpx    #$2C
        bne    LB036
        inc    $1B
        jsr    LBDB2
        jsr    LAE56
        jsr    L92F0
        jsr    LBDCB
        lda    $2A
        cmp    $36
        bcs    LAFEB
        sta    $36
LAFEB:
        lda    #$00
        rts

; =RIGHT$(string$, numeric)
; =========================
LAFEE:
        jsr    L9B29
        bne    LB033
        cpx    #$2C
        bne    LB036
        inc    $1B
        jsr    LBDB2
        jsr    LAE56
        jsr    L92F0
        jsr    LBDCB
        lda    $36
        sec
        sbc    $2A
        bcc    LB023
        beq    LB025
        tax
        lda    $2A
        sta    $36
        beq    LB025
        ldy    #$00
LB017:
        lda    $0600,x
        sta    $0600,y
        inx
        iny
        dec    $2A
        bne    LB017
LB023:
        lda    #$00
LB025:
        rts

; =INKEY$ numeric
; ===============
LB026:
        jsr    LAFAD
        txa
        cpy    #$00
        beq    LAFC2
LB02E:
        lda    #$00
        sta    $36
        rts
LB033:
        jmp    L8C0E
LB036:
        jmp    L8AA2

; =MID$(string$, numeric [, numeric] )
; ====================================
LB039:
        jsr    L9B29
        bne    LB033
        cpx    #$2C
        bne    LB036
        jsr    LBDB2
        inc    $1B
        jsr    L92DD
        lda    $2A
        pha
        lda    #$FF
        sta    $2A
        inc    $1B
        cpx    #')'
        beq    LB061
        cpx    #$2C
        bne    LB036
        jsr    LAE56
        jsr    L92F0
LB061:
        jsr    LBDCB
        pla
        tay
        clc
        beq    LB06F
        sbc    $36
        bcs    LB02E
        dey
        tya
LB06F:
        sta    $2C
        tax
        ldy    #$00
        lda    $36
        sec
        sbc    $2C
        cmp    $2A
        bcs    LB07F
        sta    $2A
LB07F:
        lda    $2A
        beq    LB02E
LB083:
        lda    $0600,x
        sta    $0600,y
        iny
        inx
        cpy    $2A
        bne    LB083
        sty    $36
        lda    #$00
        rts

; =STR$ [~] numeric
; =================
LB094:
        jsr    L8A8C            ; Skip spaces
        ldy    #$FF             ; Y=&FF for decimal
        cmp    #'~'
        beq    LB0A1
        ldy    #$00             ; Y=&00 for hex, step past ~
        dec    $1B
LB0A1:
        tya                     ; Save format
        pha
        jsr    LADEC            ; Evaluate, error if not number
        beq    LB0BF
        tay
        pla                     ; Get format back
        sta    $15
        lda    $0403            ; Top byte of @%, STR$ uses @%
        bne    LB0B9
        sta    $37              ; Store 'General format'
        jsr    L9EF9            ; Convert using general format
        lda    #$00             ; Return string
        rts
LB0B9:
        jsr    L9EDF            ; Convert using @% format
        lda    #$00             ; Return string
        rts
LB0BF:
        jmp    L8C0E            ; Jump to Type mismatch error

; =STRING$(numeric, string$)
; ==========================
LB0C2:
        jsr    L92DD
        jsr    LBD94
        jsr    L8AAE
        jsr    LAE56
        bne    LB0BF
        jsr    LBDEA
        ldy    $36
        beq    LB0F5
        lda    $2A
        beq    LB0F8
        dec    $2A
        beq    LB0F5
LB0DF:
        ldx    #$00
LB0E1:
        lda    $0600,x
        sta    $0600,y
        inx
        iny
        beq    LB0FB
        cpx    $36
        bcc    LB0E1
        dec    $2A
        bne    LB0DF
        sty    $36
LB0F5:
        lda    #$00
        rts
LB0F8:
        sta    $36
        rts
LB0FB:
        jmp    L9C03
LB0FE:
        pla
        sta    $0C
        pla
        sta    $0B
        brk
        .byte  $1D, "No such ", tknFN, "/", tknPROC
        brk
; Look through program for FN/PROC
; --------------------------------
LB112:
        lda    $18             ; Start at PAGE
        sta    $0C
        lda    #$00
 sta    $0B
LB11A:
        ldy    #$01             ; Get line number high byte
        lda    ($0B),y
        bmi    LB0FE            ; End of program, jump to 'No such FN/PROC' error
        ldy    #$03
LB122:
        iny
        lda    ($0B),y
        cmp    #' '             ; Skip past spaces
        beq    LB122
        cmp    #tknDEF          ; Found DEF at start of lien
        beq    LB13C
LB12D:
        ldy    #$03             ; Get line length
        lda    ($0B),y
        clc                     ; Point to next line
        adc    $0B
        sta    $0B
        bcc    LB11A
        inc    $0C
        bcs    LB11A            ; Loop back to check next line
LB13C:
        iny
        sty    $0A
        jsr    L8A97
        tya
        tax
        clc
        adc    $0B
        ldy    $0C
        bcc    LB14D
        iny
        clc
LB14D:
        sbc    #$00
        sta    $3C
        tya
        sbc    #$00
        sta    $3D
        ldy    #$00
LB158:
        iny
        inx
        lda    ($3C),y
        cmp    ($37),y
        bne    LB12D
        cpy    $39
        bne    LB158
        iny
        lda    ($3C),y
        jsr    L8926
        bcs    LB12D
        txa
        tay
        jsr    L986D
        jsr    L94ED
        ldx    #$01
        jsr    L9531
        ldy    #$00
        lda    $0B
        sta    ($02),y
        iny
        lda    $0C
        sta    ($02),y
        jsr    L9539
        jmp    LB1F4
LB18A:
        brk
        .byte  $1E, "Bad call"
        brk

; =FNname [parameters]
; ====================
LB195:
        lda    #$A4             ; 'FN' token

; Call subroutine
; ---------------
; A=FN or PROC
; PtrA=>start of FN/PROC name
;
LB197:
        sta    $27              ; Save PROC/FN token
        tsx                     ; Drop BASIC stack by size of 6502 stack
        txa
        clc
        adc    $04
        jsr    LBE2E            ; Store new BASIC stack pointer, check for No Room
        ldy    #$00             ; Store 6502 Stack Pointer on BASIC stack
        txa
        sta    ($04),y
LB1A6:
        inx
        iny
        lda    $0100,x          ; Copy 6502 stack onto BASIC stack
        sta    ($04),y
        cpx    #$FF
        bne    LB1A6
        txs                     ; Clear 6502 stack
        lda    $27              ; Push PROC/FN token
        pha
        lda    $0A              ; Push PtrA line pointer
        pha
        lda    $0B
        pha
        lda    $0C              ; Push PtrA line pointer offset
        pha
        lda    $1B
        tax
        clc
        adc    $19
        ldy    $1A
        bcc    LB1CA
LB1C8:
        iny
        clc
LB1CA:
        sbc    #$01
        sta    $37
        tya                     ; &37/8=>PROC token
        sbc    #$00
        sta    $38
        ldy    #$02             ; Check name is valid
        jsr    L955B
        cpy    #$02             ; No valid characters, jump to 'Bad call' error
        beq    LB18A
        stx    $1B              ; Line pointer offset => after valid FN/PROC name
        dey
        sty    $39
        jsr    L945B            ; Look for FN/PROC name in heap, if found, jump to it
        bne    LB1E9
        jmp    LB112            ; Not in heap, jump to look through program

; FN/PROC destination found
; -------------------------
LB1E9:
        ldy    #$00             ; Set PtrA to address from FN/PROC infoblock
        lda    ($2A),y
        sta    $0B
        iny
        lda    ($2A),y
        sta    $0C
LB1F4:
        lda    #$00             ; Push 'no parameters' (?)
        pha
        sta    $0A
        jsr    L8A97
        cmp    #'('
        beq    LB24D
        dec    $0A
LB202:
        lda    $1B
        pha
        lda    $19
        pha
        lda    $1A
        pha
        jsr    L8BA3
        pla
        sta    $1A
        pla
        sta    $19
        pla
        sta    $1B
        pla
        beq    LB226
        sta    $3F
LB21C:
        jsr    LBE0B
        jsr    L8CC1
        dec    $3F
        bne    LB21C
LB226:
        pla
        sta    $0C
        pla
        sta    $0B
        pla
        sta    $0A
        pla
        ldy    #$00
        lda    ($04),y
        tax
        txs
LB236:
        iny
        inx
        lda    ($04),y          ; Copy stacked 6502 stack back onto 6502 stack
        sta    $0100,x
        cpx    #$FF
        bne    LB236
        tya                     ; Adjust BASIC stack pointer
        adc    $04
        sta    $04
        bcc    LB24A
        inc    $05
LB24A:
        lda    $27
        rts
LB24D:
        lda    $1B
        pha
        lda    $19
        pha
        lda    $1A
        pha
        jsr    L9582
        beq    LB2B5
        lda    $1B
        sta    $0A
        pla
        sta    $1A
        pla
        sta    $19
        pla
        sta    $1B
        pla
        tax
        lda    $2C
        pha
        lda    $2B
        pha
        lda    $2A
        pha
        inx
        txa
        pha
        jsr    LB30D
        jsr    L8A97
        cmp    #','
        beq    LB24D
        cmp    #')'
        bne    LB2B5
        lda    #$00
        pha
        jsr    L8A8C
        cmp    #'('
        bne    LB2B5
LB28E:
        jsr    L9B29
        jsr    LBD90
        lda    $27
        sta    $2D
        jsr    LBD94
        pla
        tax
        inx
        txa
        pha
        jsr    L8A8C
        cmp    #$2C
        beq    LB28E
        cmp    #$29
        bne    LB2B5
        pla
        pla
        sta    $4D
        sta    $4E
        cpx    $4D
        beq    LB2CA
LB2B5:
        ldx    #$FB
        txs
        pla
        sta    $0C
        pla
        sta    $0B
        brk
        .byte  $1F, "Arguments"
        brk
LB2CA:
        jsr    LBDEA
        pla
        sta    $2A
        pla
        sta    $2B
        pla
        sta    $2C
        bmi    LB2F9
        lda    $2D
        beq    LB2B5
        sta    $27
        ldx    #$37
        jsr    LBE44
        lda    $27
        bpl    LB2F0
        jsr    LBD7E
        jsr    LA3B5
        jmp    LB2F3
LB2F0:
        jsr    LBDEA
LB2F3:
        jsr    LB4B7
        jmp    LB303
LB2F9:
        lda    $2D
        bne    LB2B5
        jsr    LBDCB
        jsr    L8C21
LB303:
        dec    $4D
        bne    LB2CA
        lda    $4E
        pha
        jmp    LB202
; Push a value onto the stack
; ---------------------------
LB30D:
        ldy    $2C
        cpy    #$04
        bne    LB318
        ldx    #$37
        jsr    LBE44
LB318:
        jsr    LB32C
        php
        jsr    LBD90
        plp
        beq    LB329
        bmi    LB329
        ldx    #$37
        jsr    LAF56
LB329:
        jmp    LBD94
LB32C:
        ldy    $2C
        bmi    LB384
        beq    LB34F
        cpy    #$05
        beq    LB354
        ldy    #$03
        lda    ($2A),y
        sta    $2D
        dey
        lda    ($2A),y
        sta    $2C
        dey
        lda    ($2A),y
        tax
        dey
        lda    ($2A),y
        sta    $2A
        stx    $2B
        lda    #$40
        rts
LB34F:
        lda    ($2A),y
        jmp    LAEEA
LB354:
        dey
        lda    ($2A),y
        sta    $34
        dey
        lda    ($2A),y
        sta    $33
        dey
        lda    ($2A),y
        sta    $32
        dey
        lda    ($2A),y
        sta    $2E
        dey
        lda    ($2A),y
        sta    $30
        sty    $35
        sty    $2F
        ora    $2E
        ora    $32
        ora    $33
        ora    $34
        beq    LB37F
        lda    $2E
        ora    #$80
LB37F:
        sta    $31
        lda    #$FF
        rts
LB384:
        cpy    #$80
        beq    LB3A7
        ldy    #$03
        lda    ($2A),y
        sta    $36
        beq    LB3A6
        ldy    #$01
        lda    ($2A),y
        sta    $38
        dey
        lda    ($2A),y
        sta    $37
        ldy    $36
LB39D:
        dey
        lda    ($37),y
        sta    $0600,y
        tya
        bne    LB39D
LB3A6:
        rts
LB3A7:
        lda    $2B
        beq    LB3C0
LB3AB:
        ldy    #$00
LB3AD:
        lda    ($2A),y
        sta    $0600,y
        eor    #$0D
        beq    LB3BA
        iny
        bne    LB3AD
        tya
LB3BA:
        sty    $36
        rts

; =CHR$ numeric
; =============
LB3BD:
        jsr    L92E3
LB3C0:
        lda    $2A
        jmp    LAFC2
LB3C5:
        ldy    #$00
        sty    $08
        sty    $09
        ldx    $18
        stx    $38
        sty    $37
        ldx    $0C
        cpx    #$07
        beq    LB401
        ldx    $0B
LB3D9:
        jsr    L8942
        cmp    #$0D
        bne    LB3F9
        cpx    $37
        lda    $0C
        sbc    $38
        bcc    LB401
        jsr    L8942
        ora    #$00
        bmi    LB401
        sta    $09
        jsr    L8942
        sta    $08
        jsr    L8942
LB3F9:
        cpx    $37
        lda    $0C
        sbc    $38
        bcs    LB3D9
LB401:
        rts

; ERROR HANDLER
; =============
LB402:

; FAULT set up, now process BRK error
; -----------------------------------
        jsr    LB3C5
        sty    $20
        lda    (FAULT),Y        ; If ERR<>0, skip past ON ERROR OFF
        bne    LB413
        lda    #LB433 & 255     ; ON ERROR OFF
        sta    $16
        lda    #LB433 / 256
        sta    $17
LB413:
        lda    $16              ; Point program point to ERROR program
        sta    $0B
        lda    $17
        sta    $0C
        jsr    LBD3A            ; Clear DATA and stack
        tax
        stx    $0A
        lda    #$DA             ; Clear VDU queue
        jsr    OSBYTE
        lda    #$7E             ; Acknowledge any Escape state
        jsr    OSBYTE
        ldx    #$FF             ; Clear system stack
        stx    $28
        txs
        jmp    L8BA3            ; Jump to execution loop
LD428:

; Default ERROR program
; ---------------------
LB433:
        .byte  tknREPORT, ":", tknIF, tknERL
        .byte  tknPRINT, '"', " at line ", '"', ';', tknERL, ':', tknEND
        .byte  tknELSE, tknPRINT, ":"
        .byte  tknEND, 13

; SOUND numeric, numeric, numeric, numeric
; ========================================
LB44C:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    L8821            ; Evaluate integer
        ldx    #$03             ; Three more to evaluate
LB451:
        lda    $2A              ; Stack current 16-bit integer
        pha
        lda    $2B
        pha
        txa
        pha
        jsr    L92DA
        pla
        tax
        dex
        bne    LB451
        jsr    L9852
        lda    $2A
        sta    $3D
        lda    $2B
        sta    $3E
        ldy    #$07
        ldx    #$05
        bne    LB48F
.endif

; ENVELOPE a,b,c,d,e,f,g,h,i,j,k,l,m,n
; ====================================
LB472:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    L8821            ; Evaluate integer
        ldx    #$0D             ; 13 more to evaluate
LB477:
        lda    $2A              ; Stack current 8-bit integer
        pha
        txa                     ; Step past comma, evaluate next integer
        pha
        jsr    L92DA
        pla                     ; Loop to stack this one
        tax
        dex
        bne    LB477
LB484:
        jsr    L9852            ; Check end of statement
        lda    $2A              ; Copy current 8-bit integer to end of control block
        sta    $44
        ldx    #$0C             ; Prepare for 12 more bytes and OSWORD 8
        ldy    #$08
LB48F:
        pla                     ; Pop bytes into control block
        sta    $37,x
        dex
        bpl    LB48F
        tya                     ; Y=OSWORD number
        ldx    #$37             ; XY=>control block
        ldy    #$00
        jsr    OSWORD
        jmp    L8B9B            ; Return to execution loop
.endif

; WIDTH numeric
; =============
LB4A0:
        jsr    L8821
        jsr    L9852
        ldy    $2A
        dey
        sty    $23
        jmp    L8B9B
LB4AE:
        jmp    L8C0E

; Store byte or word integer
; ==========================
LB4B1:
        jsr    L9B29            ; Evaluate expression
LB4B4:
        jsr    LBE0B            ; Unstack integer (address of data)
LB4B7:
        lda    $39
        cmp    #$05             ; Size=5, jump to store float
        beq    LB4E0
        lda    $27              ; Type<>num, jump to error
        beq    LB4AE
        bpl    LB4C6            ; Type=int, jump to store it
        jsr    LA3E4            ; Convert float to integer
LB4C6:
        ldy    #$00
        lda    $2A              ; Store byte 1
        sta    ($37),y
        lda    $39              ; Exit if size=0, byte
        beq    LB4DF
        lda    $2B              ; Store byte 2
        iny
        sta    ($37),y
        lda    $2C              ; Store byte 3
        iny
        sta    ($37),y
        lda    $2D              ; Store byte 4
        iny
        sta    ($37),y
LB4DF:
        rts

; Store float
; ===========
LB4E0:
        lda    $27              ; Type<>num, jump to error
        beq    LB4AE
        bmi    LB4E9            ; Type=float, jump to store it
        jsr    LA2BE            ; Convert integer to float
LB4E9:
        ldy    #$00             ; Store 5-byte float
        lda    $30              ; exponent
        sta    ($37),y
        iny
        lda    $2E              ; Unpack sign
        and    #$80
        sta    $2E
        lda    $31              ; Unpack mantissa 1
        and    #$7F
        ora    $2E              ; sign + mantissa 1
        sta    ($37),y
        iny                     ; mantissa 2
        lda    $32
        sta    ($37),y
        iny                     ; mantissa 3
        lda    $33
        sta    ($37),y
        iny                     ; mantissa 3
        lda    $34
        sta    ($37),y
        rts
LB500:
LB50E:
        sta    $37
        cmp    #$80
        bcc    LB558
        lda    #L8071 & 255     ; Point to token table
        sta    $38
        lda    #L8071 / 256
        sta    $39
        sty    $3A
LB51E:
        ldy    #$00
LB520:
        iny
        lda    ($38),y
        bpl    LB520
        cmp    $37
        beq    LB536
        iny
        tya
        sec
        adc    $38
        sta    $38
        bcc    LB51E
        inc    $39
        bcs    LB51E
LB536:
        ldy    #$00
LB538:
        lda    ($38),y
        bmi    LB542
        jsr    LB558
        iny
        bne    LB538
LB542:
        ldy    $3A
        rts
LB545:
        pha
        lsr    a
        lsr    a
        lsr    a
        lsr    a
        jsr    LB550
        pla
        and    #$0F
LB550:
        cmp    #$0A
        bcc    LB556
        adc    #$06
LB556:
        adc    #$30
LB558:
        cmp    #$0D
        bne    LB567
        jsr    OSWRCH
        jmp    LBC28
LB562:
        jsr    LB545
LB565:
        lda    #$20
LB567:
        pha
        lda    $23
        cmp    $1E
        bcs    LB571
        jsr    LBC25
LB571:
        pla
        inc    $1E
        jmp    (WRCHV)
LB577:
        and    $1F
        beq    LB589
        txa
        beq    LB589
        bmi    LB565
LB580:
        jsr    LB565
        jsr    LB558
        dex
        bne    LB580
LB589:
        rts
LB58A:
        inc    $0A
        jsr    L9B1D
        jsr    L984C
        jsr    L92EE
        lda    $2A
        sta    $1F
        jmp    L8AF6

; LIST [linenum [,linenum]]
; =========================
LB59C:
        iny
        lda    ($0B),y
        cmp    #'O'
        beq    LB58A
        lda    #$00
        sta    $3B
        sta    $3C
        jsr    LAED8
        jsr    L97DF
        php
        jsr    LBD94
        lda    #$FF
        sta    $2A
        lda    #$7F
        sta    $2B
        plp
        bcc    LB5CF
        jsr    L8A97
        cmp    #','
        beq    LB5D8
        jsr    LBDEA
        jsr    LBD94
        dec    $0A
        bpl    LB5DB
LB5CF:
        jsr    L8A97
        cmp    #','
        beq    LB5D8
        dec    $0A
LB5D8:
        jsr    L97DF
LB5DB:
        lda    $2A
        sta    $31
        lda    $2B
        sta    $32
        jsr    L9857
        jsr    LBE6F
        jsr    LBDEA
        jsr    L9970
        lda    $3D
        sta    $0B
        lda    $3E
        sta    $0C
        bcc    LB60F
        dey
        bcs    LB602
LB5FC:
        jsr    LBC25
        jsr    L986D
LB602:
        lda    ($0B),y
        sta    $2B
        iny
        lda    ($0B),y
        sta    $2A
        iny
        iny
        sty    $0A
LB60F:
        lda    $2A
        clc
        sbc    $31
        lda    $2B
        sbc    $32
        bcc    LB61D
        jmp    L8AF6
LB61D:
        jsr    L9923
        ldx    #$FF
        stx    $4D
        lda    #$01
        jsr    LB577
        ldx    $3B
        lda    #$02
        jsr    LB577
        ldx    $3C
        lda    #$04
        jsr    LB577
LB637:
        ldy    $0A
LB639:
        lda    ($0B),y
        cmp    #$0D
        beq    LB5FC
        cmp    #$22
        bne    LB651
        lda    #$FF
        eor    $4D
        sta    $4D
        lda    #$22
LB64B:
        jsr    LB558
        iny
        bne    LB639
LB651:
        bit    $4D
        bpl    LB64B
        cmp    #$8D
        bne    LB668
        jsr    L97EB
        sty    $0A
        lda    #$00
        sta    $14
        jsr    L991F
        jmp    LB637
LB668:
        cmp    #$E3
        bne    LB66E
        inc    $3B
LB66E:
        cmp    #$ED
        bne    LB678
        ldx    $3B
        beq    LB678
        dec    $3B
LB678:
        cmp    #$F5
        bne    LB67E
        inc    $3C
LB67E:
        cmp    #$FD
        bne    LB688
        ldx    $3C
        beq    LB688
        dec    $3C
LB688:
        jsr    LB50E
        iny
        bne    LB639
LB68E:
        brk
        .byte   $20, "No ", tknFOR
        brk

; NEXT [variable [,...]]
; ======================
LB695:
        jsr    L95C9
        bne    LB6A3
        ldx    $26
        beq    LB68E
        bcs    LB6D7
LB6A0:
        jmp    L982A
LB6A3:
        bcs    LB6A0
        ldx    $26
        beq    LB68E
LB6A9:
        lda    $2A
        cmp    $04F1,x
        bne    LB6BE
        lda    $2B
        cmp    $04F2,x
        bne    LB6BE
        lda    $2C
        cmp    $04F3,x
        beq    LB6D7
LB6BE:
        txa
        sec
        sbc    #$0F
        tax
        stx    $26
        bne    LB6A9
        brk
        .byte  $21, "Can't Match ", tknFOR
        brk
LB6D7:
        lda    $04F1,x
        sta    $2A
        lda    $04F2,x
        sta    $2B
        ldy    $04F3,x
        cpy    #$05
        beq    LB766
        ldy    #$00
        lda    ($2A),y
        adc    $04F4,x
        sta    ($2A),y
        sta    $37
        iny
        lda    ($2A),y
        adc    $04F5,x
        sta    ($2A),y
        sta    $38
        iny
        lda    ($2A),y
        adc    $04F6,x
        sta    ($2A),y
        sta    $39
        iny
        lda    ($2A),y
        adc    $04F7,x
        sta    ($2A),y
        tay
        lda    $37
        sec
        sbc    $04F9,x
        sta    $37
        lda    $38
        sbc    $04FA,x
        sta    $38
        lda    $39
        sbc    $04FB,x
        sta    $39
        tya
        sbc    $04FC,x
        ora    $37
        ora    $38
        ora    $39
        beq    LB741
        tya
        eor    $04F7,x
        eor    $04FC,x
        bpl    LB73F
        bcs    LB741
        bcc    LB751
LB73F:
        bcs    LB751
LB741:
        ldy    $04FE,x
        lda    $04FF,x
        sty    $0B
        sta    $0C
        jsr    L9877
        jmp    L8BA3
LB751:
        lda    $26
        sec
        sbc    #$0F
        sta    $26
        ldy    $1B
        sty    $0A
        jsr    L8A97
        cmp    #','
        bne    LB7A1
        jmp    LB695
LB766:
        jsr    LB354
        lda    $26
        clc
        adc    #$F4
        sta    $4B
        lda    #$05
        sta    $4C
        jsr    LA500
        lda    $2A
        sta    $37
        lda    $2B
        sta    $38
        jsr    LB4E9
        lda    $26
        sta    $27
        clc
        adc    #$F9
        sta    $4B
        lda    #$05
        sta    $4C
        jsr    L9A5F
        beq    LB741
        lda    $04F5,x
        bmi    LB79D
        bcs    LB741
        bcc    LB751
LB79D:
        bcc    LB741
        bcs    LB751
LB7A1:
        jmp    L8B96
LB7A4:
        brk
        .byte  $22, tknFOR, " variable"
LB7B0:
        brk
        .byte  $23, "Too many ", tknFOR, "s"
LB7BD:
        brk
        .byte  $24, "No ", tknTO
        brk

; FOR numvar = numeric TO numeric [STEP numeric]
; ==============================================
LB7C4:
        jsr    L9582
        beq    LB7A4
        bcs    LB7A4
        jsr    LBD94
        jsr    L9841
        jsr    LB4B1
        ldy    $26
        cpy    #$96
        bcs    LB7B0
        lda    $37
        sta    $0500,y
        lda    $38
        sta    $0501,y
        lda    $39
        sta    $0502,y
        tax
        jsr    L8A8C
        cmp    #$B8
        bne    LB7BD
        cpx    #$05
        beq    LB84F
        jsr    L92DD
        ldy    $26
        lda    $2A
        sta    $0508,y
        lda    $2B
        sta    $0509,y
        lda    $2C
        sta    $050A,y
        lda    $2D
        sta    $050B,y
        lda    #$01
        jsr    LAED8
        jsr    L8A8C
        cmp    #$88
        bne    LB81F
        jsr    L92DD
        ldy    $1B
LB81F:
        sty    $0A
        ldy    $26
        lda    $2A
        sta    $0503,y
        lda    $2B
        sta    $0504,y
        lda    $2C
        sta    $0505,y
        lda    $2D
        sta    $0506,y
LB837:
        jsr    L9880
        ldy    $26
        lda    $0B
        sta    $050D,y
        lda    $0C
        sta    $050E,y
        clc
        tya
        adc    #$0F
        sta    $26
        jmp    L8BA3
LB84F:
        jsr    L9B29
        jsr    L92FD
        lda    $26
        clc
        adc    #$08
        sta    $4B
        lda    #$05
        sta    $4C
        jsr    LA38D
        jsr    LA699
        jsr    L8A8C
        cmp    #$88
        bne    LB875
        jsr    L9B29
        jsr    L92FD
        ldy    $1B
LB875:
        sty    $0A
        lda    $26
        clc
        adc    #$03
        sta    $4B
        lda    #$05
        sta    $4C
        jsr    LA38D
        jmp    LB837

; GOSUB numeric
;=============
LB888:
        jsr    LB99A
LB88B:
        jsr    L9857
        ldy    $25
        cpy    #$1A
        bcs    LB8A2
        lda    $0B
        sta    $05CC,y
        lda    $0C
        sta    $05E6,y
        inc    $25
        bcc    LB8D2
LB8A2:
        brk
        .byte  $25, "Too many ", tknGOSUB, "s"
LB8AF:
        brk
        .byte  $26, "No ", tknGOSUB
        brk

; RETURN
; ======
LB8B6:
        jsr    L9857            ; Check for end of statement
        ldx    $25              ; If GOSUB stack empty, error
        beq    LB8AF
        dec    $25              ; Decrement GOSUB stack
        ldy    $05CB,x          ; Get stacked line pointer
        lda    $05E5,x
        sty    $0B              ; Set line pointer
        sta    $0C
        jmp    L8B9B            ; Jump back to execution loop

; GOTO numeric
; ============
LB8CC:
        jsr    LB99A            ; Find destination line, check for end of statement
        jsr    L9857
LB8D2:
        lda    $20              ; If TRACE ON, print current line number
        beq    LB8D9
        jsr    L9905
LB8D9:
        ldy    $3D              ; Get destination line address
        lda    $3E
LB8DD:
        sty    $0B              ; Set line pointer
        sta    $0C
        jmp    L8BA3            ; Jump back to execution loop

; ON ERROR OFF
; ------------
LB8E4:
        jsr    L9857            ; Check end of statement
        lda    #LB433 & 255     ; ON ERROR OFF
        sta    $16
        lda    #LB433 / 256
        sta    $17
        jmp    L8B9B            ; Jump to execution loop

; ON ERROR [OFF | program ]
; -------------------------
LB8F2:
        jsr    L8A97
        cmp    #tknOFF          ; ON ERROR OFF
        beq    LB8E4
        ldy    $0A
        dey
        jsr    L986D
        lda    $0B              ; Point ON ERROR pointer to here
        sta    $16
        lda    $0C
        sta    $17
        jmp    L8B7D            ; Skip past end of line
LB90A:
        brk
        .byte  $27, tknON, " syntax"
        brk

; ON [ERROR] [numeric]
; ====================
LB915:
        jsr    L8A97            ; Skip spaces and get next character
        cmp    #tknERROR        ; Jump with ON ERROR
        beq    LB8F2
        dec    $0A
        jsr    L9B1D
        jsr    L92F0
        ldy    $1B
        iny
        sty    $0A
        cpx    #tknGOTO
        beq    LB931
        cpx    #tknGOSUB
        bne    LB90A
LB931:
        txa                     ; Save GOTO/GOSUB token
        pha
        lda    $2B              ; Get IntA
        ora    $2C
        ora    $2D              ; ON >255 - out of range, look for an ELSE
        bne    LB97D
        ldx    $2A              ; ON zero - out of range, look for an ELSE
        beq    LB97D
        dex                     ; Dec. counter, if zero use first destination
        beq    LB95C
        ldy    $0A              ; Get line index
LB944:
        lda    ($0B),y
        iny
        cmp    #$0D             ; End of line - error
        beq    LB97D
        cmp    #':'             ; End of statement - error
        beq    LB97D
        cmp    #tknELSE         ; ELSE - drop everything else to here
        beq    LB97D
        cmp    #','             ; No comma, keep looking
        bne    LB944
        dex                     ; Comma found, loop until count decremented to zero
        bne    LB944
        sty    $0A              ; Store line index
LB95C:
        jsr    LB99A            ; Read line number
        pla                     ; Get stacked token back
        cmp    #tknGOSUB        ; Jump to do GOSUB
        beq    LB96A
        jsr    L9877            ; Update line index and check Escape
        jmp    LB8D2

; Update line pointer so RETURN comes back to next statement
; ----------------------------------------------------------
LB96A:
        ldy    $0A              ; Get line pointer
LB96C:
        lda    ($0B),y          ; Get character from line
        iny
        cmp    #$0D             ; End of line, RETURN to here
        beq    LB977
        cmp    #':'             ; <colon>, return to here
        bne    LB96C
LB977:
        dey                     ; Update line index to RETURN point
        sty    $0A
        jmp    LB88B            ; Jump to do the GOSUB

; ON num out of range - check for an ELSE clause
; ----------------------------------------------
LB97D:
        ldy    $0A              ; Get line index
        pla                     ; Drop GOTO/GOSUB token
LB980:
        lda    ($0B),y          ; Get character from line
        iny
        cmp    #tknELSE         ; Found ELSE, jump to use it
        beq    LB995
        cmp    #$0D             ; Loop until end of line
        bne    LB980
        brk
        .byte  $28, tknON, " range"
        brk
LB995:
        sty    $0A              ; Store line index and jump to GOSUB
        jmp    L98E3
LB99A:
        jsr    L97DF            ; Embedded line number found
        bcs    LB9AF
        jsr    L9B1D            ; Evaluate expression, ensure integer
        jsr    L92F0
        lda    $1B              ; Line number low byte
        sta    $0A
        lda    $2B              ; Line number high byte
        and    #$7F             ; Note - this makes goto &8000+10 the same as goto 10
        sta    $2B
LB9AF:
        jsr    L9970            ; Look for line, error if not found
        bcs    LB9B5
        rts
LB9B5:
        brk
        .byte  $29, "No such line"
        brk
LB9C4:
        jmp    L8C0E
LB9C7:
        jmp    L982A
LB9CA:
        sty    $0A
        jmp    L8B98

; INPUT #channel, ...
; -------------------
LB9CF:
        dec    $0A
        jsr    LBFA9
        lda    $1B
        sta    $0A
        sty    $4D
LB9DA:
        jsr    L8A97
        cmp    #','
        bne    LB9CA
        lda    $4D
        pha
        jsr    L9582
        beq    LB9C7
        lda    $1B
        sta    $0A
        pla
        sta    $4D
        php
        jsr    LBD94
        ldy    $4D
        jsr    OSBGET
        sta    $27
        plp
        bcc    LBA19
        lda    $27
        bne    LB9C4
        jsr    OSBGET
        sta    $36
        tax
        beq    LBA13
LBA0A:
        jsr    OSBGET
        sta    $05FF,x
        dex
        bne    LBA0A
LBA13:
        jsr    L8C1E
        jmp    LB9DA
LBA19:
        lda    $27
        beq    LB9C4
        bmi    LBA2B
        ldx    #$03
LBA21:
        jsr    OSBGET
        sta    $2A,x
        dex
        bpl    LBA21
        bmi    LBA39
LBA2B:
        ldx    #$04
LBA2D:
        jsr    OSBGET
        sta    $046C,x
        dex
        bpl    LBA2D
        jsr    LA3B2
LBA39:
        jsr    LB4B4
        jmp    LB9DA
LBA3F:
        pla
        pla
        jmp    L8B98

; INPUT [LINE] [print items][variables]
; =====================================
LBA44:
        jsr    L8A97            ; Get next non-space char
        cmp    #'#'             ; If '#' jump to do INPUT#
        beq    LB9CF
        cmp    #tknLINE         ; If 'LINE', skip next with CS
        beq    LBA52
        dec    $0A              ; Step back to non-LINE char, set CC
        clc
LBA52:
        ror    $4D              ; bit7=0, bit6=notLINE/LINE
        lsr    $4D
        lda    #$FF
        sta    $4E
LBA5A:
        jsr    L8E8A            ; Process ' " TAB SPC, jump if none found
        bcs    LBA69
LBA5F:
        jsr    L8E8A            ; Keep processing any print items
        bcc    LBA5F
        ldx    #$FF
        stx    $4E
        clc
LBA69:
        php
        asl    $4D
        plp
        ror    $4D
        cmp    #','             ; ',' - jump to do next item
        beq    LBA5A
        cmp    #';'             ; ';' - jump to do next item
        beq    LBA5A
        dec    $0A
        lda    $4D
        pha
        lda    $4E
        pha
        jsr    L9582
        beq    LBA3F
        pla
        sta    $4E
        pla
        sta    $4D
        lda    $1B
        sta    $0A
        php
        bit    $4D
        bvs    LBA99
        lda    $4E
        cmp    #$FF
        bne    LBAB0
LBA99:
        bit    $4D
        bpl    LBAA2
        lda    #'?'
        jsr    LB558
LBAA2:
        jsr    LBBFC
        sty    $36
        asl    $4D
        clc
        ror    $4D
        bit    $4D
        bvs    LBACD
LBAB0:
        sta    $1B
        lda    #$00
        sta    $19
        lda    #$06
        sta    $1A
        jsr    LADAD
LBABD:
        jsr    L8A8C
        cmp    #','
        beq    LBACA
        cmp    #$0D
        bne    LBABD
        ldy    #$FE
LBACA:
        iny
        sty    $4E
LBACD:
        plp
        bcs    LBADC
        jsr    LBD94
        jsr    LAC34
        jsr    LB4B4
        jmp    LBA5A
LBADC:
        lda    #$00
        sta    $27
        jsr    L8C21
        jmp    LBA5A

; RESTORE [linenum]
; =================
LBAE6:
        ldy    #$00             ; Set DATA pointer to PAGE
        sty    $3D
        ldy    $18
        sty    $3E
        jsr    L8A97
        dec    $0A
        cmp    #':'
        beq    LBB07
        cmp    #$0D
        beq    LBB07
        cmp    #tknELSE
        beq    LBB07
        jsr    LB99A
        ldy    #$01
        jsr    LBE55
LBB07:
        jsr    L9857
        lda    $3D
        sta    $1C
        lda    $3E
        sta    $1D
        jmp    L8B9B
LBB15:
        jsr    L8A97
        cmp    #','
        beq    LBB1F
        jmp    L8B96

; READ varname [,...]
; ===================
LBB1F:
        jsr    L9582
        beq    LBB15
        bcs    LBB32
        jsr    LBB50
        jsr    LBD94
        jsr    LB4B1
        jmp    LBB40
LBB32:
        jsr    LBB50
        jsr    LBD94
        jsr    LADAD
        sta    $27
        jsr    L8C1E
LBB40:
        clc
        lda    $1B
        adc    $19
        sta    $1C
        lda    $1A
        adc    #$00
        sta    $1D
        jmp    LBB15
LBB50:
        lda    $1B
        sta    $0A
        lda    $1C
        sta    $19
        lda    $1D
        sta    $1A
        ldy    #$00
        sty    $1B
        jsr    L8A8C
        cmp    #','
        beq    LBBB0
        cmp    #tknDATA
        beq    LBBB0
        cmp    #$0D
        beq    LBB7A
LBB6F:
        jsr    L8A8C
        cmp    #','
        beq    LBBB0
        cmp    #$0D
        bne    LBB6F
LBB7A:
        ldy    $1B
        lda    ($19),y
        bmi    LBB9C
        iny
        iny
        lda    ($19),y
        tax
LBB85:
        iny
        lda    ($19),y
        cmp    #$20
        beq    LBB85
        cmp    #tknDATA
        beq    LBBAD
        txa
        clc
        adc    $19
        sta    $19
        bcc    LBB7A
        inc    $1A
        bcs    LBB7A
LBB9C:
        brk
        .byte  $2A, "Out of ", tknDATA
LBBA6:
        brk
        .byte  $2B, "No ", tknREPEAT
        brk
LBBAD:
        iny
        sty    $1B
LBBB0:
        rts

; UNTIL numeric
; =============
LBBB1:
        jsr    L9B1D
        jsr    L984C
        jsr    L92EE
        ldx    $24
        beq    LBBA6
        lda    $2A
        ora    $2B
        ora    $2C
        ora    $2D
        beq    LBBCD
        dec    $24
        jmp    L8B9B
LBBCD:
        ldy    $05A3,x
        lda    $05B7,x
        jmp    LB8DD
LBBD6:
        brk
        .byte  $2C, "Too many ", tknREPEAT, "s"
        brk

; REPEAT
; ======
LBBE4:
        ldx    $24
        cpx    #$14
        bcs    LBBD6
        jsr    L986D
        lda    $0B
        sta    $05A4,x
        lda    $0C
        sta    $05B8,x
        inc    $24
        jmp    L8BA3

; Input string to string buffer
; -----------------------------
LBBFC:
        ldy    #$00
        lda    #$06             ; String buffer at $0600
        bne    LBC09

; Print character, read input line
; --------------------------------
LBC02:
        jsr    LB558            ; Print character
        ldy    #$00             ; $AAYY=input buffer at &0700
        lda    #$07
LBC09:
        sty    $37              ; $37/8=>input buffer
        sta    $38

; BBC - Call MOS to read a line
; -----------------------------
        lda    #$EE             ; Maximum length
        sta    $39
        lda    #$20             ; Lowest acceptable character
        sta    $3A
        ldy    #$FF             ; Highest acceptable character
        sty    $3B
        iny                     ; XY=>control block at &0037
        ldx    #$37
        tya                     ; Call OSWORD 0 to read line of text
        jsr    OSWORD
        bcc    LBC28            ; CC, Escape not pressed
        jmp    L9838            ; Escape
LBC25:
        jsr    OSNEWL
LBC28:
        lda    #$00             ; Set COUNT to zero
        sta    $1E
        rts
LBC2D:
        jsr    L9970
        bcs    LBC80
        lda    $3D
        sbc    #$02
        sta    $37
        sta    $3D
        sta    $12
        lda    $3E
        sbc    #$00
        sta    $38
        sta    $13
        sta    $3E
        ldy    #$03
        lda    ($37),y
        clc
        adc    $37
        sta    $37
        bcc    LBC53
        inc    $38
LBC53:
        ldy    #$00
LBC55:
        lda    ($37),y
        sta    ($12),y
        cmp    #$0D
        beq    LBC66
LBC5D:
        iny
        bne    LBC55
        inc    $38
        inc    $13
        bne    LBC55
LBC66:
        iny
        bne    LBC6D
        inc    $38
        inc    $13
LBC6D:
        lda    ($37),y
        sta    ($12),y
        bmi    LBC7C
        jsr    LBC81
        jsr    LBC81
        jmp    LBC5D
LBC7C:
        jsr    LBE92
        clc
LBC80:
        rts
LBC81:
        iny
        bne    LBC88
        inc    $13
        inc    $38
LBC88:
        lda    ($37),y
        sta    ($12),y
        rts
LBC8D:
        sty    $3B
        jsr    LBC2D
        ldy    #$07
        sty    $3C
        ldy    #$00
        lda    #$0D
        cmp    ($3B),y
        beq    LBD10
LBC9E:
        iny
        cmp    ($3B),y
        bne    LBC9E
        iny
        iny
        iny
        sty    $3F
        inc    $3F
        lda    $12
        sta    $39
        lda    $13
        sta    $3A
        jsr    LBE92
        sta    $37
        lda    $13
        sta    $38
        dey
        lda    $06
        cmp    $12
        lda    $07
        sbc    $13
        bcs    LBCD6
        jsr    LBE6F
        jsr    LBD20
        brk
        .byte  0, tknLINE, " space"
        brk
LBCD6:
        lda    ($39),y
        sta    ($37),y
        tya
        bne    LBCE1
        dec    $3A
        dec    $38
LBCE1:
        dey
        tya
        adc    $39
        ldx    $3A
        bcc    LBCEA
        inx
LBCEA:
        cmp    $3D
        txa
        sbc    $3E
        bcs    LBCD6
        sec
        ldy    #$01
        lda    $2B
        sta    ($3D),y
        iny
        lda    $2A
        sta    ($3D),y
        iny
        lda    $3F
        sta    ($3D),y
        jsr    LBE56
        ldy    #$FF
LBD07:
        iny
        lda    ($3B),y
        sta    ($3D),y
        cmp    #$0D
        bne    LBD07
LBD10:
        rts

; RUN
; ===
LBD11:
        jsr    L9857
LBD14:
        jsr    LBD20
        lda    $18
        sta    $0C              ; Point PtrA to PAGE
        stx    $0B
        jmp    L8B0B

; Clear BASIC heap, stack and DATA pointer
; ========================================
LBD20:
        lda    $12              ; LOMEM=TOP, VAREND=TOP
        sta    $00
        sta    $02
        lda    $13
        sta    $01
        sta    $03
        jsr    LBD3A            ; Clear DATA and stack
LBD2F:
        ldx    #$80
        lda    #$00
LBD33:
        sta    $047F,x          ; Clear dynamic variables list
        dex
        bne    LBD33
        rts

; Clear DATA pointer and BASIC stack
; ==================================
LBD3A:
        lda    $18              ; DATA pointer hi=PAGE hi
        sta    $1D
        lda    $06              ; STACK=HIMEM
        sta    $04
        lda    $07
        sta    $05
        lda    #$00             ; Clear REPEAT, FOR, GOSUB stacks
        sta    $24
        sta    $26
        sta    $25
        sta    $1C              ; DATA pointer=PAGE
        rts
LBD51:
        lda    $04
        sec
        sbc    #$05
        jsr    LBE2E
        ldy    #$00
        lda    $30
        sta    ($04),y
        iny
        lda    $2E
        and    #$80
        sta    $2E
        lda    $31
        and    #$7F
        ora    $2E
        sta    ($04),y
        iny
        lda    $32
        sta    ($04),y
        iny
        lda    $33
        sta    ($04),y
        iny
        lda    $34
        sta    ($04),y
        rts
LBD7E:
        lda    $04
        clc
        sta    $4B
        adc    #$05
        sta    $04
        lda    $05
        sta    $4C
        adc    #$00
        sta    $05
        rts
LBD90:
        beq    LBDB2
        bmi    LBD51
LBD94:
        lda    $04
        sec
        sbc    #$04
LBD99:
        jsr    LBE2E
        ldy    #$03
        lda    $2D
        sta    ($04),y
        dey
        lda    $2C
        sta    ($04),y
        dey
        lda    $2B
        sta    ($04),y
        dey
        lda    $2A
        sta    ($04),y
        rts

; Stack the current string
; ========================
LBDB2:
        clc                     ; stackbot=stackbot-length-1
        lda    $04
        sbc    $36
        jsr    LBE2E            ; Check enough space
        ldy    $36              ; Zero length, just stack length
        beq    LBDC6
LBDBE:
        lda    $05FF,y          ; Copy string to stack
        sta    ($04),y
        dey                     ; Loop for all characters
        bne    LBDBE
LBDC6:
        lda    $36              ; Copy string length
        sta    ($04),y
        rts

; Unstack a string
; ================
LBDCB:
        ldy    #$00             ; Get stacked string length
        lda    ($04),y
        sta    $36              ; If zero length, just unstack length
        beq    LBDDC
        tay
LBDD4:
        lda    ($04),y          ; Copy string to string buffer
        sta    $05FF,y
        dey                     ; Loop for all characters
        bne    LBDD4
LBDDC:
        ldy    #$00             ; Get string length again
        lda    ($04),y
        sec
LBDE1:
        adc    $04              ; Update stack pointer
        sta    $04
        bcc    LBE0A
        inc    $05
        rts

; Unstack an integer to IntA
; --------------------------
LBDEA:
        ldy    #$03
        lda    ($04),y          ; Copy to IntA
        sta    $2D
        dey
        lda    ($04),y
        sta    $2C
        dey
        lda    ($04),y
        sta    $2B
        dey
        lda    ($04),y
        sta    $2A
LBDFF:
        clc
        lda    $04
        adc    #$04             ; Drop 4 bytes from stack
        sta    $04
        bcc    LBE0A
        inc    $05
LBE0A:
        rts

; Unstack an integer to zero page
; -------------------------------
LBE0B:
        ldx    #$37
LBE0D:
        ldy    #$03
        lda    ($04),y
        sta    $03,x
        dey
        lda    ($04),y
        sta    $02,x
        dey
        lda    ($04),y
        sta    $01,x
        dey
        lda    ($04),y
        sta    $00,x
        clc
        lda    $04              ; Drop 4 bytes from stack
        adc    #$04
        sta    $04
        bcc    LBE0A
        inc    $05
        rts
LBE2E:
        sta    $04
        bcs    LBE34
        dec    $05
LBE34:
        ldy    $05
        cpy    $03
        bcc    LBE41
        bne    LBE40
        cmp    $02
        bcc    LBE41
LBE40:
        rts
LBE41:
        jmp    L8CB7
LBE44:
        lda    $2A
        sta    $00,x
        lda    $2B
        sta    $01,x
        lda    $2C
        sta    $02,x
        lda    $2D
        sta    $03,x
        rts
LBE55:
        clc
LBE56:
        tya
        adc    $3D
        sta    $3D
        bcc    LBE5F
        inc    $3E
LBE5F:
        ldy    #$01
        rts
LBE62:
        jsr    LBEDD            ; FILE.LOAD=PAGE
        tay
        lda    #$FF

        sty    F_EXEC           ; FILE.EXEC=0, load to specified address
        ldx    #$37
        jsr    OSFILE

; Scan program to check consistency and find TOP
; ----------------------------------------------
LBE6F:
        lda    $18
        sta    $13
        ldy    #$00             ; Point TOP to PAGE
        sty    $12
        iny
LBE78:
        dey                     ; Get byte preceding line
        lda    ($12),y
        cmp    #$0D             ; Not <cr>, jump to 'Bad program'
        bne    LBE9E
        iny                     ; Step to line number/terminator
        lda    ($12),y
        bmi    LBE90
        ldy    #$03             ; Point to line length
        lda    ($12),y          ; Zero length, jump to 'Bad program'
        beq    LBE9E
        clc                     ; Update TOP to point to next line
        jsr    LBE93
        bne    LBE78            ; Loop to check next line

; End of program found, set TOP
; -----------------------------
LBE90:
        iny
        clc
LBE92:
        tya
LBE93:
        adc    $12              ; TOP=TOP+A
        sta    $12
        bcc    LBE9B
        inc    $13
LBE9B:
        ldy    #$01             ; Return Y=1, NE
        rts

; Report 'Bad program' and jump to immediate mode
; -----------------------------------------------
LBE9E:
        jsr    LBFCF            ; Print inline text
        .byte  13, "Bad program", 13
        nop
        jmp    L8AF6            ; Jump to immediate mode

; Point &37/8 to <cr>-terminated string in string buffer
; ------------------------------------------------------
LBEB2:
        lda    #$00
        sta    $37
        lda    #$06
        sta    $38
LBEBA:
        ldy    $36
        lda    #$0D
        sta    $0600,y
        rts

; OSCLI string$ - Pass string to OSCLI to execute
; ===============================================
LBEC2:
        jsr    LBED2            ; $37/8=>cr-string

        ldx    #$00
        ldy    #$0600 / 256
        jsr    OS_CLI           ; Call OSCLI and return to execution loop
        jmp    L8B9B
LBECF:
        jmp    L8C0E
LBED2:
        jsr    L9B1D            ; Evaluate expression, error if not string
        bne    LBECF
        jsr    LBEB2            ; Convert to <cr>-string, check end of statement
        jmp    L984C

; Set FILE.LOAD to MEMHI.PAGE
; ---------------------------
LBEDD:
        jsr    LBED2            ; LOAD.lo=&00
        dey
        sty    F_LOAD+0
        lda    $18              ; LOAD.hi=PAGEhi
        sta    F_LOAD+1
LBEE7:
        lda    #$82             ; Get memory base high word
        jsr    OSBYTE
        stx    F_LOAD+2         ; Set LOAD high word
        sty    F_LOAD+3
        lda    #$00
        rts

;  SAVE string$
; =============
LBEF3:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    LBE6F            ; Set FILE.END to TOP
        lda    $12
        sta    F_END+0          ; Set FILE.END to TOP
        lda    $13
        sta    F_END+1
        lda    #L8023 & 255     ; Set FILE.EXEC to STARTUP
        sta    F_EXEC+0
        lda    #L8023 / 256
        sta    F_EXEC+1
        lda    $18              ; Set FILE.START to PAGE
        sta    F_START+1
        jsr    LBEDD            ; Set FILE.LOAD to PAGE
        stx    F_EXEC+2         ; Set address high words
        sty    F_EXEC+3
        stx    F_START+2
        sty    F_START+3
        stx    F_END+2
        sty    F_END+3
        sta    F_START+0        ; Low byte of FILE.START
        tay
        ldx    #$37
        jsr    OSFILE
        jmp    L8B9B
.endif

; LOAD string$
; ============
LBF24:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    LBE62            ; Do LOAD, jump to immediate mode
        jmp    L8AF3
.endif

; CHAIN string$
; =============
LBF2A:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    LBE62            ; Do LOAD, jump to execution loop
        jmp    LBD14
.endif

; PTR#numeric=numeric
; ===================
LBF30:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    LBFA9            ; Evaluate #handle
        pha
        jsr    L9813            ; Step past '=', evaluate integer
        jsr    L92EE
        pla                     ; Get handle, point to IntA
        tay
        ldx    #$2A
        lda    #$01
        jsr    OSARGS
        jmp    L8B9B            ; Jump to execution loop
.endif

; =EXT#numeric - Read file pointer via OSARGS
; ===========================================
LBF46:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        sec                     ; Flag to do =EXT
.endif

; =PTR#numeric - Read file pointer via OSARGS
; ===========================================
LBF47:
        lda    #$00             ; A=0 or 1 for =PTR or =EXT
        rol    a
        rol    a
        pha                     ; Atom - A=0/1, BBC - A=0/2
        jsr    LBFB5            ; Evaluate #handle, point to IntA
        ldx    #$2A
        pla
        jsr    OSARGS
        lda    #$40             ; Return integer
        rts

; BPUT#numeric, numeric
; =====================
LBF58:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    LBFA9            ; Evaluate #handle
        pha
        jsr    L8AAE
        jsr    L9849
        jsr    L92EE
        pla
        tay
        lda    $2A
        jsr    OSBPUT           ; Call OSBPUT, jump to execution loop
        jmp    L8B9B
.endif

;=BGET#numeric
;=============
LBF6F:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    LBFB5            ; Evaluate #handle
        jsr    OSBGET
        jmp    LAED8            ; Jump to return 8-bit integer
.endif

; OPENIN f$ - Call OSFIND to open file for input
; ==============================================
LBF78:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        lda    #$40             ; $40=OPENUP
        bne    LBF82
.endif

; OPENOUT f$ - Call OSFIND to open file for output
; ================================================
LBF7C:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        lda    #$80             ; $80=OPENOUT
        bne    LBF82
.endif

; OPENUP f$ - Call OSFIND to open file for update
; ===============================================
LBF80:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        lda    #$C0             ; $C0=OPENUP
LBF82:
        pha
        jsr    LADEC            ; Evaluate, if not string, jump to error
        bne    LBF96
        jsr    LBEBA            ; Terminate string with <cr>
        ldx    #$00             ; Point to string buffer, get action back
        ldy    #$06
        pla
        jsr    OSFIND           ; Pass to OSFIND, jump to return integer from A
        jmp    LAED8
LBF96:
        jmp    L8C0E            ; Jump to 'Type mismatch' error
.endif

; CLOSE#numeric
; =============
LBF99:
.if .defined (PSBC)
        jmp    L9821            ; Syntax error
.else
        jsr    LBFA9            ; Evaluate #handle, check end of statement
        jsr    L9852
        ldy    $2A              ; Get handle from IntA
        lda    #$00
        jsr    OSFIND
        jmp    L8B9B            ; Jump back to execution loop
.endif

; Copy PtrA to PtrB, then get handle
; ==================================
LBFA9:
        lda    $0A              ; Set PtrB to program pointer in PtrA
        sta    $1B
        lda    $0B
        sta    $19
        lda    $0C
        sta    $1A

; Check for '#', evaluate channel
; ===============================
LBFB5:
        jsr    L8A8C            ; Skip spaces
        cmp    #'#'             ; If not '#', jump to give error
        bne    LBFC3
        jsr    L92E3            ; Evaluate as integer
LBFBF:
        ldy    $2A              ; Get low byte and return
        tya
        rts

LBFC3:
        brk
        .byte   $2D, "Missing #"
        brk

; Print inline text
; =================
LBFCF:
        pla                     ; Pop return address to pointer
        sta    $37
        pla
        sta    $38
        ldy    #$00             ; Jump into loop
        beq    LBFDC
LBFD9:
        jsr    OSASCI           ; Print character
LBFDC:
        jsr    L894B            ; Update pointer, get character, loop if b7=0
        bpl    LBFD9
        jmp    ($0037)          ; Jump back to program

; REPORT
; ======
LBFE4:
        jsr    L9857            ; Check end of statement, print newline, clear COUNT
        jsr    LBC25
        ldy    #$01
LBFEC:
        lda    (FAULT),y        ; Get byte, exit if &00 terminator
        beq    LBFF6
        jsr    LB50E            ; Print character or token, loop for next
        iny
        bne    LBFEC
LBFF6:
        jmp    L8B9B            ; Jump to main execution loop
        brk
        .byte  "Roger"
        brk
LC000:

.if .defined(PSBC)
  .include "mos.asm"
.endif
