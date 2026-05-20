T1LL    =       $C704
T1LH    =       $C705
ACR     =       $C70B
IFR     =       $C70D

        .ORG    $1811

        LDA     #$00            ; Initialize T1 to be
        STA     ACR             ; in the one-shot mode.
        LDA     #$4F            ; Set up the time interval
        STA     T1LL            ; to be $C34E+1 (50,000)
        LDA     #$C3            ; clock cycles.
        STA     T1LH            ; Timing begins with this instruction.
        LDA     #$40            ; Set up mask for IFR.
WAIT:   BIT     IFR             ; Has IFR6 been set?
        BEQ     WAIT            ; No, so wait in this loop.
        BRK                     ; Yes, continue.
