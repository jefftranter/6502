; Disassembly of Apple 1 BASIC
; 17-Sep-2003
; Apple 1 BASIC was written by Steve Wozniak
; This disassembly is copyright 2003 Eric Smith <eric@brouhaha.com>
; http://www.brouhaha.com/~eric/retrocomputing/apple/apple1/basic/

RESET	.equ	$00
Z1d	.equ	$1d
ch	.equ	$24
cv	.equ	$25
lomem	.equ	$4a
himem	.equ	$4c
rnd	.equ	$4e
noun_stk_l	.equ	$50
noun_stk_h_str	.equ	$78
noun_stk_h_int	.equ	$a0
text_index	.equ	$c8
leadbl	.equ	$c9
pp	.equ	$ca
pv	.equ	$cc
acc	.equ	$ce
srch	.equ	$d0
tokndxstk	.equ	$d1
srch2	.equ	$d2
if_flag	.equ	$d4
cr_flag	.equ	$d5
current_verb	.equ	$d6
precedence	.equ	$d7
x_save	.equ	$d8
run_flag	.equ	$d9
aux	.equ	$da
pline	.equ	$dc
pverb	.equ	$e0
p1	.equ	$e2
p2	.equ	$e4
p3	.equ	$e6
token_index	.equ	$f1
pcon	.equ	$f2
auto_inc	.equ	$f4
auto_ln	.equ	$f6
auto_flag	.equ	$f8
char	.equ	$f9
leadzr	.equ	$fa
for_nest_count	.equ	$fb
gosub_nest_count	.equ	$fc
synstkdx	.equ	$fd
synpag	.equ	$fe
gstk_pverbl	.equ	$0100
gstk_pverbh	.equ	$0108
gstk_plinel	.equ	$0110
gstk_plineh	.equ	$0118
fstk_varl	.equ	$0120
fstk_varh	.equ	$0128
fstk_stepl	.equ	$0130
fstk_steph	.equ	$0138
fstk_plinel	.equ	$0140
fstk_plineh	.equ	$0148
fstk_pverbl	.equ	$0150
fstk_pverbh	.equ	$0158
fstk_tol	.equ	$0160
fstk_toh	.equ	$0168
buffer	.equ	$0200
Dd010	.equ	$d010
Dd011	.equ	$d011
Dd0f2	.equ	$d0f2
	.org	$e000

e000  4c b0 e2   Pe000:	JMP	cold

e003  ad 11 d0   rdkey:	LDA	Dd011
e006  10 fb      	BPL	rdkey
e008  ad 10 d0   	LDA	Dd010
e00b  60         	RTS

e00c  8a         Se00c:	TXA
e00d  29 20      	AND	#$20	; 32  
e00f  f0 23      	BEQ	Le034

e011  a9 a0      Se011:	LDA	#$a0	; 160  
e013  85 e4      	STA	p2
e015  4c c9 e3   	JMP	cout

e018  a9 20      Se018:	LDA	#$20	; 32  

e01a  c5 24      Se01a:	CMP	ch
e01c  b0 0c      	BCS	nextbyte
e01e  a9 8d      	LDA	#$8d	; 141 .
e020  a0 07      	LDY	#$07	; 7 .
e022  20 c9 e3   Le022:	JSR	cout
e025  a9 a0      	LDA	#$a0	; 160  
e027  88         	DEY
e028  d0 f8      	BNE	Le022

e02a  a0 00      nextbyte:	LDY	#$00	; 0 .
e02c  b1 e2      	LDA	(p1),Y
e02e  e6 e2      	INC	p1
e030  d0 02      	BNE	Le034
e032  e6 e3      	INC	p1+1
e034  60         Le034:	RTS

e035  20 15 e7   list_comman:	JSR	get16bit
e038  20 76 e5   	JSR	find_line2
e03b  a5 e2      Le03b:	LDA	p1
e03d  c5 e6      	CMP	p3
e03f  a5 e3      	LDA	p1+1
e041  e5 e7      	SBC	p3+1
e043  b0 ef      	BCS	Le034
e045  20 6d e0   	JSR	list_line
e048  4c 3b e0   	JMP	Le03b

e04b  a5 ca      list_all:	LDA	pp
e04d  85 e2      	STA	p1
e04f  a5 cb      	LDA	pp+1
e051  85 e3      	STA	p1+1
e053  a5 4c      	LDA	himem
e055  85 e6      	STA	p3
e057  a5 4d      	LDA	himem+1
e059  85 e7      	STA	p3+1
e05b  d0 de      	BNE	Le03b

e05d  20 15 e7   list_cmd:	JSR	get16bit
e060  20 6d e5   	JSR	find_line
e063  a5 e4      	LDA	p2
e065  85 e2      	STA	p1
e067  a5 e5      	LDA	p2+1
e069  85 e3      	STA	p1+1
e06b  b0 c7      	BCS	Le034

e06d  86 d8      list_line:	STX	x_save
e06f  a9 a0      	LDA	#$a0	; 160  
e071  85 fa      	STA	leadzr
e073  20 2a e0   	JSR	nextbyte
e076  98         	TYA
e077  85 e4      list_int:	STA	p2
e079  20 2a e0   	JSR	nextbyte
e07c  aa         	TAX
e07d  20 2a e0   	JSR	nextbyte
e080  20 1b e5   	JSR	prdec
e083  20 18 e0   Le083:	JSR	Se018
e086  84 fa      	STY	leadzr
e088  aa         	TAX
e089  10 18      	BPL	list_token
e08b  0a         	ASL
e08c  10 e9      	BPL	list_int
e08e  a5 e4      	LDA	p2
e090  d0 03      	BNE	Le095
e092  20 11 e0   	JSR	Se011
e095  8a         Le095:	TXA
e096  20 c9 e3   Le096:	JSR	cout
e099  a9 25      Le099:	LDA	#$25	; 37 %
e09b  20 1a e0   	JSR	Se01a
e09e  aa         	TAX
e09f  30 f5      	BMI	Le096
e0a1  85 e4      	STA	p2
e0a3  c9 01      list_token:	CMP	#$01	; 1 .
e0a5  d0 05      	BNE	Le0ac
e0a7  a6 d8      	LDX	x_save
e0a9  4c cd e3   	JMP	crout
e0ac  48         Le0ac:	PHA
e0ad  84 ce      	STY	acc
e0af  a2 ed      	LDX	#$ed	; 237 m
e0b1  86 cf      	STX	acc+1
e0b3  c9 51      	CMP	#$51	; 81 Q
e0b5  90 04      	BCC	Le0bb
e0b7  c6 cf      	DEC	acc+1
e0b9  e9 50      	SBC	#$50	; 80 P
e0bb  48         Le0bb:	PHA
e0bc  b1 ce      	LDA	(acc),Y
e0be  aa         Le0be:	TAX
e0bf  88         	DEY
e0c0  b1 ce      	LDA	(acc),Y
e0c2  10 fa      	BPL	Le0be
e0c4  e0 c0      	CPX	#$c0	; 192 @
e0c6  b0 04      	BCS	Le0cc
e0c8  e0 00      	CPX	#$00	; 0 .
e0ca  30 f2      	BMI	Le0be
e0cc  aa         Le0cc:	TAX
e0cd  68         	PLA
e0ce  e9 01      	SBC	#$01	; 1 .
e0d0  d0 e9      	BNE	Le0bb
e0d2  24 e4      	BIT	p2
e0d4  30 03      	BMI	Le0d9
e0d6  20 f8 ef   	JSR	Seff8
e0d9  b1 ce      Le0d9:	LDA	(acc),Y
e0db  10 10      	BPL	Le0ed
e0dd  aa         	TAX
e0de  29 3f      	AND	#$3f	; 63 ?
e0e0  85 e4      	STA	p2
e0e2  18         	CLC
e0e3  69 a0      	ADC	#$a0	; 160  
e0e5  20 c9 e3   	JSR	cout
e0e8  88         	DEY
e0e9  e0 c0      	CPX	#$c0	; 192 @
e0eb  90 ec      	BCC	Le0d9
e0ed  20 0c e0   Le0ed:	JSR	Se00c
e0f0  68         	PLA
e0f1  c9 5d      	CMP	#$5d	; 93 ]
e0f3  f0 a4      	BEQ	Le099
e0f5  c9 28      	CMP	#$28	; 40 (
e0f7  d0 8a      	BNE	Le083
e0f9  f0 9e      	BEQ	Le099

e0fb  20 18 e1   paren_substr:	JSR	Se118
e0fe  95 50      	STA	noun_stk_l,X
e100  d5 78      	CMP	noun_stk_h_str,X
e102  90 11      Le102:	BCC	Le115
e104  a0 2b      string_err:	LDY	#$2b	; 43 +
e106  4c e0 e3   go_errmess_1:	JMP	print_err_msg

e109  20 34 ee   comma_substr:	JSR	getbyte
e10c  d5 50      	CMP	noun_stk_l,X
e10e  90 f4      	BCC	string_err
e110  20 e4 ef   	JSR	Sefe4
e113  95 78      	STA	noun_stk_h_str,X
e115  4c 23 e8   Le115:	JMP	left_paren

e118  20 34 ee   Se118:	JSR	getbyte
e11b  f0 e7      	BEQ	string_err
e11d  38         	SEC
e11e  e9 01      	SBC	#$01	; 1 .
e120  60         	RTS

e121  20 18 e1   str_arr_dest:	JSR	Se118
e124  95 50      	STA	noun_stk_l,X
e126  18         	CLC
e127  f5 78      	SBC	noun_stk_h_str,X
e129  4c 02 e1   	JMP	Le102
e12c  a0 14      Le12c:	LDY	#$14	; 20 .
e12e  d0 d6      	BNE	go_errmess_1

e130  20 18 e1   dim_str:	JSR	Se118
e133  e8         	INX
e134  b5 50      Le134:	LDA	noun_stk_l,X
e136  85 da      	STA	aux
e138  65 ce      	ADC	acc
e13a  48         	PHA
e13b  a8         	TAY
e13c  b5 78      	LDA	noun_stk_h_str,X
e13e  85 db      	STA	aux+1
e140  65 cf      	ADC	acc+1
e142  48         	PHA
e143  c4 ca      	CPY	pp
e145  e5 cb      	SBC	pp+1
e147  b0 e3      	BCS	Le12c
e149  a5 da      	LDA	aux
e14b  69 fe      	ADC	#$fe	; 254 ~
e14d  85 da      	STA	aux
e14f  a9 ff      	LDA	#$ff	; 255 .
e151  a8         	TAY
e152  65 db      	ADC	aux+1
e154  85 db      	STA	aux+1
e156  c8         Le156:	INY
e157  b1 da      	LDA	(aux),Y
e159  d9 cc 00   	CMP	pv,Y
e15c  d0 0f      	BNE	Le16d
e15e  98         	TYA
e15f  f0 f5      	BEQ	Le156
e161  68         Le161:	PLA
e162  91 da      	STA	(aux),Y
e164  99 cc 00   	STA	pv,Y
e167  88         	DEY
e168  10 f7      	BPL	Le161
e16a  e8         	INX
e16b  60         	RTS
e16c             	.byte	$ea                     	; "j"
e16d  a0 80      Le16d:	LDY	#$80	; 128 .
e16f  d0 95      Le16f:	BNE	go_errmess_1

e171  a9 00      input_str:	LDA	#$00	; 0 .
e173  20 0a e7   	JSR	push_a_noun_stk
e176  a0 02      	LDY	#$02	; 2 .
e178  94 78      	STY	noun_stk_h_str,X
e17a  20 0a e7   	JSR	push_a_noun_stk
e17d  a9 bf      	LDA	#$bf	; 191 ?
e17f  20 c9 e3   	JSR	cout
e182  a0 00      	LDY	#$00	; 0 .
e184  20 9e e2   	JSR	read_line
e187  94 78      	STY	noun_stk_h_str,X
e189  ea         	NOP
e18a  ea         	NOP
e18b  ea         	NOP

e18c  b5 51      string_lit:	LDA	noun_stk_l+1,X
e18e  85 ce      	STA	acc
e190  b5 79      	LDA	noun_stk_h_str+1,X
e192  85 cf      	STA	acc+1
e194  e8         	INX
e195  e8         	INX
e196  20 bc e1   	JSR	Se1bc
e199  b5 4e      Le199:	LDA	rnd,X
e19b  d5 76      	CMP	syn_stk_h+30,X
e19d  b0 15      	BCS	Le1b4
e19f  f6 4e      	INC	rnd,X
e1a1  a8         	TAY
e1a2  b1 ce      	LDA	(acc),Y
e1a4  b4 50      	LDY	noun_stk_l,X
e1a6  c4 e4      	CPY	p2
e1a8  90 04      	BCC	Le1ae
e1aa  a0 83      	LDY	#$83	; 131 .
e1ac  d0 c1      	BNE	Le16f
e1ae  91 da      Le1ae:	STA	(aux),Y
e1b0  f6 50      	INC	noun_stk_l,X
e1b2  90 e5      	BCC	Le199
e1b4  b4 50      Le1b4:	LDY	noun_stk_l,X
e1b6  8a         	TXA
e1b7  91 da      	STA	(aux),Y
e1b9  e8         	INX
e1ba  e8         	INX
e1bb  60         	RTS

e1bc  b5 51      Se1bc:	LDA	noun_stk_l+1,X
e1be  85 da      	STA	aux
e1c0  38         	SEC
e1c1  e9 02      	SBC	#$02	; 2 .
e1c3  85 e4      	STA	p2
e1c5  b5 79      	LDA	noun_stk_h_str+1,X
e1c7  85 db      	STA	aux+1
e1c9  e9 00      	SBC	#$00	; 0 .
e1cb  85 e5      	STA	p2+1
e1cd  a0 00      	LDY	#$00	; 0 .
e1cf  b1 e4      	LDA	(p2),Y
e1d1  18         	CLC
e1d2  e5 da      	SBC	aux
e1d4  85 e4      	STA	p2
e1d6  60         	RTS

e1d7  b5 53      string_eq:	LDA	noun_stk_l+3,X
e1d9  85 ce      	STA	acc
e1db  b5 7b      	LDA	noun_stk_h_str+3,X
e1dd  85 cf      	STA	acc+1
e1df  b5 51      	LDA	noun_stk_l+1,X
e1e1  85 da      	STA	aux
e1e3  b5 79      	LDA	noun_stk_h_str+1,X
e1e5  85 db      	STA	aux+1
e1e7  e8         	INX
e1e8  e8         	INX
e1e9  e8         	INX
e1ea  a0 00      	LDY	#$00	; 0 .
e1ec  94 78      	STY	noun_stk_h_str,X
e1ee  94 a0      	STY	noun_stk_h_int,X
e1f0  c8         	INY
e1f1  94 50      	STY	noun_stk_l,X
e1f3  b5 4d      Le1f3:	LDA	himem+1,X
e1f5  d5 75      	CMP	syn_stk_h+29,X
e1f7  08         	PHP
e1f8  48         	PHA
e1f9  b5 4f      	LDA	rnd+1,X
e1fb  d5 77      	CMP	syn_stk_h+31,X
e1fd  90 07      	BCC	Le206
e1ff  68         	PLA
e200  28         	PLP
e201  b0 02      	BCS	Le205
e203  56 50      Le203:	LSR	noun_stk_l,X
e205  60         Le205:	RTS
e206  a8         Le206:	TAY
e207  b1 ce      	LDA	(acc),Y
e209  85 e4      	STA	p2
e20b  68         	PLA
e20c  a8         	TAY
e20d  28         	PLP
e20e  b0 f3      	BCS	Le203
e210  b1 da      	LDA	(aux),Y
e212  c5 e4      	CMP	p2
e214  d0 ed      	BNE	Le203
e216  f6 4f      	INC	rnd+1,X
e218  f6 4d      	INC	himem+1,X
e21a  b0 d7      	BCS	Le1f3

e21c  20 d7 e1   string_neq:	JSR	string_eq
e21f  4c 36 e7   	JMP	not_op

e222  20 54 e2   mult_op:	JSR	Se254
e225  06 ce      Le225:	ASL	acc
e227  26 cf      	ROL	acc+1
e229  90 0d      	BCC	Le238
e22b  18         	CLC
e22c  a5 e6      	LDA	p3
e22e  65 da      	ADC	aux
e230  85 e6      	STA	p3
e232  a5 e7      	LDA	p3+1
e234  65 db      	ADC	aux+1
e236  85 e7      	STA	p3+1
e238  88         Le238:	DEY
e239  f0 09      	BEQ	Le244
e23b  06 e6      	ASL	p3
e23d  26 e7      	ROL	p3+1
e23f  10 e4      	BPL	Le225
e241  4c 7e e7   	JMP	Le77e
e244  a5 e6      Le244:	LDA	p3
e246  20 08 e7   	JSR	push_ya_noun_stk
e249  a5 e7      	LDA	p3+1
e24b  95 a0      	STA	noun_stk_h_int,X
e24d  06 e5      	ASL	p2+1
e24f  90 28      	BCC	Le279
e251  4c 6f e7   	JMP	negate

e254  a9 55      Se254:	LDA	#$55	; 85 U
e256  85 e5      	STA	p2+1
e258  20 5b e2   	JSR	Se25b

e25b  a5 ce      Se25b:	LDA	acc
e25d  85 da      	STA	aux
e25f  a5 cf      	LDA	acc+1
e261  85 db      	STA	aux+1
e263  20 15 e7   	JSR	get16bit
e266  84 e6      	STY	p3
e268  84 e7      	STY	p3+1
e26a  a5 cf      	LDA	acc+1
e26c  10 09      	BPL	Le277
e26e  ca         	DEX
e26f  06 e5      	ASL	p2+1
e271  20 6f e7   	JSR	negate
e274  20 15 e7   	JSR	get16bit
e277  a0 10      Le277:	LDY	#$10	; 16 .
e279  60         Le279:	RTS

e27a  20 6c ee   mod_op:	JSR	See6c
e27d  f0 c5      	BEQ	Le244
e27f             	.byte	$ff                     	; "."
e280  c9 84      Le280:	CMP	#$84	; 132 .
e282  d0 02      	BNE	Le286
e284  46 f8      	LSR	auto_flag
e286  c9 df      Le286:	CMP	#$df	; 223 _
e288  f0 11      	BEQ	Le29b
e28a  c9 9b      	CMP	#$9b	; 155 .
e28c  f0 06      	BEQ	Le294
e28e  99 00 02   	STA	buffer,Y
e291  c8         	INY
e292  10 0a      	BPL	read_line
e294  a0 8b      Le294:	LDY	#$8b	; 139 .
e296  20 c4 e3   	JSR	Se3c4

e299  a0 01      Se299:	LDY	#$01	; 1 .
e29b  88         Le29b:	DEY
e29c  30 f6      	BMI	Le294

e29e  20 03 e0   read_line:	JSR	rdkey
e2a1  ea         	NOP
e2a2  ea         	NOP
e2a3  20 c9 e3   	JSR	cout
e2a6  c9 8d      	CMP	#$8d	; 141 .
e2a8  d0 d6      	BNE	Le280
e2aa  a9 df      	LDA	#$df	; 223 _
e2ac  99 00 02   	STA	buffer,Y
e2af  60         	RTS
e2b0  20 d3 ef   cold:	JSR	mem_init_4k
e2b3  20 cd e3   warm:	JSR	crout
e2b6  46 d9      Le2b6:	LSR	run_flag
e2b8  a9 be      	LDA	#$be	; 190 >
e2ba  20 c9 e3   	JSR	cout
e2bd  a0 00      	LDY	#$00	; 0 .
e2bf  84 fa      	STY	leadzr
e2c1  24 f8      	BIT	auto_flag
e2c3  10 0c      	BPL	Le2d1
e2c5  a6 f6      	LDX	auto_ln
e2c7  a5 f7      	LDA	auto_ln+1
e2c9  20 1b e5   	JSR	prdec
e2cc  a9 a0      	LDA	#$a0	; 160  
e2ce  20 c9 e3   	JSR	cout
e2d1  a2 ff      Le2d1:	LDX	#$ff	; 255 .
e2d3  9a         	TXS
e2d4  20 9e e2   	JSR	read_line
e2d7  84 f1      	STY	token_index
e2d9  8a         	TXA
e2da  85 c8      	STA	text_index
e2dc  a2 20      	LDX	#$20	; 32  
e2de  20 91 e4   	JSR	Se491
e2e1  a5 c8      	LDA	text_index
e2e3  69 00      	ADC	#$00	; 0 .
e2e5  85 e0      	STA	pverb
e2e7  a9 00      	LDA	#$00	; 0 .
e2e9  aa         	TAX
e2ea  69 02      	ADC	#$02	; 2 .
e2ec  85 e1      	STA	pverb+1
e2ee  a1 e0      	LDA	(pverb,X)
e2f0  29 f0      	AND	#$f0	; 240 p
e2f2  c9 b0      	CMP	#$b0	; 176 0
e2f4  f0 03      	BEQ	Le2f9
e2f6  4c 83 e8   	JMP	Le883
e2f9  a0 02      Le2f9:	LDY	#$02	; 2 .
e2fb  b1 e0      Le2fb:	LDA	(pverb),Y
e2fd  99 cd 00   	STA	pv+1,Y
e300  88         	DEY
e301  d0 f8      	BNE	Le2fb
e303  20 8a e3   	JSR	Se38a
e306  a5 f1      	LDA	token_index
e308  e5 c8      	SBC	text_index
e30a  c9 04      	CMP	#$04	; 4 .
e30c  f0 a8      	BEQ	Le2b6
e30e  91 e0      	STA	(pverb),Y
e310  a5 ca      	LDA	pp
e312  f1 e0      	SBC	(pverb),Y
e314  85 e4      	STA	p2
e316  a5 cb      	LDA	pp+1
e318  e9 00      	SBC	#$00	; 0 .
e31a  85 e5      	STA	p2+1
e31c  a5 e4      	LDA	p2
e31e  c5 cc      	CMP	pv
e320  a5 e5      	LDA	p2+1
e322  e5 cd      	SBC	pv+1
e324  90 45      	BCC	Le36b
e326  a5 ca      Le326:	LDA	pp
e328  f1 e0      	SBC	(pverb),Y
e32a  85 e6      	STA	p3
e32c  a5 cb      	LDA	pp+1
e32e  e9 00      	SBC	#$00	; 0 .
e330  85 e7      	STA	p3+1
e332  b1 ca      	LDA	(pp),Y
e334  91 e6      	STA	(p3),Y
e336  e6 ca      	INC	pp
e338  d0 02      	BNE	Le33c
e33a  e6 cb      	INC	pp+1
e33c  a5 e2      Le33c:	LDA	p1
e33e  c5 ca      	CMP	pp
e340  a5 e3      	LDA	p1+1
e342  e5 cb      	SBC	pp+1
e344  b0 e0      	BCS	Le326
e346  b5 e4      Le346:	LDA	p2,X
e348  95 ca      	STA	pp,X
e34a  ca         	DEX
e34b  10 f9      	BPL	Le346
e34d  b1 e0      	LDA	(pverb),Y
e34f  a8         	TAY
e350  88         Le350:	DEY
e351  b1 e0      	LDA	(pverb),Y
e353  91 e6      	STA	(p3),Y
e355  98         	TYA
e356  d0 f8      	BNE	Le350
e358  24 f8      	BIT	auto_flag
e35a  10 09      	BPL	Le365
e35c  b5 f7      Le35c:	LDA	auto_ln+1,X
e35e  75 f5      	ADC	auto_inc+1,X
e360  95 f7      	STA	auto_ln+1,X
e362  e8         	INX
e363  f0 f7      	BEQ	Le35c
e365  10 7e      Le365:	BPL	Le3e5
e367  00         	BRK
e368             	.byte	$00,$00,$00               	; "..."
e36b  a0 14      Le36b:	LDY	#$14	; 20 .
e36d  d0 71      	BNE	print_err_msg

e36f  20 15 e7   del_comma:	JSR	get16bit
e372  a5 e2      	LDA	p1
e374  85 e6      	STA	p3
e376  a5 e3      	LDA	p1+1
e378  85 e7      	STA	p3+1
e37a  20 75 e5   	JSR	find_line1
e37d  a5 e2      	LDA	p1
e37f  85 e4      	STA	p2
e381  a5 e3      	LDA	p1+1
e383  85 e5      	STA	p2+1
e385  d0 0e      	BNE	Le395

e387  20 15 e7   del_cmd:	JSR	get16bit

e38a  20 6d e5   Se38a:	JSR	find_line
e38d  a5 e6      	LDA	p3
e38f  85 e2      	STA	p1
e391  a5 e7      	LDA	p3+1
e393  85 e3      	STA	p1+1
e395  a0 00      Le395:	LDY	#$00	; 0 .
e397  a5 ca      Le397:	LDA	pp
e399  c5 e4      	CMP	p2
e39b  a5 cb      	LDA	pp+1
e39d  e5 e5      	SBC	p2+1
e39f  b0 16      	BCS	Le3b7
e3a1  a5 e4      	LDA	p2
e3a3  d0 02      	BNE	Le3a7
e3a5  c6 e5      	DEC	p2+1
e3a7  c6 e4      Le3a7:	DEC	p2
e3a9  a5 e6      	LDA	p3
e3ab  d0 02      	BNE	Le3af
e3ad  c6 e7      	DEC	p3+1
e3af  c6 e6      Le3af:	DEC	p3
e3b1  b1 e4      	LDA	(p2),Y
e3b3  91 e6      	STA	(p3),Y
e3b5  90 e0      	BCC	Le397
e3b7  a5 e6      Le3b7:	LDA	p3
e3b9  85 ca      	STA	pp
e3bb  a5 e7      	LDA	p3+1
e3bd  85 cb      	STA	pp+1
e3bf  60         	RTS
e3c0  20 c9 e3   Le3c0:	JSR	cout
e3c3  c8         	INY

e3c4  b9 00 eb   Se3c4:	LDA	error_msg_tbl,Y
e3c7  30 f7      	BMI	Le3c0

e3c9  c9 8d      cout:	CMP	#$8d	; 141 .
e3cb  d0 06      	BNE	Le3d3

e3cd  a9 00      crout:	LDA	#$00	; 0 .
e3cf  85 24      	STA	ch
e3d1  a9 8d      	LDA	#$8d	; 141 .
e3d3  e6 24      Le3d3:	INC	ch
e3d5  2c f2 d0   Le3d5:	BIT	Dd0f2
e3d8  30 fb      	BMI	Le3d5
e3da  8d f2 d0   	STA	Dd0f2
e3dd  60         	RTS
e3de  a0 06      too_long_err:	LDY	#$06	; 6 .
e3e0  20 d3 ee   print_err_msg:	JSR	print_err_msg
e3e3  24 d9      	BIT	run_flag
e3e5  30 03      Le3e5:	BMI	Le3ea
e3e7  4c b6 e2   	JMP	Le2b6
e3ea  4c 9a eb   Le3ea:	JMP	Leb9a
e3ed  2a         Le3ed:	ROL
e3ee  69 a0      	ADC	#$a0	; 160  
e3f0  dd 00 02   	CMP	buffer,X
e3f3  d0 53      	BNE	Le448
e3f5  b1 fe      	LDA	(synpag),Y
e3f7  0a         	ASL
e3f8  30 06      	BMI	Le400
e3fa  88         	DEY
e3fb  b1 fe      	LDA	(synpag),Y
e3fd  30 29      	BMI	Le428
e3ff  c8         	INY
e400  86 c8      Le400:	STX	text_index
e402  98         	TYA
e403  48         	PHA
e404  a2 00      	LDX	#$00	; 0 .
e406  a1 fe      	LDA	(synpag,X)
e408  aa         	TAX
e409  4a         Le409:	LSR
e40a  49 48      	EOR	#$48	; 72 H
e40c  11 fe      	ORA	(synpag),Y
e40e  c9 c0      	CMP	#$c0	; 192 @
e410  90 01      	BCC	Le413
e412  e8         	INX
e413  c8         Le413:	INY
e414  d0 f3      	BNE	Le409
e416  68         	PLA
e417  a8         	TAY
e418  8a         	TXA
e419  4c c0 e4   	JMP	Le4c0

e41c  e6 f1      put_token:	INC	token_index
e41e  a6 f1      	LDX	token_index
e420  f0 bc      	BEQ	too_long_err
e422  9d 00 02   	STA	buffer,X
e425  60         Le425:	RTS
e426  a6 c8      Le426:	LDX	text_index
e428  a9 a0      Le428:	LDA	#$a0	; 160  
e42a  e8         Le42a:	INX
e42b  dd 00 02   	CMP	buffer,X
e42e  b0 fa      	BCS	Le42a
e430  b1 fe      	LDA	(synpag),Y
e432  29 3f      	AND	#$3f	; 63 ?
e434  4a         	LSR
e435  d0 b6      	BNE	Le3ed
e437  bd 00 02   	LDA	buffer,X
e43a  b0 06      	BCS	Le442
e43c  69 3f      	ADC	#$3f	; 63 ?
e43e  c9 1a      	CMP	#$1a	; 26 .
e440  90 6f      	BCC	Le4b1
e442  69 4f      Le442:	ADC	#$4f	; 79 O
e444  c9 0a      	CMP	#$0a	; 10 .
e446  90 69      	BCC	Le4b1
e448  a6 fd      Le448:	LDX	synstkdx
e44a  c8         Le44a:	INY
e44b  b1 fe      	LDA	(synpag),Y
e44d  29 e0      	AND	#$e0	; 224 `
e44f  c9 20      	CMP	#$20	; 32  
e451  f0 7a      	BEQ	Le4cd
e453  b5 a8      	LDA	txtndxstk,X
e455  85 c8      	STA	text_index
e457  b5 d1      	LDA	tokndxstk,X
e459  85 f1      	STA	token_index
e45b  88         Le45b:	DEY
e45c  b1 fe      	LDA	(synpag),Y
e45e  0a         	ASL
e45f  10 fa      	BPL	Le45b
e461  88         	DEY
e462  b0 38      	BCS	Le49c
e464  0a         	ASL
e465  30 35      	BMI	Le49c
e467  b4 58      	LDY	syn_stk_h,X
e469  84 ff      	STY	synpag+1
e46b  b4 80      	LDY	syn_stk_l,X
e46d  e8         	INX
e46e  10 da      	BPL	Le44a
e470  f0 b3      Le470:	BEQ	Le425
e472  c9 7e      	CMP	#$7e	; 126 ~
e474  b0 22      	BCS	Le498
e476  ca         	DEX
e477  10 04      	BPL	Le47d
e479  a0 06      	LDY	#$06	; 6 .
e47b  10 29      	BPL	go_errmess_2
e47d  94 80      Le47d:	STY	syn_stk_l,X
e47f  a4 ff      	LDY	synpag+1
e481  94 58      	STY	syn_stk_h,X
e483  a4 c8      	LDY	text_index
e485  94 a8      	STY	txtndxstk,X
e487  a4 f1      	LDY	token_index
e489  94 d1      	STY	tokndxstk,X
e48b  29 1f      	AND	#$1f	; 31 .
e48d  a8         	TAY
e48e  b9 20 ec   	LDA	syntabl_index,Y

e491  0a         Se491:	ASL
e492  a8         	TAY
e493  a9 76      	LDA	#$76	; 118 v
e495  2a         	ROL
e496  85 ff      	STA	synpag+1
e498  d0 01      Le498:	BNE	Le49b
e49a  c8         	INY
e49b  c8         Le49b:	INY
e49c  86 fd      Le49c:	STX	synstkdx
e49e  b1 fe      	LDA	(synpag),Y
e4a0  30 84      	BMI	Le426
e4a2  d0 05      	BNE	Le4a9
e4a4  a0 0e      	LDY	#$0e	; 14 .
e4a6  4c e0 e3   go_errmess_2:	JMP	print_err_msg
e4a9  c9 03      Le4a9:	CMP	#$03	; 3 .
e4ab  b0 c3      	BCS	Le470
e4ad  4a         	LSR
e4ae  a6 c8      	LDX	text_index
e4b0  e8         	INX
e4b1  bd 00 02   Le4b1:	LDA	buffer,X
e4b4  90 04      	BCC	Le4ba
e4b6  c9 a2      	CMP	#$a2	; 162 "
e4b8  f0 0a      	BEQ	Le4c4
e4ba  c9 df      Le4ba:	CMP	#$df	; 223 _
e4bc  f0 06      	BEQ	Le4c4
e4be  86 c8      	STX	text_index
e4c0  20 1c e4   Le4c0:	JSR	put_token
e4c3  c8         	INY
e4c4  88         Le4c4:	DEY
e4c5  a6 fd      	LDX	synstkdx
e4c7  b1 fe      Le4c7:	LDA	(synpag),Y
e4c9  88         	DEY
e4ca  0a         	ASL
e4cb  10 cf      	BPL	Le49c
e4cd  b4 58      Le4cd:	LDY	syn_stk_h,X
e4cf  84 ff      	STY	synpag+1
e4d1  b4 80      	LDY	syn_stk_l,X
e4d3  e8         	INX
e4d4  b1 fe      	LDA	(synpag),Y
e4d6  29 9f      	AND	#$9f	; 159 .
e4d8  d0 ed      	BNE	Le4c7
e4da  85 f2      	STA	pcon
e4dc  85 f3      	STA	pcon+1
e4de  98         	TYA
e4df  48         	PHA
e4e0  86 fd      	STX	synstkdx
e4e2  b4 d0      	LDY	srch,X
e4e4  84 c9      	STY	leadbl
e4e6  18         	CLC
e4e7  a9 0a      Le4e7:	LDA	#$0a	; 10 .
e4e9  85 f9      	STA	char
e4eb  a2 00      	LDX	#$00	; 0 .
e4ed  c8         	INY
e4ee  b9 00 02   	LDA	buffer,Y
e4f1  29 0f      	AND	#$0f	; 15 .
e4f3  65 f2      Le4f3:	ADC	pcon
e4f5  48         	PHA
e4f6  8a         	TXA
e4f7  65 f3      	ADC	pcon+1
e4f9  30 1c      	BMI	Le517
e4fb  aa         	TAX
e4fc  68         	PLA
e4fd  c6 f9      	DEC	char
e4ff  d0 f2      	BNE	Le4f3
e501  85 f2      	STA	pcon
e503  86 f3      	STX	pcon+1
e505  c4 f1      	CPY	token_index
e507  d0 de      	BNE	Le4e7
e509  a4 c9      	LDY	leadbl
e50b  c8         	INY
e50c  84 f1      	STY	token_index
e50e  20 1c e4   	JSR	put_token
e511  68         	PLA
e512  a8         	TAY
e513  a5 f3      	LDA	pcon+1
e515  b0 a9      	BCS	Le4c0
e517  a0 00      Le517:	LDY	#$00	; 0 .
e519  10 8b      	BPL	go_errmess_2

e51b  85 f3      prdec:	STA	pcon+1
e51d  86 f2      	STX	pcon
e51f  a2 04      	LDX	#$04	; 4 .
e521  86 c9      	STX	leadbl
e523  a9 b0      Le523:	LDA	#$b0	; 176 0
e525  85 f9      	STA	char
e527  a5 f2      Le527:	LDA	pcon
e529  dd 63 e5   	CMP	dectabl,X
e52c  a5 f3      	LDA	pcon+1
e52e  fd 68 e5   	SBC	dectabh,X
e531  90 0d      	BCC	Le540
e533  85 f3      	STA	pcon+1
e535  a5 f2      	LDA	pcon
e537  fd 63 e5   	SBC	dectabl,X
e53a  85 f2      	STA	pcon
e53c  e6 f9      	INC	char
e53e  d0 e7      	BNE	Le527
e540  a5 f9      Le540:	LDA	char
e542  e8         	INX
e543  ca         	DEX
e544  f0 0e      	BEQ	Le554
e546  c9 b0      	CMP	#$b0	; 176 0
e548  f0 02      	BEQ	Le54c
e54a  85 c9      	STA	leadbl
e54c  24 c9      Le54c:	BIT	leadbl
e54e  30 04      	BMI	Le554
e550  a5 fa      	LDA	leadzr
e552  f0 0b      	BEQ	Le55f
e554  20 c9 e3   Le554:	JSR	cout
e557  24 f8      	BIT	auto_flag
e559  10 04      	BPL	Le55f
e55b  99 00 02   	STA	buffer,Y
e55e  c8         	INY
e55f  ca         Le55f:	DEX
e560  10 c1      	BPL	Le523
e562  60         	RTS
e563             dectabl:	.byte	$01,$0a,$64,$e8,$10         	; "..dh."
e568             dectabh:	.byte	$00,$00,$00,$03,$27         	; "....'"

e56d  a5 ca      find_line:	LDA	pp
e56f  85 e6      	STA	p3
e571  a5 cb      	LDA	pp+1
e573  85 e7      	STA	p3+1

e575  e8         find_line1:	INX

e576  a5 e7      find_line2:	LDA	p3+1
e578  85 e5      	STA	p2+1
e57a  a5 e6      	LDA	p3
e57c  85 e4      	STA	p2
e57e  c5 4c      	CMP	himem
e580  a5 e5      	LDA	p2+1
e582  e5 4d      	SBC	himem+1
e584  b0 26      	BCS	Le5ac
e586  a0 01      	LDY	#$01	; 1 .
e588  b1 e4      	LDA	(p2),Y
e58a  e5 ce      	SBC	acc
e58c  c8         	INY
e58d  b1 e4      	LDA	(p2),Y
e58f  e5 cf      	SBC	acc+1
e591  b0 19      	BCS	Le5ac
e593  a0 00      	LDY	#$00	; 0 .
e595  a5 e6      	LDA	p3
e597  71 e4      	ADC	(p2),Y
e599  85 e6      	STA	p3
e59b  90 03      	BCC	Le5a0
e59d  e6 e7      	INC	p3+1
e59f  18         	CLC
e5a0  c8         Le5a0:	INY
e5a1  a5 ce      	LDA	acc
e5a3  f1 e4      	SBC	(p2),Y
e5a5  c8         	INY
e5a6  a5 cf      	LDA	acc+1
e5a8  f1 e4      	SBC	(p2),Y
e5aa  b0 ca      	BCS	find_line2
e5ac  60         Le5ac:	RTS

e5ad  46 f8      new_cmd:	LSR	auto_flag
e5af  a5 4c      	LDA	himem
e5b1  85 ca      	STA	pp
e5b3  a5 4d      	LDA	himem+1
e5b5  85 cb      	STA	pp+1

e5b7  a5 4a      clr:	LDA	lomem
e5b9  85 cc      	STA	pv
e5bb  a5 4b      	LDA	lomem+1
e5bd  85 cd      	STA	pv+1
e5bf  a9 00      	LDA	#$00	; 0 .
e5c1  85 fb      	STA	for_nest_count
e5c3  85 fc      	STA	gosub_nest_count
e5c5  85 fe      	STA	synpag
e5c7  a9 00      	LDA	#$00	; 0 .
e5c9  85 1d      	STA	Z1d
e5cb  60         	RTS
e5cc  a5 d0      Le5cc:	LDA	srch
e5ce  69 05      	ADC	#$05	; 5 .
e5d0  85 d2      	STA	srch2
e5d2  a5 d1      	LDA	tokndxstk
e5d4  69 00      	ADC	#$00	; 0 .
e5d6  85 d3      	STA	srch2+1
e5d8  a5 d2      	LDA	srch2
e5da  c5 ca      	CMP	pp
e5dc  a5 d3      	LDA	srch2+1
e5de  e5 cb      	SBC	pp+1
e5e0  90 03      	BCC	Le5e5
e5e2  4c 6b e3   	JMP	Le36b
e5e5  a5 ce      Le5e5:	LDA	acc
e5e7  91 d0      	STA	(srch),Y
e5e9  a5 cf      	LDA	acc+1
e5eb  c8         	INY
e5ec  91 d0      	STA	(srch),Y
e5ee  a5 d2      	LDA	srch2
e5f0  c8         	INY
e5f1  91 d0      	STA	(srch),Y
e5f3  a5 d3      	LDA	srch2+1
e5f5  c8         	INY
e5f6  91 d0      	STA	(srch),Y
e5f8  a9 00      	LDA	#$00	; 0 .
e5fa  c8         	INY
e5fb  91 d0      	STA	(srch),Y
e5fd  c8         	INY
e5fe  91 d0      	STA	(srch),Y
e600  a5 d2      	LDA	srch2
e602  85 cc      	STA	pv
e604  a5 d3      	LDA	srch2+1
e606  85 cd      	STA	pv+1
e608  a5 d0      	LDA	srch
e60a  90 43      	BCC	Le64f
e60c  85 ce      execute_var:	STA	acc
e60e  84 cf      	STY	acc+1
e610  20 ff e6   	JSR	get_next_prog_byte
e613  30 0e      	BMI	Le623
e615  c9 40      	CMP	#$40	; 64 @
e617  f0 0a      	BEQ	Le623
e619  4c 28 e6   	JMP	Le628
e61c             	.byte	$06,$c9,$49,$d0,$07,$a9,$49   	; ".IIP.)I"
e623  85 cf      Le623:	STA	acc+1
e625  20 ff e6   	JSR	get_next_prog_byte
e628  a5 4b      Le628:	LDA	lomem+1
e62a  85 d1      	STA	tokndxstk
e62c  a5 4a      	LDA	lomem
e62e  85 d0      Le62e:	STA	srch
e630  c5 cc      	CMP	pv
e632  a5 d1      	LDA	tokndxstk
e634  e5 cd      	SBC	pv+1
e636  b0 94      	BCS	Le5cc
e638  b1 d0      	LDA	(srch),Y
e63a  c8         	INY
e63b  c5 ce      	CMP	acc
e63d  d0 06      	BNE	Le645
e63f  b1 d0      	LDA	(srch),Y
e641  c5 cf      	CMP	acc+1
e643  f0 0e      	BEQ	Le653
e645  c8         Le645:	INY
e646  b1 d0      	LDA	(srch),Y
e648  48         	PHA
e649  c8         	INY
e64a  b1 d0      	LDA	(srch),Y
e64c  85 d1      	STA	tokndxstk
e64e  68         	PLA
e64f  a0 00      Le64f:	LDY	#$00	; 0 .
e651  f0 db      	BEQ	Le62e
e653  a5 d0      Le653:	LDA	srch
e655  69 03      	ADC	#$03	; 3 .
e657  20 0a e7   	JSR	push_a_noun_stk
e65a  a5 d1      	LDA	tokndxstk
e65c  69 00      	ADC	#$00	; 0 .
e65e  95 78      	STA	noun_stk_h_str,X
e660  a5 cf      	LDA	acc+1
e662  c9 40      	CMP	#$40	; 64 @
e664  d0 1c      	BNE	fetch_prog_byte
e666  88         	DEY
e667  98         	TYA
e668  20 0a e7   	JSR	push_a_noun_stk
e66b  88         	DEY
e66c  94 78      	STY	noun_stk_h_str,X
e66e  a0 03      	LDY	#$03	; 3 .
e670  f6 78      Le670:	INC	noun_stk_h_str,X
e672  c8         	INY
e673  b1 d0      	LDA	(srch),Y
e675  30 f9      	BMI	Le670
e677  10 09      	BPL	fetch_prog_byte

e679  a9 00      execute_stmt:	LDA	#$00	; 0 .
e67b  85 d4      	STA	if_flag
e67d  85 d5      	STA	cr_flag
e67f  a2 20      	LDX	#$20	; 32  
e681  48         push_old_verb:	PHA
e682  a0 00      fetch_prog_byte:	LDY	#$00	; 0 .
e684  b1 e0      	LDA	(pverb),Y
e686  10 18      Le686:	BPL	execute_token
e688  0a         	ASL
e689  30 81      	BMI	execute_var
e68b  20 ff e6   	JSR	get_next_prog_byte
e68e  20 08 e7   	JSR	push_ya_noun_stk
e691  20 ff e6   	JSR	get_next_prog_byte
e694  95 a0      	STA	noun_stk_h_int,X
e696  24 d4      Le696:	BIT	if_flag
e698  10 01      	BPL	Le69b
e69a  ca         	DEX
e69b  20 ff e6   Le69b:	JSR	get_next_prog_byte
e69e  b0 e6      	BCS	Le686
e6a0  c9 28      execute_token:	CMP	#$28	; 40 (
e6a2  d0 1f      	BNE	execute_verb
e6a4  a5 e0      	LDA	pverb
e6a6  20 0a e7   	JSR	push_a_noun_stk
e6a9  a5 e1      	LDA	pverb+1
e6ab  95 78      	STA	noun_stk_h_str,X
e6ad  24 d4      	BIT	if_flag
e6af  30 0b      	BMI	Le6bc
e6b1  a9 01      	LDA	#$01	; 1 .
e6b3  20 0a e7   	JSR	push_a_noun_stk
e6b6  a9 00      	LDA	#$00	; 0 .
e6b8  95 78      	STA	noun_stk_h_str,X
e6ba  f6 78      Le6ba:	INC	noun_stk_h_str,X
e6bc  20 ff e6   Le6bc:	JSR	get_next_prog_byte
e6bf  30 f9      	BMI	Le6ba
e6c1  b0 d3      	BCS	Le696
e6c3  24 d4      execute_verb:	BIT	if_flag
e6c5  10 06      	BPL	Le6cd
e6c7  c9 04      	CMP	#$04	; 4 .
e6c9  b0 d0      	BCS	Le69b
e6cb  46 d4      	LSR	if_flag
e6cd  a8         Le6cd:	TAY
e6ce  85 d6      	STA	current_verb
e6d0  b9 98 e9   	LDA	verb_prec_tbl,Y
e6d3  29 55      	AND	#$55	; 85 U
e6d5  0a         	ASL
e6d6  85 d7      	STA	precedence
e6d8  68         Le6d8:	PLA
e6d9  a8         	TAY
e6da  b9 98 e9   	LDA	verb_prec_tbl,Y
e6dd  29 aa      	AND	#$aa	; 170 *
e6df  c5 d7      	CMP	precedence
e6e1  b0 09      	BCS	do_verb
e6e3  98         	TYA
e6e4  48         	PHA
e6e5  20 ff e6   	JSR	get_next_prog_byte
e6e8  a5 d6      	LDA	current_verb
e6ea  90 95      	BCC	push_old_verb
e6ec  b9 10 ea   do_verb:	LDA	verb_adr_l,Y
e6ef  85 ce      	STA	acc
e6f1  b9 88 ea   	LDA	verb_adr_h,Y
e6f4  85 cf      	STA	acc+1
e6f6  20 fc e6   	JSR	Se6fc
e6f9  4c d8 e6   	JMP	Le6d8

e6fc  6c ce 00   Se6fc:	JMP	(acc)

e6ff  e6 e0      get_next_prog_byte:	INC	pverb
e701  d0 02      	BNE	Le705
e703  e6 e1      	INC	pverb+1
e705  b1 e0      Le705:	LDA	(pverb),Y
e707  60         	RTS

e708  94 77      push_ya_noun_stk:	STY	syn_stk_h+31,X

e70a  ca         push_a_noun_stk:	DEX
e70b  30 03      	BMI	Le710
e70d  95 50      	STA	noun_stk_l,X
e70f  60         	RTS
e710  a0 66      Le710:	LDY	#$66	; 102 f
e712  4c e0 e3   go_errmess_3:	JMP	print_err_msg

e715  a0 00      get16bit:	LDY	#$00	; 0 .
e717  b5 50      	LDA	noun_stk_l,X
e719  85 ce      	STA	acc
e71b  b5 a0      	LDA	noun_stk_h_int,X
e71d  85 cf      	STA	acc+1
e71f  b5 78      	LDA	noun_stk_h_str,X
e721  f0 0e      	BEQ	Le731
e723  85 cf      	STA	acc+1
e725  b1 ce      	LDA	(acc),Y
e727  48         	PHA
e728  c8         	INY
e729  b1 ce      	LDA	(acc),Y
e72b  85 cf      	STA	acc+1
e72d  68         	PLA
e72e  85 ce      	STA	acc
e730  88         	DEY
e731  e8         Le731:	INX
e732  60         	RTS

e733  20 4a e7   eq_op:	JSR	neq_op

e736  20 15 e7   not_op:	JSR	get16bit
e739  98         	TYA
e73a  20 08 e7   	JSR	push_ya_noun_stk
e73d  95 a0      	STA	noun_stk_h_int,X
e73f  c5 ce      	CMP	acc
e741  d0 06      	BNE	Le749
e743  c5 cf      	CMP	acc+1
e745  d0 02      	BNE	Le749
e747  f6 50      	INC	noun_stk_l,X
e749  60         Le749:	RTS

e74a  20 82 e7   neq_op:	JSR	subtract
e74d  20 59 e7   	JSR	sgn_fn

e750  20 15 e7   abs_fn:	JSR	get16bit
e753  24 cf      	BIT	acc+1
e755  30 1b      	BMI	Se772
e757  ca         Le757:	DEX
e758  60         Le758:	RTS

e759  20 15 e7   sgn_fn:	JSR	get16bit
e75c  a5 cf      	LDA	acc+1
e75e  d0 04      	BNE	Le764
e760  a5 ce      	LDA	acc
e762  f0 f3      	BEQ	Le757
e764  a9 ff      Le764:	LDA	#$ff	; 255 .
e766  20 08 e7   	JSR	push_ya_noun_stk
e769  95 a0      	STA	noun_stk_h_int,X
e76b  24 cf      	BIT	acc+1
e76d  30 e9      	BMI	Le758

e76f  20 15 e7   negate:	JSR	get16bit

e772  98         Se772:	TYA
e773  38         	SEC
e774  e5 ce      	SBC	acc
e776  20 08 e7   	JSR	push_ya_noun_stk
e779  98         	TYA
e77a  e5 cf      	SBC	acc+1
e77c  50 23      	BVC	Le7a1
e77e  a0 00      Le77e:	LDY	#$00	; 0 .
e780  10 90      	BPL	go_errmess_3

e782  20 6f e7   subtract:	JSR	negate

e785  20 15 e7   add:	JSR	get16bit
e788  a5 ce      	LDA	acc
e78a  85 da      	STA	aux
e78c  a5 cf      	LDA	acc+1
e78e  85 db      	STA	aux+1
e790  20 15 e7   	JSR	get16bit

e793  18         Se793:	CLC
e794  a5 ce      	LDA	acc
e796  65 da      	ADC	aux
e798  20 08 e7   	JSR	push_ya_noun_stk
e79b  a5 cf      	LDA	acc+1
e79d  65 db      	ADC	aux+1
e79f  70 dd      	BVS	Le77e
e7a1  95 a0      Le7a1:	STA	noun_stk_h_int,X

e7a3  60         unary_pos:	RTS

e7a4  20 15 e7   tab_fn:	JSR	get16bit
e7a7  a4 ce      	LDY	acc
e7a9  f0 05      	BEQ	Le7b0
e7ab  88         	DEY
e7ac  a5 cf      	LDA	acc+1
e7ae  f0 0c      	BEQ	Le7bc
e7b0  60         Le7b0:	RTS

e7b1  a5 24      tabout:	LDA	ch
e7b3  09 07      	ORA	#$07	; 7 .
e7b5  a8         	TAY
e7b6  c8         	INY
e7b7  a9 a0      Le7b7:	LDA	#$a0	; 160  
e7b9  20 c9 e3   	JSR	cout
e7bc  c4 24      Le7bc:	CPY	ch
e7be  b0 f7      	BCS	Le7b7
e7c0  60         	RTS

e7c1  20 b1 e7   print_com_num:	JSR	tabout

e7c4  20 15 e7   print_num:	JSR	get16bit
e7c7  a5 cf      	LDA	acc+1
e7c9  10 0a      	BPL	Le7d5
e7cb  a9 ad      	LDA	#$ad	; 173 -
e7cd  20 c9 e3   	JSR	cout
e7d0  20 72 e7   	JSR	Se772
e7d3  50 ef      	BVC	print_num
e7d5  88         Le7d5:	DEY
e7d6  84 d5      	STY	cr_flag
e7d8  86 cf      	STX	acc+1
e7da  a6 ce      	LDX	acc
e7dc  20 1b e5   	JSR	prdec
e7df  a6 cf      	LDX	acc+1
e7e1  60         	RTS

e7e2  20 15 e7   auto_cmd:	JSR	get16bit
e7e5  a5 ce      	LDA	acc
e7e7  85 f6      	STA	auto_ln
e7e9  a5 cf      	LDA	acc+1
e7eb  85 f7      	STA	auto_ln+1
e7ed  88         	DEY
e7ee  84 f8      	STY	auto_flag
e7f0  c8         	INY
e7f1  a9 0a      	LDA	#$0a	; 10 .
e7f3  85 f4      Le7f3:	STA	auto_inc
e7f5  84 f5      	STY	auto_inc+1
e7f7  60         	RTS

e7f8  20 15 e7   auto_com:	JSR	get16bit
e7fb  a5 ce      	LDA	acc
e7fd  a4 cf      	LDY	acc+1
e7ff  10 f2      	BPL	Le7f3

e801  20 15 e7   var_assign:	JSR	get16bit
e804  b5 50      	LDA	noun_stk_l,X
e806  85 da      	STA	aux
e808  b5 78      	LDA	noun_stk_h_str,X
e80a  85 db      	STA	aux+1
e80c  a5 ce      	LDA	acc
e80e  91 da      	STA	(aux),Y
e810  c8         	INY
e811  a5 cf      	LDA	acc+1
e813  91 da      	STA	(aux),Y
e815  e8         	INX

e816  60         Te816:	RTS

e817  68         begin_line:	PLA
e818  68         	PLA

e819  24 d5      colon:	BIT	cr_flag
e81b  10 05      	BPL	Le822

e81d  20 cd e3   print_cr:	JSR	crout

e820  46 d5      print_semi:	LSR	cr_flag
e822  60         Le822:	RTS

e823  a0 ff      left_paren:	LDY	#$ff	; 255 .
e825  84 d7      	STY	precedence

e827  60         right_paren:	RTS

e828  20 cd ef   if_stmt:	JSR	Sefcd
e82b  f0 07      	BEQ	Le834
e82d  a9 25      	LDA	#$25	; 37 %
e82f  85 d6      	STA	current_verb
e831  88         	DEY
e832  84 d4      	STY	if_flag
e834  e8         Le834:	INX
e835  60         	RTS
e836  a5 ca      run_warm:	LDA	pp
e838  a4 cb      	LDY	pp+1
e83a  d0 5a      	BNE	Le896

e83c  a0 41      gosub_stmt:	LDY	#$41	; 65 A
e83e  a5 fc      	LDA	gosub_nest_count
e840  c9 08      	CMP	#$08	; 8 .
e842  b0 5e      	BCS	go_errmess_4
e844  a8         	TAY
e845  e6 fc      	INC	gosub_nest_count
e847  a5 e0      	LDA	pverb
e849  99 00 01   	STA	gstk_pverbl,Y
e84c  a5 e1      	LDA	pverb+1
e84e  99 08 01   	STA	gstk_pverbh,Y
e851  a5 dc      	LDA	pline
e853  99 10 01   	STA	gstk_plinel,Y
e856  a5 dd      	LDA	pline+1
e858  99 18 01   	STA	gstk_plineh,Y

e85b  20 15 e7   goto_stmt:	JSR	get16bit
e85e  20 6d e5   	JSR	find_line
e861  90 04      	BCC	Le867
e863  a0 37      	LDY	#$37	; 55 7
e865  d0 3b      	BNE	go_errmess_4
e867  a5 e4      Le867:	LDA	p2
e869  a4 e5      	LDY	p2+1
e86b  85 dc      run_loop:	STA	pline
e86d  84 dd      	STY	pline+1
e86f  2c 11 d0   	BIT	Dd011
e872  30 4f      	BMI	Le8c3
e874  18         	CLC
e875  69 03      	ADC	#$03	; 3 .
e877  90 01      	BCC	Le87a
e879  c8         	INY
e87a  a2 ff      Le87a:	LDX	#$ff	; 255 .
e87c  86 d9      	STX	run_flag
e87e  9a         	TXS
e87f  85 e0      	STA	pverb
e881  84 e1      	STY	pverb+1
e883  20 79 e6   Le883:	JSR	execute_stmt
e886  24 d9      	BIT	run_flag
e888  10 49      	BPL	end_stmt
e88a  18         	CLC
e88b  a0 00      	LDY	#$00	; 0 .
e88d  a5 dc      	LDA	pline
e88f  71 dc      	ADC	(pline),Y
e891  a4 dd      	LDY	pline+1
e893  90 01      	BCC	Le896
e895  c8         	INY
e896  c5 4c      Le896:	CMP	himem
e898  d0 d1      	BNE	run_loop
e89a  c4 4d      	CPY	himem+1
e89c  d0 cd      	BNE	run_loop
e89e  a0 34      	LDY	#$34	; 52 4
e8a0  46 d9      	LSR	run_flag
e8a2  4c e0 e3   go_errmess_4:	JMP	print_err_msg

e8a5  a0 4a      return_stmt:	LDY	#$4a	; 74 J
e8a7  a5 fc      	LDA	gosub_nest_count
e8a9  f0 f7      	BEQ	go_errmess_4
e8ab  c6 fc      	DEC	gosub_nest_count
e8ad  a8         	TAY
e8ae  b9 0f 01   	LDA	gstk_plinel-1,Y
e8b1  85 dc      	STA	pline
e8b3  b9 17 01   	LDA	gstk_plineh-1,Y
e8b6  85 dd      	STA	pline+1
e8b8  be ff 00   	LDX	synpag+1,Y
e8bb  b9 07 01   	LDA	gstk_pverbh-1,Y
e8be  a8         Le8be:	TAY
e8bf  8a         	TXA
e8c0  4c 7a e8   	JMP	Le87a
e8c3  a0 63      Le8c3:	LDY	#$63	; 99 c
e8c5  20 c4 e3   	JSR	Se3c4
e8c8  a0 01      	LDY	#$01	; 1 .
e8ca  b1 dc      	LDA	(pline),Y
e8cc  aa         	TAX
e8cd  c8         	INY
e8ce  b1 dc      	LDA	(pline),Y
e8d0  20 1b e5   	JSR	prdec

e8d3  4c b3 e2   end_stmt:	JMP	warm
e8d6  c6 fb      Le8d6:	DEC	for_nest_count

e8d8  a0 5b      next_stmt:	LDY	#$5b	; 91 [
e8da  a5 fb      	LDA	for_nest_count
e8dc  f0 c4      Le8dc:	BEQ	go_errmess_4
e8de  a8         	TAY
e8df  b5 50      	LDA	noun_stk_l,X
e8e1  d9 1f 01   	CMP	fstk_varl-1,Y
e8e4  d0 f0      	BNE	Le8d6
e8e6  b5 78      	LDA	noun_stk_h_str,X
e8e8  d9 27 01   	CMP	fstk_varh-1,Y
e8eb  d0 e9      	BNE	Le8d6
e8ed  b9 2f 01   	LDA	fstk_stepl-1,Y
e8f0  85 da      	STA	aux
e8f2  b9 37 01   	LDA	fstk_steph-1,Y
e8f5  85 db      	STA	aux+1
e8f7  20 15 e7   	JSR	get16bit
e8fa  ca         	DEX
e8fb  20 93 e7   	JSR	Se793
e8fe  20 01 e8   	JSR	var_assign
e901  ca         	DEX
e902  a4 fb      	LDY	for_nest_count
e904  b9 67 01   	LDA	fstk_toh-1,Y
e907  95 9f      	STA	syn_stk_l+31,X
e909  b9 5f 01   	LDA	fstk_tol-1,Y
e90c  a0 00      	LDY	#$00	; 0 .
e90e  20 08 e7   	JSR	push_ya_noun_stk
e911  20 82 e7   	JSR	subtract
e914  20 59 e7   	JSR	sgn_fn
e917  20 15 e7   	JSR	get16bit
e91a  a4 fb      	LDY	for_nest_count
e91c  a5 ce      	LDA	acc
e91e  f0 05      	BEQ	Le925
e920  59 37 01   	EOR	fstk_steph-1,Y
e923  10 12      	BPL	Le937
e925  b9 3f 01   Le925:	LDA	fstk_plinel-1,Y
e928  85 dc      	STA	pline
e92a  b9 47 01   	LDA	fstk_plineh-1,Y
e92d  85 dd      	STA	pline+1
e92f  be 4f 01   	LDX	fstk_pverbl-1,Y
e932  b9 57 01   	LDA	fstk_pverbh-1,Y
e935  d0 87      	BNE	Le8be
e937  c6 fb      Le937:	DEC	for_nest_count
e939  60         	RTS

e93a  a0 54      for_stmt:	LDY	#$54	; 84 T
e93c  a5 fb      	LDA	for_nest_count
e93e  c9 08      	CMP	#$08	; 8 .
e940  f0 9a      	BEQ	Le8dc
e942  e6 fb      	INC	for_nest_count
e944  a8         	TAY
e945  b5 50      	LDA	noun_stk_l,X
e947  99 20 01   	STA	fstk_varl,Y
e94a  b5 78      	LDA	noun_stk_h_str,X
e94c  99 28 01   	STA	fstk_varh,Y
e94f  60         	RTS

e950  20 15 e7   to_clause:	JSR	get16bit
e953  a4 fb      	LDY	for_nest_count
e955  a5 ce      	LDA	acc
e957  99 5f 01   	STA	fstk_tol-1,Y
e95a  a5 cf      	LDA	acc+1
e95c  99 67 01   	STA	fstk_toh-1,Y
e95f  a9 01      	LDA	#$01	; 1 .
e961  99 2f 01   	STA	fstk_stepl-1,Y
e964  a9 00      	LDA	#$00	; 0 .
e966  99 37 01   Le966:	STA	fstk_steph-1,Y
e969  a5 dc      	LDA	pline
e96b  99 3f 01   	STA	fstk_plinel-1,Y
e96e  a5 dd      	LDA	pline+1
e970  99 47 01   	STA	fstk_plineh-1,Y
e973  a5 e0      	LDA	pverb
e975  99 4f 01   	STA	fstk_pverbl-1,Y
e978  a5 e1      	LDA	pverb+1
e97a  99 57 01   	STA	fstk_pverbh-1,Y
e97d  60         	RTS

e97e  20 15 e7   Te97e:	JSR	get16bit
e981  a4 fb      	LDY	for_nest_count
e983  a5 ce      	LDA	acc
e985  99 2f 01   	STA	fstk_stepl-1,Y
e988  a5 cf      	LDA	acc+1
e98a  4c 66 e9   	JMP	Le966
e98d             	.byte	$00,$00,$00,$00,$00,$00,$00,$00	; "........"
e995             	.byte	$00,$00,$00               	; "..."
e998             verb_prec_tbl:	.byte	$00,$00,$00,$ab,$03,$03,$03,$03	; "...+...."
e9a0             	.byte	$03,$03,$03,$03,$03,$03,$03,$03	; "........"
e9a8             	.byte	$03,$03,$3f,$3f,$c0,$c0,$3c,$3c	; "..??@@<<"
e9b0             	.byte	$3c,$3c,$3c,$3c,$3c,$30,$0f,$c0	; "<<<<<0.@"
e9b8             	.byte	$cc,$ff,$55,$00,$ab,$ab,$03,$03	; "L.U.++.."
e9c0             	.byte	$ff,$ff,$55,$ff,$ff,$55,$cf,$cf	; "..U..UOO"
e9c8             	.byte	$cf,$cf,$cf,$ff,$55,$c3,$c3,$c3	; "OOO.UCCC"
e9d0             	.byte	$55,$f0,$f0,$cf,$56,$56,$56,$55	; "UppOVVVU"
e9d8             	.byte	$ff,$ff,$55,$03,$03,$03,$03,$03	; "..U....."
e9e0             	.byte	$03,$03,$ff,$ff,$ff,$03,$03,$03	; "........"
e9e8             	.byte	$03,$03,$03,$03,$03,$03,$03,$03	; "........"
e9f0             	.byte	$03,$03,$03,$03,$03,$00,$ab,$03	; "......+."
e9f8             	.byte	$57,$03,$03,$03,$03,$07,$03,$03	; "W......."
ea00             	.byte	$03,$03,$03,$03,$03,$03,$03,$03	; "........"
ea08             	.byte	$03,$03,$aa,$ff,$ff,$ff,$ff,$ff	; "..*....."
ea10             verb_adr_l:	.byte	$17,$ff,$ff,$19,$5d,$35,$4b,$f2	; "....]5Kr"
ea18             	.byte	$ec,$87,$6f,$ad,$b7,$e2,$f8,$54	; "l.o-7bxT"
ea20             	.byte	$80,$96,$85,$82,$22,$10,$33,$4a	; "....".3J"
ea28             	.byte	$13,$06,$0b,$4a,$01,$40,$47,$7a	; "...J.@Gz"
ea30             	.byte	$00,$ff,$23,$09,$5b,$16,$b6,$cb	; "..#.[.6K"
ea38             	.byte	$ff,$ff,$fb,$ff,$ff,$24,$f6,$4e	; "..{..$vN"
ea40             	.byte	$59,$50,$00,$ff,$23,$a3,$6f,$36	; "YP..##o6"
ea48             	.byte	$23,$d7,$1c,$22,$c2,$ae,$ba,$23	; "#W."B.:#"
ea50             	.byte	$ff,$ff,$21,$30,$1e,$03,$c4,$20	; "..!0..D "
ea58             	.byte	$00,$c1,$ff,$ff,$ff,$a0,$30,$1e	; ".A... 0."
ea60             	.byte	$a4,$d3,$b6,$bc,$aa,$3a,$01,$50	; "$S6<*:.P"
ea68             	.byte	$7e,$d8,$d8,$a5,$3c,$ff,$16,$5b	; "~XX%<..["
ea70             	.byte	$28,$03,$c4,$1d,$00,$0c,$4e,$00	; "(.D...N."
ea78             	.byte	$3e,$00,$a6,$b0,$00,$bc,$c6,$57	; ">.&0.<FW"
ea80             	.byte	$8c,$01,$27,$ff,$ff,$ff,$ff,$ff	; "..'....."
ea88             verb_adr_h:	.byte	$e8,$ff,$ff,$e8,$e0,$e0,$e0,$ef	; "h..h```o"
ea90             	.byte	$ef,$e3,$e3,$e5,$e5,$e7,$e7,$ee	; "occeeggn"
ea98             	.byte	$ef,$ef,$e7,$e7,$e2,$ef,$e7,$e7	; "ooggbogg"
eaa0             	.byte	$ec,$ec,$ec,$e7,$ec,$ec,$ec,$e2	; "lllglllb"
eaa8             	.byte	$00,$ff,$e8,$e1,$e8,$e8,$ef,$eb	; "..hahhok"
eab0             	.byte	$ff,$ff,$e0,$ff,$ff,$ef,$ee,$ef	; "..`..ono"
eab8             	.byte	$e7,$e7,$00,$ff,$e8,$e7,$e7,$e7	; "gg..hggg"
eac0             	.byte	$e8,$e1,$e2,$ee,$ee,$ee,$ee,$e8	; "habnnnnh"
eac8             	.byte	$ff,$ff,$e1,$e1,$ef,$ee,$e7,$e8	; "..aaongh"
ead0             	.byte	$ee,$e7,$ff,$ff,$ff,$ee,$e1,$ef	; "ng...nao"
ead8             	.byte	$e7,$e8,$ef,$ef,$eb,$e9,$e8,$e9	; "ghookihi"
eae0             	.byte	$e9,$e8,$e8,$e8,$e8,$ff,$e8,$e8	; "ihhhh.hh"
eae8             	.byte	$e8,$ee,$e7,$e8,$ef,$ef,$ee,$ef	; "hnghoono"
eaf0             	.byte	$ee,$ef,$ee,$ee,$ef,$ee,$ee,$ee	; "nonnonnn"
eaf8             	.byte	$e1,$e8,$e8,$ff,$ff,$ff,$ff,$ff	; "ahh....."
eb00             error_msg_tbl:	.byte	$be,$b3,$b2,$b7,$b6,$37,$d4,$cf	; ">32767TO"
eb08             	.byte	$cf,$a0,$cc,$cf,$ce,$47,$d3,$d9	; "O LONGSY"
eb10             	.byte	$ce,$d4,$c1,$58,$cd,$c5,$cd,$a0	; "NTAXMEM "
eb18             	.byte	$c6,$d5,$cc,$4c,$d4,$cf,$cf,$a0	; "FULLTOO "
eb20             	.byte	$cd,$c1,$ce,$d9,$a0,$d0,$c1,$d2	; "MANY PAR"
eb28             	.byte	$c5,$ce,$53,$d3,$d4,$d2,$c9,$ce	; "ENSSTRIN"
eb30             	.byte	$47,$ce,$cf,$a0,$c5,$ce,$44,$c2	; "GNO ENDB"
eb38             	.byte	$c1,$c4,$a0,$c2,$d2,$c1,$ce,$c3	; "AD BRANC"
eb40             	.byte	$48,$be,$b8,$a0,$c7,$cf,$d3,$d5	; "H>8 GOSU"
eb48             	.byte	$c2,$53,$c2,$c1,$c4,$a0,$d2,$c5	; "BSBAD RE"
eb50             	.byte	$d4,$d5,$d2,$4e,$be,$b8,$a0,$c6	; "TURN>8 F"
eb58             	.byte	$cf,$d2,$53,$c2,$c1,$c4,$a0,$ce	; "ORSBAD N"
eb60             	.byte	$c5,$d8,$54,$d3,$d4,$cf,$d0,$d0	; "EXTSTOPP"
eb68             	.byte	$c5,$c4,$a0,$c1,$d4,$20,$aa,$aa	; "ED AT **"
eb70             	.byte	$aa,$20,$a0,$c5,$d2,$d2,$0d,$be	; "*  ERR.>"
eb78             	.byte	$b2,$b5,$35,$d2,$c1,$ce,$c7,$45	; "255RANGE"
eb80             	.byte	$c4,$c9,$4d,$d3,$d4,$d2,$a0,$cf	; "DIMSTR O"
eb88             	.byte	$d6,$c6,$4c,$dc,$0d,$d2,$c5,$d4	; "VFL\.RET"
eb90             	.byte	$d9,$d0,$c5,$a0,$cc,$c9,$ce,$c5	; "YPE LINE"
eb98             	.byte	$8d,$3f                  	; ".?"
eb9a  46 d9      Leb9a:	LSR	run_flag
eb9c  90 03      	BCC	Leba1
eb9e  4c c3 e8   	JMP	Le8c3
eba1  a6 cf      Leba1:	LDX	acc+1
eba3  9a         	TXS
eba4  a6 ce      	LDX	acc
eba6  a0 8d      	LDY	#$8d	; 141 .
eba8  d0 02      	BNE	Lebac

ebaa  a0 99      input_num_stmt:	LDY	#$99	; 153 .
ebac  20 c4 e3   Lebac:	JSR	Se3c4
ebaf  86 ce      	STX	acc
ebb1  ba         	TSX
ebb2  86 cf      	STX	acc+1
ebb4  a0 fe      	LDY	#$fe	; 254 ~
ebb6  84 d9      	STY	run_flag
ebb8  c8         	INY
ebb9  84 c8      	STY	text_index
ebbb  20 99 e2   	JSR	Se299
ebbe  84 f1      	STY	token_index
ebc0  a2 20      	LDX	#$20	; 32  
ebc2  a9 30      	LDA	#$30	; 48 0
ebc4  20 91 e4   	JSR	Se491
ebc7  e6 d9      	INC	run_flag
ebc9  a6 ce      	LDX	acc

ebcb  a4 c8      input_num_comma:	LDY	text_index
ebcd  0a         	ASL
ebce  85 ce      Lebce:	STA	acc
ebd0  c8         	INY
ebd1  b9 00 02   	LDA	buffer,Y
ebd4  c9 74      	CMP	#$74	; 116 t
ebd6  f0 d2      	BEQ	input_num_stmt
ebd8  49 b0      	EOR	#$b0	; 176 0
ebda  c9 0a      	CMP	#$0a	; 10 .
ebdc  b0 f0      	BCS	Lebce
ebde  c8         	INY
ebdf  c8         	INY
ebe0  84 c8      	STY	text_index
ebe2  b9 00 02   	LDA	buffer,Y
ebe5  48         	PHA
ebe6  b9 ff 01   	LDA	buffer-1,Y
ebe9  a0 00      	LDY	#$00	; 0 .
ebeb  20 08 e7   	JSR	push_ya_noun_stk
ebee  68         	PLA
ebef  95 a0      	STA	noun_stk_h_int,X
ebf1  a5 ce      	LDA	acc
ebf3  c9 c7      	CMP	#$c7	; 199 G
ebf5  d0 03      	BNE	Lebfa
ebf7  20 6f e7   	JSR	negate
ebfa  4c 01 e8   Lebfa:	JMP	var_assign
ebfd             	.byte	$ff,$ff,$ff,$50            	; "...P"

ec01  20 13 ec   Tec01:	JSR	Tec13
ec04  d0 15      	BNE	Lec1b

ec06  20 0b ec   Tec06:	JSR	Tec0b
ec09  d0 10      	BNE	Lec1b

ec0b  20 82 e7   Tec0b:	JSR	subtract
ec0e  20 6f e7   	JSR	negate
ec11  50 03      	BVC	Lec16

ec13  20 82 e7   Tec13:	JSR	subtract
ec16  20 59 e7   Lec16:	JSR	sgn_fn
ec19  56 50      	LSR	noun_stk_l,X
ec1b  4c 36 e7   Lec1b:	JMP	not_op
ec1e             	.byte	$ff,$ff                  	; ".."
ec20             syntabl_index:	.byte	$c1,$ff,$7f,$d1,$cc,$c7,$cf,$ce	; "A..QLGON"
ec28             	.byte	$c5,$9a,$98,$8b,$96,$95,$93,$bf	; "E......?"
ec30             	.byte	$b2,$32,$2d,$2b,$bc,$b0,$ac,$be	; "22-+<0,>"
ec38             	.byte	$35,$8e,$61,$ff,$ff,$ff,$dd,$fb	; "5.a...]{"

ec40  20 c9 ef   Tec40:	JSR	Sefc9
ec43  15 4f      	ORA	rnd+1,X
ec45  10 05      	BPL	Lec4c

ec47  20 c9 ef   Tec47:	JSR	Sefc9
ec4a  35 4f      	AND	rnd+1,X
ec4c  95 50      Lec4c:	STA	noun_stk_l,X
ec4e  10 cb      	BPL	Lec1b
ec50  4c c9 ef   	JMP	Sefc9
ec53             	.byte	$40,$60,$8d,$60,$8b,$00,$7e,$8c	; "@`.`..~."
ec5b             	.byte	$33,$00,$00,$60,$03,$bf,$12,$00	; "3..`.?.."
ec63             	.byte	$40,$89,$c9,$47,$9d,$17,$68,$9d	; "@.IG..h."
ec6b             	.byte	$0a,$00,$40,$60,$8d,$60,$8b,$00	; "..@`.`.."
ec73             	.byte	$7e,$8c,$3c,$00,$00,$60,$03,$bf	; "~.<..`.?"
ec7b             	.byte	$1b,$4b,$67,$b4,$a1,$07,$8c,$07	; ".Kg4!..."
ec83             	.byte	$ae,$a9,$ac,$a8,$67,$8c,$07,$b4	; ".),(g..4"
ec8b             	.byte	$af,$ac,$b0,$67,$9d,$b2,$af,$ac	; "/,0g.2/,"
ec93             	.byte	$af,$a3,$67,$8c,$07,$a5,$ab,$af	; "/#g..%+/"
ec9b             	.byte	$b0,$f4,$ae,$a9,$b2,$b0,$7f,$0e	; "0t.)20.."
eca3             	.byte	$27,$b4,$ae,$a9,$b2,$b0,$7f,$0e	; "'4.)20.."
ecab             	.byte	$28,$b4,$ae,$a9,$b2,$b0,$64,$07	; "(4.)20d."
ecb3             	.byte	$a6,$a9,$67,$af,$b4,$af,$a7,$78	; "&)g/4/'x"
ecbb             	.byte	$b4,$a5,$ac,$78,$7f,$02,$ad,$a5	; "4%,x..-%"
ecc3             	.byte	$b2,$67,$a2,$b5,$b3,$af,$a7,$ee	; "2g"53/'n"
eccb             	.byte	$b2,$b5,$b4,$a5,$b2,$7e,$8c,$39	; "254%2~.9"
ecd3             	.byte	$b4,$b8,$a5,$ae,$67,$b0,$a5,$b4	; "48%.g0%4"
ecdb             	.byte	$b3,$27,$af,$b4,$07,$9d,$19,$b2	; "3'/4...2"
ece3             	.byte	$af,$a6,$7f,$05,$37,$b4,$b5,$b0	; "/&..7450"
eceb             	.byte	$ae,$a9,$7f,$05,$28,$b4,$b5,$b0	; ".)..(450"
ecf3             	.byte	$ae,$a9,$7f,$05,$2a,$b4,$b5,$b0	; ".)..*450"
ecfb             	.byte	$ae,$a9,$e4,$ae,$a5,$00,$ff,$ff	; ".)d.%..."
ed03             syntabl2:	.byte	$47,$a2,$a1,$b4,$7f,$0d,$30,$ad	; "G"!4..0-"
ed0b             	.byte	$a9,$a4,$7f,$0d,$23,$ad,$a9,$a4	; ")$..#-)$"
ed13             	.byte	$67,$ac,$ac,$a1,$a3,$00,$40,$80	; "g,,!#.@."
ed1b             	.byte	$c0,$c1,$80,$00,$47,$8c,$68,$8c	; "@A..G.h."
ed23             	.byte	$db,$67,$9b,$68,$9b,$50,$8c,$63	; "[g.h.P.c"
ed2b             	.byte	$8c,$7f,$01,$51,$07,$88,$29,$84	; "...Q..)."
ed33             	.byte	$80,$c4,$80,$57,$71,$07,$88,$14	; ".D.Wq..."
ed3b             	.byte	$ed,$a5,$ad,$af,$ac,$ed,$a5,$ad	; "m%-/,m%-"
ed43             	.byte	$a9,$a8,$f2,$af,$ac,$af,$a3,$71	; ")(r/,/#q"
ed4b             	.byte	$08,$88,$ae,$a5,$ac,$68,$83,$08	; "...%,h.."
ed53             	.byte	$68,$9d,$08,$71,$07,$88,$60,$76	; "h..q..`v"
ed5b             	.byte	$b4,$af,$ae,$76,$8d,$76,$8b,$51	; "4/.v.v.Q"
ed63             	.byte	$07,$88,$19,$b8,$a4,$ae,$b2,$f2	; "...8$.2r"
ed6b             	.byte	$b3,$b5,$f3,$a2,$a1,$ee,$a7,$b3	; "35s"!n'3"
ed73             	.byte	$e4,$ae,$b2,$eb,$a5,$a5,$b0,$51	; "d.2k%%0Q"
ed7b             	.byte	$07,$88,$39,$81,$c1,$4f,$7f,$0f	; "..9.AO.."
ed83             	.byte	$2f,$00,$51,$06,$88,$29,$c2,$0c	; "/.Q..)B."
ed8b             	.byte	$82,$57,$8c,$6a,$8c,$42,$ae,$a5	; ".W.j.B.%"
ed93             	.byte	$a8,$b4,$60,$ae,$a5,$a8,$b4,$4f	; "(4`.%(4O"
ed9b             	.byte	$7e,$1e,$35,$8c,$27,$51,$07,$88	; "~.5.'Q.."
eda3             	.byte	$09,$8b,$fe,$e4,$af,$ad,$f2,$af	; "..~d/-r/"
edab             	.byte	$e4,$ae,$a1,$dc,$de,$9c,$dd,$9c	; "d.!\^.]."
edb3             	.byte	$de,$dd,$9e,$c3,$dd,$cf,$ca,$cd	; "^].C]OJM"
edbb             	.byte	$cb,$00,$47,$9d,$ad,$a5,$ad,$af	; "K.G.-%-/"
edc3             	.byte	$ac,$76,$9d,$ad,$a5,$ad,$a9,$a8	; ",v.-%-)("
edcb             	.byte	$e6,$a6,$af,$60,$8c,$20,$af,$b4	; "f&/`. /4"
edd3             	.byte	$b5,$a1,$f2,$ac,$a3,$f2,$a3,$b3	; "5!r,#r#3"
eddb             	.byte	$60,$8c,$20,$ac,$a5,$a4,$ee,$b5	; "`. ,%$n5"
ede3             	.byte	$b2,$60,$ae,$b5,$b2,$f4,$b3,$a9	; "2`.52t3)"
edeb             	.byte	$ac,$60,$8c,$20,$b4,$b3,$a9,$ac	; ",`. 43),"
edf3             	.byte	$7a,$7e,$9a,$22,$20,$00,$60,$03	; "z~." .`."
edfb             	.byte	$bf,$60,$03,$bf,$1f         	; "?`.?."

ee00  20 b1 e7   print_str_comma:	JSR	tabout

ee03  e8         print_str:	INX
ee04  e8         	INX
ee05  b5 4f      	LDA	rnd+1,X
ee07  85 da      	STA	aux
ee09  b5 77      	LDA	syn_stk_h+31,X
ee0b  85 db      	STA	aux+1
ee0d  b4 4e      	LDY	rnd,X
ee0f  98         Lee0f:	TYA
ee10  d5 76      	CMP	syn_stk_h+30,X
ee12  b0 09      	BCS	Lee1d
ee14  b1 da      	LDA	(aux),Y
ee16  20 c9 e3   	JSR	cout
ee19  c8         	INY
ee1a  4c 0f ee   	JMP	Lee0f
ee1d  a9 ff      Lee1d:	LDA	#$ff	; 255 .
ee1f  85 d5      	STA	cr_flag
ee21  60         	RTS

ee22  e8         len_fn:	INX
ee23  a9 00      	LDA	#$00	; 0 .
ee25  95 78      	STA	noun_stk_h_str,X
ee27  95 a0      	STA	noun_stk_h_int,X
ee29  b5 77      	LDA	syn_stk_h+31,X
ee2b  38         	SEC
ee2c  f5 4f      	SBC	rnd+1,X
ee2e  95 50      	STA	noun_stk_l,X
ee30  4c 23 e8   	JMP	left_paren
ee33             	.byte	$ff                     	; "."

ee34  20 15 e7   getbyte:	JSR	get16bit
ee37  a5 cf      	LDA	acc+1
ee39  d0 28      	BNE	gr_255_err
ee3b  a5 ce      	LDA	acc
ee3d  60         	RTS

ee3e  20 34 ee   plot_comma:	JSR	getbyte
ee41  a4 c8      	LDY	text_index
ee43  c9 30      	CMP	#$30	; 48 0
ee45  b0 21      	BCS	range_err
ee47  c0 28      	CPY	#$28	; 40 (
ee49  b0 1d      	BCS	range_err
ee4b  60         	RTS
ee4c             	.byte	$ea,$ea                  	; "jj"

ee4e  20 34 ee   Tee4e:	JSR	getbyte
ee51  60         	RTS
ee52             	.byte	$ea,$ea                  	; "jj"

ee54  46 f8      man_cmd:	LSR	auto_flag
ee56  60         	RTS

ee57  20 34 ee   vtab_stmt:	JSR	getbyte
ee5a  c9 18      	CMP	#$18	; 24 .
ee5c  b0 0a      	BCS	range_err
ee5e  85 25      	STA	cv
ee60  60         	RTS
ee61             	.byte	$ea,$ea                  	; "jj"
ee63  a0 77      gr_255_err:	LDY	#$77	; 119 w
ee65  4c e0 e3   go_errmess_5:	JMP	print_err_msg
ee68  a0 7b      range_err:	LDY	#$7b	; 123 {
ee6a  d0 f9      	BNE	go_errmess_5

ee6c  20 54 e2   See6c:	JSR	Se254
ee6f  a5 da      	LDA	aux
ee71  d0 07      	BNE	Lee7a
ee73  a5 db      	LDA	aux+1
ee75  d0 03      	BNE	Lee7a
ee77  4c 7e e7   	JMP	Le77e
ee7a  06 ce      Lee7a:	ASL	acc
ee7c  26 cf      	ROL	acc+1
ee7e  26 e6      	ROL	p3
ee80  26 e7      	ROL	p3+1
ee82  a5 e6      	LDA	p3
ee84  c5 da      	CMP	aux
ee86  a5 e7      	LDA	p3+1
ee88  e5 db      	SBC	aux+1
ee8a  90 0a      	BCC	Lee96
ee8c  85 e7      	STA	p3+1
ee8e  a5 e6      	LDA	p3
ee90  e5 da      	SBC	aux
ee92  85 e6      	STA	p3
ee94  e6 ce      	INC	acc
ee96  88         Lee96:	DEY
ee97  d0 e1      	BNE	Lee7a
ee99  60         	RTS
ee9a             	.byte	$ff,$ff,$ff,$ff,$ff,$ff      	; "......"

eea0  20 15 e7   call_stmt:	JSR	get16bit
eea3  6c ce 00   	JMP	(acc)
eea6             bogus_eea6:	.byte	$20,$34,$ee,$c5,$c8,$90,$bb,$85	; " 4nEH.;."

eeae  a5 4d      Teeae:	LDA	himem+1

eeb0  48         Teeb0:	PHA
eeb1  a5 4c      	LDA	himem
eeb3  20 08 e7   	JSR	push_ya_noun_stk
eeb6  68         	PLA
eeb7  95 a0      	STA	noun_stk_h_int,X
eeb9  60         	RTS

eeba  a5 4b      Teeba:	LDA	lomem+1

eebc  48         Teebc:	PHA
eebd  a5 4a      	LDA	lomem
eebf  4c b3 ef   	JMP	Lefb3
eec2             bogus_eec2:	.byte	$a5,$85,$2d,$60            	; "%.-`"

eec6  20 34 ee   Teec6:	JSR	getbyte
eec9  c9 28      	CMP	#$28	; 40 (
eecb  b0 9b      Leecb:	BCS	range_err
eecd  a8         	TAY
eece  a5 c8      	LDA	text_index
eed0  60         	RTS
eed1             	.byte	$ea,$ea                  	; "jj"

eed3  98         print_err_msg:	TYA
eed4  aa         	TAX
eed5  a0 6e      	LDY	#$6e	; 110 n
eed7  20 c4 e3   	JSR	Se3c4
eeda  8a         	TXA
eedb  a8         	TAY
eedc  20 c4 e3   	JSR	Se3c4
eedf  a0 72      	LDY	#$72	; 114 r
eee1  4c c4 e3   	JMP	Se3c4

eee4  20 15 e7   Seee4:	JSR	get16bit
eee7  06 ce      Leee7:	ASL	acc
eee9  26 cf      	ROL	acc+1
eeeb  30 fa      	BMI	Leee7
eeed  b0 dc      	BCS	Leecb
eeef  d0 04      	BNE	Leef5
eef1  c5 ce      	CMP	acc
eef3  b0 d6      	BCS	Leecb
eef5  60         Leef5:	RTS

eef6  20 15 e7   peek_fn:	JSR	get16bit
eef9  b1 ce      	LDA	(acc),Y
eefb  94 9f      	STY	syn_stk_l+31,X
eefd  4c 08 e7   	JMP	push_ya_noun_stk

ef00  20 34 ee   poke_stmt:	JSR	getbyte
ef03  a5 ce      	LDA	acc
ef05  48         	PHA
ef06  20 15 e7   	JSR	get16bit
ef09  68         	PLA
ef0a  91 ce      	STA	(acc),Y

ef0c  60         Tef0c:	RTS
ef0d             	.byte	$ff,$ff,$ff               	; "..."

ef10  20 6c ee   divide:	JSR	See6c
ef13  a5 ce      	LDA	acc
ef15  85 e6      	STA	p3
ef17  a5 cf      	LDA	acc+1
ef19  85 e7      	STA	p3+1
ef1b  4c 44 e2   	JMP	Le244

ef1e  20 e4 ee   dim_num:	JSR	Seee4
ef21  4c 34 e1   	JMP	Le134

ef24  20 e4 ee   num_array_subs:	JSR	Seee4
ef27  b4 78      	LDY	noun_stk_h_str,X
ef29  b5 50      	LDA	noun_stk_l,X
ef2b  69 fe      	ADC	#$fe	; 254 ~
ef2d  b0 01      	BCS	Lef30
ef2f  88         	DEY
ef30  85 da      Lef30:	STA	aux
ef32  84 db      	STY	aux+1
ef34  18         	CLC
ef35  65 ce      	ADC	acc
ef37  95 50      	STA	noun_stk_l,X
ef39  98         	TYA
ef3a  65 cf      	ADC	acc+1
ef3c  95 78      	STA	noun_stk_h_str,X
ef3e  a0 00      	LDY	#$00	; 0 .
ef40  b5 50      	LDA	noun_stk_l,X
ef42  d1 da      	CMP	(aux),Y
ef44  c8         	INY
ef45  b5 78      	LDA	noun_stk_h_str,X
ef47  f1 da      	SBC	(aux),Y
ef49  b0 80      	BCS	Leecb
ef4b  4c 23 e8   	JMP	left_paren

ef4e  20 15 e7   rnd_fn:	JSR	get16bit
ef51  a5 4e      	LDA	rnd
ef53  20 08 e7   	JSR	push_ya_noun_stk
ef56  a5 4f      	LDA	rnd+1
ef58  d0 04      	BNE	Lef5e
ef5a  c5 4e      	CMP	rnd
ef5c  69 00      	ADC	#$00	; 0 .
ef5e  29 7f      Lef5e:	AND	#$7f	; 127 .
ef60  85 4f      	STA	rnd+1
ef62  95 a0      	STA	noun_stk_h_int,X
ef64  a0 11      	LDY	#$11	; 17 .
ef66  a5 4f      Lef66:	LDA	rnd+1
ef68  0a         	ASL
ef69  18         	CLC
ef6a  69 40      	ADC	#$40	; 64 @
ef6c  0a         	ASL
ef6d  26 4e      	ROL	rnd
ef6f  26 4f      	ROL	rnd+1
ef71  88         	DEY
ef72  d0 f2      	BNE	Lef66
ef74  a5 ce      	LDA	acc
ef76  20 08 e7   	JSR	push_ya_noun_stk
ef79  a5 cf      	LDA	acc+1
ef7b  95 a0      	STA	noun_stk_h_int,X
ef7d  4c 7a e2   	JMP	mod_op

ef80  20 15 e7   Tef80:	JSR	get16bit
ef83  a4 ce      	LDY	acc
ef85  c4 4a      	CPY	lomem
ef87  a5 cf      	LDA	acc+1
ef89  e5 4b      	SBC	lomem+1
ef8b  90 1e      	BCC	Lefab
ef8d  84 4c      	STY	himem
ef8f  a5 cf      	LDA	acc+1
ef91  85 4d      	STA	himem+1
ef93  4c ad e5   Lef93:	JMP	new_cmd

ef96  20 15 e7   Tef96:	JSR	get16bit
ef99  a4 ce      	LDY	acc
ef9b  c4 4c      	CPY	himem
ef9d  a5 cf      	LDA	acc+1
ef9f  e5 4d      	SBC	himem+1
efa1  b0 08      	BCS	Lefab
efa3  84 4a      	STY	lomem
efa5  a5 cf      	LDA	acc+1
efa7  85 4b      	STA	lomem+1
efa9  90 e8      	BCC	Lef93
efab  4c cb ee   Lefab:	JMP	Leecb
efae             	.byte	$a5,$4d,$48,$a5,$4c         	; "%MH%L"
efb3  20 c9 ef   Lefb3:	JSR	Sefc9

efb6  20 71 e1   string_input:	JSR	input_str
efb9  4c bf ef   	JMP	Lefbf

efbc  20 03 ee   input_prompt:	JSR	print_str
efbf  a9 ff      Lefbf:	LDA	#$ff	; 255 .
efc1  85 c8      	STA	text_index
efc3  a9 74      	LDA	#$74	; 116 t
efc5  8d 00 02   	STA	buffer
efc8  60         	RTS

efc9  20 36 e7   Sefc9:	JSR	not_op
efcc  e8         	INX

efcd  20 36 e7   Sefcd:	JSR	not_op
efd0  b5 50      	LDA	noun_stk_l,X
efd2  60         	RTS

efd3  a9 00      mem_init_4k:	LDA	#$00	; 0 .
efd5  85 4a      	STA	lomem
efd7  85 4c      	STA	himem
efd9  a9 08      	LDA	#$08	; 8 .
efdb  85 4b      	STA	lomem+1
efdd  a9 10      	LDA	#$10	; 16 .
efdf  85 4d      	STA	himem+1
efe1  4c ad e5   	JMP	new_cmd

efe4  d5 78      Sefe4:	CMP	noun_stk_h_str,X
efe6  d0 01      	BNE	Lefe9
efe8  18         	CLC
efe9  4c 02 e1   Lefe9:	JMP	Le102

efec  20 b7 e5   Tefec:	JSR	clr
efef  4c 36 e8   	JMP	run_warm

eff2  20 b7 e5   Teff2:	JSR	clr
eff5  4c 5b e8   	JMP	goto_stmt

eff8  e0 80      Seff8:	CPX	#$80	; 128 .
effa  d0 01      	BNE	Leffd
effc  88         	DEY
effd  4c 0c e0   Leffd:	JMP	Se00c
Tffff	.equ	$ffff





Cross References

Symbol    Value  References
Dd010     d010   e008 
Dd011     d011   e86f e003 
Dd0f2     d0f2   e3da e3d5 
Le022     e022   e028 
Le034     e034   e043 e030 e00f e06b 
Le03b     e03b   e048 e05b 
Le083     e083   e0f7 
Le095     e095   e090 
Le096     e096   e09f 
Le099     e099   e0f9 e0f3 
Le0ac     e0ac   e0a5 
Le0bb     e0bb   e0d0 e0b5 
Le0be     e0be   e0ca e0c2 
Le0cc     e0cc   e0c6 
Le0d9     e0d9   e0eb e0d4 
Le0ed     e0ed   e0db 
Le102     e102   efe9 e129 
Le115     e115   e102 
Le12c     e12c   e147 
Le134     e134   ef21 
Le156     e156   e15f 
Le161     e161   e168 
Le16d     e16d   e15c 
Le16f     e16f   e1ac 
Le199     e199   e1b2 
Le1ae     e1ae   e1a8 
Le1b4     e1b4   e19d 
Le1f3     e1f3   e21a 
Le203     e203   e214 e20e 
Le205     e205   e201 
Le206     e206   e1fd 
Le225     e225   e23f 
Le238     e238   e229 
Le244     e244   e239 ef1b e27d 
Le277     e277   e26c 
Le279     e279   e24f 
Le280     e280   e2a8 
Le286     e286   e282 
Le294     e294   e29c e28c 
Le29b     e29b   e288 
Le2b6     e2b6   e30c e3e7 
Le2d1     e2d1   e2c3 
Le2f9     e2f9   e2f4 
Le2fb     e2fb   e301 
Le326     e326   e344 
Le33c     e33c   e338 
Le346     e346   e34b 
Le350     e350   e356 
Le35c     e35c   e363 
Le365     e365   e35a 
Le36b     e36b   e324 e5e2 
Le395     e395   e385 
Le397     e397   e3b5 
Le3a7     e3a7   e3a3 
Le3af     e3af   e3ab 
Le3b7     e3b7   e39f 
Le3c0     e3c0   e3c7 
Le3d3     e3d3   e3cb 
Le3d5     e3d5   e3d8 
Le3e5     e3e5   e365 
Le3ea     e3ea   e3e5 
Le3ed     e3ed   e435 
Le400     e400   e3f8 
Le409     e409   e414 
Le413     e413   e410 
Le425     e425   e470 
Le426     e426   e4a0 
Le428     e428   e3fd 
Le42a     e42a   e42e 
Le442     e442   e43a 
Le448     e448   e3f3 
Le44a     e44a   e46e 
Le45b     e45b   e45f 
Le470     e470   e4ab 
Le47d     e47d   e477 
Le498     e498   e474 
Le49b     e49b   e498 
Le49c     e49c   e465 e462 e4cb 
Le4a9     e4a9   e4a2 
Le4b1     e4b1   e446 e440 
Le4ba     e4ba   e4b4 
Le4c0     e4c0   e419 e515 
Le4c4     e4c4   e4bc e4b8 
Le4c7     e4c7   e4d8 
Le4cd     e4cd   e451 
Le4e7     e4e7   e507 
Le4f3     e4f3   e4ff 
Le517     e517   e4f9 
Le523     e523   e560 
Le527     e527   e53e 
Le540     e540   e531 
Le54c     e54c   e548 
Le554     e554   e54e e544 
Le55f     e55f   e559 e552 
Le5a0     e5a0   e59b 
Le5ac     e5ac   e591 e584 
Le5cc     e5cc   e636 
Le5e5     e5e5   e5e0 
Le623     e623   e617 e613 
Le628     e628   e619 
Le62e     e62e   e651 
Le645     e645   e63d 
Le64f     e64f   e60a 
Le653     e653   e643 
Le670     e670   e675 
Le686     e686   e69e 
Le696     e696   e6c1 
Le69b     e69b   e6c9 e698 
Le6ba     e6ba   e6bf 
Le6bc     e6bc   e6af 
Le6cd     e6cd   e6c5 
Le6d8     e6d8   e6f9 
Le705     e705   e701 
Le710     e710   e70b 
Le731     e731   e721 
Le749     e749   e745 e741 
Le757     e757   e762 
Le758     e758   e76d 
Le764     e764   e75e 
Le77e     e77e   e241 ee77 e79f 
Le7a1     e7a1   e77c 
Le7b0     e7b0   e7a9 
Le7b7     e7b7   e7be 
Le7bc     e7bc   e7ae 
Le7d5     e7d5   e7c9 
Le7f3     e7f3   e7ff 
Le822     e822   e81b 
Le834     e834   e82b 
Le867     e867   e861 
Le87a     e87a   e8c0 e877 
Le883     e883   e2f6 
Le896     e896   e83a e893 
Le8be     e8be   e935 
Le8c3     e8c3   eb9e e872 
Le8d6     e8d6   e8eb e8e4 
Le8dc     e8dc   e940 
Le925     e925   e91e 
Le937     e937   e923 
Le966     e966   e98a 
Leb9a     eb9a   e3ea 
Leba1     eba1   eb9c 
Lebac     ebac   eba8 
Lebce     ebce   ebdc 
Lebfa     ebfa   ebf5 
Lec16     ec16   ec11 
Lec1b     ec1b   ec09 ec04 ec4e 
Lec4c     ec4c   ec45 
Lee0f     ee0f   ee1a 
Lee1d     ee1d   ee12 
Lee7a     ee7a   ee97 ee75 ee71 
Lee96     ee96   ee8a 
Leecb     eecb   efab ef49 eef3 eeed 
Leee7     eee7   eeeb 
Leef5     eef5   eeef 
Lef30     ef30   ef2d 
Lef5e     ef5e   ef58 
Lef66     ef66   ef72 
Lef93     ef93   efa9 
Lefab     efab   ef8b efa1 
Lefb3     efb3   eebf 
Lefbf     efbf   efb9 
Lefe9     efe9   efe6 
Leffd     effd   effa 
Pe000     e000   0000 
RESET     0000   0000 0000 0000 0000 0000 
Se00c     e00c   effd e0ed 
Se011     e011   e092 
Se018     e018   e083 
Se01a     e01a   e09b 
Se118     e118   e0fb e121 e130 
Se1bc     e1bc   e196 
Se254     e254   e222 ee6c 
Se25b     e25b   e258 
Se299     e299   ebbb 
Se38a     e38a   e303 
Se3c4     e3c4   eee1 eedc eed7 ebac e8c5 e296 
Se491     e491   ebc4 e2de 
Se6fc     e6fc   e6f6 
Se772     e772   e755 e7d0 
Se793     e793   e8fb 
See6c     ee6c   ef10 e27a 
Seee4     eee4   ef24 ef1e 
Sefc9     efc9   ec40 ec50 ec47 efb3 
Sefcd     efcd   e828 
Sefe4     efe4   e110 
Seff8     eff8   e0d6 
Te816     e816   0000 0000 
Te97e     e97e   0000 
Tec01     ec01   0000 
Tec06     ec06   0000 
Tec0b     ec0b   ec06 0000 
Tec13     ec13   ec01 0000 
Tec40     ec40   0000 
Tec47     ec47   0000 
Tee4e     ee4e   0000 
Teeae     eeae   0000 
Teeb0     eeb0   0000 
Teeba     eeba   0000 
Teebc     eebc   0000 
Teec6     eec6   0000 
Tef0c     ef0c   0000 
Tef80     ef80   0000 
Tef96     ef96   0000 
Tefec     efec   0000 
Teff2     eff2   0000 
Tffff     ffff   0000 0000 0000 0000 0000 0000 0000 
Tffff     ffff   0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 
Z1d       001d   e5c9 
abs_fn    e750   0000 
acc       00ce   e0d9 e0c0 e0bc e0ad e7e5 e7fb ef83 ef99 e225 ef13 ef35 eef9 
acc       00ce   e729 e725 e719 e80c 
acc       00ce   ebc9 ebaf eba4 e5e5 e5a1 e58a e63b e60c e6ef e1a2 e18e e72e 
acc       00ce   ef0a ef03 e73f ee3b e25b ee94 ee7a e794 e788 e774 ebf1 ebce 
acc       00ce   ef74 e207 e1d9 eef1 eee7 e138 e7a7 e955 e983 e760 e91c e7da 
acc+1     00cf   e0b7 e0b1 e7e9 e7fd ef8f ef87 efa5 ef9d e227 ef17 ef3a ef79 
acc+1     00cf   e5a6 e58f e660 e641 e60e e6f4 e192 e72b e723 e71d e811 
acc+1     00cf   e743 ee37 e26a e25f ee7c e79b e78c e77a ebb2 eba1 e623 e5e9 
acc+1     00cf   e753 e1dd eee9 e140 e7ac e95a e988 e76b e75c e7df e7d8 e7c7 
add       e785   0000 
auto_cmd  e7e2   0000 
auto_com  e7f8   0000 
auto_flag  00f8   e7ee ee54 e5ad e358 e557 e2c1 e284 
auto_inc  00f4   e7f3 
auto_inc+1  00f5   e7f5 e35e 
auto_ln   00f6   e7e7 e2c5 
auto_ln+1  00f7   e7eb e360 e35c e2c7 
aux       00da   e22e ef47 ef42 ef30 e210 e1e1 e162 e157 e14d e149 e136 e8f0 
aux       00da   e813 e80e e806 
aux       00da   ee14 ee07 e25d ee90 ee84 ee6f e1d2 e1be e796 e78a e1b7 e1ae 
aux+1     00db   e234 ef32 e1e5 e154 e152 e13e e8f5 ee0b e261 ee88 ee73 e1c7 
aux+1     00db   e79d e78e e80a 
begin_line  e817   0000 
bogus_eea6  eea6   0000 
bogus_eec2  eec2   0000 
buffer    0200   
buffer    0200   efc5 ebe2 ebd1 e3f0 e437 e42b e422 e4ee e4b1 e55b e28e e2ac 
buffer-1  01ff   ebe6 
call_stmt  eea0   0000 
ch        0024   e01a e7b1 e7bc e3d3 e3cf 
char      00f9   e4fd e4e9 e540 e53c e525 
clr       e5b7   eff2 efec 0000 
cold      e2b0   e000 
colon     e819   0000 
comma_substr  e109   0000 
cout      e3c9   e022 e015 e0e5 e096 e7b9 ee16 e7cd e554 e2ce e2ba e3c0 e2a3 
cout      e3c9   e17f 
cr_flag   00d5   e819 ee1f e7d6 e820 e67d 
crout     e3cd   e0a9 e81d e2b3 
current_verb  00d6   e82f e6e8 e6ce 
cv        0025   ee5e 
dectabh   e568   e52e 
dectabl   e563   e537 e529 
del_cmd   e387   0000 
del_comma  e36f   0000 
dim_num   ef1e   0000 0000 
dim_str   e130   0000 0000 
divide    ef10   0000 
do_verb   e6ec   e6e1 
end_stmt  e8d3   e888 0000 
eq_op     e733   0000 
error_msg_tbl  eb00   e3c4 
execute_stmt  e679   e883 
execute_token  e6a0   e686 
execute_var  e60c   e689 
execute_verb  e6c3   e6a2 
fetch_prog_byte  e682   e677 e664 
find_line  e56d   e060 e85e e38a 
find_line1  e575   e37a 
find_line2  e576   e038 e5aa 
for_nest_count  00fb   e5c1 e942 e93c e953 e981 e8d6 e937 e91a e902 e8da 
for_stmt  e93a   0000 
fstk_plineh-1  0147   e970 e92a 
fstk_plinel-1  013f   e96b e925 
fstk_pverbh-1  0157   e97a e932 
fstk_pverbl-1  014f   e975 e92f 
fstk_steph-1  0137   e966 e920 e8f2 
fstk_stepl-1  012f   e961 e985 e8ed 
fstk_toh-1  0167   e95c e904 
fstk_tol-1  015f   e957 e909 
fstk_varh  0128   e94c 
fstk_varh-1  0127   e8e8 
fstk_varl  0120   e947 
fstk_varl-1  011f   e8e1 
get16bit  e715   e035 e05d e7e2 e7f8 ef80 ef96 eef6 ef4e e750 eea0 eee4 e7a4 
get16bit  e715   e790 e785 e76f e387 e36f e801 
get16bit  e715   e950 e97e e759 e917 e8f7 e85b e7c4 ef06 e736 ee34 e274 e263 
get_next_prog_byte  e6ff   e625 e610 e6e5 e6bc e69b e691 e68b 
getbyte   ee34   e109 e118 ee4e ee3e ef00 eec6 ee57 
go_errmess_1  e106   e12e e16f 
go_errmess_2  e4a6   e47b e519 
go_errmess_3  e712   e780 
go_errmess_4  e8a2   e8dc e8a9 e842 e865 
go_errmess_5  ee65   ee6a 
gosub_nest_count  00fc   e5c3 e8ab e8a7 e845 e83e 
gosub_stmt  e83c   0000 
goto_stmt  e85b   eff5 0000 0000 
gr_255_err  ee63   ee39 
gstk_plineh  0118   e858 
gstk_plineh-1  0117   e8b3 
gstk_plinel  0110   e853 
gstk_plinel-1  010f   e8ae 
gstk_pverbh  0108   e84e 
gstk_pverbh-1  0107   e8bb 
gstk_pverbl  0100   e849 
himem     004c   efd7 e053 ef8d e5af ef9b eeb1 e57e e896 
himem+1   004d   efdf e057 ef91 e5b3 ef9f e218 e1f3 eeae e582 e89a 
if_flag   00d4   e832 e6cb e6c3 e6ad e696 e67b 
if_stmt   e828   0000 
input_num_comma  ebcb   0000 
input_num_stmt  ebaa   ebd6 0000 
input_prompt  efbc   0000 
input_str  e171   efb6 
leadbl    00c9   e509 e4e4 e54c e54a e521 
leadzr    00fa   e086 e071 e550 e2bf 
left_paren  e823   ef4b ee30 e115 0000 0000 0000 0000 
len_fn    ee22   0000 
list_all  e04b   0000 
list_cmd  e05d   0000 
list_comman  e035   0000 
list_int  e077   e08c 
list_line  e06d   e045 
list_token  e0a3   e089 
lomem     004a   efd5 ef85 e5b7 efa3 eebd e62c 
lomem+1   004b   efdb ef89 e5bb efa7 eeba e628 
man_cmd   ee54   0000 
mem_init_4k  efd3   e2b0 
mod_op    e27a   ef7d 0000 
mult_op   e222   0000 
negate    e76f   ec0e e251 e271 e782 ebf7 0000 
neq_op    e74a   e733 0000 0000 
new_cmd   e5ad   efe1 ef93 0000 
next_stmt  e8d8   0000 0000 
nextbyte  e02a   e01c e07d e079 e073 
not_op    e736   ec1b e21f efcd efc9 0000 
noun_stk_h_int  00a0   
noun_stk_h_int  00a0   e24b ef7b ef62 e1ee ee27 e769 eeb7 e73d e7a1 ebef e694 e71b 
noun_stk_h_str  0078   e670 e66c e65e e6ba e6b8 e6ab e187 e178 e71f e808 
noun_stk_h_str  0078   efe4 e113 e100 ef45 ef3c ef27 e1ec ee25 e127 e13c e94a e8e6 
noun_stk_h_str+1  0079   e1e3 e1c5 e190 
noun_stk_h_str+3  007b   e1db 
noun_stk_l  0050   e945 e8df e747 efd0 e70d e1b4 e1b0 e1a4 e717 e804 
noun_stk_l  0050   ec19 ec4c e10c e0fe ef40 ef37 ef29 e203 e1f1 ee2e e124 e134 
noun_stk_l+1  0051   e1df e1bc e18c 
noun_stk_l+3  0053   e1d7 
num_array_subs  ef24   0000 
p1        00e2   e03b e02e e02c e065 e04d e33c e38f e37d e372 
p1+1      00e3   e03f e032 e069 e051 e340 e393 e381 e376 
p2        00e4   e013 e0e0 e0d2 e0a1 e08e e077 e063 e212 e209 e867 e1d4 e1cf 
p2        00e4   e1c3 e346 e31c e314 e5a8 e5a3 e597 e58d e588 e57c e3b1 e3a7 
p2        00e4   e3a1 e399 e37f e1a6 
p2+1      00e5   e067 e24d e869 e26f e256 e1cb e320 e31a e580 e578 e3a5 e39d 
p2+1      00e5   e383 
p3        00e6   e03d e055 e23b e230 e22c ef15 e244 e266 ee92 ee8e ee82 ee7e 
p3        00e6   e353 e334 e32a e599 e595 e57a e56f e3b7 e3b3 e3af e3a9 e38d 
p3        00e6   e374 
p3+1      00e7   e041 e059 e23d e236 e232 ef19 e249 e268 ee8c ee86 ee80 e330 
p3+1      00e7   e59d e576 e573 e3bb e3ad e391 e378 
paren_substr  e0fb   0000 
pcon      00f2   e501 e4f3 e4da e53a e535 e527 e51d 
pcon+1    00f3   e513 e503 e4f7 e4dc e533 e52c e51b 
peek_fn   eef6   0000 
pline     00dc   e969 e928 e8b1 e851 e8ce e8ca e86b e88f e88d 
pline+1   00dd   e96e e92d e8b6 e856 e86d e891 
plot_comma  ee3e   0000 
poke_stmt  ef00   0000 0000 0000 0000 
pp        00ca   e04b e836 e5b1 e143 e348 e33e e336 e332 e326 e310 e56d e3b9 
pp        00ca   e397 e5da 
pp+1      00cb   
pp+1      00cb   e04f e838 e5b5 e145 e342 e33a e32c e316 e571 e3bd e39b e5de 
prdec     e51b   e080 e7dc e8d0 e2c9 
precedence  00d7   e825 e6df e6d6 
print_com_num  e7c1   0000 
print_cr  e81d   0000 
print_err_msg  e3e0   ee65 e106 e4a6 e36d e8a2 e712 
print_err_msg  eed3   e3e0 
print_num  e7c4   e7d3 0000 0000 
print_semi  e820   0000 
print_str  ee03   efbc 0000 0000 
print_str_comma  ee00   0000 
push_a_noun_stk  e70a   e668 e657 e6b3 e6a6 e17a e173 
push_old_verb  e681   e6ea 
push_ya_noun_stk  e708   
push_ya_noun_stk  e708   eefd e246 ef76 ef53 e766 e90e eeb3 e73a e798 e776 ebeb e68e 
put_token  e41c   e50e e4c0 
pv        00cc   e5b9 e164 e159 e31e e602 e630 
pv+1      00cd   e5bd e322 e2fd e606 e634 
pverb     00e0   e87f e2ee e2e5 
pverb     00e0   e973 e847 e351 e34d e328 e312 e30e e2fb e705 e6ff e6a4 e684 
pverb+1   00e1   e978 e84c e703 e6a9 e881 e2ec 
range_err  ee68   ee49 ee45 eecb ee5c 
rdkey     e003   e006 e29e 
read_line  e29e   e2d4 e292 e184 
return_stmt  e8a5   0000 
right_paren  e827   0000 
rnd       004e   ef6d ef5a ef51 ee0d e19f e199 
rnd+1     004f   ec43 ec4a ef6f ef66 ef60 ef56 e216 e1f9 ee2c ee05 
rnd_fn    ef4e   0000 
run_flag  00d9   ebc7 ebb6 eb9a e87c e8a0 e886 e2b6 e3e3 
run_loop  e86b   e89c e898 
run_warm  e836   efef 
sgn_fn    e759   e74d ec16 e914 0000 
srch      00d0   e4e2 e608 e5fe e5fb e5f6 e5f1 e5ec e5e7 e5cc e673 e653 e64a 
srch      00d0   e646 e63f e638 e62e 
srch2     00d2   e600 e5ee e5d8 e5d0 
srch2+1   00d3   e604 e5f3 e5dc e5d6 
str_arr_dest  e121   0000 
string_eq  e1d7   e21c 0000 
string_err  e104   e10e e11b 
string_input  efb6   0000 0000 
string_lit  e18c   0000 
string_neq  e21c   0000 
subtract  e782   e74a ec13 ec0b e911 0000 
syn_stk_h  0058   e467 e481 e4cd 
syn_stk_h+29  0075   e1f5 
syn_stk_h+30  0076   ee10 e19b 
syn_stk_h+31  0077   e1fb ee29 ee09 e708 
syn_stk_l  0080   e46b e47d e4d1 
syn_stk_l+31  009f   eefb e907 
synpag    00fe   e5c5 e40c e406 e3fb e3f5 e45c e44b e430 e4d4 e4c7 e49e 
synpag+1  00ff   e8b8 e469 e47f e4cf e496 
synstkdx  00fd   e448 e4e0 e4c5 e49c 
syntabl_index  ec20   e48e 
tab_fn    e7a4   0000 
tabout    e7b1   ee00 e7c1 
text_index  00c8   e308 e2e1 e2da 
text_index  00c8   ee41 efc1 eece ebe0 ebcb ebb9 e400 e455 e426 e483 e4be e4ae 
to_clause  e950   0000 
token_index  00f1   ebbe e459 e487 e41e e41c e50c e505 e306 e2d7 
tokndxstk  00d1   e457 e489 e5d2 e65a e64c e632 e62a 
too_long_err  e3de   e420 
txtndxstk  00a8   e453 e485 
unary_pos  e7a3   0000 
var_assign  e801   e8fe ebfa 0000 0000 
verb_adr_h  ea88   e6f1 
verb_adr_l  ea10   e6ec 
verb_prec_tbl  e998   e6da e6d0 
vtab_stmt  ee57   0000 
warm      e2b3   e8d3 
x_save    00d8   e0a7 e06d 
