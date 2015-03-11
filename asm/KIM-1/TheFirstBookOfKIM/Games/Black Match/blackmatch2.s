IQ      = $ED
SLOW    = $EE
INH     = $F9
POINTL  = $FA
POINTH  = $FB

CLOCK   = $1707
SCANDS  = $1F1F
GETKEY  = $1F6A

        .ORG    $0200

START:  LDA     #$21            ; initial IQ
        STA     IQ
NEW:    LDA     #$21            ; 21 matches
        STA     INH             ;   to start game
PLAY:   LDA     #0              ; clear player's move
        STA     POINTH
        JSR     SCANDS          ; light display
        JSR     GETKEY          ;   and test keys
        CMP     #4              ; key 4 or over?
        BPL     PLAY            ;   go back
        CMP     #0              ; key 0? go back
        BEQ     PLAY
        STA     POINTH          ; record move
        LDA     #0              ; wipe last KIM move
        STA     POINTL
        SED                     ; decimal mode
        SEC
        LDA     INH             ; get total matches
        SBC     POINTH          ; subtract move
        BMI     PLAY            ; not enough matches?
        STA     INH             ; OK, new total
        LDA     #8
        STA     SLOW            ; set slow counter
TIME:   LDA     #$FF            ; slowest count into..
        STA     CLOCK           ;  ..slowest KIM timer
DISP:   JSR     SCANDS
        BIT     CLOCK
        BPL     DISP
        DEC     SLOW
        BNE     TIME
        CLC
        LDA     INH             ; get total
        BEQ     DEAD            ; player loses?
        ADC     #4              ; divide m-1 by 4
SUB:    SBC     #4
        BEQ     DUMP
        CMP     #4
        BCS     SUB             ; keep dividing
        LDX     $1746           ; random, timer#2
        CPX     IQ              ; KIM smart enough?
        BCS     COMP            ; Yes
DUMP:   LDA     #1              ; No
COMP:   STA     POINTL          ; Record the move
        SEC
        LDA     INH
        SBC     POINTL          ; Subtract KIM move
        STA     INH             ;  from total
        BNE     PLAY
        LDA     #$5A            ; Player wins:
        LDY     #$FE            ;  SAFE
        LSR     IQ              ; get smart
        BPL     SHOW
DEAD:   LDX     #$DE            ; KIM wins:
        LDY     #$AD            ;  DEAD
        SEC
        ROL     IQ              ; get dumb
SHOW:   STX     POINTH
        STY     POINTL
LOK:    JSR     SCANDS
        BNE     NEW             ; new game if key
        BEQ     LOK
        .end
