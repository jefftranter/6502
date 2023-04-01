; Calculator supplement for KIMATH
; see KIMATH manual for undefined labels

; KIM-1 routines
         CHAROUT = $1EA0
         CHARIN = $1E5A

; KIMATH routines
         ADD = $F808
         ARGYH = $0009
         ARGYL = $0008
         ATANX = $FB78
         CLRX = $FD71
         CLRY = $FD7C
         CLRZ = $FD87
         CNT = $03
         DECHEX = $FBC3
         DIVIDE = $FA16
         EM = $027C
         EX = $0246
         EY = $0258
         EZ = $026A
         INFIN = $FCD2
         KON = $0E
         KONH = $0F
         LOG = $FAE7
         LOOKUP = $FD92
         MUL = $F90B
         MVMX = $FD1C
         MVMY = $FD20
         MVNX = $FD2C
         MVXM = $FCF4
         MVXN = $FCF8
         MVXY = $FCEC
         MVXZ = $FCF0
         MVYX = $FCFC
         MVYZ = $FD00
         MVZM = $FD14
         MVZN = $FD18
         MVZX = $FD0C
         MVZY = $FD10
         NKON = $01
         PGTARG = $FDE1
         PREC = $10
         PSTRES = $FE3C
         PTR = $0C
         RES = $0A
         RX = $0235
         SQRT0 = $FAB5
         SUB = $F800
         SX = $0235
         SY = $0247
         SZ = $0259
         TANX = $FB5C
         TENX = $FB41
         XSY = $FCBF
         XZTST = $FCA6

        .org  $0000
N       .byte $10       ;set to 10 or length
        .res 3
LENGTH  .res 1
;       .org  $0017
        .res $0017-*
PER     .res  1
QUADCT  .res  1
ID      .res  1
SIGN    .res  1
CAL1    .res  1
CAL2    .res  1
;       .org  $0040
        .res  $0040-*
LR      .res  64        ;I/O buffer 64 bytes
; Page 03 used for numeric storage.
; clear all bytes to 00. Set last 11
; bytes of page 03 ( or first 11 of
; page 04)to FF.
;       .org $0300
        .res $0300-*
        .res 256-11, $00
        .res 11, $FF

;       .org $3000
        .res $3000-*
PACKER  JSR CLRY        ;routine to load  raw
        LDX #$00        ;number at (ARGYL,
        LDY #$00        ;ARGYH) into Ry.
        STY PER
        STY CNT
        STY SIGN
        LDA (ARGYL),Y   ;1st character
        CMP #$2B        ;"+"
        BEQ PACK1
        CMP #$2D        ;"-"
        BNE PACK2
        LDA #$80
        STA SIGN        ;set sign neg
PACK1   INY
        LDA (ARGYL),Y
PACK2   CMP #$2E        ;"."
        BNE PACK4
        LDA #$40        ;decimal point found
        BIT PER
        BMI PACK3       ;stop counting exponent
        ORA SIGN        ;start counting down
        STA SIGN
        ASL A
PACK3   STA PER
        BNE PACK1       ;unconditional
PACK4   CMP #$30        ;test for 0-9
        BCC PACK8       ;non-digit
        CMP #$3A
        BCS PACK8       ;non-digit
        BIT PER
        BPL PACK5       ;not counting exp
        INC CNT
        BVS PACK7       ;counting up
        CMP #$30        ;zero?
        BEQ PACK1       ;place setting zero
        PHA
        LDA #$40        ;stop counting
        BNE PACK6       ;unconditional
PACK5   BVS PACK7       ;counting stopped
        CMP #$30
        BEQ PACK1       ;leading zero
        PHA
        LDA #$C0        ;start counting up
PACK6   STA PER
        PLA
PACK7   AND #$0F        ;mask off digit
        STA SY+1,X      ;store in Ry
        INX
        CPX #$11        ;16 digits?
        BCC PACK1       ;not yet
        LDX #$10        ;clamp X to 16
        BNE PACK1       ;unconditional
PACK8   TXA             ;X=0?
        BNE PACK9       ;no
        STX SIGN
        STX CNT
PACK9   JSR HEXDEC      ;convert exp to BCD
EXOT    STA EY
        LDA (ARGYL),Y
        CMP #$45        ;"E"
        BEQ EXP
        LDA SIGN
        STA SY
        RTS
EXP     LDA CNT         ;old exp
        PHA
        LDA SIGN
        PHA
        AND #$80        ;preserve man sign
        STA SIGN        ;new sign
        LDA #$00
        STA CNT         ;new exp
        INY
        LDA (ARGYL),Y
        CMP #$2B        ;"+"
        BEQ EXP1
        CMP #$2D        ;"-"
        BNE EXP2
        LDA #$40        ;new exp sign neg
        ORA SIGN
        STA SIGN
EXP1    INY
        LDA (ARGYL),Y
EXP2    CMP #$30        ;test for 0-9
        BCC EXP3        ;non digit
        CMP #$3A
        BCS EXP3        ;non digit
        AND #$0F        ;mask off digit
        ASL CNT
        ASL CNT
        ASL CNT
        ASL CNT         ;shift exponent
        ORA CNT         ;combine with digit
        STA CNT
        SEC
        BCS EXP1        ;unconditional
EXP3    SED             ;adjust sign and exp
        PLA             ;old sign
        PHA
        EOR SIGN        ;test signs of the
        STA PER         ;two exp's to see
        BIT PER         ;if they are the same
        BVC EXP6        ;sign's same
        PLA             ;old sign
        STA PER
        PLA             ;old exp
        CMP CNT
        BCC EXP4        ;new exp gtr
        SBC CNT         ;difference of exp's
        PHA             ;adjusted exp
        LDA PER         ;old sign
        PHA             ;adjusted sign
        SEC
        BCS EXP5        ;unconditional
EXP4    SBC CNT         ;difference of exp's
        STA CNT         ;compensate subtracting
        LDA #$00        ;larger number from
        SBC CNT         ;small by subtracting
        PHA             ;from zero
        LDA SIGN
        PHA             ;adjusted sign
EXP5    LDA #$00
        STA CNT
EXP6    CLC
        PLA             ;sign
        STA SIGN
        PLA             ;exponent
        ADC CNT
        PHA
        CLD
        BNE EXP7        ;exp not zero
        LDA #$BF
        AND SIGN
        STA SIGN
EXP7    PLA
        JMP EXOT
UNPACK  LDA EZ          ;routine to unpack
        STA CNT         ;Rz and store at
        JSR DECHEX      ;(RES,RES+1)
        LDY #$00
        BIT SZ
        BPL UNPAC1      ;positive number
        LDA #$2D        ;"-"
        STA (RES),Y
        INY
UNPAC1  LDX #$00
        LDA CNT
        CMP #$10        ;exp gtr 15
        BCS UNPAC7      ;use scientific notation
        BIT SZ
        BVC UNPAC3      ;exp is positive
        LDA #$2E        ;decimal point
        STA (RES),Y
        LDA #$30        ;zero
UNPAC2  INY             ;display place setting 0's
        STA (RES),Y
        DEC CNT
        BPL UNPAC2
        DEY
UNPAC3  LDA SZ+1,X      ;fetch digit
        ORA #$30        ;convert to ASCII
        STA (RES),Y
        INX
        INY
        BIT CNT
        BMI UNPAC4
        DEC CNT
        BPL UNPAC4
        LDA #$2E        ;decimal point
        STA (RES),Y
        INY
UNPAC4  CPX PREC        ;all digits moved?
        BNE UNPAC3
        BIT CNT
        BMI UNPAC6
        LDA #$30
UNPAC5  STA (RES),Y     ;trailing zero's
        INY
        DEC CNT
        BPL UNPAC5
UNPAC6  RTS
UNPAC7  LDA #$00        ;scientific notation
        STA CNT
        JSR UNPAC3
        LDA #$20        ;blank
        STA (RES),Y
        INY
        LDA #$45        ;"E"
        STA (RES),Y
        INY
        BIT SZ
        BVC UNPAC8      ;positive exponent
        LDA #$2D        ;"-"
        STA (RES),Y
        INY
UNPAC8  LDA EZ
        LSR A
        LSR A
        LSR A
        LSR A
        ORA #$30        ;convert to ASCII
        STA (RES),Y
        INY
        LDA EZ
        AND #$0F
        ORA #$30        ;convert to ASCII
        STA (RES),Y
        INY
        RTS

; routines to store and recall numbers.
; numbers are taken from Rz and stored
; in page 03. Numbers are recalled to Ry.
STORE   JSR SRCH
        BNE STOR1       ;ID already in memory
        LDA ID
        PHA
        LDA #$00
        JSR SRCH        ;look for empty cell
        BEQ STOR2       ;no room in page 03
        PLA
        STA (PTR),Y     ;set ID in pg 03
STOR1   LDA RES
        PHA
        LDA RES+1
        PHA
        LDA #$01
        JSR ADDM        ;add one to address
        LDA PTR
        STA RES
        LDA PTR+1
        STA RES+1
        LDA N
        STA PREC
        JSR PSTRES      ;Move Rz into Pg 03
        PLA
        STA RES+1
        PLA
        STA RES
        LDA ID
        RTS
STOR2   PLA
        LDA #$FF        ;No room in pg 3
        RTS
RECALL  JSR SRCH
        BEQ RECAL1      ;not in memory
        LDA #$01
        JSR ADDM        ;add one to address
        LDA N           ;recall number into Ry
        LSR A
        ADC #$01
        STA LENGTH
        JSR CLRZ
        JSR PGTARG
        JSR MVZY
        LDA ID
RECAL1  RTS
FORGET  JSR SRCH
        BEQ FORGE1
        LDA #$00
        STA (PTR),Y
FORGE1  RTS
SRCH    CLD             ;search page 03 for
        STA ID          ;ID or FF
        LDY #$00
        LDA #$02
        STA PTR+1
        LDA #$F5
        STA PTR
SRCH1   JSR ADDL
        LDA (PTR),Y
        CMP ID
        BEQ SRCH2
        CMP #$FF
        BNE SRCH1
SRCH2   CMP #$FF
        RTS
ADDL    LDA N           ;Add  length to address
        LSR A
        ADC #$03
ADDM    CLC             ;add A to address
        ADC PTR
        STA PTR
        LDA #$00
        ADC PTR+1
        STA PTR+1
        RTS
; LOG base 10 of Rx is found and stored
; in Rz. Rx must be positive and non zero
LOGT    LDA N
        PHA             ;save length
        LDA SX
        PHA             ;save sign
        LDA EX
        PHA             ;save exponent
        LDA #$00
        STA SX
        STA EX
        LDA #$09
        JSR SETCON      ;Ry=1/SQR(10)
        JSR MUL
        JSR MVZX
        JSR LOG
        JSR MVZX
        JSR CLRY
        LDA #$05
        STA SY+2        ;Ry=+.5
        JSR ADD
        JSR MVZX
        JSR CLRY
        PLA             ;exponent
        CMP #$10
        BCS LOGT1       ;exp gtr 9
        AND #$0F
        STA SY+1
        LDA #$00
        BEQ LOGT2       ;unconditional
LOGT1   PHA
        LSR A
        LSR A
        LSR A
        LSR A
        STA SY+1
        PLA
        AND #$0F
        STA SY+2
        LDA #$01
LOGT2   STA EY          ;Ry now contains exp
        PLA
        ASL A
        STA SY
        JSR ADD
        PLA
        STA N           ;length
        RTS
SQRT    JSR ABS         ;square root routine
        JSR XZTST
        BNE SQRT1
        RTS
SQRT1   JSR MVZN
        JSR MVZM
        LDA EX
        STA CNT
        JSR DECHEX      ;exp now hex
        LSR A           ;divide by two
        BNE SQRT2
        LDA #$01
SQRT2   STA CNT
        JSR HEXDEC      ;exp now BCD
        STA EM
        LDA #$07
        STA NKON
        JMP SQRT0
; routine to find the largest integer
; less than or equal to Rx.
INT     LDA N
        PHA             ;save length
        LDA SX
        PHA             ;save sign
        AND #$7F
        STA SX          ;set positive
        JSR MVXM
        BIT SX
        BVC INT1        ;Rx gtr than one
        JSR CLRX        ;Rx=0
INT1    LDA EX
        CMP #$15
        BCC INT2        ;exp less 15
        LDA #$15
INT2    STA CNT
        JSR DECHEX      ;exp now hex
        STA $00
        INC $00
        JSR CLRY
        JSR CLRZ
        JSR ADD
        PLA             ;sign
        BPL INT4
        JSR MVZX
        JSR MVMY
        LDA #$10
        STA N
        JSR SUB
        JSR MVZX
        JSR MVYZ
        JSR XZTST
        BEQ INT3
        JSR ONEX
        JSR ADD
INT3    LDA #$80
        STA SZ
INT4    PLA
        STA N
        RTS
; antilog base 10 routine. Rx must be
; gtr than -99 and less than +100
ALOG    BIT SX
        BVS ALOG2       ;Rx less than 1
        LDA EX
        CMP #$02
        BCC ALOG2       ;Exp less 2
ALOG1   JSR INFIN
        LDA SX
        LSR A
        STA SZ
        RTS
ALOG2   JSR MVXN
        JSR INT
        JSR MVZX
        LDX EZ
        CPX #$02
        BEQ ALOG1       ;X=-100
        LDA N
        PHA
        LDA SZ,X
        ASL A
        ASL A
        ASL A
        ASL A
        ORA SZ+1,X
        STA PER
        PHA             ;save exponent
        LDA SZ
        LSR A           ;adjust sign
        PHA             ;save sign
        JSR MVNX
        LDA PER
        BEQ ALOG3       ;exp=00
        JSR MVZY
        JSR SUB
        JSR MVZX
ALOG3   JSR TENX
        PLA
        STA SZ
        PLA
        STA EZ
        PLA
        STA N
        RTS
SIN     JSR TRIG5       ;SIN(Rx) found and
        JSR ADD         ;placed in Rz
TRIG1   JSR TRIG4
TRIG2   LDA QUADCT
        BEQ TRIG3
        CMP #$03
        BEQ TRIG3
        LDA SZ
        EOR #$80
        STA SZ
TRIG3   JMP CHOPIT      ;TAN(Rx) found and
TAN     JSR TRIG5       ;placed in Rz
        JSR SUB
TRIG4   JSR MVZY
        JSR MVMX
        JSR DIVIDE
        LDA EZ
        CMP #$06
        BCC TRIG3
        BIT SZ
        BVS TRIG3
        LDA SZ
        PHA
        JSR INFIN
        PLA
        STA SZ
        JMP CHOPIT
COS     JSR TRIG5       ;COS(Rx) found and
        JSR SUB         ;placed in Rz
        JSR MVZM
        JSR SUB
        JMP TRIG1
TRIG5   LDA #$FF        ;Rx can be any value
        STA QUADCT
TRIG6   BIT SX
        BMI TRIG7
        JSR Y360        ;angle is pos
        JSR SUB
        JSR MVZX
        JMP TRIG6
TRIG7   JSR Y360        ;angle is neg
        JSR ADD
        JSR MVZX
        BIT SX
        BMI TRIG7
TRIG8   JSR Y90
        JSR SUB
        JSR MVZX
        INC QUADCT
        BIT SX
        BPL TRIG8
        LDA QUADCT      ;angle between -90 and 0
        LSR A
        BCS TRIG9
        JSR Y90
        JSR ADD
        JSR MVZX
TRIG9   JSR Y90
        JSR DIVIDE
        JSR MVZX
        LDA N
        PHA
        JSR TANX        ;Rz=TAN(X/2)
        PLA
        STA N
        JSR MVZX
        JSR MVZY
        JSR MUL
        JSR MVZM
        JSR ADD
        JSR MVMY
        JSR MVZM
        JMP ONEX
Y90     LDA #$1E
        JMP SETCON
Y360    JSR CLRY
        LDA #$03
        STA SY+1
        LDA #$06
        STA SY+2
        BIT SX
        BVS Y360A
        SED
        LDA EX
        BEQ Y360A
        SEC
        SBC #$01
        CMP #$02
        BCS Y360B
Y360A   LDA #$02
Y360B   STA EY
        CLD
        RTS
; arctrig routines give results in degrees
ACOS    JSR ARCSET
        BIT SY
        BPL ASIN1       ;angle in 1st quad
        JSR ASIN1       ;angle in 2nd quad
        JSR MVZX
        LDA #$1B
        JSR SETCON      ;Ry=180
        JMP ADD
ASIN    JSR ARCSET
        JSR XSY
ASIN1   LDA SX
        AND #$80
        PHA
        JSR DIVIDE
        JSR MVZX
        PLA
        ORA SX
        STA SX
ATAN    LDA N
        PHA
        LDA SX
        PHA
        AND #$7F
        STA SX
        JSR XSY
        JSR ONEX
        JSR ADD
        JSR XSY
        JSR DIVIDE
        JSR MVZX
        JSR XZTST
        BEQ ATAN2
        BIT SX
        BVC ATAN1
        LDA EX
        BNE ATAN1
        LDA #$99
        STA EX
ATAN1   JSR ATANX
        PLA
        PHA
        AND #$40
        BNE ATAN2
        JSR MVZX
        LDA #$12
        JSR SETCON      ;Ry=Pi/2
        JSR XSY
        JSR SUB
ATAN2   PLA             ;sign
        AND #$80
        ORA SZ
        STA SZ
        JSR MVZX
        JSR DEG         ;convert to degrees
        PLA
        STA N
        RTS
ARCSET  BIT SX
        BVS ARC2        ;Rx less one
        LDA SX+1
        PHA
        LDA SX
        PHA
        JSR CLRX
        PLA
        STA SX
        PLA
        BEQ ARC1
        LDA #$01
ARC1    STA SX+1
ARC2    JSR MVXY        ;-1 ls X ls +1
        JSR MVXZ
        LDA #$01
        JSR STORE
        JSR MUL         ;X^2
        JSR MVZY
        JSR ONEX
        JSR SUB         ;1-X^2
        JSR MVZX
        JSR SQRT        ;SQR(1-X^2)
        JSR MVZX
        LDA #$01
        JMP RECALL      ;Ry ? ARG
;
ONEX    JSR CLRX
        LDA #$01
        STA RX+1        ;Rx=1.000
        RTS
;
ABS     LDA SX          ;Absolute value
        AND #$7F
        STA SX
        JMP MVXZ
;
DEG     LDA #$00        ;convert to deg
        JSR SETCON      ;Pi/180
        JMP DIVIDE
;
RAD     LDA #$00        ;convert to rad
        JSR SETCON      ;Pi/180
        JMP MUL
;
XRY     JSR MVYZ        ;raise Rx to Ry
        LDA #$01
        JSR STORE
        JSR LOGT
        JSR MVZX
        LDA #$01
        JSR RECALL
        JSR MUL
        JSR MVZX
        JMP ALOG
;
INV     JSR MVXY        ;find 1/Rx
        JSR ONEX
        JMP DIVIDE
;
PIE     LDA #$21        ;set Ry=Pi
        JMP SETCON
;
HEXDEC  SED             ;convert CNT from
        INC CNT         ;HEX to BCD
        LDA #$99
HEX1    CLC
        ADC #$01
        DEC CNT
        BNE HEX1
        STA CNT
        CLD
        RTS
;
SETCON  STA NKON        ;load constant in Ry
        LDA #$C0
        STA KON
        LDA #$37
        STA KONH
        JMP LOOKUP
;
CHOPIT  LDX N           ;remove unnedded 0's
CHOP1   LDA SZ,X        ;by adjusting PREC
        BNE CHOP2
        DEX
        BNE CHOP1
        STX SZ          ;man=0,clear sign,exp
        STX EZ
        INX
CHOP2   STX PREC
        RTS
;
PACADD  TYA             ;add Y to ARGY
        CLD
        CLC
        ADC ARGYL
        STA ARGYL
        LDA #$00
        ADC ARGYH
        STA ARGYH
        RTS
RNDF    LDA N           ;round off routine
        PHA             ;round off to X
        LDA #$10
        STA N
        BIT SX
        BVS RNDF1
        CMP EX
        BCC RNDF3
RNDF1   LDA SX
        PHA
        AND #$7F
        STA SX
        TXA
        PHA
        JSR MVXY
        JSR ONEX
        PLA
        PHA
        TAX
        LDA #$05
        STA SX+2,X
        JSR ADD
        JSR MVZY
        JSR CLRZ
        JSR ONEX
        JSR XSY
        PLA
        TAX
        INX
        STX N
        JSR SUB
        JSR MVZX
        JSR XZTST
        BEQ RNDF2
        PLA
        PHA
        AND #$80
        ORA SX
RNDF2   STA SX
        PLA
RNDF3   JSR MVXZ
        PLA
        STA N
        RTS
        .res $0E, $00
INVEC   JMP CHARIN      ;user input routine
OTVEC   JMP CHAROUT     ;user output routine
ECHO    .byte $0A       ;echo character
SCICAL  LDA #$01        ;START OF ROUTINE
        STA CAL1
BACK    DEC CAL1        ;backspace routine
LOOP1   JSR INVEC
        CMP #$08        ;backspace?
        BEQ BACK        ;yes
        LDX CAL1        ;X points to open cell
        STA LR,X        ;store chars at 0040
        INC CAL1
        CMP #$0D        ;carriage return?
        BNE LOOP1
        LDA ECHO
        JSR OTVEC       ;Echo character
        LDA LR          ;assignment char
        PHA
        LDA #$40
        STA ARGYL
        STA RES
        LDA #$00
        STA ARGYH
        STA RES+1
        LDY #$02
        JSR LOAD
        BCS HAV1        ;number loaded
        LDA LR+3        ;letter found, test function
        JSR LTRTST
        BCC FUNCTN      ;function found
        LDA LR+2
        JSR RECALL      ;fetch number into Ry
        CMP #$FF
        BEQ WHATC       ;number not in memory
        LDY #$03
HAV1    JSR MVYX
        LDA (ARGYL),Y
        PHA             ;operation
        CMP #$0D        ;carriage return
        BEQ OPS
        INY
        JSR LOAD
        BCS OPS
        JSR RECALL
        CMP #$FF
WHATC   BEQ WHATD
OPS     PLA
        JSR OPERT       ;two number op
        JSR MVZX
        LDX N
        DEX
        DEX
OUT     JSR RNDF        ;resutl in Rz
        JSR CHOPIT      ;remove unwanted zero's
        PLA             ;assignment
        CMP #$40        ;@?
        BEQ OUT1        ;display result
        JSR LTRTST      ;assignment a letter?
        BCS WHAT        ;non letter
        JSR STORE       ;save result
        CMP #$FF
WHATD   BEQ WHAT        ;no room in pg 03
        BNE SCICAL      ;unconditional
OUT1    JSR UNPACK      ;display Rz
        LDA #$0D        ;car ret
        STA (RES),Y
        INY
        LDA ECHO        ;echo character
        STA (RES),Y
DISP    LDX #$00
        STX CAL1
DISP1   LDX CAL1
        LDA LR,X
        CMP ECHO        ;last character?
        BEQ DISP2       ;yes
        JSR OTVEC
        INC CAL1
        BNE DISP1       ;unconditional
DISP2   JSR OTVEC
        JMP SCICAL
FUNCTN  LDY #$00        ;function found
        LDX #$00
        JSR LOOK        ;match 1st letter
        JSR LOOK        ;match 2nd letter
        JSR LOOK        ;match 3rd letter
        LDA TAB2-1,Y    ;Add Hi byte
        STA CAL2
        LDA TAB2-2,Y    ;Add Lo byte
        STA CAL1
        LDY #$06
        JSR LOAD        ;load arg
        BCS FUN1
        JSR RECALL
        CMP #$FF
        BEQ WHAT        ;number not in mem
FUN1    JSR MVYX
        JSR FUN         ;perform function
        JSR MVZX
        LDX #$08        ;round off to 8 digits
        JMP OUT         ;display result
FUN     JMP (CAL1)
LOOK    LDA TAB1,Y
        CMP LR+2,X
        BEQ FOUND
        CMP #$FF        ;end of table
        BEQ NTFND
        INY
        INY
        INY
        BNE LOOK
NTFND   BEQ WHAT        ;function not there
FOUND   INX
        INY
        RTS
WHAT    LDX #$05        ;output "WHAT"
WHAT1   LDA WHAT2,X
        STA LR,X
        DEX
        BPL WHAT1
        JMP DISP
WHAT2   .byte "WHAT",$0D,$0A
LOAD    LDA (ARGYL),Y   ;load variable into Ry
        JSR LTRTST
        BCC LOAD1
        JSR PACADD      ;adjust address
        JSR PACKER      ;load number
        SEC
LOAD1   RTS
LTRTST  CMP #$41        ;test for letter
        BCC BAD
        CMP #$5B
        BCC OUTL
BAD     SEC             ;C=1,non letter
OUTL    RTS
OPERT   CMP #$5E        ;raise to power
        BNE OP1
        JMP XRY
OP1     CMP #$2A        ;*
        BNE OP2
        JMP MUL
OP2     CMP #$2F        ;/
        BNE OP3
        JMP DIVIDE
OP3     CMP #$2B        ;+
        BNE OP4
        JMP ADD
OP4     CMP #$2D        ;-
        BNE OP5
        JMP SUB
OP5     JMP MVXZ

; Tables:

; TAB1    function code names

TAB1    .byte "ABS"
        .byte "ACS"
        .byte "ALG"
        .byte "ASN"
        .byte "ATN"
        .byte "COS"
        .byte "DEG"
        .byte "FNA"
        .byte "FNB"
        .byte "FNC"
        .byte "INV"
        .byte "LOG"
        .byte "RAD"
        .byte "SIN"
        .byte "SQR"
        .byte "TAN"

        .res 12, $FF

; TAB2    function addresses

TAB2:   .byte $FF
        .word ABS
        .byte $FF
        .word ACOS
        .byte $FF
        .word ALOG
        .byte $FF
        .word ASIN
        .byte $FF
        .word ATAN
        .byte $FF
        .word COS
        .byte $FF
        .word DEG
        .byte $FF
        .word MVXZ
        .byte $FF
        .word MVXZ
        .byte $FF
        .word MVXZ
        .byte $FF
        .word INV
        .byte $FF
        .word LOGT
        .byte $FF
        .word RAD
        .byte $FF
        .word SIN
        .byte $FF
        .word SQRT
        .byte $FF
        .word TAN
        .res 9, $FF

        .byte $40, $17, $45, $32, $92, $51, $99, $40, $F2 ;Pi/180      00
        .byte $40, $31, $62, $27, $76, $60, $16, $70, $F1 ;1/SQR(10)   09
        .byte $00, $15, $70, $79, $63, $26, $79, $50, $F0 ;Pi/2        12
        .byte $00, $18, $F2                               ;180         1B
        .byte $00, $90, $F1                               ; 90         1E
        .byte $00, $31, $41, $59, $26, $53, $59, $F0      ; Pi         21
