#! /usr/bin/env python3
#
# Universal Disassembler
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

# Flags


pcr = 1
str = 2

# Functions


def isprint(c):
    "Return if character is printable ASCII"
    if c >= '@' and c <= '~':
        return True
    else:
        return False

# TODO: Fix any PEP8 warnings

# Avoids an error when output piped, e.g. to "less"
signal.signal(signal.SIGPIPE, signal.SIG_DFL)

# Parse command line options
parser = argparse.ArgumentParser()
parser.add_argument("filename", help="Binary file to disassemble")
parser.add_argument("-c", "--cpu", help="Specify CPU type (defaults to 6502)", default="6502")
parser.add_argument("-n", "--nolist", help="Don't list  instruction bytes (make output suitable for assembler)", action="store_true")
parser.add_argument("-a", "--address", help="Specify decimal starting address (defaults to 0)", default=0, type=int)
parser.add_argument("-i", "--invalid", help="Show invalid opcodes as ??? rather than constants", action="store_true")
args = parser.parse_args()

# Load CPU plugin based on command line option.
plugin = args.cpu + ".py"
try:
    exec(open(plugin).read())
except FileNotFoundError:
    print(("error: cpu plugin file '{}' not found.".format(plugin)), file=sys.stderr)
    sys.exit(1)

# Get filename from command line arguments.
filename = args.filename

# Current instruction address. Silently force it to be in valid range.
address = args.address & 0xffff

# Any flags for current instruction.
flags = 0

# Contains a line of output.
line = ""

# Open input file.
# Display error and exit if filename does not exist.
try:
    f = open(filename, "rb")
except FileNotFoundError:
    print(("error: input file '{}' not found.".format(filename)), file=sys.stderr)
    sys.exit(1)

# Variables:
# address - current instruction address
# opcode - binary instruction opcode (may be multiple bytes)
# length - length of current instruction
# mnemonic - assembler mnemonic for current instruction
# format - operand format string
# line - line to output
# leadin - extended opcode (true/false)

# Print initial origin address
if args.nolist is False:
    print("{0:04X}            .org   ${1:04X}".format(address, address))
else:
    print(" .org    ${0:04X}".format(address))

while True:
    try:
        b = f.read(1)  # Get binary byte from file

        if len(b) == 0:  # handle EOF
            break

        opcode = ord(b)

        if opcode in leadInBytes:
            b = f.read(1)  # Get next byte of extended opcode
            opcode = (opcode << 8) + ord(b)
            leadin = True
        else:
            leadin = False

        if opcode in opcodeTable:
            length = opcodeTable[opcode][0]
            mnemonic = opcodeTable[opcode][1]
            mode = opcodeTable[opcode][2]
            if len(opcodeTable[opcode]) > 3:
                flags = opcodeTable[opcode][3]
            else:
                flags = 0
            if mode in addressModeTable:
                format = addressModeTable[mode]
            else:
                print(("error: mode '{}' not found in addressModeTable.".format(mode)), file=sys.stderr)
                sys.exit(1)
        else:
            length = 1  # Invalid opcode
            format = ""
            mnemonic = "???"

# Disassembly format:
# XXXX  XX XX XX XX XX  nop    ($1234,X)
# With --nolist option:
# nop    ($1234,X)

# TODO: Implement --nolist option

        if leadin is True:
            line += "{0:04X}  {1:02X} {2:02X}".format(address, opcode // 256, opcode % 256)
            length -= 1
        else:
            line += "{0:04X}  {1:02X}".format(address, opcode)

        op = {}  # Array to hold operands

        for i in range(1, maxLength):
            if (i < length):
                op[i] = ord(f.read(1))  # Get operand bytes
                line += " {0:02X}".format(op[i])
            else:
                line += "   "

        # Handle relative addresses (flag)
        if flags == pcr:
            if op[1] < 128:
                op[1] = address + op[1] + 2
            else:
                op[1] = address - (256 - op[1]) + 2
            if op[1] < 0:
                op[1] = 65536 + op[1]

        # Format the operand using format string and any operands.
        if length == 1:
            operand = ""
        elif length == 2:
            operand = format.format(op[1])
        elif length == 3:
            operand = format.format(op[1], op[2])
        elif length == 4:
            operand = format.format(op[1], op[2], op[3])
        elif length == 5:
            operand = format.format(op[1], op[2], op[3], op[4])

        # Special check for invalid op code.
        if mnemonic == "???" and not args.invalid:
            if isprint(chr(opcode)):
                mnemonic = ".byte  '{0:c}'".format(opcode)
            else:
                mnemonic = ".byte  ${0:02X}".format(opcode)

        if operand == "":
            line += "  {0:s}".format(mnemonic)
        else:
            line += "  {0:s}    {1:s}".format(mnemonic, operand)

        print(line)

        address = (address + length) & 0xffff
        line = ""
        flags = 0

    except KeyboardInterrupt:
        print("Interrupted by Control-C", file=sys.stderr)
        break
