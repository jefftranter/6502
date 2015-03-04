START   = $1C4F

        .ORG    $0000

INIT:   LDX     #$06            ; CLEAR DISPLAY
        LDY     #$00            ; (8C-91)=0
INIT1:  STY     $008B,X
        DEX
        BNE     INIT1
        CLD
        LDX     #$34            ; FILL DECK
        STX     $0092           ; STORE CARDS LEFT (52)
        INY                     ; (93-C6)=1
INIT2:  STY     $0092,X
        DEX
        BNE     INIT2
NEWCRD: LDA     $0092           ; DECK FINISHED?
        BNE     RANDOM
        JMP     START           ; YES, STOP
RANDOM: LDA     $1704           ; GET RANDOM # (1-FF)
        BNE     FASTER
        LDA     $1744
        BNE     FASTER
        LDA     $0092           ; BOTH CLOCKS OUT OF RANGE
        LSR                     ; # APPROX. MIDDECK
        CLC
        ADC     #$01
FASTER: CMP     $0092           ; GET NUMBER 1-34
        BCC     FIND
        BEQ     FIND
        SBC     $0092
        JMP     FASTER
FIND:   LDX     #$33            ; FIND THE CARD
FIND1:  SEC                     ; KEEP SUBTRACTING CARD
        SBC     $0093,X         ; CARD=0 MEANS PICKED
        BEQ     UPDATE          ; CARD=1 MEANS IN DECK
        DEX                     ; X=CARD POSITION
        BPL     FIND1
UPDATE: STA     $0093,X         ; CARD=0
        DEC     $0092           ; 1 LESS CARD LEFT
        TXA                     ; GET FIRST 6 BITS OF X
        LSR                     ; Y=(0-C)
        LSR
        TAY
        LDA     $007B,Y         ; GET VALUE FROM VALTBL
        STA     $0090           ; STORE AS 5TH DISPLAY DIGIT
        TXA                     ; GET LAST 2 BITS OF X
        AND     #$03            ; Y=(0-3)
        TAY
        LDA     $0088,Y         ; GET SUIT FROM SUITBL
        STA     $0091           ; STORE AS 6TH DISP. DIGIT
KDOWN:  JSR     DISP            ; DISPLAY (8C-91)
        BNE     KDOWN           ; UNTIL KEY UP
KUP:    JSR     DISP            ; DISPLAY (8C-91)
        BNE     NEWCRD          ; UNTIL KEY DOWN
        BEQ     KUP
DISP:   LDA     #$7F            ; SEGMENTS TO OUTPUT
        STA     $1741
        LDY     #$00            ; INITIALIZE
        LDX     #$08
DISP1:  LDA     $008C,Y         ; GET CHARACTER
        STY     $00FC
        JSR     $1F4E           ; DISPLAY CHARACTER
        INY                     ; NEXT CHARACTER
        CPY     #$06 
        BCC     DISP1
        JMP     $1F3D           ; DONE, KEY DOWN?
            
; XXXXXX TABLES XXXXX

VALTBL:
        .BYTE   $77             ; "A"
        .BYTE   $5B             ; "2"
        .BYTE   $4F             ; "3"
        .BYTE   $66             ; "4"
        .BYTE   $6D             ; "5"
        .BYTE   $7D             ; "6"
        .BYTE   $07             ; "7"
        .BYTE   $7F             ; "8"
        .BYTE   $6F             ; "9"
        .BYTE   $78             ; "T"
        .BYTE   $1E             ; "J"
        .BYTE   $67             ; "Q"
        .BYTE   $70             ; "K"

SUITBL:
        .BYTE   $6D             ; "S"
        .BYTE   $76             ; "H"
        .BYTE   $5E             ; "D"
        .BYTE   $39             ; "C"
