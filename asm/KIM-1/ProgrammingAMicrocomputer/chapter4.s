; Code for Piano Keyboard. Chapter 4.

; I have confirmed this program works on a real KIM-1 - Jeff Tranter

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703

; To initialize the computer we set up the stop key and make port A
; be input and port B 7-2 be input so we can sense closure of the
; piano keys. Bits B1 will be output "just because" and B0 will be
; output so we can toggle the loudspeaker.

START:  LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
        LDA     #$00            ; We'll get a new zero in A
        STA     DIRA            ; just in case some time we
                                ; want something else
        LDA     #$03
        STA     DIRB

; We look to see if one of the keys connected to port A is closed. If
; port A is not all zero then we try to find out which key by shifting
; and counting in index register X. We exit to SECOND if no key of
; this group was pressed and to FOUND when we discover and identify a
; key. Numbers in parentheses are the cycles to execute each
; instruction.

FIRST:  LDX     #$00            ; (2)    Zero the counter
        LDA     PORTA           ; (4)    (1700)
        BEQ     SECOND          ; (2/3)  3 if you do jump
LOOP1:  BMI     FOUND           ; (2/3)  We are testing the leftmost bit
        INX                     ; (2)    Increment X
        ASL                     ; (2)    Shift accum. left
        JMP     LOOP1           ; (3)

; SECOND tests port B and is much like FIRST except that we have to
; clear out B1 and B0 (and B6 for good luck) before testing for a key
; in this group.

SECOND:   LDX   #$08            ; (2)    Start count at 8
          LDA   PORTB           ; (4)
          AND   #$BC            ; (4)    Clear unused bits
          BEQ   FIRST           ; (2/3)  Nothing here go to FIRST
LOOP2:    BMI   FOUND           ; (2/3)
          INX                   ; (2)
          ASL                   ; (2)
          JMP   LOOP2           ; (3)

; Now at FOUND we have a number in index register X which identifies
; which key was pressed. We get half period delays from TABLE,
; put it in Y and count down to zero. Then we toggle the speaker and
; go back to see if any keys are still pressed:

FOUND:    LDA    z:TABLE,X      ; (4)
          TAY                   ;        Get number from  to Y
WAIT:     JMP    WI             ; (3)
WI:       DEY                   ; (4)
          BNE    WAIT           ; (2/3)
          INC    PORTB          ; (6)    Toggle speaker
          JMP    FIRST

; The TABLE holds delays for each note. These delays are corrected
; for the time it takes to decide that this note was pressed.

TABLE:    .BYTE  $00            ; C
          .BYTE  $F0            ; C#
          .BYTE  $E0            ; D
          .BYTE  $D1            ; D#
          .BYTE  $C4            ; E
          .BYTE  $B6            ; F
          .BYTE  $A9            ; F#
          .BYTE  $9D            ; G
          .BYTE  $9D            ; G#  By coincidence the same number
          .BYTE  $00            ; Phantom key
          .BYTE  $90            ; A
          .BYTE  $85            ; A#
          .BYTE  $7B            ; B
          .BYTE  $72            ; C

; Note this table will generate tones somewhat flat. If you have perfect
; pitch and this bothers you, try the table of page 52.
