INVFLG  =       $32

        .org    $1015

START:  ldx     #$7F            ; "LDX" in the immediate mode.
        stx     INVFLG          ; "STX" in the zero-page mode.
END:    brk
