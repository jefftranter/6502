        RND     = $D0
        PADD    = $1741
        INIT1   = $1E8E

        .ORG    $0200

        LDX     #$0C            ; ... INITIALIZATION ...
INIT:   LDA     $02DF,X         ; .. 12 VALUES ARE LOADED
        STA     $00E2,X         ; FROM 00E2 ON UP ..
        DEX
        BPL     INIT
GRUP:   LDX     #$04            ; (SPACE LENGTH)
        JSR     SPACE           ; SPACE FOR ANOTHER GROUP
        LDA     #$06            ; GROUP SIZE, 5 CHAR.
        STA     $00E0
CHAR:   DEC     $00E0           ; NEXT CHAR. IN GROUP
        BEQ     GRUP            ; FINISHED, GET NEW GROUP
        LDX     #$03            ; (SPACE LENGTH)
        JSR     SPACE           ; SPACE BETWEEN CHAR.
NUMB:   JSR     RAND            ; GET A RANDOM #
        AND     #$3F            ; MAKE SURE POSITIVE
        CMP     #$28            ; LESS THAN 41 (DECIMAL)?
        BPL     NUMB            ; NO, GET ANOTHER
        TAX                     ; USE AS INDEX
        LDA     $0313,X         ; GET DISPLAY CONVERSION
        LDY     $00E2           ; CHAR. INDEX IN Y
        STA     $033B,Y         ; STORE CONVERSION
        INC     $00E2           ; INDEX UP ONE
        LDA     $00E2           ; LAST CHARACTER?
        CMP     #$1A
        BEQ     DEBO            ; YES, GO READOUT
        LDA     $02EB,X         ; GET CODE CHARACTER
        STA     $00DF           ; TEMPORARY STORE
BITS:   ASL     $00DF           ; SHIFT
        BEQ     CHAR            ; EMPTY, GET NEXT CHAR.
        BCS     DASH            ; IF CARRY SET, SEND DASH
        LDX     #$01            ; ..ELSE SEND DOT
        JSR     MARK
SPAC:   LDX     #$01            ; THEN SPACE
        JSR     SPACE
        CLC
        BCC     BITS            ; UNCOND. JUMP
DASH:   LDX     #$03            ; (DASH LENGTH)
        JSR     MARK            ; SEND A DASH
        CLC
        BCC     SPAC            ; UNCOND. JUMP
DEBO:   JSR     INIT1           ; DEBOUNCE KEY..
        JSR     DISP
        BNE     DEBO            ; WAIT FOR KEY RELEASE
WAIT:   JSR     DISP
        BEQ     WAIT            ; WAIT FOR KEY DOWN
        CLC
        LDA     $00E4           ; UPDATE POINTER TO
        ADC     #$05            ; POINT AT NEXT GROUP..
        STA     $00E4
        LDY     #$04            ; ..LOAD WINDOWS 00E8-
WIND:   LDA     ($00E4),Y       ; 00EC WITH CONVERSIONS
        STA     $00E8,Y         ; FOR DISPLAY..
        DEY
        BPL     WIND
        DEC     $00E3           ; LAST GROUP?
        BNE     DEBO            ; NO, GET ANOThER
        LDA     #$36            ; REINITILIZE POINTER
        STA     $00E4           ; TO RUN THRU GROUPS AGAIN
        LDA     #$05
        STA     $00E3
        BNE     DEBO            ; UNCOND. JUMP

;      ***** MARK SUBROUTINE ****

MARK:   STX     $00DD           ; TEMP. STORE
TIMM:   LDA     $00E6           ; SPEED BYTE
        STA     $1707           ; START TIMER
        LDA     #$01            ; PA0 TO OUTPUT
        STA     $1701
TOGG:   INC     $1700           ; TOGGLE PA0
        LDX     $00E7           ; DETERMINE FREQ.
FREQ:   DEX
        BNE     FREQ
        BIT     $1707           ; TIME UP?
        BPL     TOGG            ; NO
        DEC     $00DD           ; DETERMINE MARK LENGTH
        BNE     TIMM
        RTS

;        ***** SPACE SUBROUTINE *****

SPACE:  STX     $00DD           ; TEMP. STORE
TIMS:   LDA     $00E6           ; SPEED BYTE
        STA     $1707           ; START TIMER
HOLD:   BIT     $1707           ; DONE?
        BPL     HOLD            ; NO
        DEC     $00DD           ; FULL TIME UP?
        BNE     TIMS            ; NO
        RTS

;          ***** DISPLAY SUBROUTINE *******

DISP:   LDA     #$7F            ; CHANGE SEGMENTS..
        STA     PADD            ; TO OUTPUTS
        LDY     #$0             ; INIT. RECALL INDEX
        LDX     #$9             ; INIT. DIGIT NUMBER
SIX:    LDA     $00E8,Y         ; GET CHARACTER
        STY     $00FC           ; SAVE Y
        JSR     $1F4E           ; DISPLAY CHARACTER
        INY                     ; SET UP FOR NEXT OAR.
        CPY     #$06            ; 6 CHAR. DISPLAYED?
        BCC     SIX             ; NO
        JSR     $1F3D           ; KEY DOWN?
        RTS                     ; EXIT

;          ***** RANDOM NUMBER SUBROUTINE ******

RAND:   SEC                     ; FROM J. BUTTERFIELD
        CLD                     ; KIM USER NOTES
        LDA     RND+1           ; VOL. 1, *1
        ADC     RND+4
        ADC     RND+5
        STA     RND
        LDX     #$04
ROLL:   LDA     RND,X
        STA     RND+1,X
        DEX
        BPL     ROLL
        RTS

;           ***** INITIALIZATION VALUES *******

        .ORG    $02DF
        .BYTE   $00,$05,$36,$03,$33,$66,$C0,$C0,$C0,$C0,$C0,$00

;           ***** TABLE OF CODE CHARACTERS *******

        .ORG    $02EB
        .BYTE   $60,$88,$A8,$90,$40
        .BYTE   $28,$D0,$08,$20,$78,$B0,$48,$E0,$A0,$F0,$68,$D8,$50,$10,$C0,$30
        .BYTE   $18,$70,$98,$B8,$C8,$FC,$7C,$3C,$1C,$0C,$04,$84,$C4,$E4,$F4,$56
        .BYTE   $CE,$32,$8C

;           ***** TABLE OF DISPLAY CONVERSIONS ******

        .ORG   $0313
        .BYTE  $F7,$FC,$B9,$DE,$F9,$F1,$BD,$F6,$84,$9E,$F0,$B8,$B7
        .BYTE  $D4,$DC,$F3,$E7,$D0,$ED,$F8,$BE,$EA,$9C,$94,$EE,$C9,$BF,$86,$DB
        .BYTE  $CF,$E6,$ED,$FD,$87,$FF,$EF,$90,$84,$D3,$C8

; *** STORAGE OF CHARACTERS SENT: 033B - 03FF
