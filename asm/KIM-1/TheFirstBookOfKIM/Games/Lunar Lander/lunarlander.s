        ALT     = $D5
        VEL     = $D8
        TH2     = $DB
        THRUST  = $DD
        FUEL    = $DE
        MODE    = $E1
        DOWN    = $E2
        DECK    = $E3
        INH     = $F9

; linkages to KIM monitor

        SCANDS  = $1F1F
        GETKEY  = $1F6A
        POINTH  = $FB
        POINTL  = $FA

        .ORG    $0200

;  main routine - initialization

GO:     LDX     #13             ; fourteen bytes
LP1:    LDA     INIT,X
        STA     ALT,X
        DEX
        BPL     LP1

;  Update height and velocity

CALC:   LDX     #5
RECAL:  LDY     #1
        SED
        CLC
DIGIT:  LDA     ALT,X
        ADC     ALT+2,X         ; add each digit
        STA     ALT,X
        DEX
        DEY
        BPL     DIGIT           ; next digit
        LDA     ALT+3,X         ; hi-order .. zero ..
        BPL     INCR            ; .. or ..
        LDA     #$99
INCR:   ADC     ALT,X
        STA     ALT,X
        DEX
        BPL     RECAL           ; do next addition
        LDA     ALT
        BPL     UP              ; still flying?
        LDA     #0              ; nope, turn off
        STA     DOWN
        LDX     #2
DD:     STA     ALT,X
        STA     TH2,X
        DEX
        BPL     DD
UP:     SEC                     ; update fuel
        LDA     FUEL+2
        SBC     THRUST
        STA     FUEL+2
        LDX     #1              ; two more digits to go
LP2:    LDA     FUEL,X
        SBC     #0
        STA     FUEL,X
        DEX
        BPL     LP2
        BCS     TANK            ; still got fuel?
        LDA     #0              ; nope, kill motor
        LDX     #3
LP3:    STA     THRUST,X
        DEX
        BPL     LP3

; show alt, fuel, or messages

        JSR     THRSET
TANK:   LDA     FUEL            ; fuel into registers
        LDX     FUEL+1
        ORA     #$F0            ; plus F flag
        LDY     MODE
        BEQ     ST
GOLINK: BEQ     GO
CLINK:  BEQ     CALC
        LDX     #$FE
        LDY     #$5A
        CLC
        LDA     VEL+1
        ADC     #5
        LDA     VEL
        ADC     #0
        BCS     GOOD
        LDX     #$AD
        LDY     #$DE
GOOD:   TYA
        LDY     DOWN
        BEQ     ST
        LDA     ALT
        LDX     ALT+1
ST:     STA     POINTH
        STX     POINTL

; show rate of ascent/descent as absolute

        LDA     VEL+1
        LDX     VEL             ; up or down?
        BPL     FLY             ; .. up, we're OK
        SEC
        LDA     #0
        SBC     VEL+1
FLY:    STA     INH
        LDA     #2              ; loop twice thru display
        STA     DECK
        CLD                     ; display & key test
FLITE:  JSR     SCANDS          ; light 'em up!
        JSR     GETKEY          ; check keys
        CMP     #$13            ; GO key?
        BEQ     GOLINK          ; ...yes
        BCS     NOKEY           ; ..if no key
        JSR     DOKEY
NOKEY:  DEC     DECK
        BNE     FLITE
        BEQ     CLINK           ; to CALC

; subroutine to test keys

DOKEY:  CMP     #$0A            ; test numeric
        BCC     NUMBER
        EOR     #$0F            ; Fuel F gives 0 flag
        STA     MODE
RETRN:  RTS
NUMBER: TAX
        LDA     THRUST          ; test; is motor off?
        BEQ     RETRN           ; yes, ignore key
        STX     THRUST          ; no, store thrust

; calculate accel as thrust minus 5

THRSET: LDA     THRUST
        SEC
        SED
        SBC     #5
        STA     TH2+1
        LDA     #0
        SBC     #0
        STA     TH2
        RTS

; initial values

INIT:   .BYTE   $45,1,0         ; altitude
        .BYTE   $99,$81,0       ; rate of ascent
        .BYTE   $99,$97         ; acceleration
        .BYTE   2               ; thrust
        .BYTE   8,0,0           ; fuel
        .BYTE   1               ; display mode
        .BYTE   1               ; in flight/landed
; end
