M       =       $00

        .ORG    $1038

        LDX     M               ; Load X with M.
LOOP:   DEX                     ; Decrement X.
        BNE     LOOP            ; Loop until X is zero.
        BRK
