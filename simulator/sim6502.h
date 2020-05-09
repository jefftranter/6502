/*
 * Class to emulate a 6502 CPU and system with RAM, ROM, and peripherals.
 */

#include <cstdint>
#include <string>

using namespace std;

class Sim6502 {

public:

    enum CpuType { MOS6502, Rockwell65C02, WDC65C02, WDC65816 };
    enum PeripheralType { MC6850, MC6820 };

    // Status register bits
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

    Sim6502();
    ~Sim6502();

    CpuType cpuType();
    void setCpuType(const CpuType &type);

    // TODO: Support multiple RAM/ROM ranges? Set arbitrary addresses or pages as ROM or ROM?
    void ramRange(uint16_t &start, uint16_t &end);
    void setRamRange(uint16_t start, uint16_t end);
    void romRange(uint16_t &start, uint16_t &end);
    void setRomRange(uint16_t start, uint16_t end);

    void videoRange(uint16_t &start, uint16_t &end);
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
    void step();

    // Set/get registers (A, X, Y, SR, SP, PC)
    uint8_t aReg();
    void setAReg(uint8_t val);
    uint8_t xReg();
    void setXReg(uint8_t val);
    uint8_t yReg();
    void setYReg(uint8_t val);
    uint8_t sr();
    void setSR(uint8_t val);
    uint8_t sp();
    void setSP(uint8_t val);
    uint16_t pc();
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
    bool isRam(uint16_t address);
    bool isRom(uint16_t address);
    bool isPeripheral(uint16_t address);
    bool isVideo(uint16_t address);
    bool isKeyboard(uint16_t address);
    bool isUnused(uint16_t address);

    // Load memory from file.
    bool loadMemory(string filename, uint16_t startAddress=0);

    // Save memory to file.
    bool saveMemory(string filename, uint16_t startAddress=0, uint16_t endAddress=0xffff);

    // Set/Fill a range of memory
    void setMemory(uint16_t startAddress, uint16_t endAddress, uint8_t byte=0);

    // Dump memory to standard output
    void dumpMemory(uint16_t startAddress, uint16_t endAddress);

    // Dump registers to standard output
    void dumpRegisters();

    // Dump video memory
    void dumpVideo();

    // TODO: Set/get breakpoint?
    // TODO: Breakpoint hit (callback?).
    // TODO: Keyboard/peripheral input (callback?).
    // TODO Illegal instruction (callback?).

  protected:

    CpuType m_cpuType = MOS6502; // CPU type

    uint16_t m_ramStart = 0; // RAM start
    uint16_t m_ramEnd = 0; // RAM end

    uint16_t m_romStart = 0; // ROM start
    uint16_t m_romEnd = 0; // ROM end

    uint16_t m_videoStart = 0; // Video memory start
    uint16_t m_videoEnd = 0; // Video memory end

    uint16_t m_peripheralStart = 0; // Peripheral base address
    uint8_t m_6850_control_reg = 0; // MC6850 Status/Control Register
    uint8_t m_6850_data_reg = 0; // MC6850 Data Register

    uint16_t m_keyboardStart = 0; // Keyboard base address
    uint8_t m_keyboardRowRegister = 0;

    uint8_t m_regA = 0; // Registers
    uint8_t m_regX = 0;
    uint8_t m_regY = 0;
    uint8_t m_regSR = X_BIT;
    uint8_t m_regSP = 0;
    uint16_t m_regPC = 0;

    uint8_t m_memory[0x10000]{0}; // Memory (Used for RAM, ROM, and video)
};
