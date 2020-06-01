; Replica 1 SpeakJet Chip Demo

; Says HELLO, numbers 1 through 10, then GOODBYE.

; Uses the D0/Speaking pin to determine when phoneme has completed
; playing. You need to connect D0 (pin 16) to PA0 of the 6522 VIA.

T1 = $30                ; Temp variable 1 (2 bytes)

    .org    $1000

; Defines

; 6551 ACIA
ACIA_DATA    = $C300    ; Data Register
ACIA_STATUS  = $C301    ; Status Register
ACIA_CMD     = $C302    ; Command Register
ACIA_CONTROL = $C303    ; Control Register

; 6522 VIA
VIA_PORTA = $C201

start:
    jsr Initialize      ; Initialize hardware

    ldx #<Hello         ; Get pointer to phonemes for "HELLO"
    ldy #>Hello
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<One           ; Get pointer to phonemes for "ONE"
    ldy #>One
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Two           ; Get pointer to phonemes for "TWO"
    ldy #>Two
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Three         ; Get pointer to phonemes for "THREE"
    ldy #>Three
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Four          ; Get pointer to phonemes for "FOUR"
    ldy #>Four
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Five          ; Get pointer to phonemes for "FIVE"
    ldy #>Five
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Six           ; Get pointer to phonemes for "SIX"
    ldy #>Six
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Seven         ; Get pointer to phonemes for "SEVEN"
    ldy #>Seven
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Eight         ; Get pointer to phonemes for "EIGHT"
    ldy #>Eight
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Nine          ; Get pointer to phonemes for "NINE"
    ldy #>Nine
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Ten           ; Get pointer to phonemes for "TEN"
    ldy #>Ten
    jsr Say             ; Say phrase
    jsr Pause

    ldx #<Goodbye       ; Get pointer to phonemes for "GOODBYE"
    ldy #>Goodbye
    jsr Say             ; Say phrase
    jsr Pause

    rts                 ; Return


; Initialize ACIA and VIA
Initialize:
; Set ACIA to 9600 BPS 8N1
    lda  #%00011110     ; 2 stop bits, 8 data bits, internal clock, 9600 baud
    sta  ACIA_CONTROL
    lda  #%00001011     ; no parity, no echo, no interrupts, RTS low, DTR low
    sta  ACIA_CMD
; Assume 6522 is initialized to reset defaults (all pins inputs).
    rts


; Say a word. Pass address of phoneme table in X (low) and Y (high).
; Must be terminated in a null (zero).
; Registers changed: None
Say:
        PHA             ; Save A
        TYA
        PHA             ; Save Y
        STX T1          ; Save in page zero so we can use indirect addressing
        STY T1+1
        LDY #0          ; Set offset to zero
@loop:  LDA (T1),Y      ; Read a character
        BEQ done        ; Done if we get a null (zero)
        JSR SendPhoneme ; Say it
        CLC             ; Increment address
        LDA T1          ; Low byte
        ADC #1
        STA T1
        BCC @nocarry
        INC T1+1        ; High byte
@nocarry:
        JMP @loop       ; Go back and print next character
done:   
        PLA
        TAY             ; Restore Y
        PLA             ; Restore A
        RTS


; Send command for 100ms pause.
Pause:
    lda  #1
    jsr  SendPhoneme
    rts


; Send Phoneme stored in A.
SendPhoneme:
    pha                 ; Save A
    jsr  PutChar        ; Send it
    lda  #%00000001     ; Look at bit 0...
playing:
    bit  VIA_PORTA      ; of PA0
    bne  playing        ; Loop until not playing
    pla                 ; Restore A
    rts

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

; Tables of phonemes for words. Terminated in null.

; hello = \HE \FAST \EHLE \LO \OWWW
Hello:
    .byte 183, 7, 159, 146, 164, 0

;one =\WW \Stress \OH \SLOW \NE             
One:
    .byte  147, 14, 135, 8, 141, 0

;two = \SLOW \TT \IHWW
Two:
    .byte 8, 191, 162, 0

;three = \SLOW \TH \RR \SLOW \IY
Three:
    .byte 8, 190, 148, 8, 128, 0

;four =\FF \Fast \OW \OWRR 
Four:
    .byte 186, 7, 137, 153, 0

;five = \FF \OHIH \VV
Five:
    .byte 186, 155, 166, 0

;six =\SLOW \SE \IH \Stress \KE \Fast \SE  
Six:
    .byte 8, 187, 129, 14, 194, 7, 187, 0

;seven = \SLOW \SE \FAST \EH \VV \EH \NE
Seven:
    .byte 8, 187, 7, 131, 166, 131, 141, 0

;eight = \EYIY \P4 \TT
Eight:
    .byte  154, 4, 191, 0

;nine =\NE \Stress \OHIH \NE     
Nine:
    .byte 141, 14, 157, 141, 0

;ten = \TT \EH \EH \NE
Ten:
    .byte 191, 131, 131, 141, 0

;goodbye=\Slow \GO \UW \OD \FAST \P4 \SOFT \BO \OHIH  
Goodbye:
    .byte 8, 179, 139, 177, 7, 4, 15, 171, 155, 0
