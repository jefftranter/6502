##########################################################################
#
# Processor specific code

CPU = "6502"
Description = "MOS Technology (and others) 6502 8-bit microprocessor."
DataWidth = 8  # 8-bit data
AddressWidth = 16  # 16-bit addresses

# Maximum length of an instruction (for formatting purposes)
maxLength = 3

# Leadin bytes for multibyte instructions
leadInBytes = []

# Addressing mode table
# List of addressing modes and corresponding format strings for operands.
addressModeTable = {
"implicit"    : "",
"absolute"    : "${1:02X}{0:02X}",
"absolutex"   : "${1:02X}{0:02X},X",
"absolutey"   : "${1:02X}{0:02X},Y",
"accumulator" : "a",
"immediate"   : "#${0:02X}",
"indirectx"   : "(${0:02X},X)",
"indirecty"   : "(${0:02X}),Y",
"indirect"    : "(${1:02X}{0:02X})",
"relative"    : "${0:04X}",
"zeropage"    : "${0:02X}",
"zeropagex"   : "${0:02X},X",
"zeropagey"   : "${0:02X},Y",
}

# Op Code Table
# Key is numeric opcode (possibly multiple bytes)
# Value is a list:
#   # bytes
#   mnemonic
#   addressing mode
#   flags (e.g. pcr)
opcodeTable = {
0x00 : [ 1, "brk", "implicit"        ],
0x01 : [ 2, "ora", "indirectx"       ],
0x05 : [ 2, "ora", "zeropage"        ],
0x06 : [ 2, "asl", "zeropage"        ],
0x08 : [ 1, "php", "implicit"        ],
0x09 : [ 2, "ora", "immediate"       ],
0x0a : [ 1, "asl", "accumulator"     ],
0x0d : [ 3, "ora", "absolute"        ],
0x0e : [ 3, "asl", "absolute"        ],

0x10 : [ 2, "bpl", "relative", pcr   ],
0x11 : [ 2, "ora", "indirecty"       ],
0x15 : [ 3, "ora", "absolutex"       ],
0x16 : [ 3, "asl", "absolutey"       ],
0x18 : [ 1, "clc", "implicit"        ],
0x19 : [ 3, "ora", "absolutey"       ],
0x1d : [ 3, "ora", "absolutex"       ],
0x1e : [ 3, "asl", "absolutex"       ],

0x20 : [ 3, "jsr", "absolute"        ],
0x21 : [ 2, "and", "indirectx"       ],
0x24 : [ 2, "bit", "zeropage"        ],
0x25 : [ 2, "and", "zeropage"        ],
0x26 : [ 2, "rol", "zeropage"        ],
0x28 : [ 1, "plp", "implicit"        ],
0x29 : [ 2, "and", "immediate"       ],
0x2a : [ 1, "rol", "accumulator"     ],
0x2c : [ 3, "bit", "absolute"        ],
0x2d : [ 3, "and", "absolute"        ],
0x2e : [ 3, "rol", "absolute"        ],

0x30 : [ 2, "bmi", "relative"        ],
0x31 : [ 2, "and", "indirecty"       ],
0x35 : [ 2, "and", "zeropagex"       ],
0x36 : [ 2, "rol", "zeropagex"       ],
0x38 : [ 1, "sec", "implicit"        ],
0x39 : [ 3, "and", "absolutey"       ],
0x3d : [ 3, "and", "absolutex"       ],
0x3e : [ 3, "rol", "absolutex"       ],

0x40 : [ 1, "rti", "implicit"        ],
0x41 : [ 2, "eor", "indirectx"       ],
0x45 : [ 2, "eor", "zeropage"        ],
0x46 : [ 2, "lsr", "zeropage"        ],
0x48 : [ 1, "pha", "implicit"        ],
0x49 : [ 2, "eor", "immediate"       ],
0x4a : [ 1, "lsr", "accumulator"     ],
0x4c : [ 3, "jmp", "absolute"        ],
0x4d : [ 3, "eor", "absolute"        ],
0x4e : [ 3, "lsr", "absolute"        ],

0x4c : [ 3, "jmp", "absolute"        ],
0x6c : [ 3, "jmp", "indirect"        ],
0xa1 : [ 2, "lda", "indirectx"       ],
0xa5 : [ 2, "lda", "zeropage"        ],
0xa9 : [ 2, "lda", "immediate"       ],
0xb1 : [ 2, "lda", "indirecty"       ],
0xb5 : [ 2, "lda", "zeropagex"       ],
0xad : [ 3, "lda", "absolute"        ],
0xb9 : [ 3, "lda", "absolutey"       ],
0xbd : [ 3, "lda", "absolutex"       ],
0xfe : [ 2, "inc", "zeropagex"       ],
}

# End of processor specific code
##########################################################################
