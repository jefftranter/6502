PAD     =       $C781
PCR     =       $C78C
IFR     =       $C78D

        .ORG    $1970

        LDA     #$0A            ; Initialize PCR to
        STA     PCR             ; pulse CA2 to start A
        LDA     PAD             ; conversion.
BACK:   LDA     #$02            ; Set up mask for IFR1.
WAIT:   BIT     IFR             ; Is the conversion complete?
        BEQ     WAIT            ; No, then wait.
        LDA     PAD             ; Yes, read data.
        RTS
