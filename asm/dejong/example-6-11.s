BCD     =       $F0

        .ORG    $1400

        SED                     ; Set the decimal mode.
        SEC                     ; Set the carry to add 1.
        LDX     #3              ; X is the byte counter.
HERE:   LDA     #0              ; Clear accumulator.
        ADC     BCD,X           ; Add carry to the number.
        STA     BCD,X           ; Store it.
        DEX                     ; Decrement the byte counter.
        BNE     HERE            ; Loop back for another byte.
        CLD                     ; Clear the decimal mode before
        RTS                     ; returning to the main program.
