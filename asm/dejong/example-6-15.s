IAL     =       $FE

        .ORG    $14A6

; Subroutine CLEAR

CLEAR:  LDY     #$00            ; Initialize Y to zero.
        LDA     #$00            ; Zeros into the accumulator.
        STA     IAL             ; Set up base address low, BAL.
        LDX     #$20            ; BAH = $20
        STX     IAL+1           ; Set up base address high, BAH.
        LDX     #$3F            ; Set up ending page number.
LOOP:   STA     (IAL),Y         ; Clear a location.
        INY                     ; Increment Y for the next location.
        BNE     LOOP            ; Loop back until a page is cleared.
        INC     IAL+1           ; Go to the next page.
        CPX     IAL+1           ; Is it time to quit?
        BCS     LOOP            ; No, fill another page with zeros.
        RTS                     ; Yes, then quit.
