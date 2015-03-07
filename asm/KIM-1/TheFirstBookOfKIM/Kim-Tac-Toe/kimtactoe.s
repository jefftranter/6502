        RS      = $C8
        TEMP    = $D9
        PS      = $DB
        SQST    = $BF
        SS      = $BF

        .ORG    $0100

        JMP     STIQ            ; JUMP TO START LOCATION
        NOP                     ; NOP'S
        NOP
        NOP

; ***** SUBROUTINE "LOAD BLINK" *****

        LDA     #$20            ; BLINK FLAG
        ORA     SQST,X          ; ADD IT TO THE..
        STA     SQST,X          ; INDEXED BYTE
        RTS
        NOP                     ; NOP'S
        NOP

; ***** TABLE - SEGMENTS ZZ ***

        .BYTE   $08,$08,$08,$40,$40,$40,$01,$01,$01

; ***** TABLE - ROWS *****

        .BYTE   $01,$04,$07,$01,$02,$03,$01,$03
SQ1:    .BYTE   $02,$05,$08,$04,$05,$06,$05,$05
SQ2:    .BYTE   $03,$06,$09,$07,$08,$09,$09,$07

; *** SUBROUTINE "GET PLAY" ***

GPLA:   STA     TEMP            ; SAVE THE ACCUMULATOR
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

        LDA     SS,X
        BNE     OUT1            ; COUNT OPEN SQUARES
        INC     PS,X            ; ONLY
OUT1:   RTS

; ***** SUBROUTINE "UPDATE" *****

UPDA:   STA     SS,X            ; FLAG THE SQUARE
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
NEW:    LDA     #$00
        LDX     #$1D            ; CLEAR REGISTERS
INLP:   STA     $00B4,X
        DEX
        BNE     INLP
        LDA     #$05            ; INITALIZE ORDER OF..
        STA     $00B8           ; NON-CALCULATED PLAYS
        LDY     #$04            ; CENTER - FIXED ORDER
ELP1:   JSR     RPLA
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
OLP1:   JSR     RPLA
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
WNLP:   CMP     ROWS,Y          ; 03=PLAYER WIN/OCZKIM WIN
        BEQ     WIN             ; GAME WON-BLINK ThE ROW
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
TURN:   INC     PLA4            ; COUNT THE PLAYS
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


   02C8   Co   Ol         cry   #$01   1ST PLAY?
   O2CA   DO   01+         BNE   FOUR   NO
   O2CC   29   Ol         AND   #$oi   YES
   020E   Do   17         BNE   TPLA   1/2 TIME PLAY A CORNER
   0200   CO   01+      FOUR   OPY   #$04   4Th PLAY?
   0202   DC   OS         BNE   SPLA   NO, SKIP
   0204   21+   C4         BIT   SQST+5   YES, CK WHO HAS CENTER
   0206   30   OD         B~!   DUMB   KIM - PLAY A SIDE
   0208   70   07         BVS   PLAC   PLAYER-PLAY A CORNER
   O2DA   A9   02      SPLA   LDA   #$02   CAN PLAYER MAKE A.
   O2DC   20   30   Ol      JSR   GETPLA   SQUEEZE PLAY?
   O2DF   DO   11         BNE   PLAY   YES - BLOCK IT
   02E1   AO   OS      PLAC   LDY   C$0S
   02E3   DO   02         BNE   TPLA   START WITH ThE CENTER
   02E5   AO   OS      DUMB   LOY   ~$09   START WITH ThE SIDES
   02E7   85   85      TPLA   LOX   RPLA,Y   USE ThE RANDOM PLAY
   02E9   85   8ff         LDA   DISP,X   TABLE - OPEN SQUARE?
   O2EB   FO   05         BEQ   PLAY   FOUND ONE - PLAY IT
   0250   88            DEY      NO, TRY NEXT ONE
   O2EE   Do   ff7         BNE   RPLA   NOT YET
   02F0   FO   F3         BEQ   DUMB   START OVER
   02ff2   AS   80      PLAY   LDA   ~$80   MARK ThE..
   02F1+   20   47   Ol      JSR   UPDATE   SQUARE FOR KIM
   02F7   CS   OB         DEC   MODE   PLAYER'S TURN NEXT
   02F9   AS   OC         LDA   #$oc   FIRST, DID KIM WIN?
   O2FB   1+C   39   02      JMP   TEST
   02FE   AS   DB      MTST   LDA   MODE   WHO WON?
   0300   Do   01+         BNE   IQUP   PLAYER, UP KIM'S 1.9.
   0302   CS   D2      IQON   DEC   19   KIM'S TOO SMART
   0304   10   OF         BPL   DONE   LOWER THE 1.9.
   0306   ES   D2      IQUP   INC   19   NOT BELOW ZERO
   0308   AS   10         LDA   #tSio   NOT OVER 10 HEX
   030A   CS   D2         CMP   19
   030C   90   ff4         BCC   IQEN
   030E   80   Os      BCS DONE
   0310   AS   OC      STIQ   LDA   #$OC   START WITH 75%
   0312   85   D2      IQST   STA   19   1.9.
   0314   D8            CLO
   0315   20   AS   03   DONE   JSR   KEYS   DISPLAY RESULTS-GET KEY
   0318   AO   Ol         LOY   '$oi   START WITH KIM
   031A   C9   13         CMP   *$13   IF ~ KEY PRESSED
   031C   FO   28         859   SEMO
   031E   88            DEY      START WJTH PLAYER..
   031F   CS   12         CMP   tt$12   IF "+" KEY PRESSED
   0321   FO   23         BEQ   SEMO
   0323   CS   11+         CMP   jt$i4   "PC" PRESSED - SKIP
   0325   Do   EE         BNE   DONE   NO KEY - LOOP
   0327   A9   OD      CHIQ   LDA   #$oo
   0329   85   ff8         STA   POINTh   SHOW "ODDS"
   0328   AS   OS         LDA   ~$D5
   0320   85   ffA         STA   POINTL
   032ff   AS   D2         LDA   œ9   AND I.Q.
   0331   85   ff9         STA   INH
   0333   20   iF   1ff      JSR   SCANDS   ON DISPLAY
   0336   20   40   1ff      JSR   KEYPR
   0339   20   SA   1ff      JSR   GETKEY



   033C     CS   11      ~   #$ii   'e!w' KEY PRESSED
   033E     FO   DS      SEQ   DOtE   RE~ TO 'IDONE~w LOOP
   0340     86   ES      BCS   CHJQ   KEEP TRYING IF OVER SIADIt
   0342     85   D2      STA   IQ   LIER uCHEX), CHANGE
   0344     SO   El      SCC   CHIQ   [Q TO KEY ~, NO KEY AGAIN
   0346     84   DO      SEMO      STY   K)DE   SET STARTING PLAY
   0348     4C   GO   02   JMP   NEW   ANOThER GAME
   0348     LA         NOP
                  SUBROUTINE 11DrSPLAY"
   034C     AS   7F      DISPLAY    LDA   ~$7F
   034E     80   41   17   STA   PADO   OPEN DISPLAY CHANELS
   0351     EG   DA      INC   RATE
   0353     AD   OG      LDY   #$oo
   0355     A2   GB      DIGX      LOX   tiSOB   INDEX DIGIT
   0357   B9 CO OC  SEGY   LDA SQST,Y   GET CONTROL BYTE
   035A   85 FC      STA SAVE   SAVE IT
   035C   FO 14      SEQ OFF   OPEN SQUARE
   035E   29   20   AND *$20   BLINK FLAG
   0360   FO G4      SEQ FLIC   NOT ON - SKIP BLINK
   0362   24 DA      SIT RATE
   0364   70 OC   BVS OFF   ALTERNATE ON-OFF
   0366   AS FC   FLIC   LDA SAVE
   0368   29   40   AND tt$40   STEADY FLAG
C36A   DO CA   BNE ON   ON - SKIP FLICKER
   036C   AS DA      LDA RATE
   036E   29 Os      AND ~$o8   FLICKER RATE
   0370   FO 04   SEQ ON   ON
0372 A9 GO   OFF   LDA #$oo   OFF
   0374   Fr) 03      SEQ DIOT
   0376   89 OF Cl  ON   LUA SEGS;Y
   0379   84 FC   DIOT   STY SAVE   SAVE FROM LOSS IN SUBR
   0376   20   4E iF   JSR CONV~6   DISPLAY A SEGMENT
   037E   Cs   INY
   037F   CO OS   cPY   ~$09   LAST SQUARE
   0381   FO 06   SEQ LAST   YES   DONE
   0383   ED 11      cpx #$i1   NO, LAST DIGIT?
   0385   FO CE   SNE DIGX   YES   REPEAT DIGITS
   0387   DO CE      SNE SEGY   NO - NEXT DIGIT
   0389   60   LAST   RTS
SUBROUTINE "RS ADD"
   038A   55 EF   RSA   LDA SQST,x
G38C   85 OS   STA TEMP
   038E   24 D9      BIT TEMP   WHO'S SQUARE?
   0390   30   0œ   BMr KIM   KrM'S
   0392   70 OS      BVS PLYR   PLAYER'S
   0394   AS On   OPEN   LDA #$oo   OPEN SQUARE VALUE
   0396   FO 0œ      SEQ ADD
   0398   AS 04   KIM   LDA tt$04   KIM VALUE
   039A   DO 02      SNE ADD
   035C   AS Ol   PLYR   LDA ~$O1   PLAYER VALUE
   039E   18   ADD   CLC
   03SF   79 CB OG      ADC RS,Y   ADD TO ROW STATUS
   03A2   99 CS CO   STA RS,Y   BYTE
   03A5   60      RTS



'cc "'C 'C SUBROUTINE ttKEYSII
   03A6   20   4C   OS   BACK   JSR   DISPLAY   DISPLAY LOOP
   03A9   20   40   iF      JSR   ANYK   UNLESS
   OSAC   FO   ES         BEQ   BACK   A KEY IS PRESSED
   03AE   20   GA   iF      JSR   KEYS   THEN GET A NUMBER
   0381   AA            TAX      RECOVER THE FLAGS
   0382   60            RTS
                SUBROUTINE "RANDOM"
   0383   D8            CLO
   0384   38            SEC      GENERATES A..
   0385   AS   01%         LDA   R+1   RANDOM NUMBER
   0387   65   D7         AX   R+4   (THANKS TO J. BUTTERFIELD)
   0389   65   DS         AX   R+5
   0385   85   US         STA   R
   OSED   A2   01%         LUX    $04
   O3BF   BS   DS      ROLL   LDA   R,X
   o3C1   95   01%         STA   R+1,X
   03C3   CA            DEX
   OSC4   10   ES         BPL   ROLL
   03C6   60            RTS
   03C7   EA            NOP
                    SUBROUTINE "PS LOAD"
03C8   85   D9      PSL   STA TEMP
OSCA   A2   09         LUX "$09
OSCC   16   DB      XLP   ASL PS,X        SHIFT PREVIOUS DATA
OSCE   16   DB         ASL PS,X        OUT OF THE WAY
03D0   CA            DEX
OSUl   DO   ff9         BNE XLP
03D3   AO   OS         LDY  $05
   03D5  AS   DS   YLP   LDA TEMP
   03D7  US   CS   O0   CMP RS,Y   COUNT THE TIMES AN OPEN..
O3DA  DO   12      BNE NOCT   SQUARE FITS ThE..
OSOC  BE   17   Ol   LUX SQ1,Y   TEST PARAMETER
OSUE  20   40   Ol   JSR T+1
03E2  BE lF Ol   LOX 5Q2,Y
OSES  20   40 Ol   JSR T+1
OSES  BE 27 Ol   LOX 5Q3,Y
O3EB  20   40 Ol   JSR T+1
O3EE  88   NOCT   DEY
OSEF  DO E4   BNE YLP
   03F1   60   RTS

; SUBROUTINE "RANDOM PLAYS"

   03F2   20   83   03  RPLA   JSR RAND   GET RANDOM NUMBER
OSES  29   OE   AND '-"$OE   0 - E (EVEN)
   03F7  Os   86   eRA ODEV   MAKE IT ODD IF Ol
   03F9  FO   F7   BEQ RPLA   NO ZEROS
OSEB  CS   OA   CMP x$OA
O3FD  80   F3   sCS RPLA   LOOP TILL DONE
   03FF   60   RTS

 ZERO   PAGE USAGE
    0056      ODD/EVEN         MODIEJER
    OGCO-C8      PRESTORED RANDOM PLAYS
    GOCS-DO      ROWS STATUS
    0001      DELAY   TIMER
    0002      I.Q.
    00D3-D5      RANDOM NUMBER REGISTERS
    00D9      TEMPORARY         STORAGE
    OODA      FLICKER I BLINK         RATE
    00DB      PLAY MODE
    00DC-E4      PLAY STATUS
    OOffC      SAVE
