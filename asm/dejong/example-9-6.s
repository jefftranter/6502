PAD     =       $C701
DDRA    =       $C703

        .ORG    $17B7

        LDA     #$FF            ; Initialize PAD to be an
        STA     DDRA            ; output port.
TOGGLE: INC     PAD             ; Increment the number in PAD.
        CLV                     ; Force a branch.
        BVC     TOGGLE
