; Ohio Scientific Assembler Editor
;
; Disassembled from cassette version of Ohio Scientific Assembler
; Editor The original has a small loader at the front which is not
; included.
;
; For details and usage see the manual "Assembler Editor and Extended
; Monitor Reference Manual (C1P, C4P and C8))".
;
; Occupies memory from $0240 -$1390
; Normally entered at $1300

        .org   $0240
        ldx    #$00
        beq    $0246
        ldx    #$06
        lda    ($24),y
        bmi    $0256
        eor    ($00,x)
        beq    $0251
        jmp    $11CF
        ldy    #$02
        jmp    $0284
        and    #$7F
        tay
        lda    ($00,x)
        cmp    $0267,y
        bmi    $024E
        cmp    $026B,y
        bmi    $0251
        bpl    $024E
        eor    ($30,x)
        eor    ($00,x)
        .byte  '['
        .byte  $3A
        .byte  'G'
        and    ($00,x)
        jsr    $04A0
        tax
        lda    ($24),y
        tay
        lda    $00,x
        sta    $0000,y
        lda    $01,x
        sta    $0001,y
        jmp    $11CF
        lda    ($24),y
        tax
        clc
        adc    $24
        sta    $24
        txa
        bmi    $0293
        lda    #$00
        beq    $0295
        lda    #$FF
        adc    $25
        sta    $25
        jmp    $02A9
        lda    ($24),y
        tax
        iny
        lda    ($24),y
        sta    $25
        stx    $24
        jmp    $1179
        clc
        tya
        adc    $24
        sta    $24
        lda    $25
        adc    #$00
        sta    $25
        jmp    $1179
        lda    ($24),y
        tax
        tay
        pla
        sta    $24
        pla
        sta    $25
        pla
        sta    $2A
        dex
        bpl    $0284
        jmp    $11CF
        .byte  $03
        .byte  $04
        brk
        ora    ($FF),y
        lda    ($24),y
        tax
        inc    $00,x
        bne    $02D9
        inc    $01,x
        jmp    $11CF
        lda    ($24),y
        jsr    $02ED
        jmp    $11CF
        inc    $24
        bne    $02EA
        inc    $25
        jmp    ($0024)
        tax
        lda    $00,x
        bne    $02F4
        dec    $01,x
        dec    $00,x
        rts
        jsr    $0356
        bne    $0347
        ldy    $3F
        clv
        rts
        stx    $26
        stx    $EC
        lda    ($24),y
        tax
        lda    #$00
        sta    $00,x
        sta    $01,x
        ldy    $26
        lda    ($06),y
        and    #$0F
        sta    $E7
        txa
        tay
        lda    #$3C
        jsr    $0A84
        bcs    $0327
        inc    $26
        dec    $08
        bne    $030D
        jmp    $11CF
        ldy    #$02
        jmp    $0284
        lda    $1A
        sta    $12FE
        lda    $1B
        sta    $12FF
        lda    ($24),y
        asl    a
        jmp    $117E
        lda    #$0D
        jsr    $0343
        lda    #$0A
        cmp    #$0A
        bne    $0358
        dec    $FC
        bne    $034F
        lda    #$42
        sta    $FC
        lda    $12E0
        cmp    $FC
        bmi    $02F7
        lda    #$0A
        bit    $FF
        sty    $3F
        pha
        jmp    $0BF6
        jsr    $0341
        sec
        lda    $06
        sbc    $02
        beq    $0373
        tax
        lda    #$2D
        jsr    $0343
        dex
        bne    $036D
        lda    #$5E
        jsr    $0343
        lda    #$0D
        jsr    $0343
        jsr    $0341
        lda    ($24),y
        iny
        cmp    #$00
        beq    $0391
        jsr    $0343
        cmp    #$0D
        bne    $0380
        jsr    $0341
        tya
        clc
        adc    $24
        sta    $24
        lda    #$00
        adc    $25
        sta    $25
        jmp    $1179
        jsr    $04A0
        tax
        lda    ($24),y
        sta    $E4
        iny
        lda    ($24),y
        tay
        sec
        lda    $00,x
        sbc    $0000,y
        sta    $E5
        lda    $01,x
        sbc    $0001,y
        ldx    #$02
        ora    $E5
        beq    $03C4
        dex
        bcs    $03C4
        ldx    #$04
        txa
        nop
        nop
        and    $E4
        bne    $03CE
        jmp    $11CF
        ldy    #$04
        jmp    ($078A)
        .byte  $FF
        .byte  $03
        asl    $10,x
        ora    #$10
        .byte  $02
        .byte  $1A
        .byte  $04
        .byte  $04
        stx    $1104
        ldx    #$26
        ldy    #$7E
        lda    #$6A
        jsr    $052A
        jmp    $0D02
        inc    $06
        jmp    $0360
        brk
        lda    ($26),y
        sta    ($28),y
        ldx    #$46
        jsr    $02EE
        lda    $46
        ora    $47
        rts
        jsr    $04A0
        tax
        lda    ($24),y
        tay
        clc
        lda    $0000,y
        adc    $00,x
        sta    $E4
        lda    $0001,y
        adc    $01,x
        sta    $E5
        sec
        bcs    $042F
        jsr    $04A0
        tax
        lda    ($24),y
        tay
        sec
        lda    $00,x
        sbc    $0000,y
        sta    $E4
        lda    $01,x
        sbc    $0001,y
        sta    $E5
        ldy    #$03
        lda    ($24),y
        tax
        lda    $E4
        sta    $00,x
        lda    $E5
        sta    $01,x
        jmp    $11CF
        brk
        stx    $28
        stx    $0E
        stx    $27
        stx    $26
        ldy    $28
        lda    ($00),y
        cmp    $27
        bne    $0456
        dec    $26
        inc    $28
        bne    $0448
        tax
        ldy    $0E
        lda    $26
        beq    $0460
        sta    ($00),y
        iny
        txa
        sta    ($00),y
        sta    $27
        inc    $28
        iny
        sty    $0E
        ldx    #$00
        cmp    #$0D
        bne    $0446
        stx    $0F
        beq    $04BD
        jmp    $1303
        nop
        nop
        jmp    $132E
        asl    a
        bpl    $0491
        bpl    $048B
        .byte  $14
        .byte  'B'
        .byte  $14
        .byte  $03
        bit    $0912
        bpl    $048F
        .byte  $1A
        .byte  $03
        .byte  $12
        ora    ($8E,x)
        .byte  't'
        bpl    $04CA
        ora    $C8,x
        lda    ($10),y
        cmp    #$0D
        bne    $0493
        iny
        sty    $12
        jmp    ($07A2)
        lda    ($24),y
        bpl    $04AD
        and    #$7F
        sty    $E4
        tay
        lda    ($FA),y
        ldy    $E4
        iny
        rts
        jsr    $04A0
        tax
        lda    ($00,x)
        pha
        jsr    $04A0
        tax
        pla
        sta    ($00,x)
        jmp    $11CF
        .byte  $03
        sta    ($46,x)
        .byte  $03
        .byte  $82
        rol    $03
        .byte  $83
        plp
        ora    #$46
        .byte  $02
        bit    $0919
        rol    $04
        plp
        ora    $15,x
        dey
        beq    $04DE
        iny
        bne    $04DE
        inc    $27
        inc    $29
        jsr    $03F2
        bne    $04D7
        jsr    $11DC
        ora    ($0A),y
        lsr    $26
        rol    $0A
        lsr    $28
        plp
        ora    $88,x
        tya
        bne    $04F8
        dec    $27
        dec    $29
        dey
        jsr    $03F2
        bne    $04F1
        beq    $04E3
        lda    ($24),y
        tax
        lda    $00,x
        sta    $26
        lda    $01,x
        sta    $27
        dey
        ldx    #$FF
        lda    ($26),y
        bpl    $0515
        tax
        lda    $28
        jsr    $0343
        inx
        bmi    $0515
        sta    $28
        iny
        cmp    #$0D
        bne    $050C
        lda    #$00
        jsr    $033E
        jmp    $11CF
        sta    $E4
        stx    $E5
        sty    $E6
        ldx    $E6
        ldy    #$01
        lda    $01
        bmi    $0543
        iny
        asl    $00,x
        rol    $01,x
        bmi    $0543
        cpy    #$11
        bne    $0538
        sty    $E7
        ldy    $E4
        ldx    #$00
        stx    $00,y
        stx    $01,y
        ldy    $E6
        ldx    $E5
        sec
        lda    $00,x
        sbc    $0000,y
        sta    $EC
        lda    $01,x
        sbc    $0001,y
        bcc    $0566
        sta    $01,x
        lda    $EC
        sta    $00,x
        ldx    $E4
        rol    $00,x
        rol    $01,x
        dec    $E7
        beq    $0583
        ldx    $E6
        lsr    $01,x
        lda    $00,x
        bcc    $057D
        lsr    a
        ora    #$80
        bne    $057E
        lsr    a
        sta    $00,x
        sec
        bcs    $054F
        lda    $E4
        ldx    $E5
        rts
        sty    $3F
        jsr    $0474
        ldy    $3F
        rts
        lda    ($24),y
        tax
        lda    $00,x
        sta    $26
        lda    $01,x
        sta    $27
        lda    #$05
        sta    $46
        ldx    #$26
        ldy    #$3C
        lda    #$28
        jsr    $052A
        sta    $47
        lda    $00,x
        pha
        txa
        ldx    $47
        dec    $46
        bne    $05A5
        ldx    #$80
        pla
        beq    $05BE
        tax
        ora    #$30
        bne    $05C5
        ora    #$30
        inx
        bpl    $05C5
        lda    #$20
        jsr    $0343
        inc    $46
        lda    $46
        cmp    #$05
        bne    $05B6
        jmp    $11CF
        ora    #$36
        .byte  $02
        bit    $0304
        rol    $14,x
        .byte  $04
        .byte  $DC
        asl    $00
        brk
        stx    $D474
        .byte  $32
        ora    $A5,x
        bmi    $05B8
        .byte  $0C
        lda    $6F
        ldy    #$05
        sta    ($0C),y
        lda    #$FF
        ldy    #$03
        sta    ($0C),y
        jmp    $0BAB
        .byte  $03
        lsr    $1356,x
        brk
        .byte  $04
        .byte  $97
        asl    a
        brk
        stx    $61,y
        .byte  $14
        .byte  $1C
        .byte  $02
        eor    ($59,x)
        .byte  $02
        eor    #$69
        .byte  $02
        bvc    $0667
        .byte  $02
        .byte  'D'
        eor    $5202,y
        eor    $4502,y
        eor    $3704,y
        .byte  $13
        .byte  'D'
        jsr    $5245
        .byte  'R'
        ora    $2E07
        brk
        ora    $DC
        .byte  $1F
        .byte  $03
        brk
        .byte  $04
        .byte  $14
        brk
        .byte  $13
        brk
        ora    ($20,x)
        .byte  $FC
        .byte  $03
        bit    $0308
        brk
        asl    $01
        .byte  $80
        ora    ($01),y
        sta    ($16,x)
        ora    ($0D,x)
        .byte  $1C
        .byte  $03
        brk
        asl    $03
        beq    $064D
        .byte  $13
        brk
        .byte  $12
        .byte  $02
        .byte  $13
        brk
        .byte  $13
        php
        ora    ($80,x)
        .byte  $FA
        ora    ($13),y
        brk
        .byte  $13
        php
        ora    ($81,x)
        .byte  $FA
        .byte  $12
        ora    ($12,x)
        .byte  $03
        bit    $0D
        ora    $A2
        .byte  $04
        lsr    $11,x
        .byte  $04
        bcc    $066C
        .byte  $04
        bvc    $0670
        .byte  $04
        bne    $0673
        .byte  $04
        and    $1508
        jmp    ($FFFC)
        .byte  $07
        ora    $4907
        lsr    $5A49
        .byte  $3F
        brk
        .byte  $1F
        .byte  $1F
        brk
        .byte  $03
        asl    $10,x
        .byte  $03
        bit    $0112
        eor    $0503,y
        .byte  $04
        .byte  $03
        asl    $1A,x
        .byte  $04
        jsr    $1006
        rol    $61,x
        .byte  $0C
        asl    a
        asl    $0E74
        ora    #$36
        .byte  $02
        bit    $0915
        rol    $03,x
        .byte  $14
        .byte  $02
        .byte  $8F
        ora    #$14
        .byte  $03
        rol    $05,x
        sta    $0508
        sed
        ora    #$14
        .byte  $02
        rol    $04,x
        .byte  $03
        bit    $0A12
        bpl    $06C5
        .byte  $1C
        asl    a
        bpl    $06CD
        asl    $1A0B,x
        asl    $0A20,x
        .byte  $1C
        jsr    $0922
        .byte  $22
        ora    ($18,x)
        .byte  $22
        stx    $1E20
        .byte  $1C
        .byte  $0B
        asl    $1C74
        asl    a
        bpl    $0748
        asl    $1C8E,x
        brk
        asl    $D304,x
        ora    $8E
        .byte  't'
        .byte  $3A
        bpl    $06E4
        asl    $0312
        .byte  $22
        .byte  $1A
        sta    $0501
        .byte  $14
        .byte  $07
        rol    a
        lsr    $55
        jmp    $0D4C
        ora    $0B
        php
        .byte  $23
        .byte  'T'
        .byte  'O'
        .byte  'O'
        jsr    $4942
        .byte  'G'
        ora    $2004
        asl    $03
        bit    $031C
        rol    $961E
        ora    $14
        eor    $05
        bvs    $071D
        .byte  $1C
        .byte  $33
        stx    $2B,y
        bpl    $0719
        .byte  $03
        .byte  $1C
        asl    $1197,x
        .byte  $03
        .byte  $1C
        asl    $0211,x
        and    $050B
        .byte  $1B
        .byte  $02
        and    $0206
        bit    $05F2
        .byte  $13
        stx    $05,y
        ora    $05EB
        inx
        bpl    $074F
        bpl    $06C9
        php
        .byte  $04
        .byte  $E2
        ora    $DF
        .byte  $02
        bit    $08DD
        .byte  $3F
        .byte  $3F
        ora    $0B05
        php
        .byte  $23
        .byte  'T'
        .byte  'O'
        .byte  'O'
        jsr    $4942
        .byte  'G'
        ora    $1F1F
        .byte  $1F
        .byte  $12
        ora    ($9A,x)
        ora    ($07,x)
        ora    $098F
        bpl    $075A
        .byte  $1A
        .byte  $1F
        ora    #$14
        .byte  $03
        .byte  $1C
        ora    $8D
        php
        ora    $F8
        ora    #$14
        asl    $1E
        ora    $9A
        .byte  $0F
        ora    $E9
        ora    $0A14,y
        bpl    $07E5
        jsr    $201B
        sta    $05F3
        cpx    $0104
        asl    $97
        .byte  $12
        ora    ($FF,x)
        .byte  $FF
        .byte  'Z'
        .byte  $13
        rti
        .byte  $02
        .byte  'D'
        .byte  $02
        bvs    $078A
        .byte  $9C
        .byte  $02
        sty    $02
        .byte  'c'
        .byte  $03
        adc    $EC03,x
        .byte  $03
        ldy    #$03
        brk
        .byte  $04
        ora    $4004,y
        .byte  $04
        .byte  '|'
        .byte  $04
        cpy    #$04
        .byte  $D4
        .byte  $03
        brk
        .byte  $03
        ldy    $B802,x
        .byte  $02
        bne    $07AA
        .byte  $DC
        .byte  $02
        cpx    $02
        rol    $06
        .byte  $CB
        .byte  $02
        adc    $09
        bcc    $07B9
        brk
        .byte  $07
        brk
        ora    $5D
        ora    #$89
        ora    #$85
        ora    #$4E
        .byte  $02
        bmi    $07CE
        beq    $07CE
        .byte  $AF
        .byte  $04
        rts
        asl    a
        .byte  $80
        .byte  $03
        sbc    $0B
        cmp    $0B
        and    $0E
        txs
        rol    $03,x
        bit    $0522
        .byte  $04
        .byte  $04
        ora    ($06,x)
        .byte  $8F
        ora    #$14
        .byte  $03
        .byte  $1C
        ora    $8D
        bmi    $07E8
        sed
        .byte  $03
        bpl    $0803
        ora    #$14
        ora    ($1E,x)
        ora    $13
        .byte  $22
        ora    $36
        .byte  $0B
        .byte  $1A
        jsr    $091E
        .byte  $22
        .byte  $02
        bit    $8E19
        asl    $1C20,x
        asl    a
        .byte  $1C
        asl    $8F1A,x
        txs
        .byte  $D4
        ora    $CD
        .byte  $FF
        php
        jmp    $4E49
        eor    $53
        .byte  $3F
        ora    $1205
        php
        lsr    $204F
        .byte  'S'
        eor    $43,x
        pha
        jsr    $494C
        lsr    $2845
        .byte  'S'
        and    #$0D
        .byte  $04
        jsr    $0A06
        bpl    $083A
        jsr    $C68D
        ora    $BB
        .byte  $03
        .byte  $3C
        rol    $8F,x
        ora    #$10
        .byte  $02
        .byte  $1A
        ora    $748E
        .byte  $3A
        bpl    $0845
        .byte  $3C
        rol    $36,x
        sta    $0503
        beq    $084A
        brk
        .byte  $8F
        ora    $0436,y
        .byte  '\'
        asl    $04
        lsr    a
        ora    ($04),y
        brk
        bpl    $0854
        bit    $037C
        clc
        asl    a
        .byte  $03
        .byte  'B'
        rti
        .byte  $03
        bit    $8F44
        .byte  $03
        bit    $03F0
        bit    $23E2
        .byte  $03
        .byte  $02
        brk
        .byte  $03
        lsr    a
        jmp    $4E03
        bvc    $0871
        lsr    $0352
        bit    $9C54
        ora    ($0D,x)
        bvc    $0879
        .byte  $3B
        .byte  $34
        ora    ($2A,x)
        cmp    ($01),y
        rol    $A1CB
        asl    $1F
        clc
        ora    #$05
        ror    $239D
        .byte  $03
        and    ($01),y
        .byte  $03
        .byte  'B'
        .byte  'T'
        ora    ($20,x)
        .byte  $03
        ora    $07
        .byte  $9C
        lda    ($1C,x)
        ora    ($2E,x)
        lda    ($01),y
        rol    a
        lda    ($01),y
        and    $0109,x
        .byte  $3B
        asl    a
        ora    ($0D,x)
        php
        ora    $10
        .byte  $04
        plp
        bpl    $08C4
        ora    ($03,x)
        bit    $054C
        .byte  'C'
        .byte  $9E
        .byte  $04
        .byte  $03
        asl    $01
        clc
        asl    $05
        .byte  $3A
        ora    ($83,x)
        .byte  $03
        ora    $F8
        .byte  $04
        ldy    $0E,x
        bit    $9C30
        ora    ($0D,x)
        .byte  'D'
        ora    ($23,x)
        .byte  $14
        ora    ($28,x)
        plp
        .byte  $03
        cli
        lsr    $01,x
        eor    ($7C,x)
        ldy    #$1E
        ora    ($2C,x)
        .byte  '['
        .byte  $03
        .byte  'Z'
        lsr    $05,x
        ror    a
        .byte  $13
        brk
        ldy    #$12
        ora    ($83,x)
        ora    $18
        .byte  $07
        ora    $0B
        .byte  $03
        .byte  '\'
        lsr    $09,x
        ror    a
        .byte  $04
        eor    ($5C,x)
        clc
        .byte  $14
        ora    $65
        .byte  $13
        brk
        ldy    #$61
        ora    ($2C,x)
        asl    $01
        and    #$21
        ora    $E5
        .byte  $13
        brk
        ora    ($58,x)
        .byte  $03
        ora    $DE
        .byte  $04
        sed
        ora    $18
        .byte  $0F
        ora    $4B
        .byte  $13
        brk
        ora    ($83,x)
        .byte  $03
        ora    $D0
        ora    #$6A
        .byte  $04
        eor    ($32,x)
        clc
        ora    $3B05
        .byte  $13
        brk
        ora    ($2C,x)
        asl    $03
        .byte  'b'
        lsr    $05,x
        .byte  $1F
        .byte  $13
        brk
        .byte  $03
        rts
        lsr    $01,x
        eor    $05DF,y
        .byte  $B3
        .byte  $13
        brk
        .byte  $03
        .byte  'd'
        lsr    $01,x
        cli
        .byte  $0B
        .byte  $03
        ror    $56
        ora    ($59,x)
        ora    $18
        php
        ora    $15
        .byte  $13
        brk
        ora    ($83,x)
        .byte  $03
        ora    $9A
        .byte  $04
        and    $130D,x
        brk
        ora    ($83,x)
        sbc    $0014,y
        .byte  $04
        cmp    $08,x
        .byte  $04
        tax
        bpl    $0972
        brk
        .byte  $13
        brk
        ora    ($20,x)
        .byte  $FC
        ora    ($A6),y
        .byte  $E2
        cpx    #$04
        beq    $0982
        lda    ($24),y
        asl    a
        ldy    $40
        dey
        bne    $0975
        bcc    $0982
        lsr    a
        .byte  $9D,$F6,$00 ; sta $00F6,x
        inx
        lda    $00
        .byte  $9D,$F6,$00 ; sta $00F6,x
        inx
        stx    $E2
        jmp    $11CF
        ora    $88,x
        beq    $098A
        ora    $4C,x
        sbc    $6E0B
        ora    $6F
        bne    $09B9
        lda    #$40
        sta    $E4
        asl    a
        tax
        ldy    $0F01,x
        cpy    $6D
        bcc    $09AE
        bne    $09AA
        ldy    $0F00,x
        cpy    $6C
        bcc    $09AE
        beq    $0A20
        sbc    $E4
        bcs    $09B0
        adc    $E4
        lsr    $E4
        ldy    $E4
        cpy    #$02
        bpl    $0997
        nop
        jsr    $11DC
        .byte  $0B
        clc
        .byte  $F2
        .byte  $0C
        ora    $A5,x
        .byte  $0C
        sec
        sbc    $0A
        lda    $0D
        sbc    $0B
        bcc    $0A41
        lda    $6D
        cmp    ($0C),y
        bne    $09F3
        lda    $6C
        cmp    ($0C,x)
        bne    $09F3
        ldy    #$03
        lda    ($0C),y
        cmp    #$FE
        bcc    $09E8
        sta    $32
        ldy    #$05
        lda    ($0C),y
        ldy    #$03
        cmp    $6F
        bne    $09F3
        dey
        lda    $6E
        cmp    ($0C),y
        beq    $0A02
        jsr    $11DC
        .byte  $0B
        .byte  $0C
        .byte  $F4
        .byte  $0C
        ora    $86,x
        .byte  $32
        bne    $09C1
        jmp    $0BAB
        lda    $32
        bne    $0A47
        lda    $30
        beq    $0A44
        jsr    $11DC
        asl    a
        .byte  $0C
        nop
        .byte  $0C
        .byte  $04
        .byte  $3C
        ora    ($8E),y
        .byte  't'
        .byte  $0C
        sei
        ora    #$44
        .byte  $02
        ror    $1803,x
        .byte  $0C
        ora    ($BD),y
        .byte  $03
        .byte  $0F
        cmp    #$FF
        bne    $0A2C
        jsr    $11DC
        .byte  $12
        ora    ($A8,x)
        lda    $0DD5,y
        sta    $1E
        lda    $0DE3,y
        sta    $1F
        lda    $0F02,x
        sta    $20
        jsr    $11DC
        .byte  $12
        .byte  $03
        jmp    $0C0C
        jmp    $0C00
        ldy    #$04
        ldx    $30
        beq    $0A50
        jmp    $1200
        eor    #$FE
        bne    $09FF
        sta    $7F
        lda    ($0C),y
        sta    $7E
        lda    $ED
        jmp    $0AE9
        brk
        stx    $E4
        iny
        ldx    #$FF
        lda    ($10),y
        bpl    $0A6C
        tax
        lda    $28
        sty    $E5
        ldy    $E4
        sta    ($02),y
        iny
        inx
        bmi    $0A70
        sta    $28
        sty    $E4
        ldy    $E5
        iny
        cmp    #$0D
        bne    $0A63
        jmp    $11CF
        stx    $E5
        tax
        lda    $00,x
        sta    $E8
        lda    $01,x
        lsr    a
        sta    $E9
        lda    #$10
        sta    $E6
        clc
        bcc    $0AC4
        ora    ($29,x)
        .byte  $04
        .byte  $04
        inc    $08
        .byte  $04
        bpl    $0AA9
        lda    $EC
        bcc    $0AB1
        clc
        lda    $E7
        adc    $0000,y
        sta    $E7
        lda    $EC
        adc    $0001,y
        jsr    $0AE0
        sta    $EC
        lda    $E7
        jsr    $0AE0
        sta    $E7
        lda    $E9
        jsr    $0AE0
        sta    $E9
        lda    $E8
        jsr    $0AE0
        sta    $E8
        dec    $E6
        bpl    $0AA0
        ldx    $E5
        sta    $00,x
        lda    $E9
        sta    $01,x
        lda    $E7
        clc
        ora    $EC
        beq    $0ADF
        sec
        rts
        bcc    $0AE7
        lsr    a
        ora    #$80
        bne    $0AE8
        lsr    a
        rts
        ora    #$40
        sta    $ED
        jmp    ($07A2)
        ora    $8A,x
        ldx    #$04
        sta    $6B,x
        dex
        bne    $0AF4
        sta    $26
        sta    $27
        sta    $29
        sty    $47
        iny
        sty    $46
        bne    $0B08
        ldx    #$04
        ldy    #$00
        lda    ($00),y
        cmp    $0B80,x
        bmi    $0B14
        jmp    $0B93
        dex
        bpl    $0B0C
        lda    $27
        beq    $0B7B
        bne    $0B6B
        ldy    $27
        cpy    #$06
        bpl    $0B61
        sec
        sbc    $28
        sta    $28
        ldx    #$6C
        ldy    $47
        bne    $0B30
        ldx    #$6E
        ldy    $46
        bne    $0B48
        clc
        nop
        adc    $00,x
        sta    $00,x
        lda    #$00
        adc    $01,x
        sta    $01,x
        dec    $47
        lda    #$02
        sta    $46
        bne    $0B61
        lda    $00,x
        sta    $E7
        lda    $01,x
        sta    $EC
        lda    $0B8E,y
        sta    $E8
        jmp    $0BA3
        lda    #$E8
        ldy    #$28
        jsr    $0A84
        dec    $46
        inc    $00
        bne    $0B67
        inc    $01
        inc    $27
        bne    $0B06
        cmp    #$07
        bpl    $0B74
        jsr    $11DC
        .byte  $12
        ora    ($20,x)
        .byte  $DC
        ora    ($18),y
        asl    a
        .byte  $12
        ora    ($20,x)
        .byte  $DC
        ora    ($11),y
        .byte  $FF
        eor    ($30,x)
        jsr    $242E
        .byte  '['
        .byte  $3B
        jsr    $252F
        rti
        ora    $20,x
        php
        sbc    $4028,x
        brk
        asl    $DD
        sta    $0B
        bmi    $0B9B
        jmp    $0B14
        ldy    $0B8A,x
        sty    $28
        jmp    $0B1D
        lda    $0B90,y
        sta    $E9
        jmp    $0B58
        jsr    $11DC
        .byte  $12
        .byte  $04
        lda    $00,x
        sty    $3F
        pha
        lsr    a
        lsr    a
        lsr    a
        lsr    a
        jsr    $1329
        pla
        and    #$0F
        jsr    $1329
        jmp    $02FC
        lda    ($24),y
        tay
        stx    $01,y
        ldx    $E2
        beq    $0BE0
        dex
        .byte $BD,$F6,$00 ; lda $00F6,x
        sta    $06
        dex
        .byte $BD,$F6,$00 ; lda $00F6,x
        sta    $0000,y
        stx    $E2
        jmp    $11CF
        ldy    #$02
        jmp    $0284
        lda    ($24),y
        tax
        jsr    $0BB0
        bvc    $0BDD
        sty    $30
        stx    $32
        lda    $6E
        jmp    $098E
        bvc    $0BFE
        nop
        jsr    $1333
        ldy    $3F
        pla
        rts
        jsr    $11DC
        asl    a
        .byte  $0C
        nop
        .byte  $0C
        stx    $0C74
        sei
        ora    ($A5),y
        .byte  '|'
        beq    $0C13
        jmp    $0BAB
        jsr    $11DC
        ora    #$0C
        .byte  $03
        .byte  $1A
        php
        clc
        sta    $4203,y
        .byte  '|'
        .byte  $12
        .byte  $04
        .byte  $03
        .byte  $0C
        asl    a
        stx    $7AEA
        .byte  $0C
        asl    a
        .byte  $0C
        nop
        .byte  $32
        .byte  $04
        cpx    #$05
        .byte  $03
        bit    $03EC
        bit    $0336
        bit    $016A
        .byte  $83
        adc    $20A1,y
        asl    a
        .byte  $3C
        .byte  $F4
        .byte  $34
        ora    ($24,x)
        jsr    $4A0A
        .byte  $F2
        .byte  $34
        ora    ($40,x)
        ora    $7403,y
        .byte  $34
        ora    ($25,x)
        .byte  $13
        ora    ($27,x)
        adc    #$04
        sbc    ($0E),y
        .byte  $03
        .byte  $3C
        .byte  $34
        ora    $0A
        .byte  $9E
        sei
        .byte  'w'
        ror    $75,x
        ora    $79
        .byte  $13
        brk
        .byte  $03
        bit    $037E
        bit    $156C
        ldy    #$00
        jmp    $0ECC
        bmi    $0CA2
        cmp    $34
        bpl    $0C95
        inc    $6C
        sta    $E7
        lda    #$00
        sta    $EC
        ldx    #$7E
        ldy    #$7E
        lda    #$34
        jsr    $0A84
        bcc    $0C8D
        inc    $6D
        inc    $00
        bne    $0C93
        inc    $01
        bne    $0C6D
        cpx    #$10
        bne    $0CA2
        sec
        sbc    #$07
        bmi    $0CA2
        cmp    #$10
        bmi    $0C78
        lda    $6C
        beq    $0CB1
        lda    $6D
        beq    $0CB8
        jsr    $11DC
        clc
        .byte  $03
        ora    $2C
        jsr    $11DC
        clc
        .byte  $07
        .byte  $12
        ora    ($20,x)
        .byte  $DC
        ora    ($05),y
        jsr    $0013
        .byte  $03
        bit    $227E
        brk
        sei
        .byte  $04
        dec    $130E,x
        brk
        lda    ($01,x)
        ora    #$6E
        ora    $2C
        cpx    $03
        jmp    ($057E)
        .byte  $07
        asl    a
        .byte  'B'
        sbc    $05ED
        .byte  '\'
        .byte  $03
        .byte  $3A
        asl    $02
        .byte  $2F
        rol    $02
        rol    a
        bpl    $0CE8
        and    $0A07
        ror    a
        ror    $056A,x
        bit    $0B
        ror    a
        ror    $056A,x
        asl    $A915,x
        ror    a
        ldy    #$7E
        stx    $E7
        stx    $EC
        ldx    #$6A
        jsr    $0A84
        jsr    $11DC
        ora    $0B
        ora    $B6,x
        ror    a
        stx    $26,y
        dey
        bpl    $0D08
        bmi    $0D31
        ora    ($2B,x)
        .byte  $0C
        ora    ($2D,x)
        ora    #$01
        rol    a
        asl    $01
        .byte  $2F
        .byte  $03
        ora    $09
        .byte  $22
        brk
        .byte  $3A
        .byte  $13
        brk
        .byte  $04
        and    $090C,y
        ror    a
        .byte  $04
        eor    ($05,x)
        asl    a
        cli
        sbc    $11ED
        jmp    $03E0
        jmp    $0E06
        clc
        .byte  $12
        ora    $D7
        brk
        brk
        ora    $A0,x
        .byte  $FF
        lda    $1F
        and    $57
        bne    $0D4F
        ldy    #$07
        lda    $1E
        nop
        and    $56
        beq    $0D34
        rol    a
        iny
        bcc    $0D4F
        cpy    #$08
        bpl    $0DB1
        lda    $0DFD,y
        and    $0E05
        bne    $0D90
        tya
        bne    $0DB1
        lda    #$3F
        bit    $ED
        bne    $0DB1
        nop
        jsr    $11DC
        .byte  $0B
        ror    a
        .byte  'D'
        ror    a
        .byte  $0B
        ror    a
        .byte  't'
        ror    a
        ora    #$6A
        .byte  $04
        cli
        .byte  $14
        asl    a
        ror    a
        cli
        .byte  $1C
        ora    #$1C
        .byte  $04
        cli
        .byte  $0B
        clc
        bpl    $0D89
        tax
        bpl    $0DA7
        .byte  $1F
        .byte  $1F
        .byte  $1F
        .byte  $1F
        ora    $38,x
        bcs    $0DB0
        lda    $ED
        asl    a
        bne    $0DA6
        bcc    $0DB1
        iny
        lda    $0DFD,y
        and    $1F
        bne    $0DB1
        jsr    $11DC
        clc
        .byte  $03
        ora    $DF
        iny
        lda    $0DFD,y
        sty    $1E
        and    $1F
        bne    $0DCE
        dey
        lda    $20
        lsr    a
        lda    $0E0D,y
        bcs    $0DBC
        lda    $0E19,y
        clc
        adc    $20
        sta    $50
        lda    $0DF1,y
        sta    $4C
        jsr    $11DC
        .byte  $03
        ror    a
        eor    ($05),y
        .byte  $B7
        jsr    $11DC
        .byte  $04
        dec    $0E,x
        .byte  $FF
        rts
        rts
        brk
        .byte  $80
        brk
        brk
        brk
        brk
        brk
        brk
        bpl    $0DE1
        brk
        brk
        adc    $3C3D,x
        .byte  $3C
        .byte  's'
        .byte  $32
        .byte  '|'
        sec
        bvs    $0E1D
        bpl    $0DFF
        brk
        .byte  $80
        .byte  $02
        .byte  $02
        .byte  $02
        .byte  $03
        .byte  $02
        .byte  $03
        .byte  $02
        .byte  $03
        ora    ($02,x)
        .byte  $02
        .byte  $03
        .byte  $80
        rti
        jsr    $0810
        .byte  $04
        .byte  $02
        ora    ($2A,x)
        jsr    $11DC
        clc
        ora    $05
        cpy    #$00
        php
        .byte  $04
        .byte  $0C
        .byte  $14
        .byte  $1C
        brk
        clc
        brk
        bpl    $0E18
        brk
        brk
        brk
        .byte  $04
        .byte  $0C
        .byte  $14
        .byte  $1C
        .byte  $14
        .byte  $1C
        php
        brk
        brk
        bit    $1F1F
        .byte  $04
        .byte  $B3
        bpl    $0E34
        rti
        .byte  $02
        .byte  'B'
        asl    $09
        pha
        .byte  $02
        bit    $0906
        bit    $E202
        eor    $1419
        ora    #$40
        .byte  $02
        .byte  'B'
        .byte  $2B
        bit    $20
        brk
        and    $45
        and    $44
        bit    $20
        brk
        ora    #$4C
        .byte  $02
        bit    $2559
        bvc    $0E5B
        jmp    $4202
        .byte  $0C
        and    $51
        ora    #$4C
        .byte  $02
        .byte  't'
        ora    #$25
        .byte  'R'
        ora    $0A
        bit    $20
        jsr    $2400
        jsr    $0020
        .byte  $1F
        ora    #$42
        .byte  $02
        beq    $0EC6
        bit    $20
        brk
        .byte  $1B
        .byte  $02
        .byte  $03
        .byte  'B'
        beq    $0E9E
        jsr    $0A0C
        asl    $F4
        asl    $09
        rti
        .byte  $02
        .byte  'B'
        .byte  $1C
        ora    $16
        asl    a
        .byte  'D'
        jmp    $1144
        .byte  $13
        rti
        ora    #$40
        ora    ($74,x)
        .byte  $04
        .byte  $04
        eor    $0408,y
        jsr    $FF06
        cpy    #$10
        asl    a
        asl    $76
        asl    $06
        eor    $23
        brk
        ora    $0520,y
        jsr    $24FF
        jsr    $0020
        ora    $B5
        ora    #$48
        .byte  $02
        .byte  't'
        .byte  $32
        ora    $D7
        ora    #$1E
        .byte  $02
        bit    $0404
        cmp    $08
        .byte  $03
        .byte  'B'
        jmp    $2003
        bvc    $0EC7
        .byte  'Z'
        ora    #$24
        ora    $AF05
        .byte  $FF
        .byte  $FF
        .byte  $FF
        lda    ($00),y
        sec
        ldx    $34
        sbc    #$30
        jmp    $0C72
        clc
        .byte  $13
        ora    $A4,x
        asl    $B14C,x
        .byte  $0D,$13,$00
        .byte  $04
        .byte  $DC
        .byte  $0C
        .byte  $03
        .byte  'B'
        rol    $05A7,x
        ldx    #$00
        brk
        brk
        .byte  $13
        brk
        .byte  $04
        .byte  $DC
        .byte  $0C
        ora    ($2A,x)
        asl    a
        ora    ($22,x)
        .byte  $04
        .byte  $04
        cli
        .byte  $0C
        .byte  $04
        iny
        .byte  $0C
        .byte  $03
        .byte  'D'
        ror    $EC04,x
        asl    $40FF
        asl    $00
        .byte  $FF
        .byte  $E3
        asl    $61
        brk
        .byte  't'
        php
        and    ($00,x)
        .byte  'D'
        ora    #$02
        .byte  $03
        .byte  $FB
        .byte  $0C
        bcc    $0F25
        .byte  $0B
        ora    $0DB0
        eor    $F00D,y
        ora    $0DFC
        jsr    $9109
        asl    $0D30
        lda    $0E,x
        bne    $0F39
        .byte  $0C
        .byte  $0F
        bpl    $0F3D
        .byte  '['
        .byte  $0F
        brk
        .byte  $0C
        .byte  $F3
        .byte  $0F
        bvc    $0F45
        .byte  $03
        bpl    $0FAB
        ora    $14A3
        clc
        .byte  $0C
        ldy    $14
        cld
        .byte  $0C
        lda    #$14
        cli
        .byte  $0C
        ldx    $14,y
        clv
        .byte  $0C
        cld
        .byte  $14
        cmp    ($00,x)
        cli
        ora    $E0,x
        php
        eor    $C015,y
        php
        .byte  $CB
        ora    $02C2,y
        cpx    #$19
        dex
        .byte  $0C
        sbc    ($19,x)
        dey
        .byte  $0C
        tax
        and    ($41,x)
        brk
        .byte  's'
        .byte  $3A
        .byte  $E2
        .byte  $02
        dey
        .byte  $3A
        inx
        .byte  $0C
        .byte  $89
        .byte  $3A
        iny
        .byte  $0C
        tya
        rti
        rti
        asl    a
        txa
        eor    ($14,x)
        .byte  $0B
        lda    ($4B,x)
        lda    ($00,x)
        clv
        .byte  'K'
        ldx    #$04
        lda    $A04B,y
        asl    $0A
        lsr    $0342
        inx
        eor    $0CEA,y
        sta    ($60),y
        ora    ($00,x)
        brk
        .byte  'd'
        brk
        .byte  $FF
        eor    ($65,x)
        pha
        .byte  $0C
        bvc    $1003
        php
        .byte  $0C
        sbc    ($65,x)
        pla
        .byte  $0C
        beq    $100B
        plp
        .byte  $0C
        cpx    $72
        .byte  $22
        .byte  $03
        nop
        .byte  'r'
        .byte  'b'
        .byte  $03
        lda    #$73
        rti
        .byte  $0C
        .byte  $B3
        .byte  's'
        rts
        .byte  $0C
        cpy    #$76
        brk
        .byte  $FF
        .byte  $13
        .byte  'w'
        sbc    ($00,x)
        .byte  $8B
        .byte  'w'
        sec
        .byte  $0C
        sty    $F877
        .byte  $0C
        sta    ($77),y
        sei
        .byte  $0C
        sbc    ($79,x)
        sta    ($01,x)
        sed
        adc    $0582,y
        sbc    $8079,y
        .byte  $07
        rti
        adc    $0CAA,x
        eor    ($7D,x)
        tay
        .byte  $0C
        bpl    $0F62
        tsx
        .byte  $0C
        cmp    ($80,x)
        txa
        .byte  $0C
        .byte  $D3
        .byte  $80
        txs
        .byte  $0C
        sbc    #$80
        tya
        .byte  $0C
        brk
        stx    $00,y
        .byte  $FF
        rti
        .byte  $9C
        brk
        .byte  $FF
        .byte  $FF
        .byte  $FF
        .byte  $FF
        .byte  $FF
        .byte  $FF
        .byte  $FF
        .byte  $FF
        .byte  $FF
        .byte  $03
        bit    $134C
        brk
        .byte  $9C
        ora    ($3D,x)
        .byte  $04
        .byte  $04
        .byte  $B7
        php
        .byte  $13
        brk
        .byte  $9C
        ldy    #$13
        ora    ($83,x)
        .byte  $04
        .byte  $04
        inc    $08
        ora    $A9,x
        .byte  $3F
        bit    $ED
        beq    $1025
        jsr    $11DC
        clc
        sty    $05
        .byte  's'
        jmp    $1130
        .byte  $03
        bit    $134C
        brk
        .byte  $9C
        ldy    #$68
        ora    ($83,x)
        .byte  $04
        .byte  $04
        inc    $08
        .byte  $03
        .byte  $02
        brk
        .byte  $9C
        lda    ($02,x)
        .byte  $1F
        sta    $0D0E,x
        .byte  $0C
        .byte  $0B
        .byte  $03
        ror    a
        ror    $748E,x
        sei
        .byte  $0C
        rol    $1E
        ora    ($05,x)
        lsr    a
        ora    $A2,x
        .byte  $03
        lda    $6D
        cmp    $D6,x
        bne    $105D
        lda    $6C
        cmp    $DA,x
        beq    $1062
        dex
        bpl    $1051
        bmi    $10A4
        lda    $DE,x
        sta    $4C
        stx    $1E
        lda    #$00
        sta    $1F
        jsr    $11DC
        .byte  $9C
        ora    #$1E
        ora    $2C
        .byte  $04
        .byte  $A7
        ora    $39
        .byte  $04
        bmi    $108D
        ora    $A5,x
        asl    $03C9,x
        bne    $108A
        lda    $50
        ldy    $51
        sta    $51
        sty    $50
        jsr    $11DC
        .byte  $A7
        ora    ($2C,x)
        asl    a
        ora    ($83,x)
        clc
        clc
        .byte  $07
        .byte  $1F
        .byte  $04
        tax
        bpl    $10AE
        brk
        ora    $DB
        .byte  $03
        bit    $044C
        bcs    $10B4
        jsr    $11DC
        .byte  $03
        bit    $A74C
        sta    $0404
        eor    $0408,x
        lda    $090E
        rti
        ora    $74
        asl    $09
        pha
        .byte  $03
        .byte  't'
        .byte  $04
        .byte  $04
        rol    a
        asl    $4809
        .byte  $02
        .byte  't'
        .byte  $0C
        asl    a
        .byte  'D'
        bvs    $10E5
        stx    $724C
        .byte  $1C
        .byte  $04
        sta    $0E
        ora    $88,x
        lsr    $3E
        lda    $4C
        sta    $E4
        bcs    $10ED
        dec    $E4
        bmi    $1119
        ldx    $D1
        lda    $0050,y
        sta    $B8,x
        iny
        inx
        stx    $D1
        cpx    #$18
        bne    $10DA
        ldx    $D1
        bne    $10F4
        jmp    $126A
        lda    #$3B
        jsr    $0343
        txa
        jsr    $127D
        ldx    #$02
        lda    $67,x
        jsr    $127D
        dex
        bne    $10FF
        lda    $B8,x
        jsr    $127D
        inx
        dec    $D1
        bne    $1107
        ldx    #$D3
        jsr    $0BB0
        jmp    $1259
        jsr    $11DC
        .byte  $04
        sta    $0E
        brk
        .byte  $03
        bit    $9648
        asl    $02
        .byte  $07
        .byte  $04
        .byte  $14
        asl    $10
        pha
        .byte  $FB
        .byte  $04
        bvc    $1138
        jsr    $11DC
        .byte  $03
        .byte  'B'
        rol    $6A03,x
        .byte  'D'
        .byte  $04
        tax
        bpl    $10D3
        .byte  $03
        .byte  $02
        ora    ($97,x)
        .byte  $02
        and    $0404,x
        .byte  $14
        asl    a
        .byte  $04
        .byte  $1F
        asl    a
        .byte  $13
        brk
        lda    ($06,x)
        clc
        .byte  $1A
        .byte  $04
        .byte  $A7
        bpl    $1158
        lsr    $0710
        ora    $031F
        .byte  'B'
        rol    $2004,x
        ora    ($00),y
        ldx    #$00
        txa
        sta    $00,x
        inx
        bne    $1163
        ldy    $1290,x
        lda    $12C8,x
        sta    $0000,y
        inx
        cpx    #$38
        bne    $1168
        nop
        nop
        nop
        ldy    #$00
        jmp    $032C
        cmp    #$4F
        bcc    $1187
        ldx    $24
        ldy    $25
        brk
        clc
        adc    #$80
        sta    $E4
        lda    #$00
        adc    #$07
        sta    $E5
        lda    ($24),y
        and    #$7F
        lsr    a
        tax
        lda    $11EA,x
        bcs    $11A1
        lsr    a
        lsr    a
        lsr    a
        lsr    a
        and    #$0F
        sta    $2A
        lda    ($24),y
        bmi    $11B7
        lda    ($E4),y
        sta    $E6
        iny
        lda    ($E4),y
        sta    $E7
        ldx    #$00
        jmp    ($00E6)
        lda    $2A
        pha
        lda    $25
        pha
        sta    $FB
        lda    $24
        sta    $FA
        pha
        lda    ($E4),y
        sta    $24
        iny
        lda    ($E4),y
        sta    $25
        bne    $1179
        lda    $2A
        clc
        adc    $24
        sta    $24
        lda    $25
        adc    #$00
        bne    $11CB
        pla
        sta    $24
        pla
        sta    $25
        inc    $24
        bne    $11E8
        inc    $25
        bne    $1179
        .byte  $13
        .byte  $33
        .byte  $32
        .byte  $3F
        sbc    $44,x
        .byte  $12
        eor    ($31,x)
        .byte  $22
        and    ($41,x)
        .byte  $22
        .byte  $22
        ora    $51,x
        .byte  $22
        and    ($F2),y
        and    ($00),y
        brk
        eor    #$FE
        bne    $1210
        sta    $7F
        lda    ($0C),y
        sta    $7E
        jsr    $11DC
        .byte  $04
        clc
        asl    a
        lda    $45
        beq    $1224
        iny
        sta    ($0C),y
        dey
        lda    $44
        sta    ($0C),y
        dey
        lda    $6F
        sta    ($0C),y
        jmp    $0B7B
        lda    $44
        sta    ($0C),y
        dey
        lda    #$FE
        sta    ($0C),y
        jmp    $0B7B
        ora    ($27,x)
        ora    #$A0
        ora    $6A03
        bvc    $123D
        .byte  '{'
        bpl    $1245
        asl    $4202,x
        ora    $1F
        .byte  $04
        inc    $08
        .byte  $13
        brk
        .byte  $22
        brk
        .byte  'r'
        .byte  $A7
        .byte  $13
        brk
        ora    ($27,x)
        .byte  $03
        ora    $F6
        .byte  $13
        brk
        ora    ($27,x)
        sbc    ($04),y
        stx    $CA10
        jsr    $0BB0
        jsr    $033C
        ldx    #$06
        lda    #$00
        jsr    $0343
        dex
        bne    $1262
        stx    $D2
        stx    $D3
        clc
        tya
        adc    $44
        sta    $68
        lda    #$00
        adc    $45
        sta    $69
        jmp    $10DA
        pha
        clc
        adc    $D2
        sta    $D2
        lda    #$00
        adc    $D3
        sta    $D3
        pla
        jmp    $0BB2
        brk
        brk
        brk
        .byte  $02
        asl    $17,x
        clc
        ora    $2524,y
        rol    $382F
        .byte  $3A
        .byte  $3C
        .byte  'B'
        lsr    a
        lsr    $584F
        .byte  '['
        eor    $605E,x
        .byte  'b'
        adc    $67
        .byte  $FC
        .byte  'r'
        .byte  't'
        ror    $78,x
        .byte  'z'
        .byte  $D4
        dec    $D7,x
        cld
        cmp    $DBDA,y
        .byte  $DC
        cmp    $DFDE,x
        cpx    #$E1
        nop
        inc    $F4F2
        .byte  $FF
        brk
        .byte  $80
        asl    a
        .byte  $0B
        bvs    $1337
        .byte  $1A
        .byte  $1B
        .byte  $80
        sta    ($13),y
        .byte  $FF
        .byte  $1F
        ora    ($06,x)
        .byte  $FF
        .byte  $FF
        .byte  $14
        rol    $0A,x
        ora    ($03,x)
        nop
        nop
        .byte  $80
        bcs    $131B
        jsr    $1040
        .byte  $0C
        .byte  $03
        .byte  'B'
        bvc    $12E5
        .byte  $0C
        ror    $446C,x
        and    ($10,x)
        .byte  $92
        ora    $7C74,y
        rol    a
        adc    #$00
        ora    ($02,x)
        .byte  $02
        .byte  $04
        .byte  $37
        ora    $06
        .byte  $FF
        .byte  $80
        eor    #$00
        brk
        brk
        brk
        sta    ($13),y
start:  jmp    $1160
        lda    $1336
        beq    $1311
        dec    $1336
        beq    $1311
        lda    #$20
        bpl    $1333
        jsr    $FFEB
        cmp    #$09
        beq    $1322
        cmp    #$0D
        beq    $1333
        cmp    #$20
        bpl    $1333
        bmi    $1311
        lda    #$09
        sta    $1336
        bpl    $1308
        and    #$0F
        ora    #$30
        cmp    #$3A
        bcc    $1333
        adc    #$06
        jmp    $FFEE
        brk
        .byte  $02
        jmp    $0210
        .byte  'S'
        .byte  $14
        php
        .byte  'C'
        eor    $2044
        eor    $52
        .byte  'R'
        ora    $2004
        asl    $15
        jsr    $FFF4
        jmp    $1354
        ora    $20,x
        .byte  $F7
        .byte  $FF
        jsr    $11DC
        .byte  $04
        jsr    $A006
        ora    ($88,x)
        bmi    $135A
        bpl    $1363
        sta    $FF
        jsr    $0588
        sta    ($02),y
        cmp    #$0D
        beq    $1387
        cmp    #$5F
        beq    $135C
        cmp    #$5E
        beq    $135A
        cmp    #$09
        beq    $1380
        cmp    #$7F
        beq    $1361
        cmp    #$20
        bmi    $1361
        iny
        cpy    #$38
        bne    $1363
        beq    $135C
        lda    #$0A
        dey
        lda    $02
        sta    $00
        jmp    $11CF
