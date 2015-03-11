        INH     = $F9
        POINTL  = $FA
        POINTH  = $FB
        TEMP    = $FF
        TIMER   = $1704
        SCANDS  = $1F1F
        KEYIN   = $1F40
        GETKEY  = $1F6A

        .ORG    $0000

START:  JSR     KEYIN
        BNE     START                   ; key still depressed - blank
        LDA     TIMER                   ; random value
        LSR     A                       ; wipe high order bits
        LSR     A
        LSR     A
        LSR     A
        STA     TEMP                    ; save the digit
        ASL     A                       ; move back left
        ASL     A
        ASL     A
        ASL     A
        ORA     TEMP                    ; repeat the digit
        STA     INH                     ; put..
        STA     POINTL                  ;   ..into..
        STA     POINTH                  ;        ..display
LIGHT:  JSR     SCANDS                  ; light display
        JSR     GETKEY                  ; test keys
        CMP     TEMP                    ; right key?
        BEQ     START                   ; yes, blank & rpeat
        BNE     LIGHT
