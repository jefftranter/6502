; Page zero addresses

DCDLO   =       $00             ; Application Address Low
DCDHI   =       $03             ; Application Address High

PARAM0  =       $B0             ; Parameter 0 is usually the COMMAND CODE
PARAM1  =       $B1             ; Parameter 1 is usually DATA
PARAM2  =       $B2             ; Parameter 2 is usually DATA
PARAM3  =       $B3             ; Parameter 3 is usually DATA
ADRLO   =       $B4             ; Low Address pointer for Indirect Address
ADRHI   =       $B5             ; High Address pointer for Indirect Address
PNTR    =       $B6             ; Temporary Pointer Storage
STEPNO  =       $B7             ; Number of NEXT PLEASE Step
STEPLO  =       $B8             ; Low Address of Current PLEASE Step
STEPHI  =       $B9             ; High Address of Current PLEASE Step
TRANLO  =       $BA             ; Temporary Transfer Pointer to PLEASE Function
TRANHI  =       $BB             ; Temporary Transfer Pointer to PLEASE Function
FUNTBL  =       $BC             ; Low Address of PLEASE Function Table
FUNTBH  =       $BD             ; High Address of PLEASE Function Table
PTEMP0  =       $BE             ; PLEASE Temporary Storage
PTEMP1  =       $BF             ; PLEASE Temporary Storage
TEMP1   =       PTEMP0
TEMP2   =       PTEMP1

THOUS   =       $C0             ; Thousands and Tens of Thousands of Seconds
TENS    =       $C1             ; Tens and Hundreds of Seconds
TENTHS  =       $C2             ; Tenths and Seconds
MILLI   =       $C3             ; Thousandths and hundredths of Seconds
HOUR    =       $C4             ; Hour portion of 24 Hour Clock
MINUTE  =       $C5             ; Minute portion of 24 Hour Clock
SECOND  =       $C6             ; Second portion of 24 Hour Clock
ONESEC  =       $C7             ; Counter for One Second

DSP0    =       $C8             ; Display position 0 (Leftmost Digit)
DSP1    =       $C9             ; Display position 1
DSP2    =       $CA             ; Display position 2
DSP3    =       $CB             ; Display position 3
DSP4    =       $CC             ; Display position 4
DSP5    =       $CD             ; Display position 5 (Rightmost Digit)
DSPLO   =       $CE             ; Low Address of Display Buffer (Usually = DSP0 = C8)
DSPHI   =       $CF             ; High Address of Display Buffer (Usually = DSP0 = 00)

DCONLO  =       $D0             ; Display Conversion Table Low Address
DCONHI  =       $D1             ; Display Conversion Table High Address
DTABLO  =       DCONLO
DTABHI  =       DCONHI
HEXDEC  =       HEXLO
HEXLO   =       $D2             ; Hexadecimal (and Decimal) Conversion Table Low Address = E7
HEXHI   =       $D3             ; Hexadecimal (and Decimal) Conversion Table High Address = 17
ALPHLO  =       $D4             ; Alphabetic Conversion Table Low Address (usually = F0)
ALPHHI  =       $D5             ; Alphabetic Conversion Table High Address (usually = 03)
XTABLE  =       $D6             ; Used by Conversion Routine to Point to HEX or ALPHA Table
TEMP    =       $D7             ; General Purpose Temporary Save Location
LIMIT   =       $D8             ; Uses by Conversion Routine.  General Purposes Register
DSPPOS  =       $D9             ; Executive Pointer to Current Display Position
CURPNT  =       $DA             ; Used by Input Routines as Current Data Pointer.
CHAR    =       $DB             ; Save location for Input Character
CTABLO  =       $DC             ; Command Table Low Address (usually = A0)
CTABHI  =       $DD             ; Command Table High Address (usually = 00)
KEYTST  =       $DE             ; Used by Executive as part of Keyboard Input
KEYVAL  =       $DF             ; Contains Last Character if Input String

BUF0    =       $E0             ; General Purpose Buffer
BUF1    =       $E1
BUF2    =       $E2
BUF3    =       $E3
BUF4    =       $E4
BUF5    =       $E5

ALT0    =       $E6             ; Alternate General Purposes Buffer
ALT1    =       $E7
ALT2    =       $E8
ALT3    =       $E9
ALT4    =       $EA
ALT5    =       $EB

APL0    =       $EC             ; Application General Registers
APL1    =       $ED
APL2    =       $EF

; Addresses of PLEASE routines and constants

EXAPLO  =       $17CC
EXAPHI  =       $17CD
MATCH   =       $0D

; KIM-1 ROM routines and constants

GETKEY  =   $1F6A
INITS   =   $1E88
KEYMAX  =   $14
PC      =   $14

; Function Table
; JJT: Table was not shown in original listng

        .ORG    $0100
                        ; Code Word
        .WORD   ALPIN   ; 00   ALPIN
        .WORD   HEXIN   ; 01   HEXIN
        .WORD   DECIN   ; 02   DECIN
        .WORD   ALPOUT  ; 03   ALPOUT
        .WORD   HEXOUT  ; 04   HEXOUT
        .WORD   _TIMER  ; 05   TIMER
        .WORD   PACK    ; 06   PACK
        .WORD   UNPACK  ; 07   UNPACK
        .WORD   BRANCH  ; 08   BRANCH
        .WORD   BRCHAR  ; 09   BRCHAR
        .WORD   BRTABL  ; 0A   BRTABL
        .WORD   FILL    ; 0B   FILL
        .WORD   COMPAR  ; 0C   COMPARE
        .WORD   COMPAR  ; 0D   MATCH (same code as COMPARE)
        .WORD   $0000   ; 0E   Not used
        .WORD   $0000   ; 0F   Not used

; System Timer

        .RES $0200-*, $00

TIMER:  SED                     ; Calculations done in Decimal Mode
        LDX     #3              ; Setup Counter for Timer

TIMER1: CLC                     ; Clear Carry Bit
        LDA     THOUS,X         ; Add 1 to Current Timer Value
        ADC     #1
        STA     THOUS,X
        BCC     TDONE           ; All done if no Carry

        CPX     #3              ; Test Carry from Millisecond
        BNE     TIMER2          ; Skip Clock Update unless Millisecond
        DEC     ONESEC          ; Decrement a Ten * 1/10 second timer
        BNE     TIMER2          ; Skip Clock Update unless 10 counts

CLOCK:  CLC
        LDA     MILLI,X         ; Get Byte Using Index
        ADC     #1              ; Increment Byte
        CMP     #$60            ; Test Second or Minute Limit
        BNE     HTEST           ; Not Limit.  Test Hour Limit
        LDA     #0              ; Reset Second or Minute to Zero
        STA     MILLI,X         ; Save Modified Byte
        DEX                     ; Decrement Index
        BPL     CLOCK           ; Unconditional Branch

HTEST:  CPX     #1              ; Is this the Hour Byte?
        BNE     CDONE           ; If not, then Clock is Done
        CMP     #$24            ; Test Hour Limit
        BNE     CDONE           ; If not Limit, then Clock is Done
        LDA     #0              ; If Limit, Reset to Zero

CDONE:  STA     MILLI,X         ; Store Modified Value
        LDX     #3              ; Restore Index Value
        lDA     #10             ; Reset Ten * 1/10 Counter
        STA     ONESEC

TIMER2: DEX                     ; Decrement Index
        BPL     TIMER1          ; If Index Positive, Continue Updates

TDONE:  CLD                     ; All Done.  Clear Decimal Mode
        RTS                     ; Subroutine Return

; PLEASE functions

PACK:   LDX     PARAM1
        LDA     0,X
        ASL
        ASL
        ASL
        ASL
        ORA     1,X
        BCC     PACK2
        LDA     1,X
        BPL     PACK2
        LDA     #$00
PACK2:  LDX     PARAM2
        STA     0,X
        INC     PARAM1
        INC     PARAM1
        INC     PARAM2
        DEC     PARAM3
        BNE     PACK
        BEQ     TONEXT

UNPACK: LDX     PARAM1
        LDA     0,X
        LSR
        LSR
        LSR
        LSR
        LDX     PARAM2
        STA     0,X
        INC     PARAM2
        DEC     PARAM3
        BEQ     TONEXT-2       ; JJT: Original code had TONEXT but listing used TONEXT-2
        LDX     PARAM1
        LDA     #$0F
        AND     0,X
        LDX     PARAM2
        STA     0,X
        INC     PARAM2
        INC     PARAM1
        DEC     PARAM3
        BNE     UNPACK
        BEQ     TONEXT

ALPOUT: LDX     #ALPHLO
        BNE     GETADR
HEXOUT: LDX     #HEXDEC
GETADR: JSR     DIRADR
        JSR     CONDSP
TONEXT: JMP     NXTSTP

BRCHAR: LDX     CHAR
        LDA     #$20
        STA     CHAR
        CPX     #$20
        BEQ     TONEXT
        LDA     PARAM2
        CPX     PARAM1
        BEQ     OKAY
        LDA     PARAM3
OKAY:   BPL     SETSTP

BRANCH: LDA     PARAM1
        BPL     SETSTP

_TIMER: LDA     #10            ; JJT: Was TIMER in original listing but conficts with other label
        STA     TEMP1
RESET:  LDA     #10
        STA     TEMP2
WAIT:   JSR     EXSET
        DEC     TEMP2
        BNE     WAIT
        DEC     TEMP1
        BNE     RESET
        DEC     PARAM1
        BNE     _TIMER
        LDA     PARAM2
        BPL     SETSTP

COMPAR: JSR     DIRADR
        LDX     PARAM2
        LDY     #$00

CTEST:  LDA     0,X
        SEC
        CMP     (ADRLO),Y      ; JJT: Original code had SBC but used code for CMP
        BEQ     SAME
        BCS     LESS

GREAT:  LDA     #MATCH
        CMP     PARAM0
        BEQ     LESS
        INC     STEPNO
EQUAL:  INC     STEPNO

LESS:   BPL     NXTSTP

SAME:   INX
        INY
        CPY     PARAM3
        BNE     CTEST
        BEQ     EQUAL

FILL:   JSR     DIRADR
        LDA     PARAM2
        LDY     PARAM3
        DEY

FILLIT: STA     (ADRLO),Y
        DEY
        BPL     FILLIT
        BMI     NXTSTP

        BRK
        BRK
        BRK
        BRK
        BRK
        BRK
        BRK
        BRK

; Interpreter

APPL:
DECODE: LDA     #$00
SETSTP: STA     STEPNO
NXTSTP: JSR     EXSET
        LDA     STEPNO
        ASL
        ASL
        STA     STEPLO

        LDY     #3
PARMOV: LDA     (STEPLO),Y
        STA     PARAM0,Y
        DEY
        BPL     PARMOV
        INC     STEPNO

        ASL
        STA     BREAK+3
BREAK:  NOP
        NOP
        JMP     ($0100)

        BRK
        BRK
        BRK
        BRK
        BRK
        BRK
        BRK

; PLEASE functions continued

ALPIN:
ALPHA:  LDA     #$10
        LDX     #ALPHLO
        BNE     SETTAB

HEXIN:  LDA     #$10
        BNE     SETHEX

DECIN:  LDA     #$0A
SETHEX: LDX     #HEXDEC
SETTAB: STX     XTABLE
        STA     LIMIT
        JSR     DIRADR

RSTART: JSR     CLRDSP
        LDA     PARAM2
        STA     CURPNT
        BPL     MORE

SAVE:   JSR     STORE
MORE:   LDX     XTABLE
        JSR     CONDSP
        JSR     EXSET
        LDA     CHAR
        LDX     #$20
        STX     CHAR
        CMP     #PC
        BEQ     RSTART
        BPL     MORE
        CMP     LIMIT
        BMI     SAVE

FINISH: STA     KEYVAL
        BPL     NXTSTP

BRTABL: JSR     INDADR
        LDX     PARAM2
        LDY     #00

_MORE:  LDA     0,X             ; JJT: Was MORE in original listing but conficts with other label
        CMP     (ADRLO),Y
        BEQ     FOUND
        INY
        INY
        LDA     (ADRLO),Y
        BNE     _MORE
        LDA     PARAM3
BRDONE: BPL     SETSTP

FOUND:  INY
        LDA     (ADRLO),Y
        BPL     BRDONE

        BRK

DIRADR: LDA     PARAM1
        STA     ADRLO
        LDA     #$00
        STA     ADRHI
        RTS

INDADR: LDX     PARAM1
XNDADR: LDA     0,X
        STA     ADRLO
        LDA     1,X
        STA     ADRHI
        RTS

CLRDSP: LDA     #$FF
FILDSP: LDX     #$06
        STX     TEMP
        LDY     PARAM2
        STY     CURPNT

FILNXT: JSR     STORE
        DEC     TEMP
        BNE     FILNXT
        RTS

CONDSP: LDA     0,X
        STA     DTABLO
        LDA     1,X
        STA     DTABHI
        LDY     PARAM2

CON:    STY     TEMP
        LDA     (ADRLO),Y
        BPL     CON2
        LDA     #$00
        BEQ     CON3
CON2:   TAY
        LDA     (DTABLO),Y
CON3:   LDY     TEMP
        STA     (DSPLO),Y
        CPY     PARAM3
        BEQ     RETURN
        BMI     INCR
        DEY
        BPL     CON
INCR:   INY
        BPL     CON

STORE:  TAX
        LDY     PARAM3
        CPY     PARAM2
        BMI     SHIFT
        CPY     CURPNT
        BMI     RETURN
        LDY     CURPNT
        INC     CURPNT
        BPL     PUT

SHIFT:  INY
        LDA     (ADRLO),Y
        DEY
        STA     (ADRLO),Y
        INY
        CPY     PARAM2
        BMI     SHIFT
        TXA
PUT:    STA     (ADRLO),Y
RETURN: RTS

; Alpha Display Table

                        ; Key Character
        .BYTE   $77     ; 0    A
        .BYTE   $7C     ; 1    b
        .BYTE   $58     ; 2    c
        .BYTE   $5E     ; 3    d
        .BYTE   $79     ; 4    E
        .BYTE   $71     ; 5    F
        .BYTE   $76     ; 6    H
        .BYTE   $30     ; 7    I
        .BYTE   $38     ; 8    L
        .BYTE   $54     ; 9    n
        .BYTE   $5C     ; A    o
        .BYTE   $73     ; B    P
        .BYTE   $50     ; C    r
        .BYTE   $6D     ; D    S
        .BYTE   $78     ; E    t
        .BYTE   $6E     ; F    Y

; PLEASE Monitor

        .RES $1780-*, $00

EXINIT: LDA     #DCDLO          ; DCDLO = Application Low
        STA     EXAPLO          ; Address to Exec Transfer
        LDA     #DCDHI          ; DCDHI = Application High
        STA     EXAPHI          ; Address to Exec Transfer
        LDA     #$20            ; 20 is uses to indicate
        STA     CHAR            ; No character input

EXLOOP: LDA     #$7B            ; Set millisecond timer
        STA     $1745           ; (Actually 984 microseconds)

KEYIN:  JSR    INITS            ; Setup for Keyboard Input
        JSR    GETKEY           ; Get Keyboard Input if any
        CMP    #KEYMAX          ; Was there a Key Pressed ?
        BMI    KEYIN2           ; Yes, a Key was Pressed
        STA    KEYTST           ; No, so reset debounce flag
        BNE    DSPLAY           ; Unconditional branch
KEYIN2: LDX    KEYTST           ; Test debounce flag.
        BEQ    DSPLAY           ; Branch of not a new char.
        STA    CHAR             ; Save new character
        LDA    #$00             ; Clear debounce flag
        STA    KEYTST

DSPLAY: LDY    DSPPOS           ; Current Display Pointer
        TYA                     ; Calculate Select Line
        ASL    A
        ADC    #$08
        STA    $1742            ; Select Display Position
        LDA    #$7F             ; Select All Output Lines
        STA    $1741
        LDA    (DSPLO),Y        ; Get Display Character from
        STA    $1740            ; Display Buffer and Output
        DEY                     ; Decrement Position Pointer
        BPL    DSPLY2           ; Okay if Positive
        LDY    #5               ; Else, Reset to Maximum
DSPLY2: STY    DSPPOS           ; Save Pointer for Next Loop

        JSR    TIMER            ; Go to TIMER subroutine
        NOP                     ; (JSR ?????)
        NOP                     ; NOPs can be changed
        NOP
        JSR     APPL            ; This goes off to Application

EXWAIT: BIT     $1745           ; Text current interval
        BPL     EXWAIT          ; Not done if Positive
        BMI     EXLOOP          ; Done if Negative

        NOP
        NOP
        NOP
        NOP

EXSET:  PLA                     ; Pull Address of Next
        STA     EXAPLO          ; Application Instruction
        INC     EXAPLO          ; and Save and Correct
        PLA                     ; Pull Page Address of Next
        STA     EXAPHI          ; Appl. Inst and Save it.
        RTS                     ; Return to EXLOOP at EXWAIT

        .END
