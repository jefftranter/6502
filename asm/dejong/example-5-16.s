MLTP    =       $01
MCND    =       $02
PRODLO  =       $03
PRODHI  =       $04

        .ORG    $1290

        LDX     #$08            ; X serves as a bit counter.
        LDA     #$00            ; Clear the MSB of the product.
BR1:    LSR     MLTP            ; Shift multiplier into carry.
        BCC     BR2             ; If C=0, then skip addition.
        CLC                     ; Clear carry for addition.
        ADC     MCND            ; Collect the sum of the products
BR2:    ROR     A               ; in the accumulator, rotate it
        ROR     PRODLO          ; into the LSB of the product.
        DEX                     ; Decrement the bit counter
        BNE     BR1             ; until 8 bits have been counted.
        STA     PRODHI          ; Store MSB in PRODHI.
        RTS
