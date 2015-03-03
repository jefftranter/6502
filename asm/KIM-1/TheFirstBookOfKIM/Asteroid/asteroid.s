        .org    $0200

SCANDS  = $1F1F
KEYIN   = $1F40
GETKEY  = $1F6A

        LDA     #$00            ; ..INITIALIZE COUNTER...
        STA     $00F9
        STA     $00FA
        STA     $00FB
        LDX     #$06            ; ..INITIALIZE 00E2-00E8
INIT:   LDA     $02CE,X
        STA     $00E2,X
        DEX
        BPL     INIT
TOGG:   LDA     $00E8           ; ..TOGGLE 00E8..
        EOR     #$FF
        STA     $00E8           ; (FLASHER FLAG)
        LDX     #$05            ; DELAY BETWEEN FLASHES
LITE:   JSR     DISP            ; DISPLAY AND..
        JSR     CHEK            ; CHECK FOR MATCH
        DEX
        BNE     LITE
        JSR     KEYIN           ; SET DIRECTIONAL REGS.
        JSR     GETKEY          ; GET KEYBOARD ENTRY
        CMP     #$15            ; A VALID KEY?
        BPL     TOGG            ; NO
        CMP     #$00            ; KEY 0?
        BEQ     LEFT            ; YES, GO LEFT
        CMP     #$03            ; KEY 3?
        BEQ     RT              ; YES, GO RIGHT
        BNE     TOGG            ; NOT A VALID KEY
LEFT:   ASL     $00E7           ; SHIFT CRAFT LEFT
        LDA     #$40            ; LEFT HAND EDGE?
        CMP     $00E7
        BNE     TOGG            ; NO, RETURN
RT:     LSR     $00E7           ; SHIFT RIGHT
        BNE     TOGG            ; NOT RIGHT SIDE, RETURN
        SEC                     ; OFF EDGE, RETURN TO
        ROL     $00E7           ; RIGHT SIDE
        BNE     TOGG            ; RETURN
; *** DISPLAY SUBROUTINE ***
DISP:   LDA     #$7F            ; PORT TO OUTPUT
        STA     $1741
        LDA     #$09            ; INIT. DIGIT
        STA     $1742
        LDA     #$20            ; BIT POSITION TO
        STA     $00E0           ; 6TH BIT
BITS:   LDY     #$02            ; 3 BYTES
        LDA     #$00            ; ZERO CHARACTER
        STA     $00E1
BYTE:   LDA     ($00E2),Y       ; GET BYTE
        AND     $00E0           ; NTH BIT = 1?
        BEQ     NOBT            ; NO, SKIP
        LDA     $00E1           ; YES, UPDATE
        ORA     $00E4,Y         ; CHARACTER
        STA     $00E1
NOBT:   DEY
        BPL     BYTE            ; NEXT BYTE
        LDA     $00E1           ; CHAR IN ACCUM.
        CPY     $00E8           ; SHIP ON?
        BNE     DIGT            ; NO, SKIP
        LDY     $00E0           ; IS THIS SHIP
        CPY     $00E7           ; DIGIT?
        BNE     DIGT            ; NO, SKIP
        ORA     #$08            ; ADD IN SHIP
DIGT:   STA     $1740           ; LIGHT DIGIT
        LDA     #$30            ; DELAY (DIGIT ON)
        STA     $1706
DELA:   LDA     $1707           ; TIME UP?
        BEQ     DELA            ; NO
        LDA     #$00            ; TURN OF SEGMENTS
        STA     $1740
        INC     $1742           ; SHIFT TO NEXT DIGIT
        INC     $1742
        LSR     $00E0           ; SHIFT TO NEXT BIT
        BNE     BITS            ; MORE BITS
        RTS
; *** CHECK SUBROUTINE ***
CHEK:   DEC     $00E9           ; DEC. TIMES THRU COUNT
        BNE     MORE            ; SKIP IF NOT 48TH TIME
        LDA     #$30            ; RESET TIMES THRU COUNT
        STA     $00E9
        TXA                     ; SAVE X
        PHA
        LDX     #$FD            ; NEGATIVE 3 IN X
        SED                     ; DECIMAL MODE
        SEC                     ; (TO ADD ONE)
NXTB:   LDA     $00FC,X         ; ..INCREMENT COUNTER
        ADC     #$00            ; WHICH IS MADE OF BYTES
        STA     $00FC,X         ; IN DISPLAY AREA (00F9-
        INX                     ; 00FB)..
        BNE     NXTB            ; NEXT BYTE
        CLD
        PLA                     ; RETURN X
        TAX
        INC     $00E2           ; ..SET UP FOR NEXT GROUP
        LDA     $00E2           ; OF BYTES..
MORE:   CMP     #$30            ; ALL GROUPS FINISHED?
        BEQ     RECY            ; YES, RECYCLE ASTR. FIELD
MATCH:  LDY     #$00            ; SHIP - ASTEROID MATCH?
        LDA     $00E7           ; LOAD CRAFT POSITION
        AND     ($00E2),Y       ; AND WITH ASTEROID BYTE
        BNE     FIN             ; IF MATCH, YOU'VE HAD IT
        RTS                     ; EXIT MATCH SUBROUTINE
RECY:   LDA     #$00            ; GO THRU ASTEROID FIELD
        STA     $00E2           ; AGAIN
        BEQ     MATCH           ; UNCONDITIONAL BRANCH
FIN:    JSR     SCANDS          ; DISPLAY COUNT
        JMP     FIN             ; CONTINOUSLY

        .BYTE   $D5              ; LOW POINTER, ASTEROID
        .BYTE   $02              ; HIGH POINTER, ASTEROID
        .BYTE   $08              ; MASK, BOTTOM SEGMENT
        .BYTE   $40              ; MASK, MIDDLE SEGMENT
        .BYTE   $01              ; MASK, TOP SEGMENT
        .BYTE   $04              ; CRAFT POSITION
        .BYTE   $FF              ; FLAG (SHIP ON)

; ***** ASTEROID FIELD *****

        .BYTE $00, $00, $00, $04, $00, $08, $00, $06, $12, $00, $11, $00, $05, $00, $2C, $00
        .BYTE $16, $00, $29, $00, $16, $00, $2B, $00, $26, $00, $19, $00, $17, $00, $38, $00
        .BYTE $2E, $00, $09, $00, $1B, $00, $24, $00, $15, $00, $39, $00, $0D, $00, $21, $00
        .BYTE $10, $00, $00

