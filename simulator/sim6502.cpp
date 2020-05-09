/*
 * Class to emulate a 6502 CPU and system with RAM, ROM, and peripherals.
 */

// TODO: Profile and optimize performance bottlenecks.

#include <cassert>
#include <iostream>
#include <iomanip>
#include <fstream>
#include "sim6502.h"

using namespace std;

Sim6502::Sim6502()
{
}

Sim6502::~Sim6502()
{
}

void Sim6502::setRamRange(uint16_t start, uint16_t end)
{
    assert(start <= end);
    m_ramStart = start;
    m_ramEnd = end;
}

void Sim6502::setRomRange(uint16_t start, uint16_t end)
{
    assert(start <= end);
    m_romStart = start;
    m_romEnd = end;
}

void Sim6502::videoRange(uint16_t &start, uint16_t &end)
{
    start = m_videoStart;
    end = m_videoEnd;
}

void Sim6502::setVideoRange(uint16_t start, uint16_t end)
{
    assert(start <= end);
    m_videoStart = start;
    m_videoEnd = end;
}

void Sim6502::setPeripheral(PeripheralType type, uint16_t start)
{
    assert(type == MC6850);
    m_peripheralStart = start;
}

void Sim6502::setKeyboard(uint16_t start)
{
    m_keyboardStart = start;
}

void Sim6502::reset()
{
    m_regPC = m_memory[0xfffc] + m_memory[0xfffd] * 256;
}


Sim6502::CpuType Sim6502::cpuType()
{
    return m_cpuType;
}

void Sim6502::setCpuType(const CpuType &type)
{
    // TODO: Add support for other CPU variants.
    assert(m_cpuType == MOS6502);
    m_cpuType = type;
}

void Sim6502::irq()
{
    // TODO: Implement full IRQ handling
    m_regPC = m_memory[0xfffe] + m_memory[0xffff] * 256;
}

void Sim6502::nmi()
{
    // TODO: Implement full NMI handling
    m_regPC = m_memory[0xfffa] + m_memory[0xfffb] * 256;
}

uint8_t Sim6502::aReg()
{
    return m_regA;
}

void Sim6502::setAReg(uint8_t val)
{
    m_regA = val;
}

uint8_t Sim6502::xReg()
{
    return m_regX;
}

void Sim6502::setXReg(uint8_t val)
{
    m_regX = val;
}

uint8_t Sim6502::yReg()
{
    return m_regY;
}

void Sim6502::setYReg(uint8_t val)
{
    m_regY = val;
}

uint8_t Sim6502::sr()
{
    return m_regSR;
}

void Sim6502::setSR(uint8_t val)
{
    m_regSR = val;
}

uint8_t Sim6502::sp()
{
    return m_regSP;
}

void Sim6502::setSP(uint8_t val)
{
    m_regSP = val;
}

uint16_t Sim6502::pc()
{
    return m_regPC;
}

void Sim6502::setPC(uint16_t val)
{
    m_regPC = val;
}

void Sim6502::write(uint16_t address, uint8_t byte)
{
    if (isRam(address) || isRom(address)) {
        m_memory[address] = byte;
    } else if (isVideo(address)) {
        writeVideo(address, byte);
    } else if (isPeripheral(address)) {
        writePeripheral(address, byte);
    } else if (isKeyboard(address)) {
        writeKeyboard(address, byte);
    }
}

void Sim6502::writeVideo(uint16_t address, uint8_t byte)
{
    cout << "Wrote $" << setw(2) << hex << (int)byte << " to video RAM at $" << hex << setw(4) << address << endl;
    m_memory[address] = byte;
}

void Sim6502::writePeripheral(uint16_t address, uint8_t byte)
{
    if (address == m_peripheralStart) {
        m_6850_control_reg = byte;
        cout << "Wrote $" << hex << setw(2) << (int)byte << " to MC680 Control Register" << endl;
    } else if (address == m_peripheralStart + 1) {
        m_6850_data_reg = byte;
        cout << "Wrote $" << hex << setw(2) << (int)byte << " to MC680 Data Register" << endl;
    } else {
        assert(false); // Should never be reached
    }
}

void Sim6502::writeKeyboard(uint16_t address, uint8_t byte)
{
    // TODO: Fully implement
    m_keyboardRowRegister = byte;
    cout << "Wrote $" << hex << setw(2) << (int)byte << " to keyboard register" << endl;
}

uint8_t Sim6502::read(uint16_t address)
{
    if (isRam(address) || isRom(address)) {
        return m_memory[address];
    }
    if (isVideo(address)) {
        return readVideo(address);
    }
    if (isPeripheral(address)) {
        return readPeripheral(address);
    }
    if (isKeyboard(address)) {
        return readKeyboard(address);
    }
    return 0; // Unused, read as zero                
}

uint8_t Sim6502::readPeripheral(uint16_t address)
{
    if (address == m_peripheralStart) {
        cout << "Read $" << hex << setw(2) << (int)m_6850_control_reg << " from MC680 Status Register" << endl;
        return m_6850_control_reg = 0;
    }
    if (address == m_peripheralStart + 1) {
        cout << "Read $" << hex << setw(2) << (int)m_6850_data_reg << " from MC680 Data Register" << endl;
        return m_6850_control_reg = 0;
    }
    assert(false); // Should never be reached
}

uint8_t Sim6502::readKeyboard(uint16_t address)
{
    static int tries = 0;

    // TODO: Fully implement
    cout << "Read from keyboard register" << endl;
    if (m_keyboardRowRegister == 0xfe) {
        cout << "Sending keyboard key Shift Lock" << endl;
        return 0xfe; // Return Shift Lock pressed when this row selected.
    }
    if ((m_keyboardRowRegister == 0xfb) && (tries < 3)) {
        tries++;
        //cout << "Sending keyboard key 'C'" << endl;
        //return 0x64; // Simulate sending "C" for BASIC cold start.
        cout << "Sending keyboard key 'M'" << endl;
        return 0xfb; // Simulate sending "M" for Monitor.
    } else {
        cout << "Sending no keyboard key pressed" << endl;
        return 0xff; // No key pressed
    }
}

uint8_t Sim6502::readVideo(uint16_t address)
{
    cout << "Read video RAM at $" << hex << setw(4) << address << endl;
    return m_memory[address];
}

bool Sim6502::isRam(uint16_t address)
{
    // TODO: May want to optimize using array lookup
    return (address >= m_ramStart && address <= m_ramEnd);
}

bool Sim6502::isRom(uint16_t address)
{
    // TODO: May want to optimize using array lookup
    return (address >= m_romStart && address <= m_romEnd);
}

bool Sim6502::isPeripheral(uint16_t address)
{
    // 6550 UART is two addresses.
    return address >= m_peripheralStart && address <= m_peripheralStart + 1;
}

bool Sim6502::isVideo(uint16_t address)
{
    return (address >= m_videoStart && address <= m_videoEnd);
}

bool Sim6502::isKeyboard(uint16_t address)
{
    // Keyboard is only one address
    return address == m_keyboardStart;
}

bool Sim6502::isUnused(uint16_t address)
{
    // TODO: May want to optimize using array lookup
    return (!isRam(address) && !isRom(address) &&!isPeripheral(address));
}

bool Sim6502::loadMemory(string filename, uint16_t startAddress)
{
    // TODO: Add support for file formats other than binary

    ifstream inFile;

    inFile.open(filename, ios::binary);
    if (inFile.is_open()) {
        for (int i = startAddress; i <= 0xffff; i++) {
            inFile.read((char*) &m_memory[i], 1);
        }
        inFile.close();
        return true;
    } else {
        cerr << "Error: Unable to open file '" << filename << "' for reading." << endl;
        return false;
    }
}

bool Sim6502::saveMemory(string filename, uint16_t startAddress, uint16_t endAddress)
{
    // TODO: Add support for file formats other than binary

    ofstream outFile;

    outFile.open(filename, ios::binary);
    if (outFile.is_open()) {
        for (int i = startAddress; i <= endAddress; i++) {
            outFile.write((const char*) &m_memory[i], 1);
        }
        outFile.close();
        return true;
    } else {
        cerr << "Error: Unable to open file '" << filename << "' for writing." << endl;
        return false;
    }
}

void Sim6502::setMemory(uint16_t startAddress, uint16_t endAddress, uint8_t byte)
{
    assert(startAddress <= endAddress);

    for (int i = startAddress; i <= endAddress; i++) {
        m_memory[i] = byte;
    }
}

void Sim6502::dumpMemory(uint16_t startAddress, uint16_t endAddress)
{
    assert(startAddress <= endAddress);

    for (int i = startAddress; i <= endAddress; i++) {

        if ((i == startAddress) || (i % 16 == 0)) {
            cout << endl << hex << setfill('0') << setw(4) << i << ":";
        }    
        cout << " " << setfill('0') << setw(2) << (int)m_memory[i];
    }
    cout << endl;
}

void Sim6502::dumpRegisters()
{
    string s;

    (m_regSR & S_BIT) ? s += "S" : s += "s";
    (m_regSR & V_BIT) ? s += "V" : s += "v";
    (m_regSR & X_BIT) ? s += "1" : s += "0";
    (m_regSR & B_BIT) ? s += "B" : s += "b";
    (m_regSR & D_BIT) ? s += "D" : s += "d";
    (m_regSR & I_BIT) ? s += "I" : s += "i";
    (m_regSR & Z_BIT) ? s += "Z" : s += "z";
    (m_regSR & C_BIT) ? s += "C" : s += "c";

    cout << hex << setfill('0') << "PC=" << setw(4) << m_regPC
         << " (" << setw(2) << (int)m_memory[m_regPC] << ")"
         << " A=" << setw(2) << (int)m_regA
         << " X=" << setw(2) << (int)m_regX
         << " Y=" << setw(2) << (int)m_regY
         << " SP=01" << setw(2) << (int)m_regSP
         << " SR=" << s << endl;
}

void Sim6502::dumpVideo()
{
    cout << "+------------------------+" << endl;

    for (int row = 0; row < 24; row++) {
        cout << "|";
        for (int col = 0; col < 24; col++) {
            char c = m_memory[0xd085 + (row * 32) + col];
            if ((c >= 0x20) && (c <= 0x7c)) {
                cout << c;
            } else {
                cout << ".";
            }
        }
        cout << "|" << endl;
    }
    cout << "+------------------------+" << endl;
}

void Sim6502::step()
{
    // This is written for speed and efficiency and not elegance and redability.

    // TODO: Fully implement

    int len = 1; // Instruction length
    uint8_t opcode = m_memory[m_regPC];
    uint8_t operand1 = m_memory[m_regPC + 1];
    uint8_t operand2 = m_memory[m_regPC + 2];
    uint8_t tmp;

    switch (opcode) {

    case 0x0a: // asla
        (m_regA & 0x80) ? m_regSR |= C_BIT : m_regSR &= ~C_BIT;; // Set C flag
        m_regA = (m_regA << 1) & 0xff; // Shift left
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        cout << "asla" << endl;
        break;

    case 0x10: // bpl
        if (!(m_regSR & S_BIT)) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        cout << "bpl $" << setw(2) << (int)operand1 << endl;
        break;

    case 0x18: // clc     
        m_regSR &= ~C_BIT;
        cout << "clc" << endl;
        break;

    case 0x20: // jsr xxxx
        write(STACK + m_regSP, (m_regPC + 2) >> 8); // Push PC high byte
        m_regSP--;
        write(STACK + m_regSP, (m_regPC + 2) & 0xff); // Push PC low byte
        m_regSP--;
        m_regPC = operand1 + 256 * operand2; // New PC
        cout << "jsr $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 0;
        break;

    case 0x29: // and #
        m_regA &= operand1;
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "and #$" << setw(2) << (int)operand1 << endl;
        len = 2;
        break;

    case 0x2a: // rola
        (m_regA & 0x80) ? m_regSR |= C_BIT : m_regSR &= ~C_BIT; // Set C flag
        m_regA = (m_regA << 1) & 0xff; // Shift left
        m_regA |= C_BIT; // Set LSB of A to C bit
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        cout << "rola" << endl;
        break;

    case 0x2c: // bit xxxx
        ((m_regA & read(operand1 + 256 * operand2)) == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        (read(operand1 + 256 * operand2) >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (read(operand1 + 256 * operand2) & 0x40) ? m_regSR |= V_BIT : m_regSR &= ~V_BIT;; // Set V flag
        cout << "bit $" << setw(4) << (int)(operand1 + 256 * operand2) << endl;
        len = 3;
        break;

    case 0x30: // bmi
        if (m_regSR & S_BIT) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        cout << "bmi $" << setw(2) << (int)operand1 << endl;
        break;

    case 0x38: // sec
        m_regSR |= C_BIT;
        cout << "sec" << endl;
        break;

    case 0x48: // pha
        write(STACK + m_regSP, m_regA);
        m_regSP--;
        cout << "pha" << endl;
        break;

    case 0x4a: // lsra
        (m_regA & 0x01) ? m_regSR |= C_BIT : m_regSR &= ~C_BIT;; // Set C flag
        m_regA >>= 1; // Shift right
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        m_regSR &= ~S_BIT; // Clear S flag
        cout << "lsra" << endl;
        break;

    case 0x49: // eor #
        m_regA ^= operand1;
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "eor #$" << setw(2) << (int)operand1 << endl;
        len = 2;
        break;

    case 0x4c: // jmp
        m_regPC = operand1 + 256 * operand2;
        cout << "jmp $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 0;
        break;

    case 0x60: // rts
        m_regSP++;
        m_regPC = read(STACK + m_regSP); // Pull PC low byte
        m_regSP++;
        m_regPC += read(STACK + m_regSP) << 8; // Pull PC high byte
        m_regPC++; // Increment PC by 1
        cout << "rts" << endl;
        len = 0;
        break;

    case 0x68: // pla
        m_regSP++;
        m_regA = read(STACK + m_regSP);
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "pla" << endl;
        break;

    case 0x69: // adc #xx
        m_regA += operand1; // Add immediate operand
        if (m_regSR & C_BIT) m_regA++; // Add 1 if carry set
        // TODO: Update S, V, Z, C flags
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT; // Set V flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        (m_regA >= 0x80) ? m_regSR |= C_BIT : m_regSR &= ~C_BIT; // Set C flag
        cout << "adc #$" << setw(2) << (int)operand1 << endl;
        len = 2;
        break;

    case 0x6d: // adc xxxx
        m_regA += read(operand1 + 256 * operand2); // Add operand
        if (m_regSR & C_BIT) m_regA++; // Add 1 if carry set
        // TODO: Update S, V, Z, C flags
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT; // Set V flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        (m_regA >= 0x80) ? m_regSR |= C_BIT : m_regSR &= ~C_BIT; // Set C flag
        cout << "adc $" << setw(4) << (int)operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0x88: // dey
        m_regY--;
        (m_regY >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regY == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "dey" << endl;
        break;

    case 0x8a: // txa
        m_regA = m_regX;
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "txa" << endl;
        break;

    case 0x8c: // sty xxxx
        write(operand1 + 256 * operand2, m_regY);
        cout << "sty $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0x8d: // sta xxxx
        write(operand1 + 256 * operand2, m_regA);
        cout << "sta $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0x8e: // stx xxxx
        write(operand1 + 256 * operand2, m_regX);
        cout << "stx $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0x90: // bcc
        if (!(m_regSR & C_BIT)) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        cout << "bcc $" << setw(2) << (int)operand1 << endl;
        break;

    case 0x98: // tya
        m_regA = m_regY;
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "tya" << endl;
        break;

    case 0x9a: // txs
        m_regSP = m_regX;
        cout << "txs" << endl;
        break;

    case 0x9d: // sta xxxx,x
        write(operand1 + 256 * operand2 + m_regX, m_regA);
        cout << "sta $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        len = 3;
        break;

    case 0x99: // sta xxxx,y
        write(operand1 + 256 * operand2 + m_regY, m_regA);
        cout << "sta $" << setw(4) << operand1 + 256 * operand2 << ",y" << endl;
        len = 3;
        break;

    case 0xa0: // ldy #
        m_regY = operand1;
        (m_regY >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regY == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "ldy #$" << setw(2) << (int)operand1 << endl;
        len = 2;
        break;

    case 0xa2: // ldx #
        m_regX = operand1;
        (m_regX >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regX == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "ldx #$" << setw(4) << (int)operand1 << endl;
        len = 2;
        break;

    case 0xa8: // tay
        m_regY = m_regA;
        (m_regY >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regY == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "tay" << endl;
        break;

    case 0xa9: // lda #
        m_regA = operand1;
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "lda #$" << setw(2) << (int)operand1 << endl;
        len = 2;
        break;

    case 0xaa: // tax
        m_regX = m_regA;
        (m_regX >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regX == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "tax" << endl;
        break;

    case 0xac: // ldy xxxx
        m_regY = read(operand1 + 256 * operand2);
        (m_regY >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regY == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "ldy $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xad: // lda xxxx
        m_regA = read(operand1 + 256 * operand2);
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "lda $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xae: // ldx xxxx
        m_regX = read(operand1 + 256 * operand2);
        (m_regX >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regX == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "ldx $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xb9: // lda xxxx,y
        m_regA = read(operand1 + 256 * operand2 + m_regY);
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "lda $" << setw(4) << operand1 + 256 * operand2 << ",y" << endl;
        len = 3;
        break;

    case 0xbd: // lda xxx,x
        m_regA = read(operand1 + 256 * operand2 + m_regX);
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "lda $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        len = 3;
        break;

    case 0xc8: // iny
        m_regY++;
        (m_regY >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regY == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "iny" << endl;
        break;

    case 0xc9: // cmp #
        // TODO: Set S flag
        (m_regA == operand1) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        // TODO: Set C flag
        cout << "cmp #$" << setw(2) << (int)operand1 << endl;
        len = 2;
        break;

    case 0xca: // dex
        m_regX--;
        (m_regX >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regX == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "dex" << endl;
        break;

    case 0xcd: // cmp xxxx
        // TODO: Set S flag
        (m_regA == read(operand1 + 256 * operand2)) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        // TODO: Set C flag
        cout << "cmp $" << setw(4) << (int)(operand1 + 256 * operand2) << endl;
        len = 3;
        break;

    case 0xd0: // bne
        if (!(m_regSR & Z_BIT)) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        cout << "bne $" << setw(2) << (int)operand1 << endl;
        break;

    case 0xce: // dec xxxx
        tmp = read(operand1 + 256 * operand2) - 1;
        write(operand1 + 256 * operand2, tmp);
        (tmp >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (tmp == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "dec $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xd8: // cld
        m_regSR &= ~D_BIT;
        cout << "cld" << endl;
        break;

    case 0xe0:// cpx #
        // TODO: Set S flag
        (m_regX == operand1) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        // TODO: Set C flag
        cout << "cpx #$" << setw(2) << (int)operand1 << endl;
        len = 2;
        break;

    case 0xe8: // inx
        m_regX++;
        (m_regX >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regX == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "inx" << endl;
        break;

    case 0xea: // nop
        cout << "nop" << endl;
        break;

    case 0xed: // sbc xxxx
        m_regA -= read(operand1 + 256 * operand2); // Add operand
        if (!(m_regSR & C_BIT)) m_regA--; // Subtract 1 if carry (borrow) not set
        // TODO: Update S, V, Z, C flags
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT; // Set V flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        (m_regA >= 0x80) ? m_regSR |= C_BIT : m_regSR &= ~C_BIT; // Set C flag
        cout << "sbc $" << setw(4) << (int)operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xee: // inc xxxx
        tmp = read(operand1 + 256 * operand2) + 1;
        write(operand1 + 256 * operand2, tmp);
        (tmp >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (tmp == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "inc $" << setw(4) << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xf0: // beq
        if (m_regSR & Z_BIT) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        cout << "beq $" << setw(2) << (int)operand1 << endl;
        break;

    case 0xf8: // sed
        // TODO: Handle decimal mode for relevant instructions
        m_regSR |= D_BIT;
        cout << "sed" << endl;
        break;

    default: // Invalid instruction, handle as NOP
        //cout << "???" << endl;
        cout << "??? unhandled opcode: " << setw(2) << (int) opcode << endl;
        exit(1);
        break;
    }

    m_regPC += len;
}
