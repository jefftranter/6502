T1LL    =       $C704
T1LH    =       $C705
T2CH    =       $C709
T2LL    =       $C708
ACR     =       $C70B
IFR     =       $C70D

        .ORG    $18AD

        LDA     #$E0            ; Initialize T1 to toggle PB7 in its
        STA     ACR             ; free-running mode. T2 counts pulses.
        LDA     #$BE            ; T1 will product a period of
        STA     T1LL            ; 2($C7BE + 2) clock cycles.
        LDA     #$C7            ; $C7BE + 2 = 51,136.
        STA     T1LH            ; Start  T1 running the square wave.
        LDA     #$9F            ; Set up T2 to count $8C9F + 1 pulses
        STA     T2LL            ; before timing out.
        LDA     #$8C            ; $89CF + 1 = 36,000.
        STA     T2CH            ; Start counting.
        LDA     #$20            ; Set up mask for IFR5.
WAIT:   BIT     IFR             ; Has flag been set?
        BEQ     WAIT            ; No, so wait here for an hour or so.
        RTS                     ; Yes, an hour is up, return.

