PBD     =       $C700
DDRB    =       $C702

        .ORG    $17A9

        LDA     #$7F            ; Clear bit 7 of DDRB.
        AND     DDRB            ; So PB7 is an input pin.
        STA     DDRB
LOOP:   BIT     PBD             ; Is bit seven at
        BMI     LOOP            ; logic one? Yes, wait.
        BRK                     ; No, continue.
