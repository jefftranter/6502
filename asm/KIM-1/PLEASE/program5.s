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
ASTABL  =       $60
TTABLO  =       $90
TTABLE  =       $9E
DISPLAY =       $C8
DSPLAY  =       $C8
CMDTBL  =       $DC
BUFFER  =       $E0
HALT    =       $E0
AREG    =       $E6
BREG    =       $E9

        .ORG    $0000

;               COMMAND  PARAM1   PARAM2  PARAM3

; Command Decoder
        .BYTE   ALPIN,   BUFFER,    0,        5
        .BYTE   PACK,    BUFFER,    KEYVAL,   1
        .BYTE   FILL,    DISPLAY,   0,        6
        .BYTE   BRTABL,  CMDTBL,    KEYVAL,   DECODE

; Add and Subtract
        .BYTE   DECIN,   BUFFER,    5,        0
        .BYTE   PACK,    BUFFER,    AREG,     3
        .BYTE   DECIN,   BUFFER,    5,        0
        .BYTE   PACK,    BUFFER,    BREG,     3
        .BYTE   BRTABL,  ASTABL,    KEYVAL,   NEW
        .BYTE   DECADD,  AREG,      BREG,     AREG
        .BYTE   BRANCH,  FLASH,     0,        0
        .BYTE   UNPACK,  AREG,      BUFFER,   6
        .BYTE   DECOUT,  BUFFER,    0,        5
        .BYTE   BRCHAR,  GO,        DECODE,   NEXT
        .BYTE   BRANCH,  WAIT,      0,        0
        .BYTE   DECSUB,  AREG,      BREG,     AREG
        .BYTE   BRANCH,  FLASH,     0,        0
        .BYTE   BRANCH,  SHOW,      0,        0
        .BYTE   TIMER,   2,         BLANK,    0
        .BYTE   FILL,    DISPLAY,   0,        6
        .BYTE   TIMER,   2,         WAIT2,    0
        .BYTE   DECOUT,  BUFFER,    0,        5
        .BYTE   BRCHAR,  GO,        DECODE,   ADDSUB
        .BYTE   BRANCH,  FLASH,     ASTABL,   ASTABH
        .BYTE   $12,     ADD,       $11,      SUB
        .BYTE   0,       0,         0,        0

; Reaction Time Tester
        .BYTE   BRCHAR,  GO,        DECODE,   START
        .BYTE   BRANCH,  REACT,     00,       00
        .BYTE   FILL,    DSPLAY,    $3F,      6
        .BYTE   BRTABL,  TTABLE,    TENTHS,   TEST
        .BYTE   FILL,    DSPLAY,    BLNK,     6
        .BYTE   UNPACK,  TENS,      BUFFER,   6
        .BYTE   PACK,    BUFFER,    AREG,     3
        .BYTE   BRCHAR,  GO,        DECODE,   STOP
        .BYTE   BRANCH,  WAIT3,     0,        0
        .BYTE   DECSUB,  TENS,      AREG,     AREG
        .BYTE   $01,     HALT,      0,        0
        .BYTE   UNPACK,  AREG,      BUFFER,   6
        .BYTE   DECOUT,  BUFFER,    0         ,5
        .BYTE   BRANCH,  REACT,     TTABLO,   TTABHI

; Special Function Table
; JJT: Table was not shown in original listing. Unsure if it is needed
; since the program does not have any native routines.

        .RES    $0120-*, $00
                        ; Code Word
        .WORD   _DECADD ; 10   DECADD
        .WORD   _HEXADD ; 11   HEXADD
        .WORD   _DECSUB ; 12   DECSUB
        .WORD   _HEXSUB ; 13   HEXSUB
        .WORD   $0000   ; 14   Not used
        .WORD   $0000   ; 15   Not used
        .WORD   $0000   ; 16   Not used
        .WORD   $0000   ; 17   Not used;

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

