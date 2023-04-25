; This OS-65D V3.3 disassembly was based on the V3.2 disassembly and
; subsequently modified based on a dump of memory on a running system.
;
; This was performed on a system running the OS-65D version for the
; C1P, so there may be some differences from the C3 version.
;
; Key differences between V3.2 and V3.3:
; - Screen display commands were added.
; - Editor commands were added.
; - Buffer addresses changed and no longer vary between 8" and 5" disks.
; - Many other small changes.
;
; Jeff Tranter <tranter@pobox.com>
;
;************************************************************************
;
;                        OS-65D V3.3 DISASSEMBLY
;                                   by
;                          Software Consultants
;                            7053 Rose Trail
;                           Memphis, TN 38134
;                             (901) 377-3503
;
;                            with V3.3 updates
;                                   by
;                               Jeff Tranter
;
;
; This document is not from any official source, but was done using the
; "brute force method". That is, starting with the small amount of data
; released by OSI, each routine was painstakingly traced and decoded by
; hand. Great care was taken to insure accuracy throughout, however, if
; you do find any errors or omissions, please let us know. We will then
; forward all such corrections to all purchasers.
;
; In several places within this listing you will find comments which are
; less than complimentary to 0SI. This was not done with the intent of
; belittling the original authors of OS-65D, but strictly to inform all
; readers of the shortcomings as well as the virtues of this operating
; system. If anyone feels we have been overly critical, we apologize.
;
; If any of your friends asks you to allow them to make a copy of this
; document, please ask them to first read the following.
;
; Software Consultants is a professional software house specializing in
; OSI compatible products. We are in business to make a profit, just as
; all businesses are. The OS-65D disassembly represents over 500 manhours
; of research, compilation, and editing. The price was set as low as was
; possible while still allowing us a reasonable profit. If we are denied
; this reasonable profit by large numbers of people making pirate copies
; then we will not be able to continue working on other products for OSI
; equipment. You may save yourself a few, dollars, but you will also be
; jeopardizing one of the very limited number of sources of high quality
;
; COPYRIGHT 1980 by Software Consultants.
; All rights reserved.
;
; GENERAL INFORMATION
; -------------------
;
; One of the most frustrating features of using Ohio Scientific
; equipment is the almost total lack of useable documentation.
; OS-65D is supposed to be a "developmental" operating system, which
; implies that the user can develop his own machine language programs
; and tie them into the OS. Obviously this is not the case or this
; document would never have come into existence.
;
; We originally broke the OS not as a money making project, but to
; enable us to tie our own machine language programs into the OS, and
; to give us the information necessary to make modifications that suit
; our needs. Once completed, we felt others attempting to use this OS
; could use this information to the same advantage that we have. Of
; course, the profit motive was also a deciding factor.
;
; We assume that anyone using this document is thoroughly familiar with
; the workings of OS-65D V3.2 and is also a competent 6502 assembler
; programmer. Every effort has been made to make each routine within
; the OS as clear as possible. However, this is a reference manual,
; not a textbook.
;
; We suggest that upon first reading this document you simply scan
; through and read all comments rather than attempt to absorb the entire
; thing at one reading. Then you may go back and read the actual code
; after first getting a feel for the contents and flow of the OS.
;
; This manual was intentionally printed on just one side of the paper to
; allow you to put your own notes on the facing pages. In particular, if
; you make changes to the OS, note each change in the listing along with
; it's purpose and the date made. If you will do your documentation as
; if you were going to be struck with amnesia tomorrow, it will truly
; make your life easier.
;
; Following the listing of the OS itself is a complete cross reference
; showing the locations where each label is used. The location where
; the label is defined is marked with an asterisk. This should prove
; invaluable in both tracing logic and in assuring yourself that any
; changes made will not have any undesired side effects.
;
; Our intention in the preparation of this manual was to make it as
; useful as possible to you, the purchaser. If after careful study of
; the listing, you still have unanswered questions about the workings
; of OS-65D, write us and we will attempt to answer your questions
;
; Happy computing!
;

       .ORG $2200

; Define the last track number (in BCD, starting from zero): 76 for 8"
; floppies and 39 for 5.25" as well the number of tracks.
LASTTRACK = $39
NUMTRACKS = $40
;LASTTRACK = $76
;NUMTRACKS = $77

; INITIALIZATION ROUTINE
;
; THIS IS THE ENTRY POINT WHEN THE SYSTEM IS BOOTED.
; THE CODE FROM $2200 TO $22FF IS OVERLAYED BY BASIC WHEN IT IS CALLED.
;
        LDA #1
        STA a:SECTNM    ; SET SECTOR # to 1
        JSR SETTK       ; MOVE TO TRACK 1
        LDA #$2A
        STA z:MEMHI     ; SET HI MEM ADDR
        JSR LDHEAD      ; LOAD HEAD
        STX z:MEMLO     ; SET LOW MEM ADDR TO 0
        JSR READDK      ; READ TK 1 INTO $2A00
        JSR UNLDHD      ; UNLOAD HEAD
        STX PTRPIA+1
        STX PTRPIA      ; CLEAR PRINTER PIA (X=0)
        STX PTRPIA+3
        DEX             ; X=FF
        STX KPORT+1     ; SET KEYBOARD SOUND GENERATOR TO
                        ; LOWEST FREQUENCY (192.753 HZ)
                        ; THEN TURN IT OFF @ $228F!!!
        STX PTRPIA+2    ; SET PRINTER PIA
        LDA UART+6
        STX UART+5      ; SET SERIAL PORT
        LDA #4
        STA PTRPIA+1    ; PRINTER AGAIN
        STA PTRPIA+3
        STY FLOPIN+1    ; RESET DISK (Y=0)
        LDY #$40
        STY FLOPIN
        STA FLOPIN+1
        LDA #1
        JSR SETDRV      ; SET DRIVE TO 1
        LDA #3
        STA TERMAC      ; RESET TERMINAL ACIA
        LDY #$11
        STY TERMAC      ; SET TERMINAL ACIA
        LDX #$1E
CLRX16  STA X16ACI,X    ; SET CA-10X 16 WAY SERIAL BOARD
        TYA             ; (IF ADDRESSED @ $CF00)
        STA X16ACI,X
        LDA #3
        DEX
        DEX
        BPL CLRX16
        LDX #8          ; CLEAR VIDEO SCREEN
        LDA #$D0
        STA z:MEMHI
        LDY #0
        STY z:MEMLO
        LDA #$20
CLRVID  STA (MEMLO),Y
        INY
        BNE CLRVID
        INC z:MEMHI
        DEX
        BNE CLRVID
        STX z:MEMLO     ; X = 0
;
; WE ORIGINALLY THOUGHT THE ABOVE INSTRUCTION WAS USED FOR A
; FOR A PURPOSE WE HAVE NEVER SEEN DOCUMENTED. WHEN BASIC IS RUN
; IT PUTS A JUMP AT $0000 TO $0474 (4C 74 04).THIS JUMP WILL TAKE
; YOU TO THE COMMAND MODE. IF YOU RESET THE SYSTEM WHILE BASIC
; IS RUNNING AND DO NOT WISH TO LOSE THE PROGRAM IN MEMORY, ALL YOU
; HAVE TO DO IS TO JUMP TO $0000 FROM THE MONITOR. I.E. TYPE M THEN
; L012E0000RG FOR A SERIAL SYSTEM OR .0000G FOR A VIDEO SYSTEM.
; ANOTHER TIME WHEN THIS IS USEFUL IS WHEN BASIC IS AT AN INPUT
; STATEMENT AND YOU DO NOT WANT TO CONTINUE THE PROGRAM. SINCE YOU
; CANNOT USE CONTROL C AT AN INPUT STATEMENT, JUST RESET AND DO THE
; ABOVE. WE SUSPECTED THE PURPOSE OF THIS INSTRUCTION WAS TO
; PREVENT DOING JUST THIS IF THE RESET IS HIT, THEN D, THEN RESET
; AGAIN BEFORE BASIC HAS BOOTED. ACTUALLY THAT IS NOT THE REASON,
; BUT SINCE THIS IS A USEFUL PIECE OF INFORMATION, WE PUT IT IN
; ANYWAY. THE REASON $00 IS SET TO 0 IS AS A FLAG FOR BASIC TO
; KNOW WHETHER OR NOT TO SWAP PAGE 0 AND 1 (SEE $2D50).
;
; MEMTST : HIGHEST MEMORY TEST ROUTINE
;
; THIS ROUTINE CHECKS FOR THE HIGHEST AVAILABLE MEMORY PAGE.
; IT STARTS WITH THE PAGE @ $BF00 AND MOVES DOWN IN STEPS OF ONE
; PAGE UNTIL IT FINDS MEMORY. A WORD OF CAUTION. IF YOU HAVE LESS
; THAN 48K AND INTEND TO USE SOME OF THE UPPER ADDRESS SPACE FOR
; HARDWARE, THEN THE STARTING PAGE ADDRESS @ $2277 SHOULD BE MODIFIED
; OR THE MEMORY TEST MAY DO STRANGE THINGS TO YOUR DEVICE.
;
MEMTST  LDY #$BF        ; START TEST @ $BF00
        JSR MEMCHK      ; TEST THIS PAGE
        BEQ HMFND       ; IF SO, FOUND MEMORY
        DEY             ; TRY NEXT PAGE
        BNE MEMTST+2    ; ALWAYS JUMP BACK
HMFND   STY HIMEM       ; STORE HIGHEST MEMORY PAGE
        LDX #1          ; CHECK FOR SERIAL OR VIDEO
        LDA $FE01       ; (EITHER 65-A OR 65-V PROM)
        BEQ *+3
        INX             ; IF VIDEO SET X=2
        STX INDST       ; STORE DEFAULT DEVICE
; THE DEFAULT DEVICE ABOVE IS PICKED UP BY BEXEC* AND PUT INTO THE
; INPUT & OUTPUT DISTRIBUTOR BYTES. THIS IS THE REASON THAT THE
; BASIC STARTUP MESSAGE IS NOT PRINTED ON BOOTING THE SYSTEM, SINCE
; THE OUTPUT DISTRIBUTOR ON DISK IS $00, WHICH DOES NOT OUTPUT TO
; ANYTHING.
        STX OUTDST
        STX $2AC6
        JMP GOBAS       ; SKIP OVER UNUSED CODE!
;
;$2297-$22B2 IS UNUSED CODE
;
        CPX $F022
        CLC
        LDY #$D7
        JSR MEMCHK
        BNE $22B3
        LDY #0
        LDX $22C7,Y
        BEQ $22B3
        INY
        LDA $22C7,Y
        STA VIDOUT,X
        INY
        BNE $22A4

GOBAS   JSR STROUT
        .BYTE $0D,$0A,"OS-65D V3.0",$00
        JMP OS65D3
;
; $22C7 THRU $22EB IS A TABLE USED BY THE UNUSED ROUTINE @$2297.
;
        .BYTE $0B,$40,$8D,$40,$91,$40,$AF,$40
        .BYTE $2D,$80,$9E,$80,$A1,$D7,$2A,$D7
        .BYTE $34,$D7,$3C,$D7,$8B,$D7,$97,$D7
        .BYTE $BA,$D7,$7D,$D7,$84,$D7,$80,$B1
        .BYTE $87,$AA,$31,$00,$00
;
; MEMCHK : MEMORY CHECK SUBROUTINE. CALLED @ $2278
;
; THERE MUST BE SOME REASON TO ONLY CHECK THE LOWEST SIX BITS OF
; THE BYTE UNDER TEST, BUT WE SURE CAN'T THINK OF ONE!
;
MEMCHK  STY z:MEMHI     ; POINT TO PAGE UNDER TEST
        LDA (MEMLO),Y   ; GET A BYTE FROM THAT PAGE
        AND #$3F        ; KILL HIGHEST 2 BITS (?!)
        EOR #$3F        ; INVERT ALL REMAINING BITS
        STA (MEMLO),Y   ; PUT HASHED BYTE BACK
        STA z:TS2       ; AND SAVE IT
        LDA (MEMLO),Y   ; GET BYTE BACK FROM MEMORY
        AND #$3F        ; KILL HIGHEST 2 BITS
        CMP z:TS2       ; IS IT THE SAME?
        RTS             ; EXIT WITH EQL FLAG SET

; OS-65D V3.2 (NMHZ)
;
; ZERO PAGE LOCATIONS USED BY OS
;
PAGE0   =   $0000       ; BASE OF PAGE ZERO
TS1     =   $E0         ; TEMPORARY STORAGE
OSIBAD  =   $00E1       ; OS INPUT BUFFER ADDRESS
STROAD  =   $00E3       ; ADDRESS USED BY STROUT ROUTINE
HSTTK   =   $00E5       ; HIGHEST TRACK NUMBER OF FILE
TKNHLD  =   $00EE       ; TRACK NUMBER HOLD
STEPRT  =   $00EF       ; STEP RATE FOR DISK
SCTRTY  =   $00F5       ; SECTOR RETRY COUNT
WRTRTY  =   $00F6       ; WRITE RETRY COUNT
RDRTYM  =   $00F7       ; READ VERIFICATION RETRY COUNT
                        ; AFTER MOVING HEAD (3)
                        ; NOT USED ON VERIFY AFTER DISK WRITE
RDRTYN  =   $00F8       ; READ VERIFICATION RETRY COUNT
                        ; WITHOUT MOVING HEAD (7)
; ON READ, TOTAL RETRIES BEFORE AN ERROR = RDRTYN * RDRTYM (21)
SCTBYP  =   $00F9       ; SECTORS BYPASSED COUNTER
SCTLEN  =   $00FA       ; SECTOR LENGTH IN PAGES
SCTNUM  =   $00FB       ; SECTOR NUMBER
STKADR  =   $00FC       ; STACK ADDRESS
TS2     =   $00FD       ; TEMPORARY STORAGE
MEMLO   =   $00FE       ; INDIRECT MEMORY ADDRESS, LOW
MEMHI   =   $00FF       ; "        "      "      , HI
;
; OTHER MEMORY ADDRESSES REFERRED TO BY THE OS
; ALL EXCEPT THOSE MARKED WITH AN ASTERISK ARE PART OF AN INSTRUCTION
; AND THEREFORE ARE CASES OF SELF-MODIFYING CODE.
; DURING THE LISTING, ANY ADDRESS WHICH IS MODIFIED IS DENOTED BY
; A PLACEHOLDER (PH) IN THE PLACE OF AN ADDRESS.
;
PH      =   $0000       ; PLACEHOLDER ADDRESS IN SELF-MODIFYING CODE
STACK   =   $0100       ; * BASE OF STACK (PAGE 1)
SWAP4A  =   $0213       ; * 4 BYTES SWAPPED DURING POLLED
                        ; KEYBOARD ROUTINE
STASM   =   $1300       ; * COLD START FOR ASSEMBLER
RTASM   =   $1303       ; * RESTART ASSEMBLER ENTRY POINT
STEM    =   $1700       ; * COLD START FOR EXTENDED MONITOR
                        ; THERE IS NO RESTART POINT
RTBAS   =   $20C4       ; * RESTART BASIC ENTRY POINT
STBAS   =   $20E4       ; * COLD START FOR BASIC
X_HOLD  =   $235F       ; X REGISTER HOLD
Y_HOLD  =   $2361       ; Y REGISTER HOLD
A_HOLD  =   $2363       ; ACCUMULATOR HOLD
IOOFS   =   $2378       ; VECTORED I/O OFFSET
MINADR  =   $238A       ; MEMORY INPUT ADDRESS
MOTADR  =   $2391       ; "     OUTPUT "
D1IADR  =   $23AC       ; DISK 1 BUFFER INPUT ADDRESS
D1OADR  =   $23C3       ; "    " "     OUTPUT "
D2IADR  =   $23FD       ; "    2 "      INPUT "
D2OADR  =   $2416       ; "    " "     OUTPUT "
VOTOFS  =   $25A4       ; VIDEO OUTPUT LINE OFFSET
VLP1    =   $262B       ; VIDEO LINE POINTER DURING SCROLL
VLP2    =   $262E       ; "     "    "       "      "
VLOSAV  =   $2639       ; OFFSET SAVE
NMHZ    =   $267B       ; NMHZ VARIABLE
                        ; $31=1MHZ, $62=2MHZ
                        ; WE CAN NOT FIND WHERE THIS IS
                        ; SET, PROBABLY IN BASIC.
DEFDEV  =   $2AC6       ; DEFAULT I/O DEVICE (SET @ $2288)
BUFOFS  =   $2CE5       ; OS BUFFER OFFSET
MAXBUF  =   $2CED       ; MAXIMUM SIZE OF OS BUFFER
PLINE   =   $D700       ; * PRINT LINE FOR 549 VIDEO
;
; FLOPPY DISK PIA (MC6B21)
;
FLOPIN =   $C000        ; FLOPPY DISK STATUS PORT
;
; BIT FUNCTION
; --- --------
;  0  DRIVE 0 READY (0 IF READY)
;  1  TRACK 0 (0 IF AT TRACK 0)
;  2  FAULT (0 IF FAULT)
;  4  DRIVE 1 READY (0 IF READY)
;  5  WRITE PROTECT (0 IF WRITE PROTECT)
;  6  DRIVE SELECT (1 = A OR C, B = B OR D)
;  7  INDEX (0 IF AT INDEX HOLE)
;
FLOPOT   =  $C002       ; FLOPPY DISK CONTROL PORT
;
; BIT FUNCTION
; --- --------
;  0  WRITE ENABLE (0 ALLOWS WRITING)
;  1  ERASE ENABLE (0 ALLOWS ERASING)
;     ERASE ENABLE IS ON 200us AFTER WRITE IS ON
;     ERASE ENABLE IS OFF 530us AFTER WRITE IS OFF
;  2  STEP BIT : INDICATES DIRECTION OF STEP (WAIT 10 us FIRST)
;     0 INDICATES STEP TOWARD 39/76
;     1 INDICATES STEP TOWARD 0
;  3  STEP (TRANSITION FROM 1 TO 0)
;     MUST HOLD AT LEAST 10 us, MIN 8us BETWEEN
;  4  FAULT RESET (0 RESETS)
;  5  SIDE SELECT (1 = A OR B, 0 = C OR D)
;  6  LOW CURRENT (0 FOR TRKS 43-76, 1 FOR TRKS 0-42)
;  7  HEAD LOAD (0 TO LOAD: MUST WAIT 40ms AFTER)
;
; FLOPPY DISK ACIA (MC6850)
;
ACIA    =   $C010       ; DISK CONTROLLER ACIA STATUS PORT
ACIAIO  =   $C011       ; "    "          "    I/O    "
;
; OTHER HARDWARE ADDRESSES
;
X16ACI  =   $CF00       ; NORMAL BASE ADDRESS OF CA10X BOARD
VIDSIZ  =   $DE00       ; VIDEO SIZE (1= 64 CHAR, B = 32)
KPORT   =   $DF00       ; POLLED KEYBOARD PORT
PTRPIA  =   $F400       ; PARALLEL PRINTER PIA (MC6821)
UART    =   $FB00       ; 430 BOARD SERIAL PORT ($1883)
TERMAC  =   $FC00       ; SERIAL TERMINAL ACIA STATUS PORT
TERMIO  =   $FC01       ; "      "        "    I/O    "
KPOLL   =   $FD00       ; POLLED KEYBOARD ROUTINE (ROM)
;
; THE ACIAS AT $CFXX AND $FC00 ARE ALL MC6850'S

  .RES      $2301-*

; START OF RESIDENT OS MEMORY AREA
;
HIMEM   =   $2300       ; HIGHEST MEMORY PAGE ADDRESS
                        ; SET @$2280
;
; I/O DISPATCH TABLE (ADDRESS = ACTUAL ADDRESS - 1)
; ROUTINES ARE CALLED BY PUSHING THE ADDRESS ON
; THE STACK AND DOING AN RTS.
;
; INPUT DISPATCH TABLE
;
IOTABL  .WORD TERMIN-1  ; TERMINAL (ACIA): BASIC DEVICE 1
        .WORD KBINP-1   ; POLLED KEYBOARD: BASIC DEVICE 2
        .WORD SERINP-1  ; SERIAL (UART): BASIC DEVICE 3
        .WORD NULLIN-1  ; NULL: BASIC DEVICE 4
        .WORD MEMIN-1   ; MEMORY: BASIC DEVICE 5
        .WORD DK1IN-1   ; DISK1: BASIC DEVICE 6
        .WORD DK2IN-1   ; DISK2: BASIC DEVICE 7
        .WORD $24B0-1   ; CA10X: BASIC DEVICE 8 (OBSOLETE)
;
; OUTPUT DISPATCH TABLE
;
        .WORD TERMOT-1  ; TERMINAL (ACIA): BASIC DEVICE 1
        .WORD VIDOUT-1  ; 540 VIDEO: BASIC DEVICE 2
        .WORD SEROUT-1  ; SERIAL (UART): BASIC DEVICE 3
        .WORD PTROUT-1  ; PARALLEL PRINTER: BASIC DEVICE 4
        .WORD MEMOT-1   ; MEMORY: BASIC DEVICE 5
        .WORD DK1OUT-1  ; DISK1: BASIC DEVICE 6
        .WORD DK2OUT-1  ; DISK2: BASIC DEVICE 7
        .WORD $24BD-1   ; CA10X: BASIC DEVICE 8 (OBSOLETE)
;
; GENERAL STORAGE AREA
;
INDST   .RES 1          ; INPUT DISTRIBUTOR
OUTDST  .RES 1          ; OUTPUT DISTRIBUTOR
X16DEV  .RES 1          ; CA10X DEVICE # * 2 (0-1E)
RNDSED  .RES 1          ; RANDOM NUMBER SEED
KPDO    .RES 1          ; KEY PRESSED DURING OUTPUT
D1BFLO  .RES 2          ; DISK1 BUFFER LOW ADDRESS
D1BFHI  .RES 2          ; DISK1 BUFFER HI ADDRESS
D1FRST  .RES 1          ; DISK1 FIRST TRACK
D1LAST  .RES 1          ; DISK1 LAST TRACK
D1CRTK  .RES 1          ; DISK1 CURRENT TRACK
D1BFDR  .RES 1          ; DISK1 BUFFER 'DIRTY' FLAG
D2BFLO  .RES 2          ; DISK2 BUFFER LOW ADDRESS
D2BFHI  .RES 2          ; DISK2 BUFFER HI ADDRESS
D2FRST  .RES 1          ; DISK2 FIRST TRACK
D2LAST  .RES 1          ; DISK2 LAST TRACK
D2CRTK  .RES 1          ; DISK2 CURRENT TRACK
D2BFDR  .RES 1          ; DISK2 BUFFER 'DIRTY' FLAG
;
; START OF ACTUAL CODE
;
; INPUT/OUTPUT ROUTINES
;
IN1     JMP INPUT       ; USED BY INECHO @$2340
;
; DOINP : DO VECTORED INPUT BASED ON VALUE IN INDST
;
; (SEE NOTE AT #2CD6)
; THE OS-65D MANUAL SAYS THAT INPUT IS DONE FROM THE LOWEST SET
; DEVICE & ALL OTHERS ARE IGNORED. WRONG!!! IF MORE THAN ONE BIT
; IS SET IN INDST, THINGS REALLY GO CRAZY. TRY ENTERING "1O ,11"
; (OR "IO 12" FOR A VIDEO SYSTEM) AT "A*" AND WATCH THE RESULTS.
;
DOINP   LDY #$00        ; SET FOR INPUT
        LDA INDST       ; GET INPUT DISTRIBUTOR
        BNE DOIO        ; GO DO INPUT
;
; INECHO : INPUT & ECHO. ALSO CHECKS FOR CONTROL CHARACTERS.
;
INECHO  JSR IN1         ; INPUT AND ECHO
                        ; THIS SHOULD HAVE BEEN
                        ; JSR INPUT. WHY THEY DID IT
                        ; THIS WAY WE DON'T KNOW.
;
; PRINT ROUTINE : OUTPUT TO ALL ACTIVE DEVICES
; OUTPUT CHARACTER IN A
;
PRINT   JSR SAVAXY      ; SAVE ALL REGISTERS
        JSR $25A6
        LDY #$10        ; DENOTES OUTPUT
;
; DO I/O, EITHER INPUT OR OUTPUT BASED ON VALUE IN Y
;
DOIO    LDX #$FF        ; SET INDEX TO DETERMINE DEVICE
        BNE PATCH1      ; GO TO PATCH FOR I/O OFFSET
        INX
        LSR A           ; CHECK FOR I/O BIT ON
        BCC DONXIO      ; ($235C) BRANCH IF NOT
        PHA             ; SAVE REST OF I/O DIST BYTE
        TXA             ; AND DEVICE NUMBER FOUND
        PHA             ; I/O DEVICE NOW IN A
        JSR IODISP      ; GO DO I/O
        PLA             ; RESTORE A AND X
        TAX
        PLA
DONXIO  BNE DOIO+4      ; ($234F) IF ANY BITS STILL ON
;
; RSTAXY : RESTORE A,X,Y (USED AFTER SAVAXY)
; WARNING! THIS ROUTINE MASKS OUT THE UPPER BIT IN A
;
RSTAXY  LDX #$01        ; RESET X
        LDY #$00        ; RESET Y
        LDA #$20        ; RESET A
        AND #$7F        ; KILL UPPER BIT IN A
        RTS             ; BACK WE GO
;
; SAVE A,X,Y FOR LATER
;
SAVAXY  STA A_HOLD      ; SAVE A
        STY Y_HOLD      ; SAVE Y
        STX X_HOLD      ; SAVE X
        RTS
;
; PATCH TO SET I/O OFFSET
;
PATCH1  STY IOOFS       ; STORE I/O OFFSET
        BNE DOIO+4      ; ($234F) GO BACK
;
; IODISP : I/O DISPATCH ROUTINE
;
IODISP  ASL A           ; MULTIPLY I/O DEVICE BY 2
        ADC #$10        ; I/O OFFSET (0=INPUT $10=OUTPUT)
        TAX             ; GET SET TO GET I/O ADDRESS
        LDA IOTABL+1,X  ; GET HI BYTE
        PHA             ; PUSH ON STACK
        LDA IOTABL,X    ; GET THE LOW BYTE
        PHA             ; PUSH ON STACK
        LDA A_HOLD      ; RESTORE A FOR OUTPUT
        RTS             ; JUMP TO ROUTINE
;
; NULLIN: NULL INPUT ROUTINE (BASIC DEVICE 4)
;
; WHILE THE NULL INPUT ROUTINE IN ITSELF IS NOT THAT USEFUL,
; SINCE IT IS 3 BYTES LONG IT COULD BE USED AS A JUMP TO A
; USER DEFINED INPUT ROUTINE.
;
NULLIN  LDA #$00
        RTS
;
; MEMIN : INPUT FROM MEMORY ROUTINE (BASIC DEVICE 5)
; THIS ROUTINE IS ALSO USED FOR THE INDIRECT FILE FUNCTION.
;
MEMIN   LDA DSPTBL      ; GET BYTE FROM MEMORY
                        ; MODIFIED BY COMINC
        LDX #$00        ; SET OFFSET
        BEQ COMINC      ; GO TO COMMON INCREMENT ROUTINE
;
; MEMOT : MEMORY OUTPUT ROUTINE (BASIC DEVICE 5)
; THIS ROUTINE IS ALSO USED BY THE INDIRECT FILE FUNCTION.
;
MEMOT   STA a:PH        ; PUT BYTE IN MEMORY
                        ; MODIFIED BY COMINC
        LDX #$07        ; SET OFFSET
;
; COM INC : COMMON INCREMENT ROUTINE
; THE FOLLOWING ROUTINE IS USED BY THE DISK 1 AND 2 INPUT
; AND OUTPUT ROUTINES AS WELL AS THE MEMORY INPUT AND OUTPUT
; ROUTINES. THIS IS AN EXTREME CASE OF SELF MODIFYING CODE WHICH
; SHOULD NORMALLY BE AVOIDED. X IS USED AS THE INDEX
; AND IS SET BY EACH INDIVIDUAL ROUTINE BEFORE CALLING THIS ROUTINE.
;
COMINC  STA A_HOLD      ; SAVE A
        INC MINADR,X    ; INCREMENT MEMORY ADDRESS
        BNE *+5         ; ($23A0)
        INC MINADR+1,X
        RTS
;
; DK1IN : DISK 1 INPUT ROUTINE (BASIC DEVICE 6)
;
DK1IN   LDY #$00        ; SET Y OFFSET
        JSR CKBFEN-2    ; CHECK FOR END OF BUFFER
        BNE *+5         ; ($23AB) IF NOT END OF BUFFER, CONT
        JSR DK1NXT      ; READ NEXT TRACK
        LDA a:PH        ; LOAD BYTE (MODIFIED BY COMINC)
        LDX #$22        ; SET THE OFFSET
        BNE COMINC      ; GO USE COMMON INCREMENT ROUTINE
;
; DK1OUT : DISK 1 OUTPUT ROUTINE (BASIC DEVICE 6)
;
; THIS ROUTINE WILL ALLOW YOU TO PRINT ANY CHARACTERS TO DISK EXCEPT
; A LINE FEED ($0A). SOMETIMES IT IS USEFUL TO BE ABLE TO WRITE A
; LINE FEED TO DISK, I.E. CREATING A WORD PROCESSOR OR ASSEMBLER
; FILE WITH BASIC. IF YOU WISH TO DO SO, YOU CAN CHANGE THE FOURTH
; BYTE OF EITHER DISK OUTPUT ROUTINE TO A NULL (HEX 0). JUST BE SURE
; YOU DON'T DO A "NORMAL" WRITE TO DISK WHILE THE CHANGE IS IN EFFECT
; OR THE CARRIAGE RETURN WILL BE FOLLOWED BY A LINE FEED.
;
DK1OUT  CMP #$0A        ; IF LINE FEED THEN RETURN
        BEQ DK1IN-1     ; ($23A0)
        PHA             ; SAVE BYTE TO BE WRITTEN
        LDY #$17        ; SET Y FOR OFFSET
        JSR CKBFEN-2    ; CHECK FOR END OF BUFFER
        BNE *+5         ; ($23C1) CONTINUE IF NOT AT END
        JSR DK1NXT      ; WRITE THIS TRACK, READ NEXT
        PLA             ; RESTORE THE OUTPUT BYTE
        STA a:PH        ; PUT IN BUFFER (MODIFIED BY COMINC)
        LDX #LASTTRACK  ; SET OFFSET FOR COMMON INCREMENT
        STX D1BFDR      ; SET BUFFER DIRTY FLAG
        BNE COMINC      ; BRANCH TO COMMON INCREMENT
;
; DK1NXT : DISK 1 NEXT TRACK READ, USED BY DK1IN AND DK1OUT
;
DK1NXT  LDA D1BFDR      ; GET BUFFER 'DIRTY' FLAG
        BEQ *+7         ; ($2306) IF NOT 'DIRTY' CONTINUE
        LDX #$00        ; SET OFFSET
        JSR WTDKBF      ; GOSUB TO WRITE DISK BUFFER
        LDA D1BFLO      ; RESET READ/WRITE ADDRESS
        STA D1IADR      ; AND MEMORY ADDRESS TO START
        STA D1OADR      ; OF DISK BUFFER
        STA MEMLO
        LDA D1BFLO+1
        STA D1IADR+1
        STA D1OADR+1
        STA MEMHI
        LDX #$00        ; SET OFFSET
        BEQ BDRDNX      ; ALWAYS BRANCH
;
; DK2IN : DISK 2 INPUT ROUTINE (BASIC DEVICE 7)
;
DK2IN   LDX #$08        ; SET OFFSETS
        LDY #$51
        JSR CKBFEN      ; CHECK FOR END OF BUFFER
        BNE *+5         ; ($23FC) IF NOT END, CONTINUE
        JSR DK2NXT      ; WRITE THIS BUFFER, READ NEXT
        LDA a:PH        ; LOAD BYTE FROM BUFFER
                        ; MODIFIED BY COMINC
        LDX #$73        ; SET OFFSET
        BNE COMINC      ; BRANCH TO COMMON INCREMENT
;
; DK2OUT : DISK 2 OUTPUT ROUTINE (BASIC DEVICE 7)
; SEE NOTE @$23B2 ABOUT LINE FEED
DK2OUT  CMP #$0A        ; IF LINE FEED THEN RETURN
        BEQ L2476
        PHA             ; SAVE BYTE TO BE WRITTEN
        LDX #$08        ; SET OFFSETS
        LDY #$6A
        JSR CKBFEN      ; CHECK FOR END OF BUFFER
        BNE *+5         ; ($2414) IF NOT END THEN CONTINUE
        JSR DK2NXT      ; WRITE BUFFER, READ NEXT TRACK
        PLA             ; GET BYTE TO BE WRITTEN
        STA a:PH        ; PUT IN BUFFER (MODIFIED BY COMINC)
        LDX #$8C        ; SET OFFSET FOR COMINC
        STX D2BFDR      ; SET BUFFER 'DIRTY' FLAG
        JMP COMINC      ; DO INCREMENT FOR POINTER
;
; DK2NXT : DISK 2 NEXT TRACK READ, USED BY DK2IN AND DK2OUT
;
DK2NXT  LDA D2BFDR      ; GET BUFFER 'DIRTY' FLAG
        BEQ *+7         ; ($242A) CONTINUE IF NOT 'DIRTY'
        LDX #$08        ; SET OFFSET
        JSR WTDKBF      ; GO WRITE THIS BUFFER
        LDA D2BFLO      ; RESET READ/WRITE ADDRESSES
        STA D2IADR      ; AND MEMORY ADDRESS TO
        STA D2OADR      ; START OF BUFFER
        STA MEMLO
        LDA D2BFLO+1
        STA D2IADR+1
        STA D2OADR+1
        STA MEMHI
        LDX #$08        ; SET OFFSET
;
; THE NEXT GROUP OF ROUTINES ARE USED BY BOTH DISK 1 & DISK 2
; X IS SET TO 0 FOR DISK 1 AND TO 8 FOR DISK 2.
;
; BDRDNX : BUFFERED DISK I/O READ NEXT TRACK
;
BDRDNX  LDA D1CRTK,X    ; GET CURRENT TRACK NUMBER
        CLC             ; GET SET TO ADD 1 TO CURRENT TRACK
        SED             ; SET DECIMAL (TRACK# IN BCD)
        ADC #$01        ; DO THE ADD
        CLD             ; CLEAR DECIMAL MODE
        STA D1CRTK,X    ; SAVE THE TRACK NUMBER
        JSR BDMHTK      ; MOVE HEAD TO TRACK
        JMP CALL+12     ; ($2B1D) READ DISK, UNLOAD HEAD
                        ; AND RETURN
;
; BDMHTK : : BUFFERED DISK I/O MOVE HEAD TO TRACK
;
BDMHTK  LDA #$00        ; CLEAR BUFFER 'DIRTY' FLAG
        STA D1BFDR,X
        LDA D1CRTK,X    ; COMPARE CURRENT TRACK
        CMP D1LAST,X    ; WITH LAST TRACK
        JSR INCTKN+10   ; ($2C8D) MOVE HEAD TO TRACK, IF
                        ; PAST END OF FILE, ERROR D
        INY             ; SET Y TO 1
        BNE PATCH2      ; ALWAYS BRANCH TO PATCH2
        BRK             ; (NOT USED)
        BRK             ; (NOT USED)
;
        LDX #$00        ; SET OFFSET
                        ; USED BY DK1IN AND DK1OUT
;
; CKBFEN : CHECK FOR END OF BUFFER
;
CKBFEN  LDA D1IADR,Y    ; LOW ADDRESS OF BYTE TO BE READ
        CMP D1BFHI,X    ; LOW ADDRESS OF END OF BUFFER
        BNE *+8         ; ($2476) IF NOT THE SAME THEN RETURN
        LDA D1IADR+1,Y  ; HI ADDRESS OF BYTE TO BE READ
        CMP D1BFHI+1,X  ; HI ADDRESS OF END OF BUFFER
L2476   RTS             ; RETURN WITH Z FLAG SET IF END
;
; WTDKBF : WRITE DISK BUFFER
;
WTDKBF  LDA D1BFHI+1,X  ; HI ADDR OF BUFFER HI ADDR
        SEC
        SBC D1BFLO+1,X  ; HI ADDR OF BUFFER LOW ADDR
        STA PGCNT       ; NUMBER OF PAGES
        LDA D1BFLO,X    ; SET MEMORY ADDRESS TO LOW
        STA MEMLO       ; BUFFER ADDRESS
        LDA D1BFLO+1,X
        STA MEMHI
        JSR BDMHTK      ; MOVE HEAD TO TRACK
        JMP DSKWRT      ; WRITE TO DISK AND RETURN
;
; PATCH2 (FROM $2462)
;
PATCH2  STY SECTNM      ; SET SECTOR NUMBER TO 1
        JMP LDHEAD      ; LOAD HEAD AND RETURN
;
; MODMIN : MODIFY MEMORY INPUT ADDRESS
;
; THIS ROUTINE IS USED ONLY BY THE INPUT FROM INDIRECT FILE
; FUNCTION (CTRL X). IF YOU WANT TO CHANGE THE LOCATION OF
; THE INDIRECT FILE, YOU MUST CHANGE THE ADDRESS HERE AND IN
; THE ROUTINE @$2551.
;
MODMIN  LDA #$80        ; HIGH ADDRESS FOR INDIRECT FILE
        STA MINADR+1    ; SAVE IT
        LDA #$00        ; LOW ADDRESS OF INDIRECT FILE
        RTS
;
; PTROUT : PARALLEL PRINTER OUTPUT DEVICE (BASIC DEVICE 4)
;
; NOTE: SOME OF THE NEWER PRINTERS ON THE MARKET ARE EQUIPPED WITH
; GRAPHICS AND NEED THE FULL 8 BITS OF AN OUTPUT BYTE TO USE
; THIS FEATURE. CHANGING THE INSTRUCTION AT $24A7 AND $24A8 TO
; NOP'S ($EA) WILL ALLOW THIS.
;
PTROUT  PHA             ; SAVE BYTE TO BE PRINTED
        EOR #$FF
        STA KPORT
        LDA KPORT
        EOR #$FF
        STA $2525
        PLA
        BIT $2525
        RTS
        .RES 27
;
; TERMOT : TERMINAL OUTPUT ROUTINE (BASIC DEVICE 1)
;
TERMOT  PHA
        LDA $F000
        LSR A
        LSR A
        BCC $24CE
        PLA
        STA $F001
        PHA
        LDA $F000
        LSR A           ; CHECK FOR INPUT READY
        BCC TORTN       ; NO KEY PRESSED, GO BACK
        JSR TERMIN      ; INPUT A CHARACTER
        STA KPDO        ; SAVE IT
        CMP #$13        ; CONTROL S?
        BNE TORTN       ; NO, GO BACK
        JSR TERMIN      ; YES, INPUT A BYTE
        CMP #$11        ; CONTROL Q?
        BNE *-5         ; ($24EA) NO, TRY AGAIN
TORTN   PLA             ; RESTORE THE OUTPUT BYTE
        STA A_HOLD      ; SAVE IT
        RTS
;
; TERMIN : SERIAL TERMINAL INPUT ROUTINE (BASIC DEVICE 1)
TERMIN  LDA $F000       ; GET ACIA STATUS
        INC RNDSED      ; BUMP THE RANDOM SEED
        LSR A           ; CHECK RCV READY
        BCC TERMIN      ; IF NOT TRY AGAIN
        LDA $F001       ; INPUT THE BYTE
        AND #$7F        ; KILL THE UPPER BIT
TIRTN   STA A_HOLD      ; SAVE THE CHARACTER
        RTS
;
; PATCH3 : ADDED TO X16INP ROUTINE (FROM $24B9)
;
PATCH3  LDA X16ACI+1,X  ; GET BYTE FROM ACIA
        BCS TIRTN       ; PUT IN A_HOLD AND RETURN
;
; SEROUT : 430 BOARD UART OUTPUT (BASIC DEVICE 3)
;
SEROUT  PHA             ; SAVE THE BYTE TO OUTPUT
        LDA UART+5      ; GET UART STATUS
        BPL SEROUT+1    ; ($250E) NOT READY, TRY AGAIN
        PLA             ; RESTORE THE OUTPUT CHARACTER
        STA UART+4      ; AND OUTPUT IT
        RTS
;
; SERINP : 430 BOARD UART INPUT (BASIC DEVICE 3)
;
SERINP  LDA UART+5      ; GET THE UART STATUS
        LSR A
        BCC SERINP      ; NOT READY, TRY AGAIN
        LDA UART+3      ; INPUT A BYTE
        STA UART+7      ; ACKNOWLEDGE INPUT
        STA IOTABL      ; SAVE THE BYTE
        RTS
;
; THE FOLLOWING IS A "WHO KNOWS" INSTRUCTION
; THIS IS ANOTHER CASE OF HOW TO USE UP COMPUTER TIME
;
        JSR $2544       ; JUMP SUBROUTINE TO RTS
;
; KBINP : POLLED KEYBOARD INPUT ROUTINE (BASIC DEVICE 2)
;
; THIS ROUTINE USES THE SAME ROUTINE AS THE ROM BASED MACHINES.
; UNFORTUNATELY, THE DISK BASIC USES SOME OF THE SAME MEMORY
; LOCATIONS AS THE ROUTINE AT $FD00. INSTEAD OF DOING THE CORRECT
; THING, WRITING A NEW ROUTINE FOR THE DOS, OSI MADE ANOTHER PATCH.
; EVERY TIME YOU INPUT FROM THE 540 KEYBOARD YOU MUST FIRST SWAP
; OUT 4 BYTES, CALL THE ROUTINE IN ROM @$FD00, AND THEN RESTORE
; THE 4 BYTES. HIGHLY INEFFICIENT!
;
KBINP   JSR SWAP4       ; SAVE $213-$216
        INC RNDSED      ; BUMP THE RANDOM SEED
        JSR $32CC       ; CALL THE ROUTINE
        BEQ KBINP+3     ; ($252E) IF NULL THEN TRY AGAIN
;
; THIS IS ANOTHER STRANGE INSTRUCTION. THE PRESENT KEYBOARD ROUTINE
; WAITS UNTIL A KEY IS PRESSED AND THEN RETURNS IT'S ASCII VALUE.
; A NULL IS NEVER RETURNED FROM THE PRESENT KEYBOARD ROUTINE SO
; IT MAKES NO SENSE TO CHECK FOR IT.
;
        STA A_HOLD      ; SAVE THE INPUT CHARACTER
        JSR SWAP4       ; RESTORE $213-$216
        LDA A_HOLD      ; GET THE INPUT CHARACTER
KIRTN   RTS
;
; PATCH 4 : USED BY 540 VIDEO DRIVER FOR KEY PRESSED DURING OUTPUT
; (FROM $25F2)
;
PATCH4  STA KPDO        ; SAVE THE CHARACTER
        PLA
        JMP TIRTN       ; SAVE A AND RETURN
;
; THIS IS AN UNDOCUMENTED RE-ENTRY POINT TO THE OS. ON VIDEO SYSTEMS
; WHEN YOU EXIT TO THE MONITOR AND THEN RE-ENTER THE OS AT $2A51, YOU
; WILL NORMALLY HAVE PROBLEMS WITH THE POLLED KEYBOARD ROUTINE. BY
; ENTERING AT $2547, THE 4 BYTES FROM $0213-$0216 ARE RESTORED AND THE
; KEYBOARD ROUTINE WILL WORK CORRECTLY.
;
        JSR SWAP4       ; SWAP THE 4 BYTES
        JMP OS65D3      ; JUMP TO THE OS
;
; CKINP : CHECK INPUT FOR INDIRECT FILE COMMANDS AND CONTROL P.
;
; THE CONTROL P IS A NICE FEATURE THAT WE HAVE NEVER SEEN DOCUMENTED
; BY OSI. UNDER VERSION 3.0 IT WAS A CONTROL T, WHILE UNDER
; VERSION , 3.2 IT HAS BEEN CHANGED TO A CONTROL P. THIS CONTROL
; CHARACTER, WHICHEVER ONE IT IS, FLIP-FLOPS A FLAG THAT CONTROLS
; PRINTER OUTPUT. THE FIRST TIME THE CONTROL CHARACTER IS ENCOUNTERED
; IT TURNS ON THE PRINTER DEVICE AND THE NEXT TIME IT TURNS IT OFF.
; WARNING! SOME OF THE SOFTWARE PROVIDED ON THE SYSTEM USES THIS
; FUNCTION. WHEN USING WP2 IF YOU USE THIS FEATURE DURING OUTPUT
; THE WORD PROCESSOR TURNS IT OFF WHEN DONE. HOWEVER THE ASSEMBLER
; DOES NOT AFFECT IT AND IT REMAINS ON UNTIL THERE IS ANOTHER
; CONTROL (T/P) INPUT FROM THE KEYBOARD. THE PRINTER DEVICE BIT
; IS AT LOCATION $2592.
;
CKINP   CMP #$5B        ; ([) START INDIRECT FILE?
        BNE CKIFND      ; NO, CONTINUE
        LDA #$80        ; SET UPPER ADDRESS FOR INDIRECT
        STA MOTADR+1    ; MODIFY MEMORY OUTPUT ROUTINE
        LDA #$00        ; SET LOWER ADDRESS FOR INDIRECT
        STA MOTADR      ; MODIFY MEMORY OUTPUT ROUTINE
        LDA OUTDST
        ORA #$10        ; SET MEMORY OUTPUT
        BNE CKIRTN      ; ALWAYS BRANCH TO EXIT
CKIFND  CMP #$5D        ; (]) CLOSE INDIRECT FILE?
        BNE CKCTLX      ; NO, CONTINUE
        JSR PRINT+3     ; PRINT 'J', BYPASS SAVAXY
        LDA DEFDEV      ; I/O DEFAULT DEVICE
        STA INDST       ; RESET INPUT POINTER
        LDA OUTDST      ; GET THE PRESENT OUTPUT DEVICE(S)
        AND #$EF        ; TURN OFF MEMORY OUTPUT
        STA OUTDST      ; SAVE THE OUTPUT DISTRIBUTOR
        LDA #$5D        ; PUT ']' BACK IN A
CKCTLX  CMP #$18        ; CONTROL X? (LOAD INDIRECT FILE)
        BNE CKCTLP      ; NO, CONTINUE
        LDA #$10
        STA INDST       ; SET FOR MEMORY INPUT
        JSR MODMIN      ; GOSUB TO SET INPUT HIGH ADDRESS
        STA MINADR      ; SET INPUT LOW ADDRESS
        BCS CKIRTN+3    ; ($2596) ALWAYS BRANCH TO EXIT
CKCTLP  NOP             ; CODE REMOVED IN V3.3
        NOP             ; CODE REMOVED IN V3.3
        BNE CKIRTN+5    ; ($2598) NO, JUMP TO EXIT
        LDA OUTDST      ; GET THE OUTPUT DISTRIBUTOR
        EOR #$08        ; FLIP-FLOP THE PRINTER OUTPUT
CKIRTN  STA OUTDST      ; SAVE THE DISTRIBUTOR
        LDA #$00        ; DENOTES CONTROL CHARACTER FOUND
        RTS
;
; VIDOUT : 540 VIDEO OUTPUT ROUTINE (BASIC DEVICE 2)
;
; THIS CODE WAS SIGNIFICANTLY IMPROVED OVER THE "GLASS TELETYPE"
; VIDEO OUTPUT CODE IN V3.2.
;
VIDOUT  LDA $2363
        JMP $32CF
        BRK
        BRK
        AND #$7F
        JMP PRINT
        JSR $37DA
        PHA
        AND #$8D
        BEQ L1
        CMP $2AC6
        BNE L2
L1      PLA
        RTS
L2      LDA #$00
        BNE L1
        LDY $2363
        LDX $31A9
        LDA #$00
        BNE MOVE
        CPY #$0C
        BEQ $25FE
        CPY #$0A
        BNE BSPACE
        INC $31AB
        CPX $31AB
        BCS L1
        BCC $2601
        BRK
        BRK
        NOP
        NOP
EXIT    LDA #$01        ; CHECK FOR 'CNTRL'
        JSR KEYTST
        BVC KTRTN       ; NO, WE ARE DONE
        LDA #$08        ; CHECK FOR 'S'
        JSR KEYTST
        BPL KTRTN       ; NO, WE ARE DONE
        LDA A_HOLD      ; RESTORE OUTPUT CHARACTER
        PHA             ; AND SAVE
        JSR KBINP       ; INPUT FROM POLLED KEYBOARD
        CMP #$13        ; CNTRL S?
        BEQ *-5         ; ($25EB) YES, KEEP LOOPING
        JMP PATCH4      ; EXIT THE ROUTINE
BSPACE
        CPY #$1B
        BNE $25B3
        DEC $25C0
        BNE $25B3
        INC $31AB
        TXA
        SEC
        SBC $31AB
        SEC
        ADC $31AA
        STA $25B6
        TAX
        LDA $235F
        LDY $2361
        PHA
        LDA #$0A
        JSR $2343
        DEX
        BNE $2617
        TXA
        STA $25B6
        STA $31AB
        PLA
        TAX
        JMP $31A1
MOVE    BMI $2638
        TYA
        PHA
        LDY #$00
        SEC
        SBC #$0A
        INY
        BCS $2630
        JMP $3180
        JMP $3193
        BRK
        BRK
;
; KEYTST : TEST POLLED KEYBOARD FOR KEYDOWN IN ROW IN ACCUM
;
KEYTST  JMP $249F
        BIT KPORT        ; CHECK FOR KEY DOWN
KTRTN   RTS
;
; SWAP4 : PATCH ADDED TO ENABLE USE OF POLLED KEYBOARD ROUTINE
; @$FD00. SWAPS OUT 4 BYTES FROM $213-$216 TO $2657-$265A
;
SWAP4   LDX #$03        ; SET INDEX FOR 4 BYTES
        LDA SWAP4A,X    ; SWAP A BYTE
        LDY SWAP4B,X
        STA SWAP4B,X
        TYA
        STA SWAP4A,X
        DEX
        BPL SWAP4+2     ; ($2646) IF ANOTHER CONTINUE
        RTS
;
SWAP4B  .RES 4          ; SWAP AREA FOR $0213-$0216
;
; DISK DRIVER ROUTINES AND STORAGE
;
        .BYTE $20       ; (UNKNOWN USAGE, IF ANY)
DSKDR   .RES 1          ; PRESENT DISK DRIVE
TKNUM   .RES 1          ; CURRENT TRACK NUMBER
SECTNM  .RES 1          ; PRESENT SECTOR NUMBER
PGCNT   .RES 1          ; PAGE COUNT
LAMB    .RES 1          ; LOW ADDRESS OF MEMORY BLOCK
HAMB    .RES 1          ; HI ADDRESS OF MEMORY BLOCK
TRKNM   .RES 1          ; HEX TRACK NUMBER
                        ; NOT USED, SEE NOTE @ $26A6
;
; HOME : HOMES HEAD TO TRACK 0 ON CURRENT DISK DRIVE
;
HOME    JSR STEPOT      ; STEP HEAD OUT
        JSR TENMS       ; DELAY 10 MS
        STY TKNUM       ; SET TRACK# TO 0
HOLOOP  LDA #$02        ; CHECK FOR TRACK 0
        BIT FLOPIN
        BEQ TENMS       ; DELAY 10MS AND RETURN IF TR 0
        JSR $2C54       ; STEP HEAD IN
        BNE HOLOOP      ; LOOP BACK AND THY AGAIN
;
; TENMS : 10 MS DELAY. ACTUALLY @ 1MHZ THE DELAY IS CLOSER TO 11 MS
;
TENMS   LDX #$0C
        LDY #$31        ; LOOP COUNT FOR  DELAY
        JSR $2707       ; DO 1 MS DELAY
        DEX
        BNE TENMS+2     ; ($267A) NOT DONE, KEEP ON
        RTS
;
; STEP IN : STEP TOWARDS 'TRACK 0
; MOVES EEAD ONE TRACK
STEPIN  LDA FLOPOT      ; TURN ON STEPIN BIT
        ORA #$04
        BNE STEP        ; GO STEP IN
;
; STEPOT : STEP HEAD AWAY FROM TRACK 0
; MOVES HEAD ONE THACK.
;
STEPOT  LDA #$FB        ; TURN OFF STEP IN BIT
        AND FLOPOT
STEP    STA FLOPOT
        JSR STEPIN-1    ; ($2682) KILLS 12 CLOCK CYCLES
        AND #$F7        ; TURN OFF STEP BIT
        JSR SETFLO      ; STA @ $C002 AND RETURN
        JSR $270D       ; ($270D) KILL 14 CYCLES
        ORA #$08        ; TURN ON STEP BIT
        JSR SETFLO      ; STA @ $C002 AND RETURN
        LDX #$08        ; STEP RATE
        BNE TENMS+2     ; ($267A) DELAY STEP RATE MS
;
; (ROUTINE @ $26A6) THIS ROUTINE CONVERTS A HEX TRACK NUMBER
; AT $2662 TO BCD AND STORES IT AT $EE, THEN FALLS INTO THE SET
; TRACK ROUTINE. THE ROUTINE IS NOT USED BY THE OS, SO EITHER
; IT IS USED BY BASIC, OR IT'S LEFT OVER FROM AN OLDER VERSION.
;
CNVHTN  LDA TRKNM
        SEC
        LDX #$FF        ; INIT X TO COUNT 10'S
        INX
        SBC #10         ; SUBTRACT 10 FROM TRACK#
        BCS *-3         ; ($26AC) IF >=0 BUMP X AND DO AGAIN
        ADC #10         ; ADD BACK LAST 10 FOR REMAINDER
        STA SCTLEN      ; SAVE REMAINDER
        TXA             ; GET NUMBER OF TENS
        ASL A           ; SHIFT TO HIGH NIBBLE
        ASL A
        ASL A
        ASL A
        ORA SCTLEN      ; COMBINE WITH REMAINDER
;
; SETTK : CHECK FOR VALID TRACK NUMBER AND MOVE HEAD THERE
; TRACK NUMBER IN ACCUMULATOR
;
SETTK   STA SCTLEN      ; SAVE TRACK NUMBER
        PHA
        BIT $269E       ; CHECK FOR 8 BIT
        BEQ ERR8-5      ; ($26CB) IF NOT, CONTINUE
        AND #$06        ; CHECK FOR 4 BIT OR 2 BIT
        BNE ERR8        ; YES, LOW NIBBLE > 9 : ERROR 8
        PLA             ; RESTORE TRACK NUMBER
        CMP #NUMTRACKS  ; TRACK < LAST?
        BCC MOVEHD      ; YES, CONTINUE
ERR8    LDA #$08        ; ERROR 8, BAD TRACK NUMBER
        BNE ERR6A+2     ; ($26DE) JUMP TO ERROR HANDLER
MOVEHD  LDA  DSKDR      ; GET DISK DRIVE
        AND  #$01       ; TOP DRIVE=1, BOTTOM DRIVE=0
        TAY
        JSR CKRDY       ; SEE IF DRIVE IS READY
        BCC CKTK        ; YES, CONTINUE
ERR6A   LDA #$06        ; DRIVE NOT READY : ERROR 6
        JMP ERRENT      ; JUMP TO OS ERROR ROUTINE
CKTK    LDA SCTLEN      ; RETRIEVE TRACK NUMBER
        CMP TKNUM       ; SAME AS PRESENT TRACK NUMBER?
        BEQ STCCNT-3    ; YES, DON'T MOVE THE HEAD
        BCS *+9         ; ($26F1) BRANCH IF > PRESENT TRACK
        JSR STEPIN      ; STEP HEAD IN ONE TRACK
        LDA #$99        ; SET TO SUBTRACT 1 FROM TKNUM
        BCC *+6         ; ($26F5) JUMP
        JSR STEPOT      ; MOVE HEAD OUT 1 TRACK
        TXA             ; X=1 : SET TO ADD 1 TO TKNUM
        SED
        ADC TKNUM       ; ADD OR SUBTRACT 1 FROM TKNUM
        STA TKNUM       ; AND SAVE
        CLD
        JMP CKTK        ; GO SEE IF WE ARE DONE
;
; DELAY : DELAY=18*Y+14 CYCLES (DELAY=896us IF Y=$C1)
;
DELAY   LDA $FA
        ASL A
        ASL A
        ASL A
        TAX
        RTS
        JSR $239B
        DEY
        BNE *-4
        NOP
        RTS
        LDY #$00
        RTS
;
; SET TRACK CODE CONTINUED FROM $26E6
;
STCCNT  BCS SETFLO      ; IF PAST TRACK 42, CONTINUE
        LDA #$40
        ORA FLOPOT      ; (PIA2) SET LOW CURRENT BIT
SETFLO  STA FLOPOT      ; STORE IT
        RTS
;
; WAITIH : WAIT FOR INDEX HOLE
;
WAITIH  LDA FLOPIN      ; GET DISK STATUS
        BMI WAITIH      ; IF BIT 7 ON, GO TEST AGAIN
        LDA FLOPIN      ; GET DISK STATUS
        BPL *-3         ; ($2722) IF BIT 7 OFF, TRY AGAIN
        RTS
;
; LDHDWI : LOAD HEAD AND WAIT FOR INDEX HOLD
;
LDHDWI  JSR LDHEAD      ; LOAD HEAD
;
; RSACIA : RESET DISK ACIA, WAIT FOR INDEX HOLE
;
RSACIA  JSR WAITIH      ; WAIT FOR THE INDEX 1I0LE
        LDA #$03
        STA ACIA        ; MASTER RESET FOR ACIA
        LDA #$58        ; SET FOR /1, RTS=1, NO INTERRUPT
        STA ACIA
        RTS
;
; EXAMCN : EXAM COMMAND CONTINUED , FIRST SECTION AT $2B37
;
EXAMCN  JSR LDHDWI      ; LOAD HEAD, WAIT FOR INDEX HOLE
        LDA FLOPIN      ; GET THE STATUS
        BPL UNLDHD      ; IF AT INDEX HOLE, UNLOAD HEAD
        LDA ACIA        ; GET ACIA STATUS
        LSR A
        BCC EXAMCN+3    ; ($273C) NOT READY, WAIT FOR INDEX
        LDA ACIAIO      ; READ A BYTE
        STA (MEMLO),Y   ; STORE IT IN MEMORY
        INY
        BNE EXAMCN+3    ; ($273C) IF MORE IN THIS PAGE
        INC MEMHI       ; BUMP MEMORY ADDRESS
        JMP EXAMCN+3    ; ($273C) CONTINUE
;
; LDHEAD : LOAD HEAD TO DISK
;
LDHEAD  LDA #$7F
        AND FLOPOT      ; SET BIT 7 TO 0
        STA FLOPOT
        LDX #$28        ; SET FOR 32 ms DELAY
        JMP TENMS+2
;
; UNLDHD : UNLOAD HEAD FROM DISK
;
UNLDHD  LDA #$80
        ORA FLOPOT      ; SET BIT 7 TO 1
        BNE LDHEAD+5    ; ($2759) JUMP
;
; INITAL : INITIALIZE ALL TRACKS (EXCEPT ZERO) ON CURRENT DRIVE
;
INITAL  LDA #LASTTRACK  ; SET HIGHEST TRACK NUMBER
        STA HSTTK
        JSR HOME        ; HOME THE HEAD
        JSR INCTKN      ; INCREMENT TRACK
        JSR INITTK      ; INITIALIZE THIS TRACK
        LDA TKNUM       ; GET CURRENT TRACK NUMBER
        CMP #LASTTRACK  ; AT LAST TRACK YET?
        BNE INITAL+7    ; ($276F) NO, KEEP ON
        RTS
;
; INITTK : INITIALIZE TRACK
;
INITTK  LDA #$02
        BIT FLOPIN      ; CHECK FOR TRACK 0
        BNE *+6         ; ($2788) NO, CONTINUE
ERE3    LDA #$03        ; DO ERROR #3
        BNE ERR4+2      ; JUMP TO ERROR HANDLER
        LDA #$20
        BIT FLOPIN      ; CHECK FOR WRITE PROTECT
        BNE ERR4+5      ; ($2794) NO, CONTINUE
ERR4    LDA #$04        ; DO ERROR #4
        JMP ERRENT      ; JUMP TO ERROR HANDLER
        JSR LDHDWI      ; LOAD HEAD AND WAIT FOR INDEX
        LDA #$FC        ; GET SET TO TURN ON
        AND FLOPOT      ; WRITE ENABLE AND ERASE ENABLE
        STA FLOPOT
        LDX #$0A        ; DO 1 ms DELAY
        JSR TENMS+2
        LDX #$43        ; TRACK START CODE BYTE1
        JSR DKWTX       ; WRITE IT
        LDX #$57        ; TRACK START CODE BYTE2
        JSR DKWTX       ; WRITE IT
        LDX TKNUM       ; GET THE TRACK NUMBER
        JSR DKWTX       ; WRITE IT
        LDX #$58        ; TRACK TYPE CODE
        JSR DKWTX       ; WRITE IT
        LDA FLOPIN      ; WAIT FOR INDEX, ERASE IS ON
        BMI *-3         ; ($27B9) NOT YET, TRY AGAIN
        LDA #$83        ; TURN OFF WRITE ENABLE, ERASE
        BNE UNLDHD+2    ; ($2763) ENABLE, UNLOAD HEAD & RET
;
; DKWTX : WRITE X TO DISK
;
DKWTX   LDA ACIA        ; GET ACIA STATUS
        LSR A
        LSR A
        BCC DKWTX       ; NOT READY, TRY AGAIN
        STX ACIAIO      ; WRITE X TO DISK
        RTS
;
; DSKBYT : GET BYTE FROM DISK
;
DSKBYT  LDA ACIA        ; GET ACIA STATUS
        LSR A
        BCC DSKBYT      ; NOT READY, TRY AGAIN
        LDA ACIAIO      ; READ THE BYTE
        RTS
;
; THE FOLLOWING IS NOT USED BY THE OS. MAY BE USED BY BASIC
        LDA LAMB       ; GET LOW ADDRESS OF MEMORY BLOCK
        STA MEMLO      ; SAVE AT MEMORY ADDRESS
        LDA HAMB       ; GET HIGH ADDRESS
        STA MEMHI      ; AND SAVE
;
; DSKWRT : WRITE SECTOR TO DISK ROUTINE
;
; TO USE THIS ROUTINE THE HEAD MUST ALREADY BE POSITIONED TO THE
; PROPER TRACK, THE NUMBER OF PAGES TO WRITE IN PGCNT ($265F), AND
; THE SECTOR NUMBER TO WRITE IN SECNM ($265E). STARTING
; ADDRESS OF DATA MUST BE IN MEMLO,MEMHI ($FE,$FF).
;
DSKWRT  LDA PGCNT       ; GET NUMBER OF PAGES
        BEQ ERRB        ; IF 0 DO ERROR B
        BPL *+6         ; ($27EC) IF BIT 7 IS ON DO ERROR B
ERRB    LDA #$0B        ; ERROR B ROUTINE
        BNE ERR4+2      ; ($2791) JUMP
        CMP #$09        ; IF>D, THEN ERROR B
        BPL ERRB
        LDA #$02        ; TEST FOR TRACK 0
        BIT FLOPIN
        BEQ DSKBYT+9    ; ($27D6) IF TRACK 0 THEN RETURN
        LSR A
        STA SCTLEN      ; PUT 1 IN SECTOR LENGTH
        LDA #$20        ; TEST FOR WRITE PROTECT
        BIT FLOPIN
        BNE *+6         ; ($2805) NOT WRITE PROTECT, CONTINUE
        LDA #$04        ; WRITE PROTECT IS ON, ERROR 4
        BNE DSKWRT+9    ; ($27EA) JUMP
        LDA #$01
        STA WRTRTY      ; SET RETRY COUNT
REWRT   LDA #$03
        STA RDRTYN      ; READ VERIFICATION RETRY COUNT
        JSR SETSCT      ; POSITION TO START OF SECTOR
        JSR DLYFA       ; DO 800us DELAY (SCTLEN = 1)
        LDA #$FE        ; SET WRITE ENABLE
        AND FLOPOT
        STA FLOPOT
        LDX #$02        ; DELAY 200us
        JSR HUNDUS
        LDA #$FF        ; TURN ON ERASE ENABLE
        AND FLOPOT
        STA FLOPOT
        JSR DLYFA       ; ANOTHER 800us DELAY
        LDX #$76
        JSR DKWTX       ; WRITE SECTOR START CODE
        LDX SECTNM      ; GET SECTOR NUMBER
        JSR DKWTX       ; WRITE IT
        LDX PGCNT       ; GET THE PAGE COUNT
        STX TS2         ; SAVE IT
        JSR DKWTX       ; WRITE PAGE COUNT
        LDY #$00        ; SET INDEX
WRTPG   LDA (MEMLO),Y   ; WRITE PAGE OF MEMORY TO DISK
        TAX
        JSR DKWTX       ; WRITE TO DISK
        INY
        BNE WRTPG       ; ($2840) NOT DONE, LOOP BACK
        INC MEMHI       ; BUMP HIGH MEMORY ADDRESS
        DEC TS2         ; DROP PAGE COUNT
        BNE WRTPG       ; IF ANOTHER PAGE THEN CONTINUE
        LDX #$47        ; WRITE 'G' TO DISK
                        ; (SECTOR START CODE)
        JSR DKWTX
        LDX #$53        ; WRITE 'S' TO DISK
                        ; (SECTOR START CODE)

        JSR DKWTX
        LDA PGCNT       ; GET PAGE COUNT
        ASL A           ; MULTIPLY BY 2
        STA TS2         ; SAVE IT
        ASL A           ; MULTIPLY BY 2 AGAIN
        ADC TS2         ; ADD TOGETHER, = 6*PAGE COUNT
        TAX
        JSR HUNDUS      ; 100us DELAY*PAGE COUNT
        LDA FLOPOT
        ORA #$01        ; TURN OFF WRITE ENABLE
        STA FLOPOT
        LDX #$05
        JSR HUNDUS      ; 500us DELAY
        LDA #$02
        JSR SETFLO-3    ; ($2716) TURN OFF ERASE ENABLE
RTYCMP  CLC
        TXA             ; ADD X TO HIGH MEMORY ADDRESS
        ADC MEMHI       ; X=0 FIRST TIME WE COMPARE
        SEC             ; X=# OF SECTORS NOT COMPARED
                        ; IF THIS IS A RETRY
        SBC PGCNT       ; RESET HIGH MEMORY ADDRESS
        STA MEMHI
        JSR $2905      ; COMPARE DATA WRITTEN TO DISK
;
; WARNING! IF WRITE STARTED FROM PAGE 0, ABOVE ROUTINE WILL
; READ FROM DISK INSTEAD OF COMPARE.
;
        BCS DKBT9-1     ; ($28AF) NO FAULT SO RETURN
        DEC RDRTYN      ; DROP COMPARE RETRY COUNT
        BNE RTYCMP      ; IF NOT 0 THEN TRY AGAIN
        DEC WRTRTY      ; DROP WRITE RETRY COUNT
        BMI ERR2        ; IF DONE THEN ERROR 12
        TXA
        ADC MEMHI       ; RESET MEMORY ADDRESS
        SEC
        SBC PGCNT
        STA MEMHI
        JMP REWRT       ; WRITE TO DISK AGAIN
ERR2    LDA #$02        ; ERROR #2
        BNE ERR9+2      ; ($28C1) ALWAYS JUMP
;
; DLYFA : 800us DELAY TIMES VALUE IN SCTLEN ($FA)
;
DLYFA   JSR $2700       ; GO COMPUTE VALUE FOR X
;
; HUNDUS : APPROXIMATELY 100us DELAY PER X
;
HUNDUS  LDA NMHZ        ; GET DELAY COUNT
        BIT PAGE0       ; KILL 3 CYCLES
        SEC
        SBC #$05        ; SUBTRACT 5 FROM DELAY COUNT
        BCS HUNDUS+3    ; ($28A5) IF >=0 THEN DO AGAIN
        DEX
        BNE HUNDUS      ; DO X TIMES
        RTS
;
; DKBT9 : GET BYTE FROM DISK, ERROR #9 IF INDEX HOLD
;
DKBT9   LDA FLOPIN      ; GET DISK STATUS
        BPL ERR9        ; IF INDEX HOLE THEN ERROR #9
;
; WARNING: $28B4 IS MODIFIED BY THE D9 COMMAND @ $2823
;
        LDA ACIA        ; CHECK ACIA STATUS
        LSR A
        BCC DKBT9       ; NOT READY, KEEP LOOKING
        LDA ACIAIO      ; GET BYTE FROM DISK
        RTS
ERR9    LDA #$09        ; ERROR #9, CAN'T FIND SECTOR
        JMP ERRENT
RDCDSK
SETSCT
        JSR $272B
        JSR $28B0
        CMP #$43
        BNE $28C7
        JSR $28B0
        CMP #$57
        BNE $28CA
        JSR $27CD
        CMP $265D
        BEQ $28E1
        LDA #$05
        BNE $28C1
        JSR $27CD
        DEC $265E
        BEQ $28FD
        LDA #$00
        STA $F9
        JSR $2998
        BCC $2901
        LDA $265E
        CMP $F9
        BNE $28ED
        CMP $FB
        BNE $2901
        INC $265E
        RTS
        LDA #$0A
        BNE $28C1
        PHA
        JSR $28C4
        JSR $28B0
        CMP #$76
        BNE $2909
        JSR $27CD
        CMP $265E
        BEQ $291B
        PLA
        CLC
        RTS
        JSR $27CD
        TAX
        STA $265F
        LDY #$00
        PLA
        BEQ $2943
        LDA $C010
        LSR A
        BCC $2927
        LDA $C011
        BIT $C010
        BVS $2919
        CMP ($FE),Y
        BNE $2919
        INY
        BNE $2927
        INC $FF
        DEX
        BNE $2927
        SEC
        RTS
        LDA $C010
        LSR A
        BCC $2943
        LDA $C011
        BIT $C010
        BVS $2919
        STA ($FE),Y
        INY
        BNE $2943
        INC $FF
        DEX
        BNE $2943
        SEC
        RTS
;
; SET MEMORY ADDRESS POINTER TO DISK BUFFER ADDRESS
; NOT USED BY OS.
;
        LDA LAMB
        STA MEMLO
        LDA HAMB
        STA MEMHI
;
; READDK : READ DISK, THIS TRACK INTO MEMORY @($FE)
;
READDK  LDA #$03        ; SET RETRY COUNT WHEN HEAD MOVED
        STA RDRTYM
        LDA #$07        ; SET RETRY COUNT W/O MOVING HEAD
        STA RDRTYN
RTYRD   LDA #$00        ; DENOTES READ
        JSR $2905       ; READ SECTOR INTO MEMORY
        BCC DKRDRY+3    ; ($297A) IF FAULT OCCURRED, RETRY
        RTS
;
; DKRDRY : DISK READ RETRY
;
DKRDRY  DEC MEMHI       ; RESET MEMORY ADDRESS
        INX
        CPX PGCNT
        BNE DKRDRY      ; NOT DONE, CONTINUE
        DEC RDRTYN      ; DROP RETRY COUNT
        BNE RTYRD       ; NOT 0, TRY AGAIN W/O MOVING HEAD
        JSR STEPIN      ; STEP HEAD IN
        JSR TENMS       ; 10ms DELAY
        JSR STEPOT      ; STEP HEAD OUT
        JSR TENMS
        DEC $F7         ; DROP RETRY COUNT
        BPL $296B
        LDA #$01
        JMP $2A4B
        LDA $C000
        BPL $29C4
        LDA $C010
        LSR A
        BCC $2998
        LDA $C011
        CMP #$76
        BNE $2998
        JSR $27CD
        STA $FB
        JSR $27CD
        STA $FA
        INC $F9
        TAY
        LDX #$00
        JSR $27CD
        DEX
        BNE $29B9
        DEY
        BNE $29B9
        SEC
        RTS
        CLC
        RTS
BPSECT
;
; SETDRV : SET FOR DRIVE IN ACCUMULATOR
;
SETDRV  STA $265C       ; SET TRACK NUMBER
        ASL A           ; MULTI BY 2 : A=2,B=4,C=6,D=8
        TAX
        AND #$02        ; ISOLATE DRIVE: A=1,B=0,C=1,D=0
        TAY
        LDA DKINIT-2,X  ; INITIALIZE PIA FROM INIT TABLE
        STA FLOPIN
        LDA DKINIT-1,X
        STA FLOPOT
;
; CKRDY : CHECK FOR DRIVE READY, RETURNS WITH CARRY CLEAR IF READY
;
CKRDY   LDA FLOPIN      ; PUT READY BIT IN CARRY FLAG
        LSR A
        PHP             ; SAVE CARRY STATUS
        CPY #$00        ; IF TOP DRIVE THEN RETURN
        BNE DKINIT-2    ; ($29E9)
        PLP             ; RESTORE STATUS
        LSR A           ; PUT BIT 4 IN CARRY
        LSR A
        LSR A
        LSR A
        RTS
        PLP             ; RESTORE STATUS
        RTS
;
; DISK INITIALIZATION TABLE
;
DKINIT  .BYTE $40       ; DRIVE A
        .BYTE $FF
        .BYTE $00       ; DRIVE B
        .BYTE $FF
        .BYTE $40       ; DRIVE C
        .BYTE $DF
        .BYTE $00       ; DRIVE D
        .BYTE $DF
;
; DIRCNT : DIR COMMAND CONTINUED (FROM $2B2C)
;
DIRCNT  TAX             ; PUT TRACK NUMBER IN X
        BEQ DKINIT-39   ; ($29E7) 0 II THEN RETURN
        PHA             ; SAVE TRACK NUMBER
        JSR SETTK       ; MOVE HEAD TO TRACK
        JSR STROUT      ; PRINT THE FOLLOWING MESSAGE
        .BYTE $0D,$0A,"TRACK ",0
        PLA             ; RESTORE THE TRACK NUMBER
        JSR PRT2HX      ; PRINT TRACK NUMBER
        TSX             ; SAVE STACK ADDRESS
        STX STKADR
        JSR LDHEAD      ; LOAD HEAD TO DISK
        INX
        STX SECTNM      ; PUT 1 IN SECTOR NUMBER
        JSR SETSCT      ; POSITION FOR SECTOR 1
        LDA #$00        ; CLEAR SECTORS BYPASSED COUNT
        STA SCTBYP
        JSR $2998       ; BYPASS THIS SECTOR
        LDA SCTNUM
        PHA             ; SAVE SECTOR NUMBER
        LDA SCTLEN
        PHA             ; SAVE SECTOR LENGTH
        BCS *-9         ; ($2A1B) IF WE DIDN'T HIT THE INDEX
                        ; HOLE, TRY AGAIN
        LDX STKADR      ; GET ORIGINAL STACK ADDRESS
        BCC *+15        ; ($2A37) AND JUMP
        JSR CRLF        ; PRINT CR/LF
        LDA #$20        ; PRINT SPACE AND SECTOR NUMBER
        JSR DCPRNT
        LDA #$2D        ; PRINT - AND SECTOR LENGTH
        JSR DCPRNT
        DEC SCTBYP      ; DROP SECTORS BYPASSED COUNT
        BPL *-15        ; ($2A2A) IF MORE TO DO, CONTINUE
        LDX STKADR      ; RESET STACK ADDRESS
        TXS
        JMP UNLDHD      ; UNLOAD HEAD AND RETURN
DCPRNT  JSR PRINT       ; PRINT ACCUMULATOR
        LDA STACK,X     ; GET NEXT BYTE OFF STACK
        DEX             ; GET SET FOR THE: NEXT ONE
        JMP PRT2HX      ; PRINT AS 2 HEX CHAR. AND RETURN
;
; ** KERNEL **
;
; ERRENT : OS ERROR ENTRY. ERROR # IN ACCUMULATOR
;
ERRENT  JSR OSERR
        JMP $1756
;
; WHILE IT MAKES LITTLE SENSE TO DO A DIRECT JUMP TO THE NEXT
; MEMORY LOCATION, THIS MAKES IT POSSIBLE TO ALTER THE EXIT
; FROM THE OS ERROR ROUTINE SO THAT IT WILL RETURN TO ANOTHER
; PLACE OTHER THAN THE OS. THIS CAN BE DONE WITH THE SETERR
; ROUTINE @ $2A7D. IF YOU ARE USING THE OS FROM YOUR OWN PROGRAM,
; YOU MAY ALSO WISH TO MODIFY THE OSERR ROUTINE TO NOT PRINT THE
; ERROR MESSAGE, IN WHICH CASE YOU WOULD NEED TO SET A FLAG TO INFORM
; YOUR PROGRAM THAT AN ERROR HAD OCCURRED.
;
; OS65D3 : ENTRY POINT FOR OS65D MAIN LOOP
;
OS65D3  LDX #$28
        TXS             ; SET STACK
;
; THE TOP OF STACK IS SET TO $28 SINCE THE NON-MASKABLE INTERRUPT
; VECTOR IS SET TO $0130. WE WON'T EVEN COMMENT ON HOW ASININE IT
; IS TO PUT THE INTERRUPT VECTORS IN THE STACK AREA.
;
        LDA #$51        ; SET OS ERROR RETURN TO OS
        LDY #$2A
        JSR SETERR
        JSR CRLF
        LDA DSKDR       ; GET PRESENT DISK DRIVE
        CLC
        ADC #$40        ; ACCUM NOW HAS LETTER OF
                        ; PRESENT DISK DRIVE
        JSR PRINT       ; PRINT IT
        LDA #'*'
        JSR PRINT       ; PRINT '*'
        JSR OSINP       ; DO INPUT TO OS BUFFER
        LDA #$2E        ; OS INPUT BUFFER HI ADDRESS
        STA OSIBAD+1
        LDA #$1E        ; OS INPUT BUFFER LOW ADDRESS
        STA OSIBAD
        JSR EXCOM       ; GO EXECUTE COMMAND
        JMP OS65D3      ; LOOP BACK FOR ANOTHER COMMAND
;
; SETERR : SET OS ERROR RETURN, LOW ADDRESS IN A
;          HIGH ADDRESS IN Y
;
SETERR  STA ERRENT+4    ; ($2A4F)
        STY ERRENT+5    ; ($2A50)
        RTS
;
; EXCOM : EXECUTE OS COMMAND SUBROUTINE
;
; TO EXECUTE OS COMMANDS FROM OTHER PROGRAMS EITHER PLACE THE COMMAND
; IN THE OS BUFFER (@$2E1E) AND DO A JSR TO EXCOM, OR PUT THE COMMAND
; IN MEMORY, SET THE BUFFER POINTER ($E1,E2) TO YOUR BUFFER. THEN DO
; A JSR TO EXCOM. YOU WOULD PROBABLY ALSO WANT TO SET THE OS ERROR
; RETURN TO YOUR OWN PROGRAM
;
EXCOM   LDX #$00        ; X=OFFSET INTO DISPATCH TABLE
        STX BUFOFS      ; CLEAR BUFFER OFFSET
                        ; USED BY BUFBYT
        LDY #$00        ; Y=OFFSET INTO BUFFER
        LDA DSPTBL,X    ; FIRST CHARACTER IN DISPATCH
                        ; TABLE ENTRY
        BEQ ERR7        ; IF 0 THEN DO ERROR #7
        JSR $3732
        NOP
        INY             ; BUMP BUFFER INDEX
        LDA DSPTBL+1,X  ; SECOND CHAR. IN TABLE ENTRY
        JSR $3732
        NOP
        LDA DSPTBL+3,X  ; GET HIGH ADDRESS FROM TABLE
        PHA
        LDA DSPTBL+2,X  ; GET LOW ADDRESS
        PHA
        JSR BUFBYT      ; GET BYTE FROM BUFFER
        CMP #$00D       ; CHECK FOR 'CR'
        BEQ NXTENT-1    ; ($2AB9) IF IT IS, EXECUTE COMMAND
        CMP #$20        ; CHECK FOR A 'SPACE'
        BNE *-9         ; (S2AA4) IF NOT, TRY AGAIN
        JSR BUFBYT      ; GET BYTE FROM BUFFER
        CMP #$20        ; CHECK FOR A 'SPACE'
        BEQ *-5         ; ($2AAF) IF SO, LOOK AGAIN
        DEC BUFOFS      ; POINT TO FIRST NONSPACE
        RTS             ; JUMP TO ADDRESS FROM TABLE
NXTENT  INX             ; INCREMENT TO NEXT TABLE ENTRY
        INX             ; EACH ENTRY IS 4 BYTES
        INX
        INX
        BNE EXCOM+5     ; ($2A89) GO BACK IF MORE TABLE
ERR7    LDA #$07        ; SYNTAX ERROR #7
        BNE ERRENT      ; JUMP TO OS ERROR ENTRY
;
; OSERR : OS ERROR ROUTINE, ERROR I# IN ACCUMULATOR
;
; ALWAYS CALLED FROM $2A4B. NOTE THAT THE I/O DISTRIBUTORS ARE
; RESET TO THE DEFAULT DEVICE ON ANY ERROR.
;
OSERR   PHA
        LDA #$01        ; GET DEFAULT I/O DISTRIBUTOR
        STA INDST       ; AND RESET
        STA OUTDST
        JSR STROUT      ; PRINT THE FOLLOWING
.BYTE   " ERR #",0
        PLA
        JSR PRTHEX      ; PRINT THE ERROR NUMBER
        JMP UNLDHD      ; UNLOAD HEAD AND RETURN
;
; ASM : ASSEMBLER COMMAND
;
ASM     LDA #$07        ; FIRST TRACK NUMBER
        JSR LDCMN       ; COMMON CODE
        JMP STASM       ; JUMP TO START OF ASSEMBLER
;
; BASIC : BASIC COMMAND
;
BASIC   LDA #$02        ; FIRST TRACK NUMBER
        JSR LDCMN       ; COMMON CODE
        JMP STBAS       ; JUMP TO START OF BASIC
;
; LDCMN : LOAD LANGUAGE COMMON ROUTINE
; LOADS 3 TRACKS STARTING WITH TRACK IN ACCUM INTO MEMORY @ $0200 & UP
;
LDCMN   JSR SETTK       ; POSITION HEAD TO FIRST TRACK
        LDX #$02
        STX TS1         ; # OF TRACKS-1 TO READ
        STX MEMHI       ; MEMORY ADDRESS HIGH=2
        DEX
        STX SECTNM      ; SET SECTOR TO 1
        DEX
        STX MEMLO       ; MEMORY ADDRESS LOW=0
        DEX
        STX HSTTK       ; HIGHEST TRACK = $FF
        JSR $3179       ; LOAD HEAD TO DISK
        JSR READDK      ; READ TRACK INTO MEMORY
        DEC TS1
        BMI D9-3        ; ($2820) IF NO MORE TRACKS, DONE
        JSR INCTKN      ; BUMP TRACK NUMBER AND SET HEAD
        JMP $2B04       ; ($2804) CONTINUE
;
; CALL : CALL COMMAND, READ SECTOR INTO .MEMORY
;
CALL    JSR GETADR      ; MEMORY ADDRESS @$FE,FF
        JSR CKEQL       ; LOOK FOR = SIGN
        JSR GETTK       ; GET TRACK # AND SECTOR
        JSR LDHEAD      ; LOAD HEAD TO DISK
        JSR READDK      ; READ DISK INTO MEMORY
        JMP UNLDHD      ; UNLOAD HEAD AND RETURN
;
; D9 : DISABLE ERROR 9
;
D9      LDA #$00
        STA DKBT9+4     ; ($28B4) CHANGE DKBT9 ROUTINE
        RTS
;
; DIR : DIRECTORY COMMAND, PRINT SECTOR MAP OF TRACK
;
DIR     JSR BLDHEX      ; GET TRACK NUMBER FROM BUFFER
        JMP DIRCNT      ; GOTO ACTUAL CODE
;
; EM : CALL AND ENABLE EXTENDED MONITOR
EM      LDA #$07        ; GET FIRST TRACK NUMBER
        JSR LDCMN       ; COMMON CODE
        JMP STEM        ; GOTO START OF EXTENDED MONITOR
;
; EXAM : EXAM TRACK INCLUDING FORMATTING INFORMATION
;
; THIS IS A REALLY NICE COMMAND, EXCEPT THEY DON'T GIVE YOU ANY
; EASY WAY TO PUT THE DATA BACK ONTO THE DISK.
;
EXAM    JSR GETADR      ; MEMORY ADDRESS @$FE,FF
        JSR CKEQL       ; LOOK FOR EQUAL SIGN
        JSR BLDHEX      ; GET TRACK NUMBER
        JSR SETTK       ; MOVE HEAD TO TRACK
        JMP EXAMCN      ; JUMP TO REST OF CODE
;
; GO : GO COMMAND
;
GO      JSR BLDHEX      ; GET HIGH ORDER ADDRESS
        STA GOADR+2     ; ($2B54) SAVE IT
        JSR BLDHEX      ; GET LOW ORDER ADDRESS
        STA GOADR+1     ; ($2B53) SAVE IT
GOADR   JMP PH          ; GO TD ADDRESS ENTERED
;
; INIT : INITIALIZATION COMMAND
;
INIT    JSR BUFBYT      ; GET BYTE FROM BUFFER
        CMP #$0D
        BEQ FULINT      ; IF 'CR' THEN DO ENTIRE DISK
                        ; OTHERWISE, DO ONE TRACK
        DEC BUFOFS      ; RESET BUFFER POINTER
        JSR BLDHEX      ; GET TRACK NUMBER
        JSR SETTK       ; MOVE HEAD TO TRACK
        JMP INITTK      ; INITIALIZE TRACK AND RETURN
FULINT  JSR STROUT      ; PRINT THE MESSAGE
        .BYTE "ARE YOU SURE?",0
        JSR INECHO      ; INPUT AND ECHO 1 CHARACTER
        CMP #'Y'
        BNE LOAD-1      ; ($2BA6) IF NOT 'Y' THEN RETURN
        JMP INITAL      ; DO REST OF CODE
;
; IO : I/O COMMAND (SEE NOTE AT $2339)
;
IO      JSR BUFBYT      ; GET BYTE FROM BUFFER
        CMP #','        ; IF ',' DO OUTPUT ONLY
        BEQ ONLYO       ; RESET BUFFER POINTER
        DEC BUFOFS
        JSR BLDHEX      ; GET INPUT FLAG
        STA INDST       ; SAVE IT
        JSR BUFBYT      ; GET BYTE FROM BUFFER
        CMP #$0D
        BEQ LOAD-1      ; ($2BA6) IF 'CR' THEN RETURN
        DEC BUFOFS      ; RESET BUFFER POINTER
        JSR CKEQL+3     ; CHECK FOR COMMA
ONLYO   JSR BLDHEX      ; GET OUTPUT FLAG
        STA OUTDST      ; STORE IT
        RTS
;
; LOAD : LOAD COMMAND
;
LOAD    JSR FNDFL       ; FIND FILE NAME IN DIRECTORY
        JSR SETPGM      ; SET MEMORY ADDRESS & LOAD HEAD
        STX TS1         ; X=0 USED AS # OF TRACKS READ
        BEQ *+5         ; ($2BB4) SKIP NEXT INSTR 1ST TIME
        JSR INCTKN      ; BUMP TRACK NUMBER
        JSR READDK      ; READ TRACK INTO MEMORY
        INC TS1         ; BUMP TRACKS READ
        DEC $3A7D       ; DROP NUMBER OF TRACKS TO READ
        BNE *-11        ; ($2BB1) IF MORE TRACKS, CONTINUE
        LDA TS1
        STA $3A7D       ; RESET NUMBER OF TRACKS IN FILE
        JMP $327B      ; UNLOAD HEAD AND RETURN
;
; MEM : MEMORY COMMAND
;
MEM     LDX #$00        ; SET OFFSET FOR INPUT ADDRESS
        JSR $2BD0       ; ($2BD0) GET FROM BUFFER AND SAVE IT
        JSR CKCOMA      ; CHECK FOR COMMA
        LDX #$07        ; SET OFFSET FOR OUTPUT ADDRESS
        JSR BLDHEX      ; GET HIGH ORDER ADDRESS
        STA MINADR+1,X  ; SAVE IT
        JSR BLDHEX      ; GET LOW ORDER ADDRESS
        STA MINADR,X    ; SAVE IT
        RTS
;
; PUT : PUT COMMAND
;
; THERE IS A SERIOUS FLAW IN THE PUT COMMAND. IT ALWAYS WRITES WHOLE
; TRACKS STARTING @ $3179. IF YOU HAVE A VERY LARGE FILE IN MEMORY,
; SUCH AS A WORD PROCESSOR FILE, AND IT GOES BEYOND $B578 THEN THE
; LANGUAGES (BASIC, ASSEMBLER, WORD PROCESSOR) WILL COMPUTE 13
; TRACKS TO BE PUT TO DISK. UNFORTUNATELY, ATTEMPTING TO PUT OUT
; 13 TRACKS WILL CAUSE THE SYSTEM TO WRITE THE DISK CONTROLLER
; MEMORY TO DISKI!! THE READ AFTER WRITE CHECK WILL FAIL AND YOU
; WILL GET AN ERROR 2. IF YOU DON'T SEE THE ERROR WHEN IT OCCURS,
; AND ATTEMPT TO LOAD THE FILE LATER, VERY CURIOUS ERRORS HAPPEN.
; THE SIMPLEST FIX FOR THIS PROBLEM IS TO LIMIT THE AMOUNT OF MEMORY
; THE COMPUTER THINKS YOU HAVE BY CHANGING HIMEM @ $2300 TO $B4.
;
PUT     JSR FNDFL       ; FIND FILE NAME IN DIRECTORY
        JSR SETPGM      ; SET MEMORY ADDRESS, LOAD HEAD
        LDA $3A7D       ; GET NUMBER OF TRACKS
        STA TS1         ; SAVE IT
        LDA #$08        ; NUMBER OF PAGES
;
; YET ANOTHER EXAMPLE OF AN OSI BLUNDER. EACH TRACK ON THE DISK
; IS CAPABLE OF HOLDING 13 SECTORS BUT THE PROGRAMMERS AT OSI
; ONLY USE 11 IN THE PUT COMMAND. THERE IS NO LOGICAL REASON
; TO DO THIS, MAYBE THEY THOUGHT THAT THIS WOULD HELP THEM TO
; SELL MORE DISKS. YOU MAY CHANGE THIS, AS WE HAVE, TO USE 12
; OR 13 SECTORS PER TRACK BY CHANGING THE PREVIOUS LDA #$0B TO
; LDA $0C OR $0D. IF YOU DO DECIDE TO UTILIZE THE WASTED
; SECTORS WE WOULD ADVISE YOU TO GO TO A 12 SECTOR PER TRACK
; FORMAT AS THIS IS THE MOST THAT BASIC WILL RECOGNIZE.
; THIS WILL NOT HELP YOU WHEN SAVING BASIC OR ASSEMBLER PROGRAMS
; OR WORD PROCESSOR FILES AS ALL OF THESE LANGUAGES CALCULATE
; THE NUMBER OF TRACKS TO BE WRITTEN TO DISK BASED ON 11
; SECTORS PER TRACK. HOWEVER, IF YOU ARE DOING DISK I/O FROM
; YOUR OWN MACHINE LANGUAGE PROGRAMS, SUCH AS THE TEXT EDITOR
; USED TO PREPARE THIS DOCUMENT, YOU CAN USE 12 SECTORS PER TRACK
; WITHOUT ANY PROBLEM.
;
        JSR $3274       ; SAVE IT
        JSR DSKWRT      ; WRITE TO DISK
        DEC TS1         ; DROP TRACK COUNT
        BEQ *+8         ; ($2BFA) IF NO MORE THEN DONE
        JSR INCTKN      ; BUMP TRACK NUMBER AND STEP HEAD
        JMP $2BED       ; ($2BED) LOOP BACK & ,WRITE THIS TRACK
        JMP $009C       ; UNLOAD HEAD AND RETURN
;
; RET : RESTART COMMAND
;
; (*) NOTE, NOT ALL OF THESE WILL BE SET AT THE SAME TIME.
; EACH LANGUAGE SET IT'S OWN RESTART ADDRESS AND SETS THE
; OTHERS TO REPORT AN ERROR. OF COURSE, THE ASSEMBLER/EXTENDED MONITOR
; SETS BOTH RETURN ADDRESSES.
;
RET     JSR BUFBYT      ; GET BYTE FROM BUFFER
        CMP #'A'
        BNE *+5         ; ($2C07) NOT 'A' THEN CONTINUE
        JMP RTASM       ; REENTER ASSEMBLER (*)
        CMP #'B'
        BNE *+5         ; ($2C0E) NOT 'B' THEN CONTINUE
        JMP $2AC0       ; REENTER BASIC (*)
        CMP #'E'
        BNE *+5         ; ($2C15) NOT 'E' THEN CONTINUE
        JMP STEM        ; ENTER EXTENDED MONITOR (*)
        CMP #'M'
        BNE *+8         ; ($2CIF) NOT 'M ' THEN ERROR #7
        JSR SWAP4       ; SWAP 4 BYTES FOR VIDEO ROUTINE
        JMP ($FEFC)     ; JUMP TO RESET VECTOR
        JMP ERR7        ; DO ERROR #7
;
; XQT : LOAD FILE AND GO @$317E
;
; ONE USEFUL CHANGE TO THIS ROUTINE IS TO MAKE THE JUMP AT $2C25
; INTO AN INDIRECT JUMP TO $3179 (6C 79 31). SINCE THE PROGRAM MUST
; BE IN LOAD FORMAT ANYWAY, THIS WOULD ALLOW YOU TO HAVE A DISK
; BUFFER OR TWO AT THE FRONT OF THE WORKSPACE AND USE THE BASIC
; DISK I/O ROUTINES IN A STRAIGHTFORWARD FASHION.
;
XQT     JSR LOAD        ; DO LOAD
        JMP $3A7E       ; JUMP TO START OF PROGRAM
;
; SAVE : SAVE COMMAND, WRITE SECTOR TO DISK
;
SAVE    JSR GETTK       ; GET TRACK# AND POSITION HEAD
        JSR CKEQL       ; CHECK FOR =
        JSR GETADR      ; GET MEMORY ADDRESS AND PUT @$FE,FF
        JSR CKEQL+6     ; CHECK FOR '/'
        JSR GETHEX      ; GET NUMBER OF PAGES FROM BUFFER
        STA PGCNT       ; SAVE IT
        JSR LDHEAD      ; LOAD HEAD
        JSR DSKWRT      ; WRITE TO DISK
        JMP UNLDHD      ; UNLOAD HEAD AND RETURN
;
; SELECT : SELECT DISK DRIVE
; SETS PARAMETERS FOR DRIVE AND HOMES HEAD
;
SELECT  JSR BUFBYT      ; GET BYTE FROM BUFFER
        SBC #$3F
        CMP #$05
        BCS $2C5B
        STA $FD
        JSR $29C6
        JMP $2663
        JSR $2683
        INC $FD
        BNE $2C6F
ERR6    LDA #$06        ; DO ERROR #6
        JMP ERRENT
;
; COMMON ROUTINES USED BY KERNEL
;
; GETTK : GET TRACK NUMBER & SECTOR FROM BUFFER & POSITION HEAD
;
GETTK   JSR BLDHEX      ; GET TRACK NUMBER
        JSR SETTK       ; CHECK TRACK AND MOVE HEAD THERE
        JSR CKCOMA      ; CHECK FOR COM~IA
        JSR GETHEX      ; GET SECTOR NUMBER
        STA SECTNM      ; SAVE IT
        RTS
;
; SETPGM : SET UP FOR PROGRAM
;
SETPGM  JSR SETTK       ; SET HEAD TO TRACK
        LDA #$3A        ; SET MEMORY ADDRESS TO $3179
        STA MEMHI
        LDA #$79
        STA MEMLO
        LDA #$01
        STA SECTNM      ; SET SECTOR NUMBER TO 1
        JMP LDHEAD      ; LOAD HEAD AND RETURN
;
; INCTKN : INCREMENT TRACK NUMBER
;
INCTKN  LDA TKNUM       ; GET TRACK NUMBER
        CLC
        SED
        ADC #$01        ; ADD 1 IN DECIMAL
        CLD
        CMP HSTTK       ; IS THIS HIGHEST TRACK NUMBER?
        BEQ *+4         ; ($2C91) YES, LET'S CONTINUE
        BCS *+5         ; ($2C94) HIGHER, DO ERROR D
        JMP SETTK       ; SET HEAD AT TRACK AND RETURN
ERRD    LDA #$0D        ; ERROR D
        BNE ERR6+2      ; ($2C5D) JUMP TO ERROR
;
NXTOSN  JSR CRLF        ; SET FOR NEXT OS INPUT
;
; OSINP : OS INPUT ROUTINE
;
; NOTE: THIS ROUTINE DOES NOT TRAP ILLEGAL CONTROL CHARACTERS.
; IF YOU PRESS 'BACKSPACE' ($08), THE PREVIOUS CHARACTER WILL
; BE ERASED, BUT BOTH THE 'BACKSPACE' AND THE CHARACTER WILL
; STILL BE IN THE BUFFER AND YOU WILL GET AN ERROR #7 EVEN
; THOUGH THE INPUT COMMAND LOOKS CORRECT.
;
OSINP   LDA #$11        ; SET BUFFER SIZE
        STA MAXBUF
        LDX #$00        ; X=CHARACTER COUNT
NXTOSI  JSR INECHO      ; GET A CHARACTER
        CMP #$5F        ; IS IT THE 'UNDERLINE'
        BNE OSIOK       ; CONTINUE IF NOT
        DEX             ; MOVE BACK ONE CHARACTER
        BMI NXTOSN      ; TRY AGAIN
                        ; BACKSPACED AT FIRST CHARACTER
        STA OSBUF,X     ; PUT IT IN BUFFER
        JSR STROUT      ; DO BACKSPACE
;
; THIS PRINT FIRST DOES 2 BACKSPACES TO POSITION THE CURSOR
; AT THE CHARACTER TO BE DELETED. THE FIRST IS NECESSARY TO GET
; PAST THE UNDERLINE OR LEFT ARROW AND THE SECOND TO GET TO THE
; CHARACTER THAT WAS INPUT. THE ROUTINE THEN PRINTS 2 SPACES, 1
; TO ELIMINATE THE CHARACTER THAT WAS ENTERED AND ANOTHER TO
; ELIMINATE THE UNDERLINE OR LEFT ARROW. THE CURSOR IS THEN
; BACKSPACED TWICE TO REPOSITION IT SO YOU ARE READY TO
; ENTER THE CORRECT CHARACTER.
;
        .BYTE 8,8,"  ",8,8,0
        JMP NXTOSI      ; CONTINUE
OSIOK   CMP #$15        ; CHECK FOR CONTROL U
        BEQ NXTOSN      ; IF SO IGNORE INPUT UP TO NOW
        STA OSBUF,X     ; PUT IN BUFFER
        CMP #$0D        ; CHECK FOR 'CR'
        BEQ *+11        ; ($2CD0) IF SO THEN WE ARE DONE
        INX             ; BUMP INDEX
        CPX #$11        ; CHECK FOR MAXIMUM LENGTH
        BNE NXTOSI      ; NOT DONE SO CONTINUE
        LDA #$0D        ; BUFFER FULL, STOP INPUT AND PROCESS
        BNE OSIOK+4     ; ($2CC0) JUMP
        JMP CRLF
        BRK             ; (UNUSED)
        BRK             ; (UNUSED)
        BRK             ; (UNUSED)
;
; INPUT: INPUT ROUTINE. CHECKS FOR CONTROL CHARACTERS.
;
; (SEE NOTE AT $2339)
; WHEN WRITING YOUR OWN INPUT ROUTINES TO BE USED WITH THE OS
; YOU SHOULD STORE THE INPUT CHARACTER IN A_HOLD BEFORE RETURNING
; FROM YOUR ROUTINE SINCE THE INPUT ROUTINE RESTORES A,X,Y
; WHEN IT RETURNS. IF YOU DO NOT DO THIS YOUR INPUT WILL BE THE
; CHARACTER IN A WHEN THE ROUTINE WAS CALLED.
;
INPUT   JSR SAVAXY
        JSR DOINP       ; GO DO INPUT
        JSR CKINP       ; CHECK FOR CONTROL CHARACTERS
        BEQ INPUT+3     ; ($2CDF) IF SO CONTINUE INPUT
        JMP RSTAXY      ; RESTORE REGISTERS AND GO BACK
;
; BUFBYT : GET BYTE FROM BUFFER
;
BUFBYT  LDY #$0A        ; GET OFFSET INTO BUFFER
                        ; MORE SELF MODIFYING CODE
        LDA (OSIBAD),Y  ; LOAD BYTE
        JMP $3A6A
        NOP
        CPY #$11        ; CHECK FOR END OF BUFFER
        BEQ *+6         ; ($2CF4) IF SO THEN RETURN
        INC BUFOFS      ; BUMP THE OFFSET
        RTS
        LDA #$0D        ; LOAD A 'CR'
        RTS             ; RETURN, BUFFER IS FULL
;
; SWAP : SWAP PAGE 0 AND 1 WITH $2F79 AND UP (USED BY BASIC)
; THIS ROUTINE IS NOT CALLED ANYWHERE BY THE OS
;
SWAP    PLA             ; CHANGE RETURN ADDRESS
        CLC             ; INTO JUMP @$2D20
        ADC #$01
        STA GETADR-2    ; ($2D21)
        PLA
        ADC #$00
        STA GETADR-1    ; ($2D22)
        LDX #$00        ; SET THE OFFSET
SWAPLP  LDA STACK,X     ; GET BYTE FROM PAGE 1
        LDY SWAP1,X     ; GET BYTE FROM SWAP AREA
        STA SWAP1,X     ; SAVE THE BYTE FROM PAGE 1
        TYA
        STA STACK,X     ; SAVE THE BYTE FROM SWAP AREA
        LDA PAGE0,X     ; GET BYTE FROM PAGE 0
        LDY SWAP0,X     ; GET BYTE FROM SWAP AREA
        STA SWAP0,X     ; SAVE BYTE FROM PAGE 0
        STY PAGE0,X     ; SAVE BYTE FROM SWAP AREA
        INX             ; BUMP THE OFFSET
        BNE SWAPLP      ; NOT DONE, KEEP ON
        JMP PH          ; ADDRESS FOR JUMP IS CHANGED ABOVE
;
; GETADR : GET MEMORY ADDRESS FROM BUFFER
;
GETADR  JSR BLDHEX
        STA MEMHI       ; HIGH ORDER BYTE
        JSR BLDHEX
        STA MEMLO       ; LOW ORDER BYTE
        RTS
;
; BLDHEX : BUILD HEX BYTE FROM BUFFER
; RESULT IS IN ACCUM
;
BLDHEX  JSR GETHEX      ; GET BYTE FROM BUFFER
        ASL A
        ASL A
        ASL A
        ASL A
        STA TS1         ; SAVE UPPER FOUR BITS
        JSR GETHEX      ; GET SECOND BYTE
        ORA TS1         ; COMBINE WITH FIRST BYTE
        RTS
;
; GETHEX : GET 1 HEX DIGIT FROM BUFFER
;
GETHEX  JSR BUFBYT      ; GET BYTE FROM BUFFER
        SEC
        SBC #$30
        CMP #$0A
        BCC *+10        ; ($2D4F) IF <10 THEN RETURN
        SBC #$11
        CMP #$06
        BCS *+10        ; ($2055) IF > F THEN ERROR
        ADC #$0A
        RTS
;
; THIS CODE USED BY BASIC AND POSSIBLY THE OTHER LANGUAGES
;
        LDA PAGE0       ; DO WE NEED TO SWAP PAGES 0/1
        BEQ SWAP        ; YES, GO DO IT
        RTS
;
        JMP ERR7        ; GOT HERE FROM $2D4B
;
; CKEQL : CHECK FOR '=' OR ',' OR '/'
;
; THREE ENTRY POINTS -> CKEQL=$2D58 : CKCOMA=$2D5B : CKSLSH=$2D5E
; ANOTHER EXAMPLE OF TURNING A TWO BYTE INSTRUCTION INTO A THREE
; BYTE 'HARMLESS' INSTRUCTION. (SEE NOTE @ $28E6)
; FORTUNATELY, THIS TIME THEY ARE HARMLESS.
CKCOMA  = $2D5B
CKSLSH  = $2D5E
CKEQL   LDA #'='
        BIT $2CA9
        BIT $2FA9
        STA TS1         ; SAVE CHARACTER TO TEST
        JSR BUFBYT      ; GET BYTE FROM BUFFER
        CMP TS1
        BNE CKEQL-3     ; ($2D55) IF NOT THEN ERROR #7
        RTS
;
; CRLF : PRINT CR,LF TO ALL ACTIVE DEVICES
;
CRLF    LDA #$0D        ; DO 'CR'
        JSR PRINT
        LDA #$0A        ; DO 'LF'
        BNE FNDFL-3     ; ($2DA3) JUMP TO PRINT
;
; STROUT : PRINT STRING FOLLOWING JSR THAT GOT US HERE
;
; THE STRING CAN BE ANYTHING, BUT MUST BE TERMINATED BY A NULL.
; STRING LENGTH IS LIMITED TO 255 CHARACTERS.
; THIS IS A VERY USEFUL ROUTINE, BUT BE WARNED THAT IT CAN REALLY
; PLAY HAVOC WITH YOUR PROGRAM IF YOU FORGET TO PUT THE NULL
; DELIMITER ON YOUR STRING.
;
STROUT  PLA             ; PULL RETURN ADDRESS OFF STACK
        STA STROAD      ; STORE LOW ADDRESS
        PLA
        STA STROAD+1    ; STORE HIGH ADDRESS
        LDY #$01        ; SET TO INDEX THROUGH STRING
        LDA (STROAD),Y  ; GET BYTE FROM STRING
        BEQ *+8        ; ($2D85) IF NULL THEN WE ARE DONE
        JSR PRINT       ; PRINT IT IF NOT
        INY             ; GET SET FOR NEXT CHARACTER
        BNE *-8         ; ($2D7B) JUMP AND CONTINUE
        TYA
        SEC             ; GET SET TO FIND RETURN ADDRESS
        ADC STROAD      ; ADD LENGTH OF STRING TO ADDRESS
        STA STROAD      ; SAVE IT
        BCC *+4         ; ($2D8F) NO CARRY SO UPPER BYTE IS 01
        INC STROAD+1    ; BUMP THE UPPER BYTE
        JMP (STROAD)    ; JUMP PAST PRINTED STRING
;
; PRT2HX : PRINT 2 HEX CHARACTERS OF ACCUMULATOR
;
PRT2HX  PHA             ; SAVE THE CHARACTER
        LSR A           ; PUT UPPER NIBBLE IN LOWER NIBBLE
        LSR A
        LSR A
        LSR A
        JSR PRTHEX      ; PRINT THE UPPER 4 BITS
        PLA             ; RESTORE THE CHARACTER
;
; PRTHEX : PRINT HEX OF LOW NIBBLE IN ACCUMULATOR
; GOOD HEX TO ASCII CONVERSION
;
PRTHEX  AND #$0F        ; MASK UPPER 4 BITS
        CMP #$0A        ; SET CARRY IF >9 AND CLEAR
                        ; CARRY IF <10
        SED
        ADC #$30        ; IF CARRY SET THEN A=$41
                        ; IF CARRY CLEAR 9=$39
        CLD
        JMP PRINT
;
; FNDFL : FIND FILE NAME IN DIRECTORY
;
; ONE OF THE MOST USEFUL ROUTINES IN THE OS IF YOU ARE WRITING
; YOUR OWN MACHINE LANGUAGE PROGRAMS. PUT THE NAME OF THE FILE YOU ARE
; LOOKING FOR IN A BUFFER, EITHER THE OS BUFFER @ $2E1E OR YOUR OWN.
; THE FILE NAME SHOULD BE DELIMITED BY A CR IF IT IS SHORTER THAN
; SIX CHARACTERS. IF YOU ARE USING YOUR OWN BUFFER, IT'S ADDRESS
; SHOULD BE PUT IN $E1,$E2. THE BUFFER OFFSET @ $2CE5 MUST BE
; SET, EITHER TO ZERO IF THE FILE NAME IS AT THE BEGINNING OF THE
; BUFFER, OR TO WHATEVER OFFSET IN THE BUFFER THE FIRST CHARACTER
; OF THE FILE NAME IS AT. THEN CALL THIS ROUTINE.
; RETURNS WITH STARTING TRACK IN A, LAST TRACK @ $E5 .
;
FNDFL   LDA #LASTTRACK
        STA HSTTK       ; SET HIGHEST TRACK NUMBER
        JSR BUFBYT      ; GET BYTE FROM BUFFER
        DEC BUFOFS      ; SET POINTER BACK
        CMP #$41
        BPL *+12        ; ($2DBE) IF ALPHA THEN LOOK FOR NAME
        LDX #$00        ; HERE IF TRACK NUMBER ENTERED
        LDA #LASTTRACK
        STA SCRBUF+1,X
        JMP BLDHEX      ; GET TRACK# IN A AND RETURN
;
; LOAD BY NAME
;
        LDA BUFOFS      ; GET POINTER
        STA TS1         ; SAVE IT
        LDA #$12        ; TRACK NUMBER FOR DIRECTORY
        JSR SETTK       ; MOVE TO TRACK 8
        STY SECTNM      ; SECTNM=0
        JMP NEWDS       ; JUMP AROUND A LITTLE
        LDX #$00
NXTCHR  JSR BUFBYT      ; GET BYTE FROM BUFFER
        CMP #$0D
        BNE *+4         ; ($2DD9) IF NOT 'CR' THEN CONTINUE
        LDA #$20        ; IF 'CR' USE 'SPACE' FOR COMPARE
        JSR $373C       ; COMPARE TO DIRECTORY ENTRY
        BNE NXTDE       ; IF NOT = TRY NEXT ENTRY
        INX             ; BUMP OFFSET
        TXA
        AND #$07
        CMP #$06
        BNE NXTCHR      ; IF WE HAVEN'T LOOKED AT ALL
                        ; 6 CHARACTERS THEN CONTINUE
        LDA SCRBUF+1,X  ; MATCH! GET LAST TRACK#
        STA HSTTK       ; SAVE IT
        LDA SCRBUF,X    ; GET STARTING TRACK#
        RTS
NXTDE   TXA             ; NEXT DIR ENTRY SETUP
        AND #$F8        ; KILL LOWER 3 BITS IN OFFSET
        CLC
        ADC #$08        ; SET TO NEXT DIR ENTRY
        TAX
        BEQ NEWDS       ; IF END OF SECTOR GET NEXT
NXTDS   LDA TS1         ; RESTORE BUFFER OFFSET
        STA BUFOFS
        JMP NXTCHR      ; JUMP BACK AND TRY AGAIN
NEWDS   INC SECTNM      ; BUMP SECTOR NUMBER
        LDA SECTNM
        CMP #$03
        BMI *+7         ; ($2E0F) IF < 3 THEN CONTINUE
ERRC    LDA #$0C        ; ERROR C, FILE NOT FOUND
        JMP ERRENT
        LDA #$79        ; SET MEMORY ADDRESS TO $2E79
        STA MEMLO       ; (SCRATCH BUFFER, 256 BYTES)
        LDA #$2E
        STA MEMHI
        JSR CALL+9      ; ($2B1A) LOAD HEAD, READ DISK,
                        ; UNLOAD HEAD
        LDX #$00        ; BUFFER OFFSET
        BEQ NXTDS       ; SEARCH THIS DIRECTORY SECTOR
;
; TABLES AND STORAGE FOR OS65D
;
; OS65D INPUT BUFFER @$2E1E TO $2E2F
;
OSBUF   .RES 18
;
; OS65D DISPATCH TABLE
;
; ADDRESS IN TABLE = ACTUAL ADDRESS OF ROUTINE - 1
; ADDRESS IN TABLE IS PUSHED ON STACK AND THEN CALLED
; BY DOING AN RTS.
;
DSPTBL  .BYTE "AS"
        .WORD ASM-1
        .BYTE "BA"
        .WORD BASIC-1
        .BYTE "CA"
        .WORD CALL-1
        .BYTE "D9"
        .WORD $2AC0-1
        .BYTE "DI"
        .WORD DIR-1
        .BYTE "EM"
        .WORD EM-1
        .BYTE "EX"
        .WORD EXAM-1
        .BYTE "GO"
        .WORD GO-1
        .BYTE "HO"
        .WORD HOME-1
        .BYTE "IN"
        .WORD INIT-1
        .BYTE "IO"
        .WORD IO-1
        .BYTE "LO"
        .WORD LOAD-1
        .BYTE "ME"
        .WORD MEM-1
        .BYTE "PU"
        .WORD PUT-1
        .BYTE "RE"
        .WORD RET-1
        .BYTE "XQ"
        .WORD XQT-1
        .BYTE "SA"
        .WORD SAVE-1
        .BYTE "SE"
        .WORD SELECT-1
        .BYTE 0
;
; THE REST OF THE OS MEMORY AREA IS WORKING STORAGE LOCATIONS
;
SCRBUF  .RES 256        ; SCRATCH BUFFER FOR DIRECTORY
;
; THIS AREA IS ALSO USED BY THE BASIC GET/PUT LOGIC.
; YOU CAN USE THIS PAGE FOR TRANSIENT CODE BY CALLING IT HERE.
; JUST BE SURE THAT YOU DON'T DO A DIRECTORY SEARCH OR USE BASIC'S
; RANDOM DISK I/O. A GOOD PLACE TO PUT SUCH CODE IS ON TRACK 8
; IN SECTORS 6 & UP SINCE THIS AREA IS NOT USED FOR ANY OTHER
; PURPOSE.
;
SWAP0   .RES 256        ; PAGE 9 HOLD AREA (USED BY BASIC)
SWAP1   .RES 256        ; STACK  "    "     "    "  "

; BELOW CODE IS NEW IN V3.3

        LDA #$04
        STA $E0
        JMP $2754
        STY $31AA
        PLA
        SEC
        SBC $31AA
        STA $31A9
        STA $31AB
        DEC $25C0
        BPL $31A1
        INC $25C0
        CPY #$50
        BEQ $31AC
        CPY #$43
        BNE $31A6
        INC $25C0
        LDA #$00
        STA $2363
        JMP $25B3
        EOR ($01,X)
        BRK
        INC $25B6
        LDA $235F
        PHA
        LDA $2361
        PHA
        LDA #$00
        JSR $2343
        JSR $31CD
        PLA
        STA $2361
        PLA
        STA $235F
        DEC $25B6
        JMP $31A1
        JSR $3233
        JSR $32FC
        JSR $3321
        LDA #$AF
        LDX #$DF
        JSR $324C
        STY $E6
        JSR $3268
        INC $E6
        LDX $E6
        JSR $3330
        LDY #$00
        LDA ($E2),Y
        LDX #$07
        CMP $323C,X
        BEQ $3202
        DEX
        BPL $31EF
        CMP #$7F
        BCS $31FF
        CMP #$20
        BCS $3212
        LDA #$20
        INX
        LDA ($E0),Y
        AND #$01
        CMP $3244,X
        BEQ $320F
        TXA
        EOR #$0F
        TAX
        TXA
        ORA #$A0
        JSR $2343
        CPY $F5
        INY
        BCC $31EB
        JSR $3268
        JSR $3263
        LDA $E6
        CMP $F4
        BCC $31DF
        LDA #$AF
        LDX #$AC
        JSR $324C
        JSR $331E
        JSR $3305
        JSR $2D73
        ORA $0A0A
        ASL A
        BRK
        RTS
        JSR $A6A8
        TXS
        .BYTE $A7
        STA $A5AA,X
        BRK
        BRK
        BRK
        ORA ($00,X)
        ORA ($00,X)
        ORA ($48,X)
        JSR $3263
        TXA
        JSR $2343
        PLA
        LDY $F5
        ORA #$80
        JSR $2343
        DEY
        BPL $3257
        TXA
        JSR $2343
        LDA #$0D
        JMP $2343
        LDA #$DC
        JMP $2343
        .BYTE 'C'
        .BYTE $23
        JSR $0D3B
        .BYTE $DA
        JSR $AC20
        BRK
        LDX #$F8
        BNE $3280
        JSR $2761
        LDX #$08
        LDA $FE
        PHA
        LDA $FF
        PHA
        LDA #$79
        STA $FE
        LDA #$3A
        STA $FF
        STX $32C8
        LDY #$03
        JSR $32C2
        LDY #$01
        JSR $32C2
        LDA $0200
        CMP #$29
        BNE $32BB
        LDY #$00
        LDA ($FE),Y
        INY
        TAX
        LDA ($FE),Y
        STX $FE
        LDX $32C8
        BPL $32B4
        CLC
        ADC #$08
        STA $FF
        JSR $32C2
        BNE $32A2
        PLA
        STA $FF
        PLA
        STA $FE
        RTS
        LDA ($FE),Y
        BEQ $32CB
        CLC
        ADC #$08
        STA ($FE),Y
        RTS
        JMP $3590
        JSR $33C0
        JMP $25D7
        .BYTE $CB
        CMP $CB,X
        CMP ($FF),Y
        ORA a:$40
        BRK
        ORA $00,X
        ORA $15
        .BYTE $AB       ; $32E2 - Selects cursor character (normally $AB/171)
        ASL $0D20
        .BYTE $34
        ASL $3F
        .BYTE $0B
        .BYTE $2F
        .BYTE $8B
        BNE $3300
        BPL $32FA
        ORA $1F
        .BYTE $17
        .BYTE $17
        STA $D0
        ASL $3F
        .BYTE $0B
        .BYTE $2F
        .BYTE $8B
        BNE $328A
        .BYTE $EF
        .BYTE $32
        STX $32ED
        STY $32EE
        LDX #$17
        LDA $E0,X
        LDY $32D5,X
        STA $32D5,X
        STY $E0,X
        DEX
        BPL $3307
        LDY $32EE
        LDX $32ED
        LDA $32EF
        RTS
        LDA $ED
        BIT $EFA5
        PHA
        JSR $332E
        LDA ($E2),Y
        TAX
        PLA
        STA ($E2),Y
        RTS
        LDX $EB
        LDA #$00
        STA $E3
        TXA
        LDY $F2
        ASL A
        ROL $E3
        DEY
        BNE $3337
        ADC $F6
        STA $E2
        STA $E0
        LDA $E3
        ADC $F7
        STA $E3
        ADC #$04
        STA $E1
        LDY $EA
        RTS
        LDA #$FF
        PHA
        EOR $F3
        PHA
        TXA
        TAY
        LDX $F4
        BCS $3367
        LDA #$00
        PHA
        LDA $F3
        ADC #$00
        PHA
        TXA
        LDY $F4
        STA $E9
        PLA
        STA $E6
        PLA
        STA $E7
        TYA
        PHA
        TXA
        PHA
        JSR $3330
        LDA $E2
        STA $E0
        LDA $E3
        STA $E1
        JSR $339A
        PLA
        TAX
        JSR $3330
        JSR $339A
        PLA
        TAX
        JSR $3330
        LDY $F5
        JSR $357E
        DEY
        DEY
        BPL $3390
        LDA #$00
        RTS
        LDA $F4
        SEC
        SBC $E9
        TAX
        BEQ $33BF
        LDA $E0
        STA $E2
        CLC
        ADC $E6
        STA $E0
        LDA $E1
        STA $E3
        ADC $E7
        STA $E1
        LDY $F5
        LDA ($E0),Y
        STA ($E2),Y
        DEY
        BPL $33B5
        DEX
        BNE $33A2
        RTS
        PHA
        JSR $32FC
        JSR $3321
        PLA
        LDX $E8
        BEQ $33F4
        BPL $33EC
        STA $E9
        INC $E8
        CMP #$02
        BEQ $33E6
        CMP #$1F
        BEQ $33E8
        CMP #$1D
        BEQ $33E8
        CMP #$11
        BEQ $33E6
        CMP #$16
        BNE $3461
        INC $E8
        INC $E8
        BNE $33FC
        STA $E5,X
        DEC $E8
        BNE $33FC
        BEQ $3461
        LDX $E4
        BMI $33FE
        BNE $33FC
        DEC $E4
        LDA #$00
        CMP #$1B
        BNE $3404
        DEC $E8
        LDX $EB
        CMP #$08
        BNE $3417
        DEY
        BPL $3417
        DEX
        BPL $3415
        INX
        JSR $3350
        TAX
        LDY $F5
        CMP #$10
        BNE $3424
        CPY $F5
        BNE $3423
        LDA #$0A
        LDY #$FF
        INY
        CMP #$0D
        BNE $342A
        LDY #$00
        CMP #$0A
        BNE $343C
        CPX $F4
        BNE $343B
        LDX #$00
        STY $EA
        JSR $335C
        BEQ $3459
        INX
        CMP #$0E
        BNE $3447
        INY
        TYA
        ORA #$07
        TAY
        BNE $3475
        STX $EB
        STY $EA
        CMP #$20
        BCC $3459
        STA ($E2),Y
        LDA $EE
        STA ($E0),Y
        LDA #$10
        BNE $33F4
        JSR $331E
        STX $EF
        JMP $364B
        LDA $E9
        LDX $EB
        CMP #$12
        BNE $346D
        LDX #$00
        BEQ $3428
        CMP #$11
        BNE $3481
        LDX $E6
        LDY $E7
        CPY $F5
        BEQ $347B
        BCS $3459
        CPX $F4
        BEQ $3447
        BCC $3447
        CMP #$0B
        BEQ $342E
        CMP #$0C
        BNE $348F
        DEX
        BPL $3447
        INX
        LDA #$1A
        CMP #$13
        BNE $3496
        JSR $335C
        CMP #$1A
        BNE $349D
        JSR $3350
        CMP #$1F
        BNE $34A5
        LDX $E6
        BCS $34B3
        CMP #$01
        BNE $34AD
        LDX #$00
        BCS $34B3
        CMP #$19
        BNE $34B5
        LDX #$0E
        STX $EE
        CMP #$05
        BNE $34C7
        TYA
        ADC #$40
        STA $E7
        TXA
        ADC #$41
        STA $E6
        LDA #$03
        BNE $34D1
        CMP #$21
        BNE $34D5
        LDA ($E2),Y
        STA $E6
        LDA #$02
        STA $E4
        LDA #$00
        CMP #$0F
        BNE $34DD
        LDX $F4
        BCS $34E1
        CMP #$18
        BNE $34F5
        CPY $F5
        JSR $357E
        BCC $34E1
        INX
        JSR $3330
        LDY #$00
        CPX $F4
        BCC $34E1
        BEQ $34E1
        TYA
        CMP #$16
        BNE $3520
        CLC
        TXA
        ADC $E6
        CMP $F4
        BCS $356F
        TYA
        ADC $E7
        CMP $F5
        BCS $356F
        TYA
        ADC $E2
        STA $E2
        BCC $3511
        INC $E3
        LDX #$01
        LDA $E2,X
        STA $F6,X
        LDA $E6,X
        STA $F4,X
        DEX
        BPL $3513
        BMI $355E
        CMP #$14
        BNE $352A
        LDY #$02
        LDX #$05
        BNE $3532
        CMP #$15
        BNE $3545
        LDY #$03
        LDX #$0B
        STA $EC
        STY $D800
        LDY #$05
        LDA $32F0,X
        STA $00F2,Y
        DEX
        DEY
        BPL $3539
        LDA #$1C
        LDY #$00
        STY $E2
        STY $E0
        LDX #$D0
        STX $E3
        LDX #$D4
        STX $E1
        LDX #$04
        CMP #$1C
        BNE $3561
        JSR $357E
        BNE $3559
        JMP $3469
        CMP #$02
        BEQ $356A
        CMP #$1D
        BNE $356F
        CLC
        JSR $3572
        BNE $356A
        JMP $3459
        LDA ($E0),Y
        AND #$0F
        EOR $E6
        BNE $3586
        LDA $E7
        BCS $3584
        LDA #$20
        STA ($E2),Y
        LDA #$0E
        STA ($E0),Y
        INY
        BNE $358E
        INC $E3
        INC $E1
        DEX
        TXA
        RTS
        JSR $32FC
        LDX $E4
        BMI $359E
        DEC $E4
        LDY $E4,X
        JMP $363B
        INC $F1
        LDA $F1
        AND #$0F
        BNE $35B2
        JSR $331E
        LDA $F1
        AND #$10
        BNE $35B2
        .BYTE $20       ; $35AF - Sets flashing cursor (normally $20/32). $2C/44 selects non-flashing cursor.
        .BYTE $21
        .BYTE $33
        LDX #$01
        JSR $364E
        PHA
        INX
        LDY #$06
        JSR $364E
        BNE $35C9
        DEY
        TXA
        ASL A
        TAX
        BCC $35BB
        TAY
        BCS $35E0
        PHA
        TYA
        ASL A
        ASL A
        ASL A
        STA $32EF
        PLA
        LDX #$FF
        INX
        ASL A
        BCC $35D4
        TXA
        ADC $32EF
        TAX
        LDY $365C,X
        TYA
        BEQ $3608
        PLA
        BMI $35EE
        CPY $F0
        BNE $35EE
        LDY #$00
        BEQ $363B
        PHA
        AND #$20
        BEQ $3608
        CPX #$0C
        BCS $3608
        STY $F0
        LDY #$1B
        STY $32EF
        PLA
        LDA $3694,X
        DEC $E8
        PHA
        JMP $33C4
        PLA
        STY $F0
        CPY #$0D
        BEQ $363B
        CPY #$20
        BEQ $363B
        CPY #$00
        BEQ $363B
        PHA
        AND #$07
        LDX #$20
        CPY #$00
        BPL $3624
        AND #$06
        LDX #$10
        LSR A
        BCC $362C
        BEQ $362E
        LDX #$30
        BIT $04F0
        TXA
        EOR $F0
        TAY
        PLA
        AND #$40
        BEQ $363B
        TYA
        AND #$1F
        TAY
        LDX #$07
        DEC $32EF
        BNE $363D
        DEX
        BNE $363D
        TYA
        AND #$7F
        STA $32EF
        JMP $3305
        TXA
        EOR #$FF
        STA $DF00
        STA $DF00
        LDA $DF00
        EOR #$FF
        RTS
        LDA ($B2),Y
        .BYTE $B3
        LDY $B5,X
        LDX $B7,Y
        BRK
        CLV
        LDA $BAB0,Y
        LDA a:$007F
        BRK
        LDX $6F6C
        TXA
        ORA a:$0000
        BRK
        .BYTE 'w'
        ADC $72
        .BYTE 't'
        ADC $6975,Y
        BRK
        .BYTE 's'
        .BYTE 'd'
        ROR $67
        PLA
        ROR A
        .BYTE 'k'
        BRK
        SEI
        .BYTE 'c'
        ROR $62,X
        ROR $AC6D
        BRK
        ADC ($61),Y
        .BYTE 'z'
        JSR $BBAF
        BVS $3695
        .BYTE $14
        ORA $12,X
        CLC
        .BYTE $0C
        .BYTE $0B
        .BYTE $1A
        BRK
        .BYTE $13
        ORA $0001,Y
        JSR $2343
        PLA
        ROR A
        BCS $36AD
        LDA #$11
        JSR $2343
        JSR $00C0
        JSR $0E10
        JSR $1618
        PHA
        TXA
        JSR $2343
        PLA
        CMP #$2C
        BNE $36C5
        JSR $00C0
        BNE $36B3
        JSR $0E0D
        PLA
        PLA
        JMP $0A32
        BRK
        BRK
        LDA #$00
        BNE $36D6
        JMP $1CD1
        JSR $0A73
        LDA #$00
        STA $19
        LDA #$00
        STA $1A
        PLA
        PLA
        LDA #$FF
        STA $87
        JSR $08AC
        JMP $07B4
        CMP $232C
        BNE $36F9
        PLA
        PLA
        PLA
        PLA
        JMP $2291
        PHA
        LDA $232D
        BEQ $3707
        LDX #$00
        JSR $2477
        JSR $2761
        PLA
        JSR $17D8
        RTS
        CMP #$46
        BEQ $3713
        JMP $0E1E
        JSR $00C0
        BEQ $3710
        CMP #$2C
        BNE $3713
        JSR $00C0
        JSR $0CCD
        JSR $0CBE
        JSR $1520
        STA $2CED
        STX $E1
        STY $E2
        JMP $1953
        JSR $3744
        BEQ $370B
        PLA
        PLA
        JMP $2ABA
        STA $374D
        LDA $2E79,X
        BNE $3749
        STA $374D
        LDA ($E1),Y
        JSR $3A5F
        CMP #$4D
        RTS
        BRK
        BRK
        BRK
        BRK
        .BYTE $1B
        BRK
        .BYTE 'G'
        .BYTE 'b'
        .BYTE 'D'
        BPL $3766
        BPL $3764
        PHP
        .BYTE $7F
        .BYTE '_'
        .BYTE $14
        ASL $09
        .BYTE $12
        RTI
        .BYTE $07
        JSR $0D7B
        .BYTE $04
        .BYTE $04
        .BYTE 'O'
        .BYTE $07
        BRK
        BRK
        .BYTE $FF
        BRK
        LDY $87
        INY
        BEQ $3778
        JMP $10D0
        JSR $00C6
        BEQ $3797
        CMP #$21
        BNE $3788
        JSR $00C0
        BEQ $37A4
        BNE $3794
        JSR $00C6
        BCC $378F
        BCS $3794
        JSR $096C
        BEQ $37A4
        JMP $0E1E
        INC $19
        BNE $379D
        INC $1A
        LDY #$01
        LDA ($AC),Y
        BNE $37A4
        RTS
        JSR $0633
        BCS $37B7
        LDY #$03
        LDA ($AC),Y
        STA $1A
        DEY
        LDA ($AC),Y
        STA $19
        DEY
        BNE $379D
        LDY #$FF
        STY $376F
        INY
        STY $16
        JSR $06D8
        LDY #$FF
        STY $376D
        INY
        STY $376E
        STY $376F
        STY $16
        LDA $3767
        STA ($EE),Y
        PLA
        PLA
        JMP $047D
        LDY $376F
        BNE $37E3
        LDA $2322
        RTS
        LDY $EE
        CPY $3756
        BCS $37FE
        CMP $3765
        BCC $37FE
        CMP #$20
        BNE $37F8
        CPY $3753
        BEQ $37FE
        LDY #$00
        STA ($EE),Y
        INC $EE
        LDA #$00
        RTS
        CMP #$3F
        BNE $3808
        JMP $05C1
        CMP #$21
        BNE $3816
        CPX $3753
        BNE $3816
        LDA #$91
        JMP $05C3
        JMP $05C5
        LDA $3753
        STA $EE
        LDA $3754
        STA $EF
        LDA $376E
        BEQ $382F
        LDY #$00
        LDA $3767
        STA ($EE),Y
        LDY #$FF
        INY
        LDA ($EE),Y
        CMP $3767
        BEQ $3843
        LDX $376D
        BEQ $3831
        JSR $0AEE
        BNE $3831
        LDX #$00
        STX $376D
        STY $3768
        LDA $16
        STA $3769
        LDA $376C
        BEQ $3882
        STX $376C
        LDX $3768
        LDA $3767
        RTS
        LDA #$FF
        STA $376C
        STA $376E
        BNE $382F
        LDY #$00
        LDA ($EE),Y
        LDY $3768
        CMP $3767
        BEQ $3882
        JSR $0A73
        LDX #$00
        STX $16
        DEX
        STX $376D
        BNE $382F
        JMP $38CE
        LDX $375C
        BEQ $38BA
        LDX $375A
        BEQ $38BA
        LDA ($EE),Y
        CMP $3767
        BEQ $389F
        LDA $375A
        INY
        JSR $0AEE
        BNE $388F
        TYA
        BEQ $38C4
        DEC $16
        LDX #$02
        LDA $375C
        JSR $0AEE
        DEX
        BEQ $38A6
        BMI $38B5
        LDA #$20
        BNE $38A9
        DEC $16
        DEY
        BPL $389F
        JSR $0AEE
        JSR $0A73
        LDA #$00
        STA $16
        LDY #$01
        DEY
        BMI $38C4
        LDA $3767
        STA ($EE),Y
        STY $3768
        JSR $0587
        CMP $375B
        BNE $38DC
        JMP $3983
        CMP $3758
        BEQ $38E6
        CMP $3759
        BNE $38E9
        JMP $39D6
        CMP $375F
        BNE $38F1
        JMP $3869
        CMP $3760
        BNE $38F9
        JMP $3977
        CMP $3761
        BNE $3901
        JMP $39B7
        CMP $3762
        BNE $3909
        JMP $39A9
        CMP $3763
        BNE $3911
        JMP $3885
        CMP $375D
        BEQ $391B
        CMP $375E
        BNE $391E
        JMP $3A00
        CMP $3767
        BNE $3926
        JMP $385F
        CMP $3765
        BCC $38CE
        CMP $3766
        BCC $3933
        JMP $38CE
        CPY $3755
        BCS $3930
        LDX $16
        CPX $376A
        BCS $3930
        PHA
        TXA
        CLC
        ADC #$03
        CMP $376A
        BCC $394F
        LDA $3764
        JSR $0AEE
        PLA
        INC $16
        PHA
        DEC $16
        JSR $0AEE
        CPY $3757
        BCC $3963
        LDA $3764
        JSR $0AEE
        LDA ($EE),Y
        TAX
        PLA
        STA ($EE),Y
        INY
        TXA
        CMP $3767
        BEQ $3996
        CPY $3755
        BCS $3991
        BCC $3952
        LDX $375C
        BEQ $39D3
        LDA #$00
        STA $3768
        BEQ $399B
        STA $375C
        TYA
        BEQ $39D3
        TAX
        DEX
        STX $3768
        CLC
        BCC $399B
        LDA $3767
        DEC $16
        INC $3768
        STA ($EE),Y
        CPY $3768
        BEQ $39D3
        DEY
        LDA $375C
        JSR $0AEE
        BNE $399B
        LDX $375A
        BEQ $39D3
        LDX $3755
        INX
        STX $3768
        BNE $39EB
        LDX $375A
        BEQ $39D3
        LDA #$00
        STA $3768
        CLC
        LDA $376B
        ADC $3768
        STA $3768
        TYA
        CMP $3768
        BCS $39C1
        BCC $39EB
        JMP $38CE
        LDX $375A
        BNE $39E0
        STA $375A
        BNE $39E5
        CMP $375A
        BNE $39D3
        STY $3768
        INC $3768
        LDA ($EE),Y
        CMP $3767
        BEQ $39D3
        CPY $3768
        BCS $39D3
        INY
        LDA $375A
        JSR $0AEE
        BNE $39EB
        LDY #$00
        LDA ($EE),Y
        LDY $3768
        CMP $3767
        BEQ $39D3
        LDA $375C
        BNE $3A23
        LDA $3764
        LDX $16
        CPX $376A
        BCS $3A1E
        LDA $375E
        JSR $0AEE
        BNE $3A3F
        DEC $16
        LDA ($EE),Y
        CMP $3767
        BNE $3A42
        LDX #$02
        LDA $375C
        JSR $0AEE
        DEX
        BEQ $3A2E
        BMI $3A3D
        LDA #$20
        BNE $3A31
        DEC $16
        JMP $38C6
        INY
        LDA ($EE),Y
        DEY
        STA ($EE),Y
        PHA
        CMP $3767
        BNE $3A50
        LDA #$20
        JSR $0AEE
        DEC $16
        INY
        PLA
        CMP $3767
        BNE $3A42
        JMP $399B
        CMP #$61
        BCC $3A69
        CMP #$7B
        BCS $3A69
        EOR #$20
        RTS
        JSR $3A5F
        CMP #$0D
        BEQ $3A69
        JMP $2CEC
        EOR $2E,X
        ADC ($42,X)
        CMP $7F,X
        .BYTE $3A
        .BYTE $13
        EOR ($03),Y
;
; AND THAT (FINALLY!) BRINGS US UP TO THE START OF THE BASIC WORKSPACE.
;
