        NMI = $0130
        IRQ = $01C0

        L0000 = $0000
        L0218 = $0218
        L021A = $021A
        L021C = $021C
        L021E = $021E
        L0220 = $0220
        LA636 = $A636
        LBD11 = $BD11
        LBF2D = $BF2D
        LFC00 = $FC00
        LFCA6 = $FCA6
        LFCB1 = $FCB1
        LFD00 = $FD00
        LFE00 = $FE00

        * = $FF00

RESET:  cld
        ldx     #$28
        txs
        ldy     #$0A
LFF06:  lda     $FEEF,y
        sta     $0217,y
        dey
        bne     LFF06
        jsr     LFCA6
        sty     $0212
        sty     $0203
        sty     $0205
        sty     $0206
        lda     LFFE0
        sta     $0200
        lda     #$20
LFF26:  sta     $D300,y
        sta     $D200,y
        sta     $D100,y
        sta     $D000,y
        iny
        bne     LFF26
LFF35:  lda     LFF5F,y
        beq     LFF40
        jsr     LBF2D
        iny
        bne     LFF35
LFF40:  jsr     LFFBA
        cmp     #$4D
        bne     LFF4A
        jmp     LFE00
LFF4A:  cmp     #$57
        bne     LFF51
        jmp     L0000
LFF51:  cmp     #$43
        bne     LFF58
        jmp     LBD11
LFF58:  cmp     #$44
        bne     RESET
        jmp     LFC00
LFF5F:  .asciiz   "D/C/W/M ?"
        jsr     LBF2D
        pha
        lda     $0205
        beq     LFF94
        pla
        jsr     LFCB1
        cmp     #$0D
        bne     LFF95
        pha
        txa
        pha
        ldx     #$0A
        lda     #$00
LFF81:  jsr     LFCB1
        dex
        bne     LFF81
        pla
        tax
        pla
        rts
        pha
        dec     $0203
        lda     #$00
LFF91:  sta     $0205
LFF94:  pla
LFF95:  rts
        pha
        lda     #$01
        bne     LFF91
        lda     $0212
        bne     LFFB9
        lda     #$FE
        sta     $DF00
        bit     $DF00
        bvs     LFFB9
        lda     #$FB
        sta     $DF00
        bit     $DF00
        bvs     LFFB9
        lda     #$03
        jmp     LA636
LFFB9:  rts
LFFBA:  bit     $0203
        bpl     LFFD8
LFFBF:  lda     #$FD
        sta     $DF00
        lda     #$10
        bit     $DF00
        beq     LFFD5
        lda     $F000
        lsr     a
        bcc     LFFBF
        lda     $F001
        rts
LFFD5:  inc     $0203
LFFD8:  jmp     LFD00
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   $FF
LFFE0:  .byte   $65, $17
        .byte   $00
        .byte   $00
        .byte   $03
        .byte   $FF
        .byte   $9F
        .byte   $00
        .byte   $03
        .byte   $FF
        .byte   $9F
        jmp     (L0218)
        jmp     (L021A)
        jmp     (L021C)
        jmp     (L021E)
        jmp     (L0220)
        .word   NMI
        .word   RESET
        .word   IRQ
