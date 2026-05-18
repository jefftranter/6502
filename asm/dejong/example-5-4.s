ADDEND1 =       $01
ADDEND2 =       $02
SUMLO   =       $03
SUMHI   =       $04

        .ORG    $1238

        CLD                     ; Clear the decimal mode flag.
        CLC                     ; Clear the carry flag.
        LDA     ADDEND1         ; Get the first number.
        ADC     ADDEND2         ; Add it to the second.
        STA     SUMLO           ; Store it here.
        LDA     #$00            ; Clear the accumulator.
        ADC     #$00            ; Add: $00 + $00 + C; that is, add C.
        STA     SUMHI           ; Store result in SUMHI.
        BRK
