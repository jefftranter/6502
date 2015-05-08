; Experiment 6
;
; Write to 4 bit D/A converter on port A.
; With 2MHz CPU clock sine wave is 7.245 KHz

       .org $0280
       .include "6522.inc"

       SAMPLES = 16    ; Number of samples in table

       LDA #%00001111  ; Set low 4 bits of port A to all outputs
       STA DDRA
START: 
       LDX #0
LOOP:
       LDA SINE,X      ; Get value. Select SINE, RAMP, or TRIANGLE
       STA PORTA       ; Write to port
       NOP             ; 2 Can add more NOPS to slow down frequency
       INX             ; increment index
       CPX #SAMPLES    ; are we at end?
       BNE LOOP        ; if not, continue
       JMP START       ; otherwise restart

; Sine values calculated using spreadsheet
SINE:
       .byte 7,10,12,14,15,14,12,10,7,4,2,0,0,0,2,4

RAMP:
       .byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

TRIANGLE:
       .byte 0,2,4,6,8,10,12,14,15,14,12,10,8,6,4,2
