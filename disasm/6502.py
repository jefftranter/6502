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
"accumulator" : "",
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
#   flags (e.g. pcr, char)
opcodeTable = {
0x00 : [ 1, "brk", "implicit"        ],
0x01 : [ 2, "ora", "indirectx"       ],
0x05 : [ 2, "ora", "zeropage"        ],
0x10 : [ 2, "bpl", "relative", pcr   ],
0x20 : [ 3, "jsr", "absolute"        ],
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
