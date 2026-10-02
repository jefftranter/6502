; Reverse engineered source code for ProDOS 8 bitsy.boot program.
; From ProDOS 2.4.3.
; See https://prodos8.com/bitsy-boot/

ESC     =      $9B      ; Escape character

MLI     =      $BF00    ; ProDOS system call
DEVNUM  =      $BF30
KBD     =      $C000
CLR80VID =     $C00C
INIT    =      $FB2F
SETKBD  =      $FE89
SETVID  =      $FE93

        .org    $2000           ; Standard start address for ProDOS system programs
        sta     CLR80VID        ; Turn off 80-column mode
        sta     KBD             ; Turn off 80STORE feature
        jsr     SETVID
        jsr     SETKBD
        jsr     INIT
        jsr     L20C8
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
        cmp     #ESC
        beq     $209B
        cmp     #$8D
        beq     $208F
        cmp     #$A0
        bne     $2073
        jsr     L20C8
        and     #$07
        beq     $2073
        ora     #$C0
        sta     $20A0
        jsr     $FC58
        jsr     MLI
        adc     $A4
        jsr     $C904
        .byte   ESC
        beq     $20AF
        and     #$DF
        cmp     #$D1
        bne     $2070
        bit     $C061
        bpl     $2070
        .byte   'B'+$80
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
L20C8:  lda     DEVNUM
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        rts

        .byte   $AD
        .byte   $16
        .byte   $29
        .byte   $C2
        .byte   $C9
        .byte   $D4
        .byte   $D3
        .byte   $D9
        .byte   $A0
        .byte   $C2
        .byte   $CF
        .byte   $CF
        .byte   $D4
        .byte   $04
        .byte   $23
        .byte   $B1
        .byte   $AE
        .byte   $B0
        .byte   $15
        .byte   $28
        .byte   $C2
        .byte   $D9
        .byte   $09
        .byte   $1F
        .byte   $CA
        .byte   $CF
        .byte   $C8
        .byte   $CE
        .byte   $0F
        .byte   $20
        .byte   $C2
        .byte   $D2
        .byte   $CF
        .byte   $CF
        .byte   $CB
        .byte   $D3
        .byte   $12
        .byte   $21
        .byte   $C1
        .byte   $C3
        .byte   $D4
        .byte   $C9
        .byte   $D6
        .byte   $C5
        .byte   $A0
        .byte   $A0
        .byte   $D3
        .byte   $CC
        .byte   $CF
        .byte   $D4
        .byte   $D3
        .byte   $04
        .byte   $10
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   08
        .byte   $10
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $A0
        .byte   $AE
        .byte   $0A
        .byte   $10
        .byte   $B1
        .byte   $AD
        .byte   $B7
        .byte   $BA
        .byte   $C2
        .byte   $CF
        .byte   $CF
        .byte   $D4
        .byte   $A0
        .byte   $C1
        .byte   $A0
        .byte   $D3
        .byte   $CC
        .byte   $CF
        .byte   $D4
        .byte   $0F
        .byte   $11
        .byte   $D2
        .byte   $C5
        .byte   $D4
        .byte   $BA
        .byte   $C2
        .byte   $CF
        .byte   $CF
        .byte   $D4
        .byte   $A0
        .byte   $D3
        .byte   $CC
        .byte   $CF
        .byte   $D4
        .byte   $A0
        .byte   $CE
        .byte   $12
        .byte   $11
        .byte   $C5
        .byte   $D3
        .byte   $C3
        .byte   $BA
        .byte   $D1
        .byte   $D5
        .byte   $C9
        .byte   $D4
        .byte   $A0
        .byte   $D4
        .byte   $CF
        .byte   $A0
        .byte   $D0
        .byte   $D2
        .byte   $CF
        .byte   $C4
        .byte   $CF
        .byte   $D3
        .byte   $17
        .byte   $12
        .byte   $CF
        .byte   $C1
        .byte   $AD
        .byte   $D1
        .byte   $BA
        .byte   $D1
        .byte   $D5
        .byte   $C9
        .byte   $D4
        .byte   $A0
        .byte   $D4
        .byte   $CF
        .byte   $A0
        .byte   $C7
        .byte   $D3
        .byte   $AF
        .byte   $CF
        .byte   $D3
        .byte   $17
        .byte   $28
