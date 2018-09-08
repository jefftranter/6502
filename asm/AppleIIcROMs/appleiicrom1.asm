 .setcpu "65c02"
 .org   $C000

; Set to the version of Apple //c ROM you want to build. Typically
; done on the command line.
;ROMVER = 255
;ROMVER = 0
;ROMVER = 3
;ROMVER = 4

; Macro to define a string in ASCII with high bit set on each character.
.macro STR Arg
    .repeat .strlen(Arg), I
    .byte   .strat(Arg, I) | $80
    .endrep
.endmacro

; The first 256 bytes of the ROM ($C000-$C0FF) are normally not mapped
; in to memory. They contain an Easter egg of the designer's
; names.

 .byte   "Peter Quinn, "
 .byte   "Rick Rice, "
 .byte   "Joe Ennis, "
 .byte   "J MacDougall, "
 .byte   "Ken Victor, "
 .byte   "E Beernink, "
 .byte   "JR Huston, "
 .byte   "RC Williams, "
 .byte   "S DesJardin, "
 .byte   "Randy Bleske, "
 .byte   "Rob Gemmell, "
 .byte   "Stan Robbins, "
 .byte   "Donna Keyes, "
 .byte   "Doug Farrar, "
 .byte   "Rich Jordan, "
 .byte   "Jerry Devlin, "
 .byte   "John Medica, "
 .byte   "B Etheredge, "
 .byte   "Dave Downey, "
 .byte   "Conrad Rogers"

 bit    $C189
 bvs    $C111
 sec
 bcc    $C120
 clv
 bvc    $C111
 ora    ($31,x)
 stz    $B4A8,x
 .byte  $BB
 phx
 ldx    #$C1
 jmp    $C21C
 bcc    $C11C
 jmp    $C7E5
 asl    a
 ply
 phy
 lda    $04B8,x
 beq    $C166
 lda    $24
 bcs    $C144
 cmp    $04B8,x
 bcc    $C130
 lda    $0738,x
 cmp    $0738,x
 bcs    $C140
 cmp    #$11
 bcs    $C14A
 ora    #$F0
 and    $0738,x
 adc    $24
 sta    $24
 bra    $C14A
 cmp    $21
 bcc    $C14A
 stz    $24
 ply
 phy
 lda    $0738,x
 cmp    $04B8,x
 bcs    $C15C
 cmp    $24
 bcs    $C166
 lda    #$40
 bra    $C15E
 lda    #$1A
 cpy    #$80
 ror    a
 jsr    $C19B
 bra    $C14A
 tya
 jsr    $C18A
 lda    $04B8,x
 beq    $C186
 bit    $06B8,x
 bmi    $C186
 lda    $0738,x
 sbc    $04B8,x
 cmp    #$F8
 bcc    $C182
 clc
 adc    $21
 ldy    a:$00A9
 sta    $24
 pla
 ply
 plx
 rts
 jsr    $C7A9
 bcc    $C189
 bit    $06B8,x
 bpl    $C19B
 cmp    #$91
 beq    $C19B
 jsr    $FDF0
 jmp    $C7CD
 phy
 pha
 jsr    $C2B6
 stz    $06B8,x
 bra    $C1AF
 phy
 jsr    $C7D9
 bcc    $C1A8
 bcc    $C218
 ply
 ldx    #$00
 rts
 phy
 pha
 jsr    $C18A
 bra    $C1AF
 phy
 pha
 lsr    a
 bne    $C1D5
 php
 jsr    $C7D3
 plp
 bcc    $C1CC
 and    #$28
 asl    a
 bra    $C1CE
 and    #$30
 cmp    #$10
 beq    $C1AF
 clc
 bra    $C1AF
 ldx    #$40
 pla
 ply
 clc
 rts
 cmp    $CE,x
 cmp    ($C2,x)
 cpy    $A0C5
 .byte  $D4
 .byte  $CF
 ldy    #$D3
 .byte  $D4
 cmp    ($D2,x)
 .byte  $D4
 ldy    #$C6
 cmp    ($CF)
 cmp    $CDA0
 cmp    $CD
 .byte  $CF
 cmp    ($D9)
 ldy    #$C3
 cmp    ($D2,x)
 cpy    $00
 brk
 brk
 brk
 brk
 bit    $C189
 bvs    $C219
 sec
 bcc    $C220
 clv
 bvc    $C219
 ora    ($31,x)
 ora    ($13),y
 ora    $17,x
 bra    $C19E
 bra    $C1A8
 bra    $C1B4
 bra    $C1BB
 phx
 ldx    #$C2
 phy
 pha
 stx    $07F8
 bvc    $C245
 lda    $36
 eor    $38
 beq    $C22F
 lda    $37
 cmp    $39
 beq    $C232
 jsr    $C2B6
 txa
 eor    $39
 ora    $38
 bne    $C240
 lda    #$05
 sta    $38
 sec
 bra    $C245
 lda    #$07
 sta    $36
 clc
 lda    $06B8,x
 bit    #$01
 bne    $C24F
 jmp    $C117
 bcc    $C24C
 pla
 bra    $C27C
 bit    $03B8,x
 bvc    $C275
 jsr    $C18F
 bra    $C27C
 pla
 jsr    $CC70
 bpl    $C27F
 jsr    $C7A9
 bcs    $C254
 and    #$5F
 cmp    #$51
 beq    $C273
 cmp    #$52
 bne    $C27C
 lda    #$98
 ply
 plx
 rts
 clc
 jsr    $C7A3
 jsr    $CC4C
 pha
 jsr    $C7D9
 bcs    $C28E
 lda    $06B8,x
 and    #$10
 beq    $C25E
 bra    $C280
 tay
 pla
 phy
 jsr    $C3B8
 pla
 ldy    $0638,x
 beq    $C2AC
 ora    #$80
 cmp    #$91
 beq    $C27C
 cmp    #$FF
 beq    $C27C
 cmp    #$92
 beq    $C278
 cmp    #$94
 beq    $C279
 bit    $03B8,x
 bvc    $C275
 jsr    $FDED
 bra    $C27C
 jsr    $CFA0
 ldy    $C229,x
 jsr    $C37C
 pha
 dey
 bmi    $C2C7
 cpy    #$03
 bne    $C2BC
 jsr    $CFA0
 pla
 ldy    $C22B,x
 sta    $BFFB,y
 pla
 sta    $BFFA,y
 pla
 sta    $06B8,x
 and    #$01
 bne    $C2DF
 lda    #$09
 sta    $0638,x
 pla
 sta    $04B8,x
 stz    $03B8,x
 rts
 .byte  $03
 .byte  $07
 ldy    #$B0
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 pha
 phx
 phy
 bra    $C317
 sec
 bcc    $C320
 bra    $C324
 nop
 ora    ($88,x)
 bit    $322F
 and    $4C,x
 .byte  $AF
 .byte  $C7
 jmp    $C7B5
 jsr    $CE20
 jsr    $CDBE
 jsr    $FC58
 ply
 plx
 pla
 clc
 bcs    $C329
 jmp    $FDF6
 jmp    $FD1B
 jmp    $CF41
 jmp    $CF35
 jmp    $CEC2
 jmp    $CEB1
 lda    #$06
 cmp    $FBB3
 beq    $C37B
 jsr    $C360
 lda    #$F8
 sta    $37
 stz    $36
 lda    ($36)
 sta    ($36)
 inc    $36
 bne    $C348
 inc    $37
 bne    $C348
 phx
 ldx    $0478
 bit    $C081,x
 bit    $C081,x
 plx
 rts
 phx
 ldx    #$00
 bit    $C011
 bmi    $C36A
 ldx    #$08
 bit    $C012
 bpl    $C371
 inx
 inx
 bit    $C081
 bit    $C081
 stx    $0478
 plx
 rts
 lda    $C013
 asl    a
 lda    $C018
 php
 sta    $C000
 sta    $C003
 lda    $0478,y
 plp
 bcs    $C393
 sta    $C002
 bpl    $C398
 sta    $C001
 rts
 ora    #$80
 cmp    #$FB
 bcs    $C3A5
 cmp    #$E1
 bcc    $C3A5
 and    #$DF
 rts
 pha
 lda    #$08
 .byte  $1C
 .byte  $FB
 .byte  $04
 pla
 jsr    $FDED
 jmp    $FD44
 jsr    $CC9D
 bra    $C3C1
 jsr    $CC9D
 bit    $32
 bmi    $C3C1
 and    #$7F
 phy
 ora    #$00
 bmi    $C3DB
 pha
 lda    $04FB
 ror    a
 pla
 bcc    $C3DB
 bit    $C01E
 bpl    $C3DB
 eor    #$40
 bit    #$60
 beq    $C3DB
 eor    #$40
 bit    $C01F
 bpl    $C3F9
 pha
 sta    $C001
 tya
 eor    $20
 lsr    a
 bcs    $C3EE
 lda    $C055
 iny
 tya
 lsr    a
 tay
 pla
 sta    ($28),y
 bit    $C054
 ply
 rts
 sta    ($28),y
 ply
 rts
 brk
 brk
 brk
 cmp    #$20
 cmp    #$00
 cmp    #$03
 cmp    #$00
 bcs    $C40E
 ldy    #$05
 bne    $C462
 sei
 lda    $39
 bcc    $C45E
 pha
 jsr    $FE89
 jsr    $FE93
 pla
 jsr    $C74C
 ldx    $0801
 beq    $C428
 ldx    #$40
 jmp    $0801
 lda    $00
 bne    $C439
 lda    $01
 cmp    #$C4
 bne    $C439
 lda    #$C6
 sta    $01
 jmp    ($0000)
 lda    #$17
 sta    $25
 lda    $C1DB,x
 beq    $C448
 jsr    $FDED
 inx
 bne    $C43D
 jmp    $E000
 jmp    $C71C
 jmp    $C454
 jmp    $C494
 lda    #$28
 ldx    $43
 bmi    $C484
 lda    #$01
 ldy    $42
 cpy    #$04
 bcs    $C484
 ldx    #$0A
 lda    $41,x
 pha
 dex
 bne    $C464
 tya
 clc
 adc    #$14
 jsr    $C752
 ldx    #$00
 pla
 sta    $42,x
 inx
 cpx    #$0A
 bcc    $C473
 ldx    $0578
 ldy    $05F8
 lda    $04F8
 cmp    #$01
 ora    #$00
 rts
 lda    #$01
 bne    $C48F
 lda    #$11
 sta    $04F8
 bne    $C471
 pla
 tay
 cmp    #$FD
 pla
 tax
 adc    #$00
 pha
 tya
 adc    #$03
 pha
 lda    $4B
 pha
 stx    $4B
 ldx    #$09
 lda    $41,x
 pha
 dex
 bne    $C4A8
 sty    $4A
 ldy    #$03
 sta    $0041,y
 lda    ($4A),y
 dey
 bne    $C4B2
 tax
 ldy    #$08
 lda    ($42),y
 sta    $0043,y
 dey
 bpl    $C4BD
 lsr    $44
 bne    $C48D
 txa
 rol    a
 cmp    #$14
 bcs    $C489
 bcc    $C46E
 sty    $48
 sta    $49
 ldy    #$01
 lda    ($48),y
 cmp    #$40
 beq    $C4E0
 jmp    $BD04
 ldy    #$04
 jsr    $C462
 beq    $C4E9
 lda    #$80
 ldy    #$0D
 sta    ($48),y
 rts
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 ora    ($01),y
 brk
 brk
 .byte  'O'
 lsr    $20A2
 ldx    #$00
 ldx    #$03
 cmp    #$00
 bcs    $C521
 sec
 bcs    $C50E
 clc
 ldx    #$05
 ror    $0473,x
 clc
 ldx    #$C5
 stx    $07F8
 ldx    #$05
 lda    $CFFF
 jmp    $C797
 ldx    #$05
 stx    $58
 lda    #$C5
 sta    $07F8
 jsr    $C576
 ldy    #$05
 lda    $C570,y
 sta    $0042,y
 dey
 bpl    $C52F
 jsr    $C50A
 bcs    $C552
 ldx    $0800
 dex
 bne    $C552
 ldx    $0801
 beq    $C552
 lda    $58
 asl    a
 asl    a
 asl    a
 asl    a
 tax
 jmp    $0801
 ldx    #$10
 lda    $C55F,x
 sta    $07DB,x
 dex
 bpl    $C554
 bra    $C55D
 .byte  $C3
 inx
 sbc    $E3
 .byte  $EB
 ldy    #$C4
 sbc    #$F3
 .byte  $EB
 ldy    #$C4
 sbc    ($E9)
 inc    $E5,x
 ldx    $5001
 brk
 php
 brk
 brk
 ldx    #$08
 lda    $C583,x
 sta    $02,x
 dex
 bpl    $C578
 jmp    $0002
 jsr    $C50D
 ora    $09
 brk
 rts
 ora    ($00,x)
 brk
 brk
 ldx    #$03
 ldy    #$00
 stx    $3C
 txa
 asl    a
 bit    $3C
 beq    $C5AA
 ora    $3C
 eor    #$FF
 and    #$7E
 bcs    $C5AA
 lsr    a
 bne    $C5A0
 tya
 sta    $0356,x
 iny
 inx
 bpl    $C592
 lda    #$08
 sta    $27
 ldy    #$7F
 rts
 lda    $0200,y
 iny
 jmp    $C399

 STR    "Apple //c"    ; Power on boot message

 jsr    $F8D0
 jsr    $F953
 sta    $3A
 sty    $3B
 rts
 phy
 bcs    $C5EE
 ldy    #$C7
 cpy    $39
 bne    $C5DC
 ldy    $38
 beq    $C5EE
 phx
 pha
 and    #$7F
 cmp    #$02
 bcs    $C5EA
 jsr    $C71C
 jsr    $C73A
 pla
 plx
 ply
 rts
 jmp    $C79D
 brk
 brk
 brk
 brk
 jmp    $C552
 jmp    $C576
 brk
 brk
 brk
 .byte  $BF
 asl    a
 ldx    #$20
 ldy    #$00
 stz    $03
 stz    $3C
 lda    #$60
 tax
 stx    $2B
 sta    $4F
 phy
 lda    $C08E,x
 lda    $C08C,x
 ply
 lda    $C0EA,y
 lda    $C089,x
 ldy    #$50
 lda    $C080,x
 tya
 and    #$03
 asl    a
 ora    $2B
 tax
 lda    $C081,x
 lda    #$56
 jsr    $FCA8
 dey
 bpl    $C61F
 sta    $26
 sta    $3D
 sta    $41
 jsr    $C58E
 stz    $03
 clc
 php
 plp
 ldx    $2B
 dec    $03
 bne    $C656
 lda    $C088,x
 lda    $01
 cmp    #$C6
 bne    $C5F5
 jmp    $C500
 brk
 brk
 php
 dey
 bne    $C65E
 beq    $C641
 bra    $C63D
 lda    $C08C,x
 bpl    $C65E
 eor    #$D5
 bne    $C657
 lda    $C08C,x
 bpl    $C667
 cmp    #$AA
 bne    $C663
 nop
 lda    $C08C,x
 bpl    $C671
 cmp    #$96
 beq    $C683
 plp
 bcc    $C63F
 eor    #$AD
 beq    $C6A6
 bne    $C63F
 ldy    #$03
 sta    $40
 lda    $C08C,x
 bpl    $C687
 rol    a
 sta    $3C
 lda    $C08C,x
 bpl    $C68F
 and    $3C
 dey
 bne    $C685
 plp
 cmp    $3D
 bne    $C63F
 lda    $40
 cmp    $41
 bne    $C63F
 bcs    $C642
 ldy    #$56
 sty    $3C
 ldy    $C08C,x
 bpl    $C6AA
 eor    $02D6,y
 ldy    $3C
 dey
 sta    $0300,y
 bne    $C6A8
 sty    $3C
 ldy    $C08C,x
 bpl    $C6BC
 eor    $02D6,y
 ldy    $3C
 sta    ($26),y
 iny
 bne    $C6BA
 ldy    $C08C,x
 bpl    $C6CB
 eor    $02D6,y
 bne    $C6A2
 ldy    #$00
 ldx    #$56
 dex
 bmi    $C6D7
 lda    ($26),y
 lsr    $0300,x
 rol    a
 lsr    $0300,x
 rol    a
 sta    ($26),y
 iny
 bne    $C6D9
 inc    $27
 inc    $3D
 lda    $3D
 cmp    $0800
 ldx    $4F
 bcc    $C6D3
 jmp    $0801
 brk
 brk
 brk
 brk
 brk
 bra    $C707
 ldx    #$03
 rts
 sec
 bcc    $C720
 jmp    $C5CF
 ora    ($20,x)
 .byte  $02
 .byte  $02
 .byte  $02
 .byte  $02
 brk
 .byte  $1C
 .byte  $22
 plp
 rol    $341A
 dec    a
 rti
 clc
 rts
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
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
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
 jmp    $C7F1
 sta    $C028
 jmp    $C7F6
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
 jsr    $CE23
 bra    $C784
 jsr    $CE4D
 bra    $C784
 dec    $00,x
 brk
 brk
 brk
 jmp    $C19E
 clv
 pha
 phx
 tsx
 pla
 pla
 pla
 txs
 phy
 ldx    $C066
 ldy    $C067
 cld
 and    #$10
 cmp    #$10
 lda    $C018
 and    $C01C
 and    #$80
 beq    $C826
 sta    $C054
 lda    #$40
 bvc    $C82A
 ora    #$01
 bit    $C013
 bpl    $C834
 sta    $C002
 ora    #$20
 bit    $C014
 bpl    $C83E
 sta    $C004
 ora    #$10
 bcs    $C848
 pha
 jsr    $C7BB
 bcc    $C882
 pla
 clc
 bit    $C012
 bra    $C850
 jmp    $C1A8
 bpl    $C85E
 ora    #$0C
 bit    $C011
 bpl    $C85B
 eor    #$06
 sta    $C081
 bit    $C016
 bpl    $C870
 tsx
 stx    $0101
 ldx    $0100
 txs
 sta    $C008
 ora    #$80
 bcs    $C8A7
 pha
 lda    #$C8
 pha
 lda    #$7F
 pha
 lda    #$04
 pha
 jmp    ($03FE)
 lda    $C081
 pla
 bpl    $C88C
 sta    $C009
 ldx    $0101
 txs
 ldy    #$06
 bpl    $C896
 ldx    $CF86,y
 inc    $C000,x
 dey
 bmi    $C89C
 asl    a
 bne    $C88E
 asl    a
 asl    a
 ply
 plx
 pla
 bcs    $C8A4
 rti
 jmp    $C780
 bmi    $C8C9
 bit    #$09
 beq    $C8C9
 and    #$FE
 pha
 tsx
 pla
 pla
 pla
 pla
 pla
 pla
 ply
 cpy    #$C1
 bcc    $C8C7
 sbc    #$02
 bcs    $C8C1
 dey
 phy
 pha
 txs
 jmp    $C87F
 txs
 pla
 jmp    $FA47
 lda    $C000
 bpl    $C8D5
 sta    $C010
 rts
 jsr    $C8E6
 bpl    $C8D4
 bcc    $C8CC
 phy
 ldy    #$80
 jsr    $C7DF
 ply
 ora    #$00
 rts
 bit    $05FA
 bpl    $C8FB
 sec
 php
 pha
.if ROMVER = 255
 lda    $0660
.elseif ROMVER = 0
 lda    $06FF
.elseif ROMVER = 3
 lda    $06FF
.elseif ROMVER = 4
 lda    $06FC
.endif
 cmp    $05FC
 beq    $C8F9
 pla
 plp
 rts
 pla
 plp
 bit    $C000
 clc
 rts
 lda    $07FF
 cmp    #$01
 beq    $C90D
 lda    $C070
 jmp    $FB21
 cpx    #$01
 ror    a
 tay
 lda    $057F,y
 beq    $C918
 lda    #$FF
 ora    $047F,y
 tay
 rts
 jsr    $CA3B
 sty    $34
 cmp    $F9BA,x
 bne    $C93A
 jsr    $CA3B
 cmp    $F9B4,x
 beq    $C93C
 lda    $F9B4,x
 beq    $C93B
 cmp    #$A4
 beq    $C93B
 ldy    $34
 clc
 dey
 rol    $44
 cpx    #$03
 bne    $C94F
 jsr    $FFA7
 lda    $3F
 beq    $C94A
 inx
 stx    $35
 ldx    #$03
 dey
 stx    $3D
 dex
 bpl    $C91D
 rts
 sbc    #$81
 lsr    a
 bne    $C96E
 ldy    $3F
 ldx    $3E
 bne    $C961
 dey
 dex
 txa
 clc
 sbc    $3A
 sta    $3E
 bpl    $C96B
 iny
 tya
 sbc    $3B
 bne    $C9C7
 ldy    $2F
 lda    $003D,y
 sta    ($3A),y
 dey
 bpl    $C972
 jsr    $F948
 jsr    $FC1A
 jsr    $FC1A
 jsr    $C5C4
 lda    #$A1
 sta    $33
 jsr    $FD67
 bra    $C9D8
 lda    $3D
 jsr    $F88E
 tax
 lda    $FA00,x
 cmp    $42
 bne    $C9BD
 lda    $F9C0,x
 bra    $C9AD
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 jmp    $C1B4
 cmp    $43
 bne    $C9BD
 lda    $44
 ldy    $2E
 cpy    #$9D
 beq    $C955
 cmp    $2E
 beq    $C970
 dec    $3D
 bne    $C98F
 inc    $44
 dec    $35
 beq    $C98F
 ldy    $34
 tya
 tax
 jsr    $F94A
 lda    #$DE
 jsr    $FDED
 jsr    $FF3A
 bra    $C986
 jsr    $FFC7
 lda    $0200
 cmp    #$A0
 beq    $C9F4
 cmp    #$8D
 bne    $C9E7
 rts
 jsr    $FFA7
 cmp    #$93
 bne    $C9C9
 txa
 beq    $C9C9
 jsr    $FE78
 lda    #$03
 sta    $3D
 jsr    $CA3B
 asl    a
 sbc    #$BE
 cmp    #$C2
 bcc    $C9C9
 asl    a
 asl    a
 ldx    #$04
 asl    a
 rol    $42
 rol    $43
 dex
 bpl    $CA06
 dec    $3D
 beq    $CA06
 bpl    $C9F8
 ldx    #$05
 jsr    $C91D
 lda    $44
 asl    a
 asl    a
 ora    $35
 cmp    #$20
 bcs    $CA29
 ldx    $35
 beq    $CA29
 ora    #$80
 sta    $44
 sty    $34
 lda    $0200,y
 cmp    #$BB
 beq    $CA38
 cmp    #$8D
 bne    $C9EC
 jmp    $C98F
 jsr    $C5B4
 cmp    #$A0
 beq    $CA3B
 rts
 bit    $C061
 bpl    $CA50
 ldx    #$07
 jsr    $FCA8
 dex
 bne    $CA4A
 bit    $C062
 bmi    $CAA6
 jsr    $FE75
 clc
 jsr    $CB0D
 pla
 sta    $2C
 pla
 sta    $2D
 ldx    #$08
 lda    $CB04,x
 sta    $3C,x
 dex
 bne    $CA64
 lda    ($3A,x)
 beq    $CAA6
 ldy    $2F
 cmp    #$20
 beq    $CAC0
 cmp    #$60
 beq    $CAB0
 cmp    #$4C
 beq    $CAC8
 cmp    #$6C
 beq    $CAC9
 cmp    #$7C
 beq    $CAE3
 cmp    #$40
 beq    $CAAC
 cmp    #$80
 bne    $CA90
 lda    #$10
 and    #$1F
 eor    #$14
 cmp    #$04
 beq    $CA9A
 lda    ($3A),y
 sta    $003C,y
 dey
 bpl    $CA98
 jsr    $FF3F
 jmp    $003C
 lda    #$64
 ldx    #$FF
 bra    $CAD9
 clc
 pla
 sta    $48
 pla
 sta    $3A
 pla
 sta    $3B
 lda    $2F
 jsr    $F956
 sty    $3B
 clc
 bcc    $CAD1
 clc
 jsr    $F954
 phy
 pha
 ldy    #$02
 clc
 lda    ($3A),y
 tax
 dey
 lda    ($3A),y
 stx    $3B
 sta    $3A
 bcs    $CAC8
 ldx    $2D
 lda    $2C
 phx
 pha
 lda    #$27
 sta    $24
 sec
 jmp    $CB0D
 clc
 lda    $3A
 adc    $46
 sta    $3A
 bcc    $CAEE
 inc    $3B
 sec
 bra    $CAC9
 clc
 ldy    #$01
 lda    ($3A),y
 jsr    $F956
 sta    $3A
 tya
 sec
 bcs    $CAB4
 jsr    $FF4A
 sec
 bcs    $CAB6
 nop
 nop
 jmp    $CAFF
 jmp    $CAF1
 lda    $36
 pha
 lda    $37
 pha
 lda    #$F0
 sta    $36
 lda    #$FD
 sta    $37
 bcs    $CB22
 jsr    $F8D0
 bra    $CB25
 jsr    $FADA
 pla
 sta    $37
 pla
 sta    $36
 rts
 brk
 brk
 brk
 brk
 phx
 ldx    #$00
 bra    $CB38
 phx
 ldx    #$01
 ldy    $21
 bit    $C01F
 bpl    $CB57
 sta    $C001
 tya
 lsr    a
 tay
 lda    $20
 lsr    a
 clv
 bcc    $CB4E
 bit    $CBC1
 rol    a
 eor    $21
 lsr    a
 bvs    $CB57
 bcs    $CB57
 dey
 sty    $05F8
 lda    $C01F
 php
 lda    $22
 cpx    #$00
 bne    $CB67
 lda    $23
 dec    a
 sta    $0578
 jsr    $FC24
 lda    $28
 sta    $2A
 lda    $29
 sta    $2B
 lda    $0578
 cpx    #$00
 bne    $CB83
 cmp    $22
 beq    $CBB9
 dec    a
 bra    $CB88
 inc    a
 cmp    $23
 bcs    $CBB9
 sta    $0578
 jsr    $FC24
 ldy    $05F8
 plp
 php
 bpl    $CBB4
 lda    $C055
 tya
 beq    $CBA2
 lda    ($28),y
 sta    ($2A),y
 dey
 bne    $CB9B
 bvs    $CBA8
 lda    ($28),y
 sta    ($2A),y
 lda    $C054
 ldy    $05F8
 bcs    $CBB4
 lda    ($28),y
 sta    ($2A),y
 dey
 bpl    $CBB0
 bra    $CB6D
 jsr    $FCA0
 jsr    $FC22
 plp
 plx
 rts
 bit    $C01F
 bmi    $CBDA
 sta    ($28),y
 iny
 cpy    $21
 bcc    $CBC7
 rts
 phx
 ldx    #$D8
 ldy    #$14
 lda    $32
 and    #$A0
 bra    $CBF1
 phx
 pha
 tya
 pha
 sec
 sbc    $21
 tax
 tya
 lsr    a
 tay
 pla
 eor    $20
 ror    a
 bcs    $CBEE
 bpl    $CBEE
 iny
 pla
 bcs    $CBFC
 bit    $C055
 sta    ($28),y
 bit    $C054
 inx
 beq    $CC02
 sta    ($28),y
 iny
 inx
 bne    $CBF1
 plx
 rts
 stz    $05FA
 stz    $05F9
 rts
 lda    $04FB
 and    #$10
 bne    $CC1C
 jsr    $CC1D
 pha
 eor    #$80
 jsr    $C3B3
 pla
 rts
 phy
 jsr    $CC9D
 lda    $C01F
 bpl    $CC3D
 sta    $C001
 tya
 eor    $20
 ror    a
 bcs    $CC33
 lda    $C055
 iny
 tya
 lsr    a
 tay
 lda    ($28),y
 sta    $C054
 bra    $CC3F
 lda    ($28),y
 bit    $C01E
 bpl    $CC4A
 cmp    #$20
 bcs    $CC4A
 ora    #$40
 ply
 rts
 ldy    $07FB
 bne    $CC53
 bra    $CC12
 jsr    $CC1D
 pha
 sta    $077B
 tya
 iny
 beq    $CC6B
 ply
 phy
 bmi    $CC6B
 lda    $C01E
 ora    #$7F
 lsr    a
 and    $07FB
 jsr    $C3B3
 pla
 rts
 pha
 inc    $4E
 bne    $CC93
 lda    $4F
 inc    $4F
 eor    $4F
 and    #$10
 beq    $CC93
 lda    $07FB
 beq    $CC93
 phy
 jsr    $CC1D
 ldy    $077B
 sta    $077B
 tya
 jsr    $C3B3
 ply
 pla
 jsr    $C8E6
 bpl    $CCBF
 jmp    $CFC3
 nop
 ldy    $24
 cpy    $047B
 bne    $CCA7
 ldy    $057B
 cpy    $21
 bcc    $CCAD
 ldy    #$00
 sty    $057B
 bit    $C01F
 bpl    $CCB7
 ldy    #$00
 sty    $24
 sty    $047B
 ldy    $057B
 rts
 lda    $CD0C,y
 phy
 jsr    $CD58
 ply
 cpy    #$08
 bcs    $CCED
 jsr    $CC1D
 pha
 and    #$80
 eor    #$AB
 jsr    $C3B3
 jsr    $C8E6
 bpl    $CCD7
 pla
 jsr    $CC99
 jsr    $C39B
 ldy    #$13
 cmp    $CCF8,y
 beq    $CCC0
 dey
 bpl    $CCE5
 lda    #$08
 .byte  $1C
 .byte  $FB
 .byte  $04
 jsr    $FD0C
 jmp    $FD44
 dex
 dey
 cmp    $958B
 txa
 cmp    #$CB
 .byte  $C2
 .byte  $C3
 cpy    $C1
 cpy    #$C5
 dec    $B4
 clv
 sta    ($84),y
 sta    $88
 dey
 txa
 .byte  $9F
 stz    $9F8A
 stz    $8A88
 .byte  $9F
 stz    $9D8C
 .byte  $8B
 sta    ($92),y
 sta    $04,x
 ora    $0085
 stx    $8E
 .byte  $8F
 stx    $97,y
 tya
 sta    $9B9A,y
 ror    $FC
 inc    a
 .byte  $FC
 ldy    #$FB
 cli
 .byte  $FC
 stz    $42FC
 .byte  $FC
 cpy    #$CD
 ldx    $45CD,y
 dec    $CD91
 sta    $CD,x
 bit    #$CD
 sta    $B0CD
 cmp    $CDB7
 bmi    $CD15
 and    $CB,x
 .byte  $9F
 cmp    $CDA5
 ldy    #$FC
 sta    $2CCD,y
 cmp    ($CB,x)
 bvc    $CD11
 phx
 sta    $04F8
 jsr    $FC04
 cmp    $04F8
 bne    $CD6F
 ldx    #$14
 cmp    $CD15,x
 beq    $CD71
 dex
 bpl    $CD67
 plx
 rts
 pha
 bvc    $CD80
 lda    $04FB
 and    #$28
 eor    #$08
 beq    $CD80
 pla
 plx
 rts
 txa
 asl    a
 tax
 pla
 jsr    $FCA4
 plx
 rts
 lda    #$10
 bra    $CD9B
 lda    #$10
 bra    $CDA1
 lda    #$20
 bra    $CDA1
 lda    #$20
 bra    $CD9B
 lda    #$01
 .byte  $1C
 .byte  $FB
 .byte  $04
 rts
 lda    #$01
 .byte  $0C
 .byte  $FB
 .byte  $04
 rts
 jsr    $FEE9
 tay
 lda    $22
 sta    $25
 jmp    $FC88
 jsr    $FE84
 lda    #$04
 bra    $CD9B
 jsr    $FE80
 lda    #$04
 bra    $CDA1
 sec
 bcc    $CDD9
 bit    $04FB
 bpl    $CE1A
 php
 jsr    $CE1B
 plp
 bra    $CDD5
 bit    $C01F
 bpl    $CE1A
 clc
 bcs    $CE0D
 stz    $22
 bit    $C01A
 bmi    $CDE0
 lda    #$14
 sta    $22
 bit    $C01F
 php
 bcs    $CDED
 bpl    $CDF2
 jsr    $CE53
 bra    $CDF2
 bmi    $CDF2
 jsr    $CE80
 jsr    $CC9D
 tya
 clc
 adc    $20
 plp
 bcs    $CE02
 cmp    #$28
 bcc    $CE02
 lda    #$27
 jsr    $FEEC
 lda    $25
 jsr    $FBC1
 stz    $20
 lda    #$18
 sta    $23
 lda    #$28
 bit    $C01F
 bpl    $CE18
 asl    a
 sta    $21
 rts
 bit    $067B
 bpl    $CE31
 jsr    $C338
 lda    #$05
 sta    $38
 lda    #$07
 sta    $36
 lda    #$C3
 sta    $39
 sta    $37
 stz    $07FB
 lda    #$08
 and    $04FB
 ora    #$81
 sta    $04FB
 stz    $067B
 sta    $C00F
 rts
 bit    $04FB
 bpl    $CE44
 jsr    $CDD2
 jsr    $FE89
 jmp    $FE93
 ldx    #$17
 sta    $C001
 txa
 jsr    $FBC1
 ldy    #$27
 phy
 tya
 lsr    a
 bcs    $CE66
 bit    $C055
 tay
 lda    ($28),y
 bit    $C054
 ply
 sta    ($28),y
 dey
 bpl    $CE5E
 dex
 bmi    $CE79
 cpx    $22
 bcs    $CE58
 sta    $C000
 sta    $C00C
 rts
 ldx    #$17
 txa
 jsr    $FBC1
 ldy    #$00
 sta    $C001
 lda    ($28),y
 phy
 pha
 tya
 lsr    a
 bcs    $CE96
 sta    $C055
 tay
 pla
 sta    ($28),y
 sta    $C054
 ply
 iny
 cpy    #$28
 bcc    $CE8B
 jsr    $CBCF
 dex
 bmi    $CEAD
 cpx    $22
 bcs    $CE82
 sta    $C00D
 rts
 tax
 beq    $CEBC
 dex
 bne    $CEBE
 jsr    $C8E6
 bpl    $CEC0
 sec
 rts
 ldx    #$03
 clc
 rts
 ora    #$80
 tax
 jsr    $CF54
 lda    #$08
 bit    $04FB
 bne    $CEFA
 txa
 bit    #$60
 beq    $CF19
 ldy    $057B
 bit    $32
 bmi    $CEDD
 and    #$7F
 jsr    $C3C1
 iny
 sty    $057B
 cpy    $21
 bcc    $CEF4
 jsr    $C360
 jsr    $FEE9
 jsr    $FC66
 jsr    $C354
 jsr    $CC0B
 ldx    #$00
 rts
 jsr    $CC0B
 txa
 sec
 sbc    #$A0
 bit    $06FB
 bmi    $CF30
 sta    $05FB
 jsr    $CF71
 ldy    $06FB
 jsr    $CCAD
 lda    #$08
 .byte  $1C
 .byte  $FB
 .byte  $04
 bra    $CEF4
 jsr    $CC0B
 txa
 cmp    #$9E
 beq    $CF29
 jsr    $C360
 jsr    $CD58
 bra    $CEF1
 lda    #$08
 .byte  $0C
 .byte  $FB
 .byte  $04
 lda    #$FF
 sta    $06FB
 bra    $CEF4
 jsr    $CF54
 jsr    $C8D5
 bpl    $CF38
 and    #$7F
 bra    $CEF7
 lda    #$01
 jsr    $CE3B
 jsr    $CF51
 jsr    $CDD4
 jsr    $FC58
 bra    $CEF1
 jsr    $C360
 stz    $22
 jsr    $CE0A
 lda    #$FF
 sta    $32
 lda    #$04
 bit    $04FB
 beq    $CF66
 lsr    $32
 ldy    $057B
 jsr    $CCAD
 lda    $05FB
 sta    $25
 asl    a
 tay
 lsr    a
 lsr    a
 and    #$03
 ora    #$04
 sta    $29
 tya
 ror    a
 and    #$98
 sta    $28
 asl    a
 asl    a
 .byte  $04
 plp
 rts
 .byte  $83
 .byte  $8B
 .byte  $8B
 ora    $03
 eor    $9E,x
 .byte  $0B
 rti
 bvc    $CFA7
 .byte  $0B
 ora    ($00,x)
 cmp    $D8C1
 cmp    $D3D0,y
 jsr    $CFA0
 jmp    $C784
 jsr    $C360
 lda    $C016
 asl    a
 ldy    #$01
 lda    $FFFE,y
 sta    $C009
 sta    $FFFE,y
 sta    $C008
 sta    $FFFE,y
 dey
 bpl    $CFA9
 bcc    $CFC0
 sta    $C009
 jmp    $C354
 phy
 jsr    $C3B3
 ply
 jmp    $C8D5
 bcs    $CFDE
 cmp    #$A0
 bne    $CFE4
 lda    $0200,y
 ldx    #$07
 cmp    #$8D
 beq    $CFE1
 iny
 jmp    $FF90
 jmp    $FF8A
 jmp    $FFA7
 rts
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
 brk
.if ROMVER = 255
 .byte  $67
.elseif ROMVER = 0
 .byte  $44
.elseif ROMVER = 3
 .byte  $D0
.elseif ROMVER = 4
 .byte  $D3
.endif
 .byte  'o'
 cld
 adc    $D7
 sed
 .byte  $DC
 sty    $D9,x
 lda    ($DB),y
 bmi    $CFFF
 cld
 .byte  $DF
 sbc    ($DB,x)
 .byte  $8F
 .byte  $F3
 tya
 .byte  $F3
 cpx    $F1
 cmp    $D4F1,x
 sbc    ($24),y
 sbc    ($31)
 sbc    ($40)
 sbc    ($D7)
 .byte  $F3
 sbc    ($F3,x)
 inx
 inc    $FD,x
 inc    $68,x
 .byte  $F7
 ror    $E6F7
 .byte  $F7
 .byte  'W'
 .byte  $FC
 jsr    $26F7
 .byte  $F7
 .byte  $F4
 .byte  $03
 jmp    ($6EF2)
 sbc    ($72)
 sbc    ($76)
 sbc    ($7F)
 sbc    ($4E)
 sbc    ($6A)
 cmp    $F255,y
 sta    $F2
 lda    $F2
 dex
 sbc    ($17)
 .byte  $F3
 .byte  $F4
 .byte  $03
 .byte  $F4
 .byte  $03
 adc    ($F2,x)
 eor    $DA
 and    $11D9,x
 cmp    $D9C8,y
 pha
 cld
 .byte  $F4
 .byte  $03
 jsr    $6AD9
 cmp    $D9DB,y
 adc    $EBD8
 cmp    $E783,y
 .byte  $F4
 .byte  $03
 .byte  $F4
 .byte  $03
 ora    ($E3)
 ply
 .byte  $E7
 .byte  $D4
 phx
 sta    $D8,x
 ldy    $D6
 adc    #$D6
 .byte  $9F
 .byte  $DB
 pha
 dec    $90,x
 .byte  $EB
 .byte  $23
 cpx    $EBAF
 asl    a
 brk
 dec    $12E2,x
 .byte  $D4
 cmp    $FFDF
 .byte  $E2
 sta    $AEEE
 .byte  $EF
 eor    ($E9,x)
 ora    #$EF
 nop
 .byte  $EF
 sbc    ($EF),y
 dec    a
 beq    $D03D
 beq    $D105
 .byte  $E7
 dec    $E6,x
 cmp    $E3
 .byte  $07
 .byte  $E7
 sbc    $E6
 lsr    $E6
 phy
 inc    $86
 inc    $91
 inc    $79
 cpy    #$E7
 adc    $E7A9,y
 .byte  '{'
 sta    ($E9,x)
 .byte  '{'
 pla
 nop
 adc    $EE96,x
 bvc    $D117
 .byte  $DF
 lsr    $4E
 .byte  $DF
 .byte  $7F
 .byte  $CF
 inc    $977F
 dec    $6464,x
 .byte  $DF
 eor    $4E
 cpy    $46
 .byte  'O'
 cmp    ($4E)
 eor    $58
 .byte  $D4
 .byte  'D'
 eor    ($54,x)
 cmp    ($49,x)
 lsr    $5550
 .byte  $D4
 .byte  'D'
 eor    $CC
 .byte  'D'
 eor    #$CD
 eor    ($45)
 eor    ($C4,x)
 .byte  'G'
 cmp    ($54)
 eor    $58
 .byte  $D4
 bvc    $D147
 .byte  $A3
 eor    #$4E
 .byte  $A3
 .byte  'C'
 eor    ($4C,x)
 cpy    $4C50
 .byte  'O'
 .byte  $D4
 pha
 jmp    $CE49
 lsr    $4C,x
 eor    #$CE
 pha
 .byte  'G'
 eor    ($B2)
 pha
 .byte  'G'
 cmp    ($48)
 .byte  'C'
 .byte  'O'
 jmp    $524F
 lda    $5048,x
 jmp    $D44F
 .byte  'D'
 eor    ($41)
 .byte  $D7
 cli
 .byte  'D'
 eor    ($41)
 .byte  $D7
 pha
 .byte  'T'
 eor    ($C2,x)
 pha
 .byte  'O'
 eor    $52C5
 .byte  'O'
 .byte  'T'
 lda    $4353,x
 eor    ($4C,x)
 eor    $BD
 .byte  'S'
 pha
 jmp    $414F
 cpy    $54
 eor    ($41)
 .byte  'C'
 cmp    $4E
 .byte  'O'
 .byte  'T'
 eor    ($41)
 .byte  'C'
 cmp    $4E
 .byte  'O'
 eor    ($4D)
 eor    ($CC,x)
 eor    #$4E
 lsr    $45,x
 eor    ($53)
 cmp    $46
 jmp    $5341
 iny
 .byte  'C'
 .byte  'O'
 jmp    $524F
 lda    $4F50,x
 bne    $D1BB
 .byte  'T'
 eor    ($C2,x)
 pha
 eor    #$4D
 eor    $4D
 tsx
 jmp    $4D4F
 eor    $4D
 tsx
 .byte  'O'
 lsr    $5245
 cmp    ($52)
 eor    $53
 eor    $4D,x
 cmp    $52
 eor    $43
 eor    ($4C,x)
 cpy    $5453
 .byte  'O'
 eor    ($C5)
 .byte  'S'
 bvc    $D1D2
 eor    $44
 lda    $454C,x
 .byte  $D4
 .byte  'G'
 .byte  'O'
 .byte  'T'
 .byte  $CF
 eor    ($55)
 dec    $C649
 eor    ($45)
 .byte  'S'
 .byte  'T'
 .byte  'O'
 eor    ($C5)
 ldx    $47
 .byte  'O'
 .byte  'S'
 eor    $C2,x
 eor    ($45)
 .byte  'T'
 eor    $52,x
 dec    $4552
 cmp    $5453
 .byte  'O'
 bne    $D206
 dec    $4157
 eor    #$D4
 jmp    $414F
 cpy    $53
 eor    ($56,x)
 cmp    $44
 eor    $C6
 bvc    $D218
 .byte  'K'
 cmp    $50
 eor    ($49)
 lsr    $43D4
 .byte  'O'
 lsr    $4CD4
 eor    #$53
 .byte  $D4
 .byte  'C'
 jmp    $4145
 cmp    ($47)
 eor    $D4
 lsr    $D745
 .byte  'T'
 eor    ($42,x)
 tay
 .byte  'T'
 .byte  $CF
 lsr    $CE
 .byte  'S'
 bvc    $D231
 tay
 .byte  'T'
 pha
 eor    $CE
 eor    ($D4,x)
 lsr    $D44F
 .byte  'S'
 .byte  'T'
 eor    $D0
 .byte  $AB
 lda    $AFAA
 dec    $4E41,x
 cpy    $4F
 cmp    ($BE)
 lda    $53BC,x
 .byte  'G'
 dec    $4E49
 .byte  $D4
 eor    ($42,x)
 .byte  $D3
 eor    $53,x
 cmp    ($46)
 eor    ($C5)
 .byte  'S'
 .byte  'C'
 eor    ($4E)
 tay
 bvc    $D263
 cpy    $4F50
 .byte  $D3
 .byte  'S'
 eor    ($D2),y
 eor    ($4E)
 cpy    $4C
 .byte  'O'
 .byte  $C7
 eor    $58
 bne    $D273
 .byte  'O'
 .byte  $D3
 .byte  'S'
 eor    #$CE
 .byte  'T'
 eor    ($CE,x)
 eor    ($54,x)
 dec    $4550
 eor    $CB
 jmp    $CE45
 .byte  'S'
 .byte  'T'
 eor    ($A4)
 lsr    $41,x
 cpy    $5341
 .byte  $C3
 .byte  'C'
 pha
 eor    ($A4)
 jmp    $4645
 .byte  'T'
 ldy    $52
 eor    #$47
 pha
 .byte  'T'
 ldy    $4D
 eor    #$44
 ldy    $00
 lsr    $5845
 .byte  'T'
 jsr    $4957
 .byte  'T'
 pha
 .byte  'O'
 eor    $54,x
 jsr    $4F46
 cmp    ($53)
 eor    $544E,y
 eor    ($D8,x)
 eor    ($45)
 .byte  'T'
 eor    $52,x
 lsr    $5720
 eor    #$54
 pha
 .byte  'O'
 eor    $54,x
 jsr    $4F47
 .byte  'S'
 eor    $C2,x
 .byte  'O'
 eor    $54,x
 jsr    $464F
 jsr    $4144
 .byte  'T'
 cmp    ($49,x)
 jmp    $454C
 .byte  'G'
 eor    ($4C,x)
 jsr    $5551
 eor    ($4E,x)
 .byte  'T'
 eor    #$54
 cmp    $564F,y
 eor    $52
 lsr    $4C
 .byte  'O'
 .byte  $D7
 .byte  'O'
 eor    $54,x
 jsr    $464F
 jsr    $454D
 eor    $524F
 cmp    $4E55,y
 .byte  'D'
 eor    $46
 .byte  $27
 .byte  'D'
 jsr    $5453
 eor    ($54,x)
 eor    $4D
 eor    $4E
 .byte  $D4
 .byte  'B'
 eor    ($44,x)
 jsr    $5553
 .byte  'B'
 .byte  'S'
 .byte  'C'
 eor    ($49)
 bvc    $D2AC
 eor    ($45)
 .byte  'D'
 eor    #$4D
 .byte  $27
 .byte  'D'
 jsr    $5241
 eor    ($41)
 cmp    $4944,y
 lsr    $49,x
 .byte  'S'
 eor    #$4F
 lsr    $4220
 eor    $5A20,y
 eor    $52
 .byte  $CF
 eor    #$4C
 jmp    $4745
 eor    ($4C,x)
 jsr    $4944
 eor    ($45)
 .byte  'C'
 .byte  $D4
 .byte  'T'
 eor    $4550,y
 jsr    $494D
 .byte  'S'
 eor    $5441
 .byte  'C'
 iny
 .byte  'S'
 .byte  'T'
 eor    ($49)
 lsr    $2047
 .byte  'T'
 .byte  'O'
 .byte  'O'
 jsr    $4F4C
 lsr    $46C7
 .byte  'O'
 eor    ($4D)
 eor    $4C,x
 eor    ($20,x)
 .byte  'T'
 .byte  'O'
 .byte  'O'
 jsr    $4F43
 eor    $4C50
 eor    $D8
 .byte  'C'
 eor    ($4E,x)
 .byte  $27
 .byte  'T'
 jsr    $4F43
 lsr    $4954
 lsr    $C555
 eor    $4E,x
 .byte  'D'
 eor    $46
 .byte  $27
 .byte  'D'
 jsr    $5546
 lsr    $5443
 eor    #$4F
 dec    $4520
 eor    ($52)
 .byte  'O'
 eor    ($07)
 brk
 jsr    $4E49
 jsr    $0D00
 .byte  'B'
 eor    ($45)
 eor    ($4B,x)
 .byte  $07
 brk
 tsx
 inx
 inx
 inx
 inx
 lda    $0101,x
 cmp    #$81
 bne    $D392
 lda    $86
 bne    $D37F
 lda    $0102,x
 sta    $85
 lda    $0103,x
 sta    $86
 cmp    $0103,x
 bne    $D38B
 lda    $85
 cmp    $0102,x
 beq    $D392
 txa
 clc
 adc    #$12
 tax
 bne    $D36A
 rts
 jsr    $D3E3
 sta    $6D
 sty    $6E
 sec
 lda    $96
 sbc    $9B
 sta    $5E
 tay
 lda    $97
 sbc    $9C
 tax
 inx
 tya
 beq    $D3CE
 lda    $96
 sec
 sbc    $5E
 sta    $96
 bcs    $D3B7
 dec    $97
 sec
 lda    $94
 sbc    $5E
 sta    $94
 bcs    $D3C7
 dec    $95
 bcc    $D3C7
 lda    ($96),y
 sta    ($94),y
 dey
 bne    $D3C3
 lda    ($96),y
 sta    ($94),y
 dec    $97
 dec    $95
 dex
 bne    $D3C7
 rts
 asl    a
 adc    #$36
 bcs    $D410
 sta    $5E
 tsx
 cpx    $5E
 bcc    $D410
 rts
 cpy    $70
 bcc    $D40F
 bne    $D3ED
 cmp    $6F
 bcc    $D40F
 pha
 ldx    #$09
 tya
 pha
 lda    $93,x
 dex
 bpl    $D3F1
 jsr    $E484
 ldx    #$F7
 pla
 sta    $9D,x
 inx
 bmi    $D3FC
 pla
 tay
 pla
 cpy    $70
 bcc    $D40F
 bne    $D410
 cmp    $6F
 bcs    $D410
 rts
 ldx    #$4D
 bit    $D8
 bpl    $D419
 jmp    $F2E9
 jsr    $DAFB
 jsr    $DB5A
 lda    $D260,x
 pha
 jsr    $DB5C
 inx
 pla
 bpl    $D41F
 jsr    $D683
 lda    #$50
 ldy    #$D3
 jsr    $DB3A
 ldy    $76
 iny
 beq    $D43C
 jsr    $ED19
 jsr    $DAFB
 ldx    #$DD
 jsr    $D52E
 stx    $B8
 sty    $B9
 lsr    $D8
 jsr    $00B1
 tax
 beq    $D43C
 ldx    #$FF
 stx    $76
 bcc    $D45C
 jsr    $D559
 jmp    $D805
 ldx    $AF
 stx    $69
 ldx    $B0
 stx    $6A
 jsr    $DA0C
 jsr    $D559
 sty    $0F
 jsr    $D61A
 bcc    $D4B5
 ldy    #$01
 lda    ($9B),y
 sta    $5F
 lda    $69
 sta    $5E
 lda    $9C
 sta    $61
 lda    $9B
 dey
 sbc    ($9B),y
 clc
 adc    $69
 sta    $69
 sta    $60
 lda    $6A
 adc    #$FF
 sta    $6A
 sbc    $9C
 tax
 sec
 lda    $9B
 sbc    $69
 tay
 bcs    $D49F
 inx
 dec    $61
 clc
 adc    $5E
 bcc    $D4A7
 dec    $5F
 clc
 lda    ($5E),y
 sta    ($60),y
 iny
 bne    $D4A7
 inc    $5F
 inc    $61
 dex
 bne    $D4A7
 lda    $0200
 beq    $D4F2
 lda    $73
 ldy    $74
 sta    $6F
 sty    $70
 lda    $69
 sta    $96
 adc    $0F
 sta    $94
 ldy    $6A
 sty    $97
 bcc    $D4D1
 iny
 sty    $95
 jsr    $D393
 lda    $50
 ldy    $51
 sta    $01FE
 sty    $01FF
 lda    $6D
 ldy    $6E
 sta    $69
 sty    $6A
 ldy    $0F
 lda    $01FB,y
 dey
 sta    ($9B),y
 bne    $D4EA
 jsr    $D665
 lda    $67
 ldy    $68
 sta    $5E
 sty    $5F
 clc
 ldy    #$01
 lda    ($5E),y
 bne    $D50F
 lda    $69
 sta    $AF
 lda    $6A
 sta    $B0
 jmp    $D43C
 ldy    #$04
 iny
 lda    ($5E),y
 bne    $D511
 iny
 tya
 adc    $5E
 tax
 ldy    #$00
 sta    ($5E),y
 lda    $5F
 adc    #$00
 iny
 sta    ($5E),y
 stx    $5E
 sta    $5F
 bcc    $D4FE
 ldx    #$80
 stx    $33
 jsr    $FD6A
 cpx    #$EF
 bcc    $D539
 ldx    #$EF
 lda    #$00
 sta    $0200,x
 txa
 beq    $D54C
 lda    $01FF,x
 and    #$7F
 sta    $01FF,x
 dex
 bne    $D541
 lda    #$00
 ldx    #$FF
 ldy    #$01
 rts
 jsr    $FD0C
 and    #$7F
 rts
 ldx    $B8
 dex
 ldy    #$04
 sty    $13
 bit    $D6
 bpl    $D56C
 pla
 pla
 jsr    $D665
 jmp    $D7D2
 inx
 jsr    $D8B5
 bit    $13
 bvs    $D578
 cmp    #$20
 beq    $D56C
 sta    $0E
 cmp    #$22
 beq    $D5F2
 bvs    $D5CD
 cmp    #$3F
 bne    $D588
 lda    #$BA
 bne    $D5CD
 cmp    #$30
 bcc    $D590
 cmp    #$3C
 bcc    $D5CD
 sty    $AD
 lda    #$D0
 sta    $9D
 lda    #$CF
 sta    $9E
 ldy    #$00
 sty    $0F
 dey
 stx    $B8
 dex
 iny
 bne    $D5A7
 inc    $9E
 inx
 jsr    $D8B5
 cmp    #$20
 beq    $D5A7
 sec
 sbc    ($9D),y
 beq    $D5A2
 cmp    #$80
 bne    $D5F9
 ora    $0F
 cmp    #$C5
 bne    $D5CB
 jsr    $D8B0
 cmp    #$4E
 beq    $D5F9
 cmp    #$4F
 beq    $D5F9
 lda    #$C5
 ldy    $AD
 inx
 iny
 sta    $01FB,y
 lda    $01FB,y
 beq    $D610
 sec
 sbc    #$3A
 beq    $D5E0
 cmp    #$49
 bne    $D5E2
 sta    $13
 sec
 sbc    #$78
 bne    $D56D
 sta    $0E
 jsr    $D8B5
 beq    $D5CD
 cmp    $0E
 beq    $D5CD
 iny
 sta    $01FB,y
 inx
 bne    $D5E9
 ldx    $B8
 inc    $0F
 lda    ($9D),y
 iny
 bne    $D604
 inc    $9E
 asl    a
 bcc    $D5FD
 lda    ($9D),y
 bne    $D5A8
 jsr    $D8C3
 bpl    $D5CB
 sta    $01FD,y
 dec    $B9
 lda    #$FF
 sta    $B8
 rts
 lda    $67
 ldx    $68
 ldy    #$01
 sta    $9B
 stx    $9C
 lda    ($9B),y
 beq    $D647
 iny
 iny
 lda    $51
 cmp    ($9B),y
 bcc    $D648
 beq    $D635
 dey
 bne    $D63E
 lda    $50
 dey
 cmp    ($9B),y
 bcc    $D648
 beq    $D648
 dey
 lda    ($9B),y
 tax
 dey
 lda    ($9B),y
 bcs    $D61E
 clc
 rts
 bne    $D648
 lda    #$00
 sta    $D6
 tay
 sta    ($67),y
 iny
 sta    ($67),y
 lda    $67
 adc    #$02
 sta    $69
 sta    $AF
 lda    $68
 adc    #$00
 sta    $6A
 sta    $B0
 jsr    $D697
 lda    #$00
 bne    $D696
 lda    $73
 ldy    $74
 sta    $6F
 sty    $70
 lda    $69
 ldy    $6A
 sta    $6B
 sty    $6C
 sta    $6D
 sty    $6E
 jsr    $D849
 ldx    #$55
 stx    $52
 pla
 tay
 pla
 ldx    #$F8
 txs
 pha
 tya
 pha
 lda    #$00
 sta    $7A
 sta    $14
 rts
 clc
 lda    $67
 adc    #$FF
 sta    $B8
 lda    $68
 adc    #$FF
 sta    $B9
 rts
 bcc    $D6B1
 beq    $D6B1
 cmp    #$C9
 beq    $D6B1
 cmp    #$2C
 bne    $D696
 jsr    $DA0C
 jsr    $D61A
 jsr    $00B7
 beq    $D6CC
 cmp    #$C9
 beq    $D6C4
 cmp    #$2C
 bne    $D648
 jsr    $00B1
 jsr    $DA0C
 bne    $D696
 pla
 pla
 lda    $50
 ora    $51
 bne    $D6DA
 lda    #$FF
 sta    $50
 sta    $51
 ldy    #$01
 lda    ($9B),y
 beq    $D724
 jsr    $D858
 jsr    $DAFB
 iny
 lda    ($9B),y
 tax
 iny
 lda    ($9B),y
 cmp    $51
 bne    $D6F5
 cpx    $50
 beq    $D6F7
 bcs    $D724
 sty    $85
 jsr    $D8D3
 lda    #$20
 ldy    $85
 and    #$7F
 jsr    $DB5C
 jsr    $D8DD
 nop
 bcc    $D712
 jsr    $DAFB
 lda    #$05
 sta    $24
 iny
 lda    ($9B),y
 bne    $D734
 tay
 lda    ($9B),y
 tax
 iny
 lda    ($9B),y
 stx    $9B
 sta    $9C
 bne    $D6DA
 lda    #$0D
 jsr    $DB5C
 jmp    $D7D2
 iny
 bne    $D731
 inc    $9E
 lda    ($9D),y
 rts
 bpl    $D702
 sec
 sbc    #$7F
 tax
 sty    $85
 ldy    #$D0
 sty    $9D
 ldy    #$CF
 sty    $9E
 ldy    #$FF
 dex
 beq    $D750
 jsr    $D72C
 bpl    $D749
 bmi    $D746
 lda    #$20
 jsr    $DB5C
 jsr    $D72C
 bmi    $D75F
 jsr    $DB5C
 bne    $D755
 jsr    $DB5C
 lda    #$20
 bne    $D6FE
 lda    #$80
 sta    $14
 jsr    $DA46
 jsr    $D365
 bne    $D777
 txa
 adc    #$0F
 tax
 txs
 pla
 pla
 lda    #$09
 jsr    $D3D6
 jsr    $D9A3
 clc
 tya
 adc    $B8
 pha
 lda    $B9
 adc    #$00
 pha
 lda    $76
 pha
 lda    $75
 pha
 lda    #$C1
 jsr    $DEC0
 jsr    $DD6A
 jsr    $DD67
 lda    $A2
 ora    #$7F
 and    $9E
 sta    $9E
 lda    #$AF
 ldy    #$D7
 sta    $5E
 sty    $5F
 jmp    $DE20
 lda    #$13
 ldy    #$E9
 jsr    $EAF9
 jsr    $00B7
 cmp    #$C7
 bne    $D7C3
 jsr    $00B1
 jsr    $DD67
 jsr    $EB82
 jsr    $DE15
 lda    $86
 pha
 lda    $85
 pha
 lda    #$81
 pha
 tsx
 stx    $F8
 jsr    $D858
 lda    $B8
 ldy    $B9
 ldx    $76
 inx
 beq    $D7E5
 sta    $79
 sty    $7A
 ldy    #$00
 lda    ($B8),y
 bne    $D842
 ldy    #$02
 lda    ($B8),y
 clc
 beq    $D826
 iny
 lda    ($B8),y
 sta    $75
 iny
 lda    ($B8),y
 sta    $76
 tya
 adc    $B8
 sta    $B8
 bcc    $D805
 inc    $B9
 bit    $F2
 bpl    $D81D
 ldx    $76
 inx
 beq    $D81D
 lda    #$23
 jsr    $DB5C
 ldx    $75
 lda    $76
 jsr    $ED24
 jsr    $DB57
 jsr    $00B1
 jsr    $D828
 jmp    $D7D2
 beq    $D88A
 beq    $D857
 sbc    #$80
 bcc    $D83F
 cmp    #$40
 bcs    $D846
 asl    a
 tay
 lda    $D001,y
 pha
 lda    $D000,y
 pha
 jmp    $00B1
 jmp    $DA46
 cmp    #$3A
 beq    $D805
 jmp    $DEC9
 sec
 lda    $67
 sbc    #$01
 ldy    $68
 bcs    $D853
 dey
 sta    $7D
 sty    $7E
 rts
 lda    $C000
 cmp    #$83
 beq    $D860
 rts
 jsr    $D553
 ldx    #$FF
 bit    $D8
 bpl    $D86C
 jmp    $F2E9
 cmp    #$03
 bcs    $D871
 clc
 bne    $D8AF
 lda    $B8
 ldy    $B9
 ldx    $76
 inx
 beq    $D888
 sta    $79
 sty    $7A
 lda    $75
 ldy    $76
 sta    $77
 sty    $78
 pla
 pla
 lda    #$5D
 ldy    #$D3
 bcc    $D893
 jmp    $D431
 jmp    $D43C
 bne    $D8AF
 ldx    #$D2
 ldy    $7A
 bne    $D8A1
 jmp    $D412
 lda    $79
 sta    $B8
 sty    $B9
 lda    $77
 ldy    $78
 sta    $75
 sty    $76
 rts
 lda    $0201,x
 bpl    $D8C6
 lda    $0E
 beq    $D8CF
 cmp    #$22
 beq    $D8CF
 lda    $13
 cmp    #$49
 beq    $D8CF
 lda    $0200,x
 php
 cmp    #$61
 bcc    $D8CD
 and    #$5F
 plp
 rts
 lda    $0200,x
 rts
 pha
 lda    #$20
 jsr    $DB5C
 pla
 jmp    $ED24
 lda    $24
 cmp    #$21
 bit    $C01F
 bpl    $D8EB
 lda    $057B
 cmp    #$49
 rts
 lda    $C050
 jsr    $D8F7
 lda    #$14
 jmp    $FB4B
 ldy    #$27
 sty    $2D
 jsr    $F3CB
 lda    #$27
 bcc    $D903
 rol    a
 tay
 lda    #$00
 sta    $30
 jsr    $F78B
 dey
 bpl    $D904
 rts
 brk
 brk
 brk
 php
 dec    $76
 plp
 bne    $D91B
 jmp    $D665
 jsr    $D66C
 jmp    $D935
 lda    #$03
 jsr    $D3D6
 lda    $B9
 pha
 lda    $B8
 pha
 lda    $76
 pha
 lda    $75
 pha
 lda    #$B0
 pha
 jsr    $00B7
 jsr    $D93E
 jmp    $D7D2
 jsr    $DA0C
 jsr    $D9A6
 lda    $76
 cmp    $51
 bcs    $D955
 tya
 sec
 adc    $B8
 ldx    $B9
 bcc    $D959
 inx
 bcs    $D959
 lda    $67
 ldx    $68
 jsr    $D61E
 bcc    $D97C
 lda    $9B
 sbc    #$01
 sta    $B8
 lda    $9C
 sbc    #$00
 sta    $B9
 rts
 bne    $D96A
 lda    #$FF
 sta    $85
 jsr    $D365
 txs
 cmp    #$B0
 beq    $D984
 ldx    #$16
 bit    $5AA2
 jmp    $D412
 jmp    $DEC9
 pla
 pla
 cpy    #$42
 beq    $D9C5
 sta    $75
 pla
 sta    $76
 pla
 sta    $B8
 pla
 sta    $B9
 jsr    $D9A3
 tya
 clc
 adc    $B8
 sta    $B8
 bcc    $D9A2
 inc    $B9
 rts
 ldx    #$3A
 bit    a:$00A2
 stx    $0D
 ldy    #$00
 sty    $0E
 lda    $0E
 ldx    $0D
 sta    $0D
 stx    $0E
 lda    ($B8),y
 beq    $D9A2
 cmp    $0E
 beq    $D9A2
 iny
 cmp    #$22
 bne    $D9B6
 beq    $D9AE
 pla
 pla
 pla
 rts
 jsr    $DD7B
 jsr    $00B7
 cmp    #$AB
 beq    $D9D8
 lda    #$C4
 jsr    $DEC0
 lda    $9D
 bne    $D9E1
 jsr    $D9A6
 beq    $D998
 jsr    $00B7
 bcs    $D9E9
 jmp    $D93E
 jmp    $D828
 jsr    $E6F8
 pha
 cmp    #$B0
 beq    $D9F8
 cmp    #$AB
 bne    $D981
 dec    $A1
 bne    $DA00
 pla
 jmp    $D82A
 jsr    $00B1
 jsr    $DA0C
 cmp    #$2C
 beq    $D9F8
 pla
 rts
 ldx    #$00
 stx    $50
 stx    $51
 bcs    $DA0B
 sbc    #$2F
 sta    $0D
 lda    $51
 sta    $5E
 cmp    #$19
 bcs    $D9F4
 lda    $50
 asl    a
 rol    $5E
 asl    a
 rol    $5E
 adc    $50
 sta    $50
 lda    $5E
 adc    $51
 sta    $51
 asl    $50
 rol    $51
 lda    $50
 adc    $0D
 sta    $50
 bcc    $DA40
 inc    $51
 jsr    $00B1
 jmp    $DA12
 jsr    $DFE3
 sta    $85
 sty    $86
 lda    #$D0
 jsr    $DEC0
 lda    $12
 pha
 lda    $11
 pha
 jsr    $DD7B
 pla
 rol    a
 jsr    $DD6D
 bne    $DA7A
 pla
 bpl    $DA77
 jsr    $EB72
 jsr    $E10C
 ldy    #$00
 lda    $A0
 sta    ($85),y
 iny
 lda    $A1
 sta    ($85),y
 rts
 jmp    $EB27
 pla
 ldy    #$02
 lda    ($A0),y
 cmp    $70
 bcc    $DA9A
 bne    $DA8C
 dey
 lda    ($A0),y
 cmp    $6F
 bcc    $DA9A
 ldy    $A1
 cpy    $6A
 bcc    $DA9A
 bne    $DAA1
 lda    $A0
 cmp    $69
 bcs    $DAA1
 lda    $A0
 ldy    $A1
 jmp    $DAB7
 ldy    #$00
 lda    ($A0),y
 jsr    $E3D5
 lda    $8C
 ldy    $8D
 sta    $AB
 sty    $AC
 jsr    $E5D4
 lda    #$9D
 ldy    #$00
 sta    $8C
 sty    $8D
 jsr    $E635
 ldy    #$00
 lda    ($8C),y
 sta    ($85),y
 iny
 lda    ($8C),y
 sta    ($85),y
 iny
 lda    ($8C),y
 sta    ($85),y
 rts
 jsr    $DB3D
 jsr    $00B7
 beq    $DAFB
 beq    $DB02
 cmp    #$C0
 beq    $DB19
 cmp    #$C3
 clc
 beq    $DB19
 cmp    #$2C
 clc
 beq    $DB03
 cmp    #$3B
 beq    $DB2F
 jsr    $DD7B
 bit    $11
 bmi    $DACF
 jsr    $ED34
 jsr    $E3E7
 jmp    $DACF
 lda    #$0D
 jsr    $DB5C
 eor    #$FF
 rts
 jsr    $D8DD
 bmi    $DB11
 cmp    #$18
 bcc    $DB11
 jsr    $DAFB
 bne    $DB2F
 adc    #$10
 and    #$F0
 tax
 sec
 bcs    $DB25
 php
 jsr    $E6F5
 cmp    #$29
 bne    $DB83
 plp
 bcc    $DB2B
 dex
 jsr    $F7CB
 bcc    $DB2F
 tax
 inx
 dex
 bne    $DB35
 jsr    $00B1
 jmp    $DAD7
 jsr    $DB57
 bne    $DB2C
 jsr    $E3E7
 jsr    $E600
 tax
 ldy    #$00
 inx
 dex
 beq    $DB02
 lda    ($5E),y
 jsr    $DB5C
 iny
 cmp    #$0D
 bne    $DB44
 jsr    $DB00
 jmp    $DB44
 lda    #$20
 bit    $3FA9
 ora    #$80
 cmp    #$A0
 bcc    $DB64
 ora    $F3
 jsr    $FDED
 and    #$7F
 pha
 lda    $F1
 jsr    $FCA8
 pla
 rts
 lda    $15
 beq    $DB87
 bmi    $DB7B
 ldy    #$FF
 bne    $DB7F
 lda    $7B
 ldy    $7C
 sta    $75
 sty    $76
 jmp    $DEC9
 pla
 bit    $D8
 bpl    $DB90
 ldx    #$FE
 jmp    $F2E9
 lda    #$EF
 ldy    #$DC
 jsr    $DB3A
 lda    $79
 ldy    $7A
 sta    $B8
 sty    $B9
 rts
 jsr    $E306
 ldx    #$01
 ldy    #$02
 lda    #$00
 sta    $0201
 lda    #$40
 jsr    $DBEB
 rts
 cmp    #$22
 bne    $DBC4
 jsr    $DE81
 lda    #$3B
 jsr    $DEC0
 jsr    $DB3D
 jmp    $DBC7
 jsr    $DB5A
 jsr    $E306
 lda    #$2C
 sta    $01FF
 jsr    $D52C
 lda    $0200
 cmp    #$03
 bne    $DBE9
 jmp    $D863
 jsr    $DB5A
 jmp    $D52C
 ldx    $7D
 ldy    $7E
 lda    #$98
 bit    a:$00A9
 sta    $15
 stx    $7F
 sty    $80
 jsr    $DFE3
 sta    $85
 sty    $86
 lda    $B8
 ldy    $B9
 sta    $87
 sty    $88
 ldx    $7F
 ldy    $80
 stx    $B8
 sty    $B9
 jsr    $00B7
 bne    $DC2B
 bit    $15
 bvc    $DC1F
 jsr    $FD0C
 and    #$7F
 sta    $0200
 ldx    #$FF
 ldy    #$01
 bne    $DC27
 bmi    $DCA0
 jsr    $DB5A
 jsr    $DBDC
 stx    $B8
 sty    $B9
 jsr    $00B1
 bit    $11
 bpl    $DC63
 bit    $15
 bvc    $DC3F
 inx
 stx    $B8
 lda    #$00
 sta    $0D
 beq    $DC4B
 sta    $0D
 cmp    #$22
 beq    $DC4C
 lda    #$3A
 sta    $0D
 lda    #$2C
 clc
 sta    $0E
 lda    $B8
 ldy    $B9
 adc    #$00
 bcc    $DC57
 iny
 jsr    $E3ED
 jsr    $E73D
 jsr    $DA7B
 jmp    $DC72
 pha
 lda    $0200
 beq    $DC99
 pla
 jsr    $EC4A
 lda    $12
 jsr    $DA63
 jsr    $00B7
 beq    $DC7E
 cmp    #$2C
 beq    $DC7E
 jmp    $DB71
 lda    $B8
 ldy    $B9
 sta    $7F
 sty    $80
 lda    $87
 ldy    $88
 sta    $B8
 sty    $B9
 jsr    $00B7
 beq    $DCC6
 jsr    $DEBE
 jmp    $DBF1
 lda    $15
 bne    $DC69
 jmp    $DB86
 jsr    $D9A3
 iny
 tax
 bne    $DCB9
 ldx    #$2A
 iny
 lda    ($B8),y
 beq    $DD0D
 iny
 lda    ($B8),y
 sta    $7B
 iny
 lda    ($B8),y
 iny
 sta    $7C
 lda    ($B8),y
 tax
 jsr    $D998
 cpx    #$83
 bne    $DCA0
 jmp    $DC2B
 lda    $7F
 ldy    $80
 ldx    $15
 bpl    $DCD1
 jmp    $D853
 ldy    #$00
 lda    ($7F),y
 beq    $DCDE
 lda    #$DF
 ldy    #$DC
 jmp    $DB3A
 rts
 .byte  $3F
 eor    $58
 .byte  'T'
 eor    ($41)
 jsr    $4749
 lsr    $524F
 eor    $44
 ora    $3F00
 eor    ($45)
 eor    $4E
 .byte  'T'
 eor    $52
 ora    $D000
 .byte  $04
 ldy    #$00
 beq    $DD02
 jsr    $DFE3
 sta    $85
 sty    $86
 jsr    $D365
 beq    $DD0F
 ldx    #$00
 beq    $DD78
 txs
 inx
 inx
 inx
 inx
 txa
 inx
 inx
 inx
 inx
 inx
 inx
 stx    $60
 ldy    #$01
 jsr    $EAF9
 tsx
 lda    $0109,x
 sta    $A2
 lda    $85
 ldy    $86
 jsr    $E7BE
 jsr    $EB27
 ldy    #$01
 jsr    $EBB4
 tsx
 sec
 sbc    $0109,x
 beq    $DD55
 lda    $010F,x
 sta    $75
 lda    $0110,x
 sta    $76
 lda    $0112,x
 sta    $B8
 lda    $0111,x
 sta    $B9
 jmp    $D7D2
 txa
 adc    #$11
 tax
 txs
 jsr    $00B7
 cmp    #$2C
 bne    $DD52
 jsr    $00B1
 jsr    $DCFF
 jsr    $DD7B
 clc
 bit    $38
 bit    $11
 bmi    $DD74
 bcs    $DD76
 rts
 bcs    $DD73
 ldx    #$A3
 jmp    $D412
 ldx    $B8
 bne    $DD81
 dec    $B9
 dec    $B8
 ldx    #$00
 bit    $48
 txa
 pha
 lda    #$01
 jsr    $D3D6
 jsr    $DE60
 lda    #$00
 sta    $89
 jsr    $00B7
 sec
 sbc    #$CF
 bcc    $DDB4
 cmp    #$03
 bcs    $DDB4
 cmp    #$01
 rol    a
 eor    #$01
 eor    $89
 cmp    $89
 bcc    $DE0D
 sta    $89
 jsr    $00B1
 jmp    $DD98
 ldx    $89
 bne    $DDE4
 bcs    $DE35
 adc    #$07
 bcc    $DE35
 adc    $11
 bne    $DDC5
 jmp    $E597
 adc    #$FF
 sta    $5E
 asl    a
 adc    $5E
 tay
 pla
 cmp    $D0B2,y
 bcs    $DE3A
 jsr    $DD6A
 pha
 jsr    $DDFD
 pla
 ldy    $87
 bpl    $DDF6
 tax
 beq    $DE38
 bne    $DE43
 lsr    $11
 txa
 rol    a
 ldx    $B8
 bne    $DDEE
 dec    $B9
 dec    $B8
 ldy    #$1B
 sta    $89
 bne    $DDCD
 cmp    $D0B2,y
 bcs    $DE43
 bcc    $DDD6
 lda    $D0B4,y
 pha
 lda    $D0B3,y
 pha
 jsr    $DE10
 lda    $89
 jmp    $DD86
 jmp    $DEC9
 lda    $A2
 ldx    $D0B2,y
 tay
 pla
 sta    $5E
 inc    $5E
 pla
 sta    $5F
 tya
 pha
 jsr    $EB72
 lda    $A1
 pha
 lda    $A0
 pha
 lda    $9F
 pha
 lda    $9E
 pha
 lda    $9D
 pha
 jmp    ($005E)
 ldy    #$FF
 pla
 beq    $DE5D
 cmp    #$64
 beq    $DE41
 jsr    $DD6A
 sty    $87
 pla
 lsr    a
 sta    $16
 pla
 sta    $A5
 pla
 sta    $A6
 pla
 sta    $A7
 pla
 sta    $A8
 pla
 sta    $A9
 pla
 sta    $AA
 eor    $A2
 sta    $AB
 lda    $9D
 rts
 lda    #$00
 sta    $11
 jsr    $00B1
 bcs    $DE6C
 jmp    $EC4A
 jsr    $E07D
 bcs    $DED5
 cmp    #$2E
 beq    $DE69
 cmp    #$C9
 beq    $DECE
 cmp    #$C8
 beq    $DE64
 cmp    #$22
 bne    $DE90
 lda    $B8
 ldy    $B9
 adc    #$00
 bcc    $DE8A
 iny
 jsr    $E3E7
 jmp    $E73D
 cmp    #$C6
 bne    $DEA4
 ldy    #$18
 bne    $DED0
 lda    $9D
 bne    $DE9F
 ldy    #$01
 bit    a:$00A0
 jmp    $E301
 cmp    #$C2
 bne    $DEAB
 jmp    $E354
 cmp    #$D2
 bcc    $DEB2
 jmp    $DF0C
 jsr    $DEBB
 jsr    $DD7B
 lda    #$29
 bit    $28A9
 bit    $2CA9
 ldy    #$00
 cmp    ($B8),y
 bne    $DEC9
 jmp    $00B1
 ldx    #$10
 jmp    $D412
 ldy    #$15
 pla
 pla
 jmp    $DDD7
 jsr    $DFE3
 sta    $A0
 sty    $A1
 ldx    $11
 beq    $DEE5
 ldx    #$00
 stx    $AC
 rts
 ldx    $12
 bpl    $DEF6
 ldy    #$00
 lda    ($A0),y
 tax
 iny
 lda    ($A0),y
 tay
 txa
 jmp    $E2F2
 jmp    $EAF9
 jsr    $00B1
 jsr    $F1EC
 txa
 ldy    $F0
 jsr    $F7A6
 tay
 jsr    $E301
 jmp    $DEB8
 cmp    #$D7
 beq    $DEF9
 asl    a
 pha
 tax
 jsr    $00B1
 cpx    #$CF
 bcc    $DF3A
 jsr    $DEBB
 jsr    $DD7B
 jsr    $DEBE
 jsr    $DD6C
 pla
 tax
 lda    $A1
 pha
 lda    $A0
 pha
 txa
 pha
 jsr    $E6F8
 pla
 tay
 txa
 pha
 jmp    $DF3F
 jsr    $DEB2
 pla
 tay
 lda    $CFDC,y
 sta    $91
 lda    $CFDD,y
 sta    $92
 jsr    $0090
 jmp    $DD6A
 lda    $A5
 ora    $9D
 bne    $DF60
 lda    $A5
 beq    $DF5D
 lda    $9D
 bne    $DF60
 ldy    #$00
 bit    $01A0
 jmp    $E301
 jsr    $DD6D
 bcs    $DF7D
 lda    $AA
 ora    #$7F
 and    $A6
 sta    $A6
 lda    #$A5
 ldy    #$00
 jsr    $EBB2
 tax
 jmp    $DFB0
 lda    #$00
 sta    $11
 dec    $89
 jsr    $E600
 sta    $9D
 stx    $9E
 sty    $9F
 lda    $A8
 ldy    $A9
 jsr    $E604
 stx    $A8
 sty    $A9
 tax
 sec
 sbc    $9D
 beq    $DFA5
 lda    #$01
 bcc    $DFA5
 ldx    $9D
 lda    #$FF
 sta    $A2
 ldy    #$FF
 inx
 iny
 dex
 bne    $DFB5
 ldx    $A2
 bmi    $DFC1
 clc
 bcc    $DFC1
 lda    ($A8),y
 cmp    ($9E),y
 beq    $DFAA
 ldx    #$FF
 bcs    $DFC1
 ldx    #$01
 inx
 txa
 rol    a
 and    $16
 beq    $DFCA
 lda    #$01
 jmp    $EB93
 jsr    $E6FB
 jsr    $FB1E
 jmp    $E301
 jsr    $DEBE
 tax
 jsr    $DFE8
 jsr    $00B7
 bne    $DFD6
 rts
 ldx    #$00
 jsr    $00B7
 stx    $10
 sta    $81
 jsr    $00B7
 jsr    $E07D
 bcs    $DFF7
 jmp    $DEC9
 ldx    #$00
 stx    $11
 stx    $12
 jmp    $E007
 jmp    $F128
 jmp    $D43C
 stx    $20,y
 lda    ($00),y
 bcc    $E011
 jsr    $E07D
 bcc    $E01C
 tax
 jsr    $00B1
 bcc    $E012
 jsr    $E07D
 bcs    $E012
 cmp    #$24
 bne    $E026
 lda    #$FF
 sta    $11
 bne    $E036
 cmp    #$25
 bne    $E03D
 lda    $14
 bmi    $DFF4
 lda    #$80
 sta    $12
 ora    $81
 sta    $81
 txa
 ora    #$80
 tax
 jsr    $00B1
 stx    $82
 sec
 ora    $14
 sbc    #$28
 bne    $E049
 jmp    $E11E
 bit    $14
 bmi    $E04F
 bvs    $E046
 lda    #$00
 sta    $14
 lda    $69
 ldx    $6A
 ldy    #$00
 stx    $9C
 sta    $9B
 cpx    $6C
 bne    $E065
 cmp    $6B
 beq    $E087
 lda    $81
 cmp    ($9B),y
 bne    $E073
 lda    $82
 iny
 cmp    ($9B),y
 beq    $E0DE
 dey
 clc
 lda    $9B
 adc    #$07
 bcc    $E05B
 inx
 bne    $E059
 cmp    #$41
 bcc    $E086
 sbc    #$5B
 sec
 sbc    #$A5
 rts
 pla
 pha
 cmp    #$D7
 bne    $E09C
 tsx
 lda    $0102,x
 cmp    #$DE
 bne    $E09C
 lda    #$9A
 ldy    #$E0
 rts
 brk
 brk
 lda    $6B
 ldy    $6C
 sta    $9B
 sty    $9C
 lda    $6D
 ldy    $6E
 sta    $96
 sty    $97
 clc
 adc    #$07
 bcc    $E0B2
 iny
 sta    $94
 sty    $95
 jsr    $D393
 lda    $94
 ldy    $95
 iny
 sta    $6B
 sty    $6C
 ldy    #$00
 lda    $81
 sta    ($9B),y
 iny
 lda    $82
 sta    ($9B),y
 lda    #$00
 iny
 sta    ($9B),y
 iny
 sta    ($9B),y
 iny
 sta    ($9B),y
 iny
 sta    ($9B),y
 iny
 sta    ($9B),y
 lda    $9B
 clc
 adc    #$02
 ldy    $9C
 bcc    $E0E8
 iny
 sta    $83
 sty    $84
 rts
 lda    $0F
 asl    a
 adc    #$05
 adc    $9B
 ldy    $9C
 bcc    $E0F9
 iny
 sta    $94
 sty    $95
 rts
 bcc    $E080
 brk
 brk
 jsr    $00B1
 jsr    $DD67
 lda    $A2
 bmi    $E119
 lda    $9D
 cmp    #$90
 bcc    $E11B
 lda    #$FE
 ldy    #$E0
 jsr    $EBB2
 bne    $E199
 jmp    $EBF2
 lda    $14
 bne    $E169
 lda    $10
 ora    $12
 pha
 lda    $11
 pha
 ldy    #$00
 tya
 pha
 lda    $82
 pha
 lda    $81
 pha
 jsr    $E102
 pla
 sta    $81
 pla
 sta    $82
 pla
 tay
 tsx
 lda    $0102,x
 pha
 lda    $0101,x
 pha
 lda    $A0
 sta    $0102,x
 lda    $A1
 sta    $0101,x
 iny
 jsr    $00B7
 cmp    #$2C
 beq    $E12C
 sty    $0F
 jsr    $DEB8
 pla
 sta    $11
 pla
 sta    $12
 and    #$7F
 sta    $10
 ldx    $6B
 lda    $6C
 stx    $9B
 sta    $9C
 cmp    $6E
 bne    $E179
 cpx    $6D
 beq    $E1B8
 ldy    #$00
 lda    ($9B),y
 iny
 cmp    $81
 bne    $E188
 lda    $82
 cmp    ($9B),y
 beq    $E19E
 iny
 lda    ($9B),y
 clc
 adc    $9B
 tax
 iny
 lda    ($9B),y
 adc    $9C
 bcc    $E16D
 ldx    #$6B
 bit    $35A2
 jmp    $D412
 ldx    #$78
 lda    $10
 bne    $E19B
 lda    $14
 beq    $E1AA
 sec
 rts
 jsr    $E0ED
 lda    $0F
 ldy    #$04
 cmp    ($9B),y
 bne    $E196
 jmp    $E24B
 lda    $14
 beq    $E1C1
 ldx    #$2A
 jmp    $D412
 jsr    $E0ED
 jsr    $D3E3
 lda    #$00
 tay
 sta    $AE
 ldx    #$05
 lda    $81
 sta    ($9B),y
 bpl    $E1D5
 dex
 iny
 lda    $82
 sta    ($9B),y
 bpl    $E1DE
 dex
 dex
 stx    $AD
 lda    $0F
 iny
 iny
 iny
 sta    ($9B),y
 ldx    #$0B
 lda    #$00
 bit    $10
 bvc    $E1F7
 pla
 clc
 adc    #$01
 tax
 pla
 adc    #$00
 iny
 sta    ($9B),y
 iny
 txa
 sta    ($9B),y
 jsr    $E2AD
 stx    $AD
 sta    $AE
 ldy    $5E
 dec    $0F
 bne    $E1E7
 adc    $95
 bcs    $E26C
 sta    $95
 tay
 txa
 adc    $94
 bcc    $E21A
 iny
 beq    $E26C
 jsr    $D3E3
 sta    $6D
 sty    $6E
 lda    #$00
 inc    $AE
 ldy    $AD
 beq    $E22E
 dey
 sta    ($94),y
 bne    $E229
 dec    $95
 dec    $AE
 bne    $E229
 inc    $95
 sec
 lda    $6D
 sbc    $9B
 ldy    #$02
 sta    ($9B),y
 lda    $6E
 iny
 sbc    $9C
 sta    ($9B),y
 lda    $10
 bne    $E2AC
 iny
 lda    ($9B),y
 sta    $0F
 lda    #$00
 sta    $AD
 sta    $AE
 iny
 pla
 tax
 sta    $A0
 pla
 sta    $A1
 cmp    ($9B),y
 bcc    $E26F
 bne    $E269
 iny
 txa
 cmp    ($9B),y
 bcc    $E270
 jmp    $E196
 jmp    $D410
 iny
 lda    $AE
 ora    $AD
 clc
 beq    $E281
 jsr    $E2AD
 txa
 adc    $A0
 tax
 tya
 ldy    $5E
 adc    $A1
 stx    $AD
 dec    $0F
 bne    $E253
 sta    $AE
 ldx    #$05
 lda    $81
 bpl    $E292
 dex
 lda    $82
 bpl    $E298
 dex
 dex
 stx    $64
 lda    #$00
 jsr    $E2B6
 txa
 adc    $94
 sta    $83
 tya
 adc    $95
 sta    $84
 tay
 lda    $83
 rts
 sty    $5E
 lda    ($9B),y
 sta    $64
 dey
 lda    ($9B),y
 sta    $65
 lda    #$10
 sta    $99
 ldx    #$00
 ldy    #$00
 txa
 asl    a
 tax
 tya
 rol    a
 tay
 bcs    $E26C
 asl    $AD
 rol    $AE
 bcc    $E2D9
 clc
 txa
 adc    $64
 tax
 tya
 adc    $65
 tay
 bcs    $E26C
 dec    $99
 bne    $E2C0
 rts
 lda    $11
 beq    $E2E5
 jsr    $E600
 jsr    $E484
 sec
 lda    $6F
 sbc    $6D
 tay
 lda    $70
 sbc    $6E
 ldx    #$00
 stx    $11
 sta    $9E
 sty    $9F
 ldx    #$90
 jmp    $EB9B
 ldy    $24
 lda    #$00
 sec
 beq    $E2F2
 ldx    $76
 inx
 bne    $E2AC
 ldx    #$95
 bit    $E0A2
 jmp    $D412
 jsr    $E341
 jsr    $E306
 jsr    $DEBB
 lda    #$80
 sta    $14
 jsr    $DFE3
 jsr    $DD6A
 jsr    $DEB8
 lda    #$D0
 jsr    $DEC0
 pha
 lda    $84
 pha
 lda    $83
 pha
 lda    $B9
 pha
 lda    $B8
 pha
 jsr    $D995
 jmp    $E3AF
 lda    #$C2
 jsr    $DEC0
 ora    #$80
 sta    $14
 jsr    $DFEA
 sta    $8A
 sty    $8B
 jmp    $DD6A
 jsr    $E341
 lda    $8B
 pha
 lda    $8A
 pha
 jsr    $DEB2
 jsr    $DD6A
 pla
 sta    $8A
 pla
 sta    $8B
 ldy    #$02
 lda    ($8A),y
 sta    $83
 tax
 iny
 lda    ($8A),y
 beq    $E30E
 sta    $84
 iny
 lda    ($83),y
 pha
 dey
 bpl    $E378
 ldy    $84
 jsr    $EB2B
 lda    $B9
 pha
 lda    $B8
 pha
 lda    ($8A),y
 sta    $B8
 iny
 lda    ($8A),y
 sta    $B9
 lda    $84
 pha
 lda    $83
 pha
 jsr    $DD67
 pla
 sta    $8A
 pla
 sta    $8B
 jsr    $00B7
 beq    $E3A9
 jmp    $DEC9
 pla
 sta    $B8
 pla
 sta    $B9
 ldy    #$00
 pla
 sta    ($8A),y
 pla
 iny
 sta    ($8A),y
 pla
 iny
 sta    ($8A),y
 pla
 iny
 sta    ($8A),y
 pla
 iny
 sta    ($8A),y
 rts
 jsr    $DD6A
 ldy    #$00
 jsr    $ED36
 pla
 pla
 lda    #$FF
 ldy    #$00
 beq    $E3E7
 ldx    $A0
 ldy    $A1
 stx    $8C
 sty    $8D
 jsr    $E452
 stx    $9E
 sty    $9F
 sta    $9D
 rts
 ldx    #$22
 stx    $0D
 stx    $0E
 sta    $AB
 sty    $AC
 sta    $9E
 sty    $9F
 ldy    #$FF
 iny
 lda    ($AB),y
 beq    $E408
 cmp    $0D
 beq    $E404
 cmp    $0E
 bne    $E3F7
 cmp    #$22
 beq    $E409
 clc
 sty    $9D
 tya
 adc    $AB
 sta    $AD
 ldx    $AC
 bcc    $E415
 inx
 stx    $AE
 lda    $AC
 beq    $E41F
 cmp    #$02
 bne    $E42A
 tya
 jsr    $E3D5
 ldx    $AB
 ldy    $AC
 jsr    $E5E2
 ldx    $52
 cpx    #$5E
 bne    $E435
 ldx    #$BF
 jmp    $D412
 lda    $9D
 sta    $00,x
 lda    $9E
 sta    $01,x
 lda    $9F
 sta    $02,x
 ldy    #$00
 stx    $A0
 sty    $A1
 dey
 sty    $11
 stx    $53
 inx
 inx
 inx
 stx    $52
 rts
 lsr    $13
 pha
 eor    #$FF
 sec
 adc    $6F
 ldy    $70
 bcs    $E45F
 dey
 cpy    $6E
 bcc    $E474
 bne    $E469
 cmp    $6D
 bcc    $E474
 sta    $6F
 sty    $70
 sta    $71
 sty    $72
 tax
 pla
 rts
 ldx    #$4D
 lda    $13
 bmi    $E432
 jsr    $E484
 lda    #$80
 sta    $13
 pla
 bne    $E454
 ldx    $73
 lda    $74
 stx    $6F
 sta    $70
 ldy    #$00
 sty    $8B
 lda    $6D
 ldx    $6E
 sta    $9B
 stx    $9C
 lda    #$55
 ldx    #$00
 sta    $5E
 stx    $5F
 cmp    $52
 beq    $E4A9
 jsr    $E523
 beq    $E4A0
 lda    #$07
 sta    $8F
 lda    $69
 ldx    $6A
 sta    $5E
 stx    $5F
 cpx    $6C
 bne    $E4BD
 cmp    $6B
 beq    $E4C2
 jsr    $E519
 beq    $E4B5
 sta    $94
 stx    $95
 lda    #$03
 sta    $8F
 lda    $94
 ldx    $95
 cpx    $6E
 bne    $E4D9
 cmp    $6D
 bne    $E4D9
 jmp    $E562
 sta    $5E
 stx    $5F
 ldy    #$00
 lda    ($5E),y
 tax
 iny
 lda    ($5E),y
 php
 iny
 lda    ($5E),y
 adc    $94
 sta    $94
 iny
 lda    ($5E),y
 adc    $95
 sta    $95
 plp
 bpl    $E4CA
 txa
 bmi    $E4CA
 iny
 lda    ($5E),y
 ldy    #$00
 asl    a
 adc    #$05
 adc    $5E
 sta    $5E
 bcc    $E50A
 inc    $5F
 ldx    $5F
 cpx    $95
 bne    $E514
 cmp    $94
 beq    $E4CE
 jsr    $E523
 beq    $E50C
 lda    ($5E),y
 bmi    $E552
 iny
 lda    ($5E),y
 bpl    $E552
 iny
 lda    ($5E),y
 beq    $E552
 iny
 lda    ($5E),y
 tax
 iny
 lda    ($5E),y
 cmp    $70
 bcc    $E538
 bne    $E552
 cpx    $6F
 bcs    $E552
 cmp    $9C
 bcc    $E552
 bne    $E542
 cpx    $9B
 bcc    $E552
 stx    $9B
 sta    $9C
 lda    $5E
 ldx    $5F
 sta    $8A
 stx    $8B
 lda    $8F
 sta    $91
 lda    $8F
 clc
 adc    $5E
 sta    $5E
 bcc    $E55D
 inc    $5F
 ldx    $5F
 ldy    #$00
 rts
 ldx    $8B
 beq    $E55D
 lda    $91
 and    #$04
 lsr    a
 tay
 sta    $91
 lda    ($8A),y
 adc    $9B
 sta    $96
 lda    $9C
 adc    #$00
 sta    $97
 lda    $6F
 ldx    $70
 sta    $94
 stx    $95
 jsr    $D39A
 ldy    $91
 iny
 lda    $94
 sta    ($8A),y
 tax
 inc    $95
 lda    $95
 iny
 sta    ($8A),y
 jmp    $E488
 lda    $A1
 pha
 lda    $A0
 pha
 jsr    $DE60
 jsr    $DD6C
 pla
 sta    $AB
 pla
 sta    $AC
 ldy    #$00
 lda    ($AB),y
 clc
 adc    ($A0),y
 bcc    $E5B7
 ldx    #$B0
 jmp    $D412
 jsr    $E3D5
 jsr    $E5D4
 lda    $8C
 ldy    $8D
 jsr    $E604
 jsr    $E5E6
 lda    $AB
 ldy    $AC
 jsr    $E604
 jsr    $E42A
 jmp    $DD95
 ldy    #$00
 lda    ($AB),y
 pha
 iny
 lda    ($AB),y
 tax
 iny
 lda    ($AB),y
 tay
 pla
 stx    $5E
 sty    $5F
 tay
 beq    $E5F3
 pha
 dey
 lda    ($5E),y
 sta    ($71),y
 tya
 bne    $E5EA
 pla
 clc
 adc    $71
 sta    $71
 bcc    $E5FC
 inc    $72
 rts
 jsr    $DD6C
 lda    $A0
 ldy    $A1
 sta    $5E
 sty    $5F
 jsr    $E635
 php
 ldy    #$00
 lda    ($5E),y
 pha
 iny
 lda    ($5E),y
 tax
 iny
 lda    ($5E),y
 tay
 pla
 plp
 bne    $E630
 cpy    $70
 bne    $E630
 cpx    $6F
 bne    $E630
 pha
 clc
 adc    $6F
 sta    $6F
 bcc    $E62F
 inc    $70
 pla
 stx    $5E
 sty    $5F
 rts
 cpy    $54
 bne    $E645
 cmp    $53
 bne    $E645
 sta    $52
 sbc    #$03
 sta    $53
 ldy    #$00
 rts
 jsr    $E6FB
 txa
 pha
 lda    #$01
 jsr    $E3DD
 pla
 ldy    #$00
 sta    ($9E),y
 pla
 pla
 jmp    $E42A
 jsr    $E6B9
 cmp    ($8C),y
 tya
 bcc    $E666
 lda    ($8C),y
 tax
 tya
 pha
 txa
 pha
 jsr    $E3DD
 lda    $8C
 ldy    $8D
 jsr    $E604
 pla
 tay
 pla
 clc
 adc    $5E
 sta    $5E
 bcc    $E67F
 inc    $5F
 tya
 jsr    $E5E6
 jmp    $E42A
 jsr    $E6B9
 clc
 sbc    ($8C),y
 eor    #$FF
 jmp    $E660
 lda    #$FF
 sta    $A1
 jsr    $00B7
 cmp    #$29
 beq    $E6A2
 jsr    $DEBE
 jsr    $E6F8
 jsr    $E6B9
 dex
 txa
 pha
 clc
 ldx    #$00
 sbc    ($8C),y
 bcs    $E667
 eor    #$FF
 cmp    $A1
 bcc    $E668
 lda    $A1
 bcs    $E668
 jsr    $DEB8
 pla
 tay
 pla
 sta    $91
 pla
 pla
 pla
 tax
 pla
 sta    $8C
 pla
 sta    $8D
 lda    $91
 pha
 tya
 pha
 ldy    #$00
 txa
 beq    $E6F2
 rts
 jsr    $E6DC
 jmp    $E301
 jsr    $E5FD
 ldx    #$00
 stx    $11
 tay
 rts
 jsr    $E6DC
 beq    $E6F2
 ldy    #$00
 lda    ($5E),y
 tay
 jmp    $E301
 jmp    $E199
 jsr    $00B1
 jsr    $DD67
 jsr    $E108
 ldx    $A0
 bne    $E6F2
 ldx    $A1
 jmp    $00B7
 jsr    $E6DC
 bne    $E70F
 jmp    $E84E
 ldx    $B8
 ldy    $B9
 stx    $AD
 sty    $AE
 ldx    $5E
 stx    $B8
 clc
 adc    $5E
 sta    $60
 ldx    $5F
 stx    $B9
 bcc    $E727
 inx
 stx    $61
 ldy    #$00
 lda    ($60),y
 pha
 lda    #$00
 sta    ($60),y
 jsr    $00B7
 jsr    $EC4A
 pla
 ldy    #$00
 sta    ($60),y
 ldx    $AD
 ldy    $AE
 stx    $B8
 sty    $B9
 rts
 jsr    $DD67
 jsr    $E752
 jsr    $DEBE
 jmp    $E6F8
 lda    $9D
 cmp    #$91
 bcs    $E6F2
 jsr    $EBF2
 lda    $A0
 ldy    $A1
 sty    $50
 sta    $51
 rts
 lda    $50
 pha
 lda    $51
 pha
 jsr    $E752
 ldy    #$00
 lda    ($50),y
 tay
 pla
 sta    $51
 pla
 sta    $50
 jmp    $E301
 jsr    $E746
 txa
 ldy    #$00
 sta    ($50),y
 rts
 jsr    $E746
 stx    $85
 ldx    #$00
 jsr    $00B7
 beq    $E793
 jsr    $E74C
 stx    $86
 ldy    #$00
 lda    ($50),y
 eor    $86
 and    $85
 beq    $E797
 rts
 lda    #$64
 ldy    #$EE
 jmp    $E7BE
 jsr    $E9E3
 lda    $A2
 eor    #$FF
 sta    $A2
 eor    $AA
 sta    $AB
 lda    $9D
 jmp    $E7C1
 jsr    $E8F0
 bcc    $E7FA
 jsr    $E9E3
 bne    $E7C6
 jmp    $EB53
 ldx    $AC
 stx    $92
 ldx    #$A5
 lda    $A5
 tay
 beq    $E79F
 sec
 sbc    $9D
 beq    $E7FA
 bcc    $E7EA
 sty    $9D
 ldy    $AA
 sty    $A2
 eor    #$FF
 adc    #$00
 ldy    #$00
 sty    $92
 ldx    #$9D
 bne    $E7EE
 ldy    #$00
 sty    $AC
 cmp    #$F9
 bmi    $E7B9
 tay
 lda    $AC
 lsr    $01,x
 jsr    $E907
 bit    $AB
 bpl    $E855
 ldy    #$9D
 cpx    #$A5
 beq    $E806
 ldy    #$A5
 sec
 eor    #$FF
 adc    $92
 sta    $AC
 lda    $0004,y
 sbc    $04,x
 sta    $A1
 lda    $0003,y
 sbc    $03,x
 sta    $A0
 lda    $0002,y
 sbc    $02,x
 sta    $9F
 lda    $0001,y
 sbc    $01,x
 sta    $9E
 bcs    $E82E
 jsr    $E89E
 ldy    #$00
 tya
 clc
 ldx    $9E
 bne    $E880
 ldx    $9F
 stx    $9E
 ldx    $A0
 stx    $9F
 ldx    $A1
 stx    $A0
 ldx    $AC
 stx    $A1
 sty    $AC
 adc    #$08
 cmp    #$20
 bne    $E832
 lda    #$00
 sta    $9D
 sta    $A2
 rts
 adc    $92
 sta    $AC
 lda    $A1
 adc    $A9
 sta    $A1
 lda    $A0
 adc    $A8
 sta    $A0
 lda    $9F
 adc    $A7
 sta    $9F
 lda    $9E
 adc    $A6
 sta    $9E
 jmp    $E88D
 adc    #$01
 asl    $AC
 rol    $A1
 rol    $A0
 rol    $9F
 rol    $9E
 bpl    $E874
 sec
 sbc    $9D
 bcs    $E84E
 eor    #$FF
 adc    #$01
 sta    $9D
 bcc    $E89D
 inc    $9D
 beq    $E8D5
 ror    $9E
 ror    $9F
 ror    $A0
 ror    $A1
 ror    $AC
 rts
 lda    $A2
 eor    #$FF
 sta    $A2
 lda    $9E
 eor    #$FF
 sta    $9E
 lda    $9F
 eor    #$FF
 sta    $9F
 lda    $A0
 eor    #$FF
 sta    $A0
 lda    $A1
 eor    #$FF
 sta    $A1
 lda    $AC
 eor    #$FF
 sta    $AC
 inc    $AC
 bne    $E8D4
 inc    $A1
 bne    $E8D4
 inc    $A0
 bne    $E8D4
 inc    $9F
 bne    $E8D4
 inc    $9E
 rts
 ldx    #$45
 jmp    $D412
 ldx    #$61
 ldy    $04,x
 sty    $AC
 ldy    $03,x
 sty    $04,x
 ldy    $02,x
 sty    $03,x
 ldy    $01,x
 sty    $02,x
 ldy    $A4
 sty    $01,x
 adc    #$08
 bmi    $E8DC
 beq    $E8DC
 sbc    #$08
 tay
 lda    $AC
 bcs    $E911
 asl    $01,x
 bcc    $E903
 inc    $01,x
 ror    $01,x
 ror    $01,x
 ror    $02,x
 ror    $03,x
 ror    $04,x
 ror    a
 iny
 bne    $E8FD
 clc
 rts
 sta    ($00,x)
 brk
 brk
 brk
 .byte  $03
 .byte  $7F
 lsr    $CB56,x
 adc    $1380,y
 .byte  $9B
 .byte  $0B
 stz    $80
 ror    $38,x
 .byte  $93
 asl    $82,x
 sec
 tax
 .byte  $3B
 jsr    $3580
 .byte  $04
 .byte  $F3
 bit    $81,x
 and    $04,x
 .byte  $F3
 bit    $80,x
 bra    $E93A
 brk
 brk
 bra    $E96F
 adc    ($17)
 sed
 jsr    $EB82
 beq    $E948
 bpl    $E94B
 jmp    $E199
 lda    $9D
 sbc    #$7F
 pha
 lda    #$80
 sta    $9D
 lda    #$2D
 ldy    #$E9
 jsr    $E7BE
 lda    #$32
 ldy    #$E9
 jsr    $EA66
 lda    #$13
 ldy    #$E9
 jsr    $E7A7
 lda    #$18
 ldy    #$E9
 jsr    $EF5C
 lda    #$37
 ldy    #$E9
 jsr    $E7BE
 pla
 jsr    $ECD5
 lda    #$3C
 ldy    #$E9
 jsr    $E9E3
 bne    $E987
 jmp    $E9E2
 jsr    $EA0E
 lda    #$00
 sta    $62
 sta    $63
 sta    $64
 sta    $65
 lda    $AC
 jsr    $E9B0
 lda    $A1
 jsr    $E9B0
 lda    $A0
 jsr    $E9B0
 lda    $9F
 jsr    $E9B0
 lda    $9E
 jsr    $E9B5
 jmp    $EAE6
 bne    $E9B5
 jmp    $E8DA
 lsr    a
 ora    #$80
 tay
 bcc    $E9D4
 clc
 lda    $65
 adc    $A9
 sta    $65
 lda    $64
 adc    $A8
 sta    $64
 lda    $63
 adc    $A7
 sta    $63
 lda    $62
 adc    $A6
 sta    $62
 ror    $62
 ror    $63
 ror    $64
 ror    $65
 ror    $AC
 tya
 lsr    a
 bne    $E9B8
 rts
 sta    $5E
 sty    $5F
 ldy    #$04
 lda    ($5E),y
 sta    $A9
 dey
 lda    ($5E),y
 sta    $A8
 dey
 lda    ($5E),y
 sta    $A7
 dey
 lda    ($5E),y
 sta    $AA
 eor    $A2
 sta    $AB
 lda    $AA
 ora    #$80
 sta    $A6
 dey
 lda    ($5E),y
 sta    $A5
 lda    $9D
 rts
 lda    $A5
 beq    $EA31
 clc
 adc    $9D
 bcc    $EA1B
 bmi    $EA36
 clc
 bit    $1410
 adc    #$80
 sta    $9D
 bne    $EA26
 jmp    $E852
 lda    $AB
 sta    $A2
 rts
 lda    $A2
 eor    #$FF
 bmi    $EA36
 pla
 pla
 jmp    $E84E
 jmp    $E8D5
 jsr    $EB63
 tax
 beq    $EA4F
 clc
 adc    #$02
 bcs    $EA36
 ldx    #$00
 stx    $AB
 jsr    $E7CE
 inc    $9D
 beq    $EA36
 rts
 sty    $20
 brk
 brk
 brk
 jsr    $EB63
 lda    #$50
 ldy    #$EA
 ldx    #$00
 stx    $AB
 jsr    $EAF9
 jmp    $EA69
 jsr    $E9E3
 beq    $EAE1
 jsr    $EB72
 lda    #$00
 sec
 sbc    $9D
 sta    $9D
 jsr    $EA0E
 inc    $9D
 beq    $EA36
 ldx    #$FC
 lda    #$01
 ldy    $A6
 cpy    $9E
 bne    $EA96
 ldy    $A7
 cpy    $9F
 bne    $EA96
 ldy    $A8
 cpy    $A0
 bne    $EA96
 ldy    $A9
 cpy    $A1
 php
 rol    a
 bcc    $EAA3
 inx
 sta    $65,x
 beq    $EAD1
 bpl    $EAD5
 lda    #$01
 plp
 bcs    $EAB4
 asl    $A9
 rol    $A8
 rol    $A7
 rol    $A6
 bcs    $EA96
 bmi    $EA80
 bpl    $EA96
 tay
 lda    $A9
 sbc    $A1
 sta    $A9
 lda    $A8
 sbc    $A0
 sta    $A8
 lda    $A7
 sbc    $9F
 sta    $A7
 lda    $A6
 sbc    $9E
 sta    $A6
 tya
 jmp    $EAA6
 lda    #$40
 bne    $EAA3
 asl    a
 asl    a
 asl    a
 asl    a
 asl    a
 asl    a
 sta    $AC
 plp
 jmp    $EAE6
 ldx    #$85
 jmp    $D412
 lda    $62
 sta    $9E
 lda    $63
 sta    $9F
 lda    $64
 sta    $A0
 lda    $65
 sta    $A1
 jmp    $E82E
 sta    $5E
 sty    $5F
 ldy    #$04
 lda    ($5E),y
 sta    $A1
 dey
 lda    ($5E),y
 sta    $A0
 dey
 lda    ($5E),y
 sta    $9F
 dey
 lda    ($5E),y
 sta    $A2
 ora    #$80
 sta    $9E
 dey
 lda    ($5E),y
 sta    $9D
 sty    $AC
 rts
 ldx    #$98
 bit    $93A2
 ldy    #$00
 beq    $EB2B
 ldx    $85
 ldy    $86
 jsr    $EB72
 stx    $5E
 sty    $5F
 ldy    #$04
 lda    $A1
 sta    ($5E),y
 dey
 lda    $A0
 sta    ($5E),y
 dey
 lda    $9F
 sta    ($5E),y
 dey
 lda    $A2
 ora    #$7F
 and    $9E
 sta    ($5E),y
 dey
 lda    $9D
 sta    ($5E),y
 sty    $AC
 rts
 lda    $AA
 sta    $A2
 ldx    #$05
 lda    $A4,x
 sta    $9C,x
 dex
 bne    $EB59
 stx    $AC
 rts
 jsr    $EB72
 ldx    #$06
 lda    $9C,x
 sta    $A4,x
 dex
 bne    $EB68
 stx    $AC
 rts
 lda    $9D
 beq    $EB71
 asl    $AC
 bcc    $EB71
 jsr    $E8C6
 bne    $EB71
 jmp    $E88F
 lda    $9D
 beq    $EB8F
 lda    $A2
 rol    a
 lda    #$FF
 bcs    $EB8F
 lda    #$01
 rts
 jsr    $EB82
 sta    $9E
 lda    #$00
 sta    $9F
 ldx    #$88
 lda    $9E
 eor    #$FF
 rol    a
 lda    #$00
 sta    $A1
 sta    $A0
 stx    $9D
 sta    $AC
 sta    $A2
 jmp    $E829
 lsr    $A2
 rts
 sta    $60
 sty    $61
 ldy    #$00
 lda    ($60),y
 iny
 tax
 beq    $EB82
 lda    ($60),y
 eor    $A2
 bmi    $EB86
 cpx    $9D
 bne    $EBE9
 lda    ($60),y
 ora    #$80
 cmp    $9E
 bne    $EBE9
 iny
 lda    ($60),y
 cmp    $9F
 bne    $EBE9
 iny
 lda    ($60),y
 cmp    $A0
 bne    $EBE9
 iny
 lda    #$7F
 cmp    $AC
 lda    ($60),y
 sbc    $A1
 beq    $EC11
 lda    $A2
 bcc    $EBEF
 eor    #$FF
 jmp    $EB88
 lda    $9D
 beq    $EC40
 sec
 sbc    #$A0
 bit    $A2
 bpl    $EC06
 tax
 lda    #$FF
 sta    $A4
 jsr    $E8A4
 txa
 ldx    #$9D
 cmp    #$F9
 bpl    $EC12
 jsr    $E8F0
 sty    $A4
 rts
 tay
 lda    $A2
 and    #$80
 lsr    $9E
 ora    $9E
 sta    $9E
 jsr    $E907
 sty    $A4
 rts
 lda    $9D
 cmp    #$A0
 bcs    $EC49
 jsr    $EBF2
 sty    $AC
 lda    $A2
 sty    $A2
 eor    #$80
 rol    a
 lda    #$A0
 sta    $9D
 lda    $A1
 sta    $0D
 jmp    $E829
 sta    $9E
 sta    $9F
 sta    $A0
 sta    $A1
 tay
 rts
 ldy    #$00
 ldx    #$0A
 sty    $99,x
 dex
 bpl    $EC4E
 bcc    $EC64
 cmp    #$2D
 bne    $EC5D
 stx    $A3
 beq    $EC61
 cmp    #$2B
 bne    $EC66
 jsr    $00B1
 bcc    $ECC1
 cmp    #$2E
 beq    $EC98
 cmp    #$45
 bne    $EC9E
 jsr    $00B1
 bcc    $EC8A
 cmp    #$C9
 beq    $EC85
 cmp    #$2D
 beq    $EC85
 cmp    #$C8
 beq    $EC87
 cmp    #$2B
 beq    $EC87
 bne    $EC8C
 ror    $9C
 jsr    $00B1
 bcc    $ECE8
 bit    $9C
 bpl    $EC9E
 lda    #$00
 sec
 sbc    $9A
 jmp    $ECA0
 ror    $9B
 bit    $9B
 bvc    $EC61
 lda    $9A
 sec
 sbc    $99
 sta    $9A
 beq    $ECB9
 bpl    $ECB2
 jsr    $EA55
 inc    $9A
 bne    $ECA9
 beq    $ECB9
 jsr    $EA39
 dec    $9A
 bne    $ECB2
 lda    $A3
 bmi    $ECBE
 rts
 jmp    $EED0
 pha
 bit    $9B
 bpl    $ECC8
 inc    $99
 jsr    $EA39
 pla
 sec
 sbc    #$30
 jsr    $ECD5
 jmp    $EC61
 pha
 jsr    $EB63
 pla
 jsr    $EB93
 lda    $AA
 eor    $A2
 sta    $AB
 ldx    $9D
 jmp    $E7C1
 lda    $9A
 cmp    #$0A
 bcc    $ECF7
 lda    #$64
 bit    $9C
 bmi    $ED05
 jmp    $E8D5
 asl    a
 asl    a
 clc
 adc    $9A
 asl    a
 clc
 ldy    #$00
 adc    ($B8),y
 sec
 sbc    #$30
 sta    $9A
 jmp    $EC87
 .byte  $9B
 rol    $1FBC,x
 sbc    $6E9E,x
 .byte  'k'
 .byte  $27
 sbc    $6E9E,x
 .byte  'k'
 plp
 brk
 lda    #$58
 ldy    #$D3
 jsr    $ED31
 lda    $76
 ldx    $75
 sta    $9E
 stx    $9F
 ldx    #$90
 sec
 jsr    $EBA0
 jsr    $ED34
 jmp    $DB3A
 ldy    #$01
 lda    #$2D
 dey
 bit    $A2
 bpl    $ED41
 iny
 sta    $00FF,y
 sta    $A2
 sty    $AD
 iny
 lda    #$30
 ldx    $9D
 bne    $ED4F
 jmp    $EE57
 lda    #$00
 cpx    #$80
 beq    $ED57
 bcs    $ED60
 lda    #$14
 ldy    #$ED
 jsr    $E97F
 lda    #$F7
 sta    $99
 lda    #$0F
 ldy    #$ED
 jsr    $EBB2
 beq    $ED89
 bpl    $ED7F
 lda    #$0A
 ldy    #$ED
 jsr    $EBB2
 beq    $ED78
 bpl    $ED86
 jsr    $EA39
 dec    $99
 bne    $ED6D
 jsr    $EA55
 inc    $99
 bne    $ED62
 jsr    $E7A0
 jsr    $EBF2
 ldx    #$01
 lda    $99
 clc
 adc    #$0A
 bmi    $ED9E
 cmp    #$0B
 bcs    $ED9F
 adc    #$FF
 tax
 lda    #$02
 sec
 sbc    #$02
 sta    $9A
 stx    $99
 txa
 beq    $EDAA
 bpl    $EDBD
 ldy    $AD
 lda    #$2E
 iny
 sta    $00FF,y
 txa
 beq    $EDBB
 lda    #$30
 iny
 sta    $00FF,y
 sty    $AD
 ldy    #$00
 ldx    #$80
 lda    $A1
 clc
 adc    $EE6C,y
 sta    $A1
 lda    $A0
 adc    $EE6B,y
 sta    $A0
 lda    $9F
 adc    $EE6A,y
 sta    $9F
 lda    $9E
 adc    $EE69,y
 sta    $9E
 inx
 bcs    $EDE5
 bpl    $EDC1
 bmi    $EDE7
 bmi    $EDC1
 txa
 bcc    $EDEE
 eor    #$FF
 adc    #$0A
 adc    #$2F
 iny
 iny
 iny
 iny
 sty    $83
 ldy    $AD
 iny
 tax
 and    #$7F
 sta    $00FF,y
 dec    $99
 bne    $EE09
 lda    #$2E
 iny
 sta    $00FF,y
 sty    $AD
 ldy    $83
 txa
 eor    #$FF
 and    #$80
 tax
 cpy    #$24
 bne    $EDC1
 ldy    $AD
 lda    $00FF,y
 dey
 cmp    #$30
 beq    $EE19
 cmp    #$2E
 beq    $EE26
 iny
 lda    #$2B
 ldx    $9A
 beq    $EE5A
 bpl    $EE36
 lda    #$00
 sec
 sbc    $9A
 tax
 lda    #$2D
 sta    $0101,y
 lda    #$45
 sta    $0100,y
 txa
 ldx    #$2F
 sec
 inx
 sbc    #$0A
 bcs    $EE42
 adc    #$3A
 sta    $0103,y
 txa
 sta    $0102,y
 lda    #$00
 sta    $0104,y
 beq    $EE5F
 sta    $00FF,y
 lda    #$00
 sta    $0100,y
 lda    #$00
 ldy    #$01
 rts
 bra    $EE66
 brk
 brk
 brk
 plx
 asl    a
 .byte  $1F
 brk
 brk
 tya
 stx    $80,y
 .byte  $FF
 beq    $EE31
 cpy    #$00
 ora    ($86,x)
 ldy    #$FF
 .byte  $FF
 cld
 beq    $EE7E
 brk
 .byte  $03
 inx
 .byte  $FF
 .byte  $FF
 .byte  $FF
 stz    a:$0000
 brk
 asl    a
 .byte  $FF
 .byte  $FF
 .byte  $FF
 .byte  $FF
 jsr    $EB63
 lda    #$64
 ldy    #$EE
 jsr    $EAF9
 beq    $EF09
 lda    $A5
 bne    $EEA0
 jmp    $E850
 ldx    #$8A
 ldy    #$00
 jsr    $EB2B
 lda    $AA
 bpl    $EEBA
 jsr    $EC23
 lda    #$8A
 ldy    #$00
 jsr    $EBB2
 bne    $EEBA
 tya
 ldy    $0D
 jsr    $EB55
 tya
 pha
 jsr    $E941
 lda    #$8A
 ldy    #$00
 jsr    $E97F
 jsr    $EF09
 pla
 lsr    a
 bcc    $EEDA
 lda    $9D
 beq    $EEDA
 lda    $A2
 eor    #$FF
 sta    $A2
 rts
 sta    ($38,x)
 tax
 .byte  $3B
 and    #$07
 adc    ($34),y
 cli
 rol    $7456,x
 asl    $7E,x
 .byte  $B3
 .byte  $1B
 .byte  'w'
 .byte  $2F
 inc    $85E3
 ply
 ora    $1C84,x
 rol    a
 jmp    ($5963,x)
 cli
 asl    a
 ror    $FD75,x
 .byte  $E7
 dec    $80
 and    ($72),y
 clc
 bpl    $EE86
 brk
 brk
 brk
 brk
 lda    #$DB
 ldy    #$EE
 jsr    $E97F
 lda    $AC
 adc    #$50
 bcc    $EF19
 jsr    $EB7A
 sta    $92
 jsr    $EB66
 lda    $9D
 cmp    #$88
 bcc    $EF27
 jsr    $EA2B
 jsr    $EC23
 lda    $0D
 clc
 adc    #$81
 beq    $EF24
 sec
 sbc    #$01
 pha
 ldx    #$05
 lda    $A5,x
 ldy    $9D,x
 sta    $9D,x
 sty    $A5,x
 dex
 bpl    $EF37
 lda    $92
 sta    $AC
 jsr    $E7AA
 jsr    $EED0
 lda    #$E0
 ldy    #$EE
 jsr    $EF72
 lda    #$00
 sta    $AB
 pla
 jsr    $EA10
 rts
 sta    $AD
 sty    $AE
 jsr    $EB21
 lda    #$93
 jsr    $E97F
 jsr    $EF76
 lda    #$93
 ldy    #$00
 jmp    $E97F
 sta    $AD
 sty    $AE
 jsr    $EB1E
 lda    ($AD),y
 sta    $A3
 ldy    $AD
 iny
 tya
 bne    $EF85
 inc    $AE
 sta    $AD
 ldy    $AE
 jsr    $E97F
 lda    $AD
 ldy    $AE
 clc
 adc    #$05
 bcc    $EF96
 iny
 sta    $AD
 sty    $AE
 jsr    $E7BE
 lda    #$98
 ldy    #$00
 dec    $A3
 bne    $EF89
 rts
 tya
 and    $44,x
 ply
 pla
 plp
 lda    ($46),y
 jsr    $EB82
 tax
 bmi    $EFCC
 lda    #$C9
 ldy    #$00
 jsr    $EAF9
 txa
 beq    $EFA5
 lda    #$A6
 ldy    #$EF
 jsr    $E97F
 lda    #$AA
 ldy    #$EF
 jsr    $E7BE
 ldx    $A1
 lda    $9E
 sta    $A1
 stx    $9E
 lda    #$00
 sta    $A2
 lda    $9D
 sta    $AC
 lda    #$80
 sta    $9D
 jsr    $E82E
 ldx    #$C9
 ldy    #$00
 jmp    $EB2B
 lda    #$66
 ldy    #$F0
 jsr    $E7BE
 jsr    $EB63
 lda    #$6B
 ldy    #$F0
 ldx    $AA
 jsr    $EA5E
 jsr    $EB63
 jsr    $EC23
 lda    #$00
 sta    $AB
 jsr    $E7AA
 lda    #$70
 ldy    #$F0
 jsr    $E7A7
 lda    $A2
 pha
 bpl    $F023
 jsr    $E7A0
 lda    $A2
 bmi    $F026
 lda    $16
 eor    #$FF
 sta    $16
 jsr    $EED0
 lda    #$70
 ldy    #$F0
 jsr    $E7BE
 pla
 bpl    $F033
 jsr    $EED0
 lda    #$75
 ldy    #$F0
 jmp    $EF5C
 jsr    $EB21
 lda    #$00
 sta    $16
 jsr    $EFF1
 ldx    #$8A
 ldy    #$00
 jsr    $EFE7
 lda    #$93
 ldy    #$00
 jsr    $EAF9
 lda    #$00
 sta    $A2
 lda    $16
 jsr    $F062
 lda    #$8A
 ldy    #$00
 jmp    $EA66
 pha
 jmp    $F023
 sta    ($49,x)
 .byte  $0F
 phx
 ldx    #$83
 eor    #$0F
 phx
 ldx    #$7F
 brk
 brk
 brk
 brk
 ora    $84
 inc    $1A
 and    $861B
 plp
 .byte  $07
 .byte  $FB
 sed
 .byte  $87
 sta    $8968,y
 ora    ($87,x)
 .byte  $23
 and    $DF,x
 sbc    ($86,x)
 lda    $5D
 .byte  $E7
 plp
 .byte  $83
 eor    #$0F
 phx
 ldx    #$A6
 .byte  $D3
 cmp    ($C8,x)
 .byte  $D4
 iny
 cmp    $C4,x
 dec    $A5CA
 ldx    #$48
 bpl    $F0A6
 jsr    $EED0
 lda    $9D
 pha
 cmp    #$81
 bcc    $F0B4
 lda    #$13
 ldy    #$E9
 jsr    $EA66
 lda    #$CE
 ldy    #$F0
 jsr    $EF5C
 pla
 cmp    #$81
 bcc    $F0C7
 lda    #$66
 ldy    #$F0
 jsr    $E7A7
 pla
 bpl    $F0CD
 jmp    $EED0
 rts
 .byte  $0B
 ror    $B3,x
 .byte  $83
 lda    $79D3,x
 asl    $A6F4,x
 sbc    $7B,x
 .byte  $83
 .byte  $FC
 bcs    $F0EE
 jmp    ($1F0C,x)
 .byte  'g'
 dex
 jmp    ($53DE,x)
 .byte  $CB
 cmp    ($7D,x)
 .byte  $14
 stz    $70
 jmp    $B77D
 nop
 eor    ($7A),y
 adc    $3063,x
 dey
 ror    $927E,x
 .byte  'D'
 sta    $7E3A,y
 jmp    $91CC
 .byte  $C7
 .byte  $7F
 tax
 tax
 tax
 .byte  $13
 sta    ($00,x)
 brk
 brk
 brk
 inc    $B8
 bne    $F111
 inc    $B9
 lda    $EA60
 cmp    #$3A
 bcs    $F122
 cmp    #$20
 beq    $F10B
 sec
 sbc    #$30
 sec
 sbc    #$D0
 rts
 bra    $F174
 .byte  $C7
 eor    ($58)
 ldx    #$FF
 stx    $76
 ldx    #$FB
 txs
 lda    #$28
 ldy    #$F1
 sta    $01
 sty    $02
 sta    $04
 sty    $05
 jsr    $F273
 lda    #$4C
 sta    $00
 sta    $03
 sta    $90
 sta    $0A
 lda    #$99
 ldy    #$E1
 sta    $0B
 sty    $0C
 ldx    #$1C
 lda    $F10A,x
 sta    $B0,x
 stx    $F1
 dex
 bne    $F152
 stx    $F2
 txa
 sta    $A4
 sta    $54
 pha
 lda    #$03
 sta    $8F
 jsr    $DAFB
 lda    #$01
 sta    $01FD
 sta    $01FC
 ldx    #$55
 stx    $52
 lda    #$00
 ldy    #$08
 sta    $50
 sty    $51
 ldy    #$00
 inc    $51
 lda    ($50),y
 eor    #$FF
 sta    ($50),y
 cmp    ($50),y
 bne    $F195
 eor    #$FF
 sta    ($50),y
 cmp    ($50),y
 beq    $F181
 ldy    $50
 lda    $51
 and    #$F0
 sty    $73
 sta    $74
 sty    $6F
 sta    $70
 ldx    #$00
 ldy    #$08
 stx    $67
 sty    $68
 ldy    #$00
 sty    $D6
 tya
 sta    ($67),y
 inc    $67
 bne    $F1B8
 inc    $68
 lda    $67
 ldy    $68
 jsr    $D3E3
 jsr    $D64B
 lda    #$3A
 ldy    #$DB
 sta    $04
 sty    $05
 lda    #$3C
 ldy    #$D4
 sta    $01
 sty    $02
 jmp    ($0001)
 jsr    $DD67
 jsr    $E752
 jmp    ($0050)
 jsr    $E6F8
 txa
 jmp    $FE8B
 jsr    $E6F8
 txa
 jmp    $FE95
 jsr    $E6F8
 cpx    #$50
 bcs    $F206
 stx    $F0
 lda    #$2C
 jsr    $DEC0
 jsr    $E6F8
 cpx    #$50
 bcs    $F206
 stx    $2C
 stx    $2D
 rts
 jmp    $E199
 jsr    $F1EC
 cpx    $F0
 bcs    $F218
 lda    $F0
 sta    $2C
 sta    $2D
 stx    $F0
 lda    #$C5
 jsr    $DEC0
 jsr    $E6F8
 cpx    #$50
 bcs    $F206
 rts
 jsr    $F1EC
 ldy    $F0
 jsr    $F775
 txa
 jmp    $F39F
 brk
 jsr    $F209
 ldy    $2C
 jsr    $F775
 cpx    #$30
 bcs    $F206
 jmp    $F796
 jsr    $F209
 txa
 tay
 jsr    $F775
 lda    $F0
 jmp    $F783
 brk
 jsr    $E6F8
 txa
 jmp    $F864
 jsr    $E6F8
 dex
 txa
 cmp    #$18
 bcs    $F206
 jmp    $FB5B
 jsr    $E6F8
 txa
 eor    #$FF
 tax
 inx
 stx    $F1
 rts
 sec
 bcc    $F288
 ror    $F2
 rts
 lda    #$FF
 bne    $F279
 lda    #$3F
 ldx    #$00
 sta    $32
 stx    $F3
 rts
 lda    #$7F
 ldx    #$40
 bne    $F27B
 jsr    $DD67
 jsr    $E752
 lda    $50
 cmp    $6D
 lda    $51
 sbc    $6E
 bcs    $F299
 jmp    $D410
 lda    $50
 sta    $73
 sta    $6F
 lda    $51
 sta    $74
 sta    $70
 rts
 jsr    $DD67
 jsr    $E752
 lda    $50
 cmp    $73
 lda    $51
 sbc    $74
 bcs    $F296
 lda    $50
 cmp    $69
 lda    $51
 sbc    $6A
 bcc    $F296
 lda    $50
 sta    $69
 lda    $51
 sta    $6A
 jmp    $D66C
 lda    #$AB
 jsr    $DEC0
 lda    $B8
 sta    $F4
 lda    $B9
 sta    $F5
 sec
 ror    $D8
 lda    $75
 sta    $F6
 lda    $76
 sta    $F7
 jsr    $D9A6
 jmp    $D998
 stx    $DE
 ldx    $F8
 stx    $DF
 lda    $75
 sta    $DA
 lda    $76
 sta    $DB
 lda    $79
 sta    $DC
 lda    $7A
 sta    $DD
 lda    $F4
 sta    $B8
 lda    $F5
 sta    $B9
 lda    $F6
 sta    $75
 lda    $F7
 sta    $76
 jsr    $00B7
 jsr    $D93E
 jmp    $D7D2
 lda    $DA
 sta    $75
 lda    $DB
 sta    $76
 lda    $DC
 sta    $B8
 lda    $DD
 sta    $B9
 ldx    $DF
 txs
 jmp    $D7D2
 jmp    $DEC9
 bcs    $F32E
 ldx    $AF
 stx    $69
 ldx    $B0
 stx    $6A
 jsr    $DA0C
 jsr    $D61A
 lda    $9B
 sta    $60
 lda    $9C
 sta    $61
 lda    #$2C
 jsr    $DEC0
 jsr    $DA0C
 inc    $50
 bne    $F357
 inc    $51
 jsr    $D61A
 lda    $9B
 cmp    $60
 lda    $9C
 sbc    $61
 bcs    $F365
 rts
 ldy    #$00
 lda    ($9B),y
 sta    ($60),y
 inc    $9B
 bne    $F371
 inc    $9C
 inc    $60
 bne    $F377
 inc    $61
 lda    $69
 cmp    $9B
 lda    $6A
 sbc    $9C
 bcs    $F367
 ldx    $61
 ldy    $60
 bne    $F388
 dex
 dey
 stx    $6A
 sty    $69
 jmp    $D4F2
 lda    $C056
 lda    $C053
 jmp    $D8EC
 lda    $C054
 jmp    $FB39
 lsr    a
 php
 jsr    $F847
 plp
 lda    #$0F
 bcc    $F3AB
 adc    #$E0
 sta    $2E
 phy
 jsr    $F7BB
 bcc    $F3BD
 phx
 lda    $30
 tax
 lsr    a
 txa
 ror    a
 sec
 sta    $30
 jsr    $F80E
 bcc    $F3C9
 lda    $C054
 stx    $30
 plx
 clc
 ply
 rts
 lda    $C079
 eor    #$80
 and    $C018
 and    $C01F
 asl    a
 rts
 bit    $C055
 bit    $C052
 lda    #$40
 bne    $F3EA
 lda    #$20
 bit    $C054
 bit    $C053
 sta    $E6
 lda    $C057
 lda    $C050
 lda    #$00
 sta    $1C
 lda    $E6
 sta    $1B
 ldy    #$00
 sty    $1A
 lda    $1C
 sta    ($1A),y
 jsr    $F47E
 iny
 bne    $F3FE
 inc    $1B
 lda    $1B
 and    #$1F
 bne    $F3FE
 rts
 sta    $E2
 stx    $E0
 sty    $E1
 pha
 and    #$C0
 sta    $26
 lsr    a
 lsr    a
 ora    $26
 sta    $26
 pla
 sta    $27
 asl    a
 asl    a
 asl    a
 rol    $27
 asl    a
 rol    $27
 asl    a
 ror    $26
 lda    $27
 and    #$1F
 ora    $E6
 sta    $27
 txa
 cpy    #$00
 beq    $F442
 ldy    #$23
 adc    #$04
 iny
 sbc    #$07
 bcs    $F441
 sty    $E5
 tax
 lda    $F4B9,x
 sta    $30
 tya
 lsr    a
 lda    $E4
 sta    $1C
 bcs    $F47E
 rts
 jsr    $F411
 lda    $1C
 eor    ($26),y
 and    $30
 eor    ($26),y
 sta    ($26),y
 rts
 bpl    $F48A
 lda    $30
 lsr    a
 bcs    $F471
 eor    #$C0
 sta    $30
 rts
 dey
 bpl    $F476
 ldy    #$27
 lda    #$C0
 sta    $30
 sty    $E5
 lda    $1C
 asl    a
 cmp    #$C0
 bpl    $F489
 lda    $1C
 eor    #$7F
 sta    $1C
 rts
 lda    $30
 asl    a
 eor    #$80
 bmi    $F46E
 lda    #$81
 iny
 cpy    #$28
 bcc    $F478
 ldy    #$00
 bcs    $F478
 clc
 lda    $D1
 and    #$04
 beq    $F4C8
 lda    #$7F
 and    $30
 and    ($26),y
 bne    $F4C4
 inc    $EA
 lda    #$7F
 and    $30
 bpl    $F4C4
 clc
 lda    $D1
 and    #$04
 beq    $F4C8
 lda    ($26),y
 eor    $1C
 and    $30
 bne    $F4C4
 inc    $EA
 eor    ($26),y
 sta    ($26),y
 lda    $D1
 adc    $D3
 and    #$03
 cmp    #$02
 ror    a
 bcs    $F465
 bmi    $F505
 clc
 lda    $27
 bit    $F5B9
 bne    $F4FF
 asl    $26
 bcs    $F4FB
 bit    $F4CD
 beq    $F4EB
 adc    #$1F
 sec
 bcs    $F4FD
 adc    #$23
 pha
 lda    $26
 adc    #$B0
 bcs    $F4F6
 adc    #$F0
 sta    $26
 pla
 bcs    $F4FD
 adc    #$1F
 ror    $26
 adc    #$FC
 sta    $27
 rts
 clc
 lda    $27
 adc    #$04
 bit    $F5B9
 bne    $F501
 asl    $26
 bcc    $F52A
 adc    #$E0
 clc
 bit    $F508
 beq    $F52C
 lda    $26
 adc    #$50
 eor    #$F0
 beq    $F524
 eor    #$F0
 sta    $26
 lda    $E6
 bcc    $F52C
 adc    #$E0
 ror    $26
 bcc    $F501
 pha
 lda    #$00
 sta    $E0
 sta    $E1
 sta    $E2
 pla
 pha
 sec
 sbc    $E0
 pha
 txa
 sbc    $E1
 sta    $D3
 bcs    $F550
 pla
 eor    #$FF
 adc    #$01
 pha
 lda    #$00
 sbc    $D3
 sta    $D1
 sta    $D5
 pla
 sta    $D0
 sta    $D4
 pla
 sta    $E0
 stx    $E1
 tya
 clc
 sbc    $E2
 bcc    $F568
 eor    #$FF
 adc    #$FE
 sta    $D2
 sty    $E2
 ror    $D3
 sec
 sbc    $D0
 tax
 lda    #$FF
 sbc    $D1
 sta    $1D
 ldy    $E5
 bcs    $F581
 asl    a
 jsr    $F465
 sec
 lda    $D4
 adc    $D2
 sta    $D4
 lda    $D5
 sbc    #$00
 sta    $D5
 lda    ($26),y
 eor    $1C
 and    $30
 eor    ($26),y
 sta    ($26),y
 inx
 bne    $F59E
 inc    $1D
 beq    $F600
 lda    $D3
 bcs    $F57C
 jsr    $F4D3
 clc
 lda    $D4
 adc    $D0
 sta    $D4
 lda    $D5
 adc    $D1
 bvc    $F58B
 sta    ($82,x)
 sty    $88
 bcc    $F558
 cpy    #$1C
 .byte  $FF
 inc    $F4FA,x
 cpx    $D4E1
 cmp    $B4
 lda    ($8D,x)
 sei
 adc    ($49,x)
 and    ($18),y
 .byte  $FF
 lda    $26
 asl    a
 lda    $27
 and    #$03
 rol    a
 ora    $26
 asl    a
 asl    a
 asl    a
 sta    $E2
 lda    $27
 lsr    a
 lsr    a
 and    #$07
 ora    $E2
 sta    $E2
 lda    $E5
 asl    a
 adc    $E5
 asl    a
 tax
 dex
 lda    $30
 and    #$7F
 inx
 lsr    a
 bne    $F5F0
 sta    $E1
 txa
 clc
 adc    $E5
 bcc    $F5FE
 inc    $E1
 sta    $E0
 rts
 stx    $1A
 sty    $1B
 tax
 lsr    a
 lsr    a
 lsr    a
 lsr    a
 sta    $D3
 txa
 and    #$0F
 tax
 ldy    $F5BA,x
 sty    $D0
 eor    #$0F
 tax
 ldy    $F5BB,x
 iny
 sty    $D2
 ldy    $E5
 ldx    #$00
 stx    $EA
 lda    ($1A,x)
 sta    $D1
 ldx    #$80
 stx    $D4
 stx    $D5
 ldx    $E7
 lda    $D4
 sec
 adc    $D0
 sta    $D4
 bcc    $F63D
 jsr    $F4B3
 clc
 lda    $D5
 adc    $D2
 sta    $D5
 bcc    $F648
 jsr    $F4B4
 dex
 bne    $F630
 lda    $D1
 lsr    a
 lsr    a
 lsr    a
 bne    $F626
 inc    $1A
 bne    $F658
 inc    $1B
 lda    ($1A,x)
 bne    $F626
 rts
 stx    $1A
 sty    $1B
 tax
 lsr    a
 lsr    a
 lsr    a
 lsr    a
 sta    $D3
 txa
 and    #$0F
 tax
 ldy    $F5BA,x
 sty    $D0
 eor    #$0F
 tax
 ldy    $F5BB,x
 iny
 sty    $D2
 ldy    $E5
 ldx    #$00
 stx    $EA
 lda    ($1A,x)
 sta    $D1
 ldx    #$80
 stx    $D4
 stx    $D5
 ldx    $E7
 lda    $D4
 sec
 adc    $D0
 sta    $D4
 bcc    $F699
 jsr    $F49C
 clc
 lda    $D5
 adc    $D2
 sta    $D5
 bcc    $F6A4
 jsr    $F49D
 dex
 bne    $F68C
 lda    $D1
 lsr    a
 lsr    a
 lsr    a
 bne    $F682
 inc    $1A
 bne    $F6B4
 inc    $1B
 lda    ($1A,x)
 bne    $F682
 rts
 jsr    $DD67
 jsr    $E752
 ldy    $51
 ldx    $50
 cpy    #$01
 bcc    $F6CD
 bne    $F6E6
 cpx    #$18
 bcs    $F6E6
 txa
 pha
 tya
 pha
 lda    #$2C
 jsr    $DEC0
 jsr    $E6F8
 cpx    #$C0
 bcs    $F6E6
 stx    $9D
 pla
 tay
 pla
 tax
 lda    $9D
 rts
 jmp    $F206
 jsr    $E6F8
 cpx    #$08
 bcs    $F6E6
 lda    $F6F6,x
 sta    $E4
 rts
 brk
 rol    a
 eor    $7F,x
 bra    $F6A6
 cmp    $FF,x
 cmp    #$C1
 beq    $F70F
 jsr    $F6B9
 jsr    $F457
 jsr    $00B7
 cmp    #$C1
 bne    $F6F5
 jsr    $DEC0
 jsr    $F6B9
 sty    $9D
 tay
 txa
 ldx    $9D
 jsr    $F53A
 jmp    $F708
 jsr    $E6F8
 stx    $F9
 rts
 jsr    $E6F8
 stx    $E7
 rts
 jsr    $E6F8
 lda    $E8
 sta    $1A
 lda    $E9
 sta    $1B
 txa
 ldx    #$00
 cmp    ($1A,x)
 beq    $F741
 bcs    $F6E6
 asl    a
 bcc    $F747
 inc    $1B
 clc
 tay
 lda    ($1A),y
 adc    $1A
 tax
 iny
 lda    ($1A),y
 adc    $E9
 sta    $1B
 stx    $1A
 jsr    $00B7
 cmp    #$C5
 bne    $F766
 jsr    $DEC0
 jsr    $F6B9
 jsr    $F411
 lda    $F9
 rts
 jsr    $F72D
 jmp    $F605
 jsr    $F72D
 jmp    $F661
 jsr    $F3CB
 bcs    $F77E
 cpy    #$28
 bcs    $F73F
 cpy    #$50
 bcs    $F73F
 rts
 pha
 lda    $2D
 cmp    #$30
 pla
 bcs    $F73F
 pha
 jsr    $F39F
 pla
 cmp    $2D
 inc    a
 bcc    $F78B
 rts
 txa
 ldy    $F0
 jsr    $F39F
 cpy    $2C
 bcs    $F795
 iny
 jsr    $F3AD
 bra    $F79C
 pha
 jsr    $F7BB
 pla
 php
 jsr    $F871
 plp
 bcc    $F7BA
 sta    $C054
 cmp    #$08
 asl    a
 and    #$0F
 rts
 jsr    $F3CB
 bcc    $F7CA
 tya
 eor    #$01
 lsr    a
 tay
 bcc    $F7CA
 lda    $C055
 rts
 txa
 bit    $C01F
 bmi    $F7E3
 bit    $2485
 sec
 txa
 sbc    $24
 rts
 lda    #$40
 sta    $14
 jsr    $DFE3
 stz    $14
 rts
 sbc    $057B
 rts
 jsr    $E6F8
 dex
 lda    #$28
 cmp    $21
 bcs    $F7F3
 lda    $21
 jsr    $F7D2
 stx    $24
 bcc    $F7D8
 tax
 jsr    $DAFB
 bra    $F7EB
 lsr    a
 php
 jsr    $F847
 plp
 lda    #$0F
 bcc    $F80C
 adc    #$E0
 sta    $2E
 lda    ($26),y
 eor    $30
 and    $2E
 eor    ($26),y
 sta    ($26),y
 rts
 jsr    $F800
 cpy    $2C
 bcs    $F831
 iny
 jsr    $F80E
 bcc    $F81C
 adc    #$01
 pha
 jsr    $F800
 pla
 cmp    $2D
 bcc    $F826
 rts
 ldy    #$2F
 bne    $F838
 ldy    #$27
 sty    $2D
 ldy    #$27
 lda    #$00
 sta    $30
 jsr    $F828
 dey
 bpl    $F83C
 rts
 pha
 lsr    a
 and    #$03
 ora    #$04
 sta    $27
 pla
 and    #$18
 bcc    $F856
 adc    #$7F
 sta    $26
 asl    a
 asl    a
 ora    $26
 sta    $26
 rts
 lda    $30
 clc
 adc    #$03
 and    #$0F
 sta    $30
 asl    a
 asl    a
 asl    a
 asl    a
 ora    $30
 sta    $30
 rts
 lsr    a
 php
 jsr    $F847
 lda    ($26),y
 plp
 bcc    $F87F
 lsr    a
 lsr    a
 lsr    a
 lsr    a
 and    #$0F
 rts
 ldx    $3A
 ldy    $3B
 jsr    $FD96
 jsr    $F948
 lda    ($3A,x)
 tay
 lsr    a
 bcc    $F897
 ror    a
 bcs    $F8A1
 and    #$87
 lsr    a
 tax
 lda    $F962,x
 jsr    $F879
 bne    $F8A5
 ldy    #$FC
 lda    #$00
 tax
 lda    $F9A6,x
 sta    $2E
 and    #$03
 sta    $2F
 jsr    $FC35
 beq    $F8CC
 and    #$8F
 tax
 tya
 ldy    #$03
 cpx    #$8A
 beq    $F8C9
 lsr    a
 bcc    $F8C9
 lsr    a
 lsr    a
 ora    #$20
 dey
 bne    $F8C2
 iny
 dey
 bne    $F8BE
 rts
 .byte  $FF
 .byte  $FF
 .byte  $FF
 jsr    $F882
 pha
 lda    ($3A),y
 jsr    $FDDA
 ldx    #$01
 jsr    $F94A
 cpy    $2F
 iny
 bcc    $F8D4
 ldx    #$03
 cpy    #$04
 bcc    $F8DB
 pla
 tay
 lda    $F9C0,y
 sta    $2C
 lda    $FA00,y
 sta    $2D
 lda    #$00
 ldy    #$05
 asl    $2D
 rol    $2C
 rol    a
 dey
 bne    $F8F9
 adc    #$BF
 jsr    $FDED
 dex
 bne    $F8F5
 jsr    $F948
 ldy    $2F
 ldx    #$06
 cpx    #$03
 beq    $F930
 asl    $2E
 bcc    $F926
 lda    $F9B9,x
 jsr    $FDED
 lda    $F9B3,x
 beq    $F926
 jsr    $FDED
 dex
 bne    $F910
 rts
 dey
 bmi    $F914
 jsr    $FDDA
 lda    $2E
 cmp    #$E8
 lda    ($3A),y
 bcc    $F92A
 jsr    $F956
 tax
 inx
 bne    $F940
 iny
 tya
 jsr    $FDDA
 txa
 jmp    $FDDA
 ldx    #$03
 lda    #$A0
 jsr    $FDED
 dex
 bne    $F94A
 rts
 sec
 lda    $2F
 ldy    $3B
 tax
 bpl    $F95C
 dey
 adc    $3A
 bcc    $F961
 iny
 rts
 .byte  $0F
 .byte  $22
 .byte  $FF
 .byte  $33
 .byte  $CB
 .byte  'b'
 .byte  $FF
 .byte  's'
 .byte  $03
 .byte  $22
 .byte  $FF
 .byte  $33
 .byte  $CB
 ror    $FF
 .byte  'w'
 .byte  $0F
 jsr    $33FF
 .byte  $CB
 rts
 .byte  $FF
 bvs    $F98A
 .byte  $22
 .byte  $FF
 and    $66CB,y
 .byte  $FF
 adc    $220B,x
 .byte  $FF
 .byte  $33
 .byte  $CB
 ldx    $FF
 .byte  's'
 ora    ($22),y
 .byte  $FF
 .byte  $33
 .byte  $CB
 ldx    $FF
 .byte  $87
 ora    ($22,x)
 .byte  $FF
 .byte  $33
 .byte  $CB
 rts
 .byte  $FF
 bvs    $F99C
 .byte  $22
 .byte  $FF
 .byte  $33
 .byte  $CB
 rts
 .byte  $FF
 bvs    $F9C7
 and    ($65),y
 sei
 brk
 and    ($81,x)
 .byte  $82
 eor    $914D,y
 sta    ($86)
 lsr    a
 sta    $9D
 eor    #$5A
 cmp    $D800,y
 ldy    $A4
 brk
 ldy    $ACA9
 .byte  $A3
 tay
 ldy    $1C
 txa
 .byte  $1C
 .byte  $23
 eor    $1B8B,x
 lda    ($9D,x)
 txa
 ora    $9D23,x
 .byte  $8B
 ora    $1CA1,x
 and    #$19
 ldx    $A869
 ora    $2423,y
 .byte  'S'
 .byte  $1B
 .byte  $23
 bit    $53
 ora    $ADA1,y
 inc    a
 .byte  '['
 .byte  '['
 lda    $69
 bit    $24
 ldx    $A8AE
 lda    $8A29
 jmp    ($158B,x)
 stz    $9C6D
 lda    $69
 and    #$53
 sty    $13
 bit    $11,x
 lda    $69
 .byte  $23
 ldy    #$D8
 .byte  'b'
 phy
 pha
 rol    $62
 sty    $88,x
 .byte  'T'
 .byte  'D'
 iny
 .byte  'T'
 pla
 .byte  'D'
 inx
 sty    $C4,x
 ldy    $08,x
 sty    $74
 ldy    $28,x
 ror    $F474
 cpy    $724A
 sbc    ($A4)
 txa
 asl    $AA
 ldx    #$A2
 stz    $74,x
 stz    $72,x
 .byte  'D'
 pla
 lda    ($32)
 lda    ($72)
 .byte  $22
 adc    ($1A)
 inc    a
 rol    $26
 adc    ($72)
 dey
 iny
 cpy    $CA
 rol    $48
 .byte  'D'
 .byte  'D'
 ldx    #$C8
 sta    $45
 lda    $45
 jmp    $C803
 sta    $44
 ply
 plx
 pla
 plp
 jsr    $FF4A
 pla
 sta    $3A
 pla
 sta    $3B
 jmp    ($03F0)
 jsr    $F882
 jsr    $FADA
 jmp    $FF65
 cld
 jsr    $FE84
 jsr    $FB2F
 jsr    $CE4D
 jsr    $C740
 jsr    $CC04
 stz    $04FC
 lda    $C05F
 jsr    $FABD
 bit    $C010
 bra    $FA85
 .byte  $FF
 cld
 jsr    $FF3A
 lda    $03F3
 eor    #$A5
 cmp    $03F4
 bne    $FAA6
 lda    $03F2
 bne    $FAA3
 lda    #$E0
 cmp    $03F3
 bne    $FAA3
 ldy    #$03
 sty    $03F2
 jmp    $E000
 jmp    ($03F2)
 jsr    $FCCA
 ldx    #$05
 lda    $FAFC,x
 sta    $03EF,x
 dex
 bne    $FAAB
 lda    #$C4
 bra    $FB12
 txa
 .byte  $8B
 lda    $AC
 brk
 lda    #$FF
 sta    $04FB
 jsr    $FF3A
 jsr    $C5F8
 asl    $C062
 bit    $C061
 bpl    $FB2E
 bcc    $FAA6
 jmp    $C7C1
 nop
 nop
 jsr    $FD8E
 lda    #$44
 sta    $40
 lda    #$00
 sta    $41
 ldx    #$FA
 lda    #$A0
 jsr    $FDED
 lda    $CE9A,x
 jsr    $FDED
 lda    #$BD
 jsr    $FDED
 lda    $4A,x
 bra    $FB02
 stz    $74,x
 ror    $C6,x
 brk
 eor    $00FA,y
 cpx    #$45
 jsr    $FDDA
 inx
 bmi    $FAE4
 rts
 cmp    ($F0,x)
 beq    $FAF9
 sbc    $A0
 cmp    $C4DB,x
 stx    $00
 sta    $01
 jsr    $FB60
 jmp    ($0000)
 .byte  $FF
 .byte  $FF
 jmp    $C900
 ldy    #$00
 nop
 nop
 lda    $C064,x
 bpl    $FB2E
 iny
 bne    $FB25
 dey
 rts
 lda    #$00
 sta    $48
 lda    $C056
 lda    $C054
 lda    $C051
 lda    #$00
 beq    $FB4B
 lda    $C050
 lda    $C053
 jsr    $F836
 lda    #$14
 sta    $22
 nop
 nop
 jsr    $CE0A
 bra    $FB59
 ora    #$80
 jmp    $CD54
 lda    #$17
 sta    $25
 jmp    $FC22
 jsr    $FC58
 ldy    #$09
 lda    $C5BA,y
 sta    $040D,y
 dey
 bne    $FB65
 rts
 lda    $03F3
 eor    #$A5
 sta    $03F4
 rts
 cmp    #$8D
 bne    $FB94
 ldy    $C000
 bpl    $FB94
 cpy    #$93
 bne    $FB94
 bit    $C010
 ldy    $C000
 bpl    $FB88
 cpy    #$83
 beq    $FB94
 bit    $C010
 bit    $067B
 bmi    $FBFD
 bit    #$60
 beq    $FB54
 jsr    $C3B8
 inc    $057B
 lda    $057B
 bit    $C01F
 bmi    $FBB0
 sta    $047B
 sta    $24
 bra    $FBF8
 .byte  $FF
 asl    $10
 asl    $C9
 ldy    #$90
 .byte  $02
 and    $32
 jmp    $FDF6
.if ROMVER = 255
 .byte  $FF
.elseif ROMVER = 0
 .byte  $00
.elseif ROMVER = 3
 .byte  $03
.elseif ROMVER = 4
 .byte  $04
.endif
 brk
 pha
 lsr    a
 and    #$03
 ora    #$04
 sta    $29
 pla
 and    #$18
 bcc    $FBD0
 adc    #$7F
 sta    $28
 asl    a
 asl    a
 ora    $28
 sta    $28
 rts
 cmp    #$87
 bne    $FBEF
 lda    #$40
 jsr    $FCA8
 ldy    #$C0
 lda    #$0C
 jsr    $FCA8
 lda    $C030
 dey
 bne    $FBE4
 rts
 ldy    $24
 sta    ($28),y
 inc    $24
 lda    $24
 cmp    $21
 bcs    $FC62
 rts
 cmp    #$A0
 bcs    $FBF0
 tay
 bpl    $FBF0
 cmp    #$8D
 beq    $FC73
 cmp    #$8A
 beq    $FC66
 cmp    #$88
 bne    $FBD9
 jsr    $FEE2
 bpl    $FBFC
 lda    $21
 jsr    $FEEB
 lda    $22
 cmp    $25
 bcs    $FBFC
 dec    $25
 bra    $FC86
 jsr    $FBC1
 lda    $20
 bit    $C01F
 bpl    $FC30
 lsr    a
 clc
 adc    $28
 sta    $28
 rts
 tya
 ldx    #$16
 cmp    $FEFE,x
 beq    $FC80
 dex
 bpl    $FC38
 rts
 .byte  $FF
 bra    $FC5D
 lda    $25
 pha
 jsr    $FC24
 jsr    $FC9E
 ldy    #$00
 pla
 inc    a
 cmp    $23
 bcc    $FC46
 bcs    $FC22
 .byte  $FF
 jsr    $CDA5
 bra    $FC44
 jsr    $CC9D
 bra    $FC44
 bra    $FC73
 .byte  $FF
 .byte  $FF
 inc    $25
 lda    $25
 cmp    $23
 bcc    $FC88
 dec    $25
 jmp    $CB35
 jsr    $FEE9
 bit    $04FB
 bpl    $FC85
 jsr    $FD44
 bra    $FC66
 lda    $FF15,x
 ldy    #$00
 rts
 lda    $25
 sta    $05FB
 bra    $FC24
 jsr    $CC9D
 lda    #$A0
 bit    $067B
 bmi    $FC99
 and    $32
 jmp    $CBC2
 bra    $FC8D
 bra    $FC90
 ldy    #$00
 bra    $FC90
 jmp    ($CD2A,x)
 nop
 sec
 pha
 sbc    #$01
 bne    $FCAA
 pla
 sbc    #$01
 bne    $FCA9
 rts
 inc    $42
 bne    $FCBA
 inc    $43
 lda    $3C
 cmp    $3E
 lda    $3D
 sbc    $3F
 inc    $3C
 bne    $FCC8
 inc    $3D
 rts
 rts
 ldy    #$B0
 stz    $3C
 ldx    #$BF
 stx    $3D
 lda    #$A0
 sta    ($3C),y
 dey
 sta    ($3C),y
 dex
 cpx    #$01
 bne    $FCD0
 sta    $C001
 lda    $C055
 ldx    #$88
 lda    $CF8B,x
 bcc    $FCF5
 cmp    $0477,x
 clc
 bne    $FCF5
 cpx    #$82
 bcc    $FCFB
 sta    $0477,x
 dex
 bne    $FCE6
 lda    $C054
 sta    $C000
 rts

.if ROMVER = 255
 .byte  $FF
 .byte  $FF
 .byte  $FF
.elseif ROMVER = 0
 .byte  $FF
 .byte  $FF
 .byte  $FF
.elseif ROMVER = 3
 .byte  $F1
 .byte  $FF
 .byte  $FF
.elseif ROMVER = 4
 .byte  $FF
 .byte  $B2
 .byte  $FE
.endif

 .byte  $FF
 .byte  $FF
 .byte  $FF

.if ROMVER = 255
 .byte  $FF
 .byte  $FF
 .byte  $FF
 .byte  $FF
.elseif ROMVER = 0
 .byte  $FF
 .byte  $FF
 .byte  $FF
 .byte  $FF
.elseif ROMVER = 3
 .byte  $BF
 .byte  $FE
 .byte  $FE
 .byte  $FE
.elseif ROMVER = 4
 .byte  $FF
 .byte  $FF
 .byte  $FF
 .byte  $FF
.endif

 ldy    $24
 lda    ($28),y
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 jmp    ($0038)
 sta    ($28),y
 jsr    $CC4C
 jsr    $CC70
 bpl    $FD20
 pha
 lda    #$08
 bit    $04FB
 bne    $FD4A
 pla
 cmp    #$9B
 bne    $FD38
 jmp    $CCCC
 jmp    $CCED
 bit    $067B
 bmi    $FD44
 cmp    #$95
 bne    $FD44
 jsr    $CC1D
 pha
 lda    #$08
 .byte  $0C
 .byte  $FB
 .byte  $04
 pla
 rts
.if ROMVER = 255
 nop
.elseif ROMVER = 0
 nop
.elseif ROMVER = 3
 .byte  $FE
.elseif ROMVER = 4
 nop
.endif
 jsr    $C3A6
 cmp    #$88
 beq    $FD71
 cmp    #$98
 beq    $FD62
 cpx    #$F8
 bcc    $FD5F
 jsr    $FF3A
 inx
 bne    $FD75
 lda    #$DC
 jsr    $C3A6
 jsr    $FD8E
 lda    $33
 jsr    $FDED
 ldx    #$01
 txa
 beq    $FD67
 dex
 jsr    $CCED
 cmp    #$95
 bne    $FD84
 jsr    $CC1D
 nop
 nop
 nop
 nop
 nop
 sta    $0200,x
 cmp    #$8D
 bne    $FD4D
 jsr    $FC9C
 lda    #$8D
 bne    $FDED
 ldy    $3D
 ldx    $3C
 jsr    $FD8E
 jsr    $F940
 ldy    #$00
 lda    #$AD
 jmp    $FDED
 lda    $3C
 ora    #$07
 sta    $3E
 lda    $3D
 sta    $3F
 lda    $3C
 and    #$07
 bne    $FDB6
 jsr    $FD92
 lda    #$A0
 jsr    $FDED
 lda    ($3C),y
 jsr    $FDDA
 jsr    $FCBA
 bcc    $FDAD
 rts
 lsr    a
 bcc    $FDB3
 lsr    a
 lsr    a
 lda    $3E
 bcc    $FDD1
 eor    #$FF
 adc    $3C
 pha
 lda    #$BD
 jsr    $FDED
 pla
 pha
 lsr    a
 lsr    a
 lsr    a
 lsr    a
 jsr    $FDE5
 pla
 and    #$0F
 ora    #$B0
 cmp    #$BA
 bcc    $FDED
 adc    #$06
 jmp    ($0036)
 bit    $067B
 jmp    $FBB4
 sty    $35
 pha
 jsr    $FB78
 pla
 ldy    $35
 rts
 dec    $34
 beq    $FDA3
 dex
 bne    $FE1D
 cmp    #$BA
 bne    $FDC6
 sta    $31
 lda    $3E
 sta    ($40),y
 inc    $40
 bne    $FE17
 inc    $41
 rts
 ldy    $34
 lda    $01FF,y
 sta    $31
 rts
 ldx    #$01
 lda    $3E,x
 sta    $42,x
 sta    $44,x
 dex
 bpl    $FE22
 rts
 lda    ($3C),y
 sta    ($42),y
 jsr    $FCB4
 bcc    $FE2C
 rts
 lda    ($3C),y
 cmp    ($42),y
 beq    $FE58
 jsr    $FD92
 lda    ($3C),y
 jsr    $FDDA
 lda    #$A0
 jsr    $FDED
 lda    #$A8
 jsr    $FDED
 lda    ($42),y
 jsr    $FDDA
 lda    #$A9
 jsr    $FDED
 jsr    $FCB4
 bcc    $FE36
 rts
 jsr    $FE75
 lda    #$14
 pha
 jsr    $C5C4
 pla
 dec    a
 bne    $FE63
 rts
 jmp    $C986
 dec    $34
 jmp    $CA43

.if ROMVER = 255
 .byte  $60
.elseif ROMVER = 0
 .byte  $00
.elseif ROMVER = 3
 .byte  $00
.elseif ROMVER = 4
 .byte  $10
.endif
 .byte  $8A
 beq    $FE7F
 lda    $3C,x
 sta    $3A,x
 dex
 bpl    $FE78
 rts
 ldy    #$3F
 bne    $FE86
 ldy    #$FF
 sty    $32
 rts
 lda    #$00
 sta    $3E
 ldx    #$38
 ldy    #$1B
 bne    $FE9B
 lda    #$00
 sta    $3E
 ldx    #$36
 ldy    #$F0
 lda    $3E
 and    #$0F
 bne    $FEA7
 cpy    #$1B
 beq    $FEDE
 bra    $FEC2
 ora    #$C0
 ldy    #$00
 sty    $00,x
 sta    $01,x
 rts
 jmp    $E000
 jmp    $E003
 jsr    $FE75
 jsr    $FF3F
 jmp    ($003A)
 jmp    $FAD7
 dec    a
 sta    $07FB
 lda    #$F7
 bra    $FECE
 jmp    $03F8
 rts
 sta    $067B
 sta    $C00E
 .byte  $0C
 .byte  $FB
 .byte  $04
 phx
 phy
 jsr    $CDCD
 ply
 plx
 lda    #$FD
 bra    $FEAB
 phy
 jsr    $CC9D
 dey
 bra    $FEEE
 lda    #$01
 dec    a
 phy
 tay
 jsr    $CCAD
 ply
 lda    $057B
 rts
 jsr    $FE00
 pla
 pla
 bne    $FF69
 rts
 ora    ($14)
 inc    a
 .byte  $1C
 and    ($34)
 dec    a
 bit    $5A52,x
 stz    $72
 stz    $7A,x
 jmp    ($9289,x)
 stz    $B29E
 cmp    ($F2)
 .byte  $FC
 sec
 .byte  $FB
 .byte  $37
 .byte  $FB
 and    $3621,y
 and    ($3A,x)
 sed
 plx
 .byte  $3B
 plx
 sbc    $2122,y
 bit    $FAFA,x
 and    $3F3E,x
 .byte  $FC
 brk
 lda    #$C5
 jsr    $FDED
 lda    #$D2
 jsr    $FDED
 jsr    $FDED
 lda    #$87
 jmp    $FDED
 lda    $48
 pha
 lda    $45
 ldx    $46
 ldy    $47
 plp
 rts
 sta    $45
 stx    $46
 sty    $47
 php
 pla
 sta    $48
 tsx
 stx    $49
 cld
 rts
 jsr    $FE84
 jsr    $FB2F
 jsr    $FE93
 jsr    $FE89
 cld
 jsr    $FF3A
 lda    #$AA
 sta    $33
 jsr    $FD67
 jsr    $FFC7
 jsr    $FFA7
 sty    $34
 ldy    #$17
 dey
 bmi    $FF65
 cmp    $FFCC,y
 bne    $FF7A
 jsr    $FFBE
 ldy    $34
 jmp    $FF73
 ldx    #$03
 asl    a
 asl    a
 asl    a
 asl    a
 asl    a
 rol    $3E
 rol    $3F
 dex
 bpl    $FF90
 lda    $31
 bne    $FFA2
 lda    $3F,x
 sta    $3D,x
 sta    $41,x
 inx
 beq    $FF98
 bne    $FFAD
 ldx    #$00
 stx    $3E
 stx    $3F
 jsr    $C5B4
 eor    #$B0
 cmp    #$0A
 bcc    $FF8A
 adc    #$88
 cmp    #$FA
 jmp    $CFCB
 brk
 lda    #$FE
 pha
 lda    $FFE3,y
 pha
 lda    $31
 ldy    #$00
 sty    $31
 rts
 ldy    $BEB2,x
 txs
 .byte  $EF
 cpy    $A9
 .byte  $BB
 ldx    $A4
 asl    $95
 .byte  $07
 .byte  $02
 ora    $00
 .byte  $93
 .byte  $A7
 dec    $99
 cpx    $EAED
 lda    ($C9)
 ldx    $356B,y
 sty    $AF96
 .byte  $17
 .byte  $17
 .byte  $2B
 .byte  $1F
 .byte  $83
 .byte  $7F
 .byte  $5D
 .byte  $B5
 .byte  $17
 .byte  $17
 .byte  $F5
 .byte  $03
 .byte  $70
 .byte  $6E
 .byte  $00
 .word  $03FB
 .word  $FA62
 .word  $C803
