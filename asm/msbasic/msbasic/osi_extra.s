.segment "EXTRA"

.include "CFFA1_API.s"

  ESC = $1B        ; Escape character

  IN    = $0200    ; Buffer used by GetLine. From $0200 through $027F (shared with Woz Mon)

  SaveZeroPage    = $9140      ; Routines in CFFA1 firmware
  RestoreZeroPage = $9135

; Read key from keyboard.
MONRDKEY:
        LDA     $D011           ; keyboard status
        BPL     MONRDKEY        ; branch until key pressed
        LDA     $D010           ; keyboard data
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

        LDA     #$00                       ; Destination of $0000 means use file's Auxtype value
        STA     Destination
        STA     Destination+1

        LDX     #CFFA1_ReadFile            ; Write the file
        JSR     CFFA1_API
        BCC     Restore1                   ; Branch if succeeded
        LDX     #CFFA1_DisplayError        ; Otherwise display error message
        JSR     CFFA1_API

; Now restore the page zero locations
Restore1:
        JSR     RestoreZeroPage

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

; Call CFFA1 routines to save file. Save memory from RAMSTART2 to
; MEMSIZ.

        LDA     #<IN                       ; Filename is in input buffer, length byte first.
        STA     Filename
        LDA     #>IN
        STA     Filename+1

        LDA     #<RAMSTART2                ; Start address
        STA     Destination
        LDA     #>RAMSTART2
        STA     Destination+1
   
        SEC
        LDA     MEMSIZ                     ; Length is end address minus start address
        SBC     Destination
        STA     FileSize

        LDA     MEMSIZ+1
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
        STX TEMP1
        STY TEMP1+1
        LDY #0
@loop:  LDA (TEMP1),Y
        BEQ done
        JSR MONCOUT
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
        JSR  MONRDKEY		; Get character from keyboard
        AND  #$7F               ; Convert to ASCII
        CMP  #CR                ; <Enter> key pressed?
        BEQ  EnterPressed       ; If so, handle it
        CMP  #ESC               ; <Esc> key pressed?
        BEQ  EscapePressed      ; If so, handle it
        JSR  MONCOUT            ; Echo the key pressed
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
