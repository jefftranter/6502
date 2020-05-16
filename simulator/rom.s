        .org $8000

start:  nop
        lda     #$01
        clc
        adc     #$01
        lda     #$ff
        clc
        adc     #$01
        lda     #$ff
        clc
        adc     #$02
        lda     #$70
        clc
        adc     #$10
        nop
        lda     #$10
        sec
        sbc     #$01
        lda     #$01
        sec
        sbc     #$02
        nop

        sec
        bcs     l1
        brk
l1:     clc
        bcc     *+3
        brk
        lda     #$01
        bpl     *+3
        brk
        lda     #$80
        bmi     *+3
        brk
        lda     #$00
        beq     *+3
        brk
        ldx     #$00
        beq     *+3
        brk
        ldy     #$00
        beq     *+3
        brk
        ldx     #$00
        beq     *+3
        brk
        ldy     #$00
        beq     *+3
        brk
        jmp     start
