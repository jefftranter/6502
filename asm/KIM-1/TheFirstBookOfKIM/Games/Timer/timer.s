        INH     = $F9
        POINTL  = $FA
        POINTH  = $FB

        SCANDS  = $1F1F
        GETKEY  = $1F6A
        ROM     = $1C00

        .ORG    $0200

BEGN:   LDA     #$00
        STA     INH             ; ZERO DISPLAY
        STA     POINTL
        STA     POINTH
HOLD:   JSR     SCANDS          ; LIGHT DISPLAY
        JSR     GETKEY
        CMP     #$04            ; KEY 4?
        BNE     CONT
        JMP     $1C64           ; RETURN TO KIM
CONT:   CMP     #$02            ; KEY 2?
        BEQ     BEGN            ; BACK TO ZERO
        CMP     #$01            ; KEY 1?
        BNE     HOLD
        LDA     #$9C
        STA     $1706           ; SET TIMER
DISP:   JSR     SCANDS          ; DISPLAY VALUE
CLCK:   LDA     $1707           ; CHECK TIMER
        BEQ     CLCK
        STA     ROM             ; DELAY 4 MICROSEC.
        LDA     #$9C            ; SET TIMER
        STA     $1706
        CLC
        SED                     ; SET FLAGS
        LDA     INH
        ADC     #$01            ; INC. 100THS
        STA     INH
        LDA     POINTL
        ADC     #$00            ; INC. SECONDS
        STA     POINTL
        CMP     #$60            ; STOP AT 60
        BNE     CKEY
        LDA     #$00
        STA     POINTL          ; ZERO SECONDS
        LDA     POINTH
        CLC
        ADC     #$01            ; INC. MINUTES
        STA     POINTH
CKEY:   CLD
        JSR     GETKEY          ; READ KEYBOARD
        CMP     #$00            ; KEY 0?
        BNE     DISP
        BEQ     HOLD            ; STOP
