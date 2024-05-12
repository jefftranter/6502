# AIM Memory Map
*Transcript from MICRO - The 6502/6809 Journal, No. 38 - July 1981*

**This article describes how a ROM-based assembler works, with detailed instructions for getting at several useful, but undocumented features, including new .OPT functions for the AIM.**

---

Greg Paris<br />
11-2A English Village<br />
Cranford, N ew Jersey 07016

---

The AIM 65 assembler was designed by Compas Microsystems (the makers of the AIM monitor) to be a subset of its larger, RAM-based A/65 assembler. In fitting the AIM assembler into a 4K ROM, several features of the A/65 assembler had to be dropped. What remains, however, is an extremely useful program to be resident in one's AIM, even if it doesn't list a sorted symbol table or count lines of program listing.

I wanted to see if I could extend the AIM assembler's command, set through a conveniently-placed zero-page RAM hook or vector. I found out quickly that I could not. But in the process of line-by-line decoding, I found many other things of interest — some useful subroutines which can be called from outside the assembler, and several hidden shortcuts and undocumented functions. This article will provide a memory map of the AIM 65 assembler ROM, describe its operation and use of RAM, and detail these undocumented features.

## The Assembler Disassembled

Table 1 shows how the assembler is organized into a 4K block of memory which starts at $DOOO. Most of the look-up tables are found near the upper end of this block, which allows the majority of the program from $EOOO to $DD4A to be disassembled continuously by use of the AIM monitor command "K ". If you do it for yourself, it's best to disassemble only 1 to 2 pages of memory at a time, to prevent your power supply from overheating any more than it usually does.

***Table 1: Assembler ROM Memory Map***

| Address<br />from | Address<br />to | Description |
| :--- | :--- | :--- |
| ``D000`` | ``DODF`` | initialize RAM and setup for PASS 1 |
| ``D0E0`` | ``DOE8`` | loop to process lines of source code; stack reset each time |
| ``D0E9`` | ``D66E`` | SBR - PROCESS a line... includes: |
| ``    `` | ``D104`` | ..get a line from AID; echo to display |
| ``    `` | ``D128`` | ..separate labels from mnemonics and operands |
| ``    `` | ``D1DB`` | ..reassign program counter or PC (* =) |
| ``    `` | ``D1E8`` | ..process an equate (=) |
| ``    `` | ``D259`` | ..directive (.XXX) decoding; then jump-indirect to do it |
| ``    `` | ``D299`` | ..encode data as per .BYT, .WOR, .DBY instructions |
| ``    `` | ``D346`` | ..check and assign .BYT data in ASCII literal format |
| ``    `` | ``D396`` | ..decode .OPT XXX; then jump-indirect to do it |
| ``    `` | ``D3B3`` | ..set up directive flag variable ($37) |
| ``    `` | ``D3CC`` | ..do .OPT SYM, NOS, NOC, CNT, and COU: i.e., nothing! |
| ``    `` | ``D3D4`` | ..perform .SKI |
| ``    `` | ``D3DE`` | ..perform .END; setup for PASS 2 |
| ``    `` | ``D414`` | ..toggle tape recorders while waiting for PASS 2 |
| ``    `` | ``D43E`` | ..set up FNAME for tape file for PASS 2 |
| ``    `` | ``D454`` | ..encode mnemonic/symbolic address into opcode/operand |
| ``D66F`` | ``D68F`` | SBR - do list of line and preset ERROR statement; then NEW line |
| ``D690`` | ``    `` | execute .FIL if AID = T or U |
| ``D69D`` | ``    `` | perform .PAG |
| ``D6CA`` | ``    `` | SBR - get beginning-of-line pointer, then
| ``D6CE`` | ``    `` | SBR - increment line pointer, then
| ``D6D0`` | ``D6E7`` | SBR - get first non­-space character to begin string
| ``D6E8`` | ``D71F`` | SBR - get last character in a string; ignore between quotes |
| ``D720`` | ``D74A`` | SBR - look for ), comma, space or end-of-line (EOL) |
| ``D74B`` | ``D75B`` | SBR - output the buffer to LIST-AOD until quote or EOL |
| ``D75C`` | ``D767`` | SBR - carry set if alphabetic character |
| ``D768`` | ``D773`` | SBR - carry set if numeric character |
| ``D774`` | ``    `` | SBR - set A = 3, then |
| ``D776`` | ``    `` | SBR - store A as number of characters, then |
| ``D778`` | ``D796`` | SBR - transfer characters from text buffer to SEARCH buffer |
| ``D797`` | ``D8AC`` | SBR - EVALUATE an expression..., includes: |
| ``    `` | ``D7B9`` | ..select low byte of symbol (<) (set up to convert to a hex number, i.e. .DBY format) |
| ``    `` | ``D7C1`` | ..select high byte of symbol (>) (set up to convert to a hex number, i.e. .DBY format) |
| ``    `` | ``D7D4`` | ..decimal number string (set up to convert to a hex number, i.e. .DBY format) |
| ``    `` | ``D7DA`` | ..hex number string ($) (set up to convert to a hex number, i.e. .DBY format) |
| ``    `` | ``D7E0`` | ..octal number string (@) (set up to convert to a hex number, i.e. .DBY format) |
| ``    `` | ``D7E6`` | ..binary number string (%) (set up to convert to a hex number, i.e. .DBY format) |
| ``    `` | ``D7E8`` | ..get symbol value with SEARCH |
| ``    `` | ``D81D`` | ..evaluate current pointer or PC (*) |
| ``    `` | ``D858`` | .. perform 2-byte addition (+) |
| ``    `` | ``D886`` | .. perform 2-byte subtraction (-) |
| ``D8AF`` | ``D8C2`` | SBR - test flag from EVALUATE for arithmetic error and overflow |
| ``D8C3`` | ``D8DA`` | SBR - get current character with X register as pointer; also check for end-of-symbol |
| ``D8DB`` | ``D8EC`` | SBR - get opcode addend from table |
| ``D8ED`` | ``D94E`` | SBR - base conversion |
| ``D94F`` | ``D955`` | SBR - test for carry from previously performed add/subtract |
| ``D956`` | ``D95D`` | TABLE - constants for base conversion |
| ``D95E`` | ``D9A1`` | SBR - SEARCH symbol table for entry |
| ``D9A2`` | ``D9D3`` | SBR - STORE symbol and value in table |
| ``D9D4`` | ``D9E9`` | SBR - if string = mnemonic, get opcode data |
| ``D9EA`` | ``DAOB`` | SBR - find mnemonic |
| ``DAOC`` | ``    `` | SBR - set flag for no­-error/list-line-only, then |
| ``DAOF`` | ``DA5D`` | SBR - decode error number, select LIST or not |
| ``DA5E`` | ``DBC6`` | SBR - LIST a line to LIST-AOD and output OBJ code to OBJ-AOD, followed by **ERROR XX, if needed..., includes: |
| ``    `` | ``DA7E`` | ..determine if PC needs to be output |
| ``    `` | ``DA90`` | ..output PC at beginning of line, then |
| ``    `` | ``DAAO`` | ..output label if one is present |
| ``    `` | ``DAC3`` | ..recalculate when next PC announcement is due |
| ``    `` | ``DADO`` | ..output opcode/operand or data |
| ``    `` | ``DB19`` | ..output rest of line |
| ``    `` | ``DB62`` | ..format quotated strings |
| ``    `` | ``DBB2`` | ..finish output line; return for more data if .OPT GEN selected |
| ``DBC7`` | ``DBEC`` | SBR - output an error message and number; increment error count |
| ``DBED`` | ``    `` | SBR - set A = 1, then |
| ``DBEF`` | ``    `` | SBR - add A to PC, then |
| ``DBF8`` | ``    `` | SBR - zero A, then |
| ``DBFA`` | ``DC05`` | SBR - add PC to A storing result as memory deposit pointer |
| ``DC06`` | ``    `` | SBR - output single byte to OBJ-AOD |
| ``DC09`` | ``DC28`` | SBR - output byte as 2 ASCII hex numbers to OBJ-AOD |
| ``DC29`` | ``    `` | SBR - add opcode to A, then |
| ``DC2E`` | ``DC4D`` | SBR - output A to memory, or to OBJ-OUT intermediate buffer |
| ``DC4E`` | ``    `` | SBR - move from intermediate buffer to OBJ-OUT buffer, then |
| ``DCA9`` | ``DCB7`` | SBR - clear OBJ-OUT intermediate buffer |
| ``DCB8`` | ``    `` | SBR - zero and start OBJ-checksum calculation, then |
| ``DCC8`` | ``DCD1`` | SBR - add A to OBJ-checksum |
| ``DCD2`` | ``    `` | SBR - format and output an OBJ-code record, then |
| ``DD02`` | ``DDOC`` | SBR - CRLF to OBJ-AOD |
| ``DDOD`` | ``DD4A`` | SBR - format and do last OBJ-record; close tape file |
| ``DD4B`` | ``DD74`` | TABLE - assembler directive action addresses (.WOR format) |
| ``DD75`` | ``DDB3`` | TABLE - assembler directives and .OPT list, in ASCII |
| ``DDB4`` | ``DE5B`` | TABLE - mnemonic list, in ASCII, in alphabetic order |
| ``DE5C`` | ``DE65`` | TABLE - allowed opcode addends |
| ``DE66`` | ``DE74`` | TABLE - look-up index to reference table $DE75 |
| ``DE75`` | ``DEDD`` | TABLE - look-up legal operand format |
| ``DEDE`` | ``DF15`` | TABLE - opcode classification list |
| ``DF16`` | ``DF4D`` | TABLE - basal opcodes; in same order as mnemonics |
| ``DF4E`` | ``DFA2`` | TABLE - messages, in ASCII; each one ends with a semicolon |
| ``DFA3`` | ``DFA7`` | TABLE - reserved labels, in ASCII: "AXYSP" |
| ``DFA8`` | ``    `` | SBR - set up display and monitor with FNAME of .FIL, then |
| ``DFCC`` | ``DFDC`` | SBR - go get file if AID = T or U |
| ``DFDD`` | ``DFE8`` | SBR - print a message; input in X = offset of beginning of message from $DF4E |
| ``DFE9`` | ``    `` | SBR - output a blank space, then |
| ``DFEC`` | ``DFF5`` | SBR - output a CRLF to AOD |
| ``DFF6`` | ``DFF9`` | ??TABLE?? - four unidentified bytes... |
| ``DFFA`` | ``DFFE`` | SBR - output space to AOD |
| ``DFFF`` | ``    `` | "N" in ASCII: the monitor command to jump to the Assemble |

There are several directives and "list" options which are supported by the assembler. The recognition process requires that a list of these commands (in ASCII) be present in ROM to be scanned as necessary. This list, and the action address for each command, are shown in table 2. I noticed that there were more options listed in ROM than I had ever seen described. As I will detail later, there is a new pair of options which are supported — .OPT MEM and .OPT NOM — and several which are recognized (i.e., not rejected outright with "**ERROR 14") but simply ignored.

A memory map of any program is only of limited usefulness if its constants and variables are not well-documented. Table 3 shows how the assembler utilizes zero page RAM, and the functions of most of these addresses, or their contents. In addition to this zero page use, a section of page one, just below the stack area, is reserved for the temporary storage of compiled opcodes and data. Several addresses vie for the most-used-zero-page-address award, but the winners are $46+ (the text input buffer starting address), $35 (the length of the current line in said buffer), and $29 (the pointer to the active character in this buffer, a single byte usually stored here from the X register)

## How It Works

The following description will be most informative if the disassembled object code is available, if for no other reason than to see how some of the tricks are accomplished with minimal coding. But it's not absolutely necessary.

All the real work of assembly is directed from the subroutine at $D0E9 - $D66E, which I've labeled PROCESS. The section immediately preceding this (from $D0E0 - $D0E8) is a small loop which calls PROCESS each time a new line is to be processed. This loop does only two things: resets the stack pointer, and calls PROCESS. All other subroutines are called from PROCESS.

If it becomes necessary to leave PROCESS because of some fatal processing error, even if the stack pointer is randomly set, there is no problem because exit always occurs after the stack pointer is partially reset. This allows an RTS instruction to return control to the small loop. (See $D686 - $D688 for how this is done.)

The assembler itself has very few functions: get some text; try to assemble it; check for errors; and output the results. The actual processing is almost as simple as the statement.

***Table 2: Assembler Directive and Option Mnemonics***

| Location of<br />First Byte<br />(hex) | Mnemonic | Action<br />Address<br />(hex) |
| :------- | :------- | :--- |
| ``DD75`` | ``BYT`` | ``D299`` |
| ``DD78`` | ``WOR`` | ``D2A1`` |
| ``DD7B`` | ``DBY`` | ``D29D`` |
| ``DD7E`` | ``SKI`` | ``D3D4`` |
| ``DD81`` | ``PAG`` | ``D69D`` |
| ``DD84`` | ``END`` | ``D3DE`` |
| ``DD87`` | ``OPT`` | ``D39D`` |
| ``DD8A`` | ``FIL`` | ``D690`` |
| ``DD8D`` | ``GEN`` | ``D3B3`` |
| ``DD90`` | ``NOG`` | ``D3B7`` |
| ``DD93`` | ``SYM`` | ``D3CC (unsupported)`` |
| ``DD96`` | ``NOS`` | ``D3CC (unsupported)`` |
| ``DD99`` | ``NOC`` | ``D3CC (unsupported)`` |
| ``DD9C`` | ``CNT`` | ``D3CC (unsupported)`` |
| ``DD9F`` | ``COU`` | ``D3CC (unsupported)`` |
| ``DDA2`` | ``ERR`` | ``D3BB`` |
| ``DDA5`` | ``NOE`` | ``D3BF`` |
| ``DDA8`` | ``MEM`` | ``D3C8`` |
| ``DDAB`` | ``NOM`` | ``D3C4`` |
| ``DDAE`` | ``LIS`` | ``D3BF`` |
| ``DDB1`` | ``NOL`` | ``D3BB`` |

Input text is obtained from the AID as specified by the monitor variable IN-FLG (which also allows input directly from memory) in a loop from $D104 - $D127. Output, on the other hand, can w be two-fold: actual object code (the real reason for using this program, after all) and a formatted assembly listing. These must go to two different devices, and a significant portion of the assembler is devoted to the proper formatting of the listing ($DA5E - $DBEC) and to the production of a formatted standard object code ($DBED - $DD4A). If the object code is to go directly to memory, no formatting into a record is performed, and the code is merely deposited (at step $DC3C) as per the pointer in $09/0A.

The assembly itself is done as follows. The input line is first parsed into labels, mnemonics or assembly directives. Any string that does not meet these criteria is rejected with error numbers 3, 8, 9,10, or 20. Directives are processed by the section which starts at $D259; the jump-indirect to the specific address is taken only after the directive in the text is compared with those com­mands supported (see table 2) and the proper action address is obtained from the table at $DD4B. Any errors in this process are called "undefined assembler directives." When a directive has been performed and listed (if desired), exit to the small loop at $D0E0 occurs.

Those strings which are used as symbolic constants or address labels are differentiated from mnemonics by length, or by a mnemonic scan called from $D167. Labels may be associated with equates, or with the current program counter address (PC). On the first pass, if the string is legal and not a mnemonic, it is assigned a value and placed in the symbol table with this value by the subroutine called from $D1CF. If the string is found to be a mnemonic, a branch occurs to that section of the assembler which performs the actual opcode assembly calculations.

The opcode compiler starts at $D454 and is the heart of the assembler. First the mnemonic is checked against a list in ROM, which starts at $DDB4. Like the directive list, this list is in ASCII, and is conveniently arranged alphabetically. Then, two new bytes of information are obtained using the position of the mnemonic in the list as an index. The table which starts at $DF16 yields the "basal opcode." This is a single byte which represents the lowest numeric value of the opcodes allowed for a given instruction, to which a constant determined by the assembler may be added. And the table at $DEDE yields the opcode classification type. How do these two bytes determine the actual opcode?

If you look at the allowed instruction set for the 6502, you will see that not only does it contain holes (not all instructions use all addressing modes) but there is some pattern to these holes. Various mnemonics can be grouped together by considering which modes are allowed for each. Table 4 shows how this classification scheme is implemented. What the assembler does in the opcode compiling section is to sort out the requested mode, and give errors if this disagrees with those allowable modes obtained from table $DEDE. Then it evaluates the expression which is the operand (if any) and does the following calculation (more or less):

>basal opcode + (addend from table $DE5C x factor Q) = opcode for the desired addressing mode.

"Factor Q" is determined when the syntax of the operand is checked. It takes into account such things as whether the address is page zero, or whether the mode is implied, indirect, indexed, etc. If your source code can run this gantlet, it is assembled.

One concept simplifies the control of much of the operation of the assembler - flag variables. Several page zero locations store information which is used repeatedly to direct operations: locations $21 - $23, and $36 - $38. Of central importance is the directive flag, $37.

Three of its bits are used to store the status of various selected options and allow this status to be tested frequently during assembly. Table 5 details how the bits of this variable are understood by the assembler. This variable will also be of importance later in the discussion of the  undocumented  .OPT MEM/NOM functions.

There are few differences between PASS 1 and PASS 2. During the first pass, any output is swallowed by the program instead of being directed to the printer or OBJ-OUT device. The symbol table is compiled during the first pass, and is used extensively in the second pass to evaluate expressions. The distinction between each pass is signaled by the PASS 1/2 flag - $23.

## Undocumented Features

This is probably the section you turned to first! Here I'll describe those assembler functions which haven't been detailed in the AIM manual, including a few shorthand notations, a built-in routine which allows the user to toggle tape recorders on and off while waiting for PASS 2, and several undocumented .OPT functions, especially two which are supported but not described in the manual.

1. I found three shorthand techniques that are allowed by the assembler. First, the indexed indirect addressing mode can be written either as LDA (VAR,X) or LDA (VAR,X with no closing parenthesis. Second, the indirect indexed addressing mode can be written either as LDA (VAR),Y or LDA (VAR)Y with no separating comma. Third, single-byte ASCII literal operands may be denoted in two ways: CMP #'X' or CMP #'X with no closing quotation mark. This last shorthand is not explicitly stated in the AIM manual, but it is used as an example on pg. 5-19 (rev 3/79). These shorthand methods save one shifted keystroke per operand. Note, however, that .BYT 'XXXXXXX' still requires a closing quotation mark.

2. If you have ever assembled from a source file on a tape cassette under remote control, you will have noticed one inconvenient operating detail: while the assembler waits to do PASS 2, the remote line shuts off your recorder! Before the tape can be rewound, you have to manually override this control, and, for example, disconnect the remote plug. But no more! The capability to toggle the tape remote control is already a part of the assembler. Here is how it works.

***Table 3: Assembler RAM Usage***

| Address<br />(hex) | Description |
| :--- | : --- |
| ``00⇨03`` | (not used) |
| ``04`` | number of bytes in data or opcode/operand at SBR $DA0F |
| ``05`` | (not used) |
| ``06/07`` | .WOR - temporary storage of program counter (PC) |
| ``08`` | error index at SBR $DA0F |
| ``09/0A`` | .WOR - pointer used to store OBJ code in memory |
| ``0B/0C`` | .DBY - number of entries in symbol table |
| ``0D/0E`` | .WOR - directive action ad­dress or SEARCH address |
| ``OF`` | basal opcode stored here |
| ``10`` | opcode classification type (see table 4); or $E if branch |
| ``11/12`` | .WOR - symbol counter for SEARCH |
| ``13/14`` | .DBY - value of symbol; or workspace for * assignment |
| ``15`` | + or - sign for EVALUATE |
| ``16`` | same as 04, but maximum value allowed is $14 |
| ``17/18`` | parameters for BASE con­version; loaded from table at $D956 |
| ``19`` | number of bytes in com­pleted .BYT ASCH literal string; or flag for format­ting quotated material for LIST |
| ``1A/1B`` | .DBY - number of errors in PASS 2 |
| ``1C`` | allowable operand coding key; used in opcode processing |
| ``1D`` | expression OK/NOK flag; used in opcode processing |
| ``1E`` | error number (in decimal) for to print **ERROR XX |
| ``1F`` | output line counter for LIST formatting |
| ``20`` | flag: "this line contains a label" |
| ``21`` | flag:"* = " |
| ``22`` | flag: used to select .DBY, .WOR, .BYT notation |
| ``23`` | pass counter: PASS 1=0; PASS 2=1 |
| ``24`` | pointer to next non-space character in buffer |
| ``25`` | pointer to last character of string in buffer |
| ``26`` | number of characters in string |
| ``27/28`` | .DBY - output of EVALUATE = value of ex­ pression |
| ``29`` | pointer to active character in buffer |
| ``2A⇨2F`` | string storage for com­parison by SEARCH |
| ``30`` | number of bytes compiled at SBR $D66F et al. |
| ``31`` | stored error number at SBR $D683 |
| ``32/33`` | .WOR - program counter or PC |
| ``34`` | display buffer pointer |
| ``35`` | number of characters in current line in buffer |
| ``36`` | flag: for > or < operations |
| ``37`` | flag: directive/option status (see table 5) |
| ``38`` | flag: arithmetic over- or under- flow from EVALUATE |
| ``39`` | number of bytes (.BYT = 1; .WOR and .DBY = 2) |
| ``3A/3B`` | .WOR - symbol table start |
| ``3C/3D`` | .WOR - last active symbol |
| ``3E/3F`` | .WOR - symbol table upper limit |
| ``40/41`` | .WOR - OBJ output record counter |
| ``42/43`` | .DBY - OBJ record checksum |
| ``44/45`` | .WOR - address at which PC is next due to be LISTed |
| ``46⇨81`` | input buffer; usually uses X as index/pointer |
| ``82/83`` | workspace... various uses |
| ``84`` | index/pointer for OBJ in­termediate buffer |
| ``85/86`` | used in OBJ output process­ing: absolute address of where data would be deposited if not stored in intermediate buffer |
| ``87`` | OBJ-OUTFLG, if defined |
| ``88`` | LIST-OUTFLG stored here when OBJ is being output |
| ``89⇨A6`` | record assembly space for OBJ output... includes: |
| ``-- 89`` | number of bytes in record |
| ``-- 8A/8B`` | starting address of data |
| ``-- 8C⇨A2`` | data |
| ``-- A3-A6`` | checksum |
| ``A7⇨AB`` | AID input FNAME stored here |
| ``0170-0183`` | intermediate storage buffer of compiled object code

Assume that PASS 2 has been displayed, and that the assembler is patiently waiting for you to press "space” to initiate the second pass. In­stead of "space", press "1" or "2", depending on which line is connected to your recorder. Voila, your recorder is now running. Rewind to the start of the file, toggle "1" (or "2") again if you wish, start the recorder, and then press "space" on the keyboard. It’s as easy as that.

3. Now to the undocumented op­tions. You may have noticed in table 2 that several assembler mnemonics were unfamiliar. Indeed, MEM and NOM are supported, and I'll discuss them in the next paragraph. But the options SYM, NOS, NOC, CNT, and COU, while recognized, are not supported. Their action addresses direct processing to null place in the program so their inclusion doesn't crash the assembly, but merely is ignored. I assume that these are fossils which remain from the command set of Compas Microsystem's larger A/65 assembler. With that assumption, some of their functions can be guessed at: SYM/NOS toggled the printing of a sorted symbol table NOC/CNT probably determined whether each line of the formatted assembly listing was sequentially numbered; and COU probably set the number of lines per page. Note that there is room in the directive flag variable for, at most, 5 more status toggles than are used by the AIM Assembler.

4. .OPT MEM / .OPT NOM does work, however. Its syntax is like that one other .OPT commands, and the option determines the status of bit 3 in the directive flag. (See table 5.) This option allows the user, for whatever reasons, to choose exactly when and where the object code will be directed during assembly. As with other options, use of an .OPT command overrides those parameters determined during the initialization dialog. But this mean that if .OPT NOM is to be used somewhere in the source text, the user must feply "Y" to "OBJ?" during the dialog, and then specify the OBJ-OUT device to insure that the OBJ-OUTFLG will be determined before it is needed. Thereafter, .OPT MEM and .OPT NOM will allow object code to be directed to this device as desired during assembly of the source program.

I have even found a few useful subroutines that can be called from outside the assembler. Some of these are described in detail in table 6. I especially like the subroutine which converts from multiple base systems to hex notation. Although it cannot be incorporated directly into a USR function and called from a BASIC program because of zero page RAM conflicts, the concept can be used by anyone to provide a simple basic conversion function in BASIC.

Finally, a word of warning to any reader who may want to relocate the assembler. Disassembling this program into a source file cannot be done blindly. Various changes must be made manually. These are summarized in table 7. If these suggestions are followed, any planned reassembly should proceed smoothly.

***Table 4: Opcode classifications from table $D9DF***

| Table<br />Entry | Class of<br />Opcodes |
| :--- | :--- |
| ``01`` | widest variety of operand type allowed (as for ADC, LDA, etc.)
| ``02`` | STA |
| ``03`` | JMP, direct or indirect |
| ``04`` | JSR |
| ``05`` | accumulator mode allowed (as in LSR) |
| ``06`` | CPX, CPY |
| ``07`` | BIT |
| ``08`` | LDY |
| ``09`` | STX |
| ``0A`` | STY |
| ``0B`` | LDX |
| ``0C`` | DEC |
| ``14`` |  single bytes (accumulator mode not allowed) (as in SEC or TAY) |
| ``15`` | all branches |

***Table 5: Directive Flag Variable ($37)***

| Bit<br />Number | Used For | .OPT if<br />Bit is SET | .OPT if<br />Bit is CLR |
| :--- | :--- | :--- | :--- |
| ``7`` | generate complete data for .BYT command? | ``NOG``<br />(no) | ``GEN``<br />(yes) |
| ``6`` | (not used) | | |
| ``5`` | (not used) | | |
| ``4`` | output a complete assembly listing or errors only? | ``ERR``<br />``NOL``<br />(errors only) | ``NOE``<br />``LIS``<br />(complete) |
| ``3`` | object code to memory | ``NOM``<br />(no) | ``MEM``<br />(yes) | 
| ``2`` | (not used) | | |
| ``1`` | (not used) | | |
| ``0`` | (not used) | | |

***Table 6: Useful Subroutines: I/O formats, RAM and register usage.***

| SBR<br />entry<br />address | Function | Input | Output | Flags<br />upon<br />exit | Registers <br />altered | RAM used,<br />including<br />that of<br />called SBR's |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| ``D797`` | EVALUATE an<br />expression | pointer to<br />beginning of<br />expr in 46,X | value in<br />27/28<br />(if done) | test $38<br />.and.<br />Y = 0, 1 or 2<br />0: not done<br />1: no symbol<br />found<br />2: OK | A X Y | 13/14<br />15 16<br />17/18<br />27/28<br />32/33<br />35 36 38<br />82/83 |
| ``D8ED`` | BASE conversion | pointer to<br />beginning of <br /> string in<br />46,X | hex value<br />in 13/14 | SEC if OK<br />CLC if not<br />possible<br /> .also.<br />test $38 | A X Y | 13/14<br />16 17/18<br />35 82/83<br />38 |
| ``D95E`` | SEARCH for<br />symbol table<br />entry | label in<br />$2A+ | value in<br />13/14,<br />if found | SEC if OK<br />CLC if not<br />found | A Y | 0B/OC<br />11/12 13/14<br />2A +<br />3A/3B<br />3C/3D

***Table 7: Disassembly Precautions***

<style> table, th, td { border: 1px solid black; } </style>
| Location (Hex) | Content | Status |
| :--- | :--- | :--- |
| ``D956-D95D``<br />``DD75-DFA7``<br />``DFF6-DFF9`` | position-independent data | no change necessary |
| ``D000-D955``<br />``D95E-DD4A``<br />``DFA8-DFF5``<br />``DFFA-DFFE`` | program segments | although relative branches<br />remain intact, all absolute<br />addresses in the range<br />$D000-DFFF must be changed |
| ``DD4B-DD74``<br />``D27C-D27F``<br />``D3AA-D3AD``<br />``D9D4-D9D7`` | action addresses for<br />directives (.WOR)<br />these are MSB/LSB bytes<br />of position-dependent<br />address used as input to<br />SBR $D9EA in registers<br />A and Y | all must be changed<br />change LDA#__<br />and LDY#__<br />operands to<br />reflect new addresses

---

Greg Paris has been doing postdoctoral research in neurobiology, and has turned his hobby into a job - as Senior Applications Specialist at Merck Pharmaceutical Co. He interfaces between the research scientists and the programming and design staff.

---

No. 38 - July 1981       MICRO - The 6502/6809 Journal
