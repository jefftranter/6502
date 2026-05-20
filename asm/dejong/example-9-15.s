DURT    =       $1C
SONG    =       $1A
T1LL    =       $C704
T1LH    =       $C705
ACR     =       $C708
IER     =       $C70E
DELAY   =       $182D

        .ORG    $1860

        LDA     #$40            ; Initialize T1 to run free,
        STA     ACR             ; generating interrupts.
        LDA     #$C0            ; Load interrupt enable register
        STA     IER             ; to produce interrupts from T1.
        LDY     #$00            ; Indirect index equal zero.
LOOP:   LDA     (SONG),y        ; Get note index.
        TAX                     ; Use index to look up
        LDA     NOTE,X          ; low byte for T1.
        STA     T1LL
        LDA     NOTE+$24,X      ; Get high byte for T1.
        STA     T1LH
        LDA     (DURT),Y        ; Get duration of note.
        BEQ     OUT             ; Zero duration ends song.
        TAX
WAIT:   JSR     DELAY           ; Use T2 delay subroutine.
        DEX                     ; Number of delays is duration.
        BNE     WAIT
        INC     SONG            ; Increment song pointer.
        BNE     BR1
        INC     SONG+1          ; Go to the next page.
BR1:    INC     DURT            ; Increment duration pointer.
        BNE     BR2
        INC     DURT+1          ; Go to the next page.
BR2:    CLC
        BCC     LOOP            ; Keep getting notes.
OUT:    BRK                     ; The song is over.

; Load $57 and $18 into $03FE and $03FF respectively.
; Load interrupt routine from example 9-14.
; Initialize indirect index pointers, SONG and DURT, by
; loading $00 into $001A and $001C. Load $11 into $001B
; and $13 into $001D.
; Load song, duration, and not tables.
; Long delay routine from example 9-13.

; Note Table:

       .ORG     $1000
NOTE:  .BYTE    $EE, $18, $4D, $8E, $DA, $2F, $8F, $F7
       .BYTE    $68, $E1, $61, $E9, $77, $0C, $A7, $47
       .BYTE    $ED, $98, $48, $FC, $B4, $70, $31, $F4
       .BYTE    $BC, $86, $53, $23, $F6, $CC, $A4, $7E
       .BYTE    $5A, $38, $18, $FA, $0E, $0E, $0D, $0C
       .BYTE    $0B, $0B, $0A, $09, $09, $08, $08, $07
       .BYTE    $07, $07, $06, $06, $05, $05, $05, $04
       .BYTE    $04, $04, $04, $03, $03, $03, $03, $03
       .BYTE    $02, $02, $02, $02, $02, $02, $02, $01

; Song Table:

       .ORG     $1100
       .BYTE    $00, $01, $02, $03, $04, $05, $06, $07
       .BYTE    $08, $09, $0A, $0B, $0C, $0E, $0F, $10
       .BYTE    $11, $12, $13, $14, $15, $16, $17, $18
       .BYTE    $19, $1A, $1B, $1C, $1D, $1E, $1F, $20
       .BYTE    $21, $22, $23, $24
