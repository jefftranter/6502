; Program Module #1

.INCLUDE        "pagezero.s"

; PLEASE routine addresses

NXTSTP  =       $0304
DIRADR  =       $0383
EXSET   =       $17D9

; Please command codes

ALPIN   =       $00
DECODE  =       $00
HEXIN   =       $01
MSGHI   =       $01
DECIN   =       $02
ALPOUT  =       $03
HEXOUT  =       $04
DECOUT  =       $04
SCLOCK  =       $04
TIMER   =       $05
PACK    =       $06
DCLOCK  =       $06
UNPACK  =       $07
BRANCH  =       $08
BRCHAR  =       $09
BRTABL  =       $0A
STIMER  =       $0A
FILL    =       $0B
COMPAR  =       $0C
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

;               COMMAND  PARAM1     PARAM2    PARAM3   STEP LABEL

; Command Decoder
        .BYTE   ALPIN,   BUFFER,    0,        5      ;  0   DECODE
        .BYTE   PACK,    BUFFER,    KEYVAL,   1      ;  1
        .BYTE   FILL,    DISPLAY,   0,        6      ;  2
        .BYTE   BRTABL,  CMDTBL,    KEYVAL,   DECODE ;  3

; Set Clock and Display Clock
        .BYTE   DECIN,   BUFFER,    0,        5      ;  4   SCLOCK
        .BYTE   PACK,    BUFFER,    HOUR,     3      ;  5
        .BYTE   UNPACK,  HOUR,      BUFFER,   6      ;  6   DCLOCK
        .BYTE   DECOUT,  BUFFER,    0,        5      ;  7
        .BYTE   BRCHAR,  GO,        DECODE,   SCLOCK ;  8
        .BYTE   BRANCH,  DCLOCK,    0,        0      ;  9

; Set Timer and Display Timer
        .BYTE   DECIN,   BUFFER,    5,        0      ;  A   STIMER
        .BYTE   PACK,    BUFFER,    TENS,     3      ;  B
        .BYTE   UNPACK,  TENS,      BUFFER,   6      ;  C   DTIMER
        .BYTE   DECOUT,  BUFFER,    0,        5      ;  D
        .BYTE   BRCHAR,  GO,        DECODE,   STIMER ;  E
        .BYTE   BRANCH,  DTIMER,    0,        0      ;  F

; Notice and Billboard
        .BYTE   MESAGE,  NMSGLO,    MSGHI,    10     ; 10   NOTICE
        .BYTE   BRCHAR,  GO,        DECODE,   BILBRD ; 11
        .BYTE   BRANCH,  NOTICE,    0,        0      ; 12
        .BYTE   BBOARD,  BMSGLO,    MSGHI,    4      ; 13   BILBRD
        .BYTE   BRCHAR,  GO,        DECODE,   NOTICE ; 14
        .BYTE   BRANCH,  BILBRD,    0,        0      ; 15

; Daffy
        .BYTE   FILL,    ANSWER,    0,        6      ; 16   DAFFY
        .BYTE   UNPACK,  TENS,      ANSWER,   4      ; 17
        .BYTE   DECIN,   GUESS,     0,        3      ; 18   GET
        .BYTE   MASTER,  GUESS,     ANSWER,   BAD    ; 19
        .BYTE   DECOUT,  ANSWER,    0,        5      ; 1A   GOOD
        .BYTE   TIMER,   2,         BLANK,    0      ; 1B
        .BYTE   FILL,    DISPLAY+4, 0,        2      ; 1C   BLANK
        .BYTE   TIMER,   1,         WAIT,     0      ; 1D
        .BYTE   BRCHAR,  GO,        DECODE,   DAFFY  ; 1E   WAIT
        .BYTE   BRANCH,  GOOD,      0,        0      ; 1F
        .BYTE   DECOUT,  GUESS,     4,        5      ; 20   BAD
        .BYTE   BRCHAR,  GO,        DECODE,   GET    ; 21   HOLD
        .BYTE   BRANCH,  HOLD,      0,        0      ; 22

; Command Table.
; JJT: Table was not shown in the original listing but is described in
; the LISTING document page 38.

; Command Keys Step Description
;  "SC"   D2   04   Set Clock
;  "DC"   32   06   Display Clock
;  "ST"   DE   0A   Set Timer
;  "DT"   3E   0C   Display Timer
;  "DA"   30   16   Daffy
;  "NO"   9A   10   Notice
;  "BB"   11   13   Billboard
;         00   00   End of table

        .RES    $00A0-*, $0000

        .BYTE   $D2, $04, $32, $06, $DE, $0A, $3E, $0C
        .BYTE   $30, $16, $9A, $10, $11, $13, $00, $00

; Special Function Table
; JJT: Table was not shown in original listing

        .RES    $0120-*, $00
                       ; Code Word
        .WORD   _MASTER ; 10   MASTER
        .WORD   _MESAGE ; 11   MESAGE
        .WORD   _MESAGE ; 12   BBOARD
        .WORD   $0000   ; 13   Not used
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
