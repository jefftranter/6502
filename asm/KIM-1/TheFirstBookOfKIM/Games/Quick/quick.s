        INH     = $F9
        POINTL  = $FA
        POINTH  = $FB

        SCANDS  = $1F1F
        KEYIN   = $1F40
        GETKEY  = $1F6A

        .ORG    $0300

START:  LDA     INH             ; RANDOMIZE DELAY
        ROL     A               ; ..BY MULTIPLYING
        ADC     INH             ; BY 3 AND
        AND     #$7F            ; MASKING
        STA     POINTH          ; WORK IN DISPLAY AREA
ZIP:    JSR     KEYIN           ; IF YOU CHEAT BY KEYING...
        BNE     ZIP             ; PROGRAM WAITS YOU OUT
        INC     POINTL
        BNE     ZIP             ; COUNT DOWN FOR
        INC     POINTH          ; RANDOM DELAY
        BNE     ZIP
        STA     INH             ; SET TO ZERO
RUN:    LDX     #$FD            ; NEGATIVE THREE
        SED                     ; COUNT IN DECIMAL
        SEC                     ; ADD VALUE 1
DIGIT:  LDA     POINTH+1,X
        ADC     #$00            ; ADD IT IN
        STA     POINTH+1,X
        INX                     ; MOVE ON TO NEXT DIGITS
        BNE     DIGIT
        CLD
        JSR     SCANDS          ; LIGHT UP COUNT
        BEQ     RUN             ; AND KEEP COUNTING
STAND:  JSR     SCANDS
        JSR     GETKEY
        CMP     #$13            ; GO KEY DEPRESSED?
        BNE     STAND           ; NOPE, HOLD IT
        BEQ     START           ; YUP, START OVER
