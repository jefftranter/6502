XPOS    =       $01
YPOS    =       $02
TEMP    =       $FF
GRAPH   =       $0F00
CLEAR   =       $14A6
PLOT    =       $14BE
SS1     =       $C052
SS2     =       $C050
SS3     =       $C057
SS4     =       $C054

        .ORG    $152E

        LDA     SS1             ; Set the soft switches
        LDA     SS2             ; For all HIRES graphics
        LDA     SS3
        LDA     SS4
        JSR     CLEAR           ; Clear the HIRES screen.
        LDX     #$00            ; Initialize X index to zero.
LOOP:   LDA     GRAPH,X         ; Get graph data from table.
        STA     YPOS            ; Data into Y-coordinate.
        STX     XPOS            ; X into X-coordinate.
        STX     TEMP            ; Save index.
        JSR     PLOT            ; Plot the point.
        LDX     TEMP            ; Restore index.
        INX                     ; Get another point?
        BNE     LOOP            ; Yes.
INFIN:  BEQ     INFIN           ; No, loop here forever.
