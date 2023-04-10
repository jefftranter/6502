#!/usr/bin/env python3
#
# Converts an OS65D 5.25" disk image to an 8" image.
# Based on QBasic code from OSIWeb forum user "bxdanny".
#
# Jeff Tranter <tranter@pobox.com>

import sys

if len(sys.argv) != 3:
  print("usage:", sys.argv[0], "convert <infile> <outfile>");
  exit(1)

F1 = sys.argv[1]
F2 = sys.argv[2]
print("Converting", F1, "to", F2)
f1 = open(F1, "rb")
f2 = open(F2, "wb")
t5 = bytes([0]*0x900)
for t in range(40):
    f1.seek(t*0x900)
    t5 = f1.read(0x900)
    f2.seek(t*0xf00)
    f2.write(t5)
    hw = t5[-4:]
    f2.seek((t + 1) * 0xf00 - 3)
    f2.write(hw)
lb = bytes([0])
f2.seek(int(77 * 0xf00) -1)
f2.write(lb)
f1.close()
f2.close()
