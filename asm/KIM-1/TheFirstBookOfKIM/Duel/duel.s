        SADD    = $1741
        KEYIN   = $1F40
        CONVD   = $1F48
        CONVX   = $1F4E
        GETKEY  = $1F6A

        .ORG    $0200

        LDA     #$10            ; INITIALIZE DIGITS
        STA     $00F9
        STA     $00FB
RAND:   LDA     $1744           ; GET "RANDOM" #
        AND     #$1F            ; NOT TOO BIG
        ORA     #$01            ; NOT TOO SMALL
        STA     $00EE           ; PUT IN DECREMENT LOC.
        LDA     #$00            ; BLANK CENTER DIGITS
        STA     $00FA
DISP:   JSR     LITE            ; DISPLAY DIGITS
        LDA     $1707           ; TIME UP?
        BEQ     MORE            ; NO
        LDA     #$FF
        STA     $1707           ; START TIMER
        DEC     $00EE           ; FULL TIME UP?
        BPL     MORE            ; NO, SKIP
        LDA     #$36            ; YES, CHANGE
        STA     $00FA           ; CENTER DIGITS
MORE:   CLD                     ; CLEAR FOR KEYBOARD
        JSR     KEYIN           ; INIT. KEYBOARD
        JSR     GETKEY          ; KEY DEPRESSED?
        CMP     #$15            ; VALID KEY?
        BPL     DISP            ; NO
        CMP     #$07            ; RIGHT KEY?
        BEQ     RITE            ; YES
        CMP     #$00            ; LEFT KEY?
        BEQ     LEFT            ; YES
        BNE     DISP            ; NOT A 0 OR A 7
LEFT:   LDX     #$02            ; INDEX FOR LEFT
        LDA     $00EE           ; TIME UP?
        BPL     LOS1            ; NO DECREASE LEFT ONE
        BMI     ADD1            ; YES, INCREASE LEFT
RITE:   LDX     #$00            ; INDEX FOR RIGHT
        LDA     $00EE           ; CHECK TIME
        BPL     LOS1            ; NOPE, NOT YET
ADD1:   SED
        CLC                     ; INCREASE SCORE
        LDA     $00F9,X         ; BY ONE
        ADC     #$01
        STA     $00F9,X
        TXA                     ; INDEX TO OTHER
        EOR     #$02            ; SIDE
        TAX
LOS1:   SED                     ; DECREASE SCORE
        SEC                     ; BY ONE
        LDA     $00F9,X
        SBC     #$01
        STA     $00F9,X
        BEQ     FIN             ; GO TO FIN IF ZERO
WAIT:   JSR     LITE            ; WAIT FOR SWITCH
        JSR     KEYIN           ; TO BE RELEASED
        BNE     WAIT
        BEQ     RAND            ; THEN START NEW DELAY
FIN:    JSR     LITE            ; FINISHED LOOP
        CLV
        BVC     FIN             ; UNCOND. JUMP

;               XXXXX  DISPLAY SUBROUTINE XXXXX

LITE:   LDA     #$7F
        STA     SADD
        LDX     #$09            ; INIT. DIGIT ~
        LDA     $00FB
        JSR     HEX2
        LDA     $00FA           ; GET CENTER DIGITS
        JSR     CONVX           ; CONVERT NONHEX CHAR.
        JSR     CONVX           ; TWO OF THEM
        LDA     $00F9
        JSR     HEX2
        RTS

;      XXXXX HEX CHARACTER CONVERSION SUBROUTINE XXXXX

HEX2:   TAY
        LSR     A               ; SUBROUTINE TO CONVERT
        LSR     A               ; ONE WORD TO 2 HEX
        LSR     A               ; CHARACTERS
        LSR     A
        BEQ     ZBLK
        JSR     CONVD
SCNDC:  TYA                     ; SECOND CHARACTER
        AND     #$0F
        JSR     CONVD
        RTS
ZBLK:   LDA     #$80            ; BLANK LEADING   ZEROS
        STY     $00FC
        JSR     CONVX           ; CONVERT NONHEX CHAR.
        CLV
        BVC     SCNDC           ; UNCOND. JUMP
