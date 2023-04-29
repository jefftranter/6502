10	*=$4000
20	ADDR=$A
30START	LDA	ADDR		; save the page 0 locations
40	PHA			; in case this routine is
50	LDA	ADDR+1		; called from BASIC
60	PHA
70	LDA	#$D0		; set up page 0 locations
80	STA	ADDR+1		; for indirect addressing
90	LDA	#$83
100	STA	ADDR
110	LDX	#3		; counter
120	LDY	#0		; register for ind. addressing
130	LDA	#32		; blank character in ASCII code
140LOOP	STA	(ADDR),Y
150	INY
160	BNE	LOOP
170	INC	ADDR+1		; after 256 locations incr. page
180	DEX
190	BPL	LOOP
200	PLA			; recover the page 0 info
210	STA	ADDR+1		; & put it back
220	PLA
230	STA	ADDR
240	RTS
250	.END
