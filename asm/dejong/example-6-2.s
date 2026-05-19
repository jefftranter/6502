SS1     =       $C050
SS2     =       $C052
SS3     =       $C054
SS4     =       $C056
CLRSCR  =       $F832
TABLE   =       $0528

        .ORG    $137C

        STA     SS1             ; Set screen soft switches
        STA     SS2             ; for low resolution
        STA     SS3             ; graphics mode.
        STA     SS4             ; LORES graphics mode is set.
        JSR     CLRSCR          ; Subroutine to clear screen.

;****************

        LDX     #$27            ; Start index at $27 = 39.
        LDA     #$0F            ; Number to be stored in table into A.
LOOP:   STA     TABLE,X         ; A into table location.
        DEX                     ; Decrement the index
        BPL     LOOP            ; Branch to LOOP until X < 0.

;****************

HERE:   JMP     HERE            ; Infinite loop to observe result.
