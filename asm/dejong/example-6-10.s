NUMA    =       $00
NUMB    =       $10

        .ORG    $13E9

        LDY     #32             ; Y is the # of bits to rotate.
LOOPY:  LDX     #4              ; X is # of bytes in the number.
LOOPX:  LSR     NUMA,X          ; Shift A right into carry.
        ROR     NUMB,X          ; Rotate carry into B.
        DEX                     ; Decrement byte counter.
        BNE     LOOPX           ; Rotate another byte.
        DEY                     ; Decrement bit counter.
        BNE     LOOPY           ; Do another bit.
        RTS
