GETBYTS =       $114F
TEST    =       $115D
OPA     =       $01
OPB     =       $02
RESULT  =       $03

        .ORG    $120C

AGAIN:  JSR     GETBYTS         ; Input the two operands.
;****************
        LDA     OPA             ; Fetch one number.
        AND     OPB             ; AND it with another number.
        STA     RESULT          ; Store the answer.
;****************
        JSR     TEST            ; Input your own answer.
        JMP     AGAIN           ; Try another problem.

