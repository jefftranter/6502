; ******************************
; ***** ONE ARMED BANDIT   *****
; ***** BY JIM BUTTERFIELD *****
; ******************************

WINDOW  = $0000                 ; DISPLAY WINDOW
AMT     = $0005                 ; CASH CACHE
ARROW   = $0006
RWD     = $0007                 ; REWARD
STALLA  = $0008                 ; WAIT WHILE
TUMBLE  = $0009

; LINKAGES TO KIM

KEYIN  = $1F40                  ; IS KEY DEPRESSED?
PADD   = $1741
SAD    = $1740
SBD    = $1742
TABLE  = $1FE7                  ; HEX:7 SEG

; MAIN PROGRAM

       .ORG $0200

GO:    LDA     #$25             ; GIVE HIM $25
       STA     AMT              ; TO START WITH
       JSR     CVAMT            ; AND SHOW IT TO HIM.
       LDA     #$00             ; RESET ARROW.
       STA     ARROW

; MAIN DISPLAY LOOP

LPA:   JSR     DISPLY           ; DISPLAY UNTIL
       BNE     LPA              ; [GO] IS RELEASED
ROLL:  INC     TUMBLE           ; RANDOMIZE TUMBLE
       JSR     DISPLY           ; DISPLAY UNTIL
       BEQ     ROLL             ; A KEY IS HIT

       LDA     #$03
       STA     ARROW
       SED
       SEC
       LDA     AMT
       SBC     #$01            ; CHARGE ONE BUCK.
       STA     AMT
       JSR     CVAMT           ; CONVERT FOR LED
       ROL     TUMBLE

LPB:   JSR     DISPLY
       DEC     STALLA          ; DISPLAY A WHILE.
       BNE     LPB
       LDX     ARROW
       LDA     TUMBLE          ; MAKE A
       AND     #$06            ; RESULT
       ORA     #$40

       STA     WINDOW+1,X
       LSR     TUMBLE
       LSR     TUMBLE          ; DO ALL
       DEC     ARROW           ; 3 WINDOWS
       BNE     LPB

; ALL WHEELS STOPPED - COMPUTE PAYOFF

       LDA     WINDOW+4
       CMP     WINDOW+3        ; CHECK FOR
       BNE     NOMAT           ; A MATCH.
       CMP     WINDOW+2
       BNE     NOMAT
       LDX     #$10
       CMP     #$40            ; PAY $15 FOR 3 BARS
       BEQ     PAY
       LDX     #$0B            ; NOTE: ERROR IN PRINTED LISTING
       CMP     #$42            ; PAY $10 FOR 3 UPS
       BEQ     PAY
       LDX     #$06
       CMP     #$44            ; PAY $5 FOR 3 DOWNS
       BEQ     PAY
       DEX

; A WIN!!! PAY AMOUNT IN X

PAY:   STX     RWD             ; HIDE REWARD
PAX:   LDA     #$80
       STA     STALLA
LPC:   JSR     DISPLY          ; DISPLAY
       DEC     STALLA          ; FOR A HALF
       BNE     LPC             ; A WHILE.
       DEC     RWD
       BEQ     LPA
       CLC                     ; SLOWLY ADD
       SED                     ; THE PAYOFF
       LDA     AMT             ; TO THE AM'T.
       ADC     #$01
       BCS     LPA
       STA     AMT
       JSR     CVAMT
       BNE     PAX

; WHEELS NOT ALL THE SAME - CHECK FOR SMALL PAYOFF

NOMAT: LDX     #$03
       CMP     #$46            ; A CHERRY?
       BEQ     PAY
LOK:   JSR     DISPLY
       LDA     AMT             ; CAN'T PLAY
       BNE     LPA             ; WITH NO DOUGH!
       BEQ     LOK

; DISPLAY SUBROUTINE

DISPLY: LDX    ARROW
       BPL     INDIS           ; ROLL
OVER:  INC     WINDOW+2,X      ; THE DRUM
INDIS: DEX
       BPL     OVER
       LDA     #$7F
       STA     PADD
       LDY     #$0B            ; NOTE: ERROR IN PRINTED LISTING
       LDX     #$04
LITE:  LDA     WINDOW,X        ; LIGHT
       STY     SBD             ; ALL THE
       STA     SAD             ; WINDOWS
       CLD
       LDA     #$7F
ZIP:   SBC     #$01
       BNE     ZIP
       STA     SBD
       INY
       INY
       DEX
       BPL     LITE
       JSR     KEYIN
       RTS

; AMOUNT CONVERSION

CVAMT: LDA     AMT
       AND     #$0F            ; TRANSLATE
       TAX                     ; AMOUNT
       LDA     TABLE,X         ; TO LED
       STA     WINDOW          ; CODE.
       LDA     AMT
       LSR     A
       LSR     A
       LSR     A
       LSR     A
       TAX
       LDA     TABLE,X
       STA     WINDOW+01
       RTS
