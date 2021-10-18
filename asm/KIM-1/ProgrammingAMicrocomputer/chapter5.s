; Code for Keybounce. Chapter 5.

; I have confirmed this program works on a real KIM-1 - Jeff Tranter

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703

; Once again we must set up the stop key and make port A bit 0 an
; input with the other bits being output. Then we initialize the
; stack pointer to point to line FF of page 01:

START:  LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
        LDA     #$FE
        STA     DIRA
        LDA     #$FF            ; Put FF into stack pointer
        TXS
        LDX     #$F8            ; Set X to count 248d

; Now we wait until a key is pushed:

KEY:    LDA     PORTA
        BEQ     KEY

; Once a key has been pushed we start taking samples of the key state
; and putting them on the stack. We use X as a counter to see if we
; are out of space yet.

LOOP:   LDA     PORTA
        PHA                     ; Push Acc onto the stack
        DEX
        BNE     LOOP

; We have the samples all nicely stored in page 01 so we can stop,
; using a "dynamic halt" if the machine doesn't have anything better.

HALT:   JMP     HALT
