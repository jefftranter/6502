This directory contains source code for the PLEASE software package
for the KIM-1 written by Robert M. Tripp in 1977.

It was originally distributed on cassette tape.

I have entered the original source code in a format that it can be
cross-assembled and loaded as a paper tape (PTP) file. Some errors in
the original code were corrected and are marked with "JJT" in the
comments.

You need to load both please.ptp as well as one of the program
module files (e.g. program1.ptp).

See the PDF documentation for details.

Current status:

All programs working, except:

Module #5:
  "AS" - Crashes when making calculation.
  "RE" - Crashes when starting timer.

The latter hits BRK at address $0382?
