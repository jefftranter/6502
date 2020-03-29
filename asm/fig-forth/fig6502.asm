;
;                        Through the courtesy of
;
;                         FORTH INTEREST GROUP
;                            P.O. BOX  2154
;                         OAKLAND, CALIFORNIA
;                                94621
;
;
;                             Release 1.1
;
;                        with compiler security
;                                  and
;                        variable length names
;
;    Further distribution must include the above notice.
;    The FIG installation Manual is required as it contains
;    the model of FORTH and glossary of the system.
;    Available from FIG at the above address for **.** postpaid.
;
;    Translated from the FIG model by W.F. Ragsdale with input-
;    output given for the Rockwell System-65. Transportation to
;    other systems requires only the alteration of :
;                 XEMIT, XKEY, XQTER, XCR, AND RSLW
;
;    Equates giving memory assignments, machine
;    registers, and disk parameters.
;
SSIZE     =128           ; sector size in bytes
NBUF      =8             ; number of buffers desired in RAM
;                             (SSIZE*NBUF >= 1024 bytes)
SECTR     =800           ; sector per drive
;                              forcing high drive to zero
SECTL     =1600          ; sector limit for two drives
;                              of 800 per drive.
BMAG      =1056          ; total buffer magnitude, in bytes
;                              expressed by SSIZE+4*NBUF
;
BOS       =$20           ; bottom of data stack, in zero-page.
TOS       =$9E           ; top of data stack, in zero-page.
N         =TOS+8         ; scratch workspace.
IP        =N+8           ; interpretive pointer.
W         =IP+3          ; code field pointer.
UP        =W+2           ; user area pointer.
XSAVE     =UP+2          ; temporary for X register.
;
TIBX      =$0100         ; terminal input buffer of 84 bytes.
ORIG      =$0380         ; origin of FORTH's Dictionary.
MEM       =$2000         ; top of assigned memory+1 byte.
UAREA     =MEM-128       ; 128 bytes of user area
DAREA     =UAREA-BMAG    ; disk buffer space.
;
;         Monitor calls for terminal support
;
OUTCH     =$BF2D         ; output one ASCII char. to term. OSI ROM Routine (screen)
;OUTCH    =$FCB1         ; output one ASCII char. to term. OSI ROM Routine (serial port)
INCH      =$FD00         ; input one ASCII char. to term.  OSI ROM Routine (keyboard)
;INCH     =$FE80         ; input one ASCII char. to term.  OSI ROM Routine (serial port)
;TCR      =$D0F1         ; terminal return and line feed. See end of listing.
;
;    From DAREA downward to the top of the dictionary is free
;    space where the user's applications are compiled.
;
;    Boot up parameters. This area provides jump vectors
;    to Boot up code, and parameters describing the system.
;
;
          .org ORIG
;
                         ; User cold entry point
ENTER:    NOP            ; Vector to COLD entry
          JMP COLD+2     ;
REENTR:   NOP            ; User Warm entry point
          JMP WARM       ; Vector to WARM entry
          .WORD $0004    ; 6502 in radix-36
          .WORD $5ED2    ;
          .WORD NTOP     ; Name address of MON
          .WORD $7F      ; Backspace Character
          .WORD UAREA    ; Initial User Area
          .WORD TOS      ; Initial Top of Stack
          .WORD $1FF     ; Initial Top of Return Stack
          .WORD TIBX     ; Initial terminal input buffer
;
;
          .WORD 31       ; Initial name field width
          .WORD 0        ; 0=nod disk, 1=disk
          .WORD TOP      ; Initial fence address
          .WORD TOP      ; Initial top of dictionary
          .WORD VL0      ; Initial Vocabulary link ptr.
;
;    The following offset adjusts all code fields to avoid an
;    address ending $XXFF. This must be checked and altered on
;    any alteration , for the indirect jump at W-1 to operate !
;
;         .org *+2
;
;
;                                       LIT
;                                       SCREEN 13 LINE 1
;
L22:      .BYTE $83,"LI",$D4            ; <--- name field
;                          <----- link field
          .WORD 00       ; last link marked by zero
LIT:      .WORD *+2      ; <----- code address field
          LDA (IP),Y     ; <----- start of parameter field
          PHA
          INC IP
          BNE L30
          INC IP+1
L30:      LDA (IP),Y
L31:      INC IP
          BNE PUSH
          INC IP+1
;
PUSH:     DEX
          DEX
;
PUT:      STA 1,X
          PLA
          STA 0,X
;
;    NEXT is the address interpreter that moves from machine
;    level word to word.
;
NEXT:     LDY #1
          LDA (IP),Y     ; Fetch code field address pointed
          STA W+1        ; to by IP.
          DEY
          LDA (IP),Y
          STA W
;         JSR TRACE      ; Remove this when all is well
          CLC            ; Increment IP by two.
          LDA IP
          ADC #2
          STA IP
          BCC L54
          INC IP+1
L54:      JMP W-1        ; Jump to an indirect jump (W) which
;                        ; vectors to code pointed to by a code
;                        ; field.
;
;    CLIT pushes the next inline byte to data stack
;
L35:      .BYTE $84,"CLI",$D4
          .WORD L22      ; Link to LIT
CLIT:     .WORD *+2
          LDA (IP),Y
          PHA
          TYA
          BEQ L31        ; a forced branch into LIT
;
;
;    This is a temporary trace routine, to be used until FORTH
;    is generally operating. Then NOP the terminal query
;    "JSR ONEKEY". This will allow user input to the text
;    interpreter. When crashes occur, the display shows IP, W,
;    and the word locations of the offending code. When all is
;    well, remove : TRACE, TCOLON, PRNAM, DECNP, and the
;    following monitor/register equates.
;
;
;
;    Monitor routines needed to trace.
;
;XBLANK    =$D0AF         ; print one blank
;CRLF      =$D0D2         ; print a carriage return and line feed.
;HEX2      =$D2CE         ; print accum as two hex numbers
;LETTER    =$D2C1         ; print accum as one ASCII character
;ONEKEY    =$D1DC         ; wait for keystroke
;XW        =$12           ; scratch reg. to next code field add
;NP        =$14           ; scratch reg. pointing to name field
;
;
;TRACE:    STX XSAVE
;          JSR CRLF
;          LDA IP+1
;          JSR HEX2
;          LDA IP
;          JSR HEX2       ; print IP, the interpreter pointer
;          JSR XBLANK
;
;
;          LDA #0
;          LDA (IP),Y
;          STA XW
;          STA NP         ; fetch the next code field pointer
;          INY
;          LDA (IP),Y
;          STA XW+1
;          STA NP+1
;          JSR PRNAM      ; print dictionary name
;
;          LDA XW+1
;          JSR HEX2       ; print code field address
;          LDA XW
;          JSR HEX2
;          JSR XBLANK
;
;          LDA XSAVE      ; print stack location in zero-page
;          JSR HEX2
;          JSR XBLANK
;
;          LDA #1         ; print return stack bottom in page 1
;          JSR HEX2
;          TSX
;          INX
;          TXA
;          JSR HEX2
;          JSR XBLANK
;
;          JSR ONEKEY     ; wait for operator keystroke
;          LDX XSAVE      ; just to pinpoint early problems
;          LDY #0
;          RTS
;
;    TCOLON is called from DOCOLON to label each point
;    where FORTH 'nests' one level.
;
;TCOLON:   STX XSAVE
;          LDA W
;          STA NP         ; locate the name of the called word
;          LDA W+1
;          STA NP+1
;          JSR CRLF
;          LDA #$3A       ; ':
;          JSR LETTER
;          JSR XBLANK
;          JSR PRNAM
;          LDX XSAVE
;          RTS
;
;    Print name by it's code field address in NP
;
;PRNAM:    JSR DECNP
;          JSR DECNP
;          JSR DECNP
;          LDY #0
;PN1:      JSR DECNP
;          LDA (NP),Y     ; loop till D7 in name set
;          BPL PN1
;PN2:      INY
;          LDA (NP),Y
;          JSR LETTER     ; print letters of name field
;          LDA (NP),Y
;          BPL PN2
;          JSR XBLANK
;          LDY #0
;          RTS
;
;    Decrement name field pointer
;
;DECNP:    LDA NP
;          BNE DECNP1
;          DEC NP+1
;DECNP1:   DEC NP
;          RTS
;
;
SETUP:    ASL A
          STA N-1
L63:      LDA 0,X
          STA N,Y
          INX
          INY
          CPY N-1
          BNE L63
          LDY #0
          RTS
;
;                                       EXCECUTE
;                                       SCREEN 14 LINE 11
;
L75:      .BYTE $87,"EXECUT",$C5
          .WORD L35      ; link to CLIT
EXEC:     .WORD *+2
          LDA 0,X
          STA W
          LDA 1,X
          STA W+1
          INX
          INX
          JMP W-1        ; to JMP (W) in z-page
;
;                                       BRANCH
;                                       SCREEN 15 LINE 11
;
L89:      .BYTE $86,"BRANC",$C8
          .WORD L75      ; link to EXCECUTE
BRAN:     .WORD *+2
          CLC
          LDA (IP),Y
          ADC IP
          PHA
          INY
          LDA (IP),Y
          ADC IP+1
          STA IP+1
          PLA
          STA IP
          JMP NEXT +2
;
;                                       0BRANCH
;                                       SCREEN 15 LINE 6
;
L107:     .BYTE $87,"0BRANC",$C8
          .WORD L89      ; link to BRANCH
ZBRAN:    .WORD *+2
          INX
          INX
          LDA $FE,X
          ORA $FF,X
          BEQ BRAN+2
;
BUMP:     CLC
          LDA IP
          ADC #2
          STA IP
          BCC L122
          INC IP+1
L122:     JMP NEXT
;
;                                       (LOOP)
;                                       SCREEN 16 LINE 1
;
L127:     .BYTE $86,"(LOOP",$A9
          .WORD L107     ; link to 0BRANCH
PLOOP:    .WORD L130
L130:     STX  XSAVE
          TSX
          INC $101,X
          BNE PL1
          INC $102,X
;
PL1:      CLC
          LDA $103,X
          SBC $101,X
          LDA $104,X
          SBC $102,X
;
PL2:      LDX XSAVE
          ASL A
          BCC BRAN+2
          PLA
          PLA
          PLA
          PLA
          JMP BUMP
;
;                                       (+LOOP)
;                                       SCREEN 16 LINE 8
;
L154:     .BYTE $87,"(+LOOP",$A9
          .WORD L127     ; link to (loop)
PPLOO:    .WORD *+2
          INX
          INX
          STX XSAVE
          LDA $FF,X
          PHA
          PHA
          LDA $FE,X
          TSX
          INX
          INX
          CLC
          ADC $101,X
          STA $101,X
          PLA
          ADC $102,X
          STA $102,X
          PLA
          BPL PL1
          CLC
          LDA $101,X
          SBC $103,X
          LDA $102,X
          SBC $104,X
          JMP PL2
;
;                                       (DO)
;                                       SCREEN 17 LINE 2
;
L185:     .BYTE $84,"(DO",$A9
          .WORD L154     ; link to (+LOOP)
PDO:      .WORD *+2
          LDA 3,X
          PHA
          LDA 2,X
          PHA
          LDA 1,X
          PHA
          LDA 0,X
          PHA
;
POPTWO:   INX
          INX
;
;
;
POP:      INX
          INX
          JMP NEXT
;
;                                       I
;                                       SCREEN 17 LINE 9
;
L207:     .BYTE $81,$C9
          .WORD L185     ; link to (DO)
I:        .WORD R+2      ; share the code for R
;
;                                       DIGIT
;                                       SCREEN 18 LINE 1
;
L214:     .BYTE $85,"DIGI",$D4
          .WORD L207     ; link to I
DIGIT:    .WORD *+2
          SEC
          LDA 2,X
          SBC #$30
          BMI L234
          CMP #$A
          BMI L227
          SEC
          SBC #7
          CMP #$A
          BMI L234
L227:     CMP 0,X
          BPL L234
          STA 2,X
          LDA #1
          PHA
          TYA
          JMP PUT        ; exit true with converted value
L234:     TYA
          PHA
          INX
          INX
          JMP PUT        ; exit false with bad conversion
;
;                                       (FIND)
;                                       SCREEN 19 LINE 1
;
L243:     .BYTE $86,"(FIND",$A9
          .WORD L214   ; Link to DIGIT
PFIND:    .WORD *+2
          LDA #2
          JSR SETUP
          STX XSAVE
L249:     LDY #0
          LDA (N),Y
          EOR (N+2),Y
;
;
          AND #$3F
          BNE L281
L254:     INY
          LDA (N),Y
          EOR (N+2),Y
          ASL A
          BNE L280
          BCC L254
          LDX XSAVE
          DEX
          DEX
          DEX
          DEX
          CLC
          TYA
          ADC #5
          ADC N
          STA 2,X
          LDY #0
          TYA
          ADC N+1
          STA 3,X
          STY 1,X
          LDA (N),Y
          STA 0,X
          LDA #1
          PHA
          JMP PUSH
L280:     BCS L284
L281:     INY
          LDA (N),Y
          BPL L281
L284:     INY
          LDA (N),Y
          TAX
          INY
          LDA (N),Y
          STA N+1
          STX N
          ORA N
          BNE L249
          LDX XSAVE
          LDA #0
          PHA
          JMP PUSH       ; exit false upon reading null link
;
;                                       ENCLOSE
;                                       SCREEN 20 LINE 1
;
L301:     .BYTE $87,"ENCLOS",$C5
          .WORD L243     ; link to (FIND)
ENCL:     .WORD *+2
          LDA #2
          JSR SETUP
          TXA
          SEC
          SBC #8
          TAX
          STY 3,X
          STY 1,X
          DEY
L313:     INY
          LDA (N+2),Y
          CMP N
          BEQ L313
          STY 4,X
L318:     LDA (N+2),Y
          BNE L327
          STY 2,X
          STY 0,X
          TYA
          CMP 4,X
          BNE L326
          INC 2,X
L326:     JMP NEXT
L327:     STY 2,X
          INY
          CMP N
          BNE L318
          STY 0,X
          JMP NEXT
;
;                                       EMIT
;                                       SCREEN 21 LINE 5
;
L337:     .BYTE $84,"EMI",$D4
          .WORD L301     ; link to ENCLOSE
EMIT:     .WORD XEMIT    ; Vector to code for KEY
;
;                                       KEY
;                                       SCREEN 21 LINE 7
;
L344:     .BYTE $83,"KE",$D9
          .WORD L337     ; link to EMIT
KEY:      .WORD XKEY     ; Vector to code for KEY
;
;                                       ?TERMINAL
;                                       SCREEN 21 LINE 9
;
L351:     .BYTE $89,"?TERMINA",$CC
          .WORD L344     ; link to KEY
QTERM:    .WORD XQTER    ; Vector to code for ?TERMINAL
;
;
;
;
;
;                                       CR
;                                       SCREEN 21 LINE 11
;
L358:     .BYTE $82,"C",$D2
          .WORD L351     ; link to ?TERMINAL
CR:       .WORD XCR      ; Vector to code for CR
;
;                                       CMOVE
;                                       SCREEN 22 LINE 1
;
L365:     .BYTE $85,"CMOV",$C5
          .WORD L358     ; link to CR
CMOVE:    .WORD *+2
          LDA #3
          JSR SETUP
L370:     CPY N
          BNE L375
          DEC N+1
          BPL L375
          JMP NEXT
L375:     LDA (N+4),Y
          STA (N+2),Y
          INY
          BNE L370
          INC N+5
          INC N+3
          JMP L370
;
;                                       U*
;                                       SCREEN 23 LINE 1
;
L386:     .BYTE $82,"U",$AA
          .WORD L365     ; link to CMOVE
USTAR:    .WORD *+2
          LDA 2,X
          STA N
          STY 2,X
          LDA 3,X
          STA N+1
          STY 3,X
          LDY #16        ; for 16 bits
L396:     ASL 2,X
          ROL 3,X
          ROL 0,X
          ROL 1,X
          BCC L411
          CLC
          LDA N
          ADC 2,X
          STA 2,X
          LDA N+1
          ADC 3,X
          STA 3,X
          LDA #0
          ADC 0,X
          STA 0,X

L411:     DEY
          BNE L396
          JMP NEXT
;
;                                       U/
;                                       SCREEN 24 LINE 1
;
L418:     .BYTE $82,"U",$AF
          .WORD L386     ; link to U*
USLAS:    .WORD *+2
          LDA 4,X
          LDY 2,X
          STY 4,X
          ASL A
          STA 2,X
          LDA 5,X
          LDY 3,X
          STY 5,X
          ROL A
          STA 3,X
          LDA #16
          STA N
L433:     ROL 4,X
          ROL 5,X
          SEC
          LDA 4,X
          SBC 0,X
          TAY
          LDA 5,X
          SBC 1,X
          BCC L444
          STY 4,X
          STA 5,X
L444:     ROL 2,X
          ROL 3,X
          DEC N
          BNE L433
          JMP POP
;
;                                       AND
;                                       SCREEN 25 LINE 2
;
L453:     .BYTE $83,"AN",$C4
          .WORD L418     ; link to U/
ANDD:     .WORD *+2
          LDA 0,X
          AND 2,X
          PHA
          LDA 1,X
          AND 3,X
;
BINARY:   INX
          INX
          JMP PUT
;
;                                       OR
;                                       SCREEN 25 LINE 7
;
L469:     .BYTE $82,"O",$D2
          .WORD L453     ; link to AND
OR:       .WORD *+2
          LDA 0,X
          ORA 2,X
          PHA
          LDA 1,X
          ORA 3,X
          INX
          INX
          JMP PUT
;
;                                       XOR
;                                       SCREEN 25 LINE 11
;
L484:     .BYTE $83,"XO",$D2
          .WORD L469     ; link to OR
XOR:      .WORD *+2
          LDA 0,X
          EOR 2,X
          PHA
          LDA 1,X
          EOR 3,X
          INX
          INX
          JMP PUT
;
;                                       SP@
;                                       SCREEN 26 LINE 1
;
L499:     .BYTE $83,"SP",$C0
          .WORD L484     ; link  to XOR
SPAT:     .WORD *+2
          TXA
;
PUSHOA:   PHA
          LDA #0
          JMP PUSH
;
;                                       SP!
;                                       SCREEN 26 LINE 5
;
;
L511:     .BYTE $83,"SP",$A1
          .WORD L499     ; link to SP@
SPSTO:    .WORD *+2
          LDY #6
          LDA (UP),Y     ; load data stack pointer (X reg) from
          TAX            ; silent user variable S0.
          JMP NEXT
;
;                                       RP!
;                                       SCREEN 26 LINE 8
;
L522:     .BYTE $83,"RP",$A1
          .WORD L511     ; link to SP!
RPSTO:    .WORD *+2
          STX XSAVE      ; load return stack pointer (machine
          LDY #8         ; stack pointer) from silent user
          LDA (UP),Y     ; VARIABLE R0
          TAX
          TXS
          LDX XSAVE
          JMP NEXT
;
;                                       ;S
;                                       SCREEN 26 LINE 12
;
L536:     .BYTE $82,";",$D3
          .WORD L522     ; link to RP!
SEMIS:    .WORD *+2
          PLA
          STA IP
          PLA
          STA IP+1
          JMP NEXT
;
;                                       LEAVE
;                                       SCREEN 27 LINE  1
;
L548:     .BYTE $85,"LEAV",$C5
          .WORD L536     ; link to ;S
LEAVE:    .WORD *+2
          STX XSAVE
          TSX
          LDA $101,X
          STA $103,X
          LDA $102,X
          STA $104,X
          LDX XSAVE
          JMP NEXT
;
;                                       >R
;                                       SCREEN 27 LINE 5
;
L563:     .BYTE $82,">",$D2
          .WORD L548     ; link to LEAVE
TOR:      .WORD *+2
          LDA 1,X        ; move high byte
          PHA
          LDA 0,X        ; then low byte
          PHA            ; to return stack
          INX
          INX            ; popping off data stack
          JMP NEXT
;
;                                       R>
;                                       SCREEN 27 LINE 8
;
L577:     .BYTE $82,"R",$BE
          .WORD L563     ; link to >R
RFROM:    .WORD *+2
          DEX            ; make room on data stack
          DEX
          PLA            ; high byte
          STA 0,X
          PLA            ; then low byte
          STA 1,X        ; restored to data stack
          JMP NEXT
;
;                                       R
;                                       SCREEN 27 LINE 11
;
L591:     .BYTE $81,$D2
          .WORD L577     ; link to R>
R:        .WORD *+2
          STX XSAVE
          TSX            ; address return stack
          LDA $101,X     ; copy bottom value
          PHA            ; to data stack
          LDA $102,X
          LDX XSAVE
          JMP PUSH
;
;                                       0=
;                                       SCREEN 28 LINE 2
;
L605:     .BYTE $82,"0",$BD
          .WORD L591     ; link to R
ZEQU:     .WORD *+2
          LDA 1,X        ; Corrected from FD3/2 p69
          STY 1,X
          ORA 0,X
          BNE L613
          INY
L613:     STY 0,X
          JMP NEXT
;
;                                       0<
;                                       SCREEN 28 LINE 6
;
L619:     .BYTE $82,"0",$BC
          .WORD L605     ; link to 0=
ZLESS:    .WORD *+2
          ASL 1,X
          TYA
          ROL A
          STY 1,X
          STA 0,X
          JMP NEXT
;
;                                       +
;                                       SCREEN 29 LINE 1
;
L632:     .BYTE $81,$AB
          .WORD L619     ; link to V-ADJ
PLUS:     .WORD *+2
          CLC
          LDA 0,X
          ADC 2,X
          STA 2,X
          LDA 1,X
          ADC 3,X
          STA 3,X
          INX
          INX
          JMP NEXT
;
;                                       D+
;                                       SCREEN 29 LINE 4
;
L649:     .BYTE $82,"D",$AB
          .WORD L632     ;    LINK TO +
DPLUS:    .WORD *+2
          CLC
          LDA 2,X
          ADC 6,X
          STA 6,X
          LDA 3,X
          ADC 7,X
          STA 7,X
          LDA 0,X
          ADC 4,X
          STA 4,X
          LDA 1,X
          ADC 5,X
          STA 5,X
          JMP POPTWO
;
;                                       MINUS
;                                       SCREEN 29 LINE 9
;
L670:     .BYTE $85,"MINU",$D3
          .WORD L649     ; link to D+
MINUS:    .WORD *+2
          SEC
          TYA
          SBC 0,X
          STA 0,X
          TYA
          SBC 1,X
          STA 1,X
          JMP NEXT
;
;                                       DMINUS
;                                       SCREEN 29 LINE 12
;
L685:     .BYTE $86,"DMINU",$D3
          .WORD L670     ; link to  MINUS
DMINU:    .WORD *+2
          SEC
          TYA
          SBC 2,X
          STA 2,X
          TYA
          SBC 3,X
          STA 3,X
          JMP MINUS+3
;
;                                       OVER
;                                       SCREEN 30 LINE 1
;
L700:     .BYTE $84,"OVE",$D2
          .WORD L685     ; link to DMINUS
OVER:     .WORD *+2
          LDA 2,X
          PHA
          LDA 3,X
          JMP PUSH
;
;                                       DROP
;                                       SCREEN 30 LINE 4
;
L711:     .BYTE $84,"DRO",$D0
          .WORD L700     ; link to OVER
DROP:     .WORD POP
;
;                                       SWAP
;                                       SCREEN 30 LINE 8
;
L718:     .BYTE $84,"SWA",$D0
          .WORD L711     ; link to DROP
SWAP:     .WORD *+2
          LDA 2,X
          PHA
          LDA 0,X
          STA 2,X
          LDA 3,X
          LDY 1,X
          STY 3,X
          JMP PUT
;
;                                       DUP
;                                       SCREEN 30 LINE 21
;
L733:     .BYTE $83,"DU",$D0
          .WORD L718     ; link to SWAP
DUP:      .WORD *+2
          LDA 0,X
          PHA
          LDA 1,X
          JMP PUSH
;
;                                       +!
;                                       SCREEN 31 LINE 2
;
L744:     .BYTE $82,"+",$A1
          .WORD L733     ; link to DUP
PSTOR:    .WORD *+2
          CLC
          LDA (0,X)      ; fetch 16 bit value addressed by
          ADC 2,X        ; bottom of  stack, adding to
          STA (0,X)      ; second item on stack, and return
          INC 0,X        ; to memory
          BNE L754
          INC 1,X
L754:     LDA (0,X)
          ADC 3,X
          STA (0,X)
          JMP POPTWO
;
;                                       TOGGLE
;                                       SCREEN 31 LINE 7
;
L762:     .BYTE $81,"TOGGL",$C5
          .WORD L744     ; link to +!
TOGGL:    .WORD *+2
          LDA (2,X)      ; complement bits in memory address
          EOR 0,X        ; second on stack, by pattern on
          STA (2,X)      ; bottom of stack.
          JMP POPTWO
;
;                                       @
;                                       SCREEN 32 LINE 1
;
L773:     .BYTE $81,$C0
          .WORD L762     ; link to TOGGLE
AT:       .WORD *+2
          LDA (0,X)
          PHA
          INC 0,X
          BNE L781
          INC 1,X
L781:     LDA (0,X)
          JMP PUT
;
;                                       C@
;                                       SCREEN 32 LINE 5
;
L787:     .BYTE $82,"C",$C0
          .WORD L773     ; link to @
CAT:      .WORD *+2
          LDA (0,X)      ; fetch byte addressed by bottom of
          STA 0,X        ; stack to stack, zeroing the high
          STY 1,X        ; byte
          JMP NEXT
;
;                                       !
;                                       SCREEN 32 LINE 8
;
L798:     .BYTE $81,$A1
          .WORD L787     ; link to C@
STORE:    .WORD *+2
          LDA 2,X
          STA (0,X)      ; store second 16bit value on stack
          INC 0,X        ; to memory as addressed by bottom
          BNE L806       ; of stack.
          INC 1,X
L806:     LDA 3,X
          STA (0,X)
          JMP POPTWO
;
;                                       C!
;                                       SCREEN 32 LINE 12
;
L813:     .BYTE $82,"C",$A1
          .WORD L798     ; link to !
CSTOR:    .WORD *+2
          LDA 2,X
          STA (0,X)
          JMP POPTWO
;
;                                       :
;                                       SCREEN 33 LINE 2
;
L823:     .BYTE $C1,$BA
          .WORD L813     ; link to C!
COLON:    .WORD DOCOL
          .WORD QEXEC
          .WORD SCSP
          .WORD CURR
          .WORD AT
          .WORD CON
          .WORD STORE
          .WORD CREAT
          .WORD RBRAC
          .WORD PSCOD
;
DOCOL:    LDA IP+1
          PHA
          LDA IP
          PHA
;          JSR TCOLON     ; mark the start of a traced : def.
          CLC
          LDA W
          ADC #2
          STA IP
          TYA
          ADC W+1
          STA IP+1
          JMP NEXT
;
;                                       ;
;                                       SCREEN 33 LINE 9
;
L853:     .BYTE $C1,$BB
          .WORD L823     ; link to :
          .WORD DOCOL
          .WORD QCSP
          .WORD COMP
          .WORD SEMIS
          .WORD SMUDG
          .WORD LBRAC
          .WORD SEMIS
;
;                                       CONSTANT
;                                       SCREEN 34 LINE 1
;
L867:     .BYTE $88,"CONSTAN",$D4
          .WORD L853     ; link to ;
CONST:    .WORD DOCOL
          .WORD CREAT
          .WORD SMUDG
          .WORD COMMA
          .WORD PSCOD
;
DOCON:    LDY #2
          LDA (W),Y
          PHA
          INY
          LDA (W),Y
          JMP PUSH
;
;                                       VARIABLE
;                                       SCREEN 34 LINE 5
;
L885:     .BYTE $88,"VARIABL",$C5
          .WORD L867     ; link to CONSTANT
VAR:      .WORD DOCOL
          .WORD CONST
          .WORD PSCOD
;
DOVAR:    CLC
          LDA W
          ADC #2
          PHA
          TYA
          ADC W+1
          JMP PUSH
;
;                                       USER
;                                       SCREEN 34 LINE 10
;
L902:     .BYTE $84,"USE",$D2
          .WORD L885     ; link to VARIABLE
USER:     .WORD DOCOL
          .WORD CONST
          .WORD PSCOD
;
DOUSE:    LDY #2
          CLC
          LDA (W),Y
          ADC UP
          PHA
          LDA #0
          ADC UP+1
          JMP PUSH
;
;                                       0
;                                       SCREEN 35 LINE 2
;
L920:     .BYTE $81,$B0
          .WORD L902     ; link to USER
ZERO:     .WORD DOCON
          .WORD 0
;
;                                       1
;                                       SCREEN 35 LINE 2
;
L928:     .BYTE $81,$B1
          .WORD L920     ; link to 0
ONE:      .WORD DOCON
          .WORD 1
;
;                                       2
;                                       SCREEN 35 LINE 3
;
L936:     .BYTE $81,$B2
          .WORD L928     ; link to 1
TWO:      .WORD DOCON
          .WORD 2
;
;                                       3
;                                       SCREEN 35 LINE 3
;
L944:     .BYTE $81,$B3
          .WORD L936     ; link to 2
THREE:    .WORD DOCON
          .WORD 3
;
;                                       BL
;                                       SCREEN 35 LINE 4
;
L952:     .BYTE $82,"B",$CC
          .WORD L944     ; link to 3
BL:       .WORD DOCON
          .WORD $20
;
;                                       C/L
;                                       SCREEN 35 LINE 5
;                                       Characters per line
L960:     .BYTE $83,"C/",$CC
          .WORD L952     ; link to BL
CSLL:     .WORD DOCON
          .WORD 64
;
;                                       FIRST
;                                       SCREEN 35 LINE 7
;
L968:     .BYTE $85,"FIRS",$D4
          .WORD L960     ; link to C/L
FIRST:    .WORD DOCON
          .WORD DAREA    ; bottom of disk buffer area
;
;                                       LIMIT
;                                       SCREEN 35 LINE 8
;
L976:     .BYTE $85,"LIMI",$D4
          .WORD L968     ; link to FIRST
LIMIT:    .WORD DOCON
          .WORD UAREA    ; buffers end at user area
;
;                                       B/BUF
;                                       SCREEN 35 LINE 9
;                                       Bytes per Buffer
;
L984:     .BYTE $85,"B/BU",$C6
          .WORD L976     ; link to LIMIT
BBUF:     .WORD DOCON
          .WORD SSIZE    ; sector size
;
;                                       B/SCR
;                                       SCREEN 35 LINE 10
;                                       Blocks per screen
;
L992:     .BYTE $85,"B/SC",$D2
          .WORD L984     ; link to B/BUF
BSCR:     .WORD DOCON
          .WORD 8        ; blocks to make one screen





;
;                                       +ORIGIN
;                                       SCREEN 35 LINE 12
;
L1000:    .BYTE $87,"+ORIGI",$CE
          .WORD L992     ; link to B/SCR
PORIG:    .WORD DOCOL
          .WORD LIT,ORIG
          .WORD PLUS
          .WORD SEMIS
;
;                                       TIB
;                                       SCREEN 36 LINE 4
;
L1010:    .BYTE $83,"TI",$C2
          .WORD L1000    ; link to +ORIGIN
TIB:      .WORD DOUSE
          .BYTE $A
;
;                                       WIDTH
;                                       SCREEN 36 LINE 5
;
L1018:    .BYTE $85,"WIDT",$C8
          .WORD L1010    ; link to TIB
WIDTH:    .WORD DOUSE
          .BYTE $C
;
;                                       WARNING
;                                       SCREEN 36 LINE 6
;
L1026:    .BYTE $87,"WARNIN",$C7
          .WORD L1018    ; link to WIDTH
WARN:     .WORD DOUSE
          .BYTE $E
;
;                                       FENCE
;                                       SCREEN 36 LINE 7
;
L1034:    .BYTE $85,"FENC",$C5
          .WORD L1026    ; link to WARNING
FENCE:    .WORD DOUSE
          .BYTE $10
;
;
;                                       DP
;                                       SCREEN 36 LINE 8
;
L1042:    .BYTE $82,"D",$D0
          .WORD L1034    ; link to FENCE
DP:       .WORD DOUSE
          .BYTE $12
;
;                                       VOC-LINK
;                                       SCREEN 36 LINE 9
;
L1050:    .BYTE $88,"VOC-LIN",$CB
          .WORD L1042    ; link to DP
VOCL:     .WORD DOUSE
          .BYTE $14
;
;                                       BLK
;                                       SCREEN 36 LINE 10
;
L1058:    .BYTE $83,"BL",$CB
          .WORD L1050    ; link to VOC-LINK
BLK:      .WORD DOUSE
          .BYTE $16
;
;                                       IN
;                                       SCREEN 36 LINE 11
;
L1066:    .BYTE $82,"I",$CE
          .WORD L1058    ; link to BLK
IN:       .WORD DOUSE
          .BYTE $18
;
;                                       OUT
;                                       SCREEN 36 LINE 12
;
L1074:    .BYTE $83,"OU",$D4
          .WORD L1066    ; link to IN
OUT:      .WORD DOUSE
          .BYTE $1A
;
;                                       SCR
;                                       SCREEN 36 LINE 13
;
L1082:    .BYTE $83,"SC",$D2
          .WORD L1074    ; link to OUT
SCR:      .WORD DOUSE
          .BYTE $1C
;
;                                       OFFSET
;                                       SCREEN 37 LINE 1
;
L1090:    .BYTE $86,"OFFSE",$D4
          .WORD L1082    ; link to SCR
OFSET:    .WORD DOUSE
          .BYTE $1E
;
;                                       CONTEXT
;                                       SCREEN 37 LINE 2
;
L1098:    .BYTE $87,"CONTEX",$D4
          .WORD L1090    ; link to OFFSET
CON:      .WORD DOUSE
          .BYTE $20
;
;                                       CURRENT
;                                       SCREEN 37 LINE 3
;
L1106:    .BYTE $87,"CURREN",$D4
          .WORD L1098    ; link to CONTEXT
CURR:     .WORD DOUSE
          .BYTE $22
;
;                                       STATE
;                                       SCREEN 37 LINE 4
;
L1114:    .BYTE $85,"STAT",$C5
          .WORD L1106    ; link to CURRENT
STATE:    .WORD DOUSE
          .BYTE $24
;
;                                       BASE
;                                       SCREEN 37 LINE 5
;
L1122:    .BYTE $84,"BAS",$C5
          .WORD L1114    ; link to STATE
BASE:     .WORD DOUSE
          .BYTE $26
;
;                                       DPL
;                                       SCREEN 37 LINE 6
;
L1130:    .BYTE $83,"DP",$CC
          .WORD L1122    ; link to BASE
DPL:      .WORD DOUSE
          .BYTE $28
;
;                                       FLD
;                                       SCREEN 37 LINE 7
;
L1138:    .BYTE $83,"FL",$C4
          .WORD L1130    ; link to DPL
FLD:      .WORD DOUSE
          .BYTE $2A
;
;
;
;                                       CSP
;                                       SCREEN 37 LINE 8
;
L1146:    .BYTE $83,"CS",$D0
          .WORD L1138    ; link to FLD
CSP:      .WORD DOUSE
          .BYTE $2C
;
;                                       R#
;                                       SCREEN 37  LINE 9
;
L1154:    .BYTE $82,"R",$A3
          .WORD L1146    ; link to CSP
RNUM:     .WORD DOUSE
          .BYTE $2E
;
;                                       HLD
;                                       SCREEN 37 LINE 10
;
L1162:    .BYTE $83,"HL",$C4
          .WORD L1154    ; link to R#
HLD:      .WORD DOUSE
          .BYTE $30
;
;                                       1+
;                                       SCREEN 38 LINE  1
;
L1170:    .BYTE $82,"1",$AB
          .WORD L1162    ; link to HLD
ONEP:     .WORD DOCOL
          .WORD ONE
          .WORD PLUS
          .WORD SEMIS
;
;                                       2+
;                                       SCREEN 38 LINE 2
;
L1180:    .BYTE $82,"2",$AB
          .WORD L1170    ; link to 1+
TWOP:     .WORD DOCOL
          .WORD TWO
          .WORD PLUS
          .WORD SEMIS
;
;                                       HERE
;                                       SCREEN 38 LINE 3
;
L1190:    .BYTE $84,"HER",$C5
          .WORD L1180    ; link to 2+
HERE:     .WORD DOCOL
          .WORD DP
          .WORD AT
          .WORD SEMIS
;
;                                       ALLOT
;                                       SCREEN 38 LINE 4
;
L1200:    .BYTE $85,"ALLO",$D4
          .WORD L1190    ; link to HERE
ALLOT:    .WORD DOCOL
          .WORD DP
          .WORD PSTOR
          .WORD SEMIS
;
;                                       ,
;                                       SCREEN 38 LINE 5
;
L1210:    .BYTE $81,$AC
          .WORD L1200    ; link to ALLOT
COMMA:    .WORD DOCOL
          .WORD HERE
          .WORD STORE
          .WORD TWO
          .WORD ALLOT
          .WORD SEMIS
;
;                                       C,
;                                       SCREEN 38 LINE 6
;
L1222:    .BYTE $82,"C",$AC
          .WORD L1210    ; link to ,
CCOMM:    .WORD DOCOL
          .WORD HERE
          .WORD CSTOR
          .WORD ONE
          .WORD ALLOT
          .WORD SEMIS
;
;                                       -
;                                       SCREEN 38 LINE 7
;
L1234:    .BYTE $81,$AD
          .WORD L1222    ; link to C,
SUB:      .WORD DOCOL
          .WORD MINUS
          .WORD PLUS
          .WORD SEMIS
;
;                                       =
;                                       SCREEN 38 LINE 8
;
L1244:    .BYTE $81,$BD
          .WORD L1234    ; link to -
EQUAL:    .WORD DOCOL
          .WORD SUB
          .WORD ZEQU
          .WORD SEMIS
;
;                                       U<
;                                       Unsigned less than
;
L1246:    .BYTE $82,"U",$BC
          .WORD L1244    ; link to =
ULESS:    .WORD DOCOL
          .WORD SUB      ; subtract two values
          .WORD ZLESS    ; test sign
          .WORD SEMIS
;
;                                       <
;                                       Altered from model
;                                       SCREEN 38 LINE 9
;
L1254:    .BYTE $81,$BC
          .WORD L1246    ; link to U<
LESS:     .WORD *+2
          SEC
          LDA 2,X
          SBC 0,X        ; subtract
          LDA 3,X
          SBC 1,X
          STY 3,X        ; zero high byte
          BVC L1258
          EOR #$80       ; correct overflow
L1258:    BPL L1260
          INY            ; invert boolean
L1260:    STY 2,X        ; leave boolean
          JMP POP
;
;                                       >
;                                       SCREEN 38 LINE 10
L1264:    .BYTE $81,$BE
          .WORD L1254    ; link to <
GREAT:    .WORD DOCOL
          .WORD SWAP
          .WORD LESS
          .WORD SEMIS
;
;                                       ROT
;                                       SCREEN 38 LINE 11
;
L1274:    .BYTE $83,"RO",$D4
          .WORD L1264    ; link to >
ROT:      .WORD DOCOL
          .WORD TOR
          .WORD SWAP
          .WORD RFROM
          .WORD SWAP
          .WORD SEMIS
;
;                                       SPACE
;                                       SCREEN 38 LINE 12
;
L1286:    .BYTE $85,"SPAC",$C5
          .WORD L1274    ; link to ROT
SPACE:    .WORD DOCOL
          .WORD BL
          .WORD EMIT
          .WORD SEMIS
;
;                                       -DUP
;                                       SCREEN 38 LINE 13
;
L1296:    .BYTE $84,"-DU",$D0
          .WORD L1286    ; link to SPACE
DDUP:     .WORD DOCOL
          .WORD DUP
          .WORD ZBRAN
L1301:    .WORD $4       ; L1303-L1301
          .WORD DUP
L1303:    .WORD SEMIS
;
;                                       TRAVERSE
;                                       SCREEN 39 LINE 14
;
L1308:    .BYTE $88,"TRAVERS",$C5
          .WORD L1296    ; link to -DUP
TRAV:     .WORD DOCOL
          .WORD SWAP
L1312:    .WORD OVER
          .WORD PLUS
          .WORD CLIT
          .BYTE $7F
          .WORD OVER
          .WORD CAT
          .WORD LESS
          .WORD ZBRAN
L1320:    .WORD $FFF1    ; L1312-L1320
          .WORD SWAP
          .WORD DROP
          .WORD SEMIS
;
;                                       LATEST
;                                       SCREEN 39 LINE 6
;
L1328:    .BYTE $86,"LATES",$D4
          .WORD L1308    ; link to TRAVERSE
LATES:    .WORD DOCOL
          .WORD CURR
          .WORD AT
          .WORD AT
          .WORD SEMIS
;
;
;                                       LFA
;                                       SCREEN 39 LINE 11
;
L1339:    .BYTE $83,"LF",$C1
          .WORD L1328    ; link to LATEST
LFA:      .WORD DOCOL
          .WORD CLIT
          .BYTE 4
          .WORD SUB
          .WORD SEMIS
;
;                                       CFA
;                                       SCREEN 39 LINE 12
;
L1350:    .BYTE $83,"CF",$C1
          .WORD L1339    ; link to LFA
CFA:      .WORD DOCOL
          .WORD TWO
          .WORD SUB
          .WORD SEMIS
;
;                                       NFA
;                                       SCREEN 39 LIINE 13
;
L1360:    .BYTE $83,"NF",$C1
          .WORD L1350    ; link to CFA
NFA:      .WORD DOCOL
          .WORD CLIT
          .BYTE $5
          .WORD SUB
          .WORD LIT,$FFFF
          .WORD TRAV
          .WORD SEMIS
;
;                                       PFA
;                                       SCREEN 39 LINE 14
;
L1373:    .BYTE $83,"PF",$C1
          .WORD L1360    ; link to NFA
PFA:      .WORD DOCOL
          .WORD ONE
          .WORD TRAV
          .WORD CLIT
          .BYTE 5
          .WORD PLUS
          .WORD SEMIS
;
;                                       !CSP
;                                       SCREEN 40 LINE 1
;
L1386:    .BYTE $84,"!CS",$D0
          .WORD L1373    ; link to PFA
SCSP:     .WORD DOCOL
          .WORD SPAT
          .WORD CSP
          .WORD STORE
          .WORD SEMIS
;
;                                       ?ERROR
;                                       SCREEN 40 LINE 3
;
L1397:    .BYTE $86,"?ERRO",$D2
          .WORD L1386    ; link to !CSP
QERR:     .WORD DOCOL
          .WORD SWAP
          .WORD ZBRAN
L1402:    .WORD 8        ; L1406-L1402
          .WORD ERROR
          .WORD BRAN
L1405:    .WORD 4        ; L1407-L1405
L1406:    .WORD DROP
L1407:    .WORD SEMIS
;
;                                       ?COMP
;                                       SCREEN 40 LINE 6
;
L1412:    .BYTE $85,"?COM",$D0
          .WORD L1397    ; link to ?ERROR
QCOMP:    .WORD DOCOL
          .WORD STATE
          .WORD AT
          .WORD ZEQU
          .WORD CLIT
          .BYTE $11
          .WORD QERR
          .WORD SEMIS
;
;                                       ?EXEC
;                                       SCREEN 40 LINE 8
;
L1426:    .BYTE $85,"?EXE",$C3
          .WORD L1412    ; link to ?COMP
QEXEC:    .WORD DOCOL
          .WORD STATE
          .WORD AT
          .WORD CLIT
          .BYTE $12
          .WORD QERR
          .WORD SEMIS
;
;                                       ?PAIRS
;                                       SCREEN 40 LINE 10
;
L1439:    .BYTE $86,"?PAIR",$D3
          .WORD L1426    ; link to ?EXEC
QPAIR:    .WORD DOCOL
          .WORD SUB
          .WORD CLIT
          .BYTE $13
          .WORD QERR
          .WORD SEMIS
;
;                                       ?CSP
;                                       SCREEN 40 LINE 12
;
L1451:    .BYTE $84,"?CS",$D0
          .WORD L1439    ; link to ?PAIRS
QCSP:     .WORD DOCOL
          .WORD SPAT
          .WORD CSP
          .WORD AT
          .WORD SUB
          .WORD CLIT
          .BYTE $14
          .WORD QERR
          .WORD SEMIS
;
;                                       ?LOADING
;                                       SCREEN 40 LINE 14
;
L1466:    .BYTE $88,"?LOADIN",$C7
          .WORD L1451    ; link to ?CSP
QLOAD:    .WORD DOCOL
          .WORD BLK
          .WORD AT
          .WORD ZEQU
          .WORD CLIT
          .BYTE $16
          .WORD QERR
          .WORD SEMIS
;
;                                       COMPILE
;                                       SCREEN 41 LINE 2
;
L1480:    .BYTE $87,"COMPIL",$C5
          .WORD L1466    ; link to ?LOADING
COMP:     .WORD DOCOL
          .WORD QCOMP
          .WORD RFROM
          .WORD DUP
          .WORD TWOP
          .WORD TOR
          .WORD AT
          .WORD COMMA
          .WORD SEMIS
;
;                                       [
;                                       SCREEN 41 LINE 5
;
L1495:    .BYTE $C1,$DB
          .WORD L1480    ; link to COMPILE
LBRAC:    .WORD DOCOL
          .WORD ZERO
          .WORD STATE
          .WORD STORE
          .WORD SEMIS
;
;                                       ]
;                                       SCREEN 41 LINE 7
;
L1507:    .BYTE $81,$DD
          .WORD L1495    ; link to [
RBRAC:    .WORD DOCOL
          .WORD CLIT
          .BYTE $C0
          .WORD STATE
          .WORD STORE
          .WORD SEMIS
;
;                                       SMUDGE
;                                       SCREEN 41 LINE 9
;
L1519:    .BYTE $86,"SMUDG",$C5
          .WORD L1507    ; link to ]
SMUDG:    .WORD DOCOL
          .WORD LATES
          .WORD CLIT
          .BYTE $20
          .WORD TOGGL
          .WORD SEMIS
;
;                                       HEX
;                                       SCREEN 41 LINE 11
;
L1531:    .BYTE $83,"HE",$D8
          .WORD L1519    ; link to SMUDGE
HEX:      .WORD DOCOL
          .WORD CLIT
          .BYTE 16
          .WORD BASE
          .WORD STORE
          .WORD SEMIS
;
;                                       DECIMAL
;                                       SCREEN 41 LINE 13
;
L1543:    .BYTE $87,"DECIMA",$CC
          .WORD L1531    ; link to HEX
DECIM:    .WORD DOCOL
          .WORD CLIT
          .BYTE 10
          .WORD BASE
          .WORD STORE
          .WORD SEMIS
;
;
;
;                                       (;CODE)
;                                       SCREEN 42 LINE 2
;
L1555:    .BYTE $87,"(;CODE",$A9
          .WORD L1543    ; link to DECIMAL
PSCOD:    .WORD DOCOL
          .WORD RFROM
          .WORD LATES
          .WORD PFA
          .WORD CFA
          .WORD STORE
          .WORD SEMIS
;
;                                       ;CODE
;                                       SCREEN 42 LINE 6
;
L1568:    .BYTE $C5,";COD",$C5
          .WORD L1555    ; link to (;CODE)
          .WORD DOCOL
          .WORD QCSP
          .WORD COMP
          .WORD PSCOD
          .WORD LBRAC
          .WORD SMUDG
          .WORD SEMIS
;
;                                       <BUILDS
;                                       SCREEN 43 LINE 2
;
L1582:    .BYTE $87,"<BUILD",$D3
          .WORD L1568    ; link to ;CODE
BUILD:    .WORD DOCOL
          .WORD ZERO
          .WORD CONST
          .WORD SEMIS
;
;                                       DOES>
;                                       SCREEN 43 LINE 4
;
L1592:    .BYTE $85,"DOES",$BE
          .WORD L1582    ; link to <BUILDS
DOES:     .WORD DOCOL
          .WORD RFROM
          .WORD LATES
          .WORD PFA
          .WORD STORE
          .WORD PSCOD
;
DODOE:    LDA IP+1
          PHA
          LDA IP
          PHA
          LDY #2
          LDA (W),Y
          STA IP
          INY
          LDA (W),Y
          STA IP+1
          CLC
          LDA W
          ADC #4
          PHA
          LDA W+1
          ADC #0
          JMP PUSH
;
;                                       COUNT
;                                       SCREEN 44 LINE 1
;
L1622:    .BYTE $85,"COUN",$D4
          .WORD L1592    ; link to DOES>
COUNT:    .WORD DOCOL
          .WORD DUP
          .WORD ONEP
          .WORD SWAP
          .WORD CAT
          .WORD SEMIS
;
;                                       TYPE
;                                       SCREEN 44 LINE 2
;
L1634:    .BYTE $84,"TYP",$C5
          .WORD L1622    ; link to COUNT
TYPE:     .WORD DOCOL
          .WORD DDUP
          .WORD ZBRAN
L1639:    .WORD $18      ; L1651-L1639
          .WORD OVER
          .WORD PLUS
          .WORD SWAP
          .WORD PDO
L1644:    .WORD I
          .WORD CAT
          .WORD EMIT
          .WORD PLOOP
L1648:    .WORD $FFF8    ; L1644-L1648
          .WORD BRAN
L1650:    .WORD $4       ; L1652-L1650
L1651:    .WORD DROP
L1652:    .WORD SEMIS
;
;                                       -TRAILING
;                                       SCREEN 44 LINE 5
;
L1657:    .BYTE $89,"-TRAILIN",$C7
          .WORD L1634    ; link to TYPE
DTRAI:    .WORD DOCOL
          .WORD DUP
          .WORD ZERO
          .WORD PDO
L1663:    .WORD OVER
          .WORD OVER
          .WORD PLUS
          .WORD ONE
          .WORD SUB
          .WORD CAT
          .WORD BL
          .WORD SUB
          .WORD ZBRAN
L1672:    .WORD 8        ; L1676-L1672
          .WORD LEAVE
          .WORD BRAN
L1675:    .WORD 6        ; L1678-L1675
L1676:    .WORD ONE
          .WORD SUB
L1678:    .WORD PLOOP
L1679:    .WORD $FFE0    ; L1663-L1679
          .WORD SEMIS
;
;                                       (.")
;                                       SCREEN 44 LINE 8
L1685:    .BYTE $84,"(.",$22,$A9
          .WORD L1657    ; link to -TRAILING
PDOTQ:    .WORD DOCOL
          .WORD R
          .WORD COUNT
          .WORD DUP
          .WORD ONEP
          .WORD RFROM
          .WORD PLUS
          .WORD TOR
          .WORD TYPE
          .WORD SEMIS
;
;                                       ."
;                                       SCREEN 44 LINE12
;
L1701:    .BYTE $C2,".",$A2
          .WORD L1685    ; link to PDOTQ
          .WORD DOCOL
          .WORD CLIT
          .BYTE $22
          .WORD STATE
          .WORD AT
          .WORD ZBRAN
L1709:    .WORD $14      ;L1719-L1709
          .WORD COMP
          .WORD PDOTQ
          .WORD WORD
          .WORD HERE
          .WORD CAT
          .WORD ONEP
          .WORD ALLOT
          .WORD BRAN
L1718:    .WORD $A       ;L1723-L1718
L1719:    .WORD WORD
          .WORD HERE
          .WORD COUNT
          .WORD TYPE
L1723:    .WORD SEMIS
;
;                                       EXPECT
;                                       SCREEN 45 LINE 2
;
L1729:    .BYTE $86,"EXPEC",$D4
          .WORD L1701    ; link to ."
EXPEC:    .WORD DOCOL
          .WORD OVER
          .WORD PLUS
          .WORD OVER
          .WORD PDO
L1736:    .WORD KEY
          .WORD DUP
          .WORD CLIT
          .BYTE $E
          .WORD PORIG
          .WORD AT
          .WORD EQUAL
          .WORD ZBRAN
L1744:    .WORD $1F       ; L1760-L1744
          .WORD DROP
          .WORD CLIT
          .BYTE 08
          .WORD OVER
          .WORD I
          .WORD EQUAL
          .WORD DUP
          .WORD RFROM
          .WORD TWO
          .WORD SUB
          .WORD PLUS
          .WORD TOR
          .WORD SUB
          .WORD BRAN
L1759:    .WORD $27       ; L1779-L1759
L1760:    .WORD DUP
          .WORD CLIT
          .BYTE $0D
          .WORD EQUAL
          .WORD ZBRAN
L1765:    .WORD $0E       ; L1772-L1765
          .WORD LEAVE
          .WORD DROP
          .WORD BL
          .WORD ZERO
          .WORD BRAN
L1771:    .WORD 04        ; L1773-L1771
L1772:    .WORD DUP
L1773:    .WORD I
          .WORD CSTOR
          .WORD ZERO
          .WORD I
          .WORD ONEP
          .WORD STORE
L1779:    .WORD EMIT
          .WORD PLOOP
L1781:    .WORD $FFA9
          .WORD DROP      ; L1736-L1781
          .WORD SEMIS
;
;                                       QUERY
;                                       SCREEN 45 LINE 9
;
L1788:    .BYTE $85,"QUER",$D9
          .WORD L1729    ; link to EXPECT
QUERY:    .WORD DOCOL
          .WORD TIB
          .WORD AT
          .WORD CLIT
          .BYTE 80       ; 80 characters from terminal
          .WORD EXPEC
          .WORD ZERO
          .WORD IN
          .WORD STORE
          .WORD SEMIS
;
;                                       X
;                                       SCREEN 45 LINE 11
;                                       Actually Ascii Null
;
L1804:    .BYTE $C1,$80
          .WORD L1788    ; link to QUERY
          .WORD DOCOL
          .WORD BLK
          .WORD AT
          .WORD ZBRAN
L1810:    .WORD $2A      ; L1830-l1810
          .WORD ONE
          .WORD BLK
          .WORD PSTOR
          .WORD ZERO
          .WORD IN
          .WORD STORE
          .WORD BLK
          .WORD AT
          .WORD ZERO,BSCR
          .WORD USLAS
          .WORD DROP     ; fixed from model
          .WORD ZEQU
          .WORD ZBRAN
L1824:    .WORD 8        ; L1828-L1824
          .WORD QEXEC
          .WORD RFROM
          .WORD DROP
L1828:    .WORD BRAN
L1829:    .WORD 6        ; L1832-L1829
L1830:    .WORD RFROM
          .WORD DROP
L1832:    .WORD SEMIS
;
;                                       FILL
;                                       SCREEN 46 LINE 1
;
;
L1838:    .BYTE $84,"FIL",$CC
          .WORD L1804    ; link to X
FILL:     .WORD DOCOL
          .WORD SWAP
          .WORD TOR
          .WORD OVER
          .WORD CSTOR
          .WORD DUP
          .WORD ONEP
          .WORD RFROM
          .WORD ONE
          .WORD SUB
          .WORD CMOVE
          .WORD SEMIS
;
;                                       ERASE
;                                       SCREEN 46 LINE 4
;
L1856:    .BYTE $85,"ERAS",$C5
          .WORD L1838    ; link to FILL
ERASE:    .WORD DOCOL
          .WORD ZERO
          .WORD FILL
          .WORD SEMIS
;
;                                       BLANKS
;                                       SCREEN 46 LINE 7
;
L1866:    .BYTE $86,"BLANK",$D3
          .WORD L1856    ; link to ERASE
BLANK:    .WORD DOCOL
          .WORD BL
          .WORD FILL
          .WORD SEMIS
;
;                                       HOLD
;                                       SCREEN 46 LINE 10
;
L1876:    .BYTE $84,"HOL",$C4
          .WORD L1866    ; link to BLANKS
HOLD:     .WORD DOCOL
          .WORD LIT,$FFFF
          .WORD HLD
          .WORD PSTOR
          .WORD HLD
          .WORD AT
          .WORD CSTOR
          .WORD SEMIS
;
;                                       PAD
;                                       SCREEN 46 LINE 13
;
L1890:    .BYTE $83,"PA",$C4
          .WORD L1876    ; link to HOLD
PAD:      .WORD DOCOL
          .WORD HERE
          .WORD CLIT
          .BYTE 68       ; PAD is 68 bytes above here.
          .WORD PLUS
          .WORD SEMIS
;
;                                       WORD
;                                       SCREEN 47 LINE 1
;
L1902:    .BYTE $84,"WOR",$C4
          .WORD L1890    ; link to PAD
WORD:     .WORD DOCOL
          .WORD BLK
          .WORD AT
          .WORD ZBRAN
L1908:    .WORD $C       ; L1914-L1908
          .WORD BLK
          .WORD AT
          .WORD BLOCK
          .WORD BRAN
L1913:    .WORD $6       ; L1916-L1913
L1914:    .WORD TIB
          .WORD AT
L1916:    .WORD IN
          .WORD AT
          .WORD PLUS
          .WORD SWAP
          .WORD ENCL
          .WORD HERE
          .WORD CLIT
          .BYTE $22
          .WORD BLANK
          .WORD IN
          .WORD PSTOR
          .WORD OVER
          .WORD SUB
          .WORD TOR
          .WORD R
          .WORD HERE
          .WORD CSTOR
          .WORD PLUS
          .WORD HERE
          .WORD ONEP
          .WORD RFROM
          .WORD CMOVE
          .WORD SEMIS
;
;                                       UPPER
;                                       SCREEN 47 LINE 12
;
L1943:    .BYTE $85,"UPPE",$D2
          .WORD L1902    ; link to WORD
UPPER:    .WORD DOCOL
          .WORD OVER     ; This routine converts text to U case
          .WORD PLUS     ; It allows interpretation from a term.
          .WORD SWAP     ; without a shift-lock.
          .WORD PDO
L1950:    .WORD I
          .WORD CAT
          .WORD CLIT
          .BYTE $5F
          .WORD GREAT
          .WORD ZBRAN
L1956:    .WORD 09       ; L1961-L1956
          .WORD I
          .WORD CLIT
          .BYTE $20
          .WORD TOGGL
L1961:    .WORD PLOOP
L1962:    .WORD $FFEA    ; L1950-L1962
          .WORD SEMIS
;
;                                       (NUMBER)
;                                       SCREEN 48 LINE 1
;
L1968:    .BYTE $88,"(NUMBER",$A9
          .WORD L1943    ; link to UPPER
PNUMB:    .WORD DOCOL
L1971:    .WORD ONEP
          .WORD DUP
          .WORD TOR
          .WORD CAT
          .WORD BASE
          .WORD AT
          .WORD DIGIT
          .WORD ZBRAN
L1979:    .WORD $2C      ; L2001-L1979
          .WORD SWAP
          .WORD BASE
          .WORD AT
          .WORD USTAR
          .WORD DROP
          .WORD ROT
          .WORD BASE
          .WORD AT
          .WORD USTAR
          .WORD DPLUS
          .WORD DPL
          .WORD AT
          .WORD ONEP
          .WORD ZBRAN
L1994:    .WORD 8        ; L1998-L1994
          .WORD ONE
          .WORD DPL
          .WORD PSTOR
L1998:    .WORD RFROM
          .WORD BRAN
L2000:    .WORD $FFC6    ; L1971-L2000
L2001:    .WORD RFROM
          .WORD SEMIS
;
;                                       NUMBER
;                                       SCREEN 48 LINE 6
;
L2007:    .BYTE $86,"NUMBE",$D2
          .WORD L1968    ; link to (NUMBER)
NUMBER:   .WORD DOCOL
          .WORD ZERO
          .WORD ZERO
          .WORD ROT
          .WORD DUP
          .WORD ONEP
          .WORD CAT
          .WORD CLIT
          .BYTE $2D
          .WORD EQUAL
          .WORD DUP
          .WORD TOR
          .WORD PLUS
          .WORD LIT,$FFFF
L2023:    .WORD DPL
          .WORD STORE
          .WORD PNUMB
          .WORD DUP
          .WORD CAT
          .WORD BL
          .WORD SUB
          .WORD ZBRAN
L2031:    .WORD $15      ; L2042-L2031
          .WORD DUP
          .WORD CAT
          .WORD CLIT
          .BYTE $2E
          .WORD SUB
          .WORD ZERO
          .WORD QERR
          .WORD ZERO
          .WORD BRAN
L2041:    .WORD $FFDD    ; L2023-L2041
L2042:    .WORD DROP
          .WORD RFROM
          .WORD ZBRAN
L2045:    .WORD 4        ; L2047-L2045
          .WORD DMINU
L2047:    .WORD SEMIS
;
;                                       -FIND
;                                       SCREEN 48 LINE 12
;
L2052:    .BYTE $85,"-FIN",$C4
          .WORD L2007    ; link to NUMBER
DFIND:    .WORD DOCOL
          .WORD BL
          .WORD WORD
          .WORD HERE     ; )
          .WORD COUNT    ; |- Optional allowing free use of low
          .WORD UPPER    ; )  case from terminal
          .WORD HERE
          .WORD CON
          .WORD AT
          .WORD AT
          .WORD PFIND
          .WORD DUP
          .WORD ZEQU
          .WORD ZBRAN
L2068:    .WORD $A       ; L2073-L2068
          .WORD DROP
          .WORD HERE
          .WORD LATES
          .WORD PFIND
L2073:    .WORD SEMIS
;
;                                       (ABORT)
;                                       SCREEN 49 LINE 2
;
L2078:    .BYTE $87,"(ABORT",$A9
          .WORD L2052    ; link to -FIND
PABOR:    .WORD DOCOL
          .WORD ABORT
          .WORD SEMIS
;
;                                       ERROR
;                                       SCREEN 49 LINE 4
;
L2087:    .BYTE $85,"ERRO",$D2
          .WORD L2078    ; link to (ABORT)
ERROR:    .WORD DOCOL
          .WORD WARN
          .WORD AT
          .WORD ZLESS
          .WORD ZBRAN
L2094:    .WORD $4       ; L2096-L2094
          .WORD PABOR
L2096:    .WORD HERE
          .WORD COUNT
          .WORD TYPE
          .WORD PDOTQ
          .BYTE 4,"  ? "
          .WORD MESS
          .WORD SPSTO
          .WORD DROP,DROP; make room for 2 error values
          .WORD IN
          .WORD AT
          .WORD BLK
          .WORD AT
          .WORD QUIT
          .WORD SEMIS
;
;                                       ID.
;                                       SCREEN 49 LINE 9
;
L2113:    .BYTE $83,"ID",$AE
          .WORD L2087    ; link to ERROR
IDDOT:    .WORD DOCOL
          .WORD PAD
          .WORD CLIT
          .BYTE $20
          .WORD CLIT
          .BYTE $5F
          .WORD FILL
          .WORD DUP
          .WORD PFA
          .WORD LFA
          .WORD OVER
          .WORD SUB
          .WORD PAD
          .WORD SWAP
          .WORD CMOVE
          .WORD PAD
          .WORD COUNT
          .WORD CLIT
          .BYTE $1F
          .WORD ANDD
          .WORD TYPE
          .WORD SPACE
          .WORD SEMIS
;
;                                       CREATE
;                                       SCREEN 50 LINE 2
;
L2142:    .BYTE $86,"CREAT",$C5
          .WORD L2113    ; link to ID
CREAT:    .WORD DOCOL
          .WORD TIB      ;)
          .WORD HERE     ;|
          .WORD CLIT     ;|  6502 only, assures
          .BYTE $A0      ;|  room exists in dict.
          .WORD PLUS     ;|
          .WORD ULESS    ;|
          .WORD TWO      ;|
          .WORD QERR     ;)
          .WORD DFIND
          .WORD ZBRAN
L2155:    .WORD $0F
          .WORD DROP
          .WORD NFA
          .WORD IDDOT
          .WORD CLIT
          .BYTE 4
          .WORD MESS
          .WORD SPACE
L2163:    .WORD HERE
          .WORD DUP
          .WORD CAT
          .WORD WIDTH
          .WORD AT
          .WORD MIN
          .WORD ONEP
          .WORD ALLOT
          .WORD DP       ;)
          .WORD CAT      ;| 6502 only. The code field
          .WORD CLIT     ;| must not straddle page
          .BYTE $FD      ;| boundaries
          .WORD EQUAL    ;|
          .WORD ALLOT    ;)
          .WORD DUP
          .WORD CLIT
          .BYTE $A0
          .WORD TOGGL
          .WORD HERE
          .WORD ONE
          .WORD SUB
          .WORD CLIT
          .BYTE $80
          .WORD TOGGL
          .WORD LATES
          .WORD COMMA
          .WORD CURR
          .WORD AT
          .WORD STORE
          .WORD HERE
          .WORD TWOP
          .WORD COMMA
          .WORD SEMIS
;
;                                       [COMPILE]
;                                       SCREEN 51 LINE 2
;
L2200:    .BYTE $C9,"[COMPILE",$DD
          .WORD L2142    ; link to CREATE
          .WORD DOCOL
          .WORD DFIND
          .WORD ZEQU
          .WORD ZERO
          .WORD QERR
          .WORD DROP
          .WORD CFA
          .WORD COMMA
          .WORD SEMIS
;
;                                       LITERAL
;                                       SCREEN 51 LINE 2
;
L2216:    .BYTE $C7,"LITERA",$CC
          .WORD L2200    ; link to [COMPILE]
LITER:    .WORD DOCOL
          .WORD STATE
          .WORD AT
          .WORD ZBRAN
L2222:    .WORD 8        ; L2226-L2222
          .WORD COMP
          .WORD LIT
          .WORD COMMA
L2226:    .WORD SEMIS
;
;                                       DLITERAL
;                                       SCREEN 51 LINE 8
;
L2232:    .BYTE $C8,"DLITERA",$CC
          .WORD L2216    ; link to LITERAL
DLIT:     .WORD DOCOL
          .WORD STATE
          .WORD AT
          .WORD ZBRAN
L2238:    .WORD 8        ; L2242-L2238
          .WORD SWAP
          .WORD LITER
          .WORD LITER
L2242:    .WORD SEMIS
;
;                                       ?STACK
;                                       SCREEN 51 LINE 13
;
L2248:    .BYTE $86,"?STAC",$CB
          .WORD L2232    ; link to DLITERAL
QSTAC:    .WORD DOCOL
          .WORD CLIT
          .BYTE TOS
          .WORD SPAT
          .WORD ULESS
          .WORD ONE
          .WORD QERR
          .WORD SPAT
          .WORD CLIT
          .BYTE BOS
          .WORD ULESS
          .WORD CLIT
          .BYTE 7
          .WORD QERR
          .WORD SEMIS
;
;                                       INTERPRET
;                                       SCREEN 52 LINE 2
;
L2269:    .BYTE $89,"INTERPRE",$D4
          .WORD L2248    ; link to ?STACK
INTER:    .WORD DOCOL
L2272:    .WORD DFIND
          .WORD ZBRAN
L2274:    .WORD $1E      ; L2289-L2274
          .WORD STATE
          .WORD AT
          .WORD LESS
          .WORD ZBRAN
L2279:    .WORD $A       ; L2284-L2279
          .WORD CFA
          .WORD COMMA
          .WORD BRAN
L2283:    .WORD $6       ; L2286-L2283
L2284:    .WORD CFA
          .WORD EXEC
L2286:    .WORD QSTAC
          .WORD BRAN
L2288:    .WORD $1C      ; L2302-L2288
L2289:    .WORD HERE
          .WORD NUMBER
          .WORD DPL
          .WORD AT
          .WORD ONEP
          .WORD ZBRAN
L2295:    .WORD 8        ; L2299-L2295
          .WORD DLIT
          .WORD BRAN
L2298:    .WORD $6       ; L2301-L2298
L2299:    .WORD DROP
          .WORD LITER
L2301:    .WORD QSTAC
L2302:    .WORD BRAN
L2303:    .WORD $FFC2    ; L2272-L2303
;
;                                       IMMEDIATE
;                                       SCREEN 53 LINE 1
;
L2309:    .BYTE $89,"IMMEDIAT",$C5
          .WORD L2269;   ; link to INTERPRET
          .WORD DOCOL
          .WORD LATES
          .WORD CLIT
          .BYTE $40
          .WORD TOGGL
          .WORD SEMIS
;
;                                       VOCABULARY
;                                       SCREEN 53 LINE 4
;
L2321:    .BYTE $8A,"VOCABULAR",$D9
          .WORD L2309    ; link to IMMEDIATE
          .WORD DOCOL
          .WORD BUILD
          .WORD LIT,$A081
          .WORD COMMA
          .WORD CURR
          .WORD AT
          .WORD CFA
          .WORD COMMA
          .WORD HERE
          .WORD VOCL
          .WORD AT
          .WORD COMMA
          .WORD VOCL
          .WORD STORE
          .WORD DOES
DOVOC:    .WORD TWOP
          .WORD CON
          .WORD STORE
          .WORD SEMIS
;
;                                       FORTH
;                                       SCREEN 53 LINE 9
;
L2346:    .BYTE $C5,"FORT",$C8
          .WORD L2321    ; link to VOCABULARY
FORTH:    .WORD DODOE
          .WORD DOVOC
          .WORD $A081
XFOR:     .WORD NTOP     ; points to top name in FORTH
VL0:      .WORD 0        ; last vocab link ends at zero
;
;                                       DEFINITIONS
;                                       SCREEN 53 LINE 11
;
;
L2357:    .BYTE $8B,"DEFINITION",$D3
          .WORD L2346    ; link to FORTH
DEFIN:    .WORD DOCOL
          .WORD CON
          .WORD AT
          .WORD CURR
          .WORD STORE
          .WORD SEMIS
;
;                                       (
;                                       SCREEN 53 LINE 14
;
L2369:    .BYTE $C1,$A8
          .WORD L2357    ; link to DEFINITIONS
          .WORD DOCOL
          .WORD CLIT
          .BYTE $29
          .WORD WORD
          .WORD SEMIS
;
;                                       QUIT
;                                       SCREEN 54 LINE 2
;
L2381:    .BYTE $84,"QUI",$D4
          .WORD L2369    ; link to (
QUIT:     .WORD DOCOL
          .WORD ZERO
          .WORD BLK
          .WORD STORE
          .WORD LBRAC
L2388:    .WORD RPSTO
          .WORD CR
          .WORD QUERY
          .WORD INTER
          .WORD STATE
          .WORD AT
          .WORD ZEQU
          .WORD ZBRAN
L2396:    .WORD 7        ; L2399-L2396
          .WORD PDOTQ
          .BYTE 2,"OK"
L2399:    .WORD BRAN
L2400:    .WORD $FFE7    ; L2388-L2400
          .WORD SEMIS
;
;                                       ABORT
;                                       SCREEN 54 LINE 7
;
L2406:    .BYTE $85,"ABOR",$D4
          .WORD L2381    ; link to QUIT
ABORT:    .WORD DOCOL
          .WORD SPSTO
          .WORD DECIM
          .WORD DR0
          .WORD CR
          .WORD PDOTQ
          .BYTE 14,"fig-FORTH  1.0"
          .WORD FORTH
          .WORD DEFIN
          .WORD QUIT
;
;                                       COLD
;                                       SCREEN 55 LINE 1
;
L2423:    .BYTE $84,"COL",$C4
          .WORD L2406    ; link to ABORT
COLD:     .WORD *+2
          LDA ORIG+$0C   ; from cold start area
          STA FORTH+6
          LDA ORIG+$0D
          STA FORTH+7
          LDY #$15
          BNE L2433
WARM:     LDY #$0F
L2433:    LDA ORIG+$10
          STA UP
          LDA ORIG+$11
          STA UP+1
L2437:    LDA ORIG+$0C,Y
          STA (UP),Y
          DEY
          BPL  L2437
          LDA #>ABORT    ; actually #>(ABORT+2)
          STA IP+1
          LDA #<ABORT+2
          STA IP
          CLD
          LDA #$6C
          STA W-1
          JMP RPSTO+2    ; And off we go !
;
;                                       S->D
;                                       SCREEN 56 LINE 1
;
L2453:    .BYTE $84,"S->",$C4
          .WORD L2423    ; link to COLD
STOD:     .WORD DOCOL
          .WORD DUP
          .WORD ZLESS
          .WORD MINUS
          .WORD SEMIS
;
;                                       +-
;                                       SCREEN 56 LINE 4
;
L2464:    .BYTE $82,"+",$AD
          .WORD L2453    ; link to S->D
PM:       .WORD DOCOL
          .WORD ZLESS
          .WORD ZBRAN
L2469:    .WORD 4
          .WORD MINUS
L2471:    .WORD SEMIS
;
;                                       D+-
;                                       SCREEN 56 LINE 6
;
L2476:    .BYTE $83,"D+",$AD
          .WORD L2464    ; link to +-
DPM:      .WORD DOCOL
          .WORD ZLESS
          .WORD ZBRAN
L2481:    .WORD 4        ; L2483-L2481
          .WORD DMINU
L2483:    .WORD SEMIS
;
;                                       ABS
;                                       SCREEN 56 LINE 9
;
L2488:    .BYTE $83,"AB",$D3
          .WORD L2476    ; link to D+-
ABS:      .WORD DOCOL
          .WORD DUP
          .WORD PM
          .WORD SEMIS
;
;                                       DABS
;                                       SCREEN 56 LINE 10
;
L2498:    .BYTE $84,"DAB",$D3
          .WORD L2488    ; link to ABS
DABS:     .WORD DOCOL
          .WORD DUP
          .WORD DPM
          .WORD SEMIS
;
;                                       MIN
;                                       SCREEN 56 LINE 12
;
L2508:    .BYTE $83,"MI",$CE
          .WORD L2498    ; link to DABS
MIN:      .WORD DOCOL
          .WORD OVER
          .WORD OVER
          .WORD GREAT
          .WORD ZBRAN
L2515:    .WORD 4        ; L2517-L2515
          .WORD SWAP
L2517:    .WORD DROP
          .WORD SEMIS
;
;                                       MAX
;                                       SCREEN 56 LINE 14
;
L2523:    .BYTE $83,"MA",$D8
          .WORD L2508     ; link to MIN
MAX:      .WORD DOCOL
          .WORD OVER
          .WORD OVER
          .WORD LESS
          .WORD ZBRAN
L2530:    .WORD 4        ; L2532-L2530
          .WORD SWAP
L2532:    .WORD DROP
          .WORD SEMIS
;
;                                       M*
;                                       SCREEN 57 LINE 1
;
L2538:    .BYTE $82,"M",$AA
          .WORD L2523    ; link to MAX
MSTAR:    .WORD DOCOL
          .WORD OVER
          .WORD OVER
          .WORD XOR
          .WORD TOR
          .WORD ABS
          .WORD SWAP
          .WORD ABS
          .WORD USTAR
          .WORD RFROM
          .WORD DPM
          .WORD SEMIS
;
;                                       M/
;                                       SCREEN 57 LINE 3
;
L2556:    .BYTE $82,"M",$AF
          .WORD L2538    ; link to M*
MSLAS:    .WORD DOCOL
          .WORD OVER
          .WORD TOR
          .WORD TOR
          .WORD DABS
          .WORD R
          .WORD ABS
          .WORD USLAS
          .WORD RFROM
          .WORD R
          .WORD XOR
          .WORD PM
          .WORD SWAP
          .WORD RFROM
          .WORD PM
          .WORD SWAP
          .WORD SEMIS
;
;                                       *
;                                       SCREEN 57 LINE 7
;
L2579:    .BYTE $81,$AA
          .WORD L2556    ; link to M/
STAR:     .WORD DOCOL
          .WORD USTAR
          .WORD DROP
          .WORD SEMIS
;
;                                       /MOD
;                                       SCREEN 57 LINE 8
;
L2589:    .BYTE $84,"/MO",$C4
          .WORD L2579    ; link to *
SLMOD:    .WORD DOCOL
          .WORD TOR
          .WORD STOD
          .WORD RFROM
          .WORD MSLAS
          .WORD SEMIS
;
;                                       /
;                                       SCREEN 57 LINE 9
;
L2601:    .BYTE $81,$AF
          .WORD L2589    ; link to /MOD
SLASH:    .WORD DOCOL
          .WORD SLMOD
          .WORD SWAP
          .WORD DROP
          .WORD SEMIS
;
;                                       MOD
;                                       SCREEN 57 LINE 10
;
L2612:    .BYTE $83,"MO",$C4
          .WORD L2601    ; link to /
MOD:      .WORD DOCOL
          .WORD SLMOD
          .WORD DROP
          .WORD SEMIS
;
;                                       */MOD
;                                       SCREEN 57 LINE 11
;
L2622:    .BYTE $85,"*/MO",$C4
          .WORD L2612    ; link to MOD
SSMOD:    .WORD DOCOL
          .WORD TOR
          .WORD MSTAR
          .WORD RFROM
          .WORD MSLAS
          .WORD SEMIS
;
;                                       */
;                                       SCREEN 57 LINE 13
;
L2634:    .BYTE $82,"*",$AF
          .WORD L2622    ; link to */MOD
SSLAS:    .WORD DOCOL
          .WORD SSMOD
          .WORD SWAP
          .WORD DROP
          .WORD SEMIS
;
;                                       M/MOD
;                                       SCREEN 57 LINE 14
;
L2645:    .BYTE $85,"M/MO",$C4
          .WORD L2634    ; link to */
MSMOD:    .WORD DOCOL
          .WORD TOR
          .WORD ZERO
          .WORD R
          .WORD USLAS
          .WORD RFROM
          .WORD SWAP
          .WORD TOR
          .WORD USLAS
          .WORD RFROM
          .WORD SEMIS
;
;                                       USE
;                                       SCREEN 58 LINE 1
;
L2662:    .BYTE $83,"US",$C5
          .WORD L2645    ; link to M/MOD
USE:      .WORD DOVAR
          .WORD DAREA
;
;                                       PREV
;                                       SCREEN 58 LINE 2
;
L2670:    .BYTE $84,"PRE",$D6
          .WORD L2662    ; link to USE
PREV:     .WORD DOVAR
          .WORD DAREA
;
;                                       +BUF
;                                       SCREEN 58 LINE 4
;
;
L2678:    .BYTE $84,"+BU",$C6
          .WORD L2670    ; link to PREV
PBUF:     .WORD DOCOL
          .WORD LIT
          .WORD SSIZE+4  ; hold block #, one sector two num
          .WORD PLUS
          .WORD DUP
          .WORD LIMIT
          .WORD EQUAL
          .WORD ZBRAN
L2688:    .WORD 6        ; L2691-L2688
          .WORD DROP
          .WORD FIRST
L2691:    .WORD DUP
          .WORD PREV
          .WORD AT
          .WORD SUB
          .WORD SEMIS
;
;                                       UPDATE
;                                       SCREEN 58 LINE 8
;
L2700:    .BYTE $86,"UPDAT",$C5
          .WORD L2678    ; link to +BUF
UPDAT:    .WORD DOCOL
          .WORD PREV
          .WORD AT
          .WORD AT
          .WORD LIT,$8000
          .WORD OR
          .WORD PREV
          .WORD AT
          .WORD STORE
          .WORD SEMIS
;
;                                       FLUSH
;
L2705:    .BYTE $85,"FLUS",$C8
          .WORD L2700    ; link to UPDATE
          .WORD DOCOL
          .WORD LIMIT,FIRST,SUB
          .WORD BBUF,CLIT
          .BYTE 4
          .WORD PLUS,SLASH,ONEP
          .WORD ZERO,PDO
L2835:    .WORD LIT,$7FFF,BUFFR
          .WORD DROP,PLOOP
L2839:    .WORD $FFF6    ; L2835-L2839
          .WORD SEMIS
;
;                                       EMPTY-BUFFERS
;                                       SCREEN 58 LINE 11
;
L2716:    .BYTE $8D,"EMPTY-BUFFER",$D3
          .WORD L2705    ; link to FLUSH
          .WORD DOCOL
          .WORD FIRST
          .WORD LIMIT
          .WORD OVER
          .WORD SUB
          .WORD ERASE
          .WORD SEMIS
;
;                                       DR0
;                                       SCREEN 58 LINE 14
;
L2729:    .BYTE $83,"DR",$B0
          .WORD L2716    ; link to EMPTY-BUFFERS
DR0:      .WORD DOCOL
          .WORD ZERO
          .WORD OFSET
          .WORD STORE
          .WORD SEMIS
;
;                                       DR1
;                                       SCREEN 58 LINE 15
;
L2740:    .BYTE $83,"DR",$B1
          .WORD L2729    ; link to DR0
          .WORD DOCOL
          .WORD LIT,SECTR ; sectors per drive
          .WORD OFSET
          .WORD STORE
          .WORD SEMIS
;
;                                       BUFFER
;                                       SCREEN 59 LINE 1
;
L2751:    .BYTE $86,"BUFFE",$D2
          .WORD L2740    ; link to DR1
BUFFR:    .WORD DOCOL
          .WORD USE
          .WORD AT
          .WORD DUP
          .WORD TOR
L2758:    .WORD PBUF
          .WORD ZBRAN
L2760:    .WORD $FFFC    ; L2758-L2760
          .WORD USE
          .WORD STORE
          .WORD R
          .WORD AT
          .WORD ZLESS
          .WORD ZBRAN
L2767:    .WORD $14      ; L2776-L2767
          .WORD R
          .WORD TWOP
          .WORD R
          .WORD AT
          .WORD LIT,$7FFF
          .WORD ANDD
          .WORD ZERO
          .WORD RSLW
L2776:    .WORD R
          .WORD STORE
          .WORD R
          .WORD PREV
          .WORD STORE
          .WORD RFROM
          .WORD TWOP
          .WORD SEMIS
;
;                                       BLOCK
;                                       SCREEN 60 LINE 1
;
L2788:    .BYTE $85,"BLOC",$CB
          .WORD L2751    ; link to BUFFER
BLOCK:    .WORD DOCOL
          .WORD OFSET
          .WORD AT
          .WORD PLUS
          .WORD TOR
          .WORD PREV
          .WORD AT
          .WORD DUP
          .WORD AT
          .WORD R
          .WORD SUB
          .WORD DUP
          .WORD PLUS
          .WORD ZBRAN
L2804:    .WORD $34      ; L2830-L2804
L2805:    .WORD PBUF
          .WORD ZEQU
          .WORD ZBRAN
L2808:    .WORD $14      ; L2818-L2808
          .WORD DROP
          .WORD R
          .WORD BUFFR
          .WORD DUP
          .WORD R
          .WORD ONE
          .WORD RSLW
          .WORD TWO
          .WORD SUB
L2818:    .WORD DUP
          .WORD AT
          .WORD R
          .WORD SUB
          .WORD DUP
          .WORD PLUS
          .WORD ZEQU
          .WORD ZBRAN
L2826:    .WORD $FFD6    ; L2805-L2826
          .WORD DUP
          .WORD PREV
          .WORD STORE
L2830:    .WORD RFROM
          .WORD DROP
          .WORD TWOP
          .WORD SEMIS    ; end of BLOCK
;
;
;                                       (LINE)
;                                       SCREEN 61 LINE 2
;
L2838:    .BYTE $86,"(LINE",$A9
          .WORD L2788    ; link to BLOCK
PLINE:    .WORD DOCOL
          .WORD TOR
          .WORD CSLL
          .WORD BBUF
          .WORD SSMOD
          .WORD RFROM
          .WORD BSCR
          .WORD STAR
          .WORD PLUS
          .WORD BLOCK
          .WORD PLUS
          .WORD CSLL
          .WORD SEMIS
;
;                                       .LINE
;                                       SCREEN 61 LINE 6
;
L2857:    .BYTE $85,".LIN",$C5
          .WORD L2838    ; link to (LINE)
DLINE:    .WORD DOCOL
          .WORD PLINE
          .WORD DTRAI
          .WORD TYPE
          .WORD SEMIS
;
;                                       MESSAGE
;                                       SCREEN 61 LINE 9
;
L2868:    .BYTE $87,"MESSAG",$C5
          .WORD L2857    ; link to .LINE
MESS:     .WORD DOCOL
          .WORD WARN
          .WORD AT
          .WORD ZBRAN
L2874:    .WORD $1B      ; L2888-L2874
          .WORD DDUP
          .WORD ZBRAN
L2877:    .WORD $11      ; L2886-L2877
          .WORD CLIT
          .BYTE 4
          .WORD OFSET
          .WORD AT
          .WORD BSCR
          .WORD SLASH
          .WORD SUB
          .WORD DLINE
L2886:    .WORD BRAN
L2887:    .WORD 13       ; L2891-L2887
L2888:    .WORD PDOTQ
          .BYTE 6,"MSG # "
          .WORD DOT
L2891:    .WORD SEMIS
;
;                                       LOAD
;                                       SCREEN 62 LINE 2
;
L2896:    .BYTE $84,"LOA",$C4
          .WORD L2868    ; link to MESSAGE
LOAD:     .WORD DOCOL
          .WORD BLK
          .WORD AT
          .WORD TOR
          .WORD IN
          .WORD AT
          .WORD TOR
          .WORD ZERO
          .WORD IN
          .WORD STORE
          .WORD BSCR
          .WORD STAR
          .WORD BLK
          .WORD STORE
          .WORD INTER
          .WORD RFROM
          .WORD IN
          .WORD STORE
          .WORD RFROM
          .WORD BLK
          .WORD STORE
          .WORD SEMIS
;
;                                       -->
;                                       SCREEN 62 LINE 6
;
L2924:    .BYTE $C3,"--",$BE
          .WORD L2896    ; link to LOAD
          .WORD DOCOL
          .WORD QLOAD
          .WORD ZERO
          .WORD IN
          .WORD STORE
          .WORD BSCR
          .WORD BLK
          .WORD AT
          .WORD OVER
          .WORD MOD
          .WORD SUB
          .WORD BLK
          .WORD PSTOR
          .WORD SEMIS
;
;    XEMIT writes one ascii character to terminal
;
;
XEMIT:    TYA
          SEC
          LDY #$1A
          ADC (UP),Y
          STA (UP),Y
          INY            ; bump user variable OUT
          LDA #0
          ADC (UP),Y
          STA (UP),Y
          LDA 0,X        ; fetch character to output
          STX XSAVE
          JSR OUTCH      ; and display it
          LDX XSAVE
          JMP POP
;
;         XKEY reads one terminal keystroke to stack
;
;
XKEY:     STX XSAVE
          JSR INCH       ; might otherwise clobber it while
          LDX XSAVE      ; inputting a char to accumulator
          JMP PUSHOA
;
;         XQTER leaves a boolean representing terminal break
;
;
XQTER:    LDA $C000      ; system depend port test
          CMP $C001
          AND #1
          JMP PUSHOA
;
;         XCR displays a CR and LF to terminal
;
;
XCR:      STX XSAVE
          JSR TCR        ; use monitor call
          LDX XSAVE
          JMP NEXT
;
;                                       -DISC
;                                       machine level sector R/W
;
L3030:    .BYTE $85,"-DIS",$C3
          .WORD L2924    ; link to -->
DDISC:    .WORD *+2
          LDA 0,X
          STA $C60C
          STA $C60D      ; store sector number
          LDA 2,X
          STA $C60A
          STA $C60B      ; store track number
          LDA 4,X
          STA $C4CD
          STA $C4CE      ; store drive number
          STX XSAVE
          LDA $C4DA      ; sense read or write
          BNE L3032
          JSR $E1FE
          JMP L3040
L3032:    JSR $E262
L3040:    JSR $E3EF      ; head up motor off
          LDX XSAVE
          LDA $C4E1      ; report error code
          STA 4,X
          JMP POPTWO
;
;                                       -BCD
;                             Convert binary value to BCD
;
L3050:    .BYTE $84,"-BC",$C4
          .WORD L3030    ; link to -DISC
DBCD:     .WORD DOCOL
          .WORD ZERO,CLIT
          .BYTE 10
          .WORD USLAS,CLIT
          .BYTE 16
          .WORD STAR,OR,SEMIS
;
;                                       R/W
;                              Read or write one sector
;
L3060:    .BYTE $83,"R/",$D7
          .WORD L3050    ; link to -BCD
RSLW:     .WORD DOCOL
          .WORD ZEQU,LIT,$C4DA,CSTOR
          .WORD SWAP,ZERO,STORE
          .WORD ZERO,OVER,GREAT,OVER
          .WORD LIT,SECTL-1,GREAT,OR,CLIT
          .BYTE 6
          .WORD QERR
          .WORD ZERO,LIT,SECTR,USLAS,ONEP
          .WORD SWAP,ZERO,CLIT
          .BYTE $12
          .WORD USLAS,DBCD,SWAP,ONEP
          .WORD DBCD,DDISC,CLIT
          .BYTE 8
          .WORD QERR
          .WORD SEMIS
;
;
;
          .WORD SEMIS
;
;                                       "
;                                       SCREEN 72 LINE 2
;
L3202:    .BYTE $C1,$A7
          .WORD L3060    ; link to R/W
TICK:     .WORD DOCOL
          .WORD DFIND
          .WORD ZEQU
          .WORD ZERO
          .WORD QERR
          .WORD DROP
          .WORD LITER
          .WORD SEMIS
;
;                                       FORGET
;                                       Altered from model
;                                       SCREEN 72 LINE 6
;
L3217:    .BYTE $86,"FORGE",$D4
          .WORD L3202    ; link to " TICK
FORG:     .WORD DOCOL
          .WORD TICK,NFA,DUP
          .WORD FENCE,AT,ULESS,CLIT
          .BYTE $15
          .WORD QERR,TOR,VOCL,AT
L3220:    .WORD R,OVER,ULESS
          .WORD ZBRAN,L3225-*
          .WORD FORTH,DEFIN,AT,DUP
          .WORD VOCL,STORE
          .WORD BRAN,$FFFF-24+1 ; L3220-*
L3225:    .WORD DUP,CLIT
          .BYTE 4
          .WORD SUB
L3228:    .WORD PFA,LFA,AT
          .WORD DUP,R,ULESS
          .WORD ZBRAN,$FFFF-14+1 ; L3228-*
          .WORD OVER,TWO,SUB,STORE
          .WORD AT,DDUP,ZEQU
          .WORD ZBRAN,$FFFF-39+1 ; L3225-*
          .WORD RFROM,DP,STORE
          .WORD SEMIS
;
;                                       BACK
;                                       SCREEN 73 LINE 1
;
L3250:    .BYTE $84,"BAC",$CB
          .WORD L3217    ; link to FORGET
BACK:     .WORD DOCOL
          .WORD HERE
          .WORD SUB
          .WORD COMMA
          .WORD SEMIS
;
;                                       BEGIN
;                                       SCREEN 73 LINE 3
;
L3261:    .BYTE $C5,"BEGI",$CE
          .WORD L3250    ; link to BACK
          .WORD DOCOL
          .WORD QCOMP
          .WORD HERE
          .WORD ONE
          .WORD SEMIS
;
;                                       ENDIF
;                                       SCREEN 73 LINE 5
;
L3273:    .BYTE $C5,"ENDI",$C6
          .WORD L3261    ; link to BEGIN
ENDIF:    .WORD DOCOL
          .WORD QCOMP
          .WORD TWO
          .WORD QPAIR
          .WORD HERE
          .WORD OVER
          .WORD SUB
          .WORD SWAP
          .WORD STORE
          .WORD SEMIS
;
;                                       THEN
;                                       SCREEN 73 LINE 7
;
L3290:    .BYTE $C4,"THE",$CE
          .WORD L3273    ; link to ENDIF
          .WORD DOCOL
          .WORD ENDIF
          .WORD SEMIS
;
;                                       DO
;                                       SCREEN 73 LINE 9
;
L3300:    .BYTE $C2,"D",$CF
          .WORD L3290    ; link to THEN
          .WORD DOCOL
          .WORD COMP
          .WORD PDO
          .WORD HERE
          .WORD THREE
          .WORD SEMIS
;
;                                       LOOP
;                                       SCREEN 73 LINE 11
;
;
L3313:    .BYTE $C4,"LOO",$D0
          .WORD L3300    ; link to DO
          .WORD DOCOL
          .WORD THREE
          .WORD QPAIR
          .WORD COMP
          .WORD PLOOP
          .WORD BACK
          .WORD SEMIS
;
;                                       +LOOP
;                                       SCREEN 73 LINE 13
;
L3327:    .BYTE $C5,"+LOO",$D0
          .WORD L3313    ; link to LOOP
          .WORD DOCOL
          .WORD THREE
          .WORD QPAIR
          .WORD COMP
          .WORD PPLOO
          .WORD BACK
          .WORD SEMIS
;
;                                       UNTIL
;                                       SCREEN 73 LINE 15
;
L3341:    .BYTE $C5,"UNTI",$CC
          .WORD L3327    ; link to +LOOP
UNTIL:    .WORD DOCOL
          .WORD ONE
          .WORD QPAIR
          .WORD COMP
          .WORD ZBRAN
          .WORD BACK
          .WORD SEMIS
;
;                                       END
;                                       SCREEN 74 LINE 1
;
L3355:    .BYTE $C3,"EN",$C4
          .WORD L3341    ; link to UNTIL
          .WORD DOCOL
          .WORD UNTIL
          .WORD SEMIS
;
;                                       AGAIN
;                                       SCREEN 74 LINE 3
;
L3365:    .BYTE $C5,"AGAI",$CE
          .WORD L3355    ; link to END
AGAIN:    .WORD DOCOL
          .WORD ONE
          .WORD QPAIR
          .WORD COMP
          .WORD BRAN
          .WORD BACK
          .WORD SEMIS
;
;                                       REPEAT
;                                       SCREEN 74 LINE 5
;
L3379:    .BYTE $C6,"REPEA",$D4
          .WORD L3365    ; link to AGAIN
          .WORD DOCOL
          .WORD TOR
          .WORD TOR
          .WORD AGAIN
          .WORD RFROM
          .WORD RFROM
          .WORD TWO
          .WORD SUB
          .WORD ENDIF
          .WORD SEMIS
;
;                                       IF
;                                       SCREEN 74 LINE 8
;
L3396:    .BYTE $C2,"I",$C6
          .WORD L3379    ; link to REPEAT
IF:       .WORD DOCOL
          .WORD COMP
          .WORD ZBRAN
          .WORD HERE
          .WORD ZERO
          .WORD COMMA
          .WORD TWO
          .WORD SEMIS
;
;                                       ELSE
;                                       SCREEN 74 LINE 10
;
L3411:    .BYTE $C4,"ELS",$C5
          .WORD L3396    ; link to IF
          .WORD DOCOL
          .WORD TWO
          .WORD QPAIR
          .WORD COMP
          .WORD BRAN
          .WORD HERE
          .WORD ZERO
          .WORD COMMA
          .WORD SWAP
          .WORD TWO
          .WORD ENDIF
          .WORD TWO
          .WORD SEMIS
;
;                                       WHILE
;                                       SCREEN 74 LINE 13
;
L3431:    .BYTE $C5,"WHIL",$C5
          .WORD L3411    ; link to ELSE
          .WORD DOCOL
          .WORD IF
          .WORD TWOP
          .WORD SEMIS
;
;                                       SPACES
;                                       SCREEN 75 LINE 1
;
L3442:    .BYTE $86,"SPACE",$D3
          .WORD L3431    ; link to WHILE
SPACS:    .WORD DOCOL
          .WORD ZERO
          .WORD MAX
          .WORD DDUP
          .WORD ZBRAN
L3449:    .WORD $0C      ; L3455-L3449
          .WORD ZERO
          .WORD PDO
L3452:    .WORD SPACE
          .WORD PLOOP
L3454:    .WORD $FFFC    ; L3452-L3454
L3455:    .WORD SEMIS
;
;                                       <#
;                                       SCREEN 75 LINE 3
;
L3460:    .BYTE $82,"<",$A3
          .WORD L3442    ; link to SPACES
BDIGS:    .WORD DOCOL
          .WORD PAD
          .WORD HLD
          .WORD STORE
          .WORD SEMIS
;
;                                       #>
;                                       SCREEN 75 LINE 5
;
L3471:    .BYTE $82,"#",$BE
          .WORD L3460    ; link to <#
EDIGS:    .WORD DOCOL
          .WORD DROP
          .WORD DROP
          .WORD HLD
          .WORD AT
          .WORD PAD
          .WORD OVER
          .WORD SUB
          .WORD SEMIS
;
;                                       SIGN
;                                       SCREEN 75 LINE 7
;
L3486:    .BYTE $84,"SIG",$CE
          .WORD L3471    ; link to #>
SIGN:     .WORD DOCOL
          .WORD ROT
          .WORD ZLESS
          .WORD ZBRAN
L3492:    .WORD $7       ; L3496-L3492
          .WORD CLIT
          .BYTE $2D
          .WORD HOLD
L3496:    .WORD SEMIS
;
;                                       #
;                                       SCREEN 75 LINE 9
;
L3501:    .BYTE $81,$A3
          .WORD L3486    ; link to SIGN
DIG:      .WORD DOCOL
          .WORD BASE
          .WORD AT
          .WORD MSMOD
          .WORD ROT
          .WORD CLIT
          .BYTE 9
          .WORD OVER
          .WORD LESS
          .WORD ZBRAN
L3513:    .WORD 7        ; L3517-L3513
          .WORD CLIT
          .BYTE 7
          .WORD PLUS
L3517:    .WORD CLIT
          .BYTE $30
          .WORD PLUS
          .WORD HOLD
          .WORD SEMIS
;
;                                       #S
;                                       SCREEN 75 LINE 12
;
L3526:    .BYTE $82,"#",$D3
          .WORD L3501    ; link to #
DIGS:     .WORD DOCOL
L3529:    .WORD DIG
          .WORD OVER
          .WORD OVER
          .WORD OR
          .WORD ZEQU
          .WORD ZBRAN
L3535:    .WORD $FFF4    ; L3529-L3535
          .WORD SEMIS
;
;                                       D.R
;                                       SCREEN 76 LINE 1
;
L3541:    .BYTE $83,"D.",$D2
          .WORD L3526    ; link to #S
DDOTR:    .WORD DOCOL
          .WORD TOR
          .WORD SWAP
          .WORD OVER
          .WORD DABS
          .WORD BDIGS
          .WORD DIGS
          .WORD SIGN
          .WORD EDIGS
          .WORD RFROM
          .WORD OVER
          .WORD SUB
          .WORD SPACS
          .WORD TYPE
          .WORD SEMIS
;
;                                       D.
;                                       SCREEN 76 LINE 5
;
L3562:    .BYTE $82,"D",$AE
          .WORD L3541    ; link to D.R
DDOT:     .WORD DOCOL
          .WORD ZERO
          .WORD DDOTR
          .WORD SPACE
          .WORD SEMIS
;
;                                       .R
;                                       SCREEN 76 LINE 7
;
L3573:    .BYTE $82,".",$D2
          .WORD L3562     ; link to D.
DOTR:     .WORD DOCOL
          .WORD TOR
          .WORD STOD
          .WORD RFROM
          .WORD DDOTR
          .WORD SEMIS
;
;                                       .
;                                       SCREEN 76  LINE  9
;
L3585:    .BYTE $81,$AE
          .WORD L3573    ; link to .R
DOT:      .WORD DOCOL
          .WORD STOD
          .WORD DDOT
          .WORD SEMIS
;
;                                       ?
;                                       SCREEN 76 LINE 11
;
L3595:    .BYTE $81,$BF
          .WORD L3585    ; link to .
QUES:     .WORD DOCOL
          .WORD AT
          .WORD DOT
          .WORD SEMIS
;
;                                       LIST
;                                       SCREEN 77 LINE 2
;
L3605:    .BYTE $84,"LIS",$D4
          .WORD L3595    ; link to ?
LIST:     .WORD DOCOL
          .WORD DECIM
          .WORD CR
          .WORD DUP
          .WORD SCR
          .WORD STORE
          .WORD PDOTQ
          .BYTE 6,"SCR # "
          .WORD DOT
          .WORD CLIT
          .BYTE 16
          .WORD ZERO
          .WORD PDO
L3620:    .WORD CR
          .WORD I
          .WORD THREE
          .WORD DOTR
          .WORD SPACE
          .WORD I
          .WORD SCR
          .WORD AT
          .WORD DLINE
          .WORD PLOOP
L3630:    .WORD $FFEC
          .WORD CR
          .WORD SEMIS
;
;                                       INDEX
;                                       SCREEN 77 LINE 7
;
L3637:    .BYTE $85,"INDE",$D8
          .WORD L3605    ; link to LIST
          .WORD DOCOL
          .WORD CR
          .WORD ONEP
          .WORD SWAP
          .WORD PDO
L3647:    .WORD CR
          .WORD I
          .WORD THREE
          .WORD DOTR
          .WORD SPACE
          .WORD ZERO
          .WORD I
          .WORD DLINE
          .WORD QTERM
          .WORD ZBRAN
L3657:    .WORD 4        ; L3659-L3657
          .WORD LEAVE
L3659:    .WORD PLOOP
L3660:    .WORD $FFE6    ; L3647-L3660
          .WORD CLIT
          .BYTE $0C      ; form feed for printer
          .WORD EMIT
          .WORD SEMIS
;
;                                       TRIAD
;                                       SCREEN 77 LINE 12
;
L3666:    .BYTE $85,"TRIA",$C4
          .WORD L3637    ; link to INDEX
          .WORD DOCOL
          .WORD THREE
          .WORD SLASH
          .WORD THREE
          .WORD STAR
          .WORD THREE
          .WORD OVER
          .WORD PLUS
          .WORD SWAP
          .WORD PDO
L3681:    .WORD CR
          .WORD I
          .WORD LIST
          .WORD PLOOP
L3685:    .WORD $FFF8    ; L3681-L3685
          .WORD CR
          .WORD CLIT
          .BYTE $F
          .WORD MESS
          .WORD CR
          .WORD CLIT
          .BYTE $0C      ;  form feed for printer
          .WORD EMIT
          .WORD SEMIS
;
;                                       VLIST
;                                       SCREEN 78 LINE 2
;
;
L3696:    .BYTE $85,"VLIS",$D4
          .WORD L3666    ; link to TRIAD
VLIST:    .WORD DOCOL
          .WORD CLIT
          .BYTE $80
          .WORD OUT
          .WORD STORE
          .WORD CON
          .WORD AT
          .WORD AT
L3706:    .WORD OUT
          .WORD AT
          .WORD CSLL
          .WORD GREAT
          .WORD ZBRAN
L3711:    .WORD $A       ; L3716-L3711
          .WORD CR
          .WORD ZERO
          .WORD OUT
          .WORD STORE
L3716:    .WORD DUP
          .WORD IDDOT
          .WORD SPACE
          .WORD SPACE
          .WORD PFA
          .WORD LFA
          .WORD AT
          .WORD DUP
          .WORD ZEQU
          .WORD QTERM
          .WORD OR
          .WORD ZBRAN
L3728:    .WORD $FFD4    ; L3706-L3728
          .WORD DROP
          .WORD SEMIS
;
;                                       MON
;                                       SCREEN 79 LINE 3
;
NTOP:     .BYTE $83,"MO",$CE
          .WORD L3696    ; link to VLIST
MON:      .WORD *+2
          JMP $FE00       ; Go to OSI Monitor
;
; Terminal return and line feed.
TCR:      PHA
          LDA #$0D
          JSR OUTCH
          LDA #$0A
          JSR OUTCH
          PLA
          RTS

TOP:      .END           ; end of listing
