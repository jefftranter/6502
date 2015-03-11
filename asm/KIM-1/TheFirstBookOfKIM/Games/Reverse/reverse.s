        POINTR  = $10
        MOD     = $11
        RND     = $12
        WINDOW  = $18

        SAD     = $1740
        SADD    = $1741
        SBD     = $1742
        KEYIN   = $1F40
        GETKEY  = $1F6A
        TABLE   = $1FE7

        .ORG    $0200

START:  INC     RND+4           ; randomize
        JSR     KEYIN           ; **Game by Bob Albrecht -
        BNE     START           ; People's Computer Co  **
        CLD
        LDX     #5
        LDA     #0
        STX     POINTR
ZLOOP:  STA     WINDOW,X        ; set window to zeros
        DEX
        BPL     ZLOOP
RAND:   SEC
        LDA     RND+1           ; hash in new random number
        ADC     RND+4
        ADC     RND+5
        STA     RND
        LDX     #4
RLP:    LDA     RND,X           ; move random string down one
        STA     RND+1,X
        DEX
        BPL     RLP
        LDY     #$C0            ; divide random 4 by 6
        STY     MOD
        LDY     #6
SET:    CMP     MOD
        BCC     PASS
        SBC     MOD
PASS:   LSR     MOD
        DEY
        BNE     SET
        TAX
        LDY     POINTR
        LDA     TABLE+10,Y      ; digits A to F
TOP:    DEX
        BPL     TRY             ; find an empty window
        LDX     #5
TRY:    LDY     WINDOW,X
        BNE     TOP
        STA     WINDOW,X        ; and put the digit in
        DEC     POINTR
        BPL     RAND
SLINK:  BEQ     START           ; link to start
WTEST:  LDX     #5              ; test
TEST2:  LDA     WINDOW,X        ;     win
        CMP     WINNER,X        ;        condition
        BNE     PLAY
        DEX
        BPL     TEST2
        LDX     #5
        LDA     #$40            ; set
SET1:   STA     WINDOW,X        ;    to
        DEX                     ;     "------"
        BPL     SET1
PLAY:   LDA     #$7F            ; directional
        STA     SADD            ;            registers
        LDY     #$09
        LDX     #$FA            ; negative 5
SHOW:   LDA     WINDOW+6,X      ; light (Note error in published listing)
        STA     SAD             ; display
        STY     SBD
ST1:    DEC     MOD
        BNE     ST1
        INY
        INY
        INX
        BMI     SHOW            ; Note error in published listing
        JSR     KEYIN
        JSR     GETKEY
        CMP     #$13            ; GO key?
        BEQ     SLINK           ;   yes, restart
        CMP     #7              ; Keys 0 to 6?
        BCS     WTEST           ;   no, test win
        TAX                     ; Keys 1 to 6?
        BEQ     PLAY            ;   no, exit
        DEX                     ; Keys 2 to 6 (=1 to 5)?
        BEQ     PLAY            ;   no, exit
        CPX     POINTR          ; Same key as before?
        BEQ     PLAY            ;   yes, ignore
        STX     POINTR          ;   no, we've got a live one
TOP1:   LDA     WINDOW,X
        PHA                     ; roll em out...
        DEX
        BPL     TOP1
        LDX     POINTR
TOP2:   PLA                     ; roll 'em back in
        STA     WINDOW,X
        DEX
        BPL     TOP2
        BMI     PLAY

WINNER: .BYTE   $F7, $FC, $B9, $DE, $F9, $F1

; end
