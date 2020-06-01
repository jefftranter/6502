; 6551 ACIA Example.
; Write a message out the serial port.
; Then read characters from the port and echo them back until 'Q' is pressed.
; Serial port set to 19200 8N1. No H/W handshaking (not connected on board).


; RxC pin at 19200bps outputs 16X or 307.2KHz
; 115200bps would be 1.8432 MHz. Too high for VIA to generate.

; Would be good enhancement to wire RTS and CTS to the serial port for H/W handshaking. Also DCD?

       .include "6551.inc"

       CR = $0A ; carriage return

; Set 1 stop bit, 8 bit data, internal clock, 19200bps
       LDA #%00011111
       STA CTLREG

; Set no parity, no echo, no TX interrupts, RTS low, no RX interrupts, DTR low  
      LDA #%00001011
      STA CMDREG

; Display OK\n
      LDA #'O'
      JSR ECHO
      LDA #'K'
      JSR ECHO
      LDA #CR
      JSR ECHO

; Now get a character and echo it back
; Quit if it is 'Q'
LOOP: JSR GETCHAR
      CMP #'Q'
      BEQ DONE
      JSR ECHO
      JMP LOOP
DONE: RTS

; Send character in A out serial port
ECHO:
        PHA
        LDA #$10
TXFULL: BIT STATUSREG ; wait for TDRE bit = 1
        BEQ TXFULL
        PLA
        STA TXDATA
        RTS

; Read character from serial port and return in A
GETCHAR:
        LDA #$08
RXFULL: BIT STATUSREG
        BEQ RXFULL
        LDA RXDATA
        RTS
