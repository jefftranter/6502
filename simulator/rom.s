        .org $8000

start:  nop
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
