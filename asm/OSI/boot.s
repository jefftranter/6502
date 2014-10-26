/*

FROM Peek(65) Vol 5 No. 1, Jan. 1984
By: Leroy Erickson
Courtesy of OSMOSUS NEWS
3128 Silver Lake Rd.
Minneapolis, MN 55418

On any standard OSI Challenger II (C4P or C8P) or Challenger III, the
"boot program" is contained in a 2k byte ROM (a 2316). Such a ROM
contains 8 "pages", where a page is 256 decimal or 100 hexadecimal
bytes.  In OSI's ROMs, each page is a totally self-contained
program. Out of the 8 available pages, each system uses only 2 or 3 of
them addressed at $FFOO, $FEOO and, maybe, $FDOO. The 8 pages in one
standard OSI ROM, the Synertek "SYNMON", contain the following
routines:

Jumper  Page
PIN     Number  Name    Address Description
------  ----    ----    ------- -----------
14      0       65V2P   $FEOO   65V Monitor for 540 Video and ASCII keyboard
13      1       65VB73  $FFOO   ROM BASIC Support for 540 Video & ASCII keyboard
12      2       65K     $FDOO   Polled keyboard Driver
11      3       65VK    $FEOO   65V Monitor for 540 Video and Polled Keyboard
10      4       65VB76  $FFOO   ROM BASIC Support for 540 Video & Polled keyboard
9       5       65H     $FFOO?  CD-74 Hard Disk Boot Code
8       6       65A     $FEOO   Serial Monitor
7       7       65F3    $FFOO   "H/D/M?" Floppy Disk Boot

The jumper socket pin numbers are for the 502 & 505 CPU boards. Jumper
socket pins 1, 2 & 3 are the select lines for addresses $FDOO, $FEOO &
$FFOO, respectively. A standard BASIC in ROM system thus has the
following 3 jumpers set - pins 1 to 12, 2 to 11, & 3 to 10. To convert
to a floppy disk system, simply connect pin 3 to pin 7 rather than pin
10. To convert to a standard ASCII keyboard, connect pin 2 to pin 14,
and pin 3 to pin 13, while leaving pin 1 open. To convert to a disk
based serial system, connect pin 2 to pin 8 and pin 3 to pin 7. A
serial BASIC in ROM system cannot be supported with this boot ROM.

This listing (see Listing 1) is the one for page 7, the floppy disk
boot code. To follow what the routine is doing, start with the 6502's
three interrupt vectors. On receiving an NMI interrupt (pin 6 of the
6502 pulled to ground), a jump is made to the address contained in
locations $FFFA & $FFFB. For an IRQ (pin 4) or BRK instruction, the
address in locations $FFFE & $FFFF is used. For a RESET (pin 40, which
is connected to the Break key) , addresses $FFFC & $FFFD are used.
Notice that the contents of those last 2 locations is $FFAO,
indicating that when you press the Break key, all system hardware is
initialized (RESET also does that) and a jump to $FFAO is made. From
there on, you're on your own.  If you have any questions, mail them to
me and I'll try to answer them through PEEK.  Have fun!

LISTING 1
SYNMON ROM Page 7 - Floppy Disk Boot Code

*/
        *=$FF00

        LODADR=$00FD
        PAGCNT=$00FF        
        STRTAD=$2200        
        DSKPIA=$C000        
        DSKACI=$C010
        SCREEN=$D000        
        HD0C6=SCREEN+$C6
        SERPRT=$FC00        
        HFD00=$FD00        
        HFE00=$FE00        
        HFE01=$FE01        
        HFE0B=$FE0B        
        HFEED=$FEED        
        HFEFC=$FEFC        
        NMIADR=$0130        
        IRQADR=$01C0                
        ;
        ; *** DISK BOOT SUBROUTINE ***
        ;
HFF00   LDY #$00        ;Select Data Direction Register A
        STY DSKPIA+1
        STY DSKPIA      ;Assign Port A as all INPUT
        LDX #$04        ;Select I/O Port A
        STX DSKPIA+1
        STY DSKPIA+3    ;Select Data Direction Register B
        DEY             ;Get an FF
        STY DSKPIA+2    ;Assign Port B as all OUTPUT
        STX DSKPIA+3    ;Select I/O Port B
        STY DSKPIA+2    ;Write Port B = all high (FF)

        LDA #$FB        ;Set step direction line to 'IN'
        BNE HFF27       ;Skip for first pass
HFF1E   LDA #$02        ;Test for 'Track 0' true
        BIT DSKPIA      ;Read Port-A & mask with TRKO bit
        BEQ HFF41       ;True - exit this loop
        LDA #$FF        ;Else, set step dir line to 'OUT'
HFF27   STA DSKPIA+2    ;Set step direction to given value
        JSR HFF99       ;Wait 12 clock cycles
        AND #$F7        ;Select 'STEP' function
                        ;
        STA DSKPIA+2
        JSR HFF99       ;Wait 12 clock cycles
        ORA #$08        ;Turn off 'STEP' function
        STA DSKPIA+2    ;
        LDX #$18        ;Wait 30,000 clock cycles
        JSR WAIT        ; (30 OR 15 ms)
        BEQ HFF1E       ;Loop back for more steps
                        ;
HFF41   LDX #$7F        ;Lower the head
        STX DSKPIA+2    ;
        JSR WAIT        ;Wait about 150,000 cycles
                        ;
HFF49   LDA DSKPIA      ;Wait for the index hole
        BMI HFF49       ;
                        ;
HFF4E   LDA DSKPIA      ;Wait until the index hole
                        ;is gone
        BPL HFF4E       ;
        LDA #$03        ;Reset the ACIA
        STA DSKACI      ;
        LDA #$58        ;Select - Receive interrupt
                        ;disabled Xmit interrupt
                        ;disabled, 8 data bits,
                        ;even parity, 1 stop bit,
                        ;/1 clock
        STA DSKACI

        JSR GETCHR      ;Get a byte from the disk
        STA LODADR+1    ;Store as load address hi·
                        ;and save it in X
        TAX
        JSR GETCHR      ;Get another byte
        STA LODADR      ;Store as load address low
        JSR GETCHR      ;Get a third byte
        STA PAGCNT      ;Store it as /I of pages
                        ;to load
        LDY #$00        ;Clear index register

HFF6F   JSR GETCHR      ;Get a data byte
        STA (LODADR),Y  ;Save it at current
                        ;location
        INY             ;Bump index
        BNE HFF6F       ;Loop until a page is full
        INC LODADR+1    ;When a page is full, incr
                        ;addr hi, decr the # of
                        ;pages to load
        DEC PAGCNT      ;
        BNE HFF6F       ;Loop until all pages are
                        ;done
        STX LODADR+1    ;Then, restore addr hi
                        ;
        LDA #$FF        ;Lift the head
        STA DSKPIA+2    ;
        RTS             ;Go home, page zero is
                        ;loaded
;
; *** Timed Wait Routine ***
;
; Wait 1250 * X + 11 machine cycles
;
WAIT    LDY #$F8        ;2 ; Get a 248, decimal
                        ;
HFF87   DEY             ;2 ; Inner loop - wait 1240
        BNE HFF87       ;2/3 ; machine cycles
                        ;
        EOR PAGCNT,X    ;4 ; waste 4 cycles
        DEX             ;2 ; Wait X * 1250 cycles
        BNE WAIT        ;2/3 ; Loop until done
        RTS             ;6 ; Go home after X*1250+
                        ;11 cycles
;
; *** Get a byte from the disk ***
GETCHR  LDA DSKACI      ;Wait for ACIA receive flag
        LSR A           ;
        BCC GETCHR      ;
        LDA DSKACI+1    ;It's there, get the byte
HFF99   RTS             ;And go home
;
HFF9A   .BYTE "H/D/M?"  ;*** Request Message ***
;
;
; *** RESET Entry Point ***
;
RSTADR  CLD             ;Clear the decimal flag
                        ;* Clear the screen *
        LDX #$D8        ;Get the high video page# + 1

        LDA #$D0        ;Get the low video page #
        STA LODADR+1    ;Store it in an indirect register

        LDY #$00        ;Clear the low byte of the reg
        STY LODADR
        LDA #$20        ;Get a blank
HFFAD   STA (LODADR),Y  ;Clear a char
        INY             ;Bump the index
        BNE HFFAD       ;Loop until a page is done
        INC LODADR+1    ;Then inc the page #
        CPX LODADR+1    ;Done with the screen?
        BNE HFFAD       ;No, keep going
        LDA #$03        ;* Reset the serial port *
        STA SERPRT      ;Reset the ACIA
        LDA #$B1        ;Select - enable xmit &
                        ;recv interrupts, 8 bit,
                        ;no parity, 2 stop bits,
                        ;/16 clock
        STA SERPRT
                        ;
                        ; *Print the request Message *
                        ;
HFFC2   LDA HFF9A,Y     ;Get a char
        BMI HFFD5       ;Skip when "CLD' reached
        STA HD0C6,Y     ;Start at 4th line, 6th col
        LDX HFE01       ;Send to serial only if valid,
                        ; else, skip
        BNE HFFD2       ;
        JSR HFE0B       ;Call serial out routine
HFFD2   INY             ;Loop
        BNE HFFC2       ;
HFFD5   LDA HFE01       ;Test for video or serial systems
        BNE HFFDF       ;Skip if video
        JSR HFE00       ;Get char from serial
                        ;device then skip, else
                        ;get char from keyboard
        BCS HFFE2       ;
HFFDF   JSR HFEED       ;
HFFE2   CMP #$48        ;Is it an 'H'?
        BEQ HFFF0       ;Yes, do hard disk boot
        CMP #$44        ;Is it a 'D'?
        BNE HFFF6       ;No, go to ROM monitor
        JSR HFF00       ;Yes, load track zero
        JMP STRTAD      ;Then go to $2200
HFFF0   JMP HFD00       ;Goto hard disk routine.
        JSR HFF00       ;** Unreachable code **
HFFF6   JMP (HFEFC)     ;Enter ROM monitor
        NOP             ;** Unreachable code **
HFFFA  .WORD NMIADR     ;NMI Vector
HFFFC  .WORD RSTADR     ;RESET Vector
HFFFE  .WORD IRQADR     ;IRQ Vector
       .END
