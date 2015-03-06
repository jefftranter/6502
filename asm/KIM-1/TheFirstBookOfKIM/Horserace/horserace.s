        LAP     = $8F
        KEYIN   = $1F3D

        .ORG    $0200

        CLD                     ; ...INITIALIZATION...
        LDX     #$13
INIT:   LDA     $02D9,X         ; HORSES TO STARTING GATE
        STA     $007C,X
        DEX
        BPL     INIT
DISP:   LDA     #$7F            ; ...LIGHT DISPLAY...
        STA     $1741
        LDY     #$00
        LDX     #$09
LITE:   LDA     $007C,Y
        STY     $00FC
        JSR     $1F4E           ; OUTPUT DIGIT
        INY
        CPY     #$06            ; SIX DIGITS DISPLAYED?
        BCC     LITE            ; NOT YET
        JSR     $1F3D           ; TURN OFF DIGITS
        LDA     LAP             ; CNT.FINISHED TOTAL LAPS?
        BMI     DISP            ; YES, FREEZE DISPLAY
        LDX     #$03
NEXT:   DEX                     ; NEXT HORSE
        BMI     DISP            ; FINISHED 3 HORSES
        DEC     $0086,X         ; DEC. CNT., HORSE X
        BNE     NEXT            ; NOT ZERO, NEXT HORSE
        STX     $0099           ; SAVE HORE INDEX
        LDY     $0099           ; AND PUT IN Y AS INDEX
        LDX     $0083,Y         ; DIGIT P05. OF HORSE IN X
        LDA     $02ED,Y         ; MASK TO REMOVE HORSE
        AND     $007C,X         ; GET RID OF HORSE
        STA     $007C,X         ; RETURN REMAINING HORSES
        INX                     ; GO TO NEXT DIGIT RIGHT
        STX     $0083,Y         ; UPDATE HORSE DIGIT POS.
        LDA     $02ED,Y         ; GET MASK
        EOR     #$FF            ; CHANGE TO AN INSERT MASK
        ORA     $007C,X         ; PUT HORSE IN NEXT
        STA     $007C,X         ; DIGIT RIGHT
        CPX     #$05            ; REACHED RIGHT SIDE?
        BMI     POOP            ; NOT YET
        BNE     NLAP            ; OFF RIGHT SIDE, CHANGE LAP
        LDA     $008F           ; CHECK LAP COUNTER
        BEQ     LAST            ; IF ZERO, LAST LAP
        BNE     POOP
NLAP:   LDX     #$02            ; ...CHANGE TO A NEW LAP
DOWN:   SEC                     ; SHIFT ALL HORSE DIGIT
        LDA     $0083,X         ; POSITIONS SIX PLACES
        SBC     #$06            ; DOWN...
        STA     $0083,X
        DEX
        BPL     DOWN
        LDX     #$06
STOR:   LDA     $007C,X         ; ...ALSO SHIFT DIGIT
        STA     $0076,X         ; CONTENTS INTO STORAGE
        LDA     #$80            ; AREA AND CLEAR DISPLAY
        STA     $007C,X         ; AREA...
        DEX
        BNE     STOR
LAST:   DEC     $008F           ; DEC. LAP COUNTER
        BNE     POOP            ; NOT LAST LAP, CONTINUE
        LDA     $0081           ; LAST LAP, PUT FINISH
        ORA     #$06            ; LINE IN LAST DIGIT
        STA     $0081
POOP:   LDA     $0089,Y         ; HORSE Y POOP FLAG
        BEQ     NOPO            ; HORSE NOT POOPED
        JSR     RAND            ; ...POOPED, BUT MAY
        AND     #$3C            ; BECOME UNPOOPED DEPENDING
        BNE     FAST            ; ON RANDOM NUMBER
        STA     $0089,Y
NOPO:   JSR     RAND            ; ...NOT POOPED, BUT MAY
        AND     #$38            ; BECOME POOPED DEPENDING
        STA     $009A           ; ON RANDOM NUMBER...
        LDA     $008C,Y
        BMI     FAST
        AND     #$38
        CMP     $009A
        BCS     FAST
        LDA     #$FF            ; IF POOPED, SET POOP
        STA     $0089,Y         ; FLAG TO "FF"
FAST:   JSR     KEYIN           ; GET KEY FROM KEYBOARD
        LDY     #$FF            ; INIT. Y TO MAX
        LDX     $0099           ; HORSE INDEX IN X
        AND     $02F0,X         ; MASK (IS HORSE WHIPPED?)
        BEQ     SKIP            ; NO, NOT BEING WHIPPED
        DEY                     ; WHIPPED, Y MADE SMALLER
SKIP:   TYA                     ; CHANGE SIGN IF POOPED
        EOR     $0089,X         ; EXC. OR WITH 00 OR FF
        STA     $009A           ; SAVE SPEED UPDATE
        JSR     RAND            ; GET A RANDOM NUMBER
        SEC
        AND     #$01            ; ..LOWEST BIT OF #
        ADC     $009A           ; COMBINE WHIP UPDATE,
        CLC                     ; RAND # (0 OR 1) & CARRY
        LDX     $0099           ; HORSE INDEX IN X
        ADC     $008C,X         ; HORSES SPEED ADDED IN
        STA     $008C,X         ; SAVE NEW SPEED
        STA     $0086,X         ; ALSO IN WINDOW COUNTER
        JMP     NEXT            ; LOOP

;     XXXXX RANDOM NUMBER SUBROUTINE XXXX

RAND:   SEC
        LDA     $0092           ; FROM J. BUTTERFIELD
        ADC     $0095           ; KIM USER NOTES *1
        ADC     $0096           ; PAGE 4
        STA     $0091
        LDX     #$04
MOVE:   LDA     $0091,X
        STA     $0092,X
        DEX
        BPL     MOVE
        RTS

;                XXXXX TABLES - HORSERACE XXXX

       .BYTE     $00,$80,$80,$80,$80,$80,$80,$80
       .BYTE     $FF,$FF,$FF,$80,$80,$80,$00,$00,$00,$80,$80,$80,$08,$FE,$BF,$F7
       .BYTE     $01,$02,$04
