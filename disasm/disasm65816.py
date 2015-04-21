#! /usr/bin/env python3
#
# Disassembler for 65816 microprocessor.
# Copyright (c) 2013-2015 by Jeff Tranter <tranter@pobox.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys
import fileinput
import argparse
import signal

# Avoids an error when output piped, e.g. to "less"
signal.signal(signal.SIGPIPE, signal.SIG_DFL)

# Addressing modes. Used as indices into opcode table.
implicit = 0                         # e.g. rts
absolute = 1                         # e.g. lda $1234
absoluteX = 2                        # e.g. lda $1234,x
absoluteY = 3                        # e.g. lda $1234,y
accumulator = 4                      # e.g. asl a
immediate = 5                        # e.g. lda #$12
indirectX = 6                        # e.g. lda ($12,x)
indirectY = 7                        # e.g. lda ($12),y
indirect = 8                         # e.g. jmp ($1234)
relative = 9                         # e.g. bne $1234
zeroPage = 10                        # e.g. lda #12
zeroPageX = 11                       # e.g. lda $12,x
zeroPageY = 12                       # e.g. lda $12,y
indirectZeroPage = 13                # e.g. lda ($12)
absoluteIndexedIndirect = 14         # e.g. jmp ($1234,x)
zeroPageRelative = 15                # e.g. bbs1 $12, $3456
stackRelative = 16                   # e.g. ora 1,s
absoluteLong = 17                    # e.g. jsl $123456
srIndirectIndexedY = 18              # e.g. ora ($12,s),y
blockMove = 19                       # e.g. mvp $12,$34
directPageIndirectLong = 20          # e.g. ora [$10]
directPageIndirectLongIndexedY = 21  # e.g. ora [$10],y
absoluteIndirectLong = 22            # e.g. jmp [$1234]
absoluteLongIndexedX = 23            # e.g. asl $123456,x

# Lookup table - given addressing mode, returns length of instruction in bytes.
lengthTable = [
    1,  # 0  - implicit
    3,  # 1  - absolute
    3,  # 2  - absolute X
    3,  # 3  - absolute Y
    1,  # 4  - accumulator
    2,  # 5  - immediate
    2,  # 6  - indirect X
    2,  # 7  - indirect Y
    3,  # 8  - indirect
    2,  # 9  - relative
    2,  # 10 - zero page
    2,  # 11 - zero page X
    2,  # 12 - zero page Y
    2,  # 13 - indirect zero page
    3,  # 14 - absolute indexed indirect
    3,  # 15 - zero page relative
    2,  # 16 - stack relative
    4,  # 17 - absolute long
    2,  # 18 - stack relative indirect indexed Y
    3,  # 19 - block move
    2,  # 20 - direct page indirect long
    2,  # 21 - direct page indirect long indexed y
    3,  # 22 - absolute indirect long
    4,  # 23 - absolute long indexed X
]

# Lookup table - given opcode byte as index, return mnemonic of instruction
# and addressing mode.
opcodeTable = [
    ["brk", implicit],                        # 00
    ["ora", indirectX],                       # 01
    ["cop", zeroPage],                        # 02
    ["ora", stackRelative],                   # 03
    ["tsb", zeroPage],                        # 04
    ["ora", zeroPage],                        # 05
    ["asl", zeroPage],                        # 06
    ["ora", directPageIndirectLong],          # 07
    ["php", implicit],                        # 08
    ["ora", immediate],                       # 09
    ["asl", accumulator],                     # 0A
    ["phd", implicit],                        # 0B
    ["tsb", absolute],                        # 0C
    ["ora", absolute],                        # 0D
    ["asl", absolute],                        # 0E
    ["ora", absoluteLong],                    # 0F

    ["bpl", relative],                        # 10
    ["ora", indirectY],                       # 11
    ["ora", indirectZeroPage],                # 12
    ["ora", srIndirectIndexedY],              # 13
    ["trb", zeroPage],                        # 14
    ["ora", zeroPageX],                       # 15
    ["asl", zeroPageX],                       # 16
    ["ora", directPageIndirectLongIndexedY],  # 17
    ["clc", implicit],                        # 18
    ["ora", absoluteY],                       # 19
    ["inc", accumulator],                     # 1A
    ["tcs", implicit],                        # 1B
    ["trb", absolute],                        # 1C
    ["ora", absoluteX],                       # 1D
    ["asl", absoluteX],                       # 1E
    ["ora", absoluteLongIndexedX],            # 1F

    ["jsr", absolute],                        # 20
    ["and", indirectX],                       # 21
    ["jsl", absoluteLong],                    # 22
    ["and", stackRelative],                   # 23
    ["bit", zeroPage],                        # 24
    ["and", zeroPage],                        # 25
    ["rol", zeroPage],                        # 26
    ["and", directPageIndirectLong],          # 27
    ["plp", implicit],                        # 28
    ["and", immediate],                       # 29
    ["rol", accumulator],                     # 2A
    ["pld", implicit],                        # 2B
    ["bit", absolute],                        # 2C
    ["and", absolute],                        # 2D
    ["rol", absolute],                        # 2E
    ["and", absoluteLong],                    # 2F

    ["bmi", relative],                        # 30
    ["and", indirectY],                       # 31
    ["and", indirectZeroPage],                # 32
    ["and", srIndirectIndexedY],              # 33
    ["bit", zeroPageX],                       # 34
    ["and", zeroPageX],                       # 35
    ["rol", zeroPageX],                       # 36
    ["and", directPageIndirectLongIndexedY],  # 37
    ["sec", implicit],                        # 38
    ["and", absoluteY],                       # 39
    ["dec", accumulator],                     # 3A
    ["tsc", implicit],                        # 3B
    ["bit", absoluteX],                       # 3C
    ["and", absoluteX],                       # 3D
    ["rol", absoluteX],                       # 3E
    ["and", absoluteLongIndexedX],            # 3F

    ["rti", implicit],                        # 40
    ["eor", indirectX],                       # 41
    ["wdm", zeroPage],                        # 42
    ["eor", stackRelative],                   # 43
    ["mvp", blockMove],                       # 44
    ["eor", zeroPage],                        # 45
    ["lsr", zeroPage],                        # 46
    ["eor", directPageIndirectLong],          # 47
    ["pha", implicit],                        # 48
    ["eor", immediate],                       # 49
    ["lsr", accumulator],                     # 4A
    ["phk", implicit],                        # 4B
    ["jmp", absolute],                        # 4C
    ["eor", absolute],                        # 4D
    ["lsr", absolute],                        # 4E
    ["eor", absoluteLong],                    # 4F

    ["bvc", relative],                        # 50
    ["eor", indirectY],                       # 51
    ["eor", indirectZeroPage],                # 52
    ["eor", srIndirectIndexedY],              # 53
    ["mvn", blockMove],                       # 54
    ["eor", zeroPageX],                       # 55
    ["lsr", zeroPageX],                       # 56
    ["eor", directPageIndirectLongIndexedY],  # 57
    ["cli", implicit],                        # 58
    ["eor", absoluteY],                       # 59
    ["phy", implicit],                        # 5A
    ["tcd", implicit],                        # 5B
    ["jmp", absoluteLong],                    # 5C
    ["eor", absoluteX],                       # 5D
    ["lsr", absoluteX],                       # 5E
    ["eor", absoluteLongIndexedX],            # 5F

    ["rts", implicit],                        # 60
    ["adc", indirectX],                       # 61
    ["per", absolute],                        # 62
    ["adc", stackRelative],                   # 63
    ["stz", zeroPage],                        # 64
    ["adc", zeroPage],                        # 65
    ["ror", zeroPage],                        # 66
    ["adc", directPageIndirectLong],          # 67
    ["pla", implicit],                        # 68
    ["adc", immediate],                       # 69
    ["ror", accumulator],                     # 6A
    ["rtl", implicit],                        # 6B
    ["jmp", indirect],                        # 6C
    ["adc", absolute],                        # 6D
    ["ror", absolute],                        # 6E
    ["adc", absoluteLong],                    # 6F

    ["bvs", relative],                        # 70
    ["adc", indirectY],                       # 71
    ["adc", indirectZeroPage],                # 72
    ["adc", srIndirectIndexedY],              # 73
    ["stz", zeroPageX],                       # 74
    ["adc", zeroPageX],                       # 75
    ["ror", zeroPageX],                       # 76
    ["adc", directPageIndirectLongIndexedY],  # 77
    ["sei", implicit],                        # 78
    ["adc", absoluteY],                       # 79
    ["ply", implicit],                        # 7A
    ["tdc", implicit],                        # 7B
    ["jmp", absoluteIndexedIndirect],         # 7C
    ["adc", absoluteX],                       # 7D
    ["ror", absoluteX],                       # 7E
    ["adc", absoluteLongIndexedX],            # 7F

    ["bra", relative],                        # 80
    ["sta", indirectX],                       # 81
    ["brl", absolute],                        # 82
    ["sta", stackRelative],                   # 83
    ["sty", zeroPage],                        # 84
    ["sta", zeroPage],                        # 85
    ["stx", zeroPage],                        # 86
    ["sta", directPageIndirectLong],          # 87
    ["dey", implicit],                        # 88
    ["bit", immediate],                       # 89
    ["txa", implicit],                        # 8A
    ["phb", implicit],                        # 8B
    ["sty", absolute],                        # 8C
    ["sta", absolute],                        # 8D
    ["stx", absolute],                        # 8E
    ["sta", absoluteLong],                    # 8F

    ["bcc", relative],                        # 90
    ["sta", indirectY],                       # 91
    ["sta", indirectZeroPage],                # 92
    ["sta", srIndirectIndexedY],              # 93
    ["sty", zeroPageX],                       # 94
    ["sta", zeroPageX],                       # 95
    ["stx", zeroPageY],                       # 96
    ["sta", directPageIndirectLongIndexedY],  # 97
    ["tya", implicit],                        # 98
    ["sta", absoluteY],                       # 99
    ["txs", implicit],                        # 9A
    ["txy", implicit],                        # 9B
    ["stz", absolute],                        # 9C
    ["sta", absoluteX],                       # 9D
    ["stz", absoluteX],                       # 9E
    ["sta", absoluteLongIndexedX],            # 9F

    ["ldy", immediate],                       # A0
    ["lda", indirectX],                       # A1
    ["ldx", immediate],                       # A2
    ["lda", stackRelative],                   # A3
    ["ldy", zeroPage],                        # A4
    ["lda", zeroPage],                        # A5
    ["ldx", zeroPage],                        # A6
    ["lda", directPageIndirectLong],          # A7
    ["tay", implicit],                        # A8
    ["lda", immediate],                       # A9
    ["tax", implicit],                        # AA
    ["plb", implicit],                        # AB
    ["ldy", absolute],                        # AC
    ["lda", absolute],                        # AD
    ["ldx", absolute],                        # AE
    ["lda", absoluteLong],                    # AF

    ["bcs", relative],                        # B0
    ["lda", indirectY],                       # B1
    ["lda", indirectZeroPage],                # B2
    ["lda", srIndirectIndexedY],              # B3
    ["ldy", zeroPageX],                       # B4
    ["lda", zeroPageX],                       # B5
    ["ldx", zeroPageY],                       # B6
    ["lda", directPageIndirectLongIndexedY],  # B7
    ["clv", implicit],                        # B8
    ["lda", absoluteY],                       # B9
    ["tsx", implicit],                        # BA
    ["tyx", implicit],                        # BB
    ["ldy", absoluteX],                       # BC
    ["lda", absoluteX],                       # BD
    ["ldx", absoluteY],                       # BE
    ["lda", absoluteLongIndexedX],            # BF

    ["cpy", immediate],                       # C0
    ["cmp", indirectX],                       # C1
    ["rep", immediate],                       # C2
    ["cmp", stackRelative],                   # C3
    ["cpy", zeroPage],                        # C4
    ["cmp", zeroPage],                        # C5
    ["dec", zeroPage],                        # C6
    ["cmp", directPageIndirectLong],          # C7
    ["iny", implicit],                        # C8
    ["cmp", immediate],                       # C9
    ["dex", implicit],                        # CA
    ["wai", implicit],                        # CB
    ["cpy", absolute],                        # CC
    ["cmp", absolute],                        # CD
    ["dec", absolute],                        # CE
    ["cmp", absoluteLong],                    # CF

    ["bne", relative],                        # D0
    ["cmp", indirectY],                       # D1
    ["cmp", indirectZeroPage],                # D2
    ["cmp", srIndirectIndexedY],              # D3
    ["pei", indirectZeroPage],                # D4
    ["cmp", zeroPageX],                       # D5
    ["dec", zeroPageX],                       # D6
    ["cmp", directPageIndirectLongIndexedY],  # D7
    ["cld", implicit],                        # D8
    ["cmp", absoluteY],                       # D9
    ["phx", implicit],                        # DA
    ["stp", implicit],                        # DB
    ["jmp", absoluteIndirectLong],            # DC
    ["cmp", absoluteX],                       # DD
    ["dec", absoluteX],                       # DE
    ["cmp", absoluteLongIndexedX],            # DF

    ["cpx", immediate],                       # E0
    ["sbc", indirectX],                       # E1
    ["sep", immediate],                       # E2
    ["sbc", stackRelative],                   # E3
    ["cpx", zeroPage],                        # E4
    ["sbc", zeroPage],                        # E5
    ["inc", zeroPage],                        # E6
    ["sbc", directPageIndirectLong],          # E7
    ["inx", implicit],                        # E8
    ["sbc", immediate],                       # E9
    ["nop", implicit],                        # EA
    ["xba", implicit],                        # EB
    ["cpx", absolute],                        # EC
    ["sbc", absolute],                        # ED
    ["inc", absolute],                        # EE
    ["sbc", absoluteLong],                    # EF

    ["beq", relative],                        # F0
    ["sbc", indirectY],                       # F1
    ["sbc", indirectZeroPage],                # F2
    ["sbc", srIndirectIndexedY],              # F3
    ["pea", absolute],                        # F4
    ["sbc", zeroPageX],                       # F5
    ["inc", zeroPageX],                       # F6
    ["sbc", directPageIndirectLongIndexedY],  # F7
    ["sed", implicit],                        # F8
    ["sbc", absoluteY],                       # F9
    ["plx", implicit],                        # FA
    ["xce", implicit],                        # FB
    ["jsr", absoluteIndexedIndirect],         # FC
    ["sbc", absoluteX],                       # FD
    ["inc", absoluteX],                       # FE
    ["sbc", absoluteLongIndexedX],            # FF
]

# Indicates if uppercase option is in effect.
upperOption = False

# Handle 16-bit modes of 65816
# When M=0 (16-bit accumulator) the following instructions take an extra byte:
variableAccInstructions = set(
    [0x09, 0x29, 0x49, 0x69, 0x89, 0xA9, 0xC9, 0xE9])

# When X=0 (16-bit index) the following instructions take an extra byte:
variableIndexInstructions = set([0xA0, 0xA2, 0xC0, 0xE0])

# Tracks the state of the M bit.
mbit = 1

# Tracks the state of the X bit.
xbit = 1

# Functions


def isprint(c):
    "Return if character is printable ASCII"
    if c >= '@' and c <= '~':
        return True
    else:
        return False


def case(s):
    "Return string or uppercase version of string if option is set."
    global upperOption
    if upperOption:
        return s.upper()
    else:
        return s


def formatByte(data):
    "Format an 8-bit byte using the current display format (e.g. hex or octal)"
    global args
    if args.format == 4:  # Octal
        return "%03o" % data
    else:  # Hex
        return "%02X" % data


def formatAddress(data):
    "Format 16-bit address using current display format (e.g. hex or octal)"
    global args
    if args.format == 4:  # Octal
        return "%06o" % data
    else:  # Hex
        return "%04X" % data

# Parse command line options
parser = argparse.ArgumentParser()
parser.add_argument("filename", help="Binary file to disassemble")
parser.add_argument("-n", "--nolist",
                    help="Don't list  instruction bytes (make output suitable for assembler)",
                    action="store_true")
parser.add_argument("-u", "--uppercase",
                    help="Use uppercase for mnemonics", action="store_true")
parser.add_argument("-a", "--address",
                    help="Specify decimal starting address (defaults to 0)",
                    default=0, type=int)
parser.add_argument("-f", "--format",
                    help="Use number format: 1=$1234 2=1234h 3=1234 4=177777 (default 1)",
                    default=1, type=int, choices=range(1, 5))
parser.add_argument("-i", "--invalid",
                    help="Show invalid opcodes as ??? rather than constants",
                    action="store_true")
args = parser.parse_args()

# Get filename from command line arguments.
filename = args.filename

# Current instruction address. Silently force it to be in valid range.
address = args.address & 0xffff

# Set uppercase output option.
upperOption = args.uppercase

# Contains a line of output
line = ""

# Contains optional comment
comment = ""

# Open input file.
# Display error and exit if filename does not exist.
try:
    f = open(filename, "rb")
except FileNotFoundError:
    print("error: input file '%s' not found." % filename, file=sys.stderr)
    sys.exit(1)

# Print initial origin address
if args.nolist is False:
    if args.format == 1:
        print("%04X               %s   $%04X"
              % (address, case(".org"), address))
    elif args.format == 2:
        print("%04X               %s   %04X%s"
              % (address, case(".org"), address, case("h")))
    elif args.format == 3:
        print("%04X               %s   %04X"
              % (address, case(".org"), address))
    else:
        print("%06o                  %s   %06o"
              % (address, case(".org"), address))
else:
    if args.format == 1:
        print(" %s   $%04X" % (case(".org"), address))
    elif args.format == 2:
        print(" %s   %04X%s" % (case(".org"), address, case("h")))
    elif args.format == 3:
        print(" %s   %04X" % (case(".org"), address))
    else:
        print(" %s   %06o" % (case(".org"), address))

while True:
    try:
        b = f.read(1)  # Get binary byte from file

        if len(b) == 0:  # EOF
            if args.nolist is False:
                if args.format == 4:
                    print("%06o               %s"
                          % (address, case("end")))  # Exit if eof reached.
                else:
                    print("%04X            %s"
                          % (address, case("end")))  # Exit if eof reached.
            break

        if args.nolist is False:
            line = "%s  " % formatAddress(address)  # Print current address

        op = ord(b)  # Get opcode byte

        mnem = case(opcodeTable[op][0])  # Get mnemonic

        mode = opcodeTable[op][1]  # Get addressing mode

        n = lengthTable[mode]  # Look up number of instruction bytes

        # Check for 16-bit instruction in 16-bit mode.
        if ((mbit == 0) and (op in variableAccInstructions)) or ((xbit == 0) and (op in variableIndexInstructions)):
            n = n + 1

        # Print instruction bytes
        if n == 1:
            if args.nolist is False:
                if args.format == 4:
                    line += "%03o             " % op
                else:
                    line += "%02X           " % op
        elif n == 2:
            try:  # Possible to get exception here if EOF reached.
                op1 = ord(f.read(1))
            except TypeError:
                op1 = 0  # Fake it to recover from EOF
            if args.nolist is False:
                if args.format == 4:
                    line += "%03o %03o         " % (op, op1)
                else:
                    line += "%02X %02X        " % (op, op1)
        elif n == 3:
            try:  # Possible to get exception here if EOF reached.
                op1 = ord(f.read(1))
                op2 = ord(f.read(1))
            except TypeError:
                op1 = 0  # Fake it to recover from EOF
                op2 = 0
            if args.nolist is False:
                line += "%s %s %s     " % (formatByte(op), formatByte(op1), formatByte(op2))
        elif n == 4:
            try:  # Possible to get exception here if EOF reached.
                op1 = ord(f.read(1))
                op2 = ord(f.read(1))
                op3 = ord(f.read(1))
            except TypeError:
                op1 = 0  # Fake it to recover from EOF
                op2 = 0
                op3 = 0
            if args.nolist is False:
                line += "%s %s %s %s  " % (formatByte(op), formatByte(op1), formatByte(op2), formatByte(op3))
        if args.nolist is True:
            line += " "

        # Special check for invalid op code (none for 65816).
        if (mnem == "???" and not args.invalid):
            if isprint(chr(op)):
                line += "%s  '%c'" % (case(".byte"), op)
            else:
                if args.format == 1:
                    line += "%s  $%s" % (case(".byte"), formatByte(op))
                elif args.format == 2:
                    line += "%s  %s%s" % (case(".byte"), formatByte(op), case("h"))
                else:
                    line += "%s  %s" % (case(".byte"), formatByte(op))
        else:
            line += mnem

        if mode == implicit:
            pass

        elif mode == absolute:
            # Handle special case of brl which is a long relative branch
            if mnem == "brl":
                dest = (address + op1 + 256 * op2 + 3) & 0xffff
                if args.format == 1:
                    line += "    $%s" % formatAddress(dest)
                elif args.format == 2:
                    line += "    %s%s" % (formatAddress(dest), case("h"))
                else:
                    line += "    %s" % formatAddress(dest)
            else:
                if args.format == 1:
                    line += "    $%s%s" % (formatByte(op2), formatByte(op1))
                elif args.format == 2:
                    line += "    %s%s%s" % (formatByte(op2), formatByte(op1), case("h"))
                else:
                    line += "    %s" % formatByte(op2)

        elif mode == absoluteX:
            if args.format == 1:
                line += "    $%s%s,%s" % (formatByte(op2), formatByte(op1), case("x"))
            elif args.format == 2:
                line += "    %s%s,%s" % (formatByte(op2), formatByte(op1), case("x"))
            else:
                line += "    %s%s,%s" % (formatByte(op2), formatByte(op1), case("x"))

        elif mode == absoluteY:
            if args.format == 1:
                line += "    $%s%s,%s" % (formatByte(op2), formatByte(op1), case("y"))
            elif args.format == 2:
                line += "    %s%s,%s" % (formatByte(op2), formatByte(op1), case("y"))
            else:
                line += "    %s%s,%s" % (formatByte(op2), formatByte(op1), case("y"))

        elif mode == accumulator:
                line += "    %s" % (("a"))

        elif mode == immediate:

            # Special check for REP and SEP instructions. These set or clear
            # the M and X bits which change the length of some instructions.

            if mnem == "rep":
                mbit = (~op1 & 0x20) >> 5
                xbit = (~op1 & 0x10) >> 4
                comment = "      ; Note: m=%d, x=%d" % (mbit, xbit)

            if mnem == "sep":
                mbit = (op1 & 0x20) >> 5
                xbit = (op1 & 0x10) >> 4
                comment = "      ; Note: m=%d, x=%d" % (mbit, xbit)

            # Handle 16-bit mode of 65816

            if ((mbit == 0) and (op in variableAccInstructions)) or ((xbit == 0) and (op in variableIndexInstructions)):
                comment = "    ; Note: 16-bit instruction"
                if args.format == 1:
                    line += "    #$%s%s" % (formatByte(op2), formatByte(op1))
                elif args.format == 2:
                    line += "    #%s%s%s" % (formatByte(op2), formatByte(op1), case("h"))
                else:
                    line += "    #%s%s" % (formatByte(op2), formatByte(op1))
            else:
                if isprint(chr(op1)):
                    line += "    #'%c'" % op1
                else:
                    if args.format == 1:
                        line += "    #$%s" % formatByte(op1)
                    elif args.format == 2:
                        line += "    #%s%s" % (formatByte(op1), case("h"))
                    else:
                        line += "    #%s" % formatByte(op1)

        elif mode == indirectX:
            if args.format == 1:
                line += "    ($%s,%s)" % (formatByte(op1), case("x"))
            elif args.format == 2:
                line += "    (%s%s,%s)" % (formatByte(op1), case("h"), case("x"))
            else:
                line += "    (%s,%s)" % (formatByte(op1), case("x"))

        elif mode == indirectY:
            if args.format == 1:
                line += "    ($%s),%s" % (formatByte(op1), case("y"))
            elif args.format == 2:
                line += "    (%s%s),%s" % (formatByte(op1), case("h"), case("y"))
            else:
                line += "    (%s),%s" % (formatByte(op1), case("y"))

        elif mode == indirect:
            if args.format == 1:
                line += "    ($%s%s)" % (formatByte(op2), formatByte(op1))
            elif args.format == 2:
                line += "    (%s%s%s)" % (formatByte(op2), formatByte(op1), case("h"))
            else:
                line += "    (%s%s)" % (formatByte(op2), formatByte(op1))

        elif mode == relative:
            if op1 < 128:
                dest = address + op1 + 2
            else:
                dest = address - (256 - op1) + 2
            if dest < 0:
                dest = 65536 + dest
            if args.format == 1:
                line += "    $%s" % formatAddress(dest)
            elif args.format == 2:
                line += "    %s%s" % (formatAddress(dest), case("h"))
            else:
                line += "    %s" % formatAddress(dest)

        elif mode == zeroPage:
            # Check for 3 or 4 character mnemonics
            if len(mnem) == 4:
                line += "   "
            else:
                line += "    "
            if args.format == 1:
                line += "$%s" % formatByte(op1)
            elif args.format == 2:
                line += "%s%s" % (formatByte(op1), case("h"))
            else:
                line += "%s" % formatByte(op1)

        elif mode == zeroPageX:
            if args.format == 1:
                line += "    $%s,%s" % (formatByte(op1), case("x"))
            elif args.format == 2:
                line += "    %s%s,%s" % (formatByte(op1), case("h"), case("x"))
            else:
                line += "    %s,%s" % (formatByte(op1), case("x"))

        elif mode == zeroPageY:
            if args.format == 1:
                line += "    $%s,%s" % (formatByte(op1), case("y"))
            elif args.format == 2:
                line += "    %s%s,%s" % (formatByte(op1), case("h"), case("y"))
            else:
                line += "    %s,%s" % (formatByte(op1), case("y"))

        elif mode == indirectZeroPage:
            if args.format == 1:
                line += "    ($%s)" % formatByte(op1)
            elif args.format == 2:
                line += "    (%s%s)" % (formatByte(op1), case("h"))
            else:
                line += "    (%s)" % formatByte(op1)

        elif mode == absoluteIndexedIndirect:
            if args.format == 1:
                line += "    ($%s%s,%s)" % (formatByte(op2), formatByte(op1), case("x"))
            elif args.format == 2:
                line += "    (%s%s,%s%s)" % (formatByte(op2), formatByte(op1), case("x"), case("h"))
            else:
                line += "    (%s%s,%s)" % (formatByte(op2), formatByte(op1), case("x"))

        elif mode == zeroPageRelative:
            if op2 < 128:
                dest = address + op2 + 3
            else:
                dest = address - (256 - op2) + 3
            if dest < 0:
                dest = 65536 + dest
            if args.format == 1:
                line += "   $%s,$%s" % (formatByte(op1), formatAddress(dest))
            elif args.format == 2:
                line += "    %s%s,%s%s" % (formatByte(op1), case("h"), formatAddress(dest), case("h"))
            else:
                line += "    %s,%s" % (formatByte(op1), formatAddress(dest))

        elif mode == stackRelative:
            if args.format == 1:
                line += "    $%s,%s" % (formatByte(op1), case("s"))
            elif args.format == 2:
                line += "    %s%s,%s" % (formatByte(op1), case("h"), case("s"))
            else:
                line += "    %s,%s" % (formatByte(op1), case("s"))

        elif mode == absoluteLong:
            if args.format == 1:
                line += "    $%s%s%s" % (formatByte(op3), formatByte(op2), formatByte(op1))
            elif args.format == 2:
                line += "    %s%s%s%s" % (formatByte(op3), formatByte(op2), formatByte(op1), case("h"))
            else:
                line += "    %s%s%s" % (formatByte(op3), formatByte(op2), formatByte(op1))

        elif mode == srIndirectIndexedY:
            if args.format == 1:
                line += "    ($%s,%s),%s" % (formatByte(op1), case("s"), case("y"))
            elif args.format == 2:
                line += "    (%s%s,%s),%s" % (formatByte(op1), case("h"), case("s"), case("y"))
            else:
                line += "    (%s,%s),%s" % (formatByte(op1), case("s"), case("y"))

        elif mode == blockMove:
            if args.format == 1:
                line += "    $%s,$%s" % (formatByte(op2), formatByte(op1))
            elif args.format == 2:
                line += "    %s%s,%s%s" % (formatByte(op2), case("h"), formatByte(op1), case("h"))
            else:
                line += "    %s,%s" % (formatByte(op2), formatByte(op1))

        elif mode == directPageIndirectLong:
            if args.format == 1:
                line += "    [$%s]" % formatByte(op1)
            elif args.format == 2:
                line += "    [%s%s]" % (formatByte(op1), case("h"))
            else:
                line += "    [%s]" % formatByte(op1)

        elif mode == directPageIndirectLongIndexedY:
            if args.format == 1:
                line += "    [$%s],%s" % (formatByte(op1), case("y"))
            elif args.format == 2:
                line += "    [%s%s],%s" % (formatByte(op1), case("h"), case("y"))
            else:
                line += "    [%s],%s" % (formatByte(op1), case("y"))

        elif mode == absoluteIndirectLong:
            if args.format == 1:
                line += "    [$%s%s]" % (formatByte(op2), formatByte(op1))
            elif args.format == 2:
                line += "    ]%s%s%s]" % (formatByte(op2), formatByte(op1), case("h"))
            else:
                line += "    [%s%s]" % (formatByte(op2), formatByte(op1))

        elif mode == absoluteLongIndexedX:
            if args.format == 1:
                line += "    $%s%s%s,%s" % (formatByte(op3), formatByte(op2), formatByte(op1), case("x"))
            elif args.format == 2:
                line += "    %s%s%s%s,%s" % (formatByte(op3), formatByte(op2), formatByte(op2), case("h"), case("x"))
            else:
                line += "    %s%s%s,%s" % (formatByte(op3), formatByte(op2), formatByte(op1), case("x"))

        else:
            print("Internal error: unknown addressing mode:",
                  mode, file=sys.stderr)
            sys.exit(1)

        # Update address
        address += n

        # Check for address exceeding 0xFFFF, if so wrap around.
        if address > 0xffff:
            address = address & 0xffff

        # Check for comment
        if (comment != ""):
            line += comment

        # Finished a line of disassembly
        print(line)
        line = ""
        comment = ""

    except KeyboardInterrupt:
        # Exit if eof reached.
        print("Interrupted by Control-C", file=sys.stderr)
        if args.format == 4:
            print("%s               %s"
                  % (formatAddress(address), case("end")))
        else:
            print("%s            %s"
                  % (formatAddress(address), case("end")))
        break
