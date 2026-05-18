S51     =       $C050
S52     =       $C052
S53     =       $C054
S54     =       $C056
CLRSCR  =       $F832
TABLE   =       $0528

        .ORG    $137C

        STA     S51             ; Set screen soft switches
        STA     S52             ; for low resolution
        STA     S53             ; graphics mode.
        STA     S54             ; LORES graphics mode is set.
        JSR     CLRSCR          ; Subroutine to clear screen.

;****************

        LDX     #$27            ; Start index at $27 = 39.
        LDA     #$0F            ; Number to be stored in table into A.
LOOP:   STA     TABLE,X         ; A into table location.
        DEX                     ; Decrement the index
        BPL     LOOP            ; Branch to LOOP until X < 0.

;****************

HERE:   JMP     HERE            ; Infinite loop to observe result.
