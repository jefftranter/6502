MINLO   =       $1001
MINHI   =       $1002
SBTLO   =       $1003
SBTHI   =       $1004
DIFFLO  =       $1005
DIFFHI  =       $1006

        .ORG    $1260

        SEC                     ; Clear the borrow flag.
        LDA     MINLO           ; Get the LSB of the minuend.
        SBC     SBTLO           ; Subtract LSB of the subtrahend.
        STA     DIFFLO          ; Store the LSB of the difference.
        LDA     MINHI           ; Get the MSB of the minuend.
        SBC     SBTHI           ; Subtract MSB of the subtrahend.
        STA     DIFFHI          ; Store the MSB of the difference.
        BRK

