MEM1    =       $00
MEM2    =       $100F

        .ORG    $10A9

        LDA     #$7F            ; Perform an AND operation between
        AND     MEM1            ; $7F and the number in MEM1.
        STA     MEM2            ; Result into MEM2.
        BRK
