; Computer Assisted Learning (CAL) Program

TEMP    =       $0000           ; Temporary storage location.
CROUT   =       $FD8E           ; Carriage return.
RDKEY   =       $FD0C           ; Read keyboard.
HOME    =       $FC58           ; Subroutine to clear the screen.
COUT    =       $FDED           ; Output subroutine.
PREG    =       $48
AREG    =       $45

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

; Subroutine DISPLAY

DISPLAY:
        STA     AREG            ; Save A.
        PHA                     ; Save A on the stack.
        PHP                     ; Push P on the stack.
        PHP
        PLA
        STA     PREG
        TXA
        PHA                     ; Save X on the stack.
        LDX     #$07
BR2:    ROR     AREG            ; Rotate A contents into carry.
        LDA     #$00
        ADC     #$B0            ; Convert bit to ASCII.
        STA     $0510,X
        DEX
        BPL     BR2
        ROR     PREG
        LDA     #$00
        ADC     #$80
        STA     $050E
        PLA                     ; Get X from the stack.
        TAX
        PLP                     ; Get P from the stack.
        PLA                     ; Get A from the stack.
        RTS                     ; Return to calling program.

; Subroutine GETBYTS

OPA     =       $0001
OPB     =       $0002
RESULT  =       $03

GETBYTS:
        JSR     HOME            ; Home the cursor.
        JSR     RDBYTE          ; Get the first number.
        STA     OPA             ; Store it.
        JSR     RDBYTE          ; Get the second number.
        STA     OPB             ; Store it.
        RTS

; Subroutine TEST

TEST:   JSR     DISPLAY         ; Display the result.
AGAIN:  JSR     RDBYTE          ; Get the answer.
        EOR     RESULT          ; Is it equal to the result?
        BNE     AGAIN           ; No, then try again.
        RTS
