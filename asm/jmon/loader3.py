#! /usr/bin/env python3
#
# Reads a binary file and outputs a series of Basic DATA statements to
# write the file to memory.

import sys
import argparse

# Parse command line options
parser = argparse.ArgumentParser()
parser.add_argument("filename", help="Binary file to use for data")

args = parser.parse_args()

# Get filename from command line arguments.
filename = args.filename

try:
    f = open(args.filename, "rb")
except FileNotFoundError:
    print(("error: input file '{}' not found.".format(args.filename)), file=sys.stderr)
    sys.exit(1)

a = 0
l = 1000

while True:
    b = f.read(1)
    if not b:
        break

    if a % 8 == 0:
        print("{0:d} DATA ".format(l), end="");
    
    print("{0:d}".format(ord(b)), end="")

    a += 1
    if a % 8 == 0:
        print("");
        l += 10
    else:
        print(",", end="")

print("")
