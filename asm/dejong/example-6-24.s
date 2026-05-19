        .ORG    $15F0

        CLD
        INC     $12
        BNE     BR0
        INC     $13
BR0:    LDY     #$00
LOOP:   LDA     ($10),Y
        STA     ($14),Y
        INC     $10
        BNE     BR1
        INC     $11
BR1:    INC     $14
        BNE     BR2
        INC     $15
BR2:    LDA     $10
        CMP     $12
        LDA     $11
        SBC     $13
        BCC     LOOP
        BRK
