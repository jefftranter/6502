; Code for Morse Code Oscillator. Chapter 3.

; I have confirmed this program works on a real KIM-1 - Jeff Tranter

        .ORG    $0000

PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703
STOP    = $1C00
NMIV    = $17FA

; First we must set up the stop key so it will work properly

START:  LDA     z:ZERO          ; This cell will contain "00"
        STA     NMIV
        LDA     z:ONEC          ; This one holds "1C"
        STA     NMIV+1

; Now we make A0 be input (and the rest of port A to be output) and we
; make B0 be output (and the rest of port B be output also)

       LDA   z:K2               ; This cell holds "FE"
       STA   DIRA               ; Direction A
       LDA   z:ALLONES          ; This cell holds "FF" - all ones
       STA   DIRB               ; Direction B

; We clear port A to have all zeros in it. Then we look at A0 to see
; if it has changed to a one indicating that the switch was closed.
; If not we loop back to try again.

       LDA   z:ZERO
       STA   PORTA              ; Clear port A
LOOP:  LDA   PORTA
       BEQ   LOOP               ; Was it all zeros?

; At this point we have found the switch closed so we toggle the
; speaker. Then we set a value in COUNTER and in the loop called
; WAIT we count down until that counter goes to zero. Then we go
; back and see if the switch is still closed.

       INC   PORTB              ; Toggle speaker
       LDA   z:CONST            ; Determines how long between toggles
       STA   z:COUNTER
WAIT:  DEC   z:COUNTER
       BPL   WAIT
       JMP   LOOP

; The constants we need for this program can be stored right after
; the JMP LOOP instruction. They are:

ZERO:  .byte <STOP
ONEC:  .byte >STOP
ALLONES:
       .byte $FF
K2:    .byte $FE
CONST: .byte $3B                ; That will do for a starting value

; The only variable we use here can go right after the last constant:

COUNTER:
       .byte $00                ; Will do for a filler value to begin
                                ; the program with.
