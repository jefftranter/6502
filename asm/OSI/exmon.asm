; Ohio Scientific Extended Monitor
;
; Disassembled from cassette version of Ohio Scientific Extended
; Monitor. The original has a small loader at the front which is not
; included.
;
; For details and usage see the manual "Assembler Editor and Extended
; Monitor Reference Manual (C1P, C4P and C8)".
;
; Occupies memory from $0800-$0FFF

        .org   $0800

start:  ldx    #$1F
        lda    #$FF
        sta    $E0,x
        dex
        bpl    $0804
        cld
        sei
        lda    #$4C
        sta    $01C0
        lda    $0996
        sta    $01C1
        lda    $0997
        sta    $01C2
        ldx    $E4
        txs

noinit: lda    $0999  ; Entry point without initialization
        pha
        lda    $0998
        pha
        jsr    $0B07
        lda    #$3A
        jsr    $0861
        jsr    $0853
        cmp    #$40
        bcc    $084C
        cmp    #$5B
        bcs    $084C
        asl    a
        and    #$7F
        tax
        inx
        lda    $0960,x
        pha
        dex
        lda    $0960,x
        pha
        ldy    #$00
        php
        rti
        jmp    $0AFF
        and    #$7F
        bpl    $0861
        ldy    #$00
        jsr    $FFEB
        cmp    #$20
        bpl    $0861
        cmp    #$0D
        beq    $0861
        rts
        jmp    $FFEE
        ora    #$08
        rti
        .byte  $02
        eor    $03
        bne    $0874
        rti
        ora    #$30
        .byte  $22
        eor    $33
        bne    $087C
        rti
        ora    #$40
        .byte  $02
        eor    $33
        bne    $0884
        rti
        ora    #$40
        .byte  $02
        eor    $B3
        bne    $088C
        rti
        ora    #$00
        .byte  $22
        .byte  'D'
        .byte  $33
        bne    $0818
        .byte  'D'
        brk
        ora    ($22),y
        .byte  'D'
        .byte  $33
        bne    $0820
        .byte  'D'
        txs
        bpl    $08BA
        .byte  'D'
        .byte  $33
        bne    $08A4
        rti
        ora    #$10
        .byte  $22
        .byte  'D'
        .byte  $33
        bne    $08AC
        rti
        ora    #$62
        .byte  $13
        sei
        lda    #$00
        and    ($81,x)
        .byte  $82
        brk
        brk
        eor    $914D,y
        .byte  $92
        stx    $4A
        sta    $9D
        ldy    $ACA9
        .byte  $A3
        tay
        ldy    $D9
        brk
        cld
        ldy    $A4
        brk
        .byte  $1C
        txa
        .byte  $1C
        .byte  $23
        eor    $1B8B,x
        lda    ($9D,x)
        txa
        ora    $9D23,x
        .byte  $8B
        .byte  $1D,$A1,$00
        and    #$19
        ldx    $A869
        ora    $2423,y
        .byte  'S'
        .byte  $1B
        .byte  $23
        bit    $53
        .byte  $19,$A1,$00
        .byte  $1A
        .byte  '['
        .byte  '['
        lda    $69
        bit    $24
        ldx    $A8AE
        .byte  $AD,$29,$00
        .byte  '|'
        brk
        ora    $9C,x
        adc    $A59C
        adc    #$29
        .byte  'S'
        sty    $13
        .byte  $34
        ora    ($A5),y
        adc    #$23
        ldy    #$D8
        .byte  'b'
        .byte  'Z'
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
        sty    $00,x
        ldy    $08,x
        sty    $74
        ldy    $28,x
        ror    $F474
        cpy    $724A
        .byte  $F2
        ldy    $8A
        brk
        tax
        ldx    #$A2
        .byte  't'
        .byte  't'
        .byte  't'
        .byte  'r'
        .byte  'D'
        pla
        .byte  $B2
        .byte  $32
        .byte  $B2
        brk
        .byte  $22
        brk
        .byte  $1B
        .byte  $1B
        .byte  $27
        .byte  $27
        .byte  'r'
        .byte  'r'
        dey
        iny
        cpy    $CA
        rol    $48
        .byte  'D'
        .byte  'D'
        ldx    #$C8
        rol    $7B1A
        .byte  $80
        asl    $40,x
        and    $2080
        jmp    ($C04C)
        brk
        php
        .byte  $9B
        .byte  'D'
        .byte  'd'
        .byte  $80
        asl    $40,x
        bpl    $09C4
        .byte  'o'
        rol    $9C7E
        pha
        lsr    $53,x
        .byte  $0B
        .byte  $B3
        .byte  $0B
        txs
        .byte  $0C
        .byte  $BF
        .byte  $0C
        .byte  $D2
        .byte  $0C
        .byte  'W'
        .byte  $0C
        .byte  $A3
        ora    $0BC1
        .byte  $33
        asl    $0C12
        jmp    $AF08   ; Unused command 'J'. Can add address of routine here
        .byte  $0B
        .byte  'C'
        .byte  $0F
        sta    ($0D),y
        and    $0D,x
        and    #$0E
        bcs    $098D
        .byte  $14
        ora    $0DB7
        .byte  $C3
        asl    $0C6E
        jmp    $3B08   ; Unused command 'U'. Can add address of routine here
        .byte  $0F
        ror    $B20D,x
        .byte  $0B
        lda    ($0B),y
        .byte  $B7
        .byte  $0F
        .byte  $C7
        .byte  $0B
        asl    $E008,x
        brk
        lda    #$17
        sta    $D7
        jsr    $09B0
        jsr    $0A94
        sta    $D5
        sty    $D6
        dec    $D7
        bmi    $09E5
        bne    $09A0
        jsr    $0A7F
        lda    ($D5,x)
        tay
        lsr    a
        bcc    $09C4
        lsr    a
        bcs    $09D3
        cmp    #$22
        beq    $09D3
        and    #$07
        ora    #$80
        lsr    a
        tax
        lda    $0866,x
        bcs    $09CF
        lsr    a
        lsr    a
        lsr    a
        lsr    a
        and    #$0F
        bne    $09D7
        ldy    #$80
        lda    #$00
        tax
        lda    $08AA,x
        sta    $D1
        and    #$03
        sta    $D2
        lda    $D8
        bne    $09E6
        rts
        tya
        and    #$8F
        tax
        tya
        ldy    #$03
        cpx    #$8A
        beq    $09FC
        lsr    a
        bcc    $09FC
        lsr    a
        lsr    a
        ora    #$20
        dey
        bne    $09F5
        iny
        dey
        bne    $09F1
        pha
        lda    ($D5),y
        jsr    $0AAC
        cpy    $D2
        iny
        bcc    $0A00
        ldx    #$01
        jsr    $0A8B
        iny
        ldx    #$02
        cpy    #$04
        bcc    $0A0C
        pla
        tay
        lda    $08C4,y
        sta    $D3
        lda    $0904,y
        sta    $D4
        lda    #$00
        ldy    #$05
        asl    $D4
        rol    $D3
        rol    a
        dey
        bne    $0A26
        adc    #$BF
        jsr    $084F
        dex
        bpl    $0A22
        jsr    $0A89
        ldx    #$06
        cpx    #$03
        bne    $0A59
        ldy    $D2
        bne    $0A4B
        asl    $D3
        bcc    $0A59
        lda    #$41
        bne    $0A8D
        lda    $D1
        cmp    #$E8
        lda    ($D5),y
        bcs    $0A6F
        jsr    $0AAC
        dey
        bne    $0A4B
        asl    $D1
        bcc    $0A6B
        lda    $08B7,x
        jsr    $084F
        lda    $08BD,x
        beq    $0A6B
        jsr    $084F
        dex
        bne    $0A3B
        rts
        jsr    $0A97
        tax
        inx
        bne    $0A77
        iny
        tya
        jsr    $0AAC
        txa
        jmp    $0AAC
        jsr    $0B07
        lda    $D6
        ldx    $D5
        jsr    $0A78
        ldx    #$01
        lda    #$20
        jsr    $084F
        dex
        bne    $0A8B
        rts
        lda    $D2
        sec
        ldy    $D6
        tax
        bpl    $0A9D
        dey
        adc    $D5
        bcc    $0AA2
        iny
        rts
        jsr    $0AA6
        jsr    $0AE7
        jmp    $0AC2
        pha
        lsr    a
        lsr    a
        lsr    a
        lsr    a
        jsr    $0AB5
        pla
        and    #$0F
        ora    #$30
        cmp    #$3A
        bcc    $0ABF
        adc    #$06
        jmp    $0861
        asl    a
        asl    a
        asl    a
        asl    a
        ldy    #$04
        rol    a
        rol    $E7
        dey
        bne    $0AC8
        lda    $E7
        rts
        jsr    $0AEA
        jsr    $0AC2
        jmp    $0AA6
        jsr    $0853
        cmp    #$31
        bmi    $0AFF
        cmp    #$39
        bcs    $0AFF
        bcc    $0AFC
        jsr    $0853
        cmp    #$30
        bmi    $0AFF
        cmp    #$3A
        bcc    $0AFC
        cmp    #$47
        bcs    $0AFF
        cmp    #$41
        bcc    $0AFF
        sbc    #$07
        and    #$0F
        rts
        lda    #$3F
        jsr    $0861
        jmp    $0809
        lda    #$0D
        jsr    $0861
        lda    #$0A
        jmp    $0861
        jsr    $0AA3
        sta    $DB
        jsr    $0AA3
        sta    $DA
        rts
        jsr    $0AA3
        sta    $DD
        jsr    $0AA3
        sta    $DC
        lda    #$2C
        jsr    $0861
        jsr    $0AA3
        sta    $DF
        jsr    $0AA3
        sta    $DE
        rts
        inc    $DC
        bne    $0B3C
        inc    $DD
        sec
        lda    $DC
        sbc    $DE
        lda    $DD
        sbc    $DF
        bcs    $0B04
        rts
        jsr    $0B11
        lda    #$3D
        jsr    $0861
        jmp    $0B1C
        jsr    $0B11
        lda    #$2F
        jsr    $0861
        lda    ($DA),y
        jsr    $0AAC
        jsr    $0C51
        jsr    $0853
        cmp    #$0D
        bne    $0B6B
        rts
        cmp    #$2F
        beq    $0B5B
        cmp    #$0A
        beq    $0B8B
        cmp    #$5E
        beq    $0B94
        cmp    #$22
        bne    $0B83
        lda    ($DA),y
        jsr    $0861
        jmp    $0B60
        jsr    $0AD1
        sta    ($DA),y
        jmp    $0B60
        inc    $DA
        bne    $0B9F
        inc    $DB
        jmp    $0B9F
        sec
        lda    $DA
        sbc    #$01
        sta    $DA
        bcs    $0B9F
        dec    $DB
        jsr    $0B07
        lda    $DB
        jsr    $0AAC
        lda    $DA
        jsr    $0AAC
        jmp    $0B56
        iny
        iny
        iny
        iny
        clc
        tya
        adc    $099A
        sta    $DA
        lda    #$00
        tay
        sta    $DB
        beq    $0B56
        jsr    $0B11
        jmp    ($00DA)
        sta    $E0
        pla
        pha
        and    #$10
        bne    $0BD4
        lda    $E0
        jmp    ($0864)
        stx    $E1
        sty    $E2
        pla
        sta    $E3
        cld
        sec
        pla
        sbc    #$02
        sta    $E5
        pla
        sbc    #$00
        sta    $E6
        tsx
        stx    $E4
        ldx    #$00
        ldy    #$01
        lda    $E5
        cmp    $F0,x
        beq    $0BFE
        inx
        inx
        iny
        cpy    #$09
        bmi    $0BEE
        jmp    $0AFF
        inx
        lda    $E6
        cmp    $F0,x
        bne    $0BF5
        jsr    $0B07
        tya
        jsr    $0C5A
        tya
        ora    #$B0
        jsr    $0AAC
        lda    #$40
        jsr    $0861
        lda    $E6
        jsr    $0AAC
        lda    $E5
        jsr    $0AAC
        jsr    $0B07
        ldx    #$00
        lda    #$41
        jsr    $0C3C
        lda    #$58
        jsr    $0C3C
        lda    #$59
        jsr    $0C3C
        lda    #$50
        jsr    $0C3C
        lda    #$4B
        jsr    $0861
        lda    #$2F
        jsr    $0861
        lda    $E0,x
        jsr    $0AAC
        inx
        cpx    #$05
        bne    $0C51
        jmp    $081F
        lda    #$20
        jsr    $0861
        rts
        jsr    $0ADA
        jsr    $0C92
        ldx    $D9
        dex
        lda    $E8,x
        ldx    $D8
        sta    ($F0,x)
        lda    #$FF
        sta    $F0,x
        inx
        sta    $F0,x
        rts
        ldx    #$00
        ldy    #$01
        jsr    $0B07
        tya
        ora    #$B0
        jsr    $0AAC
        lda    #$2C
        jsr    $0861
        lda    $F1,x
        jsr    $0AAC
        lda    $F0,x
        jsr    $0AAC
        inx
        inx
        iny
        cpy    #$09
        bmi    $0C72
        rts
        sta    $D9
        asl    a
        sbc    #$01
        sta    $D8
        rts
        jsr    $0ADA
        jsr    $0C5A
        lda    #$2C
        jsr    $0861
        jsr    $0B11
        ldx    $D8
        sta    $F0,x
        inx
        lda    $DB
        sta    $F0,x
        dex
        lda    ($F0,x)
        pha
        tya
        sta    ($F0,x)
        ldx    $D9
        dex
        pla
        sta    $E8,x
        rts
        ldx    $E4
        txs
        ldx    $E1
        ldy    $E2
        lda    $E6
        pha
        lda    $E5
        pha
        lda    $E3
        pha
        lda    $E0
        rti
        jsr    $0B1C
        jsr    $0B07
        ldy    #$07
        jsr    $0C51
        dey
        bne    $0CDA
        ldx    $DC
        ldy    #$10
        txa
        jsr    $0AB5
        jsr    $0C51
        jsr    $0C51
        inx
        dey
        bne    $0CE4
        jsr    $0B07
        lda    $DD
        jsr    $0AAC
        lda    $DC
        jsr    $0AAC
        ldx    #$10
        jsr    $0C51
        jsr    $0C51
        lda    ($DC),y
        jsr    $0AAC
        jsr    $0B36
        dex
        bne    $0D04
        beq    $0CF2
        jsr    $0B11
        sta    $D5
        lda    $DB
        sta    $D6
        jsr    $0B07
        sta    $D8
        jsr    $099C
        jsr    $09A3
        jsr    $0B07
        jsr    $0853
        cmp    #$0A
        beq    $0D1D
        jmp    $0832
        ldx    #$07
        jsr    $0C51
        jsr    $0AA3
        sta    $D0,x
        jsr    $0C51
        jsr    $0853
        cmp    #$3E
        beq    $0D55
        dex
        bmi    $0D52
        jsr    $0AD1
        jmp    $0D3D
        jmp    $0AFF
        stx    $D8
        jsr    $0B1C
        ldx    #$07
        ldy    #$00
        lda    ($DC),y
        cmp    $D0,x
        beq    $0D69
        jsr    $0B36
        bcc    $0D5A
        cpx    $D8
        beq    $0D71
        iny
        dex
        bpl    $0D5E
        lda    $DC
        sta    $DA
        lda    $DD
        sta    $DB
        ldy    #$00
        jmp    $0B9F
        ldx    #$08
        jsr    $0C51
        jsr    $0853
        cmp    #$3E
        beq    $0D55
        dex
        bmi    $0D52
        sta    $D0,x
        bpl    $0D83
        jsr    $0B48
        lda    ($DC),y
        sta    ($DA),y
        jsr    $0B36
        inc    $DA
        bne    $0D94
        inc    $DB
        bcc    $0D94
        jsr    $0B1C
        lda    #$3D
        jsr    $0861
        jsr    $0AA3
        lda    $E7
        sta    ($DC),y
        jsr    $0B36
        bcc    $0DAE
        jsr    $0B48
        lda    $DC
        sta    $D5
        lda    $DD
        sta    $D6
        lda    $DA
        sta    $E7
        lda    $DB
        sta    $D9
        sec
        lda    $D5
        sbc    $DE
        lda    $D6
        sbc    $DF
        bcc    $0DD6
        rts
        ldx    #$00
        stx    $D8
        jsr    $09B3
        ldx    $D2
        ldy    #$00
        jsr    $0E18
        dex
        bmi    $0DCA
        beq    $0DDF
        sec
        lda    $DE
        sbc    ($D5),y
        iny
        lda    $DF
        sbc    ($D5),y
        bcc    $0E14
        dey
        lda    ($D5),y
        sbc    $DC
        tax
        iny
        lda    ($D5),y
        sbc    $DD
        bcc    $0E14
        pha
        txa
        dey
        clc
        adc    $E7
        jsr    $0E1A
        pla
        adc    $D9
        jsr    $0E1A
        jmp    $0DCA
        ldx    #$01
        bpl    $0DDF
        lda    ($D5),y
        sta    ($DA),y
        inc    $D5
        bne    $0E22
        inc    $D6
        inc    $DA
        bne    $0E28
        inc    $DB
        rts
        lda    $D9
        jsr    $0AAC
        lda    $D8
        jmp    $0AAC
        jsr    $0B1C
        ldx    #$03
        sty    $D8,x
        dex
        bpl    $0E38
        ldx    #$10
        jsr    $0E4F
        lda    #$3D
        jsr    $0861
        tya
        jsr    $0AAC
        txa
        jmp    $0AAC
        jsr    $0853
        cmp    #$2F
        beq    $0E70
        cmp    #$2A
        beq    $0E88
        cmp    #$2D
        beq    $0EAB
        cmp    #$2B
        beq    $0EB7
        jmp    $0AFF
        rol    $DC
        rol    $DD
        dex
        bmi    $0E83
        rol    $D8
        rol    $D9
        sec
        lda    $D8
        sbc    $DE
        tay
        lda    $D9
        sbc    $DF
        bcc    $0E65
        sta    $D9
        tya
        sta    $D8
        bcs    $0E65
        ldy    $DD
        ldx    $DC
        rts
        lsr    $DF
        ror    $DE
        bcc    $0E9B
        clc
        lda    $DC
        adc    $D8
        sta    $D8
        lda    $DD
        adc    $D9
        sta    $D9
        ror    $D9
        ror    $D8
        ror    $DB
        ror    $DA
        dex
        bne    $0E88
        ldy    $DB
        ldx    $DA
        rts
        sec
        lda    $DC
        sbc    $DE
        tax
        lda    $DD
        sbc    $DF
        tay
        rts
        clc
        lda    $DC
        adc    $DE
        tax
        lda    $DD
        adc    $DF
        tay
        rts
        jsr    $FFF7
        jsr    $0B1C
        sty    $DA
        sty    $DB
        ldx    #$18
        sec
        lda    $DE
        sbc    $DC
        sta    $E7
        lda    $DF
        sbc    $DD
        bne    $0EE6
        lda    $E7
        beq    $0F38
        cpx    $E7
        bcc    $0EE6
        ldx    $E7
        lda    #$0D
        jsr    $0F38
        lda    #$0A
        jsr    $0F38
        lda    #$3B
        jsr    $0F38
        txa
        jsr    $0F20
        lda    $DD
        jsr    $0F20
        lda    $DC
        jsr    $0F20
        dex
        bmi    $0F14
        lda    ($DC),y
        jsr    $0F20
        inc    $DC
        bne    $0F03
        inc    $DD
        jmp    $0F03
        lda    $DB
        jsr    $0F25
        lda    $DA
        jsr    $0F25
        bpl    $0EC9
        sta    $E7
        jsr    $0F9B
        pha
        lsr    a
        lsr    a
        lsr    a
        lsr    a
        jsr    $0F2E
        pla
        and    #$0F
        ora    #$30
        cmp    #$3A
        bcc    $0F38
        adc    #$06
        jmp    $0861
        jsr    $FFF4
        jsr    $0FA7
        bpl    $0F3E
        jsr    $FFF4
        jsr    $0FA7
        cmp    #$3B
        bne    $0F46
        lda    #$00
        tay
        sta    $DA
        sta    $DB
        jsr    $0F98
        sta    $D9
        jsr    $0F98
        sta    $DD
        jsr    $0F98
        sta    $DC
        sty    $D8
        jsr    $0F98
        ldy    $D8
        sta    ($DC),y
        iny
        cpy    $D9
        bne    $0F63
        jsr    $0F8C
        cmp    $DB
        bne    $0F7F
        jsr    $0F8C
        cmp    $DA
        beq    $0F46
        lda    #$45
        jsr    $084F
        lda    #$52
        jsr    $084F
        jmp    $084F
        jsr    $0F8F
        jsr    $0FA7
        jsr    $0AEA
        jmp    $0AC2
        jsr    $0F8C
        clc
        adc    $DA
        sta    $DA
        bcc    $0FA4
        inc    $DB
        lda    $E7
        rts
        jsr    $FFEB
        pha
        lda    $0203
        beq    $0FB4
        pla
        jmp    $084F
        jmp    $0809
        jsr    $0B11
        jsr    $0B07
        lda    $DB
        jsr    $0AAC
        lda    $DA
        tay
        jsr    $0AAC
        ldx    #$02
        jsr    $0C51
        jsr    $0C51
        jsr    $0C51
        tya
        jsr    $0C51
        iny
        inx
        cpx    #$08
        bne    $0FCD
        jsr    $0B07
        ldy    #$00
        lda    ($DA),y
        jsr    $0AAC
        jsr    $0C51
        inc    $DA
        bne    $0FF0
        inc    $DB
        dex
        bne    $0FE2
        jsr    $0B07
        jsr    $0853
        cmp    #$0A
        beq    $0FBD
        jmp    $0432
