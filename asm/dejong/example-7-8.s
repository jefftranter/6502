KYBD    =       $C000
PNTR    =       $0010

        .ORG    $16B8

; KYBD  Interrupt Routine
;************************

NMIRTN: PHA                     ; Save the accumulator.
        TYA                     ; Y into A.
        PHA                     ; A onto stack. Y is saved.
        TXA                     ; X into A.
        PHA                     ; X onto stack. X is saved.
        LDA     KYBD            ; Read the keyboard.
        BPL     RETURN          ; Return without key.
        LDY     #$00            ; Y=0 for indirect indexed mode.
        STA     (PNTR),Y        ; Store the character.
        INC     PNTR            ; Increment the pointer.
        JSR     $FDED           ; Output the character to the screen.
        STA     $C010           ; Clear the keyboard strobe.
        PLA                     ; Restore X.
        TAX
        PLA                     ; Restore Y.
        TAY                     ; JJT: Book listing incorrectly had TAX here.
        PLA                     ; Restore A.
RETURN: RTI                     ; Return to interrupted program.
