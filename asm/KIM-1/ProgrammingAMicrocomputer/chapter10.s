; MicroBART, Chapter 10.

        .ORG    $0000

PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703

; Initialize the stop key and set port A to be output and B5-B0 are
; output. B7 is input and set the stack pointer.

START:  LDA     #$00
        STA     $17FA
        LDA     #$1C
        STA     $17FB
        LDA     #$FF
        STA     DIRA
        LDA     #$3F
        STA     DIRB
        LDX     #$FF
        TXS

; Next we place the trains on the track.

        LDA     #$0C
        STA     BLOCK0          ; Train 0 in B4
        LDA     #$08
        STA     BLOCK1          ; Train 1 in B0

; We clear the busy table:

        LDX     #$0D
CLEAR:  STA     BUSY,X
        DEX
        BNE     CLEAR

; Neither train is stopped:

        LDA     #$00
        STA     STOP0
        STA     STOP1

; We initialize speed and dwell time for both trains but we don't make
; reservations in the busy table. This will take care of itself since
; they start on opposite sides of the layout.

        LDA     #$01
        STA     DWELL0
        STA     DWELL1
        LDA     #$30
        STA     SPEED0
        STA     SPEED1

; At enter we check to see if either train wants to advance to the
; net track block.

ENTER:  LDX     #$01
        JSR     ADVANCE
        LDX     #$01
        JSR     ADVANCE

; At Alfa we delay 300 microseconds and then read B7 and generate feed-
; back via B5. We keep separate count of the times B7 is zero and is
; one because at this point I wasn't sure which one I'd used.

ALFA:   LDA     #55             ; Decimal
        STA     CTR
DLAY:   DEC     CTR
        BNE     DLAY
        LDA     PORTB           ; Get B7
        BPL     POS
        ORA     #$20            ; Pattern 0010 0000 - set B5
        STA     PORTB
        INC     CTONE           ; Was a one
        JMP     JOIN
POS:    AND     #$9F            ; 1001 1111 clear B5
        STA     PORTB
        INC     CTZERO

; We join together again and see if we have been round this loop 100
; times. If not we go to ALFA. If yes we reset the counter.

