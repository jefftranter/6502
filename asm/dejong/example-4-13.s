PORT    =       $C061

        .ORG    $10D0

        LDA     #$01            ; Set up the mask byte.
LOOP1:  BIT     PORT            ; Test the port.
        BNE     LOOP1           ; Wait until bit 0 is 0.
LOOP2:  BIT     PORT            ; Test the port again.
        BPL     LOOP2           ; Wait until bit 0 is 1.
        BRK
