        .ORG    $15CE

        LDA     #00
        STA     $10
        STA     $12
        LDA     #$20
        STA     $11
        LDA     #$40
        STA     $13
        LDY     #00
LOOPY:  LDA     ($10),Y
        STA     ($12),Y
        INY
        BNE     LOOPY
        INC     $11
        INC     $13
        LDA     $11
        CMP     #$40
        BNE     LOOPY
        RTS
