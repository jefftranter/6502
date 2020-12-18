; Memory test.
; Downloaded from http://www.willegal.net/appleii/6502mem.htm and adapted to the CC65 assembler.

; MACROS
;
; INITIALIZE ADDRESS WITH START
        .macro INI_ADDRS
        LDA START
        STA ADDRS
        LDA START + $01
        STA ADDRS + $01
        .endmacro

; INCREMENT ADDRESS
        .macro INC_ADDRSC
        INC ADDRS
        BNE @SKIP_HI
        INC ADDRS+$01
 @SKIP_HI:
        LDA END
        CMP ADDRS
        BNE @EXIT2
        LDA END+$01
        CMP ADDRS+$01
 @EXIT2:
       .endmacro

; SET TEST PATTERN
; only for tests 4 and 5 (address in address tests), make address High or Low
; equal to pattern
; test 4 is LSB of address
; test 5 is MSB of address
;
        .macro         SET_PATRN
        CPY        #4
        BNE         @TEST5
        LDA        ADDRS
        STA        TEST_PATRN
@TEST5:
        CPY        #5
        BNE         @EXIT1
        LDA        ADDRS+$01
        STA        TEST_PATRN
@EXIT1:
        .endmacro

; start of program
;
; TESTS TYPE
;        0 = all zeros
;        1 = all ones
;        2 = floating 1s
;        3 = floating 0s
;        4 = address in address (LS 8 address bits)
;        5 = address in address (MS 8 address bits)

MEM_TEST:
        CLC
        LDA END
        ADC #1                ; add 1 to END since test goes to END-1
        STA END
        LDA END+1
        ADC #0               ; add possible carry
        STA END+1
        LDA #$00
        STA PASSES                ; start at pass 0
REPEAT:
        LDA #$00
        TAY                        ; TEST # in REG Y
        TAX                        ; X must be zero
        STA TEST_PATRN           ; first pass all zeros
NX_PASS:
        INI_ADDRS
LOOP1:
        SET_PATRN                       ; sets up TEST_PATRN for address in address test
        LDA        TEST_PATRN
        STA        (ADDRS, X)           ; STORE PATTERN
        JSR        DELAY                ; delay after writing to EEPROM
        LDA        (ADDRS, X)           ; READ (save result of read in case of error)
        CMP        TEST_PATRN           ; CHECK
        BNE        LOOP_ERR2            ; branch if error
        INC_ADDRSC
        BNE        LOOP1

CK_PATRN:
        INI_ADDRS         ; INITIALISE ADDRS

LOOP2:
        SET_PATRN                       ; sets up TEST_PATRN for address in address test
        LDA         (ADDRS, X)          ; READ (save result of read in case of error)
        CMP        TEST_PATRN           ; CHECK
LOOP_ERR2:
        BNE         LOOP_ERR            ; branch if error
        INC_ADDRSC
        BNE LOOP2
;
; Pass Complete - see what is next
;
        CPY        #0                ; test 0 - all zeros complete
        BNE        CHK_TEST1
;
; move to test 1
;

        LDA        #$FF
NX_TEST:
        STA        TEST_PATRN
        INY                        ; move to next test
NX_PASS3:
NX_PASS1:
NX_PASS2:
        JMP        NX_PASS

CHK_TEST1:
        CPY        #1                ; all ones complete?
        BNE        CHK_TEST2

; test 1 - all zeros complete

        LDA        #$01
        BNE        NX_TEST        ; always

CHK_TEST2:
        CPY        #2                ; floating 1s in progress or done
        BNE        CHK_TEST3
;
; pass of test 2 complete - 8 passes in all with 1 in each bit position
;
        ASL         TEST_PATRN                ; shift left - zero to LSB- MSB to CARRY
        BCC        NX_PASS1
;
; all test 2 passes complete - prepase for test 3
;
        LDA        #$7F
        BNE        NX_TEST                ;always branch

CHK_TEST3:                ;floating zeros in progress or done
        CPY        #3
        BNE        CHK_TEST4
;
; pass of test 3 complete - 8 passes in all with 0 in each bit position
;
        SEC
        ROR        TEST_PATRN        ; rotate right - Carry to MSB, LSB to Carry
        BCS        NX_PASS2        ; keep going until zero bit reaches carry

NXT_ADDR_TEST:
        INY                        ; move to test 4 or 5 - address in address
        BNE        NX_PASS3        ; aways
;
; ADDRESS IN ADDRESS tests - two test only make one pass each
;
CHK_TEST4:
        CPY        #4                ; address in address (low done)?
        BEQ        NXT_ADDR_TEST        ; if test 4 done, start test 5

; test 5 complete - we have finished a complete pass
TESTDONE:                        ; print done and stop
        JSR        Imprint
        .asciiz "Pass "
        INC        PASSES
        LDA        PASSES
        JSR        PrintByte
        JSR        PrintCR
.if .defined(APPLE1)
; Stop if key pressed
        BIT        $D011 ; Keyboard CR
        BMI        KeyPressed
        JMP        REPEAT
KeyPressed:
        LDA        $D010 ; Keyboard data
        JMP        FINISHED
.elseif .defined(APPLE2)
; Stop if key pressed
        BIT        $C000 ; Keyboard register
        BMI        KeyPressed
        JMP        REPEAT
KeyPressed:
        STA        $C010 ; Clear keyboard strobe
        JMP        FINISHED
.elseif .defined(OSI)
        LDA        #$00
        STA        $DF00  ; Select all keyboard rows
        LDA        $DF00  ; Read columns
        ORA        #$01   ; Set bit for possible shift lock key
        CMP        #$FF   ; All bits set means no key pressed
        BNE        KeyPressed
        JMP        REPEAT
KeyPressed:
        JMP        FINISHED
.elseif .defined(KIM1)

; Can't find any way to detect keypress on KIM-1 without blocking, so
; just prompt user.
        JSR        PromptToContinue
        BCS        FINISHED           ; done
        JMP        REPEAT             ; continue
.elseif .defined(SBC)
        JSR        MONRDKEY
        BCS        FINISHED           ; done
        JMP        REPEAT             ; continue
.endif

; OUTPUT THE ERROR INFO and STOP
; TEST#, ADDRESS, PATTERN, ERROR
LOOP_ERR:
        PHA
        STY     LZ                     ; test # is in Y
        JSR     Imprint
        .asciiz "Error: "
        LDA     LZ
        JSR     PrintByte                ; test #
        JSR     Imprint
        .asciiz " Addr: "
        LDA     ADDRS + $01
        JSR     PrintByte                 ; OUTPUT ADDRS HI
        LDA     ADDRS
        JSR     PrintByte                 ; OUTPUT ADDRS LO
        JSR     Imprint
        .asciiz " Exp: "
        LDA     TEST_PATRN
        JSR     PrintByte                 ; OUTPUT EXPECTED
        JSR     Imprint
        .asciiz " Read: "
        PLA
        JSR     PrintByte                 ; OUTPUT ACTUAL
        JSR      PrintCR
FINISHED:
        RTS
