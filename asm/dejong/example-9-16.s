T2LL    =       $C708
T2CH    =       $C709
ACR     =       $C70B
IFR     =       $C70D

        .ORG    $1896

        LDA     #$20            ; Initialize T2 to be
        STA     ACR             ; in counting mode.
        LDA     #$E7            ; Set up T2 to count 1000
        STA     T2LL            ; pulses. $03E7 + 1 = 1000.
        LDA     #$03
        STA     T2CH            ; Counting begins with this instruction.
        LDA     #$20            ; Set up mask for IFR.
WAIT:   BIT     IFR             ; Has IFR5 been set?
        BEQ     WAIT            ; No, so wait in this loop.
        RTS                     ; 1000 pulses have been counted.

