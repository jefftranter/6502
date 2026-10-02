; Reverse engineered source code for ProDOS 8 bitsy.boot program.
; From ProDOS 2.4.3.
; See https://prodos8.com/bitsy-boot/

        .org    $2000   ; Standard start address for ProDOS system programs
        sta     $C00C
        sta     $C000
        jsr     $FE93
        jsr     $FE89
        jsr     $FB2F
        jsr     $20C8
        and     #$07
        ora     #$B0
        sta     $2142
        ldy     $BF31
        lda     $BF32,y
        beq     $2036
        php
        lsr     a
        lsr     a
        lsr     a
        and     #$0E
        tax
        lsr     a
        ora     #$B0
        plp
        bmi     $2033
        sta     $2103,x
        bne     $2036
        sta     $2112,x
        dey
        bpl     $201C
        jsr     $FC58
        ldx     #$9D
        lda     $20CF,x
        bmi     $204A
        jsr     $FBC1
        ldy     $20D0,x
        bit     $2891
        dey
        dex
        bne     $203E
        sta     $0400,y
        sta     ($28),y
        dey
        bpl     $2050
        ldx     #$15
        txa
        jsr     $FBC1
        ldy     #$14
        lda     #$A1
        sta     ($28),y
        dex
        bne     $205A
        lda     #$10
        sta     $29
        sta     $C010
        bne     $2073
        jsr     $FBDD
        jsr     $FD0C
        bit     $C061
        bmi     $20A5
        cmp     #$B8
        bcs     $20A5
        cmp     #$B1
        bcs     $2092
        cmp     #$9B
        beq     $209B
        cmp     #$8D
        beq     $208F
        cmp     #$A0
        bne     $2073
        jsr     $20C8
        and     #$07
        beq     $2073
        ora     #$C0
        sta     $20A0
        jsr     $FC58
        jsr     $BF00
        adc     $A4
        jsr     $C904
        .byte   $9B
        beq     $20AF
        and     #$DF
        cmp     #$D1
        bne     $2070
        bit     $C061
        bpl     $2070
        .byte   $C2
        .byte   $80
        bmi     $2070
        .byte   $AF
        lda     $E100,x
        .byte   $3A
        bne     $2070
        clc
        .byte   $FB
        lda     $C08B
        .byte   '\'
        brk
        bne     $20A8
        lda     $BF30
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        rts
        lda     $2916
        .byte   $C2
        cmp     #$D4
        .byte   $D3
        cmp     $C2A0,y
        .byte   $CF
        .byte   $CF
        .byte   $D4
        .byte   $04
        .byte   $23
        lda     ($AE),y
        bcs     $20F8
        plp
        .byte   $C2
        cmp     $1F09,y
        dex
        .byte   $CF
        iny
        dec     $200F
        .byte   $C2
        .byte   $D2
        .byte   $CF
        .byte   $CF
        .byte   $CB
        .byte   $D3
        .byte   $12
        and     ($C1,x)
        .byte   $C3
        .byte   $D4
        cmp     #$D6
        cmp     $A0
        ldy     #$D3
        cpy     $D4CF
        .byte   $D3
        .byte   $04
        bpl     $20B4
        ldy     #$AE
        ldy     #$AE
        ldy     #$AE
        ldy     #$AE
        ldy     #$AE
        ldy     #$AE
        php
        bpl     $20C3
        ldy     #$AE
        ldy     #$AE
        ldy     #$AE
        ldy     #$AE
        ldy     #$AE
        ldy     #$AE
        asl     a
        bpl     $20D5
        lda     $BAB7
        .byte   $C2
        .byte   $CF
        .byte   $CF
        .byte   $D4
        ldy     #$C1
        ldy     #$D3
        cpy     $D4CF
        .byte   $0F
        ora     ($D2),y
        cmp     $D4
        tsx
        .byte   $C2
        .byte   $CF
        .byte   $CF
        .byte   $D4
        ldy     #$D3
        cpy     $D4CF
        ldy     #$CE
        .byte   $12
        ora     ($C5),y
        .byte   $D3
        .byte   $C3
        tsx
        cmp     ($D5),y
        cmp     #$D4
        ldy     #$D4
        .byte   $CF
        ldy     #$D0
        .byte   $D2
        .byte   $CF
        cpy     $CF
        .byte   $D3
        .byte   $17
        .byte   $12
        .byte   $CF
        cmp     ($AD,x)
        cmp     ($BA),y
        cmp     ($D5),y
        cmp     #$D4
        ldy     #$D4
        .byte   $CF
        ldy     #$C7
        .byte   $D3
        .byte   $AF
        .byte   $CF
        .byte   $D3
        .byte   $17
        plp
