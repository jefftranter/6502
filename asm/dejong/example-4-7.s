MEM2    =       $100F

        .ORG    $10C1

        LDA     #$01            ; Perform a BIT test on location
        BIT     MEM2            ; MEM2 with $01 in A.
        BRK
