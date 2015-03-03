
;       LINKAGES TO KIM MONITOR

KEYIN   = $1F40
GETKEY  = $1F6A
TABLE   = $1FE7
PADD    = $1741
SBD     = $1742
SAD     = $1740
;
; WORK AREAS
;
       .org $0000

SECRET = $0000                  ; computer's secret code
WINDOW = $0004                  ; display window
INPUT  = $000a                  ; 4 player's input area
EXACT  = $000E                  ; # of exact matches
MATCH  = $000F                  ; # of other matches
POINTR = $0010                  ; digit being input
MOD    = $0011                  ; divisor/delay flag
RND    = $0012                  ; random number series
COUNT  = $0018                  ; number of guesses left

        .org    $0200

GO:     INC     RND+4           ; randomize
        JSR     KEYIN           ; on pushbutton delay
        BNE     GO
        CLD
NEW:    LDA     #$0A            ; ten guesses/game
        STA     COUNT           ; new game starting
        LDA     #3              ; create 4 mystery codes
        STA     POINTR
RAND:   SEC                     ; one plus...
        LDA     RND+1           ; ...three previous
        ADC     RND+4           ; random numbers
        ADC     RND+5
        STA     RND             ; =new random value
        LDX     #4
RLP:    LDA     RND,X           ; move random numbers over
        STA     RND+1, X
        DEX
        BPL     RLP
        LDX     POINTR
        LDY     #$C0            ; divide by 6
        STY     MOD             ; keeping remainder
        LDY     #6
SET:    CMP     MOD
        BCC     PASS
        SBC     MOD
PASS:   LSR     MOD
        DEY
        BNE     SET             ; continue division
        CLC
        ADC     #$0A            ; random value A to F
        STA     SECRET, X
        DEC     POINTR
        BPL     RAND
GUESS:  DEC     COUNT           ; new guess starts here
        BMI     FINISH          ; ten guesses?
        LDA     #0
        LDX     #$0C            ; clear from WINDOW...
WIPE:   STA     WINDOW, X       ; ...to POINTR
        DEX
        BPL WIPE
;
; WAIT FOR KEY TO BE DEPRESSED
;
WAIT:   JSR     SHOW
        BEQ     WAIT
        JSR     SHOW
        BEQ     WAIT            ; debounce key
        LDA     WINDOW+4        ; new guess?
        BEQ     RESUME          ; no, input digit
        AND     #$60
        EOR     #$60            ; previous game finished?
        BEQ     NEW             ; ...yes, new game;
        BNE     GUESS           ; ...no, next guess
RESUME: JSR     GETKEY
        CMP     #$10            ; guess must be in
        BCS     WAIT            ; range A to F
        CMP     #$0A
        BCC     WAIT
        TAY
        LDX     POINTR          ; zero to start
        INC     POINTR
        LDA     TABLE,Y         ; segment pattern
        STA     WINDOW,X
        TYA
        CMP     SECRET,X        ; exact match?
        BNE     NOTEX
        INC     EXACT
        TXA                     ; destroy input
NOTEX:  STA     INPUT,X
        LDA     WINDOW+3        ; has fourth digit arrived?
        BEQ     BUTT            ; ...no
        LDY     #3              ; ...yes, calculate matches
STEP:   LDA     INPUT,Y         ; for each digit:
        AND     #$18            ; ..has it already been
        BEQ     ON              ; matched?
        LDA     SECRET,Y
        LDX     #3              ; if not, test
LOOK:   CMP     INPUT, X        ; ...against input
        BEQ     GOT
        DEX
        BPL     LOOK
        BMI     ON
GOT:    INC     MATCH           ; increment counter
        ASL     INPUT,X         ; and destroy input
ON:     DEY
        BPL     STEP
        LDX     #1              ; display counts
TRANS:  LDY     EXACT,X
        LDA     TABLE,Y
        STA     WINDOW+4,X
        DEX
        BPL     TRANS
DELAY:  JSR     SHOW            ; long pause for debounce
        INC     MATCH
        BNE     DELAY
BUTT:   JSR     SHOW            ; wait for key release
        BNE     BUTT
        BEQ WAIT
;
;       TEN GUESSES MADE - SHOW ANSWER
;
FINISH: LDX     #3
FIN2:   LDY     SECRET,X
        LDA     TABLE,Y
        STA     WINDOW,X
        DEX
        BPL     FIN2
        LDA     #$E3            ; 'square' flag
        STA     WINDOW+4
        BNE     DELAY           ; unconditional jump
;       SUBROUTINE TO DISPLAY
;       AND TEST KEYBOARD
SHOW:   LDY      #$13
        LDX      #5
        LDA      #$7F
        STA      PADD
LITE:   LDA      WINDOW, X
        STA      SAD
        STY      SBD
POZ:    INC      MOD            ; pause loop
        BNE      POZ
        DEY
        DEY
        DEX
        BPL     LITE
        JSR     KEYIN
        RTS
        .END
