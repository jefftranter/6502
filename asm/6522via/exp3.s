; Experiment 3
;
; Set Timer 2 to pulse counting.
; Read pulses on PB6 line.
; Output value to screen.
; Timer counts down so for fun we complement the bits to get a count that goes up.
       .org $0280
       .include "6522.inc"

        ECHO    = $FFEF ; Woz monitor
        PRBYTE  = $FFDC ; Woz monitor

        CR      = $0D   ; Carriage return

        LDA #$00
        STA IER             ; disable all interrupts
        LDA #%00100000
        STA ACR             ; Set to T2 pulse count mode
        LDA #$FF
        STA T2CL            ; Set low byte of count
        LDA #$FF
        STA T2CH            ; Set high byte of count
        CLC
        LDA #CR
        JSR ECHO            ; print newline
LOOP:
        LDA T2CL
SAME:
        CMP T2CL            ; wait for LSB to change
        BEQ SAME
        LDA T2CH            ; get high byte of count
        EOR #$FF            ; complement the bits
        JSR PRBYTE          ; print it
        LDA T2CL            ; get low byte of count
        EOR #$FF            ; complement the bits
        JSR PRBYTE          ; print it
        LDA #CR
        JSR ECHO            ; print newline
        BCC LOOP            ; forever

