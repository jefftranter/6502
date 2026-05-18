CURSHO  =       $24
CURSVT  =       $25

        .ORG    $1009

        LDA     #$00            ; "LDA" in immediate mode.
        STA     CURSHO          ; "STA" in zero-page mode.
        STA     CURSVT
        BRK                     ; BREAK to the monitor.
