PB1     =       $C062
AN1OFF  =       $C05A
AN1ON   =       $C05B

        .org    $106F

START:  ldy     PB1             ; Read the switch.
        bmi     PAST            ; Go turn annunciator on.
        sta     AN1OFF          ; Turn annunciator off.
        bpl     AROUND          ; Skip to AROUND.
PAST:   sta     AN1ON
AROUND: jmp     START           ; Loop to run program again.
