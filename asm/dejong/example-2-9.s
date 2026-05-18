INVFLG  =       $32

        .ORG    $1015

START:  LDX     #$7F            ; "LDX" in the immediate mode.
        STX     INVFLG          ; "STX" in the zero-page mode.
END:    BRK
