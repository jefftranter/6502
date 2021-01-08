#! /usr/bin/env python3
#

# Reads a binary file and outputs a format that can be loaded by the JMON monitor.

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

# Output format:
# : <load address> <hh> <hh> <hh> <hh> <hh>... <esc>
# GO <start address>

try:
    f = open(args.filename, "rb")
except FileNotFoundError:
    print(("error: input file '{}' not found.".format(args.filename)), file=sys.stderr)
    sys.exit(1)

print(":{0:04X}".format(a), end="")

while True:
    b = f.read(1)
    if not b:
        break

    print("{0:02X}".format(ord(b)), end="")

# Send ESC at end of data
print("\x1b", end="")

# Go address
print("G{0:04X}".format(s), end="")
