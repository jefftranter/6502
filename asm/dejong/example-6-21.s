XPOS    =       $01
YPOS    =       $02
TEMPX   =       $0A
TEMPY   =       $0B
IAL     =       $E0
SS1     =       $C053
SS2     =       $C050
SS3     =       $C057
SS4     =       $C054
RDBYTE  =       $1100
CLEAR   =       $14A6
PLOT    =       $14BE

        .ORG    $1552

        LDA     SS1             ; Set soft switches for mixed
        LDA     SS2             ; HIRES graphics
        LDA     SS3             ; and text.
        LDA     SS4
        LDA     #0              ; Set up address table.
        STA     IAL
        STA     IAL+2
        STA     IAL+4
        LDA     #$0F
        STA     IAL+1
        LDA     #$0E
        STA     IAL+3
        LDA     #$0D
        STA     IAL+5
        JSR     CLEAR           ; Clear screen.
NEWX:   JSR     RDBYTE          ; Get an 8-bit number.
        STA     TEMPX           ; Save A.
        JSR     CLEAR           ; Clear screen.
        LDA     TEMPX           ; Restore A.
        TAX                     ; Put it in the X register.
        ASL     A               ; Double it.
        TAY
;****************
LOOP:   LDA     (IAL,X)         ; Get data from the table.
        STA     YPOS            ; Put it in the Y-coordinate.
;****************
        LDA     IAL,Y
        STA     XPOS
        STY     TEMPY           ; Save Y.
        STX     TEMPX           ; Save X.
        JSR     PLOT            ; Plot the point.
        LDY     TEMPY           ; Restore Y.
        LDX     TEMPX
        SEC
        LDA     IAL,Y
        ADC     #$00
        STA     IAL,Y
        BNE     LOOP
        BEQ     NEWX            ; Graph a new table.


