PBD     =       $C700
DDRB    =       $C702
PCR     =       $C70C
IFR     =       $C70D

        .ORG    $17C2

MAIN:   LDA     #$00            ; Make port B an input port.
        STA     DDRB
        LDA     PCR             ; Initialize the PCR by clearing
        AND     #$EF            ; bit 4, PCR4. A negative
        STA     PCR             ; transition will set IFR4.

;****************
; Subroutine KEYIN

KEYIN:  LDA     #$10            ; Mask IFR to isolate IFR4
WAIT:   BIT     IFR             ; Is IFR4 set?
        BEQ     WAIT            ; No, then wait here.
        LDA     PBD             ; Yes, then read port and clear flag.
        RTS                     ; Return with code in A.
