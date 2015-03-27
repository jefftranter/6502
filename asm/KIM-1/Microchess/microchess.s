; © COPYRIGHT 1976, PETER JENNINGS, MICROCHESS,
; 1612-43 THORNCLIFFE PK DR, TORONTO, CANADA.
; ALL RIGHTS RESERVED.  REPRODUCTION BY   ANY
; MEANS, IN WHOLE OR IN PART, IS PROHIBITED.

        BOARD   = $50
        BK      = $60
        PIECE   = $B0
        SQUARE  = $B1
        SP2     = $B2
        SP1     = $B3
        INCHEK  = $B4
        STATE   = $B5
        MOVEN   = $B6
        OMOVE   = $DC
        WCAP0   = $DD
        COUNT   = $DE
        BCAP2   = $DE
        WCAP2   = $DF
        BCAP1   = $E0
        WCAP1   = $E1
        BCAP0   = $E2
        MOB     = $E3
        MAXC    = $E4
        CC      = $E5
        PCAP    = $E6
        BMOB    = $E3
        BMAXC   = $E4
        BBCC    = $E5
        BMAXP   = $E6
        XMAXC   = $E8
        WMOB    = $EB
        WMAXC   = $EC
        WCC     = $ED
        WMAXP   = $EE
        PMOB    = $EF
        PMAXC   = $F0
        PCC     = $F1
        PCP     = $F2
        OLDKY   = $F3
        BESTP   = $FB
        BESTV   = $FA
        BESTM   = $F9
        DIS3    = $F9
        DIS2    = $FA
        DIS1    = $FB

        SCANDS  = $1F1F
        GETKEY  = $1F6A

;       EXECUTION BEGINS AT ADDRESS 0000
;
        .ORG    $0000

CHESS:  CLD                     ; INITIALIZE
        LDX     #$FF            ; TWO STACKS
        TXS
        LDX     #$C8
        STX     SP2
;
;       ROUTINES TO LIGHT LED
;       DISPLAY AND GET KEY
;       FROM KEYBOARD.
;
OUT:    JSR     SCANDS          ; DISPLAY AND
        JSR     GETKEY          ; GET INPUT
        CMP     OLDKY           ; KEY IN ACC
        BEQ     OUT             ; (DEBOUNCE)
        STA     OLDKY
;
        CMP     #$0C            ; [C]
        BNE     NOSET           ; SET UP
        LDX     #$1F            ; BOARD
        .GLOBALZP SETW
WHSET:  LDA     SETW,X        ; FROM
        STA     BOARD,X         ; SETW
        DEX
        BPL     WHSET
        STX     OMOVE
        LDA     #$CC
        BNE     CLDSP
;
NOSET:  CMP     #$0E            ; [E]
        BNE     NOREV           ; REVERSE
        JSR     REVERSE         ; BOARD AS
        LDA     #$EE            ; IS
        BNE     CLDSP
;
NOREV:  CMP     #$14            ; [PC]
        BNE     NOGO            ; PLAY CHESS
        JSR     GO
CLDSP:  STA     DIS1            ; DISPLAY
        STA     DIS2            ; ACROSS
        STA     DIS3            ; DISPLAY
        BNE     CHESS
;
NOGO:   CMP     #$0F            ; [F]
        BNE     NOMV            ; MOVE MAN
        JSR     MOVE            ; AS ENTERED
        JMP     DISP
NOMV:   JMP     INPUT


; BLOCK DATA
        .RES    34
        .ORG    $0070

SETW:   .BYTE   $03, $04, $00, $07, $02, $05, $01, $06, $10, $17, $11, $16, $12, $15, $14, $13
        .BYTE   $73, $74, $70, $77, $72, $75, $71, $76, $60, $67, $61, $66, $62, $65, $64

MOVEX:  .BYTE   $63
        .BYTE   $F0, $FF, $01, $10, $11, $0F, $EF, $F1, $DF, $E1, $EE, $F2, $12, $0E, $1F, $21

POINTS: .BYTE   $0B, $0A, $06, $06, $04, $04, $04, $04, $02, $02, $02, $02, $02, $02, $02, $02

        .RES    16

; The data below enables the computer to play the opening specified
; from memory. The data is in a block from 00C0 to 00DB. W specifies
; that the computer will play white, B specifies  that the computer
; is black.

; Choose and uncomment one of the 10 openings below. The default is Giuoco Piano (W).

; French Defence (W)
;       .BYTE   $99, $22, $06, $45, $32, $0C, $72, $14, $01, $63, $63, $05, $64, $43, $0F, $63
;       .BYTE   $41, $05, $52, $25, $07, $44, $43, $0E, $53, $33, $0F, $CC

; French Defence (B)
;       .BYTE   $99, $22, $07, $55, $32, $0D, $45, $06, $00, $63, $14, $01, $14, $13, $06, $34
;       .BYTE   $14, $04, $36, $25, $06, $52, $33, $0E, $43, $24, $0F, $44

; Giuoco Piano (W)
        .BYTE   $99, $25, $0B, $25, $01, $00, $33, $25, $07, $36, $34, $0D, $34, $34, $0E, $52
        .BYTE   $25, $0D, $45, $35, $04, $55, $22, $06, $43, $33, $0F, $CC

; Giuoco Piano (B)
;       .BYTE   $99, $52, $04, $52, $52, $06, $75, $44, $06, $52, $41, $03, $43, $43, $0F, $43
;       .BYTE   $25, $06, $52, $32, $04, $42, $22, $07, $55, $34, $0F, $44

; Ruy Lopez (W)
;       .BYTE   $99, $25, $07, $66, $43, $0E, $55, $55, $04, $54, $13, $01, $63, $34, $0E, $33
;       .BYTE   $01, $00, $52, $46, $04, $55, $22, $06, $43, $33, $0F, $CC

; Ruy Lopez (B)
;       .BYTE   $99, $06, $00, $52, $11, $06, $34, $22, $0B, $22, $23, $06, $64, $14, $04, $43
;       .BYTE   $44, $06, $75, $25, $06, $31, $22, $07, $55, $34, $0F, $44

; Queen's Indian (W)
;       .BYTE   $99, $25, $01, $25, $15, $01, $33, $25, $07, $72, $01, $00, $63, $11, $04, $66
;       .BYTE   $21, $0A, $56, $22, $06, $53, $35, $0D, $52, $34, $0E, $CC

; Queen's Indian (B)
;       .BYTE   $99, $35, $0c, $52, $52, $06, $62, $44, $06, $52, $06, $00, $75, $14, $04, $66
;       .BYTE   $11, $05, $56, $21, $0B, $55, $24, $0F, $42, $25, $06, $43

; Four Knights (W)
;       .BYTE   $99, $03, $02, $63, $25, $0B, $25, $41, $05, $54, $24, $0E, $72, $01, $00, $36
;       .BYTE   $46, $04, $52, $25, $07, $55, $22, $06, $43, $33, $0F, $CC

; Four Knights (B)
;       .BYTE   $99, $03, $07, $74, $14, $01, $52, $52, $04, $36, $23, $0E, $53, $06, $00, $75
;       .BYTE   $41, $04, $31, $25, $06, $52, $22, $07, $55, $34, $0F, $44

OPNING:

; NOTE THAT 00B7 TO 00BF, 00F4 TO 00F8, AND 00FC TO 00FF ARE
; AVAILABLE FOR USER EXPANSION AND I/O ROUTINES.


;
;       THE ROUTINE JANUS DIRECTS THE
;       ANALYSIS BY DETERMINING WHAT
;       SHOULD OCCUR AFTER EACH MOVE
;       GENERATED BY GNM
;
;
        .RES    36
        .ORG    $0100

JANUS:   LDX    STATE
         BMI    NOCOUNT
;
;       THIS ROUTINE COUNTS OCCURRENCES
;       IT DEPENDS UPON STATE TO INDEX
;       THE CORRECT COUNTERS
;
COUNTS:  LDA    PIECE
         BEQ    OVER            ; IF STATE=8
         CPX    #$08            ; DO NOT COUNT
         BNE    OVER            ; BLK MAX CAP
         CMP    BMAXP           ; MOVES FOR
         BEQ    XRT             ; WHITE
;
OVER:    INC    MOB,X           ; MOBILITY
         CMP    #$01            ; + QUEEN
         BNE    NOQ             ; FOR TWO
         INC    MOB,X
;
NOQ:     BVC    NOCAP
         LDY    #$0F            ; CALCULATE
         LDA    SQUARE          ; POINTS
ELOOP:   CMP    BK,Y            ; CAPTURED
         BEQ    FOUN            ; BY THIS
         DEY                    ; MOVE
         BPL    ELOOP
FOUN:    LDA    POINTS,Y
         CMP    MAXC,X
         BCC    LESS            ; SAVE IF
         STY    PCAP,X          ; BEST THIS
         STA    MAXC,X          ; STATE
;
LESS:    CLC
         PHP                    ; ADD TO
         ADC    CC,X            ; CAPTURE
         STA    CC,X            ; COUNTS
         PLP
;
NOCAP:   CPX    #$04
         BEQ    ON4
         BMI    TREE            ; (=00 ONLY)
XRT:     RTS
;
;      GENERATE FURTHER MOVES FOR COUNT
;      AND ANALYSIS
;
ON4:     LDA     XMAXC          ; SAVE ACTUAL
         STA     WCAP0          ; CAPTURE
         LDA     #$00           ; STATE=0
         STA     STATE
         JSR     MOVE           ; GENERATE
         JSR     REVERSE        ; IMMEDIATE
         JSR     GNMZ           ; REPLY MOVES
         JSR     REVERSE
;
         LDA     #$08           ; STATE=8
         STA     STATE          ; GENERATE
         JSR     GNM            ; CONTINUATION
         JSR     UMOVE          ; MOVES
;
         JMP     STRATGY        ; FINAL EVALUATION
NOCOUNT: CPX     #$F9
         BNE     TREE
;
;      DETERMINE IF THE KING CAN BE
;      TAKEN, USED BY CHKCHK
;
         LDA     BK             ; IS KING
         CMP     SQUARE         ; IN CHECK?
         BNE     RETJ           ; SET INCHEK=0
         LDA     #$00           ; IF IT IS
         STA     INCHEK
RETJ:    RTS
;
;      IF A PIECE HAS BEEN CAPTURED BY 
;      A TRIAL MOVE, GENERATE REPLIES &
;      EVALUATE THE EXCHANGE GAIN/LOSS
;
TREE:    BVC     RETJ           ; NO CAP
         LDY     #$07           ; (PIECES)
         LDA     SQUARE
LOOPX:   CMP     BK,Y
         BEQ     FOUNX
         DEY
         BEQ     RETJ           ; (KING)
         BPL     LOOPX          ; SAVE
FOUNX:   LDA     POINTS,Y       ; BEST CAP
         CMP     BCAP0,X        ; AT THIS
         BCC     NOMAX          ; LEVEL
         STA     BCAP0,X
NOMAX:   DEC     STATE
         LDA     #$FB           ; IF STATE=FB
         CMP     STATE          ; TIME TO TURN
         BEQ     UPTREE         ; AROUND
         JSR     GENRM          ; GENERATE FURTHER
UPTREE:  INC     STATE          ; CAPTURES
         RTS
;
;      THE PLAYER'S MOVE IS INPUT
;
INPUT:   CMP     #$08           ; NOT A LEGAL
         BCS     ERROR          ; SQUARE #
         JSR     DISMV
DISP:    LDX     #$1F
SEARCH:  LDA     BOARD,X
         CMP     DIS2
         BEQ     HERE           ; DISPLAY
         DEX                    ; PIECE AT
         BPL     SEARCH         ; FROM
HERE:    STX     DIS1           ; SQUARE
         STX     PIECE
ERROR:   JMP     CHESS
;
;      GENERATE ALL MOVES FOR ONE
;      SIDE, CALL JANUS AFTER EACH
;      ONE FOR NEXT STEP
;
        .RES    81
        .ORG    $0200

GNMZ:    LDX     #$10           ; CLEAR
GNMX:    LDA     #$00           ; COUNTERS
CLEAR:   STA     COUNT,X
         DEX
         BPL     CLEAR
;
GNM:     LDA     #$10           ; SET UP
         STA     PIECE          ; PIECE
NEWP:    DEC     PIECE          ; NEW PIECE
         BPL     NEX            ; ALL DONE?
         RTS                    ; -YES
;
NEX:     JSR     RESET          ; READY
         LDY     PIECE          ; GET PIECE
         LDX     #$08
         STX     MOVEN          ; COMMON START
         CPY     #$08           ; WHAT IS IT?
         BPL     PAWN           ; PAWN
         CPY     #$06
         BPL     KNIGHT         ; KNIGHT
         CPY     #$04
         BPL     BISHOP         ; BISHOP
         CPY     #$01
         BEQ     QUEEN          ; QUEEN
         BPL     ROOK           ; ROOK
;
KING:    JSR     SNGMV          ; MUST BE KING!
         BNE     KING           ; MOVES
         BEQ     NEWP           ; 8 TO 1
QUEEN:   JSR     LINE
         BNE     QUEEN          ; MOVES
         BEQ     NEWP           ; 8 TO 1
;
ROOK:    LDX     #$04
         STX     MOVEN          ; MOVES
AGNR:    JSR     LINE           ; 4 TO 1
         BNE     AGNR
         BEQ     NEWP
;
BISHOP:  JSR     LINE
         LDA     MOVEN          ; MOVES
         CMP     #$04           ; 8 TO 5
         BNE     BISHOP
         BEQ     NEWP
;
KNIGHT:  LDX     #$10
         STX     MOVEN          ; MOVES
AGNN:    JSR     SNGMV          ; 16 TO 9
         LDA     MOVEN
         CMP     #$08
         BNE     AGNN
         BEQ     NEWP
;
PAWN:    LDX     #$06
         STX     MOVEN
P1:      JSR     CMOVE          ; RIGHT CAP?
         BVC     P2
         BMI     P2
         JSR     JANUS          ; YES
P2:      JSR     RESET
         DEC     MOVEN          ; LEFT CAP?
         LDA     MOVEN
         CMP     #$05
         BEQ     P1
P3:      JSR     CMOVE          ; AHEAD
         BVS     NEWP           ; ILLEGAL
         BMI     NEWP
         JSR     JANUS
         LDA     SQUARE         ; GETS TO
         AND     #$F0           ; 3RD RANK?
         CMP     #$20
         BEQ     P3             ; DO DOUBLE
         JMP     NEWP
;
;      CALCULATE SINGLE STEP MOVES
;      FOR K, N
;
SNGMV:   JSR     CMOVE          ; CALC MOVE
         BMI     ILL1           ; -IF LEGAL
         JSR     JANUS          ; -EVALUATE
ILL1:    JSR     RESET
         DEC     MOVEN
         RTS
;
;     CALCULATE ALL MOVES DOWN A
;     STRAIGHT LINE FOR Q,B,R
;
LINE:    JSR     CMOVE          ; CALC MOVE
         BCC     OVL            ; NO CHK
         BVC     LINE           ; CH,NOCAP
OVL:     BMI     ILL            ; RETURN
         PHP
         JSR     JANUS          ; EVALUATE POSN
         PLP
         BVC     LINE           ; NOT A CAP
ILL:     JSR     RESET          ; LINE STOPPED
         DEC     MOVEN          ; NEXT DIR
         RTS
;
;      EXCHANGE SIDES FOR REPLY
;      ANALYSIS
;
REVERSE: LDX     #$0F
ETC:     SEC
         LDY     BK,X            ; SUBTRACT
         LDA     #$77            ; POSITION
         SBC     BOARD,X         ; FROM 77
         STA     BK,X
         STY     BOARD,X         ; AND
         SEC
         LDA     #$77            ; EXCHANGE
         SBC     BOARD,X         ; PIECES
         STA     BOARD,X
         DEX
         BPL     ETC
         RTS
;
;
;
;
;
;
;
;        CMOVE CALCULATES THE TO SQUARE
;        USING .SQUARE AND THE MOVE
;       TABLE.  FLAGS SET AS FOLLOWS:
;       N - ILLEGAL MOVE
;       V - CAPTURE (LEGAL UNLESS IN CH)
;       C - ILLEGAL BECAUSE OF CHECK
;       [MY THANKS TO JIM BUTTERFIELD
;        WHO WROTE THIS MORE EFFICIENT
;        VERSION OF CMOVE]
;
CMOVE:   LDA     SQUARE          ; GET SQUARE
         LDX     MOVEN           ; MOVE POINTER
         CLC
         ADC     MOVEX,X         ; MOVE LIST
         STA     SQUARE          ; NEW POS'N
         AND     #$88
         BNE     ILLEGAL         ; OFF BOARD
         LDA     SQUARE
;
         LDX     #$20
LOOP:    DEX                     ; IS TO
         BMI     NO              ; SQUARE
         CMP     BOARD,X         ; OCCUPIED?
         BNE     LOOP
;
         CPX     #$10            ; BY SELF?
         BMI     ILLEGAL
;
         LDA     #$7F            ; MUST BE CAP!
         ADC     #$01            ; SET V FLAG
         BVS     SPX             ; (JMP)
;
NO:      CLV                     ; NO CAPTURE
;
SPX:     LDA     STATE           ; SHOULD WE
         BMI     RETL            ; DO THE
         CMP     #$08            ; CHECK CHECK?
         BPL     RETL
;
;        CHKCHK REVERSES SIDES
;       AND LOOKS FOR A KING
;       CAPTURE TO INDICATE
;       ILLEGAL MOVE BECAUSE OF
;       CHECK.  SINCE THIS IS
;       TIME CONSUMING, IT IS NOT
;       ALWAYS DONE.
;
CHKCHK:  PHA                     ; STATE
         PHP
         LDA     #$F9
         STA     STATE          ; GENERATE
         STA     INCHEK         ; ALL REPLY
         JSR     MOVE           ; MOVES TO
         JSR     REVERSE        ; SEE IF KING
         JSR     GNM            ; IS IN
         JSR     RUM            ; CHECK
         PLP
         PLA
         STA     STATE
         LDA     INCHEK
         BMI     RETL           ; NO - SAFE
         SEC                    ; YES - IN CHK
         LDA     #$FF
         RTS
;
RETL:    CLC                    ; LEGAL
         LDA     #$00           ; RETURN
         RTS
;
ILLEGAL: LDA     #$FF
         CLC                    ; ILLEGAL
         CLV                    ; RETURN
         RTS
;
;       REPLACE .PIECE ON CORRECT .SQUARE
;
RESET:   LDX     PIECE          ; GET LOGAT.
         LDA     BOARD,X        ; FOR PIECE
         STA     SQUARE         ; FROM BOARD
         RTS
;
;
;
GENRM:   JSR     MOVE           ; MAKE MOVE
GENR2:   JSR     REVERSE        ; REVERSE BOARD
         JSR     GNM            ; GENERATE MOVES
RUM:     JSR     REVERSE        ; REVERSE BACK
;
;       ROUTINE TO UNMAKE A MOVE MADE BY
;                MOVE
;
UMOVE:   TSX                    ; UNMAKE MOVE
         STX     SP1
         LDX     SP2            ; EXCHANGE
         TXS                    ; STACKS
         PLA                    ; MOVEN
         STA     MOVEN
         PLA                    ; CAPTURED
         STA     PIECE          ; PIECE
         TAX
         PLA                    ; FROM SQUARE
         STA     BOARD,X
         PLA                    ; PIECE
         TAX
         PLA                    ; TO SQUARE
         STA     SQUARE
         STA     BOARD,X
         JMP     STRV
;
;       THIS ROUTINE MOVES .PIECE
;       TO .SQUARE,  PARAMETERS
;       ARE SAVED IN A STACK TO UNMAKE
;       THE MOVE LATER
;
MOVE:    TSX
         STX     SP1            ; SWITCH
         LDX     SP2            ; STACKS
         TXS
         LDA     SQUARE
         PHA                    ; TO SQUARE
         TAY
         LDX     #$1F
CHECK:   CMP     BOARD,X        ; CHECK FOR
         BEQ     TAKE           ; CAPTURE
         DEX
         BPL     CHECK
TAKE:    LDA     #$CC
         STA     BOARD,X
         TXA                    ; CAPTURED
         PHA                    ; PIECE
         LDX     PIECE
         LDA     BOARD,X
         STY     BOARD,X        ; FROM
         PHA                    ; SQUARE
         TXA
         PHA                    ; PIECE
         LDA     MOVEN
         PHA                    ; MOVEN
STRV:    TSX
         STX     SP2            ; SWITCH
         LDX     SP1            ; STACKS
         TXS                    ; BACK
         RTS
;
;       CONTINUATION OF SUB STRATGY
;       -CHECKS FOR CHECK OR CHECKMATE
;       AND ASSIGNS VALUE TO MOVE
;
CKMATE:  LDX     BMAXC          ; CAN BLK CAP
         CPX     POINTS         ; MY KING?
         BNE     NOCHEK
         LDA     #$00           ; GULP!
         BEQ     RETV           ; DUMB MOVE!
;
NOCHEK:  LDX     BMOB           ; IS BLACK
         BNE     RETV           ; UNABLE TO
         LDX     WMAXP          ; MOVE AND
         BNE     RETV           ; KING IN CH?
         LDA     #$FF           ; YES! MATE
;
RETV:    LDX     #$04           ; RESTORE
         STX     STATE          ; STATE=4
;
;       THE VALUE OF THE MOVE (IN ACCU)
;       IS COMPARED TO THE BEST MOVE AND
;       REPLACES IT IF IT IS BETTER
;
PUSH:    CMP     BESTV          ; IS THIS BEST
         BCC     RETP           ; MOVE SO FAR?
         BEQ     RETP
         STA     BESTV          ; YES!
         LDA     PIECE          ; SAVE IT
         STA     BESTP
         LDA     SQUARE
         STA     BESTM          ; FLASH DISPLAY
RETP:    JMP     SCANDS         ; AND RTS
;
;       MAIN PROGRAM TO PLAY CHESS
;       PLAY FROM OPENING OR THINK
;
GO:      LDX     OMOVE          ; OPENING?
         BPL     NOOPEN         ; -NO
         LDA     DIS3           ; -YES WAS
         CMP     OPNING,X       ; OPPONENT'S
         BNE     END            ; MOVE OK?
         DEX
         LDA     OPNING,X       ; GET NEXT
         STA     DIS1           ; CANNED
         DEX                    ; OPENING MOVE
         LDA     OPNING,X
         STA     DIS3           ; DISPLAY IT
         DEX
         STX     OMOVE          ; MOVE IT
         BNE     MV2            ; (JMP)
;
END:     STA     OMOVE          ; FLAG OPENING
NOOPEN:  LDX     #$0C           ; FINISHED
         STX     STATE          ; STATE=C
         STX     BESTV          ; CLEAR BESTV
         LDX     #$14           ; GENERATE P
         JSR     GNMX           ; MOVES
;
         LDX     #$04           ; STATE=4
         STX     STATE          ; GENERATE AND
         JSR     GNMZ           ; TEST AVAILABLE
;                                 MOVES
;
         LDX     BESTV          ; GET BEST MOVE
         CPX     #$0F           ; IF NONE
         BCC     MATE           ; OH OH!
;
MV2:     LDX     BESTP          ; MOVE
         LDA     BOARD,X        ; THE
         STA     BESTV          ; BEST
         STX     PIECE          ; MOVE
         LDA     BESTM
         STA     SQUARE         ; AND DISPLAY
         JSR     MOVE           ; IT
         JMP     CHESS
;
MATE:    LDA     #$FF           ; RESIGN
         RTS                    ; OR STALEMATE
;
;       SUBROUTINE TO ENTER THE 
;       PLAYER'S MOVE
;
DISMV:   LDX     #$04           ; ROTATE
ROLL:    ASL     DIS3           ; KEY
         ROL     DIS2           ;INTO
         DEX                    ; DISPLAY
         BNE     ROLL
         ORA     DIS3
         STA     DIS3
         STA     SQUARE
         RTS
;
;       THE FOLLOWING SUBROUTINE ASSIGNS
;       A VALUE TO THE MOVE UNDER
;       CONSIDERATION AND RETURNS IT IN
;         THE ACCUMULATOR
;
        .RES     4998
        .ORG     $1780

STRATGY: CLC
         LDA     #$80
         ADC     WMOB           ; PARAMETERS
         ADC     WMAXC          ; WITH WEIGHT
         ADC     WCC            ; OF 0.25
         ADC     WCAP1
         ADC     WCAP2
         SEC
         SBC     PMAXC
         SBC     PCC
         SBC     BCAP0
         SBC     BCAP1
         SBC     BCAP2
         SBC     PMOB
         SBC     BMOB
         BCS     POS            ; UNDERFLOW
         LDA     #$00           ; PREVENTION
POS:     LSR     A
         CLC                    ; **************
         ADC     #$40
         ADC     WMAXC          ; PARAMETERS
         ADC     WCC            ; WITH WEIGHT
         SEC                    ; OF 0.5
         SBC     BMAXC
         LSR     A              ;  **************
         CLC
         ADC     #$90
         ADC     WCAP0          ; PARAMETERS
         ADC     WCAP0          ; WITH WEIGHT
         ADC     WCAP0          ; OF 1.0
         ADC     WCAP0
         ADC     WCAP1
         SEC                    ; [UNDER OR OVER-
         SBC     BMAXC          ; FLOW MAY OCCUR
         SBC     BMAXC          ; FROM THIS
         SBC     BBCC            ; SECTION]
         SBC     BBCC
         SBC     BCAP1
         LDX     SQUARE         ; ***************
         CPX     #$33
         BEQ     POSN           ; POSITION
         CPX     #$34           ; BONUS FOR
         BEQ     POSN           ; MOVE TO
         CPX     #$22           ; CENTRE
         BEQ     POSN           ; OR
         CPX     #$25           ; OUT OF
         BEQ     POSN           ; BACK RANK
         LDX     PIECE
         BEQ     NOPOSN
         LDY     BOARD,X
         CPY     #$10
         BPL     NOPOSN
POSN:    CLC
         ADC     #$02
NOPOSN:  JMP     CKMATE         ; CONTINUE
;
;
;
