KYBD    =       $C000
STROBE  =       $C010
COUT    =       $FDED

        .org    $102A

WAIT:   LDA     KYBD            ; Read the keyboard input port.
        bpl     WAIT            ; Wait in this loop for a keystroke.

        sta     STROBE          ; Clear the flag flip-flop.
        jsr     COUT            ; Output the character
        brk
