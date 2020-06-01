; Experiment 1
;
; Toggle the port A output lines
; With 2MHz clock,  1 cycle is two iterations of the loop (2 * 10)
; 2000000 / 20 = 100 kHz on PA0 line.
; Could do this in 9 cycles but want a round number.
; PA1 is 50 kHz, PA2 is 25 kHz etc.

       .org $0280
       .include "6522.inc"

        LDA #%11111111 ; Set port A to all outputs
        STA DDRA
;  Increment output to toggle all bits
        CLV
        LDX #$00
        STX PORTA
Loop:   INC PORTA,X             ; 7 cycles
        BVC Loop                ; 3 cycles
