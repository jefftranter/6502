; Replica 1 SpeakJet Chip Demo

; Uses the DO/Speaking pin to determine when phoneme has completed
; playing. You need to connect D0 (pin 16) to PA0 of the 6522 VIA.

    .org    $1000

; Defines

; 6551 ACIA
ACIA_DATA    = $C300    ; Data Register
ACIA_STATUS  = $C301    ; Status Register
ACIA_CMD     = $C302    ; Command Register
ACIA_CONTROL = $C303    ; Control Register

; 6522 VIA
VIA_PORTB = $C200
VIA_PORTA = $C201
VIA_DDRB  = $C202
VIA_DDRA  = $C203

; For Random routine
rnd = $00               ; Uses 5 bytes

; Set ACIA to 9600 BPS 8N1
    lda  #%00011110     ; 2 stop bits, 8 data bits, internal clock, 9600 baud
    sta  ACIA_CONTROL
    lda  #%00001011     ; no parity, no echo, no interrupts, RTS low, DTR low
    sta  ACIA_CMD

; Assume 6522 is initialized to reset defaults (all pins inputs).

; Play all sound effect phonemes from 200 to 255

play:
    jsr  Random         ; Get random number
    ora  #%10000000     ; Want >= 128
    jsr  PutChar        ; Send it

    lda  #%00000001     ; Look at bit 0...
playing:
    bit  VIA_PORTA      ; of PA0
    bne  playing        ; Loop until not playing

    jmp  play

; Wait for ACIA to be ready to send, then write data out serial port.
PutChar:
    pha                 ; Save A
    lda  #%00010000     ; TDRE bit
loop:
    bit  ACIA_STATUS    ; Check status register
    beq  loop           ; Branch until TDRE is true
    pla                 ; Restore A
    sta  ACIA_DATA      ; Send character
    rts                 ; Return

; Jim Butterfield's random number generator routine.
Random:
    cld
    sec
    lda  rnd+1
    adc  rnd+4
    adc  rnd+5
    sta  rnd
    ldx  #4
rpl:
    lda  rnd,x
    sta  rnd+1,x
    dex
    bpl  rpl
    rts
