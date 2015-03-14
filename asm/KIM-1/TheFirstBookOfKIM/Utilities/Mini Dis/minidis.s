        POINTL  = $FA

        PADD    = $1741
        SCAND   = $1F19
        INCPT   = $1F63
        GETKEY  = $1F6A
        TABLE   = $1FE7

        .ORG    $0300

START:  CLD                     ; NOTE ERROR IN PRINTED LISTING
        LDX     #$FF            ; INITIALIZE STACK
        TXS                     ; POINTER
INIT:   LDY     #$00            ; (E6-EE)=0
        LDX     #$09
INIT1:  STY     $00E5,X
        DEX
        BNE     INIT1
        INX                     ; X=1
LENGTH: LDA     (POINTL),Y      ; GET OPCODE, FIND LENGTH
        CMP     #$20            ; ANALYZE BIT PATTERNS
        BEQ     N3BYTE          ; %00100000 ; 3 BYTES
        AND     #$9F            ; "X" MEANS DON'T CARE
        BEQ     N1BYTE          ; %OXXOOOOO ; 1 BYTE (20)
        CMP     #$92
        BEQ     FLASH           ; %1XX10010 ; ILLEGAL (B2,D2)
        TAY                     ; STORE TEMPORARILY
        AND     #$1D
        CMP     #$19
        BEQ     N3BYTE          ; %XXX110X1 ; 3 BYTES (59,B9)
        AND     #$0D
        CMP     #$08
        BEQ     N1BYTE          ; %XXXXX0X0 ; 1 BYTE (D8,4A)
        AND     #$0C
        CMP     #$0C
        BEQ     N3BYTE          ; %XXXX11XX  ; 3 BYTES (4C,EE)
        TYA                     ; RESTORE
        AND     #$8F
        CMP     #$02            ; %0XXX0010 ; ILLEGAL (22,52)
        BNE     N2BYTE          ; ALL LEFTOVERS ; 2 BYTES
FLASH:  INC     $00EC           ; FLIP BIT 0
        LDA     #$FF            ; LOOP FOR 1/4 SEC.
        STA     $1707
FLASH1: LDA     $00EC           ; SLINK ON OR OFF
        AND     #$01
        BEQ     FLASH2          ; SIT 0-0 ; BLINK OFF
        JSR     SCAND           ; BIT ON  ; BLINK ON
FLASH2: BIT     $1707
        BMI     FLASH
        BPL     FLASH1
N1BYTE: INX
N2BYTE: INX
N3BYTE: TXA                     ; CENTER CODE
        EOR     #$07
        STA     $00ED
CONVRT: LDY     $EE             ; LOOP FOR EACH BYTE
        LDA     (POINTL),Y      ; CONVERT AND STORE
        PHA                     ; IN E6 - EB
        LSR     A               ; LSR's
        LSR     A
        LSR     A
        LSR     A
        TAY
        LDA     TABLE,Y
        STA     $00E5,X
        INX
        PLA
        AND     #$0F
        TAY
        LDA     TABLE,Y
        STA     $00E5,X
        INX
        INC     $00EE
        CPX     $00ED
        BCC     CONVRT
KDOWN:  JSR     DISP            ; DISPLAY UNTIL ALL KEYS
        BNE     KDOWN           ; ARE UP
KUP:    JSR     DISP            ; DISPLAY AND GETKEY
        JSR     GETKEY
BQ:     CMP     #$0B            ; IS "B" PRESSED?
        BNE     PLUSQ           ; NO, BRANCH
BCKSTP: TSX
        CPX     #$FF            ; IS STACK EMPTY?
        BEQ     WINDOW          ; YES, ACT LIKE "PC"
        PLA                     ; PULL FB AND FA
        STA     $00FB           ; DISPLAY WORD
        PLA
        STA     $00FA
NEWORD: JMP     INIT
PLUSQ:  CMP     #$12            ; IS "+" PRESSED?
        BNE     PCQ             ; NO, BRANCH
STEP:   LDA     $00FA           ; PUSH FA AND FB
        PHA
        LDA     $00FB
        PHA
STEP1:  JSR     INCPT           ; FIND NEW LOCATION
        DEC     $00EE           ; DISPLAY WORD
        BEQ     NEWORD
        BNE     STEP1
PCQ:    CMP     #$14            ; IS "PC" PRESSED?
        BNE     KUP             ; NO, GET KEY
WINDOW: JSR     SCAND           ; DISPLAY LOCATION
        BEQ     KUP             ; UNTIL KEY RELEASED
        BNE     WINDOW          ; THEN GET KEY
DISP:   LDA     #$7F            ; SEGMENTS TO OUTPUT
        STA     PADD
        LDX     #$08            ; INITIALIZE
        LDY     #$00
DISP1:  STY     $00FC
        LDA     $00E6,Y         ; GET CHARACTER
        JSR     $1F4E           ; DISPLAY CHARACTER
        INY                     ; NEXT CHARACTER
        CPY     #$06
        BCC     DISP1
        JMP     $1F3D           ; DONE, KEY DOWN?
