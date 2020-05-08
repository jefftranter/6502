        .org $8000

start:  nop
        sed
        cld
        ldx     #1
        ldy     #2
        lda     #3
        sta     $1000
        stx     $1001
        sty     $1002
        lda     $1000
        ldx     $1002
        ldy     $1001
        sec
        clc
        adc     #$02
loop:   iny
        dex
        bne     loop
        inc     $1000
        jmp     start
