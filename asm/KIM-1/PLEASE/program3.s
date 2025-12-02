; Program Module #3

.INCLUDE        "pagezero.s"

; Please command codes

ALPIN   =       $00
DECIN   =       $02
DECOUT  =       $04
HEXOUT  =       $04
TIMER   =       $05
PACK    =       $06
UNPACK  =       $07
BRANCH  =       $08
BRCHAR  =       $09
BRTABL  =       $0A
FILL    =       $0B
MATCH   =       $0D

DECODE  =       $00
PLUS    =       $05
READY   =       $07
BLANK   =       $0B
ACCEPT  =       $0D
START   =       $10
GO      =       $13
NO      =       $18
DASH    =       $40
ZERO    =       $52
DISPLAY =       $C8
CMDTBL  =       $DC
BUFFER  =       $E0
GUESS   =       $E6

        .ORG    $0000

;               COMMAND  PARAM1   PARAM2  PARAM3

; Command Decoder
        .BYTE   ALPIN,   BUFFER,    0,        5
        .BYTE   PACK,    BUFFER,    KEYVAL,   1
        .BYTE   FILL,    DISPLAY,   0,        6
        .BYTE   BRTABL,  CMDTBL,    KEYVAL,   DECODE

; Tipsy
        .BYTE   FILL,    DISPLAY,   0,        6
        .BYTE   BRCHAR,  GO,        DECODE,   READY
        .BYTE   BRANCH,  PLUS,      0,        0
        .BYTE   FILL,    BUFFER,    $FF,      6
        .BYTE   UNPACK,  TENTHS,    BUFFER,   4
        .BYTE   HEXOUT,  BUFFER,    0,        5
        .BYTE   TIMER,   20,        BLANK,    0
        .BYTE   FILL,    DISPLAY,   0,        4
        .BYTE   TIMER,   10,        ACCEPT,   0
        .BYTE   FILL,    DISPLAY+4, DASH,     2
        .BYTE   FILL,    CHAR,      $20,      1
        .BYTE   FILL,    THOUS,     0,        4
        .BYTE   DECIN,   GUESS,     0,        3
        .BYTE   MATCH,   BUFFER,    GUESS,    4
        .BYTE   BRANCH,  NO,        0,        0
        .BYTE   MATCH,   ZERO,      TENS,     1
        .BYTE   BRANCH,  NO,        0,        0
        .BYTE   UNPACK,  TENTHS,    BUFFER+4, 2
        .BYTE   DECOUT,  BUFFER,    4,        5
        .BYTE   BRANCH,  PLUS,      0,        0
        .BYTE   FILL,    DISPLAY+4, $53,      2
        .BYTE   BRANCH,  PLUS,      0,        0

; Special Function Table
; JJT: Table was not shown in original listing

        .RES    $0120-*, $00
                        ; Code Word
        .WORD   $0000   ; 10   Not used
        .WORD   $0000   ; 11   Not used
        .WORD   $0000   ; 12   Not used
        .WORD   $0000   ; 13   Not used
        .WORD   $0000   ; 14   Not used
        .WORD   $0000   ; 15   Not used
        .WORD   $0000   ; 16   Not used
        .WORD   $0000   ; 17   Not used
