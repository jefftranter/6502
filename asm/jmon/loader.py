#! /usr/bin/env python3
#
# Reads a binary file and outputs a series of Basic POKE statements to
# write the file to memory.

import sys
import argparse

# Parse command line options
parser = argparse.ArgumentParser()
parser.add_argument("filename", help="Binary file to use for data")
parser.add_argument("-l", "--loadAddress", help="Specify decimal starting load address (defaults to 4096)", default=4096, type=int)
parser.add_argument("-s", "--startAddress", help="Specify decimal run address (defaults to load address)", default=-1, type=int)

args = parser.parse_args()

# Get filename from command line arguments.
filename = args.filename

# Get initial instruction address from command line arguments.
a = args.loadAddress

# Get start instruction address from command line arguments.
# Use load address if not specified.
s = args.startAddress
if s == -1:
    s = a

try:
    f = open(args.filename, "rb")
except FileNotFoundError:
    print(("error: input file '{}' not found.".format(args.filename)), file=sys.stderr)
    sys.exit(1)

print("REM {0:s}".format(args.filename))

while True:
    b = f.read(1)
    if not b:
        break

    print("POKE{0:d},{1:d}".format(a, ord(b)))
    a += 1

# 11,12 contains USR() function address
print("REM START ADDRESS {0:d}".format(s))
print("POKE11,{0:d}:POKE 12,{1:d}".format(int(s % 256), int(s / 256)))
print("X = USR(0)")
