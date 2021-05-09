; Contents of 32X8 SCAN PROM1

        .org    $0000

        .res    31, $A0         ; LDY #$A0
        .byte   $60             ; RTS
