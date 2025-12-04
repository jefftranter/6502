; Program Module #2

.INCLUDE        "pagezero.s"

; PLEASE routine addresses

NXTSTP  =       $0304

; Please command codes

ALPIN   =       $00
DECODE  =       $00
HEXIN   =       $01
DECIN   =       $02
ALPOUT  =       $03
DECOUT  =       $04
STAR    =       $04
TIMER   =       $05
PACK    =       $06
UNPACK  =       $07
BRANCH  =       $08
BRCHAR  =       $09
RWAIT   =       $09
BRTABL  =       $0A
FILL    =       $0B
LOSE    =       $0B
COMPARE =       $0C
SWAIT   =       $0C
WIN     =       $0E
START   =       $10
SHOT    =       $11
HILO    =       $11
GO      =       $13
WAIT    =       $13
READY   =       $15
LOW     =       $1C
EQUAL   =       $1E
BLANK   =       $20
NEXT    =       $22
HI      =       $6A
LO      =       $72
DISPLAY =       $C8
CMDTBL  =       $DC
BUFFER  =       $E0
COUNT   =       $E6
GUESS   =       $E6
UNIV    =       $E7
CENTER  =       $E8

        .ORG    $0000

; JJT: The table below in the LISTING document showed different hex
; values in different places for the symbol WAIT: $0C and $13. The
; table below matches the hex values in the listing but it could be in
; error.

;               COMMAND  PARAM1   PARAM2  PARAM3

; Command Decoder
        .BYTE   ALPIN,   BUFFER,    0,        5
        .BYTE   PACK,    BUFFER,    KEYVAL,   1
        .BYTE   FILL,    DISPLAY,   0,        6
        .BYTE   BRTABL,  CMDTBL,    KEYVAL,   DECODE

; Shooting Stars
        .BYTE   START,   0,         0,        0
        .BYTE   HEXIN,   BUFFER,    3,        3
        .BYTE   SHOT,    LOSE,      WIN,      0
        .BYTE   UNPACK,  COUNT,     BUFFER+4, 2
        .BYTE   DECOUT,  BUFFER,    4,        5
        .BYTE   BRCHAR,  GO,        DECODE,   5
        .BYTE   BRANCH,  RWAIT,     0,        0
        .BYTE   FILL,    DISPLAY+4, $53,      2
        .BYTE   BRCHAR,  GO,        DECODE,   STAR
        .BYTE   BRANCH,  SWAIT,     0,        0
        .BYTE   UNPACK,  COUNT,     BUFFER+4, 2
        .BYTE   DECOUT,  BUFFER,    4,        5
        .BYTE   BRANCH,  SWAIT,     0,        0

; HILO Number Guessing Game
        .BYTE   FILL,    GUESS,     $FF,      6
        .BYTE   UNPACK,  TENTHS,    BUFFER+4, 2
        .BYTE   BRCHAR,  GO,        DECODE,   READY
        .BYTE   BRANCH,  WAIT,      0,        0
        .BYTE   FILL,    DISPLAY+4, 0,        2
        .BYTE   DECIN,   GUESS,     0,        1
        .BYTE   COMPARE, GUESS,     BUFFER+4, 2
        .BYTE   BRANCH,  LOW,       0,        0
        .BYTE   BRANCH,  EQUAL,     0,        0
        .BYTE   ALPOUT,  HI,        4,        5
        .BYTE   BRANCH,  WAIT,      $06,      $07
        .BYTE   ALPOUT,  LO,        4,        5
        .BYTE   BRANCH,  WAIT,      $08,      $0A
        .BYTE   DECOUT,  BUFFER,    4,        5
        .BYTE   TIMER,   1,         BLANK,    0
        .BYTE   FILL,    DISPLAY+4, 0,        2
        .BYTE   TIMER,   1,         NEXT,     0
        .BYTE   BRCHAR,  GO,        DECODE,   HILO
        .BYTE   BRANCH,  EQUAL,     0,        0

; Command Table.
; JJT: Table was not shown in the original listing but is described in
; the LISTING document page 38.

; Command Keys Step Description
;  "SS"   DD   04   Shooting Stars
;  "HI"   67   11   HiLo
;         00   00   End of table

        .RES    $00A0-*, $0000

        .BYTE   $DD, $04, $67, $11, $00, $00, $00, $00
        .BYTE   $00, $00, $00, $00, $00, $00, $00, $00

; Special Function Table
; JJT: Table was not shown in original listing

        .RES    $0120-*, $00
                        ; Code Word
        .WORD   _START  ; 10   START
        .WORD   _SHOT   ; 11   SHOT
        .WORD   $0000   ; 12   Not used
        .WORD   $0000   ; 13   Not used
        .WORD   $0000   ; 14   Not used
        .WORD   $0000   ; 15   Not used
        .WORD   $0000   ; 16   Not used
        .WORD   $0000   ; 17   Not used

_START: LDA     #0              ; Initialize Shooting Stars
        STA     COUNT           ; Clear Shot Counter
        STA     UNIV            ; Clear Universe
        LDA     #1              ; Set Center Star
        STA     CENTER          ; to be on
        BPL     FIRST           ; Go Map Universe to Display

_SHOT:  LDA     #<MAP           ; Shot Evaluation
        STA     ADRLO           ; Set ADRLO/ADRHI to
        LDA     #>MAP           ; point to Shot Map
        STA     ADRHI
        LDY     #0
SEARCH: LDA     BUFFER+3        ; Get current shot value
        CMP     (ADRLO),y       ; Test Shot Map match
        BEQ     MATCH           ; Branch on match
        TYA                     ; Else set for next position
        CLC                     ; in Shot Map.
        ADC     #4              ; Four bytes per entry
        CMP     #36             ; Test end of Shot Map
        BEQ     NMATCH          ; for Invalid Shot
        TAY                     ; Set to get next.
        BPL     SEARCH          ; Continue Search
MATCH:  INY                     ; Set for next byte
        LDA     (ADRLO),y       ; Get POS from Shot Map
        BEQ     CTEST           ; Test Center
        AND     UNIV            ; Else mask to see if Star
        BEQ     NMATCH          ; exists.  If not, invalid.
FIX:    INY                     ; Set for next byte.
        LDA     (ADRLO),Y       ; Get GALAXY
        EOR     UNIV            ; Exclusive OR to turn on/off
        STA     UNIV            ; associated Stars.
        INY                     ; Set for next byte.
        LDA     (ADRLO),Y       ; Get Center value
        EOR     CENTER          ; Exclusive OR
        STA     CENTER
        BPL     SHOWIT
CTEST:  LDA     CENTER          ; Test if Center Exists
        BNE     FIX             ; Okay if Center Exists
NMATCH: LDA     #$53            ; Invalid Shot.  Show a
        STA     DSP3            ; Question Mark in Shot
        BPL     RUN             ; position of display.
SHOWIT: SED                     ; Increment two digit
        CLC                     ; Decimal Shot Counter
        LDA     #01
        ADC     COUNT
        STA     COUNT
        CLD

FIRST:  LDA     #$49            ; Convert Universe to
        AND     UNIV            ; Display Segment Values
        STA     DSP0            ; First Position

SECND:  LDA     #$24            ; Mask Second Position
        AND     UNIV            ; to calculate Segments
        LSR                     ; Shift for actual
        LSR                     ; segment values
        STA     DSP1
        LDA     CENTER          ; Get Center value
        BEQ     THIRD           ; Test on/off
        LDA     DSP1            ; ON so add in the
        ADC     #$40            ; Center segment value
        STA     DSP1

THIRD:  LDA     #$92            ; Mask Third Position
        AND     UNIV            ; and then shift into
        STA     DSP2            ; correct positions
        LSR     DSP2

TEST:   LDA     UNIV            ; Test Empty Universe
        BEQ     TEST2           ; Maybe
        CMP     #$FF            ; Test Win Position
        BNE     RUN             ; No
        LDA     CENTER          ; Maybe.  Win if Center
        BEQ     _WIN            ; position is OFF
TEST2:  LDA     CENTER          ; Empty of Win
        BNE     RUN             ; Not if Center is ON
_LOSE:  LDA     PARAM1          ; Empty Universe.  LOSE.
        BPL     STEP            ; Use PARAM1 Step No.
_WIN:   LDA     PARAM2          ; WIN.  Use PARAM2.
STEP:   STA     STEPNO          ; Save new Step No.
RUN:    JMP     NXTSTP

; Shooting Stars - Shot Map

        .RES    $01C0-*, $00

;               SHOT POS GALAXY CENTER
MAP:    .BYTE   $00, $08, $68, $01
        .BYTE   $01, $20, $38, $00
        .BYTE   $02, $10, $B0, $01
        .BYTE   $04, $40, $49, $00
        .BYTE   $05, $00, $E4, $01
        .BYTE   $06, $80, $92, $00
        .BYTE   $08, $01, $45, $01
        .BYTE   $09, $04, $07, $00
        .BYTE   $0A, $02, $86, $01
