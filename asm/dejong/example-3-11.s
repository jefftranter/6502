PB0     =       $C061

        .ORG    $1069

TEST:   LDX     PB0             ; Read the switch, bit 7.
        BMI     TEST            ; Loop until it's logic zero.
        BRK                     ; Then do something.
