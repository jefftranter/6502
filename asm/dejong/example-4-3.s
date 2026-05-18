MEM1    =       $00
MEM2    =       $100F

        .ORG    $10B1

        LDA     MEM1            ; Perform an OR operation between
        ORA     #$80            ; the number in MEM1 and $80.
        STA     MEM2            ; Result into MEM2.
        BRK
