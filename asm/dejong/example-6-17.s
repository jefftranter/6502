XPOS    =       $01
YPOS    =       $02
RDBYTE  =       $1100
CLEAR   =       $14A6
PLOT    =       $14BE
SS1     =       $C053
SS2     =       $C050
SS3     =       $C057
SS4     =       $C054

        .ORG    $150E

        CLD                     ; Clear decimal mode.
        JSR     CLEAR           ; Clear the HIRES screen.
        STA     SS1             ; Set the soft switches
        STA     SS2             ; For HIRES graphics
        STA     SS3             ; mixed with text.
        STA     SS4
BR6:    JSR     RDBYTE          ; Get the X coordinate.
        STA     XPOS            ; Store it here.
        JSR     RDBYTE          ; Get the Y coordinate.
        STA     YPOS            ; Store it here.
        JSR     PLOT            ; Plot the point on the HIRES screen.
        CLC                     ; Force a jump to get another point.
        BCC     BR6

