;
; 6502 Instruction Trace
;
; Copyright (C) 2012-2019 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; Trace Feature
; --------------
;
; The "." command single steps one instruction at a time showing the
; CPU registers. Starts with the register values listed by the R
; command. Updates them after single stepping.
;
; The R(egister) command shows the current PC and disassembles the
; current instruction. It also allows the user to change the PC. Pressing
; <Enter> when prompted for a new register value will keep the current
; value and advance to the next register.
;
; The G(o) command will optionally use the PC value if the user
; hits <Enter> instead of an address.
;
; A breakpoint (BRK instruction) will display a message and update
; the current register values so that it can be traced. This works
; whether the breakpint address is set using the B command or not.
;
; The command supports tracing/stepping through ROM as well as RAM.
;
; e.g.
;
; ? R
; A-D2 X-00 Y-03 S-017B P-33 ..-BDIZC
; FF00   D8          CLD
; A-00 X-01 Y-02 S-01FF P-00 ........
; PC-FF00
; ? .
; A-D2 X-00 Y-03 S-017B P-33 ..-B.IZC
; FF01   58          CLI
; ? .
; A-D2 X-00 Y-03 S-017B P-33 ..-B..ZC
; FF02   A0 7F       LDY   #$7F
; ? .
; A-D2 X-00 Y-7F S-017B P-33 ..-B...C
; FF04   8C 12 D0    STY   $D012

; Variables used (defined in jmon.s):
;
; SAVE_A  - Holds saved values of registers
; SAVE_X  - "
; SAVE_Y  - "
; SAVE_S  - "
; SAVE_P  - "
; SAVE_PC - "
; NEXT_PC - Value of PC after next instruction
; ADDR - instruction address
; OPCODE - instruction op code
; OP - instruction type (OP_*)
; LEN -length of instruction
; IN - input buffer holding operands
; AM - addressing mode (AM_*)
; TRACEINST - buffer holding traced instruction


; Trace the next instruction using saved registers. Execute the
; instruction, display new registers values. disassemble new current
; instruction, and return.

Trace:

; Get next instruction op code from saved PC location.

        LDA SAVE_PC             ; Get address of instruction to execute (low byte)
        STA ADDR                ; Save in page zero so we can use indirect addressing
        LDA SAVE_PC+1           ; Do the same for the high byte of address
        STA ADDR+1
        LDY #0
        LDA (ADDR),Y            ; Get the instruction opcode
        STA OPCODE              ; And save it
        JSR GetLength           ; Determine instruction length

; Copy next instruction and operands to RAM buffer (can be up to 3 bytes)

        LDY #0
@Copy:
        LDA (ADDR),Y            ; Get the instruction / operand from memory
        STA TRACEINST,Y         ; Write it to the buffer where we will execute it
        INY                     ; Increment index
        CPY LEN                 ; Did we reach the instruction length?
        BNE @Copy               ; Continue for instruction length

; Now add a jump after the instruction to where we want to go after it is executed

        LDA #$4C                ; JMP ReturnFromTrace
        STA TRACEINST,Y
        INY
        LDA #<ReturnFromTrace
        STA TRACEINST,Y
        INY
        LDA #>ReturnFromTrace
        STA TRACEINST,Y

; Calculate new PC value.

        LDA SAVE_PC             ; Existing PC (low byte)
        CLC
        ADC LEN                 ; Add length to it
        STA NEXT_PC             ; Save as next PC (low byte)
        LDA SAVE_PC+1           ; High byte
        ADC #0                  ; Add any carry
        STA NEXT_PC+1           ; Save as next PC (high byte)

        LDA #0
        STA TAKEN               ; Clear branch taken flag.

; Special handling for instructions that change flow of control.
; These are not actually executed, they are emulated.
; TODO: Factor out common code for handling instructions which change flow of control.

; Bxx - branch instructions. These are executed but we change the
; destination of the branch so we catch whether they are taken or not.

        LDA AM                  ; Get addressing mode
        CMP #AM_RELATIVE        ; Relative addressing means a branch instruction
        BNE TryBRK

; The code in the TRACEINST buffer will look like this:
;
;       JMP TRACEINST
;       ...
;       Bxx $03 (Taken)         ; Instruction being traced
;       JMP ReturnFromTrace
;Taken: JMP BranchTaken
;        ...
;ReturnFromTrace:

        LDY #1                  ; Points to branch destination
        LDA #$03                ; Want to set it to $03 (Taken)
        STA TRACEINST,Y
        LDY #5
        LDA #$4C                ; JMP BranchTaken
        STA TRACEINST,Y
        INY
        LDA #<BranchTaken
        STA TRACEINST,Y
        INY
        LDA #>BranchTaken
        STA TRACEINST,Y

; Next PC in the case where the branch is not taken was already set earlier.

        JMP Execute

; BRK - set B=1. Next PC is contents of IRQ vector at $FFFE,$FFFF. Push return address-1 (Current address + 1). Push P.
TryBRK:
        LDA OPCODE              ; Get the opcode
        CMP #$00                ; BRK ?
        BNE TryJmp

        LDA SAVE_P              ; Get P
        ORA #%00010000          ; Set B bit
        STA SAVE_P

        LDA $FFFE               ; IRQ vector low
        STA NEXT_PC
        LDA $FFFF               ; IRQ vector high
        STA NEXT_PC+1

        LDA ADDR                ; Add 1 to current address
        CLC
        ADC #1
        STA ADDR
        LDA ADDR+1
        ADC #0                  ; Add any carry
        STA ADDR+1

        TSX                     ; Save our stack pointer
        STX THIS_S
        LDX SAVE_S              ; Get program's stack pointer
        TXS

        LDA ADDR+1              ; Push return address on program's stack (high byte first)
        PHA
        LDA ADDR
        PHA

        LDA SAVE_P              ; Push P
        PHA

        TSX                     ; Put program's stack pointer back
        STX SAVE_S

        LDX THIS_S              ; Restore our stack pointer
        TXS

        JMP AfterStep           ; We're done

; JMP (2) - Next PC is operand effective address (possibly indirect).

TryJmp:
        CMP #$4C                ; JMP nnnn ?
        BNE TryJmpI
        LDY #1
        LDA (ADDR),Y            ; Destination address low byte
        STA NEXT_PC
        INY
        LDA (ADDR),Y            ; Destination address high byte
        STA NEXT_PC+1
        JMP AfterStep           ; We're done

TryJmpI:
        CMP #$6C                ; JMP (nnnn) ?
        BNE TryJSR
        LDY #1
        LDA (ADDR),Y            ; Indirect destination address low byte
        STA T1
        INY
        LDA (ADDR),Y            ; Indirect destination address high byte
        STA T1+1
        LDY #0
        LDA (T1),Y              ; Get actual address low byte
        STA NEXT_PC
        INY
        LDA (T1),Y              ; Get actual address high byte
        STA NEXT_PC+1
        JMP AfterStep           ; We're done

; JSR - Next PC is operand effective address. Push return address-1 (Current address + 2) on stack.

TryJSR:
        CMP #$20                ; JSR nnnn ?
        BNE TryRTI

        LDY #1
        LDA (ADDR),Y            ; Destination address low byte
        STA NEXT_PC
        INY
        LDA (ADDR),Y            ; Destination address high byte
        STA NEXT_PC+1

        LDA ADDR                ; Add 2 to current address
        CLC
        ADC #2
        STA ADDR
        LDA ADDR+1
        ADC #0                  ; Add any carry
        STA ADDR+1

        TSX                     ; Save our stack pointer
        STX THIS_S
        LDX SAVE_S              ; Get program's stack pointer
        TXS

        LDA ADDR+1              ; Push return address on program's stack
        PHA
        LDA ADDR
        PHA

        TSX                     ; Put program's stack pointer back
        STX SAVE_S

        LDX THIS_S              ; Restore our stack pointer
        TXS

        JMP AfterStep           ; We're done

; RTI - Pop P. Pop PC. Increment PC to get next PC.

TryRTI:
        CMP #$40                ; RTI
        BNE TryRTS
        TSX                     ; Save our stack pointer
        STX THIS_S
        LDX SAVE_S              ; Get program's stack pointer
        TXS
        PLA                     ; Pop P
        STA SAVE_P
        PLA                     ; Pop return address low
        STA ADDR
        PLA                     ; Pop return address high
        STA ADDR+1
        TSX                     ; Put program's stack pointer back
        STX SAVE_S
        LDX THIS_S              ; Restore our stack pointer
        TXS
        LDA ADDR
        CLC
        ADC #1                  ; Add 1 to get new PC
        STA NEXT_PC
        LDA ADDR+1
        ADC #0                  ; Add any carry
        STA NEXT_PC+1
        JMP AfterStep           ; We're done

; RTS - Pop PC. Increment PC to get next PC.

TryRTS:
        CMP #$60                ; RTS
        BNE Execute
        TSX                     ; Save our stack pointer
        STX THIS_S
        LDX SAVE_S              ; Get program's stack pointer
        TXS
        PLA                     ; Pop return address low
        STA ADDR
        PLA                     ; Pop return address high
        STA ADDR+1
        TSX                     ; Put program's stack pointer back
        STX SAVE_S
        LDX THIS_S              ; Restore our stack pointer
        TXS
        LDA ADDR
        CLC
        ADC #1                  ; Add 1 to get new PC
        STA NEXT_PC
        LDA ADDR+1
        ADC #0                  ; Add any carry
        STA NEXT_PC+1
        JMP AfterStep           ; We're done

; Not a special instruction. We execute it from the buffer.

Execute:
; Save this program's stack pointer so we can restore it later.

        TSX
        STX THIS_S

; Restore registers from saved values.
; The order is critical here and P must be restored last.

        LDX SAVE_S              ; Restore stack pointer
        TXS
        LDA SAVE_P
        PHA                     ; Push P
        LDY SAVE_Y              ; Restore Y
        LDX SAVE_X              ; Restore X
        LDA SAVE_A              ; Restore A
        PLP                     ; Restore P

; Call instruction in buffer.
; It is followed by a JMP ReturnFromTrace so we get back

        JMP TRACEINST

; We get here if a relative branch being traced was taken.
BranchTaken:
        PHP                     ; Save value of P because INC will change it
        INC TAKEN               ; Set flag that branch was taken
        PLP                     ; Restore P
                                ; Fall through to same code as normal return from trace

; We get here after the traced instruction was executed.
ReturnFromTrace:

; Save new register values. Opposite order as was restored above.

        PHP
        STA SAVE_A
        STX SAVE_X
        STY SAVE_Y
        PLA
        STA SAVE_P
        TSX
        STX SAVE_S

; Clear D mode in case it is set, otherwise it would mess up our code.

        CLD

; Restore this program's stack pointer so RTS etc. will still work.

        LDX THIS_S
        TXS

AfterStep:

; Special case: If branch was taken (TAKEN=1), need to set next PC accordingly

        LDA TAKEN
        BEQ NewPC

; Next PC is Current address (ADDR) + operand (branch offset) + 2

        LDY #1
        LDA (ADDR),Y            ; Branch offset low
        STA REL
        BMI Min                 ; If minus, high byte is sign extended to be $FF
        LDA #0                  ; high byte is zero
        STA REL+1
        BEQ Add
Min:
        LDA #$FF                ; Negative offset, high byte is $FF
        STA REL+1
Add:
        LDA ADDR                ; Get current address low byte
        CLC
        ADC REL                 ; Add relative offset
        STA NEXT_PC
        LDA ADDR+1              ; Get current address low byte
        ADC REL+1               ; Add offset with any carry
        STA NEXT_PC+1

        LDA NEXT_PC             ; Get low byte of intermediate result
        CLC
        ADC #2                  ; Add 2
        STA NEXT_PC
        LDA NEXT_PC+1           ; Get low byte of intermediate result
        ADC #0                  ; Add any carry
        STA NEXT_PC+1
                                ; Now fall through to code below

; Set new PC to next PC
NewPC:
        LDA NEXT_PC
        STA SAVE_PC
        LDA NEXT_PC+1
        STA SAVE_PC+1

; Display register values

        JSR PrintRegisters

; Disassemble next instruction (Set ADDR, call DISASM)

        LDA SAVE_PC
        STA ADDR
        LDA SAVE_PC+1
        STA ADDR+1
        JMP DISASM              ; will return via caller

; Given an instruction opcode, return the instruction's length.
; On entry opcode is in OPCODE. Length is returned in LEN.
; Also sets opcode type in OP and addressing mode in AM.
; Registers changed: A, X
GetLength:
        LDA OPCODE
        BMI @UPPER              ; If bit 7 set, in upper half of table
        ASL A                   ; double it since table is two bytes per entry
        TAX
        LDA OPCODES1,X          ; Get the instruction type (e.g. OP_LDA)
        STA OP                  ; Store it
        INX
        LDA OPCODES1,X          ; Get addressing mode
        STA AM                  ; Store it
        JMP @AROUND
@UPPER:
        ASL A                   ; Double it since table is two bytes per entry
        TAX
        LDA OPCODES2,X          ; Get the instruction type (e.g. OP_LDA)
        STA OP                  ; Store it
        INX
        LDA OPCODES2,X          ; Get addressing mode
        STA AM                  ; Store it
@AROUND:
        TAX                     ; Put addressing mode in X
        LDA LENGTHS,X           ; Get instruction length given addressing mode
        STA LEN                 ; Store it
        RTS                     ; Return
