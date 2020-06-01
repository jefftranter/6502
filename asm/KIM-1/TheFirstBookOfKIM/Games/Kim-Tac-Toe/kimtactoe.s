; ***** ZERO PAGE USAGE *****

        PLAC    = $B5
        ODEV    = $B6
        RPLA    = $B6
        RODD    = $B6
        REVN    = $BB
        DSPL    = $BF
        DISP    = $BF
        ROWS    = $C8           ; CO-C8 PRESTORED RANDOM PLAYS
        RS      = $C8           ; CO-C8 PRESTORED RANDOM PLAYS
        LPCNT   = $D1           ; DELAY TIMER
        IQ      = $D2           ; I.Q.
        R       = $D3           ; RANDOM NUMBER REGISTERS
        TEMP    = $D9           ; TEMPORARY STORAGE
        RATE    = $DA           ; FLICKER / BLINK RATE
        MODE    = $DB           ; PLAY MODE
        PS      = $DB
        SS      = $BF
        SQST    = $BF
        INH     = $F9
        POINTL  = $FA
        POINTH  = $FB
        SAVE    = $FC           ; SAVE

        PADD    = $1741
        SCANDS  = $1F1F
        KEYPR   = $1F40
        ANYK    = $1F40
        CONVD   = $1F48
        GETKEY  = $1F6A

        .ORG    $0100

        JMP     STIQ            ; JUMP TO START LOCATION
        NOP                     ; NOP'S
        NOP
        NOP

; ***** SUBROUTINE "LOAD BLINK" *****

BLNK:   LDA     #$20            ; BLINK FLAG
        ORA     SQST,X          ; ADD IT TO THE..
        STA     SQST,X          ; INDEXED BYTE
        RTS
        NOP                     ; NOP'S
        NOP

; ***** TABLE - SEGMENTS ZZ***

SEGS:   .BYTE   $08,$08,$08,$40,$40,$40,$01,$01
SQ1:    .BYTE   $01

; ***** TABLE - ROWS *****

        .BYTE   $01,$04,$07,$01,$02,$03,$01
SQ2:    .BYTE   $03
        .BYTE   $02,$05,$08,$04,$05,$06,$05
SQ3:    .BYTE   $05
        .BYTE   $03,$06,$09,$07,$08,$09,$09,$07

; *** SUBROUTINE "GET PLAY" ***

GETPLA: STA     TEMP            ; SAVE THE ACCUMULATOR
        LDX     #$09            ; FOR TESTING
GPLP:   LDA     TEMP            ; GET IT BACK
        AND     PS,X            ; MASK THE STATUS BYTE
        BIT     TEMP            ; CHECK FOR BIT ON
        BNE     OUT             ; GOT IT - DONE
        DEX
        BNE     GPLP            ; NOPE - KEEP TRYING
OUT:    RTS                     ; SQUARE VALUE IN X
                                ; 0 = NO MATCH

; ***** SUBROUTINE "TEST AND INCREMENT" *****

TANDI:  LDA     SS,X
        BNE     OUT1            ; COUNT OPEN SQUARES
        INC     PS,X            ; ONLY
OUT1:   RTS

; ***** SUBROUTINE "UPDATE" *****

UPDATE: STA     SS,X            ; FLAG THE SQUARE
        LDY     #$08
UPLP:   LDA     #$00            ; CLEAR THE REGISTER
        STA     RS,Y
        LDX     SQ1,Y           ; THEN LOAD
        JSR     RSADD           ; CURRENT STATUS
        LDX     SQ2,Y           ; VALUES
        JSR     RSADD
        LDX     SQ3,Y
        JSR     RSADD
        DEY
        BNE     UPLP            ; LOOP TILL DONE
        RTS

        .RES    154
        .ORG    $0200

NEW:    LDA     #$00
        LDX     #$1D            ; CLEAR REGISTERS
INLP:   STA     $00B4,X
        DEX
        BNE     INLP
        LDA     #$05            ; INITALIZE ORDER OF..
        STA     $00BB           ; NON-CALCULATED PLAYS
        LDY     #$04            ; CENTER - FIXED ORDER
ELP1:   JSR     RPLAY
        LDX     #$04
ELP2:   CMP     REVN,X
        BEQ     ELP1
        DEX
        BNE     ELP2
        STA     REVN,Y          ; SIDES IN RANDOM ORDER
        DEY
        BNE     ELP1
        INC     ODEV
        LDY     #$04
OLP1:   JSR     RPLAY
        LDX     #$05
OLP2:   CMP     RODD,X
        BEQ     OLP1
        DEX
        BNE     OLP2
        STA     RODD,Y          ; CORNERS-IN RANDOM ORDER
        DEY
        BNE     OLP1
PVAL:   LDA     #$03
TEST:   LDY     #$08            ; TEST FOR 3 IN A ROW
WNLP:   CMP     ROWS,Y          ; 03=PLAYER WIN/OC=KIM WIN
        BEQ     WIN             ; GAME WON-BLINK THE ROW
        DEY
        BNE     WNLP            ; NOT YET-CK NEXT ROW
        BEQ     DRAW            ; NO WINNER-CK FOR DRAW
WIN:    LDX     SQ1,Y
        JSR     BLNK            ; BLINK #1
        LDX     SQ2,Y
        JSR     BLNK            ; BLINK #2
        LDX     SQ3,Y
        JSR     BLNK            ; BLINK #3
        JMP     MTST            ; CHECK THE WINNER
DRAW:   LDX     #$09
OPEN:   LDA     #$C0            ; OPEN SQUARE?
        AND     DSPL,X
        BEQ     TURN            ; YES - CONTINUE GAME
        DEX                     ; NO - CK NEXT SQUARE
        BNE     OPEN            ; ALL DONE?
        LDX     #$09
NXBL:   JSR     BLNK            ; NO OPEN SQUARES
        DEX                     ; 1T'S A DRAW
        BNE     NXBL            ; SLINK 'EM ALL
        JMP     DONE            ; GAME'S OVER
TURN:   INC     PLAC            ; COUNT THE PLAYS
        LDA     MODE            ; WHO'S TURN?
        BNE     WAIT            ; KIM'S
KEY:    JSR     KEYS            ; PLAYER'S
        BEQ     KEY             ; GET A KEY
        CMP     #$0A            ; OVER 9?
        BCS     KEY             ; GET ANOTHER
        TAX                     ; USE IT AS AN INDEX
        LDY     DSPL,X          ; SEE IF SQUARE'S OPEN
        BNE     KEY             ; NO, TRY AGAIN
        LDA     #$40            ; YES, MARK IT FOR..
        JSR     UPDATE          ; PLAYER
        INC     MODE            ; KIM'S NEXT
        BNE     PVAL            ; BUT FIRST CK FOR WIN
WAIT:   JSR     DISPLAY         ; HOLD KIM BACK
        INC     LPCNT           ; A LITTLE
        BNE     WAIT            ; UPDATE AND..
        LDA     #$08            ; THEN CHECK THE..
        JSR     PSLD            ; BOARD
        LDA     #$02
        JSR     PSLD
        LDA     #$04
        JSR     PSLD
        LDA     #$01
        JSR     PSLD
        LDA     #$C0            ; WINNING PLAY FOR KIM
        JSR     GETPLA
        BNE     PLAY            ; YES - MAKE IT
        LDA     #$30            ; 2 IN A ROW FOR..
        JSR     GETPLA          ; PLAYER
        BNE     PLAY            ; YES - BLOCK IT
        LDA     #$08            ; POSSIBLE SQUEEZE
        JSR     GETPLA          ; PLAY FOR KIM
        BNE     PLAY            ; YES - DO IT
IPLA:   JSR     RAND            ; HOW MUCH SMARTS?
        AND     #$0F            ; NEEDED?
        CMP     IQ              ; KIM'S I.Q.
        BCS     DUMB            ; TOO LOW - BAD MOVES
        LDY     PLAC            ; SMART
        CPY     #$01            ; 1ST PLAY?
        BNE     FOUR            ; NO
        AND     #$01            ; YES
        BNE     TPLA            ; 1/2 TIME PLAY A CORNER
FOUR:   CPY     #$04            ; 4TH PLAY?
        BNE     SPLA            ; NO, SKIP
        BIT     SQST+5          ; YES, CK WHO HAS CENTER
        BMI     DUMB            ; KIM - PLAY A SIDE
        BVS     PLAC1           ; PLAYER-PLAY A CORNER
SPLA:   LDA     #$02            ; CAN PLAYER MAKE A.
        JSR     GETPLA          ; SQUEEZE PLAY?
        BNE     PLAY            ; YES - BLOCK IT
PLAC1:  LDY     #$05
        BNE     TPLA            ; START WITH THE CENTER
DUMB:   LDY     #$09            ; START WITH THE SIDES
TPLA:   LDX     RPLA,Y          ; USE THE RANDOM PLAY
        LDA     DISP,X          ; TABLE - OPEN SQUARE?
        BEQ     PLAY            ; FOUND ONE - PLAY IT
        DEY                     ; NO, TRY NEXT ONE
        BNE     TPLA            ; NOT YET
        BEQ     DUMB            ; START OVER
PLAY:   LDA     #$80            ; MARK THE..
        JSR     UPDATE          ; SQUARE FOR KIM
        DEC     MODE            ; PLAYER'S TURN NEXT
        LDA     #$0C            ; FIRST, DID KIM WIN?
        JMP     TEST
MTST:   LDA     MODE            ; WHO WON?
        BNE     IQUP            ; PLAYER, UP KIM'S 1.9.
IQDN:   DEC     IQ              ; KIM'S TOO SMART
        BPL     DONE            ; LOWER THE I.Q.
IQUP:   INC     IQ              ; NOT BELOW ZERO
        LDA     #$10            ; NOT OVER 10 HEX
        CMP     IQ
        BCC     IQDN
        BCS     DONE
STIQ:   LDA     #$0C            ; START WITH 75%
IQST:   STA     IQ              ; I.Q.
        CLD
DONE:   JSR     KEYS            ; DISPLAY RESULTS-GET KEY
        LDY     #$01            ; START WITH KIM
        CMP     #$13            ; IF "GO" KEY PRESSED
        BEQ     SEMO
        DEY                     ; START WITH PLAYER..
        CMP     #$12            ; IF "+" KEY PRESSED
        BEQ     SEMO
        CMP     #$14            ; "PC" PRESSED - SKIP
        BNE     DONE            ; NO KEY - LOOP
CHIQ:   LDA     #$0D
        STA     POINTH          ; SHOW "ODDS"
        LDA     #$D5
        STA     POINTL
        LDA     IQ              ; AND I.Q.
        STA     INH
        JSR     SCANDS          ; ON DISPLAY
        JSR     KEYPR
        JSR     GETKEY
        CMP     #$11            ; "DA" KEY PRESSED
        BEQ     DONE            ; RETURN TO "DONE" LOOP
        BCS     CHIQ            ; KEEP TRYING IF OVER "AD"
        STA     IQ              ; UNER 11(HEX), CHANGE
        BCC     CHIQ            ; IQ TO KEY #, NO KEY AGAIN
SEMO:   STY     MODE            ; SET STARTING PLAY
        JMP     NEW             ; ANOTHER GAME
        NOP

; ***** SUBROUTINE "DISPLAY" *****

DISPLAY: LDA    #$7F
        STA     PADD            ; OPEN DISPLAY CHANELS
        INC     RATE
        LDY     #$00
DIGX:   LDX     #$0B            ; INDEX DIGIT
SEGY:   LDA     SQST+1,Y        ; GET CONTROL BYTE
        STA     SAVE            ; SAVE IT
        BEQ     OFF             ; OPEN SQUARE
        AND     #$20            ; BLINK FLAG
        BEQ     FLIC            ; NOT ON - SKIP BLINK
        BIT     RATE
        BVS     OFF             ; ALTERNATE ON-OFF
FLIC:   LDA     SAVE
        AND     #$40            ; STEADY FLAG
        BNE     ON              ; ON - SKIP FLICKER
        LDA     RATE
        AND     #$08            ; FLICKER RATE
        BEQ     ON              ; ON
OFF:    LDA     #$00            ; OFF
        BEQ     DIGT
ON:     LDA     SEGS,Y
DIGT:   STY     SAVE            ; SAVE FROM LOSS IN SUBR
        JSR     CONVD+6         ; DISPLAY A SEGMENT
        INY
        CPY     #$09            ; LAST SQUARE
        BEQ     LAST            ; YES - DONE
        CPX     #$11            ; NO, LAST DIGIT?
        BEQ     DIGX            ; YES - REPEAT DIGITS
        BNE     SEGY            ; NO - NEXT DIGIT
LAST:   RTS

; ***** SUBROUTINE "RS ADD" *****

RSADD:  LDA     SQST,X
        STA     TEMP
        BIT     TEMP            ; WHO'S SQUARE?
        BMI     KIM             ; KIM'S
        BVS     PLYR            ; PLAYER'S
        LDA     #$00            ; OPEN SQUARE VALUE
        BEQ     ADD
KIM:    LDA     #$04            ; KIM VALUE
        BNE     ADD
PLYR:   LDA     #$01            ; PLAYER VALUE
ADD:    CLC
        ADC     RS,Y            ; ADD TO ROW STATUS
        STA     RS,Y            ; BYTE
        RTS

; ***** SUBROUTINE "KEYS" *****

KEYS:
BACK:   JSR     DISPLAY         ; DISPLAY LOOP
        JSR     ANYK            ; UNLESS
        BEQ     BACK            ; A KEY IS PRESSED
        JSR     GETKEY          ; THEN GET A NUMBER
        TAX                     ; RECOVER THE FLAGS
        RTS

; ***** SUBROUTINE "RANDOM" *****

RAND:   CLD
        SEC                     ; GENERATES A..
        LDA      R+1            ; RANDOM NUMBER
        ADC      R+4            ; (THANKS TO J. BUTTERFIELD)
        ADC      R+5
        STA      R
        LDX      #$04
ROLL:   LDA      R,X
        STA      R+1,X
        DEX
        BPL      ROLL
        RTS
        NOP

; ***** SUBROUTINE "PS LOAD" *****

PSLD:   STA      TEMP
        LDX      #$09
XLP:    ASL      PS,X           ; SHIFT PREVIOUS DATA
        ASL      PS,X           ; OUT OF THE WAY
        DEX
        BNE      XLP
        LDY      #$08
YLP:    LDA      TEMP
        CMP      RS,Y           ; COUNT THE TIMES AN OPEN..
        BNE      NOCT           ; SQUARE FITS THE..
        LDX      SQ1,Y          ; TEST PARAMETER
        JSR      TANDI
        LDX      SQ2,Y
        JSR      TANDI
        LDX      SQ3,Y
        JSR      TANDI
NOCT:   DEY
        BNE YLP
        RTS

; SUBROUTINE "RANDOM PLAYS"

RPLAY:  JSR      RAND           ; GET RANDOM NUMBER
        AND      #$0E           ; 0 - E (EVEN)
        ORA      ODEV           ; MAKE IT ODD IF 01
        BEQ      RPLAY          ; NO ZEROS
        CMP      #$0A
        BCS      RPLAY          ; LOOP TILL DONE
        RTS
