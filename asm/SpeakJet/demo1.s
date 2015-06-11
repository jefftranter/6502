; Replica 1 SpeakJet Chip Demo

  .org    $1000

; Defines

; 6551 ACIA
ACIA_DATA    = $C300    ; Data Register
ACIA_STATUS  = $C301    ; Status Register
ACIA_CMD     = $C302    ; Command Register
ACIA_CONTROL = $C303    ; Control Register

; Set ACIA to 9600 BPS 8N1
    lda  #%00011110     ; 2 stop bits, 8 data bits, internal clock, 9600 baud
    sta  ACIA_CONTROL
    lda  #%00001011     ; no parity, no echo, no interrupts, RTS low, DTR low
    sta  ACIA_CMD

; Play all phonemes from 128 to 254

    lda  #128           ; First phoneme
next:
    jsr  PutChar        ; Send it
    jsr  Delay          ; Wait
    clc
    adc  #1             ; Next phoneme
    cmp  #255           ; Last one reached?
    bne  next
    rts

; Write data out serial port, wait until sent and then return.
PutChar:
    pha                 ; Save A
    sta  ACIA_DATA       ; Send character
    lda  #%00010000      ; TDRE bit
loop:
    bit  ACIA_STATUS     ; Check status register
    beq  loop            ; Branch until TDRE is true
    pla                 ; Restore A
    rts                 ; Return

; Delay loopl
Delay:
    ldy  #0
outer:
    ldx  #0
inner:
    inx
    bne  inner
    iny
    bne  outer
    rts
