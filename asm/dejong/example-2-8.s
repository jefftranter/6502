        .org    $1010

BEGIN:  lda     #$00            ; "LDA" in the immediate mode.
        tax                     ; "TAX" uses the implied mode.
        tay                     ; "TAY" uses the implied mode.
END:    brk                     ; "BRK" uses the implied mode.
