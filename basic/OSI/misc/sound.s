; Assembly language source corresponding to code in sound.bas.

DAC     = $DF00         ; Sound DAC

        * =  $0C00      ; Start address

; Main program

start   lda #8          ; Initialize number of hi/lo cycles
        sta cycles
toggle  lda #$00        ; Write zero to sound DAV
        sta DAC
        jsr delay       ; And delay
        lda #$FF        ; Write all ones to sound DAC
        sta DAC
        jsr delay       ; And delay
        dec cycles      ; Decrement number of cycles
        bne toggle      ; Continue if not zero
        dec interv      ; Reduce time between cycles
        lda interv      ; Get new interval time
        sta del         ; Save as delay value
        bne start       ; Continue if not zero
        rts             ; Else done, return

        .org $0D00

; Delay subroutine

delay   ldx del         ; Get delay constant
l1      ldy #4          ; Inner delay loop
l2      dey
        bne l2
        dex             ; Outer delay loop
        bne l1
        rts

; Variables

cycles  .byte 0         ; Number of hi/lo cycles
interv  .byte 0         ; Interval between cycles
del     .byte 0         ; Delay time value
