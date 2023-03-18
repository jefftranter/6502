; DHT11/DHT21/DHT22 temperature/humidity sensor demo.
;
; Connect sensor module data line to VIA PA0 (with pullup resistor if
; not present on module).
; Timing assumes CPU running at 2 MHz.
;
; Some of the logic came from the Arduino implementation here:
;  https://github.com/adafruit/DHT-sensor-library/blob/master/DHT.cpp
;
; TODO:
; - Finish implementation
; - Add support for DHT22
; - See if it can also run at 1 MHz
;
; Jeff Tranter <tranter@pobox.com>

; 6522 Chip registers
        VIA     = $8000         ; 6522 VIA base address
        PORTA   = VIA+1         ; ORA register
        DDRA    = VIA+3         ; DDRA register

; Constants
        CR      = $0D           ; Carriage Return
        LF      = $0A           ; Line Feed

; External routines
        WAIT    = $FEA8         ; ROM delay routine
        IMPRINT = $EC5E         ; Embedded string printer

        .org    $1000           ; Start address

; Code

START:  cld                     ; Ensure in binary mode
        ldx     #$FF            ; Set up stack
        txs

loop:   lda     #%11111111      ; Set data line initially high
        sta     PORTA

        lda     #%00000001      ; Set PA0 as output
        sta     DDRA

        lda     #%11111110      ; Set data line low
        sta     PORTA

;       lda     #$1B            ; Delay 1.1 ms (DHT21/DHT22)
        lda     #$7C            ; Delay 20 ms (DHT11)
        jsr     WAIT

        lda     #%11111111      ; Set data line high
        sta     PORTA

        lda     #%00000000      ; Set PA0 as input
        sta     DDRA

        lda     #$04            ; Delay 55us to let sensor pull data line low.
        jsr     WAIT

; First expect a low signal for ~80 microseconds followed by a high
; signal for ~80 microseconds again.

        jsr     ExpectLow
        sta     count
        jsr     ExpectHigh
        sta     count+1

; Now sample and store the levels of the data pulses.
; They are very short so we can only record them in a tight loop and analyze them later.
; Loop below takes 14 clock cycles @ 0.5 uS per cycle = 7.5 uS.
; Data pulses: 50 us low followed by 26-28 (indicating 0) or 70 us (indicating 1) high.
; Typically see 3 or 4 samples for a 0 and 10 or 11 samples for a 1.
; 3 times 256 samples should be enough to capture all the data samples (40 data bits).

        ldy     #0
fst1:   lda     PORTA           ; (4)
        sta     count+2,y       ; (5)
        iny                     ; (2)
        bne     fst1            ; (3)

        ldy     #0
fst2:   lda     PORTA
        sta     count+$100+2,y
        iny
        bne     fst2

        ldy     #0
fst3:   lda     PORTA
        sta     count+$200+2,y
        iny
        bne     fst3

; Now analyze the samples.

; First two samples should be for for start signal consisting of a low
; of 80 us and high for 80 msec. If either zero, it timed out waiting
; for the start signal and the rest of the data is invalid (most
; likely means there is no sensor connected).

        lda     count
        beq     timerr
        lda     count+1
        beq     timerr
        bne     okay1
timerr: jsr     IMPRINT
        .byte   "Timeout waiting for start signal", CR, LF, 0
okay1:

; Now analyze data bit samples.
; Each bit starts with 50us low (typically 7 or 8 samples).
; Then for a 0 26-28 us high (typically 3 or 4 samples)
; or for 1 70 us high (typically 10 or 11 samples)
; There should be 40 bits in total.
; e.g.
; FE FE FE FE FE FE FF FF FF FF -> 0
; FE FE FE FE FE FE FE FE FF FF FF -> 0
; FE FE FE FE FE FE FE FE FF FF FF FF FF FF FF FF FF FF -> 1
; FE FE FE FE FE FE FE FE FF FF FF FF FF FF FF FF FF FF -> 1
; FE FE FE FE FE FE FE FE FF FF FF -> 0
; etc.
; Go through 40 samples counting the lengths of each high pulse.
; e.g. for above
; 4 3 10 10 3 ...

; Now go through list and decide if each is a 0 or 1 bit
; Will call <= 7 a 0, > 7 a 1
; e.g. for above
; 0 0 1 1 0 ...

; Now convert the 40 bits into 5 bytes of data
; e.g. 0011 0010 0000 0000 0001 0100 0000 0100 0100 1010
; becomes: 32 00 14 04 4A

; Now do checksum check on the data: sum of first 4 bytes (modulo 256) should equal 5th byte.
; Otherwise report error.

; Now calculate and display humidity

; Now calculate and display temperature

        brk

; Don't read again for at least 2 seconds.

        jsr     DELAY           ; Delay 2 seconds
        jsr     DELAY

        jmp     loop            ; Repeat

; DELAY: Fixed delay of approx. 1 sec (2 MHz clock).
; Registers changed: none

DELAY:  pha                     ; Save registers
        txa
        pha
        tya
        pha
        ldy     #$00
outer:  ldx     #$00
inner:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        dex
        bne     inner
        dey
        bne     outer
        pla                     ; Restore registers
        tay
        pla
        tax
        pla
        rts


; ExpectHigh: Return (in A) count of loop cycles spent at high level
; or 0 if it times out waiting for level to change.
; Registers changed: A, X.

ExpectHigh:
        ldx     #0              ; Zero count
        lda     #%00000001      ; Bit to test
poll1:  bit     PORTA           ; Read data port
        beq     ex1             ; No longer at expected level
        inx                     ; Increment count
        bne     poll1           ; Continue polling if we have not timed out
ex1:    txa                     ; Put result in A
        rts

; ExpectLow: Return (in A) count of loop cycles spent at low level
; or 0 if it times out waiting for level to change.
; Registers changed: A, X.

ExpectLow:
        ldx     #0              ; Zero count
        lda     #%00000001      ; Bit to test
poll2:  bit     PORTA           ; Read data port
        bne     ex2             ; No longer at expected level
        inx                     ; Increment count
        bne     poll2           ; Continue polling if we have not timed out
ex2:    txa                     ; Put result in A
        rts

; Data for pulse length counts

count:  .res    770             ; 3 * 256 + 2

        .end
