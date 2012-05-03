This is source code for Apple 1 BASIC. The starting point was a
disassembly by Eric Smith <eric@brouhaha.com> from
http://www.brouhaha.com/~eric/retrocomputing/apple/apple1/basic/

It was modified to assemble with CC65 and match the code in the Apple
Replica 1 BASIC ROM.

You can change the .org address and run it out of RAM if desired.

Examples of things easily changed:

- change the prompt character (look for the comment "Prompt character...")
- change defaults value of LOMEM or HIMEM (see routine mem_init_4k)
