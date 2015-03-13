        LAST    = $F3
        INH     = $F9
        POINTL  = $FA
        POINTH  = $FB

        SCANDS  = $1F1F
        GETKEY  = $1F6A

        .ORG    $0000

START:  CLD
        CLC
        LDA     POINTL
        SBC     POINTH
        STA     INH
        DEC     INH
        JSR     SCANDS
        JSR     GETKEY
        CMP     LAST
        BEQ     START
        STA     LAST
        CMP     #$10
        BCS     START
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        LDX     #4
ADDR:   ASL     A
        ROL     POINTL
        ROL     POINTH
        DEX
        BNE     ADDR
        BEQ     START
