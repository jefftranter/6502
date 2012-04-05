; See http://jefftranter.blogspot.ca/2012/03/direct-keyboard-input-from-basic.html

  CR   = $D011 ; CONTROL REGISTER
  DATA = $D010 ; DATA REGISTER

POLL: LDA CR   ; READ CONTROL REG
      BPL POLL ; BRANCH UNTIL BIT 7 SET
      LDA DATA ; GET CHARACTER
      STA KEY  ; STORE IT
      RTS      ; RETURN

KEY: .byte $00 ; KEY CODE
