; Tune Player. Chapter 7.

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703
GETKEY  = $1F6A

; The usual initialization including making B0 be output and B7 be
; input.

START:  LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
        LDA     #$01
        STA     DIRB

; First of all go to the KIM subroutines to read in a key. Then put
; the key number in index register X. Using this key number we will
; get the starting address of the Xth song from TABLO and TABHI. We
; store this address in ADR1 and ADR2 which must be in page zero.

LGETKEY:
        JSR     GETKEY           ; Subroutine to get a key
        CMP     #$15             ; Returns 15H if no key
        BEQ     LGETKEY
        CMP     #$13             ; If we find the GO key pay
        BEQ     LGETKEY          ; no attention
        TAX
        LDA     z:TABLO,X
        STA     z:ADR1
        LDA     z:TABHI,X
        STA     z:ADR2

; We clear Y and the get the Yth note of the song by indirect indexed
; addressing. This note we will pull apart into the name of a half period
; and a duration over which to play the note.

        LDY      #$00
NEWNOTE:
        LDA     (ADR1),Y        ; Get the note of the song
        AND     #$0F            ; Keep lower half
        TAX
        LDA     z:PERTAB,X      ; Get the half period for this
                                ; note
        STA     z:PERIOD
        LDA     (ADR1),Y        ; Get note again
        LSR                     ; Logical right shift accumulator
        LSR                     ; four times to get duration
        LSR                     ; right justified
        LSR
        STA     z:TIME

; If the note is FF that's the end of the song.

        LDA     (ADR1),Y
        CMP     #$FF
        BEQ     START

; First we start the timer going with a count of 80H. Then we count
; down the half period and toggle the speaker. We keep on doing this
; till the timer runs out.

RUNTIME:
        LDA     #$80            ; Get timer started in slowest
        STA     $170F           ; mode
HALFPER:
        LDX     z:PERIOD
LOOP:   JMP     NEXT            ; This is a time waster
NEXT:   DEX
        BNE     LOOP
        INC     PORTB
        LDA     $1707           ; Read timer status. Is sign bit B7=1?
        BMI     CLKOUT          ; When the timer runs out

; To balance off the time taken at CLOCKOUT we will put in 3 jump to
; the next instruction and then return to HALFPER.

        JMP     N1
N1:     JMP     N2
N2:     JMP     N3
N3:     JMP     HALFPER

; Finally we see if we have played this note long enough.

CLKOUT: DEC     z:TIME
        BNE     RUNTIME         ; If we haven't played enough
        INY                     ; Bump the pointer Y
        JMP     NEWNOTE

; There are two tables we have to have to store the address of the
; beginnings of the songs. For the songs shown in the main text we
; have:

TABLO:  .BYTE   <SONG0
        .BYTE   <SONG1
        .BYTE   <SONG2

TABHI:  .BYTE   >SONG0
        .BYTE   >SONG1
        .BYTE   >SONG2

; There are four variables:

TIME:   .BYTE   $00             ; Holds the length of the note
                                ;  in 1/8 notes
PERIOD: .BYTE   $00             ; Holds the half period or
                                ;  inverse frequencies
ADR1:   .BYTE   $01             ; Must be in page zero. Used
ADR2:   .BYTE   $00             ;  for holding the start of the
                                ;  song

PERTAB: .BYTE  $00              ; C
        .BYTE  $F0              ; C#
        .BYTE  $E0              ; D
        .BYTE  $D1              ; D#
        .BYTE  $C4              ; E
        .BYTE  $B6              ; F
        .BYTE  $A9              ; F#
        .BYTE  $9D              ; G
        .BYTE  $9D              ; G#  By coincidence the same number
        .BYTE  $00              ; Phantom key
        .BYTE  $90              ; A
        .BYTE  $85              ; A#
        .BYTE  $7B              ; B
        .BYTE  $72              ; C

; Skip to $0200 so we don't put code in page 1 where the stack is located.
        .RES   $0200-*

; "0" Red River Valley

SONG0:
        .BYTE  $21, $24, $46, $10
        .BYTE  $26, $25, $44, $25
        .BYTE  $24, $22, $64, $10
        .BYTE  $24, $21, $24, $46
        .BYTE  $10, $26, $10, $26
        .BYTE  $48, $27, $26, $c5
        .BYTE  $21, $24, $46, $10
        .BYTE  $26, $19, $26, $44
        .BYTE  $25, $26, $28, $67
        .BYTE  $10, $27, $20, $22
        .BYTE  $10, $22, $41, $24
        .BYTE  $25, $46, $25, $10
        .BYTE  $25, $84, $10, $24
        .BYTE  $FF

; "1" British Grenadier

SONG1:
        .BYTE   $21, $24, $21, $24
        .BYTE   $25, $46, $25, $16
        .BYTE   $17, $28, $24, $16
        .BYTE   $14, $14, $13, $64
        .BYTE   $21, $24, $21, $24
        .BYTE   $25, $46, $25, $36
        .BYTE   $17, $28, $24, $16
        .BYTE   $15, $14, $13, $24
        .BYTE   $20, $16, $17, $38
        .BYTE   $19, $28, $27, $36
        .BYTE   $17, $28, $24, $32
        .BYTE   $12, $18, $17, $16
        .BYTE   $15, $44, $23, $11
        .BYTE   $11, $24, $21, $24
        .BYTE   $25, $46, $25, $16
        .BYTE   $17, $28, $24, $16
        .BYTE   $15, $14, $13, $64
        .BYTE   $FF

; "2" Nearer My God To Thee

SONG2:
        .BYTE   $C6, $85, $44, $84
        .BYTE   $32, $10, $C2, $C1
        .BYTE   $84, $46, $B5, $10
        .BYTE   $85, $40, $C6, $85
        .BYTE   $34, $10, $84, $32
        .BYTE   $10, $C2, $81, $44
        .BYTE   $83, $45, $B4, $10
        .BYTE   $84, $40, $C8, $89
        .BYTE   $38, $10, $88, $46
        .BYTE   $B8, $10, $C8, $82
        .BYTE   $31, $10, $81, $46
        .BYTE   $C5, $C6, $85, $34
        .BYTE   $10, $C4, $32, $10
        .BYTE   $C2, $81, $44, $83
        .BYTE   $45, $B4, $10, $84
        .BYTE   $FF
