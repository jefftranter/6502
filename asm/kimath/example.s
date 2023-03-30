; Example program from KMATH manual.

; KIMATH routines

ARGXH   =       $0007
ARGXL   =       $0006
ARGYH   =       $0009
ARGYL   =       $0008
DIVIDE  =       $FA16
EXTRA   =       $0011
EZ      =       $026A
KONH    =       $000F
KONL    =       $000E
MLTPLY  =       $F90B
MVYX    =       $FCFC
MVZX    =       $FD0C
MVZY    =       $FD10
NKON    =       $0001
PREC    =       $0010
RES     =       $000A
SQRT    =       $DA9E
sx      =       $0246
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
       JSR      PREC    ; calculate N

; (3) Read L and transfer to RX

       JSR      GETNL   ; user-provided subroutine to input value for L
                        ; to L register in unpacked format.
       LDA      #>L     ; low-order byte of address of L
       STA      ARGXL
       LDA      #<L     ; high-order byte
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
       LDA      #<TWOPI ; address low of First constant
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
       JSR      DIVIDE  ;
                        ; (11) Move RZ to L and print it out
       LDA      #<L     ; set up
       STA      RES     ; pointer
       LDA      #>L     ; to locate
       STA      RES+1   ; destination register
       JSR      USTRES  ; move it
       JSR      PRINTL  ; user-supplied routine to print out L.
       RTS

VAL    .res     1

SQRIN  SED
SQ1    SEC
       LDA      EX
       SBC      #2
       STA      EX
       BCC      OUT
       CLC
       LDA      VAL
       ADC      #1
       STA      VAL
       BNE      SQ1
OUT    ADC      #2
       BIT      sx
       BVC      SQ2
       STA      EX
       CLC
       ADC      VAL
       STA      VAL
       CLD
       RTS
SQ2    STA      EX
       CLD
       RTS

SQROUT LDA      VAL
       STA      EZ
       RTS

; User-supplied routine to read value of C into register C.
; Not implemented.
GETNC  RTS

; User-provided subroutine to input value for L to L register in
; unpacked format.
; Not implemented.
GETNL  RTS

; User-supplied routine to print out L.
; Not implemented.
PRINTL RTS

       .END
