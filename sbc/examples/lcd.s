; Simple example of driving a 2x16 LCD from the 6522 VIA.
; Based on code by Ben Eater from https://eater.net/6502
; See lcd1.s for hardware setup.

PORTB   = $8000
PORTA   = $8001
DDRB    = $8002
DDRA    = $8003

E       = %10000000
RW      = %01000000
RS      = %00100000

        .org $7000

start:
        ldx     #$ff
        txs

        lda     #%11111111      ; Set all pins on port B to output
        sta     DDRB
        lda     #%11100000      ; Set top 3 pins on port A to output
        sta     DDRA

        lda     #%00111000      ; Set 8-bit mode; 2-line display; 5x8 font
        jsr     lcd_instruction
        lda     #%00001110      ; Display on; cursor on; blink off
        jsr     lcd_instruction
        lda     #%00000110      ; Increment and shift cursor; don't shift display
        jsr     lcd_instruction
        lda     #$00000001      ; Clear display
        jsr     lcd_instruction

        ldx     #0
print:
        lda     message,x
        beq     loop
        jsr     print_char
        inx
        jmp     print

loop:
        jmp     loop

message:
        .asciiz "Hello, world!"

lcd_wait:
        pha
        lda     #%00000000      ; Port B is input
        sta     DDRB
lcdbusy:
        lda     #RW
        sta     PORTA
        lda     #(RW | E)
        sta     PORTA
        lda     PORTB
        and     #%10000000
        bne     lcdbusy

        lda     #RW
        sta     PORTA
        lda     #%11111111      ; Port B is output
        sta     DDRB
        pla
        rts

lcd_instruction:
        jsr     lcd_wait
        sta     PORTB
        lda     #0              ; Clear RS/RW/E bits
        sta     PORTA
        lda     #E              ; Set E bit to send instruction
        sta     PORTA
        lda     #0              ; Clear RS/RW/E bits
        sta     PORTA
        rts

print_char:
        jsr     lcd_wait
        sta     PORTB
        lda     #RS             ; Set RS; Clear RW/E bits
        sta     PORTA
        lda     #(RS | E)       ; Set E bit to send instruction
        sta     PORTA
        lda     #RS             ; Clear E bits
        sta     PORTA
        rts
