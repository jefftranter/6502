; 65816 Programming Example 4

.org $6000

; Set 65816 mode for assembler
.P816

; Make assembler smart about figuring out 8 versus 16-bit mode.
; Alternatively can use .A16 and .I16 directives.

  .smart

DEMO3:

; Examples of all 65816 instructions. This is a test case for my
; disassembler. It is not intended to run or do anything useful.

  COP $12
  ORA 3,S
  ORA [$44]
  PHD
  ORA $123456
  ORA (4,S),Y
  ORA [$55],Y
  TCS
  ORA $123456,X
  JSR $123456
  AND 7,S
  AND [$99]
  PLD
  AND $123456
  AND (4,S),Y
  AND [$55],Y
  TSC
  AND $123456,X
  .byte $42, $AA        ;  WDM $AA (Not supported by the assembler)
  EOR 7,S
  MVP $12,$34
  EOR [$99]
  PHK
  EOR $123456
  EOR (4,S),Y
  MVN $34,$12
  EOR [$55],Y
  TCD
  JMP $123456
  EOR $123456,X
  PER $1234
  ADC 5,X
  ADC [$55]
  RTL
  ADC $123456
  ADC (5,S),Y
  ADC [$55],Y
  TDC
  ADC $123456,X
  BRL DEMO3
  STA 1,S
  STA [$55]
  PHB
  STA $123456
  STA (5,S),Y
  STA [$55],Y
  TXY
  STA $123456,X
  LDA 5,S
  LDA [$66]
  PLB
  LDA $123456
  LDA (1,S),Y
  LDA [$55],Y
  TYX
  LDA $123456,X
  REP #%00110000
  SEP #%00110000
  CMP 5,S
  CMP [$12]
  WAI
  CMP $123456
  CMP (5,S),Y
  PEI ($55)
  CMP [$55],Y
  STP
  JML ($1234)
  CMP $123456,X
  CPX #$12
  SBC 5,S
  SBC [$55]
  XBA
  SBC $123456
  SBC (5,S),Y
  PEA $1234
  SBC [$44],Y
  XCE
  JSR ($1234,X)
  SBC $123456,X
