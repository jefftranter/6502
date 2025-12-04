; Program Module #5

.INCLUDE        "pagezero.s"

; Please Functions

NXTSTP  =      $0304

; Please command codes

ALPIN   =       $00
ASTABH  =       $00
BLNK    =       $00
DECODE  =       $00
TTABHI  =       $00
DECIN   =       $02
DECOUT  =       $04
ADDSUB  =       $04
NEW     =       $05
TIMER   =       $05
PACK    =       $06
NEXT    =       $06
UNPACK  =       $07
BRANCH  =       $08
ADD     =       $09
BRCHAR  =       $09
BRTABL  =       $0A
FILL    =       $0B
SHOW    =       $0B
WAIT    =       $0D
SUB     =       $0F
DECADD  =       $10
DECSUB  =       $11
FLASH   =       $12
GO      =       $13
BLANK   =       $13
WAIT2   =       $15
REACT   =       $1A
START   =       $1C
TEST    =       $1D
WAIT3   =       $21
STOP    =       $23
ASTAB   =       $5E
ASTABL  =       $60
TTABLO  =       $90
TTABLE  =       $9E
DISPLAY =       $C8
DSPLAY  =       $C8
CMDTBL  =       $DC
BUFFER  =       $E0
HALT    =       $1E
AREG    =       $E6
BREG    =       $E9

        .ORG    $0000

;               COMMAND  PARAM1     PARAM2    PARAM3   STEP LABEL

; Command Decoder
        .BYTE   ALPIN,   BUFFER,    0,        5      ;  0   DECODE
        .BYTE   PACK,    BUFFER,    KEYVAL,   1      ;  1
        .BYTE   FILL,    DISPLAY,   0,        6      ;  2
        .BYTE   BRTABL,  CMDTBL,    KEYVAL,   DECODE ;  3

; Add and Subtract
        .BYTE   DECIN,   BUFFER,    5,        0      ;  4   ADDSUB
        .BYTE   PACK,    BUFFER,    AREG,     3      ;  5   NEW
        .BYTE   DECIN,   BUFFER,    5,        0      ;  6   NEXT
        .BYTE   PACK,    BUFFER,    BREG,     3      ;  7
        .BYTE   BRTABL,  ASTAB,     KEYVAL,   NEW    ;  8
        .BYTE   DECADD,  AREG,      BREG,     AREG   ;  9   ADD
        .BYTE   BRANCH,  FLASH,     0,        0      ;  A
        .BYTE   UNPACK,  AREG,      BUFFER,   6      ;  B   SHOW
        .BYTE   DECOUT,  BUFFER,    0,        5      ;  C
        .BYTE   BRCHAR,  GO,        DECODE,   NEXT   ;  D   WAIT
        .BYTE   BRANCH,  WAIT,      0,        0      ;  E
        .BYTE   DECSUB,  AREG,      BREG,     AREG   ;  F   SUB
        .BYTE   BRANCH,  FLASH,     0,        0      ; 10
        .BYTE   BRANCH,  SHOW,      0,        0      ; 11
        .BYTE   TIMER,   2,         BLANK,    0      ; 12   FLASH
        .BYTE   FILL,    DISPLAY,   0,        6      ; 13   BLANK
        .BYTE   TIMER,   2,         WAIT2,    0      ; 14
        .BYTE   DECOUT,  BUFFER,    0,        5      ; 15   WAIT2
        .BYTE   BRCHAR,  GO,        DECODE,   ADDSUB ; 16
        .BYTE   BRANCH,  FLASH,     ASTABL,   ASTABH ; 17
        .BYTE   $12,     ADD,       $11,      SUB    ; 18
        .BYTE   0,       0,         0,        0      ; 19

; Reaction Time Tester
        .BYTE   BRCHAR,  GO,        DECODE,   START  ; 1A   REACT
        .BYTE   BRANCH,  REACT,     00,       00     ; 1B
        .BYTE   FILL,    DSPLAY,    $3F,      6      ; 1C   START
        .BYTE   BRTABL,  TTABLE,    TENTHS,   TEST   ; 1D   TEST
        .BYTE   FILL,    DSPLAY,    BLNK,     6      ; 1E   HALT
        .BYTE   UNPACK,  TENS,      BUFFER,   6      ; 1F
        .BYTE   PACK,    BUFFER,    AREG,     3      ; 20
        .BYTE   BRCHAR,  GO,        DECODE,   STOP   ; 21   WAIT
        .BYTE   BRANCH,  WAIT3,     0,        0      ; 22
        .BYTE   DECSUB,  TENS,      AREG,     AREG   ; 23   STOP
        .BYTE   $01,     HALT,      0,        0      ; 24
        .BYTE   UNPACK,  AREG,      BUFFER,   6      ; 25
        .BYTE   DECOUT,  BUFFER,    0         ,5     ; 26
        .BYTE   BRANCH,  REACT,     TTABLO,   TTABHI ; 27

; Command Table.
; JJT: Table was not shown in the original listing but is described in
; the LISTING document page 38.

; Command Keys Step Description
;  "AS"   0D   04   Add/Subtract Calculator
;  "RE"   C4   1A   Reaction Time Tester
;         00   00   End of table

        .RES    $00A0-*, $0000

        .BYTE   $0D, $04, $C4, $1A, $00, $00, $00, $00
        .BYTE   $00, $00, $00, $00, $00, $00, $00, $00

; Special Function Table
; JJT: Table was not shown in original listing.

        .RES    $0120-*, $00
                        ; Code Word
        .WORD   _DECADD ; 10   DECADD
        .WORD   _DECSUB ; 11   DECSUB
        .WORD   _HEXADD ; 12   HEXADD
        .WORD   _HEXSUB ; 13   HEXSUB
        .WORD   $0000   ; 14   Not used
        .WORD   $0000   ; 15   Not used
        .WORD   $0000   ; 16   Not used
        .WORD   $0000   ; 17   Not used

_DECADD:SED                     ; Set Decimal Mode
_HEXADD:CLC                     ; Entry for Hex Add
        LDY     #3              ; Service three bytes

_NEXT:  LDX     PARAM1          ; Get A buffer digit
        LDA     2,X
        LDX     PARAM2          ; Add to B buffer digit
        ADC     2,X
        LDX     PARAM3          ; Store in C buffer
        STA     2,X
        DEC     PARAM1          ; Decrement buffer pointers
        DEC     PARAM2
        DEC     PARAM3
        DEY                     ; Decrement byte counter
        BNE     _NEXT           ; Continue if not zero
        CLD                     ; Clear Decimal Mode

        BCS     RETURN          ; Test Carry
        INC     STEPNO          ; Skip on Step on Normal
RETURN: JMP     NXTSTP          ; Next Step on Overflow

_DECSUB:SED                     ; Set Decimal Mode
_HEXSUB:SEC                     ; Entry for Hex Subtract
        LDY     #3              ; Service three bytes

NXT:    LDX     PARAM1          ; Get A buffer digit
        LDA     2,X
        LDX     PARAM2          ; Subtract B buffer digit
        SBC     2,X
        LDX     PARAM3          ; Store in C buffer
        STA     2,X
        DEC     PARAM1          ; Decrement buffer pointers
        DEC     PARAM2
        DEC     PARAM3
        DEY                     ; Decrement byte counter
        BNE     NXT             ; Continue of not zero
        CLD                     ; Clear Decimal Mode

        BCC     RETRN           ; Test Borrow
        INC     STEPNO          ; Skip on Step if no borrow
RETRN:  JMP     NXTSTP          ; Next Step if borrow
