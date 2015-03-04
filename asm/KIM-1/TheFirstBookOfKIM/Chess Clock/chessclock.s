        SCANDS  = $1F1F
        GETKEY  = $1F6A

        .ORG    $0200

        LDA     #$00            ; ZERO ALL OF PAGE ZERO
        TAX
ZERO:   STA     a:$0000,X
        INX
        BNE     ZERO
DISP:   JSR     SCANDS          ; DISPLAY ZEROS
        JSR     GETKEY          ; KEY PRESSED?
        CMP     #$02            ; KEY # 2?
        BNE     DISP            ; NO, WAIT TILL 2 DOWN
LOOP:   LDA     #$01            ; FLAG TO 1
        STA     $00D4           ; (CLOCK *1 TO RUN)
        JSR     TIME            ; GET CLOCK RUNNING
        JSR     SAVE            ; SAVE TIME ON DISPLAY
        LDA     #$02            ; FLAG TO 2
        STA     $00D4           ; (CLOCK *2 TO RUN)
        JSR     TIME            ; GET OTHER CLOCK RUNNING
        CLC                     ; ...INCREMENT MOVE
        LDA     $00F9           ; NUMBER...
        ADC     #$01
        STA     $00F9
        JSR     SAVE            ; SAVE CLOCK 2 TINE
        JMP     LOOP            ; BACK TO CLOCK ~ 1
; XXXX SAVE TIME INDICATED SUBROUTINE XXXX
SAVE:   LDA     #$02            ; CLOCK * 2?
        CMP     $00D4
        BNE     CLK1            ; NO, STORE FOR CLOCK # 1
        LDA     $00FB           ; ..STORE VALUES FOR
        STA     $00D2           ; CLOCK * 2 IN 0002
        LDA     $00FA           ; AND 0003
        STA     $00D3
        LDA     $00D0           ; ..LOAD DISPLAY WITH
        STA     $00FB           ; VALUES FOR CLOCK # 1
        LDA     $00D1
        STA     $00FA
        RTS
CLK1:   LDA     $00FB           ; ..STORE VALUES FOR
        STA     $00D0           ; CLOCK * 1 IN 00D0
        LDA     $00FA           ; AND 0001
        STA     $00D1
        LDA     $00D2           ; ..LOAD DISPLAY WITH
        STA     $00FB           ; VALUES FOR CLOCK * 2
        LDA     $00D3
        STA     $00FA
        RTS

        .RES    7

; CLOCK ADVANCE SUBROUTINE

TIME:   SED                     ; SET DECIMAL MODE
        LDA     #$04            ; TIME MULTIPLIER TO 4
        STA     $00D5
LOAD:   LDA     #$F0            ; SET TIMER
        STA     $1707
LITE:   JSR     SCANDS          ; DISPLAY CLOCK
        JSR     GETKEY          ; GET KEYBOARD ENTRY
        CMP     $00D4           ; EQUAL TO FLAG?
        BNE     WAIT            ; NO TIME OUT THEN UPDATE
        RTS                     ; YES, RETURN FROM SUBR.
WAIT:   BIT     $1707           ; TIME DONE?
        BPL     LITE            ; NOT YET
        DEC     $00D5           ; DECREMENT TIME MULT.
        BNE     LOAD            ; NOT ZERO, RESET TIMER
        LDA     #$BF            ; LAST LITTLE BIT OF TIME
        STA     $1706           ; INTO TIMER
TINY:   BIT     $1707           ; DONE?
        BPL     TINY            ; NO
        CLC                     ; ONE SECOND ADDED
        LDA     $00FA           ; TO CLOCK..
        ADC     #$01
        STA     $00FA           ; (CENTER TWO DIGITS)
        CMP     #$60            ; A MINUTE UP?
        BNE     NOMN            ; NOT YET
        SEC                     ; YES, SEC. TO ZERO
        LDA     #$00
        STA     $00FA
NOMN:   LDA     $00FB           ; ..MINUTES INCREMENTED
        ADC     #$00            ; IF CARRY SET
        STA     $00FB
        JMP     TIME            ; LOOP
