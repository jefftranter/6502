DVSOR   =       $01
DIVD    =       $02

        .ORG    $12A4

DIVIDE: CLD                     ; Clear the decimal mode.
        LDA     #$00            ; Clear the partial dividend.
        LDX     #$08            ; X is a bit counter.
        ASL     DIVD            ; Shift DIVD into carry,
HERE:   ROL     A               ; and carry into partial dividend.
        CMP     DVSOR           ; Compare it with the divisor.
        BCC     PAST            ; Do not subtract.
        SBC     DVSOR           ; Subtract from partial dividend.
PAST:   ROL     DIVD            ; Rotate carry into quotient.
        DEX                     ; Decrement the bit counter.
        BNE     HERE            ; Go back for another bit.
        RTS
