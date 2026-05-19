BCDLO   =       $01
BCDHI   =       $02
BINUM   =       $03

        .ORG    $1314

                                ; JJT: Book listing incorrectly had 80 (decimal) below.
BISUB:  LDA     #$80            ; Clear seven bits of the
        STA     BINUM           ; binary number. Bit 7 = 1
BR1:    LSR     BCDHI           ; Rotate BCDHI into BCDLO.
        ROR     BCDLO           ; Remainder into carry.
        ROR     BINUM           ; Move it into BINUM.
        BCS     OUT             ; One in carry signals the end.
        SEC                     ; Set the carry for subtractions.
        LDA     BCDLO           ; Do we need a fix?
        AND     #$08            ; Check bit three.
        BEQ     BR2             ; It was not one, no fix required.
        LDA     BCDLO           ; Fix required, subtract three.
        SBC     #$03
        STA     BCDLO           ; Store it.
BR2:    LDA     BCDLO           ; Do we need a fix on bit seven?
        AND     #$80            ; Check it.
        BEQ     BR3             ; It was not one, no fix required.
        LDA     BCDLO           ; Fix required, subtract thirty.
        SBC     #$30
        STA     BCDLO           ; Store it.
BR3:    BCS     BR1             ; Get more bits.
OUT:    RTS                     ; Return.

