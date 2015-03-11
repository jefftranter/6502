        RND     = $D0
        MZPT    = $D2
        POSIT   = $D4
        PLUG    = $D5
        STALL   = $D6
        SOK     = $D7
        WORK    = $D8

        SAD     = $1740
        SADD    = $1741
        SBD     = $1742
        KEYIN   = $1F40
        GETKEY  = $1F6A

        .ORG    $0200

START:  INC     RND             ; random seed
        JSR     KEYIN
        BNE     START
        LDX     #7              ; patch the maze
LP1:    ROL     RND             ; in 8 places
        BCC     NXUP
        LDY     PLACE,X
        LDA     POINT1,X
        EOR     MAZE,Y
        STA     MAZE,Y
        INY
        INY
        LDA     POINT2,X
        EOR     MAZE,Y
        STA     MAZE,Y
NXUP:   DEX
        BPL     LP1
        LDX     #2
        CLD
SLINK:  BMI     START
SETUP:  LDA     INIT,X
        STA     MZPT,X
        DEX                     ; 3 values from INIT
        BPL     SETUP
; pick out specific part of maze
MAP:    LDY     #11
GETMOR: LDA     (MZPT),Y        ; 6 rows x 2
        STA     WORK,Y
        DEY
        BPL     GETMOR
; shift for vertical position
        LDX     #10             ; for each of 6 rows
NXDIG:  LDY     POSIT           ; shift Y positions
        LDA     #$FF            ; filling with 'walls'
REROL:  SEC                     ; on both sides
        ROL     WORK+1,X
        ROL     WORK,X          ; roll 'em
        ROL     A
        DEY
        BNE     REROL
; calculate segments
        AND     #7
        TAY
        LDA     TAB1,Y          ; 3 bits to segment
        STA     WORK,x          ; ..stored
        DEX
LIGHT1: DEX
        BPL     NXDIG
; test   flasher
LIGHT:  DEC     PLUG            ; time out?
        BPL     MUG             ; ..no
        LDA     #5              ; ..yes, reset
        STA     PLUG
        LDA     WORK+6          ; and..
        EOR     #$40            ; ..flip..
        STA     WORK+6          ; ..flasher
; light display
MUG:    LDA     #$7F            ; open the gate
        STA     SADD
        LDY     #$09
        LDX     #10
SHOW:   LDA     WORK,X          ; tiptoe thru..
        STA     SAD             ; ..the segments
        STY     SBD
ST1:    DEC     STALL           ; ..pausing
        BNE     ST1
        INY
        INY
        DEX
        DEX
        BPL     SHOW
; test new key depression
        JSR    KEYIN            ; set dir reg
        JSR    GETKEY
        CMP    SOK              ; same as last?
        BEQ    LIGHT
        STA    SOK
; test   which key
        LDX    #4               ; 5 items in table
SCAN:   CMP    TAB2,X
        BEQ    FOUND
        DEX
        BPL     SCAN
        BMI     LIGHT1          ; error in published listing?
FOUND:  DEX
        BMI     SLINK           ; go key?
        LDY     TAB3,X
        LDA     WORK,Y
        AND     TAB4,X
        BNE     LIGHT
; move
        DEX
        BPL     NOTUP
        DEC     POSIT           ; upward move
MLINK:  BNE     MAP             ; 1.o.n.g  branch
NOTUP:  BNE     SIDEWY
        INC     POSIT           ; downward move
        BNE     MLINK
SIDEWY: DEX
        BNE     LEFT
RIGHT:  DEC     MZPT            ; right move
        DEC     MZPT
        BNE     MLINK
LEFT:   INC     MZPT            ; left move
        INC     MZPT
        BNE     MLINK
        BEQ     RIGHT

; tables follow in Hex format

TAB1:   .BYTE   $00, $08, $40, $48, $01, $09, $41, $49
TAB2:   .BYTE   $13, $09, $01, $06, $04
TAB3:   .BYTE   $06, $06, $04, $08
TAB4:   .BYTE   $01, $08, $40, $40
INIT:   .BYTE   $DA, $02, $08
MAZE:   .BYTE   $FF, $FF, $04, $00, $F5, $7F, $15, $00, $41, $FE, $5F, $04, $51, $7D, $5D, $04
        .BYTE   $51, $B6, $54, $14, $F7, $D5, $04, $54, $7F, $5E, $01, $00, $FD, $FF, $00, $00
        .BYTE   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
PLACE:  .BYTE   $05, $0B, $10, $10, $14, $18, $17, $10
POINT1: .BYTE   $01, $04, $80, $10, $80, $02, $40, $40
POINT2: .BYTE   $02, $02, $40, $01, $10, $04, $80, $10

; end of program
