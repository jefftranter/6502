/*
 * Class to emulate a 6502 CPU and system with RAM, ROM, and peripherals.
 */

#include <cstdint>
#include <list>
#include <queue>
#include <istream>
#include <ostream>
#include <fstream>
#include <fstream>

using namespace std;

class Sim6502 {

public:

    // CPU types. Currently only MOS6502 is supported.
    enum CpuType { MOS6502, Rockwell65C02, WDC65C02, WDC65816 };

    // Peripheral types. Currently only M6850 is supported.
    enum PeripheralType { MC6850, MC6820 };

    // Processor status register bits
    const uint8_t S_BIT = 0x80;
    const uint8_t V_BIT = 0x40;
    const uint8_t X_BIT = 0x20;
    const uint8_t B_BIT = 0x10;
    const uint8_t D_BIT = 0x08;
    const uint8_t I_BIT = 0x04;
    const uint8_t Z_BIT = 0x02;
    const uint8_t C_BIT = 0x01;

    // Stack address
    const uint16_t STACK = 0x0100;

    // Addressing modes, used for disassembly
    enum AddressMode
        {
         implicit, absolute, absoluteX, absoluteY, accumulator, immediate, indirectX,
         indirectY, indirect, relative, zeroPage, zeroPageX, zeroPageY
        };

    // Lookup table of addressing modes. Given addressing mode, returns length of instruction in bytes.
    const int lengthTable[13] =
        {
         1, 3, 3, 3, 1, 2, 2, 2, 3, 2, 2, 2, 2
        };

    // Opcodes for disassembly. Given opcode number, returns instruction name string.
    const char *opCodeTable[256] =
        {
         "brk", "ora", "???", "???", "???", "ora", "asl", "???", "php", "ora", "asla", "???", "???", "ora", "asl", "???",
         "bpl", "ora", "???", "???", "???", "ora", "asl", "???", "clc", "ora", "???",  "???", "???", "ora", "asl", "???",
         "jsr", "and", "???", "???", "bit", "and", "rol", "???", "plp", "and", "rola", "???", "bit", "and", "rol", "???",
         "bmi", "and", "???", "???", "???", "and", "rol", "???", "sec", "and", "???",  "???", "???", "and", "rol", "???",
         "rti", "eor", "???", "???", "???", "eor", "lsr", "???", "pha", "eor", "lsra", "???", "jmp", "eor", "lsr", "???",
         "bvc", "eor", "???", "???", "???", "eor", "lsr", "???", "cli", "eor", "???",  "???", "???", "eor", "lsr", "???",
         "rts", "adc", "???", "???", "???", "adc", "ror", "???", "pla", "adc", "rora", "???", "jmp", "adc", "ror", "???",
         "bvs", "adc", "???", "???", "???", "adc", "ror", "???", "sei", "adc", "???",  "???", "???", "adc", "ror", "???",
         "???", "sta", "???", "???", "sty", "sta", "stx", "???", "dey", "???", "txa",  "???", "sty", "sta", "stx", "???",
         "bcc", "sta", "???", "???", "sty", "sta", "stx", "???", "tya", "sta", "txs",  "???", "???", "sta", "???", "???",
         "ldy", "lda", "ldx", "???", "ldy", "lda", "ldx", "???", "tay", "lda", "tax",  "???", "ldy", "lda", "ldx", "???",
         "bcs", "lda", "???", "???", "ldy", "lda", "ldx", "???", "clv", "lda", "tsx",  "???", "ldy", "lda", "ldx", "???",
         "cpy", "cmp", "???", "???", "cpy", "cmp", "dec", "???", "iny", "cmp", "dex",  "???", "cpy", "cmp", "dec", "???",
         "bne", "cmp", "???", "???", "???", "cmp", "dec", "???", "cld", "cmp", "???",  "???", "???", "cmp", "dec", "???",
         "cpx", "sbc", "???", "???", "cpx", "sbc", "inc", "???", "inx", "sbc", "nop",  "???", "cpx", "sbc", "inc", "???",
         "beq", "sbc", "???", "???", "???", "sbc", "inc", "???", "sed", "sbc", "???",  "???", "???", "sbc", "inc", "???"
        };

    // Lookup table of addressing modes. Gven opcode number, returns addressing mode.
    const AddressMode addressModeTable[256] =
        {
         implicit,  indirectX, implicit,    implicit, implicit,  zeroPage,  zeroPage,  implicit,
         implicit,  immediate, accumulator, implicit, implicit,  absolute,  absolute,  implicit,
         relative,  indirectY, implicit,    implicit, implicit,  zeroPageX, zeroPageX, implicit,
         implicit,  absoluteY, implicit,    implicit, implicit,  absoluteX, absoluteX, implicit,
         absolute,  indirectX, implicit,    implicit, zeroPage,  zeroPage,  zeroPage,  implicit,
         implicit,  immediate, accumulator, implicit, absolute,  absolute,  absolute,  implicit,
         relative,  indirectY, implicit,    implicit, implicit,  zeroPageX, zeroPageX, implicit,
         implicit,  absoluteY, implicit,    implicit, implicit,  absoluteX, absoluteX, implicit,
         implicit,  indirectX, implicit,    implicit, implicit,  zeroPage,  zeroPage,  implicit,
         implicit,  immediate, accumulator, implicit, absolute,  absolute,  absolute,  implicit,
         relative,  indirectY, implicit,    implicit, implicit,  zeroPageX, zeroPageX, implicit,
         implicit,  absoluteY, implicit,    implicit, implicit,  absoluteX, absoluteX, implicit,
         implicit,  indirectX, implicit,    implicit, implicit,  zeroPage,  zeroPage,  implicit,
         implicit,  immediate, accumulator, implicit, indirect,  absolute,  absolute,  implicit,
         relative,  indirectY, implicit,    implicit, implicit,  zeroPageX, zeroPageX, implicit,
         implicit,  absoluteY, implicit,    implicit, implicit,  absoluteX, absoluteX, implicit,
         implicit,  indirectX, implicit,    implicit, zeroPage,  zeroPage,  zeroPage,  implicit,
         implicit,  implicit,  implicit,    implicit, absolute,  absolute,  absolute,  implicit,
         relative,  indirectY, implicit,    implicit, zeroPageX, zeroPageX, zeroPageY, implicit,
         implicit,  absoluteY, implicit,    implicit, implicit,  absoluteX, implicit,  implicit,
         immediate, indirectX, immediate,   implicit, zeroPage,  zeroPage,  zeroPage,  implicit,
         implicit,  immediate, implicit,    implicit, absolute,  absolute,  absolute,  implicit,
         relative,  indirectY, implicit,    implicit, zeroPageX, zeroPageX, zeroPageY, implicit,
         implicit,  absoluteY, implicit,    implicit, absoluteX, absoluteX, absoluteY, implicit,
         immediate, indirectX, implicit,    implicit, zeroPage,  zeroPage,  zeroPage,  implicit,
         implicit,  immediate, implicit,    implicit, absolute,  absolute,  absolute,  implicit,
         relative,  indirectY, implicit,    implicit, implicit,  zeroPageX, zeroPageX, implicit,
         implicit,  absoluteY, implicit,    implicit, implicit,  absoluteX, absoluteX, implicit,
         immediate, indirectX, implicit,    implicit, zeroPage,  zeroPage,  zeroPage,  implicit,
         implicit,  immediate, implicit,    implicit, absolute,  absolute,  absolute,  implicit,
         relative,  indirectY, implicit,    implicit, implicit,  zeroPageX, zeroPageX, implicit,
         implicit,  absoluteY, implicit,    implicit, implicit,  absoluteX, absoluteX, implicit
        };

    // Constructor
    Sim6502();

    // Destructor
    ~Sim6502();

    CpuType cpuType();
    void setCpuType(const CpuType &type);

    // TODO: Support multiple RAM/ROM ranges? Set arbitrary addresses or pages as ROM or ROM?
    void ramRange(uint16_t &start, uint16_t &end) const;
    void setRamRange(uint16_t start, uint16_t end);
    void romRange(uint16_t &start, uint16_t &end) const;
    void setRomRange1(uint16_t start, uint16_t end);
    void setRomRange2(uint16_t start, uint16_t end);

    void videoRange(uint16_t &start, uint16_t &end) const;
    void setVideoRange(uint16_t start, uint16_t end);
    void setPeripheral(PeripheralType type, uint16_t start);
    void setKeyboard(uint16_t start);

    // Reset CPU.
    void reset();

    // Simulate IRQ.
    void irq();

    // Simulate NMI.
    void nmi();

    // Step CPU one instruction.
    void step(bool over = false);

    // Set/get registers (A, X, Y, SR, SP, PC)
    uint8_t aReg() const;
    void setAReg(uint8_t val);
    uint8_t xReg() const;
    void setXReg(uint8_t val);
    uint8_t yReg() const;
    void setYReg(uint8_t val);
    uint8_t pReg() const;
    void setPReg(uint8_t val);
    uint8_t sp() const;
    void setSP(uint8_t val);
    uint16_t pc() const;
    void setPC(uint16_t val);

    // Write to memory. Ignores writes to ROM or unused memory.
    void write(uint16_t address, uint8_t byte);

    // Write to peripheral.
    void writePeripheral(uint16_t address, uint8_t byte);

    // Write to video memory.
    void writeVideo(uint16_t address, uint8_t byte);

    // Write to keyboard.
    void writeKeyboard(uint16_t address, uint8_t byte);

    // Read from memory.
    uint8_t read(uint16_t address);

    // Read from peripheral.
    uint8_t readPeripheral(uint16_t address);

    // Read from video memory.
    uint8_t readVideo(uint16_t address);

    // Read from keyboard.
    uint8_t readKeyboard(uint16_t address);

    // Return if an address is RAM, ROM, peripheral, video, keyboard, or unused.
    bool isRam(uint16_t address) const;
    bool isRom(uint16_t address) const;
    bool isPeripheral(uint16_t address) const;
    bool isVideo(uint16_t address) const;
    bool isKeyboard(uint16_t address) const;
    bool isUnused(uint16_t address) const;

    // Load memory from file.
    bool loadMemory(string filename, uint16_t startAddress=0);

    // Save memory to file.
    bool saveMemory(string filename, uint16_t startAddress=0, uint16_t endAddress=0xffff);

    // Set/Fill a range of memory
    void setMemory(uint16_t startAddress, uint16_t endAddress, uint8_t byte=0);

    // Dump memory to standard output
    void dumpMemory(uint16_t startAddress, uint16_t endAddress, bool showAscii=true);

    // Disassemble memory to standard output. Returns next address to disassemble.
    uint16_t disassembleMemory(uint16_t startAddress, uint16_t endAddress, bool showAscii=true);

    // Dump registers to standard output
    void dumpRegisters();

    // Dump video memory
    void dumpVideo();

    // Simulate pressing a keyboard key
    void pressKey(char key);

    // Breakpoint support
    void setBreakpoint(uint16_t address);
    void clearBreakpoint(uint16_t address);
    std::list<uint16_t> getBreakpoints() const;

    // Watchpoint support
    void setReadWatchpoint(uint16_t address);
    void setWriteWatchpoint(uint16_t address);
    void clearReadWatchpoint(uint16_t address);
    void clearWriteWatchpoint(uint16_t address);
    std::list<uint16_t> getReadWatchpoints() const;
    std::list<uint16_t> getWriteWatchpoints() const;

    bool stop(); // Return whether trace/go should stop due to event.
    string stopReason(); // Return reason for stop

    // Flags to control logging output
    void loggingStatus();
    void enableLogging(string category, bool enable = true);

    // Control of options
    bool stopInvalid();
    void setStopInvalid(bool option);
    bool stopBrk();
    void setStopBrk(bool option);
    string serialInputFile();
    void setSerialInputFile(string filename);
    string serialOutputFile();
    void setSerialOutputFile(string filename);

  protected:

    CpuType m_cpuType = MOS6502; // CPU type

    uint16_t m_ramStart = 0; // RAM start
    uint16_t m_ramEnd = 0; // RAM end

    uint16_t m_romStart1 = 0; // ROM start
    uint16_t m_romEnd1 = 0; // ROM end

    uint16_t m_romStart2 = 0; // ROM start
    uint16_t m_romEnd2 = 0; // ROM end

    uint16_t m_videoStart = 0; // Video memory start
    uint16_t m_videoEnd = 0; // Video memory end

    uint16_t m_peripheralStart = 0; // Peripheral base address
    uint8_t m_6850_control_reg = 0; // MC6850 Status/Control Register
    uint8_t m_6850_data_reg = 0; // MC6850 Data Register

    uint16_t m_keyboardStart = 0; // Keyboard base address
    uint8_t m_keyboardRowRegister = 0;
    uint8_t m_desiredRow = 0;
    uint8_t m_columnData = 0;
    bool m_shift = false;
    bool m_sendingCharacter = false;
    char m_keyboardCharacter;
    int m_tries = 0;

    uint8_t m_regA = 0; // Registers
    uint8_t m_regX = 0;
    uint8_t m_regY = 0;
    uint8_t m_regP = X_BIT;
    uint8_t m_regSP = 0;
    uint16_t m_regPC = 0;

    uint8_t m_memory[0x10000]{0}; // Memory (Used for RAM, ROM, and video)

    uint8_t m_row[128]{0}; // Keyboard row lookup table by key
    uint8_t m_col[128]{0}; // Keyboard column lookup table by key
    bool m_shifted[128]{false}; // Flags keys that need to be shifted

    std::list<uint16_t> m_breakpoints; // Breakpoint list

    std::list<uint16_t> m_readWatchpoints; // Read watchpoint list
    std::list<uint16_t> m_writeWatchpoints; // Write watchpoint list

    std::queue<char> m_keyboardFifo = {}; // Holds keyboard input

    string m_serialInFilename = "serial.in"; // Default filename for serial port input
    string m_serialOutFilename = "serial.out"; // Default filename for serial port input

    ofstream m_serialOut; // File for emulating serial port output
    ifstream m_serialIn; // File for emulating serial port input

    // Flags to set whether to stop run/trace on specific events
    bool m_stop = false;
    string m_stopReason = "none";

    // Control of options
    bool m_stopInvalid = true;
    bool m_stopBRK = true;

    // Flags to control logging output
    bool m_logErrors = true;
    bool m_logWarnings = true;
    bool m_logSerial = false;
    bool m_logKeyboard = false;
    bool m_logMemory = false;
    bool m_logVideo = false;
    bool m_logInstructions = false;
    bool m_logRegisters = false;
};
