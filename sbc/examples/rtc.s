; Experiment 5
;
; Timer interrupt driven time of day clock routine
; Set Timer 1 to generate continuous interrupts.
; Interrupt service routine will increment counter.
;
; See http://www.6502.org/tutorials/interrupts.html
;
; This version count 100ths of seconds, seconds, minutes, and hours.

; Once it runs it returns and is all interrupt driven.
; Could use from BASIC and PEEK the time values. Have to make sure
; program did not use memory used by BASIC.  Also risk of clobbering IRQ
; vector because it is set to $0100 which is in the stack (programmed in
; EEPROM so we can't change it at run time).
;
; Try running program time.bas to display the time.

    .org $7000

; 6522 Chip registers

    PORTB    = $8000
    PORTA    = $8001
    DDRB     = $8002
    DDRA     = $8003
    T1CL     = $8004
    T1CH     = $8005
    T1LL     = $8006
    T1LH     = $8007
    T2LL     = $8008
    T2CL     = $8008
    T2CH     = $8009
    SR       = $800A
    ACR      = $800B
    PCR      = $800C
    IFR      = $800D
    IER      = $800E
    ORAX     = $800F

    ECHO     = $FF3B    ; MONCOUT
    COUNT    = 19998    ; 100 Hz sample rate (10 msec interrupts) assuming 2 MHz CPU clock
    IRQ      = $0100    ; IRQ vector

    JIFFIES  = $7103    ; 100ths of seconds
    SECONDS  = $7102    ; counts seconds
    MINUTES  = $7101    ; counts minutes
    HOURS    = $7100    ; counts hours

    SEI                 ; mask interrupts
    LDA #$4C            ; JMP ISR instruction
    STA IRQ             ; Store at interrupt vector
    LDA #<ISR
    STA IRQ+1
    LDA #>ISR
    STA IRQ+2

    LDA #0              ; Set clock to zero
    STA JIFFIES
    STA SECONDS
    STA MINUTES
    STA HOURS

    LDA #%11000000
    STA IER             ; enable T1 interrupts

    LDA #%01000000
    STA ACR             ; T1 continuous, PB7 disabled

    CLI                 ; enable interrupts

    LDA #<COUNT         ; Set count for T1
    STA T1CL            ; Set low byte of count
    LDA #>COUNT
    STA T1CH            ; Set high byte of count
    RTS                 ; Done

; Interrupt service routine
ISR:
    PHA                 ; save A

    BIT T1CL            ; Clears interrupt

    LDA JIFFIES
    CLC
    ADC #1
    STA JIFFIES
    CMP #100            ; reached 1 second?
    BNE DONE            ; if not, done for now

    LDA #'S'            ; for test purposes
    JSR ECHO

    LDA #0              ; reset jiffies
    STA JIFFIES
    LDA SECONDS         ; increment seconds
    CLC
    ADC #1
    STA SECONDS
    CMP #60             ; reached 1 minute?
    BNE DONE            ; if not, done for now

    LDA #'M'            ; for test purposes
    JSR ECHO

    LDA #0              ; reset seconds
    STA SECONDS
    LDA MINUTES         ; increment minutes
    CLC
    ADC #1
    STA MINUTES
    CMP #60             ; reached 1 hour?
    BNE DONE            ; if not, done for now

    LDA #'H'            ; for test purposes
    JSR ECHO

    LDA #0              ; reset minutes
    STA MINUTES
    LDA HOURS           ; increment hours
    CLC
    ADC #1
    STA HOURS
    CMP #24             ; reached 24 hours?
    BNE DONE            ; if not, done for now

    LDA #0              ; reset hours
    STA HOURS

DONE:
    PLA                 ; restore A
    RTI                 ; and return
