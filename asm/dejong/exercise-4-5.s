HOME    =       $FC58
RDBYTE  =       $1100
DISPLAY =       $1129

        .ORG    $121B

        JSR     HOME            ; Home the cursor, clear screen.
        JSR     RDBYTE          ; Get a 2-digit hexadecimal number.
        CLC                     ; Clear the carry before starting.
AGAIN:  JSR     DISPLAY         ; Display it.
;****************
        ASL     A               ; Shift or rotate it.
;****************
WAIT:   BIT     $C000           ; "Press any key to continue" routine.
        BPL     WAIT            ; Wait for keystroke.
        STA     $C010           ; Clear flip-flop.
        BMI     AGAIN

