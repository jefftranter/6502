AN0OFF  =       $C058
AN0ON   =       $C059
AN1OFF  =       $C05A
AN1ON   =       $C05B
PB1     =       $C062
PAD0    =       $C064
CLEAR   =       $C070

        .ORG    $107F

START:  LDY     PB1             ; Read the switch.
        BMI     PAST            ; Go turn annunciator on.
        STA     AN1OFF          ; Turn annunciator off.
        BPL     AROUND          ; Skip to AROUND.
PAST:   STA     AN1ON           ; Turn annunciator on.
AROUND: LDA     AN0OFF          ; Turn annunciator 0 off.
        LDA     AN0ON           ; Then on to step motor.
        LDX     #$04            ; Set counter to minimum.
        lDA     CLEAR           ; Start the timer.
WAIT:   LDA     PAD0            ; Read the paddle port.
        BPL     LOOPX           ; Get out of timing loop.
STAY:   INX                     ; Otherwise, stay in.
        BNE     WAIT            ; Test paddle again.
LOOPX:  LDY     #$CB            ; Set Y for 1 ms loop.
LOOPY:  DEY                     ; Decrement Y.
        BNE     LOOPY           ; Loop until Y is 0.
        DEX                     ; Decrement X.
        BNE     LOOPX           ; Loop until X is 0.
        BEQ     START           ; Repeat the program.
