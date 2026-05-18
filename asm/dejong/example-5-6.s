ADD1LO  =       $01
ADD2HI  =       $02
ADD2LO  =       $03
ADD1HI  =       $04
SUMLO   =       $05
SUMHI   =       $06

        .ORG    $1247

        CLC                     ; Clear the carry flag.
        LDA     ADD1LO          ; Get LSB of #1.
        ADC     ADD2LO          ; Add to LSB of #2.
        STA     SUMLO           ; Result is LSB of sum.
        LDA     ADD1HI          ; Get MSB of #1.
        ADC     ADD2HI          ; Add to MSB of #2.
        STA     SUMHI           ; Result is MSB of sum.
        BRK
