;***************************************************
;***************************************************
;**                                               **
;**                                               **
;**                                               **
;**     ROCKWELL R6500 MICROCOMPUTER SYSTEM       **
;**                                               **
;**               AIM 65 MONITOR                  **
;**                                               **
;**         USER AVAILABLE SUBROUTINES            **
;**               AND VARIABLES                   **
;**                                               **
;**                                               **
;**                                               **
;***************************************************
;***************************************************

; Monitor variables
        .define UIN     $0108   ; 2 bytes, Vector to User Input Handler
        .define UOUT    $010A   ; 2 bytes, Vector to User Output Handler
        .define KEYF1   $010C   ; 3 bytes, JMP to User Function 1
        .define KEYF2   $010C   ; 3 bytes, JMP to User Function 2
        .define KEYF3   $010C   ; 3 bytes, JMP to User Function 3
        .define IRQV4   $A400   ; 2 bytes, Vector to IRQ after Monitor
                                ;          Interrupt Routine
        .define NMIV2   $A402   ; 2 bytes, Vector to NMI Interrupt Routine
        .define IRQV2   $A404   ; 2 bytes, Vector to IRQ Interrupt Routine
        .define DILINK  $A406   ; 2 bytes, Vector to Display Routine
        .define TSPEED  $A408   ; 1 byte, Audio Tape Speed
                                ;         Default = $C7 (AIM 65)
                                ;         Options = $5A (KIM-1 x 1)
                                ;         Options = $5B (KIM-1 x 3)
        .define GAP     $A409   ; 1 byte, Audio Tape Gap
                                ;         Default = $08 (32 SYN characters)
                                ;         Option  = $80 (for Assembler input & Editor update)
        .define INFLG   $A412   ; Input Device
        .define OUTFLG  $A413   ; Output Device
        .define S1      $A41A   ; Start Address
        .define ADDR    $A41C   ; End Address
        .define CKSUM   $A41E   ; Checksum
        .define NAME    $A42E   ; Tape File Name
        .define DRB     $A800   ; 6522 Data Register B

; Monitor routines
; Legend:
;        AID = Active Input Device
;        AOD = Active Output Device
;        D/P = Display / Printer
;        CR  = Carriage Return ASCII control code
;        LF  = Line Feed ASCII control code
;        NUL = Null ASCII control code
;        KB  = Keyboard

        .define BLANK   $E83E   ; Outputs one SP to D/P
        .define BLANK2  $E83B   ; Outputs two SP's to D/P
        .define CLR     $EB44   ; Clears D/P pointers
        .define CRCK    $EA24   ; Outputs print buffer to Printer
        .define CRLF    $E9F0   ; Outputs CR, LF & NUL to AOD
        .define CRLOW   $EA13   ; Outputs CR & LF to D/P
        .define COMIN   $E1A1   ;
        .define CUREAD  $FE83   ; Inputs one ASCII char from KB to A, display
                                ; cursor
        .define DISASM  $F46C   ; Outputs disassembled instruction
        .define DU11    $E50A   ;
        .define DUMPTA  $E56F   ; Opens Audio Tape output file
        .define EQUAL   $E7D8   ; Outputs "=" to D/P
        .define FROM    $E7A3   ; Outputs "FROM=" to D/P and enters address
        .define GETTAP  $EE29   ; Inputs one character from Audio Tape
        .define HEX     $EA7D   ; Converts a hex number in A from ASCII to
                                ; binary, and puts result in the LSD of A,
                                ; with zero in MSD of A
        .define INALL   $E993   ; Inputs one ASCII char from AID to A
        .define INLOW   $E8F8   ; Indicates KB input in INFLG
        .define LL      $E8FE   ; Sets input from KB and output to D/P
        .define LOADTA  $E32F   ; Searches for audio input file
        .define NOUT    $EA51   ; Converts a hex number in LSD of A from
                                ; binary to ASCII, and outputs them to AOD
        .define NUMA    $EA46   ; Converts two hex numbers in A from binary
                                ; to ASCII, and outputs them to AOD, MSD first
        .define OUTALL  $E9BC   ; Outputs ASCII char in A to AOD
        .define OUTCK1  $E53B   ;
        .define OUTDIS  $EF05   ;
        .define OUTDP   $EEFC   ;
        .define OUTDP1  $EF02   ;
        .define OUTLOW  $E901   ;
        .define OUTPRI  $F000   ;
        .define OUTPUT  $E97A   ; Outputs ASCII char in A to D/P
        .define OUTTAP  $F24A   ; Outputs ASCII char in A to Audo Tape
                                ; after SYN
        .define PACK    $EA84   ; Converts a hex number in A from ASCII to
                                ; binary, and puts result in the LSD of A,
                                ; with the result of the last call to PACK
                                ; or HEX in the MSD of A
        .define PHXY    $EB9E   ; Push X and Y Registers onto Stack
        .define PLXY    $EBAC   ; Pull X and Y Registers from Stack
        .define PSL1    $E837   ; Outputs "/" to D/P
        .define QM      $E7D4   ; Outputs "?" to D/P
        .define RBYTE   $E3FD   ; Inputs two ASCII chars from AID, and
                                ; converts to binary with result in A
        .define RCHEK   $E907   ; Scans KB, returns to Monitor in ESC, to
                                ; caller on no entry, wait on SP
        .define RDRUB   $E95F   ; Inputs one ASCII char from KB to A, with
                                ; echo to D/P. Allows DEL, if Y != 0
        .define READ    $E93C   ; Inputs one ASCII char from KB to A
        .define RED1    $FE96   ; Inputs one char from KB, with echo to D/P
        .define REDOUT  $E973   ; Inputs one ASCII char from KB to A, with
                                ; echo to D/P, displays cursor
        .define SEMI    $E9BA   ; Outputs ";" to AOD
        .define TAISET  $EDEA   ; Sets up Audio Tape input, detects five SYN
                                ; chars
        .define TAOSET  $F21D   ; Sets up Audio Tape output, issues SYN
                                ; characters
        .define TIBY1   $ED53   ; Loads a block of 80 bytes from Audio Tape
        .define TIBYTE  $ED3B   ;
        .define TO      $E7A7   ; Outputs "TO" to D/P and enters address
        .define TOBYTE  $F18B   ;
        .define TOGTA1  $E6BD   ;
        .define TOGTA2  $E6CB   ;
        .define TOPNO   $F8BC   ;
        .define WRAX    $EA42   ;
        .define WHEREI  $E848   ; Sets up the AID and loads INFLG
        .define WHEREO  $E871   ; Sets up the AOD and loads OUTFLG
