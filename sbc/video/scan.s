; Scan code for Scungy video 1x32 alphanumeric display
; JSR/RTS or BRK method.

        .org    $2000

        .res    30, $A0         ; LDY #$A0
        rts
        rts
;       rti
;       rti
