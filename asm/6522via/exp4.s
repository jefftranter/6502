; Experiment 3
;
; Measure frequency on PB6 input.
; Use Timer 2 to count pulses.
; User Timer 1 to set time period.
; Output value to screen.
; Enhancement would be to make this interrupt driven but want to keep it simple for now.

; example
; input was 100KHz
; Counted $13AE pulses = 5038 * 20 Hz = 10,076 Hz
; If wanted to convert to Hz, good sample are might be 16,32, 64 since could multiply by shifting it.
; input was an audio signal generator and then through a 74LS04 inverter to make sure levels were TTL.

    .org $0280
    .include "6522.inc"

    ECHO     = $FFEF    ; Woz monitor
    PRBYTE   = $FFDC    ; Woz monitor
    CR       = $0D      ; Carriage return
    COUNT    = 49998    ; 20 Hz sample rate

    LDA #$00
    STA IER             ; disable all interrupts

    LDA #%00100000
    STA ACR             ; T1 single shot PB7 disabled, T2 pulse count mode

LOOP:
    LDA #<COUNT         ; Set count for T1
    STA T1CL            ; Set low byte of count
    LDA #>COUNT
    STA T1CH            ; Set high byte of count

    LDA #$FF            ; Set count for T2
    STA T2CL            ; Set low byte of count
    LDA #$FF
    STA T2CH            ; Set high byte of count

WAIT:
    LDA T1CH            ; wait for timer T1 to count down to zero
    BNE WAIT
    LDA T1CL
    BNE WAIT

    LDA T2CH            ; get high byte of T2 count
    EOR #$FF
    JSR PRBYTE          ; print it
    LDA T2CL            ; get low byte of T2 count
    EOR #$FF
    JSR PRBYTE          ; print it
    LDA #CR
    JSR ECHO            ; print newline
    JMP LOOP            ; repeat forever
