PAD     =       $C781
PCR     =       $C78C
IFR     =       $C78D
TABLE   =       $0F00

        .ORG    $1983

        LDX     #$00            ; Clear X.
        LDA     #$0A            ; Initialize PCR to
        STA     PCR             ; pulse CA2.
        LDA     PAD             ; Start a conversion.
BACK:   LDA     #$02            ; Set up mask.
WAIT:   BIT     IFR             ; Conversion complete?
        BEQ     WAIT            ; No, then wait.
        LDA     PAD             ; Yes, read data.
        STA     TABLE,X         ; Store it in a table.
        INX                     ; Get more data.
        BNE     BACK            ; 256 points?
        BRK                     ; Yes, then quit.

