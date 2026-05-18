PB0     =       $C061

        .org    $1069

TEST:   ldx     PB0             ; Read the switch, bit 7.
        bmi     TEST            ; Loop until it's logic zero.
        brk                     ; Then do something.
