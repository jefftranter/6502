; Real-Time Clock Example
;
; Uses the clock circuit and 6820/6821 PIA on the OSI 610 board to
; generate interrupts at 10 ms intervals. An interrupt service routine
; increments counters for time including hours, minutes, and seconds.
;
; The following hardware needs to be set up:
;
; 1. You need an OSI 610 expander board fully populated with memory.
; The program location could be adjusted depending on the memory
; available; the program assumes 32K.
; 2. Jumper pad from the 6820 IRQ line (near pin 38) to the /IRQ
; line (next to it and to the right when facing the front of the
; board).
; 3. Connect the 10mS timer signal (pad from U10 pin 9) to the pad for
; signal CA1 (the rightmost of the four pads near it).
;
; There is a Basic program provided in the file time.bas that can also
; be run to show how the clock runs even while Basic is executing. To
; ensure that Basic does not wipe out the clock program, from cold
; start enter a value of 30000 or less to the MEMORY SIZE? prompt. The
; Basic program includes the machine language code and is
; self-contained.
;
; The timer hardware is not exactly 10 ms, so the clock is not
; particularly accurate but could be calibrated in software to improve
; accuracy.
;
; This version count 100ths of seconds, seconds, minutes, and hours.
; Once it runs, it returns and is all interrupt driven.
;
; There is a risk of clobbering the IRQ vector because it is set to
; $01C0 which is in the stack (programmed in ROM so we can't change it
; at run time).

        .org    $7530   ; Start of reserved memory if 30000 was entered for MEMORY SIZE?

; 6820/6821 PIA Chip registers

        PORTA   = $C000 ; Peripheral Register A
        DDRA    = $C000 ; Data Direction Register A
        CREGA   = $C001 ; Control Register A
        PORTB   = $C002 ; Peripheral Register B
        DDRB    = $C002 ; Data Direction Register b
        CREGB   = $C003 ; Control Register b

        IRQ     = $01C0 ; IRQ vector

JIFFIES:        .res 1  ; 100ths of seconds
SECONDS:        .res 1  ; seconds
MINUTES:        .res 1  ; minutes
HOURS:          .res 1  ; hours

;
; Initialization routine
;
INIT:   SEI             ; Mask interrupts
        LDA     #$4C    ; JMP ISR instruction
        STA     IRQ     ; Store at interrupt vector
        LDA     #<ISR   ; Low byte
        STA     IRQ+1
        LDA     #>ISR   ; Hgh byte
        STA     IRQ+2

        LDA     #0      ; Set clock values to all zeroes
        STA     JIFFIES
        STA     SECONDS
        STA     MINUTES
        STA     HOURS

        LDA     #%00000101 ; Set PIA port A for interrupt when CA1 goes low.
        STA     CREGA   ; Write to control register

        CLI             ; Enable interrupts
        RTS             ; Done, return

;
; Interrupt service routine
;
ISR:    PHA             ; save A
        BIT     PORTA   ; Clears interrupt

        LDA     JIFFIES ; Increment jiffies counter
        CLC
        ADC     #1
        STA     JIFFIES

; Note: Frequency of 100 Hz timer signal is actually 98.304 Hz (+/-
; depending on crystal). Can tweak the number below if your system is
; slightly different. Could make a fine adjustment, say every minute
; or every hour, to make timer even more accurate over the long term.

        CMP     #98     ; reached 1 second?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset jiffies
        STA     JIFFIES
        LDA     SECONDS ; increment seconds
        CLC
        ADC     #1
        STA     SECONDS
        CMP     #60     ; reached 1 minute?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset seconds
        STA     SECONDS
        LDA     MINUTES ; increment minutes
        CLC
        ADC     #1
        STA     MINUTES
        CMP     #60     ; reached 1 hour?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset minutes
        STA     MINUTES
        LDA     HOURS   ; increment hours
        CLC
        ADC     #1
        STA     HOURS
        CMP     #24     ; reached 24 hours?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset hours
        STA     HOURS

DONE:   PLA             ; restore A
        RTI             ; and return
