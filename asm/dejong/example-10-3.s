FIFO    =       $000D
PNTR    =       $0010
HOME    =       $FC58           ; Monitor routine to clear the screen.

SEND    =       $2015
CNTSPD  =       $20CE
T1LL    =       $C704
T1LH    =       $C705
ACR     =       $C70B
IER     =       $C70E

        .ORG    $2200

        SEI
        STA     $C059           ; Annunciator to logic 1.
        CLD
        LDA     #$FF            ; Set up timer to give
        STA     T1LL            ; interrupts every 65537
        LDA     #$FF            ; clock cycles.
        STA     T1LH
        LDA     ACR             ; Put T1 in free-running mode.
        ORA     #$40
        STA     ACR
        LDA     IER             ; Enable interrupts from T1.
        ORA     #$C0
        STA     IER
        JSR     HOME            ; Clear the screen.
        JSR     CNTSPD
        LDA     #$21            ; Set up interrupt vector.
        STA     $03FF
        LDA     #$22
        STA     $03FE
        LDA     #$00
        STA     FIFO            ; Set up indirect indexed pointers.
        STA     PNTR
        LDA     #$09
        STA     FIFO+1
        STA     PNTR+1
        LDY     #$00
        CLI                     ; Allow interrupts.
BR6:    LDA     FIFO            ; Is FIFO different
        CMP     PNTR            ; from pointer?
        BEQ     BR6             ; No, wait here for a new character.
        JSR     SEND            ; Yes, then send a character.
        CLV                     ; Force a branch back.
        BVC     BR6
