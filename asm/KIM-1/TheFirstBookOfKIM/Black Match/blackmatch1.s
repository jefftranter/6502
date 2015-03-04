AK      = $1EFE
SCANDS  = $1F1F
GETKEY  = $1F6A

        .org    $0200

        LDA     #$00            ; ZERO PLAYER'S WINDOW
        STA     $00FB
        LDA     #$21            ; LOAD TOTAL
        STA     $00F9           ; STORE TOTAL
ENTR:   JSR     SCANDS          ; DISPLAY TOTAL
        JSR     GETKEY          ; DID PLAYER ENTER #?
        CMP     #$04            ; IS NUMBER VALID?
        BPL     ENTR            ; IF NOT, TRY AGAIN
        CMP     #$00            ; IS NUMBER ZERO?
        BEQ     ENTR            ; IF SO, TRY AGAIN
        STA     $00FB           ; STORE PLAYER'S it
        SED                     ; SET DECIMAL MODE
        SEC                     ; SET CARRY
        LDA     $00F9           ; LOAD TOTAL
        SBC     $00FB           ; SUBTRACT PLAYER'S #
        STA     $00F9           ; STORE RESULT IN TOTAL
WAIT:   JSR     AK              ; IS KEY STILL DEPRESSED?
        BNE     WAIT            ; IF SO, WAIT
        LDA     #$08            ; LOAD WITH DELAY FACTOR
        STA     $00EE           ; STORE AT 00EE
TIME:   LDA     #$FF            ; LOAD TIMER TO MAX
        STA     $1707
DISP:   JSR     SCANDS          ; DISPLAY   AND TOTAL
        BIT     $1707           ; IS TIME DONE?
        BPL     DISP            ; NO, KEEP DISPLAYING
        LDA     $00EE           ; EXTEND TIMING INTERVAL
        DEC     $00EE
        BNE     TIME
        DEC     $00F9           ; .. COMPUTER DETERMINES
        LDA     $00F9           ; CORRECT RESPONSE AS
        AND     #$10            ; THE REMAINDER AFTER
        LSR     A               ; DIVIDING THE TOTAL
        LSR     A               ; MINUS ONE BY FOUR...
        LSR     A
        CLC
        ADC     $00F9
        INC     $00F9
        AND     #$03
        BNE     OVER
        LDA     #$01
OVER:   LDX     $1744           ; LOAD WITH TIMER
        CPX     #$A0            ; COMPARE WITH I.Q,
        BCS     COMP            ; IF GREATER, NO CHANGE
        LDA     #$02            ; ELSE DEFAULT TO TWO
COMP:   STA     $00FA           ; STORE COMPUTER'S CHOICE
        LDA     $00F9           ; LOAD TOTAL
        SEC                     ; SET CARRY
        SBC     $00FA           ; SUBTRACT COMPUTER'S CHOICE
        STA     $00F9           ; STORE IN TOTAL
        CMP     #$01            ; COMPARE WITH ONE
        BEQ     DEAD            ; IF EQUAL, DISPLAY DEAD
        BMI     SAFE            ; IF MINUS, DISPLAY SAFE
        BCS     ENTR            ; ELSE GET ANOTHER ENTRY
DEAD:   LDA     #$DE            ; LOAD AND DISPLAY "DEAD"
        STA     $00FB
        LDA     #$AD
        STA     $00FA
FIN:    JSR     SCANDS
        CLC
        BCC     FIN             ; UNCOND. JMP
SAFE:   LDA     #$5A            ; LOAD AND DISPLAY
        STA     $00FB           ; "SAFE"
        LDA     #$FE
        STA     $00FA
        LDA     #$00            ; TOTAL TO ZERO
        STA     $00F9
        BEQ     FIN             ; UNCOND. JMP
