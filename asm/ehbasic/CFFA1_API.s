;------------------------------------------------------------------------------
; CFFA1_API.s  Version 1.0 - 05/22/2007
;
; Equates for calling the CFFA1 API -- Firmware version 1.0 ($01)
;------------------------------------------------------------------------------

CFFA1_ID1           = $AFDC   ; contains $CF when CFFA1 card is present
CFFA1_ID2           = $AFDD   ; contains $FA when CFFA1 card is present

FirmwareVersion     = $01

;------------------------------------------------------------------------------
; Entry points to the CFFA1 firmware:
;
; MenuExitToMonitor
;   JMP here to display the CFFA1 menu.
;   Quit puts the user into the monitor.
;
; MenuExitToBASIC
;   JMP here to display the CFFA1 menu.
;   Quit puts the user into BASIC.
;
; Menu
;   JSR here to display the CFFA1 menu.
;   Quit returns control to your code.
;
; CFBlockDriver
;   JSR here to read or write a block, after setting up pdCommandCode
;   and other inputs (see below).
;   Result:  CLC, A = 0
;            SEC, A = error code
;
; CFFA1_API
;   JSR here to call one of many functions provided by the firmware.
;   See "Function selectors for CFFA1_API" below.
;
;------------------------------------------------------------------------------
MenuExitToMonitor   = $9000
MenuExitToBASIC     = $9003
Menu                = $9006
CFBlockDriver       = $9009
CFFA1_API           = $900C


;------------------------------------------------------------------------------
; Inputs for CFBlockDriver - ProDOS block interface locations
;------------------------------------------------------------------------------
pdCommandCode       = $42     ; see below
pdUnitNumber        = $43     ; always set this to 0 for firmware 1.0
pdIOBufferLow       = $44
pdIOBufferHigh      = $45
pdBlockNumberLow    = $46
pdBlockNumberHigh   = $47

;
; Values for pdCommandCode
;
PRODOS_STATUS       = $00
PRODOS_READ         = $01
PRODOS_WRITE        = $02
PRODOS_FORMAT       = $03


;------------------------------------------------------------------------------
; Function selectors for CFFA1_API.
;
; Load one of these values into X:
;
;    ldx #CFFA1_xxxxx
;    jsr API
;
; Result:  CLC, A = 0
;          SEC, A = error code
;
; Certain functions have additional outputs, as described below.
;
;------------------------------------------------------------------------------
;
; CFFA1_Version:
;   Output: X = current firmware version
;           Y = oldest compatible firmware version
;
; CFFA1_Menu:
;   Result: Runs the CFFA1 menu and returns when the user chooses Quit.
;
; CFFA1_DisplayError:
;   Input:  A = an error code
;   Result: Prints out a carriage return, the 2-digit hex error code,
;           and a description of that error, if available.
;
; CFFA1_OpenDir:
;   Input:  None (operates on the current prefix directory)
;   Result: Prepares for one or more calls to ReadDir.
;
; CFFA1_ReadDir:
;   Setup:  You have to call OpenDir before calling ReadDir.
;   Result: If no error, EntryPtr points to the next occupied directory entry.
;
; CFFA1_FindDirEntry:
;   Input:   Filename = name to search for
;   Result:  If no error, EntryPtr points at the found item's directory entry.
;
; CFFA1_WriteFile:
;   Input:  Filename = name for new file (will be replaced if it already exists)
;           Destination = starting address
;           FileSize = number of bytes to write
;           Filetype = type for new file
;           Auxtype = auxiliary type for new file
;
; CFFA1_ReadFile:
;   Input:  Filename = file to read into memory
;           Destination = starting address ($0000 to use the file's Auxtype value)
;
; CFFA1_SaveBASICFile:
;   Input:  Filename
;
; CFFA1_LoadBASICFile:
;   Input:  Filename
;
; CFFA1_Rename:
;   Input:  OldFilename = original name
;           Filename = new name
;
; CFFA1_Delete:
;   Input:  Filename = file or empty directory to delete
;
; CFFA1_NewDirectoryAtRoot:
;   Input:  Filename = name for new directory
;
; CFFA1_FormatDrive:
;   Input:  Filename = name for new volume
;           A = drive number (always set to 0 for firmware 1.0)
;           Y = $77 (just to help avoid accidental formatting)
;   Result: Disk volume is erased and given the specified name.
;
;------------------------------------------------------------------------------
CFFA1_Version            = $00
CFFA1_Menu               = $02
CFFA1_DisplayError       = $04

CFFA1_OpenDir            = $10
CFFA1_ReadDir            = $12
CFFA1_FindDirEntry       = $14

CFFA1_WriteFile          = $20
CFFA1_ReadFile           = $22
CFFA1_SaveBASICFile      = $24
CFFA1_LoadBASICFile      = $26
CFFA1_Rename             = $28
CFFA1_Delete             = $2A
CFFA1_NewDirectoryAtRoot = $2C
CFFA1_FormatDrive        = $2E


;------------------------------------------------------------------------------
; Zero-page inputs and results for API functions
;
; Filename and OldFilename point to strings that begin with a length byte (from
; 1 to 15), and each character must have its high bit off.  For example:
;
;    Filename   = $80     $280: 05  48  45  4C  4C  4F
;    Filename+1 = $02              'H'  'E' 'L' 'L' 'O'
;------------------------------------------------------------------------------
Destination         = $00                   ; 2 bytes
Filename            = Destination+2         ; 2 bytes
OldFilename         = Filename+2            ; 2 bytes
Filetype            = OldFilename+2         ; 1 byte
Auxtype             = Filetype+1            ; 2 bytes
FileSize            = Auxtype+2             ; 2 bytes
EntryPtr            = FileSize+2            ; 2 bytes


;------------------------------------------------------------------------------
;
; ProDOS low-level return codes
;
;------------------------------------------------------------------------------
PRODOS_NO_ERROR      = $00    ; No error
PRODOS_BADCMD        = $01    ; Bad Command (not implemented)
PRODOS_IO_ERROR      = $27    ; I/O error
PRODOS_NO_DEVICE     = $28    ; No Device Connected
PRODOS_WRITE_PROTECT = $2B    ; Write Protected
PRODOS_BADBLOCK      = $2D    ; Invalid block number requested
PRODOS_OFFLINE       = $2F    ; Device off-line
;
; High-level return codes
;
eBadPathSyntax       = $40
eDirNotFound         = $44
eFileNotFound        = $46
eDuplicateFile       = $47
eVolumeFull          = $48
eDirectoryFull       = $49
eFileFormat          = $4A
eBadStrgType         = $4B
eFileLocked          = $4E
eNotProDOS           = $52
eBadBufferAddr       = $56
eBakedBitmap         = $5A
eUnknownBASICFormat  = $FE
eUnimplemented       = $FF


;------------------------------------------------------------------------------
; ProDOS directory entry structure offsets
;------------------------------------------------------------------------------
oFiletype           = $10
oKeyBlock           = $11
oBlockCount         = $13
oFileSize           = $15
oCreateDateTime     = $18
oVersion            = $1C
oMinVersion         = $1D
oAccess             = $1E
oAuxtype            = $1F
oModDateTime        = $21
oHeaderPointer      = $25

oDirLinkPrevious    = $00
oDirLinkNext        = $02
oVolStorageType     = $04
oVolVersion         = $20
oVolAccess          = $22
oVolEntryLength     = $23
oVolEntriesPerBlock = $24
oVolFileCount       = $25
oVolBitmapNumber    = $27
oVolTotalBlocks     = $29

;
; ProDOS Storage types
;
kSeedling           = $10
kSapling            = $20
kTree               = $30
kExtended           = $50
kDirectory          = $D0
kSubdirHeader       = $E0
kVolume             = $F0
kStorageTypeMask    = $F0

;
; Filetypes
;
kFiletypeText       = $04
kFiletypeBinary     = $06
kFiletypeDirectory  = $0F
kFiletypeBASIC1     = $F1
kFiletypeBAS        = $FC
kFiletypeSYS        = $FF

;------------------------------------------------------------------------------
; end of CFFA1_API.s
;------------------------------------------------------------------------------

