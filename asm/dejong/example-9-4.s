PAD     =       $C701
DDRA    =       $C703

        .ORG    $179B

        LDA     #$01            ; Initialize PA0 to be an
        STA     PAD             ; output pin at logic one.
        STA     DDRA
        DEC     PAD             ; Switch PA0 to logic zero.
        INC     PAD             ; Switch PA0 to logic one.
