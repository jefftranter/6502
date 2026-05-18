RESULT   =      $03
GETBYTS =       $114F
TEST    =       $115D
MULTIPLY =      $1280

        .ORG    $12B8

AGAIN:  JSR     GETBYTS                 ; Input two 2-digit hex numbers.

;****************

        JSR     MULTIPLY                ; Call the multiplication
        STA     RESULT                  ; routine. Store the answer.

;****************

        JSR     TEST                    ; Input your own answer.
        JMP     AGAIN                   ; Try another problem.

