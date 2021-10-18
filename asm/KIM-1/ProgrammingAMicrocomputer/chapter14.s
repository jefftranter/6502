; Code for Assembler. Chapter 14.

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
GETCH   = $1E5A
OUTCH   = $1EA0
CRLF    = $1E2F
GETBYT  = $1F9D
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703

; This is the code for the assembler. I want to emphasize once again
; that  this is a lousy assembler. There are no limit checks or type
; checks; there are almost no diagnostics; input format is very rigid
; in the sense that if n characters are permitted in a given field
; then exactly n are required. Obviously to make this an easy assem-
; bler for a human to use we would probably start over from scratch.
; But we would have very little expectation of fitting into 512 bytes.
;
; We begin with usual setting up the stop key. We issue a carriage
; return and a line feed. Then we discard blanks, carriage returns,
; line feeds, and deletes (rubouts):

START:  LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
RESET:  LDX     #$FF            ; Set stack pointer to FF
        TXS
        LDX     #$00
READY:  STX     T1              ; Save x because CRLF doesn't
        JSR     CRLF            ; 1E2F prints carriage return
BEGIN:  LDX     T1
        JSR     GETCH           ; Get a character
        CMP     #' '            ; Space
        BEQ     BEGIN
        CMP     #$0D            ; Carriage return
        BEQ     BEGIN
        CMP     #$0A            ; Line feed
        BEQ     BEGIN
        CMP     #$7F            ; Rub-out
        BEQ     BEGIN

; Anything else we will accept. If it was an asterisk that means
; that we should set the address pointer. If not an asterisk we will
; save that first character in T1, get another and save it in T2 and
; then get a third character.

        CMP     #'*'            ; Star
        BEQ     STAR
        STA     T1              ; It wasn't * so we get
        JSR     GETCH           ;  two more characters
        STA     T2              ;  because the next decision
        JSR     GETCH           ;  is on character # three

; Now we do a four way branch depending on what the 3rd character is.

        CMP     #' '            ; Blank " "
        BEQ     BLANK
        CMP     #':'            ; Colon ":"
        BEQ     COLON
        CMP     #'D'            ; Letter "D"
        BEQ     LETRD
        CMP     #'='            ; "=" equals
        BEQ     EQUALS
        LDY     #$31            ; Message saying error "E1" - unknown type
        JMP     MES             ; Output message then look for a new line

; The first portion to examine is what to do when you see stars. What
; you do is read in *exactly* two characters and assume that they are
; either digits or letters and store them as 4 bit patterns in X. If
; you type 1 then 2,X will hold 0001 0010. Most of this work is done
; in a subroutine called GETBYT.

STAR:   JSR     GETBYT          ; (1F9D)
        TAX
        JMP     READY

; A full colon means it was a label for an instruction. We use the
; subroutine LABEL to make an entry n the symbol table:

COLON:  JSR     LABEL
        JMP     BEGIN           ; Do not give new line.

; An equal sign means that we are defining a hex constant. First
; enter the label n the symbol table and then get four characters
; for the memory cell:

EQUALS: JSR     LABEL
        JSR     GETBYT
        STA     HYBYT,X
        JSR     GETBYT
        STA     LOBYT,X
        INX
        JMP     READY

; A letter D implies that the user typed END. Save the address point-
; er and check to see if any unresolved forward references are left:

LETRD:  STX     T1
        LDX     SIZE
L1:     LDA     STAB2,X         ; 2nd letter is minus is
        BMI     GOTONE          ;  unresolved
MORE:   DEX
        BNE     L1
        LDX     T1
        JMP     READY
GOTONE: LDA     STAB,X
        JSR     OUTCH           ; Print 1st character
        LDA     STAB2,X
        JSR     OUTCH
        LDA     #'%'            ; % symbol
        JSR     OUTCH           ; Print it
        JMP     MORE

; When we find a blank or space as the "third" character we have to
; see if the two proceeding ones make up an opcode. Because of the way
; the op-code mnemonics are chosen the sum of the two letters is
; unique. Further we arrange them so that the index within the table
; of an op-code corresponds to the translation of that op-code:

BLANK:  LDY     #$0F
        LDA     T1
        CLC
        ADC     T2
LX:     CMP     OPCODTAB,Y
        BEQ     FNDOP
        DEY
        BPL     LX
        LDA     #$32            ; E2 - unknown op-code
        JMP     MES
FNDOP:  TYA
        ASL                     ; Shift left two places
        ASL
        STA     HYBYT,X
MORE1:  JSR     GETCH           ; Get modifier
        CMP     #' '
        BEQ     MORE1
        AND     #$03
        ORA     HYBYT,X
        STA     HYBYT,X
L2:     JSR     GETCH           ; Get 1st character
        CMP     #' '            ;  of the
        BEQ     L2              ;  address
        STA     T1
        JSR     GETCH
        ORA     #$80            ; Set sign = minus
        STA     T2
        JSR     SEEK
        BEQ     ADDED           ; Was added to symbol table
        BMI     PUTON           ; Forward reference
        LDA     STAB3,Y         ; Set address field
        STA     LOBYT,X         ; To what symbol table has
ADDED:  INX
        JMP     READY
PUTON:  LDA     STAB3,Y         ; Put on the chain of forward
                                ;  references get S.T. value
        STA     LOBYT,X         ; Store in address field
        TXA                     ; Address pointer stores in
        STA     STAB3,Y         ;  the symbol table as value
        INX
        JMP     READY

; Skip to $0200 so we don't put code in page 1 where the stack is located.
        .RES    $0200-*

; The message routine is very simple and only prints out "EM" where
; M is passed in the accumulator:

MES:    STA     T1
        LDA     #'E'            ; Letter E
        JSR     OUTCH
        LDA     T1
        JSR     OUTCH
        JMP     RESET           ; Reset stack pointer to FF

; The "label" subroutine is entered when we have the definition of a
; symbol to take care of. It uses the SEEK subroutine to see if the
; symbol has already been mentioned. If not the symbol is entered in
; the symbol table and we return. If the symbol has been mentioned
; and is already defined we issue an "E3" to indicate "double defined".
; If mentioned as an as yet undefined forward reference we have to un-
; chain the forward reference list. This routine will *not* unchain a
; chain which ends in cell 0.

LABEL:  JSR     SEEK
        BEQ     ENTERED
        BMI     UNCHAIN
        LDY     #'3'
        JMP     MES             ; Issue "E3"
ENTERED:
        RTS
UNCHAIN:
        LDA     STAB2,Y         ; Clear off the minus
        AND     #$7F            ; Sign from the second
        STA     STAB2,Y         ;  letter of the symbol
        LDA     STAB3,Y         ; Store link
        STA     T1              ;  in T1
        TXA
        STA     STAB3,Y         ; Put (x) in value in symbol table
        LDY     T1              ; Get link
LP:     LDA     LOBYT,Y         ; Get next link
        STA     T1              ; To T1
        TXA
        STA     LOBYT,Y         ; Put (c) in address field
        LDY     T1              ; Get new link
        BNE     LP
        RTS

; The "seek" subroutine looks up the symbol in T1-T2 in the symbol
; table. If it is not there at all we bump SIZE by one and enter it.
; If T1 is plus this is a "definition". If T2 is minus this is a
; "use" (the subroutine doesn't care).
; We return with (A)= 0 if it was entered, positive > 0 if the sym-
; bol has been previously defined and minus if undefined:

SEEK:   LDY     SIZE
SL1:    LDA     T1
        CMP     STAB,Y
        BEQ     HALF            ; If first letter matches, check other
S2:     DEY
        BPL     SL1             ; Go back to look some more
        INC     SIZE
        LDY     SIZE
        CPY     #$10            ; Symbol table bigger than 15?
        BPL     TOOBIG
        LDA     T1              ; Enter symbol
        STA     STAB,Y
        LDA     T2
        STA     STAB,Y
        TXA
        STA     STAB3,Y
        LDA     #$00            ; Set address field to 0
        STA     LOBYT,X

HALF:   LDA     T2
        EOR     STAB2,Y         ; Compare if equal gives 0
        AND     #$7F            ; Throw away sign bit
        BNE     S2
        LDA     STAB2,Y         ; Has right sign + or -
        RTS

TOOBIG: LDY     #'4'            ; Give "E4"
        JMP     MES

; The op-code table is stored in memory as a 16 word vector:

OPCODTAB:
        .BYTE   $97             ; -IN  input
        .BYTE   $94             ; -SA  store accumulator
        .BYTE   $95             ; -SB  store index register
        .BYTE   $8F             ; -NA  jump on negative acum.
        .BYTE   $9B             ; -ZA  jump on zero accum.
        .BYTE   $9C             ; -ZB  jump on zero index
        .BYTE   $9A             ; -JP  jump
        .BYTE   $9D             ; -JS  jump subroutine
        .BYTE   $A3             ; -OT  output
        .BYTE   $8D             ; -LA  load accumulator
        .BYTE   $8E             ; -LB  load index
        .BYTE   $85             ; -AD  add to accumulator
        .BYTE   $A8             ; -SU  subtract from accumulator
        .BYTE   $92             ; -ND  logical and with accumulator
        .BYTE   $A1             ; -OR  inclusive or
        .BYTE   $AA             ; -XR  exclusive or

; The symbol table has three bytes per cell. There are 16 cells but
; it turns out that the cell zero can't be used. The two letters of the
; symbol go in STAB and STAB2 and the value goes into STAB3.

STAB:    .RES   16
STAB2:   .RES   16
STAB3:   .RES   16

; Three constants are used:

SIZE:   .BYTE   $00             ; Number of symbols
T1:     .BYTE   $00             ; Temporary storage
T2:     .BYTE   $00             ; Temporary storage

HYBYT   = $0200
LOBYT   = $0300
