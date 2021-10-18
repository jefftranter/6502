; MicroBART. Chapter 10.

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703

; Initialize the stop key and set port A to be output and B5-B0 are
; output. B7 is input and set the stack pointer.

START:  LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
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

JOIN:   DEC     OUTER
        BNE     ALFA
        LDA     #100            ; Decimal
        STA     OUTER

; We get this count of ones (or perhaps of zeros) and store it as speed
; of train 0. Then we clear the counts and jump back to ENTER.

        LDA     CTONE
        STA     SPEED0
        LDA     #$00
        STA     CTONE
        STA     CTZERO
        JMP     ENTER

; Than ends the main program. Now we will examine the subroutine
; ADVANCE. On entry X holds 0 or 1 determining which train to con-
; sider. First it calls MAP to get the "present" and "next" section
; addresses. If the dwell time is zero we go see if the train is
; stopped. Otherwise we decrement the dwell and return.

ADVANCE:
        JSR     MAP
        LDA     DWELL0,X
        BEQ     STOPPED
        DEC     DWELL0,X
        RTS

; When dwell counts out we check to see if this train is "stopped".
; If the train is stopped we check the status of the next track sec-
; tion. If it is busy we just return. Otherwise we are going to clear
; the block.

STOPPED:
        LDA     STOP0,X
        BEQ     GOAHEAD
        LDY     NEXT0,X
        LDA     BUSY,Y
        BEQ     NOSTOP
        RTS

; Nostop is where we clear the stop flag for a train. Then we release
; the present block, then make the next block become the present block
; and remap.

NOSTOP: LDA     #$00
        STA     STOP0,X
GOAHEAD:
        LDY     PRESENT0,X
        LDA     #$00
        STA     BUSY,Y
        LDY     BLOCK0,X
        LDA     NEXTBLOCK,Y
        STA     BLOCK0,X
        JSR     MAP

; Now make this block be busy and reset the dwell time.

        LDY     PRESENT0,X
        LDA     #$01
        STA     BUSY,Y
        LDA     SPEED0,X
        STA     DWELL0

; Next thing is to set up the lights for ports A and B.

        LDY     BLOCK0
        LDA     ALITE,Y
        LDY     BLOCK1
        ORA     ALITE,Y
        STA     PORTA
        LDA     PORTB
        AND     #$0             ; 0010 0000 save B5
        LDY     BLOCK0
        ORA     BLITE,Y
        LDY     BLOCK1
        ORA     BLITE,Y
        STA     PORTB

; We check the next block after this one and if it is busy we stop our
; train and return. If it is free we reserve it by making it busy and
; then return:

        LDY     NEXT0,X
        ORA     BLITE,Y
        STA     PORTB

; Skip to $0200 so we don't put code in page 1 where the stack is located.
        .RES    $0200-*

; We check the next block after this one and if it is busy we stop our
; train and return. If it is free we reserve it by making it busy and
; then return.

        LDY     NEXT0,X
        LDA     BUSY,Y
        BEQ     RESERVE
        LDA     #$01
        STA     STOP0,X
        RTS

RESERVE:
        LDY     NEXT0,X
        LDA     #$01
        STA     BUSY,Y
        RTS

; The subroutine MAP gets the name of the present section number to
; PRESENT and of the next section number to NEXT. X still tells which
; train:

MAP:    LDY     BLOCK0,X
        LDA     SECTIONNO,Y
        STA     PRESENT0,X
        LDA     NEXTBLOCK,Y
        TAY
        LDA     SECTIONNO,Y
        STA     NEXT0,X
        RTS

; We need four fixed tables
; NEXTBLOCK tells the name of the next block around the track.
; SECTIONNO translates a block number to a track section.
; ALITE     has the lights to light in PORTA.
; BLITE     tells the same for PORTB.
; To save paper we will list all four in parallel.

NEXTBLOCK:
        .BYTE $03, $08, $09, $0A, $00, $0C, $0B, $02, $07, $0D, $01, $05, $04, $06

SECTIONNO:
        .BYTE $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $03

ALITE:
        .BYTE $01, $02, $04, $08, $10, $20, $40, $80, $00, $00, $00, $00, $00, $08

BLITE:
        .BYTE $00, $00, $00, $00, $00, $00, $00, $00, $01, $02, $04, $08, $10, $00

; Variables are as follows:

BLOCK0: .BYTE $00               ; Which block is the train now in?
BLOCK1: .BYTE $00
SPEED0: .BYTE 0                 ; How fast is the train going?
SPEED1: .BYTE 0
DWELL0: .BYTE 0                 ; How long before we are ready to advance?
DWELL1: .BYTE 0
STOP0:  .BYTE 0                 ; Is the train stopped (=1) or free (=0)
STOP1:  .BYTE 0
PRESENT0: .BYTE 0               ; Present section number
PRESENT1: .BYTE 0
NEXT0:  .BYTE 0                 ; Next section number
NEXT1:  .BYTE 0
CTR:    .BYTE 0                 ; Inner loop for delay
OUTER:  .BYTE 0                 ; How many samples remaining
CTONE:  .BYTE 0                 ; How many ones were found
CTZERO: .BYTE 0                 ; How many zeros were found
BUSY:   .BYTE 0                 ; 13 cells one for each section
                                ; 0 means free, 1 means busy
