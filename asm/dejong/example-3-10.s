M       =       $00
N       =       $01
SPKR    =       $C030

        .ORG    $1060

START:  STA     SPKR            ; Toggle the speaker.
        JSR     TIMER           ; Use the subroutine to delay.
        JMP     START           ; Loop back to START.

; Subroutine TIMER
TIMER:  LDX     M               ; Load X with the number in M.
LOOPX:  LDY     N               ; Load Y with the number in N.
LOOPY:  DEY                     ; Decrement the number in Y.
        BNE     LOOPY           ; If Y is not zero, loop back to LOOPY.
        DEX                     ; Decrement the number in X.
        BNE     LOOPX           ; If X is not zero, loop back to LOOPX.
        RTS
