        WINDOW  = $60
        WINGS   = $66
        FLAG    = $6C
        GOT     = $6D
        CORN    = $6E
        KEY     = $6F
        POINL   = $70
        POINH   = $71
        DELAY   = $72
        WAIT    = $73

        TIMER   = $1704
        SAD     = $1740
        PADD    = $1741
        SBD     = $1742
        DONE    = $1925
        KEYIN   = $1F40
        GETKEY  = $1F6A

        .ORG    $0200

START:  LDX     #13
        STX     CORN            ; bushels of corn to start
        LDA     #0              ; clear the window
SLOOP:  STA     WINDOW,X
        DEX
        BPL     SLOOP
TEST:   LDX     #11             ; is window empty?
TLOOP:  LDA     WINDOW,X
        BNE     CONTIN          ; no. keep going
        DEX
        BPL     TLOOP
        INC     GOT             ; yes. make new animal
        LDA     FLAG
        BEQ     MORE            ; did last animal get in?
        DEC     GOT
        DEC     CORN            ; take away some corn
        BNE     MORE            ; any left?
        JMP     DONE            ; no, end of game
MORE:   LDA     TIMER           ; random value..
        LSR     A               ; ..to generate..
        LSR     A
        LSR     A
        LSR     A               ; ..new random animal
        LSR     A
        CMP     #6              ; 6 types of animal
        BCC     MAKE
        AND     #$03
MAKE:   CLC
        TAX                     ; animal type to X
        ADC     #$0A            ; key type A to F
        STA     KEY
        LDA     INDEX,X         ; animal 'picture' address
        STA     POINL           ; to indirect pointer
        LDA     #2
        STA     POINH
        LDY     #5              ; six locations to move
ALOOP:  LDA     (POINL),Y       ; from 'picture'
        STA     WINGS,Y         ; ..to 'wings'
        DEY
        BPL     ALOOP
        STY     FLAG            ; flag FF - animal coming
CONTIN: LDX     #5              ; test:
CLOOP:  LDA     WINGS,X         ; is animal out of 'wings'?
        BNE     NOKEY           ; no, ignore keyboard
        DEX
        BPL     CLOOP
        JSR     KEYIN
        JSR     GETKEY
        CMP     KEY             ; right animal named?
        BNE     NOKEY           ; no, ignore key
        LDA     FLAG
        BPL     NOKEY           ; animal retreating?
        INC     FLAG            ; make animal retreat
NOKEY:  DEC     DELAY           ; wait a while..
        BNE     NOMOVE          ; before moving animal
        LDA     #$20            ; speed control value
        STA     DELAY
        LDA     FLAG            ; move animal - which way?
        BMI     COMING          ; ..left
        LDX     #10             ; ..right
RLOOP:  LDA     WINDOW-6,X
        STA     WINDOW-5,X
        DEX
        BNE     RLOOP
        STX     WINDOW-6        ; clear extreme left
        BEQ     NOMOVE          ; unconditional branch
COMING: LDX     #$F0            ; -16
CMLOOP: LDA     WINDOW+12,X
        STA     WINDOW+11,X
        INX
        BMI     CMLOOP
NOMOVE: LDA     #$7F            ; light KIM display
        STA     PADD
        LDY     #$13
        LDX     #5              ; six display digits
LITE:   LDA     WINDOW,X
        STA     SAD
        STY     SBD
LITEX:  INC     WAIT
        BNE     LITEX
        DEY
        DEY
        DEX
        BPL     LITE
        JMP     TEST

; index and animal 'pictures' in hexadecimal form

INDEX:  .BYTE $AA, $B0, $B6, $BC, $C2, $C8, $08, $00, $00, $00, $00, $00, $01, $61, $61, $40, $00, $00
        .BYTE $61, $51, $47, $01, $00, $00, $63, $58, $4E, $00, $00, $00, $71, $1D, $41, $1F, $01, $00
        .BYTE $63, $58, $4C, $40, $00, $00
