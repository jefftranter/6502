LOC1    =       $10FF
LOC2    =       $10FE

        .ORG    $1200

        LDY     #$08            ; Y contains number of bits to be shifted.
BRANCH: ASL     LOC1            ; Shift bit 7 into carry.
        ROL     LOC2            ; Rotate carry into LOC2.
        DEY                     ; Decrement the bit counter.
        BNE     BRANCH          ; Loop until 8 bits
        BRK                     ; have been shifted.
