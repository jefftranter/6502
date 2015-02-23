; This is the code from "Appendix A: An Inexpensive I/O System." from
; "A 2K Symbolic Assembler for the 6502" by Robert Ford Denison.
;
; Modified to assemble with the CC65 assembler by Jeff Tranter

DSPBUF  = $23
DSPBFI  = $24
DSPBF5  = $28
SAVX    = $3B
TIME    = $5C
POINTL  = $FA
POINTH  = $FB

PAD     = $1700
PADD    = $1701
PCD     = $1740
PCDD    = $1741
PDD     = $1742
SCAND   = $1F19

; Listing A. Test program for Qwerty keyboard. Displays hexadecimal
; code of active key.

        LDA   #$7F              ; Define I/O.
        STA   PADD
        LDA   #$00              ; Initialize pointer
        STA   POINTL            ; for display routine
        LDA   #$17
        STA   POINTH
START:  LDA   #$40              ; Scan 63 keys
        STA   PAD
SCANKB: DEC   PAD               ; Find active key.
        LDA   PAD
        BMI   SCANKB
        JSR   SCAND             ; Display key
        CLC
        BCC   START             ; Repeat for new key.
        NOP

        .org    $0E80

; Table KEYTAB. Keyboard scan codes for 64-character ASCII subset.
; Modify as desired.

KEYTAB:
        .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

        .org    $0EC0

; Table SEGTAB. Seven-segment code to display 64-character ASCII
; subset. Modify as desired.

SEGTAB:
        .byte $00,$0A,$22,$1B,$36,$24,$5F,$02,$39,$0F,$21,$18,$0C,$40,$08,$52
        .byte $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$6F,$41,$45,$60,$48,$42,$53
        .byte $7B,$77,$7C,$58,$5E,$79,$71,$3D,$76,$04,$1E,$70,$38,$37,$54,$5C
        .byte $73,$67,$50,$2D,$78,$1C,$6A,$3E,$14,$6E,$49,$39,$44,$0F,$77,$61

        .org $0F00

; Subroutine DSPLAY. Display 6 characters on KIM readout for about 3 msec.

DSPLAY:
        LDA   #$7F              ; Define I/O.
        STA   PCDD
        LDA   #$15              ; Initialize char.
        STA   PDD
        LDX   #$05              ; Display 6 chars.
CHAR:   DEC   PDD               ; Select next char.
        DEC   PDD
        LDA   DSPBUF,X          ; Get segment code.
        STA   PCD               ; Turn segments on.
        LDY   #$64              ; Wait 500 msec.
WAIT:   DEY
        BPL   WAIT
        LDA   #$00              ; Turn segments off.
        STA   PCD
        DEX
        BPL   CHAR              ; Another char?
        RTS

        .org $0F25

; Subroutine GETKEY. Scan kybd; return ASCII in A, key in Y.

GETKEY:
        LDX   #$3F              ; Define I/O.
        STX   PADD
        STX   PAD
NXTKEY: DEC   PAD               ; Scan 2 keys.
        LDA   PAD               ; for active key.
        BMI   NXTKEY
        AND   #$3F              ; Mask input bit.
        TAY                     ; Return if no key.
        BNE   ANYKEY
        RTS
ANYKEY: LDA   KEYTAB,Y          ; Get ASCII.
        STX   PAD               ; Check shift key.
        BIT   PAD
        BPL   SHFTKEY
        RTS                     ; No shift; return.
SHFTKEY:CMP   #$21              ; shift legal?
        BPL   NOT2LO
        RTS
NOT2LO: CMP   #$40
        BMI   NOT2HI
        RTS
NOT2HI: EOR     #$10            ; Fine shift char.
        RTS

        .org $0F54

; Subroutine ADDCH. Shift ASCII character in A into display from
; right.

ADDCH:
        LDX     #$00            ; Shift display
LEFT:   LDY     DSPBFI,X        ; to left.
        STY     DSPBUF,X
        INX
        CPX     #$05
        BMI     LEFT
        SBC     #$20            ; Fine segment
        TAX                     ; code.
        LDA     SEGTAB,X
        STA     DSPBF5          ; Add at right.
        RTS

        .org    $0F68

; Subroutine GETCH. Get character from keyboard. Return ASCII in A.
; Add to display or backspace as required. X is preserved.

GETCH:
        STX     SAVX            ; Save X.
OLD:    JSR     DSPLAY          ; Wait for release
        JSR     GETKEY          ; of old key.
        BNE     OLD
        NOP
NONE:   JSR     DSPLAY          ; Wait for new
        JSR     GETKEY          ; key depressed.
        BEQ     NONE
        CMP     #$08            ; Backspace?
        BNE     NOTBSP
        LDX     #$04            ; Yes. Shift
RIGHT:  LDY     DSPBUF,X        ; display right.
        STY     DSPBFI,X
        DEX
        BPL     RIGHT
        LDY     #$00            ; Add blank
        STY     DSPBUF          ; at left.
        LDX     SAVX            ; Restore X.
        RTS
NOTBSP: PHA                     ; Else, add char
        JSR     ADDCH           ; to display.
        LDX     SAVX
        PLA
        RTS

        .org    $0F97

; Subroutine OUTCH. Add ASCII character in A to display. Display for
; about 0.2 sec. Preserve X.

OUTCH:
        STX     SAVX            ; Save X.
        JSR     ADDCH           ; Add char.
        LDA     #$40            ; Wait 0.2 sec
        STA     TIME            ; before returning
SHOW:   JSR     DSPLAY
        DEC     TIME
        BPL     SHOW
        LDX     SAVX            ; Restore X.
        RTS

        .org    $0FAA

; Subroutine OUTSP. Output one space.

OUTSP:
        LDA     #$20
        JSR     OUTCH
        RTS


        .org $0FB0

; Subroutine CRLF. Clear display.

CRLF:
        LDA     #$00
        LDX     #$05
CLEAR:  STA     DSPBUF,X
        DEX
        BPL     CLEAR
        RTS
