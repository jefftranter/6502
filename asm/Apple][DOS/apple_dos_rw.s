;***************************
;*         DISC-II         *
;*     13-SECTOR FORMAT    *
;*      READ AND WRITE     *
;*       SUBROUTINES       *
;*                         *
;***************************
;*                         *
;*                         *
;*     COPYRIGHT 1978      *
;*   APPLE COMPUTER INC.   *
;*                         *
;*   ALL RIGHTS RESERVED   *
;*                         *
;***************************
;*                         *
;*      MAY 25, 1978       *
;*          WOZ            *
;*      R. WIGGINTON       *
;*                         *
;***************************
; EJECT
;***************************
;*                         *
;*     CRITICAL TIMING     *
;*   REQUIRES PAGE BOUND   *
;*   CONSIDERATIONS FOR    *
;*      CODE AND DATA      *
;*                         *
;*     -----CODE-----      *
;*                         *
;*   VIRTUALLY THE ENTIRE  *
;*     'WRITE' ROUTINE     *
;*      MUST NOT CROSS     *
;*     PAGE BOUNDARIES.    *
;*                         *
;*  CRITICAL BRANCHES IN   *
;*  THE 'WRITE', 'READ',   *
;*  AND 'READ ADR' SUBRS   *
;*  WHICH MUST NOT CROSS   *
;*  PAGE BOUNDARIES ARE    *
;*  NOTED IN COMMENTS.     *
;*                         *
;*     -----DATA-----      *
;*                         *
;*  NBUF1, NBUF2, NBUF3,   *
;*  NBUF4, AND NBUF5 ARE   *
;*  51-BYTE RAM BUFFERS    *
;*  WHICH SHOULD ALL BE    *
;*  LOCATED ON A SINGLE    *
;*  PAGE BEGINNING WITH    *
;*  NBUF1. (NBUF5 IS 52).  *
;*                         *
;*  NBUF6, NBUF7, AND      *
;*  NBUF8 MUST NOT CROSS   *
;*  PAGE BOUNDARIES AND    *
;*  SHOULD BE LOCATED      *
;*  ON A PAGE BEGINNING    *
;*  WITH NBUF6.  NBUF6     *
;*  AND NBUF7 ARE 51 BYTES *
;*  WHILE NBUF8 IS 52.     *
;*                         *
;*  NIBLIZING TABLE 'NIBL' *
;*  (32 BYTES) MUST NOT    *
;*  CROSS PAGE BOUNDARY.   *
;*  CONVERTS 5-BIT NIBLS   *
;*  TO 7-BIT NIBLS.        *
;*                         *
;*  DENIBLIZING TABLE      *
;*  'DNIBL' MUST BE ON A   *
;*  PAGE BOUNDARY, BUT     *
;*  ONLY DNIBL,$AB TO      *
;*  DNIBL,$FF NEED BE      *
;*  USED.  CONVERTS 7-BIT  *
;*  NIBLS TO 5-BIT NIBLS.  *
;*                         *
;***************************
; EJECT
;***************************
;*                         *
;*         EQUATES         *
;*                         *
;***************************
;*                         *
;*    -----PRENIBL----     *
;*      AND POSTNIBL       *
;*                         *
;***************************
BUF = $3E ; TWO BYTE POINTER.
;*
;*        POINTS TO 256-BYTE
;*        USER BUFFER ANYWHERE
;*        IN MEMORY.  PRENIBL
;*        CONVERTS USER DATA
;*        (IN BUF) INTO 5-BIT
;*        NIBLS 000ABCDE IN
;*        NBUF1 THROUGH NBUF8
;*        PRIOR TO 'WRITE'.
;*        POSTNIBL CONVERTS
;*        5-BIT NIBLS ABCDE000
;*        BACK TO USER DATA
;*        (IN BUF) AFTER 'READ'.
;*
NBUF1 = $BB00
NBUF2 = $BB33 ; OBSERVE THESE
NBUF3 = $BB66 ; PLACEMENTS
NBUF4 = $BB99 ; RELATIVE TO
NBUF5 = $BBCC ; PAGE STARTS!
NBUF6 = $BC00
NBUF7 = $BC33
NBUF8 = $BC66 ; (TO $BC99)
;*
T0 = $26 ; TEMPS USED BY PRENIBL
T1 = $27 ;    AND POSTNIBL.
T2 = $2A ; TEMP USED BY PRENIBL.
;*
;************************
;*                      *
;*    ----READADR----   *
;*                      *
;************************
COUNT = $26 ; 'MUST FIND' COUNT.
LAST = $26 ; 'ODD BIT' NIBLS.
CSUM = $27 ; CHECKSUM BYTE.
CSSTV = $2C ; FOUR BYTES,
;*       CHECKSUM, SECTOR, TRACK, AND VOLUME.
;*
;************************
;*                      *
;*    ----WRITE----     *
;*                      *
;*    USES ALL NBUFS    *
;*      AND 32-BYTE     *
;*   DATA TABLE 'NIBL'  *
;*                      *
;************************
WTEMP = $26 ; TEMP FOR DATA AT NBUF6,0.
SLOTZ = $27 ; SLOTNUM IN Z-PAG LOC.
SLOTABS = $678 ; SLOTNUM IN NON-ZPAG LOC.
;*
;************************
;*                      *
;*     -----READ----    *
;*                      *
;*    USES ALL NBUFS    *
;*  USES LAST 54 BYTES  *
;*  OF A CODE PAGE FOR  *
;*  USED BYTES OF DNIBL *
;*  TABLE.              *
;*                      *
;************************
IDX = $26 ; INDEX INTO (BUF).
DNIBL = $BA00 ; 7-BIT TO 5-BIT NIBLS.
;*
;************************
;*                      *
;*    ---- SEEK ----    *
;*                      *
;************************
TRKCNT = $26 ; HALFTRKS MOVED COUNT.
PRIOR = $27 ; PRIOR HALFTRACK.
TRKN = $2A ; DESIRED TRACK.
SLOTTEMP = $2B ; SLOT NUM TIMES $10.
CURTRK = $478 ; CURRENT TRACK ON ENTYR.
;*
;************************
;*                      *
;*   ---- MSWAIT ----   *
;*                      *
;************************
MONTIMEL = $46
MONTIMEH = $47
;*
;************************
;*                      *
;*    DEVICE ADDRESS    *
;*     ASSIGNMENTS      *
;*                      *
;************************
PHASEOFF = $C080 ; STEPPER PHASE OFF.
PHASEON = $C081 ; STEPPER PHASE ON.
Q6L = $C08C ; Q7L,Q6L=READ
Q6H = $C08D ; Q7L,Q6H=SENSE WPROT
Q7L = $C08E ; Q7H,Q6L=WRITE
Q7H = $C08F ; Q7H,Q6H=WRITE STORE
; EJECT
;****************************
;*                          *
;*    PRENIBLIZE SUBR       *
;*                          *
;****************************
;*                          *
;*  CONVERTS 256 BYTES OF   *
;*  USER DATA IN (BUF),0    *
;*  TO (BUF),255 INTO 410   *
;*  5-BIT NIBLS (000ABCDE)  *
;*  IN NBUF1 THROUGH NBUF8. *
;*                          *
;*    ---- ON ENTRY ----    *
;*                          *
;*  BUF IS 2-BYTE POINTER   *
;*    TO 256 BYTES OF USER  *
;*    DATA.                 *
;*                          *
;*    ---- ON EXIT -----    *
;*                          *
;*  A-REG: UNCERTAIN.       *
;*  X-REG: UNCERTAIN.       *
;*  Y-REG: HOLDS $FF.       *
;*  CARRY: UNCERTAIN.       *
;*                          *
;*  NBUF1 THROUGH NBUF8     *
;*    CONTAIN 5-BIT NIBLS   *
;*    OF FORM 000ABCDE.     *
;*                          *
;*  TEMPS T0, T1, T2 USED.  *
;*                          *
;****************************
 .ORG $B800
; OBJ $B800
PRENIBL: LDX #$32 ; INDEX FOR (51) 5-BYTE PASSES.
 LDY #$0 ; USER BUF INDEX.
PNIB1: LDA (BUF),Y ; FIRST OF 5 USER BYTES.
 STA T0 ; (ONLY 3 LSB'S USED)
 LSR
 LSR ; 5 MSB'S TO LOW BITS.
 LSR
 STA NBUF1,X ; FIRST OF 8 5-BIT NIBLS.
 INY
 LDA (BUF),Y ; SECOND OF 5 USER BYTES.
 STA T1 ; (ONLY 3 LSB'S USED)
 LSR
 LSR ; 5 MSB'S TO LOW BITS.
 LSR
 STA NBUF2,X ; SECOND OF 8 5-BIT NIBLS.
 INY
 LDA (BUF),Y ; THIRD OF 5 USER BYTES.
 STA T2 ; (ONLY 3 LSB'S USED)
 LSR
 LSR ; 5 MSB'S TO LOW BITS.
 LSR
 STA NBUF3,X ; THIRD OF 8 5-BIT NIBLS.
 INY
 LDA (BUF),Y ; FOURTH OF 5 USER BYTES.
 LSR
 ROL T2 ; LSB INTO T2.
 LSR
 ROL T1 ; NEXT LSB INTO T1.
 LSR
 ROL T0 ; NEXT LSB INTO T0.
 STA NBUF4,X ; FOURTH OF 8 5-BIT NIBLS.
 INY
 LDA (BUF),Y ; FIFTH OF 5 USER BYTES.
 LSR
 ROL T2 ; LSB INTO T2.
 LSR
 ROL T1 ; NEXT LSB INTO T1.
 LSR
 STA NBUF5,X ; FIFTH OF 8 5-BIT NIBLS.
 LDA T0
 ROL ; NEXT LSB.
 AND #$1F ; TRUNCATE TO 5 BITS.
 STA NBUF6,X ; SIXTH OF 8 5-BIT NIBLS.
 LDA T1
 AND #$1F ; TRUNCATE TO 5 BITS.
 STA NBUF7,X ; SEVENTH OF 8 5-BIT NIBLS.
 LDA T2
 AND #$1F ; TRUNCATE TO 5 BITS.
 STA NBUF8,X ; EIGHTH OF 8 5-BIT NIBLS.
 INY
 DEX ; NEXT OF (51) 5-BYTE PASSES.
 BPL PNIB1
 LDA (BUF),Y
 TAX
 AND #$7 ; 3 LSB'S OF LAST
 STA NBUF8+$33 ; USER BYTE.
 TXA
 LSR
 LSR
 LSR ; 5 MSB'S OF LAST
 STA NBUF5+$33 ; USER BYTE.
 RTS
; EJECT
;************************
;*                      *
;*      WRITE SUBR      *
;*                      *
;************************
;*                      *
;*   WRITES DATA FROM   *
;*    NBUF1 TO NBUF8    *
;*   CONVERTING 5-BIT   *
;*    TO 7-BIT NIBLS    *
;*   VIA 'NIBL' TABLE.  :
;*                      *
;*  FIRST, NBUF6 TO     *
;*   NBUF8, HIGH TO LOW *
;*  THEN, NBUF1 TO      *
;*   NBUF5, LOW TO HIGH *
;*                      *
;*  ---- ON ENTRY ----  *
;*                      *
;*   X-REG: SLOTNUM     *
;*        TIMES $10.    *
;*                      *
;*   NBUF1 TO NBUF8     *
;*    HOLD NIBLS FROM   *
;*    PRENIBL SUBR.     *
;*    (000ABCDE)        *
;*                      *
;*  ---- ON EXIT -----  *
;*                      *
;*  CARRY SET IF ERROR. *
;*   (W PROT VIOLATION) *
;*                      *
;*  IF NO ERROR:        *
;*                      *
;*    A-REG: UNCERTAIN. *
;*    X-REG: UNCHANGED. *
;*    Y-REG: HOLDS $00. *
;*    CARRY CLEAR.      *
;*                      *
;*    SLOTABS, SLOTZ,   *
;*     AND WTEMP USED.  *
;*                      *
;*  ---- ASSUMES ----   *
;*                      *
;*  1 USEC CYCLE TIME   *
;*                      *
;************************
WRITE: SEC ; ANTICIPATE WPROT ERR.
 LDA Q6H,X
 LDA Q7L,X ; SENSE WPROT FLAG.
 BMI WEXIT ; IF HIGH, THEN ERR.
 STX SLOTZ ; FOR ZERO PAGE ACCESS.
 STX SLOTABS ; FOR NON-ZERO PAGE.
 LDA NBUF6
 STA WTEMP ; FOR ZERO-PAGE ACCESS.
 LDA #$FF ; SYNC DATA.
 STA Q7H,X ; (5)  WRITE 1ST NIBL.
 ORA Q6L,X ; (4)
 PHA ; (3)
 PLA ; (4)  CRITICAL TIMING!
 NOP ; (2)
 LDY #$A ; (2)  FOR 11 NIBLS.
WSYNC: ORA WTEMP ; (3)  FOR TIMING.
 JSR WNIBL7 ; (13,9,6)  WRITE SYNC.
 DEY ; (2)
 BNE WSYNC ; (2*)  MUST NOT CROSS PAGE!
 LDA #$D5 ; (2)  1ST DATA MARK.
 JSR WNIBL9 ; (15,9,6)
 LDA #$AA ; (2)  2ND DATA MARK.
 JSR WNIBL9 ; (15,9,6)
 LDA #$AD ; (2)  3RD DATA MARK.
 JSR WNIBL9 ; (15,9,6)
 TYA ; (2)  CLEAR CHKSUM.
 LDY #$9A ; (2)  NBUF6-8 INDEX.
 BNE WDATA1 ; (3)  ALWAYS.  NO PAGE CROSS!!
WDATA0: LDA NBUF6,Y ; (4)  PRIOR 5-BIT NIBL.
WDATA1: EOR NBUF6-1,Y ; (5)  XOR WITH CURRENT.
;*   (NBUF6 MUST BE ON PAGE BOUNDARY FOR TIMING!!)
 TAX ; (2)  INDEX TO 7-BIT NIBL.
 LDA NIBL,X ; (4)  MUST NOT CROSS PAGE!
 LDX SLOTZ ; (3)  CRITICAL TIMING!
 STA Q6H,X ; (5)  WRITE NIBL.
 LDA Q6L,X ; (4)
 DEY ; (2)  NEXT NIBL.
 BNE WDATA0 ; (2*)  MUST NOT CROSS PAGE!
 LDA WTEMP ; (3)  PRIOR NIBL FROM BUF6.
 NOP ; (2)  CRITICAL TIMING.
WDATA2: EOR NBUF1,Y ; (4)  XOR NBUF1 NIBL.
 TAX ; (2)  INDEX TO 7-BIT NIBL.
 LDA NIBL,X ; (4)
 LDX SLOTABS ; (4)  TIMING CRITICAL.
 STA Q6H,X ; (5)  WRITE NIBL.
 LDA Q6L,X ; (4)
 LDA NBUF1,Y ; (4)  PRIOR 5-BIT NIBL.
 INY ; (2)  NEXT NBUF1 NIBL.
 BNE WDATA2 ; (2*)  MUST NOT CROSS PAGE!
 TAX ; (2)  LAST NIBL AS CHKSUM.
 LDA NIBL,X ; (4)  INDEX TO 7-BIT NIBL.
 LDX SLOTZ ; (3)
 JSR WNIBL ; (6,9,6)  WRITE CHKSUM.
 LDA #$DE ; (2)  DM4, BIT SLIP MARK.
 JSR WNIBL9 ; (15,9,6)    WRITE IT.
 LDA #$AA ; (2)  DM5, BIT SLIP MARK.
 JSR WNIBL9 ; (15,9,6)    WRITE IT.
 LDA #$EB ; (2)  DM6, BIT SLIP MARK.
 JSR WNIBL9 ; (15,9,6)    WRITE IT.
 LDA Q7L,X ; OUT OF WRITE MODE.
WEXIT: LDA Q6L,X ; TO READ MODE.
 RTS ; RETURN FROM WRITE.
;*****************************
;*                           *
;*   7-BIT NIBL WRITE SUBRS  *
;*                           *
;*   A-REG OR'D PRIOR EXIT   *
;*       CARRY CLEARED       *
;*                           *
;*****************************
WNIBL9: CLC ; (2)  9 CYCLES, THEN WRITE.
WNIBL7: PHA ; (3)  7 CYCLES, THEN WRITE.
 PLA ; (4)
WNIBL: STA Q6H,X ; (5)  NIBL WRITE SUB.
 ORA Q6L,X ; (4)  CLOBBERS ACC, NOT CARRY.
 RTS
; EJECT
;**************************
;*                        *
;*     READ SUBROUTINE    *
;*                        *
;**************************
;*                        *
;*    READS 5-BIT NIBLS   *
;*     (ABCDE000) INTO    *
;*   NBUF1 THROUGH NBUF8  *
;*    CONVERTING 7-BIT    *
;*     NIBLS TO 5-BIT     *
;*    VIA 'DNIBL' TABLE   *
;*                        *
;*  FIRST READS NBUF6 TO  *
;*    NBUF8 HIGH TO LOW,  *
;*  THEN READS NBUF1 TO   *
;*    NBUF5 LOW TO HIGH   *
;*                        *
;*   ---- ON ENTRY ----   *
;*                        *
;*  X-REG: SLOTNUM        *
;*         TIMES $10.     *
;*                        *
;*  READ MODE (Q6L, Q7L)  *
;*                        *
;*   ---- ON EXIT -----   *
;*                        *
;*  CARRY SET IF ERROR.   *
;*                        *
;*  IF NO ERROR:          *
;*     A-REG: HOLDS $AA   *
;*     X-REG: UNCHANGED.  *
;*     Y-REG: HOLDS $00   *
;*     CARRY CLEAR.       *
;*                        *
;*     NBUF1 TO NBUF8     *
;*       HOLD 5-BIT       *
;*       NIBLS ABCDE000.  *
;*                        *
;*     USES TEMP 'IDX'.   *
;*                        *
;*   ---- CAUTION -----   *
;*                        *
;*        OBSERVE         *
;*    'NO PAGE CROSS'     *
;*      WARNINGS ON       *
;*    SOME BRANCHES!!     *
;*                        *
;*   ---- ASSUMES ----    *
;*                        *
;*   1 USEC CYCLE TIME    *
;*                        *
;**************************
READ: LDY #$20 ; 'MUST FIND' COUNT.
RSYNC: DEY ; IF CAN'T FIND MARKS
 BEQ RDERR ; THEN EXIT WITH CARRY SET.
RD1: LDA Q6L,X ; READ NIBL.
 BPL RD1 ; *** NO PAGE CROSS! ***
RSYNC1: EOR #$D5 ; DATA MARK 1?
 BNE RSYNC ; LOOP IF NOT.
 NOP ; DELAY BETWEEN NIBLS.
RD2: LDA Q6L,X
 BPL RD2 ; *** NO PAGE CROSS! ***
 CMP #$AA ; DATA MARK 2?
 BNE RSYNC1 ;  (IF NOT, IS IT DM1?)
 LDY #$9A ; INIT NBUF6 INDEX.
;*              (ADDED NIBL DELAY)
RD3: LDA Q6L,X
 BPL RD3 ; *** NO PAGE CROSS! ***
 CMP #$AD ; DATA MARK 3?
 BNE RSYNC1 ;  (IF NOT, IS IT DM1?)
;*         (CARRY SET IF DM3!)
 LDA #$00 ; INIT CHECKSUM.
RDATA1: DEY
 STY IDX
RD4: LDY Q6L,X
 BPL RD4 ; *** NO PAGE CROSS! ***
 EOR DNIBL,Y ; XOR 5-BIT NIBL.
 LDY IDX
 STA NBUF6,Y ; STORE IN NBUF6 PAGE.
 BNE RDATA1 ; TAKEN IF Y-REG NONZERO.
RDATA2: STY IDX
RD5: LDY Q6L,X
 BPL RD5 ; *** NO PAGE CROSS! ***
 EOR DNIBL,Y ; XOR 5-BIT NIBL.
 LDY IDX
 STA NBUF1,Y ; STORE IN NBUF1 PAGE.
 INY
 BNE RDATA2
RD6: LDY Q6L,X ; READ 7-BIT CSUM NIBL.
 BPL RD6 ; *** NO PAGE CROSS! ***
 CMP DNIBL,Y ; IF LAST NBUF1 NIBL NOT
 BNE RDERR ; EQUAL CHKSUM NIBL THEN ERR.
RD7: LDA Q6L,X
 BPL RD7 ; *** NO PAGE CROSS! ***
 CMP #$DE ; FIRST BIT SLIP MARK?
 BNE RDERR ;  (ERR IF NOT)
 NOP ; DELAY BETWEEN NIBLS.
RD8: LDA Q6L,X
 BPL RD8 ; *** NO PAGE CROSS! ***
 CMP #$AA ; SECOND BIT SLIP MARK?
 BEQ RDEXIT ;  (DONE IF IT IS)
RDERR: SEC ; INDICATE 'ERROR EXIT'.
 RTS ; RETURN FROM READ OR READADR.
; EJECT
;****************************
;*                          *
;*    READ ADDRESS FIELD    *
;*                          *
;*        SUBROUTINE        *
;*                          *
;****************************
;*                          *
;*    READS VOLUME, TRACK   *
;*        AND SECTOR        *
;*                          *
;*   ---- ON ENTRY ----     *
;*                          *
;*  XREG: SLOTNUM TIMES $10 *
;*                          *
;*  READ MODE (Q6L, Q7L)    *
;*                          *
;*   ---- ON EXIT -----     *
;*                          *
;*  CARRY SET IF ERROR.     *
;*                          *
;*  IF NO ERROR:            *
;*    A-REG: HOLDS $AA.     *
;*    Y-REG: HOLDS $00.     *
;*    X-REG: UNCHANGED.     *
;*    CARRY CLEAR.          *
;*                          *
;*    CSSTV HOLDS CHKSUM,   *
;*      SECTOR, TRACK, AND  *
;*      VOLUME READ.        *
;*                          *
;*    USES TEMPS COUNT,     *
;*      LAST, CSUM, AND     *
;*      4 BYTES AT CSSTV.   *
;*                          *
;*    ---- EXPECTS ----     *
;*                          *
;*  NORMAL DENSITY NIBLS    *
;*   (4-BIT), ODD BITS,     *
;*   THEN EVEN.             *
;*                          *
;*    ---- CAUTION ----     *
;*                          *
;*         OBSERVE          *
;*    'NO PAGE CROSS'       *
;*      WARNINGS ON         *
;*    SOME BRANCHES!!       *
;*                          *
;*    ---- ASSUMES ----     *
;*                          *
;*    1 USEC CYCLE TIME     *
;*                          *
;****************************
RDADR: LDY #$F8
 STY COUNT ; 'MUST FIND' COUNT.
RDASYN: INY
 BNE RDA1 ; LOW ORDER OF COUNT.
 INC COUNT ; (2K NIBLS TO FIND
 BEQ RDERR ;  ADR MARK, ELSE ERR)
RDA1: LDA Q6L,X ; READ NIBL.
 BPL RDA1 ; *** NO PAGE CROSS! ***
RDASN1: CMP #$D5 ; ADR MARK 1?
 BNE RDASYN ;  (LOOP IF NOT)
 NOP ; ADDED NIBL DELAY.
RDA2: LDA Q6L,X
 BPL RDA2 ; *** NO PAGE CROSS! ***
 CMP #$AA ; ADR MARK 2?
 BNE RDASN1 ;  (IF NOT, IS IT AM1?)
 LDY #$3 ; INDEX FOR 4-BYTE READ.
;*            (ADDED NIBL DELAY)
RDA3: LDA Q6L,X
 BPL RDA3 ; *** NO PAGE CROSS! ***
 CMP #$B5 ; ADR MARK 3?
 BNE RDASN1 ;  (IF NOT, IS IT AM1?)
;*        (LEAVES CARRY SET!)
 LDA #$0 ; INIT CHECKSUM.
RDAFLD: STA CSUM
RDA4: LDA Q6L,X ; READ 'ODD BIT' NIBL.
 BPL RDA4 ; *** NO PAGE CROSS! ***
 ROL ; ALIGN ODD BITS, '1' INTO LSB.
 STA LAST ;   (SAVE THEM)
RDA5: LDA Q6L,X ; READ 'EVEN BIT' NIBL.
 BPL RDA5 ; *** NO PAGE CROSS! ***
 AND LAST ; MERGE ODD AND EVEN BITS.
 STA CSSTV,Y ; STORE DATA BYTE.
 EOR CSUM ; XOR CHECKSUM.
 DEY
 BPL RDAFLD ; LOOP ON 4 DATA BYTES.
 TAY ; IF FINAL CHECKSUM
 BNE RDERR ;  NONZERO, THEN ERROR.
RDA6: LDA Q6L,X ; FIRST BIT-SLIP NIBL.
 BPL RDA6 ; *** NO PAGE CROSS! ***
 CMP #$DE
 BNE RDERR ; ERROR IF NONMATCH.
 NOP ; DELAY BETWEEN NIBLS.
RDA7: LDA Q6L,X ; SECOND BIT-SLIP NIBL.
 BPL RDA7 ; *** NO PAGE CROSS! ***
 CMP #$AA
 BNE RDERR ; ERROR IF NONMATCH.
RDEXIT: CLC ; CLEAR CARRY ON
 RTS ;  NORMAL READ EXITS.
; EJECT
;***************************
;*                         *
;*    POSTNIBLIZE SUBR     *
;*                         *
;***************************
;*                         *
;*  CONVERTS 5-BIT NIBLS   *
;*  OF FORM ABCDE000 IN    *
;*  NBUF1 THROUGH NBUF8    *
;*  INTO 256 BYTES OF      *
;*  USER DATA IN BUF.      *
;*                         *
;*   ---- ON ENTRY ----    *
;*                         *
;*  X-REG: HOLDS SLOTNUM   *
;*            TIMES $10.   *
;*                         *
;*  BUF IS 2-BYTE POINTER  *
;*    TO 256 BYTES OF USER *
;*    DATA TO BE CONVERTED *
;*    TO 5-BIT NIBLS IN    *
;*    NBUF1 THROUGH NBUF8  *
;*    PRIOR TO WRITE.      *
;*                         *
;*   ---- ON EXIT -----    *
;*                         *
;*  A-REG: UNCERTAIN.      *
;*  Y-REG: HOLDS $FF.      *
;*  X-REG: HOLDS $FF.      *
;*  CARRY: UNCERTAIN.      *
;*                         *
;*  5-BIT NIBLS OF FORM    *
;*    000ABCDE IN 410      *
;*    BYTES FROM NBUF1     *
;*    TO NBUF8.            *
;*                         *
;***************************
POSTNIB: LDX #$32 ; INDEX FOR 51 PASSES.
 LDY #$0 ; INDEX TO USER BUF.
POSTNB1: LDA NBUF6,X
 LSR
 LSR
 LSR
 STA T1
 LSR
 STA T0
 LSR
 ORA NBUF1,X
 STA (BUF),Y ; FIRST OF 5 USER BYTES.
 INY
 LDA NBUF7,X
 LSR
 LSR
 LSR
 LSR
 ROL T1
 LSR
 ROL T0
 ORA NBUF2,X
 STA (BUF),Y ; SECOND OF 5 USER BYTES.
 INY
 LDA NBUF8,X
 LSR
 LSR
 LSR
 LSR
 ROL T1
 LSR
 ROL T0
 ORA NBUF3,X
 STA (BUF),Y ; THIRD OF 5 USER BYTES.
 INY
 LDA T0
 AND #$7
 ORA NBUF4,X
 STA (BUF),Y ; FOURTH OF 5 USER BYTES.
 INY
 LDA T1
 AND #$7
 ORA NBUF5,X
 STA (BUF),Y ; FIFTH OF 5 USER BYTES.
 INY
 DEX ; NEXT OF 51 PASSES.
 BPL POSTNB1 ; HANDLE LAST USER
 LDA NBUF8+$33 ;  BYTE DIFFERENTLY.
 LSR
 LSR
 LSR
 ORA NBUF5+$33
 STA (BUF),Y
 RTS
; EJECT
;**************************
;*                        *
;*  FAST SEEK SUBROUTINE  *
;*                        *
;**************************
;*                        *
;*   ---- ON ENTRY ----   *
;*                        *
;*  X-REG HOLDS SLOTNUM   *
;*         TIMES $10.     *
;*                        *
;*  A-REG HOLDS DESIRED   *
;*         HALFTRACK.     *
;*         (SINGLE PHASE) *
;*                        *
;*  CURTRK HOLDS CURRENT  *
;*          HALFTRACK.    *
;*                        *
;*   ---- ON EXIT -----   *
;*                        *
;*  A-REG UNCERTAIN.      *
;*  Y-REG UNCERTAIN.      *
;*  X-REG UNDISTURBED.    *
;*                        *
;*  CURTRK AND TRKN HOLD  *
;*      FINAL HALFTRACK.  *
;*                        *
;*  PRIOR HOLDS PRIOR     *
;*    HALFTRACK IF SEEK   *
;*    WAS REQUIRED.       *
;*                        *
;*  MONTIMEL AND MONTIMEH *
;*    ARE INCREMENTED BY  *
;*    THE NUMBER OF       *
;*    100 USEC QUANTUMS   *
;*    REQUIRED BY SEEK    *
;*    FOR MOTOR ON TIME   *
;*    OVERLAP.            *
;*                        *
;* --- VARIABLES USED --- *
;*                        *
;*  CURTRK, TRKN, COUNT,  *
;*    PRIOR, SLOTTEMP     *
;*    MONTIMEL, MONTIMEH  *
;*                        *
;**************************
SEEK: STA TRKN ; TARGET TRACK.
 CMP CURTRK ; ON DESIRED TRACK?
 BEQ SEEKXIT ;   YES, HIT IT AND RETURN.
 STX SLOTTEMP ; SAVE X-REG.
 LDA #$0
 STA TRKCNT ; HALFTRACK COUNT.
SEEK2: LDA CURTRK ; SAVE CURTRK FOR
 STA PRIOR ;  DELAYED TURNOFF.
 SEC
 SBC TRKN ; DELTA-TRACKS.
 BEQ SEEKEND ; DONE, FINISH SEEK.
 BCS OUT ; (MOVE OUT, NOT IN)
 EOR #$FF ; CALC TRKS TO GO.
 INC CURTRK ; INCR CURRENT TRACK (IN).
 BCC MINTST ; (ALWAYS TAKEN)
OUT: ADC #$FE ; CALC TRKS TO GO.
 DEC CURTRK ; DECR CURRENT TRACK (OUT).
MINTST: CMP TRKCNT
 BCC MAXTST ;  AND 'TRKS MOVED'.
 LDA TRKCNT
MAXTST: CMP #$C
 BCC STEP ; IF > $B, USE $B.
 LDA #$B
STEP: TAY ; ACCELLERATION INDEX.
 LDA CURTRK
 AND #$3 ; INDEX TO 'CURRENT
 ASL ;   PHASE' OF 4-PHASE
 ORA SLOTTEMP ;  STEPPER.
 TAX
 LDA PHASEON,X ; HIT NEXT PHASE
 LDA ONTABLE,Y ;  FOR 'ONTIME'.
 JSR MSWAIT ; (100 USEC INTERVALS)
 LDA PRIOR
 AND #$3 ; INDEX TO 'PRIOR PHASE'
 ASL ;    OF 4-PHASE STEPPER.
 ORA SLOTTEMP
 TAX
 LDA PHASEOFF,X ; PRIOR PHASE OFF,
 LDA OFFTABLE,Y ;  THEN WAIT 'OFFTIME'.
 JSR MSWAIT ; (100 USEC INTERVALS)
 INC TRKCNT ; 'TRACKS MOVED' COUNT.
 BNE SEEK2 ; (ALWAYS TAKEN)
SEEKEND: LDA #$5F ; DELAY 9.5 MSEC FOR
 JSR MSWAIT ;    SETTLING TIME.
 LDX SLOTTEMP ; RESTORE X-REG.
SEEKXIT: RTS ; RETURN.
; EJECT
;**************************
;*                        *
;*   MSWAIT SUBROUTINE    *
;*                        *
;**************************
;*                        *
;*  DELAYS A SPECIFIED    *
;*   NUMBER OF 100 USEC   *
;*   INTERVALS FOR MOTOR  *
;*   ON TIMING.           *
;*                        *
;*   ---- ON ENTRY ----   *
;*                        *
;*  A-REG: HOLDS NUMBER   *
;*        OF 100 USEC     *
;*        INTERVALS TO    *
;*        DELAY.          *
;*                        *
;*   ---- ON EXIT -----   *
;*                        *
;*  A-REG: HOLDS $00.     *
;*  X-REG: HOLDS $00.     *
;*  Y-REG: UNCHANGED.     *
;*  CARRY: SET.           *
;*                        *
;*  MONTIMEL, MONTIMEH    *
;*   ARE INCREMENTED ONCE *
;*   PER 100 USEC INTERVAL*
;*   FOR MOTON ON TIMING. *
;*                        *
;*   ---- ASSUMES ----    *
;*                        *
;*   1 USEC CYCLE TIME    *
;*                        *
;**************************
MSWAIT: LDX #$11
MSW1: DEX ; DELAY 86 USEC.
 BNE MSW1
 INC MONTIMEL
 BNE MSW2 ; DOUBLE-BYTE
 INC MONTIMEH ;   INCREMENT.
MSW2: SEC
 SBC #$1 ; DONE 'N' INTERVALS?
 BNE MSWAIT ; (A-REG COUNTS)
 RTS
; EJECT
;**************************
;*                        *
;*  PHASE ON-, OFF-TIME   *
;*   TABLES IN 100-USEC   *
;*   INTERVALS. (SEEK)    *
;*                        *
;**************************
ONTABLE: .byte $01,$30,$28
 .byte $24,$20,$1E
 .byte $1D,$1C,$1C
 .byte $1C,$1C,$1C
OFFTABLE: .byte $70,$2C,$26
 .byte $22,$1F,$1E
 .byte $1D,$1C,$1C
 .byte $1C,$1C,$1C
; EJECT
;**************************
;*                        *
;*     7-BIT TO 5-BIT     *
;*    'DENIBLIZE' TABL    *
;*                        *
;*      VALID CODES       *
;*    $AB TO $FF ONLY.    *
;*    ($DA NOT VALID)     *
;*                        *
;*   ---- CAUTION ----    *
;*                        *
;* INSURE THAT FOLLOWING  *
;*     'RE-ORG' IS OK.    *
;*                        *
;**************************
 .ORG $BAAB
; OBJ $BAAB
 .byte $00,$01,$08
 .byte $10,$18,$02
 .byte $03,$04,$05
 .byte $06,$20,$28
 .byte $30,$07,$09
 .byte $38,$40,$0A
 .byte $48,$50,$58
 .byte $0B,$0C,$0D
 .byte $0E,$0F,$11
 .byte $12,$13,$14
 .byte $15,$16,$17
 .byte $19,$1A,$1B
 .byte $1C,$1D,$1E
 .byte $21,$22,$23
 .byte $24,$60,$68
 .byte $25,$26,$70
 .byte $78,$27,$80
 .byte $88,$90,$29
 .byte $2A,$2B,$2C
 .byte $2D,$2E,$2F
 .byte $31,$32,$33
 .byte $98,$A0,$34
 .byte $A8,$B0,$B8
 .byte $35,$36,$37
 .byte $39,$3A,$C0
 .byte $C8,$D0,$3B
 .byte $3C,$D8,$E0
 .byte $3E,$E8,$F0
 .byte $F8
; EJECT
;**************************
;*                        *
;*     5-BIT TO 7-BIT     *
;*     NIBL CONVERSION    *
;*          TABLE         *
;*                        *
;**************************
;*                        *
;*     CODES $AA, $D5     *
;*        NOT USED        *
;*                        *
;**************************
 .ORG $BC9A
; OBJ $BC9A
NIBL: .byte $AB,$AD,$AE
 .byte $AF,$B5,$B6
 .byte $B7,$BA,$BB
 .byte $BD,$BE,$BF
 .byte $D6,$D7,$DA
 .byte $DB,$DD,$DE
 .byte $DF,$EA,$EB
 .byte $ED,$EE,$EF
 .byte $F5,$F6,$F7
 .byte $FA,$FB,$FD
 .byte $FE,$FF
 .byte $1C,$1C,$1C
 .END
