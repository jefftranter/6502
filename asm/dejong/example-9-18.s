NUMB    =       $19
TIME    =       $1D
T1CL    =       $C704
T1CH    =       $C705
T1LL    =       $C706
T2CL    =       $C708
T2CH    =       $C709
ACR     =       $C70B
IFR     =       $C70D
IER     =       $C70E

        .ORG    $1900

; *****************
; Interrupt Routine

        INC     TIME            ; Increment a two-byte
        BNE     BR1             ; counter for each
        INC     TIME+1          ; T1 interrupt.
BR1:    LDA     T1CL            ; Clear T1 interrupt flag.
        LDA     $45             ; Restore accumulator.
        RTI

; ****************
; BASIC Subroutine

        CLD                     ; Clear the decimal mode.
        LDX     #$FF
        LDA     #$60            ; Set up T1 to run free
        STA     ACR             ; and T2 to count pulses.
        LDA     #$FE            ; Set up the T1 timer
        STA     T1LL            ; with $FFFE.
        LDA     #$C0            ; Enable IRQ from T1.
        STA     IER
        LDA     #$00            ; Clear two-byte
        STA     TIME            ; interrupt counter.
        STA     TIME+1
        STA     T2CL            ; Start with 0 in T2 to
        STA     T2CH            ; detect the zeroth event.
        LDA     #$20            ; Set up mask to test T2
WAIT:   BIT     IFR             ; interrupt flag, IFR5.
        BEQ     WAIT            ; Wait for zeroth event.
        STX     T1CH            ; Start the timer.
        CLI                     ; Make sure IRQ is no masked.
        LDA     NUMB            ; Reload T2 with
        STA     T2CL            ; number of events.
        LDA     NUMB+1
        STA     T2CH
        LDA     #$20            ; Set up mask for IFR5,
LOAF:   BIT     IFR             ; the T2 flag.
        BEQ     LOAF            ; Wait for all the events.
        LDY     T1CL            ; Read the low byte of T1.
        LDX     T1CH            ; Read the high byte of T1.
        SEI                     ; Mask interrupts.
        CPY     #$04            ; Adjust for reading high byte after
        BCS     ARND            ; reading the low byte.
        INX                     ; Make correction to the high byte.
        BNE     ARND            ; Does interrupt counter need
        SEC                     ; correction? Yes, decrement it
        LDA     TIME            ; by subtracting one.
        SBC     #$01
        STA     TIME
        LDA     TIME+1
        SBC     #$00
        STA     TIME+1
ARND:   STY     TIME-2          ; Store low byte.
        STX     TIME-1          ; Store high byte.
        LDA     #$FE            ; Find the low count.
        SBC     TIME-2
        STA     TIME-2
        LDA     #$FF            ; Find the high count.
        SBC     TIME-1
        STA     TIME-1          ; Store it.
        RTS

; Load $03FE and $03FF with $00 and
; $19, respectively, to produce the
; indirect jump to the IRQ routine.

