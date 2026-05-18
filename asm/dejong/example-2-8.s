        .ORG    $1010

BEGIN:  LDA     #$00            ; "LDA" in the immediate mode.
        TAX                     ; "TAX" uses the implied mode.
        TAY                     ; "TAY" uses the implied mode.
END:    BRK                     ; "BRK" uses the implied mode.
