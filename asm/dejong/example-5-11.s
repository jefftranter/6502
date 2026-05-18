HERE    =       $037F

        .ORG    $1274

        SED                     ; Set the decimal mode flag.
        CLC                     ; Clear the carry flag.
        LDA     #$83            ; Load A with the decimal number 83.
        ADC     #$35            ; Add rthe decimal number 35.
        STA     HERE            ; Store the result here.
        BRK
