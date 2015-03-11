        TIMER   = $1704
        SAD     = $1740
        PADD    = $1741
        SBD     = $1742
        KEYIN   = $1F40
        GETKEY  = $1F6A
        TABLE   = $1FE7

        LAST    = $40
        FLAG    = $41
        DIE     = $42
        WINDX   = $43
        BUX     = $44
        POINT   = $45
        WINDOW  = $46
        DIVR    = $4E
        PAUSE   = $4F

        .ORG    $0200

START:  CLD
        JSR     KEYIN
        JSR     GETKEY
        CMP     LAST
        BEQ     LIGHT           ; same key as before?
        STA     LAST
        EOR     #$15            ; no-key test
        STA     FLAG            ; into flag
        CMP     #6              ; GO key?
        BNE     NOGO            ; nope..
        LDA     #$10            ; yes, $10
        JSR     DOBUX           ; put in window
NOGO:   LDA     TIMER           ; random value
        LDX     #$C0            ; divide by 6
        STX     DIVR
        LDX     #5
RNDLP:  CMP     DIVR            ; divide..
        BCC     RNDOV           ; ..a..
        SBC     DIVR            ; ..digit
RNDOV:  LSR     DIVR
        DEX
        BPL     RNDLP
        TAX                     ; die 0-5
        INX                     ; die 1-6
        LDA     TABLE,X         ; segment
        LDY     FLAG            ; which die?
        BEQ     PLAY            ; second?
        STX     DIE             ; first, save it..
        STA     WINDX           ; ..& segment
        BNE     LIGHT           ; unconditional
PLAY:   STA     WINDOW+1        ; show die..
        LDA     WINDX           ; ..and other
        STA     WINDOW          ;   one
        LDA     BUX             ; out of dough?
        BEQ     LIGHT           ; ..no bread
        TXA
        CLC
        ADC     DIE             ; add other die
        CMP     POINT           ; get the point?
        BEQ     WIN             ; ..yup
        LDX     POINT           ; point-zero...
        BEQ     FIRST           ; ..first roll
        CMP     #7              ; seven you lose
        BNE     LIGHT           ; ..nope
LOSE:   LDA     BUX
        BEQ     LOSX            ; nough dough?
        CLC
        SED                     ; decimal add..
        SBC     #0              ; neg one
        CLD
LOSX:   JSR     DOBUX           ; put in window
        BNE     LIGHT           ; unconditional
FIRST:  LDX     WINDOW          ; copy point
        STX     WINDOW+2
        LDX     WINDOW+1
        STX     WINDOW+3
        STA     POINT
        TAX                     ; point value
        LDA     TAB-2,X         ; 'win' table
        BEQ     LIGHT           ; ..says point
        BMI     LOSE            ; ..says craps
WIN:    LDA     BUX             ; ..says win
        CMP     #$99            ; maximum bucks?
        BEQ     WINX            ; yes, skip add
        SED                     ; decimally add..
        ADC     #1              ; ..one
        CLD
WINX:   JSR     DOBUX           ; make segments
LIGHT:  LDA     FLAG            ; still rolling?
        BEQ     NOINC           ; ..nope;
        INC     WINDOW          ; ..yup, so..
        INC     WINDOW+1        ; ..roll em!
NOINC:  LDA     #$7F
        STA     PADD
        LDY     #$13
        LDX     #5
LITE:   LDA     WINDOW,X
        STA     SAD
        STY     SBD
PAWS:   INC     PAUSE
        BNE     PAWS
        DEY
        DEY
        DEX
        BPL     LITE
        JMP     START
DOBUX:  STA     BUX
        LDY     #0
        STY     POINT           ; clear point
        STY     WINDOW+2        ; .......
        STY     WINDOW+3        ; display
        TAY
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        TAX
        LDA     TABLE,X
        STA     WINDOW+4
        TYA
        AND     #$0F
        TAX
        LDA     TABLE,X
        STA     WINDOW+5
        RTS

TAB:    .BYTE $FF, $FF, $00, $00, $00, $01, $00, $00, $00, $01, $FF
