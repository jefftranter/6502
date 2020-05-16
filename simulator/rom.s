        .org $8000

start:  nop

        clc
        lda     #$8C
        adc     #$01

        clc
        lda     #$FE
        adc     #$FD

        clc
        lda     #$70
        adc     #$20

        clc
        lda     #$70
        adc     #$FC

        lda     #$aa
        clc
        ldx     #$08
r0:     lsr
        dex
        bne     r0
        nop

        lda     #$aa
        sta     $01
        ldx     #$08
r1:     ror     $01
        lda     $01
        dex
        bne     r1

        clc
        lda     #$55
        sta     $02
        ldx     #$08
r2:     rol     $02
        lda     $02
        dex
        bne     r2
        nop

        lda     #$aa
        ldx     #$08
        clc
r3:     asl
        dex
        bne     r3

        lda     #$aa
        sta     $03
        ldx     #$08
        clc
r4:     asl     $03
        lda     $03
        dex
        bne     r4

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
