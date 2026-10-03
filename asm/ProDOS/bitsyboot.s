; Reverse engineered source code for ProDOS 8 bitsy.boot program.
; From ProDOS 2.4.3.
; See https://prodos8.com/bitsy-boot/

ESC     =      $9B      ; Escape character
CR      =      $8D      ; Carriage Return

QUIT    =      $65      ; MLI QUIT call

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
L201C:  lda     $BF32,y
        beq     L2036
        php
        lsr     a
        lsr     a
        lsr     a
        and     #$0E
        tax
        lsr     a
        ora     #'0'+$80
        plp
        bmi     L2033
        sta     L2103,x
        bne     L2036
L2033:  sta     L2112,x
L2036:  dey
        bpl     L201C
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
        cmp     #CR
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
        .byte   QUIT            ; Parameter block
        .word   $20A4
        .byte   $04

        cmp     #ESC
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

        .byte   '-'+$80
        .byte   $16
        .byte   $29
        .byte   'B'+$80
        .byte   'I'+$80
        .byte   'T'+$80
        .byte   'S'+$80
        .byte   'Y'+$80
        .byte   ' '+$80
        .byte   'B'+$80
        .byte   'O'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   $04
        .byte   $23
        .byte   '1'+$80
        .byte   '.'+$80
        .byte   '0'+$80
        .byte   $15
        .byte   $28
        .byte   'B'+$80
        .byte   'Y'+$80
        .byte   $09
        .byte   $1F
        .byte   'J'+$80
        .byte   'O'+$80
        .byte   'H'+$80
        .byte   'N'+$80
        .byte   $0F
        .byte   $20
        .byte   'B'+$80
        .byte   'R'+$80
        .byte   'O'+$80
        .byte   'O'+$80
        .byte   'K'+$80
        .byte   'S'+$80
        .byte   $12
        .byte   $21
        .byte   'A'+$80
        .byte   'C'+$80
        .byte   'T'+$80
        .byte   'I'+$80
        .byte   'V'+$80
        .byte   'E'+$80
        .byte   ' '+$80
        .byte   ' '+$80
        .byte   'S'+$80
        .byte   'L'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   'S'+$80
L2103:  .byte   $04
        .byte   $10
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
L2112:  .byte   $08
        .byte   $10
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   $0A
        .byte   $10
        .byte   '1'+$80
        .byte   '-'+$80
        .byte   '7'+$80
        .byte   ':'+$80
        .byte   'B'+$80
        .byte   'O'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   ' '+$80
        .byte   'A'+$80
        .byte   ' '+$80
        .byte   'S'+$80
        .byte   'L'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   $0F
        .byte   $11
        .byte   'R'+$80
        .byte   'E'+$80
        .byte   'T'+$80
        .byte   ':'+$80
        .byte   'B'+$80
        .byte   'O'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   ' '+$80
        .byte   'S'+$80
        .byte   'L'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   ' '+$80
        .byte   'N'+$80
        .byte   $12
        .byte   $11
        .byte   'E'+$80
        .byte   'S'+$80
        .byte   'C'+$80
        .byte   ':'+$80
        .byte   'Q'+$80
        .byte   'U'+$80
        .byte   'I'+$80
        .byte   'T'+$80
        .byte   ' '+$80
        .byte   'T'+$80
        .byte   'O'+$80
        .byte   ' '+$80
        .byte   'P'+$80
        .byte   'R'+$80
        .byte   'O'+$80
        .byte   'D'+$80
        .byte   'O'+$80
        .byte   'S'+$80
        .byte   $17
        .byte   $12
        .byte   'O'+$80
        .byte   'A'+$80
        .byte   '-'+$80
        .byte   'Q'+$80
        .byte   ':'+$80
        .byte   'Q'+$80
        .byte   'U'+$80
        .byte   'I'+$80
        .byte   'T'+$80
        .byte   ' '+$80
        .byte   'T'+$80
        .byte   'O'+$80
        .byte   ' '+$80
        .byte   'G'+$80
        .byte   'S'+$80
        .byte   '/'+$80
        .byte   'O'+$80
        .byte   'S'+$80
        .byte   $17
        .byte   $28
