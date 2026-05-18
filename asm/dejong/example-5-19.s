        .ORG    $111C

        AND     #$7F            ; Mask bit 7 off.
        CMP     #$40            ; Digit or letter?
        BCS     ARND
        AND     #$0F            ; Digit, mask hi-nibble.
        BPL     PAST            ; Branch past letter.
ARND:   SBC     #$37            ; Letter, subtract $37
PAST:   RTS                     ; Return with digit in A.
