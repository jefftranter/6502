;Example SWEET16 code

    SWEET16 = $0289

   .SETCPU "6502"
    JSR SWEET16

   .SETCPU "sweet16"
    SET R1,$7000
    SET R2,$7002
    SET R3,10
LOOP:
    LD @R1
    ST @R2
    DCR R3
    BNZ LOOP
    RTN

; Examples of opcodes (code is not meaningful).

    SET R1,$1234
    LD R1
    ST R2
    LD @R1
    ST @R2
    LDD @R3
    STD @R4
    POP @R5
    STP @R6
    ADD R7
;    SUB R8
    POPD @R9
    CPR R1
    INR R2
    DCR R3
    RTN
HERE:
     BR LOOP
     BNC LOOP
     BC LOOP
     BP LOOP
     BM LOOP
     BZ LOOP
     BNZ LOOP
     BM1 LOOP
     BNM1 LOOP
     BK
     RS
     BS LOOP

     .SETCPU "6502"
     RTS
