; da65 V2.13.3 - (C) Copyright 2000-2009,  Ullrich von Bassewitz
; Created:    2014-10-25 15:25:54
; Input file: /home/tranter/Documents/Briel/SuperboardIII/roms/fd00-fdff.hex
; Page:       1


        .setcpu "6502"

L002E           := $002E
L415A           := $415A
LFCBE           := $FCBE
LFCC6           := $FCC6
LFCCF           := $FCCF
LFDC8           := $FDC8
        txa
        pha
        tya
        pha
LFF04:  lda     #$01
LFF06:  jsr     LFCBE
        jsr     LFCC6
        bne     LFF13
LFF0E:  asl     a
        bne     LFF06
        beq     LFF66
LFF13:  lsr     a
        bcc     LFF1F
        rol     a
        cpx     #$21
        bne     LFF0E
        lda     #$1B
        bne     LFF40
LFF1F:  jsr     LFDC8
        tya
        sta     $0213
        asl     a
        asl     a
        asl     a
        sec
        sbc     $0213
        sta     $0213
        txa
        lsr     a
        jsr     LFDC8
        bne     LFF66
        clc
        tya
        adc     $0213
        tay
        lda     $FDCF,y
LFF40:  cmp     $0215
        bne     LFF6B
        dec     $0214
        beq     LFF75
        ldy     #$05
LFF4C:  ldx     #$C8
LFF4E:  dex
        bne     LFF4E
        dey
        bne     LFF4C
        beq     LFF04
LFF56:  cmp     #$01
        beq     LFF8F
        ldy     #$00
        cmp     #$02
        beq     LFFA7
        ldy     #$C0
        cmp     #$20
        beq     LFFA7
LFF66:  lda     #$00
        sta     $0216
LFF6B:  sta     $0215
        lda     #$02
        sta     $0214
        bne     LFF04
LFF75:  ldx     #$96
        cmp     $0216
        bne     LFF7E
        ldx     #$14
LFF7E:  stx     $0214
        sta     $0216
        lda     #$01
        jsr     LFCBE
        jsr     LFCCF
LFF8C:  lsr     a
        bcc     LFFC2
LFF8F:  tax
        and     #$03
        beq     LFF9F
        ldy     #$10
        lda     $0215
        bpl     LFFA7
        ldy     #$F0
        bne     LFFA7
LFF9F:  ldy     #$00
        cpx     #$20
        bne     LFFA7
        ldy     #$C0
LFFA7:  lda     $0215
        and     #$7F
        cmp     #$20
        beq     LFFB7
        sty     $0213
        clc
        adc     $0213
LFFB7:  sta     $0213
        pla
        tay
        pla
        tax
        lda     $0213
        rts
LFFC2:  bne     LFF56
        ldy     #$20
        bne     LFFA7
        ldy     #$08
LFFCA:  dey
        asl     a
        bcc     LFFCA
        rts
        bne     LFF8C
        .byte   $2F
        jsr     L415A
        eor     ($2C),y
        eor     $424E
        lsr     $43,x
        cli
        .byte   $4B
        lsr     a
        pha
        .byte   $47
        lsr     $44
        .byte   $53
        eor     #$55
        eor     $5254,y
        eor     $57
        brk
        brk
        ora     $4F0A
        jmp     L002E
        .byte   $FF
        and     $30BA
        lda     $B7B8,y
        ldx     $B5,y
        ldy     $B3,x
        .byte   $B2
        .byte   $B1
