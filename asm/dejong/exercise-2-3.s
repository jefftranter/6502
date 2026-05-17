CURSHO  =       $24
CURSVT  =       $25

        .org    $1009

        lda     #$00            ; "LDA" in immediate mode.
        sta     CURSHO          ; "STA" in zero-page mode.
        sta     CURSVT
        brk                     ; BREAK to the monitor.
