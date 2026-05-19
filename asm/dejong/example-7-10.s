        .ORG    $16F0

; Initialization Routine

        LDA     #$4C            ; Set up NMI jump instruction.
        STA     $03FB           ; NMI interrupt routine
        LDA     #<CLOCK         ; Starts at $1700
        STA     $03FC           ; So we jump
        LDA     #>CLOCK         ; to that address.
        STA     $03FD
        BRK                     ; Jump to the monitor.

; NMI Clock Routine Starts Here

CLOCK:  PHA                     ; Save A.
        TYA                     ; Save Y
        PHA                     ; on the stack.
        TXA                     ; Save X
        PHA                     ; on the stack.
        DEC     $047F           ; Decrement the count-to-60 counter.
        BNE     OUT             ; Get out unless it reaches 60.
        LDA     #$3C            ; Reload the counter.
        STA     $047F
        LDA     #$B0            ; ASCII "0" into A.
        LDX     #$BA            ; Upper limit for ASCII digits.
        LDY     #$86            ; ASCII "6" into Y.
        INC     $047E           ; Increment seconds units.
        CPX     $047E           ; Compare with upper limit.
        BNE     DISPLAY         ; Branch to DISPLAY, then get out.
        STA     $047E           ; Clear seconds units.
        INC     $047D           ; Increment tens of seconds.
        CPY     $047D           ; Compare with "6".
        BNE     DISPLAY         ; Refresh display.
        STA     $047D           ; Clear tens of seconds.
        INC     $047C           ; Increment minutes units.
        CPX     $047C           ; Compare with upper limit.
        BNE     DISPLAY         ; Display time, then get out.
        STA     $047C           ; Clear minutes units.
        INC     $047B           ; Increment tens of minutes.
        CPY     $047B           ; Compare with "6".
        BNE     DISPLAY         ; Display time.
        STA     $047B           ; Clear tens of minutes.
        LDY     #$B2            ; ASCII "2" into Y.
        INC     $047A           ; Increment hours units.
        CPX     $047A           ; Compare with upper limit.
        BNE     TEST            ; When is time= 24 00 00?
        STA     $047A           ; Clear hours units.
        INC     $0479           ; Increment tens of hours.
TEST:   CPY     $0479           ; Is it 2?
        BNE     DISPLAY         ; Branch to DISPLAY.
        LDX     #$B4            ; ASCII "4" into X.
        CPX     $047A           ; Compare with hours units.
        BNE     DISPLAY         ; Branch to DISPLAY.
        STA     $0479           ; Clear tens of hours.
        STA     $047A           ; Clear hours units.
DISPLAY:
        LDX     #05             ; Display data by transferring
BRANCH: LDA     $0479,X         ; ASCII characters
        STA     $0422,X         ; from memory to the
        DEX                     ; screen page for the video monitor,
        BPL     BRANCH          ; using absolute indexed mode.
OUT:    PLA                     ; Restore X
        TAX                     ; from the stack.
        PLA                     ; Restore Y
        TAY                     ; from the stack.
        PLA                     ; Restore A from the stack.
        RTI                     ; Return to interrupted program.

