XPOS    =       $01
YPOS    =       $02
IAL     =       $03

        .ORG    $14BE

; Subroutine plot

PLOT:   LDA     YPOS            ; Get Y-coordinate of dot.
        AND     #$30            ; Isolate bits 4 and 5.
        LSR     A               ; Divide by 16.
        LSR     A
        LSR     A
        LSR     A
        ORA     #$20            ; Set bit five.
        STA     IAL+1           ; Location of base address high.
        LDA     YPOS            ; Get Y-coordinate again.
        AND     #$07            ; Isolate bits zero, one, and two.
        ASL     A               ; Multiply by four.
        ASL     A
        ADC     IAL+1           ; Add previous result.
        STA     IAL+1           ; Store here.
        LDA     YPOS            ; Start calculation of address low.
        AND     #$C0            ; Isolate bits seven and six.
        LSR     A               ; Divide by two.
        STA     IAL             ; Location of base address low.
        LSR     A               ; Divide by two again.
        LSR     A               ; And again to get divide-by-8.
        ORA     IAL             ; OR with previous result.
        STA     IAL             ; Result into base address low.
        LDA     YPOS            ; Add $80?
        AND     #$08            ; Depends on bit three.
        BEQ     PAST            ; No.
        LDA     #$80            ; Yes, add $80.
        ADC     IAL
        STA     IAL
PAST:   LDA     #0              ; Work with X-coordinate.
        LDX     #8              ; Division starts here.
        ASL     XPOS            ; Refer to example 5013.
BR1:    ROL     A
        CMP     #7
        BCC     BR2
        SBC     #7
BR2:    ROL     XPOS
        DEX
        BNE     BR1
        TAX                     ; Remainder into X. Quotient in XPOS.
        SEC                     ; Carry contains bit to be set.
        LDA     #0              ; Clear accumulator.
BR3:    ROL     A               ; # of shifts = remainder + 1.
        DEX                     ; Decrement remainder.
        BPL     BR3             ; Until it is zero.
        LDY     XPOS            ; Quotient becomes Y index.
        ORA     (IAL),Y         ; Set the desired bit without
        STA     (IAL),Y         ; affecting the others.
        RTS                     ; That's it, folks.
