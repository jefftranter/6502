; Code for Morse Code Oscillator, Chapter 3.

        .ORG    $0000

; First we must set up the stop key so it will work properly

START:  LDA     z:ZERO          ; This cell will contain "00"
        STA     $17FA
        LDA     z:ONEC          ; This one holds "1C"
        STA     $17FB

; Now we make A0 be input (and the rest of port A to be output) and we
; make B0 be output (and the rest of port B be output also)

       LDA   z:K2               ; This cell holds "FE"
       STA   $1701              ; Direction A
       LDA   z:ALLONES          ; This cell holds "FF" - all ones
       STA   $1703              ; Direction B

; We clear port A to have all zeros in it. Then we look at A0 to see
; if it has changed to a one indicating that the switch was closed.
; If not we loop back to try again.

       LDA   z:ZERO
       STA   $1700              ; Clear port A
LOOP:  LDA   $1700
       BEQ   LOOP               ; Was it all zeros?

; At this point we have found the switch closed so we toggle the
; speaker. Then we set a value in COUNTER and in the loop called
; WAIT we count down until that counter goes to zero. Then we go
; back and see if the switch is still closed.

       INC   $1702              ; Toggle speaker
       LDA   z:CONST            ; Determines how long between toggles
       STA   z:COUNTER
WAIT:  DEC   z:COUNTER
       BPL   WAIT
       JMP   LOOP

; The constants we need for this program can be stored right after
; the JMP LOOP instruction. They are:

ZERO:  .byte $00
ONEC:  .byte $1C
ALLONES:
       .byte $FF
K2:    .byte $FE
CONST: .byte $3B                ; That will do for a starting value

; The only variable we use here can go right after the last constant:

COUNTER:
       .byte $00                ; Will do for a filler value to begin
                                ; the program with.
