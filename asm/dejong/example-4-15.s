MEM1    =       $00

        .ORG    $10E9

        LDA     MEM1            ; Get a number from location MEM1.
        LSR     A               ; Shift it right one bit.
        STA     MEM1            ; Return it to MEM1.
        BRK                     ; Display the registers.
