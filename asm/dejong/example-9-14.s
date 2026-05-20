T1LL    =       $C704
T1LH    =       $C705
ACR     =       $C70B
IER     =       $C70E

        .ORG    $183F

        LDA     #$40            ; Initialize T1 to run free,
        STA     ACR             ; generating interrupts.
        LDA     #$C0            ; Load interrupt enable register
        STA     IER             ; to produce interrupts from T1.
        LDA     #$77            ; Set up the time interval
        STA     T1LL            ; to play a note near
        LDA     #$07            ; middle C.
        STA     T1LH            ; Timing begins with this instruction.
        CLI                     ; Allow interrupts to start.
        CLC                     ; Loop here to listen to music.
LOITER: BCC     LOITER

; T1 Timer Interrupt Routine

        STA     $C030           ; Toggle Apple speaker.
        LDA     T1LL            ; Clear the T1 interrupt flag.
        LDA     $45             ; Restore the accumulator.
        RTI

; Load indirect jump vector for
; Apple IRQ routine before running.
; Load $57 into $03FE
; Load $18 into $03FF
