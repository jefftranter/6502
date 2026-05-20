PBD     =       $C700
IFR     =       $C70D

        .ORG    $1801

PRINT:  PHA                     ; Save the character on the stack.
LOAF:   LDA     #$10            ; Set up mask for IFR.
        BIT     IFR             ; Is flag set yet?
        BEQ     LOAF            ; No, then wait here.
        STA     IFR             ; Yes, then clear flag.
        PLA                     ; Get character from the stack.
        STA     PBD             ; And print it.
        RTS
