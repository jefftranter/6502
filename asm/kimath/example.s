; Example program from KIMATH manual.
;
; Calculates resonant frequency using the formula 1/(2*PI*SQRT(L*C))
;
; Port to CC65, bug fixes, and additions to make it run standalone by
; Jeff Tranter <tranter@pobox.com>

; KIM-1 ROM  Routines

CHAROUT =       $1EA0

; KIMATH routines

ARGXH   =       $0007
ARGXL   =       $0006
ARGYH   =       $0009
ARGYL   =       $0008
DIVIDE  =       $FA16
EXTRA   =       $0011
ex      =       $0246
ez      =       $026A
IPREC   =       $FEE8
KONH    =       $000F
KONL    =       $000E
MLTPLY  =       $F90B
MVYX    =       $FCFC
MVZX    =       $FD0C
MVZY    =       $FD10
NKON    =       $0001
PREC    =       $0010
RES     =       $000A
SQRT    =       $FA9E
sx      =       $0235
ULOADX  =       $FE8A
ULOADY  =       $FEA2
USRLKP  =       $FD92
USTRES  =       $FEBA

; (1) define storage

NDIG    =       8
        .org    $5000
L       .res    NDIG+3
C       .res    NDIG+3
TWOPI   .byte   $00, $62, $83, $18, $54, $F0; TWOPI
ONE     .byte   $00, $10, $F0

; (2) define precision

EX     =        2       ; use 2 extra digits in calculation
       LDA      #NDIG
       STA      PREC
       LDA      #EX
       STA      EXTRA
       JSR      IPREC   ; calculate N

; (3) Read L and transfer to RX

       JSR      GETNL   ; user-provided subroutine to input value for L
                        ; to L register in unpacked format.
       LDA      #<L     ; low-order byte of address of L
       STA      ARGXL
       LDA      #>L     ; high-order byte
       STA      ARGXH
       JSR      ULOADX  ; Move L to RX

; (4) Read C and transfer to RY

       LDA      #<C     ; low-order byte of address of C
       STA      ARGYL
       LDA      #>C     ; high-order byte of address of C
       STA      ARGYH
       JSR      GETNC   ; user-provided subroutine to input value
                        ; for C to C register in unpacked format.
       JSR      ULOADY  ; transfer C to RY

; (5) Compute L times C

       JSR      MLTPLY

; (6) Move RZ to RX and compute square root

       JSR      MVZX    ; move RZ to RX
       JSR      SQRIN   ; adjust exponent
       JSR      SQRT    ; compute root
       JSR      SQROUT  ; adjust exponent back

; (7) get 2pi to RX

       LDA      #<TWOPI ; address low of first constant
       STA      KONL
       LDA      #>TWOPI
       STA      KONH
       LDA      #00
       STA      NKON
       JSR      USRLKP  ; constant to RY
       JSR      MVYX    ; move it to RX

; (8) Move RZ to RY and multiply

       JSR      MVZY
       JSR      MLTPLY

; (9) get 1 (constant) and put in RX

       JSR      USRLKP  ; get next constant
       JSR      MVYX    ; move it to RX

; (10) Move RZ to RY and divide

       JSR      MVZY    ; move RZ to RY
       JSR      DIVIDE

; (11) Move RZ to L and print it out

       LDA      #<L     ; set up
       STA      RES     ; pointer
       LDA      #>L     ; to locate
       STA      RES+1   ; destination register
       JSR      USTRES  ; move it
       JSR      PRINTL  ; user-supplied routine to print out L.
       JMP      $1C00
       RTS

; Routine to adjust exponent so that the range is within that accepted
; by the square root function (1..100). The orginal exponent is saved
; in VAL and restored later by SQROUT.

VAL    .res     1

SQRIN  LDA      #0      ; Initialize VAL (bug in original code)
       STA      VAL
       SED
SQ1    SEC
       LDA      ex
       SBC      #2
       STA      ex
       BCC      OUT
       CLC
       LDA      VAL
       ADC      #1
       STA      VAL
       BNE      SQ1
OUT    ADC      #2
       BIT      sx
       BVC      SQ2
       STA      ex
       CLC
       ADC      VAL
       STA      VAL
       RTS
SQ2    STA      ex
       RTS

SQROUT LDA      VAL
       STA      ez
       RTS

; Test data in unpacked ASCII format
; L = 888 uH (+8.88E-4)
; C = 365 pF (+3.65E-10)
; Result should be 279.554960 kHz (+2.79554960E+5)
L1:   .byte $40, '8', '8', '8', '0', '0', '0', '0', '0', '0', '4'
C1:   .byte $40, '3', '6', '5', '0', '0', '0', '0', '0', '1', '0'

; User-supplied routine to read value of C into register C.
; Uses hard-coded value above.
GETNC  LDX      #0
COPYC  LDA      C1,X
       STA      C,X
       INX
       CPX      #NDIG+3
       BNE      COPYC
       RTS

; User-provided subroutine to input value for L to L register in
; unpacked format.
; Uses hard-coded value above.
GETNL  LDX      #0
COPYL  LDA      L1,X
       STA      L,X
       INX
       CPX      #NDIG+3
       BNE      COPYL
       RTS

; User-supplied routine to print out L.
; Sample output: F=2.79554960E05

PRINTL LDA   #$0D        ; Print CR
       JSR   CHAROUT
       LDA   #$0A        ; Print LF
       JSR   CHAROUT
       LDA   #'F'
       JSR   CHAROUT
       LDA   #'='
       JSR   CHAROUT
       LDA   L           ; Sign byte
       AND   #%10000000  ; Look at mantissa sign bit
       BEQ   MPLUS       ; Plus if zero
       LDA   #'-'
       JSR   CHAROUT
MPLUS  LDX   #$01        ; Index into value
DIGS   LDA   L,X         ; Get a character
       JSR   CHAROUT     ; Print it
       INX               ; Update index
       CPX   #2
       BNE   NOPT
       LDA   #'.'        ; Print decimal point
       JSR   CHAROUT
NOPT   CPX   #NDIG+2     ; Done?
       BNE   DIGS        ; Continue if not
       LDA   #'E'        ; Print 'E'
       JSR   CHAROUT
       LDA   L           ; Look at exponent sign bit
       AND   #%01000000
       BEQ   EPLUS       ; Plus if zero
       LDA   #'-'
       JSR   CHAROUT
EPLUS  LDA   L,X         ; First digit of exponent
       JSR   CHAROUT
       INX
       LDA   L,X         ; Second digit of exponent
       JSR   CHAROUT
       LDA   #$0D        ; Print CR
       JSR   CHAROUT
       LDA   #$0A        ; Print LF
       JSR   CHAROUT
       RTS

       .END
