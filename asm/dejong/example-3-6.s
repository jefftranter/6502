KYBD    =       $C000
STROBE  =       $C010
COUT    =       $FDED

        .ORG    $102A

WAIT:   LDA     KYBD            ; Read the keyboard input port.
        BPL     WAIT            ; Wait in this loop for a keystroke.

        STA     STROBE          ; Clear the flag flip-flop.
        JSR     COUT            ; Output the character
        BRK
