MEMORY  =       $01

        .ORG    $10EF

        LDX     #$FC            ; X serves as a bit counter with X=-4.
LOOP:   ASL     MEMORY          ; Shift the number one bit left.
        INX                     ; Increment the counter.
        BNE     LOOP            ; Go through the loop four times.
        BRK                     ; Break to the monitor.
