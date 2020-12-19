; Read pushbutton status and set LED accordingly.
; Connect pushbutton to PA0 and LED to PA7.

        VIA      = $8000        ; 6522 VIA base address
        VIA_DDRA = VIA+3        ; DDRA register
        VIA_ORA  = VIA+1        ; ORA register

        .org     $1000          ; Start address

        lda      #$80
        sta      VIA_DDRA        ; Set port A7 to output, others input
loop:
        lda      VIA_ORA         ; Read port status
        and      #$01            ; Mask out bit 0 (pushbutton)
        beq      on              ; Branch if on
        lda      #$80            ; To turn LED off
        bne      led
on:
        lda      #$00            ; To turn LED on
led:
        sta      VIA_ORA         ; Write to output register
        jmp      loop            ; Repeat forever
