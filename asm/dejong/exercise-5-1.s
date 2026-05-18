OPA     =       $01
OPB     =       $02
RESULT  =       $03
GETBYTS =       $114F
TEST    =       $115D

        .ORG    $1288

AGAIN:  JSR     GETBYTS         ; Input two 2-digit hex numbers.
;****************

        CLD                     ; Clear the decimal mode.
        CLC                     ; Clear the carry flag.
        LDA     OPA             ; Fetch a number.
        ADC     OPB             ; Add it to another number.
        STA     RESULT          ; Store the answer.

;****************
        JSR     TEST            ; Input your own answer.
        JMP     AGAIN           ; Try another problem.
