        PADD    = $1741
        INIT1   = $1E8C
        GETKEY  = $1F6A

; ***** Messages *****

        .ORG    $0000

        .BYTE   $80,$EE,$DC,$BE,$80,$F7,$D0,$F9,$80,$84,$D4,$80,$EF,$80,$C0,$80
        .BYTE   $F8,$BE,$D4,$D4,$F9,$B8,$ED,$80,$B8,$F9,$F7,$DE,$80,$F8,$DC,$80
        .BYTE   $FD,$FF,$F7,$B9,$80,$00,$80,$DC,$DC,$F3,$ED,$80,$C0,$80,$FC,$BE
        .BYTE   $B7,$F3,$F9,$DE,$80,$F7,$80,$9C,$BE,$B7,$F3,$BE,$ED,$80,$80,$00

        .RES    16

; ***** Next Room List *****

        .BYTE   $02,$02,$00,$01,$01,$00,$03,$04,$00,$06,$07,$00,$09,$0A,$01,$04
        .BYTE   $05,$03,$01,$02,$03,$02,$05,$06,$05,$08,$09,$08,$0B,$0C,$0B,$07
        .BYTE   $08,$04,$03,$04,$07,$06,$07,$0A,$09,$0A,$0F,$0C,$0D,$0E,$0C,$0A
        .BYTE   $0B,$0E,$05,$06,$0F,$08,$09,$0F,$0B,$0C,$0D,$0E,$0E,$0F,$0D,$0D


; ***** Messages *****

        .BYTE   $80,$B7,$84,$ED,$ED,$F9,$DE,$80,$C0,$80,$DC,$D4,$B8,$EE,$80,$DB
        .BYTE   $80,$B9,$F7,$D4,$ED,$80,$B8,$F9,$F1,$F8,$80,$00,$80,$EE,$DC,$BE
        .BYTE   $80,$B8,$DC,$ED,$F9,$80,$00,$80,$D0,$DC,$DC,$B7,$D3,$80,$00,$03

        .RES    64

        .BYTE   $80,$9C,$BE,$B7,$F3,$BE,$ED,$80,$B9,$B8,$DC,$ED,$F9,$00,$80,$F3
        .BYTE   $84,$F8,$80,$B9,$B8,$DC,$ED,$F9,$00,$80,$FC,$F7,$F8,$ED,$80,$B9
        .BYTE   $B8,$DC,$ED,$F9,$80,$00,$80,$F6,$F7,$80,$F6,$F7,$80,$9C,$BE,$B7
        .BYTE   $F3,$BE,$ED,$80,$BD,$DC,$F8,$80,$EE,$DC,$BE,$80,$00,$80,$ED,$BE
        .BYTE   $F3,$F9,$D0,$FC,$F7,$F8,$80,$ED,$D4,$F7,$F8,$B9,$F6,$80,$00,$80
        .BYTE   $EE,$EE,$84,$84,$F9,$F9,$F9,$80,$F1,$F9,$B8,$B8,$80,$84,$D4,$80
        .BYTE   $F3,$84,$F8,$80,$00,$80,$BD,$F7,$ED,$80,$84,$D4,$80,$D0,$DC,$DC
        .BYTE   $B7,$80,$00,$80,$DC,$BE,$F8,$80,$DC,$F1,$80,$BD,$F7,$ED,$80,$00
        .BYTE   $80,$80,$80,$80,$80,$BD,$D0,$F9,$F7,$F8,$C0,$80,$EE,$DC,$BE,$80
        .BYTE   $BD,$F9,$F8,$80,$F7,$80,$F6,$BE,$BD,$80,$F1,$D0,$DC,$B7,$80,$9C
        .BYTE   $BE,$B7,$F3,$BE,$ED,$80,$00

        .RES    89

        .ORG    $0200

SCAN:   STY     $00DE           ; TRANSFER POINTER HIGH
        STA     $00DD           ; TRANSFER POINTER LOW
        LDA     #$07            ; INIT. SCAN FORWARD
        STA     $00DF
        LDY     #$05            ; INIT Y
CONT:   LDX     #$05            ; INIT X
CHAR:   LDA     ($00DD),Y       ; GET CHARACTER
        CMP     #$00            ; LAST CHARACTER?
        BNE     MORE            ; IF NOT, CONTINUE
        RTS
MORE:   STA     $00E8,X         ; STORE IT
        DEY                     ; SET UP NEXT CHARACTER
        DEX                     ; SET UP NEXT STORE LOC.
        BPL     CHAR            ; LOOP IF NOT 6TH CHAR.
        CLD                     ; BINARY MODE
        CLC                     ; PREPARE TO ADD
        TYA                     ; GET CHAR. POINTER
        ADC     $00DF           ; UPDATE FOR 6 NEW CHAR.
        STA     $00DC           ; SAVE NEW POINTER
        JSR     $0228           ; DELAY-DISPLAY
        LDY     $00DC           ; RESTORE POINTER
        JMP     CONT            ; CONTINUE REST OF MESSAGE

; **** DELAY DISPLAY SUBROUTINE ****

        LDX     #$0A            ; SET RATE (listing has 0A, binary has 03)
        STX     $00DB           ; PUT IN DECR. LOC.
TIME:   LDA     #$52            ; LOAD TIMER
        STA     $1707           ; START TIMER
LITE:   JSR     DISP            ; JUMP TO DISPLAY SUBR.
        BIT     $1707           ; TIMER DONE?
        BPL     LITE            ; IF NOT, LOOP
        DEC     $00DB           ; DECREMENT TIMER
        BNE     TIME            ; NOT FINISHED
        RTS                     ; GET 6 NEW CHAR.

; **** BASIC DISPLAY SUBROUTINE ****

DISP:   LDA     #$7F            ; CHANGE SEGMENTS..
        STA     PADD            ; TO OUTPUT
        LDY     #$00            ; INIT. RECALL INDEX
        LDX     #$09            ; INIT. DIGIT NUMBER
SIX:    LDA     $00E8,Y         ; GET CHARACTER
        STY     $00FC           ; SAVE Y
        JSR     $1F4E           ; DISPLAY CHARACTER
        INY                     ; SET UP FOR NEXT CHAR.
        CPY     #$06            ; 6 CHAR. DISPLAYED?
        BCC     SIX             ; NO
        JSR     $1F3D           ; KEY DOWN?
        RTS                     ;EXIT

; ****  DEBOUNCE SUBROUTINE ****

DEBO:   JSR     INIT1
        JSR     DISP            ; WAIT FOR PREVIOUS KEY
        BNE     DEBO            ; TO BE RELEASED
SHOW:   JSR     DISP            ; WAIT FOR NEW KEY TO
        BEQ     SHOW            ; BE DEPRESSED
        JSR     DISP            ; CHECK AGAIN AFTER
        BEQ     SHOW            ; SLIGHT DELAY
        JSR     GETKEY          ; GET A KEY
        CMP     #$15            ; A VALID KEY?
        BPL     DEBO            ; NO
        RTS

; **** RANDOM  NUMBER SUBROUTINE ****

RAND:   TXA                     ; SAVE X REGISTER
        PHA
        CLD                     ; RANDOM # ROUTINE FROM
        SEC                     ; J. BUTTERFIELD, KIM
        LDA     $0041           ; USER NOTES #1 PAGE 4
        ADC     $0044
        ADC     $0045
        STA     $0040
        LDX     #$04
NXTN:   LDA     $0040,X
        STA     $0041,X
        DEX
        BPL     NXTN
        STA     $00C0
        PLA                     ; RETURN X REGISTER
        TAX
        LDA     $00C0
        RTS
        RTS                     ; To match binary listing in book

; **** COMPARE SUBROUTINE ****

COMP:   LDX     #$04            ; COMPARE ROOM IN ACC.
HAZD:   CMP     $00CB,X         ; WITH EACH HAZARD.
        BEQ     OUT
        DEX
        BPL     HAZD            ; X ON EXIT SHOWS MATCH
OUT:    RTS

; **** MOVE WUMPUS SUBROUTINE ****

MOVE:   JSR     RAND            ; GET A RANDOM #
        AND     #$0F            ; STRIP TO HEX DIGIT
        CMP     #$04            ; CHANGE ROOMS 75%
        BMI     NOCH            ; OF THE TIME
        JSR     NEXT            ; GET ADJ. ROOMS (TO WUMPUS)
MOVE1:  LDA     $1706           ; GET RANDOM #, 0-3
        AND     #$03
        TAX                     ; USE AS INDEX
        LDA    $00C6,X          ; GET AN ADJ. ROOM
        STA    $00CB            ; PUT WUMPUS IN IT
NOCH:   LDA    $00CB            ; WUMPUS ROOM N ACC.
        RTS

; **** LOAD NEXT ROOMS SUBROUTINE ****

NEXT:   LDX    $00CA            ; YOUR ROOM AS INDEX
NEXT1:  LDA    $0050,X          ; ... NEXT ROOMS ARE LOADED
        STA    $00C6            ; INTO 00C6-00C9 FROM
        LDA    $0060,X          ; TABLES ...
        STA    $00C7
        LDA    $0070,X
        STA    $00C8
        LDA    $0080,X
        STA    $00C9
        RTS

; ***** CHECK VALID SUBROUTINE *****

VALID:  LDX    #$03              ; ... CHECK IF ACC.
NXTV:   CMP    $00C6,X           ; MATCHS 00C6-00C9 ...
        BEQ    YVAL              ; YES, VALID ROOM
        DEX
        BPL    NXTV
YVAL:   RTS

; **** LOSE SUBROUTINE ****

LOSE:   LDY    #$01             ; ...DISPLAY REASON LOST,
        JSR    SCAN             ; THEN "YOU LOSE" ...
REPT:   LDY    #$00
        LDA    #$AC
        JSR    SCAN
        JMP    REPT

; **** GAS LEFT MESSAGE ****

        LDY    $00E0            ; GET CANS LEFT
        LDA    $1FE7,Y          ; GET CONVERSION
        STA    $009F            ; STORE IN MESSAGE
        LDY    #$00             ; (PAGE ZERO)
        LDA    #$90             ; DISPLAY CANS OF GAS
        JSR    SCAN             ; LEFT MESSAGE
        JMP    ADJR

        .RES   17
        .ORG   $0300

        NOP
        NOP
        NOP
        NOP
        NOP
        LDA    #$FF             ; ...INITIALIZATION...
        LDX    #$0E             ; ..CLEAN OUT ROOMS..
INIT:   STA    $00C1,X          ; INIT. TO FF
        DEX                     ; FINISHED?
        BPL    INIT             ; No
        LDA    #$03             ; GIVE THREE CANS OF GAS
        STA    $00E0
        LDY    #$05             ; ...RANDOMIZE...
        BPL    GETN             ; YOU,WUMPUS,PITS AND BATS
CHNG:   LDY    #$00             ; (ONLY YOU ENTRY)
GETN:   LDX    #$05
        JSR    RAND
        AND    #$0F
CKNO:   CMP    $00CA,X          ; ..MAKING SURE ALL
        BEQ    GETN             ; ARE DIFFERENT..
        DEX
        BPL    CKNO
        STA    $00CA,Y         ; STORE IN 00CA-00CF
        DEY
        BPL    GETN
ADJR:   JSR    NEXT             ; SET UP ADJACENT ROOM LIST
        LDY    #$03             ; HAZARDS IN ADJ. ROOMS?
        STY    $00E1
NXTR:   LDA    $00C6,Y
        JSR    COMP             ; COMPARE EACH TO HAZARDS
        TXA                     ; (X CONTAINS MATCH INFO.)
        BMI    NOMA             ; NO MATCH, NO HAZARDS
        CPX    #$03             ; BATS?
        BMI    SKP1             ; NO
        LDA    #$19             ; (BATS NEARBY MESSAGE)
        BPL    MESS
SKP1:   CPX    #$01             ; PIT?
        BMI    SKP2             ; NO
        LDA    #$0E             ; (PIT CLOSE MESSAGE)
        BPL    MESS
SKP2:   LDA    #$00             ; MUST BE WUMPUS
MESS:   LDY    #$01             ; (PAGE ONE)
        JSR    SCAN             ; DISPLAY HAZARD MESSAGE
NOMA:   DEC    $00E1            ; TRY NEXT ADJ. ROOM
        LDY    $00E1            ; FINISHED?
        BPL    NXTR             ; NO
        LDY    $00CA            ; LOAD AND DISPLAY -
        LDA    $1FE7,Y          ; "YOU ARE IN ... TUNNELS"
        STA    $000C            ; LEAD TO ...." MESSAGE..
        LDX    #$03             ; (FOUR NEXT ROOMS)
XRO:    LDY    $00C6,X
        LDA    $1FE7,Y          ; CONVERSION
        STA    $0020,X          ; PUT IN MESSAGE
        DEX                     ; FINISHED?
        BPL    XRO              ; NO
ROOM:   LDY    #$00             ; LOCATION AND..
        TYA                     ; PAGE OF MESSAGE
        JSR    SCAN             ; DISPLAY MESSAGE
        JSR    DEBO             ; DEBOUNCE KEY
        CMP    #$14             ; PC PUSHED?
        BEQ    ROOM1            ; YES
        JSR    VALID            ; AN ADJACENT ROOM?
        STA    $00CA            ; UPDATE YOUR ROOM
        TXA
        BMI    ROOM             ; IF X=FF, NOT VALID ROOM
        LDA    $00CA            ; CHECK FOR GAS IN ROOM
        LDX    #$04             ; 5 POSSIBLE (EXPANSION)
NXTG:   CMP    $00C1,X
        BEQ    GASM             ; GASSED!!
        DEX                     ; ALL CHECKED?
        BPL    NXTG             ; NO
        JSR    COMP             ; CHECK YOUR NEW
        TXA                     ; ROOM FOR HAZARDS.
        BMI    ADJR             ; NO MATCH, NO HAZARDS
        CPX    #$03
        BPL    BATM             ; BATS
        CPX    #$01
        BPL    PITM             ; PIT!!!
        LDY    #$00
        LDA    #$26             ; MUST HAVE BUMPED WUMPUS
        JSR    SCAN             ; DISPLAY MESSAGE
        JSR    MOVE             ; ..SEE IF HE MOVES..
        CMP    $00CA            ; STILL IN YOUR ROOM?
        BNE    ADJR             ; NO, YOU'RE O.K.
        LDA    #$26             ; HE GOT YOU!
        JMP    LOSE
BATM:   LDY    #01              ; BAT MESSAGE
        LDA    #$3D
        JSR    SCAN
        JMP    CHNG             ; CHANGE YOUR ROOM
PITM:   LDA    #$4F             ; FELL IN PIT!
        JMP    LOSE
GASM:   LDA    #$65             ; GAS IN ROOM!
        JMP    LOSE
ROOM1:  LDY    #$00             ; PITCH CAN AND SEE..
        LDA    #$B7             ; IF YOU GET HIM
        JSR    SCAN             ; ROOM?
        JSR    DEBO
        JSR    VALID            ; VALID ROOM?
        STA    $00D1
        TXA
        BMI    ROOM1            ; IF X=FF, NOT VALID
        LDA    $00D1
        LDX    $00E0            ; CANS OF GAS LEFT
        STA    $00C0,X          ; ..IS WUMPUS IN
        CMP    $00CB            ; ROOM GASSED?
        BEQ    WIN              ; YES, YOU GOT HIM
        DEC    $00E0            ; DECREASE CAN COUNT
        BEQ    OUT1             ; GAS IS GONE
        LDX    $00CB            ; MOVE WUMPUS TO AN
        JSR    NEXT1            ; ADJACENT ROOM (FOR HIM)
        JSR    MOVE1
        CMP    $00CA            ; DID HE MOVE INTO YOUR ROOM?
        BEQ    $03A8            ; YES
        JMP    $02DE            ; DISPLAY CANS LEFT MESSAGE
        NOP
        NOP
WIN:    LDY    #$01             ; GREAT& ETC. MESSAGE
        LDA    #$80
        JSR    SCAN
        BEQ    WIN              ; REPEAT
OUT1:   LDA    #$73             ; OUT OF GAS!
        JMP LOSE
