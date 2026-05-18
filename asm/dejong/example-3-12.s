PB1     =       $C062
AN1OFF  =       $C05A
AN1ON   =       $C05B

        .ORG    $106F

START:  LDY     PB1             ; Read the switch.
        BMI     PAST            ; Go turn annunciator on.
        STA     AN1OFF          ; Turn annunciator off.
        BPL     AROUND          ; Skip to AROUND.
PAST:   STA     AN1ON
AROUND: JMP     START           ; Loop to run program again.
