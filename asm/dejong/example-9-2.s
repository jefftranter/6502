PBD     =       $C700
PAD     =       $C701

        .ORG    $177E

        LDA     #$F0            ; Make bits four-seven logic one.
        STA     PAD             ; Write to the output port.
        LDA     #$81            ; Make bits zero and eight equal one.
        STA     PBD             ; Output this number to port B.
