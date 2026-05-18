MLTP    =       $01
MCND    =       $02

        .ORG    $1280

MULTIPLY:
        CLD                     ; Clear the decimal mode.
        LDA     #$00            ; Clear the product location, A.
RPEAT:  LSR     MLTP            ; Shift multiplier to check for zero.
        BCC     ARND            ; Or one in the carry flag.
        CLC                     ; If C=1, then add multiplicand.
        ADC     MCND            ; Add multiplicand.
ARND:   BEQ     QUIT            ; MLTP has been shifted to zero.
        ASL     MCND            ; Shift multiplicand.
        BNE     RPEAT           ; Get another partial product.
QUIT:   RTS                     ; That's all.
