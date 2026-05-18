MEM1    =       $00
MEM2    =       $100F

        .ORG    $10B9

        LDA     #$FF            ; Perform an EOR operation between
        EOR     MEM1            ; teh $FF and the number in MEM1.
        STA     MEM2            ; Result into MEM2.
        BRK
