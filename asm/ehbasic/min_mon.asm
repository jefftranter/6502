
; minimal monitor for EhBASIC and 6502 simulator V1.05
; Modified to support the Replica 1 by Jeff Tranter <tranter@pobox.com>

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.

	.include "basic.asm"
        .include "CFFA1_API.s"

ESC = $1B        ; Escape character
CR  = $0D        ; Return character
LF  = $0A        ; Line feed character

IN    = $0200    ; Buffer used by GetLine. From $0200 through $027F (shared with Woz Mon)

SaveZeroPage    = $9140      ; Routines in CFFA1 firmware
RestoreZeroPage = $9135

; put the IRQ and MNI code in RAM so that it can be changed

IRQ_vec	= VEC_SV+2		; IRQ code vector
NMI_vec	= IRQ_vec+$0A	; NMI code vector

; setup for the 6502 simulator environment

IO_AREA	= $F000		; set I/O area for this monitor

ACIAsimwr	= IO_AREA+$01	; simulated ACIA write port
ACIAsimrd	= IO_AREA+$04	; simulated ACIA read port

; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

;	.org	$FF80			; pretend this is in a 1/8K ROM

; reset vector points here

RES_vec
	CLD				; clear decimal mode
	LDX	#$FF			; empty stack
	TXS				; set the stack

; set up vectors and interrupt code, copy them to page 2

	LDY	#END_CODE-LAB_vec	; set index/count
LAB_stlp
	LDA	LAB_vec-1,Y		; get byte from interrupt code
	STA	VEC_IN-1,Y		; save to RAM
	DEY				; decrement index/count
	BNE	LAB_stlp		; loop if more to do

; now do the signon message, Y = $00 here

LAB_signon
	LDA	LAB_mess,Y		; get byte from sign on message
	BEQ	LAB_nokey		; exit loop if done

	JSR	V_OUTP		; output character
	INY				; increment index
	BNE	LAB_signon		; loop, branch always

LAB_nokey
	JSR	V_INPT		; call scan input device
	BCC	LAB_nokey		; loop if no key

	AND	#$DF			; mask xx0x xxxx, ensure upper case
	CMP	#'W'			; compare with [W]arm start
	BEQ	LAB_dowarm		; branch if [W]arm start

	CMP	#'C'			; compare with [C]old start
	BNE	RES_vec		; loop if not [C]old start

	JMP	LAB_COLD		; do EhBASIC cold start

LAB_dowarm
	JMP	LAB_WARM		; do EhBASIC warm start

; byte out to Replica 1/Apple 1 screen

ACIAout
        CMP     #LF                     ; Ignore line feed character
        BEQ     Ignore
WaitForReady:      
	BIT	$D012
	BMI     WaitForReady
	STA	$D012
Ignore:
	RTS

; byte in from Replica 1/Apple 1 keyboard

ACIAin
	LDA	$D011
	BPL	LAB_nobyw		; branch if no byte waiting

	LDA	$D010
	AND	#$7F			; clear high bit
	SEC				; flag byte received
	RTS

LAB_nobyw
	CLC				; flag no byte received
        RTS

; Check for presence of CFFA1 by testing for two ID bytes
CheckForCFFA1:
        LDA     CFFA1_ID1               ; First CFFA1 ID byte
        CMP     #$CF                    ; Should contain $CF
        BNE     NoCFFA1
        LDA     CFFA1_ID2               ; Second CFFA1 ID byte
        CMP     #$FA                    ; Should contain $FA
        BNE     NoCFFA1
        RTS
NoCFFA1:
        LDX     #<NoCFFA1String         ; Display error that no CFFA1 is present.
        LDY     #>NoCFFA1String
        JSR     PrintString
        PLA                             ; pop return address so we return to caller of calling routine
        PLA
 	RTS

; Implementation of LOAD using a CFFA1 flash interface if present.
LOAD:
        JSR     CheckForCFFA1           ; returns to caller of this routine if not present

; Prompt user for filename to load

        LDX     #<FilenameString
        LDY     #>FilenameString
        JSR     PrintString

; Get filename
        JSR     GetLine

; If user hit <Esc>, cancel the load
        BCS     Return1

; If filename was empty, call CFFA1 menu
        LDA     IN                     ; string length
        BNE     LoadFile               ; Was is zero length?
        JSR     Menu                   ; If so, call CFFA1 menu
        RTS                            ; and return

; Need to save the page zero locations used by the CFFA1 because they are also used by BASIC.

LoadFile:
        JSR     SaveZeroPage

; Call CFFA1 routines to load file.

        LDA     #<IN                       ; Filename is in input buffer, length byte first.
        STA     Filename
        LDA     #>IN
        STA     Filename+1

        LDA     Smeml
        STA     Destination
        LDA     Smemh
        STA     Destination+1

        LDX     #CFFA1_ReadFile            ; Write the file
        JSR     CFFA1_API
        BCC     Restore1                   ; Branch if succeeded
        LDX     #CFFA1_DisplayError        ; Otherwise display error message
        JSR     CFFA1_API

; Now restore the page zero locations
Restore1:
        LDA     FileSize                   ; Save FileSize before it gets overwritten by RestoreZeroPage
        STA     IN
        LDA     FileSize+1
        STA     IN+1
        JSR     RestoreZeroPage            ; Restore page zero addresses used by CFFA1 firmware
        CLC
        LDA     Smeml                      ; Calculate end address by taking start
        ADC     IN                         ; add FileSize
        STA     Svarl                      ; And save
        LDA     Smemh                      ; Same for high byte
        ADC     IN+1                       ; FileSize+1
        STA     Svarh

        LDA     #CR                        ; Echo newline
        JSR     ACIAout

        JSR     LAB_1477                   ; Need to call this BASIC routine to clear variables and reset the execution pointer
        JMP     LAB_1319                   ; Jump to appropriate location in BASIC
Return1:
        RTS

; Implementation of SAVE using a CFFA1 flash interface if present.
SAVE:
        JSR     CheckForCFFA1

; Prompt user for filename to save

        LDX     #<FilenameString
        LDY     #>FilenameString
        JSR     PrintString

; Get filename
        JSR     GetLine

; If user hit <Esc>, cancel the save
        BCS     Return2

; If filename was empty, call CFFA1 menu
        LDA     IN                     ; string length
        BNE     SaveFile               ; Was is zero length?
        JSR     Menu                   ; If so, call CFFA1 menu
        RTS                            ; and return

; Need to save the page zero locations used by the CFFA1 because they are also used by BASIC.
SaveFile:
        JSR     SaveZeroPage

; Call CFFA1 routines to save file.

        LDA     #<IN                       ; Filename is in input buffer, length byte first.
        STA     Filename
        LDA     #>IN
        STA     Filename+1

        LDA     Smeml                      ; Start address is (Smeml,Smemh)
        STA     Destination
        LDA     Smemh
        STA     Destination+1

        SEC
        LDA     Svarl                      ; Length is end address (Svarl, svarh) - start address
        SBC     Destination
        STA     FileSize

        LDA     Svarh
        SBC     Destination+1
        STA     FileSize+1

        LDA     #kFiletypeBinary           ; file type is binary
        STA     Filetype

        LDA     Destination                ; Aux type is start address
        STA     Auxtype
        LDA     Destination+1
        STA     Auxtype+1

        LDX     #CFFA1_WriteFile           ; Write the file
        JSR     CFFA1_API
        BCC     Restore2                   ; Branch if succeeded
        LDX     #CFFA1_DisplayError        ; Otherwise display error message
        JSR     CFFA1_API

; Now restore the page zero locations
Restore2:
        JSR     RestoreZeroPage

Return2:
        RTS

; Print a string
; Pass address of string in X (low) and Y (high).
; String must be terminated in a null.
; Cannot be longer than 256 characters.
; Registers changed: A, Y
;
PrintString:
        STX Itempl
        STY Itempl+1
        LDY #0
@loop:  LDA (Itempl),Y
        BEQ done
        JSR ACIAout
        INY
        BNE @loop       ; if doesn't branch, string is too long
done:   RTS

; String input routine.
; Enter characters from the keyboard terminated in <Return> or <ESC>.
; Characters are echoed.
; Can be up to 127 characters.
; Returns:
;   Length stored at IN (doesn't include zero byte).
;   Characters stored starting at IN+1 ($0201-$027F, same as Woz Monitor)
;   String is terminated in a 0 byte.
;   Carry set if user hit <Esc>, clear if used <Enter> or max string length reached.
; Registers changed: A, X
GetLine:
        LDX  #0                 ; Initialize index into buffer
loop:
        JSR  ACIAin		; Get character from keyboard
        BCC  loop
        CMP  #CR                ; <Enter> key pressed?
        BEQ  EnterPressed       ; If so, handle it
        CMP  #ESC               ; <Esc> key pressed?
        BEQ  EscapePressed      ; If so, handle it
        JSR  ACIAout            ; Echo the key pressed
        STA  IN+1,X             ; Store character in buffer (skip first length byte)
        INX                     ; Advance index into buffer
        CPX  #$7E               ; Buffer full?
        BEQ  EnterPressed       ; If so, return as if <Enter> was pressed
        BNE  loop               ; Always taken
EnterPressed:
        CLC                     ; Clear carry to indicate <Enter> pressed and fall through
EscapePressed:
        LDA  #0
        STA  IN+1,X             ; Store 0 at end of buffer
        STX  IN                 ; Store length of string
        RTS                     ; Return

NoCFFA1String:
  .byte "?NO CFFA1 ERROR",CR,0

FilenameString:
  .byte "FILENAME? ",0

; vector tables

LAB_vec
	.word	ACIAin		; byte in from simulated ACIA
	.word	ACIAout		; byte out to simulated ACIA
	.word	LOAD		; load vector for EhBASIC
	.word	SAVE		; save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE
	PHA				; save A
	LDA	IrqBase		; get the IRQ flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	IrqBase		; OR the original back in
	STA	IrqBase		; save the new IRQ flag byte
	PLA				; restore A
	RTI

; EhBASIC NMI support

NMI_CODE
	PHA				; save A
	LDA	NmiBase		; get the NMI flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	NmiBase		; OR the original back in
	STA	NmiBase		; save the new NMI flag byte
	PLA				; restore A
	RTI

END_CODE

LAB_mess
	.byte	$0D,$0A,"6502 EhBASIC [C]old/[W]arm ?",$00
					; sign on string

; system vectors

	.org	$FFFA

	.word	NMI_vec		; NMI vector
	.word	RES_vec		; RESET vector
	.word	IRQ_vec		; IRQ vector
