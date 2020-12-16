#! /usr/bin/env python3
#
# Reads a binary file and outputs a series of Basic POKE statements to
# write the file to memory.

import os
import sys

if len(sys.argv) != 2:
    print("usage: loader.py <filename>")
    sys.exit(1)

# Binary filename - adjust as needed
f = open(sys.argv[1], "rb")

# Start/load address - adjust as needed
s = 0x2000

# Current address
a = s

while True:
    b = f.read(1)
    if not b:
        break

    print("POKE {0:d},{1:d}".format(a, ord(b)))
    a += 1

# 11,12 contains USR() function address
print("POKE 11,{0:d} : POKE 12,{1:d}".format(int(s % 256), int(s / 256)))
print("X = USR(0)")
