M       =       $00
N       =       $01

        .ORG    $103E

        LDX     M               ; Load X with the number in M.
LOOPX:  LDY     N               ; Load Y with the number in N.
LOOPY:  DEY                     ; Decrement the number in Y.
        BNE     LOOPY           ; If Y is not zero, lop back to LOOPY.
        DEX                     ; Decrement the number in X.
        BNE     LOOPX           ; If X is not zero, loop back to LOOPX.
        BRK
