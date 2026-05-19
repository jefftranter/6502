CHCODE  =       $03FF

        .ORG    $1220

        CLC                     ; Clear the carry flag.
        LDX     #$00            ; Clear the X register to count ones.
        LDY     #$07            ; Y counts the bits in the character.
BR1:    ROR     CHCODE          ; Rotate the character right.
        BCC     BR2             ; If bit is zero, don't count it.
        INX                     ; If it is one, count it.
BR2:    DEY                     ; Decrement the bit counter.
        BNE     BR1             ; Get another bit.
        ROR     CHCODE          ; Rotate the eighth bit.
        TXA                     ; Transfer the one count to A.
        LSR     A               ; Shift into carry.
        ROR     CHCODE          ; Carry into bit 7 as parity.
        RTS
