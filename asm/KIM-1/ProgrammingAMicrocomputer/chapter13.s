; Code for Dream Machine. Chapter 13.

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
GETCH   = $1E5A
OUTCH   = $1EA0
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703

; We begin with the stop key and then set up A0 and A1 as input bits.

START:  LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
        LDA     #$FC
        STA     DIRA
        LDA     #$00
        STA     PORTA

; We drop into the RNI (read next instruction) sequence which
; is going to reset the stack pointer so it doesn't creep down in
; page 1 by any chance. Then we will look at port A to see if A0 is
; one or zero. If it is 0 that means run full speed so we branch to
; RUN. If it is 1 that means at best a single step. We check A1.
; If it is also 1 we go back to the beginning of RNI. If it is zero
; we wait 2 milliseconds for bounce to wear off and then wait for a
; one so we know the switch has been pushed and released. BIT is a
; logical AND of memory with the accumulator. It sets the condition
; flags but does not change the accumulator.

RNI:    LDX     #$FF
        TXS
        LDA     PORTA
        BIT     KONE            ; (KONE) = 01
        BEQ     RUN
        BIT     KTWO            ; (KRWO) = 02
        BNE     RNI
DELAY:  DEX
        BNE     DELAY
LOOP:   LDA     PORTA
        BIT     KTWO
        BEQ     LOOP

; Next we get the program counter (and increment it by one) and then
; load the instruction register (OPCODE - ADDR) from memory. Then we
; being to decode the mode. Bit 1 says indirect addressing if equal
; to one. The contents of the cell pointed at by what's in ADDR goes
; into ADDR as the new address. Then we do indexing. If Bit 0 is a
; one, the contents of register B are added to the contents of ADDR.

RUN:    LDX     PC
        INC     PC
        LDA     LOBYT,X         ; (page 3)
        STA     ADDR
        LDA     HYBYT,X         ; (page 2)
        STA     OPCODE
        BIT     KTWO            ; (KTWO) = 02
        BEQ     DIRECT
        LDY     ADDR
        LDA     LOBYT,Y
        STA     ADDR
DIRECT:
        LDA     OPCODE
        BIT     KONE           ; (KONE) = 01
        BEQ     NOIND
        LDA     ADDR
        CLC
        ADC     BREG
        STA     ADDR
NOIND:  LDX     ADDR

; We get the opcode back and compute 3* op-code. We use this number
; as the offset in a branch instruction to do an indexed jump into
; the table of addresses - one for each op code. We enter each op-
; code section with a zero in the accumulator and the effective
; address in the X register.

        LDA     OPCODE
        AND     #$3C            ; Save the instruction 00111100
        CLC
        LSR
        STA     OPCODE
        LSR
        STA     OPCODE
        STA     z:VAR+1
        LDA     #$00
VAR:    BEQ     *               ; VAR+1 is the address of the second byte
        JMP     INPUT
        JMP     STOREA
        JMP     STOREB
        JMP     JUMPMINA
        JMP     JUMPZEROA
        JMP     JUMPZEROB
        JMP     JUMP
        JMP     JUMPSUB
        JMP     OUTPUT
        JMP     LOADA
        JMP     LOADB
        JMP     ADD
        JMP     SUBTRACT
        JMP     IAND
        JMP     IORA
        JMP     IEOR

; The input instruction uses the KIM subroutine GETCH and stores the
; character in the low order byte of the effective address. High
; order byte is cleared to zero:

INPUT:  STA     HYBYT,X
        JSR     GETCH
        STA     LOBYT,X
        JMP     RNI

; Store A and B are quite similar except that the second one puts
; zeros in the higher order byte of the effective address:

STOREA:
        LDA     ACCUP,X
        STA     HYBYT,X
        LDA     ACCLO
        STA     LOBYT,X
        JMP     RNI
STOREB:
        STA     HYBYT,X
        LDA     BREG
        STA     LOBYT,X
        JMP     RNI

; Jump on minus A just tests the sign bit:

JUMPMINA:
        LDA     ACCUP,X
        BPL     E3
        STX     PC
E3:     JMP     RNI

; Jump on zero A has to test both halves but B has only one half

JUMPZEROA:
        LDA     ACCUP
        BNE     E4
        LDA     ACCLO
        BNE     E4
        STX     PC
E4:     JMP     RNI
JUMPZEROB:
        LDA     BREG
        BNE     E5
        STX     PC
E5:     JMP     RNI

; Plain unconditional jump could be tucked in as a new name for the
; last two instructions of any one jump instruction but it is
; clearer if we have it separate:

JUMP:   STX     PC
        JMP     RNI

; Skip to $0200 so we don't put code in page 1 where the stack is located.
        .RES    $0200-*

; Subroutine jump saves the PC at the effective address (X) and then
; transfers control to location Y + 1.

JUMPSUB:
        LDA     PC
        STA     LOBYT,X
        INX
        STX     PC
        JMP     RNI

; Output uses the OUTCH subroutine of KIM:

OUTPUT: LDA     LOBYT,X
        JSR     OUTCH
        JMP     RNI

; Load A and B are straightforward:

LOADA:   LDA    HYBYT,X
         STA    ACCUP
         LDA    LOBYT,X
         STA    ACCLO
         JMP    RNI
LOADB:   LDA    LOBYT,X
         STA    BREG
         JMP    RNI

; If you haven't done a double precision add or subtract this is your
; chance to see one in action. We add the two lower halves and then
; add the carry from that sum to the two upper halves. Subtract is
; just the same except we do a borrow instead of a carry:

ADD:     CLC
         LDA    LOBYT,X
         ADC    ACCLO
         STA    ACCLO
         LDA    HYBYT,X
         ADC    ACCUP           ; Note we do not clear carry
         STA    ACCUP
         JMP    RNI

SUBTRACT:
         SEC
         LDA    ACCLO
         SBC    LOBYT
         STA    ACCLO
         LDA    ACCUP
         SBC    HYBYT           ; We do not set carry
         STA    ACCUP
         JMP    RNI

; The three logical instructions are identical except for the substi-
; tution of a different machine code in two crucial places. In order
; to save God knows how many trees, perhaps entire forests, we
; will include the AND and merely indicate the changes for ORA and
; exclusive or.

IAND:    LDA    LOBYT,X
         AND    ACCLO           ; (ORA) (EOR)
         STA    ACCLO
         LDA    HYBYT,X
         AND    ACCUP           ; (ORA) (EOR)
         STA    ACCUP
         JMP    RNI

IORA:    LDA    LOBYT,X
         ORA    ACCLO           ; (ORA) (EOR)
         STA    ACCLO
         LDA    HYBYT,X
         ORA    ACCUP           ; (ORA) (EOR)
         STA    ACCUP
         JMP    RNI

IEOR:    LDA    LOBYT,X
         EOR    ACCLO           ; (ORA) (EOR)
         STA    ACCLO
         LDA    HYBYT,X
         EOR    ACCUP           ; (ORA) (EOR)
         STA    ACCUP
         JMP    RNI

; For constants we have only two:

KONE:    .BYTE  $01
KTWO:    .BYTE  $02

; For variables we have:

ACCLO:   .RES   1               ; The two halves of the accumulator
ACCUP:   .RES   1
BREG:    .RES   1               ; The index register B
OPCODE:  .RES   1               ; The two halves of the instruction register
ADDR:    .RES   1
PC:      .RES   1               ; The program counter
HYBYT:   .RES   1
LOBYT:   .RES   2
