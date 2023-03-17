; DHT11/DHT21/DHT22 temperature/humidity sensor demo.
;
; Connect sensor module data line to VIA PA0 (with pullup resistor if
; not present on module).
; Timing assumes CPU running at 2 MHz.
;
; Some of the logic came from the Arduino implementation here:
;  https://github.com/adafruit/DHT-sensor-library/blob/master/DHT.cpp
;
; Jeff Tranter <tranter@pobox.com>

; 6522 Chip registers
        VIA     = $8000         ; 6522 VIA base address
        PORTA   = VIA+1         ; ORA register
        DDRA    = VIA+3         ; DDRA register
; External routines
        WAIT    = $FEA8         ; ROM delay routine

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

; Should give up here if above timed out indicating timeout waiting for start signal low pulse.

        jsr     ExpectHigh
        sta     count+1

; Should give up here if above timed out indicating timeout waiting for start signal high pulse.


; ALTERNATE VERSION FOR DEBUG - START

        ldy     #0
fst1:   lda     PORTA           ; (4)
        sta     count+2,y       ; (5)
        iny                     ; (2)
        bne    fst1             ; (3)

        ldy     #0
fst2:   lda     PORTA           ; (4)
        sta     count+$100+2,y  ; (5)
        iny                     ; (2)
        bne    fst2             ; (3)

        ldy     #0
fst3:   lda     PORTA           ; (4)
        sta     count+$200+2,y  ; (5)
        iny                     ; (2)
        bne    fst3             ; (3)

        ldy     #0
fst4:   lda     PORTA           ; (4)
        sta     count+$300+2,y  ; (5)
        iny                     ; (2)
        bne    fst4             ; (3)

        brk

; 14 cycles @ 0.5 uS per cycle - 7.5 uS
; Pulses: 50 / 26-28 or 70 us
; Loop cycles: 6.7 / 3.6 or 9.3
; Check if pullup is present and adequate

; ALTERNATE VERSION FOR DEBUG - END

; Now read the 40 bits sent by the sensor. Each bit is sent as a 50
; microsecond low pulse followed by a variable length high pulse. If
; the high pulse is ~28 microseconds then it's a 0 and if it's ~70
; microseconds then it's a 1.

        ldy     #0
poll:   jsr     ExpectLow
        sta     count+2,y
        iny
        jsr     ExpectHigh
        sta     count+2,y
;       cpy     #40
        cpy     #45
        bne     poll

        brk

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

; Stores data for pulse length counts

count:  .res    $500

        .end
