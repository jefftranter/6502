BCDLO   =       $01
BCDHI   =       $02
BINUM   =       $03

        .ORG    $12F6

BCDSUB: SED                     ; Set the decimal mode.
        LDA     #$00            ; Clear the BCD locations.
        STA     BCDLO
        STA     BCDHI
        LDX     #$08            ; X will be a bit counter.
BR1:    ASL     BINUM           ; Move binary number into carry.
        LDA     BCDLO           ; Get the LSB of the BCD number.
        ADC     BCDLO           ; Add it to itself.
        STA     BCDLO           ; Store it.
        LDA     BCDHI           ; Get the MSB of the BCD number.
        ADC     BCDHI           ; Add it to itself.
        STA     BCDHI           ; Store it.
        ADC     #$00            ; Add any carry to the accumulator.
        DEX
        BNE     BR1             ; Repeat eight times.
        CLD                     ; Clear the decimal mode.
        RTS                     ; Return to the calling program.
