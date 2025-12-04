; Program Module #4

.INCLUDE        "pagezero.s"

; Please Functions

NXTSTP  =      $0304

; Please command codes

ALPIN   =       $00
DECODE  =       $00
HEXIN   =       $01
DECIN   =       $02
HEXOUT  =       $04
DECM    =       $04
PACK    =       $06
UNPACK  =       $07
SHOW    =       $07
BRANCH  =       $08
BRCHAR  =       $09
WAIT    =       $09
BRTABL  =       $0A
FILL    =       $0B
HEX     =       $0B
OVRFLO  =       $0F
DECHEX  =       $10
HEXDEX  =       $11
GO      =       $13
DISPLAY =       $C8
CMDTBL  =       $DC
BUFFER  =       $E0
DATA    =       $E6

        .ORG    $0000

;               COMMAND  PARAM1   PARAM2  PARAM3

; Command Decoder
        .BYTE   ALPIN,   BUFFER,    0,        5
        .BYTE   PACK,    BUFFER,    KEYVAL,   1
        .BYTE   FILL,    DISPLAY,   0,        6
        .BYTE   BRTABL,  CMDTBL,    KEYVAL,   DECODE

; Decimal/Hexadecimal Conversion
        .BYTE   DECIN,   BUFFER,    5,        0
        .BYTE   DECHEX,  BUFFER,    DATA,     6
        .BYTE   BRANCH,  OVRFLO,    0,        0
        .BYTE   UNPACK,  DATA,      BUFFER,   6
        .BYTE   HEXOUT,  BUFFER ,   0,        5
        .BYTE   BRCHAR,  GO,        HEX,      DECM
        .BYTE   BRANCH,  WAIT,      0,        0
        .BYTE   HEXIN,   BUFFER,    5,        0
        .BYTE   HEXDEX,  BUFFER,    DATA,     6
        .BYTE   BRANCH,  OVRFLO,    0,        0
        .BYTE   BRANCH,  SHOW,      0,        0
        .BYTE   FILL,    DISPLAY,   $53,      6
        .BYTE   BRANCH,  WAIT,      0,        0

; Command Table.
; JJT: Table was not shown in the original listing but is described in
; the LISTING document page 38.

; Command Keys Step Description
;  "DH"   36   04   Decimal to Hex
;  "HD"   63   0B   Hex to Decimal
;         00   00   End of table

        .RES    $00A0-*, $0000

        .BYTE   $36, $04, $63, $0B, $00, $00, $00, $00
        .BYTE   $00, $00, $00, $00, $00, $00, $00, $00

; Special Function Table
; JJT: Table was not shown in original listing. Unsure if it is needed
; since the program does not have any native routines.

        .RES    $0120-*, $00
                        ; Code Word
        .WORD   _HEXDEC ; 10   _HEXDEC
        .WORD   $0000   ; 11   Not used
        .WORD   $0000   ; 12   Not used
        .WORD   $0000   ; 13   Not used
        .WORD   $0000   ; 14   Not used
        .WORD   $0000   ; 15   Not used
        .WORD   $0000   ; 16   Not used
        .WORD   $0000   ; 17   Not used;

_HEXDEC:
        LDX     PARAM2          ; Get Pointer to Answer Buffer
        LDA     #0              ; Clear three bytes or six
        STA     0,X             ; digit positions
        STA     1,X
        STA     2,X

NEXT:   LDX     PARAM1          ; Get Pointer to Input Buffer
        LDA     0,X             ; Get next character
        BMI     LZERO           ; Test leading blanks
        LDX     PARAM2          ; Get Pointer to Answer Buffer
        LDY     #HEXDEX         ; Test Hex to Dec or Dec to Hex
        CPY     PARAM0
        BEQ     HX              ; Hex to Dec
        JSR     XTEN            ; Dec to Hex Subroutine
        BCS     _OVRFLO         ; Branch on Overflow
LZERO:  INC     PARAM1          ; Bump Pointer
        DEC     PARAM3          ; Decrement No. Digits
        BNE     NEXT            ; Get Next
        INC     STEPNO          ; Incr. Step. No. for Normal
_OVRFLO:
        JMP     NXTSTP          ; or Next Step for Overflow

HX:     CMP     #10             ; Hex to Dec.  Convert from
        BMI     OKAY            ; Hex Character to BCD byte
        ADC     #5
OKAY:   JSR     DSIXT           ; Hex to Dec Subroutine
        BCS     _OVRFLO         ; Branch on Overflow
        BCC     LZERO           ; Normal return

        .RES    $0170-*, $00

DSIXT:  LDY     #16             ; Set Counter for 16 loops
        SED                     ; Set Decimal Mode
        BPL     COMMON

XTEN:   LDY     #10             ; Set Counter for 10 loops
        CLD                     ; Set Binary Mode
COMMON: STA     TEMP            ; Store New Value
        CLC                     ; Clear Carry
        LDA     #0              ; Clear Temporary bytes
        STA     3,X
        STA     4,X
        STA     5,X

NTIMES: LDA     2,X             ; Shift old value by
LAST:   ADC     5,X             ; adding to itself the
        STA     5,X             ; required number of times
        LDA     1,X             ; 16 for Hex
        ADC     4,X             ; 10 for Decimal
        STA     4,X             ; Do addition for all three
        LDA     0,X             ; bytes worth of data
        ADC     3,X
        STA     3,X
        BCS     ERROR           ; Branch on Overflow
        DEY                     ; Decrement Loop Counter
        BMI     DONE            ; When minus, then done
        BNE     NTIMES          ; If not zero, keep looping
        LDA     #0              ; On zero, set up to add
        STA     0,X             ; in the new value by
        STA     1,X             ; clearing the old values
        STA     2,X             ; and then pick up the
        LDA     TEMP            ; new value and make final
        BPL     LAST            ; loop.

DONE:   LDA     5,X             ; Move result from Temp
        STA     2,X             ; to Result bytes
        LDA     4,X
        STA     1,X
        LDA     3,X
        STA     0,X
ERROR:  CLD                     ; Clear Decimal Mode
        RTS                     ; Return
