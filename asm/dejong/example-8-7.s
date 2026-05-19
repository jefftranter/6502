TEMP    =       $0000
BCD     =       $00F0
BIN     =       $00E0
CONV    =       $13D0           ; See example 8-5.
OUT     =       $13F4           ; See example 8-6.
CROUT   =       $FD8E
COUT    =       $FDED           ; Monitor routine.
RDKEY   =       $FD0C

        .ORG    $15BE

        LDX     #$FC
LOOP:   JSR     RDBYTE
        STA     $E4,X
        INX
        BNE     LOOP
        JSR     CONV
        JSR     OUT
        BRK

; Subroutine RDBYTE

        .ORG    $1100

RDBYTE: JSR     ASHEX           ; Get nibble.
        ASL     A               ; Shift to high nibble.
        ASL     A
        ASL     A
        ASL     A
        STA     TEMP            ; Store nibble.
        JSR     ASHEX           ; Get the second nibble.
        ORA     TEMP            ; Combine with first nibble.
        STA     TEMP            ; Save entire byte.
        JSR     CROUT           ; Output a return.
        LDA     TEMP            ; Get byte back.
        RTS                     ; No, return.

; ASCII-to-hex Routine

ASHEX:  JSR     RDKEY           ; Get a character
        JSR     COUT            ; Display it. Example 8-7A.
        AND     #$7F            ; Mask bit 7 off.
        CMP     #$40            ; Digit or letter?
        BCS     ARND
        AND     #$0F            ; Digit, mask hi-nibble.
        BPL     PAST            ; Branch past letter.
ARND:   SBC     #$37            ; Letter, subtract $37.
PAST:   RTS                     ; Return with digit in A.
