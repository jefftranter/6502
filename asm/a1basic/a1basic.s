; Apple 1 BASIC
;
; Modifications to build with CC65 by Jeff Tranter <tranter@pobox.com>
;
; Apple 1 BASIC was written by Steve Wozniak
; Uses disassembly copyright 2003 Eric Smith <eric@brouhaha.com>
; http://www.brouhaha.com/~eric/retrocomputing/apple/apple1/basic/

Z1d     =       $1D
ch      =       $24     ; horizontal cursor location
var     =       $48
lomem   =       $4A     ; lower limit of memory used by BASIC (2 bytes)
himem   =       $4C     ; upper limit of memory used by BASIC (2 bytes)
rnd     =       $4E     ; random number (2 bytes)

; The noun stack and syntax stack appear to overlap, which is OK since
; they apparently are not used simultaneously.

; The noun stack size appears to be 32 entries, based on LDX #$20
; instruction at e67f.  However, there seems to be enough room for
; another 8 entries.  The noun stack builds down from noun_stk_<part>+$1f
; to noun_stk_<part>+$00, indexed by the X register.

; Noun stack usage appears to be:
;   integer:
;       (noun_stk_h_int,noun_stk_l) = value
;       noun_stk_h_str = 0
;   string:
;       (noun_stk_h_str,noun_stk_l) = pointer to string
;       noun_stk_h_int = any
; Since noun_stk_h_str determines whether stack entry is integer or string,
; strings can't start in zero page.

noun_stk_l =    $50
syn_stk_h =     $58     ; through $77
noun_stk_h_str = $78
syn_stk_l  =    $80     ; through $9F
noun_stk_h_int = $A0
txtndxstk  =    $A8     ; through $C7
text_index =    $C8     ; index into text being tokenized (in buffer at $0200)
leadbl  =       $C9     ; leading blanks
pp      =       $CA     ; pointer to end of program (2 bytes)
pv      =       $CC     ; pointer to end of variable storage (2 bytes)
acc     =       $CE     ; (2 bytes)
srch    =       $D0
tokndxstk =     $D1
srch2   =       $D2
if_flag =       $D4
cr_flag =       $D5
current_verb =  $D6
precedence =    $D7
x_save  =       $D8
run_flag =      $D9
aux     =       $DA
pline   =       $DC     ; pointer to current program line (2 bytes)
pverb   =       $E0     ; pointer to current verb (2 bytes)
p1      =       $E2
p2      =       $E4
p3      =       $E6
token_index =   $F1    ; pointer used to write tokens into buffer  2 bytes)
pcon    =       $F2    ; temp used in decimal output (2 bytes)
auto_inc =      $F4
auto_ln =       $F6
auto_flag =     $F8
char    =       $F9
leadzr  =       $FA
for_nest_count = $FB    ; count of active (nested) FOR loops
gosub_nest_count = $FC  ; count of active (nested) subroutines calls (GOSUB)
synstkdx =      $FD
synpag  =       $FE

; GOSUB stack, max eight entries
; note that the Apple II version has sixteen entries
gstk_pverbl     =       $0100    ; saved pverb
gstk_pverbh     =       $0108
gstk_plinel     =       $0110    ; saved pline
gstk_plineh     =       $0118

; FOR stack, max eight entries
; note that the Apple II version has sixteen entries
fstk_varl       =       $0120   ; pointer to index variable
fstk_varh       =       $0128
fstk_stepl      =       $0130   ; step value
fstk_steph      =       $0138
fstk_plinel     =       $0140   ; saved pline
fstk_plineh     =       $0148
fstk_pverbl     =       $0150   ; saved pverb
fstk_pverbh     =       $0158
fstk_tol        =       $0160   ; "to" (limit) value
fstk_toh        =       $0168
buffer  =       $0200
KBD     =       $D010
KBDCR   =       $D011
DSP     =       $D012

        .org    $E000
        .export START
START:  JMP     cold            ; BASIC cold start entry point

; Get character for keyboard, return in A.
rdkey:  LDA     KBDCR           ; Read control register
        BPL     rdkey           ; Loop if no key pressed
        LDA     KBD             ; Read key data
        RTS                     ; and return

Se00c:  TXA
        AND     #$20
        BEQ     Le034

Se011:  LDA     #$A0
        STA     p2
        JMP     cout

Se018:  LDA     #$20

Se01a:  CMP     ch
        BCS     nextbyte
        LDA     #$8D
        LDY     #$07
Le022:  JSR     cout
        LDA     #$A0
        DEY
        BNE     Le022

nextbyte:       LDY     #$00
        LDA     (p1),Y
        INC     p1
        BNE     Le034
        INC     p1+1
Le034:  RTS

; token $75 - "," in LIST command
list_comman:    JSR     get16bit
        JSR     find_line2
Le03b:  LDA     p1
        CMP     p3
        LDA     p1+1
        SBC     p3+1
        BCS     Le034
        JSR     list_line
        JMP     Le03b

; token $76 - LIST command w/ no args
list_all:       LDA     pp
        STA     p1
        LDA     pp+1
        STA     p1+1
        LDA     himem
        STA     p3
        LDA     himem+1
        STA     p3+1
        BNE     Le03b

; token $74 - LIST command w/ line number(s)
list_cmd:       JSR     get16bit
        JSR     find_line
        LDA     p2
        STA     p1
        LDA     p2+1
        STA     p1+1
        BCS     Le034

; list one program line
list_line:      STX     x_save
        LDA     #$A0
        STA     leadzr
        JSR     nextbyte
        TYA

; list an integer (line number or literal)
list_int:       STA     p2
        JSR     nextbyte
        TAX
        JSR     nextbyte
        JSR     prdec
Le083:  JSR     Se018
        STY     leadzr
        TAX
        BPL     list_token
        ASL
        BPL     list_int
        LDA     p2
        BNE     Le095
        JSR     Se011
Le095:  TXA
Le096:  JSR     cout
Le099:  LDA     #$25
        JSR     Se01a
        TAX
        BMI     Le096
        STA     p2

; list a single token
list_token:     CMP     #$01
        BNE     Le0ac
        LDX     x_save
        JMP     crout
Le0ac:  PHA
        STY     acc
        LDX     #$ED
        STX     acc+1
        CMP     #$51
        BCC     Le0bb
        DEC     acc+1
        SBC     #$50
Le0bb:  PHA
        LDA     (acc),Y
Le0be:  TAX
        DEY
        LDA     (acc),Y
        BPL     Le0be
        CPX     #$C0
        BCS     Le0cc
        CPX     #$00
        BMI     Le0be
Le0cc:  TAX
        PLA
        SBC     #$01
        BNE     Le0bb
        BIT     p2
        BMI     Le0d9
        JSR     Seff8
Le0d9:  LDA     (acc),Y
        BPL     Le0ed
        TAX
        AND     #$3F
        STA     p2
        CLC
        ADC     #$A0
        JSR     cout
        DEY
        CPX     #$C0
        BCC     Le0d9
Le0ed:  JSR     Se00c
        PLA
        CMP     #$5D
        BEQ     Le099
        CMP     #$28
        BNE     Le083
        BEQ     Le099

; token $2A - left paren for substring like A$(3,5)
paren_substr:   JSR     Se118
        STA     noun_stk_l,X
        CMP     noun_stk_h_str,X
Le102:  BCC     Le115
string_err:     LDY     #$2B
go_errmess_1:   JMP     print_err_msg

; token $2B - comma for substring like A$(3,5)
comma_substr:   JSR     getbyte
        CMP     noun_stk_l,X
        BCC     string_err
        JSR     Sefe4
        STA     noun_stk_h_str,X
Le115:  JMP     left_paren

Se118:  JSR     getbyte
        BEQ     string_err
        SEC
        SBC     #$01
        RTS

; token $42 - left paren for string array as dest
; A$(1)="FOO"
str_arr_dest:   JSR     Se118
        STA     noun_stk_l,X
        CLC
        SBC     noun_stk_h_str,X
        JMP     Le102
Le12c:  LDY     #$14
        BNE     go_errmess_1

; token $43 - comma, next var in DIM statement is string
; token $4E - "DIM", next var in DIM is string
dim_str:        JSR     Se118
        INX
Le134:  LDA     noun_stk_l,X
        STA     aux
        ADC     acc
        PHA
        TAY
        LDA     noun_stk_h_str,X
        STA     aux+1
        ADC     acc+1
        PHA
        CPY     pp
        SBC     pp+1
        BCS     Le12c
        LDA     aux
        ADC     #$FE
        STA     aux
        LDA     #$FF
        TAY
        ADC     aux+1
        STA     aux+1
Le156:  INY
        LDA     (aux),Y
        CMP     pv,Y
        BNE     Le16d
        TYA
        BEQ     Le156
Le161:  PLA
        STA     (aux),Y
        STA     pv,Y
        DEY
        BPL     Le161
        INX
        RTS
        NOP
Le16d:  LDY     #$80
Le16f:  BNE     go_errmess_1

; token ???
input_str:      LDA     #$00
        JSR     push_a_noun_stk
        LDY     #$02
        STY     noun_stk_h_str,X
        JSR     push_a_noun_stk
        LDA     #$BF                    ; '?'
        JSR     cout
        LDY     #$00
        JSR     read_line
        STY     noun_stk_h_str,X
        NOP
        NOP
        NOP

; token $70 - string literal
string_lit:     LDA     noun_stk_l+1,X
        STA     acc
        LDA     noun_stk_h_str+1,X
        STA     acc+1
        INX
        INX
        JSR     Se1bc
Le199:  LDA     rnd,X
        CMP     syn_stk_h+30,X
        BCS     Le1b4
        INC     rnd,X
        TAY
        LDA     (acc),Y
        LDY     noun_stk_l,X
        CPY     p2
        BCC     Le1ae
        LDY     #$83
        BNE     Le16f
Le1ae:  STA     (aux),Y
        INC     noun_stk_l,X
        BCC     Le199
Le1b4:  LDY     noun_stk_l,X
        TXA
        STA     (aux),Y
        INX
        INX
        RTS

Se1bc:  LDA     noun_stk_l+1,X
        STA     aux
        SEC
        SBC     #$02
        STA     p2
        LDA     noun_stk_h_str+1,X
        STA     aux+1
        SBC     #$00
        STA     p2+1
        LDY     #$00
        LDA     (p2),Y
        CLC
        SBC     aux
        STA     p2
        RTS

; token $39 - "=" for string equality operator
string_eq:      LDA     noun_stk_l+3,X
        STA     acc
        LDA     noun_stk_h_str+3,X
        STA     acc+1
        LDA     noun_stk_l+1,X
        STA     aux
        LDA     noun_stk_h_str+1,X
        STA     aux+1
        INX
        INX
        INX
        LDY     #$00
        STY     noun_stk_h_str,X
        STY     noun_stk_h_int,X
        INY
        STY     noun_stk_l,X
Le1f3:  LDA     himem+1,X
        CMP     syn_stk_h+29,X
        PHP
        PHA
        LDA     rnd+1,X
        CMP     syn_stk_h+31,X
        BCC     Le206
        PLA
        PLP
        BCS     Le205
Le203:  LSR     noun_stk_l,X
Le205:  RTS
Le206:  TAY
        LDA     (acc),Y
        STA     p2
        PLA
        TAY
        PLP
        BCS     Le203
        LDA     (aux),Y
        CMP     p2
        BNE     Le203
        INC     rnd+1,X
        INC     himem+1,X
        BCS     Le1f3

; token $3A - "#" for string inequality operator
string_neq:     JSR     string_eq
        JMP     not_op

; token $14 - "*" for numeric multiplication
mult_op:        JSR     Se254
Le225:  ASL     acc
        ROL     acc+1
        BCC     Le238
        CLC
        LDA     p3
        ADC     aux
        STA     p3
        LDA     p3+1
        ADC     aux+1
        STA     p3+1
Le238:  DEY
        BEQ     Le244
        ASL     p3
        ROL     p3+1
        BPL     Le225
        JMP     Le77e
Le244:  LDA     p3
        JSR     push_ya_noun_stk
        LDA     p3+1
        STA     noun_stk_h_int,X
        ASL     p2+1
        BCC     Le279
        JMP     negate

Se254:  LDA     #$55
        STA     p2+1
        JSR     Se25b

Se25b:  LDA     acc
        STA     aux
        LDA     acc+1
        STA     aux+1
        JSR     get16bit
        STY     p3
        STY     p3+1
        LDA     acc+1
        BPL     Le277
        DEX
        ASL     p2+1
        JSR     negate
        JSR     get16bit
Le277:  LDY     #$10
Le279:  RTS

; token $1f - "MOD"
mod_op: JSR     See6c
        BEQ     Le244
        .byte   $FF
Le280:  CMP     #$84
        BNE     Le286
        LSR     auto_flag
Le286:  CMP     #$DF
        BEQ     Le29b
        CMP     #$9B
        BEQ     Le294
        STA     buffer,Y
        INY
        BPL     read_line
Le294:  LDY     #$8B
        JSR     Se3c4

Se299:  LDY     #$01
Le29b:  DEY
        BMI     Le294

; read a line from keyboard (using rdkey) into buffer
read_line:      JSR     rdkey
        NOP
        NOP
        JSR     cout
        CMP     #$8D
        BNE     Le280
        LDA     #$DF
        STA     buffer,Y
        RTS
cold:   JSR     mem_init_4k
        .export warm
warm:   JSR     crout           ; BASIC warm start entry point
Le2b6:  LSR     run_flag
        LDA     #'>'+$80        ; Prompt character (high bit set)
        JSR     cout
        LDY     #$00
        STY     leadzr
        BIT     auto_flag
        BPL     Le2d1
        LDX     auto_ln
        LDA     auto_ln+1
        JSR     prdec
        LDA     #$A0
        JSR     cout
Le2d1:  LDX     #$FF
        TXS
        JSR     read_line
        STY     token_index
        TXA
        STA     text_index
        LDX     #$20
        JSR     Se491
        LDA     text_index
        ADC     #$00
        STA     pverb
        LDA     #$00
        TAX
        ADC     #$02
        STA     pverb+1
        LDA     (pverb,X)
        AND     #$F0
        CMP     #$B0
        BEQ     Le2f9
        JMP     Le883
Le2f9:  LDY     #$02
Le2fb:  LDA     (pverb),Y
        STA     pv+1,Y
        DEY
        BNE     Le2fb
        JSR     Se38a
        LDA     token_index
        SBC     text_index
        CMP     #$04
        BEQ     Le2b6
        STA     (pverb),Y
        LDA     pp
        SBC     (pverb),Y
        STA     p2
        LDA     pp+1
        SBC     #$00
        STA     p2+1
        LDA     p2
        CMP     pv
        LDA     p2+1
        SBC     pv+1
        BCC     Le36b
Le326:  LDA     pp
        SBC     (pverb),Y
        STA     p3
        LDA     pp+1
        SBC     #$00
        STA     p3+1
        LDA     (pp),Y
        STA     (p3),Y
        INC     pp
        BNE     Le33c
        INC     pp+1
Le33c:  LDA     p1
        CMP     pp
        LDA     p1+1
        SBC     pp+1
        BCS     Le326
Le346:  LDA     p2,X
        STA     pp,X
        DEX
        BPL     Le346
        LDA     (pverb),Y
        TAY
Le350:  DEY
        LDA     (pverb),Y
        STA     (p3),Y
        TYA
        BNE     Le350
        BIT     auto_flag
        BPL     Le365
Le35c:  LDA     auto_ln+1,X
        ADC     auto_inc+1,X
        STA     auto_ln+1,X
        INX
        BEQ     Le35c
Le365:  BPL     Le3e5
        .byte   $00,$00,$00,$00
Le36b:  LDY     #$14
        BNE     print_err_msg

; token $0a - "," in DEL command
del_comma:      JSR     get16bit
        LDA     p1
        STA     p3
        LDA     p1+1
        STA     p3+1
        JSR     find_line1
        LDA     p1
        STA     p2
        LDA     p1+1
        STA     p2+1
        BNE     Le395

; token $09 - "DEL"
del_cmd:        JSR     get16bit

Se38a:  JSR     find_line
        LDA     p3
        STA     p1
        LDA     p3+1
        STA     p1+1
Le395:  LDY     #$00
Le397:  LDA     pp
        CMP     p2
        LDA     pp+1
        SBC     p2+1
        BCS     Le3b7
        LDA     p2
        BNE     Le3a7
        DEC     p2+1
Le3a7:  DEC     p2
        LDA     p3
        BNE     Le3af
        DEC     p3+1
Le3af:  DEC     p3
        LDA     (p2),Y
        STA     (p3),Y
        BCC     Le397
Le3b7:  LDA     p3
        STA     pp
        LDA     p3+1
        STA     pp+1
        RTS
Le3c0:  JSR     cout
        INY

Se3c4:  LDA     error_msg_tbl,Y
        BMI     Le3c0

cout:   CMP     #$8D
        BNE     Le3d3

crout:  LDA     #$00            ; character output
        STA     ch
        LDA     #$8D
Le3d3:  INC     ch

; Send character to display. Char is in A.
Le3d5:  BIT     DSP          ; See if display ready
        BMI     Le3d5        ; Loop if not
        STA     DSP          ; Write display data
        RTS                  ; and return

too_long_err:   LDY     #$06

print_err_msg:  JSR     print_err_msg1  ; print error message specified in Y
        BIT     run_flag
Le3e5:  BMI     Le3ea
        JMP     Le2b6
Le3ea:  JMP     Leb9a
Le3ed:  ROL
        ADC     #$A0
        CMP     buffer,X
        BNE     Le448
        LDA     (synpag),Y
        ASL
        BMI     Le400
        DEY
        LDA     (synpag),Y
        BMI     Le428
        INY
Le400:  STX     text_index
        TYA
        PHA
        LDX     #$00
        LDA     (synpag,X)
        TAX
Le409:  LSR
        EOR     #$48
        ORA     (synpag),Y
        CMP     #$C0
        BCC     Le413
        INX
Le413:  INY
        BNE     Le409
        PLA
        TAY
        TXA
        JMP     Le4c0

; write a token to the buffer
; buffer [++tokndx] = A
put_token:      INC     token_index
        LDX     token_index
        BEQ     too_long_err
        STA     buffer,X
Le425:  RTS
Le426:  LDX     text_index
Le428:  LDA     #$A0
Le42a:  INX
        CMP     buffer,X
        BCS     Le42a
        LDA     (synpag),Y
        AND     #$3F
        LSR
        BNE     Le3ed
        LDA     buffer,X
        BCS     Le442
        ADC     #$3F
        CMP     #$1A
        BCC     Le4b1
Le442:  ADC     #$4F
        CMP     #$0A
        BCC     Le4b1
Le448:  LDX     synstkdx
Le44a:  INY
        LDA     (synpag),Y
        AND     #$E0
        CMP     #$20
        BEQ     Le4cd
        LDA     txtndxstk,X
        STA     text_index
        LDA     tokndxstk,X
        STA     token_index
Le45b:  DEY
        LDA     (synpag),Y
        ASL
        BPL     Le45b
        DEY
        BCS     Le49c
        ASL
        BMI     Le49c
        LDY     syn_stk_h,X
        STY     synpag+1
        LDY     syn_stk_l,X
        INX
        BPL     Le44a
Le470:  BEQ     Le425
        CMP     #$7E
        BCS     Le498
        DEX
        BPL     Le47d
        LDY     #$06
        BPL     go_errmess_2
Le47d:  STY     syn_stk_l,X
        LDY     synpag+1
        STY     syn_stk_h,X
        LDY     text_index
        STY     txtndxstk,X
        LDY     token_index
        STY     tokndxstk,X
        AND     #$1F
        TAY
        LDA     syntabl_index,Y

Se491:  ASL
        TAY
        LDA     #$76
        ROL
        STA     synpag+1
Le498:  BNE     Le49b
        INY
Le49b:  INY
Le49c:  STX     synstkdx
        LDA     (synpag),Y
        BMI     Le426
        BNE     Le4a9
        LDY     #$0E
go_errmess_2:   JMP     print_err_msg
Le4a9:  CMP     #$03
        BCS     Le470
        LSR
        LDX     text_index
        INX
Le4b1:  LDA     buffer,X
        BCC     Le4ba
        CMP     #$A2
        BEQ     Le4c4
Le4ba:  CMP     #$DF
        BEQ     Le4c4
        STX     text_index
Le4c0:  JSR     put_token
        INY
Le4c4:  DEY
        LDX     synstkdx
Le4c7:  LDA     (synpag),Y
        DEY
        ASL
        BPL     Le49c
Le4cd:  LDY     syn_stk_h,X
        STY     synpag+1
        LDY     syn_stk_l,X
        INX
        LDA     (synpag),Y
        AND     #$9F
        BNE     Le4c7
        STA     pcon
        STA     pcon+1
        TYA
        PHA
        STX     synstkdx
        LDY     srch,X
        STY     leadbl
        CLC
Le4e7:  LDA     #$0A
        STA     char
        LDX     #$00
        INY
        LDA     buffer,Y
        AND     #$0F
Le4f3:  ADC     pcon
        PHA
        TXA
        ADC     pcon+1
        BMI     Le517
        TAX
        PLA
        DEC     char
        BNE     Le4f3
        STA     pcon
        STX     pcon+1
        CPY     token_index
        BNE     Le4e7
        LDY     leadbl
        INY
        STY     token_index
        JSR     put_token
        PLA
        TAY
        LDA     pcon+1
        BCS     Le4c0
Le517:  LDY     #$00
        BPL     go_errmess_2

prdec:  STA     pcon+1  ; output A:X in decimal
        STX     pcon
        LDX     #$04
        STX     leadbl
Le523:  LDA     #$B0
        STA     char
Le527:  LDA     pcon
        CMP     dectabl,X
        LDA     pcon+1
        SBC     dectabh,X
        BCC     Le540
        STA     pcon+1
        LDA     pcon
        SBC     dectabl,X
        STA     pcon
        INC     char
        BNE     Le527
Le540:  LDA     char
        INX
        DEX
        BEQ     Le554
        CMP     #$B0
        BEQ     Le54c
        STA     leadbl
Le54c:  BIT     leadbl
        BMI     Le554
        LDA     leadzr
        BEQ     Le55f
Le554:  JSR     cout
        BIT     auto_flag
        BPL     Le55f
        STA     buffer,Y
        INY
Le55f:  DEX
        BPL     Le523
        RTS
; powers of 10 table, low byte
dectabl:        .byte   $01,$0A,$64,$E8,$10             ; "..dh."

; powers of 10 table, high byte
dectabh:        .byte   $00,$00,$00,$03,$27             ; "....'"

find_line:      LDA     pp
        STA     p3
        LDA     pp+1
        STA     p3+1

find_line1:     INX

find_line2:     LDA     p3+1
        STA     p2+1
        LDA     p3
        STA     p2
        CMP     himem
        LDA     p2+1
        SBC     himem+1
        BCS     Le5ac
        LDY     #$01
        LDA     (p2),Y
        SBC     acc
        INY
        LDA     (p2),Y
        SBC     acc+1
        BCS     Le5ac
        LDY     #$00
        LDA     p3
        ADC     (p2),Y
        STA     p3
        BCC     Le5a0
        INC     p3+1
        CLC
Le5a0:  INY
        LDA     acc
        SBC     (p2),Y
        INY
        LDA     acc+1
        SBC     (p2),Y
        BCS     find_line2
Le5ac:  RTS

; token $0B - "NEW"
new_cmd:        LSR     auto_flag
        LDA     himem
        STA     pp
        LDA     himem+1
        STA     pp+1

; token $0C - "CLR"
clr:    LDA     lomem
        STA     pv
        LDA     lomem+1
        STA     pv+1
        LDA     #$00
        STA     for_nest_count
        STA     gosub_nest_count
        STA     synpag
        LDA     #$00
        STA     Z1d
        RTS
Le5cc:  LDA     srch
        ADC     #$05
        STA     srch2
        LDA     tokndxstk
        ADC     #$00
        STA     srch2+1
        LDA     srch2
        CMP     pp
        LDA     srch2+1
        SBC     pp+1
        BCC     Le5e5
        JMP     Le36b
Le5e5:  LDA     acc
        STA     (srch),Y
        LDA     acc+1
        INY
        STA     (srch),Y
        LDA     srch2
        INY
        STA     (srch),Y
        LDA     srch2+1
        INY
        STA     (srch),Y
        LDA     #$00
        INY
        STA     (srch),Y
        INY
        STA     (srch),Y
        LDA     srch2
        STA     pv
        LDA     srch2+1
        STA     pv+1
        LDA     srch
        BCC     Le64f
execute_var:    STA     acc
        STY     acc+1
        JSR     get_next_prog_byte
        BMI     Le623
        CMP     #$40
        BEQ     Le623
        JMP     Le628
        .byte   $06,$C9,$49,$D0,$07,$A9,$49   
Le623:  STA     acc+1
        JSR     get_next_prog_byte
Le628:  LDA     lomem+1
        STA     tokndxstk
        LDA     lomem
Le62e:  STA     srch
        CMP     pv
        LDA     tokndxstk
        SBC     pv+1
        BCS     Le5cc
        LDA     (srch),Y
        INY
        CMP     acc
        BNE     Le645
        LDA     (srch),Y
        CMP     acc+1
        BEQ     Le653
Le645:  INY
        LDA     (srch),Y
        PHA
        INY
        LDA     (srch),Y
        STA     tokndxstk
        PLA
Le64f:  LDY     #$00
        BEQ     Le62e
Le653:  LDA     srch
        ADC     #$03
        JSR     push_a_noun_stk
        LDA     tokndxstk
        ADC     #$00
        STA     noun_stk_h_str,X
        LDA     acc+1
        CMP     #$40
        BNE     fetch_prog_byte
        DEY
        TYA
        JSR     push_a_noun_stk
        DEY
        STY     noun_stk_h_str,X
        LDY     #$03
Le670:  INC     noun_stk_h_str,X
        INY
        LDA     (srch),Y
        BMI     Le670
        BPL     fetch_prog_byte

execute_stmt:   LDA     #$00
        STA     if_flag
        STA     cr_flag
        LDX     #$20

; push old verb on stack for later use in precedence test
push_old_verb:  PHA
fetch_prog_byte:        LDY     #$00
        LDA     (pverb),Y
Le686:  BPL     execute_token
        ASL
        BMI     execute_var
        JSR     get_next_prog_byte
        JSR     push_ya_noun_stk
        JSR     get_next_prog_byte
        STA     noun_stk_h_int,X
Le696:  BIT     if_flag
        BPL     Le69b
        DEX
Le69b:  JSR     get_next_prog_byte
        BCS     Le686

execute_token:  CMP     #$28
        BNE     execute_verb
        LDA     pverb
        JSR     push_a_noun_stk
        LDA     pverb+1
        STA     noun_stk_h_str,X
        BIT     if_flag
        BMI     Le6bc
        LDA     #$01
        JSR     push_a_noun_stk
        LDA     #$00
        STA     noun_stk_h_str,X
Le6ba:  INC     noun_stk_h_str,X
Le6bc:  JSR     get_next_prog_byte
        BMI     Le6ba
        BCS     Le696
execute_verb:   BIT     if_flag
        BPL     Le6cd
        CMP     #$04
        BCS     Le69b
        LSR     if_flag
Le6cd:  TAY
        STA     current_verb
        LDA     verb_prec_tbl,Y
        AND     #$55
        ASL
        STA     precedence
Le6d8:  PLA
        TAY
        LDA     verb_prec_tbl,Y
        AND     #$AA
        CMP     precedence
        BCS     do_verb
        TYA
        PHA
        JSR     get_next_prog_byte
        LDA     current_verb
        BCC     push_old_verb
do_verb:        LDA     verb_adr_l,Y
        STA     acc
        LDA     verb_adr_h,Y
        STA     acc+1
        JSR     Se6fc
        JMP     Le6d8

Se6fc:  JMP     (acc)

get_next_prog_byte:     INC     pverb
        BNE     Le705
        INC     pverb+1
Le705:  LDA     (pverb),Y
        RTS

push_ya_noun_stk:       STY     syn_stk_h+31,X

push_a_noun_stk:        DEX
        BMI     Le710
        STA     noun_stk_l,X
        RTS
Le710:  LDY     #$66
go_errmess_3:   JMP     print_err_msg

get16bit:       LDY     #$00
        LDA     noun_stk_l,X
        STA     acc
        LDA     noun_stk_h_int,X
        STA     acc+1
        LDA     noun_stk_h_str,X
        BEQ     Le731
        STA     acc+1
        LDA     (acc),Y
        PHA
        INY
        LDA     (acc),Y
        STA     acc+1
        PLA
        STA     acc
        DEY
Le731:  INX
        RTS

; token $16 - "=" for numeric equality operator
eq_op:  JSR     neq_op

; token $37 - "NOT"
not_op: JSR     get16bit
        TYA
        JSR     push_ya_noun_stk
        STA     noun_stk_h_int,X
        CMP     acc
        BNE     Le749
        CMP     acc+1
        BNE     Le749
        INC     noun_stk_l,X
Le749:  RTS

; token $17 - "#" for numeric inequality operator
; token $1B - "<>" for numeric inequality operator
neq_op: JSR     subtract
        JSR     sgn_fn

; token $31 - "ABS"
abs_fn: JSR     get16bit
        BIT     acc+1
        BMI     Se772
Le757:  DEX
Le758:  RTS

; token $30 - "SGN"
sgn_fn: JSR     get16bit
        LDA     acc+1
        BNE     Le764
        LDA     acc
        BEQ     Le757
Le764:  LDA     #$FF
        JSR     push_ya_noun_stk
        STA     noun_stk_h_int,X
        BIT     acc+1
        BMI     Le758

; token $36 - "-" for unary negation
negate: JSR     get16bit

Se772:  TYA
        SEC
        SBC     acc
        JSR     push_ya_noun_stk
        TYA
        SBC     acc+1
        BVC     Le7a1
Le77e:  LDY     #$00
        BPL     go_errmess_3

; token $13 - "-" for numeric subtraction
subtract:       JSR     negate

; token $12 - "+" for numeric addition
add:    JSR     get16bit
        LDA     acc
        STA     aux
        LDA     acc+1
        STA     aux+1
        JSR     get16bit

Se793:  CLC
        LDA     acc
        ADC     aux
        JSR     push_ya_noun_stk
        LDA     acc+1
        ADC     aux+1
        BVS     Le77e
Le7a1:  STA     noun_stk_h_int,X

; token $35 - "+" for unary positive
unary_pos:      RTS

; token $50 - "TAB" function
tab_fn: JSR     get16bit
        LDY     acc
        BEQ     Le7b0
        DEY
        LDA     acc+1
        BEQ     Le7bc
Le7b0:  RTS

; horizontal tab
tabout: LDA     ch
        ORA     #$07
        TAY
        INY
Le7b7:  LDA     #$A0
        JSR     cout
Le7bc:  CPY     ch
        BCS     Le7b7
        RTS

; token $49 - "," in print, numeric follows
print_com_num:  JSR     tabout

; token $62 - "PRINT" numeric
print_num:      JSR     get16bit
        LDA     acc+1
        BPL     Le7d5
        LDA     #$AD
        JSR     cout
        JSR     Se772
        BVC     print_num
Le7d5:  DEY
        STY     cr_flag
        STX     acc+1
        LDX     acc
        JSR     prdec
        LDX     acc+1
        RTS

; token $0D - "AUTO" command
auto_cmd:       JSR     get16bit
        LDA     acc
        STA     auto_ln
        LDA     acc+1
        STA     auto_ln+1
        DEY
        STY     auto_flag
        INY
        LDA     #$0A
Le7f3:  STA     auto_inc
        STY     auto_inc+1
        RTS

; token $0E - "," in AUTO command
auto_com:       JSR     get16bit
        LDA     acc
        LDY     acc+1
        BPL     Le7f3

; token $56 - "=" in FOR statement
; token $71 - "=" in LET (or implied LET) statement
var_assign:     JSR     get16bit
        LDA     noun_stk_l,X
        STA     aux
        LDA     noun_stk_h_str,X
        STA     aux+1
        LDA     acc
        STA     (aux),Y
        INY
        LDA     acc+1
        STA     (aux),Y
        INX

Te816:  RTS

; token $00 - begining of line
begin_line:
        PLA
        PLA

; token $03 - ":" statement separator
colon:  BIT     cr_flag
        BPL     Le822

; token $63 - "PRINT" with no arg
print_cr:       JSR     crout

; token $47 - ";" at end of print statement
print_semi:     LSR     cr_flag
Le822:  RTS


; token $22 - "(" in string DIM
; token $34 - "(" in numeric DIM
; token $38 - "(" in numeric expression
; token $3F - "(" in some PEEK, RND, SGN, ABS (PDL)
left_paren:     LDY     #$FF
        STY     precedence

; token $72 - ")" everywhere
right_paren:    RTS

; token $60 - "IF" statement
if_stmt:        JSR     Sefcd
        BEQ     Le834
        LDA     #$25
        STA     current_verb
        DEY
        STY     if_flag
Le834:  INX
        RTS
; RUN without CLR, used by Apple DOS
run_warm:       LDA     pp
        LDY     pp+1
        BNE     Le896

; token $5C - "GOSUB" statement
gosub_stmt:     LDY     #$41
        LDA     gosub_nest_count
        CMP     #$08
        BCS     go_errmess_4
        TAY
        INC     gosub_nest_count
        LDA     pverb
        STA     gstk_pverbl,Y
        LDA     pverb+1
        STA     gstk_pverbh,Y
        LDA     pline
        STA     gstk_plinel,Y
        LDA     pline+1
        STA     gstk_plineh,Y

; token $24 - "THEN"
; token $5F - "GOTO" statement
goto_stmt:      JSR     get16bit
        JSR     find_line
        BCC     Le867
        LDY     #$37
        BNE     go_errmess_4
Le867:  LDA     p2
        LDY     p2+1

; loop to run a program
run_loop:       STA     pline
        STY     pline+1
        BIT     KBDCR
        BMI     Le8c3
        CLC
        ADC     #$03
        BCC     Le87a
        INY
Le87a:  LDX     #$FF
        STX     run_flag
        TXS
        STA     pverb
        STY     pverb+1
Le883:  JSR     execute_stmt
        BIT     run_flag
        BPL     end_stmt
        CLC
        LDY     #$00
        LDA     pline
        ADC     (pline),Y
        LDY     pline+1
        BCC     Le896
        INY
Le896:  CMP     himem
        BNE     run_loop
        CPY     himem+1
        BNE     run_loop
        LDY     #$34
        LSR     run_flag
go_errmess_4:   JMP     print_err_msg

; token $5B - "RETURN" statement
return_stmt:    LDY     #$4A
        LDA     gosub_nest_count
        BEQ     go_errmess_4
        DEC     gosub_nest_count
        TAY
        LDA     gstk_plinel-1,Y
        STA     pline
        LDA     gstk_plineh-1,Y
        STA     pline+1
        LDX     a:synpag+1,Y            ; force absolute addressing mode
        LDA     gstk_pverbh-1,Y
Le8be:  TAY
        TXA
        JMP     Le87a
Le8c3:  LDY     #$63
        JSR     Se3c4
        LDY     #$01
        LDA     (pline),Y
        TAX
        INY
        LDA     (pline),Y
        JSR     prdec

; token $51 - "END" statement
end_stmt:       JMP     warm
Le8d6:  DEC     for_nest_count

; token $59 - "NEXT" statement
; token $5A - "," in NEXT statement
next_stmt:      LDY     #$5B
        LDA     for_nest_count
Le8dc:  BEQ     go_errmess_4
        TAY
        LDA     noun_stk_l,X
        CMP     fstk_varl-1,Y
        BNE     Le8d6
        LDA     noun_stk_h_str,X
        CMP     fstk_varh-1,Y
        BNE     Le8d6
        LDA     fstk_stepl-1,Y
        STA     aux
        LDA     fstk_steph-1,Y
        STA     aux+1
        JSR     get16bit
        DEX
        JSR     Se793
        JSR     var_assign
        DEX
        LDY     for_nest_count
        LDA     fstk_toh-1,Y
        STA     syn_stk_l+31,X
        LDA     fstk_tol-1,Y
        LDY     #$00
        JSR     push_ya_noun_stk
        JSR     subtract
        JSR     sgn_fn
        JSR     get16bit
        LDY     for_nest_count
        LDA     acc
        BEQ     Le925
        EOR     fstk_steph-1,Y
        BPL     Le937
Le925:  LDA     fstk_plinel-1,Y
        STA     pline
        LDA     fstk_plineh-1,Y
        STA     pline+1
        LDX     fstk_pverbl-1,Y
        LDA     fstk_pverbh-1,Y
        BNE     Le8be
Le937:  DEC     for_nest_count
        RTS

; token $55 - "FOR" statement
for_stmt:       LDY     #$54
        LDA     for_nest_count
        CMP     #$08
        BEQ     Le8dc
        INC     for_nest_count
        TAY
        LDA     noun_stk_l,X
        STA     fstk_varl,Y
        LDA     noun_stk_h_str,X
        STA     fstk_varh,Y
        RTS

; token $57 - "TO"
to_clause:      JSR     get16bit
        LDY     for_nest_count
        LDA     acc
        STA     fstk_tol-1,Y
        LDA     acc+1
        STA     fstk_toh-1,Y
        LDA     #$01
        STA     fstk_stepl-1,Y
        LDA     #$00
Le966:  STA     fstk_steph-1,Y
        LDA     pline
        STA     fstk_plinel-1,Y
        LDA     pline+1
        STA     fstk_plineh-1,Y
        LDA     pverb
        STA     fstk_pverbl-1,Y
        LDA     pverb+1
        STA     fstk_pverbh-1,Y
        RTS

Te97e:  JSR     get16bit
        LDY     for_nest_count
        LDA     acc
        STA     fstk_stepl-1,Y
        LDA     acc+1
        JMP     Le966
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; "........"
        .byte   $00,$00,$00                     ; "..."

; verb precedence
; (verb_prec[token]&0xAA)>>1 for left (?)
; verb_prec[token]&0x55 for right (?)
verb_prec_tbl:
        .byte   $00,$00,$00,$AB,$03,$03,$03,$03 ; "...+...."
        .byte   $03,$03,$03,$03,$03,$03,$03,$03 ; "........"
        .byte   $03,$03,$3F,$3F,$C0,$C0,$3C,$3C ; "..??@@<<"
        .byte   $3C,$3C,$3C,$3C,$3C,$30,$0F,$C0 ; "<<<<<0.@"
        .byte   $CC,$FF,$55,$00,$AB,$AB,$03,$03 ; "L.U.++.."
        .byte   $FF,$FF,$55,$FF,$FF,$55,$CF,$CF ; "..U..UOO"
        .byte   $CF,$CF,$CF,$FF,$55,$C3,$C3,$C3 ; "OOO.UCCC"
        .byte   $55,$F0,$F0,$CF,$56,$56,$56,$55 ; "UppOVVVU"
        .byte   $FF,$FF,$55,$03,$03,$03,$03,$03 ; "..U....."
        .byte   $03,$03,$FF,$FF,$FF,$03,$03,$03 ; "........"
        .byte   $03,$03,$03,$03,$03,$03,$03,$03 ; "........"
        .byte   $03,$03,$03,$03,$03,$00,$AB,$03 ; "......+."
        .byte   $57,$03,$03,$03,$03,$07,$03,$03 ; "W......."
        .byte   $03,$03,$03,$03,$03,$03,$03,$03 ; "........"
        .byte   $03,$03,$AA,$FF,$FF,$FF,$FF,$FF ; "..*....."
verb_adr_l:
        .byte   $17,$FF,$FF,$19,$5D,$35,$4B,$F2 ; "....]5Kr"
        .byte   $EC,$87,$6F,$AD,$B7,$E2,$F8,$54 ; "l.o-7bxT"
        .byte   $80,$96,$85,$82,$22,$10,$33,$4A ; "....".3J"
        .byte   $13,$06,$0B,$4A,$01,$40,$47,$7A ; "...J.@Gz"
        .byte   $00,$FF,$23,$09,$5B,$16,$B6,$CB ; "..#.[.6K"
        .byte   $FF,$FF,$FB,$FF,$FF,$24,$F6,$4E ; "..{..$vN"
        .byte   $59,$50,$00,$FF,$23,$A3,$6F,$36 ; "YP..##o6"
        .byte   $23,$D7,$1C,$22,$C2,$AE,$BA,$23 ; "#W."B.:#"
        .byte   $FF,$FF,$21,$30,$1E,$03,$C4,$20 ; "..!0..D "
        .byte   $00,$C1,$FF,$FF,$FF,$A0,$30,$1E ; ".A... 0."
        .byte   $A4,$D3,$B6,$BC,$AA,$3A,$01,$50 ; "$S6<*:.P"
        .byte   $7E,$D8,$D8,$A5,$3C,$FF,$16,$5B ; "~XX%<..["
        .byte   $28,$03,$C4,$1D,$00,$0C,$4E,$00 ; "(.D...N."
        .byte   $3E,$00,$A6,$B0,$00,$BC,$C6,$57 ; ">.&0.<FW"
        .byte   $8C,$01,$27,$FF,$FF,$FF,$FF,$FF ; "..'....."
verb_adr_h:
        .byte   $E8,$FF,$FF,$E8,$E0,$E0,$E0,$EF ; "h..h```o"
        .byte   $EF,$E3,$E3,$E5,$E5,$E7,$E7,$EE ; "occeeggn"
        .byte   $EF,$EF,$E7,$E7,$E2,$EF,$E7,$E7 ; "ooggbogg"
        .byte   $EC,$EC,$EC,$E7,$EC,$EC,$EC,$E2 ; "lllglllb"
        .byte   $00,$FF,$E8,$E1,$E8,$E8,$EF,$EB ; "..hahhok"
        .byte   $FF,$FF,$E0,$FF,$FF,$EF,$EE,$EF ; "..`..ono"
        .byte   $E7,$E7,$00,$FF,$E8,$E7,$E7,$E7 ; "gg..hggg"
        .byte   $E8,$E1,$E2,$EE,$EE,$EE,$EE,$E8 ; "habnnnnh"
        .byte   $FF,$FF,$E1,$E1,$EF,$EE,$E7,$E8 ; "..aaongh"
        .byte   $EE,$E7,$FF,$FF,$FF,$EE,$E1,$EF ; "ng...nao"
        .byte   $E7,$E8,$EF,$EF,$EB,$E9,$E8,$E9 ; "ghookihi"
        .byte   $E9,$E8,$E8,$E8,$E8,$FF,$E8,$E8 ; "ihhhh.hh"
        .byte   $E8,$EE,$E7,$E8,$EF,$EF,$EE,$EF ; "hnghoono"
        .byte   $EE,$EF,$EE,$EE,$EF,$EE,$EE,$EE ; "nonnonnn"
        .byte   $E1,$E8,$E8,$FF,$FF,$FF,$FF,$FF ; "ahh....."

; Error message strings. Last character has high bit unset.
error_msg_tbl:
        .byte   $BE,$B3,$B2,$B7,$B6,$37         ; ">32767"
        .byte   $D4,$CF,$CF,$A0,$CC,$CF,$CE,$47 ; "TOO LONG"
        .byte   $D3,$D9,$CE,$D4,$C1,$58         ; "SYNTAX"
        .byte   $CD,$C5,$CD,$A0,$C6,$D5,$CC,$4C ; "MEM FULL"
        .byte   $D4,$CF,$CF,$A0,$CD,$C1,$CE,$D9,$A0,$D0,$C1,$D2,$C5,$CE,$53 ; "TOO MANY PARENS"
        .byte   $D3,$D4,$D2,$C9,$CE,$47         ; "STRING"
        .byte   $CE,$CF,$A0,$C5,$CE,$44         ; "NO END"
        .byte   $C2,$C1,$C4,$A0,$C2,$D2,$C1,$CE,$C3,$48 ; "BAD BRANCH"
        .byte   $BE,$B8,$A0,$C7,$CF,$D3,$D5,$C2,$53     ; ">8 GOSUBS"
        .byte   $C2,$C1,$C4,$A0,$D2,$C5,$D4,$D5,$D2,$4E ; "BAD RETURN"
        .byte   $BE,$B8,$A0,$C6,$CF,$D2,$53     ; ">8 FORS"
        .byte   $C2,$C1,$C4,$A0,$CE,$C5,$D8,$54 ; "BAD NEXT"
        .byte   $D3,$D4,$CF,$D0,$D0,$C5,$C4,$A0,$C1,$D4,$20 ; "STOPPED AT "
        .byte   $AA,$AA,$AA,$20                 ; "*** "
        .byte   $A0,$C5,$D2,$D2,$0D             ; " ERR.\n"
        .byte   $BE,$B2,$B5,$35                 ; ">255"
        .byte   $D2,$C1,$CE,$C7,$45             ; RANGE"
        .byte   $C4,$C9,$4D                     ; "DIM"
        .byte   $D3,$D4,$D2,$A0,$CF,$D6,$C6,$4C ; "STR OVFL"
        .byte   $DC,$0D                         ; "\\\n"
        .byte   $D2,$C5,$D4,$D9,$D0,$C5,$A0,$CC,$C9,$CE,$C5,$8D ; "RETYPE LINE\n"
        .byte   $3F                             ; "?"
Leb9a:  LSR     run_flag
        BCC     Leba1
        JMP     Le8c3
Leba1:  LDX     acc+1
        TXS
        LDX     acc
        LDY     #$8D
        BNE     Lebac

; token $54 - "INPUT" statement, numeric, no prompt
input_num_stmt: LDY     #$99
Lebac:  JSR     Se3c4
        STX     acc
        TSX
        STX     acc+1
        LDY     #$FE
        STY     run_flag
        INY
        STY     text_index
        JSR     Se299
        STY     token_index
        LDX     #$20
        LDA     #$30
        JSR     Se491
        INC     run_flag
        LDX     acc

; token $27 - "," numeric input
input_num_comma:        LDY     text_index
        ASL
Lebce:  STA     acc
        INY
        LDA     buffer,Y
        CMP     #$74
        BEQ     input_num_stmt
        EOR     #$B0
        CMP     #$0A
        BCS     Lebce
        INY
        INY
        STY     text_index
        LDA     buffer,Y
        PHA
        LDA     buffer-1,Y
        LDY     #$00
        JSR     push_ya_noun_stk
        PLA
        STA     noun_stk_h_int,X
        LDA     acc
        CMP     #$C7
        BNE     Lebfa
        JSR     negate
Lebfa:  JMP     var_assign

        .byte   $FF,$FF,$FF,$50            

Tec01:  JSR     Tec13
        BNE     Lec1b

Tec06:  JSR     Tec0b
        BNE     Lec1b

Tec0b:  JSR     subtract
        JSR     negate
        BVC     Lec16

Tec13:  JSR     subtract
Lec16:  JSR     sgn_fn
        LSR     noun_stk_l,X
Lec1b:  JMP     not_op

        .byte   $FF,$FF                  

; indexes into syntabl
syntabl_index:
        .byte   $C1,$FF,$7F,$D1,$CC,$C7,$CF,$CE ; "A..QLGON"
        .byte   $C5,$9A,$98,$8B,$96,$95,$93,$BF ; "E......?"
        .byte   $B2,$32,$2D,$2B,$BC,$B0,$AC,$BE ; "22-+<0,>"
        .byte   $35,$8E,$61,$FF,$FF,$FF,$DD,$FB ; "5.a...]{"

Tec40:  JSR     Sefc9
        ORA     rnd+1,X
        BPL     Lec4c

Tec47:  JSR     Sefc9
        AND     rnd+1,X
Lec4c:  STA     noun_stk_l,X
        BPL     Lec1b
        JMP     Sefc9
        .byte   $40,$60,$8D,$60,$8B,$00,$7E,$8C ; "@`.`..~."
        .byte   $33,$00,$00,$60,$03,$BF,$12,$00 ; "3..`.?.."
        .byte   $40,$89,$C9,$47,$9D,$17,$68,$9D ; "@.IG..h."
        .byte   $0A,$00,$40,$60,$8D,$60,$8B,$00 ; "..@`.`.."
        .byte   $7E,$8C,$3C,$00,$00,$60,$03,$BF ; "~.<..`.?"
        .byte   $1B,$4B,$67,$B4,$A1,$07,$8C,$07 ; ".Kg4!..."
        .byte   $AE,$A9,$AC,$A8,$67,$8C,$07,$B4 ; ".),(g..4"
        .byte   $AF,$AC,$B0,$67,$9D,$B2,$AF,$AC ; "/,0g.2/,"
        .byte   $AF,$A3,$67,$8C,$07,$A5,$AB,$AF ; "/#g..%+/"
        .byte   $B0,$F4,$AE,$A9,$B2,$B0,$7F,$0E ; "0t.)20.."
        .byte   $27,$B4,$AE,$A9,$B2,$B0,$7F,$0E ; "'4.)20.."
        .byte   $28,$B4,$AE,$A9,$B2,$B0,$64,$07 ; "(4.)20d."
        .byte   $A6,$A9,$67,$AF,$B4,$AF,$A7,$78 ; "&)g/4/'x"
        .byte   $B4,$A5,$AC,$78,$7F,$02,$AD,$A5 ; "4%,x..-%"
        .byte   $B2,$67,$A2,$B5,$B3,$AF,$A7,$EE ; "2g"53/'n"
        .byte   $B2,$B5,$B4,$A5,$B2,$7E,$8C,$39 ; "254%2~.9"
        .byte   $B4,$B8,$A5,$AE,$67,$B0,$A5,$B4 ; "48%.g0%4"
        .byte   $B3,$27,$AF,$B4,$07,$9D,$19,$B2 ; "3'/4...2"
        .byte   $AF,$A6,$7F,$05,$37,$B4,$B5,$B0 ; "/&..7450"
        .byte   $AE,$A9,$7F,$05,$28,$B4,$B5,$B0 ; ".)..(450"
        .byte   $AE,$A9,$7F,$05,$2A,$B4,$B5,$B0 ; ".)..*450"
        .byte   $AE,$A9,$E4,$AE,$A5,$00,$FF,$FF ; ".)d.%..."
syntabl2:
        .byte   $47,$A2,$A1,$B4,$7F,$0D,$30,$AD ; "G"!4..0-"
        .byte   $A9,$A4,$7F,$0D,$23,$AD,$A9,$A4 ; ")$..#-)$"
        .byte   $67,$AC,$AC,$A1,$A3,$00,$40,$80 ; "g,,!#.@."
        .byte   $C0,$C1,$80,$00,$47,$8C,$68,$8C ; "@A..G.h."
        .byte   $DB,$67,$9B,$68,$9B,$50,$8C,$63 ; "[g.h.P.c"
        .byte   $8C,$7F,$01,$51,$07,$88,$29,$84 ; "...Q..)."
        .byte   $80,$C4,$80,$57,$71,$07,$88,$14 ; ".D.Wq..."
        .byte   $ED,$A5,$AD,$AF,$AC,$ED,$A5,$AD ; "m%-/,m%-"
        .byte   $A9,$A8,$F2,$AF,$AC,$AF,$A3,$71 ; ")(r/,/#q"
        .byte   $08,$88,$AE,$A5,$AC,$68,$83,$08 ; "...%,h.."
        .byte   $68,$9D,$08,$71,$07,$88,$60,$76 ; "h..q..`v"
        .byte   $B4,$AF,$AE,$76,$8D,$76,$8B,$51 ; "4/.v.v.Q"
        .byte   $07,$88,$19,$B8,$A4,$AE,$B2,$F2 ; "...8$.2r"
        .byte   $B3,$B5,$F3,$A2,$A1,$EE,$A7,$B3 ; "35s"!n'3"
        .byte   $E4,$AE,$B2,$EB,$A5,$A5,$B0,$51 ; "d.2k%%0Q"
        .byte   $07,$88,$39,$81,$C1,$4F,$7F,$0F ; "..9.AO.."
        .byte   $2F,$00,$51,$06,$88,$29,$C2,$0C ; "/.Q..)B."
        .byte   $82,$57,$8C,$6A,$8C,$42,$AE,$A5 ; ".W.j.B.%"
        .byte   $A8,$B4,$60,$AE,$A5,$A8,$B4,$4F ; "(4`.%(4O"
        .byte   $7E,$1E,$35,$8C,$27,$51,$07,$88 ; "~.5.'Q.."
        .byte   $09,$8B,$FE,$E4,$AF,$AD,$F2,$AF ; "..~d/-r/"
        .byte   $E4,$AE,$A1,$DC,$DE,$9C,$DD,$9C ; "d.!\^.]."
        .byte   $DE,$DD,$9E,$C3,$DD,$CF,$CA,$CD ; "^].C]OJM"
        .byte   $CB,$00,$47,$9D,$AD,$A5,$AD,$AF ; "K.G.-%-/"
        .byte   $AC,$76,$9D,$AD,$A5,$AD,$A9,$A8 ; ",v.-%-)("
        .byte   $E6,$A6,$AF,$60,$8C,$20,$AF,$B4 ; "f&/`. /4"
        .byte   $B5,$A1,$F2,$AC,$A3,$F2,$A3,$B3 ; "5!r,#r#3"
        .byte   $60,$8C,$20,$AC,$A5,$A4,$EE,$B5 ; "`. ,%$n5"
        .byte   $B2,$60,$AE,$B5,$B2,$F4,$B3,$A9 ; "2`.52t3)"
        .byte   $AC,$60,$8C,$20,$B4,$B3,$A9,$AC ; ",`. 43),"
        .byte   $7A,$7E,$9A,$22,$20,$00,$60,$03 ; "z~." .`."
        .byte   $BF,$60,$03,$BF,$1F             ; "?`.?."

; token $48 - "," string output
print_str_comma:        JSR     tabout

; token $45 - ";" string output
; token $61 - "PRINT" string
print_str:      INX
        INX
        LDA     rnd+1,X
        STA     aux
        LDA     syn_stk_h+31,X
        STA     aux+1
        LDY     rnd,X
Lee0f:  TYA
        CMP     syn_stk_h+30,X
        BCS     Lee1d
        LDA     (aux),Y
        JSR     cout
        INY
        JMP     Lee0f
Lee1d:  LDA     #$FF
        STA     cr_flag
        RTS

; token $3B - "LEN(" function
len_fn: INX
        LDA     #$00
        STA     noun_stk_h_str,X
        STA     noun_stk_h_int,X
        LDA     syn_stk_h+31,X
        SEC
        SBC     rnd+1,X
        STA     noun_stk_l,X
        JMP     left_paren

        .byte   $FF

getbyte:        JSR     get16bit
        LDA     acc+1
        BNE     gr_255_err
        LDA     acc
        RTS

; token $68 - "," for PLOT statement (???)
plot_comma:     JSR     getbyte
        LDY     text_index
        CMP     #$30
        BCS     range_err
        CPY     #$28
        BCS     range_err
        RTS
        NOP
        NOP

Tee4e:  JSR     getbyte
        RTS
        NOP
Tee5e:  TXA
        LDX     #$01
l123:   LDY     acc,X
        STY     himem,X
        LDY     var,X
        STY     pp,X
        DEX
        BEQ     l123
        TAX
        RTS
gr_255_err:     LDY     #$77            ; > 255 error
go_errmess_5:   JMP     print_err_msg
range_err:      LDY     #$7B            ; range error
        BNE     go_errmess_5

See6c:  JSR     Se254
        LDA     aux
        BNE     Lee7a
        LDA     aux+1
        BNE     Lee7a
        JMP     Le77e
Lee7a:  ASL     acc
        ROL     acc+1
        ROL     p3
        ROL     p3+1
        LDA     p3
        CMP     aux
        LDA     p3+1
        SBC     aux+1
        BCC     Lee96
        STA     p3+1
        LDA     p3
        SBC     aux
        STA     p3
        INC     acc
Lee96:  DEY
        BNE     Lee7a
        RTS

        .byte   $FF,$FF,$FF,$FF,$FF,$FF

; token $4D - "CALL" statement
call_stmt:      JSR     get16bit
        JMP     (acc)
l1233:  LDA     himem
        BNE     l1235
        DEC     himem+1
l1235:  DEC     himem
        LDA     var
        BNE     l1236
        DEC     var+1
l1236:  DEC     var
l1237:  LDY     #$00
        LDA     (himem),Y
        STA     (var),Y
        LDA     pp
        CMP     himem
        LDA     pp+1
        SBC     himem+1
        BCC     l1233
        JMP     Tee5e
        CMP     #$28
Leecb:  BCS     range_err
        TAY
        LDA     text_index
        RTS
        NOP
        NOP

print_err_msg1:
        TYA
        TAX
        LDY     #$6E
        JSR     Se3c4
        TXA
        TAY
        JSR     Se3c4
        LDY     #$72
        JMP     Se3c4

Seee4:  JSR     get16bit
Leee7:  ASL     acc
        ROL     acc+1
        BMI     Leee7
        BCS     Leecb
        BNE     Leef5
        CMP     acc
        BCS     Leecb
Leef5:  RTS

; token $2E - "PEEK" fn (uses $3F left paren)
peek_fn:        JSR     get16bit
        LDA     (acc),Y
        STY     syn_stk_l+31,X
        JMP     push_ya_noun_stk

; token $65 - "," for POKE statement
poke_stmt:      JSR     getbyte
        LDA     acc
        PHA
        JSR     get16bit
        PLA
        STA     (acc),Y

Tef0c:  RTS

        .byte   $FF,$FF,$FF

; token $15 - "/" for numeric division
divide: JSR     See6c
        LDA     acc
        STA     p3
        LDA     acc+1
        STA     p3+1
        JMP     Le244

; token $44 - "," next var in DIM statement is numeric
; token $4F - "DIM", next var is numeric
dim_num:        JSR     Seee4
        JMP     Le134

; token $2D - "(" for numeric array subscript
num_array_subs: JSR     Seee4
        LDY     noun_stk_h_str,X
        LDA     noun_stk_l,X
        ADC     #$FE
        BCS     Lef30
        DEY
Lef30:  STA     aux
        STY     aux+1
        CLC
        ADC     acc
        STA     noun_stk_l,X
        TYA
        ADC     acc+1
        STA     noun_stk_h_str,X
        LDY     #$00
        LDA     noun_stk_l,X
        CMP     (aux),Y
        INY
        LDA     noun_stk_h_str,X
        SBC     (aux),Y
        BCS     Leecb
        JMP     left_paren

; token $2F - "RND" fn (uses $3F left paren)
rnd_fn: JSR     get16bit
        LDA     rnd
        JSR     push_ya_noun_stk
        LDA     rnd+1
        BNE     Lef5e
        CMP     rnd
        ADC     #$00
Lef5e:  AND     #$7F
        STA     rnd+1
        STA     noun_stk_h_int,X
        LDY     #$11
Lef66:  LDA     rnd+1
        ASL
        CLC
        ADC     #$40
        ASL
        ROL     rnd
        ROL     rnd+1
        DEY
        BNE     Lef66
        LDA     acc
        JSR     push_ya_noun_stk
        LDA     acc+1
        STA     noun_stk_h_int,X
        JMP     mod_op

Tef80:  JSR     get16bit
        LDY     acc
        CPY     himem
        LDA     acc+1
        SBC     himem+1
        BCC     Lefab
        STY     var
        LDA     acc+1
        STA     var+1
Lef93:  JMP     l1237

Tef96:  JSR     get16bit
        LDY     acc
        CPY     pp
        LDA     acc+1
        SBC     pp+1
        BCS     Lefab
        STY     lomem
        LDA     acc+1
        STA     lomem+1
        JMP     clr
Lefab:  JMP     Leecb
        NOP
        NOP
        NOP
        NOP
Lefb3:  JSR     Sefc9

; token $26 - "," for string input
; token $52 - "INPUT" statement for string
string_input:   JSR     input_str
        JMP     Lefbf

; token $53 - "INPUT" with literal string prompt
input_prompt:   JSR     print_str
Lefbf:  LDA     #$FF
        STA     text_index
        LDA     #$74
        STA     buffer
        RTS

Sefc9:  JSR     not_op
        INX

Sefcd:  JSR     not_op
        LDA     noun_stk_l,X
        RTS

; memory initialization for 4K RAM
mem_init_4k:    LDA     #$00
        STA     lomem
        STA     himem
        LDA     #$08
        STA     lomem+1         ; LOMEM defaults to $0800
        LDA     #$10
        STA     himem+1         ; HIMEM defaults to $1000
        JMP     new_cmd

Sefe4:  CMP     noun_stk_h_str,X
        BNE     Lefe9
        CLC
Lefe9:  JMP     Le102

Tefec:  JSR     clr
        JMP     run_warm

Teff2:  JSR     clr
        JMP     goto_stmt

Seff8:  CPX     #$80
        BNE     Leffd
        DEY
Leffd:  JMP     Se00c
