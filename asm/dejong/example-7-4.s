KYBD    =       $C000
OUTPUT  =       $FDED

        .ORG    $16A2

MAIN:   JSR     INPUT           ; Fetch a character.
        JMP     MAIN            ; Loop back.

;****************
; Subroutine INPUT

INPUT:  LDA     KYBD            ; Read the keyboard port.
        BPL     OUT             ; Has a key been pressed?
        STA     $C010           ; Yes, clear the strobe.
        PHA                     ; Save the accumulator on the stack.
        PHP                     ; Save the P register on the stack.
        JSR     OUTPUT          ; Echo the keyboard to the monitor.
        PLP                     ; Pull the P register from the stack.
        PLA                     ; Restore the accumulator.
OUT:    RTS                     ; No, return to main program.
