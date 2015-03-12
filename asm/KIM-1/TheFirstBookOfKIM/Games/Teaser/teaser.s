        GETKEY  = $1F6A

        .ORG    $0200

BEGN:   LDA     #$00            ; ZERO REGISTERS DO-DA
        LDX     #$10
CLOP:   STA     $00CF,X
        DEX
        BNE     CLOP
        LDA     #$40            ; INITIALIZE DISPLAY...
        STA     $00D4
        LDA     #$10            ; INIT. STARFIELD
        STA     $00DE           ; REGISTERS
        LSR
        STA     $00DF
MLOP:   JSR     DISP            ; DISPLAY..
        LDX     $00D3           ; MODE?
        BNE     DELA            ; MODE=1, DELAY AND UPDATE
        JSR     $1F40           ; MODE=O, GET KEY
        BEQ     MLOP            ; NO KEY, RETURN
        JSR     $1F40           ; KEY STILL PRESSED?
        BEQ     MLOP            ; NO, RETURN
        JSR     GETKEY          ; YES, GET KEY
        CMP     #$13            ; "GO" KEY?
        BEQ     BEGN            ; YES, START AGAIN
        CMP     #$0A            ; OVER 9?
        BPL     MLOP            ; YES, TRY AGAIN
        TAY                     ; USE AS INDEX
        BEQ     MLOP            ; 0? - NOT VALID
        STA     $00D1           ; 1-9 STORE IT
        JSR     SEG             ; CONVERT TO SEGMENTS
        STA     $00D0           ; DISPLAY - LEFT DIGIT
        LDA     $02CA,Y         ; GET STAR TEST BIT
        CMP     #$06            ; TEST KEY #
        BMI     SKIP            ; 1-5, SKIP
        BIT     $00DF           ; 6-9, TEST HI FIELD
        BNE     STAR            ; IT'S A STAR
        BEQ     HOLE            ; IT'S A HOLE

SKIP:   BIT     $00DE           ; 1 TO 5, TEST LO FIELD
        BNE     STAR            ; IT'S A STAR
HOLE:   LDA     #$76            ; IT'S A HOLE LOAD "H"
        STA     $00D0           ; DISPLAY-LEFT DIGIT
        BNE     MLOP            ; UNCOND. JUMP
STAR:   SED                     ; UPDATE COUNT
        SEC
        LDA     #$00
        ADC     $00D5           ; BY ADDING ONE
        STA     $00D5           ; STORE IT
        CLD
        JSR     SEG             ; UNPACK, CONVERT
        STA     $00DA           ; TO SEGMENTS AND
        LDA     $00D5           ; DISPLAY IN DIGITS
        JSR     LEFT            ; 5 AND 6...
        STA     $00D8
        INC     $00D3           ; SET MODE TO 1
        JMP     MLOP            ; MAIN LOOP AGAIN
        LDY     #$00            ; MODE = 1
DELA:   JSR     DISP            ; DELAY ABOUT .8 SEC
        DEY                     ; WHILE DISPLAYING
        BNE     DELA
        LDX     $00D1           ; KEY # AS INDEX
        LDA     $02D3, X        ; GET SHOT PATTERN
        TAY                     ; SAVE IN Y REGISTER
        CPX     #$06            ; KEY # OVER 5?
        BMI     LOWF            ; NO, GO TO LOW FIELD
        EOR     $00DF           ; UPDATE HI FIELD, 6-9
        STA     $00DF
        TYA                     ; RECALL PATTERN, 6-9
        LDY     #$00            ; NO SHOT 3RD TIME
        ASL     A               ; ALIGN WITH LO FIELD
LOWF:   EOR     $00DE           ;UPDATE LO FIELD
        STA     $00DE
        TYA                     ; RECALL PATTERN, 1-5
        LSR     A               ; ALIGN WITH HI FIELD
        EOR     $00DF           ; UPDATE HI FIELD, I-S
        STA     $00DF           ; (BLANK SHOT IF 6-9)
        ASL     A               ; SHIFT 9 TO CARRY
        LDA     $00DE           ; GET REST OF FIELD
        LDX     #$06            ; .. STAR DISPLAY...
DLOP:   ROL                     ; ALIGN WITH DISPLAY
        PHA                     ; SAVE IT FOR NEXT TIME
        AND     #$49            ; MASK TO HORIZ. SEGS
        STA     $00D0,X         ; INTO DISPLAY WINDOW
        PLA                     ; RECALL FIELD
        DEX                     ; SHIFT TO NEXT
        DEX                     ; DISPLAY DIGIT
        BNE     DLOP            ; REPEAT TILL DONE
        ROL                     ; BIT FOR 5 TO CARRY
        BCS     MODE            ; 5 IS STAR, CONTINUE
        BEQ     LOSE            ; 5 IS HOLE, ALL HOLES
        CMP     #$FF            ; ALL THE REST STARS?
        BNE     MODE            ; NO
        LDA     #$71            ; YES, LOAD "F"
        BNE     FRST            ; AND SKIP
LOSE:   LDA     #$38            ; LOAD "L", (LOSE)
        BNE     FRST            ; AND SKIP
MODE:   DEC     $00D3           ; SET MODE TO 0
        LDA     #$00            ; BLANK FIRST DIGIT
FRST:   STA     $00D0           ; FILL FIRST DIGIT
        BNE     DONE            ; END OF GAME
        JMP     MLOP            ; MAIN LOOP AGAIN
DONE:   JSR     DISP            ; DISPLAY UNTIL
        JSR     $1F40           ; "GO" KEY IS
        JSR     GETKEY          ; PUSHED
        CMP     #$13
        BNE     DONE
        JMP     BEGN            ; START A NEW GAME

        .BYTE   $01, $02, $04, $08, $10, $10, $20, $40, $80, $1B, $07, $36, $49, $BA, $92, $6C
        .BYTE   $E0, $98

; DISPLAY SUBROUTINE

DISP:   LDA    #$7F             ; TURN ON DISPLAY
        STA    $1741
        LDX    #$09
MORE:   LDA    $00C7,X          ; PUT IN SEGMENTS
        STY    $00FC            ; SAVE Y
        JSR    $1F4E            ; DISPLAY THEM
        CPX    #$15             ; DONE? 6 TIMES
        BNE    MORE             ; NO, LOOP
        RTS                     ; YES, RETURN

; HEX CONVERSION SUBROUTINE

LEFT:   LSR    A
        LSR    A
        LSR    A
        LSR    A
SEG:    AND    #$0F             ; MASK TO 4 BITS
        TAY                     ; USE AS INDEX
        LDA    $1FE7,Y          ; CONVERT TO SEGMENTS
        RTS                     ; RETURN
