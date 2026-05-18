M       =       $00
N       =       $01

        .org    $103E

        ldx     M               ; Load X with the number in M.
LOOPX:  ldy     N               ; Load Y with the number in N.
LOOPY:  dey                     ; Decrement the number in Y.
        bne     LOOPY           ; If Y is not zero, lop back to LOOPY.
        dex                     ; Decrement the number in X.
        bne     LOOPX           ; If X is not zero, loop back to LOOPX.
        brk
