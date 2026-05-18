M       =       $00

        .org    $1038

        ldx     M               ; Load X with M.
LOOP:   dex                     ; Decrement X.
        bne     LOOP            ; Loop until X is zero.
        brk
