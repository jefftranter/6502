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

; Note: The frequency of the 100 Hz timer signal is actually 98.304 Hz
; (+/- depending on crystal) so by counting 98 interrupts as a second
; it runs a little fast. We compensate for this by periodically
; dropping counts to get a more accurate time. You can adjust these
; for the actual clock frequency on your machine. Values used here
; were determined empirically on my machine.

;
; Interrupt service routine
;
ISR:    PHA             ; save A
        BIT     PORTA   ; Clears interrupt

        INC     JIFFIES ; Increment jiffies counter
        LDA     JIFFIES ; Get current value

        CMP     #98     ; reached 1 second?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset jiffies
        STA     JIFFIES
        INC     SECONDS ; increment seconds
        LDA     SECONDS
        CMP     #60     ; reached 1 minute?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset seconds
        STA     SECONDS
        INC     MINUTES ; increment minutes

; Time adjustment: Every minute drop 16 counts.

        LDA     JIFFIES
        SEC
        SBC     #16
        STA     JIFFIES

        LDA     MINUTES
        CMP     #60     ; reached 1 hour?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset minutes
        STA     MINUTES
        INC     HOURS   ; increment hours

; Time adjustment: Every hour drop 9 (TBD) counts.

        LDA     JIFFIES
        SEC
        SBC     #00
        STA     JIFFIES

        LDA     HOURS
        CMP     #24     ; reached 24 hours?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset hours
        STA     HOURS

DONE:   PLA             ; restore A
        RTI             ; and return
