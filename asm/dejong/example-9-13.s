T2LL    =       $C708
T2CH    =       $C709
ACR     =       $C70B
IFR     =       $C70D

        .ORG    $1828

        LDA     #$00            ; Initialize T2 to be
        STA     ACR             ; an interval timer.
        LDA     #$BE            ; Set up the time interval
        STA     T2LL            ; to be $C7BE+1 cycles,
        LDA     #$C7            ; or 0.05 second.
        STA     T2CH            ; Timing begins with this instruction.
        LDA     #$20            ; Set up mask for IFR.
WAIT:   BIT     IFR             ; Has IFR5 been set?
        BEQ     WAIT            ; No, so wait in this loop.
        RTS                     ; Yes, continue.
