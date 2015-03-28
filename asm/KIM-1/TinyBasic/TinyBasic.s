         GETCH    = $1E5A           ; KIM-1 character input routine
         OUTCH    = $1EA0           ; KIM-1 character output routine
         KTTY     = $1740           ; KIM-1 TTY port
         FREERAM   = $2000          ; Start of free RAM for program storage

         .org     $0100

;  BREAK TEST FOR KIM
KIMBT    LDA      KTTY              ; LOOK AT TTY
         CLC                        ; C=O IF IDLE
         BMI      KIMX              ; IDLE
         LDA      KTTY              ; WAIT FOR END
         BPL      *-3
KLDY     JSR      *+3
         LDA      #255              ; DELAY 2 RUBOUT TIMES
         JSR      OUTCH
         SEC                        ; C=1 IF BREAK
KIMX     RTS

         .res     235
;
; Tiny Basic starts here
;
         .org     $0200             ; Start of Basic.
START

CV       JMP      COLD_S            ; Cold start vector
WV       JMP      WARM_S            ; Warm start vector
IN_V     JMP      GETCH             ; Input routine address. 
OUT_V    JMP      OUTCH             ; Output routine address.
BV       JMP      KIMBT             ; Begin break routine

;
; Some codes
;
BSC      .byte $5f                   ; Backspace code
LSC      .byte $18                   ; Line cancel code
PCC      .byte $80                   ; Pad character control
TMC      .byte $00                   ; Tape mode control
SSS      .byte $04                   ; Spare Stack size. (was $04 but documentation suggests $20)

;
; Code fragment for 'PEEK' and 'POKE'
;
PEEK     STX $C3                   ; 'PEEK' - store X in $C3
         BCC LBL008                ; On carry clear goto LBL008
         STX $C3                   ; 'POKE' - store X in $C3
         STA ($C2),Y               ; Store A in location pointed to by $C3 (hi) and Y (lo)
         RTS                       ; Return
LBL008   LDA ($C2),Y               ; Load A with value pointed to by $C3 (hi) and Y (lo)
         LDY #$00                  ; Reset Y
         RTS                       ; Return

;
; The following table contains the addresses for the ML handlers for the IL opcodes.
;
SRVT     .word  IL_BBR               ; ($40-$5F) Backward Branch Relative
         .word  IL_FBR               ; ($60-$7F) Forward Branch Relative
         .word  IL__BC               ; ($80-$9F) String Match Branch
         .word  IL__BV               ; ($A0-$BF) Branch if not Variable
         .word  IL__BN               ; ($C0-$DF) Branch if not a Number
         .word  IL__BE               ; ($E0-$FF) Branch if not End of line
         .word  IL__NO               ; ($08) No Opertion
         .word  IL__LB               ; ($09) Push Literal Byte onto Stack
         .word  IL__LN               ; ($0A) Push Literal Number
         .word  IL__DS               ; ($0B) Duplicate Top two bytes on Stack
         .word  IL__SP               ; ($0C) Stack Pop
         .word  IL__NO               ; ($0D) (Reserved)
         .word  IL__NO               ; ($0E) (Reserved)
         .word  IL__NO               ; ($0F) (Reserved)
         .word  IL__SB               ; ($10) Save Basic Pointer
         .word  IL__RB               ; ($11) Restore Basic Pointer
         .word  IL__FV               ; ($12) Fetch Variable
         .word  IL__SV               ; ($13) Store Variable
         .word  IL__GS               ; ($14) Save GOSUB line
         .word  IL__RS               ; ($15) Restore saved line
         .word  IL__GO               ; ($16) GOTO
         .word  IL__NE               ; ($17) Negate
         .word  IL__AD               ; ($18) Add
         .word  IL__SU               ; ($19) Subtract
         .word  IL__MP               ; ($1A) Multiply
         .word  IL__DV               ; ($1B) Divide
         .word  IL__CP               ; ($1C) Compare
         .word  IL__NX               ; ($1D) Next BASIC statement
         .word  IL__NO               ; ($1E) (Reserved)
         .word  IL__LS               ; ($1F) List the program
         .word  IL__PN               ; ($20) Print Number
         .word  IL__PQ               ; ($21) Print BASIC string
         .word  IL__PT               ; ($22) Print Tab
         .word  IL__NL               ; ($23) New Line
         .word  IL__PC               ; ($24) Print Literal String
         .word  IL__NO               ; ($25) (Reserved)
         .word  IL__NO               ; ($26) (Reserved)
         .word  IL__GL               ; ($27) Get input Line
         .word  ILRES1               ; ($28) (Seems to be reserved - No IL opcode calls this)
         .word  ILRES2               ; ($29) (Seems to be reserved - No IL opcode calls this)
         .word  IL__IL               ; ($2A) Insert BASIC Line
         .word  IL__MT               ; ($2B) Mark the BASIC program space Empty
         .word  IL__XQ               ; ($2C) Execute
         .word  WARM_S               ; ($2D) Stop (Warm Start)
         .word  IL__US               ; ($2E) Machine Language Subroutine Call
         .word  IL__RT               ; ($2F) IL subroutine return

ERRSTR   .byte " AT "                ; " AT " string used in error reporting.  Tom was right about this.
         .byte $80                   ; String terminator
         
LBL002   .word  ILTBL                ; Address of IL program table

;
; Begin Cold Start
;
; Load start of free RAM into locations $20 and $21
; and initialize the address for end of free ram ($22 & $23)
;
COLD_S   lda #<FREERAM              ; Load accumulator with $00
         sta $20                    ; Store $00 in $20
         sta $22                    ; Store $00 in $22
         lda #>FREERAM              ; Load accumulator with $02
         sta $21                    ; Store $02 in $21
         sta $23                    ; Store $02 in $23
;
;
; Begin test for free ram
;

         ldy #$01                   ; Load register Y with $01
MEM_T    lda ($22),Y                ; Load accumulator With the contents of a byte of memory
         tax                        ; Save it to X
         eor #$FF                   ; Next 4 instuctions test to see if this memory location
         sta ($22),Y                ; is ram by trying to write something new to it - new value
         cmp ($22),Y                ; gets created by XORing the old value with $FF - store the
         php                        ; result of the test on the stack to look at later
         txa                        ; Retrieve the old memory value
         sta ($22),Y                ; Put it back where it came from
         inc $22                    ; Increment $22 (for next memory location)
         bne SKP_PI                 ; Skip if we don't need to increment page
         inc $23                    ; Increment $23 (for next memory page)
SKP_PI   lda $23                    ; Get high byte of memory address
         cmp #>START                ; Did we reach start address of Tiny Basic?
         bne PULL                   ; Branch if not
         lda $22                    ; Get low byte of memory address
         cmp #<START                ; Did we reach start address of Tiny Basic?
         beq TOP                    ; If so, stop memory test so we don't overwrite ourselves
PULL  
         plp                        ; Now look at the result of the memory test
         beq MEM_T                  ; Go test the next memory location if the last one was ram
TOP
         dey                        ; If last memory location did not test as ram, decrement Y (should be $00 now)

IL__MT   cld                        ; Make sure we're not in decimal mode
         lda $20                    ; Load up the low-order by of the start of free ram
         adc SSS                    ; Add to the spare stack size
         sta $24                    ; Store the result in $0024
         tya                        ; Retrieve Y
         adc $21                    ; And add it to the high order byte of the start of free ram (this does not look right)
         sta $25                    ; Store the result in $0025
         tya                        ; Retrieve Y again
         sta ($20),Y                ; Store A in the first byte of program memory
         iny                        ; Increment Y
         sta ($20),Y                ; Store A in the second byte of program memory
;
;Begin Warm Start
;
WARM_S   lda $22
         sta $C6
         sta $26
         lda $23
         sta $C7
         sta $27
         jsr P_NWLN                 ; Go print CR, LF and pad characters
LBL014   lda LBL002                 ; Load up the start of the IL Table 
         sta $2A                    ;
         lda LBL002+$01             ;
         sta $2B
         lda #$80
         sta $C1
         lda #$30
         sta $C0
         ldx #$00
         stx $BE
         stx $C2
         dex
         txs

;
; IL execution loop
;
LBL006   cld                        ; Make sure we're in binary mode 
         jsr LBL004                 ; Go read a byte from the IL program table
         jsr LBL005                 ; Go decide what to do with it
         jmp LBL006                 ; Repeat
;
;
;
         .byte $83                   ; No idea about this
         .byte $65                   ; No idea about this
;
;
; Routine to service the TBIL Instructions
;
LBL005   cmp #$30                   ;
         bcs LBL011                 ; If it's $30 or higher, it's a Branch or Jump - go handle it
         cmp #$08                   ; 
         bcc LBL007                 ; If it's less than $08 it's a stack exchange - go handle it
         asl                        ; Multiply the OP code by 2 
         tax                        ; Transfer it to X
LBL022   lda SRVT-$03,X             ; Get the hi byte of the OP Code handling routine
         pha                        ; and save it on the stack
         lda SRVT-$04,X             ; Get the lo byte
         pha                        ; and save it on the stack
         php                        ; save the processor status too
         rti                        ; now go execute the OP Code handling routine
;
;
; Routine to handle the stack exchange 
;
LBL007   adc $C1
         tax
         lda ($C1),Y
         pha
         lda $00,X
         sta ($C1),Y
         pla
         sta $00,X
         rts
;
;
;
LBL015   jsr P_NWLN                 ; Go print CR, LF and pad characters
         lda #$21                   ; '!' character
         jsr OUT_V                  ; Go print it
         lda $2A                    ; Load the current TBIL pointer (lo) 
         sec                        ; Set the carry flag
         sbc LBL002                 ; Subtract the TBIL table origin (lo)
         tax                        ; Move the difference to X
         lda $2B                    ; Load the current TBIL pointer (hi)
         sbc LBL002+$01             ; Subtract the TBIL table origin (hi)
         jsr LBL010
         lda $BE
         beq LBL012
         lda #<ERRSTR               ; Get lo byte of error string address
         sta $2A                    ; Put in $2A
         lda #>ERRSTR               ; Get hi byte of error string address
         sta $2B                    ; Put in $2B
         jsr IL__PC                 ; Go report an error has been detected
         ldx $28
         lda $29
         jsr LBL010
LBL012   lda #$07                   ; ASCII Bell
         jsr OUT_V                  ; Go ring Bell
         jsr P_NWLN                 ; Go print CR, LF and pad characters
LBL060   lda $26
         sta $C6
         lda $27
         sta $C7
         jmp LBL014
;
;
;
LBL115   ldx #$7C
LBL048   cpx $C1
LBL019   bcc LBL015
         ldx $C1
         inc $C1
         inc $C1
         clc
         rts
;
;
;
IL_BBR   dec $BD                    ; Entry point for TBIL Backward Branch Relative
IL_FBR   lda $BD                    ; Entry point for TBIL Forward Branch Relative
         beq LBL015
LBL017   lda $BC
         sta $2A
         lda $BD
         sta $2B
         rts
;
; Jump handling routine
;
LBL011   cmp #$40
         bcs LBL016                 ; If it's not a Jump, go to branch handler
         pha
         jsr LBL004                 ; Go read a byte from the TBIL table
         adc LBL002
         sta $BC
         pla
         pha
         and #$07
         adc LBL002+$01
         sta $BD
         pla
         and #$08
         bne LBL017
         lda $BC
         ldx $2A
         sta $2A
         stx $BC
         lda $BD
         ldx $2B
         sta $2B
         stx $BD
LBL126   lda $C6
         sbc #$01
         sta $C6
         bcs LBL018
         dec $C7
LBL018   cmp $24
         lda $C7
         sbc $25
         bcc LBL019
         lda $BC
         sta ($C6),Y
         iny
         lda $BD
         sta ($C6),Y
         rts
;
;
; Branch Handler
;
LBL016   pha
         lsr
         lsr
         lsr
         lsr
         and #$0E
         tax
         pla
         cmp #$60
         and #$1F
         bcs LBL020
         ora #$E0
LBL020   clc
         beq LBL021
         adc $2A
         sta $BC
         tya
         adc $2B
LBL021   sta $BD
         jmp LBL022
;
;
;
IL__BC   lda $2C                    ; Entry point for TBIL BC (String Match Branch)
         sta $B8
         lda $2D
         sta $B9
LBL025   jsr LBL023
         jsr LBL024
         eor ($2A),Y
         tax
         jsr LBL004                 ; Go read a byte from the TBIL table
         txa
         beq LBL025
         asl
         beq LBL026
         lda $B8
         sta $2C
         lda $B9
         sta $2D
LBL028   jmp IL_FBR
IL__BE   jsr LBL023                 ; Entry point for TBIL BE (Branch if not End of line)
         cmp #$0D
         bne LBL028
LBL026   rts
;
;
;
IL__BV   jsr LBL023                 ; Entry point for TBIL BV (Branch if not Variable)
         cmp #$5B
         bcs LBL028
         cmp #$41
         bcc LBL028
         asl
         jsr LBL029
LBL024   ldy #$00
         lda ($2C),Y
         inc $2C
         bne LBL030
         inc $2D
LBL030   cmp #$0D
         clc
         rts
;
;
;
LBL031   jsr LBL024
LBL023   lda ($2C),Y
         cmp #$20
         beq LBL031
         cmp #$3A
         clc
         bpl LBL032
         cmp #$30
LBL032   rts
;
;
;
IL__BN   jsr LBL023                 ; Entry point for TBIL BN (Branch if not a Number)
         bcc LBL028
         sty $BC
         sty $BD
LBL033   lda $BC
         ldx $BD
         asl $BC
         rol $BD
         asl $BC
         rol $BD
         clc
         adc $BC
         sta $BC
         txa
         adc $BD
         asl $BC
         rol
         sta $BD
         jsr LBL024
         and #$0F
         adc $BC
         sta $BC
         tya
         adc $BD
         sta $BD
         jsr LBL023
         bcs LBL033
         jmp LBL034
LBL061   jsr IL__SP
         lda $BC
         ora $BD
         beq LBL036
LBL065   lda $20
         sta $2C
         lda $21
         sta $2D
LBL040   jsr LBL037
         beq LBL038
         lda $28
         cmp $BC
         lda $29
         sbc $BD
         bcs LBL038
LBL039   jsr LBL024
         bne LBL039
         jmp LBL040
LBL038   lda $28
         eor $BC
         bne LBL041
         lda $29
         eor $BD
LBL041   rts
;
;
;
LBL043   jsr LBL042
IL__PC   jsr LBL004                 ; Entry point for TBIL PC (print literal) - Go read a byte from the TBIL table
         bpl LBL043
LBL042   inc $BF
         bmi LBL044
         jmp OUT_V                  ; Go print it
LBL044   dec $BF
LBL045   rts
;
;
;
LBL046   cmp #$22
         beq LBL045
         jsr LBL042
IL__PQ   jsr LBL024                 ; Entry point for TBIL PQ
         bne LBL046
LBL036   jmp LBL015
IL__PT   lda #$20                   ; Entry point for TBIL PT
         jsr LBL042
         lda $BF
         and #$87
         bmi LBL045
         bne IL__PT
         rts
;
;
;
IL__CP   ldx #$7B
         jsr LBL048
         inc $C1
         inc $C1
         inc $C1
         sec
         lda $03,X
         sbc $00,X
         sta $00,X
         lda $04,X
         sbc $01,X
         bvc LBL052
         eor #$80
         ora #$01
LBL052   bmi LBL053
         bne LBL054
         ora $00,X
         beq LBL049
LBL054   lsr $02,X
LBL049   lsr $02,X
LBL053   lsr $02,X
         bcc LBL050
LBL004   ldy #$00                   ; Read a byte from the TBIL Table
         lda ($2A),Y               ;
         inc $2A                    ; Increment TBIL Table pointer as required
         bne LBL051                 ;
         inc $2B                    ;
LBL051   ora #$00                   ; Check for $00 and set the 'Z' flag acordingly
LBL050   rts                        ; Return
;
;
;
IL__NX   lda $BE                    ; Entry point for TBIL NX
         beq LBL055
LBL056   jsr LBL024
         bne LBL056
         jsr LBL037
         beq LBL057
LBL062   jsr LBL058
         jsr BV                     ; Test for break
         bcs LBL059
         lda $C4
         sta $2A
         lda $C5
         sta $2B
         rts
;
;
;
LBL059   lda LBL002
         sta $2A
         lda LBL002+$01
         sta $2B
LBL057   jmp LBL015
LBL055   sta $BF
         jmp LBL060
IL__XQ   lda $20                    ; Entry point fro TBIL XQ
         sta $2C
         lda $21
         sta $2D
         jsr LBL037
         beq LBL057
         lda $2A
         sta $C4
         lda $2B
         sta $C5
LBL058   lda #$01
         sta $BE
         rts
;
;
;
IL__GO   jsr LBL061                 ; Entry point for TBIL GO
         beq LBL062
LBL066   lda $BC
         sta $28
         lda $BD
         sta $29
         jmp LBL015
IL__RS   jsr LBL063                 ; Entry point for TBIL RS
         jsr LBL064
         jsr LBL065
         bne LBL066
         rts
;
;
;
LBL037   jsr LBL024
         sta $28
         jsr LBL024
         sta $29
         ora $28
         rts
;
;
;
IL__DS   jsr IL__SP                 ; Entry point for TBIL DS
         jsr LBL034
LBL034   lda $BD
LBL131   jsr LBL029
         lda $BC
LBL029   ldx $C1
         dex
         sta $00,X
         stx $C1
         cpx $C0
         bne IL__NO
LBL068   jmp LBL015
LBL097   ldx $C1
         cpx #$80
         bpl LBL068
         lda $00,X
         inc $C1
IL__NO   rts                        ; Entry point for the TBIL NO
;
;
;
LBL010   sta $BD
         stx $BC
         jmp LBL069
IL__PN   ldx $C1                    ; Entry point for the TBIL PN
         lda $01,X
         bpl LBL070
         jsr IL__NE
         lda #$2D
         jsr LBL042
LBL070   jsr IL__SP
LBL069   lda #$1F
         sta $B8
         sta $BA
         lda #$2A
         sta $B9
         sta $BB
         ldx $BC
         ldy $BD
         sec
LBL072   inc $B8
         txa
         sbc #$10
         tax
         tya
         sbc #$27
         tay
         bcs LBL072
LBL073   dec $B9
         txa
         adc #$E8
         tax
         tya
         adc #$03
         tay
         bcc LBL073
         txa
LBL074   sec
         inc $BA
         sbc #$64
         bcs LBL074
         dey
         bpl LBL074
LBL075   dec $BB
         adc #$0A
         bcc LBL075
         ora #$30
         sta $BC
         lda #$20
         sta $BD
         ldx #$FB
LBL199   stx $C3
         lda $BD,X
         ora $BD
         cmp #$20
         beq LBL076
         ldy #$30
         sty $BD
         ora $BD
         jsr LBL042
LBL076   ldx $C3
         inx
         bne LBL199
         rts
;
;
;
IL__LS   lda $2D                    ; Entry point for TBIL LS
         pha
         lda $2C
         pha
         lda $20
         sta $2C
         lda $21
         sta $2D
         lda $24
         ldx $25
         jsr LBL077
         beq LBL078
         jsr LBL077
LBL078   lda $2C
         sec
         sbc $B6
         lda $2D
         sbc $B7
         bcs LBL079
         jsr LBL037
         beq LBL079
         ldx $28
         lda $29
         jsr LBL010
         lda #$20
LBL080   jsr LBL042
         jsr BV                     ; Test for break
         bcs LBL079
         jsr LBL024
         bne LBL080
         jsr IL__NL
         jmp LBL078
LBL077   sta $B6
         inc $B6
         bne LBL082
         inx
LBL082   stx $B7
         ldy $C1
         cpy #$80
         beq LBL083
         jsr LBL061
LBL099   lda $2C
         ldx $2D
         sec
         sbc #$02
         bcs LBL084
         dex
LBL084   sta $2C
         jmp LBL085
LBL079   pla
         sta $2C
         pla
         sta $2D
LBL083   rts
IL__NL   lda $BF                    ; Entry point for TBIL NL
         bmi LBL083
;
;
; Routine to print a new line.  It handles CR, LF
; and adds pad characters to the ouput
;
P_NWLN   lda #$0D                   ; Load up a CR
         jsr OUT_V                  ; Go print it
         lda PCC                    ; Load the pad character code
         and #$7F                   ; Test to see - 
         sta $BF                    ; how many pad characters to print
         beq LBL086                 ; Skip if 0
LBL088   jsr LBL087                 ; Go print pad character
         dec $BF                    ; One less
         bne LBL088                 ; Loop until 0
LBL086   lda #$0A                   ; Load up a LF
         jmp LBL089                 ; Go print it
;
;
;
LBL092   ldy TMC
LBL091   sty $BF
         bcs LBL090
IL__GL   lda #$30                   ; Entry pont for TBIL GL
         sta $2C
         sta $C0
         sty $2D
         jsr LBL034
LBL090   eor $80
         sta $80
         jsr IN_V
         ldy #$00
         ldx $C0
         and #$7F
         beq LBL090
         cmp #$7F
         beq LBL090
         cmp #$13
         beq LBL091
         cmp #$0A
         beq LBL092
         cmp LSC
         beq LBL093
         cmp BSC
         bne LBL094
         cpx #$30
         bne LBL095
LBL093   ldx $2C
         sty $BF
         lda #$0D
LBL094   cpx $C1
         bmi LBL096
         lda #$07
         jsr LBL042
         jmp LBL090
LBL096   sta $00,X
         inx
         inx
LBL095   dex
         stx $C0
         cmp #$0D
         bne LBL090
         jsr IL__NL
IL__SP   jsr LBL097                 ; Entry point for TBIL SP
         sta $BC
         jsr LBL097
         sta $BD
         rts
;
;
;
IL__IL   jsr LBL098                 ; Entry point for TBIL IL
         jsr LBL061
         php
         jsr LBL099
         sta $B8
         stx $B9
         lda $BC
         sta $B6
         lda $BD
         sta $B7
         ldx #$00
         plp
         bne LBL100
         jsr LBL037
         dex
         dex
LBL101   dex
         jsr LBL024
         bne LBL101
LBL100   sty $28
         sty $29
         jsr LBL098
         lda #$0D
         cmp ($2C),Y
         beq LBL102
         inx
         inx
         inx
LBL103   inx
         iny
         cmp ($2C),Y
         bne LBL103
         lda $B6
         sta $28
         lda $B7
         sta $29
LBL102   lda $B8
         sta $BC
         lda $B9
         sta $BD
         clc
         ldy #$00
         txa
         beq LBL104
         bpl LBL105
         adc $2E
         sta $B8
         lda $2F
         sbc #$00
         sta $B9
LBL109   lda ($2E),Y
         sta ($B8),Y
         ldx $2E
         cpx $24
         bne LBL106
         lda $2F
         cmp $25
         beq LBL107
LBL106   inx
         stx $2E
         bne LBL108
         inc $2F
LBL108   inc $B8
         bne LBL109
         inc $B9
         bne LBL109
LBL105   adc $24
         sta $B8
         sta $2E
         tya
         adc $25
         sta $B9
         sta $2F
         lda $2E
         sbc $C6
         lda $2F
         sbc $C7
         bcc LBL110
         dec $2A
         jmp LBL015
LBL110   lda ($24),Y
         sta ($2E),Y
         ldx $24
         bne LBL111
         dec $25
LBL111   dec $24
         ldx $2E
         bne LBL112
         dec $2F
LBL112   dex
         stx $2E
         cpx $BC
         bne LBL110
         ldx $2F
         cpx $BD
         bne LBL110
LBL107   lda $B8
         sta $24
         lda $B9
         sta $25
LBL104   lda $28
         ora $29
         beq LBL113
         lda $28
         sta ($BC),Y
         iny
         lda $29
         sta ($BC),Y
LBL114   iny
         sty $B6
         jsr LBL024
         php
         ldy $B6
         sta ($BC),Y
         plp
         bne LBL114
LBL113   jmp LBL014
IL__DV   jsr LBL115
         lda $03,X
         and #$80
         beq LBL116
         lda #$FF
LBL116   sta $BC
         sta $BD
         pha
         adc $02,X
         sta $02,X
         pla
         pha
         adc $03,X
         sta $03,X
         pla
         eor $01,X
         sta $BB
         bpl LBL117
         jsr LBL118
LBL117   ldy #$11
         lda $00,X
         ora $01,X
         bne LBL119
         jmp LBL015
LBL119   sec
         lda $BC
         sbc $00,X
         pha
         lda $BD
         sbc $01,X
         pha
         eor $BD
         bmi LBL120
         pla
         sta $BD
         pla
         sta $BC
         sec
         jmp LBL121
LBL120   pla
         pla
         clc
LBL121   rol $02,X
         rol $03,X
         rol $BC
         rol $BD
         dey
         bne LBL119
         lda $BB
         bpl LBL122
IL__NE   ldx $C1                    ; Entry point for TBIL NE
LBL118   sec
         tya
         sbc $00,X
         sta $00,X
         tya
         sbc $01,X
         sta $01,X
LBL122   rts
;
;
;
IL__SU   jsr IL__NE                 ; Entry point for TBIL SU
IL__AD   jsr LBL115                 ; Entry point for TBIL AD
         lda $00,X
         adc $02,X
         sta $02,X
         lda $01,X
         adc $03,X
         sta $03,X
         rts
;
;
;
IL__MP   jsr LBL115                 ; Entry point for TBIL MP
         ldy #$10
         lda $02,X
         sta $BC
         lda $03,X
         sta $BD
LBL124   asl $02,X
         rol $03,X
         rol $BC
         rol $BD
         bcc LBL123
         clc
         lda $02,X
         adc $00,X
         sta $02,X
         lda $03,X
         adc $01,X
         sta $03,X
LBL123   dey
         bne LBL124
         rts
;
;
;
IL__FV   jsr LBL097                 ; Entry point for TBIL FV
         tax
         lda $00,X
         ldy $01,X
         dec $C1
         ldx $C1
         sty $00,X
         jmp LBL029
IL__SV   ldx #$7D                   ; Entry point for TBIL SV
         jsr LBL048
         lda $01,X
         pha
         lda $00,X
         pha
         jsr LBL097
         tax
         pla
         sta $00,X
         pla
         sta $01,X
         rts
IL__RT   jsr LBL063
         lda $BC
         sta $2A
         lda $BD
         sta $2B
         rts
;
;
;
IL__SB   ldx #$2C                   ; Entry point for TBIL SB 
         bne LBL125
IL__RB   ldx #$2E                   ; Entry point for TBIL RB
LBL125   lda $00,X
         cmp #$80
         bcs LBL098
         lda $01,X
         bne LBL098
         lda $2C
         sta $2E
         lda $2D
         sta $2F
         rts
;
;
;
LBL098   lda $2C
         ldy $2E
         sty $2C
         sta $2E
         lda $2D
         ldy $2F
         sty $2D
         sta $2F
         ldy #$00
         rts
;
;
;
IL__GS   lda $28                    ; Entry point for TBIL GS
         sta $BC
         lda $29
         sta $BD
         jsr LBL126
         lda $C6
         sta $26
         lda $C7
LBL064   sta $27
LBL129   rts
;
;
;
LBL063   lda ($C6),Y
         sta $BC
         jsr LBL127
         lda ($C6),Y
         sta $BD
LBL127   inc $C6
         bne LBL128
         inc $C7
LBL128   lda $22
         cmp $C6
         lda $23
         sbc $C7
         bcs LBL129
         jmp LBL015
IL__US   jsr LBL130
         sta $BC
         tya
         jmp LBL131
LBL130   jsr IL__SP
         lda $BC
         sta $B6
         jsr IL__SP
         lda $BD
         sta $B7
         ldy $BC
         jsr IL__SP
         ldx $B7
         lda $B6
         clc
         jmp ($00BC)
IL__LN   jsr IL__LB                 ; Entry point for TBIL LN
IL__LB   jsr LBL004                 ; Entry point for TBIL LB - Go read a byte from the IL table
         jmp LBL029
LBL085   stx $2D
         cpx #$00
         rts
;
;
;
ILRES2   ldy #$02                   ; These two entry points are for code that
ILRES1   sty $BC                    ;  does not seem to get called.  Need more research.
         ldy #$29
         sty $BD
         ldy #$00
         lda ($BC),Y
         cmp #$08
         bne LBL133
         jmp LBL117
LBL133   rts
;
;
; Subroutine to decide which pad characters to print
;
LBL089   jsr OUT_V                  ; Entry point with a character to print first
LBL087   lda #$FF                   ; Normal entry point - Set pad to $FF
         bit PCC                    ; Check if the pad flag is on
         bmi LBL134                 ; Skip it if not
         lda #$00                   ; set pad to $00
LBL134   jmp OUT_V                  ; Go print it


;
; TBIL program table
;
ILTBL    .byte $24, $3A, $91, $27, $10, $E1, $59, $C5, $2A, $56, $10, $11, $2C, $8B, $4C
         .byte $45, $D4, $A0, $80, $BD, $30, $BC, $E0, $13, $1D, $94, $47, $CF, $88, $54
         .byte $CF, $30, $BC, $E0, $10, $11, $16, $80, $53, $55, $C2, $30, $BC, $E0, $14
         .byte $16, $90, $50, $D2, $83, $49, $4E, $D4, $E5, $71, $88, $BB, $E1, $1D, $8F
         .byte $A2, $21, $58, $6F, $83, $AC, $22, $55, $83, $BA, $24, $93, $E0, $23, $1D
         .byte $30, $BC, $20, $48, $91, $49, $C6, $30, $BC, $31, $34, $30, $BC, $84, $54
         .byte $48, $45, $CE, $1C, $1D, $38, $0D, $9A, $49, $4E, $50, $55, $D4, $A0, $10
         .byte $E7, $24, $3F, $20, $91, $27, $E1, $59, $81, $AC, $30, $BC, $13, $11, $82
         .byte $AC, $4D, $E0, $1D, $89, $52, $45, $54, $55, $52, $CE, $E0, $15, $1D, $85
         .byte $45, $4E, $C4, $E0, $2D, $98, $4C, $49, $53, $D4, $EC, $24, $00, $00, $00
         .byte $00, $0A, $80, $1F, $24, $93, $23, $1D, $30, $BC, $E1, $50, $80, $AC, $59
         .byte $85, $52, $55, $CE, $38, $0A, $86, $43, $4C, $45, $41, $D2, $2B, $84, $52
         .byte $45, $CD, $1D, $A0, $80, $BD, $38, $14, $85, $AD, $30, $D3, $17, $64, $81
         .byte $AB, $30, $D3, $85, $AB, $30, $D3, $18, $5A, $85, $AD, $30, $D3, $19, $54
         .byte $2F, $30, $E2, $85, $AA, $30, $E2, $1A, $5A, $85, $AF, $30, $E2, $1B, $54
         .byte $2F, $98, $52, $4E, $C4, $0A, $80, $80, $12, $0A, $09, $29, $1A, $0A, $1A
         .byte $85, $18, $13, $09, $80, $12, $01, $0B, $31, $30, $61, $72, $0B, $04, $02
         .byte $03, $05, $03, $1B, $1A, $19, $0B, $09, $06, $0A, $00, $00, $1C, $17, $2F
         .byte $8F, $55, $53, $D2, $80, $A8, $30, $BC, $31, $2A, $31, $2A, $80, $A9, $2E
         .byte $2F, $A2, $12, $2F, $C1, $2F, $80, $A8, $30, $BC, $80, $A9, $2F, $83, $AC
         .byte $38, $BC, $0B, $2F, $80, $A8, $52, $2F, $84, $BD, $09, $02, $2F, $8E, $BC
         .byte $84, $BD, $09, $93, $2F, $84, $BE, $09, $05, $2F, $09, $91, $2F, $80, $BE
         .byte $84, $BD, $09, $06, $2F, $84, $BC, $09, $95, $2F, $09, $04, $2F, $00, $00
         .byte $00
;
; End of Tiny Basic
