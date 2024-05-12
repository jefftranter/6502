        .setcpu "6502"
        .debuginfo

        .include "aim65monitor.inc"

        ; DEFINES
        NUL = $00
        LF  = $0a
        CR  = $0d
        DEL = $7f
        
	; ZERO PAGE VARIABLES
        .segment "ZEROPAGE": zeropage
        .org $0000

	.org $0004
OPCBYTES:	.res 1	; number of bytes in data or opcode/operand at SBR $DA0F
	.org $0006
PCTEMP:		.res 2	; $06 - .WOR - temporary storage of program counter (PC)
ERRINDEX:	.res 1	; $08 - error index at SBR ERRDECODE
OBJDSTPTR:	.res 2	; $09/$0A - .WOR - pointer used to store OBJ code in memory
SYMTBLSIZ:	.res 2	; $0B/$0C . .DBY - number of entries in symbol table
DIRADR:		.res 2	; $0D/$0E - .WOR - directive action address or SEARCH address
BASOPC:		.res 1	; $0F - basal opcode stored here
OPCTYP:		.res 1	; $10 - opcode classification type (see table 4); or $E if branch
SYMCNT:		.res 2	; $11/$12 - .WOR - symbol counter for SEARCH
SYMVAL:		.res 2	; $13/$14 - .DBY - value of symbol; or workspace for * assignment
EVLSGN:		.res 1	; $15 - + or - sign for EVALUATE
OPCBYTES2:	.res 1	; $16 - same as OPCBYTES, but maximum value allowed is $14
BASCNVPRM:	.res 2	; $17/$18 - parameters for BASE conversion; loaded from table at $D956
GENCNT:		.res 1	; $19 - number of bytes in com­pleted .BYT ASCH literal string; or flag for format­ting quotated material for LIST
P2ERRS:		.res 2	; $1A/$1B - .DBY - number of errors in PASS 2
OPNALLCOD:	.res 1	; $1C - allowable operand coding key; used in opcode processing
EXPOK:		.res 1	; $1D - expression OK/NOK flag; used in opcode processing
ERRNUM:		.res 1	; $1E - error number (in decimal) for to print **ERROR XX
LINCNT:		.res 1	; $1F - output line counter for LIST formatting
FLGLST:		.res 1	; $20 - flag: "this line contains a label"
FLGPCASSIGN:	.res 1	; $21 - flag:"* = "
FGLDEF:		.res 1	; $22 - flag: used to select .DBY, .WOR, .BYT notation
PASSCNT:	.res 1	; $23 - pass counter: PASS 1=0; PASS 2=1
BUFNXTC:	.res 1	; $24 - pointer to next non-space character in buffer
BUFSTRLASTC:	.res 1	; $25 - pointer to last character of string in buffer
BUFSTRLEN:	.res 1	; $26 - number of characters in string
EVALVAL:	.res 2	; $27/$28 - .DBY - output of EVALUATE = value of ex­ pression
BUFPTR:		.res 1	; $29 - pointer to active character in buffer
SSEARCH:	.res 6	; $2A..$2F - string storage for comparison by SEARCH
NBYTCOMP:	.res 1	; $30 - number of bytes compiled at SBR $D66F et al.
SAVERRN:	.res 1	; $31 - stored error number at SBR $D683
PC:		.res 2	; $32/$33	 - program counter or PC
DISPTR:		.res 1	; $34 - display buffer pointer
BUFNCHAR:	.res 1	; $35 - number of characters in current line in buffer
FLGGRTLST:	.res 1	; $36 - flag: for > or < operations
DIRFLG:		.res 1	; $37 - flag: directive/option status (see table 5)
	FOPTNOG = $80	; .OPT NOG if flag set,
			; .OPT GEN if flag cleared
	FOPTERR = $10	; .OPT ERR + OPT NOL if flag set (errors only),
			; .OPT NOE + OPT LIS if flag cleared (complete)
	FOPTNOL = $10	; .OPT ERR + OPT NOL if flag set (errors only),,
			; .OPT NOE + OPT LIS if flag cleared (complete)
	FOPTNOM = $08	; .OPT NOM if flag set (object code to memory NO),
			; .OPT MEM if flag cleared (object code to memory YES)
FLGOVF:		.res 1	; $38 - flag: arithmetic over- or under- flow from
                        ;   EVALUATE
NBYTES:		.res 1	; $39 - number of bytes (.BYT = 1; .WOR and .DBY = 2)
SYMTSTART:	.res 2	; $3A/$3B, symbol table start
SYMTLAST:	.res 2	; 3C/3D, last active symbol
SYMTTOP:	.res 2	; 3E/3F, symbol table upper limit
OBJRECCNT:	.res 2	; $40/$41 - OBJ output record counter
OBJRECCHK:	.res 2	; $42/$43 - OBJ record checksum
NEXTPC:		.res 2	; $44 - address at which PC is next due to be LISTed
INBUF:		.res 60	; $46..$81, input buffer; usually uses X as
                        ;   index/pointer
WS:		.res 2	; $82/$83, workspace... various uses index/pointer
                        ;   for OBJ in­termediate buffer
OBJBUFNDX:	.res 1	; $84, index/pointer for OBJ in­termediate buffer
OBJOUTADR:	.res 2	; $85/$86, used in OBJ output process­ing: absolute
                        ;   address of where data would be deposited if
			;   not stored in intermediate buffer
OBJOUTFLG:	.res 1	; $87, OBJ OUTFLG, if defined
LSTOUTFLG:	.res 1	; $88, LIST OUTFLG stored here when OBJ is being
                        ;   output
RECBUF:			; $89..$A6, record assembly space for OBJ output... includes:
RECLEN:		.res 1	; $89, number of bytes in record
RECDATADRS:	.res 1	; $8A, starting address of data
RECDAT:		.res 24	; $8C..$A2, data
RECCHK:		.res 4	; $A3..$A6, checksum
AIDFNAM:	.res 6	; $A7..$AB, AID input FNAME stored here
CODBUFEND:


        .segment "STACK"
        .org $100

        .segment "CODE"
        .org $D000

; ===============================================
; initialize RAM and setup for PASS 1
; ===============================================
ASSEM:
	jsr PRCRLF
	ldx #OFFMSGASM	; Print "ASSEMBLER"
	jsr PRMSG
	jsr PRCRLF
	lda #$00		; initialize some vars
	sta PASSCNT		; PASS 1
	sta SYMTBLSIZ		; clear symbol table
	sta SYMTBLSIZ+1
@getaddressfrom:
	jsr FROM		; get start address from keyboard
	bcs @getaddressfrom
	lda CKSUM
	bne ld02a
	lda ADDR		; load end of text buffer address
	sta SYMTSTART		; and store to start address of symbol table
	lda ADDR+1
	sta SYMTSTART+1
	jmp ld031
ld02a:
	lda SYMTSTART+1
	ldx SYMTSTART
	jsr WRAX
ld031:
	jsr PRSPACE
@getaddressto:
	jsr TO
	bcs @getaddressto
	lda CKSUM
	bne ld04b
ld03e:
	lda ADDR
	sta SYMTTOP
	lda ADDR+1
	sta SYMTTOP+1
	jmp ld052
ld04b:
	lda SYMTTOP+1
	ldx SYMTTOP
	jsr WRAX
ld052:
	lda #$e4		; NOG+$40+$20+NOM
	sta DIRFLG
	jsr PRSPCRLF
	jsr WHEREI

; copy input file name in active input device file name
	ldx #$04
ld05e:
	lda NAME,x
	sta AIDFNAM,x
	dex
	bpl ld05e
	jsr PRCRLF
	ldx #OFFMSGLSQ	; print 'LIST?'
	jsr PRMSG
	jsr REDOUT
	cmp #'N'
	bne ld07b
ld075:
	lda DIRFLG
	ora #FOPTERR
	sta DIRFLG
ld07b:
	jsr PRCRLF
	ldx #OFFMSGLSM	; print 'LIST-'
	jsr PRMSG
	jsr WHEREO
	lda OUTFLG
	pha
	lda #' '	; set standard output to display
	sta OUTFLG
	jsr PRCRLF
	ldx #OFFMSGOQ	; print 'OBJ?'
	jsr PRMSG
	jsr REDOUT
	cmp #'Y'
	bne ld0b7
ld09e:
	lda DIRFLG
	ora #FOPTNOM
	sta DIRFLG
	jsr PRCRLF
	ldx #OFFMSGOBM	; print 'OBJ-'
	jsr PRMSG
	jsr WHEREO
	lda OUTFLG
	sta OBJOUTFLG
	jsr OBJCRLF
ld0b7:
	pla
	sta OUTFLG
	jsr PRCRLF
	ldx #OFFMSGP1	; print 'PASS 1'
	jsr PRMSG
ld0c3:
	jsr PRCRLF
	jsr TOPNO	; SET CURRENT LINE TO TOP
	jsr PRCRLF

; Clear some word variables
	lda #$00
	ldx #$01
@clrnext:
	sta PC,x
	sta NEXTPC,x
	sta OBJOUTADR,x
	sta P2ERRS,x
	sta OBJRECCNT,x
	dex
	bpl @clrnext

	jsr OBJCLRCHK

; loop to process lines of source code; stack reset each time
LINELOOP:
	ldx #$ff
	txs
	jsr LINENEXT
	jmp LINELOOP

; ===============================================
; SBR - PROCESS a line
; ===============================================
LINENEXT:
	lda #$00
	sta LINCNT
	sta FLGOVF
	sta BUFNXTC
	sta BUFSTRLASTC
	sta SAVERRN
	sta BUFSTRLEN
	sta EVALVAL
	sta EVALVAL+1
	sta FLGLST
	sta FLGPCASSIGN
	sta FGLDEF
	sta BUFPTR
	tay

	; ..get a line from AID; echo to display
LINEGET:
	jsr INALL	; get a char from input device
	jsr OUTDP1
	cmp #LF		; if LF skip to next line
	beq LINEGET
	cmp #DEL	; if DEL skip to next line
	beq LINEGET
	cmp #CR		; end of current line, start processing
	beq LABELGET

	cmp #NUL
	bne ld11d

	jmp DIREND
ld11d:
	cpy #'<'
	bcs ld124
ld121:
	sta INBUF,y
ld124:
	iny
	jmp LINEGET

	;..separate labels from mnemonics and operands
LABELGET:
	sty BUFNCHAR
	jsr OBJOUTCLRBUF
	jsr RCHEK
ld130:
	jsr LINENXTCHR
	bcc ld16f
ld135:
	cmp #';'
	beq ld16f
ld139:
	jsr STRGETLASTCHR
	bcc ld176
ld13e:
	ldx BUFNXTC
	lda INBUF,x

	cmp #'.'	; begin of directive?
	bne @nodirective
	jmp SELDIR

@nodirective:
	cmp #'*'	; begin of PC assignment?
	bne @nopcassign
	jmp PCSET

@nopcassign:
	ldy BUFSTRLEN
	cpy #$07
	lda #$09
	bcs ld187
ld158:
	sty OPCBYTES2
	jsr ld778
	lda #$10
	bcc ld187
ld161:
	lda BUFSTRLEN
	cmp #$03
	bne ld172
ld167:
	jsr OPCDATAGET
	bcc ld172
ld16c:
	jmp INSTENC
ld16f:
	jmp ld68a
ld172:
	lda FLGLST
	beq ld17a
ld176:
	lda #$03
	bne ld187
ld17a:
	lda #$01
	sta FLGLST
	ldx BUFPTR
	jsr IFALPHA
	bcs ld18e
ld185:
	lda #$08
ld187:
	jmp ld67a
ld18a:
	lda #' '
	bne ld187
ld18e:
	lda SSEARCH+1
	cmp #' '
	bne ld1a0
ld194:
	lda SSEARCH
	ldx #$04
ld198:
	cmp ldfa3,x
	beq ld18a
ld19d:
	dex
	bpl ld198
ld1a0:
	ldx #$00
ld1a2:
	lda SSEARCH,x
	pha
	inx
	cpx #.sizeof(SSEARCH)
	bne ld1a2
ld1aa:
	lda BUFSTRLEN
	pha
	jsr LINEPTRBEGIN
	bcc ld1b6
ld1b2:
	cmp #'='
	beq OPEQ
ld1b6:
	jsr SYMTBLSEARCH
	bcc ld1cb
ld1bb:
	lda SYMVAL
	cmp PC+1
	bne ld1c7
ld1c1:
	lda SYMVAL+1
	cmp PC
	beq ld1d2
ld1c7:
	lda #$02
	bne ld208
ld1cb:
	lda PC+1
	ldy PC
	jsr SYMTBLSTORE
ld1d2:
	lda BUFPTR
	cmp BUFNCHAR
	bcs ld16f
ld1d8:
	jmp ld130
PCSET:
	lda #$ff
	sta FLGPCASSIGN
	jsr LINEPTRINC
	bcc ld1f9
ld1e4:
	cmp #'='
	bne ld1f9
OPEQ:
	inc BUFPTR
	ldx BUFPTR
	jsr ld670
	jsr LINENXTCHR
	bcs ld1fc
ld1f4:
	lda #$07
	jmp ld3d9
ld1f9:
	jmp ld674
ld1fc:
	jsr EXPEVAL
	lda #$13
	dey
	bmi ld20b
ld204:
	bne ld208
ld206:
	lda #$11
ld208:
	jmp ld67a
ld20b:
	lda FLGPCASSIGN
	beq ld22e
ld20f:
	lda FLGOVF
	ror
	bcc ld220
ld214:
	lda #$21
	ldy #$ff
	jsr ERRDECODE
	ldx #$00
	txa
	beq ld227
ld220:
	jsr ERRNONE
	lda EVALVAL
	ldx EVALVAL+1
ld227:
	sta PC+1
	stx PC
	jmp ld686
ld22e:
	pla
	stx BUFSTRLEN
	ldx #$05
ld233:
	pla
	sta SSEARCH,x
	dex
	bpl ld233
ld239:
	jsr SYMTBLSEARCH
	bcc ld24f
ld23e:
	lda SYMVAL
	cmp EVALVAL
	bne ld24a
ld244:
	lda SYMVAL+1
	cmp EVALVAL+1
	beq ld256
ld24a:
	lda #$02
	jmp ld3d9
ld24f:
	lda EVALVAL
	ldy EVALVAL+1
	jsr SYMTBLSTORE
ld256:
	jmp ld68a
SELDIR:
	lda #$14
	sta SAVERRN
	ldx BUFNXTC
	inx
	jsr SETNCH3
ld263:
	cpx BUFNCHAR
	bcs ld271
ld267:
	lda INBUF,x
	cmp #' '
	beq ld271
ld26d:
	inx
	jmp ld263
ld271:
	stx BUFPTR
	lda #$00
	sta GENCNT
	bcs ld27c
ld279:
	jmp ld678
ld27c:
	lda #$8a
	ldy #$dd
	ldx #$07
ld282:
	jsr MNEMONICFIND
	bcc ld279
ld287:
	txa
	asl
	tax
	lda DIRADDR,x
	sta DIRADR
	lda DIRADDR+1,x
	sta DIRADR+1
	lda DIRFLG
	jmp (DIRADR)
DIRBYT:
	lda #$01
	bne ld2a3
DIRDBY:
	lda #$03
	bne ld2a3
DIRWOR:
	lda #$02
ld2a3:
	sta FGLDEF
	tay
	cpy #$03
	bne ld2ab
ld2aa:
	dey
ld2ab:
	jsr LINENXTCHR
	bcs ld2b3
ld2b0:
	jmp ld391
ld2b3:
	sty NBYTES
ld2b5:
	ldx BUFNXTC
	jsr EXPEVAL
	dey
	bmi ld2df
ld2bd:
	beq ld2c2
ld2bf:
	jmp ld346
ld2c2:
	lda #$01
	sta SAVERRN
ld2c6:
	cmp #$01
	bne ld2ce
ld2ca:
	ldy FGLDEF
	sty NBYTES
ld2ce:
	lda SAVERRN
	ldy NBYTES
	jsr ERRDECODE
	ldy NBYTES
	cpy #$03
	bne ld326
ld2db:
	dec NBYTES
	bne ld326
ld2df:
	jsr PCADD0
	lda #$04
	sta SAVERRN
	ldx FGLDEF
	cpx #$03
	bne ld2f6
ld2ec:
	lda EVALVAL
	jsr OBJOUTA
	lda #$01
	jsr PCSTOPTR
ld2f6:
	lda EVALVAL+1
	jsr OBJOUTA
	cpx #$03
	bne ld303
ld2ff:
	lda #$02
	bne ld305
ld303:
	lda #$01
ld305:
	jsr PCSTOPTR
	cpx #$02
	bne ld311
ld30c:
	lda EVALVAL
	jsr OBJOUTA
ld311:
	lda FLGOVF
	and #$09
	bne ld2c6
ld317:
	cpx #$01
	bne ld31f
ld31b:
	lda EVALVAL
	bne ld2c6
ld31f:
	lda #$00
	ldy NBYTES
ld323:
	jsr ERRDECODE
ld326:
	jsr ld722
	bcs ld32e
ld32b:
	jmp ld686
ld32e:
	cmp #','
	beq ld336
ld332:
	inc BUFPTR
	bne ld326
ld336:
	jsr LINELIST
	stx BUFPTR
	jsr LINENXTCHR
	bcc ld343
ld340:
	jmp ld2b5
ld343:
	jmp ld674
ld346:
	lda INBUF,x
	ldy FGLDEF
	cmp #$27
	beq ld352
ld34e:
	lda #$13
	bne ld323
ld352:
	ld353 = * + 1
; Instruction parameter $d353 jumped to.
	cpx BUFNXTC
ld354:
	ld355 = * + 1
; Instruction parameter $d355 jumped to.
	bne ld34e
ld356:
	cpy #$02
	bcs ld34e
ld35a:
	stx BUFPTR
	lda #$00
	sta GENCNT
ld360:
	jsr PCSTOPTR
	inc BUFPTR
	ldx BUFPTR
	cpx BUFNCHAR
	bcs ld38f
ld36b:
	lda INBUF,x
	cmp #$27
	bne ld37f
ld371:
	inc BUFPTR
	ldx BUFPTR
	cpx BUFNCHAR
	bcs ld389
ld379:
	lda INBUF,x
	cmp #$27
	bne ld389
ld37f:
	jsr OBJOUTA
	inc GENCNT
	lda GENCNT
	jmp ld360
ld389:
	ldy GENCNT
	lda #$00
	beq ld323
ld38f:
	ldy GENCNT
ld391:
	lda #$07
	jmp ld683

; ..decode .OPT XXX; then jump-indirect to do it
OPT:
	cmp #','	;','
	bne ld3d1
ld39a:
	inx
	stx BUFPTR
DIROPT:
	jsr LINENXTCHR
	bcc ld3d1
ld3a2:
	jsr SETNCH3
	bcs ld3aa
ld3a7:
	jmp ld678
ld3aa:
	lda #$b1
	ldy #$dd
	ldx #$14
	jmp ld282
DIRGEN:
	and #$7f
	bpl SETDIRFLG
DIRNOG:
	ora #$80
	bne SETDIRFLG
DIRNOL:
	ora #$10
	bne SETDIRFLG
DIRLIS:
	and #$ef
	jmp SETDIRFLG
DIRNOM:
	ora #$08
	bne SETDIRFLG
DIRMEM:
	and #$f7
SETDIRFLG:
	sta DIRFLG
DIRCOU:
	jsr ld722
	bcs OPT
ld3d1:
	jmp ld68a
DIRSKI:
	jsr LINENXTCHR
	lda #$cc
ld3d9:
	ldy #$00
	jmp ld683
DIREND:
	jsr ERRNONE
	lda PASSCNT
	beq ld3fc
ld3e5:
	ldx #OFFMSGERS
	jsr PRMSG	; print ' ERRORS='
	lda P2ERRS+1
	ldx P2ERRS
	jsr WRAX
	jsr PRCRLF
	inc PASSCNT
	jsr BUFMOVOBJOUT
	jmp COMIN
ld3fc:
	inc PASSCNT
	ldx #OFFMSGP2
	jsr PRMSG	; print 'PASS 2'
	jsr PRCRLF
	lda INFLG
	cmp #$55
	beq ld433
ld40d:
	cmp #$4d
	bne ld417
ld411:
	jmp ld0c3
TAPTOGL:
	jsr TOGTA1
ld417:
	jsr REDOUT
	cmp #$31
	beq TAPTOGL
ld41e:
	cmp #$32
	bne ld428
ld422:
	jsr TOGTA2
	jmp ld417
ld428:
	cmp #' '
	bne ld417
ld42c:
	lda INFLG
	cmp #$54
	bne ld411
ld433:
	jsr LINENXTCHR
	bcc FNAMESET
ld438:
	jsr GETFILE
	jmp ld0c3
FNAMESET:
	ldy #$00
ld440:
	lda AIDFNAM,y
	sta NAME,y
	jsr OUTDP1
	iny
	cpy #$05
	bne ld440
ld44e:
	jsr GETFILEIFTORU
	jmp ld0c3
INSTENC:
	lda #$00
	sta OPNALLCOD
	sta NBYTCOMP
	sta EXPOK
	jsr PCADD0
	lda BASOPC
	jsr OBJOUTA
	lda OPCTYP
	cmp #$14
	bne ld46f
ld46a:
	ldy #$01
	jmp ld68c
ld46f:
	cmp #$15
	bne ld47b
ld473:
	lda #$0e
	sta OPCTYP
	lda #$07
	sta SAVERRN
ld47b:
	jsr LINEPTRBEGIN
	bcs ld487
ld480:
	lda #$18
	sta SAVERRN
	jmp ld674
ld487:
	cmp #$3b
	beq ld4d6
ld48b:
	cmp #$41
	bne ld4af
ld48f:
	inx
	cpx BUFNCHAR
	dex
	bcs ld49b
ld495:
	ldy INBUF+1,x
	cpy #' '
	bne ld4af
ld49b:
	ldy OPCTYP
	dey
	tya
	jsr OPADDGET
	bmi ld4aa
ld4a4:
	jsr OBJADDA
	jmp ld46a
ld4aa:
	lda #$05
	jmp ld67a
ld4af:
	cmp #$23
	bne ld4b7
ld4b3:
	lda #$0a
	bne ld4bd
ld4b7:
	cmp #$28
	bne ld4c4
ld4bb:
	lda #$05
ld4bd:
	sta OPNALLCOD
	inc BUFNXTC
	jsr LINELIST
ld4c4:
	jsr EXPEVAL
	lda #$13
	sta SAVERRN
	dey
	bmi ld502
ld4ce:
	beq ld4fc
ld4d0:
	lda OPNALLCOD
	cmp #$0a
	beq ld4d9
ld4d6:
	jmp ld678
ld4d9:
	lda INBUF,x
	cmp #$27
	bne ld4d6
ld4df:
	txa
	tay
	jsr LINELIST
	lda INBUF,x
	sta EVALVAL+1
	inx
	cpx BUFNCHAR
	bcs ld502
ld4ed:
	lda INBUF,x
	cmp #' '
	beq ld502
ld4f3:
	cmp #$27
	beq ld502
ld4f7:
	lda SAVERRN
	jmp ld67a
ld4fc:
	inc EXPOK
	lda #$02
	sta NBYTCOMP
ld502:
	jsr ld722
	bcc ld536
ld507:
	cmp #$29
	bne ld518
ld50b:
	inc OPNALLCOD
	inc OPNALLCOD
	lda BASOPC
	cmp #$4c
	beq ld53c
ld515:
	jsr LINELIST
ld518:
	lda INBUF,x
	cmp #','
	bne ld527
ld51e:
	lda BASOPC
	cmp #$4c
	beq ld544
ld524:
	jsr LINELIST
ld527:
	lda INBUF,x
	cmp #$58
	beq ld563
ld52d:
	cmp #$59
	beq ld561
ld531:
	lda #$12
	jmp ld67a
ld536:
	lda BASOPC
	cmp #$4c
	bne ld565
ld53c:
	lda OPNALLCOD
	beq ld554
ld540:
	cmp #$07
	beq ld549
ld544:
	lda #$18
	jmp ld676
ld549:
	inx
	cpx BUFNCHAR
	bcs ld554
ld54e:
	lda INBUF,x
	cmp #' '
	bne ld544
ld554:
	lda OPNALLCOD
	beq ld55a
ld558:
	lda #' '
ld55a:
	ldy #$02
	sty NBYTCOMP
	jmp ld61e
ld561:
	inc OPNALLCOD
ld563:
	inc OPNALLCOD
ld565:
	lda EXPOK
	bne ld5db
ld569:
	lda OPCTYP
	cmp #$0e
	bne ld5a4
ld56f:
	clc
	lda PC
	adc #$02
	sta WS+1
	lda PC+1
	adc #$00
	sta WS
	lda EVALVAL+1
	sec
	sbc WS+1
	sta EVALVAL+1
	tay
	lda EVALVAL
	sbc WS
	sta EVALVAL
	bpl ld591
ld58c:
	tya
	bmi ld598
ld58f:
	bpl ld594
ld591:
	tya
	bpl ld598
ld594:
	lda #$17
	sta SAVERRN
ld598:
	lda EVALVAL
	beq ld5c0
ld59c:
	cmp #$ff
	beq ld5bc
ld5a0:
	lda #$17
	bne ld5ba
ld5a4:
	lda OPNALLCOD
	cmp #$06
	bcc ld5c0
ld5aa:
	cmp #$0a
	bcs ld5c0
ld5ae:
	lda EVALVAL
	bne ld5b8
ld5b2:
	lda EVALVAL+1
	cmp #$ff
	bne ld5c0
ld5b8:
	lda #$19
ld5ba:
	sta SAVERRN
ld5bc:
	lda #$00
	sta EVALVAL
ld5c0:
	lda #$02
	sta NBYTCOMP
	lda EVALVAL
	bne ld5db
ld5c8:
	lda #$01
	sta NBYTCOMP
	lda OPNALLCOD
	clc
	adc #$02
ld5d1:
	sta OPNALLCOD
	cmp #CR
	bcc ld5e6
ld5d7:
	lda #$15
	bne ld5ff
ld5db:
	lda #CR
ld5dd:
	clc
	adc OPNALLCOD
	sta OPNALLCOD
	cmp #$10
	bcs ld5f3
ld5e6:
	tay
	dey
	lda TABREFNDX,y
	clc
	adc OPCTYP
	jsr OPADDGET
	bpl ld61e
ld5f3:
	lda EXPOK
	beq ld60e
ld5f7:
	lda NBYTCOMP
	cmp #$02
	beq ld602
ld5fd:
	lda #$18
ld5ff:
	jmp ld676
ld602:
	lda #$01
	sta NBYTCOMP
	lda OPNALLCOD
	sec
	sbc #$0b
	jmp ld5d1
ld60e:
	lda NBYTCOMP
	cmp #$01
	beq ld618
ld614:
	lda #$18
	bne ld5ff
ld618:
	inc NBYTCOMP
	lda #$0b
	bne ld5dd
ld61e:
	jsr OBJADDA
	lda EXPOK
	bne ld65d
ld625:
	lda #$01
	jsr PCSTOPTR
	lda EVALVAL+1
	jsr OBJOUTA
	lda #$02
	jsr PCSTOPTR
	lda NBYTCOMP
	cmp #$01
	beq ld63f
ld63a:
	lda EVALVAL
	jsr OBJOUTA
ld63f:
	lda SAVERRN
	cmp #$17
	beq ld66b
ld645:
	cmp #$19
	beq ld678
ld649:
	lda #$09
	and FLGOVF
	bne ld67e
ld64f:
	lda NBYTCOMP
	cmp #$01
	bne ld659
ld655:
	lda EVALVAL
	bne ld67e
ld659:
	lda #$00
	beq ld680
ld65d:
	ldy NBYTCOMP
	lda OPCTYP
	cmp #$0e
	bne ld667
ld665:
	ldy #$01
ld667:
	lda #$01
	bne ld682
ld66b:
	ldy #$02
	bne ld683
LINELIST:
	inx
ld670:
	cpx BUFNCHAR
	bcc ld689
ld674:
	lda #$07
ld676:
	sta SAVERRN
ld678:
	lda SAVERRN
ld67a:
	ldy #$03
	bne ld683
ld67e:
	lda #$04
ld680:
	ldy NBYTCOMP
ld682:
	iny
ld683:
	jsr ERRDECODE
ld686:
	ldx #$fd
	txs
ld689:	rts
ld68a:
	ldy #$00
ld68c:
	lda #$00
	beq ld683
DIRFIL:
	jsr LINENXTCHR
	bcc ld698
ld695:
	jsr GETFILE
ld698:
	lda #INBUF
	jmp ld3d9
DIRPAG:
	lda PASSCNT
	beq ld6c7
ld6a1:
	lda DIRFLG
	and #$10
	bne ld6c7
ld6a7:
	ldy #$13
ld6a9:
	lda #$5f
	jsr OUTALL
	dey
	bpl ld6a9
ld6b1:
	jsr PRCRLF
	jsr LINENXTCHR
	bcc ld6c7
ld6b9:
	lda INBUF,x
	cmp #$27
	bne ld6c7
ld6bf:
	jsr BUFOUT
	bcs ld6c7
ld6c4:
	jsr PRCRLF
ld6c7:
	jmp DIRSKI
LINEPTRBEGIN:
	lda BUFSTRLASTC
	sta BUFPTR
LINEPTRINC:
	inc BUFPTR
LINENXTCHR:
	lda BUFNCHAR
	beq ld70d
ld6d4:
	dec BUFPTR
ld6d6:
	inc BUFPTR
	ldx BUFPTR
	cpx BUFNCHAR
	bcs ld70d
ld6de:
	lda INBUF,x
	cmp #' '
	beq ld6d6
ld6e4:
	stx BUFNXTC
	sec
	rts
STRGETLASTCHR:
	ldy #$00
	sty BUFSTRLEN
	ldx BUFPTR
ld6ee:
	cpx BUFNCHAR
	bcs ld709
ld6f2:
	lda INBUF,x
	cmp #' '
	beq ld700
ld6f8:
	cmp #'='
	beq ld700
ld6fc:
	cmp #$3b
	bne ld70f
ld700:
	cpy #$00
	bne ld71a
ld704:
	dex
	stx BUFSTRLASTC
	sec
	rts
ld709:
	cpy #$00
	beq ld704
ld70d:
	clc
	rts
ld70f:
	cmp #$27
	bne ld71a
ld713:
	iny
	cpy #$02
	bne ld71a
ld718:
	ldy #$00
ld71a:
	inx
	inc BUFSTRLEN
	jmp ld6ee
SEPFIND:
	inc BUFPTR
ld722:
	ldx BUFPTR
	cpx BUFNCHAR
	bcs ld766
ld728:
	lda INBUF,x
	cmp #$27
	bne ld73d
ld72e:
	inx
	stx BUFPTR
	cpx BUFNCHAR
	bcs ld766
ld735:
	lda INBUF,x
	cmp #$27
	bne ld72e
ld73b:
	beq SEPFIND
ld73d:
	cmp #' '
	beq ld766
ld741:
	cmp #$29
	beq ld749
ld745:
	cmp #','
	bne SEPFIND
ld749:
	sec
	rts
BUFOUT:
	inx
	cpx BUFNCHAR
	bcs ld767
ld750:
	lda INBUF,x
	cmp #$27
	beq ld766
ld756:
	jsr OUTALL
	jmp BUFOUT
IFALPHA:
	lda INBUF,x
	cmp #$41
	bcc ld766
ld762:
	cmp #$5b
	bcc ld749
ld766:
	clc
ld767:	rts
IFNUM:
	lda INBUF,x
	cmp #$30
	bcc ld766
ld76e:
	cmp #$3a
	bcc ld749
ld772:
	clc
	rts
SETNCH3:
	lda #$03
CHRTRANSFER:
	sta OPCBYTES2
ld778:
	ldy #$00
ld77a:
	cpy #$06
	bcs ld749
ld77e:
	lda #' '
	cpy OPCBYTES2
	bcs ld791
ld784:
	jsr IFALPHA
	bcs ld78e
ld789:
	jsr IFNUM
	bcc ld766
ld78e:
	lda INBUF,x
	inx
ld791:
	sta SSEARCH,y
	iny
	bne ld77a
EXPEVAL:
	lda #$00
	sta EVALVAL
	sta EVALVAL+1
	ror FLGOVF
	asl FLGOVF
	jsr CHRGETX
	bcs ld7cc
ld7a6:
	ldy #'+'
	cmp #'-'
	bne ld7ae
ld7ac:
	tay
	inx
ld7ae:
	sty $15
	lda #$00
	sta $36
	jsr CHRGETX
	bcs ld7cc
EXPLOW:
	cmp #$3c
	bne EXPHI
ld7bd:
	dec $36
	bmi ld7c7
EXPHI:
	cmp #$3e
	bne ld7cf
ld7c5:
	inc $36
ld7c7:
	inx
	cpx BUFNCHAR
	bcc ld7cf
ld7cc:
	jmp ld832
ld7cf:
	jsr IFNUM
	ldy #$04
EXPDEC:
	bcs ld835
ld7d6:
	ldy #$06
	cmp #$24
EXPHEX:
	beq ld82d
ld7dc:
	ldy #$02
	cmp #$40
EXPOCT:
	beq ld82d
ld7e2:
	ldy #$00
	cmp #$25
EXPBIN:
	beq ld82d
SYMSEARCHGET:
	jsr IFALPHA
	bcc CURPCEVAL
ld7ed:
	txa
	tay
ld7ef:
	inx
	cpx BUFNCHAR
	bcs ld7fe
ld7f4:
	jsr IFNUM
	bcs ld7ef
ld7f9:
	jsr IFALPHA
	bcs ld7ef
ld7fe:
	sty WS
	txa
	sec
	sbc WS
	cmp #$07
	bcs ld7cc
ld808:
	ldx WS
	jsr CHRTRANSFER
	bcc ld7cc
ld80f:
	stx WS+1
	jsr SYMTBLSEARCH
	ldx WS+1
	bcs ld844
ld818:
	ldx WS
	ldy #$01
	rts
CURPCEVAL:
	cmp #'*'
	bne ld7cc
ld821:
	lda PC
	sta SYMVAL+1
	lda PC+1
	sta SYMVAL
	inx
	jmp ld844
ld82d:
	inx
	cpx BUFNCHAR
	bcc ld835
ld832:
	ldy #$02
	rts
ld835:
	lda TABCONVERT,y
	sta BASCNVPRM
	lda TABCONVERT+1,y
	sta BASCNVPRM+1
	jsr BASECONV
	bcc ld832
ld844:
	lda $36
	beq ld852
ld848:
	bmi ld84e
ld84a:
	lda SYMVAL
	sta SYMVAL+1
ld84e:
	lda #$00
	sta SYMVAL
ld852:
	lda $15
	cmp #'+'
	bne ld882
INTADD:
	lda EVALVAL+1
	clc
	adc SYMVAL+1
	sta EVALVAL+1
	lda EVALVAL
	adc SYMVAL
	jsr FLGEVALTEST
	bne ld86f
ld868:
	tya
	beq ld87f
ld86b:
	lda #$08
	bne ld87b
ld86f:
	tya
	beq ld879
ld872:
	lda #$fe
	and FLGOVF
	jmp ld87d
ld879:
	lda #$01
ld87b:
	ora FLGOVF
ld87d:
	sta FLGOVF
ld87f:
	jmp ld8a5
ld882:
	cmp #'-'
	bne ld832
INTSUB:
	lda EVALVAL+1
	sec
	sbc SYMVAL+1
	sta EVALVAL+1
	lda EVALVAL
	sbc SYMVAL
	jsr FLGEVALTEST
	bne ld89b
ld896:
	tya
	bne ld872
ld899:
	beq ld879
ld89b:
	sty WS
	lda #$01
	and FLGOVF
	eor WS
	bne ld86b
ld8a5:
	jsr CHRGETX
	ldy #$00
	bcs ld8c2
ld8ac:
	jmp ld7ac
FLGEVALTEST:
	sta EVALVAL
	lda #$00
	rol
	tay
	lda #$01
	and FLGOVF
	asl
	sta WS
	lda #$02
	and FLGOVF
	eor WS
ld8c2:
	rts
CHRGETX:
	cpx BUFNCHAR
	bcs ld8da
ld8c7:
	lda INBUF,x
	cmp #' '
	beq ld8da
ld8cd:
	cmp #','
	beq ld8da
ld8d1:
	cmp #$29
	beq ld8da
ld8d5:
	cmp #$3b
	beq ld8da
ld8d9:
	clc
ld8da:
	rts
OPADDGET:
	lsr
	tay
	lda TABOPNFMT,y
	bcs ld8e6
ld8e2:
	lsr
	lsr
	lsr
	lsr
ld8e6:	and #$0f
	tay
	lda TABADDENDS,y
	rts
BASECONV:
	lda #$00
	sta SYMVAL
	sta SYMVAL+1
	sta OPCBYTES2
ld8f5:
	jsr IFNUM
	bcc ld8ff
ld8fa:
	sbc #$30
	jmp ld906
ld8ff:
	jsr IFALPHA
	bcc ld94a
ld904:
	sbc #DIRFLG
ld906:
	cmp BASCNVPRM
	bcs ld94a
ld90a:
	inc OPCBYTES2
	pha
	ldy BASCNVPRM+1
	bpl ld91d
ld911:
	ldy #$03
	lda SYMVAL+1
	asl
	sta WS+1
	lda SYMVAL
	rol
	sta WS
ld91d:
	asl SYMVAL+1
	rol SYMVAL
	jsr CARRYTEST
	dey
	bne ld91d
ld927:
	bit BASCNVPRM+1
	bpl ld93b
ld92b:
	lda SYMVAL+1
	clc
	adc WS+1
	sta SYMVAL+1
	lda SYMVAL
	adc WS
	sta SYMVAL
	jsr CARRYTEST
ld93b:
	pla
	clc
	adc SYMVAL+1
	sta SYMVAL+1
	bcc ld945
ld943:
	inc SYMVAL
ld945:
	inx
	cpx BUFNCHAR
	bcc ld8f5
ld94a:
	lda OPCBYTES2
	cmp #$01
ld94e:	rts
CARRYTEST:
	bcc ld94e
ld951:
	lda #$08
	jmp ld87b
TABCONVERT:
	.byt $02
	.byt $01
	.byt $08
	.byt $03
	.byt $0A
	.byt $FF
	.byt $10
	.byt $04
SYMTBLSEARCH:
	lda SYMTSTART
	sta $3c
	lda SYMTSTART+1
	sta $3d
	lda #$00
	sta $12
	sta $11
ld96c:
	inc $12
	bne ld972
ld970:
	inc $11
ld972:	lda SYMTBLSIZ+1
	cmp $12
	lda SYMTBLSIZ
	sbc $11
	bcc ld993
ld97c:
	ldy #$05
ld97e:
	lda SSEARCH,y
	cmp ($3c),y
	bne ld994
ld985:
	dey
	bpl ld97e
ld988:
	ldy #$06
	lda ($3c),y
	sta SYMVAL
	iny
	lda ($3c),y
	sta SYMVAL+1
ld993:
	rts
ld994:
	lda $3c
	clc
	adc #$08
	sta $3c
	bcc ld96c
ld99d:
	inc $3d
	jmp ld96c
SYMTBLSTORE:
	sta SYMVAL
	sty SYMVAL+1
	lda $3c
	cmp SYMTTOP
	lda $3d
	sbc SYMTTOP+1
	bcs ld9cc
ld9b0:
	ldy #$05
ld9b2:
	lda SSEARCH,y
	sta ($3c),y
	dey
	bpl ld9b2
ld9ba:
	ldy #$06
	lda SYMVAL
	sta ($3c),y
	iny
	lda SYMVAL+1
	sta ($3c),y
	inc SYMTBLSIZ+1
	bne ld9cb
ld9c9:
	inc SYMTBLSIZ
ld9cb:
	rts
ld9cc:
	ldx #OFFMSGOVF	; print 'SYM TBL OVERFLOW'
	jsr PRMSG
	jmp ASSEM
OPCDATAGET:
	lda #$59
	ldy #$de
	ldx #DIRFLG
	jsr MNEMONICFIND
	bcc ld9e9
ld9df:
	lda TABOPCCLASS,x
	sta OPCTYP
	lda TABBASOPC,x
	sta BASOPC
ld9e9:
	rts
MNEMONICFIND:
	sta DIRADR
	sty DIRADR+1
ld9ee:
	ldy #$02
ld9f0:
	lda SSEARCH,y
	cmp (DIRADR),y
	bne ld9fc
ld9f7:
	dey
	bpl ld9f0
ld9fa:
	sec
	rts
ld9fc:
	lda DIRADR
	sec
	sbc #$03
	sta DIRADR
	bcs lda07
lda05:
	dec $0e
lda07:
	dex
	bpl ld9ee
lda0a:
	clc
lda0b:
	rts
ERRNONE:
	lda #$00
	tay
ERRDECODE:
	sta $08
	sty $04
	ldx PC
	stx PCTEMP
	ldx PC+1
	stx PCTEMP+1
	cpy #$ff
	bne lda20
lda1f:
	iny
lda20:	cpy #$04
	bne lda2a
lda24:
	cmp #$c9
	bne lda2a
lda28:
	ldy #$02
lda2a:
	cpy #$03
	bne lda32
lda2e:
	cmp #$ca
	beq lda28
lda32:
	tya
	cpy #$15
	bcc lda39
lda37:
	ldy #$14
lda39:
	sty OPCBYTES2
	clc
	adc PC
	sta PC
	bcc lda44
lda42:
	inc PC+1
lda44:
	lda PASSCNT
	beq lda0b
lda48:
	lda $08
	beq LINEANDOBJANDOUT
lda4c:
	cmp #$cc
	bne lda59
lda50:
	lda #$10
	and DIRFLG
	bne lda0b
lda56:
	jmp PRSPCRLF
lda59:
	sta ERRNUM
	jmp ERROROUT
LINEANDOBJANDOUT:
	lda #$10
	and DIRFLG
	beq lda6f
lda64:
	lda $08
	beq lda6c
lda68:
	cmp #$c8
	bcc lda6f
lda6c:
	jmp BUFMOVOBJOUT
lda6f:
	lda PCTEMP
	sta PC
	lda PCTEMP+1
	sta PC+1
	jsr PCADD0
	ldy #$00
	sty BUFNXTC
LINEIFPCOUT:
	lda FLGLST
	bne LINEPCOUT
lda82:
	lda FLGPCASSIGN
	bne LINEPCOUT
lda86:
	lda PC
	cmp $44
	lda PC+1
	sbc $45
	bcc LINEOPOUT
LINEPCOUT:
	ldx #OFFMSGEQ	; print '=='
	jsr PRMSG
	lda PC+1
	ldx PC
	jsr WRAX
	lda FLGLST
	beq ldac0
LINELABELOUT:
	jsr PRSPACE
	ldx #$00
ldaa5:
	lda INBUF,x
	inx
	cmp #' '
	bne ldab2
ldaac:
	cpx BUFNCHAR
	beq ldac0
ldab0:
	bne ldaa5
ldab2:
	jsr OUTALL
	cpx BUFNCHAR
	beq LINEPCRECALC
ldab9:
	lda INBUF,x
	inx
	cmp #' '
	bne ldab2
ldac0:
	jsr PRCRLF
LINEPCRECALC:
	lda #$10
	clc
	adc PC
	sta $44
	lda PC+1
	adc #$00
	sta $45
LINEOPOUT:
	lda $04
ldad2:
	pha
	lda #$00
	sta $34
	ldx #$00
	lda INBUF
	cmp #$3b
	bne ldae2
ldadf:
	jmp ldb90
ldae2:
	ldy #$00
	pla
	tax
	bmi ldaf4
ldae8:
	cmp #$04
	bmi ldaf4
ldaec:
	ldx #$02
	sec
	sbc #$02
	jmp ldaf6
ldaf4:
	lda #$00
ldaf6:
	pha
ldaf7:
	dex
	bmi LINEOUT
ldafa:
	lda #$08
	and DIRFLG
	bne ldb05
ldb00:
	lda (OBJDSTPTR),y
	jmp ldb0c
ldb05:
	ldy BUFNXTC
	lda $0170,y
	inc BUFNXTC
ldb0c:
	inc $34
	inc $34
	jsr NUMA
	jsr PCADD1
	jmp ldaf7
LINEOUT:
	lda LINCNT
	beq ldb20
ldb1d:
	jmp LINEFINISH
ldb20:
	lda #' '
	ldy $34
ldb24:
	cpy #$07
	bpl ldb2e
ldb28:
	jsr OUTALL
	iny
	bpl ldb24
ldb2e:
	ldx #$00
	lda $08
	bne LINESTRFMT
ldb34:
	ldy #$00
	lda FLGLST
	beq ldb55
ldb3a:
	sty FLGLST
ldb3c:
	lda INBUF,x
	inx
	cmp #' '
	bne ldb49
ldb43:
	cpx BUFNCHAR
	bcs LINEFINISH
ldb47:
	bcc ldb3c
ldb49:
	iny
	cpx BUFNCHAR
	bcs LINEFINISH
ldb4e:
	lda INBUF,x
	inx
	cmp #' '
	bne ldb49
ldb55:
	lda INBUF,x
	cmp #' '
	bne LINESTRFMT
ldb5b:
	inx
	cpx BUFNCHAR
	bcs LINEFINISH
ldb60:
	bcc ldb55
LINESTRFMT:
	lsr GENCNT
ldb64:
	cpx BUFNCHAR
	bcs LINEFINISH
ldb68:
	lda INBUF,x
	cmp #$3b
	beq ldb8d
ldb6e:
	cmp #$27
	beq ldb9d
ldb72:
	cmp #' '
	bne ldb7b
ldb76:
	sec
	ror GENCNT
	bmi ldb89
ldb7b:
	bit GENCNT
	bpl ldb84
ldb7f:
	lsr GENCNT
	jsr PRSPACE
ldb84:
	lda INBUF,x
ldb86:
	jsr OUTALL
ldb89:
	inx
	jmp ldb64
ldb8d:
	jsr PRCRLF
ldb90:
	cpx BUFNCHAR
	bcs LINEFINISH
ldb94:
	lda INBUF,x
	inx
	jsr OUTALL
	jmp ldb90
ldb9d:
	bit GENCNT
	bpl ldba4
ldba1:
	jsr PRSPACE
ldba4:
	lda INBUF,x
	jsr OUTALL
	jsr BUFOUT
	bcs LINEFINISH
ldbae:
	lsr GENCNT
	bpl ldb86
LINEFINISH:
	jsr PRCRLF
	inc LINCNT
	pla
	beq ldbc4
ldbba:
	bit DIRFLG
	bmi ldbc1
ldbbe:
	jmp ldad2
ldbc1:
	jsr PCADDA
ldbc4:
	jmp BUFMOVOBJOUT
ERROROUT:
	jsr LINEANDOBJANDOUT
	lda ERRNUM
	cmp #$46
	beq ldbec
ldbd0:
	ldx #OFFMSGERR	; print '**ERROR'
	jsr PRMSG
	lda ERRNUM
	jsr NUMA
	jsr PRCRLF
	sed
	clc
	lda P2ERRS
	adc #$01
	sta P2ERRS
	lda P2ERRS+1
	adc #$00
	sta P2ERRS+1
	cld
ldbec:	rts
PCADD1:
	lda #$01
PCADDA:
	clc
	adc PC
	sta PC
	bcc PCADD0
ldbf6:
	inc PC+1
PCADD0:
	lda #$00
PCSTOPTR:
	clc
	adc PC
	sta OBJDSTPTR
	lda PC+1
	adc #$00
	sta OBJDSTPTR+1
	rts
OBJBYTE:
	sec
	bcs ldc0a
OBJHEX:
	clc
ldc0a:	pha
	lda OUTFLG
	sta LSTOUTFLG
	lda OBJOUTFLG
	sta OUTFLG
	pla
	bcs ldc23
ldc18:
	jsr OUTCK1
ldc1b:
	pha
	lda LSTOUTFLG
	sta OUTFLG
ldc21:	pla
	rts
ldc23:
	jsr OUTALL
	jmp ldc1b
OBJADDA:
	clc
	adc BASOPC
	dec OBJBUFNDX
OBJOUTA:
	pha
	lda PASSCNT
	beq ldc21
ldc33:
	lda DIRFLG
	and #$08
	bne ldc3f
ldc39:
	pla
	ldy #$00
	sta (OBJDSTPTR),y
	rts
ldc3f:
	ldy OBJBUFNDX
	pla
	sta $0170,y
	iny
	cpy #$14
	bne ldc4b
ldc4a:
	dey
ldc4b:
	sty OBJBUFNDX
ldc4d:	rts
BUFMOVOBJOUT:
	lda DIRFLG
	and #$08
	beq ldc4d
ldc54:
	lda PASSCNT
	cmp #$02
	bne ldc5d
ldc5a:
	jmp OBJCLOSE
ldc5d:
	clc
	lda $85
	adc OPCBYTES2
	tay
	lda $86
	adc #$00
	cmp PC+1
	bne ldc6f
ldc6b:
	cpy PC
	beq ldc82
ldc6f:
	jsr OBJRECOUT
	sec
	lda PC
	sbc OPCBYTES2
	sta $85
	lda PC+1
	sbc #$00
	sta $86
	jsr OBJCLRCHK
ldc82:
	lda RECLEN
	clc
	adc OPCBYTES2
	cmp #$19
	bcs ldc6f
ldc8b:
	ldx RECLEN
	ldy OPCBYTES2
	beq OBJOUTCLRBUF
ldc91:
	ldy #$00
ldc93:
	inc $85
	bne ldc99
ldc97:
	inc $86
ldc99:
	lda $0170,y
	sta $8c,x
	jsr OBJUPDCHK
	inc RECLEN
	inx
	iny
	cpy OPCBYTES2
	bne ldc93
OBJOUTCLRBUF:
	lda #$00
	sta OBJBUFNDX
	lda #$ea
	ldx #$13
ldcb1:
	sta $0170,x
	dex
	bpl ldcb1
	rts

; ===============================================
; SBR
; zero and start OBJ-checksum
; calculation, then ...
; ===============================================
OBJCLRCHK:
	lda #$00
	sta RECLEN
	sta OBJRECCHK+1
	lda $85
	sta $8b
	sta OBJRECCHK
	lda $86
	sta $8a
; ===============================================
; SBR
; ... add A to OBJ-checksum
; ===============================================
OBJUPDCHK:
	clc
	adc OBJRECCHK
	sta OBJRECCHK
	bcc @ret
;ldccf:
	inc OBJRECCHK+1
@ret:	rts



OBJRECOUT:
	lda RECLEN
	beq ldd0c
ldcd6:
	jsr OBJUPDCHK
	lda RECLEN
	clc
	adc #$03
	sta SAVERRN
	lda #$3b
	jsr OBJBYTE
	ldy #$00
ldce7:
	lda RECLEN,y
	jsr OBJHEX
	iny
	cpy SAVERRN
	bne ldce7
ldcf2:
	lda OBJRECCHK+1
	jsr OBJHEX
	lda OBJRECCHK
	jsr OBJHEX
	inc OBJRECCNT
	bne OBJCRLF
ldd00:
	inc OBJRECCNT+1
OBJCRLF:
	lda #CR
	jsr OBJBYTE
	lda #$0a
	jsr OBJBYTE
ldd0c:	rts
OBJCLOSE:
	jsr OBJRECOUT
	inc OBJRECCNT
	bne ldd16
ldd14:
	inc OBJRECCNT+1
ldd16:	lda #$3b
	jsr OBJBYTE
	lda #$00
	jsr OBJHEX
	ldx #$02
ldd22:
	lda OBJRECCNT+1
	jsr OBJHEX
	lda OBJRECCNT
	jsr OBJHEX
	dex
	bne ldd22
ldd2f:
	jsr OBJCRLF
	lda OUTFLG
	pha
	lda OBJOUTFLG
	sta OUTFLG
	jsr DU11
	lda DRB
	and #$cf
	sta DRB
	pla
	sta OUTFLG
	rts
DIRADDR:
	.addr DIRBYT ;D299
	.addr DIRWOR ;D2A1
	.addr DIRDBY ;D29D
	.addr DIRSKI ;D3D4
	.addr DIRPAG ;D69D
	.addr DIREND ;D3DE
	.addr DIROPT ;D39D
	.addr DIRFIL ;D690
	.addr DIRGEN ;D3B3
	.addr DIRNOG ;D3B7
	.addr DIRCOU ;D3CC ;SYM, unsupported
	.addr DIRCOU ;D3CC ;NOS, unsupported
	.addr DIRCOU ;D3CC ;NOC, unsupported
	.addr DIRCOU ;D3CC ;CNT, unsupported
	.addr DIRCOU ;D3CC ;COU, unsupported
	.addr DIRNOL ;D3BB
	.addr DIRLIS ;D3BF
	.addr DIRMEM ;D3C8
	.addr DIRNOM ;D3C4
	.addr DIRLIS ;D3BF
	.addr DIRNOL ;D3BB

TABDIRECTIVES:
	.byt "BYT", "WOR", "DBY", "SKI", "PAG", "END", "OPT", "FIL"
	.byt "GEN", "NOG", "SYM", "NOS", "NOC", "CNT", "COU", "ERR"
	.byt "NOE", "MEM", "NOM", "LIS", "NOL"
TABMNEMONICS:
	.byt "ADC", "AND", "ASL", "BCC", "BCS", "BEQ", "BIT", "BMI"
	.byt "BNE", "BPL", "BRK", "BVC", "BVS", "CLC", "CLD", "CLI"
	.byt "CLV", "CMP", "CPX", "CPY", "DEC", "DEX", "DEY", "EOR"
	.byt "INC", "INX", "INY", "JMP", "JSR", "LDA", "LDX", "LDY"
	.byt "LSR", "NOP", "ORA", "PHA", "PHP", "PLA", "PLP", "ROL"
	.byt "ROR", "RTI", "RTS", "SBC", "SEC", "SED", "SEI", "STA"
	.byt "STX", "STY", "TAX", "TAY", "TSX", "TXA", "TXS", "TYA"

TABADDENDS:
	.byt $00, $04, $08, $0c, $10, $14, $18, $1c, $20, $ff

TABREFNDX:
	.byt $ff, $0d, $1b, $29, $37, $45, $53, $61, $6f, $7d
	.byt $8b, $99, $a7, $b5, $c3

TABOPNFMT:
	.byt $99, $99, $19, $99, $99, $99, $99, $11
	.byt $99, $01, $01, $00, $10, $90, $55, $99
	.byt $49, $95, $94, $94, $99, $99, $99, $99
	.byt $99, $49, $59, $99, $99, $99, $99, $99
	.byt $99, $99, $99, $99, $99, $99, $99, $99
	.byt $99, $99, $99, $99, $99, $99, $99, $99
	.byt $99, $00, $89, $99, $99, $99, $99, $99
	.byt $99, $99, $99, $99, $99, $99, $99, $99
	.byt $99, $99, $99, $99, $99, $99, $44, $99
	.byt $99, $99, $99, $99, $99, $29, $99, $90
	.byt $90, $99, $09, $99, $33, $00, $23, $23
	.byt $22, $32, $99, $77, $99, $69, $97, $99
	.byt $96, $99, $66, $99, $99, $99, $99, $79
	.byt $99

TABOPCCLASS:
	.byt $01, $01, $05, $15, $15, $15, $07, $15
	.byt $15, $15, $14, $15, $15, $14, $14, $14
	.byt $14, $01, $06, $06, $0c, $14, $14, $01
	.byt $0c, $14, $14, $03, $04, $01, $0b, $08
	.byt $05, $14, $01, $14, $14, $14, $14, $05
	.byt $05, $14, $14, $01, $14, $14, $14, $02
	.byt $09, $0a, $14, $14, $14, $14, $14, $14
TABBASOPC:
	.byt $61, $21, $06, $90, $b0, $f0, $24, $30
	.byt $d0, $10, $00, $50, $70, $18, $d8, $58
	.byt $b8, $c1, $e0, $c0, $c6, $ca, $88, $41
	.byt $e6, $e8, $c8, $4c, $20, $a1, $a2, $a0
	.byt $46, $ea, $01, $48, $08, $68, $28, $26
	.byt $66, $40, $60, $e1, $38, $f8, $78, $81
	.byt $86, $84, $aa, $a8, $ba, $8a, $9a, $98

MESSAGES:				; $df4e

	OFFMSGERR = *-MESSAGES
MSGERR:	.byt "**ERROR ;"		; $df4e,$df4e+$00

	OFFMSGOVF = *-MESSAGES
MSGOVF:	.byt "SYM TBL OVERFLOW;"	; $df57,$df4e+$09

	OFFMSGERS = *-MESSAGES
MSGERS:	.byt " ERRORS= ;"		; $df68,$df4e+$1A

	OFFMSGP1 = *-MESSAGES
MSGP1:	.byt "PASS 1;"			; $df72,$df4e+$24

	OFFMSGP2 = *-MESSAGES
MSGP2:	.byt "PASS 2;"			; $df79,$df4e+$2B

	OFFMSGASM = *-MESSAGES
MSGASM:	.byt "ASSEMBLER;"		; $df80,$df4e+$32

	OFFMSGEQ = *-MESSAGES
MSGEQ:	.byt "==;"			; $df8a,$df4e+$3C

	OFFMSGLSQ = *-MESSAGES
MSGLSQ:	.byt "LIST?;"			; $df8d,$df4e+$3F

	OFFMSGOQ = *-MESSAGES
MSGOQ:	.byt "OBJ?;"			; $df93,$df4e+$45

	OFFMSGLSM = *-MESSAGES
MSGLSM:	.byt "LIST-;"			; $df98,$df4e+$4A

	OFFMSGOBM = *-MESSAGES
MSGOBM:	.byt "OBJ-;"			; $df9e,$df4e+$50

ldfa3:
	.byt "AXYSP"

GETFILE:
	lda #CR
	ldy #$ff
ldfac:
	iny
	jsr OUTDP1
	cpy BUFNCHAR
	bcc ldfac
	ldy #$00
	ldx BUFPTR
ldfb8:
	lda INBUF,x
	cpx BUFNCHAR
	bcc ldfc0
ldfbe:
	lda #' '
ldfc0:
	sta NAME,y
	jsr OUTDP1
	iny
	inx
	cpy #$05
	bne ldfb8
GETFILEIFTORU:
	lda INFLG
	cmp #$55
	beq ldfda
ldfd3:
	cmp #$54
	bne ldfe8
ldfd7:
	jmp LOADTA
ldfda:
	jmp ($0108)
PRSTRX:
	jsr OUTALL
	inx
; Print messages from MESSAGES table, message offfset in X, until ';'
PRMSG:
	lda MESSAGES,x
	cmp #';'
	bne PRSTRX
ldfe8:
	rts
PRSPCRLF:
	jsr PRSPACE
PRCRLF:
	pha
	txa
	pha
	jsr CRLF
	pla
	tax
	pla
	rts
	.byt $bf
	.byt $42
	.byt $bf
	.byt $da
PRSPACE:
	lda #' '
	jmp OUTALL

	.byt $4e
