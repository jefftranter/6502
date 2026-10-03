; Reverse engineered source code for ProDOS 8 bitsy.boot program.
; From ProDOS 2.4.3.
; See https://prodos8.com/bitsy-boot/

ESC     =      $9B      ; Escape character
CR      =      $8D      ; Carriage Return

QUIT    =      $65      ; MLI QUIT call

BASL    =      $28
BASH    =      $29
TEXT    =      $0400    ; Text screen address
MLI     =      $BF00    ; ProDOS system call
DEVNUM  =      $BF30
DEVCNT  =      $BF31
DEVLST  =      $BF32
KBD     =      $C000
KBDSTRB =      $C010
CLR80VID =     $C00C
PB0     =      $C061    ; Open Apple key
INIT    =      $FB2F
BASCALC =      $FBC1
BELL    =      $FBDD
HOME    =      $FC58
RDKEY   =      $FD0C
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
        sta     L2142
        ldy     DEVCNT
L201C:  lda     DEVLST,y
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
        jsr     HOME
        ldx     #$9D
L203E:  lda     L20CF,x
        bmi     L204A
        jsr     BASCALC
        ldy     L20D0,x
        .byte   $2C             ; BIT instruction skip trick
L204A:  sta     (BASL),Y
        dey
        dex
        bne     L203E
L2050:  sta     TEXT,y
        sta     (BASL),y
        dey
        bpl     L2050
        ldx     #$15
L205A:  txa
        jsr     BASCALC
        ldy     #$14
        lda     #$A1
        sta     (BASL),y
        dex
        bne     L205A
        lda     #$10
        sta     BASH
        sta     KBDSTRB
        bne     L2073
L2070:  jsr     BELL
L2073:  jsr     RDKEY
        bit     PB0
        bmi     L20A5
        cmp     #'8'+$80
        bcs     L20A5
        cmp     #'1'+$80
        bcs     L2092
        cmp     #ESC
        beq     L209B
        cmp     #CR
        beq     L208F
        cmp     #$A0
        bne     L2073
L208F:  jsr     L20C8
L2092:  and     #$07
        beq     L2073
        ora     #$C0
        sta     L209E+2         ; Change address to call below?
L209B:  jsr     HOME
L209E:  jsr     MLI
        .byte   QUIT            ; Parameter block
        .word   $20A4
        .byte   $04

L20A5:  cmp     #ESC
        beq     L20AF
        and     #$DF
        cmp     #$D1
        bne     L2070
L20AF:  bit     PB0
        bpl     L2070

        .byte   'B'+$80
        .byte   $80
        .byte   $30
        .byte   '8'+$80
        .byte   '/'+$80
        .byte   '='+$80
        .byte   $00
        .byte   'a'+$80
        .byte   $3A
        .byte   'P'+$80
        .byte   '1'+$80
        .byte   $18
        .byte   $FB
        .byte   '-'+$80
        .byte   $8B
        .byte   '@'+$80
        .byte   $5C
        .byte   $00

        bne     $20A8
L20C8:  lda     DEVNUM
        lsr     a
        lsr     a
        lsr     a
        lsr     a
L20CF:  rts

L20D0:  .byte   '-'+$80
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
L2142:  .byte   'N'+$80
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
