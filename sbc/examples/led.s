; Toggle LED connected to VIA port A
; Toggles all port lines with a binary pattern.
; Connect LED to any port A line (PA7 will toogle at approximately 2
; Hz)

        VIA      = $8000        ; 6522 VIA base address
        VIA_DDRA = VIA+3        ; DDRA register
        VIA_ORA  = VIA+1        ; ORA register

        .org     $1000          ; Start address

        ldx      #$FF
        stx      VIA_DDRA       ; Set port A to all outputs

        ldx      #$00           ; Initial data pattern
loop:
        stx      VIA_ORA        ; Write to output register
        inx                     ; Increment pattern

        ldy      #$FF           ; Delay loop
delay:
        nop
        nop
        nop
        nop
        nop
        dey
        bne      delay

        jmp      loop           ; Repeat forever
