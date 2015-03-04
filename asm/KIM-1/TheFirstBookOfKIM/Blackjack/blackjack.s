DECK    = $40
POINTR  = $74
PARAM   = $75
DPT     = $76
AMT     = $77
BET     = $79
HOLE    = $7A
PAUSE   = $7B
YSAV    = $7F
RND     = $80
WINDOW  = $90
UCNT    = $96
UTOT    = $97
UACE    = $98
MCNT    = $99
MTOT    = $9A
MACE    = $9B

TIMER   = $1704
SAD     = $1740
PADD    = $1741
SBD     = $1742
KEYIN   = $1F40
GETKEY  = $1F6A
TABLE   = $1FE7

        .org    $0200

START:  LDX     #51             ; 52 cards in deck
DK1:    TXA                     ; Create deck
        STA     DECK,X          ; by inserting cards
        DEX                     ; into deck
        BPL     DK1             ; in sequence
        LDX     #2              ; Set up 5 locations
INLOP:  LDA     INIT,X          ; ..into..
        STA     PARAM,X         ; zero page
        DEX                     ; addresshi/ dpt/ amt
        BPL     INLOP
        LDA     TIMER           ; use random timer
        STA     RND             ; to seed random chain
DEAL:   CLD                     ; main loop repeats here
        LDX     DPT             ; next-card pointer
        CPX     #9              ; less than 9 cards?
        BCS     NOSHUF          ; 9 or more, don't shuffle
; shuffle deck
        LDY     #SHUF-$300      ; Set up SHUFFL msg
        JSR     FILL            ; put in WINDOW
        LDY     #51             ; ripple 52 cards
        STY     DPT             ; set full deck
SHLP:   JSR     LIGHT           ; illuminate display
        SEC
       LDA     RND+1           ; Generate
        ADC     RND+2           ; new
        ADC     RND+5           ; random
        STA     RND             ; number
        LDX     #4
RMOV:   LDA     RND,X           ; move over
        STA     RND+1,X         ; the random
        DEX                     ; seed numbers
        BPL     RMOV
        AND     #$3F            ; Strip to 0-63 range
        CMP     #52             ; Over 51?
        BCS     SHLP            ; yes, try new number
; swap each card into random slot
        TAX
        LDA     DECK,Y          ; get next card
        PHA                     ; save it
        LDA     DECK,X          ; get random card
        STA     DECK,Y          ; into position N
        PLA                     ; and the original card
        STA     DECK,X          ; into the random slot
        DEY                     ; next in sequence
        BPL     SHLP            ; bck for next card
; ready to accept bet
NOSHUF: LDY     #MBET-$300      ; Set up BET? msg
        JSR     FILL            ; put in WINDOW
        LDA     AMT             ; display balance
        JSR     NUMDIS          ; ..put in WINDOW
BETIN:  JSR     LIGHT           ; illuminate display
        CMP     #10             ; not key C to 9?
        BCS     BETIN           ; nope, ignore
        TAX
        STX     BET             ; store bet amount
        DEX
        BMI     BETIN           ; zero bet?
        CPX     AMT             ; sufficient funds?
        BCS     BETIN           ; no, refuse bet
; bet accepted - deal
        LDX     #11             ; Clean WINDOW and
        LDA     #0              ; card counters
CLOOP:  STA     WINDOW,X
        DEX
        BPL     CLOOP
; here come the cards
        JSR     YOU             ; one for you..
        JSR     ME              ; & one for me..
        JSR     YOU             ; another for you..
        JSR     CARD            ; put my second card..
        STX     HOLE            ; ..in the hole
        JSR     WLITE           ; wait a moment
; deal complete -  wait for Hit or Stand
TRY:    JSR     LIGHT
        TAX
        DEX                     ; key input?
        BMI     HOLD            ; zero for Stand?
        CPX     UCNT            ; N for card #n?
        BNE     TRY             ; nope, ignore  key
; Hit - deal another card
        JSR     YOU             ; deal it
        CMP     #$22            ; 22 or over?
        BCS     UBUST           ; yup, you bust
        CPX     #5              ; 5 cards?
        BEQ     UWIN            ; yup, you win
        BNE     TRY             ; nope, keep going
; Stand - show player's total
HOLD:   LDA     WINDOW+5        ; save KIM card
        PHA                     ; on stack
        LDX #0                  ; flag player
        JSR     SHTOT           ; ..for total display
        LDX     #4
        LDA     #0
HLOOP:  STA     WINDOW,X        ; clean window
        DEX
        BPL     HLOOP
; restore display card and hole card
        PLA                     ; display card
        STA     WINDOW+5        ; back to display
        LDX     HOLE            ; get hole card
        JSR     CREC            ; rebuild
        JSR     MEX             ; play and display
; KIM plays here
PLAY:   JSR     WLITE           ; pause to show cards
        LDA     MTOT            ; point total
        CMP     #$22            ; ..22 or over?
        BCS     IBUST           ; yup, KIM bust
        ADC     MACE            ; add 10 for aces?
        LDX     WINDOW+1        ; five cards?
        BNE     IWIN            ; yes, KIM wins
        CMP     #$22            ; 22+ including aces?
        BCC     POV             ; nope, count ace high
        LDA     MTOT            ; yup, ace low
POV:    CMP     #$17            ; 17 or over?
        BCS     HOLD2           ; yes, stand..
        JSR     ME              ; no, hit..
        BNE     PLAY            ; unconditional Branch
; KIM wins here
UBUST:  JSR     WLITE           ; show player's hand..
        JSR     BUST            ; make BUST message..
        JSR     WLITE           ; ..and show it
IWIN:   LDA     AMT             ; decrease balance
        SED
        SEC
        SBC     BET             ; ..by amount of bet
JLINK:  STA     AMT             ; store new balance
XLINK:  JMP     DEAL            ; next play
; Player wins here
IBUST:  JSR     BUST            ; make BUST message..
UWIN:   JSR     WLITE           ; display pause
ADD:    LDA     AMT             ; increase balance
        SED
        CLC
        ADC     BET             ; by amount of bet
        LDY     #$99            ; $99 maximum..
        BCC     NOFLO           ; have we passed it?
        TYA                     ; yes, restore $99
NOFLO:  BNE     JLINK           ; unconditional branch
; KIM stands - compare points
HOLD2:  LDX     #3              ; flag KIM..
        JSR     SHTOT           ; ..for total display
        LDA     MTOT            ; KIM's total..
        CMP     UTOT            ; vs. Player's total..
        BEQ     XLINK           ; same, no score;
        BCS     IWIN            ; KIM higher, wins;
        BCC     ADD             ; KIM lower, loses.

; subroutines start here
; SHTOT shows point totals per X register
SHTOT:  LDA     UTOT,X         ; player's or KIM's total
        SED
        CLC
        ADC     UACE,X          ; try adding Ace points
        CMP     #$22            ; exceeds 21 total?
        BCS     SHOVER          ; yes, skip
        STA     UTOT,X          ; no, make permanent
SHOVER: CLD
        LDA     UTOT,X          ; get revised total
        PHA                     ; save it
        LDY     #TOT-$300       ; set up TOT- msg
        JSR     FILL            ; put in WINDOW
        PLA                     ; recall total
        JSR     NUMDIS          ; insert in window
; display pause, approx 1 second
WLITE:  LDY     #$80            ; timing constant
WDO:    JSR     LIGHT           ; illuminate screen
        DEY                     ; countdown
        BNE     WDO
; illuminate display
LIGHT:  STY     YSAV            ; save register
        LDY     #$13
        LDX     #$5             ; 6 digits to show
        LDA     #$7F
        STA     PADD            ; set directional reg
DIGIT:  LDA     WINDOW,X
        STA     SAD             ; character segments
        STY     SBD             ; character ID    
WAIT:   INC     PAUSE
        BNE     WAIT            ; wait loop
        DEY
        DEY  
        DEX
        BPL     DIGIT
        JSR     KEYIN           ; switch Dir Reg
        JSR     GETKEY          ; test keyboard
        LDY     YSAV            ; restore Y value
        RTS
; fill WINDOW with BUST or other message
BUST:   LDY     #BST-$300
FILL:   STY     POINTR
        LDY     #5              ; six digits to move
FILLIT: LDA     (POINTR),Y      ; load a digit
        STA     WINDOW,Y        ; put in window
        DEY
        BPL     FILLIT
        RTS
; deal a card, calc value & segments
CARD:   LDX     DPT             ; Pointer in deck
        DEC     DPT             ; Move pointer
        LDA     DECK,X          ; Get the card
        LSR     A               ; Drop the suit
        LSR     A
        TAX                     ; 0 to 12 in X
CREC:   CLC                     ; no-ace flag
        BNE     NOTACE          ; branch if not ace
        SEC                     ; ace flag
NOTACE: LDA     VALUE,X         ; value from table
        LDY     SEGS,X          ; segments from table
        RTS
; card to player,including display & count
YOU:    JSR     CARD            ; deal card
        INC     UCNT            ; card count
        LDX     UCNT            ; use as display pointer
        STY     WINDOW-1,X      ; put card in Wndw
        LDY     #$10            ; ten count for aces
        BCC     YOVER           ; no ace?
        STY     UACE            ; ace, set 10 flag
YOVER:  CLC
        SED
        ADC     UTOT            ; add points to..
        STA     UTOT            ; ..point total
        CLD
        RTS
; card to KIM, including display & counts
ME:     JSR     CARD            ; deal card
MEX:    DEC     MCNT            ; inverted count
        LDX     MCNT            ; use as (r) display pontr
        STY     WINDOW+6,X      ; into window
        LDY     #$10            ; ten count for aces
        BCC     MOVER           ; no ace?
        STY     MACE            ; aces set 10 flag
MOVER:  CLC
        SED
        ADC     MTOT            ; add points to..
        STA     MTOT            ; .. point total
        CLD
        RTS
; transfer number in A  to display
NUMDIS: PHA                     ; save number
        LSR     A               ; extract left digit
        LSR     A
        LSR     A
        LSR     A
        TAY
        LDA     TABLE,Y         ; convert to segments
        STA     WINDOW+4
        PLA                     ; restore digit
        AND     #$0F            ; extract right digit
        TAY
        LDA     TABLE,Y         ; convert to segments
        STA     WINDOW+5
        RTS

; tables in hex format

INIT:   .BYTE  $03, $00, $20
VALUE:  .BYTE $01, $02, $03, $04, $05, $06, $07, $08, $09, $10, $10, $10, $10
SEGS:   .BYTE $F7, $DB, $CF, $E6, $ED, $FD, $87, $FF, $EF, $F1, $F1, $F1, $F1
SHUF:   .BYTE $ED, $F6, $BE, $F1, $F1, $B8
MBET:   .BYTE $FC, $F9, $F8, $D3
TOT:    .BYTE $F8, $DC, $F8, $C0
BST:    .BYTE $FC, $BE, $ED, $87, $F9, $DE
