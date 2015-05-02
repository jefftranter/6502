This is a simple disassembler for the 6502 microprocessor. It reads a
binary file specified on the command line and produces a disassembly.
It requires Python 3. It has been tested on Linux but should work on
any platform that supports Python. See the source code for more
details.

The version disasm65c02.py supports the 65C02 microprocessor.
The version disasm65816.py supports the 65816 microprocessor.
The version disasm6800.py supports the 6800 microprocessor.

usage: disasm6502.py [-h] [-n] [-u] [-a ADDRESS] [-f {1,2,3,4}] [-i] filename

positional arguments:

  filename              Binary file to disassemble

optional arguments:

  -h, --help            show this help message and exit

  -n, --nolist          Don't list instruction bytes (make output suitable for
                        assembler)

  -u, --uppercase       Use uppercase for mnemonics

  -a ADDRESS, --address ADDRESS

                        Specify decimal starting address (defaults to 0)

  -f {1,2,3,4}, --format {1,2,3,4}

                        Use number format: 1=$1234 2=1234h 3=1234 4=177777
                        (default 1)

  -i, --invalid         Show invalid opcodes as ??? rather than constants
