#! /usr/bin/env python3
#
# Disassembler for 6800 microprocessor.
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
implied = 0    # e.g. inca
immediate = 1  # e.g. ldaa #$12
direct = 2     # e.g. ldaa $12
indexed = 3    # e.g. ldaa $12,x
extended = 4   # e.g. ldaa $1234
relative = 5   # e.g. bra $1234


# Lookup table - given addressing mode, returns length of instruction in bytes.
lengthTable = [
    1,  # 0 - implied
    2,  # 1 - immediate
    2,  # 2 - direct
    2,  # 3 - indexed
    3,  # 4 - extended
    2,  # 5 - relative
]

# Lookup table - given opcode byte as index, return mnemonic of instruction and addressing mode.
# Invalid opcodes are listed as "???".
opcodeTable = [
    ["???", implied],      # 00
    ["nop", implied],      # 01
    ["???", implied],      # 02
    ["???", implied],      # 03
    ["???", implied],      # 04
    ["???", implied],      # 05
    ["tap", implied],      # 06
    ["tpa", implied],      # 07
    ["inx", implied],      # 08
    ["dex", implied],      # 09
    ["clv", implied],      # 0A
    ["sev", implied],      # 0B
    ["clc", implied],      # 0C
    ["sec", implied],      # 0D
    ["cli", implied],      # 0E
    ["sei", implied],      # 0F

    ["sba", implied],      # 10
    ["cba", implied],      # 11
    ["???", implied],      # 12
    ["???", implied],      # 13
    ["nba", implied],      # 14
    ["???", implied],      # 15
    ["tab", implied],      # 16
    ["tba", implied],      # 17
    ["???", implied],      # 18
    ["daa", implied],      # 19
    ["???", implied],      # 1A
    ["aba", implied],      # 1B
    ["???", implied],      # 1C
    ["???", implied],      # 1D
    ["???", implied],      # 1E
    ["???", implied],      # 1F

    ["bra", relative],     # 20
    ["???", implied],      # 21
    ["bhi", relative],     # 22
    ["bls", relative],     # 23
    ["bcc", relative],     # 24
    ["bcs", relative],     # 25
    ["bne", relative],     # 26
    ["beq", relative],     # 27
    ["bvc", relative],     # 28
    ["bvs", relative],     # 29
    ["bpl", relative],     # 2A
    ["bmi", relative],     # 2B
    ["bge", relative],     # 2C
    ["blt", relative],     # 2D
    ["bgt", relative],     # 2E
    ["ble", relative],     # 2F

    ["tsx", implied],      # 30
    ["ins", implied],      # 31
    ["pula", implied],     # 32
    ["pulb", implied],     # 33
    ["des", implied],      # 34
    ["txs", implied],      # 35
    ["psha", implied],     # 36
    ["pshb", implied],     # 37
    ["???", implied],      # 38
    ["rts", implied],      # 39
    ["???", implied],      # 3A
    ["rti", implied],      # 3B
    ["???", implied],      # 3C
    ["???", implied],      # 3D
    ["wai", implied],      # 3E
    ["swi", implied],      # 3F

    ["nega", implied],     # 40
    ["???", implied],      # 41
    ["???", implied],      # 42
    ["com", implied],      # 43
    ["lsra", implied],     # 44
    ["???", implied],      # 45
    ["rora", implied],     # 46
    ["asra", implied],     # 47
    ["asla", implied],     # 48
    ["rola", implied],     # 49
    ["deca", implied],     # 4A
    ["???", implied],      # 4B
    ["inca", implied],     # 4C
    ["tsta", implied],     # 4D
    ["???", implied],      # 4E
    ["clra", implied],     # 4F

    ["neg", implied],      # 50
    ["???", implied],      # 51
    ["???", implied],      # 52
    ["comb", implied],     # 53
    ["lsrb", implied],     # 54
    ["???", implied],      # 55
    ["rorb", implied],     # 56
    ["asrb", implied],     # 57
    ["aslb", implied],     # 58
    ["rolb", implied],     # 59
    ["decb", implied],     # 5A
    ["???", implied],      # 5B
    ["incb", implied],     # 5C
    ["tstb", implied],     # 5D
    ["???", implied],      # 5E
    ["clrb", implied],     # 5F

    ["neg", indexed],      # 60
    ["???", implied],      # 61
    ["???", implied],      # 62
    ["com", indexed],      # 63
    ["lsr", indexed],      # 64
    ["???", implied],      # 65
    ["ror", indexed],      # 66
    ["asr", indexed],      # 67
    ["asl", indexed],      # 68
    ["rol", indexed],      # 69
    ["dec", indexed],      # 6A
    ["???", implied],      # 6B
    ["inc", indexed],      # 6C
    ["tst", indexed],      # 6D
    ["jmp", indexed],      # 6E
    ["clr", indexed],      # 6F

    ["neg", extended],     # 70
    ["???", implied],      # 71
    ["???", implied],      # 72
    ["com", extended],     # 73
    ["lsr", extended],     # 74
    ["???", implied],      # 75
    ["ror", extended],     # 76
    ["asr", extended],     # 77
    ["asl", extended],     # 78
    ["rol", extended],     # 79
    ["dec", extended],     # 7A
    ["???", implied],      # 7B
    ["inc", extended],     # 7C
    ["tst", extended],     # 7D
    ["jmp", extended],     # 7E
    ["clr", extended],     # 7F

    ["sub", immediate],    # 80
    ["cmp", immediate],    # 81
    ["sbc", immediate],    # 82
    ["???", implied],      # 83
    ["and", immediate],    # 84
    ["bit", immediate],    # 85
    ["lda", immediate],    # 86
    ["???", implied],      # 87 STA #
    ["eor", immediate],    # 88
    ["adc", immediate],    # 89
    ["ora", immediate],    # 8A
    ["add", immediate],    # 8B
    ["cpx", immediate],    # 8C
    ["bsr", immediate],    # 8D
    ["lds", immediate],    # 8E
    ["???", implied],      # 8F STS #

    ["sub", direct],       # 90
    ["cmp", direct],       # 91
    ["sbc", direct],       # 92
    ["???", implied],      # 93
    ["and", direct],       # 94
    ["bit", direct],       # 95
    ["lda", direct],       # 96
    ["sta", direct],       # 97
    ["eor", direct],       # 98
    ["adc", direct],       # 99
    ["ora", direct],       # 9A
    ["add", direct],       # 9B
    ["cpx", direct],       # 9C
    ["???", implied],      # 9D HCF
    ["lds", direct],       # 9E
    ["sts", direct],       # 9F

    ["sub", indexed],      # A0
    ["cmp", indexed],      # A1
    ["sbc", indexed],      # A2
    ["???", implied],      # A3
    ["and", indexed],      # A4
    ["bit", indexed],      # A5
    ["ldaa", indexed],     # A6
    ["staa", indexed],     # A7
    ["eora", indexed],     # A8
    ["adca", indexed],     # A9
    ["oraa", indexed],     # AA
    ["adda", indexed],     # AB
    ["cpx", indexed],      # AC
    ["jsr", indexed],      # AD
    ["lds", indexed],      # AE
    ["sts", indexed],      # AF

    ["suba", extended],    # B0
    ["cmpa", extended],    # B1
    ["sbca", extended],    # B2
    ["???", implied],      # B3
    ["anda", extended],    # B4
    ["bita", extended],    # B5
    ["ldaa", extended],    # B6
    ["staa", extended],    # B7
    ["eora", extended],    # B8
    ["adca", extended],    # B9
    ["oraa", extended],    # BA
    ["adda", extended],    # BB
    ["cpx", extended],     # BC
    ["jsr", extended],     # BD
    ["lds", extended],     # BE
    ["sts", extended],     # BF

    ["subb", immediate],   # C0
    ["cmpb", immediate],   # C1
    ["sbcb", immediate],   # C2
    ["???", implied],      # C3
    ["andb", immediate],   # C4
    ["bitb", immediate],   # C5
    ["ldab", immediate],   # C6
    ["???", implied],      # C7 STA #
    ["eorb", immediate],   # C8
    ["adcb", immediate],   # C9
    ["orab", immediate],   # CA
    ["addb", immediate],   # CB
    ["???", implied],      # CC
    ["???", implied],      # CD
    ["ldx", immediate],    # CE
    ["???", implied],      # CF STX #

    ["subb", direct],      # D0
    ["cmpb", direct],      # D1
    ["sbcb", direct],      # D2
    ["???", implied],      # D3
    ["andb", direct],      # D4
    ["bitb", direct],      # D5
    ["ldab", direct],      # D6
    ["stab", direct],      # D7
    ["eorb", direct],      # D8
    ["adcb", direct],      # D9
    ["orab", direct],      # DA
    ["addb", direct],      # DB
    ["???", implied],      # DC
    ["???", implied],      # DD HCF
    ["ldx", direct],       # DE
    ["stx", direct],       # DF

    ["subb", indexed],     # E0
    ["cmpb", indexed],     # E1
    ["sbcb", indexed],     # E2
    ["???", implied],      # E3
    ["andb", indexed],     # E4
    ["bitb", indexed],     # E5
    ["ldab", indexed],     # E6
    ["stab", indexed],     # E7
    ["eorb", indexed],     # E8
    ["adcb", indexed],     # E9
    ["orab", indexed],     # EA
    ["addb", indexed],     # EB
    ["???", implied],      # EC
    ["???", implied],      # ED
    ["ldx", indexed],      # EE
    ["stx", indexed],      # EF

    ["subb", extended],    # F0
    ["cmpb", extended],    # F1
    ["sbcb", extended],    # F2
    ["???", implied],      # F3
    ["andb", extended],    # F4
    ["bitb", extended],    # F5
    ["ldab", extended],    # F6
    ["stab", extended],    # F7
    ["eorb", extended],    # F8
    ["adcb", extended],    # F9
    ["orab", extended],    # FA
    ["addb", extended],    # FB
    ["???", implied],      # FC
    ["???", implied],      # FD
    ["ldx", extended],     # FE
    ["stx", extended],     # FF
]

# Indicates if uppercase option is in effect.
upperOption = False

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
    "Format a 16-bit address using the current display format (e.g. hex or octal)"
    global args
    if args.format == 4:  # Octal
        return "%06o" % data
    else:  # Hex
        return "%04X" % data

# Parse command line options
parser = argparse.ArgumentParser()
parser.add_argument("filename", help="Binary file to disassemble")
parser.add_argument("-n", "--nolist", help="Don't list  instruction bytes (make output suitable for assembler)", action="store_true")
parser.add_argument("-u", "--uppercase", help="Use uppercase for mnemonics", action="store_true")
parser.add_argument("-a", "--address", help="Specify decimal starting address (defaults to 0)", default=0, type=int)
parser.add_argument("-f", "--format", help="Use number format: 1=$1234 2=1234h 3=1234 4=177777 (default 1)", default=1, type=int, choices=range(1, 5))
parser.add_argument("-i", "--invalid", help="Show invalid opcodes as ??? rather than constants", action="store_true")
args = parser.parse_args()

# Get filename from command line arguments.
filename = args.filename

# Current instruction address. Silently force it to be in valid range.
address = args.address & 0xffff

# Set uppercase output option.
upperOption = args.uppercase

# Contains a line of output
line = ""

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
        print("%04X            %s    $%04X" % (address, case(".org"), address))
    elif args.format == 2:
        print("%04X            %s    %04X%s" % (address, case(".org"), address, case("h")))
    elif args.format == 3:
        print("%04X            %s    %04X" % (address, case(".org"), address))
    else:
        print("%06o               %s    %06o" % (address, case(".org"), address))
else:
    if args.format == 1:
        print(" %s    $%04X" % (case(".org"), address))
    elif args.format == 2:
        print(" %s    %04X%s" % (case(".org"), address, case("h")))
    elif args.format == 3:
        print(" %s    %04X" % (case(".org"), address))
    else:
        print(" %s    %06o" % (case(".org"), address))

while True:
    try:
        b = f.read(1)  # Get binary byte from file

        if len(b) == 0:  # EOF
            if args.nolist is False:
                if args.format == 4:
                    print("%06o               %s" % (address, case("end")))  # Exit if end of file reached.
                else:
                    print("%04X            %s" % (address, case("end")))  # Exit if end of file reached.
            break

        if args.nolist is False:
            line = "%s  " % formatAddress(address)  # Print current address

        op = ord(b)  # Get opcode byte

        mnem = case(opcodeTable[op][0])  # Get mnemonic

        mode = opcodeTable[op][1]  # Get addressing mode

        n = lengthTable[mode]  # Look up number of instruction bytes

        # Handle special case of immediate instructions that are three
        # bytes long.
        if mnem in set(["cpx", "ldx", "lds"]):
            n = 3

        # Print instruction bytes
        if n == 1:
            if args.nolist is False:
                if args.format == 4:
                    line += "%03o          " % op
                else:
                    line += "%02X        " % op
        elif n == 2:
            try:  # Possible to get exception here if EOF reached.
                op1 = ord(f.read(1))
            except TypeError:
                op1 = 0  # Fake it to recover from EOF
            if args.nolist is False:
                if args.format == 4:
                    line += "%03o %03o      " % (op, op1)
                else:
                    line += "%02X %02X     " % (op, op1)
        elif n == 3:
            try:  # Possible to get exception here if EOF reached.
                op1 = ord(f.read(1))
                op2 = ord(f.read(1))
            except TypeError:
                op1 = 0  # Fake it to recover from EOF
                op2 = 0
            if args.nolist is False:
                line += "%s %s %s  " % (formatByte(op), formatByte(op1), formatByte(op2))
        if args.nolist is True:
            line += " "

        # Special check for invalid op code.
        if mnem == "???" and not args.invalid:
            if isprint(chr(op)):
                line += "%s   '%c'" % (case(".byte"), op)
            else:
                if args.format == 1:
                    line += "%s   $%s" % (case(".byte"), formatByte(op))
                elif args.format == 2:
                    line += "%s   %s%s" % (case(".byte"), formatByte(op), case("h"))
                else:
                    line += "%s   %s" % (case(".byte"), formatByte(op))
        else:
            line += mnem
            if len(mnem) == 3:
               line += " "

        if mode == implied:
            pass

        elif mode == immediate:
            if (n == 2):
                if isprint(chr(op1)):
                    line += "    #'%c'" % op1
                else:
                    if args.format == 1:
                        line += "    #$%s" % formatByte(op1)
                    elif args.format == 2:
                        line += "    #%s%s" % (formatByte(op1), case("h"))
                    else:
                        line += "    #%s" % formatByte(op1)
            elif (n == 3):
                if args.format == 1:
                    line += "    #$%s%s" % (formatByte(op1), formatByte(op2))
                elif args.format == 2:
                    line += "    #%s%s%s" % (formatByte(op1), formatByte(op2), case("h"))
                else:
                    line += "    #%s%s" % (formatByte(op1), formatByte(op2))

        elif mode == direct:
            if args.format == 1:
                line += "    $%s" % formatByte(op1)
            elif args.format == 2:
                line += "    %s%s" % (formatByte(op1), case("h"))
            else:
                line += "    %s" % formatByte(op1)

        elif mode == indexed:
            if args.format == 1:
                line += "    $%s,%s" % (formatByte(op1), case("x"))
            elif args.format == 2:
                line += "    %s%s,%s" % (formatByte(op1), case("h"), case("x"))
            else:
                line += "    %s,%s" % (formatByte(op1), case("x"))

        elif mode == extended:
            if args.format == 1:
                line += "    $%s%s" % (formatByte(op1), formatByte(op2))
            elif args.format == 2:
                line += "    %s%s%s" % (formatByte(op1), formatByte(op2), case("h"))
            else:
                line += "    %s%s" % (formatByte(op1), formatByte(op2))

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
                line += "    %s%s" % (formatAddress(dest), formatByte(op1))

        else:
            print("Internal error: unknown addressing mode:", mode, file=sys.stderr)
            sys.exit(1)

        # Update address
        address += n

        # Check for address exceeding 0xFFFF, if so wrap around.
        if address > 0xffff:
            address = address & 0xffff

        # Finished a line of disassembly
        print(line)
        line = ""

    except KeyboardInterrupt:
        print("Interrupted by Control-C", file=sys.stderr)
        if args.format == 4:
            print("%s               %s" % (formatAddress(address), case("end")))  # Exit if end of file reached.
        else:
            print("%s            %s" % (formatAddress(address), case("end")))  # Exit if end of file reached.
        break
