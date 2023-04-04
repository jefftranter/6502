;
;   kimath routines -- 6502 assembler source code for MOS Technology
;                   floating point package.
;
;
;       .title KIMATH ROUTINES, MOS Technology
len = 17
xy  = $01
xz  = $02
xm  = $03
xn  = $04
yx  = $10
yz  = $12
ym  = $13
yn  = $14
zx  = $20
zy  = $21
zm  = $23
zn  = $24
mx  = $30
my  = $31
mz  = $32
mn  = $34
nx  = $40
ny  = $41
nz  = $42
nm  = $43
    .org $0
n       .res 1
nkon    .res 1
j       .res 1
cnt     .res 1
length  = *
cnta    .res 1
deg     .res 1
argxl   .res 1
argxh   .res 1
argyl   .res 1
argyh   .res 1
res     .res 2
ptr     .res 2
kon     .res 1
konl    = kon
konh    .res 1
prec    .res 1
extra   .res 1
temp    .res 1
temp1   .res 1
overr   .res 1
tmpx    .res 1
tmpy    .res 1
    .org $200
ra      .res len+1
rb      .res len+1
rq      .res len
rx      .res len
sx      = rx
ex      .res 1
ry      .res len
sy      = ry
ey      .res 1
rz      .res len
sz      = rz
ez      .res 1
rm      .res len+1
rn      .res len+1
ramcod  .res 3
rama    .res 3
ramb    .res 5
    .org $f800
;
;   Floating point add/subtract routine.
;
sub     lda sy
        eor #$80
        sta sy
add     lda sx
        eor sy
        sta temp
        sed
;
;   Clear working storage.
;
        jsr clear
;
;   Test rx for zero.
;
        jsr xztst
;
;   Test ry for zero.
;
        beq add2
        jsr yztst
        beq add3
        bit temp
        bvc add6
;
;   If the signs of the exponents
;   differ then swap rx and ry.
;
add1    bit sx
        bvc add3
add2    jsr xsy
add3    sed
        bit temp
        bvs add31
        jmp add9
add31   lda ex
        clc
        adc ey
        bcs add5
add4    sta cnt
;
;   Compute the hex value of the
;   bcd difference of the exponents.
;
        jsr dechex
        cmp n
        bcs add5
;
;   Move ry to rb.
;
        jsr rbery
;
;   Align decimal points.
;
        jsr rsbcnt
;
;   Round rb off.
;
        jsr rboff
add5    lda ex
        sta ez
;
;   Move rx to ra.
;
        jsr raerx
        bit temp
        bmi add13
;
;   Add rb to ra.
;
        jsr raprb
        lda ra
        beq add120
        jsr rsra
;
;   Correct sign and exponent
;
        lda ex
        sec
        bit sx
        bvc add110
        sbc #1
        sta ez
        bne add120
        lda #$bf
        and sx
        jmp add12
add120  lda sx
add12   sta sz
;
;   Move ra to rz.
;
add121  jsr rzera
        rts
add110  adc #0
        sta ez
        bcc add120
;
;   Set rz = 9.9...9e99
;
        jsr infin
        rts
;
;   Compare abs(rx) to abs(ry)
;
add6    jsr compxy
        lda cnta
        beq add8
;
;   Swap rx and ry,
;   so that rx has the
;   largest abs. value.
;
add7    jsr xsy
add8    lda ex
        cmp ey
        beq add81
        bcc add7
        jmp add1
add81   jmp add3
;
;   Compute the absolute value
;   of the signed difference of
;   the exponents.
;
add9    sec
        bit sx
        bvs add10
        lda ex
        sbc ey
        jmp add4
add10   lda ey
        sbc ex
        jmp add4
;
;   Subtract rb from ra.
;
add13   jsr ramrb
        lda ex
        sta ez
        lda sx
        sta sz
;
;   Test ra for zero.
;
        jsr aztst
        beq add18
add15   lda ra+1
        bne add121
;
;   If ra+1 is zero then
;   left shift ra one digit.
;
        jsr lsra
add17   bit sz
        sec
        lda ez
        bvc add20
        adc #0
        sta ez
        bcc add15
;
;   Set rz equal to zero.
;
add18   jsr clrz
add19   rts
;
;   Adjust sign and exponent
;   of the answer.
;
add20   sbc #1
        sta ez

        bcs add15
        lda #1
        sta ez
        lda #$40
        ora sz
        sta sz
        jmp add15
;
;   Floating point product routine.
;
mltply  sed
;
;   Clear working storage.
;
        jsr clear
        lda #0
        sta cnt
        sta temp1
;
;   Test ra for zero.
;
        jsr xztst
        beq mult1
;
;   Test ry for zero.
;
        jsr yztst
        bne mult3
;
;   Set rz equal to zero.
;
mult1   jsr clrz
        rts
;
;   Move ra to rz
;
mult2   jsr rzera
        rts
;
;   Move ry to rb.
;
mult3   jsr rbery
;
;   Move rx to rq.
;
        jsr rqerx
;
;   Form product of mantissas
;
        jsr mlt
;
;   Figure the sign and exponent of
;   of the answer for the multiply
;   and divide routines.
;
mult4   lda sy
        eor sx
        sta temp
        bit temp
        lda ex
        bvs md100
md1     clc
        adc ey
        bcc md2
        bne md59
        lda temp1
        beq mdov2
        bit sx
        bvs md7
        lda cnta
        beq md61
        lda #0
        sta cnta
mdov1   lda #$99
        jmp md2
md100   jmp md10
mdov2   bit sx
        bvc md61
        lda ra
        beq mdov1
        jsr rsra
        jmp mdov1
md2     sta ez
        bne md11
        lda sx
        and #$bf
md3     sta sz
md4     lda temp
        bmi md8
        lda #$7f
        and sz
md5     sta sz
        lda temp1
        bne divext
        lda ra
        beq md51
        jsr rsra
        lda ez
        bit sz
        bvs md9
        clc
        adc #1
        beq md6
        sta ez
md51    jmp mult2
md59    lda sx
        sta sz
md6     bit sz
        bvs md7
md61    jsr infin
        rts
md7     jsr clrz
        rts
md8     lda #$80
        ora sz
        jmp md5
md10    sec
        sbc ey
        bcs md2
        sec
        lda ey
        sbc ex
        sta ez
        lda sy
        jmp md3
md11    lda sx
        jmp md3
divext  lda cnta
        beq md51
dvext0  bit sz
        lda ez
        sec
        bvc dvext2
        adc #0
        beq md6
dvext1  sta ez
        jmp mult2
dvext2  beq dvext3
        sbc #1
        jmp dvext1
dvext3  lda sz
        ora #$40
        sta sz
        jmp dvext0
md9     sec
        sbc #1
        beq md22
        sta ez
        jmp mult2
md22    jmp md2
;
;   Floating point divide routine
;
divide  sed
;
;   Test ry for zero.
;
        jsr yztst
        beq md61
;
;   Test rx for zero.
;
        jsr xztst
        beq md7
;
;   Clear working storage.
;
        jsr clear
;
;   Move rx to ra.
;
        jsr raerx
;
;   move ry to rb.
;
        jsr rbery
;
;   Compare rx to ry
;
        jsr compxy
;
;   Form quotient.
;
        jsr div
;
;   Compute sign and exponent of answer.
;
div6    lda #1
        sta temp1
        lda sy
        eor #$40
        sta sy
        jsr raerq
        lda ra+1
        bne div7
        jsr lsra
div7    jsr mult4
        lda sy
        eor #$40
        sta sy
        rts
;
;   This routine computes the
;   product of the mantissas
;   of the arguments by repeated
;   addition. The result is built
;   in ra.
;
mlt     lda n
        sta j
        dec j
mlt0    ldx j
        lda rq,x
        sta cnt
mlt1    dec cnt
        bmi mlt2
        jsr raprb
        jmp mlt1
mlt2    jsr rsra
        dec j
        bpl mlt0
        jsr lsra
        rts
;
;   This routine computes the
;   quotient of ra and rb by
;   repeated subtraction. The
;   result is built in rq.
;
div     lda #0
        sta j
div0    lda #0
        sta cnt
div1    jsr ramrb
        bcc div2
        inc cnt
        bne div1
div2    jsr raprb
        jsr lsra
        ldx j
        lda cnt
        sta rq,x
        inc j
        lda j
        cmp n
        beq div0
        bcc div0
        rts
;
;   This routine computes the
;   square root of a floating point
;   number between 1 and 100 by
;   Heron's method.
;
sqrt    lda #7
        sta nkon
        jsr mvxn
        jsr clrz
        lda #7
        sta rz+1
        lda #8
        sta rz+2
        jsr mvzm
sqrt0   jsr mvmy
        jsr mvnx
        jsr divide
        jsr mvzy
        jsr mvmx
        jsr add
        jsr mvzx
        jsr clry
        lda #$40
        sta ry
        lda #5
        sta ry+1
        lda #1
        sta ey
        jsr mltply
        jsr mvzm
        dec nkon
        bpl sqrt0
        rts
;
;   This routine computes the
;   common log of a floating point
;   number between sqrt(.1) and sqrt(10).
;
log     lda #14
        sta n
        jsr setkon
        jsr mvxn
        jsr clry
        lda #1
        sta ry+1
        jsr sub
        jsr mvnx
        jsr clry
        lda #1
        sta ry+1
        jsr mvzn
        jsr add
        jsr mvzy
        jsr mvnx
        jsr divide
        jsr mvzn
        jsr mvzx
        jsr mvzy
        jsr mltply
        lda #4
        sta deg
        lda #0
logend  sta nkon
        jsr poly
        jsr mvny
lgnd0   jsr mvzx
        jsr mltply
chop    lda #0
        ldx #len/2-1
chop0   sta rz+9,x
        dex
        bpl chop0
        rts
;
;   This routine computes the
;   common anti-log of a floating
;   point number between 0 and 1.
;
tenx    lda #12
        sta n
        jsr setkon
        jsr mvxz
        lda #6
        sta deg
        lda #46
        sta nkon
        jsr poly
        jsr mvzy
        jmp lgnd0
;
;   This routine computes the
;   tangent of a floating point number
;   between 0 and pi/4. NOTE: argument is angle*(4/pi): 0 < arg < 1.0
;
tanx    lda #14
        sta n
        jsr setkon
        jsr mvxn
        jsr mvxy
        jsr mltply
        jsr chop
        lda #5
        sta deg
        lda #100
        jmp logend
;
;   This routine computes the
;   arctangent of a floating point number
;   between 0 and 1.
;
atanx   lda #14
        sta n
        jsr setkon
        jsr mvxn
        jsr mvxy
        jsr mltply
        lda #7
        sta deg
        lda #156
        jmp logend
;
;   Left shift ra one digit.
;
lsra    ldx #0
lsra0   lda ra+1,x
        sta ra,x
        inx
        cpx n
        bcc lsra0

        beq lsra0
        lda #0
        sta ra,x
        rts
;
;   Right shift ra one digit.
;
rsra    ldx n
        dex
rsra0   lda ra,x
        sta ra+1,x
        dex
        bpl rsra0
        lda #0
        sta ra
        rts
;
;   Clear working storage.
;
clear   ldx #len*3+1
        lda #0
az0     sta ra,x
        dex
        bpl az0
        rts
;
;   Convert the contents of cnt
;   from bcd to hex and store the
;   result in cnt.
;
dechex  sed
        ldx #0
        sec
dhcnv1  lda cnt
        sbc #$16
        bcc dhcnv2
        sta cnt
        inx
        jmp dhcnv1
dhcnv2  cld
        lda cnt
        cmp #$0a
        bcc dhcnv3
        and #$0f
        adc #$09
dhcnv3  stx cnt
        asl cnt
        asl cnt
        asl cnt
        asl cnt
        ora cnt
        sta cnt
        sed
dhcnve  rts
;
;   Right shift rb cnt times.
;
rsbcnt  lda cnt
        beq rbofe
        ldx n
rsbc    lda rb,x
        sta rb+1,x
        dex
        bpl rsbc
        lda #0
        sta rb
        dec cnt
        bne rsbcnt
        rts
;
;   Round rb off.
;
rboff   ldx n
        lda rb+1,x
        cmp #5
rbof    lda rb,x
        adc #$90
        and #$0f
        sta rb,x
        dex
        bpl rbof
rbofe   rts
;
;   Move ry to rb.
;
rbery   ldx n
        dex
rbry    lda ry+1,x
        sta rb+1,x
        dex
        bpl rbry
        rts
;
;   Move rx to ra.
;
raerx   ldx n
        dex
rarx0   lda rx+1,x
        sta ra+1,x
        dex
        bpl rarx0
rarxe   rts
;
;   Move rx to rq.
;
rqerx   ldx n
        dex
rqrx    lda rx+1,x
        sta rq,x
        dex
        bpl rqrx
        rts
;
;   Move rq to ra.
;
raerq   ldx n
rarq    lda rq,x
        sta ra+1,x
        dex
        bpl rarq
        rts
;
;   Move ra to rz.
;
rzera   ldx n
        dex
rzra0   lda ra+1,x
        sta rz+1,x
        dex
        bpl rzra0
rzrae   rts
;
;   Add rb to ra.
;
raprb   ldx n
        clc
apb     lda ra,x
        adc rb,x
        adc #$90
        and #$0f
        sta ra,x
        dex
        bpl apb
        rts
;
;   Subtract rb from ra.
;
ramrb   ldx n
        sec
amb     lda ra,x
        sbc rb,x
        and #$0f
        sta ra,x
        dex
        bpl amb
        rts
;
;   Compare rx to ry.
;
compxy  lda #0
        sta cnta
        ldx n
        dex
        sec
com1    lda rx+1,x
        sbc ry+1,x
        dex
        bpl com1
        bcc com2
        rts
com2    inc cnta
        rts
;
;   Test ra for zero.
;
aztst   ldx n
        inx
aztst0  lda ra,x
        bne xztst1
        dex
        bpl aztst0
        bmi xztst2
;
;   Test rx for zero.
;
xztst   ldx n
xztst0  lda rx,x
        bne xztst1
        dex
        bpl xztst0
xztst2  lda #0
xztst1  rts
;
;   Test ry for zero.
;
yztst   ldx n
yztst0  lda ry,x
        bne xztst1
        dex
        bne yztst0      ; *** NOTE: Change 'bpl' to 'bne' ***
        beq xztst2      ; *** NOTE: Change 'bmi' to 'beq' ***
;
;   Swap rx and ry.
;
xsy     ldx #len
xsy1    lda rx,x
        ldy ry,x
        sta ry,x
        tya
        sta rx,x
        dex
        bpl xsy1
        rts
;
;   Set rz=9.9...9e99 and overr=1.
;
infin   ldx n
        dex
        lda #9
inf0    sta rz+1,x
        dex
        bpl inf0
        lda #$99
        sta ez
        lda #0
        sta sz
        lda #1
        sta overr
        rts
;
;   The following routines are used
;   to move the contents from one
;   register to another, the names are
;   of the form mvsd, where s stands
;   for source and d for destination.
;
mvxy    lda #xy
        bne mvtr
mvxz    lda #xz
        bne mvtr
mvxm    lda #xm
        bne mvtr
mvxn    lda #xn
        bne mvtr
mvyx    lda #yx
        bne mvtr
mvyz    lda #yz
        bne mvtr
mvym    lda #ym
        bne mvtr
mvyn    lda #yn
        bne mvtr
mvzx    lda #zx
        bne mvtr
mvzy    lda #zy
        bne mvtr
mvzm    lda #zm
        bne mvtr
mvzn    lda #zn
        bne mvtr
mvmx    lda #mx
        bne mvtr
mvmy    lda #my
        bne mvtr
mvmz    lda #mz
        bne mvtr
mvmn    lda #mn
        bne mvtr
mvnx    lda #nx
        bne mvtr
mvny    lda #ny
        bne mvtr
mvnz    lda #nz
        bne mvtr
mvnm    lda #nm
mvtr    pha
        ldx #11
mvtr0   lda movr,x
        sta ramcod,x
        dex
        bpl mvtr0
        pla
        pha
        and #$0f
        tax
        lda tab,x
        sta ramb
        pla
        lsr
        lsr
        lsr
        lsr
        tax
        lda tab,x
        sta rama
        jmp ramcod

tab     .byte $35,$47,$59,$6b,$7d

movr    ldx #len
movr0   lda rx,x
        sta ry,x
        dex
        bpl movr0
        rts
;
;   Set rx equal to zero.
;
clrx    ldx #len
        lda #0
clrx0   sta rx,x
        dex
        bpl clrx0
        rts
;
;   Set ry equal to zero.
;
clry    ldx #len
        lda #0
clry0   sta ry,x
        dex
        bpl clry0
        rts
;
;   Set rz equal to zero.
;
clrz    ldx #len
        lda #0
clrz0   sta rz,x
        dex
        bpl clrz0
        rts
;
;   This routine is used to look up
;   the coefficients of the poly-
;   nomials used in the approximations
;   of the transcendental functions.
;
lookup  jsr clry
        ldx #0
        ldy nkon
        lda (kon),y
        sta sy
lkp0    iny
        lda (kon),y
        cmp #$f0
        bcs lkp1
        pha
        and #$0f
        sta ry+2,x
        pla
        lsr
        lsr
        lsr
        lsr
        sta ry+1,x
        inx
        inx
        jmp lkp0
lkp1    and #$0f
        sta ey
        iny
        sty nkon
        rts
;
;   This routine evaluates polynomials
;   by means of the nested multiplication
;   algorithm.
;
poly    jsr mvzm
        jsr mvzx
        jsr lookup
poly0   jsr mltply
        jsr lookup
        jsr mvzx
        jsr add
        jsr mvmx
        jsr mvzy
        dec deg
        bpl poly0
        rts
;
;   This routine unpacks an argument
;   and stores the result in rz.
;
pgtarg  ldx #0
        ldy #0
        lda (ptr),y
        sta sz
pgtrg0  iny
        cpy length
        beq pgtrg1
        lda (ptr),y
        pha
        and #$0f
        sta rz+2,x
        pla
        lsr
        lsr
        lsr
        lsr
        sta rz+1,x
        inx
        inx
        jmp pgtrg0
pgtrg1  lda (ptr),y
        sta ez
        rts
;
;   This routine unpacks an argument
;   located at (argxl,argxh) and stores
;   the results in rz and rx.
;
ploadx  lda argxl
        sta ptr
        lda argxh
        sta ptr+1
        lda prec
        lsr
        adc #1
        sta length
        jsr clrz
        jsr pgtarg
        jsr mvzx
        rts
;
;   This routine unpacks an argument
;   located at (argyl,argyh) and stores
;   the results in ry and rz.
;
ploady  lda argyl
        sta ptr
        lda argyh
        sta ptr+1
        lda prec
        lsr
        adc #1
        sta length
        jsr clrz
        jsr pgtarg
        jsr mvzy
        rts
;
;   This routine packs the contents
;   of rz into the locations starting
;   with address (res,res+1).
;
pstres  ldx #0
        ldy #0
        lda sz
        sta (res),y
        iny
ptres   lda rz+1,x
        asl
        asl
        asl
        asl
        ora rz+2,x
        sta (res),y
        iny
        inx
        inx
        cpx prec
        bcc ptres
        lda ez
        sta (res),y
        rts
;
;   This routine converts an argument
;   from ASCII format to computational
;   format and stores the result in rz.
;
ugtarg  ldy #0
        lda (ptr),y
        sta sz
ugtar0  iny
        cpy length
        beq ugtar1
        lda (ptr),y
        and #$0f
        sta rz,y
        jmp ugtar0
ugtar1  lda (ptr),y
        asl
        asl
        asl
        asl
        sta ez
        iny
        lda (ptr),y
        and #$0f
        ora ez
        sta ez
        rts
;
;   This routine converts an argument
;   from ASCII format to comp. format.
;   The address of the arg. is found in
;   (argxl,argxh) and the result is stored
;   in rz and rx.
;
uloadx  lda argxl
        sta ptr
        lda argxh
        sta ptr+1
        lda prec
        sta length
        inc length
        jsr clrz
        jsr ugtarg
        jsr mvzx
        rts
;
;   This routine converts an argument
;   from ASCII format to comp. format.
;   The address of the arg. is found in
;   (argyl,argyh) and the result is
;   stored in rz and ry.
;
uloady  lda argyl
        sta ptr
        lda argyh
        sta ptr+1
        lda prec
        sta length
        inc length
        jsr clrz
        jsr ugtarg
        jsr mvzy
        rts
;
;   This routine converts the contents
;   of rz to ASCII format while moving
;   them to the address specified by
;   (res,res+1).
;
ustres  ldy #0
        lda sz
        sta (res),y
ustrs0  iny
        cpy prec
        beq ustrs1
        bcs ustrs2
ustrs1  lda rz,y
        ora #$30
        sta (res),y
        bne ustrs0
ustrs2  nop             ; Bug fix, was iny
        lda ez
        lsr
        lsr
        lsr
        lsr
        ora #$30
        sta (res),y
        iny
        lda ez
        and #$0f
        ora #$30
        sta (res),y
        rts
;
;   This routine computes the
;   internal precision n from
;   prec and extra. The add is
;   a binary add (unsigned).
;
iprec   clc
        lda prec
        adc extra
        sta n
        rts
;
;   Save the processor index registers.
;
savxy   stx tmpx
        sty tmpy
        rts
;
;   Recall the processor index registers.
;
rclxy   ldx tmpx
        ldy tmpy
        rts

kaddr   .word konst
setkon  lda kaddr
        sta kon
        lda kaddr+1
        sta konh
        rts
;
;   These are the coefficients used
;   in the evaluation of the transcendental
;   functions.
konst   .byte $40,$18,$20,$91,$29,$97,$f1
        .byte $40,$55,$34,$27,$38,$70,$f2
        .byte $40,$13,$13,$69,$01,$12,$10,$f1
        .byte $40,$17,$31,$09,$55,$17,$f1
        .byte $40,$28,$95,$51,$13,$02,$67,$f1
        .byte $40,$86,$85,$88,$74,$83,$40,$50,$f1
        .byte $40,$93,$26,$42,$67,$f4
        .byte $40,$25,$54,$91,$79,$60,$f3
        .byte $40,$17,$42,$11,$19,$88,$f2
        .byte $40,$72,$95,$17,$36,$66,$f2
        .byte $40,$25,$43,$93,$57,$48,$40,$f1
        .byte $40,$66,$27,$30,$88,$42,$90,$f1
        .byte $00,$11,$51,$29,$27,$76,$03,$f0
        .byte $00,$10,$f0
        .byte $40,$41,$09,$74,$19,$48,$f4
        .byte $40,$20,$31,$17,$10,$84,$f4
        .byte $40,$27,$97,$43,$35,$03,$70,$f3
        .byte $40,$98,$34,$59,$45,$39,$30,$f3
        .byte $40,$39,$86,$59,$10,$47,$05,$f2
        .byte $40,$16,$14,$89,$77,$76,$17,$40,$f1
        .byte $40,$78,$53,$98,$17,$62,$29,$10,$f1
        .byte $40,$28,$49,$88,$96,$20,$80,$f3
        .byte $c0,$16,$06,$86,$28,$96,$04,$f2
        .byte $40,$42,$69,$15,$19,$27,$11,$f2
        .byte $c0,$75,$04,$29,$45,$38,$89,$f2
        .byte $40,$10,$64,$09,$34,$02,$53,$f1
        .byte $c0,$14,$20,$36,$44,$46,$65,$20,$f1
        .byte $40,$19,$99,$26,$19,$39,$16,$60,$f1
        .byte $c0,$33,$33,$30,$73,$34,$50,$50,$f1
        .byte $40,$99,$99,$99,$98,$47,$65,$70,$f1
    .end
