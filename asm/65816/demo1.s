; 65816 Programming Example 1

.org $6000

; Set 65816 mode for assembler
.P816

; Make assembler smart about figuring out 8 versus 16-bit mode.
; Alternatively can use .A16 and .I16 directives.

  .smart

DEMO1:

; Try some new instructions that work in emulation mode

  TXY
  TYX
  TDC
  TSC
  PHX
  PHY
  PLX
  PLY
  XBA
  STZ $6100
  BRA THERE1
THERE1:
  BRL THERE2
THERE2:

  CLC
  XCE           ; switch to native mode

; Try some 8-bit instructions

  LDA #$00
  STA $6100
  LDA #$01
  STA $6101

; Set mode for 16 bit accum (bit 5 M=0) and 16 bit XY regs (bit 4 X=0)
  REP  #%00110000   ; clear bits 5 and 4

; Try some 16-bit instructions

  LDA #$0302
  STA $6102
  LDX #$0504
  STX $6104
  LDY #$0706
  STY $6106

; Set mode for 8-bit accum (bit 5 M=1) and 8-bit XY regs (bit 4 X=1)
  SEP  #%00110000   ; set bits 5 and 4

; Try some 8-bit instructions

  LDA #$08
  STA $6108
  LDX #09
  STX $6109
  LDY #0A
  STY $610A

  SEC
  XCE           ; switch to emulation mode

  RTS           ; Return to caller
