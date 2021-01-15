; Simple example of driving a 2x16 LCD from the 6522 VIA.
; Based on code by Ben Eater from https://eater.net/6502
; Hook up the LCD as follows:
; LCD Pin  Signal  SBC Signal  Comments
;  1       GND     GND
;  2       VCC     VCC
;  3       VO      GND         Some displays need contrast pot
;  4       RS      PA5
;  5       R/W     PA6
;  6       EN      PA7
;  7       D0      PB0
;  8       D1      PB1
;  9       D2      PB2
;  10      D3      PB3
;  11      D4      PB4
;  12      D5      PB5
;  13      D6      PB6
;  14      D7      PB7
;  15      A       VCC         Backlight +
;  16      K       GND         Backlight -

PORTB   = $8000
PORTA   = $8001
DDRB    = $8002
DDRA    = $8003

E       = %10000000
RW      = %01000000
RS      = %00100000

        .org $7000

start:
        ldx     #$FF            ; Set up stack
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

        ldx     #0              ; Offset into string to print
print1:
        lda     message1,x      ; Get byte of message string
        beq     next            ; Branch when done
        jsr     print_char      ; Print character to display
        inx                     ; Advanced offset
        jmp     print1          ; Go back and print next character

next:
        ldx     #$00
outer:
        lda     #$00
inner:
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        sec
        sbc     #$01
        bne     inner
        dex
        bne     outer

        lda     #$00000001      ; Clear display
        jsr     lcd_instruction

        ldx     #0              ; Offset into string to print
print2:
        lda     message2,x      ; Get byte of message string
        beq     done            ; Branch when done
        jsr     print_char      ; Print character to display
        inx                     ; Advanced offset
        jmp     print2          ; Go back and print next character

done:
        brk                     ; Return to monitor

message1:
        .asciiz "Hello, world!" ; String to print (null terminated)

message2:
        .asciiz "Goodbye, world!"

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
