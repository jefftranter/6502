FIFO    =       $000D
PNTR    =       $0010
CNTSPD  =       $20CE           ; Subroutine to set speed.
COUT    =       $FDED

        .ORG    $2122

; Interrupt Routine
; *****************

        TXA                     ; Save the X and Y registers
        PHA                     ; on the stack.
        TYA
        PHA
        LDA     $C000           ; Read the keyboard.
        BPL     OUT             ; Branch to end if no key.
        STA     $C010           ; Key pressed. Clear strobe.
        CMP     #$A0            ; Is it a character?
        BCC     CONTROL         ; No, it's a control code.
        LDY     #$00            ; Yes, so put it in
        STA     (PNTR),Y        ; the FIFO memory.
        INC     PNTR
BACK:   JSR     COUT            ; Also, output the character.
HERE:   LDY     $24             ; Advance the flashing
        LDA     ($28),Y         ; cursor.
        AND     #$3F
        ORA     #$40
        STA     ($28),Y
OUT:    LDA     $C704
        PLA                     ; Restore the registers.
        TAY
        PLA
        TAX
        LDA     $45             ; Get the accumulator.
        RTI                     ; Return
CONTROL:
        CMP     #$93            ; Control S?
        BNE     NEXT1           ; No.
        JSR     CNTSPD          ; Yes, set speed.
        CLC                     ; Then get out.
        BCC     OUT
NEXT1:  CMP     #$88            ; Delete key?
        BNE     NEXT2           ; No.
        JSR     COUT            ; Yes, delete from screen.
        LDA     PNTR            ; Also decrement pointer
        CMP     FIFO            ; to current FIFO location.
        BEQ     OUT
        DEC     PNTR
        CLV                     ; Then get out.
        BVC     HERE
NEXT2:  CMP     #$95            ; Escape? Panic?
        BNE     NEXT3           ; No.
        JMP     $2200           ; Yes, restart the program.
NEXT3:  CMP     #$8D            ; Carriage return.
        BNE     NEXT4
        BEQ     BACK
NEXT4:  CMP     #$92            ; "Ctl R" key?
        BNE     NEXT5
        JMP     $2250           ; Jump to another routine.
NEXT5:  CMP     #$94            ; "Ctrl T" key?
        BNE     OUT             ; No, then return from interrupt.
        JMP     $223E           ; Start sending code.

