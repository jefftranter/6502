 .setcpu "65c02"
 .org   $C000

; Set to the version of Apple //c ROM you want to build. Typically
; done on the command line.
;ROMVER = 255
;ROMVER = 0
;ROMVER = 3
;ROMVER = 4

.if ROMVER = 255
.elseif ROMVER = 0
.elseif ROMVER = 3
.elseif ROMVER = 4
.else
.error "ROMVER not set correctly."
.endif

; This file is not part of the version 255 ROM.
 .if .not ROMVER = 255

 .res 256

 lda    #$0E
 .byte  $1C
 .byte  $7F
 .byte  $07
 sec
 lda    $C019
 bpl    $C136
 sta    $C079
 lda    #$0C
 bit    $07FF
 bne    $C118
 sta    $C05A
 ora    #$02
 sta    $C078
 bit    $067F
 bne    $C124
 lda    #$0C
 bit    $C063
 bpl    $C12B
 eor    #$04
 and    $07FF
 .byte  $0C
 .byte  $7F
 .byte  $07
 .byte  $1C
 .byte  $7F
 asl    $69
 inc    $FFAD,x
 .byte  $07
 bmi    $C1AD
 lda    $C015
 ora    $C017
 bpl    $C1AD
 txa
 ldx    #$00
 bit    $C015
 bmi    $C155
 tya
 eor    #$80
 ldx    #$80
 bit    $C017
 bpl    $C18E
 asl    a
 lda    $047F,x
 bcs    $C175
 cmp    $047D,x
 bne    $C168
 lda    $057F,x
 cmp    $057D,x
 beq    $C18A
 lda    $047F,x
 bne    $C170
 dec    $057F,x
 dec    $047F,x
 bra    $C18A
 cmp    $067D,x
 bne    $C182
 lda    $057F,x
 cmp    $077D,x
 beq    $C18A
 inc    $047F,x
 bne    $C18A
 inc    $057F,x
 cpx    #$00
 beq    $C14B
 sta    $C048
 lda    #$02
 and    $07FF
 beq    $C1A1
 sta    $C079
 sta    $C05B
 sta    $C078
 ora    #$20
 .byte  $0C
 .byte  $7F
 asl    $A9
 asl    $7F2D
 .byte  $07
 adc    #$FE
 bcs    $C1B4
 jmp    $C784
 sec
 rts
 jsr    $C1BA
 jmp    $C784
 ldx    #$C2
 jsr    $C1C2
 bcc    $C1B3
 dex
 ldy    $C142,x
 lda    #$04
 eor    $BFFA,y
 and    #$0C
 beq    $C1B2
 lda    $BFF9,y
 sta    $0438,x
 bpl    $C1B2
 cpx    #$C2
 bcs    $C1DC
 eor    #$40
 bit    $0538,x
 bvs    $C20A
 bpl    $C208
 bcc    $C208
 bit    #$40
 beq    $C20A
 lda    $C000
 ldy    #$80
 jsr    $C228
 cmp    #$98
 bne    $C200
 lda    $C062
 bpl    $C200
 stx    $05FC

.if ROMVER = 255
 stx    $06FF
.elseif ROMVER = 0
 stx    $06FF
.elseif ROMVER = 3
 stx    $06FF
.elseif ROMVER = 4
 stx    $06FC
.endif

 lda    $C010
 ldy    #$B0
 lda    $BFF9,y
 and    #$BF
 asl    a
 asl    a
 and    #$20
 beq    $C24E
 lda    $BFFA,y
 eor    #$01
 and    #$03
 bne    $C24E
 txa
 eor    $04FC
 bne    $C1B2
 php
 jsr    $C322
 bcc    $C24D
 ldy    #$00
 bne    $C231
 phx
 pha
 lda    $057C,y
 tax
 inc    a
 bit    #$7F
 bne    $C235
 tya
 cmp    $067C,y
 beq    $C23D
 sta    $057C,y
 pla
 bit    $C014
 sta    $C005
 sta    $0800,x
 bmi    $C24C
 sta    $C004
 plx
 plp
 rts
 jsr    $C255
 jmp    $C784
 pha
 bit    $C2AB
 beq    $C25E
 inc    $0738,x
 jsr    $C2B2
 and    #$30
 cmp    #$10
 bne    $C25E
 lda    $06B8,x
 bit    #$20
 beq    $C28D
 cpx    $04FC
 beq    $C286
 jsr    $C2E9
 bcc    $C286
 ldy    $C234,x
 sta    $05FE,y
 lda    $06B8,x
 ora    #$04
 sta    $06B8,x
 lda    $06B8,x
 and    #$02
 bne    $C25E
 ldy    $C142,x
 pla
 pha
 sta    $BFF8,y
 bit    $06B8,x
 eor    #$0D
 asl    a
 bne    $C2AA
 bvc    $C2A5
 lda    #$14
 ror    a
 jsr    $C255
 stz    $24
 stz    $0738,x
 pla
 rts
 jsr    $C2B2
 jmp    $C784
 php
 sei
 ldy    $C142,x
 lda    $BFF9,y
 bpl    $C2C1
 jsr    $C1D6
 bra    $C2B4
 plp
 rts
 jsr    $C2C9
 jmp    $C784
 cpx    $04FC
 bne    $C2D5
 ldy    #$00
 jsr    $C2FD
 bcs    $C2F4
 lda    $06B8,x
 bit    #$04
 beq    $C2E9
 and    #$FB
 sta    $06B8,x
 ldy    $C234,x
 lda    $05FE,y
 sec
 rts
 jsr    $C2B2
 and    #$08
 clc
 beq    $C2F4
 jsr    $C322
 rts
 brk
 bra    $C318
 sbc    $4CC2,x
 sty    $C7
 lda    $067C,y
 cmp    $057C,y
 clc
 beq    $C321
 pha
 inc    a
 bit    #$7F
 bne    $C30D
 tya
 sta    $067C,y
 ply
 lda    $C013
 asl    a
 sta    $C003
 lda    $0800,y
 bcs    $C321
 sta    $C002
 sec
 rts
 lda    $BFF8,y
 pha
 ora    #$80
 tay
 lda    $06B8,x
 bit    #$08
 bne    $C334
 cpy    #$8A
 beq    $C346
 bit    #$20
 beq    $C348
 cpy    #$91
 bne    $C340
 and    #$FD
 bra    $C346
 cpy    #$93
 bne    $C348
 ora    #$02
 clc
 bcs    $C381
 sta    $06B8,x
 pla
 rts
 pha
 lda    $C013
 pha
 lda    $C014
 pha
 bcc    $C361
 sta    $C002
 sta    $C005
 bcs    $C367
 sta    $C004
 sta    $C003
 lda    ($3C)
 sta    ($42)
 inc    $42
 bne    $C371
 inc    $43
 lda    $3C
 cmp    $3E
 lda    $3D
 sbc    $3F
 inc    $3C
 bne    $C37F
 inc    $3D
 bcc    $C367
 sta    $C004
 pla
 bpl    $C38A
 sta    $C005
 sta    $C002
 pla
 bpl    $C393
 sta    $C003
 pla
 jmp    $C784
 pha
 lda    $03ED
 pha
 lda    $03EE
 pha
 bcc    $C3AA
 sta    $C003
 sta    $C005
 bcs    $C3B0
 sta    $C002
 sta    $C004
 pla
 sta    $03EE
 pla
 sta    $03ED
 pla
 bvs    $C3C0
 sta    $C008
 bvc    $C3C3
 sta    $C009
 jmp    $C7EB
 stx    $01
 stx    $02
 stx    $03
 ldx    #$04
 stx    $04
 sta    $05
 ldx    #$04
 stz    $01
 inc    $01
 tay
 sta    $C083
 sta    $C083
 lda    $01
 and    #$F0
 cmp    #$C0
 bne    $C3F3
 lda    $C08B
 lda    $C08B
 lda    $01
 adc    #$0F
 bne    $C3F5
 lda    $01
 sta    $03
 tya
 ldy    #$00
 clc
 adc    $C82A,x
 sta    ($02),y
 dex
 bpl    $C405
 ldx    #$04
 iny
 bne    $C3FA
 inc    $01
 bne    $C3D8
 inc    $01
 ldx    #$04
 lda    $05
 tay
 lda    $C083
 lda    $C083
 lda    $01
 and    #$F0
 cmp    #$C0
 bne    $C42A
 lda    $C08B
 lda    $01
 adc    #$0F
 bne    $C42C
 lda    $01
 sta    $03
 tya
 ldy    #$00
 clc
 adc    $C82A,x
 eor    ($02),y
 bne    $C472
 lda    ($02),y
 dex
 bpl    $C440
 ldx    #$04
 iny
 bne    $C431
 inc    $01
 bne    $C412
 ror    a
 bit    $C019
 bpl    $C44F
 eor    #$A5
 dec    $04
 bmi    $C456
 jmp    $C3D0
 tax
 bit    $C013
 bmi    $C46C
 txa
 sta    $C005
 sta    $C003
 sta    $C009
 sta    $C081
 jmp    $D497
 sta    $C008
 jmp    $C4EF
 sec
 tax
 lda    $C013
 clv
 bpl    $C47D
 bit    $C82A
 lda    #$A0
 ldy    #$06
 sta    $BFFE,y
 sta    $C006,y
 dey
 dey
 bne    $C481
 sta    $C051
 sta    $C054
 sta    $0400,y
 sta    $0500,y
 sta    $0600,y
 sta    $0700,y
 iny
 bne    $C491
 txa
 beq    $C4CA
 ldy    #$03
 bcs    $C4A9
 ldy    #$05
 lda    #$AA
 bvc    $C4B0
 sta    $05B0
 lda    $C866,y
 sta    $05B1,y
 dey
 bpl    $C4B0
 ldy    #$10
 txa
 lsr    a
 tax
 lda    #$58
 rol    a
 sta    $05B6,y
 dey
 dey
 bne    $C4BB
 beq    $C4C8
 ldx    #$02
 ply
 php
 lda    $C86C,x
 plp
 php
 bcc    $C4D8
 lda    $C86F,x
 cpy    #$06
 bcc    $C4E7
 cpy    #$08
 bcc    $C4E4
 cpy    #$11
 bcc    $C4E7
 lda    $C872,x
 sta    $05B8,x
 dex
 bpl    $C4CE
 bmi    $C4ED
 ldy    #$01
 lda    #$7F
 ror    a
 ldx    $C82F,y
 beq    $C508
 bcc    $C4FE
 ldx    $C841,y
 sta    $BFFF,x
 iny
 bne    $C4F3
 ldx    $C030
 rol    a
 dey
 ldx    $C853,y
 beq    $C521
 bmi    $C504
 rol    a
 bcc    $C51A
 asl    $C000,x
 bcc    $C537
 bcs    $C508
 asl    $C000,x
 bcs    $C537
 bcc    $C508
 rol    a
 iny
 sec
 sbc    #$01
 bcs    $C4F3
 dey
 beq    $C533
 cpy    #$08
 bne    $C53F
 ldy    #$11
 bne    $C4F1
 ldy    #$09
 bne    $C4F1
 phy
 ldx    #$00
 cpy    #$0A
 jmp    $C47D
 lsr    $80
 bne    $C4EF
 lda    #$A0
 ldy    #$00
 sta    $0400,y
 sta    $0500,y
 sta    $0600,y
 sta    $0700,y
 iny
 bne    $C547
 lda    $C061
 and    $C062
 asl    a
 inc    $FF
 lda    $FF
 bcc    $C566
 jmp    $D48E
 lda    $C051
 ldy    #$08
 lda    $C875,y
 sta    $05B8,y
 dey
 bpl    $C56B
 bmi    $C556

 .res   10

 phx
 ldx    $0678
 inc    $C000,x
 plx
 lda    $49
 sta    $BFF8,x
 lda    $4A
 sta    $BFF9,x
 lda    $4B
 and    #$7F
 cmp    $03B8,y
 bcs    $C5EE
 sta    $BFFA,x
 bit    $C014
 php
 sta    $C004
 bit    $4B
 bpl    $C5AC
 sta    $C005
 ldy    #$00
 lda    $48
 sta    $05F8
 beq    $C5C9
 lda    $BFFB,x
 sta    ($45),y
 iny
 lda    $BFFB,x
 sta    ($45),y
 iny
 bne    $C5B5
 inc    $46
 dec    $48
 bne    $C5B5
 lda    $47
 beq    $C5E3
 sta    $0578
 lsr    a
 bcs    $C5D9
 lda    $BFFB,x
 sta    ($45),y
 iny
 lda    $BFFB,x
 sta    ($45),y
 iny
 cpy    $47
 bne    $C5D3
 sta    $C004
 plp
 bpl    $C5EC
 sta    $C005
 bra    $C5F3
 lda    #$2D
 sta    $04F8
 sta    $C081
 rts
 phx
 ldx    $0678
 inc    $C000,x
 plx
 lda    $49
 sta    $BFF8,x
 lda    $4A
 sta    $BFF9,x
 lda    $4B
 and    #$7F
 cmp    $03B8,y
 bcs    $C5EE
 sta    $BFFA,x
 bit    $C013
 php
 sta    $C002
 bit    $4B
 bpl    $C623
 sta    $C003
 ldy    #$00
 lda    $48
 sta    $05F8
 beq    $C640
 lda    ($45),y
 sta    $BFFB,x
 iny
 lda    ($45),y
 sta    $BFFB,x
 iny
 bne    $C62C
 inc    $46
 dec    $48
 bne    $C62C
 lda    $47
 sta    $0578
 beq    $C65A
 lsr    a
 bcs    $C650
 lda    ($45),y
 sta    $BFFB,x
 iny
 lda    ($45),y
 sta    $BFFB,x
 iny
 cpy    $47
 bne    $C64A
 sta    $C002
 plp
 bpl    $C663
 sta    $C003
 sta    $C081
 rts
 sed
 brk
 brk
 brk
 .byte  $07
 eor    ($41)
 eor    $4143
 eor    ($44)
 jsr    $2020
 jsr    $2020
 jsr    $2020
 brk
 brk
.if ROMVER = 255
 .byte  $01
.elseif ROMVER = 0
 .byte  $01
.elseif ROMVER = 3
 .byte  $01
.elseif ROMVER = 4
 .byte  $02
.endif
 .byte  $01
 .byte  $03
 .byte  $03
 .byte  $03
 .byte  $03
 .byte  $03
 .byte  $03
 ora    ($01,x)
 .byte  $03
 .byte  $03
 ora    ($01,x)
 ora    ($01,x)
 ora    ($01,x)
 .byte  $04
 .byte  $04
 .byte  $04
 .byte  $04
 .byte  $FF
 .byte  $FF
 .byte  $FF
 .byte  $FF
 .byte  $FF
 .byte  $FF
 .byte  $52
.if ROMVER = 255
 .byte  $73
.elseif ROMVER = 0
 .byte  $73
.elseif ROMVER = 3
 .byte  $73
.elseif ROMVER = 4
 .byte  $7D
.endif
 .byte  $2F
.if ROMVER = 255
 .byte  $B8
.elseif ROMVER = 0
 .byte  $B8
.elseif ROMVER = 3
 .byte  $B8
.elseif ROMVER = 4
 .byte  $C2
.endif
 .byte  $2F
.if ROMVER = 255
 .byte  $BC
.elseif ROMVER = 0
 .byte  $BC
.elseif ROMVER = 3
 .byte  $BC
.elseif ROMVER = 4
 .byte  $C6
.endif
 .byte  $2F
 sec
.if ROMVER = 255
 .byte  $69
 .byte  $69
.elseif ROMVER = 0
 .byte  $69
 .byte  $69
.elseif ROMVER = 3
 .byte  $69
 .byte  $69
.elseif ROMVER = 4
 .byte  $73
 .byte  $73
.endif
 sec
 sec
 .byte  $2F
 .byte  $2F
 .byte  $2F
 .byte  $2F
 .byte  $2F
 and    $3C2F,y
 .byte  $45
.if ROMVER = 255
 .byte  $9D
.elseif ROMVER = 0
 .byte  $9D
.elseif ROMVER = 3
 .byte  $9D
.elseif ROMVER = 4
 .byte  $A7
.endif
 .byte  $AB
 sec
 .byte  $3F
 .byte  'B'
 phx
 jsr    $C816
 phy
 sty    $0678
 jsr    $D8F9
 jmp    $C80E
 phx
 jsr    $C816
 phy
 jsr    $D621
 jmp    $C80E
 phx
 jsr    $C816
 phy
 jsr    $D6C2
 jmp    $C80E
 phx
 jsr    $C816
 phy
 jsr    $D679
 jmp    $C80E
 phx
 jsr    $C816
 phy
 jsr    $D668
 jmp    $C80E
 phx
 jsr    $C816
 phy
 jsr    $D6A3
 jmp    $C80E
 phx
 jsr    $C816
 phy
 jsr    $D651
 jmp    $C80E
 phx
 jsr    $C816
 phy
 jsr    $D600
 jmp    $C80E

 .res   13

 sta    $C028
 jmp    $C6C2
 sta    $C028
 jmp    $C6CD
 sta    $C028
 jmp    $C6D8
 sta    $C028
 jmp    $C6E3
 sta    $C028
 jmp    $C6EE
 sta    $C028
 jmp    $C6F9
 sta    $C028
 jmp    $C704
 sta    $C028
 jmp    $CF9A
 sta    $C028
 jmp    $C6B4
 sta    $C028
 phx
 jsr    $C816
 phy
 sty    $0678
 jsr    $D800
 jmp    $C80E

 .res   29

 sta    $C028
 rti
 sta    $C028
 rts
 sta    $C028
 jmp    $FA62
 sta    $C028
 bit    $C787
 jmp    $C804
 sta    $C028
 jmp    $C880
 sta    $C028
 jmp    $D400
 sta    $C028
 jmp    $C7F1
 sta    $C028
 jmp    $C806
 sta    $C028
 jmp    $C34E
 sta    $C028
 jmp    $C397
 sta    $C028
 jmp    $C100
 sta    $C028
 jmp    $D48E
 sta    $C028
 jmp    $C580
 sta    $C028
 jmp    $C24F
 sta    $C028
 jmp    $C2AC
 sta    $C028
 jmp    $C2C3
 sta    $C028
 jmp    $C2F7
 sta    $C028
 jmp    $D4C5
 sta    $C028
 jmp    ($03ED)
 phx
 jsr    $C816
 phy
 jsr    $D1A0
 bra    $C80E

 .res   8

 jmp    $C78E
 phx
 jsr    $C816
 phy
 jsr    $D000
 plx
 inc    $C000,x
 plx
 jmp    $C784
 ldy    #$81
 bit    $C012
 bpl    $C829
 ldy    #$8B
 bit    $C011
 bpl    $C826
 ldy    #$83
 sta    $C081
 rts
 .byte  'S'
 .byte  'C'
 .byte  $2B
 and    #$07
 brk
 bit    #$03
 ora    $09
 ora    ($7F,x)
 .byte  '_'
 brk
 .byte  $83
 eor    ($53),y
 eor    $57,x
 .byte  $0F
 ora    $8000
 brk
 sta    ($04,x)
 asl    $0A
 .byte  $02
 .byte  $7F
 rts
 brk
 sty    $52
 .byte  'T'
 lsr    $58,x
 bpl    $C85F
 brk
 .byte  $7F
 brk
 ora    ($13),y
 .byte  $14
 asl    $18,x
 .byte  $FF
 .byte  $7F
 brk
 ora    ($1A)
 .byte  $1B
 .byte  $1C
 ora    $1F1E,x
 brk
 ror    $D200,x
 cmp    ($CD,x)
 ldy    #$DA
 bne    $C83A
 cmp    $C9D5
 .byte  $CF
 cmp    $C7,x
 cpy    $D3D5
 sbc    $F4F3,y
 sbc    $ED
 ldy    #$CF
 .byte  $CB
 brk
 brk
 jmp    $CD4C
 jsr    $CB61
 jsr    $CA7D
 ldy    #$07
 jsr    $CC20
 lda    $C08B,x
 lda    $C089,x
 ldy    #$32
 lda    $C08E,x
 bmi    $C8A2
 dey
 bne    $C896
 sec
 jmp    $C9CC
 lda    $C081,x
 ldy    #$05
 lda    #$FF
 sta    $C08F,x
 lda    $C9D3,y
 asl    $C08C,x
 bcc    $C8AF
 sta    $C08D,x
 dey
 bpl    $C8AC
 lda    $5A
 ora    #$80
 jsr    $CA50
 jsr    $CA4E
 lda    $5B
 jsr    $CA50
 jsr    $CA4E
 jsr    $CA4E
 lda    $4C
 ora    #$80
 jsr    $CA50
 lda    $4B
 ora    #$80
 jsr    $CA50
 lda    $4C
 beq    $C8F6
 ldy    #$FF
 lda    $59
 asl    $C08C,x
 bcc    $C8E5
 sta    $C08D,x
 iny
 lda    ($54),y
 ora    #$80
 cpy    $4C
 bcc    $C8E5
 lda    $4B
 bne    $C8FD
 jmp    $C996
 nop
 ldy    #$00
 lda    $41
 sta    $C08D,x
 lda    $4D
 ora    #$80
 sty    $59
 ldy    $C08C,x
 bpl    $C90B
 sta    $C08D,x
 ldy    $59
 lda    ($56),y
 sta    $4D
 asl    a
 rol    $41
 iny
 bne    $C924
 inc    $57
 jmp    $C926
 pha
 pla
 lda    #$02
 ora    $41
 sta    $41
 lda    $4E
 ora    #$80
 sta    $C08D,x
 lda    ($56),y
 sta    $4E
 asl    a
 rol    $41
 iny
 lda    $4F
 ora    #$80
 sta    $C08D,x
 lda    ($56),y
 sta    $4F
 asl    a
 rol    $41
 iny
 lda    $50
 ora    #$80
 sta    $C08D,x
 lda    ($56),y
 sta    $50
 asl    a
 rol    $41
 iny
 bne    $C960
 inc    $57
 jmp    $C962
 pha
 pla
 lda    $51
 ora    #$80
 sta    $C08D,x
 lda    ($56),y
 sta    $51
 asl    a
 rol    $41
 iny
 lda    $52
 ora    #$80
 sta    $C08D,x
 lda    ($56),y
 sta    $52
 asl    a
 rol    $41
 iny
 lda    $53
 ora    #$80
 sta    $C08D,x
 lda    ($56),y
 sta    $53
 asl    a
 rol    $41
 iny
 dec    $4B
 beq    $C996
 jmp    $C900
 lda    $40
 ora    #$AA
 ldy    $C08C,x
 bpl    $C99A
 sta    $C08D,x
 lda    $40
 lsr    a
 ora    #$AA
 jsr    $CA50
 lda    #$C8
 jsr    $CA50
 lda    $C08C,x
 and    #$40
 bne    $C9AF
 sta    $C08D,x
 ldy    #$0A
 dey
 bne    $C9C6
 lda    #$01
 jsr    $CA97
 sec
 bcs    $C9CC
 lda    $C08E,x
 bmi    $C9BB
 clc
 lda    $C080,x
 lda    $C08C,x
 rts
 .byte  $C3
 .byte  $FF
 .byte  $FC
 .byte  $F3
 .byte  $CF
 .byte  $3F
 jsr    $C9DE
 nop
 nop
 nop
 rts
 jmp    $C9C0
 lda    #$00
 sta    $40
 lda    $54
 sta    $56
 lda    $55
 sta    $57
 jsr    $CA7D
 lda    $C08D,x
 lda    $C08E,x
 bpl    $C9F5
 lda    $C081,x
 ldy    #$1E
 lda    $C08C,x
 bpl    $C9FF
 dey
 bmi    $C9E0
 cmp    #$C3
 bne    $C9FF
 ldy    #$06
 lda    $C08C,x
 bpl    $CA0D
 and    #$7F
 sta    $004B,y
 eor    #$80
 eor    $40
 sta    $40
 dey
 bpl    $CA0D
 lda    $4C
 beq    $CA4B
 clc
 adc    $54
 sta    $56
 lda    $55
 adc    #$00
 sta    $57
 ldy    #$00
 lda    $C08C,x
 bpl    $CA31
 asl    a
 sta    $41
 lda    $C08C,x
 bpl    $CA39
 asl    $41
 bcs    $CA44
 eor    #$80
 sta    ($54),y
 iny
 cpy    $4C
 bcc    $CA39
 jmp    $CC73
 lda    #$80
 ldy    $C08C,x
 bpl    $CA50
 sta    $C08D,x
 eor    $40
 sta    $40
 rts
 jsr    $CA87
 lda    $C081,x
 lda    $C085,x
 ldy    #$50
 jsr    $CA70
 jsr    $CA87
 ldy    #$0A
 jsr    $CA77
 dey
 bne    $CA70
 rts
 ldx    #$C8
 dex
 bne    $CA79
 rts
 jsr    $CA97
 lda    $C083,x
 lda    $C087,x
 rts
 jsr    $CA97
 lda    $C080,x
 lda    $C082,x
 lda    $C084,x
 lda    $C086,x
 rts
 ldx    #$60
 rts
 bra    $CA1C
 bra    $CA1E
 bra    $CA20
 bra    $CA22
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 bra    $CA2C
 bra    $CA2E
 brk
 brk
 brk
 brk
 bra    $CA34
 bra    $CA36
 brk
 brk
 brk
 brk
 bra    $CA3C
 brk
 brk
 bra    $CA40
 brk
 brk
 bra    $CA44
 brk
 brk
 bra    $CA48
 brk
 brk
 bra    $CACC
 bra    $CACE
 bra    $CAD0
 bra    $CAD2
 bra    $CAD4
 bra    $CAD6
 bra    $CAD8
 bra    $CADA
 lda    #$05
 ldy    #$00
 jsr    $CAFD
 bcc    $CAE8
 lda    #$80
 jsr    $CF98
 rts
 jsr    $CAFD
 bcc    $CAE8
 lda    #$80
 jsr    $CF98
 lda    $06F8
 sta    $4D
 lda    $0778
 sta    $4E
 lda    #$B8
 ldy    #$0B
 ldx    $58
 sta    $04F3,x
 tya
 sta    $0573,x
 lda    $4D
 sta    $06F8
 lda    $4E
 sta    $0778
 jsr    $C883
 lda    $06F8
 sta    $4D
 lda    $0778
 sta    $4E
 bcc    $CB2F
 ldx    $58
 dec    $04F3,x
 bne    $CB0A
 dec    $0573,x
 bpl    $CB0A
 rts
 ldy    $58
 lda    #$05
 sta    $04F3,y
 jsr    $C9E3
 bcc    $CB4B
 ldy    #$01
 jsr    $CA70
 jsr    $C9C0
 ldx    $58
 dec    $04F3,x
 bne    $CB37
 rts
 brk
 bit    $49
 brk
 .byte  $04
 ora    ($00,x)
 ora    ($02,x)
 .byte  $04
 ora    #$12
 brk
 ora    ($02,x)
 .byte  $04
 ora    ($02,x)
 brk
 .byte  $7F
 .byte  $FF
 ldx    $4E
 beq    $CB7C
 lda    $55
 sta    $57
 lda    #$80
 cpx    #$01
 beq    $CB73
 inc    $57
 lda    #$00
 clc
 adc    $54
 sta    $56
 bcc    $CB7C
 inc    $57
 lda    $CB4C,x
 sta    $4B
 lda    $CB4F,x
 sta    $4C
 ldx    #$05
 lda    $4D
 sta    $59
 and    #$07
 tay
 asl    $59
 bcc    $CBA8
 lda    $CB58,x
 clc
 adc    $4C
 cmp    #$07
 bcc    $CB9F
 sbc    #$07
 sta    $4C
 lda    $CB52,x
 adc    $4B
 sta    $4B
 dex
 bmi    $CBB1
 bne    $CB8F
 tya
 jmp    $CB96
 lda    $55
 pha
 lda    #$00
 ldx    $4E
 beq    $CBD0
 ldy    $CB5E,x
 eor    ($54),y
 eor    ($56),y
 dey
 bne    $CBBD
 eor    ($54),y
 eor    ($56),y
 cpx    #$01
 beq    $CBCE
 inc    $55
 inc    $55
 ldy    $4D
 beq    $CBDD
 eor    ($54),y
 eor    ($54),y
 dey
 bne    $CBD6
 eor    ($54),y
 sta    $40
 pla
 sta    $55
 ldy    $4C
 dey
 lda    #$00
 sta    $59
 lda    ($54),y
 asl    a
 ror    $59
 dey
 bpl    $CBE9
 sec
 ror    $59
 lda    $4C
 clc
 adc    $54
 sta    $56
 lda    $55
 adc    #$00
 sta    $57
 ldy    #$06
 sec
 lda    ($56),y
 sta    $004D,y
 bmi    $CC0C
 clc
 ror    $41
 dey
 bpl    $CC03
 sec
 ror    $41
 lda    $56
 clc
 adc    #$07
 sta    $56
 bcc    $CC1F
 inc    $57
 rts
 lda    $C088,x
 lda    $C08D,x
 jmp    $CC2D
 tya
 sta    $C08F,x
 tya
 eor    $C08E,x
 and    #$1F
 bne    $CC29
 rts
 jsr    $CA97
 lda    $C08E,x
 lda    $C08D,x
 lda    $C08E,x
 and    #$20
 bne    $CC3F
 lda    $C08C,x
 phy
 ldy    #$8C
 dey
 bne    $CC4C
 ply
 rts
 lda    $4B
 tay
 ldx    #$00
 stx    $4B
 ldx    #$03
 asl    a
 rol    $4B
 dex
 bne    $CC5A
 clc
 adc    $4C
 bcc    $CC67
 inc    $4B
 sty    $4C
 sec
 sbc    $4C
 bcs    $CC70
 dec    $4B
 ldy    $4B
 rts
 ldy    #$00
 lda    $4B
 pha
 bne    $CC7D
 jmp    $CD0A
 lda    $C0EC
 bpl    $CC7D
 sta    $59
 lsr    a
 lsr    a
 lsr    a
 and    #$0F
 tax
 lda    $59
 and    #$07
 sta    $59
 lda    $C0EC
 bpl    $CC90
 eor    $CA9A,x
 sta    ($56),y
 eor    $40
 sta    $40
 iny
 bne    $CCA3
 inc    $57
 lda    $C0EC
 bpl    $CCA3
 eor    $CAAA,x
 sta    ($56),y
 eor    $40
 sta    $40
 iny
 lda    $C0EC
 bpl    $CCB2
 eor    $CABA,x
 sta    ($56),y
 eor    $40
 sta    $40
 iny
 lda    $C0EC
 bpl    $CCC1
 eor    $CACA,x
 sta    ($56),y
 eor    $40
 sta    $40
 iny
 bne    $CCD4
 inc    $57
 ldx    $59
 lda    $C0EC
 bpl    $CCD6
 eor    $CAAA,x
 sta    ($56),y
 eor    $40
 sta    $40
 iny
 lda    $C0EC
 bpl    $CCE5
 eor    $CABA,x
 sta    ($56),y
 eor    $40
 sta    $40
 iny
 lda    $C0EC
 bpl    $CCF4
 eor    $CACA,x
 sta    ($56),y
 eor    $40
 sta    $40
 iny
 dec    $4B
 beq    $CD0A
 jmp    $CC7D
 lda    $C0EC
 bpl    $CD0A
 sta    $59
 pla
 sta    $4B
 lda    $C0EC
 bpl    $CD14
 sec
 rol    a
 and    $59
 eor    $40
 ldy    $C0EC
 bpl    $CD1F
 cpy    #$C8
 bne    $CD44
 ldx    $4C
 beq    $CD34
 ldy    #$00
 eor    ($54),y
 iny
 dex
 bne    $CD2E
 tax
 bne    $CD48
 lda    $C0ED
 lda    $C0EE
 bmi    $CD3A
 lda    $C0E0
 clc
 rts
 lda    #$20
 bne    $CD4A
 lda    #$10
 sec
 rts
 bcc    $CD51
 jmp    $C523
 lda    #$40
 .byte  $1C
 sei
 .byte  $04
 cld
 txa
 tay
 lda    $0473,y
 bmi    $CD6F
 pla
 sta    $05F3,y
 clc
 adc    #$03
 tax
 pla
 sta    $0673,y
 adc    #$00
 pha
 txa
 pha
 jsr    $CC36
 php
 sei
 ldx    #$1B
 lda    $40,x
 pha
 dex
 bpl    $CD76
 sty    $58
 lda    $43
 rol    a
 php
 rol    a
 rol    a
 plp
 rol    a
 and    #$03
 eor    #$02
 cpy    #$04
 bcs    $CD90
 eor    #$02
 tax
 inx
 stx    $43
 lda    $0473,y
 bpl    $CD9C
 jmp    $CE40
 lda    $05F3,y
 sta    $54
 lda    $0673,y
 sta    $55
 ldy    #$01
 lda    ($54),y
 sta    $42
 iny
 lda    ($54),y
 tax
 iny
 lda    ($54),y
 sta    $55
 stx    $54
 lda    #$01
 ldx    $42
 cpx    #$0A
 bcc    $CDC2
 jmp    $CF17
 ldy    #$00
 lda    ($54),y
 sta    $5A
 ldy    #$08
 lda    ($54),y
 sta    $0042,y
 dey
 bne    $CDCA
 lda    $43
 bne    $CE40
 ldx    $42
 lda    $CF8E,x
 and    #$7F
 tay
 lda    #$04
 cpy    $5A
 bne    $CDBF
 cpx    #$05
 bne    $CDF2
 lda    #$00
 jsr    $CF98
 lda    #$00
 jmp    $CF39
 txa
 bne    $CE19
 lda    #$21
 ldx    $46
 bne    $CDBF
 txa
 ldx    $58
 ldy    #$07
 sta    ($44),y
 dey
 bne    $CE00
 lda    $06F9,x
 sta    ($44),y
 iny
 lda    $04F9
 sta    ($44),y
 lda    #$08
 dey
 jsr    $CFF0
 jmp    $CDED
 cmp    #$04
 bne    $CE28
 ldx    $46
 beq    $CE2C
 dex
 beq    $CE38
 lda    #$21
 bne    $CDBF
 lda    #$11
 bne    $CDBF
 lda    #$C0
 sta    $05F9
 lda    #$0F
 .byte  $0C
 txs
 cpy    #$D0
 ora    $A9
 ora    ($1C,x)
 txs
 cpy    #$4C
 sbc    $A9CD
 plp
 ldy    $58
 ldx    $06F9,y
 cpx    $43
 bcc    $CE26
 lda    #$09
 sta    $4D
 lda    #$00
 sta    $4E
 sta    $55
 lda    #$42
 sta    $54
 ldx    $58
 lda    $0473,x
 bpl    $CE73
 ldx    $42
 lda    $CF8E,x
 and    #$7F
 sta    $5A
 lda    #$00
 sta    $48
 lda    $42
 bne    $CE73
 sta    $46
 lda    $5A
 ldx    $43
 stx    $5A
 sta    $43
 lda    #$80
 sta    $5B
 jsr    $CA87
 jsr    $CAE9
 bcs    $CECD
 lda    $44
 sta    $54
 lda    $45
 sta    $55
 ldx    $42
 lda    $CF8E,x
 bpl    $CED1
 cpx    #$04
 bne    $CEB2
 ldy    #$01
 lda    ($54),y
 tax
 dey
 lda    ($54),y
 pha
 clc
 lda    #$02
 adc    $54
 sta    $54
 pla
 bcc    $CEC0
 inc    $55
 jmp    $CEC0
 cpx    #$02
 bne    $CEBC
 lda    #$00
 ldx    #$02
 bne    $CEC0
 ldx    $47
 lda    $46
 stx    $4E
 sta    $4D
 lda    #$82
 sta    $5B
 jsr    $CADA
 bcc    $CED1
 lda    #$06
 bne    $CF17
 ldy    $58
 lda    $0473,y
 bpl    $CEE4
 lda    $42
 bne    $CEE4
 lda    #$45
 ldx    #$00
 sta    $54
 stx    $55
 jsr    $CB30
 bcs    $CECD
 jsr    $CC51
 jsr    $CFF0
 lda    $42
 bne    $CF15
 ldx    $58
 lda    $0473,x
 bpl    $CF15
 lda    $46
 sta    $05F3,x
 lda    $47
 sta    $0673,x
 lda    $45
 lsr    a
 lsr    a
 lsr    a
 bcc    $CF0F
 lda    #$2B
 bra    $CF17
 lsr    a
 lsr    a
 lda    #$2F
 bcc    $CF17
 lda    $4D
 ldy    $58
 sta    $04F3,y
 tax
 beq    $CF39
 ldx    $0473,y
 bpl    $CF39
 ldx    #$00
 cmp    #$40
 bcs    $CF38
 ldx    #$27
 cmp    #$2B
 beq    $CF39
 cmp    #$28
 beq    $CF39
 cmp    #$2F
 beq    $CF39
 txa
 ldy    $58
 sta    $0573,y
 lda    $C0E8
 bit    $C0ED
 lda    #$2B
 sta    $C0EF
 nop
 nop
 nop
 nop
 lda    $C0EE
 and    #$20
 bne    $CF4D
 ldy    #$00
 ldx    #$60
 jsr    $CC20
 lda    $C0EC
 lda    $C0E2
 lda    $C0E6
 ldy    $58
 ldx    #$00
 pla
 sta    $40,x
 inx
 cpx    #$1C
 bcc    $CF68
 plp
 lda    $05F3,y
 tax
 lda    $0573,y
 pha
 lda    $0673,y
 tay
 clc
 pla
 beq    $CF82
 sec
 php
 bit    $0478
 bvs    $CF8C
 plp
 jmp    $C784
 plp
 rts
 .byte  $03
 .byte  $03
 .byte  $83
 ora    ($83,x)
 ora    ($01,x)
 ora    ($03,x)
 .byte  $83
 pha
 jsr    $CA5D
 pla
 tax
 lda    $42
 pha
 lda    $43
 pha
 lda    $46
 pha
 stx    $46
 lda    #$05
 sta    $42
 lda    #$00
 sta    $5A
 lda    #$02
 sta    $43
 lda    #$42
 sta    $54
 lda    #$00
 sta    $55
 lda    #$80
 sta    $5B
 jsr    $CA87
 inc    $5A
 lda    #$09
 sta    $4D
 lda    #$00
 sta    $4E
 jsr    $C883
 bcc    $CFD8
 dec    $5A
 jmp    $CFDF
 jsr    $C9E3
 lda    $4D
 beq    $CFC4
 lda    $5A
 ldy    $58
 sta    $06F9,y
 pla
 sta    $46
 pla
 sta    $43
 pla
 sta    $42
 rts
 ldx    $58
 sta    $05F3,x
 tya
 sta    $0673,x
 rts
 brk
 brk
 brk
 brk
 brk
 brk
 pha
 bit    $03B8,x
 bmi    $D022
 ldy    $0638,x
 beq    $D01F
 eor    $0638,x
 asl    a
 bne    $D01F
 ldy    $07FB
 sty    $0679
 ldy    #$BF
 sty    $07FB
 jmp    $D0B5
 sec
 pla
 rts
 ldy    $C142,x
 and    #$5F
 pha
 lda    $03B8,x
 bit    #$08
 bne    $D032
 pla
 bra    $D084
 pla
 pha
 cmp    #$00
 bne    $D03C
 clc
 pla
 bra    $D020
 lda    $03B8,x
 pha
 and    #$07
 sta    $06F8
 pla
 and    #$F0
 sta    $03B8,x
 pla
 phx
 ldx    $06F8
 cmp    #$45
 beq    $D0C5
 cmp    #$44
 beq    $D0C7
 plx
 phx
 cmp    $0638,x
 php
 ldx    $06F8
 plp
 beq    $D077
 cmp    #$0D
 beq    $D07F
 plx
 lda    $0679
 sta    $07FB
 asl    $03B8,x
 lsr    $03B8,x
 bra    $D01F
 plx
 phx
 inc    $03B8,x
 ldx    $06F8
 lda    $D225,x
 bra    $D08F
 phx
 ldx    #$04
 cmp    $D225,x
 beq    $D0FD
 dex
 bpl    $D087
 ldx    #$0C
 cmp    $D218,x
 beq    $D10A
 dex
 bpl    $D091
 plx
 pla
 pha
 and    #$7F
 cmp    #$20
 bcs    $D0A5
 sta    $0638,x
 eor    #$30
 cmp    #$0A
 bcs    $D0DE
 ldy    #$0A
 adc    $077E
 dey
 bne    $D0AD
 bra    $D0BF
 lda    $03B8,x
 and    #$C0
 sta    $03B8,x
 lda    #$00
 sta    $077E
 sec
 bra    $D0EA
 sec
 bcc    $D0E0
 php
 cpx    #$00
 beq    $D0F4
 cpx    #$04
 beq    $D112
 txa
 clc
 asl    a
 adc    #$03
 tax
 plp
 bcs    $D0DB
 inx
 jmp    $D139
 lda    $03B8,x
 lsr    a
 bcs    $D0B5
 lda    $0679
 sta    $07FB
 php
 asl    $03B8,x
 plp
 ror    $03B8,x
 pla
 rts
 lda    #$4C
 plp
 bcs    $D08F
 lda    #$4B
 bra    $D08F
 txa
 plx
 ora    $03B8,x
 ora    #$08
 sta    $03B8,x
 sec
 bra    $D0EA
 lda    #$D1
 pha
 lda    $D1F5,x
 pha
 rts
 plp
 plx
 bcs    $D11B
 stz    $04B8,x
 bra    $D0DE
 ldy    $D186,x
 jsr    $D22A
 sta    $04B8,x
 bra    $D0DE
 plx
 stz    $04B8,x
 lda    #$00
 jmp    $D0A2
 ply
 lda    $077E
 beq    $D13A
 sta    $04B8,y
 beq    $D1B4
 lda    $06B8,y
 and    $D202,x
 ora    $D20D,x
 sta    $06B8,y
 tya
 tax
 jmp    $D0DE
 dey
 lda    #$1F
 sec
 bcc    $D0FA
 beq    $D16B
 and    $BFFB,y
 sta    $06F8
 plx
 lda    $077E
 and    #$0F
 bcc    $D166
 asl    a
 asl    a
 asl    a
 asl    a
 asl    a
 ora    $06F8
 iny
 bra    $D183
 lda    $BFFA,y
 pha
 ora    #$0C
 sta    $BFFA,y
 lda    #$E9
 ldx    #$53
 pha
 pla
 dex
 bne    $D179
 dec    a
 bne    $D177
 pla
 plx
 sta    $BFFA,y
 bra    $D148
 sta    $BFF9,y
 lda    $067B
 asl    a
 jsr    $C797
 bcc    $D197
 jsr    $C79D
 clc
 bcs    $D1D2
 plx
 jsr    $D1A0
 bra    $D148
 lda    $03B8,x
 bit    #$40
 bcc    $D1B9
 bne    $D1C9
 cpx    $39
 bne    $D1F4
 ora    #$40
 ldy    $0679
 sty    $067A
 ldy    #$DF
 bra    $D1C0
 beq    $D1C9
 and    #$BF
 ldy    $067A
 sta    $03B8,x
 sty    $0679
 sty    $07FB
 ldy    $C142,x
 cli
 php
 sei
 lda    $BFFA,y
 ora    #$02
 bcc    $D1D8
 and    #$FD
 sta    $BFFA,y
 lda    #$00
 ror    a
 sta    $05FA
 bpl    $D1EA
 stz    $057C
 stz    $067C
 txa
 sta    $04FC
 plp
 stx    $05FC
 stx    $06FC
 rts
 sec
 sec
 sec
 rol    $4F2E
 .byte  'K'
 lsr    a
 stx    $87,y
 .byte  'k'
 tya
 and    $7F
 .byte  $BF
 .byte  $BF
 .byte  $7F
 .byte  $FF
 .byte  $DF
 .byte  $DF
 .byte  $EF
 .byte  $EF
 .byte  $F7
 .byte  $F7
 bra    $D20F
 rti
 brk
 brk
 jsr    $0000
 bpl    $D217
 php
 eor    #$4B
 jmp    $0D4E
 .byte  'B'
 .byte  'D'
 bvc    $D272
 eor    ($53)
 .byte  'T'
 phy
 jmp    $4658
 eor    $AD43
 .byte  $13
 cpy    #$0A
 lda    $C018
 php
 sta    $C000
 sta    $C003
 lda    $0478,y
 plp
 bcs    $D241
 sta    $C002
 bpl    $D246
 sta    $C001
 rts
 .byte  $03
 .byte  $07

 .res 439

 sta    ($28),y
 lda    #$05
 sta    $38
 lda    $C000
 asl    a
 php
 sei
 jsr    $D679
 ldy    #$05
 ldx    $057F
 lda    $047F
 jsr    $D441
 ldy    #$0C
 ldx    $05FF
 lda    $04FF
 jsr    $D441
 lda    $077F
 rol    a
 rol    a
 rol    a
 and    #$03
 eor    #$03
 inc    a
 plp
 ldy    #$10
 jsr    $D452
 ply
 ldx    #$11
 lda    #$8D
 sta    $0200,x
 jmp    $C784
 cpx    #$80
 bcc    $D452
 eor    #$FF
 adc    #$00
 pha
 txa
 eor    #$FF
 adc    #$00
 tax
 pla
 sec
 sta    $0214
 stx    $0215
 lda    #$2B
 bcc    $D45E
 lda    #$2D
 pha
 lda    #$2C
 sta    $0201,y
 ldx    #$11
 lda    #$00
 clc
 rol    a
 cmp    #$0A
 bcc    $D470
 sbc    #$0A
 rol    $0214
 rol    $0215
 dex
 bne    $D469
 ora    #$30
 sta    $0200,y
 dey
 beq    $D489
 cpy    #$07
 beq    $D489
 cpy    #$0E
 bne    $D464
 pla
 sta    $0200,y
 rts
 sta    $C050
 sta    $C078
 sta    $C05F
 ldy    #$04
 ldx    #$00
 clc
 adc    $C82A,y
 sta    $00,x
 inx
 bne    $D49B
 clc
 adc    $C82A,y
 cmp    $00,x
 bne    $D4BC
 inx
 bne    $D4A4
 ror    a
 bit    $C019
 bpl    $D4B7
 eor    #$A5
 dey
 bpl    $D49B
 bmi    $D4C2
 eor    $00,x
 clc
 jmp    $C473
 jmp    $C3C6
 jsr    $C79D
 pla
 ply
 pla
 lda    #$FF
 tax
 inx
 eor    $D4DA,x
 sta    $0200,x
 bpl    $D4CE
 jmp    $C784
 lda    $0A3B
 .byte  $0B
 pha
 .byte  'w'
 rol    a:$0005,x
 ora    $08
 .byte  $0C
 asl    $6553,x
 .byte  $37
 .byte  $1C
 .byte  $07
 .byte  $0C
 eor    $62
 .byte  $27
 brk
 .byte  $17
 .byte  $1C
 .byte  $07
 .byte  $07
 ora    $4B
 adc    $0224
 asl    $6145
 and    ($18)
 .byte  $02
 .byte  $07
 ora    $6A53,x
 .byte  $2B
 .byte  $0C
 php
 asl    $53,x
 pla
 and    $0706,x
 .byte  $1B
 ora    ($E3,x)

 .res   240

 stz    $077F
 ldx    #$80
 ldy    #$01
 stz    $047D,x
 stz    $057D,x
 lda    #$FF
 sta    $067D,x
 lda    #$03
 sta    $077D,x
 ldx    #$00
 dey
 bpl    $D607
 jsr    $D651
 lda    #$00
 tax
 jsr    $C746
 txa
 sta    $0478
 lsr    a
 ora    $0478
 cmp    #$10
 bcs    $D650
 and    #$05
 beq    $D636
 cli
 adc    #$55
 php
 sei
 stx    $07FF
 sta    $C079
 ldx    #$08
 dex
 asl    a
 bcc    $D649
 sta    $C058,x
 bne    $D642
 sta    $C078
 plp
 clc
 rts
 ldx    #$80
 bra    $D657
 ldx    #$00
 lda    $047D,x
 sta    $047F,x
 lda    $057D,x
 sta    $057F,x
 dex
 bpl    $D655
 bra    $D674
 stz    $047F
 stz    $057F
 stz    $04FF
 stz    $05FF
 stz    $067F
 clc
 rts
 lda    #$20
 .byte  $1C
 .byte  $7F
 .byte  $07
 and    $067F
 .byte  $1C
 .byte  $7F
 asl    $2C
 .byte  $FF
 .byte  $07
 bmi    $D69C
 bit    $C063
 bmi    $D690
 ora    #$80
 bit    $077F
 bpl    $D697
 ora    #$40
 sta    $077F
 clc
 rts
 ora    $077F
 and    #$E0
 bra    $D697
 ror    a
 ror    a
 and    #$80
 tax
 lda    $0478
 sta    $047D,x
 lda    $0578
 sta    $057D,x
 lda    $04F8
 sta    $067D,x
 lda    $05F8
 sta    $077D,x
 clc
 rts
 pha
 clc
 lda    #$0E
 and    $077F
 bne    $D6CC
 sec
 pla
 rts

 .res   306

 sta    $42
 ldy    #$C4
 sty    $07F8
 ldx    #$C8
 stx    $0778
 lda    #$00
 sta    $04F8
 jsr    $D9DD
 ldy    $42
 lda    $C680,y
 bmi    $D81F
 cmp    $43
 bne    $D834
 lda    #$D8
 bra    $D824
 brk
 pha
 lda    $C69A,y
 pha
 ldy    $07F8
 ldx    $0778
 rts
 lda    #$01
 bne    $D836
 lda    #$04
 sta    $04F8
 rts
 jmp    $C580
 jmp    $C5F7
 jmp    $D959
 jmp    $DB3A
 lda    $03B8,y
 lsr    a
 sta    $05F8
 lda    #$00
 sta    $0578
 rts
 lda    $47
 bne    $D878
 sta    $05F8
 ldy    #$08
 sty    $0578
 dey
 sta    ($45),y
 dey
 bne    $D860
 phy
 ldy    $07F8
 lda    $03B8,y
 beq    $D870
 lda    #$01
 ply
 sta    ($45),y
 rts
 lda    $47
 beq    $D87D
 lda    #$21
 sta    $04F8
 rts
 lda    #$04
 ldx    $47
 beq    $D88A
 cpx    #$03
 bne    $D878
 lda    #$19
 sta    $0578
 ldx    #$00
 stx    $05F8
 tay
 dey
 lda    $C667,y
 sta    ($45),y
 dey
 bpl    $D894
 ldy    $07F8
 lda    $03B8,y
 lsr    a
 ldy    #$02
 sta    ($45),y
 rts
 bit    $D839
 bvc    $D865
 lda    $47
 sta    $48
 lda    $46
 sta    $47
 lda    $45
 sta    $46
 lda    $44
 sta    $45
 lda    #$00
 sta    $49
 beq    $D8C8
 bit    $D839
 bvc    $D880
 lda    $47
 asl    a
 sta    $4A
 lda    $48
 rol    a
 sta    $4B
 bcs    $D8F3
 lda    $49
 bne    $D8F3
 sta    $49
 sta    $47
 lda    #$02
 sta    $48
 lda    $C014
 bvs    $D8E8
 lda    $C013
 and    #$80
 ora    $4B
 sta    $4B
 bvs    $D8F6
 jmp    $C5F7
 jmp    $C5EE
 jmp    $C580
 ldy    #$C4
 sty    $07F8
 ldx    #$C8
 stx    $0778
 cmp    $07F8
 bne    $D911
 lda    $BF00
 beq    $D911
 cmp    #$4C
 bne    $D931
 stz    $0801
 lda    $06B8,y
 cmp    #$A5
 bne    $D92C
 ldy    #$03
 lda    $D92D,y
 sta    $0044,y
 dey
 bpl    $D91D
 ldy    $07F8
 jsr    $D8A8
 rts
 brk
 php
 brk
 brk
 lda    #$4C
 sta    $BD00
 lda    #$D1
 sta    $BD01
 sty    $BD02
 lda    #$C3
 sta    $9D1E
 lda    #$A6
 sta    $9D1F
 pla
 pla
 plx
 inc    $C000,x
 plx
 pla
 pla
 ldx    #$00
 lda    #$98
 jmp    $C784
 rts
 ldy    #$02
 lda    ($48),y
 cmp    #$01
 beq    $D964
 jmp    $D830
 ldy    #$04
 lda    ($48),y
 lsr    a
 ror    $4A
 lsr    a
 ror    $4A
 lsr    a
 sta    $4B
 lda    $4A
 ror    a
 and    #$E0
 iny
 ora    ($48),y
 sta    $4A
 ldy    #$08
 lda    ($48),y
 sta    $45
 iny
 lda    ($48),y
 sta    $46
 ldy    #$0C
 lda    ($48),y
 beq    $D958
 and    #$03
 beq    $D961
 ora    #$11
 tay
 ldx    #$00
 stx    $47
 stx    $49
 inx
 stx    $48
 jmp    $D81F
 lda    #$00
 sta    $BFF8,x
 sta    $BFF9,x
 lda    #$10
 sec
 sbc    #$01
 sta    $BFFA,x
 lda    $BFFB,x
 pha
 dec    $BFF8,x
 lda    #$A5
 sta    $BFFB,x
 dec    $BFF8,x
 eor    $BFFB,x
 dec    $BFF8,x
 cmp    #$01
 pla
 sta    $BFFB,x
 lda    $BFFA,x
 and    #$0F
 beq    $D9D5
 bcs    $D9AA
 adc    #$01
 sta    $03B8,y
 lsr    a
 sta    $0478
 rts
 ldy    $07F8
 lda    #$A5
 cmp    $06B8,y
 beq    $DA12
 sta    $06B8,y
 cmp    #$05
 php
 jsr    $D99F
 plp
 beq    $DA12
 lda    $BF00
 beq    $DA13
 cmp    #$4C
 bne    $DA19
 ldy    #$FF
 jsr    $DA43
 lda    #$01
 ldy    #$20
 sta    $BFFB,x
 ora    #$FF
 dey
 bne    $DA05
 dec    $0478
 bne    $DA03
 rts
 ldy    #$78
 jsr    $DA43
 rts
 ldy    #$2C
 jsr    $DA43
 lda    #$44
 sta    $BFF8,x
 lda    $0478
 ldy    #$72
 cmp    #$04
 bcc    $DA2E
 ldy    #$BA
 lda    $BFF8,x
 cmp    #$7C
 bne    $DA3A
 lda    #$7E
 sta    $BFF8,x
 lda    #$FF
 sta    $BFFB,x
 dey
 bne    $DA2E
 rts
 lda    #$00
 sta    $BFF8,x
 sta    $BFF9,x
 sta    $BFFA,x
 sta    $BFFB,x
 lda    $BFF9,x
 and    #$F0
 beq    $DA4E
 lda    #$04
 sta    $BFF9,x
 iny
 lda    $DAB1,y
 cmp    #$FD
 beq    $DA81
 cmp    #$FE
 beq    $DA87
 cmp    #$FC
 bne    $DA72
 lda    $0478
 bne    $DA7B
 cmp    #$AA
 bne    $DA7B
 lda    $07F8
 eor    #$F0
 sta    $BFFB,x
 jmp    $DA5D
 iny
 lda    $DAB1,y
 beq    $DA98
 pha
 lda    #$00
 sta    $BFFB,x
 pla
 sec
 sbc    #$01
 bne    $DA87
 beq    $DA5D
 sta    $BFFB,x
 cmp    $BFF8,x
 bne    $DA95
 iny
 lda    $DAB1,y
 beq    $DAB0
 sta    $BFF9,x
 iny
 lda    $DAB1,y
 sta    $BFFA,x
 jmp    $DA5D
 rts
 brk
 brk
 .byte  $03
 brk
 .byte  $F4
 eor    ($41)
 eor    $FDAA
 ora    $27C3,y
 ora    a:$0000
 asl    $00
 brk
 .byte  $FC
 sbc    $FED7,x
 .byte  $02
 brk
 .byte  $04
 brk
 inc    $03FE,x
 brk
 ora    $00
 inc    $04FE,x
 brk
 brk
 inc    a:$00FD,x
 brk
 brk
 brk
 brk
 sbc    $2000,x
 .byte  $02
 .byte  $02
 ora    ($0F),y
 .byte  $04
 brk
 brk
 .byte  $FB
 sbc    $7A20,x
 sbc    $FF08,x
 .byte  $FF
 .byte  $FF
 .byte  $FF
 and    ($20)
 brk
 ora    ($FD,x)
 .byte  $CB
 inc    $0111,x
 inc    $0211,x
 inc    $0311,x
 inc    $0411,x
 inc    $0511,x
 inc    $0611,x
 inc    $0711,x
 inc    $0811,x
 inc    $0911,x
 inc    $0A11,x
 inc    $0B11,x
 inc    $0C11,x
 inc    $0D11,x
 inc    $0E11,x
 inc    a:$00FD,x
 jsr    $FD02
 brk
 brk
 brk
 brk
 asl    $FD
 .byte  $03
 .byte  $04
 eor    ($41)
 eor    $FDAA
 .byte  $04
 .byte  $FC
 sbc    a:$0000,x
 ldx    #$00
 lda    $DC00,x
 sta    $2000,x
 lda    $DD00,x
 sta    $2100,x
 lda    $DE00,x
 sta    $2200,x
 lda    $DF00,x
 sta    $2300,x
 inx
 bne    $DB3C
 ldx    $0778
 lda    #$1F
 pha
 lda    #$FF
 pha
 jmp    $C784

 .res   157

 lda    #$00
 sta    $49
 sta    $4A
 sta    $0438,y
 sta    $04B8,y
 lda    $03B8,y
 and    #$0F
 sta    $46
 jsr    $FC58
 lda    #$08
 jsr    $221D
 lda    $46
 lsr    a
 lsr    a
 pha
 ora    #$04
 jsr    $221D
 lda    #$09
 jsr    $221D
 pla
 jsr    $221D
 jsr    $FD8E
 lda    #$05
 sta    $25
 jsr    $FD8E
 lda    #$10
 jsr    $221D
 lda    $4A
 jsr    $FDDA
 lda    $49
 jsr    $FDDA
 jsr    $220B
 lda    #$01
 sta    $00
 ldy    #$05
 lda    $22F4,y
 jsr    $2213
 cmp    $BFF8,x
 bne    $DC6C
 cmp    $BFF9,x
 bne    $DC6C
 ora    #$F0
 cmp    $BFFA,x
 bne    $DC6C
 dey
 bpl    $DC50
 bmi    $DC6F
 jmp    $2197
 inc    $00
 dec    $BFF8,x
 lda    $BFFB,x
 sta    $BFFB,x
 lda    $BFFA,x
 and    #$0F
 ora    $BFF9,x
 ora    $BFF8,x
 beq    $DC8A
 jmp    $2197
 inc    $00
 lda    #$01
 sta    $45
 txa
 clc
 adc    #$F8
 sta    $42
 lda    #$C0
 sta    $43
 lda    $46
 beq    $DCA2
 cmp    #$0C
 bne    $DCA4
 lda    #$10
 lsr    a
 pha
 ldy    #$02
 pha
 jsr    $2211
 pla
 sta    ($42),y
 pha
 lda    $45
 sta    $BFFB,x
 inc    $45
 pla
 lsr    a
 bne    $DCA8
 sta    ($42),y
 ror    a
 dey
 bpl    $DCA8
 lda    #$01
 sta    $45
 pla
 ldy    #$02
 pha
 jsr    $2211
 pla
 sta    ($42),y
 sta    $47
 lda    $BFFB,x
 cmp    $45
 bne    $DCE7
 inc    $45
 lda    $47
 lsr    a
 bne    $DCC8
 sta    ($42),y
 ror    a
 dey
 bpl    $DCC8
 bmi    $DCEA
 jmp    $2197
 jsr    $2211
 inc    $00
 sta    $45
 lda    $45
 sta    $BFFB,x
 sta    $BFFB,x
 sta    $BFFB,x
 sta    $BFFB,x
 lda    $BFF8,x
 bne    $DCF1
 ora    $BFF9,x
 bne    $DCF1
 jsr    $21E4
 bne    $DCF1
 jsr    $220B
 lda    $BFFB,x
 cmp    $45
 bne    $DCE7
 lda    $BFFB,x
 cmp    $45
 bne    $DCE7
 lda    $BFF8,x
 bne    $DD11
 ora    $BFF9,x
 bne    $DD11
 jsr    $21E4
 bne    $DD11
 jsr    $220B
 lda    $45
 eor    #$FF
 bne    $DCED
 inc    $00
 lda    #$55
 sta    $45
 jsr    $21FD
 clc
 adc    $47
 adc    $45
 sta    $BFFB,x
 sta    $45
 lda    $BFF8,x
 bne    $DD40
 lda    $BFF9,x
 bne    $DD3D
 jsr    $21E4
 bne    $DD3D
 jsr    $220B
 lda    #$55
 sta    $45
 jsr    $21FD
 clc
 adc    $47
 adc    $45
 sta    $45
 lda    $BFFB,x
 cmp    $45
 bne    $DD97
 lda    $BFF8,x
 bne    $DD63
 lda    $BFF9,x
 bne    $DD60
 jsr    $21E4
 bne    $DD60
 lda    #$0B
 jsr    $221D
 sed
 lda    $49
 clc
 adc    #$01
 sta    $49
 lda    $4A
 adc    #$00
 sta    $4A
 cld
 jmp    $2031
 pha
 jsr    $FC42
 lda    #$0A
 jsr    $221D
 lda    $00
 cmp    #$03
 bcs    $DDAF
 pla
 lda    #$0C
 jsr    $221D
 jmp    $21DE
 lda    #$0D
 jsr    $221D
 sec
 lda    $BFF8,x
 sbc    #$01
 pha
 lda    $BFF9,x
 sbc    #$00
 pha
 lda    $BFFA,x
 and    #$0F
 sbc    #$00
 jsr    $FDDA
 pla
 jsr    $FDDA
 pla
 jsr    $FDDA
 lda    #$0E
 jsr    $221D
 pla
 eor    $45
 jsr    $FDDA
 lda    #$0F
 jsr    $221D
 rts
 lda    #$AE
 jsr    $FDED
 lda    $C000
 cmp    #$9B
 bne    $DDF5
 pla
 pla
 sta    $C010
 lda    $BFFA,x
 and    #$0F
 cmp    $46
 rts
 clc
 lda    $BFF9,x
 adc    $BFFA,x
 adc    #$55
 sta    $47
 lda    #$00
 rts
 jsr    $FD8E
 jsr    $FC9C
 lda    #$00
 sta    $BFF8,x
 sta    $BFF9,x
 sta    $BFFA,x
 rts
 tay
 lda    $2230,y
 tay
 lda    $2241,y
 pha
 ora    #$80
 jsr    $FDED
 iny
 pla
 bpl    $DE22
 rts
 brk
 ora    $09
 ora    $1411
 asl    $18,x
 .byte  $1B
 .byte  'G'
 .byte  '\'
 adc    $8477
 .byte  $8F
 sta    ($AA)
 and    ($20),y
 eor    $C745
 and    ($35)
 rol    $CB,x
 and    $31,x
 and    ($CB)
 .byte  $37
 rol    $38,x
 .byte  $CB
 and    ($38),y
 bcs    $DE8A
 lda    $39,x
 bcs    $DE8B
 .byte  $33
 lda    $4D,x
 eor    $4D
 .byte  'O'
 eor    ($59)
 jsr    $4143
 eor    ($44)
 jsr    $4554
 .byte  'S'
 .byte  'T'
 ora    $5345
 .byte  'C'
 jsr    $4F54
 jsr    $5845
 eor    #$54
 ora    $4554
 .byte  'S'
 .byte  'T'
 jsr    $4957
 jmp    $204C
 .byte  'T'
 eor    ($4B,x)
 eor    $A0
 jsr    $4553
 .byte  'C'
 .byte  'O'
 lsr    $5344
 ora    $4143
 eor    ($44)
 jsr    $4953
 phy
 eor    $20
 and    $0DA0,x
 ora    $4143
 eor    ($44)
 jsr    $4146
 eor    #$4C
 eor    $44
 ora    $0707
 .byte  $87
 ora    $430D
 eor    ($52,x)
 .byte  'D'
 jsr    $4B4F
 sta    $4441
 .byte  'D'
 eor    ($45)
 .byte  'S'
 .byte  'S'
 jsr    $5245
 eor    ($4F)
 cmp    ($44)
 eor    ($54,x)
 eor    ($20,x)
 eor    $52
 eor    ($4F)
 eor    ($A0)
 jsr    $A02D
 ora    $4553
 eor    $20
 .byte  'D'
 eor    $41
 jmp    $5245
 jsr    $4F46
 eor    ($20)
 .byte  'S'
 eor    $52
 lsr    $49,x
 .byte  'C'
 eor    $8D
 bvc    $DF2E
 .byte  'S'
 .byte  'S'
 eor    $53
 jsr    $A03D
 .byte  $FF
 cpy    $55AA
 .byte  $33
 brk
 eor    ($69)
 .byte  'c'
 pla
 jsr    $6957
 jmp    ($696C)
 adc    ($6D,x)
 .byte  's'
 .byte  'c'
 .byte  'o'
 bvs    $DF84
 adc    ($69)
 .byte  'g'
 pla
 stz    $20,x
 and    ($39),y
 sec
 rol    $20,x
 eor    ($70,x)
 bvs    $DF86
 adc    $20
 .byte  'C'
 .byte  'o'
 adc    $7570
 stz    $65,x
 adc    ($20)
 eor    #$6E
 .byte  'c'
 rol    $6C61
 jmp    ($7220)
 adc    #$67
 pla
 stz    $73,x
 jsr    $6572
 .byte  's'
 adc    $72
 ror    $65,x
 stz    $00

 .res   8381

 .word  $C788
 .word  $C788
 .word  $C78E

.endif ; .if ROMVER = 255
