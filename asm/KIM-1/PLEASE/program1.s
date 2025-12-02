; Program Module #1

.INCLUDE        "pagezero.s"

; PLEASE routine addresses

NXTSTP  =       $0304
DIRADR  =       $0383
EXSET   =       $17D9

; Please command codes

ALPIN   =       $00
HEXIN   =       $01
DECIN   =       $02
ALPOUT  =       $03
HEXOUT  =       $04
DECOUT  =       $04
TIMER   =       $05
PACK    =       $06
UNPACK  =       $07
BRANCH  =       $08
BRCHAR  =       $09
BRTABL  =       $0A
FILL    =       $0B
COMPAR  =       $0C
;MATCH  =       $0D

DECODE  =       $00
MSGHI   =       $01
SCLOCK  =       $04
DCLOCK  =       $06
STIMER  =       $0A
DTIMER  =       $0C
NOTICE  =       $10
MASTER  =       $10
MESAGE  =       $11
BBOARD  =       $12
GO      =       $13
BILBRD  =       $13
DAFFY   =       $16
GET     =       $18
GOOD    =       $1A
BLANK   =       $1C
WAIT    =       $1E
BAD     =       $20
HOLD    =       $21
DISPLAY =       $C8
BMSGLO  =       $CA
NMSGLO  =       $D0
CMDTBL  =       $DC
BUFFER  =       $E0
ANSWER  =       $E0
GUESS   =       $E6

        .ORG    $0000

;               COMMAND  PARAM1   PARAM2  PARAM3

; Command Decoder
        .BYTE   ALPIN,   BUFFER,  0,      5
        .BYTE   PACK,    BUFFER,  KEYVAL, 1
        .BYTE   FILL,    DISPLAY, 0,      6
        .BYTE   BRTABL,  CMDTBL,  KEYVAL, DECODE

; Set Clock and Display Clock
        .BYTE   DECIN,   BUFFER,  0,      5
        .BYTE   PACK,    BUFFER,  HOUR,   3
        .BYTE   UNPACK,  HOUR,    BUFFER, 6
        .BYTE   DECOUT,  BUFFER,  0,      5
        .BYTE   BRCHAR,  GO,      DECODE, SCLOCK
        .BYTE   BRANCH,  DCLOCK,  0,      0

; Set Timer and Display Timer
        .BYTE   DECIN,   BUFFER,  5,      0
        .BYTE   PACK,    BUFFER,  TENS,   3
        .BYTE   UNPACK,  TENS,    BUFFER, 6
        .BYTE   DECOUT,  BUFFER,  0,      5
        .BYTE   BRCHAR,  GO,      DECODE, STIMER
        .BYTE   BRANCH,  DTIMER,  0,      0

; Notice and Billboard
        .BYTE   MESAGE,  NMSGLO,  MSGHI,  10
        .BYTE   BRCHAR,  GO,      DECODE, BILBRD
        .BYTE   BRANCH,  NOTICE,  0,      0
        .BYTE   BBOARD,  BMSGLO,  MSGHI,  4
        .BYTE   BRCHAR,  GO,      DECODE, NOTICE
        .BYTE   BRANCH,  BILBRD,  0,      0

; Daffy
        .BYTE   FILL,    ANSWER,  0,      6
        .BYTE   UNPACK,  TENS,    ANSWER, 4
        .BYTE   DECIN,   GUESS,   0,      3
        .BYTE   MASTER,  GUESS,   ANSWER, BAD
        .BYTE   DECOUT,  ANSWER,  0,      5
        .BYTE   TIMER,   2,       BLANK,  0
        .BYTE   FILL,    DISPLAY+4, 0,    2
        .BYTE   TIMER,   1,       WAIT,   0
        .BYTE   BRCHAR,  GO,      DECODE, DAFFY
        .BYTE   BRANCH,  GOOD,    0,      0
        .BYTE   DECOUT,  GUESS,   4,      5
        .BYTE   BRCHAR,  GO,      DECODE, GET
        .BYTE   BRANCH,  HOLD,    0,      0

; Special Function Table
; JJT: Table was not shown in original listng

        .RES $0120-*, $00
                        ; Code Word
        .WORD   MASTER  ; 10   MASTER
        .WORD   MESAGE  ; 11   MESAGE
        .WORD   MESAGE  ; 12   BBOARD
        .WORD   BILBRD  ; 13   BILBRD
        .WORD   $0000   ; 14   Not used
        .WORD   $0000   ; 15   Not used
        .WORD   $0000   ; 16   Not used
        .WORD   $0000   ; 17   Not used

_MASTER:JSR     DIRADR          ; Address of Guess
        LDX     PARAM2          ; Bump Guesses Counter
        INC     5,X
        LDA     #$0A            ; Test Units digit - 10
        CMP     5,X
        BNE     TEST
        LDA     #0              ; Set Units = 0.
        STA     5,X             ; Incr Tens digit
        INC     4,X

TEST:   LDA     #0              ; Clear Evaluation
        STA     PTEMP0          ; Counters
        STA     PTEMP1
        LDY     #3              ; Set Digit Counter
PTEST:  LDA     (ADRLO),Y       ; Get a Guess Character
        CMP     3,X             ; Test Correct Char.
        BNE     NOTPER          ; in Correct Location.
        INC     PTEMP0          ; Bump Counter
NOTPER: DEX                     ; Test all four Guess
        DEY                     ; Characters.
        BPL     PTEST

        LDX     PARAM2          ; Test Correct without
        LDA     #3              ; regard to position.
        STA     TEMP
SETUP:  LDY     #3
MATCH:  LDA     3,X             ; Get Answer Digit
        CMP     (ADRLO),y       ; Guess digit to prevent
        BNE     NMATCH
        LDA     #$FF            ; If Match, wipe out the
        STA     (ADRLO),Y       ; Guess digit to prevent
        INC     PTEMP1          ; multiple matches.
        BPL     NEXT
NMATCH: DEY                     ; If No-match, keep trying
        BPL     MATCH
NEXT:   DEX                     ; Get next Answer digit
        DEC     TEMP            ; until all four done.
        BPL     SETUP

        LDY     #4              ; Test Perfect Match on
        CPY     PTEMP0          ; all four digits.
        BEQ     DONE            ; If so, then done.
        LDA     PARAM3          ; Else, use PARAM3 for next
        STA     STEPNO          ; Step Number.
DONE:   LDA     PTEMP0          ; Move Evaluation counters
        STA     (ADRLO),Y       ; to Guess Buffer for
        INY                     ; displaying.
        LDA     PTEMP1
        STA     (ADRLO),y
        JMP     NXTSTP

        BRK
        BRK
        BRK
        BRK
        BRK

_MESAGE:LDY     #$00            ; Initialize start of message.
        STY     PLACE
MORE:   LDX     #$00            ; Get next character.
FETCH:  LDA     (PARAM1),Y      ; If character is minus, then
        BPL     OKAY            ; end of message.
        JMP     NXTSTP
OKAY:   STA     DSP0,X          ; Store character in display
        INY                     ; buffer.  Bump pointers.
        INX
        CPX     #6              ; Text six characters done.
        BNE     FETCH           ; If not, get next.
        LDA     PLACE           ; Get message place pointer.
        LDX     #$12            ; Test MESAGE or BILBRD
        CPX     PARAM0          ; If MESAGE, then move place
        BEQ     INCR            ; pointer forward six places.
        ADC     #5              ; If BILBRD, then move one
INCR:   ADC     #0              ; place.
        STA     PLACE           ; Save modified PLACE.
        LDA     PARAM3          ; Get Delay from PARAM3
        STA     PTEMP0
SETIME: LDA     #100            ; Set 1/10 second timer.
        STA     PTEMP1
_WAIT:  JSR     EXSET           ; Wait 1 millisecond
        DEC     PTEMP1          ; Bump 1/10 second counter
        BNE     _WAIT           ; until zero.
        DEC     PTEMP0          ; Then bump Delay counter
        BNE     SETIME          ; until zero.
        LDY     PLACE           ; Now get next frame of the
        BPL     MORE            ; message.

; Message for Notice and Billboard

        .BYTE   $00, $00, $00, $00, $00, $00 ; Blanks for Billboard
        .BYTE   $73, $38, $79, $77, $6D, $79 ; PLEASE
        .BYTE   $00, $39, $77, $37, $00, $30 ;  CAN I
        .BYTE   $00, $76, $79, $38, $73, $00 ;  HELP
        .BYTE   $00, $53, $00, $00, $00, $00 ;  ?
        .BYTE   $00, $00, $00, $00, $00, $00 ; Trailing blanks
        .BYTE   $FF                          ; Terminator
