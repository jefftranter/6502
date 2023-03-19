; DHT11/DHT21/DHT22 temperature/humidity sensor demo.
;
; Connect sensor module data line to VIA PA0 (with pullup resistor if
; not present on module).
; Timing assumes CPU running at 2 MHz.
;
; Sample output:
;
; Starting (press a key to stop)
; Humidity: 47.0%  Temperature: 20.4C
;
; Some of the logic came from the Arduino implementation here:
;  https://github.com/adafruit/DHT-sensor-library/blob/master/DHT.cpp
;
; TODO:
; - Add support for DHT22.
; - Refactor some repetitive code.
; - See if I can get it work at 1 MHz clock speed.
;
; Jeff Tranter <tranter@pobox.com>

; Define one of the symbols below for the sensor type used
        DHT11   = 1
;       DHT22   = 1

.if .defined(DHT11) .and .defined(DHT22)
.error "Only define one sensor type"
.endif
.if (.not .defined(DHT11)) .and (.not .defined(DHT22))
.error "Must define sensor type"
.endif

; 6522 Chip registers
        VIA     = $8000         ; 6522 VIA base address
        PORTA   = VIA+1         ; ORA register
        DDRA    = VIA+3         ; DDRA register

; Constants
        CR      = $0D           ; Carriage Return

; External routines
        WAIT    = $FEA8         ; ROM delay routine
        IMPRINT = $EC5E         ; Embedded string printer
        PRHEX   = $EC98         ; Print one hex digit
        MONCOUT = $FF3B         ; Print a character
        MONRDKEY = $FF4A        ; Console in routine

        .org    $1000           ; Start address

; Page zero locations used
        PTR     = $20           ; Address for indirect addressing

; Code

START:  cld                     ; Ensure in binary mode
        ldx     #$FF            ; Set up stack
        txs

        jsr     IMPRINT
        .byte   CR,"Starting (press a key to stop)", CR,0

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
        sta     start1
        jsr     ExpectHigh
        sta     start2

; Now sample and store the levels of the data pulses.
; They are very short so we can only record them in a tight loop and analyze them later.
; Loop below takes 14 clock cycles @ 0.5 uS per cycle = 7.5 uS.
; Data pulses: 50 us low followed by 26-28 (indicating 0) or 70 us (indicating 1) high.
; Typically see 3 or 4 samples for a 0 and 10 or 11 samples for a 1.
; 3 times 256 samples should be enough to capture all the data samples (40 data bits).

        ldy     #0
fst1:   lda     PORTA           ; (4)
        sta     count,y         ; (5)
        iny                     ; (2)
        bne     fst1            ; (3)

        ldy     #0
fst2:   lda     PORTA
        sta     count+$100,y
        iny
        bne     fst2

        ldy     #0
fst3:   lda     PORTA
        sta     count+$200,y
        iny
        bne     fst3

; Now analyze the samples.

; First two samples should be for for start signal consisting of a low
; of 80 us and high for 80 msec. If either zero, it timed out waiting
; for the start signal and the rest of the data is invalid (most
; likely means there is no sensor connected).

        lda     start1
        beq     timerr
        lda     start2
        beq     timerr
        bne     okay1
timerr: jsr     IMPRINT
        .byte   "Error: Timeout waiting for start signal",CR,0
        brk
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

        lda     #<count         ; PTR will hold indirect address of samples
        sta     PTR
        ldy     #0
        lda     #>count
        sta     PTR+1
        ldx     #0              ; X will be index into data bits

; Find first FF

findff: lda    (PTR),y          ; Get sample
        cmp    #$FF             ; Is if FF?
        beq    foundff          ; If so, branch
        inc    PTR              ; Otherwise advance pointer address
        bne    nov1
        inc    PTR+1
nov1:   bne    findff           ; And continue

; Count number of FF samples
foundff:
        lda    #0               ; Initially zero count
        sta    bits,x
cntff:  lda    (PTR),y          ; Get sample
        cmp    #$FF             ; Is is still FF?
        bne    endff            ; Branch if not
        inc    bits,x           ; Increment count
        inc    PTR              ; Otherwise advance pointer address
        bne    nov2
        inc    PTR+1
nov2:   bne    cntff            ; Repeat

; Continue for 40 data bits

endff:  inx                     ; Advance to next data bit
        cpx    #40              ; Done 40 bits?
        bne    findff           ; If not, repeat

; Now go through list and decide if each is a 0 or 1 bit
; Will call <= 7 a 0, > 7 a 1
; e.g. for above
; 0 0 1 1 0 ...

        ldx    #0               ; Initialize index to start
decid:  lda    bits,x           ; Get count
        cmp    #7               ; Compare to 7
        bcc    zero             ; Branch if <= 7
        lda    #1               ; Make it a one
        bne    one              ; Branch always
zero:   lda    #0               ; Make it a zero
one:    sta    bits,x           ; Store it
        inx                     ; Advance to next count
        cpx    #40              ; Done 40 bits?
        bne    decid            ; Repeat if not

; Now convert the 40 bits into 5 bytes of data
; e.g. 0011 0010 0000 0000 0001 0100 0000 0100 0100 1010
; becomes: 32 00 14 04 4A

        ldy    #0               ; Initialize index into bytes
        ldx    #0               ; Initialize index to start
byt:    lda    #0               ; Initialize data byte
lp:     ora    bits,x           ; Add data bit
        inx                     ; Update counter
        pha                     ; Save A
        txa                     ; Get bit count
        and    #%00000111       ; Look at 3 least significant bits
        beq    byte             ; Branch if it is a multiple of 8 bits
        pla                     ; Restore A
        asl                     ; Shift left
        clc
        bcc    lp               ; And repeat
byte:   pla                     ; Restore A
        sta    bytes,y          ; Save a byte of data
        iny
        cpy    #5               ; Five bytes done?
        bne    byt              ; Branch of not

; Now do checksum check on the data: sum of first 4 bytes (modulo 256) should equal 5th byte.
; Otherwise report error.
; e.g. 2F 00 15 00 44

        clc
        lda    bytes
        adc    byte+1
        adc    byte+2
        adc    byte+3
        cmp    bytes+3
        bne    gudcs
        jsr    IMPRINT
        .byte  "Error: checksum mismatch.", CR,0
        brk
gudcs:

; Now calculate and display humidity
; e.g. 2F 00 14 08 4B
; 2F = 47, 00 = 0, 47.0%
; TODO: DH22 calculation is different

        jsr    IMPRINT
        .byte  "Humidity: ",0
        lda    bytes        ; Get integer part of humidity
        sta    BIN          ; Convert to decimal
        jsr    BINBCD8
        jsr    PRINTDEC     ; Print it
        lda    #'.'         ; Print decimal point
        jsr    MONCOUT
        lda    bytes+1      ; Get decimal part of humidity
        sta    BIN          ; Convert to decimal
        jsr    BINBCD8
        jsr    PRINTDEC     ; Print it

; Now calculate and display temperature
; e.g. 2F 00 14 08 4B
; 14 = 20, 08 = 8, 20.8C
; TODO: DH22 calculation is different
; TODO: Handle negative temperatures (most significant bit is 1)

        jsr    IMPRINT
        .byte  "%  Temperature: ",0
        lda    bytes+2      ; Get integer part of temperature
        sta    BIN          ; Convert to decimal
        jsr    BINBCD8
        jsr    PRINTDEC     ; Print it
        lda    #'.'         ; Print decimal point
        jsr    MONCOUT
        lda    bytes+3      ; Get decimal part of humidity
        sta    BIN          ; Convert to decimal
        jsr    BINBCD8
        jsr    PRINTDEC     ; Print it

        jsr     IMPRINT
        .byte   "C",CR,0

; Don't read again for at least 1 second (DHT11) or 2 seconds (DHT22).

        jsr     DELAY           ; Delay 4 seconds

; Stop if key pressed

        jsr     MONRDKEY        ; Key pressed?
        bcs     retn            ; If so, branch
        jmp     loop            ; Repeat
retn:   brk                     ; Return to monitor

; DELAY: Fixed delay of approx. 3 sec (2 MHz clock).
; Registers changed: A, X

DELAY:  ldx     #50             ; Approx 4 seconds
del:    lda     #$FF
        jsr     WAIT
        dex
        bne     del
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

; Print 2 byte BCD number (at address BCD) with leading zeroes suppressed.
PRINTDEC:
        lda     BCD+1           ; Get first digit
        cmp     #$00            ; Leading zero?
        beq     skip            ; If so, skip
        jsr     PRHEX           ; Print it
skip:   lda     BCD             ; Get second digit
        lsr
        lsr
        lsr
        lsr
        cmp     #$00            ; Is it a zero?
        bne     prn             ; If not, print it
        tax                     ; Save it
        lda     BCD+1           ; Was first digit also zero?
        beq     skip2           ; If so, skip this as well
        txa                     ; Otherwise print it
prn:    jsr     PRHEX           ; Print it
skip2:  lda     BCD             ; Get third digit
        and     #$0F
        jsr     PRHEX           ; Print it
        rts                     ; Return

; From: http://6502.org/source/integers/hex2dec-more.htm
; Convert an 8 bit binary value to BCD
; This function converts an 8 bit binary value into a 16 bit BCD. It
; works by transferring one bit a time from the source and adding it
; into a BCD value that is being doubled on each iteration. As all the
; arithmetic is being done in BCD the result is a binary to decimal
; conversion.  All conversions take 311 clock cycles.

BINBCD8:
        sed                     ; Switch to decimal mode
        lda     #0              ; Ensure the result is clear
        sta     BCD+0
        sta     BCD+1
        ldx     #8              ; The number of source bits
CNVBIT: asl     BIN             ; Shift out one bit
        lda     BCD+0           ; And add into result
        adc     BCD+0
        sta     BCD+0
        lda     BCD+1           ; propagating any carry
        adc     BCD+1
        sta     BCD+1
        dex                     ; And repeat for next bit
        bne     CNVBIT
        cld
        rts                     ; All Done.

; Data

start1: .res    1               ; Count of first start pulse low
start2: .res    1               ; Count of first start pulse high
count:  .res    3*356           ; Data for pulse length counts
bits:   .res    40              ; Data bit samples
bytes:  .res    5               ; Sensor data bytes
BIN:    .res    1               ; Used by BINBCD8 routine
BCD:    .res    2               ; "
        .end