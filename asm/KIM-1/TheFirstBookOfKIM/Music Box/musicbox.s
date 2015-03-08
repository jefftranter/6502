; ***** Fixed locations for MUSIC BOX *****

        WORK    = $E0
        LIMIT   = $E6
        VAL2    = $E9
        VAL1    = $EA
        TIMER   = $EB
        XSAV    = $EC
        SBD     = $1742
        PBDD    = $1743

; PROGRAM - MUSIC BOX

        .ORG    $0200

; THE LOWEST NOTE YOU CAN PLAY IS A BELOW MIDDLE C.  FOR EACH NOTE,
; YOU CAN SELECT WHETER IT IS PLAYED AS A LONG NOTE OR A SHORT NOTE
; (NORMALY, A LONG NOTE WILL LAST TWICE AS LONG AS A SHORT NOTE).
;
; SOME OF THE NOTES ARE AS FOLLOWS:
;
;        NOTE              SHORT LONG
;
;         A..................75   75
;         A#                 6E   EE
;         B..................68   E8
; MIDDLE  C                  62   E2
;         C#.................5C   DC
;         D                  56   D6
;         D#.................52   D2
;         E                  4D   CD
;         F..................48   C8
;         F#                 44   C4
;         G..................40   C0
;         G#                 3C   BC
;         A..................39   B9
;         A#                 35   B5
;         B..................32   B2
;   HIGH  C                  2F   AF
;         C#.................2C   AC
;         D                  29   A9
;         E..................24   A4
;         F                  22   A2
;         G..................1E   9E
;      PAUSE                 00   80


; INITIALIZE - RESET WORK PARAMETERS

START:  LDX     #5
LP1:    LDA     INIT,X
        STA     WORK,X
        DEX
        BPL     LP1

; MAIN ROUTINE HERE - WORK NOT RESET

GO:     LDA    #$BF
        STA    PBDD             ; open output channel
        LDY    #0
        LDA    (WORK+4),Y       ; get next note
        INC    WORK+4
        CMP    #$FA             ; test for halt
        BNE    NEXT
        BRK                     ; (or RTS if used as subroutine)
        NOP
        BEQ    GO               ; resume when GO pressed
NEXT:   BCC    NOTE             ; is it a note?
        SBC    #$FB             ; if not, decode instrument
        TAX                     ; and put it into x
        LDA    (WORK+4),Y       ; GET PARAMETER
        INC    WORK+4
        STA    WORK,X           ; STORE IN WORK TABLE
        BCS    GO               ; UNCONDITIONAL BRANCH

; SET UP FOR TIMING NOTE

NOTE:   LDX    WORK             ; TIMING
        STX    LIMIT+1
        LDX    WORK+1           ; LONG NOTE FACTOR
        TAY                     ; TEST ACCUM.
        BMI    OVER             ; LONG NOTE?
        LDX    #1               ; NOPE, SET SHORT NOTE
OVER:   STX    LIMIT            ; store length factor
        AND    #$7F             ; remove short/long flag
        STA    VAL2
        BEQ    HUSH             ; is it a pause
        STA    VAL1             ; no, set pitch
HUSH:   LDA    VAL2             ; get timing and
        AND    WORK+3           ; bypass if muted
        BEQ    ON
        INC    VAL1             ; else fade the
        DEC    VAL2             ; note
ON:     LDX    VAL2
        LDA    #$A7
        JSR    SOUND
        BMI    GO
        LDX    VAL1
        LDA    #$27
        JSR    SOUND
        BMI    GO
        BPL    HUSH

; SUBROUTINE TO SEND A BIT

SOUND:  LDY    WORK+2           ; octave flag
        STY    TIMER
        STX    XSAV
SLOOP:  CPX    #0
        BNE    CONT
        LDX    XSAV
        DEC    TIMER
        BNE    SLOOP
        BEQ    SEX
CONT:   STA    SBD
        DEX
        DEC    LIMIT+2
        BNE    SLOOP
        DEC    LIMIT+1
        BNE    SLOOP
        LDY    WORK
        STY    LIMIT+1
        DEC    LIMIT
        BNE    SLOOP
        LDA    #$FF
SEX:    RTS


; INITIAL CONSTANTS

INIT:  .BYTE    $30, 2, 1
       .BYTE    $FF, <SONGS, >SONGS     ; modified to put songs after program rather than at $0000


; SAMPLE MUSIC FOR MUSIC BOX PROGRAM

SONGS:
      .BYTE    $FB,$18,$FE,$FF,$44,$51,$E6,$E6,$66,$5A,$51,$4C,$C4,$C4,$C4,$D1
      .BYTE    $BD,$BD,$BD,$00,$44,$BD,$00,$44,$3D,$36,$33,$2D,$A8,$80,$80,$33
      .BYTE    $44,$B3,$80,$80,$44,$51,$C4,$80,$80,$5A,$51,$E6,$80,$80,$FA

      .BYTE    $FE
      .BYTE    $00,$FB,$28,$5A,$5A,$51,$48,$5A,$48,$D1,$5A,$5A,$51,$48,$DA,$E0
      .BYTE    $5A,$5A,$51,$48,$44,$48,$51,$5A,$60,$79,$6C,$60,$DA,$DA,$FA

      .BYTE    $FE
      .BYTE    $FF,$5A,$5A,$5A,$5A,$5A,$5A,$66,$72,$79,$E6,$E6,$80,$00,$56,$56
      .BYTE    $56,$56,$56,$56,$5A,$66,$F2,$80,$80,$4C,$4B,$4C,$4C,$4C,$4C,$56
      .BYTE    $5A,$56,$4C,$00,$C4,$44,$4C,$56,$5A,$5A,$56,$5A,$66,$56,$5A,$66
      .BYTE    $F2,$80,$FE,$00,$00,$72,$5A,$CC,$72,$5A,$CC,$72,$5A,$CC,$80,$B8
      .BYTE    $80,$4C,$56,$5A,$56,$5A,$E6,$F2,$80,$FA,$FF,$00

; NOTE THAT TUNES 1 AND 2 SET BOTH THE SPEED AND THE INSTRUMENT. 
; TUNE 3 CONTINUES AT THE SAME SPEED AS THE PREVIOUS ONE; BUT THE 
; INSTRUMENT IS CHANGED DURING THE TUNE.

; THE PROGRAM CAN BE CHANGED TO USE THE SPEAKER SHOWN IN 
; FIGURE 5.1 OF THE KIM MANUAL AS FOLLOWS:
;
;    BYTE           INITIALLY       CHANGE TO
;    020D              43                01
;    024C              A7                FF
;    0255              27                00
;    0270              42                00

; ***** Extra Datafile for Music Box *****

;       .BYTE   $FE,$00,$56,$52,$4D,$AF,$4D,$AF,$4D,$FC,$06,$AF,$FC,$02,$FE,$FF
;       .BYTE   $2F,$29,$26,$24,$2F,$29,$A4,$32,$A9,$FC,$06,$AF,$FC,$02,$FE,$00
;       .BYTE   $56,$52,$4D,$AF,$4D,$AF,$4D,$FC,$06,$AF,$FC,$02,$FE,$FF,$39,$40
;       .BYTE   $44,$39,$2F,$A4,$29,$2F,$39,$A9,$80,$80,$FE,$00,$56,$52,$4D,$AF
;       .BYTE   $4D,$AF,$4D,$FC,$06,$AF,$FC,$02,$FE,$FF,$2F,$29,$26,$24,$2F,$29
;       .BYTE   $A4,$32,$A9,$AF,$80,$80,$2F,$29,$24,$2F,$29,$A4,$2F,$29,$2F,$24
;       .BYTE   $2F,$29,$A4,$2F,$29,$2F,$24,$2F,$29,$A4,$32,$A9,$AF,$80,$80,$FA
;       .BYTE   $FF,$00

; Note: be sure to set the break vector 17FE,FF (00,1C)
