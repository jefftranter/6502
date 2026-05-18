TEMP    =       $0000           ; Temporary storage location.
CROUT   =       $FD8E           ; Carriage return.
RDKEY   =       $FD0C           ; Read keyboard.
COUT    =       $FDED           ; Output subroutine.

        .ORG    $1100

; Subroutine RDBYTE

RDBYTE: JSR     ASHEX           ; Get nibble.
        ASL     A               ; Shift to high nibble.
        ASL     A
        ASL     A
        ASL     A
        STA     TEMP            ; Store nibble.
        JSR     ASHEX           ; Get the second nibble.
        ORA     TEMP            ; Combine the first nibble.
        STA     TEMP            ; Save entire byte.
        JSR     CROUT           ; Output a Return.
        LDA     TEMP            ; Get byte back.
        RTS                     ; No. Return.

; ASCII-TO-HEX Routine

ASHEX:  JSR     RDKEY           ; Get a character.
        JSR     COUT            ; Display it.
        AND     #$7F            ; Mask bit 7 off.
        CMP     #$40            ; Digit or letter?
        BCS     ARND
        AND     #$0F            ; Digit, mask hi-nibble.
        BPL     PAST            ; Branch past letter.
ARND:   SBC     #$37            ; Letter, subtract $37
PAST:   RTS                     ; Return with digit in A.
