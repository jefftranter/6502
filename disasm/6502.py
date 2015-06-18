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

0x30 : [ 2, "bmi", "relative", pcr   ],
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

0x50 : [ 2, "bvc", "relative", pcr   ],
0x51 : [ 2, "eor", "indirecty"       ],
0x55 : [ 2, "eor", "zeropagex"       ],
0x56 : [ 2, "lsr", "zeropagex"       ],
0x58 : [ 1, "cli", "implicit"        ],
0x59 : [ 3, "eor", "absolutey"       ],
0x5d : [ 3, "eor", "absolutex"       ],
0x5e : [ 3, "lsr", "absolutex"       ],

0x60 : [ 1, "rts", "implicit"        ],
0x61 : [ 2, "adc", "indirectx"       ],
0x65 : [ 2, "adc", "zeropage"        ],
0x66 : [ 2, "ror", "zeropage"        ],
0x68 : [ 1, "pla", "implicit"        ],
0x69 : [ 2, "adc", "immediate"       ],
0x6a : [ 1, "ror", "accumulator"     ],
0x6c : [ 3, "jmp", "indirect"        ],
0x6d : [ 3, "adc", "absolute"        ],
0x6e : [ 3, "ror", "absolute"        ],

0x70 : [ 2, "bvs", "relative", pcr   ],
0x71 : [ 2, "adc", "indirecty"       ],
0x75 : [ 2, "adc", "zeropagex"       ],
0x76 : [ 2, "ror", "zeropagex"       ],
0x78 : [ 1, "sei", "implicit"        ],
0x79 : [ 3, "adc", "absolutey"       ],
0x7d : [ 3, "adc", "absolutex"       ],
0x7e : [ 3, "ror", "absolutex"       ],

0x81 : [ 2, "sta", "indirectx"       ],
0x84 : [ 2, "sty", "zeropage"        ],
0x85 : [ 2, "sta", "zeropage"        ],
0x86 : [ 2, "stx", "zeropage"        ],
0x88 : [ 1, "dey", "implicit"        ],
0x8a : [ 1, "txa", "implicit"        ],
0x8c : [ 1, "sty", "absolute"        ],
0x8d : [ 3, "sta", "absolute"        ],
0x8e : [ 3, "stx", "absolute"        ],

0x90 : [ 2, "bcc", "relative", pcr   ],
0x91 : [ 2, "sta", "indirecty"       ],
0x94 : [ 2, "sty", "zeropagex"       ],
0x95 : [ 2, "sta", "zeropagex"       ],
0x96 : [ 2, "stx", "zeropagey"       ],
0x98 : [ 1, "tya", "implicit"        ],
0x99 : [ 3, "sta", "absolutey"       ],
0x9a : [ 2, "txs", "implicit"        ],
0x9d : [ 3, "sta", "absolutex"       ],

0xa0 : [ 2, "ldy", "immediate"       ],
0xa1 : [ 2, "lda", "indirectx"       ],
0xa2 : [ 2, "ldx", "immediate"       ],
0xa4 : [ 2, "ldy", "zeropage"        ],
0xa5 : [ 2, "lda", "zeropage"        ],
0xa6 : [ 2, "ldx", "zeropage"        ],
0xa8 : [ 1, "tay", "implicit"        ],
0xa9 : [ 2, "lda", "immediate"       ],
0xaa : [ 1, "tax", "implicit"        ],
0xac : [ 3, "ldy", "absolute"        ],
0xad : [ 3, "lda", "absolute"        ],
0xae : [ 3, "ldx", "absolute"        ],

0xb0 : [ 2, "bcs", "relative", pcr   ],
0xb1 : [ 2, "lda", "indirecty"       ],
0xb4 : [ 2, "ldy", "zeropagex"       ],
0xb5 : [ 2, "lda", "zeropagex"       ],
0xb6 : [ 2, "ldx", "zeropagey"       ],
0xb8 : [ 1, "clv", "implicit"        ],
0xb9 : [ 3, "lda", "absolutey"       ],
0xba : [ 1, "tsx", "implicit"        ],
0xbc : [ 3, "ldy", "absolutex"       ],
0xbd : [ 3, "lda", "absolutex"       ],
0xbe : [ 3, "ldx", "absolutey"       ],

0xc0 : [ 2, "cpy", "immediate"       ],
0xc1 : [ 2, "cmp", "indirectx"       ],
0xc4 : [ 2, "cpy", "zeropage"        ],
0xc5 : [ 2, "cmp", "zeropage"        ],
0xc6 : [ 2, "dec", "zeropage"        ],
0xc8 : [ 1, "iny", "implicit"        ],
0xc9 : [ 2, "cmp", "immediate"       ],
0xca : [ 1, "dex", "implicit"        ],
0xcc : [ 3, "cpy", "absolute"        ],
0xcd : [ 3, "cmp", "absolute"        ],
0xce : [ 3, "dec", "absolute"        ],

0xd0 : [ 2, "bne", "relative", pcr   ],
0xd1 : [ 2, "cmp", "indirecty"       ],
0xd5 : [ 2, "cmp", "zeropagex"       ],
0xd6 : [ 2, "dec", "zeropagex"       ],
0xd8 : [ 1, "cld", "implicit"        ],
0xd9 : [ 3, "cmp", "absolutey"       ],
0xdd : [ 3, "cmp", "absolutex"       ],
0xde : [ 3, "dec", "absolutex"       ],

0xe0 : [ 2, "cpx", "immediate"       ],
0xe1 : [ 2, "sbc", "indirectx"       ],
0xe4 : [ 2, "cpx", "zeropage"        ],
0xe5 : [ 2, "sbc", "zeropage"        ],
0xe6 : [ 2, "inc", "zeropage"        ],
0xe8 : [ 1, "inx", "implicit"        ],
0xe9 : [ 2, "sbc", "immediate"       ],
0xea : [ 1, "nop", "implicit"        ],
0xec : [ 3, "cpx", "absolute"        ],
0xed : [ 3, "sbc", "absolute"        ],
0xee : [ 3, "inc", "absolute"        ],

0xf0 : [ 2, "beq", "relative", pcr   ],
0xf1 : [ 2, "sbc", "indirecty"       ],
0xf5 : [ 2, "sbc", "zeropagex"       ],
0xf6 : [ 2, "inc", "zeropagex"       ],
0xf8 : [ 1, "sed", "implicit"        ],
0xf9 : [ 3, "sbc", "absolutey"       ],
0xfd : [ 3, "sbc", "absolutex"       ],
0xfe : [ 3, "inc", "absolutex"       ],

}

# End of processor specific code
##########################################################################
