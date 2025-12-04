; Program Module #3

.INCLUDE        "pagezero.s"

; Please command codes

ALPIN   =       $00
DECODE  =       $00
DECIN   =       $02
DECOUT  =       $04
HEXOUT  =       $04
TIMER   =       $05
PLUS    =       $05
PACK    =       $06
UNPACK  =       $07
READY   =       $07
BRANCH  =       $08
BRCHAR  =       $09
BRTABL  =       $0A
FILL    =       $0B
BLANK   =       $0B
MATCH   =       $0D
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

;               COMMAND  PARAM1     PARAM2    PARAM3   STEP LABEL

; Command Decoder
        .BYTE   ALPIN,   BUFFER,    0,        5      ;  0   DECODE
        .BYTE   PACK,    BUFFER,    KEYVAL,   1      ;  1
        .BYTE   FILL,    DISPLAY,   0,        6      ;  2
        .BYTE   BRTABL,  CMDTBL,    KEYVAL,   DECODE ;  3

; Tipsy
        .BYTE   FILL,    DISPLAY,   0,        6      ;  4   TIPSY
        .BYTE   BRCHAR,  GO,        DECODE,   READY  ;  5   PLUS
        .BYTE   BRANCH,  PLUS,      0,        0      ;  6
        .BYTE   FILL,    BUFFER,    $FF,      6      ;  7   READY
        .BYTE   UNPACK,  TENTHS,    BUFFER,   4      ;  8
        .BYTE   HEXOUT,  BUFFER,    0,        5      ;  9
        .BYTE   TIMER,   20,        BLANK,    0      ;  A
        .BYTE   FILL,    DISPLAY,   0,        4      ;  B   BLANK
        .BYTE   TIMER,   10,        ACCEPT,   0      ;  C
        .BYTE   FILL,    DISPLAY+4, DASH,     2      ;  D   ACCEPT
        .BYTE   FILL,    CHAR,      $20,      1      ;  E
        .BYTE   FILL,    THOUS,     0,        4      ;  F
        .BYTE   DECIN,   GUESS,     0,        3      ; 10
        .BYTE   MATCH,   BUFFER,    GUESS,    4      ; 11
        .BYTE   BRANCH,  NO,        0,        0      ; 12
        .BYTE   MATCH,   ZERO,      TENS,     1      ; 13   YES
        .BYTE   BRANCH,  NO,        0,        0      ; 14
        .BYTE   UNPACK,  TENTHS,    BUFFER+4, 2      ; 15
        .BYTE   DECOUT,  BUFFER,    4,        5      ; 16
        .BYTE   BRANCH,  PLUS,      0,        0      ; 17
        .BYTE   FILL,    DISPLAY+4, $53,      2      ; 18   NO
        .BYTE   BRANCH,  PLUS,      0,        0      ; 19

; Command Table.
; JJT: Table was not shown in the original listing but is described in
; the LISTING document page 38.

; Command Keys Step Description
;  "TI"   E7   04   Tipsy
;         00   00   End of table

        .RES    $00A0-*, $0000

        .BYTE   $E7, $04, $00, $00, $00, $00, $00, $00
        .BYTE   $00, $00, $00, $00, $00, $00, $00, $00

; Special Function Table
; JJT: Table was not shown in original listing. Unsure if it is needed
; since the program does not have any native routines.

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
