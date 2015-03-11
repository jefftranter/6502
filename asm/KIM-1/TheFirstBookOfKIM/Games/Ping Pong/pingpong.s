        SPEED   = $80           ; speed ball travels
        SPOT    = $81           ; segment(s)  ball lights
        LOG     = $82           ; record of recent plays
        PAUSE   = $83           ; delay before ball moves
        DIRECT  = $84           ; direction of ball
        PLACE   = $85           ; position of ball
        SCORE   = $86
        PLEFT   = $87           ; 0 for KIM to play left
        PRITE   = $88           ; 0 for KIM to play right
        DIGIT   = $89
        ARG     = $8A
        MOD     = $8B
        TEMP    = $8C

        TIMER   = $1704
        SAD     = $1740
        PADD    = $1741
        SBD     = $1742
        KEYIN   = $1F40
        GETKEY  = $1F6A
        TABLE   = $1FE7

        .ORG    $0200

START:  JSR     KEYIN           ; directional registers
        JSR     GETKEY          ; input key
        CMP     #$13            ; GO key?
        BNE     NOGO            ; nope, skip
; GO key -      set up game here
        LDX     #8              ; get 9 ..
SETUP:  LDA     INIT,X          ;       ..inital valus
        STA     SPEED,X         ;       to zero page
        DEX
        BPL     SETUP
; test   legal keys (0,3,4,7,8,n,C,F)
NOGO:   CMP     #$10            ; key 0 to F?
        BCS     NOKEY           ; no, skip
        TAX                     ; save key in X
        AND     #3              ; test column
        BEQ     KEY             ; col 0 (0,4,8,C)?
        CMP     #3              ; col 3 (3,7,B,F)?
        BNE     NOKEY           ; neither - skip
KEY:    EOR     PLACE           ; check vs ball postn
        TAY
        AND     #4              ; ball off screen?
        BNE     NOKEY
        TXA                     ; restore key
        EOR     DIRECT          ; ball going away?
        AND     #2
        BEQ     NOKEY           ; yes, ignore key
        TYA                     ; ball position
        AND     #2              ; wrong side of net?
        BNE     POINT           ; yes, lose!
; legal play found here
        TXA                     ; restore key
        LSR     A               ; type (0=Spin, etc)
        LSR     A
        JSR     SHOT            ; make shot
; key rtns   complete - play ball
NOKEY:  JSR     KEYIN           ; if key still prest..
        BNE     FREEZE          ; freeze ball
        DEC     PAUSE
        BPL     FREEZE          ; wait til timeout
        LDA     SPEED
        STA     PAUSE
        CLC
        LDA     PLACE           ; move..
        ADC     DIRECT          ; ..ball
        STA     PLACE
        AND     #4              ; ball still..
        BEQ     FREEZE          ; in court?
; ball   outside - KIM to play?
        LDA     PLACE
        BMI     TESTL           ; ball on left
        LDA     PRITE           ; KIM plays right?
        BPL     SKPT            ; unconditional
TESTL:  LDA     PLEFT           ; KIM plays left?
SKPT:   BNE     POINT           ; no, lose point
; KIM   plays either side here
        LDX     LOG             ; log determines..
        LDA     PLAY,X          ; KIM's play
        JSR     SHOT            ; make the shot
FREEZE: LDA     #$7F
        STA     PADD            ; open registers
; light display here
        LDY     #$13
        LDX     #1
        STX     DIGIT           ; count score digts
        LDA     SCORE
        LSR     A               ; shift & store..
        LSR     A
        LSR     A
        LSR     A               ; ..left player score
        STA     ARG
        LDA     SCORE
        AND     #$0F            ; ..right player score
        TAX
HOOP:   LDA     TABLE,X
        JSR     SHOW
        LDX     ARG             ; error in printed listing?
        DEC     DIGIT
        BPL     HOOP
        LDX     #3
VUE:    LDA     PIX,X
        CPX     PLACE
        BNE     NOPIX
        ORA     SPOT            ; show the ball
NOPIX:  JSR     SHOW
        DEX
        BPL     VUE
        BMI     SLINK
; lose! score & reverse board
POINT:  JSR     SKORE
SLINK:  CLD
        JMP     START           ; return to main loop
; display subroutine
SHOW:   STA     SAD
        STY     SBD
STALL:  DEC     MOD
        BNE     STALL
        DEY
        DEY
        RTS
SHOT:   TAY                     ; save shot in Y
        LDX     LOG             ; old log in X
        ASL     LOG
        ASL     LOG
        ORA     LOG
        AND     #$F             ; update log book
        STA     LOG             ; ..last two shots
        SEC
        LDA     SPEED
        SBC     PAUSE           ; invert timing
        STA     PAUSE
; set speed & display segment(s)
        LDA     SPD,Y
        STA     SPEED
        LDA     SEG,Y
        STA     SPOT
; test play success - random
        LDA     CHANCE,X        ; odds from log bk
GIT:    DEY
        BMI     GET
        LSR     A
        LSR     A
        BPL     GIT             ; unconditional
GET:    AND     #3              ; odds 0 to 3..
        ASL     A               ; now 0 to 6
        STA    TEMP
        LDA    TIMER            ; random number
        AND    #7               ; now 0 to 7
        CMP    TEMP
        BEQ    REVRS            ; success?
        BCC    REVRS            ; success?
; lose a point & position to serve
SKORE:  LDX    #4               ; position ball R
        LDA    DIRECT
        ASL    A
        ASL    A
        ASL    A
        ASL    A
        BPL    OVER
        LDX    #$FF             ; position ball L
        LDA    #1
OVER:   STX    PLACE
        CLC
        ADC    SCORE
        STA    SCORE
        LDY    #0               ; end game, kill ball
TLP:    TAX
        AND    #$F               ; get one score
        CMP    #11               ; 11 points?
        BNE    SKI
        STY    DIRECT            ; kill ball
SKI:    TXA
        LSR    A
        LSR    A
        LSR    A
        LSR    A
        BNE    TLP
; set serve - speed, spot, log, pause
        LDX    #3
SRV:    LDA    INIT,X
        STA    SPEED,X
        DEX
        BPL    SRV
; reverse ball direction
REVRS:  LDA    DIRECT
        CLC
        EOR    #$FF
        ADC    #1
        STA    DIRECT
        RTS

; tables - in Hexadecimal format

INIT:   .BYTE  $30, $08, $00, $80, $01, $FF, $00, $01, $00
PIX:    .BYTE  $00, $06, $30, $00
SPD:    .BYTE  $20, $20, $20, $14
SEG:    .BYTE  $08, $40, $01, $49
PLAY:   .BYTE  $02, $02, $01, $02, $01, $03, $01, $02, $03, $03, $00, $02, $00, $00, $02, $02
CHANCE: .BYTE  $78, $B5, $9E, $76, $6E, $A1, $AE, $75, $AA, $EB, $8F, $75, $5B, $56, $7A, $35

; end
