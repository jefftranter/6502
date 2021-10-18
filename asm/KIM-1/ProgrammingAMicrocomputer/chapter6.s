; Code for Combination Lock. Chapter 6.

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703

; Usual initialization of stop key and stack pointer. Then we make
; A7-A4 be output, A3-A0 be input. We clear PORTA and make PORTB be
; output.

START:  LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
        LDX     #$FF
        TXS                     ; Set stack pointer
        LDA     #$F0
        STA     DIRA            ; 1701 gets set
        LDA     #$00
        STA     PORTA           ; Clear port A
        LDA     #$FF
        STA     DIRB            ; 1703 gets made output

; The main program consists of four calls to a subroutine named SUB
; and then a loop back to the beginning of the program.

        LDY     #$00
        JSR     SUB             ; State A
        LDY     #$01
        JSR     SUB             ; State B
        LDY     #$02
        JSR     SUB             ; State C
        LDY     #$03
        JSR     SUB             ; State D
        JMP     START

; The subroutine SUB gets a light pattern for this state and displays
; it. Then it waits for a zero set of keys and *then* a non-zero set.
; Once a key has been pressed we give the user about 1/4 of a second
; to close any other keys.

SUB:    LDA     LIGHT,Y         ; This is a table of patterns
        STA     PORTB           ; Set the lights
CLEAR:  LDA     PORTA
        BNE     CLEAR           ; Wait for clear keyboard
HOLD:   LDA     PORTA
        BEQ     HOLD            ; Wait for some input
        LDX     #$64
OUTER:  LDA     #$FF
        STA     z:COUNT
INNER:  DEC     z:COUNT         ; Inner
        BNE     INNER           ;       loop
        DEX
        BNE     OUTER

; He has had enough time to close all the keys he is going to close
; so we get PORTA and compare it with the required combination stored
; in the table COMB. If it matches we go to the next state (return
; to the main program). If it doesn't match we reset to state A by
; jumping to START.

        LDA     PORTA
        CMP     COMB,Y          ; Indexed
        BNE     START
        RTS                     ; Return from subroutine

; The tables we need are:

LIGHT:  .BYTE   $08             ; Light A
        .BYTE   $04             ;       B
        .BYTE   $02             ;       C
        .BYTE   $01             ;       D
COMB:   .BYTE   $03
        .BYTE   $06             ; 368
        .BYTE   $08
        .BYTE   $00

; The only variable is:

COUNT:  .BYTE   $00             ; Clear to start with
