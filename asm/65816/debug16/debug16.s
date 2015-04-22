 .p816
 .smart

; ***********************************************
; *                                             *
; *                 DEBUG16                     *
; *             A 65816 DEBUGGER                *
; *                                             *
; *                                             *
; ***********************************************

 .ORG $6000

MAIN:

 DPAGE = $0000          ; LOCATION OF THIS APPLICATION’S
                        ; DIRECT PAGE

; DIRECT PAGE STORAGE
; TRACE REGISTERS

 PCREG  = $80           ; PROGRAM COUNTER
 PCREGH = PCREG+1
 PCREGB = PCREGH+1      ; INCLUDING BANK

 NCODE = PCREGB+1       ; NEXT CODE TO BE TRACED

 OPCREG = NCODE+1       ; OLD PROGRAM COUNTER VALUE
 OPCREGH = OPCREG+1
 OPCREGB = OPCREGH+1

 CODE = OPCREGB+1       ; CURRENT CODE TO BE TRACED

 OPRNDL = CODE+1        ; OPERANDS OF CURRENT
 OPRNDH = OPRNDL+1      ; INSTRUCTION
 OPRNDB = OPRNDH+1

 XREG = OPRNDB+1        ; X REGISTER
 XREGH = XREG+1

 YREG = XREGH+1         ; Y REGISTER
 YREGH = YREG+1

 AREG = YREGH+1         ; ACCUMULATOR
 AREGH = AREG+1

 STACK = AREGH+1        ; STACK POINTER
 STACKH = STACK+1

 DIRREG = STACKH+1      ; DIRECT PAGE REGISTER
 DIRREGH = DIRREG+1

 DBREG = DIRREGH+1      ; DATA BANK REGISTER

 PREG = DBREG+1         ; P STATUS REGISTER

 EBIT = PREG+1          ; E BIT

 TEMP = EBIT+2          ; TEMPORARY
 TEMPH = TEMP+1
 TEMPB = TEMPH+1

 ADDRMODE = TEMPB+1     ; ADDRESS MODE OF CURRENT OPCODE

 MNX = ADDRMODE+1       ; MNEMONIC INDEX
                        ; FROM ATTRIBUTE TABLE

 OPLEN = MNX+2          ; LENGTH OF OPERATION,
                        ; INCLUDING INSTRUCTION

 CR = $8D               ; CARRIAGE RETURN

 M = $20                ; SYBOLIC NAMES FOR
 IX = $10               ; STATUS REGISTER BITS
 C = $01

; Default entry point.
; Set address to dissemble as this program, the call LIST to disassemble.

 LDA #CR                ; Print a newline so we start on a new line
 JSR COUT
 LDA #<MAIN             ; Start disassembly at this program
 STA PCREG
 LDA #>MAIN
 STA PCREGH
 STZ PCREGB             ; Set bank to zero
 JSR LIST              ; Call LIST to disassemble
; JSR TRACE              ; Call TRACE to trace
 RTS                    ; Return to caller

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; LIST
; MAIN LOOP OF DISASSEMBLER FUNCTION
;
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL

LIST:
 PHP                    ; SAVE ORIGINAL FLAGS
 CLC
 XCE                    ; SET NATIVE MODE
 PHP                    ; SAVE PREVIOUS MODE

 PHD                    ; SAVE CURRENT DP
 PEA DPAGE
 PLD                    ; SET TO NEW DP

TOP:                    ; ANOP

 REP #M
 SEP #IX
 .A16
 .I8

 STZ MNX                ; CLEAR MNEMONIC INDEX
 LDA PCREG              ; MOVE PROGRAM COUNTER
 STA OPCREG             ; TO ‘OLD PROGRAM COUNTER’
 LDX PCREGB             ; INCLUDING BANK
 STX OPCREGB
 LDA [PCREG]            ; GET NEXT INSTRUCTION
 TAX
 STX CODE               ; SAVE AS ‘CODE’

 JSR UPDATE             ; UPDATE ATTRIBUTE VARIABLES

 JSR FLIST              ; FORM OBJECT CODE, MNEMONIC
 JSR FRMOPRND           ; FORM OPERAND FIELD
 JSR PAUSE              ; CHECK FOR USER PAUSE
 BCC @QUIT
 JSR PRINTLN            ; PRINT IT

 BRA TOP                ; LOOP TIL END

@QUIT: PLD              ; RESTORE ENVIRONMENT,
 PLP                    ; RETURN TO CALLER
 XCE
 PLP
 RTS

;
; FLIST – FORM IMAGE OF PROGRAM COUNTER,
; OBJECT CODE, AND MNEMONIC IN ‘LINE’
;
; REQUIRES ATTRIBUTE VARIABLES TO BE PREVIOUSLY INITIALIZED
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

FLIST:

 JSR CLRLN              ; BLANK ‘LINE’ VARIABLE

 SEP #M+IX              ; SHORT REGISTERS
 .A8
 .I8

 LDY #0
 LDA OPCREGB            ; GET BANK BYTE, FORM AS HEX
 JSR PUTHEX             ; STRING
 LDA #':'               ; BANK DELIMITER
 STA LINE,Y
 INY
 LDA OPCREGH            ; GET BYTES OF PROGRAM COUNTER
 JSR PUTHEX             ; FORM AS HEX STRING IN
 LDA OPCREG             ; LINE
 JSR PUTHEX

 LDY #10
 LDA CODE               ; STORE OPCODE AS HEX STRING
 JSR PUTHEX
 LDX #1

MORE: CPX OPLEN         ; LIST OPERANDS, IF ANY
 BEQ DONE
 LDA OPRNDL-1,X
 JSR PUTHEX
 INX
 BRA MORE

DONE: REP #M+IX
 .A16
 .I16

 LDA MNX                ; GET MNEMONIC INDEX,
 ASL A                  ; MULTIPLY BY THREE
 CLC                    ; (TIMES TWO PLUS SELF)
 ADC MNX
 CLC
 ADC #MN
 TAX                    ; INDEX INTO MNEMONIC TABLE
 LDY #LINE+20           ; COPY INTO ‘LINE’
 LDA #2
MOVE:
 MVN 0,0

 RTS

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; FRMOPRND – –
; FORMS OPERAND FIELD OF DISASSEMBLED INSTRUCTION
;
; OPLEN, ADDRMODE, AND OPRND MUST HAVE BEEN
; INITIALIZED BY ‘UPDATE’
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

FRMOPRND:
 SEP #M+IX
 .A8
 .I8

 LDY #28                ; OFF SET INTO ‘LINE’ FOR OPERAND
                        ; TO BEGIN
 LDA ADDRMODE           ; GET ADDRESS MODE, MULTIPLY BY
 ASL A                  ; TWO, JUMP THROUGH ADDRESS
 TAX                    ; MODE JUMP TABLE TO PROPER
 JMP (MODES,X)          ; HANDLER

FIMM:                   ; IMMEDIATE MODE – –
 LDA #'#'               ; OUTPUT POUND SIGN,
 STA LINE,Y             ; ONE OR TWO
 INY                    ; OPERAND BYTES, DEPENDING
 LDA OPLEN              ; ON OPLEN
 CMP #2
 BEQ GOSHORT
 JMP PODB
GOSHORT: JMP POB

FABS:                   ; ABSOLUTE MODE – –
 JMP PODB               ; JUST OUTPUT A DOUBLE BYTE

FABSL:                  ; ABSOLUTE LONG – –
 JMP POTB               ; OUTPUT A TRIPLE BYTE

FDIR:                   ; DIRECT MODE – –
 JMP POB                ; OUTPUT A SINGLE BYTE

FACC:                   ; ACCUMULATOR – –
 LDA #'A'               ; JUST AN A
 STA LINE,Y
 RTS

FIMP:                   ; IMPLIED – –
 RTS                    ; NO OPERAND

FINDINX:                ; INDIRECT INDEXED – –
 JSR FIND               ; CALL ‘INDIRECT’, THEN FALL
                        ; THROUGH TO INDEXED BY Y

FINY:                   ; INDEXED BY Y MODES – –
 LDA #','               ; TACK ON A ‘COMMA,Y'
 STA LINE,Y
 INY
 LDA #'Y'
 STA LINE,Y
 RTS

FINDINXL:               ; INDIRECT INDEXED LONG – –
 JSR FINDL              ; CALL ‘INDIRECT LONG', THEN
 JMP FINY               ; EXIT THROUGH INDEXED BY Y

FINXIND:                ; INDEX INDIRECT – –
 LDA #'('               ; PARENTHESIS
 STA LINE,Y
 INY
 JSR POB                ; A SINGLE BYTE – –
 JSR FINX               ; COMMA, X
 LDA #')'               ; CLOSE.
 STA LINE,Y
 RTS

FDIRINXX:               ; DIRECT INDEXED BY X – –
 JSR POB                ; OUTPUT A BYTE,
 JMP FINX               ; TACK ON COMMA, X

FDIRINXY:               ; DIRECT INDEXED BY Y – –
 JSR POB                ; OUTPUT A BYTE,
 JMP FINY               ; TACK ON COMMA, Y

FINX:                   ; INDEXED BY X – –
 LDA #','               ; TACK ON A
 STA LINE,Y             ; COMMA, X
 INY                    ; (USED BY SEVERAL
 LDA #'X'               ; MODES)
 STA LINE,Y
 INY
 RTS

FABSX:                  ; ABSOLUTE INDEXED BY X – –
 JSR PODB               ; OUTPUT A DOUBLE BYTE,
 JMP FINX               ; TACK ON A COMMA, X

FABSLX:                 ; ABSOLUTE LONG BY X – –
 JSR POTB               ; OUTPUT A TRIPLE BYTE,
 JMP FINX               ; TACK ON COMMA, X

FABSY:                  ; ABSOLUTE Y – –
 JSR PODB               ; OUTPUT A DOUBLE BYTE,
 JMP FINY               ; TACK ON COMMA,Y

FPCRL:
FPCR:                   ; PROGRAM COUNTER RELATIVE – –
 LDA #$FF               ; SIGN EXTEND OPERAND
 XBA
 LDA OPRNDL
 REP #M+C
.A16
 BMI OK
 AND #$7F
OK: ADC OPCREG          ; ADD TO PROGRAM COUNTER
 INC A                  ; ADD TWO, WITHOUT CARRY
 INC A
 STA OPRNDL             ; STORE AS NEW ‘OPERAND'

 SEP #M
 .A8

 JMP PODB ; NOW JUST DISPLAY A DOUBLE BYTE

FCPRL:                  ; PROGRAM COUNTER RELATIVE LONG

 REP #M+C
 .A16

 LDA OPRNDL             ; JUST ADD THE OPERAND
 ADC OPCREG
 CLC                    ; BUMP BY THREE, PAST INSTRCTION
 ADC #3
 STA OPRNDL             ; STORE AS NEW ‘OPERAND'

 SEP #M
 .A8

 JMP PODB               ; PRINT A DOUBLE BYTE

FABSIND:                ; ABSOLUTE INDIRECT
 LDA #'('               ; SURROUND A DOUBLE BYTE
 STA LINE,Y             ; WITH PARENTHESES
 INY
 JSR PODB
 LDA #')'
 STA LINE,Y
 RTS

FIND:                   ; INDIRECT – –
 LDA #'('               ; SURROUND A SINGLE BYTE
 STA LINE,Y             ; WITH PARENTESES
 INY
 JSR POB
 LDA #')'
 STA LINE,Y
 INY
 RTS

FINDL:                  ; INDIRECT LONG – –
 LDA #'['               ; SURROUND A SINGLE BYTE'
 STA LINE,Y             ; WITH SQUARE BRACKTS
 INY
 JSR POB
 LDA #']'
 STA LINE,Y
 INY
 RTS

FABSINXIND:             ; ABSOLUTE INDIRECT INDEXED
 LDA #'('
 STA LINE,Y             ; SURROUND A CALL TO ‘ABSOLUTE
 INY                    ; INDEXED' WITH PARENTHESES
 JSR FABSX
 LDA #')'
 STA LINE,Y
 RTS

FSTACK:                 ; STACK – – IMPLIED
 RTS

FSTACKREL:              ; STACK RELATIVE
 JSR FDIR               ; JUST LIKE
 LDA ','                ; DIRECT INDEXED, BUT WITH
 STA LINE,Y             ; AN ‘S'
 INY
 LDA #'S'
 STA LINE,Y
 INY
 RTS

FSRINDINX:              ; STACK RELATIVE INDIRECT INDEX
 LDA #'('
 STA LINE,Y             ; SURROUND STACK RELATIVE WITH
 INY                    ; PARENTHESES, THEN
 JSR FSTACKREL
 LDA #')'
 STA LINE,Y
 INY
 JMP FINY               ; TACK ON A COMMA,Y

FBLOCK:                 ; BLOCK MOVE

 REP #M
 LDA OPRNDL             ; MAKE HUMAN-READABLE:
 XBA                    ; SWAP SOURCE, DEST
 STA OPRNDL
 SEP #M

 JSR POB                ; OUTPUT THE SOURCE
 LDA #','               ; THEN COMMA
 STA LINE,Y
 INY
 XBA                    ; SWAP DEST INTO OPRNDL
 STA OPRNDL             ; THEN PRINT ONE BYTE
 JMP POB

;LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; POB, PODB, POTB
; PUT OPERAND (DOUBLE, TRIPLE) BYTE
;
; PUTS OPRNDL (OPRNDH, OPRNDB) IN LINE AS HEX VALUE
; WITH ‘$' PREFIX
;
; ASSUMES SHORT ACCUMULATOR AND INSEX REGISTERS
; (CALLED BY FOPRND)
;LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

POB:
 .A8
 .I8

; PRINT:
 LDX #0                 ; ONE OPERAND BYTE
 BRA IN                 ; SKIP
PODB:
 LDX #1                 ; TWO OPERAND BYTES
 BRA IN                 ; SKIP
POTB:
 LDX #2                 ; THREE OPERAND BYTES
                        ; FALL THROUGH
IN: LDA #'$'            ; PRINT LEAD-IN
 STA LINE,Y
 INY

@MORE: LDA OPRNDL,X     ; LOOP THROUGH OPERAND
 JSR PUTHEX             ; HIGH TO LOW
 DEX
 BPL @MORE
 RTS

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; STEP CHECKS FOR USER PAUSE SIGNAL
; (KEYSTROKE)
;
; CONTAINS MACHINE-DEPENDENT CODE
; FOR APPLE II
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

STEP:
; KEYBD = $C000         ; Apple II keyboard
; KEYSTB = $C010        ; Apple II keyboard

 KEYBD = $D011          ; Apple 1/Replica 1 keyboard
 KEYSTB = $D010         ; Apple 1/Replica 1 keyboard

 ESC = $9B              ; ESCAPE KEY (HIGH BIT SET)
 V = $40                ; MASK FOR OVERFLOW FLAG
 .A8
 .I8

 PHP                    ; SAVE MODES
 SEP #M+IX
 BRA WAIT

PAUSE:                  ; FOR ‘PAUSE' CALL
 PHP
 SEP #M+IX
 LDA KEYBD              ; CHECK FOR KEYPRESS
 BPL RETNCR             ; NONE; DON'T PAUSE
 LDA KEYSTB             ; CLEAR STROBE
                        ; IF KEYSTROKE
WAIT: LDA KEYBD         ; LOOP FOR NEXT KEY
 BPL WAIT
 LDA KEYSTB             ; CLEAR STROBE
 CMP #ESC               ; IF ESC RETURN WITH
 BNE RETNESC

RETEQ: PLP              ; CARRY CLEAR (QUIT)
 NOP
 CLC
 RTS

RETNESC: CMP #CR
 BNE RETNCR
 PLP
 SEP #C+V
 RTS

RETNCR: LDA KEYSTB
 PLP                    ; ELSE SET
 SEC
 CLV
 RTS                    ; (CONTINUE)

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
; PUTHEX
;
; CONVERTS NUMBER IN ACCUMULATOR TO HEX STRING
; STORED AT LINE,Y
;
; SAVE AND RESTORED MODE FLAGS
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL

PUTHEX:
 PHP                    ; SAVE MODE FLAGS
 JSR MAKEHEX            ; GET ASCII CODES A, B
 REP #M
 .A16
 STA LINE,Y             ; PUT TWO BYTES AT LINE
 INY                    ; INCREMENT Y PAST THEM
 INY
 PLP                    ; RESTORE MODE
 RTS                    ; RETURN

MAKEHEX: SEP #M+IX      ; ALL EIGHT BIT
 .A8
 .I8

 PHA                    ; SAVE VALUE TO BE CONVERTED
 AND #$0F               ; MASK OFF LOW NIBBLE
 JSR FORMNIB            ; CONVERT TO HEX
 XBA                    ; STORE IN B
 PLA                    ; RESTORE VALUE
 LSR A                  ; SHIFT HIGH NIBBLE
 LSR A                  ; TO LOW NIBBLE
 LSR A
 LSR A
                        ; FALL THROUGH TO CONVERT

FORMNIB: CMP #$A        ; IF GREATER THAN OR EQUAL TO
 BCS HEXDIG             ; 10, USE DIGITS A..F
 CLC                    ; ELSE SIMPLY ADD ‘0' TO
 ADC #'0'               ; CONVERT TO ASCII
 RTS

HEXDIG: ADC #'A'-11     ; SUBTRACT 11, ADD ‘A'
 RTS                    ; (SORT OF)

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; CLRLN
;
; CLEARS ‘LINE' WITH BLANKS
;
; SAVES AND RESTORES MODE FLAGS
;
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

CLRLN:
 PHP
 REP #M+IX
 .A16
 .I16

 LDA #$2020             ; two spaces
 LDX #68

LOOP: STA LINE,X
 DEX
 DEX
 BPL LOOP
 PLP
 RTS

LINE:
 .byte "                                                                      "
 .byte $8D, $00

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; UPDATE
;
; UPDATES ATTRIBUTE VARIABLES BASED ON OPCODE
; PASSED IN ACCUMULATOR BY LOOKING IN ATTRIBUTE
; TABLES
;
; SAVES AND RESTORES MODE FLAGS
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL

UPDATE:

 LDYI = $A0+2           ; OPCODE VALUE TIMES TWO
 LDXI = $A2+2

 PHP                    ; SAVE STATE
 REP #M+IX
 .A16
 .I16

 AND #$FF               ; MASK HIGH BYTE
 ASL A                  ; TIMES TWO

 TAY
 LDA ATRIBL,Y           ; INDEX INTO ATTRIBUTE TABLE
 XBA                    ; SWAP ORDER OF ENTRIES
 STA ADDRMODE           ; SAVE ADDRMODE, MNEMONIC INDEX

 TAX                    ; ADDRMODE TO X (LOW)
 TYA                    ; OPCODE * 2 TO ACCUM
 SEP #IX
 .I8

 LDY LENS-1,X           ; GET LENGTH OF OPERATION
 STY OPLEN

 LDX EBIT               ; EMULATION MODE?
 CPX #1                 ; TEST BIT ZERO
 BEQ SHORT              ; YES ALL IMMEDIATE ARE
                        ; SHORT
 BIT #$20               ; IS MSD+2 EVEN?
 BNE SHORT              ; NO, CAN'T BE IMMEDIATE
 CMP #LDXI              ; IS IT LDX #?
 BEQ CHKA
 BIT #$F+2              ; IS LSD+2 ZERO?
 BNE CHKA               ; CHECK ACCUMULATOR OPCODES
 CMP #PREG              ; MUST = LDY# OR GREATER
 BCC CHKA               ; NO, MAYBE ACCUMULATOR
 LDA PREG               ; IF IT IS, WHAT IS FLAG SETTING?
 AND #IX
 BEQ LONG               ; CLEAR – 16 BIT MODE
 BNE SHORT              ; SET – 8 BIT MODE

CHKA: AND #$0F+2        ; MASK OUT MSD
 CMP #$9+2              ; IS LSD = 9?
 BNE SHORT
 LDA PREG               ; WHAT IS FLAG SETTING?
 AND #M
 BNE SHORT              ; NO, 8 BIT MODE

 LONG: INC OPLEN        ; LONG IMMEDIATE LENGTH IS
                        ; ONE MORE THEN FOUND IN TABLE

SHORT: LDY #0
 BRA LOOPIN

LOOP1: LDA [PCREG]      ; LOAD 16 BITS 16 BIT MODE
                        ; USED TO BUMP PCREG EASILY
 TAX                    ; TRUNCATE TO EIGHT BITS
 STX OPRNDL-1,Y         ; SAVE

LOOPIN: INC PCREG       ; MOVE PC PAST NEXT INSTRUCTION
 INY                    ; BYTE
 CPY OPLEN              ; MOVED ALL OPERAND BYTES?
 BNE LOOP1              ; NO, CONTINUE

;DONE:
 PLP
 RTS

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; PRINTLN
;
; MACHINE-DEPENDENT CODE TO OUTPUT
; THE STRING STORED AT ‘LINE'
;
; SAVES AND RESTORED MODE FLAGS
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

PRINTLN:
; COUT = $FDED          ; APPLE II CHARACTER OUTPUT ROUTINE
COUT = $FFEF            ; APPLE 1/Replica 1 ROM CHARACTER OUTPUT ROUTINE

 PHP                    ; SAVE STATUS
 PHD                    ; SAVE DIRECT PAGE
 PEA 0                  ; SWITCH TO PAGE ZERO
 PLD                    ; FOR EMULATION

 .A8
 .I8
 SEC                    ; SWITCH TO EMULATION
 XCE

 LDY #0

@LOOP: LDA LINE,Y       ; LOOP UNTIL STRING TERMINATOR
 BEQ @DONE              ; REACHED
 JSR COUT
 INY
 BRA @LOOP

@DONE: CLC              ; RESTORE NATIVE MODE
 XCE
 PLD                    ; RESTORE DIRECT PAGE
 PLP                    ; RESTORE MODE FLAGS
 RTS

;
; TRACE
;
; ENTRY POINT FOR TRACER
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL

TRACE:
; USRBRKV = $3F0         ; USER BRK VECTOR FOR APPLE II
 USRBRKV = $0100         ; USER BRK VECTOR FOR APPLE 1/REPLICA 1

 BRKN = $FFE6           ; NATIVE MODE BRK VECTOR

 PHP                    ; SAVE CALLING STATE
 CLC
 XCE
 PHP

 REP #$10
 .I16
 PEA 0                  ; OLD STACK BOUNDARY

 TSX
 STX SAVSTACK

 PEA DPAGE              ; INITIALIZE DIRECT PAGE
 PLD

 STX STACK

 SEP #$20
 .A8

 LDA #1
 STA EBIT
 STZ DIRREG             ; DIRECT PAGE, DATA BANK
 STZ DIRREGH            ; TO POWER-UP DEFAULTS
 STZ DBREG
 STZ MNX+1

 STZ STEPCNTRL

 LDA #$4C               ; JMP instruction
 STA USRBRKV            ; Put JMP to vector there
 LDX #EBRKIN            ; PATCH BRK VECTORS
 STX USRBRKV+1          ; TO POINT TO TRACE CODE

 LDX BRKN+1             ; FIND OUT WHERE BRKN POINTS TO
 CPX #$C000             ; MAKE SURE IT'S RAM ON AN APPLE
 BCC @OK
 JMP QUIT               ; MIGHT AS WELL GIVE UP NOW...
@OK: STX USRBRKN

 LDA [PCREG]            ; GET FIRST OPCODE
 JMP TBEGIN             ; BEGIN !

SAVSTACK:
 .res 2
USRBRKN:
 .res 2
SAVRAM:
 .res 2

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; EBRKIN, NBRKIN, TBGIN
;
; ENTRY POINTS FOR TRACER MAIN LOOP
; EBKIN AND NBKIN RECOVER CONTROL AFTER
; ‘BRK' INSTRUCTION EXECUTED
; TBEGIN IS INITIAL ENTRY FROM ‘TRACE'
;
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

EBRKIN:                 ; ENTRY FROM EMULATION MODE
                        ; FOR TRACER

 .A8
 .I8

 PEA 0
 PHA
                        ; FIXME (APPLE SPECIFIC)
; LDA $48                ; APPLE II MONITOR
; PHA                    ; LOCATIONS
; LDA $45                ; FOR P, AA
; LDX $46                ; AND X

; For Apple 1/Replica 1, use values already in registers
PHP

; Note that if direct page is relocated
; in emulation mode, these locations
; will be used by monitor brk handler

 INC EBIT+DPAGE         ; MARK AS EMULATION MODE

 CLC                    ; GO NATIVE
 XCE

NBRKIN:                 ; ENTRY FROM NATIVE MODE
                        ; FOR TRACER

 REP #M+IX
 .A16
 .I16

 PHB                    ; SAVE DATA BANK
 PHD                    ; DIRECT PAGE
 PEA DPAGE              ; SWITCH TO APPLICATION
 PLD                    ; DIRECT PAGE

 STA AREG               ; STASH USER REGISTERS
 STX XREG
 STY YREG

 LDA 1,S                ; GET DIRECT PAGE VALUE
 STA DIRREG             ; SAVED

 TSC                    ; CALCULATE TRUE STACK
 CLC                    ; (BEFORE BRK)
 ADC #7
 STA STACK              ; SAVE AS STACK

 LDA 3,S                ; SAVE DATA BANK, STATUS
 STA DBREG              ; STATUS REGISTER

 LDA #$140              ; SET UP SMALL STACK
 TCS

 PHK                    ; MAKE DATA BANK = PROGRAM BANK
 PLB
 LDX a:USRBRKN          ; RESTORE BORROWED RAM
 LDA a:SAVRAM+1
 STA a:1,X
 LDA a:SAVRAM
 STA a:0,X
 JSR FLIST              ; FORMAT DISASSEMBLY LINE
 JSR FRMOPRND

 JSR PRINTLN            ; PRINT IT

 JSR CLRLN
 JSR DUMPREGS           ; OUTPUT REGISTER VALUES
 JSR PRINTLN

 SEP #M
 .A16

 REP #IX
 .I16

 BIT STEPCNTRL
 BMI DOPAUSE

 JSR STEP               ; STEP ONE AT A TIME
 BCC QUIT               ; USER WANTS TO QUIT
 BVC RESUME             ; WANTS TO KEEP STEPPING
 .A8
 LDA #$80               ; HIT CR; WANTS TO TRACE, NOT
 STA STEPCNTRL          ; STEP SET FLAG
 BRA RESUME

DOPAUSE: JSR PAUSE      ; TRACING; ONLY WAIT IF USER
 BCC QUIT               ; HITS KEY
 BVC RESUME             ; WANTS TO KEEP TRACING
 STZ STEPCNTRL          ; HIT CR; WANTS TO STEP, NOT
                        ; TRACE CLEAR FLAG

RESUME: LDA NCODE       ; RESTORE ONLD ‘NEXT'; IT'S ABOUT
 STA [PCREG]            ; TO BE EXECUTED

TBEGIN:
 TAY                    ; SAVE THE CURRENT (ABOUT TO BE
                        ; EXECUTED) OPCODE

 LDX PCREG              ; REMEMBER WHERE YOU GOT IT FROM
 STX OPCREG             ; PCREG POINTED TO IT AFTER
 LDA PCREGB             ; PREVIOUS CALL TO UPDATE
 STA OPCREGB

 TYA

 STA CODE               ; SAVE CURRENT OPCODE
 JSR UPDATE             ; UPDATE PC TO POINT PAST THIS
                        ; INSTRUCTION
                        ; UPDATE ATTRIBUTE VARIABLES

 JSR CHKSPCL            ; CHECK TO SEE IF THIS CAUSES A
                        ; TRANSFER
 LDA [PCREG]            ; GET NEXT OPCODE TO BE EXECUTED
                        ; (ON NEXT LOOP THROUGH)
 STA NCODE              ; SAVE IT
 LDA #0                 ; PUT A BREAK ($00) THERE TO
                        ; REGAIN CONTROL
 STA [PCREG]

GO:
 REP #M+IX
 .A16
 .I16
 LDX a:USRBRKN            ; BORROW THIS RAM FOR A SECOND
 LDA a:0,X
 STA a:SAVRAM
 LDA a:1,X
 STA a:SAVRAM+1
 LDA #$4C
 STA a:0,X
 LDA #NBRKIN
 STA a:1,X
 LDA STACK              ; RESTORE STACK
 TCS
 PEI (DBREG)            ; GET THIS STUFF ON STACK
 PEI (EBIT-1)
 PEI (DIRREG)

 STZ EBIT               ; ASSUME NATIVE MODE ON RETURN

 LDA AREG               ; RESTORE USER REGISTERS
 LDY YREG
 LDX XREG

 PLD                    ; POP IT AWAY!

 PLP
 PLP
 XCE

 PLB
 PLP

 JML (DPAGE+OPCREG)    ; ON TO THE NEXT!

QUIT:
 SEP #$20
 .A8

 LDA NCODE              ; CLEAN UP OLD PATCH
 STA [PCREG]

 REP #$10
 .I16

 LDX a:SAVSTACK           ; GET ORIGINAL STACK POINTER
 INX
 INX
 TXS

 PEA 0                  ; RESTORE ZERO PAGE
 PLD

 PLP
 XCE
 PLP
 RTS

STEPCNTRL:
 .res 1

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
; CHKSPCL
;
; CHECK CURRENT OPCODE (IN CODE) FOR SPECIAL CASES
; INSTRUCTIONS WHICH TRANSFER CONTROL (JMP, BRA, ETC.)
;
; ASSUMES SHORTA, LONGI CALLED BY EBRKIN
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

CHKSPCL:
 .A8
 .I16

 LDX #SCX-SCODES
 LDA CODE

@LOOP: CMP SCODES,X     ; CHECK TO SEE IF CURRENT OPCODE
 BEQ HIT                ; IS IN EXCEPTION TABLE
 DEX
 BPL @LOOP
 RTS                    ; EXIT IF NOT

HIT: SEP #IX
 .I8

 TXA                    ; IF INDEX WAS LESS THAN 9, IT'S
 CMP #9                 ; A BRANCH
 BCS NOTBR

 LSR A                  ; SEE IF ‘ODD OR EVEN'
 TAX
 LDA PMASK,X            ; GET MASK TO SELECT CORRECT
                        ; PREG BIT
 AND PREG               ; IS IT SET?

 BCS BBS                ; IF INDEX WAS ODD, BRANCH IF
                        ; PREG BIT IS SET
 BEQ DOBRANCH           ; ELSE IF EVEN, BRANCH IF CLEAR
 RTS

BBS: BNE DOBRANCH       ; "BRANCH IF BIT SET"
 RTS

NOTBR: ASL A            ; NOT A BRANCH INSTRUCTION;
                        ; MULTIPLY BY TWO
 TAX                    ; AND INDEX INTO HANDLER JUMP
; TABLE
 REP #IX
 JMP (SPJMP-18,X)       ; BIAS JUMP TABLE BY 9

DOBRANCH:
 LDA #$FF               ; SET ACCUMULATOR BYTE HIGH
                        ; (ANTICIPATE NEGATIVE)
 XBA                    ; AND SIGN EXTEND INTO X

 LDA OPRNDL

 REP #M+IX+C            ; MAKE REGS LONG; CLEAR CARRY
 .A16                   ; (ANTICIPATE ADC)
 .I16

 BMI @OK                ; NUMBER WAS NEGATIVE; ALL IS OK

 AND #$7F               ; CLEAR HIGH BYTE OF ACCUM
                        ; (POSITIVE NUMBER)
@OK: ADC PCREG
 STA PCREG
 SEP #M                 ; RETURN WITH ACCUM SHORT
 RTS

SBRK:                   ; THESE ARE NOT IMPLEMENTED!
SRTI:                   ; (AN EXERCISE FOR READER)
SCOP:
 RTS

SJSRABS:                ; ABSOLUTES
SJMPABS:
 LDX OPRNDL             ; MOVE OPERAND TO PC
 STX PCREG
 RTS

SBRL:                   ; LONG BRANCH
 REP #M+C               ; LONG ACCUM AND CLEAR CARRY
 .A16
 LDA OPRNDL             ; ADD DISPLACMENT TO
 ADC PCREG              ; PROGRAM COUNTER
 STA PCREG
 SEP #M
 .A8
 RTS

SJSRABSL:               ; ABSOLUTE LONGS
SJMPABSL:
 LDX OPRNDL             ; MOVE OPERAND, INCLUDING BANK,
 STX PCREG              ; TO PROGRAM COUNTER
 LDA OPRNDB
 STA PCREGB
 RTS

SRTS:                   ; RETURN
 LDX STACK              ; PEEK ON STACK
 CPX a:SAVSTACK           ; IF ORIGINAL STACK...
 BNE CONT
 JMP QUIT               ; RETURN TO MONITOR
CONT: INX

 REP #M
 LDA f:0,X              ; ALWAYS IN BANK ZERO
 INC A                  ; ADD ONE TO GET TRUE RETURN
 STA PCREG              ; VALUE
 SEP #M

 RTS

SRTL:                   ; RETURN LONG
 JSR SRTS               ; DO NORMAL RETURN,

 INX                    ; THEN GET BANK BYTE
 INX
 LDA f:0,X              ; A IS NOW SHORT FOR BANK BYTE
 STA PCREGB
 RTS

SJMPIND:                ; INDIRECT
 LDX OPRNDL             ; GET OPERAND

 REP #M
 LDA f:0,X              ; JMP IND ALWAYS IN BANK ZERO
 STA PCREG
 SEP #M
 RTS

SJMPINDL:
 JSR SJMPIND            ; SAME AS JMP INDIRECT,
 INX                    ; PLUS BANK BYTE
 INX
 LDA f:0,X              ; ACCUM IS SHORT NOW
 STA PCREGB
 RTS

SJMPINDX:               ; INDEX JUMPS
SJSRINDX:
 LDY XREG               ; LET CPU DO ADDITION
 LDX OPRNDL             ; GET INSIRECT POINTER
 STX TEMP
 LDA PCREGB             ; INDEXED JUMPS ARE IN PROGRAM
 STA TEMP+2             ; BANK

 REP #M
 LDA [TEMP],Y           ; ‘Y IS X'
 STA PCREG
 SEP #M

 RTS

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; DUMPREGS
;
; DISPLAYS CONTENTS OF REGISTER VARIABLES IN ‘LINE'
;
; SAVES AND RESTORES MODE
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

DUMPREGS:
 PHP
 SEP #M+IX
 .A8
 .I8

 LDY #0

 LDA #>DPAGE            ; STORE DPAGE HIGH IN TEMP HIGH
 STA TEMPH

 LDX #ENDTABLE-TABLE    ; LENGTH OF COMMAND TABLE

@LOOP: LDA TABLE,X      ; GET ADDRESS OF NEXT REGISTER
 STA TEMP
 DEX
 LDA TABLE,X            ; GET REGISTER ‘NAME'
 JSR PUTREG16
 DEX
 BPL @LOOP

 LDA #DBREG             ; NOW ALL THE 8-BIT REGISTERS
 STA TEMP
 LDA #'B'
 JSR PUTREG8
 LDA #PREG
 STA TEMP
 LDA #'P'
 JSR PUTREG8
 LDA #'E'
 STA LINE,Y
 INY
 LDA #':'
 STA LINE,Y
 INY

 LDA #'0'
 LDX EBIT
 BEQ @OK
 INC A                  ; ‘0' BECOMES ‘1'
@OK: STA LINE,Y

 PLP
 RTS

TABLE: 
 .byte "D", DIRREGH     ; DIRECT PAGE
 .byte "S", STACKH      ; ' ADDRESS OF
 .byte "Y", YREGH       ; REGISTER
 .byte "X", XREGH       ; VARIABLES
 .byte "A"
ENDTABLE:
.byte AREGH

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; PUTREGS
;
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

PUTREG8:
 STA LINE,Y             ; A CONTAINS REGISTER ‘NAME'
 INY
 LDA #'='               ; EQUALS..
 STA LINE,Y
 INY
 BRA PRIN               ; USE PUTREG16 CODE

PUTREG16:
 STA LINE,Y             ; A CONTAINS REGISTER ‘NAME'
 INY
 LDA #'='               ; EQUALS..
 STA LINE,Y
 INY
 INY
 LDA (TEMP)             ; TEMP POINTS TO REGISTER
 DEC TEMP               ; VARIABLE HIGH
 JSR PUTHEX

PRIN: INY
 LDA (TEMP)             ; TEMP POINTS TO REGISTER
 JSR PUTHEX             ; VARIABLE LOW (OR 8 BIT)
 INY
 RTS

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; SP JMP
; JUMP TABLE FOR ‘SPECIAL' OPCODE HANDLERS
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

SPJMP:                  ; JUMP TABLE FOR
 .word SBRK             ; NON-BRANCH HANDLERS
 .word SJSRABS
 .word SRTI
 .word SRTS
 .word SCOP
 .word SJSRABSL
 .word SBRL
 .word SRTL
 .word SJMPABS
 .word SJMPABSL
 .word SJMPIND
 .word SJMPINDX
 .word SJMPINDL
 .word SJSRINDX

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;
; PMASK
; STATUS REGISTER MASKS FOR BRANCH HANDLING CODE
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;

PMASK:                  ; MASKS FOR STATUS REGISTER
 .byte $80     ; N FLAG
 .byte $40     ; V FLAG
 .byte $01     ; C FLAG
 .byte $02     ; Z FLAG
 .byte $00     ; BRA

SCODES: ; SPECIAL OPCODES

 .byte $10     ; BPL
 .byte $30     ; BMI
 .byte $50     ; BVC
 .byte $70     ; BVS
 .byte $90     ; BCC
 .byte $B0     ; BCS
 .byte $D0     ; BNE
 .byte $F0     ; BEQ
 .byte $80     ; BRA
 .byte $00     ; BRK
 .byte $20     ; JSR
 .byte $40     ; RTI
 .byte $60     ; RTS
 .byte $02     ; COP
 .byte $22     ; JSR ABSL
 .byte $82     ; BRL
 .byte $6B     ; RTL
 .byte $4C     ; JMP ABS
 .byte $5C     ; JMP ABSL
 .byte $6C     ; JMP ()
 .byte $7C     ; JMP (,X)
 .byte $DC     ; JMP [ ]
SCX:
 .byte $FC     ; JSR (,X)

MN:
 .byte $00,$00,$00
 .byte "ADC" ; 1
 .byte "AND" ; 2
 .byte "ASL" ; 3
 .byte "BCC" ; 4
 .byte "BCS" ; 5
 .byte "BEQ" ; 6
 .byte "BIT" ; 7
 .byte "BMI" ; 8
 .byte "BNE" ; 9
 .byte "BPL" ; 10
 .byte "BRK" ; 11
 .byte "BVC" ; 12
 .byte "BVS" ; 13
 .byte "CLC" ; 14
 .byte "CLD" ; 15
 .byte "CLI" ; 16
 .byte "CLV" ; 17
 .byte "CMP" ; 18
 .byte "CPX" ; 19
 .byte "CPY" ; 20
 .byte "DEC" ; 21
 .byte "DEX" ; 22
 .byte "DEY" ; 23
 .byte "EOR" ; 24
 .byte "INC" ; 25
 .byte "INX" ; 26
 .byte "INY" ; 27
 .byte "JMP" ; 28
 .byte "JSR" ; 29
 .byte "LDA" ; 30
 .byte "LDX" ; 31
 .byte "LDY" ; 32
 .byte "LSR" ; 33
 .byte "NOP" ; 34
 .byte "ORA" ; 35
 .byte "PHA" ; 36
 .byte "PHP" ; 37
 .byte "PLA" ; 38
 .byte "PLP" ; 39
 .byte "ROL" ; 40
 .byte "ROR" ; 41
 .byte "RIT" ; 42
 .byte "RTS" ; 43
 .byte "SBC" ; 44
 .byte "SEC" ; 45
 .byte "SED" ; 46
 .byte "SEI" ; 47
 .byte "STA" ; 48
 .byte "STX" ; 49
 .byte "STY" ; 50
 .byte "TAX" ; 51
 .byte "TAY" ; 52
 .byte "TSX" ; 53
 .byte "TXA" ; 54
 .byte "TXS" ; 55
 .byte "TYA" ; 56
 .byte "BRA" ; 57
 .byte "PLX" ; 58
 .byte "PLY" ; 59
 .byte "PHX" ; 60
 .byte "PHY" ; 61
 .byte "STZ" ; 62
 .byte "TRB" ; 63
 .byte "TSB" ; 64

 .byte "PEA" ; 65
 .byte "PEI" ; 66
 .byte "PER" ; 67
 .byte "PLB" ; 68
 .byte "PLD" ; 69
 .byte "PHB" ; 70
 .byte "PHD" ; 71
 .byte "PHK" ; 72

 .byte "REP" ; 73
 .byte "SEP" ; 74

 .byte "TCD" ; 75
 .byte "TDC" ; 76
 .byte "TCS" ; 77
 .byte "TSC" ; 78
 .byte "TXY" ; 79
 .byte "TYX" ; 80
 .byte "XBA" ; 81
 .byte "XCE" ; 82

 .byte "BRL" ; 83
 .byte "JSL" ; 84
 .byte "RTL" ; 85
 .byte "MVN" ; 86
 .byte "MVP" ; 87
 .byte "COP" ; 88
 .byte "WAI" ; 89
 .byte "STP" ; 100
 .byte "WDM" ; 101

MODES:
 .res 2
 .word FIMM ; 1
 .word FABS ; 2
 .word FABSL ; 3
 .word FDIR ; 4
 .word FACC ; 5
 .word FIMP ; 6
 .word FINDINX ; 7
 .word FINDINXL ; 8
 .word FINXIND ; 9
 .word FDIRINXX ; 10
 .word FDIRINXY ; 11
 .word FABSX ; 12
 .word FABSLX ; 13
 .word FABSY ; 14
 .word FPCR ; 15
 .word FPCRL ; 16
 .word FABSIND ; 17
 .word FIND ; 18
 .word FINDL ; 19
 .word FABSINXIND ; 20
 .word FSTACK ; 21
 .word FSTACKREL ; 22
 .word FSRINDINX ; 23
 .word FBLOCK ; 24

LENS:
 .byte $02 ; IMM
 .byte $03 ; ABS
 .byte $04 ; ABS LONG
 .byte $02 ; DIRECT
 .byte $01 ; ACC
 .byte $01 ; IMPLIED
 .byte $02 ; DIR IND INX
 .byte $02 ; DIR IND INX L
 .byte $02 ; DIR INX IND
 .byte $02 ; DIR INX X
 .byte $02 ; DIR INX Y
 .byte $03 ; ABS X
 .byte $04 ; ABS L X
 .byte $03 ; ABS Y
 .byte $02 ; PCR
 .byte $03 ; PCR L
 .byte $03 ; ABS IND
 .byte $02 ; DIR IND
 .byte $02 ; DIR IND L
 .byte $03 ; ABS INX IND
 .byte $01 ; STACK
 .byte $02 ; SR
 .byte $02 ; SR INX
 .byte $03 ; MOV

ATRIBL:
 .byte 11,6  ; BRK 00
 .byte 35,9  ; ORA D,X 01
 .byte 88,4  ; COP (REALLY 2) 02
 .byte 35,22 ; ORA-,X 03
 .byte 64,4  ; TSB D 04
 .byte 34,4  ; ORA D 05
 .byte 3,4   ; ASL D 06
 .byte 35,19 ; ORA [D] 07
 .byte 37,21 ; PHP 08
 .byte 35,1  ; ORA IMM 09
 .byte 3,5   ; ASL ACC 0A
 .byte 71,21 ; PHD 0B
 .byte 64,2  ; TSB ABS 0C
 .byte 35,2  ; ORA ABS 0D
 .byte 3,2   ; ASL ABS 0E
 .byte 35,3  ; ORA ABS L 0F
 .byte 10,15 ; BPL 10
 .byte 35,7  ; ORA (D),Y 11
 .byte 35,18 ; ORA (D) 12
 .byte 35,23 ; ORA S,Y 13
 .byte 63,4  ; TRB D 14
 .byte 35,10 ; ORA D,X 15
 .byte 3,10  ; ASL D,X 16
 .byte 35,8  ; ORA (DL),Y 17
 .byte 14,6  ; CLC 18
 .byte 35,14 ; ORA ABS,Y 19
 .byte 25,5  ; NC ACC 1A
 .byte 77,6  ; TCS 1B
 .byte 63,2  ; TRB ABS,X 1C
 .byte 35,12 ; ORA ABS,X 1D
 .byte 3,12  ; ASL ABS,X 1E
 .byte 35,13 ; ORA ABSL,X 1F
 .byte 29,2  ; JSR ABS 20
 .byte 2,7   ; AND (D, X) 21
 .byte 29,3  ; JSL ABS L 22
 .byte 2,22  ; AND SR 23
 .byte 7,4   ; BIT D 24
 .byte 2,4   ; AND D 25
 .byte 40,4  ; ROL D 26
 .byte 2,19  ; AND (DL) 27
 .byte 39,6  ; PLP 28
 .byte 2,1   ; AND IMM 29
 .byte 40,5  ; ROL ACC 2A
 .byte 69,21 ; PLD 2B
 .byte 7,2   ; BIT ABS 2C
 .byte 2,2   ; AND ABS 2D
 .byte 40,5  ; ROL A 2E
 .byte 2,3   ; AND ABS L 2F
 .byte 8,15  ; BMI 30
 .byte 2,11  ; AND D,Y 31
 .byte 2,18  ; AND (D) 32
 .byte 2,23  ; AND (SR),Y 33
 .byte 7,10  ; BIT D,X 34
 .byte 2,10  ; AND D,X 35
 .byte 40,10 ; ROL D,X 36
 .byte 2,8   ; AND (DL),Y 37
 .byte 45,6  ; SEC 38
 .byte 25,14 ; AND ABS,Y 39
 .byte 21,5  ; DEC 3A
 .byte 78,6  ; TSC 3B
 .byte 7,12  ; BIT A,X 3C
 .byte 2,12  ; AND ABS,X 3D
 .byte 40,12 ; ROL A,X 3E
 .byte 2,13  ; AND AL,X 3F
 .byte 42,6  ; RTI 40
 .byte 24,9  ; EOR (D,X) 41
 .byte 101,6 ; WDM 42
 .byte 24,22 ; EOR (D,X) 43
 .byte 87,24 ; MVP 44
 .byte 24,4  ; EOR D 45
 .byte 33,4  ; LSR D 46
 .byte 24,19 ; EOR (DL) 47
 .byte 36,6  ; PHA 48
 .byte 24,1  ; EOR IMM 49
 .byte 33,5  ; LSR ABS L 4A
 .byte 72,6  ; PHK 4B
 .byte 28,2  ; JMP ABS 4C
 .byte 24,2  ; EOR ABS 4D
 .byte 33,2  ; LSR ABS 4E
 .byte 24,5  ; EOR ABS L 4F
 .byte 12,15 ; BVC 50
 .byte 24,7  ; EOR (D),Y 51
 .byte 24,18 ; EOR (D) 52
 .byte 24,23 ; EOR (SR),Y 53
 .byte 86,24 ; MVN 54
 .byte 24,10 ; EOR D,X 55
 .byte 33,10 ; LSR D,X 56
 .byte 24,8  ; EOR (DL),Y 57
 .byte 16,6  ; CLI 58
 .byte 24,14 ; EOR 59
 .byte 61,21 ; PHY 5A
 .byte 75,6  ; TCD 5B
 .byte 28,3  ; JMP ABSL 5C
 .byte 24,12 ; EOR ABS,X 5D
 .byte 33,12 ; LSR ABS,X 5E
 .byte 24,13 ; EOR ABSL,X 5F
 .byte 43,6  ; RTS 60
 .byte 1,9   ; ADC (D, X) 61
 .byte 67,16 ; PER 62
 .byte 1,22  ; ADC SR 63
 .byte 62,4  ; STZ D 64
 .byte 1,4   ; ADC D 65
 .byte 41,4  ; ROR D 66
 .byte 1,19  ; ADC (DL) 67
 .byte 38,21 ; PLA 68
 .byte 1,1   ; ADC 69
 .byte 41,5  ; ROR ABSL 6A
 .byte 85,6  ; RTL 6B
 .byte 28,17 ; JMP (A) 6C
 .byte 1,2   ; ADC ABS 6D
 .byte 41,2  ; ROR ABS 6E
 .byte 1,3   ; ADC ABSL 6F
 .byte 13,15 ; BVS 70
 .byte 1,8   ; ADC (D),Y 71
 .byte 1,18  ; ADC (D) 72
 .byte 1,23  ; ADC (SR),Y 73
 .byte 62,10 ; STZ D,X 74
 .byte 1,10  ; ADC D,X 75
 .byte 41,10 ; ROR D,X 76
 .byte 1,8   ; ADC (DL),Y 77
 .byte 47,6  ; SEI 78
 .byte 1,14  ; ADC ABS,Y 79
 .byte 59,21 ; PLY 7A
 .byte 76,6  ; TDC 7B
 .byte 28,20 ; JMP (A, X) 7C
 .byte 1,12  ; ADC ABS,X 7D
 .byte 41,12 ; ROR ABS,X 7E
 .byte 1,13  ; ADC ABSL,X 7F

ATRIBH:
 .byte 57,15 ; BRA 80
 .byte 48,9  ; STA (D, X) 81
 .byte 83,16 ; BRL 82
 .byte 48,22 ; STA-,S 83
 .byte 50,4  ; STY D 84
 .byte 48,4  ; STA D 85
 .byte 49,4  ; STX D 86
 .byte 48,19 ; STA [ D ] 87
 .byte 23,6  ; DEY 88
 .byte 7,1   ; BIT IMM 89
 .byte 54,6  ; TXA 8A
 .byte 70,21 ; PHB 8B
 .byte 50,2  ; STY ABS 8C
 .byte 48,2  ; STA ABS 8D
 .byte 49,2  ; STX ABS 8E
 .byte 48,3  ; STA ABS L 8F
 .byte 4,15  ; BC 90
 .byte 48,7  ; STA (D),Y 91
 .byte 48,18 ; STA (D) 92
 .byte 48,23 ; STA (SR),Y 93
 .byte 50,10 ; STY D,X 94
 .byte 48,10 ; STA D,X 95
 .byte 49,11 ; STX D,Y 96
 .byte 48,8  ; STA (DL),Y 97
 .byte 56,6  ; TYA 98
 .byte 48,14 ; STA ABS,Y 99
 .byte 55,6  ; TXS D 9A
 .byte 79,6  ; TXY 9B
 .byte 62,2  ; STZ ABS 9C
 .byte 48,12 ; STA ABS,X 9D
 .byte 62,12 ; STZ ABS,X 9E
 .byte 48,13 ; STA ABSL,X 9F
 .byte 32,1  ; LDY IMM A0
 .byte 30,9  ; LDA (D,X) A1
 .byte 31,1  ; LDX IMM A2
 .byte 30,22 ; LDA SR A3
 .byte 32,4  ; LDY D A4
 .byte 30,4  ; LDA D A5
 .byte 31,4  ; LDX D A6
 .byte 30,19 ; LDA (DL) A7
 .byte 52,6  ; TAY A8
 .byte 30,1  ; LDA IMM A9
 .byte 51,6  ; TAX AA
 .byte 68,21 ; PLB AB
 .byte 32,2  ; LDY ABS AC
 .byte 30,2  ; LDA ABS AD
 .byte 31,2  ; LDX ABS AE
 .byte 30,3  ; LDA ABS L AF
 .byte 5,15  ; BCS B0
 .byte 30,7  ; LDA (D),Y B1
 .byte 30,18 ; LDA (D) B2
 .byte 30,23 ; LDA (SR),Y B3
 .byte 32,10 ; LDY D,X B4
 .byte 30,10 ; LDA D,X B5
 .byte 30,11 ; LDX D,Y B6
 .byte 30,8  ; LDA (DL),Y B7
 .byte 17,6  ; CLV B8
 .byte 30,14 ; LDA ABS,Y B9
 .byte 53,6  ; TSX BA
 .byte 80,6  ; TYX BB
 .byte 32,12 ; LDY ABS,X BC
 .byte 30,12 ; LDA ABS,X BD
 .byte 31,14 ; LDX ABS,Y BE
 .byte 30,13 ; LDA ABSL,X BF
 .byte 30,13 ; CPY C0
 .byte 18,9  ; CMP (D,X) C1
 .byte 73,1  ; REP C2
 .byte 18,22 ; CMP C3
 .byte 20,4  ; CPY D C4
 .byte 18,4  ; CMP D C5
 .byte 21,4  ; DEC D C6
 .byte 18,19 ; CMP (DL) C7
 .byte 27,6  ; INY C8
 .byte 18,1  ; CMP IMM C9
 .byte 22,6  ; DEX CA
 .byte 89,6  ; WAI CB
 .byte 20,2  ; CPY ABS CC
 .byte 18,2  ; CMP ABS CD
 .byte 21,2  ; DEC ABS CE
 .byte 18,3  ; CMP ABSL CF
 .byte 9,15  ; BNE D0
 .byte 18,7  ; CMP (D0,Y D1
 .byte 18,18 ; CMP (D) D2
 .byte 18,23 ; CMP D3
 .byte 66,4  ; PEI D D4
 .byte 18,10 ; CMP D,X D5
 .byte 21,10 ; DEC D,X D6
 .byte 18,8  ; CMP (DL),Y D7
 .byte 15,6  ; CLD D8
 .byte 18,14 ; CMP ABS,Y D9
 .byte 60,21 ; PHX DA
 .byte 100,6 ; STP DB
 .byte 28,17 ; JMP (A) DC
 .byte 18,12 ; CMP ABS,X DD
 .byte 21,12 ; DEC ABS,X DE
 .byte 18,13 ; CMP ABSL,X DF
 .byte 19,1  ; CPX IMM E0
 .byte 44,9  ; SBC (D,X) E1
 .byte 74,1  ; SEP IMM E2
 .byte 44,22 ; SBC SR E3
 .byte 31,4  ; LDX D E4
 .byte 44,4  ; SBC D E5
 .byte 25,4  ; INC D E6
 .byte 44,19 ; SBD (DL) E7
 .byte 26,6  ; INX D E8
 .byte 44,1  ; SBC IMM E9
 .byte 34,6  ; NOP EA
 .byte 81,6  ; XBA EB
 .byte 19,2  ; CPX ABS EC
 .byte 44,2  ; SBC ABS ED
 .byte 25,2  ; INC ABS EE
 .byte 44,3  ; SBC ABSL EF
 .byte 6,15  ; BEQ F0
 .byte 44,7  ; SBC (D),Y F1
 .byte 44,18 ; SBC (D) F2
 .byte 44,23 ; SBC (SR),Y F3
 .byte 65,2  ; PEA F4
 .byte 44,10 ; SBC D,X F5
 .byte 25,10 ; INC D,X F6
 .byte 44,8  ; SBC (DL),Y F7
 .byte 46,6  ; SED F8
 .byte 44,14 ; SBC ABS,Y F9
 .byte 58,21 ; PLX FA
 .byte 82,6  ; XCE FB
 .byte 29,20 ; JSR (A,X) FC
 .byte 44,12 ; SBC ABS,X FD
 .byte 25,12 ; INC ABS,X FE
 .byte 44,13 ; SBC ABSL,X FF
