; Source for 6502 BASIC II
; BBC BASIC Copyright (C) 1982/1983 Acorn Computer and Roger Wilson
; Source reconstruction and commentary Copyright (C) J.G.Harston
; Port to CC65 by Jeff Tranter

; MOS Entry Points:
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

        .org    $8000

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
        lda     #$02            ; Set up error handler
        sta     BRKV
        lda     #$B4
        sta     $0203
        cli                     ; Enable IRQs, jump to immediate loop
        jmp     $8ADD

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
        .byte   $BF78 & $FF     ; &8E - OPENIN
        .byte   $BF47 & $FF     ; &8F - PTR
        .byte   $AEC0 & 255     ; &90 - PAGE
        .byte   $AEB4 & 255     ; &91 - TIME
        .byte   $AEFC & 255     ; &92 - LOMEM
        .byte   $AF03 & 255     ; &93 - HIMEM
        .byte   $AD6A & $FF     ; &94 - ABS
        .byte   $A8D4 & $FF     ; &95 - ACS
        .byte   $AB33 & $FF     ; &96 - ADVAL
        .byte   $AC9E & $FF     ; &97 - ASC
        .byte   $A8DA & $FF     ; &98 - ASN
        .byte   $A907 & $FF     ; &99 - ATN
        .byte   $BF6F & $FF     ; &9A - BGET
        .byte   $A98D & $FF     ; &9B - COS
        .byte   $AEF7 & $FF     ; &9C - COUNT
        .byte   $ABC2 & $FF     ; &9D - DEG
        .byte   $AF9F & $FF     ; &9E - ERL
        .byte   $AFA6 & $FF     ; &9F - ERR
        .byte   $ABE9 & $FF     ; &A0 - EVAL
        .byte   $AA91 & $FF     ; &A1 - EXP
        .byte   $BF46 & $FF     ; &A2 - EXT
        .byte   $AECA & $FF     ; &A3 - FALSE
        .byte   $B195 & $FF     ; &A4 - FN
        .byte   $AFB9 & $FF     ; &A5 - GET
        .byte   $ACAD & $FF     ; &A6 - INKEY
        .byte   $ACE2 & $FF     ; &A7 - INSTR(
        .byte   $AC78 & $FF     ; &A8 - INT
        .byte   $AED1 & $FF     ; &A9 - LEN
        .byte   $A7FE & $FF     ; &AA - LN
        .byte   $ABA8 & $FF     ; &AB - LOG
        .byte   $ACD1 & $FF     ; &AC - NOT
        .byte   $BF80 & $FF     ; &AD - OPENUP
        .byte   $BF7C & $FF     ; &AE - OPENOUT
        .byte   $ABCB & $FF     ; &AF - PI
        .byte   $AB41 & $FF     ; &B0 - POINT(
        .byte   $AB6D & $FF     ; &B1 - POS
        .byte   $ABB1 & $FF     ; &B2 - RAD
        .byte   $AF49 & $FF     ; &B3 - RND
        .byte   $AB88 & $FF     ; &B4 - SGN
        .byte   $A998 & $FF     ; &B5 - SIN
        .byte   $A7B4 & $FF     ; &B6 - SQR
        .byte   $A6BE & $FF     ; &B7 - TAN
        .byte   $AEDC & $FF     ; &B8 - TO
        .byte   $ACC4 & $FF     ; &B9 - TRUE
        .byte   $ABD2 & $FF     ; &BA - USR
        .byte   $AC2F & $FF     ; &BB - VAL
        .byte   $AB76 & $FF     ; &BC - VPOS
        .byte   $B3BD & $FF     ; &BD - CHR$
        .byte   $AFBF & $FF     ; &BE - GET$
        .byte   $B026 & $FF     ; &BF - INKEY$
        .byte   $AFCC & $FF     ; &C0 - LEFT$(
        .byte   $B039 & $FF     ; &C1 - MID$(
        .byte   $AFEE & $FF     ; &C2 - RIGHT$(
        .byte   $B094 & $FF     ; &C3 - STR$(
        .byte   $B0C2 & $FF     ; &C4 - STRING$(
        .byte   $ACB8 & $FF     ; &C5 - EOF
        .byte   $90AC & $FF     ; &C6 - AUTO
        .byte   $8F31 & $FF     ; &C7 - DELETE
        .byte   $BF24 & $FF     ; &C8 - LOAD
        .byte   $B59C & $FF     ; &C9 - LIST
        .byte   $8ADA & $FF     ; &CA - NEW
        .byte   $8AB6 & $FF     ; &CB - OLD
        .byte   $8FA3 & $FF     ; &CC - RENUMBER
        .byte   $BEF3 & $FF     ; &CD - SAVE
        .byte   $982A & $FF     ; &CE - unused
        .byte   $BF30 & $FF     ; &CF - PTR
        .byte   $9283 & $FF     ; &D0 - PAGE
        .byte   $92C9 & $FF     ; &D1 - TIME
        .byte   $926F & $FF     ; &D2 - LOMEM
        .byte   $925D & $FF     ; &D3 - HIMEM
        .byte   $B44C & $FF     ; &D4 - SOUND
        .byte   $BF58 & $FF     ; &D5 - BPUT
        .byte   $8ED2 & $FF     ; &D6 - CALL
        .byte   $BF2A & $FF     ; &D7 - CHAIN
        .byte   $928D & $FF     ; &D8 - CLEAR
        .byte   $BF99 & $FF     ; &D9 - CLOSE
        .byte   $8EBD & $FF     ; &DA - CLG
        .byte   $8EC4 & $FF     ; &DB - CLS
        .byte   $8B7D & $FF     ; &DC - DATA
        .byte   $8B7D & $FF     ; &DD - DEF
        .byte   $912F & $FF     ; &DE - DIM
        .byte   $93E8 & $FF     ; &DF - DRAW
        .byte   $8AC8 & $FF     ; &E0 - END
        .byte   $9356 & $FF     ; &E1 - ENDPROC
        .byte   $B472 & $FF     ; &E2 - ENVELOPE
        .byte   $B7C4 & $FF     ; &E3 - FOR
        .byte   $B888 & $FF     ; &E4 - GOSUB
        .byte   $B8CC & $FF     ; &E5 - GOTO
        .byte   $937A & $FF     ; &E6 - GCOL
        .byte   $98C2 & $FF     ; &E7 - IF
        .byte   $BA44 & $FF     ; &E8 - INPUT
        .byte   $8BE4 & $FF     ; &E9 - LET
        .byte   $9323 & $FF     ; &EA - LOCAL
        .byte   $939A & $FF     ; &EB - MODE
        .byte   $93E4 & $FF     ; &EC - MOVE
        .byte   $B695 & $FF     ; &ED - NEXT
        .byte   $B915 & $FF     ; &EE - ON
        .byte   $942F & $FF     ; &EF - VDU
        .byte   $93F1 & $FF     ; &F0 - PLOT
        .byte   $8D9A & $FF     ; &F1 - PRINT
        .byte   $9304 & $FF     ; &F2 - PROC
        .byte   $BB1F & $FF     ; &F3 - READ
        .byte   $8B7D & $FF     ; &F4 - REM
        .byte   $BBE4 & $FF     ; &F5 - REPEAT
        .byte   $BFE4 & $FF     ; &F6 - REPORT
        .byte   $BAE6 & $FF     ; &F7 - RESTORE
        .byte   $B8B6 & $FF     ; &F8 - RETURN
        .byte   $BD11 & $FF     ; &F9 - RUN
        .byte   $8AD0 & $FF     ; &FA - STOP
        .byte   $938E & $FF     ; &FB - COLOUR
        .byte   $9295 & $FF     ; &FC - TRACE
        .byte   $BBB1 & $FF     ; &FD - UNTIL
        .byte   $B4A0 & $FF     ; &FE - WIDTH
        .byte   $BEC2 & $FF     ; &FF - OSCLI

; FUNCTION/COMMAND DISPATCH TABLE, ADDRESS HIGH BYTES
; ===================================================
L83DF: ; &83E6
        .byte   $BF78 / 256     ; &8E - OPENIN
        .byte   $BF47 / 256     ; &8F - PTR
        .byte   $AEC0 / 256     ; &90 - PAGE
        .byte   $AEB4 / 256     ; &91 - TIME
        .byte   $AEFC / 256     ; &92 - LOMEM
        .byte   $AF03 / 256     ; &93 - HIMEM
        .byte   $AD6A / 256     ; &94 - ABS
        .byte   $A8D4 / 256     ; &95 - ACS
        .byte   $AB33 / 256     ; &96 - ADVAL
        .byte   $AC9E / 256     ; &97 - ASC
        .byte   $A8DA / 256     ; &98 - ASN
        .byte   $A907 / 256     ; &99 - ATN
        .byte   $BF6F / 256     ; &9A - BGET
        .byte   $A98D / 256     ; &9B - COS
        .byte   $AEF7 / 256     ; &9C - COUNT
        .byte   $ABC2 / 256     ; &9D - DEG
        .byte   $AF9F / 256     ; &9E - ERL
        .byte   $AFA6 / 256     ; &9F - ERR
        .byte   $ABE9 / 256     ; &A0 - EVAL
        .byte   $AA91 / 256     ; &A1 - EXP
        .byte   $BF46 / 256     ; &A2 - EXT
        .byte   $AECA / 256     ; &A3 - FALSE
        .byte   $B195 / 256     ; &A4 - FN
        .byte   $AFB9 / 256     ; &A5 - GET
        .byte   $ACAD / 256     ; &A6 - INKEY
        .byte   $ACE2 / 256     ; &A7 - INSTR(
        .byte   $AC78 / 256     ; &A8 - INT
        .byte   $AED1 / 256     ; &A9 - LEN
        .byte   $A7FE / 256     ; &AA - LN
        .byte   $ABA8 / 256     ; &AB - LOG
        .byte   $ACD1 / 256     ; &AC - NOT
        .byte   $BF80 / 256     ; &AD - OPENUP
        .byte   $BF7C / 256     ; &AE - OPENOUT
        .byte   $ABCB / 256     ; &AF - PI
        .byte   $AB41 / 256     ; &B0 - POINT(
        .byte   $AB6D / 256     ; &B1 - POS
        .byte   $ABB1 / 256     ; &B2 - RAD
        .byte   $AF49 / 256     ; &B3 - RND
        .byte   $AB88 / 256     ; &B4 - SGN
        .byte   $A998 / 256     ; &B5 - SIN
        .byte   $A7B4 / 256     ; &B6 - SQR
        .byte   $A6BE / 256     ; &B7 - TAN
        .byte   $AEDC / 256     ; &B8 - TO
        .byte   $ACC4 / 256     ; &B9 - TRUE
        .byte   $ABD2 / 256     ; &BA - USR
        .byte   $AC2F / 256     ; &BB - VAL
        .byte   $AB76 / 256     ; &BC - VPOS
        .byte   $B3BD / 256     ; &BD - CHR$
        .byte   $AFBF / 256     ; &BE - GET$
        .byte   $B026 / 256     ; &BF - INKEY$
        .byte   $AFCC / 256     ; &C0 - LEFT$(
        .byte   $B039 / 256     ; &C1 - MID$(
        .byte   $AFEE / 256     ; &C2 - RIGHT$(
        .byte   $B094 / 256     ; &C3 - STR$(
        .byte   $B0C2 / 256     ; &C4 - STRING$(
        .byte   $ACB8 / 256     ; &C5 - EOF
        .byte   $90AC / 256     ; &C6 - AUTO
        .byte   $8F31 / 256     ; &C7 - DELETE
        .byte   $BF24 / 256     ; &C8 - LOAD
        .byte   $B59C / 256     ; &C9 - LIST
        .byte   $8ADA / 256     ; &CA - NEW
        .byte   $8AB6 / 256     ; &CB - OLD
        .byte   $8FA3 / 256     ; &CC - RENUMBER
        .byte   $BEF3 / 256     ; &CD - SAVE
        .byte   $982A / 256     ; &CE - unused
        .byte   $BF30 / 256     ; &CF - PTR
        .byte   $9283 / 256     ; &D0 - PAGE
        .byte   $92C9 / 256     ; &D1 - TIME
        .byte   $926F / 256     ; &D2 - LOMEM
        .byte   $925D / 256     ; &D3 - HIMEM
        .byte   $B44C / 256     ; &D4 - SOUND
        .byte   $BF58 / 256     ; &D5 - BPUT
        .byte   $8ED2 / 256     ; &D6 - CALL
        .byte   $BF2A / 256     ; &D7 - CHAIN
        .byte   $928D / 256     ; &D8 - CLEAR
        .byte   $BF99 / 256     ; &D9 - CLOSE
        .byte   $8EBD / 256     ; &DA - CLG
        .byte   $8EC4 / 256     ; &DB - CLS
        .byte   $8B7D / 256     ; &DC - DATA
        .byte   $8B7D / 256     ; &DD - DEF
        .byte   $912F / 256     ; &DE - DIM
        .byte   $93E8 / 256     ; &DF - DRAW
        .byte   $8AC8 / 256     ; &E0 - END
        .byte   $9356 / 256     ; &E1 - ENDPROC
        .byte   $B472 / 256     ; &E2 - ENVELOPE
        .byte   $B7C4 / 256     ; &E3 - FOR
        .byte   $B888 / 256     ; &E4 - GOSUB
        .byte   $B8CC / 256     ; &E5 - GOTO
        .byte   $937A / 256     ; &E6 - GCOL
        .byte   $98C2 / 256     ; &E7 - IF
        .byte   $BA44 / 256     ; &E8 - INPUT
        .byte   $8BE4 / 256     ; &E9 - LET
        .byte   $9323 / 256     ; &EA - LOCAL
        .byte   $939A / 256     ; &EB - MODE
        .byte   $93E4 / 256     ; &EC - MOVE
        .byte   $B695 / 256     ; &ED - NEXT
        .byte   $B915 / 256     ; &EE - ON
        .byte   $942F / 256     ; &EF - VDU
        .byte   $93F1 / 256     ; &F0 - PLOT
        .byte   $8D9A / 256     ; &F1 - PRINT
        .byte   $9304 / 256     ; &F2 - PROC
        .byte   $BB1F / 256     ; &F3 - READ
        .byte   $8B7D / 256     ; &F4 - REM
        .byte   $BBE4 / 256     ; &F5 - REPEAT
        .byte   $BFE4 / 256     ; &F6 - REPORT
        .byte   $BAE6 / 256     ; &F7 - RESTORE
        .byte   $B8B6 / 256     ; &F8 - RETURN
        .byte   $BD11 / 256     ; &F9 - RUN
        .byte   $8AD0 / 256     ; &FA - STOP
        .byte   $938E / 256     ; &FB - COLOUR
        .byte   $9295 / 256     ; &FC - TRACE
        .byte   $BBB1 / 256     ; &FD - UNTIL
        .byte   $B4A0 / 256     ; &FE - WIDTH
        .byte   $BEC2 / 256     ; &FF - OSCLI

; ASSEMBLER
; =========
;
; Packed mnemonic table, low bytes
; --------------------------------
L8451:
        .byte   $4B, $83, $84, $89, $96, $B8, $B9, $D8, $D9, $F0
        .byte   $01, $10, $81, $90, $89, $93, $A3, $A4, $A9, $38
        .byte   $39, $78, $01, $13, $21, $63, $73, $B1, $A9, $C5
        .byte   $0C, $C3, $D3, $C4, $F2, $41, $83, $B0, $81, $43
        .byte   $6C, $72, $EC, $F2, $A3, $C3, $18, $19, $34, $B0
        .byte   $72, $98, $99, $81, $98, $99, $14, $35


; Packed mnemonic table, high bytes
; ---------------------------------
L848B:
        .byte   $0A, $0D, $0D, $0D, $0D, $10, $10, $25, $25, $39
        .byte   $41, $41, $41, $41, $4A, $4A, $4C, $4C, $4C, $50
        .byte   $50, $52, $53, $53, $53, $08, $08, $08, $09, $09
        .byte   $0A, $0A, $0A, $05, $15, $3E, $04, $0D, $30, $4C
        .byte   $06, $32, $49, $49, $10, $25, $0E, $0E, $09, $29
        .byte   $2A, $30, $30, $4E, $4E, $4E, $3E, $16


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
        jmp     $8BA3
L8504:
        lda     #$03            ; Set OPT 3, default on entry to '['
        sta     $28
L8508:
        jsr    $8A97            ; Skip spaces
        cmp    #']'             ; ']' - exit assembler
        beq    $84FD
        jsr    $986D
L8512:
        dec    $0A
        jsr    $85BA
        dec    $0A
        lda    $28
        lsr    a
        bcc    $857E
        lda    $1E
        adc    #$04
        sta    $3F
        lda    $38
        jsr    $B545
        lda    $37
        jsr    $B562
        ldx    #$FC
        ldy    $39
        bpl    $8536
        ldy    $36
L8536:
        sty    $38
        beq    $8556
        ldy    #$00
L853C:
        inx
        bne    $854C
        jsr    $BC25            ; Print newline
        ldx    $3F

L8644:
        jsr    $B565            ; Print a space
        dex                     ; Loop to print spaces
        bne    $8544
        ldx    #$FD
L854C:
        lda    ($3A),y
        jsr    $B562
        iny
        dec    $38
        bne    L853C
L8556:
        inx
        bpl    $8565
        jsr    $B565
        jsr    $B558
        jsr    $B558
        jmp    $8556
L8565:
        ldy    #$00
L8567:
        lda    ($0B),y
        cmp    #$3A
        beq    $8577
        cmp    #$0D
        beq    $857B
L8571:
        jsr    $B50E            ; Print character or token
        iny
        bne    $8567
L8577:
        cpy    $0A
        bcc    $8571
L857B:
        jsr    $BC25            ; Print newline
L857E:
        ldy    $0A
        dey
L8581:
        iny
        lda    ($0B),y
        cmp    #$3A
        beq    $858C
        cmp    #$0D
        bne    L8581
L858C:
        jsr    $9859
        dey
        lda    ($0B),y
        cmp    #$3A
        beq    $85A2
        lda    $0C
        cmp    #$07
        bne    $859F
        jmp    $8AF6
L859F:
        jsr    $9890
L85A2:
        jmp    $8508
L85A5:
        jsr    $9582
        beq    $8604
        bcs    $8604
        jsr    $BD94
        jsr    $AE3A            ; Find P%
        sta    $27
        jsr    $B4B4
        jsr    $8827
L85BA:
        ldx    #$03             ; Prepare to fetch three characters
        jsr    $8A97            ; Skip spaces
        ldy    #$00
        sty    $3D
        cmp    #':'             ; End of statement
        beq    $862B
        cmp    #$0D             ; End of line
        beq    $862B
        cmp    #'\'            ; Comment
        beq    $862B
        cmp    #'.'             ; Label
        beq    $85A5
        dec    $0A
L85D5:
        ldy    $0A              ; Get current character, inc. index
        inc    $0A
        lda    ($0B),y          ; Token, check for tokenied AND, EOR, OR
        bmi    $8607
        cmp    #$20             ; Space, step past
        beq    $85F1
        ldy    #$05
        asl    a                ; Compact first character
        asl    a
        asl    a
L85E6:
        asl    a
        rol    $3D
        rol    $3E
        dey
        bne    $85E6
        dex                     ; Loop to fetch three characters
        bne    $85D5

; The current opcode has now been compressed into two bytes
; ---------------------------------------------------------
L85F1:
        ldx    #$3A             ; Point to end of opcode lookup table
        lda    $3D              ; Get low byte of compacted mnemonic
L85F5:
        cmp    L8451-1,x        ; Low half doesn't match
        bne    $8601
        ldy    L848B-1,x        ; Check high half
        cpy    $3E              ; Mnemonic matches
        beq    $8620
L8601:
        dex                     ; Loop through opcode lookup table
        bne    $85F5
L8604:
        jmp    $982A            ; Mnemonic not matched, Mistake
L8607:
        ldx    #$22             ; opcode number for 'AND'
        cmp    #tknAND          ; Tokenised 'AND'
        beq    $8620
        inx                     ; opcode number for 'EOR'
        cmp    #tknEOR          ; Tokenized 'EOR'
        beq    $8620
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
        bcs    $8673
L862B:
        lda    $0440            ; Get P% low byte
        sta    $37
        sty    $39
        ldx    $28              ; Offset assembly (opt>3)
        cpx    #$04
        ldx    $0441            ; Get P% high byte
        stx    $38
        bcc    $8643            ; No offset assembly
        lda    $043C
        ldx    $043D            ; Get O%
L8643:
        sta    $3A              ; Store destination pointer
        stx    $3B
        tya
        beq    $8672
        bpl    $8650
        ldy    $36
        beq    $8672
L8650:
        dey                     ; Get opcode byte
        lda    $0029,y
        bit    $39              ; Opcode - jump to store it
        bpl    $865B
        lda    $0600,y          ; Get EQU byte
L865B:
        sta    ($3A),y          ; Store byte
        inc    $0440            ; Increment P%
        bne    $8665
        inc    $0441
L8665:
        bcc    L866F
        inc    $043C            ; Increment O%
        bne    L866F
        inc    $043D
L866F:
        tya
        bne    L8650
        rts

L8673:
        cpx    #$22
        bcs    $86B7
        jsr    $8821
        clc
        lda    $2A
        sbc    $0440
        tay
        lda    $2B
        sbc    $0441
        cpy    #$01
        dey
        sbc    #$00
        beq    $86B2
        cmp    #$FF
        beq    $86AD
L8691:
        lda    $28              ; Get OPT
        lsr    a
        beq    $86A5            ; If OPT.b0=0, ignore error
        brk
        .byte  $01,"Out of range"
        brk
L86A5:
        tay
L86A6:
        sty    $2A
L86A8:
        ldy    #$02
        jmp    $862B
L86AD:
        tya
        bmi    L86A6
        bpl    $8691
L86B2:
        tya
        bpl    $86A6
        bmi    $8691
L86B7:
        cpx    #$29
        bcs    $86D3
        jsr    $8A97            ; Skip spaces
        cmp    #'#'
        bne    $86DA
        jsr    $882F
L86C5:
        jsr    $8821
L86C8:
        lda    $2B
        beq    $86A8
L86CC:
        brk
        .byte  $02,"Byte"
         brk

; Parse (zp),Y addressing mode
; ----------------------------
L86D3:
 cpx    #$36
 bne    $873F
 jsr    $8A97
 cmp    #$28
 bne    $8715
 jsr    $8821
 jsr    $8A97
 cmp    #$29
 bne    $86FB
 jsr    $8A97
 cmp    #$2C
 bne    $870D
 jsr    $882C
 jsr    $8A97
 cmp    #$59
 bne    $870D
 beq    $86C8
 cmp    #$2C
 bne    $870D
 jsr    $8A97
 cmp    #$58
 bne    $870D
 jsr    $8A97
 cmp    #$29
 beq    $86C8
 brk
 .byte  $03
 eor    #$6E
 .byte  'd'
 adc    $78
 brk
 dec    $0A
 jsr    $8821
 jsr    $8A97
 cmp    #$2C
 bne    $8735
 jsr    $882C
 jsr    $8A97
 cmp    #$58
 beq    $8735
 cmp    #$59
 bne    $870D
 jsr    $882F
 jmp    $879A
 jsr    $8832
 lda    $2B
 bne    $872F
 jmp    $86A8
 cpx    #$2F
 bcs    $876E
 cpx    #$2D
 bcs    $8750
 jsr    $8A97
 cmp    #$41
 beq    $8767
 dec    $0A
 jsr    $8821
 jsr    $8A97
 cmp    #$2C
 bne    $8738
 jsr    $882C
 jsr    $8A97
 cmp    #$58
 beq    $8738
 jmp    $870D
 jsr    $8832
 ldy    #$01
 bne    $879C
 cpx    #$32
 bcs    $8788
 cpx    #$31
 beq    $8782
 jsr    $8A97
 cmp    #$23
 bne    $8780
 jmp    $86C5
 dec    $0A
 jsr    $8821
 jmp    $8735
 cpx    #$33
 beq    $8797
 bcs    $87B2
 jsr    $8A97
 cmp    #$28
 beq    $879F
 dec    $0A
 jsr    $8821
 ldy    #$03
 jmp    $862B
 jsr    $882C
 jsr    $882C
 jsr    $8821
 jsr    $8A97
 cmp    #$29
 beq    $879A
 jmp    $870D
 cpx    #$39
 bcs    $8813
 lda    $3D
 eor    #$01
 and    #$1F
 pha
 cpx    #$37
 bcs    $87F0
 jsr    $8A97
 cmp    #$23
 bne    $87CC
 pla
 jmp    $86C5
 dec    $0A
 jsr    $8821
 pla
 sta    $37
 jsr    $8A97
 cmp    #$2C
 beq    $87DE
 jmp    $8735
 jsr    $8A97
 and    #$1F
 cmp    $37
 bne    $87ED
 jsr    $882C
 jmp    $8735
 jmp    $870D
 jsr    $8821
 pla
 sta    $37
 jsr    $8A97
 cmp    #$2C
 bne    $8810
 jsr    $8A97
 and    #$1F
 cmp    $37
 bne    $87ED
 jsr    $882C
 lda    $2B
 beq    $8810
 jmp    $86CC
 jmp    $8738
 bne    $883A
 jsr    $8821
 lda    $2A
 sta    $28
 ldy    #$00
 jmp    $862B
 jsr    $9B1D
 jsr    $92F0
 ldy    $1B
 sty    $0A
 rts
 jsr    $882F
 jsr    $8832
 lda    $29
 clc
 adc    #$04
 sta    $29
 rts
 ldx    #$01
 ldy    $0A
 inc    $0A
 lda    ($0B),y
 cmp    #$42
 beq    $8858
 inx
 cmp    #$57
 beq    $8858
 ldx    #$04
 cmp    #$44
 beq    $8858
 cmp    #$53
 beq    $886A
 jmp    $982A
 txa
 pha
 jsr    $8821
 ldx    #$29
 jsr    $BE44
 pla
 tay
 jmp    $862B
 jmp    $8C0E
 lda    $28
 pha
 jsr    $9B1D
 bne    $8867
 pla
 sta    $28
 jsr    $8827
 ldy    #$FF
 bne    $8864
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
 iny
 lda    ($39),y
 sta    ($37),y
 cmp    #$0D
 bne    $888D
 rts
 and    #$0F
 sta    $3D
 sty    $3E
 iny
 lda    ($37),y
 cmp    #$3A
 bcs    $88DA
 cmp    #$30
 bcc    $88DA
 and    #$0F
 pha
 ldx    $3E
 lda    $3D
 asl    a
 rol    $3E
 bmi    $88D5
 asl    a
 rol    $3E
 bmi    $88D5
 adc    $3D
 sta    $3D
 txa
 adc    $3E
 asl    $3D
 rol    a
 bmi    $88D5
 bcs    $88D5
 sta    $3E
 pla
 adc    $3D
 sta    $3D
 bcc    $889D
 inc    $3E
 bpl    $889D
 pha
 pla
 ldy    #$00
 sec
 rts
 dey
 lda    #$8D
 jsr    $887C
 lda    $37
 adc    #$02
 sta    $39
 lda    $38
 adc    #$00
 sta    $3A
 lda    ($37),y
 sta    ($39),y
 dey
 bne    $88EC
 ldy    #$03
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
 jsr    $8944
 jsr    $8944
 jsr    $8944
 ldy    #$00
 clc
 rts
 cmp    #$7B
 bcs    $8924
 cmp    #$5F
 bcs    $893C
 cmp    #$5B
 bcs    $8924
 cmp    #$41
 bcs    $893C
 cmp    #$3A
 bcs    $8924
 cmp    #$30
 rts
 cmp    #$2E
 bne    $8936
 rts
 lda    ($37),y
 inc    $37
 bne    $894A
 inc    $38
 rts
 jsr    $8944
 lda    ($37),y
 rts
 ldy    #$00
 sty    $3B
 sty    $3C
 lda    ($37),y
 cmp    #$0D
 beq    $894A
 cmp    #$20
 bne    $8966
 jsr    $8944
 bne    $8957
 cmp    #$26
 bne    $897C
 jsr    $894B
 jsr    $8936
 bcs    $896A
 cmp    #$41
 bcc    $8957
 cmp    #$47
 bcc    $896A
 bcs    $8957
 cmp    #$22
 bne    $898C
 jsr    $894B
 cmp    #$22
 beq    $8961
 cmp    #$0D
 bne    $8980
 rts
 cmp    #$3A
 bne    $8996
 sty    $3B
 sty    $3C
 beq    $8961
 cmp    #$2C
 beq    $8961
 cmp    #$2A
 bne    $89A3
 lda    $3B
 bne    $89E3
 rts
 cmp    #$2E
 beq    $89B5
 jsr    $8936
 bcc    $89DF
 ldx    $3C
 beq    $89B5
 jsr    $8897
 bcc    $89E9
 lda    ($37),y
 jsr    $893D
 bcc    $89C2
 jsr    $8944
 jmp    $89B5
 ldx    #$FF
 stx    $3B
 sty    $3C
 jmp    $8957
 jsr    $8926
 bcc    $89E3
 ldy    #$00
 lda    ($37),y
 jsr    $8926
 bcc    $89C2
 jsr    $8944
 jmp    $89D2
 cmp    #$41
 bcs    $89EC
 ldx    #$FF
 stx    $3B
 sty    $3C
 jmp    $8961
 cmp    #$58
 bcs    $89CB
 ldx    #$71
 stx    $39
 ldx    #$80
 stx    $3A
 cmp    ($39),y
 bcc    $89D2
 bne    $8A0D
 iny
 lda    ($39),y
 bmi    $8A37
 cmp    ($37),y
 beq    $89FE
 lda    ($37),y
 cmp    #$2E
 beq    $8A18
 iny
 lda    ($39),y
 bpl    $8A0D
 cmp    #$FE
 bne    $8A25
 bcs    $89D0
 iny
 lda    ($39),y
 bmi    $8A37
 inc    $39
 bne    $8A19
 inc    $3A
 bne    $8A19
 sec
 iny
 tya
 adc    $39
 sta    $39
 bcc    $8A30
 inc    $3A
 ldy    #$00
 lda    ($37),y
 jmp    $89F8
 tax
 iny
 lda    ($39),y
 sta    $3D
 dey
 lsr    a
 bcc    $8A48
 lda    ($37),y
 jsr    $8926
 bcs    $89D0
 txa
 bit    $3D
 bvc    $8A54
 ldx    $3B
 bne    $8A54
 clc
 adc    #$40
 dey
 jsr    $887C
 ldy    #$00
 ldx    #$FF
 lda    $3D
 lsr    a
 lsr    a
 bcc    $8A66
 stx    $3B
 sty    $3C
 lsr    a
 bcc    $8A6D
 sty    $3B
 sty    $3C
 lsr    a
 bcc    $8A81
 pha
 iny
 lda    ($37),y
 jsr    $8926
 bcc    $8A7F
 jsr    $8944
 jmp    $8A72
 dey
 pla
 lsr    a
 bcc    $8A86
 stx    $3C
 lsr    a
 bcs    $8A96
 jmp    $8961
 ldy    $1B
 inc    $1B
 lda    ($19),y
 cmp    #$20
 beq    $8A8C
 rts
 ldy    $0A
 inc    $0A
 lda    ($0B),y
 cmp    #$20
 beq    $8A97
 rts
 brk
 ora    $4D
 adc    #$73
 .byte  's'
 adc    #$6E
 .byte  'g'
 jsr    $002C
 jsr    $8A8C
 cmp    #$2C
 bne    $8AA2
 rts
 jsr    $9857
 lda    $18
 sta    $38
 lda    #$00
 sta    $37
 sta    ($37),y
 jsr    $BE6F
 bne    $8AF3
 jsr    $9857
 jsr    $BE6F
 bne    $8AF6
 jsr    $9857
 brk
 brk
 .byte  'S'
 .byte  'T'
 .byte  'O'
 bvc    $8ADA
 jsr    $9857
 lda    #$0D
 ldy    $18
 sty    $13
 ldy    #$00
 sty    $12
 sty    $20
 sta    ($12),y
 lda    #$FF
 iny
 sta    ($12),y
 iny
 sty    $12
 jsr    $BD20
 ldy    #$07
 sty    $0C
 ldy    #$00
 sty    $0B
 lda    #$33
 sta    $16
 lda    #$B4
 sta    $17
 lda    #$3E
 jsr    $BC02
 lda    #$33
 sta    $16
 lda    #$B4
 sta    $17
 ldx    #$FF
 stx    $28
 stx    $3C
 txs
 jsr    $BD3A
 tay
 lda    $0B
 sta    $37
 lda    $0C
 sta    $38
 sty    $3B
 sty    $0A
 jsr    $8957
 jsr    $97DF
 bcc    $8B38
 jsr    $BC8D
 jmp    $8AF3
 jsr    $8A97
 cmp    #$C6
 bcs    $8BB1
 bcc    $8BBF
 jmp    $8AF6
 jmp    $8504
 tsx
 cpx    #$FC
 bcs    $8B59
 lda    $01FF
 cmp    #$A4
 bne    $8B59
 jsr    $9B1D
 jmp    $984C
 brk
 .byte  $07
 lsr    $206F
 ldy    $00
 ldy    $0A
 dey
 lda    ($0B),y
 cmp    #$3D
 beq    $8B47
 cmp    #$2A
 beq    $8B73
 cmp    #$5B
 beq    $8B44
 bne    $8B96
 jsr    $986D
 ldx    $0B
 ldy    $0C
 jsr    OS_CLI
 lda    #$0D
 ldy    $0A
 dey
 iny
 cmp    ($0B),y
 bne    $8B82
 cmp    #$8B
 beq    $8B7D
 lda    $0C
 cmp    #$07
 beq    $8B41
 jsr    $9890
 bne    $8BA3
 dec    $0A
 jsr    $9857
 ldy    #$00
 lda    ($0B),y
 cmp    #$3A
 bne    $8B87
 ldy    $0A
 inc    $0A
 lda    ($0B),y
 cmp    #$20
 beq    $8BA3
 cmp    #$CF
 bcc    $8BBF
 tax
 lda    $82DF,x
 sta    $37
 lda    $8351,x
 sta    $38
 jmp    ($0037)
 ldx    $0B
 stx    $19
 ldx    $0C
 stx    $1A
 sty    $1B
 jsr    $95DD
 bne    $8BE9
 bcs    $8B60
 stx    $1B
 jsr    $9841
 jsr    $94FC
 ldx    #$05
 cpx    $2C
 bne    $8BDF
 inx
 jsr    $9531
 dec    $0A
 jsr    $9582
 beq    $8C0B
 bcc    $8BFB
 jsr    $BD94
 jsr    $9813
 lda    $27
 bne    $8C0E
 jsr    $8C1E
 jmp    $8B9B
 jsr    $BD94
 jsr    $9813
 lda    $27
 beq    $8C0E
 jsr    $B4B4
 jmp    $8B9B
 jmp    $982A
 brk
 asl    $54
 adc    $6570,y
 jsr    $696D
 .byte  's'
 adc    $7461
 .byte  'c'
 pla
 brk
 jsr    $BDEA
 lda    $2C
 cmp    #$80
 beq    $8CA2
 ldy    #$02
 lda    ($2A),y
 cmp    $36
 bcs    $8C84
 lda    $02
 sta    $2C
 lda    $03
 sta    $2D
 lda    $36
 cmp    #$08
 bcc    $8C43
 adc    #$07
 bcc    $8C43
 lda    #$FF
 clc
 pha
 tax
 lda    ($2A),y
 ldy    #$00
 adc    ($2A),y
 eor    $02
 bne    $8C5F
 iny
 adc    ($2A),y
 eor    $03
 bne    $8C5F
 sta    $2D
 txa
 iny
 sec
 sbc    ($2A),y
 tax
 txa
 clc
 adc    $02
 tay
 lda    $03
 adc    #$00
 cpy    $04
 tax
 sbc    $05
 bcs    $8CB7
 sty    $02
 stx    $03
 pla
 ldy    #$02
 sta    ($2A),y
 dey
 lda    $2D
 beq    $8C84
 sta    ($2A),y
 dey
 lda    $2C
 sta    ($2A),y
 ldy    #$03
 lda    $36
 sta    ($2A),y
 beq    $8CA1
 dey
 dey
 lda    ($2A),y
 sta    $2D
 dey
 lda    ($2A),y
 sta    $2C
 lda    $0600,y
 sta    ($2C),y
 iny
 cpy    $36
 bne    $8C97
 rts
 jsr    $BEBA
 cpy    #$00
 beq    $8CB4
 lda    $0600,y
 sta    ($2A),y
 dey
 bne    $8CA9
 lda    $0600
 sta    ($2A),y
 rts
 brk
 brk
 lsr    $206F
 .byte  'r'
 .byte  'o'
 .byte  'o'
 adc    $A500
 and    $80C9,y
 beq    $8CEE
 bcc    $8D03
 ldy    #$00
 lda    ($04),y
 tax
 beq    $8CE5
 lda    ($37),y
 sbc    #$01
 sta    $39
 iny
 lda    ($37),y
 sbc    #$00
 sta    $3A
 lda    ($04),y
 sta    ($39),y
 iny
 dex
 bne    $8CDD
 lda    ($04,x)
 ldy    #$03
 sta    ($37),y
 jmp    $BDDC
 ldy    #$00
 lda    ($04),y
 tax
 beq    $8CFF
 iny
 lda    ($04),y
 dey
 sta    ($37),y
 iny
 dex
 bne    $8CF5
 lda    #$0D
 bne    $8CE9
 ldy    #$00
 lda    ($04),y
 sta    ($37),y
 iny
 cpy    $39
 bcs    $8D26
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
 bcs    $8D26
 lda    ($04),y
 sta    ($37),y
 iny
 tya
 clc
 jmp    $BDE1
 dec    $0A
 jsr    $BFA9
 tya
 pha
 jsr    $8A8C
 cmp    #$2C
 bne    $8D77
 jsr    $9B29
 jsr    $A385
 pla
 tay
 lda    $27
 jsr    OSBPUT
 tax
 beq    $8D64
 bmi    $8D57
 ldx    #$03
 lda    $2A,x
 jsr    OSBPUT
 dex
 bpl    $8D4D
 bmi    $8D30
 ldx    #$04
 lda    $046C,x
 jsr    OSBPUT
 dex
 bpl    $8D59
 bmi    $8D30
 lda    $36
 jsr    OSBPUT
 tax
 beq    $8D30
 lda    $05FF,x
 jsr    OSBPUT
 dex
 bne    $8D6C
 beq    $8D30
 pla
 sty    $0A
 jmp    $8B98
 jsr    $BC25
 jmp    $8B96
 lda    #$00
 sta    $14
 sta    $15
 jsr    $8A97
 cmp    #$3A
 beq    $8D80
 cmp    #$0D
 beq    $8D80
 cmp    #$8B
 beq    $8D80
 bne    $8DD2
 jsr    $8A97
 cmp    #$23
 beq    $8D2B
 dec    $0A
 jmp    $8DBB
 lda    $0400
 beq    $8DBB
 lda    $1E
 beq    $8DBB
 sbc    $0400
 bcs    $8DAD
 tay
 jsr    $B565
 iny
 bne    $8DB5
 clc
 lda    $0400
 sta    $14
 ror    $15
 jsr    $8A97
 cmp    #$3A
 beq    $8D7D
 cmp    #$0D
 beq    $8D7D
 cmp    #$8B
 beq    $8D7D
 cmp    #$7E
 beq    $8DC1
 cmp    #$2C
 beq    $8DA6
 cmp    #$3B
 beq    $8D83
 jsr    $8E70
 bcc    $8DC3
 lda    $14
 pha
 lda    $15
 pha
 dec    $1B
 jsr    $9B29
 pla
 sta    $15
 pla
 sta    $14
 lda    $1B
 sta    $0A
 tya
 beq    $8E0E
 jsr    $9EDF
 lda    $14
 sec
 sbc    $36
 bcc    $8E0E
 beq    $8E0E
 tay
 jsr    $B565
 dey
 bne    $8E08
 lda    $36
 beq    $8DC3
 ldy    #$00
 lda    $0600,y
 jsr    $B558
 iny
 cpy    $36
 bne    $8E14
 beq    $8DC3
 jmp    $8AA2
 cmp    #$2C
 bne    $8E21
 lda    $2A
 pha
 jsr    $AE56
 jsr    $92F0
 lda    #$1F
 jsr    OSWRCH
 pla
 jsr    OSWRCH
 jsr    $9456
 jmp    $8E6A
 jsr    $92DD
 jsr    $8A8C
 cmp    #$29
 bne    $8E24
 lda    $2A
 sbc    $1E
 beq    $8E6A
 tay
 bcs    $8E5F
 jsr    $BC25
 beq    $8E5B
 jsr    $92E3
 ldy    $2A
 beq    $8E6A
 jsr    $B565
 dey
 bne    $8E5F
 beq    $8E6A
 jsr    $BC25
 clc
 ldy    $1B
 sty    $0A
 rts
 ldx    $0B
 stx    $19
 ldx    $0C
 stx    $1A
 ldx    $0A
 stx    $1B
 cmp    #$27
 beq    $8E67
 cmp    #$8A
 beq    $8E40
 cmp    #$89
 beq    $8E58
 sec
 rts
 jsr    $8A97
 jsr    $8E70
 bcc    $8E89
 cmp    #$22
 beq    $8EA7
 sec
 rts
 brk
 ora    #$4D
 adc    #$73
 .byte  's'
 adc    #$6E
 .byte  'g'
 jsr    $0022
 jsr    $B558
 iny
 lda    ($19),y
 cmp    #$0D
 beq    $8E98
 cmp    #$22
 bne    $8EA4
 iny
 sty    $1B
 lda    ($19),y
 cmp    #$22
 bne    $8E6A
 beq    $8EA4
 jsr    $9857
 lda    #$10
 bne    $8ECC
 jsr    $9857
 jsr    $BC28
 lda    #$0C
 jsr    OSWRCH
 jmp    $8B9B
 jsr    $9B1D
 jsr    $92EE
 jsr    $BD94
 ldy    #$00
 sty    $0600
 sty    $06FF
 jsr    $8A8C
 cmp    #$2C
 bne    $8F0C
 ldy    $1B
 jsr    $95D5
 beq    $8F1B
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
 jmp    $8EE0
 dec    $1B
 jsr    $9852
 jsr    $BDEA
 jsr    $8F1E
 cld
 jmp    $8B9B
 jmp    $AE43
 lda    $040C
 lsr    a
 lda    $0404
 ldx    $0460
 ldy    $0464
 jmp    ($002A)
 jmp    $982A
 jsr    $97DF
 bcc    $8F2E
 jsr    $BD94
 jsr    $8A97
 cmp    #$2C
 bne    $8F2E
 jsr    $97DF
 bcc    $8F2E
 jsr    $9857
 lda    $2A
 sta    $39
 lda    $2B
 sta    $3A
 jsr    $BDEA
 jsr    $BC2D
 jsr    $987B
 jsr    $9222
 lda    $39
 cmp    $2A
 lda    $3A
 sbc    $2B
 bcs    $8F53
 jmp    $8AF3
 lda    #$0A
 jsr    $AED8
 jsr    $97DF
 jsr    $BD94
 lda    #$0A
 jsr    $AED8
 jsr    $8A97
 cmp    #$2C
 bne    $8F8D
 jsr    $97DF
 lda    $2B
 bne    $8FDF
 lda    $2A
 beq    $8FDF
 inc    $0A
 dec    $0A
 jmp    $9857
 lda    $12
 sta    $3B
 lda    $13
 sta    $3C
 lda    $18
 sta    $38
 lda    #$01
 sta    $37
 rts
 jsr    $8F69
 ldx    #$39
 jsr    $BE0D
 jsr    $BE6F
 jsr    $8F92
 ldy    #$00
 lda    ($37),y
 bmi    $8FE7
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
 bcs    $8FD6
 jsr    $909F
 bcc    $8FB1
 brk
 brk
 cpy    $7320
 bvs    $903E
 .byte  'c'
 adc    $00
 brk
 .byte  'S'
 adc    #$6C
 jmp    ($0079)
 jsr    $8F9A
 ldy    #$00
 lda    ($37),y
 bmi    $900D
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
 jsr    $909F
 bcc    $8FEA
 lda    $18
 sta    $0C
 ldy    #$00
 sty    $0B
 iny
 lda    ($0B),y
 bmi    $903A
 ldy    #$04
 lda    ($0B),y
 cmp    #$8D
 beq    $903D
 iny
 cmp    #$0D
 bne    $901C
 lda    ($0B),y
 bmi    $903A
 ldy    #$03
 lda    ($0B),y
 clc
 adc    $0B
 sta    $0B
 bcc    $901A
 inc    $0C
 bcs    $901A
 jmp    $8AF3
 jsr    $97EB
 jsr    $8F92
 ldy    #$00
 lda    ($37),y
 bmi    $9080
 lda    ($3B),y
 iny
 cmp    $2B
 bne    $9071
 lda    ($3B),y
 cmp    $2A
 bne    $9071
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
 jsr    $88F5
 ldy    $0A
 bne    $901C
 jsr    $909F
 lda    $3B
 adc    #$02
 sta    $3B
 bcc    $9043
 inc    $3C
 bcs    $9043
 jsr    $BFCF
 lsr    $61
 adc    #$6C
 adc    $64
 jsr    $7461
 jsr    $B1C8
 .byte  $0B
 sta    $2B
 iny
 lda    ($0B),y
 sta    $2A
 jsr    $991F
 jsr    $BC25
 beq    $906D
 iny
 lda    ($37),y
 adc    $37
 sta    $37
 bcc    $90AB
 inc    $38
 clc
 rts
 jsr    $8F69
 lda    $2A
 pha
 jsr    $BDEA
 jsr    $BD94
 jsr    $9923
 lda    #$20
 jsr    $BC02
 jsr    $BDEA
 jsr    $8951
 jsr    $BC8D
 jsr    $BD20
 pla
 pha
 clc
 adc    $2A
 sta    $2A
 bcc    $90B5
 inc    $2B
 bpl    $90B5
 jmp    $8AF3
 jmp    $9218
 dec    $0A
 jsr    $9582
 beq    $9127
 bcs    $9127
 jsr    $BD94
 jsr    $92DD
 jsr    $9222
 lda    $2D
 ora    $2C
 bne    $9127
 clc
 lda    $2A
 adc    $02
 tay
 lda    $2B
 adc    $03
 tax
 cpy    $04
 sbc    $05
 bcs    $90DC
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
 jsr    $B4B4
 jsr    $8827
 jmp    $920B
 brk
 asl    a
 .byte  'B'
 adc    ($64,x)
 jsr    $00DE
 jsr    $8A97
 tya
 clc
 adc    $0B
 ldx    $0C
 bcc    $913C
 inx
 clc
 sbc    #$00
 sta    $37
 txa
 sbc    #$00
 sta    $38
 ldx    #$05
 stx    $3F
 ldx    $0A
 jsr    $9559
 cpy    #$01
 beq    $9127
 cmp    #$28
 beq    $916B
 cmp    #$24
 beq    $915E
 cmp    #$25
 bne    $9168
 dec    $3F
 iny
 inx
 lda    ($37),y
 cmp    #$28
 beq    $916B
 jmp    $90DF
 sty    $39
 stx    $0A
 jsr    $9469
 bne    $9127
 jsr    $94FC
 ldx    #$01
 jsr    $9531
 lda    $3F
 pha
 lda    #$01
 pha
 jsr    $AED8
 jsr    $BD94
 jsr    $8821
 lda    $2B
 and    #$C0
 ora    $2C
 ora    $2D
 bne    $9127
 jsr    $9222
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
 jsr    $9231
 jsr    $8A97
 cmp    #$2C
 beq    $9185
 cmp    #$29
 beq    $91B7
 jmp    $9127
 pla
 sta    $15
 pla
 sta    $3F
 lda    #$00
 sta    $40
 jsr    $9236
 ldy    #$00
 lda    $15
 sta    ($02),y
 adc    $2A
 sta    $2A
 bcc    $91D2
 inc    $2B
 lda    $03
 sta    $38
 lda    $02
 sta    $37
 clc
 adc    $2A
 tay
 lda    $2B
 adc    $03
 bcs    $9218
 tax
 cpy    $04
 sbc    $05
 bcs    $9218
 sty    $02
 stx    $03
 lda    $37
 adc    $15
 tay
 lda    #$00
 sta    $37
 bcc    $91FC
 inc    $38
 sta    ($37),y
 iny
 bne    $9203
 inc    $38
 cpy    $02
 bne    $91FC
 cpx    $38
 bne    $91FC
 jsr    $8A97
 cmp    #$2C
 beq    $9215
 jmp    $8B96
 jmp    $912F
 brk
 .byte  $0B
 dec    $7320,x
 bvs    $9280
 .byte  'c'
 adc    $00
 inc    $2A
 bne    $9230
 inc    $2B
 bne    $9230
 inc    $2C
 bne    $9230
 inc    $2D
 rts
 ldx    #$3F
 jsr    $BE0D
 ldx    #$00
 ldy    #$00
 lsr    $40
 ror    $3F
 bcc    $924B
 clc
 tya
 adc    $2A
 tay
 txa
 adc    $2B
 tax
 bcs    $925A
 asl    $2A
 rol    $2B
 lda    $3F
 ora    $40
 bne    $923A
 sty    $2A
 stx    $2B
 rts
 jmp    $9127
 jsr    $92EB
 lda    $2A
 sta    $06
 sta    $04
 lda    $2B
 sta    $07
 sta    $05
 jmp    $8B9B
 jsr    $92EB
 lda    $2A
 sta    $00
 sta    $02
 lda    $2B
 sta    $01
 sta    $03
 jsr    $BD2F
 beq    $928A
 jsr    $92EB
 lda    $2B
 sta    $18
 jmp    $8B9B
 jsr    $9857
 jsr    $BD20
 beq    $928A
 jsr    $97DF
 bcs    $92A5
 cmp    #$EE
 beq    $92B7
 cmp    #$87
 beq    $92C0
 jsr    $8821
 jsr    $9857
 lda    $2A
 sta    $21
 lda    $2B
 sta    $22
 lda    #$FF
 sta    $20
 jmp    $8B9B
 inc    $0A
 jsr    $9857
 lda    #$FF
 bne    $92AE
 inc    $0A
 jsr    $9857
 lda    #$00
 beq    $92B2
 jsr    $92EB
 ldx    #$2A
 ldy    #$00
 sty    $2E
 lda    #$02
 jsr    OSWORD
 jmp    $8B9B
 jsr    $8AAE
 jsr    $9B29
 jmp    $92F0
 jsr    $ADEC
 beq    $92F7
 bmi    $92F4
 rts
 jsr    $9807
 lda    $27
 beq    $92F7
 bpl    $92EA
 jmp    $A3E4
 jmp    $8C0E
 jsr    $ADEC
 beq    $92F7
 bmi    $92EA
 jmp    $A2BE
 lda    $0B
 sta    $19
 lda    $0C
 sta    $1A
 lda    $0A
 sta    $1B
 lda    #$F2
 jsr    $B197
 jsr    $9852
 jmp    $8B9B
 ldy    #$03
 lda    #$00
 sta    ($2A),y
 beq    $9341
 tsx
 cpx    #$FC
 bcs    $936B
 jsr    $9582
 beq    $9353
 jsr    $B30D
 ldy    $2C
 bmi    $931B
 jsr    $BD94
 lda    #$00
 jsr    $AED8
 sta    $27
 jsr    $B4B4
 tsx
 inc    $0106,x
 ldy    $1B
 sty    $0A
 jsr    $8A97
 cmp    #$2C
 beq    $9323
 jmp    $8B96
 jmp    $8B98
 tsx
 cpx    #$FC
 bcs    $9365
 lda    $01FF
 cmp    #$F2
 bne    $9365
 jmp    $9857
 brk
 ora    $6F4E
 jsr    $00F2
 .byte  $0C
 lsr    $746F
 jsr    $00EA
 ora    $6142,y
 .byte  'd'
 jsr    $00EB
 jsr    $8821
 lda    $2A
 pha
 jsr    $92DA
 jsr    $9852
 lda    #$12
 jsr    OSWRCH
 jmp    $93DA
 lda    #$11
 pha
 jsr    $8821
 jsr    $9857
 jmp    $93DA
 lda    #$16
 pha
 jsr    $8821
 jsr    $9857
 jsr    $BEE7
 cpx    #$FF
 bne    $93D7
 cpy    #$FF
 bne    $93D7
 lda    $04
 cmp    $06
 bne    $9372
 lda    $05
 cmp    $07
 bne    $9372
 ldx    $2A
 lda    #$85
 jsr    OSBYTE
 cpx    $02
 tya
 sbc    $03
 bcc    $9372
 cpx    $12
 tya
 sbc    $13
 bcc    $9372
 stx    $06
 stx    $04
 sty    $07
 sty    $05
 jsr    $BC28
 pla
 jsr    OSWRCH
 jsr    $9456
 jmp    $8B9B
 lda    #$04
 bne    $93EA
 lda    #$05
 pha
 jsr    $9B1D
 jmp    $93FD
 jsr    $8821
 lda    $2A
 pha
 jsr    $8AAE
 jsr    $9B29
 jsr    $92EE
 jsr    $BD94
 jsr    $92DA
 jsr    $9852
 lda    #$19
 jsr    OSWRCH
 pla
 jsr    OSWRCH
 jsr    $BE0B
 lda    $37
 jsr    OSWRCH
 lda    $38
 jsr    OSWRCH
 jsr    $9456
 lda    $2B
 jsr    OSWRCH
 jmp    $8B9B
 lda    $2B
 jsr    OSWRCH
 jsr    $8A97
 cmp    #$3A
 beq    $9453
 cmp    #$0D
 beq    $9453
 cmp    #$8B
 beq    $9453
 dec    $0A
 jsr    $8821
 jsr    $9456
 jsr    $8A97
 cmp    #$2C
 beq    $942F
 cmp    #$3B
 bne    $9432
 beq    $942A
 jmp    $8B96
 lda    $2A
 jmp    (WRCHV)
 ldy    #$01
 lda    ($37),y
 ldy    #$F6
 cmp    #$F2
 beq    $946F
 ldy    #$F8
 bne    $946F
 ldy    #$01
 lda    ($37),y
 asl    a
 tay
 lda    $0400,y
 sta    $3A
 lda    $0401,y
 sta    $3B
 lda    $3B
 beq    $94B2
 ldy    #$00
 lda    ($3A),y
 sta    $3C
 iny
 lda    ($3A),y
 sta    $3D
 iny
 lda    ($3A),y
 bne    $949A
 dey
 cpy    $39
 bne    $94B3
 iny
 bcs    $94A7
 iny
 lda    ($3A),y
 beq    $94B3
 cmp    ($37),y
 bne    $94B3
 cpy    $39
 bne    $9495
 iny
 lda    ($3A),y
 bne    $94B3
 tya
 adc    $3A
 sta    $2A
 lda    $3B
 adc    #$00
 sta    $2B
 rts
 lda    $3D
 beq    $94B2
 ldy    #$00
 lda    ($3C),y
 sta    $3A
 iny
 lda    ($3C),y
 sta    $3B
 iny
 lda    ($3C),y
 bne    $94D4
 dey
 cpy    $39
 bne    $9479
 iny
 bcs    $94E1
 iny
 lda    ($3C),y
 beq    $9479
 cmp    ($37),y
 bne    $9479
 cpy    $39
 bne    $94CF
 iny
 lda    ($3C),y
 bne    $9479
 tya
 adc    $3C
 sta    $2A
 lda    $3D
 adc    #$00
 sta    $2B
 rts
 ldy    #$01
 lda    ($37),y
 tax
 lda    #$F6
 cpx    #$F2
 beq    $9501
 lda    #$F8
 bne    $9501
 ldy    #$01
 lda    ($37),y
 asl    a
 sta    $3A
 lda    #$04
 sta    $3B
 lda    ($3A),y
 beq    $9516
 tax
 dey
 lda    ($3A),y
 sta    $3A
 stx    $3B
 iny
 bpl    $9507
 lda    $03
 sta    ($3A),y
 lda    $02
 dey
 sta    ($3A),y
 tya
 iny
 sta    ($02),y
 cpy    $39
 beq    $9558
 iny
 lda    ($37),y
 sta    ($02),y
 cpy    $39
 bne    $9527
 rts
 lda    #$00
 iny
 sta    ($02),y
 dex
 bne    $9533
 sec
 tya
 adc    $02
 bcc    $9541
 inc    $03
 ldy    $03
 cpy    $05
 bcc    $9556
 bne    $954D
 cmp    $04
 bcc    $9556
 lda    #$00
 ldy    #$01
 sta    ($3A),y
 jmp    $8CB7
 sta    $02
 rts
 ldy    #$01
 lda    ($37),y
 cmp    #$30
 bcc    $9579
 cmp    #$40
 bcs    $9571
 cmp    #$3A
 bcs    $9579
 cpy    #$01
 beq    $9579
 inx
 iny
 bne    $955B
 cmp    #$5F
 bcs    $957A
 cmp    #$5B
 bcc    $956D
 rts
 cmp    #$7B
 bcc    $956D
 rts
 jsr    $9531
 jsr    $95C9
 bne    $95A4
 bcs    $95A4
 jsr    $94FC
 ldx    #$05
 cpx    $2C
 bne    $957F
 inx
 bne    $957F
 cmp    #$21
 beq    $95A5
 cmp    #$24
 beq    $95B0
 eor    #$3F
 beq    $95A7
 lda    #$00
 sec
 rts
 lda    #$04
 pha
 inc    $1B
 jsr    $92E3
 jmp    $969F
 inc    $1B
 jsr    $92E3
 lda    $2B
 beq    $95BF
 lda    #$80
 sta    $2C
 sec
 rts
 brk
 php
 bit    $20
 .byte  'r'
 adc    ($6E,x)
 .byte  'g'
 adc    $00
 lda    $0B
 sta    $19
 lda    $0C
 sta    $1A
 ldy    $0A
 dey
 iny
 sty    $1B
 lda    ($19),y
 cmp    #$20
 beq    $95D4
 cmp    #$40
 bcc    $9595
 cmp    #$5B
 bcs    $95FF
 asl    a
 asl    a
 sta    $2A
 lda    #$04
 sta    $2B
 iny
 lda    ($19),y
 iny
 cmp    #$25
 bne    $95FF
 ldx    #$04
 stx    $2C
 lda    ($19),y
 cmp    #$28
 bne    $9665
 ldx    #$05
 stx    $2C
 lda    $1B
 clc
 adc    $19
 ldx    $1A
 bcc    $960E
 inx
 clc
 sbc    #$00
 sta    $37
 bcs    $9615
 dex
 stx    $38
 ldx    $1B
 ldy    #$01
 lda    ($37),y
 cmp    #$41
 bcs    $962D
 cmp    #$30
 bcc    $9641
 cmp    #$3A
 bcs    $9641
 inx
 iny
 bne    $961B
 cmp    #$5B
 bcs    $9635
 inx
 iny
 bne    $961B
 cmp    #$5F
 bcc    $9641
 cmp    #$7B
 bcs    $9641
 inx
 iny
 bne    $961B
 dey
 beq    $9673
 cmp    #$24
 beq    $96AF
 cmp    #$25
 bne    $9654
 dec    $2C
 iny
 inx
 iny
 lda    ($37),y
 dey
 sty    $39
 cmp    #$28
 beq    $96A6
 jsr    $9469
 beq    $9677
 stx    $1B
 ldy    $1B
 lda    ($19),y
 cmp    #$21
 beq    $967F
 cmp    #$3F
 beq    $967B
 clc
 sty    $1B
 lda    #$FF
 rts
 lda    #$00
 sec
 rts
 lda    #$00
 clc
 rts
 lda    #$00
 beq    $9681
 lda    #$04
 pha
 iny
 sty    $1B
 jsr    $B32C
 jsr    $92F0
 lda    $2B
 pha
 lda    $2A
 pha
 jsr    $92E3
 clc
 pla
 adc    $2A
 sta    $2A
 pla
 adc    $2B
 sta    $2B
 pla
 sta    $2C
 clc
 lda    #$FF
 rts
 inx
 inc    $39
 jsr    $96DF
 jmp    $9661
 inx
 iny
 sty    $39
 iny
 dec    $2C
 lda    ($37),y
 cmp    #$28
 beq    $96C9
 jsr    $9469
 beq    $9677
 stx    $1B
 lda    #$81
 sta    $2C
 sec
 rts
 inx
 sty    $39
 dec    $2C
 jsr    $96DF
 lda    #$81
 sta    $2C
 sec
 rts
 brk
 asl    $7241
 .byte  'r'
 adc    ($79,x)
 brk
 jsr    $9469
 beq    $96D7
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
 bcc    $976C
 tya
 jsr    $AED8
 lda    #$01
 sta    $2D
 jsr    $BD94
 jsr    $92DD
 inc    $1B
 cpx    #$2C
 bne    $96D7
 ldx    #$39
 jsr    $BE0D
 ldy    $3C
 pla
 sta    $38
 pla
 sta    $37
 pha
 lda    $38
 pha
 jsr    $97BA
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
 jsr    $9236
 ldy    #$00
 sec
 lda    ($37),y
 sbc    $2D
 cmp    #$03
 bcs    $96FF
 jsr    $BD94
 jsr    $AE56
 jsr    $92F0
 pla
 sta    $38
 pla
 sta    $37
 ldx    #$39
 jsr    $BE0D
 ldy    $3C
 jsr    $97BA
 clc
 lda    $39
 adc    $2A
 sta    $2A
 lda    $3A
 adc    $2B
 sta    $2B
 bcc    $977D
 jsr    $AE56
 jsr    $92F0
 pla
 sta    $38
 pla
 sta    $37
 ldy    #$01
 jsr    $97BA
 pla
 sta    $2C
 cmp    #$05
 bne    $979B
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
 bcc    $97A3
 asl    $2A
 rol    $2B
 asl    $2A
 rol    $2B
 tya
 adc    $2A
 sta    $2A
 bcc    $97AD
 inc    $2B
 clc
 lda    $37
 adc    $2A
 sta    $2A
 lda    $38
 adc    $2B
 sta    $2B
 rts
 lda    $2B
 and    #$C0
 ora    $2C
 ora    $2D
 bne    $97D1
 lda    $2A
 cmp    ($37),y
 iny
 lda    $2B
 sbc    ($37),y
 bcs    $97D1
 iny
 rts
 brk
 .byte  $0F
 .byte  'S'
 adc    $62,x
 .byte  's'
 .byte  'c'
 .byte  'r'
 adc    #$70
 .byte  't'
 brk
 inc    $0A
 ldy    $0A
 lda    ($0B),y
 cmp    #$20
 beq    $97DD
 cmp    #$8D
 bne    $9805
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
 clc
 rts
 lda    $0B
 sta    $19
 lda    $0C
 sta    $1A
 lda    $0A
 sta    $1B
 ldy    $1B
 inc    $1B
 lda    ($19),y
 cmp    #$20
 beq    $9813
 cmp    #$3D
 beq    $9849
 brk
 .byte  $04
 eor    $7369
 .byte  't'
 adc    ($6B,x)
 adc    $00
 bpl    $9880
 adc    $746E,y
 adc    ($78,x)
 jsr    $7265
 .byte  'r'
 .byte  'o'
 .byte  'r'
 brk
 ora    ($45),y
 .byte  's'
 .byte  'c'
 adc    ($70,x)
 adc    $00
 jsr    $8A8C
 cmp    #$3D
 bne    $9821
 rts
 jsr    $9B29
 txa
 ldy    $1B
 jmp    $9861
 ldy    $1B
 jmp    $9859
 ldy    $0A
 dey
 iny
 lda    ($0B),y
 cmp    #$20
 beq    $985A
 cmp    #$3A
 beq    $986D
 cmp    #$0D
 beq    $986D
 cmp    #$8B
 bne    $982A
 clc
 tya
 adc    $0B
 sta    $0B
 bcc    $9877
 inc    $0C
 ldy    #$01
 sty    $0A
 bit    $FF
 bmi    $9838
 rts
 jsr    $9857
 dey
 lda    ($0B),y
 cmp    #$3A
 beq    $987F
 lda    $0C
 cmp    #$07
 beq    $98BC
 iny
 lda    ($0B),y
 bmi    $98BC
 lda    $20
 beq    $98AC
 tya
 pha
 iny
 lda    ($0B),y
 pha
 dey
 lda    ($0B),y
 tay
 pla
 jsr    $AEEA
 jsr    $9905
 pla
 tay
 iny
 sec
 tya
 adc    $0B
 sta    $0B
 bcc    $98B7
 inc    $0C
 ldy    #$01
 sty    $0A
 rts
 jmp    $8AF6
 jmp    $8C0E
 jsr    $9B1D
 beq    $98BF
 bpl    $98CC
 jsr    $A3E4
 ldy    $1B
 sty    $0A
 lda    $2A
 ora    $2B
 ora    $2C
 ora    $2D
 beq    $98F1
 cpx    #$8C
 beq    $98E1
 jmp    $8BA3
 inc    $0A
 jsr    $97DF
 bcc    $98DE
 jsr    $B9AF
 jsr    $9877
 jmp    $B8D2
 ldy    $0A
 lda    ($0B),y
 cmp    #$0D
 beq    $9902
 iny
 cmp    #$8B
 bne    $98F3
 sty    $0A
 beq    $98E3
 jmp    $8B87
 lda    $2A
 cmp    $21
 lda    $2B
 sbc    $22
 bcs    $98BB
 lda    #$5B
 jsr    $B558
 jsr    $991F
 lda    #$5D
 jsr    $B558
 jmp    $B565
 lda    #$00
 beq    $9925
 lda    #$05
 sta    $14
 ldx    #$04
 lda    #$00
 sta    $3F,x
 sec
 lda    $2A
 sbc    $996B,x
 tay
 lda    $2B
 sbc    $99B9,x
 bcc    $9943
 sta    $2B
 sty    $2A
 inc    $3F,x
 bne    $992E
 dex
 bpl    $9929
 ldx    #$05
 dex
 beq    $994F
 lda    $3F,x
 beq    $9948
 stx    $37
 lda    $14
 beq    $9960
 sbc    $37
 beq    $9960
 tay
 jsr    $B565
 dey
 bne    $995A
 lda    $3F,x
 ora    #$30
 jsr    $B558
 dex
 bpl    $9960
 rts
 ora    ($0A,x)
 .byte  'd'
 inx
 bpl    $9911
 brk
 sty    $3D
 lda    $18
 sta    $3E
 ldy    #$01
 lda    ($3D),y
 cmp    $2B
 bcs    $998E
 ldy    #$03
 lda    ($3D),y
 adc    $3D
 sta    $3D
 bcc    $9978
 inc    $3E
 bcs    $9978
 bne    $99A4
 ldy    #$02
 lda    ($3D),y
 cmp    $2A
 bcc    $9980
 bne    $99A4
 tya
 adc    $3D
 sta    $3D
 bcc    $99A4
 inc    $3E
 clc
 ldy    #$02
 rts
 brk
 .byte  $12
 .byte  'D'
 adc    #$76
 adc    #$73
 adc    #$6F
 ror    $6220
 adc    $7A20,y
 adc    $72
 .byte  'o'
 brk
 brk
 brk
 .byte  $03
 .byte  $27
 tay
 jsr    $92F0
 lda    $2D
 pha
 jsr    $AD71
 jsr    $9E1D
 stx    $27
 tay
 jsr    $92F0
 pla
 sta    $38
 eor    $2D
 sta    $37
 jsr    $AD71
 ldx    #$39
 jsr    $BE0D
 sty    $3D
 sty    $3E
 sty    $3F
 sty    $40
 lda    $2D
 ora    $2A
 ora    $2B
 ora    $2C
 beq    $99A7
 ldy    #$20
 dey
 beq    $9A38
 asl    $39
 rol    $3A
 rol    $3B
 rol    $3C
 bpl    $99F4
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
 bcc    $9A33
 sta    $40
 stx    $3F
 pla
 sta    $3E
 pla
 sta    $3D
 bcs    $9A35
 pla
 pla
 dey
 bne    $9A01
 rts
 stx    $27
 jsr    $BDEA
 jsr    $BD51
 jsr    $A2BE
 jsr    $A21E
 jsr    $BD7E
 jsr    $A3B5
 jmp    $9A62
 jsr    $BD51
 jsr    $9C42
 stx    $27
 tay
 jsr    $92FD
 jsr    $BD7E
 jsr    $A34E
 ldx    $27
 ldy    #$00
 lda    $3B
 and    #$80
 sta    $3B
 lda    $2E
 and    #$80
 cmp    $3B
 bne    $9A92
 lda    $3D
 cmp    $30
 bne    $9A93
 lda    $3E
 cmp    $31
 bne    $9A93
 lda    $3F
 cmp    $32
 bne    $9A93
 lda    $40
 cmp    $33
 bne    $9A93
 lda    $41
 cmp    $34
 bne    $9A93
 rts
 ror    a
 eor    $3B
 rol    a
 lda    #$01
 rts
 jmp    $8C0E
 txa
 beq    $9AE7
 bmi    $9A50
 jsr    $BD94
 jsr    $9C42
 tay
 beq    $9A9A
 bmi    $9A39
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
 php
 clc
 lda    #$04
 adc    $04
 sta    $04
 bcc    $9AE5
 inc    $05
 plp
 rts
 jsr    $BDB2
 jsr    $9C42
 tay
 bne    $9A9A
 stx    $37
 ldx    $36
 ldy    #$00
 lda    ($04),y
 sta    $39
 cmp    $36
 bcs    $9AFF
 tax
 stx    $3A
 ldy    #$00
 cpy    $3A
 beq    $9B11
 iny
 lda    ($04),y
 cmp    $05FF,y
 beq    $9B03
 bne    $9B15
 lda    $39
 cmp    $36
 php
 jsr    $BDDC
 ldx    $37
 plp
 rts
 lda    $0B
 sta    $19
 lda    $0C
 sta    $1A
 lda    $0A
 sta    $1B
 jsr    $9B72
 cpx    #$84
 beq    $9B3A
 cpx    #$82
 beq    $9B55
 dec    $1B
 tay
 sta    $27
 rts
 jsr    $9B6B
 tay
 jsr    $92F0
 ldy    #$03
 lda    ($04),y
 ora    $002A,y
 sta    $002A,y
 dey
 bpl    $9B43
 jsr    $BDFF
 lda    #$40
 bne    $9B2C
 jsr    $9B6B
 tay
 jsr    $92F0
 ldy    #$03
 lda    ($04),y
 eor    $002A,y
 sta    $002A,y
 dey
 bpl    $9B5E
 bmi    $9B4E
 tay
 jsr    $92F0
 jsr    $BD94
 jsr    $9B9C
 cpx    #$80
 beq    $9B7A
 rts
 tay
 jsr    $92F0
 jsr    $BD94
 jsr    $9B9C
 tay
 jsr    $92F0
 ldy    #$03
 lda    ($04),y
 and    $002A,y
 sta    $002A,y
 dey
 bpl    $9B8A
 jsr    $BDFF
 lda    #$40
 bne    $9B75
 jsr    $9C42
 cpx    #$3F
 bcs    $9BA7
 cpx    #$3C
 bcs    $9BA8
 rts
 beq    $9BC0
 cpx    #$3E
 beq    $9BE8
 tax
 jsr    $9A9E
 bne    $9BB5
 dey
 sty    $2A
 sty    $2B
 sty    $2C
 sty    $2D
 lda    #$40
 rts
 tax
 ldy    $1B
 lda    ($19),y
 cmp    #$3D
 beq    $9BD4
 cmp    #$3E
 beq    $9BDF
 jsr    $9A9D
 bcc    $9BB4
 bcs    $9BB5
 inc    $1B
 jsr    $9A9D
 beq    $9BB4
 bcc    $9BB4
 bcs    $9BB5
 inc    $1B
 jsr    $9A9D
 bne    $9BB4
 beq    $9BB5
 tax
 ldy    $1B
 lda    ($19),y
 cmp    #$3D
 beq    $9BFA
 jsr    $9A9D
 beq    $9BB5
 bcs    $9BB4
 bcc    $9BB5
 inc    $1B
 jsr    $9A9D
 bcs    $9BB4
 bcc    $9BB5
 brk
 .byte  $13
 .byte  'S'
 .byte  't'
 .byte  'r'
 adc    #$6E
 .byte  'g'
 jsr    $6F74
 .byte  'o'
 jsr    $6F6C
 ror    a:$0067
 jsr    $BDB2
 jsr    $9E20
 tay
 bne    $9C88
 clc
 stx    $37
 ldy    #$00
 lda    ($04),y
 adc    $36
 bcs    $9C03
 tax
 pha
 ldy    $36
 lda    $05FF,y
 sta    $05FF,x
 dex
 dey
 bne    $9C2D
 jsr    $BDCB
 pla
 sta    $36
 ldx    $37
 tya
 beq    $9C45
 jsr    $9DD1
 cpx    #$2B
 beq    $9C4E
 cpx    #$2D
 beq    $9CB5
 rts
 tay
 beq    $9C15
 bmi    $9C8B
 jsr    $9DCE
 tay
 beq    $9C88
 bmi    $9CA7
 ldy    #$00
 clc
 lda    ($04),y
 adc    $2A
 sta    $2A
 iny
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
 sta    $2D
 clc
 lda    $04
 adc    #$04
 sta    $04
 lda    #$40
 bcc    $9C45
 inc    $05
 bcs    $9C45
 jmp    $8C0E
 jsr    $BD51
 jsr    $9DD1
 tay
 beq    $9C88
 stx    $27
 bmi    $9C9B
 jsr    $A2BE
 jsr    $BD7E
 jsr    $A500
 ldx    $27
 lda    #$FF
 bne    $9C45
 stx    $27
 jsr    $BDEA
 jsr    $BD51
 jsr    $A2BE
 jmp    $9C9B
 tay
 beq    $9C88
 bmi    $9CE1
 jsr    $9DCE
 tay
 beq    $9C88
 bmi    $9CFA
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
 sbc    $2D
 jmp    $9C77
 jsr    $BD51
 jsr    $9DD1
 tay
 beq    $9C88
 stx    $27
 bmi    $9CF1
 jsr    $A2BE
 jsr    $BD7E
 jsr    $A4FD
 jmp    $9CA1
 stx    $27
 jsr    $BDEA
 jsr    $BD51
 jsr    $A2BE
 jsr    $BD7E
 jsr    $A4D0
 jmp    $9CA1
 jsr    $A2BE
 jsr    $BDEA
 jsr    $BD51
 jsr    $A2BE
 jmp    $9D2C
 jsr    $A2BE
 jsr    $BD51
 jsr    $9E20
 stx    $27
 tay
 jsr    $92FD
 jsr    $BD7E
 jsr    $A656
 lda    #$FF
 ldx    $27
 jmp    $9DD4
 jmp    $8C0E
 tay
 beq    $9D39
 bmi    $9D20
 lda    $2D
 cmp    $2C
 bne    $9D1D
 tay
 beq    $9D4E
 cmp    #$FF
 bne    $9D1D
 eor    $2B
 bmi    $9D1D
 jsr    $9E1D
 stx    $27
 tay
 beq    $9D39
 bmi    $9D11
 lda    $2D
 cmp    $2C
 bne    $9D0E
 tay
 beq    $9D69
 cmp    #$FF
 bne    $9D0E
 eor    $2B
 bmi    $9D0E
 lda    $2D
 pha
 jsr    $AD71
 ldx    #$39
 jsr    $BE44
 jsr    $BDEA
 pla
 eor    $2D
 sta    $37
 jsr    $AD71
 ldy    #$00
 ldx    #$00
 sty    $3F
 sty    $40
 lsr    $3A
 ror    $39
 bcc    $9DA6
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
 asl    $2A
 rol    $2B
 rol    $2C
 rol    $2D
 lda    $39
 ora    $3A
 bne    $9D8B
 sty    $3D
 stx    $3E
 lda    $37
 php
 ldx    #$3D
 jsr    $AF56
 plp
 bpl    $9DC6
 jsr    $AD93
 ldx    $27
 jmp    $9DD4
 jmp    $9D3C
 jsr    $BD94
 jsr    $9E20
 cpx    #$2A
 beq    $9DCB
 cpx    #$2F
 beq    $9DE5
 cpx    #$83
 beq    $9E01
 cpx    #$81
 beq    $9E0A
 rts
 tay
 jsr    $92FD
 jsr    $BD51
 jsr    $9E20
 stx    $27
 tay
 jsr    $92FD
 jsr    $BD7E
 jsr    $A6AD
 ldx    $27
 lda    #$FF
 bne    $9DD4
 jsr    $99BE
 lda    $38
 php
 jmp    $9DBB
 jsr    $99BE
 rol    $39
 rol    $3A
 rol    $3B
 rol    $3C
 bit    $37
 php
 ldx    #$39
 jmp    $9DBD
 jsr    $BD94
 jsr    $ADEC
 pha
 ldy    $1B
 inc    $1B
 lda    ($19),y
 cmp    #$20
 beq    $9E24
 tax
 pla
 cpx    #$5E
 beq    $9E35
 rts
 tay
 jsr    $92FD
 jsr    $BD51
 jsr    $92FA
 lda    $30
 cmp    #$87
 bcs    $9E88
 jsr    $A486
 bne    $9E59
 jsr    $BD7E
 jsr    $A3B5
 lda    $4A
 jsr    $AB12
 lda    #$FF
 bne    $9E23
 jsr    $A381
 lda    $04
 sta    $4B
 lda    $05
 sta    $4C
 jsr    $A3B5
 lda    $4A
 jsr    $AB12
 jsr    $A37D
 jsr    $BD7E
 jsr    $A3B5
 jsr    $A801
 jsr    $AAD1
 jsr    $AA94
 jsr    $A7ED
 jsr    $A656
 lda    #$FF
 bne    $9E23
 jsr    $A381
 jsr    $A699
 bne    $9E6C
 tya
 bpl    $9E96
 jsr    $A3E4
 ldx    #$00
 ldy    #$00
 lda    $002A,y
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
 cpy    #$04
 bne    $9E9A
 dex
 beq    $9EB7
 lda    $3F,x
 beq    $9EB0
 lda    $3F,x
 cmp    #$0A
 bcc    $9EBF
 adc    #$06
 adc    #$30
 jsr    $A066
 dex
 bpl    $9EB7
 rts
 bpl    $9ED1
 lda    #$2D
 sta    $2E
 jsr    $A066
 lda    $30
 cmp    #$81
 bcs    $9F25
 jsr    $A1F4
 dec    $49
 jmp    $9ED1
 ldx    $0402
 cpx    #$03
 bcc    $9EE8
 ldx    #$00
 stx    $37
 lda    $0401
 beq    $9EF5
 cmp    #$0A
 bcs    $9EF9
 bcc    $9EFB
 cpx    #$02
 beq    $9EFB
 lda    #$0A
 sta    $38
 sta    $4E
 lda    #$00
 sta    $36
 sta    $49
 bit    $15
 bmi    $9E90
 tya
 bmi    $9F0F
 jsr    $A2BE
 jsr    $A1DA
 bne    $9EC8
 lda    $37
 bne    $9F1D
 lda    #$30
 jmp    $A066
 jmp    $9F9C
 jsr    $A699
 bne    $9F34
 cmp    #$84
 bcc    $9F39
 bne    $9F31
 lda    $31
 cmp    #$A0
 bcc    $9F39
 jsr    $A24D
 inc    $49
 jmp    $9ED1
 lda    $35
 sta    $27
 jsr    $A385
 lda    $4E
 sta    $38
 ldx    $37
 cpx    #$02
 bne    $9F5C
 adc    $49
 bmi    $9FA0
 sta    $38
 cmp    #$0B
 bcc    $9F5C
 lda    #$0A
 sta    $38
 lda    #$00
 sta    $37
 jsr    $A686
 lda    #$A0
 sta    $31
 lda    #$83
 sta    $30
 ldx    $38
 beq    $9F71
 jsr    $A24D
 dex
 bne    $9F6B
 jsr    $A7F5
 jsr    $A34E
 lda    $27
 sta    $42
 jsr    $A50B
 lda    $30
 cmp    #$84
 bcs    $9F92
 ror    $31
 ror    $32
 ror    $33
 ror    $34
 ror    $35
 inc    $30
 bne    $9F7E
 lda    $31
 cmp    #$A0
 bcs    $9F20
 lda    $38
 bne    $9FAD
 cmp    #$01
 beq    $9FE6
 jsr    $A686
 lda    #$00
 sta    $49
 lda    $4E
 sta    $38
 inc    $38
 lda    #$01
 cmp    $37
 beq    $9FE6
 ldy    $49
 bmi    $9FC3
 cpy    $38
 bcs    $9FE6
 lda    #$00
 sta    $49
 iny
 tya
 bne    $9FE6
 lda    $37
 cmp    #$02
 beq    $9FCF
 lda    #$01
 cpy    #$FF
 bne    $9FE6
 lda    #$30
 jsr    $A066
 lda    #$2E
 jsr    $A066
 lda    #$30
 inc    $49
 beq    $9FE4
 jsr    $A066
 bne    $9FDB
 lda    #$80
 sta    $4E
 jsr    $A040
 dec    $4E
 bne    $9FF4
 lda    #$2E
 jsr    $A066
 dec    $38
 bne    $9FE8
 ldy    $37
 dey
 beq    $A015
 dey
 beq    $A011
 ldy    $36
 dey
 lda    $0600,y
 cmp    #$30
 beq    $A002
 cmp    #$2E
 beq    $A00F
 iny
 sty    $36
 lda    $49
 beq    $A03F
 lda    #$45
 jsr    $A066
 lda    $49
 bpl    $A028
 lda    #$2D
 jsr    $A066
 sec
 lda    #$00
 sbc    $49
 jsr    $A052
 lda    $37
 beq    $A03F
 lda    #$20
 ldy    $49
 bmi    $A038
 jsr    $A066
 cpx    #$00
 bne    $A03F
 jmp    $A066
 rts
 lda    $31
 lsr    a
 lsr    a
 lsr    a
 lsr    a
 jsr    $A064
 lda    $31
 and    #$0F
 sta    $31
 jmp    $A197
 ldx    #$FF
 sec
 inx
 sbc    #$0A
 bcs    $A055
 adc    #$0A
 pha
 txa
 beq    $A063
 jsr    $A064
 pla
 ora    #$30
 stx    $3B
 ldx    $36
 sta    $0600,x
 ldx    $3B
 inc    $36
 rts
 clc
 stx    $35
 jsr    $A1DA
 lda    #$FF
 rts
 ldx    #$00
 stx    $31
 stx    $32
 stx    $33
 stx    $34
 stx    $35
 stx    $48
 stx    $49
 cmp    #$2E
 beq    $A0A0
 cmp    #$3A
 bcs    $A072
 sbc    #$2F
 bmi    $A072
 sta    $35
 iny
 lda    ($19),y
 cmp    #$2E
 bne    $A0A8
 lda    $48
 bne    $A0E8
 inc    $48
 bne    $A099
 cmp    #$45
 beq    $A0E1
 cmp    #$3A
 bcs    $A0E8
 sbc    #$2F
 bcc    $A0E8
 ldx    $31
 cpx    #$18
 bcc    $A0C2
 ldx    $48
 bne    $A099
 inc    $49
 bcs    $A099
 ldx    $48
 beq    $A0C8
 dec    $49
 jsr    $A197
 adc    $35
 sta    $35
 bcc    $A099
 inc    $34
 bne    $A099
 inc    $33
 bne    $A099
 inc    $32
 bne    $A099
 inc    $31
 bne    $A099
 jsr    $A140
 adc    $49
 sta    $49
 sty    $1B
 lda    $49
 ora    $48
 beq    $A11F
 jsr    $A1DA
 beq    $A11B
 lda    #$A8
 sta    $30
 lda    #$00
 sta    $2F
 sta    $2E
 jsr    $A303
 lda    $49
 bmi    $A111
 beq    $A118
 jsr    $A1F4
 dec    $49
 bne    $A108
 beq    $A118
 jsr    $A24D
 inc    $49
 bne    $A111
 jsr    $A65C
 sec
 lda    #$FF
 rts
 lda    $32
 sta    $2D
 and    #$80
 ora    $31
 bne    $A0F5
 lda    $35
 sta    $2A
 lda    $34
 sta    $2B
 lda    $33
 sta    $2C
 lda    #$40
 sec
 rts
 jsr    $A14B
 eor    #$FF
 sec
 rts
 iny
 lda    ($19),y
 cmp    #$2D
 beq    $A139
 cmp    #$2B
 bne    $A14E
 iny
 lda    ($19),y
 cmp    #$3A
 bcs    $A174
 sbc    #$2F
 bcc    $A174
 sta    $4A
 iny
 lda    ($19),y
 cmp    #$3A
 bcs    $A170
 sbc    #$2F
 bcc    $A170
 iny
 sta    $43
 lda    $4A
 asl    a
 asl    a
 adc    $4A
 asl    a
 adc    $43
 rts
 lda    $4A
 clc
 rts
 lda    #$00
 clc
 rts
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
 lda    $31
 ora    $32
 ora    $33
 ora    $34
 ora    $35
 beq    $A1ED
 lda    $2E
 bne    $A1F3
 lda    #$01
 rts
 sta    $2E
 sta    $30
 sta    $2F
 rts
 clc
 lda    $30
 adc    #$03
 sta    $30
 bcc    $A1FF
 inc    $2F
 jsr    $A21E
 jsr    $A242
 jsr    $A242
 jsr    $A178
 bcc    $A21D
 ror    $31
 ror    $32
 ror    $33
 ror    $34
 ror    $35
 inc    $30
 bne    $A21D
 inc    $2F
 rts
 lda    $2E
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
 jsr    $A21E
 lsr    $3E
 ror    $3F
 ror    $40
 ror    $41
 ror    $42
 rts
 sec
 lda    $30
 sbc    #$04
 sta    $30
 bcs    $A258
 dec    $2F
 jsr    $A23F
 jsr    $A208
 jsr    $A23F
 jsr    $A242
 jsr    $A242
 jsr    $A242
 jsr    $A208
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
 jsr    $A208
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
 jsr    $A208
 lda    $32
 rol    a
 lda    $31
 adc    $35
 sta    $35
 bcc    $A2BD
 inc    $34
 bne    $A2BD
 inc    $33
 bne    $A2BD
 inc    $32
 bne    $A2BD
 inc    $31
 bne    $A2BD
 jmp    $A20B
 rts
 ldx    #$00
 stx    $35
 stx    $2F
 lda    $2D
 bpl    $A2CD
 jsr    $AD93
 ldx    #$FF
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
 jmp    $A303
 sta    $2E
 sta    $30
 sta    $2F
 rts
 pha
 jsr    $A686
 pla
 beq    $A2EC
 bpl    $A2FD
 sta    $2E
 lda    #$00
 sec
 sbc    $2E
 sta    $31
 lda    #$88
 sta    $30
 lda    $31
 bmi    $A2EC
 ora    $32
 ora    $33
 ora    $34
 ora    $35
 beq    $A2E6
 lda    $30
 ldy    $31
 bmi    $A2EC
 bne    $A33A
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
 bcs    $A313
 dec    $2F
 bcc    $A313
 ldy    $31
 bmi    $A2EC
 asl    $35
 rol    $34
 rol    $33
 rol    $32
 rol    $31
 sbc    #$00
 sta    $30
 bcs    $A336
 dec    $2F
 bcc    $A336
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
 beq    $A37A
 lda    $3B
 ora    #$80
 sta    $3E
 rts
 lda    #$71
 bne    $A387
 lda    #$76
 bne    $A387
 lda    #$6C
 sta    $4B
 lda    #$04
 sta    $4C
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
 jsr    $A7F5
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
 beq    $A3E1
 lda    $2E
 ora    #$80
 sta    $31
 rts
 jsr    $A3FE
 lda    $31
 sta    $2D
 lda    $32
 sta    $2C
 lda    $33
 sta    $2B
 lda    $34
 sta    $2A
 rts
 jsr    $A21E
 jmp    $A686
 lda    $30
 bpl    $A3F8
 jsr    $A453
 jsr    $A1DA
 bne    $A43C
 beq    $A468
 lda    $30
 cmp    #$A0
 bcs    $A466
 cmp    #$99
 bcs    $A43C
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
 lda    $33
 sta    $34
 lda    $32
 sta    $33
 lda    $31
 sta    $32
 lda    #$00
 sta    $31
 beq    $A40C
 lsr    $31
 ror    $32
 ror    $33
 ror    $34
 ror    $3E
 ror    $3F
 ror    $40
 ror    $41
 inc    $30
 bne    $A40C
 jmp    $A66C
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
 bne    $A450
 lda    $2E
 bpl    $A485
 sec
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
 rts
 lda    $30
 bmi    $A491
 lda    #$00
 sta    $4A
 jmp    $A1DA
 jsr    $A3FE
 lda    $34
 sta    $4A
 jsr    $A4E8
 lda    #$80
 sta    $30
 ldx    $31
 bpl    $A4B3
 eor    $2E
 sta    $2E
 bpl    $A4AE
 inc    $4A
 jmp    $A4B0
 dec    $4A
 jsr    $A46C
 jmp    $A303
 inc    $34
 bne    $A4C6
 inc    $33
 bne    $A4C6
 inc    $32
 bne    $A4C6
 inc    $31
 beq    $A450
 rts
 jsr    $A46C
 jsr    $A4B6
 jmp    $A46C
 jsr    $A4FD
 jmp    $AD7E
 jsr    $A34E
 jsr    $A38D
 lda    $3B
 sta    $2E
 lda    $3C
 sta    $2F
 lda    $3D
 sta    $30
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
 rts
 jsr    $AD7E
 jsr    $A34E
 beq    $A4FC
 jsr    $A50B
 jmp    $A65C
 jsr    $A1DA
 beq    $A4DC
 ldy    #$00
 sec
 lda    $30
 sbc    $3D
 beq    $A590
 bcc    $A552
 cmp    #$25
 bcs    $A4FC
 pha
 and    #$38
 beq    $A53D
 lsr    a
 lsr    a
 lsr    a
 tax
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
 bne    $A528
 pla
 and    #$07
 beq    $A590
 tax
 lsr    $3E
 ror    $3F
 ror    $40
 ror    $41
 ror    $42
 dex
 bne    $A543
 beq    $A590
 sec
 lda    $3D
 sbc    $30
 cmp    #$25
 bcs    $A4DC
 pha
 and    #$38
 beq    $A579
 lsr    a
 lsr    a
 lsr    a
 tax
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
 bne    $A564
 pla
 and    #$07
 beq    $A58C
 tax
 lsr    $31
 ror    $32
 ror    $33
 ror    $34
 ror    $35
 dex
 bne    $A57F
 lda    $3D
 sta    $30
 lda    $2E
 eor    $3B
 bpl    $A5DF
 lda    $31
 cmp    $3E
 bne    $A5B7
 lda    $32
 cmp    $3F
 bne    $A5B7
 lda    $33
 cmp    $40
 bne    $A5B7
 lda    $34
 cmp    $41
 bne    $A5B7
 lda    $35
 cmp    $42
 bne    $A5B7
 jmp    $A686
 bcs    $A5E3
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
 jmp    $A303
 clc
 jmp    $A208
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
 jmp    $A303
 rts
 jsr    $A1DA
 beq    $A605
 jsr    $A34E
 bne    $A613
 jmp    $A686
 clc
 lda    $30
 adc    $3D
 bcc    $A61D
 inc    $2F
 clc
 sbc    #$7F
 sta    $30
 bcs    $A625
 dec    $2F
 ldx    #$05
 ldy    #$00
 lda    $30,x
 sta    $42,x
 sty    $30,x
 dex
 bne    $A629
 lda    $2E
 eor    $3B
 sta    $2E
 ldy    #$20
 lsr    $3E
 ror    $3F
 ror    $40
 ror    $41
 ror    $42
 asl    $46
 rol    $45
 rol    $44
 rol    $43
 bcc    $A652
 clc
 jsr    $A178
 dey
 bne    $A63A
 rts
 jsr    $A606
 jsr    $A303
 lda    $35
 cmp    #$80
 bcc    $A67C
 beq    $A676
 lda    #$FF
 jsr    $A2A4
 jmp    $A67C
 brk
 .byte  $14
 .byte  'T'
 .byte  'o'
 .byte  'o'
 jsr    $6962
 .byte  'g'
 brk
 lda    $34
 ora    #$01
 sta    $34
 lda    #$00
 sta    $35
 lda    $2F
 beq    $A698
 bpl    $A66C
 lda    #$00
 sta    $2E
 sta    $2F
 sta    $30
 sta    $31
 sta    $32
 sta    $33
 sta    $34
 sta    $35
 rts
 jsr    $A686
 ldy    #$80
 sty    $31
 iny
 sty    $30
 tya
 rts
 jsr    $A385
 jsr    $A699
 bne    $A6E7
 jsr    $A1DA
 beq    $A6BB
 jsr    $A21E
 jsr    $A3B5
 bne    $A6F1
 rts
 jmp    $99A7
 jsr    $92FA
 jsr    $A9D3
 lda    $4A
 pha
 jsr    $A7E9
 jsr    $A38D
 inc    $4A
 jsr    $A99E
 jsr    $A7E9
 jsr    $A4D6
 pla
 sta    $4A
 jsr    $A99E
 jsr    $A7E9
 jsr    $A6E7
 lda    #$FF
 rts
 jsr    $A1DA
 beq    $A698
 jsr    $A34E
 beq    $A6BB
 lda    $2E
 eor    $3B
 sta    $2E
 sec
 lda    $30
 sbc    $3D
 bcs    $A701
 dec    $2F
 sec
 adc    #$80
 sta    $30
 bcc    $A70A
 inc    $2F
 clc
 ldx    #$20
 bcs    $A726
 lda    $31
 cmp    $3E
 bne    $A724
 lda    $32
 cmp    $3F
 bne    $A724
 lda    $33
 cmp    $40
 bne    $A724
 lda    $34
 cmp    $41
 bcc    $A73F
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
 rol    $46
 rol    $45
 rol    $44
 rol    $43
 asl    $34
 rol    $33
 rol    $32
 rol    $31
 dex
 bne    $A70C
 ldx    #$07
 bcs    $A76E
 lda    $31
 cmp    $3E
 bne    $A76C
 lda    $32
 cmp    $3F
 bne    $A76C
 lda    $33
 cmp    $40
 bne    $A76C
 lda    $34
 cmp    $41
 bcc    $A787
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
 rol    $35
 asl    $34
 rol    $33
 rol    $32
 rol    $31
 dex
 bne    $A754
 asl    $35
 lda    $46
 sta    $34
 lda    $45
 sta    $33
 lda    $44
 sta    $32
 lda    $43
 sta    $31
 jmp    $A659
 brk
 ora    $2D,x
 ror    $65,x
 jsr    $6F72
 .byte  'o'
 .byte  't'
 brk
 jsr    $92FA
 jsr    $A1DA
 beq    $A7E6
 bmi    $A7A9
 jsr    $A385
 lda    $30
 lsr    a
 adc    #$40
 sta    $30
 lda    #$05
 sta    $4A
 jsr    $A7ED
 jsr    $A38D
 lda    #$6C
 sta    $4B
 jsr    $A6AD
 lda    #$71
 sta    $4B
 jsr    $A500
 dec    $30
 dec    $4A
 bne    $A7CF
 lda    #$FF
 rts
 lda    #$7B
 bne    $A7F7
 lda    #$71
 bne    $A7F7
 lda    #$76
 bne    $A7F7
 lda    #$6C
 sta    $4B
 lda    #$04
 sta    $4C
 rts
 jsr    $92FA
 jsr    $A1DA
 beq    $A808
 bpl    $A814
 brk
 asl    $4C,x
 .byte  'o'
 .byte  'g'
 jsr    $6172
 ror    $6567
 brk
 jsr    $A453
 ldy    #$80
 sty    $3B
 sty    $3E
 iny
 sty    $3D
 ldx    $30
 beq    $A82A
 lda    $31
 cmp    #$B5
 bcc    $A82C
 inx
 dey
 txa
 pha
 sty    $30
 jsr    $A505
 lda    #$7B
 jsr    $A387
 lda    #$73
 ldy    #$A8
 jsr    $A897
 jsr    $A7E9
 jsr    $A656
 jsr    $A656
 jsr    $A500
 jsr    $A385
 pla
 sec
 sbc    #$81
 jsr    $A2ED
 lda    #$6E
 sta    $4B
 lda    #$A8
 sta    $4C
 jsr    $A656
 jsr    $A7F5
 jsr    $A500
 lda    #$FF
 rts
 .byte  $7F
 lsr    $D85B,x
 tax
 .byte  $80
 and    ($72),y
 .byte  $17
 sed
 asl    $7A
 .byte  $12
 sec
 lda    $0B
 dey
 adc    $9F0E,y
 .byte  $F3
 .byte  '|'
 rol    a
 ldy    $B53F
 stx    $34
 ora    ($A2,x)
 .byte  'z'
 .byte  $7F
 .byte  'c'
 stx    $EC37
 .byte  $82
 .byte  $3F
 .byte  $FF
 .byte  $FF
 cmp    ($7F,x)
 .byte  $FF
 .byte  $FF
 .byte  $FF
 .byte  $FF
 sta    $4D
 sty    $4E
 jsr    $A385
 ldy    #$00
 lda    ($4D),y
 sta    $48
 inc    $4D
 bne    $A8AA
 inc    $4E
 lda    $4D
 sta    $4B
 lda    $4E
 sta    $4C
 jsr    $A3B5
 jsr    $A7F5
 jsr    $A6AD
 clc
 lda    $4D
 adc    #$05
 sta    $4D
 sta    $4B
 lda    $4E
 adc    #$00
 sta    $4E
 sta    $4C
 jsr    $A500
 dec    $48
 bne    $A8B5
 rts
 jsr    $A8DA
 jmp    $A927
 jsr    $92FA
 jsr    $A1DA
 bpl    $A8EA
 lsr    $2E
 jsr    $A8EA
 jmp    $A916
 jsr    $A381
 jsr    $A9B1
 jsr    $A1DA
 beq    $A8FE
 jsr    $A7F1
 jsr    $A6AD
 jmp    $A90A
 jsr    $AA55
 jsr    $A3B5
 lda    #$FF
 rts
 jsr    $92FA
 jsr    $A1DA
 beq    $A904
 bpl    $A91B
 lsr    $2E
 jsr    $A91B
 lda    #$80
 sta    $2E
 rts
 lda    $30
 cmp    #$81
 bcc    $A936
 jsr    $A6A5
 jsr    $A936
 jsr    $AA48
 jsr    $A500
 jsr    $AA4C
 jsr    $A500
 jmp    $AD7E
 lda    $30
 cmp    #$73
 bcc    $A904
 jsr    $A381
 jsr    $A453
 lda    #$80
 sta    $3D
 sta    $3E
 sta    $3B
 jsr    $A505
 lda    #$5A
 ldy    #$A9
 jsr    $A897
 jsr    $AAD1
 lda    #$FF
 rts
 ora    #$85
 .byte  $A3
 eor    $67E8,y
 .byte  $80
 .byte  $1C
 sta    $3607,x
 .byte  $80
 .byte  'W'
 .byte  $BB
 sei
 .byte  $DF
 .byte  $80
 dex
 txs
 asl    $8483
 sty    $CABB
 ror    $9581
 stx    $06,y
 dec    $0A81,x
 .byte  $C7
 jmp    ($7F52)
 adc    $90AD,x
 lda    ($82,x)
 .byte  $FB
 .byte  'b'
 .byte  'W'
 .byte  $2F
 .byte  $80
 adc    $3863
 bit    $FA20
 .byte  $92
 jsr    $A9D3
 inc    $4A
 jmp    $A99E
 jsr    $92FA
 jsr    $A9D3
 lda    $4A
 and    #$02
 beq    $A9AA
 jsr    $A9AA
 jmp    $AD7E
 lsr    $4A
 bcc    $A9C3
 jsr    $A9C3
 jsr    $A385
 jsr    $A656
 jsr    $A38D
 jsr    $A699
 jsr    $A4D0
 jmp    $A7B7
 jsr    $A381
 jsr    $A656
 lda    #$72
 ldy    #$AA
 jsr    $A897
 jmp    $AAD1
 lda    $30
 cmp    #$98
 bcs    $AA38
 jsr    $A385
 jsr    $AA55
 jsr    $A34E
 lda    $2E
 sta    $3B
 dec    $3D
 jsr    $A505
 jsr    $A6E7
 jsr    $A3FE
 lda    $34
 sta    $4A
 ora    $33
 ora    $32
 ora    $31
 beq    $AA35
 lda    #$A0
 sta    $30
 ldy    #$00
 sty    $35
 lda    $31
 sta    $2E
 bpl    $AA0E
 jsr    $A46C
 jsr    $A303
 jsr    $A37D
 jsr    $AA48
 jsr    $A656
 jsr    $A7F5
 jsr    $A500
 jsr    $A38D
 jsr    $A7ED
 jsr    $A3B5
 jsr    $AA4C
 jsr    $A656
 jsr    $A7F5
 jmp    $A500
 jmp    $A3B2
 brk
 .byte  $17
 eor    ($63,x)
 .byte  'c'
 adc    $72,x
 adc    ($63,x)
 adc    $6C20,y
 .byte  'o'
 .byte  's'
 .byte  't'
 brk
 lda    #$59
 bne    $AA4E
 lda    #$5E
 sta    $4B
 lda    #$AA
 sta    $4C
 rts
 lda    #$63
 bne    $AA4E
 sta    ($C9,x)
 bpl    $AA5D
 brk
 .byte  'o'
 ora    $77,x
 .byte  'z'
 adc    ($81,x)
 eor    #$0F
 .byte  $DA
 ldx    #$7B
 asl    $35FA
 .byte  $12
 stx    $65
 rol    $D3E0
 ora    $84
 txa
 nop
 .byte  $0C
 .byte  $1B
 sty    $1A
 ldx    $2BBB,y
 sty    $37
 eor    $55
 .byte  $AB
 .byte  $82
 cmp    $55,x
 .byte  'W'
 .byte  '|'
 .byte  $83
 cpy    #$00
 brk
 ora    $81
 brk
 brk
 brk
 brk
 jsr    $92FA
 lda    $30
 cmp    #$87
 bcc    $AAB8
 bne    $AAA2
 ldy    $31
 cpy    #$B3
 bcc    $AAB8
 lda    $2E
 bpl    $AAAC
 jsr    $A686
 lda    #$FF
 rts
 brk
 clc
 eor    $78
 bvs    $AAD2
 .byte  'r'
 adc    ($6E,x)
 .byte  'g'
 adc    $00
 jsr    $A486
 jsr    $AADA
 jsr    $A381
 lda    #$E4
 sta    $4B
 lda    #$AA
 sta    $4C
 jsr    $A3B5
 lda    $4A
 jsr    $AB12
 jsr    $A7F1
 jsr    $A656
 lda    #$FF
 rts
 lda    #$E9
 ldy    #$AA
 jsr    $A897
 lda    #$FF
 rts
 .byte  $82
 and    $54F8
 cli
 .byte  $07
 .byte  $83
 cpx    #$20
 stx    $5B
 .byte  $82
 .byte  $80
 .byte  'S'
 .byte  $93
 clv
 .byte  $83
 jsr    $0600
 lda    ($82,x)
 brk
 brk
 and    ($63,x)
 .byte  $82
 cpy    #$00
 brk
 .byte  $02
 .byte  $82
 .byte  $80
 brk
 brk
 .byte  $0C
 sta    ($00,x)
 brk
 brk
 brk
 sta    ($00,x)
 brk
 brk
 brk
 tax
 bpl    $AB1E
 dex
 txa
 eor    #$FF
 pha
 jsr    $A6A5
 pla
 pha
 jsr    $A385
 jsr    $A699
 pla
 beq    $AB32
 sec
 sbc    #$01
 pha
 jsr    $A656
 jmp    $AB25
 rts
 jsr    $92E3
 ldx    $2A
 lda    #$80
 jsr    OSBYTE
 txa
 jmp    $AEEA
 jsr    $92DD
 jsr    $BD94
 jsr    $8AAE
 jsr    $AE56
 jsr    $92F0
 lda    $2A
 pha
 lda    $2B
 pha
 jsr    $BDEA
 pla
 sta    $2D
 pla
 sta    $2C
 ldx    #$2A
 lda    #$09
 jsr    OSWORD
 lda    $2E
 bmi    $AB9D
 jmp    $AED8
 lda    #$86
 jsr    OSBYTE
 txa
 jmp    $AED8
 lda    #$86
 jsr    OSBYTE
 tya
 jmp    $AED8
 jsr    $A1DA
 beq    $ABA2
 bpl    $ABA0
 bmi    $AB9D
 jsr    $ADEC
 beq    $ABE6
 bmi    $AB7F
 lda    $2D
 ora    $2C
 ora    $2B
 ora    $2A
 beq    $ABA5
 lda    $2D
 bpl    $ABA0
 jmp    $ACC4
 lda    #$01
 jmp    $AED8
 lda    #$40
 rts
 jsr    $A7FE
 ldy    #$69
 lda    #$A8
 bne    $ABB8
 jsr    $92FA
 ldy    #$68
 lda    #$AA
 sty    $4B
 sta    $4C
 jsr    $A656
 lda    #$FF
 rts
 jsr    $92FA
 ldy    #$6D
 lda    #$AA
 bne    $ABB8
 jsr    $A8FE
 inc    $30
 tay
 rts
 jsr    $92E3
 jsr    $8F1E
 sta    $2A
 stx    $2B
 sty    $2C
 php
 pla
 sta    $2D
 cld
 lda    #$40
 rts
 jmp    $8C0E
 jsr    $ADEC
 bne    $ABE6
 inc    $36
 ldy    $36
 lda    #$0D
 sta    $05FF,y
 jsr    $BDB2
 lda    $19
 pha
 lda    $1A
 pha
 lda    $1B
 pha
 ldy    $04
 ldx    $05
 iny
 sty    $19
 sty    $37
 bne    $AC0F
 inx
 stx    $1A
 stx    $38
 ldy    #$FF
 sty    $3B
 iny
 sty    $1B
 jsr    $8955
 jsr    $9B29
 jsr    $BDDC
 pla
 sta    $1B
 pla
 sta    $1A
 pla
 sta    $19
 lda    $27
 rts
 jsr    $ADEC
 bne    $AC9B
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
 jsr    $8A8C
 cmp    #$2D
 beq    $AC66
 cmp    #$2B
 bne    $AC5E
 jsr    $8A8C
 dec    $1B
 jsr    $A07B
 jmp    $AC73
 jsr    $8A8C
 dec    $1B
 jsr    $A07B
 bcc    $AC73
 jsr    $AD8F
 sta    $27
 jmp    $AC23
 jsr    $ADEC
 beq    $AC9B
 bpl    $AC9A
 lda    $2E
 php
 jsr    $A3FE
 plp
 bpl    $AC95
 lda    $3E
 ora    $3F
 ora    $40
 ora    $41
 beq    $AC95
 jsr    $A4C7
 jsr    $A3E7
 lda    #$40
 rts
 jmp    $8C0E
 jsr    $ADEC
 bne    $AC9B
 lda    $36
 beq    $ACC4
 lda    $0600
 jmp    $AED8
 jsr    $AFAD
 cpy    #$00
 bne    $ACC4
 txa
 jmp    $AEEA
 jsr    $BFB5
 tax
 lda    #$7F
 jsr    OSBYTE
 txa
 beq    $ACAA
 lda    #$FF
 sta    $2A
 sta    $2B
 sta    $2C
 sta    $2D
 lda    #$40
 rts
 jsr    $92E3
 ldx    #$03
 lda    $2A,x
 eor    #$FF
 sta    $2A,x
 dex
 bpl    $ACD6
 lda    #$40
 rts
 jsr    $9B29
 bne    $AC9B
 cpx    #$2C
 bne    $AD03
 inc    $1B
 jsr    $BDB2
 jsr    $9B29
 bne    $AC9B
 lda    #$01
 sta    $2A
 inc    $1B
 cpx    #$29
 beq    $AD12
 cpx    #$2C
 beq    $AD06
 jmp    $8AA2
 jsr    $BDB2
 jsr    $AE56
 jsr    $92F0
 jsr    $BDCB
 ldy    #$00
 ldx    $2A
 bne    $AD1A
 ldx    #$01
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
 bcc    $AD52
 sbc    $36
 bcc    $AD52
 adc    #$00
 sta    $2B
 jsr    $BDDC
 ldy    #$00
 ldx    $36
 beq    $AD4D
 lda    ($37),y
 cmp    $0600,y
 bne    $AD59
 iny
 dex
 bne    $AD42
 lda    $2A
 jmp    $AED8
 jsr    $BDDC
 lda    #$00
 beq    $AD4F
 inc    $2A
 dec    $2B
 beq    $AD55
 inc    $37
 bne    $AD3C
 inc    $38
 bne    $AD3C
 jmp    $8C0E
 jsr    $ADEC
 beq    $AD67
 bmi    $AD77
 bit    $2D
 bmi    $AD93
 bpl    $ADAA
 jsr    $A1DA
 bpl    $AD89
 bmi    $AD83
 jsr    $A1DA
 beq    $AD89
 lda    $2E
 eor    #$80
 sta    $2E
 lda    #$FF
 rts
 jsr    $AE02
 beq    $AD67
 bmi    $AD7E
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
 lda    #$40
 rts
 jsr    $8A8C
 cmp    #$22
 beq    $ADC9
 ldx    #$00
 lda    ($19),y
 sta    $0600,x
 iny
 inx
 cmp    #$0D
 beq    $ADC5
 cmp    #$2C
 bne    $ADB6
 dey
 jmp    $ADE1
 ldx    #$00
 iny
 lda    ($19),y
 cmp    #$0D
 beq    $ADE9
 iny
 sta    $0600,x
 inx
 cmp    #$22
 bne    $ADCC
 lda    ($19),y
 cmp    #$22
 beq    $ADCB
 dex
 stx    $36
 sty    $1B
 lda    #$00
 rts
 jmp    $8E98
 ldy    $1B
 inc    $1B
 lda    ($19),y
 cmp    #$20
 beq    $ADEC
 cmp    #$2D
 beq    $AD8C
 cmp    #$22
 beq    $ADC9
 cmp    #$2B
 bne    $AE05
 jsr    $8A8C
 cmp    #$8E
 bcc    $AE10
 cmp    #$C6
 bcs    $AE43
 jmp    $8BB1
 cmp    #$3F
 bcs    $AE20
 cmp    #$2E
 bcs    $AE2A
 cmp    #$26
 beq    $AE6D
 cmp    #$28
 beq    $AE56
 dec    $1B
 jsr    $95DD
 beq    $AE30
 jmp    $B32C
 jsr    $A07B
 bcc    $AE43
 rts
 lda    $28
 and    #$02
 bne    $AE43
 bcs    $AE43
 stx    $1B
 lda    $0440
 ldy    $0441
 jmp    $AEEA
 brk
 .byte  $1A
 lsr    $206F
 .byte  's'
 adc    $63,x
 pla
 jsr    $6176
 .byte  'r'
 adc    #$61
 .byte  'b'
 jmp    ($0065)
 jsr    $9B29
 inc    $1B
 cpx    #$29
 bne    $AE61
 tay
 rts
 brk
 .byte  $1B
 eor    $7369
 .byte  's'
 adc    #$6E
 .byte  'g'
 jsr    $0029
 ldx    #$00
 stx    $2A
 stx    $2B
 stx    $2C
 stx    $2D
 ldy    $1B
 lda    ($19),y
 cmp    #$30
 bcc    $AEA2
 cmp    #$3A
 bcc    $AE8D
 sbc    #$37
 cmp    #$0A
 bcc    $AEA2
 cmp    #$10
 bcs    $AEA2
 asl    a
 asl    a
 asl    a
 asl    a
 ldx    #$03
 asl    a
 rol    $2A
 rol    $2B
 rol    $2C
 rol    $2D
 dex
 bpl    $AE93
 iny
 bne    $AE79
 txa
 bpl    $AEAA
 sty    $1B
 lda    #$40
 rts
 brk
 .byte  $1C
 .byte  'B'
 adc    ($64,x)
 jsr    $4548
 cli
 brk
 ldx    #$2A
 ldy    #$00
 lda    #$01
 jsr    OSWORD
 lda    #$40
 rts
 lda    #$00
 ldy    $18
 jmp    $AEEA
 jmp    $AE43
 lda    #$00
 beq    $AED8
 jmp    $8C0E
 jsr    $ADEC
 bne    $AECE
 lda    $36
 ldy    #$00
 beq    $AEEA
 ldy    $1B
 lda    ($19),y
 cmp    #$50
 bne    $AEC7
 inc    $1B
 lda    $12
 ldy    $13
 sta    $2A
 sty    $2B
 lda    #$00
 sta    $2C
 sta    $2D
 lda    #$40
 rts
 lda    $1E
 jmp    $AED8
 lda    $00
 ldy    $01
 jmp    $AEEA
 lda    $06
 ldy    $07
 jmp    $AEEA
 inc    $1B
 jsr    $AE56
 jsr    $92F0
 lda    $2D
 bmi    $AF3F
 ora    $2C
 ora    $2B
 bne    $AF24
 lda    $2A
 beq    $AF6C
 cmp    #$01
 beq    $AF69
 jsr    $A2BE
 jsr    $BD51
 jsr    $AF69
 jsr    $BD7E
 jsr    $A606
 jsr    $A303
 jsr    $A3E4
 jsr    $9222
 lda    #$40
 rts
 ldx    #$0D
 jsr    $BE44
 lda    #$40
 sta    $11
 rts
 ldy    $1B
 lda    ($19),y
 cmp    #$28
 beq    $AF0A
 jsr    $AF87
 ldx    #$0D
 lda    $00,x
 sta    $2A
 lda    $01,x
 sta    $2B
 lda    $02,x
 sta    $2C
 lda    $03,x
 sta    $2D
 lda    #$40
 rts
 jsr    $AF87
 ldx    #$00
 stx    $2E
 stx    $2F
 stx    $35
 lda    #$80
 sta    $30
 lda    $0D,x
 sta    $31,x
 inx
 cpx    #$04
 bne    $AF78
 jsr    $A659
 lda    #$FF
 rts
 ldy    #$20
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
 bne    $AF89
 rts
 ldy    $09
 lda    $08
 jmp    $AEEA
 ldy    #$00
 lda    ($FD),y
 jmp    $AEEA
 jsr    $92E3
 lda    #$81
 ldx    $2A
 ldy    $2B
 jmp    OSBYTE
 jsr    OSRDCH
 jmp    $AED8
 jsr    OSRDCH
 sta    $0600
 lda    #$01
 sta    $36
 lda    #$00
 rts
 jsr    $9B29
 bne    $B033
 cpx    #$2C
 bne    $B036
 inc    $1B
 jsr    $BDB2
 jsr    $AE56
 jsr    $92F0
 jsr    $BDCB
 lda    $2A
 cmp    $36
 bcs    $AFEB
 sta    $36
 lda    #$00
 rts
 jsr    $9B29
 bne    $B033
 cpx    #$2C
 bne    $B036
 inc    $1B
 jsr    $BDB2
 jsr    $AE56
 jsr    $92F0
 jsr    $BDCB
 lda    $36
 sec
 sbc    $2A
 bcc    $B023
 beq    $B025
 tax
 lda    $2A
 sta    $36
 beq    $B025
 ldy    #$00
 lda    $0600,x
 sta    $0600,y
 inx
 iny
 dec    $2A
 bne    $B017
 lda    #$00
 rts
 jsr    $AFAD
 txa
 cpy    #$00
 beq    $AFC2
 lda    #$00
 sta    $36
 rts
 jmp    $8C0E
 jmp    $8AA2
 jsr    $9B29
 bne    $B033
 cpx    #$2C
 bne    $B036
 jsr    $BDB2
 inc    $1B
 jsr    $92DD
 lda    $2A
 pha
 lda    #$FF
 sta    $2A
 inc    $1B
 cpx    #$29
 beq    $B061
 cpx    #$2C
 bne    $B036
 jsr    $AE56
 jsr    $92F0
 jsr    $BDCB
 pla
 tay
 clc
 beq    $B06F
 sbc    $36
 bcs    $B02E
 dey
 tya
 sta    $2C
 tax
 ldy    #$00
 lda    $36
 sec
 sbc    $2C
 cmp    $2A
 bcs    $B07F
 sta    $2A
 lda    $2A
 beq    $B02E
 lda    $0600,x
 sta    $0600,y
 iny
 inx
 cpy    $2A
 bne    $B083
 sty    $36
 lda    #$00
 rts
 jsr    $8A8C
 ldy    #$FF
 cmp    #$7E
 beq    $B0A1
 ldy    #$00
 dec    $1B
 tya
 pha
 jsr    $ADEC
 beq    $B0BF
 tay
 pla
 sta    $15
 lda    $0403
 bne    $B0B9
 sta    $37
 jsr    $9EF9
 lda    #$00
 rts
 jsr    $9EDF
 lda    #$00
 rts
 jmp    $8C0E
 jsr    $92DD
 jsr    $BD94
 jsr    $8AAE
 jsr    $AE56
 bne    $B0BF
 jsr    $BDEA
 ldy    $36
 beq    $B0F5
 lda    $2A
 beq    $B0F8
 dec    $2A
 beq    $B0F5
 ldx    #$00
 lda    $0600,x
 sta    $0600,y
 inx
 iny
 beq    $B0FB
 cpx    $36
 bcc    $B0E1
 dec    $2A
 bne    $B0DF
 sty    $36
 lda    #$00
 rts
 sta    $36
 rts
 jmp    $9C03
 pla
 sta    $0C
 pla
 sta    $0B
 brk
 ora    $6F4E,x
 jsr    $7573
 .byte  'c'
 pla
 jsr    $2FA4
 .byte  $F2
 brk
 lda    $18
 sta    $0C
 lda    #$00
 sta    $0B
 ldy    #$01
 lda    ($0B),y
 bmi    $B0FE
 ldy    #$03
 iny
 lda    ($0B),y
 cmp    #$20
 beq    $B122
 cmp    #$DD
 beq    $B13C
 ldy    #$03
 lda    ($0B),y
 clc
 adc    $0B
 sta    $0B
 bcc    $B11A
 inc    $0C
 bcs    $B11A
 iny
 sty    $0A
 jsr    $8A97
 tya
 tax
 clc
 adc    $0B
 ldy    $0C
 bcc    $B14D
 iny
 clc
 sbc    #$00
 sta    $3C
 tya
 sbc    #$00
 sta    $3D
 ldy    #$00
 iny
 inx
 lda    ($3C),y
 cmp    ($37),y
 bne    $B12D
 cpy    $39
 bne    $B158
 iny
 lda    ($3C),y
 jsr    $8926
 bcs    $B12D
 txa
 tay
 jsr    $986D
 jsr    $94ED
 ldx    #$01
 jsr    $9531
 ldy    #$00
 lda    $0B
 sta    ($02),y
 iny
 lda    $0C
 sta    ($02),y
 jsr    $9539
 jmp    $B1F4
 brk
 asl    $6142,x
 .byte  'd'
 jsr    $6163
 jmp    ($006C)
 lda    #$A4
 sta    $27
 tsx
 txa
 clc
 adc    $04
 jsr    $BE2E
 ldy    #$00
 txa
 sta    ($04),y
 inx
 iny
 lda    $0100,x
 sta    ($04),y
 cpx    #$FF
 bne    $B1A6
 txs
 lda    $27
 pha
 lda    $0A
 pha
 lda    $0B
 pha
 lda    $0C
 pha
 lda    $1B
 tax
 clc
 adc    $19
 ldy    $1A
 bcc    $B1CA
 iny
 clc
 sbc    #$01
 sta    $37
 tya
 sbc    #$00
 sta    $38
 ldy    #$02
 jsr    $955B
 cpy    #$02
 beq    $B18A
 stx    $1B
 dey
 sty    $39
 jsr    $945B
 bne    $B1E9
 jmp    $B112
 ldy    #$00
 lda    ($2A),y
 sta    $0B
 iny
 lda    ($2A),y
 sta    $0C
 lda    #$00
 pha
 sta    $0A
 jsr    $8A97
 cmp    #$28
 beq    $B24D
 dec    $0A
 lda    $1B
 pha
 lda    $19
 pha
 lda    $1A
 pha
 jsr    $8BA3
 pla
 sta    $1A
 pla
 sta    $19
 pla
 sta    $1B
 pla
 beq    $B226
 sta    $3F
 jsr    $BE0B
 jsr    $8CC1
 dec    $3F
 bne    $B21C
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
 iny
 inx
 lda    ($04),y
 sta    $0100,x
 cpx    #$FF
 bne    $B236
 tya
 adc    $04
 sta    $04
 bcc    $B24A
 inc    $05
 lda    $27
 rts
 lda    $1B
 pha
 lda    $19
 pha
 lda    $1A
 pha
 jsr    $9582
 beq    $B2B5
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
 jsr    $B30D
 jsr    $8A97
 cmp    #$2C
 beq    $B24D
 cmp    #$29
 bne    $B2B5
 lda    #$00
 pha
 jsr    $8A8C
 cmp    #$28
 bne    $B2B5
 jsr    $9B29
 jsr    $BD90
 lda    $27
 sta    $2D
 jsr    $BD94
 pla
 tax
 inx
 txa
 pha
 jsr    $8A8C
 cmp    #$2C
 beq    $B28E
 cmp    #$29
 bne    $B2B5
 pla
 pla
 sta    $4D
 sta    $4E
 cpx    $4D
 beq    $B2CA
 ldx    #$FB
 txs
 pla
 sta    $0C
 pla
 sta    $0B
 brk
 .byte  $1F
 eor    ($72,x)
 .byte  'g'
 adc    $6D,x
 adc    $6E
 .byte  't'
 .byte  's'
 brk
 jsr    $BDEA
 pla
 sta    $2A
 pla
 sta    $2B
 pla
 sta    $2C
 bmi    $B2F9
 lda    $2D
 beq    $B2B5
 sta    $27
 ldx    #$37
 jsr    $BE44
 lda    $27
 bpl    $B2F0
 jsr    $BD7E
 jsr    $A3B5
 jmp    $B2F3
 jsr    $BDEA
 jsr    $B4B7
 jmp    $B303
 lda    $2D
 bne    $B2B5
 jsr    $BDCB
 jsr    $8C21
 dec    $4D
 bne    $B2CA
 lda    $4E
 pha
 jmp    $B202
 ldy    $2C
 cpy    #$04
 bne    $B318
 ldx    #$37
 jsr    $BE44
 jsr    $B32C
 php
 jsr    $BD90
 plp
 beq    $B329
 bmi    $B329
 ldx    #$37
 jsr    $AF56
 jmp    $BD94
 ldy    $2C
 bmi    $B384
 beq    $B34F
 cpy    #$05
 beq    $B354
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
 lda    ($2A),y
 jmp    $AEEA
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
 beq    $B37F
 lda    $2E
 ora    #$80
 sta    $31
 lda    #$FF
 rts
 cpy    #$80
 beq    $B3A7
 ldy    #$03
 lda    ($2A),y
 sta    $36
 beq    $B3A6
 ldy    #$01
 lda    ($2A),y
 sta    $38
 dey
 lda    ($2A),y
 sta    $37
 ldy    $36
 dey
 lda    ($37),y
 sta    $0600,y
 tya
 bne    $B39D
 rts
 lda    $2B
 beq    $B3C0
 ldy    #$00
 lda    ($2A),y
 sta    $0600,y
 eor    #$0D
 beq    $B3BA
 iny
 bne    $B3AD
 tya
 sty    $36
 rts
 jsr    $92E3
 lda    $2A
 jmp    $AFC2
 ldy    #$00
 sty    $08
 sty    $09
 ldx    $18
 stx    $38
 sty    $37
 ldx    $0C
 cpx    #$07
 beq    $B401
 ldx    $0B
 jsr    $8942
 cmp    #$0D
 bne    $B3F9
 cpx    $37
 lda    $0C
 sbc    $38
 bcc    $B401
 jsr    $8942
 ora    #$00
 bmi    $B401
 sta    $09
 jsr    $8942
 sta    $08
 jsr    $8942
 cpx    $37
 lda    $0C
 sbc    $38
 bcs    $B3D9
 rts
 jsr    $B3C5
 sty    $20
 lda    ($FD),y
 bne    $B413
 lda    #$33
 sta    $16
 lda    #$B4
 sta    $17
 lda    $16
 sta    $0B
 lda    $17
 sta    $0C
 jsr    $BD3A
 tax
 stx    $0A
 lda    #$DA
 jsr    OSBYTE
 lda    #$7E
 jsr    OSBYTE
 ldx    #$FF
 stx    $28
 txs
 jmp    $8BA3
 inc    $3A,x
 .byte  $E7
 .byte  $9E
 sbc    ($22),y
 jsr    $7461
 jsr    $696C
 ror    $2065
 .byte  $22
 .byte  $3B
 .byte  $9E
 .byte  $3A
 cpx    #$8B
 sbc    ($3A),y
 cpx    #$0D
 jsr    $8821
 ldx    #$03
 lda    $2A
 pha
 lda    $2B
 pha
 txa
 pha
 jsr    $92DA
 pla
 tax
 dex
 bne    $B451
 jsr    $9852
 lda    $2A
 sta    $3D
 lda    $2B
 sta    $3E
 ldy    #$07
 ldx    #$05
 bne    $B48F
 jsr    $8821
 ldx    #$0D
 lda    $2A
 pha
 txa
 pha
 jsr    $92DA
 pla
 tax
 dex
 bne    $B477
 jsr    $9852
 lda    $2A
 sta    $44
 ldx    #$0C
 ldy    #$08
 pla
 sta    $37,x
 dex
 bpl    $B48F
 tya
 ldx    #$37
 ldy    #$00
 jsr    OSWORD
 jmp    $8B9B
 jsr    $8821
 jsr    $9852
 ldy    $2A
 dey
 sty    $23
 jmp    $8B9B
 jmp    $8C0E
 jsr    $9B29
 jsr    $BE0B
 lda    $39
 cmp    #$05
 beq    $B4E0
 lda    $27
 beq    $B4AE
 bpl    $B4C6
 jsr    $A3E4
 ldy    #$00
 lda    $2A
 sta    ($37),y
 lda    $39
 beq    $B4DF
 lda    $2B
 iny
 sta    ($37),y
 lda    $2C
 iny
 sta    ($37),y
 lda    $2D
 iny
 sta    ($37),y
 rts
 lda    $27
 beq    $B4AE
 bmi    $B4E9
 jsr    $A2BE
 ldy    #$00
 lda    $30
 sta    ($37),y
 iny
 lda    $2E
 and    #$80
 sta    $2E
 lda    $31
 and    #$7F
 ora    $2E
 sta    ($37),y
 iny
 lda    $32
 sta    ($37),y
 iny
 lda    $33
 sta    ($37),y
 iny
 lda    $34
 sta    ($37),y
 rts
 sta    $37
 cmp    #$80
 bcc    $B558
 lda    #$71
 sta    $38
 lda    #$80
 sta    $39
 sty    $3A
 ldy    #$00
 iny
 lda    ($38),y
 bpl    $B520
 cmp    $37
 beq    $B536
 iny
 tya
 sec
 adc    $38
 sta    $38
 bcc    $B51E
 inc    $39
 bcs    $B51E
 ldy    #$00
 lda    ($38),y
 bmi    $B542
 jsr    $B558
 iny
 bne    $B538
 ldy    $3A
 rts
 pha
 lsr    a
 lsr    a
 lsr    a
 lsr    a
 jsr    $B550
 pla
 and    #$0F
 cmp    #$0A
 bcc    $B556
 adc    #$06
 adc    #$30
 cmp    #$0D
 bne    $B567
 jsr    OSWRCH
 jmp    $BC28
 jsr    $B545
 lda    #$20
 pha
 lda    $23
 cmp    $1E
 bcs    $B571
 jsr    $BC25
 pla
 inc    $1E
 jmp    (WRCHV)
 and    $1F
 beq    $B589
 txa
 beq    $B589
 bmi    $B565
 jsr    $B565
 jsr    $B558
 dex
 bne    $B580
 rts
 inc    $0A
 jsr    $9B1D
 jsr    $984C
 jsr    $92EE
 lda    $2A
 sta    $1F
 jmp    $8AF6
 iny
 lda    ($0B),y
 cmp    #$4F
 beq    $B58A
 lda    #$00
 sta    $3B
 sta    $3C
 jsr    $AED8
 jsr    $97DF
 php
 jsr    $BD94
 lda    #$FF
 sta    $2A
 lda    #$7F
 sta    $2B
 plp
 bcc    $B5CF
 jsr    $8A97
 cmp    #$2C
 beq    $B5D8
 jsr    $BDEA
 jsr    $BD94
 dec    $0A
 bpl    $B5DB
 jsr    $8A97
 cmp    #$2C
 beq    $B5D8
 dec    $0A
 jsr    $97DF
 lda    $2A
 sta    $31
 lda    $2B
 sta    $32
 jsr    $9857
 jsr    $BE6F
 jsr    $BDEA
 jsr    $9970
 lda    $3D
 sta    $0B
 lda    $3E
 sta    $0C
 bcc    $B60F
 dey
 bcs    $B602
 jsr    $BC25
 jsr    $986D
 lda    ($0B),y
 sta    $2B
 iny
 lda    ($0B),y
 sta    $2A
 iny
 iny
 sty    $0A
 lda    $2A
 clc
 sbc    $31
 lda    $2B
 sbc    $32
 bcc    $B61D
 jmp    $8AF6
 jsr    $9923
 ldx    #$FF
 stx    $4D
 lda    #$01
 jsr    $B577
 ldx    $3B
 lda    #$02
 jsr    $B577
 ldx    $3C
 lda    #$04
 jsr    $B577
 ldy    $0A
 lda    ($0B),y
 cmp    #$0D
 beq    $B5FC
 cmp    #$22
 bne    $B651
 lda    #$FF
 eor    $4D
 sta    $4D
 lda    #$22
 jsr    $B558
 iny
 bne    $B639
 bit    $4D
 bpl    $B64B
 cmp    #$8D
 bne    $B668
 jsr    $97EB
 sty    $0A
 lda    #$00
 sta    $14
 jsr    $991F
 jmp    $B637
 cmp    #$E3
 bne    $B66E
 inc    $3B
 cmp    #$ED
 bne    $B678
 ldx    $3B
 beq    $B678
 dec    $3B
 cmp    #$F5
 bne    $B67E
 inc    $3C
 cmp    #$FD
 bne    $B688
 ldx    $3C
 beq    $B688
 dec    $3C
 jsr    $B50E
 iny
 bne    $B639
 brk
 jsr    $6F4E
 jsr    $00E3
 jsr    $95C9
 bne    $B6A3
 ldx    $26
 beq    $B68E
 bcs    $B6D7
 jmp    $982A
 bcs    $B6A0
 ldx    $26
 beq    $B68E
 lda    $2A
 cmp    $04F1,x
 bne    $B6BE
 lda    $2B
 cmp    $04F2,x
 bne    $B6BE
 lda    $2C
 cmp    $04F3,x
 beq    $B6D7
 txa
 sec
 sbc    #$0F
 tax
 stx    $26
 bne    $B6A9
 brk
 and    ($43,x)
 adc    ($6E,x)
 .byte  $27
 .byte  't'
 jsr    $614D
 .byte  't'
 .byte  'c'
 pla
 jsr    $00E3
 lda    $04F1,x
 sta    $2A
 lda    $04F2,x
 sta    $2B
 ldy    $04F3,x
 cpy    #$05
 beq    $B766
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
 beq    $B741
 tya
 eor    $04F7,x
 eor    $04FC,x
 bpl    $B73F
 bcs    $B741
 bcc    $B751
 bcs    $B751
 ldy    $04FE,x
 lda    $04FF,x
 sty    $0B
 sta    $0C
 jsr    $9877
 jmp    $8BA3
 lda    $26
 sec
 sbc    #$0F
 sta    $26
 ldy    $1B
 sty    $0A
 jsr    $8A97
 cmp    #$2C
 bne    $B7A1
 jmp    $B695
 jsr    $B354
 lda    $26
 clc
 adc    #$F4
 sta    $4B
 lda    #$05
 sta    $4C
 jsr    $A500
 lda    $2A
 sta    $37
 lda    $2B
 sta    $38
 jsr    $B4E9
 lda    $26
 sta    $27
 clc
 adc    #$F9
 sta    $4B
 lda    #$05
 sta    $4C
 jsr    $9A5F
 beq    $B741
 lda    $04F5,x
 bmi    $B79D
 bcs    $B741
 bcc    $B751
 bcc    $B741
 bcs    $B751
 jmp    $8B96
 brk
 .byte  $22
 .byte  $E3
 jsr    $6176
 .byte  'r'
 adc    #$61
 .byte  'b'
 jmp    ($0065)
 .byte  $23
 .byte  'T'
 .byte  'o'
 .byte  'o'
 jsr    $616D
 ror    $2079
 .byte  $E3
 .byte  's'
 brk
 bit    $4E
 .byte  'o'
 jsr    $00B8
 jsr    $9582
 beq    $B7A4
 bcs    $B7A4
 jsr    $BD94
 jsr    $9841
 jsr    $B4B1
 ldy    $26
 cpy    #$96
 bcs    $B7B0
 lda    $37
 sta    $0500,y
 lda    $38
 sta    $0501,y
 lda    $39
 sta    $0502,y
 tax
 jsr    $8A8C
 cmp    #$B8
 bne    $B7BD
 cpx    #$05
 beq    $B84F
 jsr    $92DD
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
 jsr    $AED8
 jsr    $8A8C
 cmp    #$88
 bne    $B81F
 jsr    $92DD
 ldy    $1B
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
 jsr    $9880
 ldy    $26
 lda    $0B
 sta    $050D,y
 lda    $0C
 sta    $050E,y
 clc
 tya
 adc    #$0F
 sta    $26
 jmp    $8BA3
 jsr    $9B29
 jsr    $92FD
 lda    $26
 clc
 adc    #$08
 sta    $4B
 lda    #$05
 sta    $4C
 jsr    $A38D
 jsr    $A699
 jsr    $8A8C
 cmp    #$88
 bne    $B875
 jsr    $9B29
 jsr    $92FD
 ldy    $1B
 sty    $0A
 lda    $26
 clc
 adc    #$03
 sta    $4B
 lda    #$05
 sta    $4C
 jsr    $A38D
 jmp    $B837
 jsr    $B99A
 jsr    $9857
 ldy    $25
 cpy    #$1A
 bcs    $B8A2
 lda    $0B
 sta    $05CC,y
 lda    $0C
 sta    $05E6,y
 inc    $25
 bcc    $B8D2
 brk
 and    $54
 .byte  'o'
 .byte  'o'
 jsr    $616D
 ror    $2079
 cpx    $73
 brk
 rol    $4E
 .byte  'o'
 jsr    $00E4
 jsr    $9857
 ldx    $25
 beq    $B8AF
 dec    $25
 ldy    $05CB,x
 lda    $05E5,x
 sty    $0B
 sta    $0C
 jmp    $8B9B
 jsr    $B99A
 jsr    $9857
 lda    $20
 beq    $B8D9
 jsr    $9905
 ldy    $3D
 lda    $3E
 sty    $0B
 sta    $0C
 jmp    $8BA3
 jsr    $9857
 lda    #$33
 sta    $16
 lda    #$B4
 sta    $17
 jmp    $8B9B
 jsr    $8A97
 cmp    #$87
 beq    $B8E4
 ldy    $0A
 dey
 jsr    $986D
 lda    $0B
 sta    $16
 lda    $0C
 sta    $17
 jmp    $8B7D
 brk
 .byte  $27
 inc    $7320
 adc    $746E,y
 adc    ($78,x)
 brk
 jsr    $8A97
 cmp    #$85
 beq    $B8F2
 dec    $0A
 jsr    $9B1D
 jsr    $92F0
 ldy    $1B
 iny
 sty    $0A
 cpx    #$E5
 beq    $B931
 cpx    #$E4
 bne    $B90A
 txa
 pha
 lda    $2B
 ora    $2C
 ora    $2D
 bne    $B97D
 ldx    $2A
 beq    $B97D
 dex
 beq    $B95C
 ldy    $0A
 lda    ($0B),y
 iny
 cmp    #$0D
 beq    $B97D
 cmp    #$3A
 beq    $B97D
 cmp    #$8B
 beq    $B97D
 cmp    #$2C
 bne    $B944
 dex
 bne    $B944
 sty    $0A
 jsr    $B99A
 pla
 cmp    #$E4
 beq    $B96A
 jsr    $9877
 jmp    $B8D2
 ldy    $0A
 lda    ($0B),y
 iny
 cmp    #$0D
 beq    $B977
 cmp    #$3A
 bne    $B96C
 dey
 sty    $0A
 jmp    $B88B
 ldy    $0A
 pla
 lda    ($0B),y
 iny
 cmp    #$8B
 beq    $B995
 cmp    #$0D
 bne    $B980
 brk
 plp
 inc    $7220
 adc    ($6E,x)
 .byte  'g'
 adc    $00
 sty    $0A
 jmp    $98E3
 jsr    $97DF
 bcs    $B9AF
 jsr    $9B1D
 jsr    $92F0
 lda    $1B
 sta    $0A
 lda    $2B
 and    #$7F
 sta    $2B
 jsr    $9970
 bcs    $B9B5
 rts
 brk
 and    #$4E
 .byte  'o'
 jsr    $7573
 .byte  'c'
 pla
 jsr    $696C
 ror    a:$0065
 jmp    $8C0E
 jmp    $982A
 sty    $0A
 jmp    $8B98
 dec    $0A
 jsr    $BFA9
 lda    $1B
 sta    $0A
 sty    $4D
 jsr    $8A97
 cmp    #$2C
 bne    $B9CA
 lda    $4D
 pha
 jsr    $9582
 beq    $B9C7
 lda    $1B
 sta    $0A
 pla
 sta    $4D
 php
 jsr    $BD94
 ldy    $4D
 jsr    OSBGET
 sta    $27
 plp
 bcc    $BA19
 lda    $27
 bne    $B9C4
 jsr    OSBGET
 sta    $36
 tax
 beq    $BA13
 jsr    OSBGET
 sta    $05FF,x
 dex
 bne    $BA0A
 jsr    $8C1E
 jmp    $B9DA
 lda    $27
 beq    $B9C4
 bmi    $BA2B
 ldx    #$03
 jsr    OSBGET
 sta    $2A,x
 dex
 bpl    $BA21
 bmi    $BA39
 ldx    #$04
 jsr    OSBGET
 sta    $046C,x
 dex
 bpl    $BA2D
 jsr    $A3B2
 jsr    $B4B4
 jmp    $B9DA
 pla
 pla
 jmp    $8B98
 jsr    $8A97
 cmp    #$23
 beq    $B9CF
 cmp    #$86
 beq    $BA52
 dec    $0A
 clc
 ror    $4D
 lsr    $4D
 lda    #$FF
 sta    $4E
 jsr    $8E8A
 bcs    $BA69
 jsr    $8E8A
 bcc    $BA5F
 ldx    #$FF
 stx    $4E
 clc
 php
 asl    $4D
 plp
 ror    $4D
 cmp    #$2C
 beq    $BA5A
 cmp    #$3B
 beq    $BA5A
 dec    $0A
 lda    $4D
 pha
 lda    $4E
 pha
 jsr    $9582
 beq    $BA3F
 pla
 sta    $4E
 pla
 sta    $4D
 lda    $1B
 sta    $0A
 php
 bit    $4D
 bvs    $BA99
 lda    $4E
 cmp    #$FF
 bne    $BAB0
 bit    $4D
 bpl    $BAA2
 lda    #$3F
 jsr    $B558
 jsr    $BBFC
 sty    $36
 asl    $4D
 clc
 ror    $4D
 bit    $4D
 bvs    $BACD
 sta    $1B
 lda    #$00
 sta    $19
 lda    #$06
 sta    $1A
 jsr    $ADAD
 jsr    $8A8C
 cmp    #$2C
 beq    $BACA
 cmp    #$0D
 bne    $BABD
 ldy    #$FE
 iny
 sty    $4E
 plp
 bcs    $BADC
 jsr    $BD94
 jsr    $AC34
 jsr    $B4B4
 jmp    $BA5A
 lda    #$00
 sta    $27
 jsr    $8C21
 jmp    $BA5A
 ldy    #$00
 sty    $3D
 ldy    $18
 sty    $3E
 jsr    $8A97
 dec    $0A
 cmp    #$3A
 beq    $BB07
 cmp    #$0D
 beq    $BB07
 cmp    #$8B
 beq    $BB07
 jsr    $B99A
 ldy    #$01
 jsr    $BE55
 jsr    $9857
 lda    $3D
 sta    $1C
 lda    $3E
 sta    $1D
 jmp    $8B9B
 jsr    $8A97
 cmp    #$2C
 beq    $BB1F
 jmp    $8B96
 jsr    $9582
 beq    $BB15
 bcs    $BB32
 jsr    $BB50
 jsr    $BD94
 jsr    $B4B1
 jmp    $BB40
 jsr    $BB50
 jsr    $BD94
 jsr    $ADAD
 sta    $27
 jsr    $8C1E
 clc
 lda    $1B
 adc    $19
 sta    $1C
 lda    $1A
 adc    #$00
 sta    $1D
 jmp    $BB15
 lda    $1B
 sta    $0A
 lda    $1C
 sta    $19
 lda    $1D
 sta    $1A
 ldy    #$00
 sty    $1B
 jsr    $8A8C
 cmp    #$2C
 beq    $BBB0
 cmp    #$DC
 beq    $BBB0
 cmp    #$0D
 beq    $BB7A
 jsr    $8A8C
 cmp    #$2C
 beq    $BBB0
 cmp    #$0D
 bne    $BB6F
 ldy    $1B
 lda    ($19),y
 bmi    $BB9C
 iny
 iny
 lda    ($19),y
 tax
 iny
 lda    ($19),y
 cmp    #$20
 beq    $BB85
 cmp    #$DC
 beq    $BBAD
 txa
 clc
 adc    $19
 sta    $19
 bcc    $BB7A
 inc    $1A
 bcs    $BB7A
 brk
 rol    a
 .byte  'O'
 adc    $74,x
 jsr    $666F
 jsr    $00DC
 .byte  $2B
 lsr    $206F
 sbc    $00,x
 iny
 sty    $1B
 rts
 jsr    $9B1D
 jsr    $984C
 jsr    $92EE
 ldx    $24
 beq    $BBA6
 lda    $2A
 ora    $2B
 ora    $2C
 ora    $2D
 beq    $BBCD
 dec    $24
 jmp    $8B9B
 ldy    $05A3,x
 lda    $05B7,x
 jmp    $B8DD
 brk
 bit    $6F54
 .byte  'o'
 jsr    $616D
 ror    $2079
 sbc    $73,x
 brk
 ldx    $24
 cpx    #$14
 bcs    $BBD6
 jsr    $986D
 lda    $0B
 sta    $05A4,x
 lda    $0C
 sta    $05B8,x
 inc    $24
 jmp    $8BA3
 ldy    #$00
 lda    #$06
 bne    $BC09
 jsr    $B558
 ldy    #$00
 lda    #$07
 sty    $37
 sta    $38
 lda    #$EE
 sta    $39
 lda    #$20
 sta    $3A
 ldy    #$FF
 sty    $3B
 iny
 ldx    #$37
 tya
 jsr    OSWORD
 bcc    $BC28
 jmp    $9838
 jsr    OSNEWL
 lda    #$00
 sta    $1E
 rts
 jsr    $9970
 bcs    $BC80
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
 bcc    $BC53
 inc    $38
 ldy    #$00
 lda    ($37),y
 sta    ($12),y
 cmp    #$0D
 beq    $BC66
 iny
 bne    $BC55
 inc    $38
 inc    $13
 bne    $BC55
 iny
 bne    $BC6D
 inc    $38
 inc    $13
 lda    ($37),y
 sta    ($12),y
 bmi    $BC7C
 jsr    $BC81
 jsr    $BC81
 jmp    $BC5D
 jsr    $BE92
 clc
 rts
 iny
 bne    $BC88
 inc    $13
 inc    $38
 lda    ($37),y
 sta    ($12),y
 rts
 sty    $3B
 jsr    $BC2D
 ldy    #$07
 sty    $3C
 ldy    #$00
 lda    #$0D
 cmp    ($3B),y
 beq    $BD10
 iny
 cmp    ($3B),y
 bne    $BC9E
 iny
 iny
 iny
 sty    $3F
 inc    $3F
 lda    $12
 sta    $39
 lda    $13
 sta    $3A
 jsr    $BE92
 sta    $37
 lda    $13
 sta    $38
 dey
 lda    $06
 cmp    $12
 lda    $07
 sbc    $13
 bcs    $BCD6
 jsr    $BE6F
 jsr    $BD20
 brk
 brk
 stx    $20
 .byte  's'
 bvs    $BD34
 .byte  'c'
 adc    $00
 lda    ($39),y
 sta    ($37),y
 tya
 bne    $BCE1
 dec    $3A
 dec    $38
 dey
 tya
 adc    $39
 ldx    $3A
 bcc    $BCEA
 inx
 cmp    $3D
 txa
 sbc    $3E
 bcs    $BCD6
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
 jsr    $BE56
 ldy    #$FF
 iny
 lda    ($3B),y
 sta    ($3D),y
 cmp    #$0D
 bne    $BD07
 rts
 jsr    $9857
 jsr    $BD20
 lda    $18
 sta    $0C
 stx    $0B
 jmp    $8B0B
 lda    $12
 sta    $00
 sta    $02
 lda    $13
 sta    $01
 sta    $03
 jsr    $BD3A
 ldx    #$80
 lda    #$00
 sta    $047F,x
 dex
 bne    $BD33
 rts
 lda    $18
 sta    $1D
 lda    $06
 sta    $04
 lda    $07
 sta    $05
 lda    #$00
 sta    $24
 sta    $26
 sta    $25
 sta    $1C
 rts
 lda    $04
 sec
 sbc    #$05
 jsr    $BE2E
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
 beq    $BDB2
 bmi    $BD51
 lda    $04
 sec
 sbc    #$04
 jsr    $BE2E
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
 clc
 lda    $04
 sbc    $36
 jsr    $BE2E
 ldy    $36
 beq    $BDC6
 lda    $05FF,y
 sta    ($04),y
 dey
 bne    $BDBE
 lda    $36
 sta    ($04),y
 rts
 ldy    #$00
 lda    ($04),y
 sta    $36
 beq    $BDDC
 tay
 lda    ($04),y
 sta    $05FF,y
 dey
 bne    $BDD4
 ldy    #$00
 lda    ($04),y
 sec
 adc    $04
 sta    $04
 bcc    $BE0A
 inc    $05
 rts
 ldy    #$03
 lda    ($04),y
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
 clc
 lda    $04
 adc    #$04
 sta    $04
 bcc    $BE0A
 inc    $05
 rts
 ldx    #$37
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
 lda    $04
 adc    #$04
 sta    $04
 bcc    $BE0A
 inc    $05
 rts
 sta    $04
 bcs    $BE34
 dec    $05
 ldy    $05
 cpy    $03
 bcc    $BE41
 bne    $BE40
 cmp    $02
 bcc    $BE41
 rts
 jmp    $8CB7
 lda    $2A
 sta    $00,x
 lda    $2B
 sta    $01,x
 lda    $2C
 sta    $02,x
 lda    $2D
 sta    $03,x
 rts
 clc
 tya
 adc    $3D
 sta    $3D
 bcc    $BE5F
 inc    $3E
 ldy    #$01
 rts
 jsr    $BEDD
 tay
 lda    #$FF
 sty    $3D
 ldx    #$37
 jsr    OSFILE
 lda    $18
 sta    $13
 ldy    #$00
 sty    $12
 iny
 dey
 lda    ($12),y
 cmp    #$0D
 bne    $BE9E
 iny
 lda    ($12),y
 bmi    $BE90
 ldy    #$03
 lda    ($12),y
 beq    $BE9E
 clc
 jsr    $BE93
 bne    $BE78
 iny
 clc
 tya
 adc    $12
 sta    $12
 bcc    $BE9B
 inc    $13
 ldy    #$01
 rts
 jsr    $BFCF
 ora    $6142
 .byte  'd'
 jsr    $7270
 .byte  'o'
 .byte  'g'
 .byte  'r'
 adc    ($6D,x)
 ora    $4CEA
 inc    $8A,x
 lda    #$00
 sta    $37
 lda    #$06
 sta    $38
 ldy    $36
 lda    #$0D
 sta    $0600,y
 rts
 jsr    $BED2
 ldx    #$00
 ldy    #$06
 jsr    OS_CLI
 jmp    $8B9B
 jmp    $8C0E
 jsr    $9B1D
 bne    $BECF
 jsr    $BEB2
 jmp    $984C
 jsr    $BED2
 dey
 sty    $39
 lda    $18
 sta    $3A
 lda    #$82
 jsr    OSBYTE
 stx    $3B
 sty    $3C
 lda    #$00
 rts
 jsr    $BE6F
 lda    $12
 sta    $45
 lda    $13
 sta    $46
 lda    #$23
 sta    $3D
 lda    #$80
 sta    $3E
 lda    $18
 sta    $42
 jsr    $BEDD
 stx    $3F
 sty    $40
 stx    $43
 sty    $44
 stx    $47
 sty    $48
 sta    $41
 tay
 ldx    #$37
 jsr    OSFILE
 jmp    $8B9B
 jsr    $BE62
 jmp    $8AF3
 jsr    $BE62
 jmp    $BD14
 jsr    $BFA9
 pha
 jsr    $9813
 jsr    $92EE
 pla
 tay
 ldx    #$2A
 lda    #$01
 jsr    OSARGS
 jmp    $8B9B
 sec
 lda    #$00
 rol    a
 rol    a
 pha
 jsr    $BFB5
 ldx    #$2A
 pla
 jsr    OSARGS
 lda    #$40
 rts
 jsr    $BFA9
 pha
 jsr    $8AAE
 jsr    $9849
 jsr    $92EE
 pla
 tay
 lda    $2A
 jsr    OSBPUT
 jmp    $8B9B
 jsr    $BFB5
 jsr    OSBGET
 jmp    $AED8
 lda    #$40
 bne    $BF82
 lda    #$80
 bne    $BF82
 lda    #$C0
 pha
 jsr    $ADEC
 bne    $BF96
 jsr    $BEBA
 ldx    #$00
 ldy    #$06
 pla
 jsr    OSFIND
 jmp    $AED8
 jmp    $8C0E
 jsr    $BFA9
 jsr    $9852
 ldy    $2A
 lda    #$00
 jsr    OSFIND
 jmp    $8B9B
 lda    $0A
 sta    $1B
 lda    $0B
 sta    $19
 lda    $0C
 sta    $1A
 jsr    $8A8C
 cmp    #$23
 bne    $BFC3
 jsr    $92E3
 ldy    $2A
 tya
 rts
 brk
 and    $694D
 .byte  's'
 .byte  's'
 adc    #$6E
 .byte  'g'
 jsr    $0023
 pla
 sta    $37
 pla
 sta    $38
 ldy    #$00
 beq    $BFDC
 jsr    OSASCI
 jsr    $894B
 bpl    $BFD9
 jmp    ($0037)
 jsr    $9857
 jsr    $BC25
 ldy    #$01
 lda    ($FD),y
 beq    $BFF6
 jsr    $B50E
 iny
 bne    $BFEC
 jmp    $8B9B
 brk
 .byte  'R'
 .byte  'o'
 .byte  'g'
 adc    $72
 brk
