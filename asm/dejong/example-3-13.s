AN0OFF  =       $C058
AN0ON   =       $C059
AN1OFF  =       $C05A
AN1ON   =       $C05B
PB1     =       $C062
PAD0    =       $C064
CLEAR   =       $C070

        .org    $107F

START:  ldy     PB1             ; Read the switch.
        bmi     PAST            ; Go turn annunciator on.
        sta     AN1OFF          ; Turn annunciator off.
        bpl     AROUND          ; Skip to AROUND.
PAST:   sta     AN1ON           ; Turn annunciator on.
AROUND: lda     AN0OFF          ; Turn annunciator 0 off.
        lda     AN0ON           ; Then on to step motor.
        ldx     #$04            ; Set counter to minimum.
        lda     CLEAR           ; Start the timer.
WAIT:   lda     PAD0            ; Read the paddle port.
        bpl     LOOPX           ; Get out of timing loop.
STAY:   inx                     ; Otherwise, stay in.
        bne     WAIT            ; Test paddle again.
LOOPX:  ldy     #$CB            ; Set Y for 1 ms loop.
LOOPY:  dey                     ; Decrement Y.
        bne     LOOPY           ; Loop until Y is 0.
        dex                     ; Decrement X.
        bne     LOOPX           ; Loop until X is 0.
        beq     START           ; Repeat the program.
