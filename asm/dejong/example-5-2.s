OPA     =       $01
OPB     =       $02
SUM     =       $03

        .ORG    $1230

        CLC                     ; Clear the carry flag before adding.
        LDA     OPA             ; Get the number from location OPA.
        ADC     OPB             ; Add it to the number in OPB.
        STA     SUM             ; Store the result in SUM.
        BRK
