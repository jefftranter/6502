KYBD    =       $C000
STROBE  =       $C010

        .ORG    $10C7

WAIT:   BIT     KYBD            ; Test bit 7. Is it zero?
        BPL     WAIT            ; Yes, then wait.
        STA     STROBE          ; Clear bit seven. Then continue.
        BRK
